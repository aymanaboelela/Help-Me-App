import 'package:url_launcher/url_launcher.dart';

/// Attempts to open the phone dialer for [number].
///
/// Returns `true` if the dialer launched, `false` on any failure — callers use
/// this to show an error message instead of crashing.
Future<bool> dialNumber(String number) async {
  final Uri uri = Uri(scheme: 'tel', path: number);
  try {
    return await launchUrl(uri);
  } catch (_) {
    return false;
  }
}
