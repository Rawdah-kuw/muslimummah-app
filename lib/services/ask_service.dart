import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AskSource {
  final String title;
  final dynamic page;
  final String slug;
  AskSource(this.title, this.page, this.slug);
  factory AskSource.fromJson(Map j) =>
      AskSource((j['title'] ?? '').toString(), j['page'], (j['slug'] ?? '').toString());
}

class AskResult {
  final String answer;
  final List<AskSource> sources;
  final bool notFound;
  AskResult(this.answer, this.sources, this.notFound);
}

/// Calls the existing "Ask the Library" endpoint on the live site.
class AskService {
  static Future<AskResult> ask(String question, String lang) async {
    final resp = await http.post(
      Uri.parse(Config.askEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'q': question, 'lang': lang}),
    );

    if (resp.statusCode == 429) {
      throw AskException(lang == 'ar'
          ? 'أكثرتَ من الأسئلة — انتظري دقيقة ثم أعيدي المحاولة.'
          : 'Too many questions — please wait a minute and try again.');
    }
    if (resp.statusCode != 200) {
      throw AskException(lang == 'ar'
          ? 'تعذّر الاتصال. تأكدي من الإنترنت ثم أعيدي المحاولة.'
          : 'Could not connect. Check your internet and try again.');
    }

    final j = jsonDecode(utf8.decode(resp.bodyBytes)) as Map;
    final sources = (j['sources'] as List? ?? [])
        .map((e) => AskSource.fromJson(e as Map))
        .toList();
    return AskResult(
      (j['answer'] ?? '').toString(),
      sources,
      j['notFound'] == true,
    );
  }
}

class AskException implements Exception {
  final String message;
  AskException(this.message);
  @override
  String toString() => message;
}
