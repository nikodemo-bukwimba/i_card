import 'package:url_launcher/url_launcher.dart';

abstract class UrlHelper {
  static Future<void> launch(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}