/// Plain data models parsed from the bundled JSON assets and Supabase.

class Cat {
  final String key;
  final Map<String, dynamic> label;
  Cat(this.key, this.label);
  factory Cat.fromJson(Map j) =>
      Cat(j['key'] as String, {'ar': j['ar'], 'en': j['en']});
}

class Book {
  final int id;
  final String cat;
  final bool bilingual;
  final String? lang; // "en" for English-only books
  final int pages;
  final String size;
  final String fileAr;
  final String? fileEn;
  final Map<String, dynamic> title;
  final Map<String, dynamic> author;
  final Map<String, dynamic> desc;

  Book({
    required this.id,
    required this.cat,
    required this.bilingual,
    required this.lang,
    required this.pages,
    required this.size,
    required this.fileAr,
    required this.fileEn,
    required this.title,
    required this.author,
    required this.desc,
  });

  String get slug =>
      fileAr.split('/').last.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

  factory Book.fromJson(Map j) => Book(
        id: j['id'] as int,
        cat: j['cat'] as String,
        bilingual: j['bilingual'] == true,
        lang: j['lang'] as String?,
        pages: (j['pages'] ?? 0) as int,
        size: (j['size'] ?? '') as String,
        fileAr: j['fileAr'] as String,
        fileEn: j['fileEn'] as String?,
        title: Map<String, dynamic>.from(j['title']),
        author: Map<String, dynamic>.from(j['author']),
        desc: Map<String, dynamic>.from(j['desc']),
      );
}

class PlaylistSource {
  final String ch;
  final String url;
  PlaylistSource(this.ch, this.url);
  factory PlaylistSource.fromJson(Map j) =>
      PlaylistSource(j['ch'] as String, j['url'] as String);
}

class Playlist {
  final int id;
  final String sci;
  final int level;
  final Map<String, dynamic> title;
  final List<PlaylistSource> sources;

  Playlist({
    required this.id,
    required this.sci,
    required this.level,
    required this.title,
    required this.sources,
  });

  factory Playlist.fromJson(Map j) => Playlist(
        id: j['id'] as int,
        sci: j['sci'] as String,
        level: j['level'] as int,
        title: Map<String, dynamic>.from(j['title']),
        sources: (j['sources'] as List)
            .map((e) => PlaylistSource.fromJson(e as Map))
            .toList(),
      );
}

class Wird {
  final String type; // ayah | hadith | dua
  final String ar;
  final String en;
  final Map<String, dynamic> source;
  Wird(this.type, this.ar, this.en, this.source);
  factory Wird.fromJson(Map j) => Wird(
        j['type'] as String,
        j['ar'] as String,
        j['en'] as String,
        Map<String, dynamic>.from(j['source']),
      );
}

class Account {
  final int id;
  final String url;
  final String handle;
  final Map<String, dynamic> name;
  final Map<String, dynamic> subtitle; // topic (YT) or focus (IG)
  final bool feat;
  final bool official;

  Account({
    required this.id,
    required this.url,
    required this.handle,
    required this.name,
    required this.subtitle,
    required this.feat,
    required this.official,
  });

  factory Account.fromJson(Map j) => Account(
        id: j['id'] as int,
        url: j['url'] as String,
        handle: (j['handle'] ?? '') as String,
        name: Map<String, dynamic>.from(j['name']),
        subtitle: Map<String, dynamic>.from(j['topic'] ?? j['focus'] ?? {}),
        feat: j['feat'] == true,
        official: j['official'] == true,
      );
}

/// A Rawdah dhikr lesson coming from Supabase.
class Lesson {
  final dynamic id;
  final String title;
  final String teacher;
  String gender; // نساء | رجال (may be inferred)
  final String day;
  final String time;
  final String area;
  final String location;
  final List<String> types;
  final String instagram;
  final String phone;
  final String channelLink;
  final String zoomLink;
  final String zoomPasscode;
  final String? lessonDate;
  final bool isRecurring;

  Lesson({
    required this.id,
    required this.title,
    required this.teacher,
    required this.gender,
    required this.day,
    required this.time,
    required this.area,
    required this.location,
    required this.types,
    required this.instagram,
    required this.phone,
    required this.channelLink,
    required this.zoomLink,
    required this.zoomPasscode,
    required this.lessonDate,
    required this.isRecurring,
  });

  bool get isWomen => gender.contains('نساء');

  factory Lesson.fromJson(Map j) {
    String s(String k) => (j[k] ?? '').toString().trim();
    List<String> typeList() {
      final t = j['types'];
      if (t is List) return t.map((e) => e.toString()).toList();
      return [];
    }

    return Lesson(
      id: j['id'],
      title: s('title'),
      teacher: s('teacher'),
      gender: s('gender'),
      day: s('day'),
      time: s('time'),
      area: s('area'),
      location: s('location'),
      types: typeList(),
      instagram: s('instagram'),
      phone: s('phone'),
      channelLink: s('channel_link'),
      zoomLink: s('zoom_link'),
      zoomPasscode: s('zoom_passcode'),
      lessonDate: (j['lesson_date'] == null || s('lesson_date').isEmpty)
          ? null
          : s('lesson_date'),
      isRecurring: j['is_recurring'] == true,
    );
  }
}
