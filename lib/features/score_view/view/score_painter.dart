import 'package:flutter/material.dart';
import '../model/song_model.dart';

class ScorePainter extends CustomPainter {
  final Track track;
  final int bpm;
  final int timeSignatureNumerator;
  final int timeSignatureDenominator;
  final int keySignature;
  final int currentMeasureIndex;
  final int currentBeatIndex;
  final double beatProgress;
  final bool isPlaying;
  final int selectedStaff;

  ScorePainter({
    required this.track,
    this.bpm = 120,
    this.timeSignatureNumerator = 4,
    this.timeSignatureDenominator = 4,
    this.keySignature = 0,
    this.currentMeasureIndex = -1,
    this.currentBeatIndex = -1,
    this.beatProgress = 0.0,
    this.isPlaying = false,
    this.selectedStaff = 0,
  });

  static const _marginLeft = 60.0;
  static const _marginTop = 50.0;
  static const _stringSpacing = 16.0;
  static const _noteSpacing = 32.0;
  static const _measurePadding = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final numStrings = track.strings;
    final tabHeight = (numStrings - 1) * _stringSpacing;
    final staffTopY = _marginTop;
    final tabTopY = staffTopY + 25;

    double currentX = _marginLeft;

    for (int m = 0; m < track.measures.length; m++) {
      final measure = track.measures[m];
      final isActive = m == currentMeasureIndex && isPlaying;

      final measureWidth = _calculateMeasureWidth(measure);

      if (isActive) {
        _drawActiveMeasureBackground(canvas, currentX, staffTopY, measureWidth, tabTopY + tabHeight);
      }

      _drawClef(canvas, currentX, staffTopY, tabTopY, numStrings);

      if (m == 0) {
        _drawKeySignature(canvas, currentX + 20, staffTopY, tabTopY, numStrings);
        _drawTimeSignature(canvas, currentX + 38, staffTopY, tabTopY, numStrings);
      }

      if (measure.tempo != null || (m == 0 && bpm != 120)) {
        _drawTempoMarking(canvas, currentX, staffTopY - 18, measure.tempo ?? bpm);
      }

      _drawMeasureNumber(canvas, currentX, staffTopY - 8, measure.number);

      _drawMeasureBorder(canvas, currentX, staffTopY, measureWidth, tabTopY, numStrings);
      _drawTabLines(canvas, currentX, tabTopY, measureWidth, numStrings);

      _drawBeats(
        canvas,
        measure,
        currentX + _measurePadding + 10,
        tabTopY,
        numStrings,
        staffTopY,
        isActive && m == currentMeasureIndex,
      );

      if (measure.timeSignatureNumerator != null) {
        _drawTimeSignature(canvas, currentX + 8, staffTopY, tabTopY, numStrings);
      }

      currentX += measureWidth;
    }

