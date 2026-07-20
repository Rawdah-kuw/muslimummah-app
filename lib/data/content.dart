import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

/// Loads the bundled static content (books, curriculum, wird, accounts).
/// Call [ContentRepo.load] once at startup.
class ContentRepo {
  static late List<Cat> bookCats;
  static late List<Book> books;

  static late List<Cat> plCats;
  static late Map<String, Map<String, dynamic>> plChannels;
  static late Map<String, Map<String, dynamic>> plLevels;
  static late List<Playlist> playlists;

  static late List<Wird> wird;

  static late List<Account> youtube;
  static late List<Account> instagram;

  static late List<Dhikr> adhkarMorning;
  static late List<Dhikr> adhkarEvening;

  static Future<void> load() async {
    final booksJson =
        jsonDecode(await rootBundle.loadString('assets/data/books.json'));
    bookCats = (booksJson['cats'] as List).map((e) => Cat.fromJson(e)).toList();
    books = (booksJson['books'] as List).map((e) => Book.fromJson(e)).toList();

    final cur =
        jsonDecode(await rootBundle.loadString('assets/data/curriculum.json'));
    plCats = (cur['cats'] as List).map((e) => Cat.fromJson(e)).toList();
    plChannels = (cur['channels'] as Map).map(
        (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)));
    plLevels = (cur['levels'] as Map).map(
        (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)));
    playlists =
        (cur['playlists'] as List).map((e) => Playlist.fromJson(e)).toList();

    final wj = jsonDecode(await rootBundle.loadString('assets/data/wird.json'));
    wird = (wj as List).map((e) => Wird.fromJson(e)).toList();

    final acc =
        jsonDecode(await rootBundle.loadString('assets/data/accounts.json'));
    youtube =
        (acc['youtube'] as List).map((e) => Account.fromJson(e)).toList();
    instagram =
        (acc['instagram'] as List).map((e) => Account.fromJson(e)).toList();

    final adh =
        jsonDecode(await rootBundle.loadString('assets/data/adhkar.json'));
    adhkarMorning =
        (adh['morning'] as List).map((e) => Dhikr.fromJson(e)).toList();
    adhkarEvening =
        (adh['evening'] as List).map((e) => Dhikr.fromJson(e)).toList();
  }

  static Book? bookById(int id) {
    for (final b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Wird that changes daily based on the day-of-year.
  static Wird wirdOfToday() {
    final now = DateTime.now();
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays;
    return wird[dayOfYear % wird.length];
  }

  static List<Book> booksByCat(String cat) =>
      cat == 'all' ? books : books.where((b) => b.cat == cat).toList();

  static List<Playlist> playlistsBySci(String sci) =>
      sci == 'all' ? playlists : playlists.where((p) => p.sci == sci).toList();

  static int playlistCountBySci(String sci) => playlistsBySci(sci).length;
}
