import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads/writes the `profiles` row that's auto-created (with the username
/// chosen at signup) for every new user by the `handle_new_user` trigger.
class ProfileService {
  const ProfileService();

  static const _maxAvatarDimension = 512;
  static const _avatarJpegQuality = 82;

  SupabaseClient get _client => Supabase.instance.client;

  Future<String?> fetchDisplayName(String userId) async {
    final row = await _client
        .from('profiles')
        .select('display_name')
        .eq('id', userId)
        .maybeSingle();
    return row?['display_name'] as String?;
  }

  Future<void> updateDisplayName(String userId, String displayName) {
    return _client
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', userId);
  }

  Future<String?> fetchAvatarUrl(String userId) async {
    final row = await _client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    return row?['avatar_url'] as String?;
  }

  /// Downscales [bytes] to at most [_maxAvatarDimension] on its longest side
  /// and re-encodes as JPEG, uploads it to the `avatars` bucket and stamps
  /// the `profiles` row with its public URL (with a cache-busting query
  /// param, since the storage path — and so the URL — stays the same across
  /// re-uploads and `Image.network` would otherwise keep showing the old
  /// cached photo). Returns the new URL.
  Future<String> uploadAvatar(String userId, Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('No se pudo leer la imagen seleccionada');
    }
    final resized = decoded.width > decoded.height
        ? img.copyResize(decoded, width: _maxAvatarDimension)
        : img.copyResize(decoded, height: _maxAvatarDimension);
    final jpeg = img.encodeJpg(resized, quality: _avatarJpegQuality);

    final path = '$userId/avatar.jpg';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          Uint8List.fromList(jpeg),
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    final bustedUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    await _client
        .from('profiles')
        .update({'avatar_url': bustedUrl})
        .eq('id', userId);
    return bustedUrl;
  }

  Future<void> removeAvatar(String userId) async {
    await _client.storage.from('avatars').remove(['$userId/avatar.jpg']);
    await _client
        .from('profiles')
        .update({'avatar_url': null})
        .eq('id', userId);
  }
}

const profileService = ProfileService();
