import 'package:supabase_flutter/supabase_flutter.dart';

/// Verifies a Play purchase token against the Google Play Developer API,
/// server-side, via the `verify-play-purchase` Supabase Edge Function (see
/// supabase/functions/verify-play-purchase) — and, on success, the edge
/// function itself marks the signed-in user premium in `profiles`. Never
/// trust a client-side "purchased" event alone for something this
/// gate-worthy; same reasoning and calling pattern as
/// `AccountDeletionService`.
class PurchaseVerificationService {
  const PurchaseVerificationService();

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> verify({required String purchaseToken}) async {
    final res = await _client.functions.invoke(
      'verify-play-purchase',
      body: {'purchaseToken': purchaseToken},
    );
    if (res.status != 200) {
      throw PurchaseVerificationException(
        _extractError(res.data) ?? 'No se pudo verificar la compra.',
      );
    }
  }

  String? _extractError(dynamic data) {
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return null;
  }
}

const purchaseVerificationService = PurchaseVerificationService();

class PurchaseVerificationException implements Exception {
  PurchaseVerificationException(this.message);
  final String message;
  @override
  String toString() => message;
}
