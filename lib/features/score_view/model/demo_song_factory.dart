import '../model/song_model.dart';

class DemoSongFactory {
  static Song createRockDemo() {
    return Song(
      title: 'Rock Demo',
      artist: 'Guitar TuxGuitar',
      album: 'Demo Songs',
      bpm: 120,
      timeSignatureNumerator: 4,
      timeSignatureDenominator: 4,
      keySignature: 0,
      tracks: [
        Track(
          name: 'Guitarra 1',
          strings: 6,
          stringTunings: [40, 45, 50, 55, 59, 64],
          isPercussion: false,
          measures: [
            Measure(
              number: 1,
              beats: [
                Beat(
                  notes: [
                    Note(stringNum: 6, fret: 0),
                    Note(stringNum: 5, fret: 0),
                  ],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 3)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 0)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 2)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 2,
              beats: [
                Beat(
                  notes: [Note(stringNum: 3, fret: 0)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 2)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 0)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 1)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 0)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 3,
              beats: [
                Beat(
                  notes: [
                    Note(stringNum: 6, fret: 3, accidental: '#'),
                    Note(stringNum: 5, fret: 5),
                  ],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 7, isBend: true, bendStrength: 1)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 5)],
                  duration: 4,
                ),
                Beat(
                  notes: [
                    Note(stringNum: 3, fret: 4, accidental: '#'),
                    Note(stringNum: 2, fret: 5),
                  ],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 4,
              beats: [
                Beat(
                  notes: [Note(stringNum: 1, fret: 0)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 1)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 3)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 5)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 3)],
                  duration: 4,
                ),
                Beat(
                  isRest: true,
                  notes: [],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 5,
              tempo: 100,
              beats: [
                Beat(
                  notes: [Note(stringNum: 6, fret: 5)],
                  duration: 4,
                ),
                Beat(
                  isRest: true,
                  notes: [],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 7)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 8)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 7)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 6,
              beats: [
                Beat(
                  notes: [Note(stringNum: 3, fret: 9, isVibrato: true)],
                  duration: 2,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 11)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 9)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 7,
              beats: [
                Beat(
                  notes: [Note(stringNum: 6, fret: 0, isDeadNote: true)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 6, fret: 0, isDeadNote: true)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 0, isDeadNote: true)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 0, isDeadNote: true)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 0)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 8,
              beats: [
                Beat(
                  notes: [Note(stringNum: 1, fret: 5, isHarmonic: true)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 7, isHarmonic: true)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 8, isHarmonic: true)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 9, isHarmonic: true)],
                  duration: 4,
                  hasFermata: true,
                ),
              ],
            ),
          ],
        ),
        Track(
          name: 'Baixo',
          strings: 4,
          stringTunings: [43, 48, 53, 58],
          isPercussion: false,
          measures: [
            Measure(
              number: 1,
              beats: [
                Beat(
                  notes: [Note(stringNum: 4, fret: 0)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 3)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 0)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 2)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 2,
              beats: [
                Beat(
                  notes: [Note(stringNum: 2, fret: 0)],
                  duration: 4,
                ),
                Beat(
                  isRest: true,
                  notes: [],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 1)],
                  duration: 4,
                ),
                Beat(
                  isRest: true,
                  notes: [],
                  duration: 4,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Song createBluesDemo() {
    return Song(
      title: 'Blues in E',
      artist: 'Guitar TuxGuitar',
      album: 'Demo Songs',
      bpm: 90,
      timeSignatureNumerator: 4,
      timeSignatureDenominator: 4,
      keySignature: 4,
      tracks: [
        Track(
          name: 'Guitarra Blues',
          strings: 6,
          stringTunings: [40, 45, 50, 55, 59, 64],
          measures: [
            Measure(
              number: 1,
              beats: [
                Beat(
                  notes: [
                    Note(stringNum: 6, fret: 0),
                    Note(stringNum: 5, fret: 2),
                  ],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 4)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 0)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 2)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 2,
              beats: [
                Beat(
                  notes: [
                    Note(stringNum: 3, fret: 0),
                    Note(stringNum: 2, fret: 1),
                  ],
                  duration: 8,
                ),
                Beat(
                  notes: [
                    Note(stringNum: 2, fret: 3),
                    Note(stringNum: 1, fret: 1),
                  ],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 3, isBend: true, bendStrength: 2)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 0)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 3,
              beats: [
                Beat(
                  isRest: true,
                  notes: [],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 6, fret: 3)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 6, fret: 5)],
                  duration: 8,
                ),
                Beat(
                  notes: [
                    Note(stringNum: 5, fret: 4, accidental: '#'),
                    Note(stringNum: 5, fret: 7),
                  ],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 4,
              beats: [
                Beat(
                  notes: [Note(stringNum: 4, fret: 5, isVibrato: true)],
                  duration: 2,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 3)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 5)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 5,
              beats: [
                Beat(
                  notes: [Note(stringNum: 1, fret: 5)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 1, fret: 7)],
                  duration: 8,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 5)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 8)],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 6,
              beats: [
                Beat(
                  notes: [
                    Note(stringNum: 3, fret: 7),
                    Note(stringNum: 4, fret: 7),
                  ],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 5, fret: 7)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 6, fret: 7)],
                  duration: 4,
                ),
                Beat(
                  isRest: true,
                  notes: [],
                  duration: 4,
                ),
              ],
            ),
            Measure(
              number: 7,
              beats: [
                Beat(
                  notes: [Note(stringNum: 1, fret: 12, isHarmonic: true)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 2, fret: 12, isHarmonic: true)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 3, fret: 12, isHarmonic: true)],
                  duration: 4,
                ),
                Beat(
                  notes: [Note(stringNum: 4, fret: 12, isHarmonic: true)],
                  duration: 4,
                  hasFermata: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
