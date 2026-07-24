import 'package:url_launcher/url_launcher.dart';

/// Opens the device's maps app searching for nearby hospitals.
///
/// Tries the `geo:` scheme first (opens a maps app directly), then falls back
/// to a universal Google Maps web link. Uses the device's own location — the
/// app never reads or stores it.
Future<bool> openNearestHospital() async {
  final Uri geo = Uri.parse('geo:0,0?q=hospital');
  try {
    if (await canLaunchUrl(geo)) {
      return await launchUrl(geo);
    }
  } catch (_) {
    // fall through to the web link
  }
  final Uri web = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=hospital',
  );
  try {
    return await launchUrl(web, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
