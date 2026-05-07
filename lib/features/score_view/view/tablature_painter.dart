import 'package:flutter/material.dart';
import '../model/song_model.dart';

class TablaturePainter extends CustomPainter {
  final Track track;

  TablaturePainter(this.track);

  static const _margin = 40.0;
  static const _stringSpacing = 18.0;
  static const _noteSpacing = 28.0;
  static const _measureBarSpacing = 30.0;
  static const _fretFontSize = 13.0;
  static const _durationSymbolSize = 14.0;
  static const _measureNumberSize = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1.2;

    final barPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1.5;

    final fretTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final symbolTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final measureTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final numStrings = track.strings;
    final tabHeight = (numStrings - 1) * _stringSpacing;
    final startY = _margin + tabHeight / 2;

    _drawStrings(canvas, size, linePaint, numStrings, startY);
    _drawMeasures(canvas, size, barPaint, fretTextPainter, symbolTextPainter,
        measureTextPainter, numStrings, startY);
  }

  void _drawStrings(
    Canvas canvas,
    Size size,
    Paint paint,
    int numStrings,
    double startY,
  ) {
    for (int i = 0; i < numStrings; i++) {
      final y = startY + i * _stringSpacing;
      canvas.drawLine(
        Offset(_margin, y),
        Offset(size.width - _margin, y),
        paint,
      );
    }
  }

  void _drawMeasures(
    Canvas canvas,
    Size size,
    Paint barPaint,
    TextPainter fretPainter,
    TextPainter symbolPainter,
    TextPainter measurePainter,
    int numStrings,
    double startY,
  ) {
    double currentX = _margin;

    for (int m = 0; m < track.measures.length; m++) {
      final measure = track.measures[m];

      measurePainter.text = TextSpan(
        text: '${measure.number}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: _measureNumberSize,
          fontWeight: FontWeight.w500,
        ),
      );
      measurePainter.layout();
      measurePainter.paint(canvas, Offset(currentX - 15, startY - 25));

      canvas.drawLine(
        Offset(currentX, startY - _stringSpacing),
        Offset(currentX, startY + (numStrings - 1) * _stringSpacing),
        barPaint,
      );

      double beatX = currentX + 10;

      for (final beat in measure.beats) {
        if (beat.isRest) {
          final symbol = _getRestSymbol(beat.duration);
          symbolPainter.text = TextSpan(
            text: symbol,
            style: TextStyle(
              color: Colors.black,
              fontSize: _durationSymbolSize,
            ),
          );
          symbolPainter.layout();

          final restY = startY + (numStrings / 2 - 0.5) * _stringSpacing;
          symbolPainter.paint(
            canvas,
            Offset(beatX - symbolPainter.width / 2, restY - 8),
          );

          beatX += _noteSpacing;
        } else {
          String? highestFretSymbol;
          double? highestFretY;

          for (final note in beat.notes) {
            final fretStr = note.fret.toString();
            final stringIdx = note.stringNum - 1;
            final noteY =
                stringIdx >= 0 && stringIdx < numStrings
                    ? startY + stringIdx * _stringSpacing
                    : startY;

            fretPainter.text = TextSpan(
              text: fretStr,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: _fretFontSize,
                fontWeight: FontWeight.w600,
              ),
            );
            fretPainter.layout();

            final xPos = beatX - fretPainter.width / 2;
            final yPos = noteY - fretPainter.height / 2;
            fretPainter.paint(canvas, Offset(xPos, yPos));

            if (highestFretSymbol == null || noteY < (highestFretY ?? double.infinity)) {
              highestFretSymbol = _getDurationSymbol(beat.duration);
              highestFretY = noteY;
            }
          }

          if (highestFretSymbol != null && beat.notes.isNotEmpty) {
            symbolPainter.text = TextSpan(
              text: highestFretSymbol,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: _durationSymbolSize,
              ),
            );
            symbolPainter.layout();

            symbolPainter.paint(
              canvas,
              Offset(
                beatX - symbolPainter.width / 2,
                startY + numStrings * _stringSpacing + 2,
              ),
            );
          }

          beatX += _noteSpacing;
        }
      }

      final measureEndX = beatX + _measureBarSpacing / 2;
      currentX = measureEndX;
    }

    if (track.measures.isNotEmpty) {
      canvas.drawLine(
        Offset(currentX - _measureBarSpacing / 2, startY - _stringSpacing),
        Offset(
            currentX - _measureBarSpacing / 2,
            startY + (numStrings - 1) * _stringSpacing),
        barPaint,
      );
    }
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
  bool shouldRepaint(covariant TablaturePainter oldDelegate) {
    return oldDelegate.track != track;
  }

  @override
  bool shouldRebuildSemantics(covariant TablaturePainter oldDelegate) => false;
}
