import 'package:url_launcher/url_launcher.dart';

/// The kinds of place the app can send someone looking for.
///
/// Each carries the search term in both languages: a maps search for "صيدلية"
/// finds far more on an Egyptian street than one for "pharmacy" does.
enum NearbyPlace {
  hospital(en: 'hospital', ar: 'مستشفى'),
  pharmacy(en: 'pharmacy', ar: 'صيدلية'),
  bloodBank(en: 'blood bank', ar: 'بنك دم'),
  clinic(en: 'clinic', ar: 'عيادة');

  const NearbyPlace({required this.en, required this.ar});

  final String en;
  final String ar;

  String query(String languageCode) => languageCode == 'ar' ? ar : en;
}

/// Opens the device's own maps app on a search for [place].
///
/// Tries the `geo:` scheme first, which hands the search to whichever maps app
/// the phone actually uses, then falls back to a universal Google Maps link.
///
/// **No location permission is involved.** The maps app works out where the user
/// is; this app never asks for, reads, or stores a position. That is a
/// deliberate constraint — a first-aid guide has no business holding somebody's
/// movements — and it costs nothing, because the maps app does the job better.
Future<bool> openNearby(NearbyPlace place, {String languageCode = 'en'}) async {
  final String term = Uri.encodeComponent(place.query(languageCode));

  final Uri geo = Uri.parse('geo:0,0?q=$term');
  try {
    if (await canLaunchUrl(geo)) {
      return await launchUrl(geo);
    }
  } catch (_) {
    // Fall through to the web link.
  }

  final Uri web =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$term');
  try {
    return await launchUrl(web, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// The emergency screen's one-tap hospital button.
Future<bool> openNearestHospital({String languageCode = 'en'}) =>
    openNearby(NearbyPlace.hospital, languageCode: languageCode);
