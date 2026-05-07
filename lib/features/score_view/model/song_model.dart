import 'dart:convert';

class Song {
  final String title;
  final String artist;
  final String album;
  final int bpm;
  final int timeSignatureNumerator;
  final int timeSignatureDenominator;
  final int keySignature;
  final List<Track> tracks;

  Song({
    required this.title,
    required this.artist,
    this.album = '',
    this.bpm = 120,
    this.timeSignatureNumerator = 4,
    this.timeSignatureDenominator = 4,
    this.keySignature = 0,
    required this.tracks,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String? ?? 'Unknown',
      artist: json['artist'] as String? ?? 'Unknown',
      album: json['album'] as String? ?? '',
      bpm: json['bpm'] as int? ?? 120,
      timeSignatureNumerator: json['timeSignatureNumerator'] as int? ?? 4,
      timeSignatureDenominator: json['timeSignatureDenominator'] as int? ?? 4,
      keySignature: json['keySignature'] as int? ?? 0,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => Track.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'bpm': bpm,
      'timeSignatureNumerator': timeSignatureNumerator,
      'timeSignatureDenominator': timeSignatureDenominator,
      'keySignature': keySignature,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }

  static Song fromJsonString(String jsonString) {
    return Song.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }
}

class Track {
  final String name;
  final int strings;
  final List<int> stringTunings;
  final bool isPercussion;
  final List<Measure> measures;

  Track({
    required this.name,
    required this.strings,
    this.stringTunings = const [40, 45, 50, 55, 59, 64],
    this.isPercussion = false,
    required this.measures,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'] as String? ?? 'Track',
      strings: json['strings'] as int? ?? 6,
      stringTunings: (json['stringTunings'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [40, 45, 50, 55, 59, 64],
      isPercussion: json['isPercussion'] as bool? ?? false,
      measures: (json['measures'] as List<dynamic>?)
              ?.map((m) => Measure.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'strings': strings,
      'stringTunings': stringTunings,
      'isPercussion': isPercussion,
      'measures': measures.map((m) => m.toJson()).toList(),
    };
  }
}

class Measure {
  final int number;
  final int? timeSignatureNumerator;
  final int? timeSignatureDenominator;
  final int? tempo;
  final List<Beat> beats;

  Measure({
    required this.number,
    this.timeSignatureNumerator,
    this.timeSignatureDenominator,
    this.tempo,
    required this.beats,
  });

  factory Measure.fromJson(Map<String, dynamic> json) {
    return Measure(
      number: json['number'] as int? ?? 0,
      timeSignatureNumerator: json['timeSignatureNumerator'] as int?,
      timeSignatureDenominator: json['timeSignatureDenominator'] as int?,
      tempo: json['tempo'] as int?,
      beats: (json['beats'] as List<dynamic>?)
              ?.map((b) => Beat.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'timeSignatureNumerator': timeSignatureNumerator,
      'timeSignatureDenominator': timeSignatureDenominator,
      'tempo': tempo,
      'beats': beats.map((b) => b.toJson()).toList(),
    };
  }
}

class Beat {
  final List<Note> notes;
  final int duration;
  final bool isRest;
  final bool hasFermata;
  final String? text;
  final int direction;

  Beat({
    required this.notes,
    required this.duration,
    this.isRest = false,
    this.hasFermata = false,
    this.text,
    this.direction = -1,
  });

  factory Beat.fromJson(Map<String, dynamic> json) {
    final notesData = json['notes'] as List<dynamic>?;
    return Beat(
      notes: notesData
              ?.map((n) => Note.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      duration: json['duration'] as int? ?? 4,
      isRest: json['isRest'] as bool? ?? false,
      hasFermata: json['hasFermata'] as bool? ?? false,
      text: json['text'] as String?,
      direction: json['direction'] as int? ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes': notes.map((n) => n.toJson()).toList(),
      'duration': duration,
      'isRest': isRest,
      'hasFermata': hasFermata,
      'text': text,
      'direction': direction,
    };
  }
}

class Note {
  final int stringNum;
  final int fret;
  final String? accidental;
  final bool isTieOrigin;
  final bool isTieDestination;
  final bool isDeadNote;
  final bool isHammerOn;
  final bool isPullOff;
  final bool isSlide;
  final int? slideTarget;
  final bool isVibrato;
  final bool isBend;
  final int? bendStrength;
  final bool isHarmonic;
  final int? ghostFret;

  Note({
    required this.stringNum,
    required this.fret,
    this.accidental,
    this.isTieOrigin = false,
    this.isTieDestination = false,
    this.isDeadNote = false,
    this.isHammerOn = false,
    this.isPullOff = false,
    this.isSlide = false,
    this.slideTarget,
    this.isVibrato = false,
    this.isBend = false,
    this.bendStrength,
    this.isHarmonic = false,
    this.ghostFret,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      stringNum: json['string'] as int? ?? 1,
      fret: json['value'] as int? ?? 0,
      accidental: json['accidental'] as String?,
      isTieOrigin: json['isTieOrigin'] as bool? ?? false,
      isTieDestination: json['isTieDestination'] as bool? ?? false,
      isDeadNote: json['isDeadNote'] as bool? ?? false,
      isHammerOn: json['isHammerOn'] as bool? ?? false,
      isPullOff: json['isPullOff'] as bool? ?? false,
      isSlide: json['isSlide'] as bool? ?? false,
      slideTarget: json['slideTarget'] as int?,
      isVibrato: json['isVibrato'] as bool? ?? false,
      isBend: json['isBend'] as bool? ?? false,
      bendStrength: json['bendStrength'] as int?,
      isHarmonic: json['isHarmonic'] as bool? ?? false,
      ghostFret: json['ghostFret'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'string': stringNum,
      'value': fret,
      'accidental': accidental,
      'isTieOrigin': isTieOrigin,
      'isTieDestination': isTieDestination,
      'isDeadNote': isDeadNote,
      'isHammerOn': isHammerOn,
      'isPullOff': isPullOff,
      'isSlide': isSlide,
      'slideTarget': slideTarget,
      'isVibrato': isVibrato,
      'isBend': isBend,
      'bendStrength': bendStrength,
      'isHarmonic': isHarmonic,
      'ghostFret': ghostFret,
    };
  }
}
