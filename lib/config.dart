/// App-wide constants. The Supabase publishable (anon) key is public and safe
/// to ship in a client app, per the project delivery notes.
class Config {
  static const String baseUrl = 'https://muslimummah.app';
  static const String askEndpoint = '$baseUrl/api/ask';

  static const String supabaseUrl = 'https://buvsgjiqtaftyexjvyzw.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_kRtGr0a2Tun1CQweltlxjw_qfQRQGTr';

  static const String contactEmail = 'muslimsummah.app@gmail.com';
  static const String aliYoutube = 'https://www.youtube.com/@For_AliAlseddiqi';
  static const String rawdahWhatsapp =
      'https://chat.whatsapp.com/J394CWBV7zw3aIexoulZAQ';

  /// Trusted fatwa sites used by the "Trusted Sites" search tab.
  static const List<String> approvedSites = [
    'binbaz.org.sa',
    'binothaimeen.net',
    'dorar.net',
    'aliftaksa.com',
    'islamweb.net',
  ];

  /// Turn a book file path into a full URL on the live site.
  static String fileUrl(String path) => '$baseUrl$path';
}
