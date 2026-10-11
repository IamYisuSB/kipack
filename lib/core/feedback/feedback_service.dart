import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum FeedbackType { bug, suggestion }

const supportEmail = 'fooserd@gmail.com';

/// Opens the user's email app with a pre-filled message to [supportEmail].
/// No backend involved — the user sends it from their own mail account, so
/// replies go straight back to them.
class FeedbackService {
  const FeedbackService();

  /// Returns false if no email app could handle the `mailto:` link.
  Future<bool> openEmail({
    required FeedbackType type,
    required String message,
  }) async {
    final info = await PackageInfo.fromPlatform();
    final label = type == FeedbackType.bug ? 'Bug' : 'Sugerencia';
    final subject = '[Kipack] $label';
    final body = '$message\n\n---\nKipack v${info.version} (${info.buildNumber})';
    // Encoded by hand: Uri(queryParameters:) turns spaces into '+', which
    // most mail apps then show literally.
    final uri = Uri.parse(
      'mailto:$supportEmail'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}

const feedbackService = FeedbackService();