    _drawMeasureBorder(
      canvas,
      currentX,
      staffTopY,
      2,
      tabTopY,
      numStrings,
      isEnd: true,
    );
  }

  double _calculateMeasureWidth(Measure measure) {
    final beatCount = measure.beats.length;
    return beatCount * _noteSpacing + _measurePadding * 2 + 20;
  }

  void _drawActiveMeasureBackground(
    Canvas canvas,
    double x,
    double topY,
    double width,
    double bottomY,
  ) {
    canvas.drawRect(
      Rect.fromLTRB(x - 5, topY - 5, x + width + 5, bottomY + 5),
      Paint()
        ..color = Colors.blue.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawClef(
    Canvas canvas,
    double x,
    double staffTopY,
    double tabTopY,
    int numStrings,
  ) {
    if (track.isPercussion) {
      _drawPercussionClef(canvas, x, tabTopY, numStrings);
      return;
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: '𝄞',
      style: const TextStyle(
        fontSize: 28,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 18, staffTopY + 2));

    textPainter.text = TextSpan(
      text: '𝄞',
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black54,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 12, tabTopY - 4));
  }

  void _drawPercussionClef(Canvas canvas, double x, double tabTopY, int numStrings) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '𝄡',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 15, tabTopY + (numStrings * _stringSpacing) / 2 - 12));
  }

  void _drawKeySignature(
    Canvas canvas,
    double x,
    double staffTopY,
    double tabTopY,
    int numStrings,
  ) {
    if (keySignature == 0) return;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final isSharp = keySignature > 0;
    final count = keySignature.abs();
    final symbol = isSharp ? '♯' : '♭';

    final sharpPositions = [
      [2, 0],
      [3, 2],
      [1, 1],
      [2, 3],
      [0, 2],
      [1, 4],
      [3, 3],
    ];

    for (int i = 0; i < count && i < 7; i++) {
      if (isSharp && i < sharpPositions.length) {
        textPainter.text = TextSpan(
          text: symbol,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        );
      } else {
        textPainter.text = TextSpan(
          text: symbol,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        );
      }
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + i * 12, staffTopY + 5),
      );
    }
  }

  void _drawTimeSignature(
    Canvas canvas,
    double x,
    double staffTopY,
    double tabTopY,
    int numStrings,
  ) {
    final numStr = timeSignatureNumerator.toString();
    final denStr = timeSignatureDenominator.toString();

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: numStr,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, staffTopY + 2));

    textPainter.text = TextSpan(
      text: denStr,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, staffTopY + 18));
  }

  void _drawTempoMarking(Canvas canvas, double x, double y, int tempo) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
      text: '♪ = $tempo',
      style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawMeasureNumber(Canvas canvas, double x, double y, int number) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 2, y));
  }

  void _drawMeasureBorder(
    Canvas canvas,
    double x,
    double staffTopY,
    double width,
    double tabTopY,
    int numStrings,
    {bool isEnd = false}
  ) {
    final barPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = isEnd ? 2.5 : 1.5;

    final staffBottom = staffTopY + 20;
    final tabBottom = tabTopY + (numStrings - 1) * _stringSpacing;

    canvas.drawLine(
      Offset(x, staffTopY),
      Offset(x, staffBottom),
      barPaint,
    );

    canvas.drawLine(
      Offset(x, tabTopY),
      Offset(x, tabBottom),
      barPaint,
    );

    if (isEnd) {
      canvas.drawLine(
        Offset(x + 4, staffTopY),
        Offset(x + 4, staffBottom),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.5,
      );
      canvas.drawLine(
        Offset(x + 4, tabTopY),
        Offset(x + 4, tabBottom),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawTabLines(
    Canvas canvas,
    double x,
    double tabTopY,
    double width,
    int numStrings,
  ) {
    final linePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    for (int i = 0; i < numStrings; i++) {
      final y = tabTopY + i * _stringSpacing;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + width, y),
        linePaint,
      );
    }
  }

  void _drawBeats(
    Canvas canvas,
    Measure measure,
    double startX,
    double tabTopY,
    int numStrings,
    double staffTopY,
    bool isActiveMeasure,
  ) {
    double x = startX;
    const fretFontSize = 12.0;
    const symbolFontSize = 12.0;
    final tabBottom = tabTopY + (numStrings - 1) * _stringSpacing;

    for (int b = 0; b < measure.beats.length; b++) {
      final beat = measure.beats[b];
      final isActive = isActiveMeasure && b == currentBeatIndex;

      if (isActive) {
        canvas.drawCircle(
          Offset(x, tabTopY + (numStrings / 2) * _stringSpacing),
          12,
          Paint()
            ..color = Colors.blue.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill,
        );
      }

      if (beat.isRest) {
        _drawRest(canvas, x, tabTopY, tabBottom, numStrings, beat.duration, beat.direction);
      } else {
        _drawNotes(canvas, beat, x, tabTopY, numStrings, fretFontSize, isActive);
      }

      _drawDurationSymbol(canvas, beat, x, tabBottom + 4, symbolFontSize);
      _drawBeatText(canvas, beat, x, tabBottom + 18);

      if (beat.hasFermata) {
        _drawFermata(canvas, x, tabTopY - 8);
      }

      x += _noteSpacing;
    }
  }

  void _drawNotes(
    Canvas canvas,
    Beat beat,
    double x,
    double tabTopY,
    int numStrings,
    double fontSize,
    bool isActive,
  ) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (final note in beat.notes) {
      final stringIdx = note.stringNum - 1;
      if (stringIdx < 0 || stringIdx >= numStrings) continue;

      final y = tabTopY + stringIdx * _stringSpacing;
      var noteColor = isActive ? Colors.blue[800]! : Colors.blue[700]!;

      if (note.isDeadNote) {
        _drawDeadNote(canvas, x, y);
        continue;
      }

      if (note.isHarmonic) {
        _drawHarmonicNote(canvas, x, y, note.fret, textPainter, noteColor, fontSize);
        continue;
      }

      String fretStr = note.fret.toString();
      if (note.accidental != null) {
        fretStr = '${note.accidental}${note.fret}';
      }

      textPainter.text = TextSpan(
        text: fretStr,
        style: TextStyle(
          color: noteColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - fontSize / 2));

      if (note.isVibrato) {
        _drawVibrato(canvas, x + textPainter.width / 2 + 2, y);
      }

      if (note.isBend) {
        _drawBend(canvas, x + textPainter.width / 2 + 2, y - 8, note.bendStrength ?? 1);
      }

      if (note.isSlide) {
        _drawSlide(canvas, x, y, note.slideTarget, numStrings, tabTopY, note.stringNum);
      }
    }

    if (beat.notes.isNotEmpty) {
      final hasHammerOn = beat.notes.any((n) => n.isHammerOn);
      final hasPullOff = beat.notes.any((n) => n.isPullOff);

      if (hasHammerOn) {
        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: const TextSpan(
            text: 'H',
            style: TextStyle(fontSize: 9, color: Colors.black54),
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 3, tabTopY - 12));
      }

      if (hasPullOff) {
        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: const TextSpan(
            text: 'P',
            style: TextStyle(fontSize: 9, color: Colors.black54),
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 3, tabTopY - 12));
      }
    }
  }

  void _drawDeadNote(Canvas canvas, double x, double y) {
    canvas.drawLine(
      Offset(x - 4, y - 4),
      Offset(x + 4, y + 4),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(x + 4, y - 4),
      Offset(x - 4, y + 4),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5,
    );
  }

  void _drawHarmonicNote(
    Canvas canvas,
    double x,
    double y,
    int fret,
    TextPainter textPainter,
    Color color,
    double fontSize,
  ) {
    textPainter.text = TextSpan(
      text: fret.toString(),
      style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
    );
    textPainter.layout();

    canvas.drawCircle(
      Offset(x, y),
      textPainter.width / 2 + 2,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - fontSize / 2));
  }

  void _drawVibrato(Canvas canvas, double x, double y) {
    final path = Path();
    path.moveTo(x, y - 3);
    for (int i = 0; i < 3; i++) {
      path.lineTo(x + 2 + i * 2, y - 6);
      path.lineTo(x + 4 + i * 2, y);
      path.lineTo(x + 6 + i * 2, y - 6);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawBend(Canvas canvas, double x, double y, int strength) {
    final path = Path();
    path.moveTo(x, y + 8);
    path.quadraticBezierTo(x + 4, y, x + 8, y);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    final arrow = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '↑',
        style: TextStyle(fontSize: 8, color: Colors.black),
      ),
    );
    arrow.layout();
    arrow.paint(canvas, Offset(x + 6, y - 12));

    if (strength > 0) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: strength == 1 ? '(1)' : strength == 2 ? '(1½)' : '(2)',
          style: const TextStyle(fontSize: 7, color: Colors.black54),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 10, y - 8));
    }
  }

  void _drawSlide(
    Canvas canvas,
    double x,
    double y,
    int? targetFret,
    int numStrings,
    double tabTopY,
    int stringNum,
  ) {
    if (targetFret == null) return;

    final targetStringIdx = stringNum - 1;
    final targetY = tabTopY + targetStringIdx * _stringSpacing;

    canvas.drawLine(
      Offset(x, y),
      Offset(x + _noteSpacing * 0.8, targetY),
      Paint()
        ..color = Colors.blue.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      Offset(x + _noteSpacing * 0.8, targetY),
      2,
      Paint()..color = Colors.blue.withValues(alpha: 0.6),
    );
  }

  void _drawRest(
    Canvas canvas,
    double x,
    double tabTopY,
    double tabBottom,
    int numStrings,
    int duration,
    int direction,
  ) {
    final symbol = _getRestSymbol(duration);
    final centerY = tabTopY + (numStrings / 2 - 0.5) * _stringSpacing;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: symbol,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, centerY - 8),
    );
  }

  void _drawDurationSymbol(
    Canvas canvas,
    Beat beat,
    double x,
    double y,
    double fontSize,
  ) {
    if (beat.isRest) return;

    final symbol = _getDurationSymbol(beat.duration);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: fontSize,
          color: beat.duration <= 8 ? Colors.black : Colors.black54,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));

    if (beat.duration == 16) {
      _drawDoubleBeam(canvas, x, y - 10);
    } else if (beat.duration == 32) {
      _drawTripleBeam(canvas, x, y - 10);
    } else if (beat.duration == 8) {
      _drawSingleBeam(canvas, x, y - 10);
    }
  }

  void _drawSingleBeam(Canvas canvas, double x, double y) {
    canvas.drawLine(
      Offset(x - 6, y),
      Offset(x + 6, y),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
  }

  void _drawDoubleBeam(Canvas canvas, double x, double y) {
    canvas.drawLine(
      Offset(x - 6, y),
      Offset(x + 6, y),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(x - 6, y + 3),
      Offset(x + 6, y + 3),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
  }

  void _drawTripleBeam(Canvas canvas, double x, double y) {
    canvas.drawLine(
      Offset(x - 6, y),
      Offset(x + 6, y),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(x - 6, y + 3),
      Offset(x + 6, y + 3),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(x - 6, y + 6),
      Offset(x + 6, y + 6),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
  }

  void _drawBeatText(Canvas canvas, Beat beat, double x, double y) {
    if (beat.text == null) return;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: beat.text,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.black54,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  void _drawFermata(Canvas canvas, double x, double y) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '𝄐',
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  String _getDurationSymbol(int duration) {
    return switch (duration) {
      1 => '𝅝',
      2 => '𝅗𝅥',
      4 => '♩',
      8 => '♪',
      16 => '♫',
      32 => '♬',
      _ => '•',
    };
  }

  String _getRestSymbol(int duration) {
    return switch (duration) {
      1 => '𝄻',
      2 => '𝄼',
      4 => '𝄽',
      8 => '𝄾',
      16 => '𝄿',
      32 => '𝅀',
      _ => '𝄽',
    };
  }

  @override
  bool shouldRepaint(covariant ScorePainter oldDelegate) {
    return oldDelegate.currentMeasureIndex != currentMeasureIndex ||
        oldDelegate.currentBeatIndex != currentBeatIndex ||
        oldDelegate.beatProgress != beatProgress ||
        oldDelegate.isPlaying != isPlaying;
  }
}
