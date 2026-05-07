package com.tuxguitar.api.service;

import com.tuxguitar.api.model.*;
import app.tuxguitar.io.base.TGFileFormatManager;
import app.tuxguitar.io.base.TGSongReaderHandle;
import app.tuxguitar.song.factory.TGFactory;
import app.tuxguitar.song.managers.TGSongManager;
import app.tuxguitar.song.models.*;
import app.tuxguitar.song.models.effects.TGEffectBend;
import app.tuxguitar.util.TGContext;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

@Service
public class TabParserService {

    private final TGContext context;
    private final TGFactory factory;
    private final TGFileFormatManager fileFormatManager;
    private final TGSongManager songManager;

    public TabParserService() {
        this.context = new TGContext();
        this.factory = new TGFactory();
        this.fileFormatManager = TGFileFormatManager.getInstance(context);
        this.songManager = new TGSongManager(factory);
    }

    public SongResponse parseSong(InputStream inputStream) throws Exception {
        TGSongReaderHandle handle = new TGSongReaderHandle();
        handle.setFactory(factory);
        handle.setInputStream(inputStream);
        fileFormatManager.read(handle);
        TGSong song = handle.getSong();

        SongResponse response = new SongResponse();
        response.setTitle(song.getName() != null ? song.getName() : "Unknown");
        response.setArtist(song.getArtist() != null ? song.getArtist() : "Unknown");
        response.setAlbum(song.getAlbum() != null ? song.getAlbum() : "");

        if (song.countMeasureHeaders() > 0) {
            TGMeasureHeader firstHeader = song.getMeasureHeader(0);
            if (firstHeader != null) {
                TGTimeSignature timeSig = firstHeader.getTimeSignature();
                response.setTimeSignatureNumerator(timeSig.getNumerator());
                response.setTimeSignatureDenominator(timeSig.getDenominator().getValue());
                if (firstHeader.getTempo() != null) {
                    response.setBpm(firstHeader.getTempo().getQuarterValue());
                }
            }
        }

        List<TrackResponse> tracks = new ArrayList<>();
        int trackCount = song.countTracks();

        for (int t = 0; t < trackCount; t++) {
            TGTrack track = song.getTrack(t);
            TrackResponse trackResponse = new TrackResponse();
            trackResponse.setName(track.getName() != null ? track.getName() : "Track " + (t + 1));
            trackResponse.setStrings(track.stringCount());
            trackResponse.setStringTunings(getStringTunings(track));
            trackResponse.setPercussion(track.isPercussion());

            List<MeasureResponse> measures = new ArrayList<>();
            int measureCount = track.countMeasures();

            for (int m = 0; m < measureCount; m++) {
                TGMeasure measure = track.getMeasure(m);
                TGMeasureHeader header = measure.getHeader();

                MeasureResponse measureResponse = new MeasureResponse();
                measureResponse.setNumber(measure.getNumber());

                if (header != null) {
                    TGTimeSignature timeSig = header.getTimeSignature();
                    measureResponse.setTimeSignatureNumerator(timeSig.getNumerator());
                    measureResponse.setTimeSignatureDenominator(timeSig.getDenominator().getValue());
                    if (header.getTempo() != null) {
                        measureResponse.setTempo(header.getTempo().getQuarterValue());
                    }
                }

                List<BeatResponse> beats = new ArrayList<>();
                for (TGBeat beat : measure.getBeats()) {
                    BeatResponse beatResponse = parseBeat(beat);
                    beats.add(beatResponse);
                }

                measureResponse.setBeats(beats);
                measures.add(measureResponse);
            }

            trackResponse.setMeasures(measures);
            tracks.add(trackResponse);
        }

        response.setTracks(tracks);
        return response;
    }

    private BeatResponse parseBeat(TGBeat beat) {
        BeatResponse beatResponse = new BeatResponse();
        TGVoice voice = beat.getVoice(0);
        if (voice != null && voice.getDuration() != null) {
            beatResponse.setDuration(convertDuration(voice.getDuration().getValue()));
        }
        beatResponse.setRest(voice == null || voice.isEmpty() || voice.isRestVoice());

        if (beat.getText() != null) {
            beatResponse.setText(beat.getText().getValue());
        }

        if (voice != null && !voice.isEmpty()) {
            List<NoteResponse> notes = new ArrayList<>();
            for (TGNote note : voice.getNotes()) {
                NoteResponse noteResponse = parseNote(note);
                notes.add(noteResponse);
            }
            beatResponse.setNotes(notes);
        } else {
            beatResponse.setNotes(new ArrayList<>());
        }

        return beatResponse;
    }

    private NoteResponse parseNote(TGNote note) {
        NoteResponse noteResponse = new NoteResponse();
        noteResponse.setString(note.getString());
        noteResponse.setValue(note.getValue());

        if (note.isTiedNote()) noteResponse.setTieOrigin(true);
        TGNoteEffect effect = note.getEffect();
        if (effect != null) {
            if (effect.isDeadNote()) noteResponse.setDeadNote(true);
            if (effect.isHammer()) {
                noteResponse.setHammerOn(true);
                noteResponse.setPullOff(true);
            }
            if (effect.isSlide()) noteResponse.setSlide(true);
            if (effect.isVibrato()) noteResponse.setVibrato(true);
            if (effect.isBend()) {
                noteResponse.setBend(true);
                TGEffectBend bend = effect.getBend();
                if (bend != null) {
                    noteResponse.setBendStrength(calculateBendStrength(bend));
                }
            }
            if (effect.isHarmonic()) noteResponse.setHarmonic(true);
        }

        String accidental = getAccidental(note);
        if (accidental != null) noteResponse.setAccidental(accidental);

        return noteResponse;
    }

    private String getAccidental(TGNote note) {
        int value = note.getValue();
        int stringNum = note.getString();
        int[] standardTuning = {40, 45, 50, 55, 59, 64};
        int stringIdx = 6 - stringNum;
        if (stringIdx < 0 || stringIdx >= standardTuning.length) return null;
        int midiNote = standardTuning[stringIdx] + value;
        int pitchClass = midiNote % 12;
        if (pitchClass == 1 || pitchClass == 3 || pitchClass == 6 || pitchClass == 8 || pitchClass == 10) {
            return "#";
        }
        return null;
    }

    private int calculateBendStrength(TGEffectBend bend) {
        if (bend == null) return 0;
        List<TGEffectBend.BendPoint> points = bend.getPoints();
        if (points.isEmpty()) return 0;
        int maxOffset = 0;
        for (TGEffectBend.BendPoint point : points) {
            if (point.getPosition() > maxOffset) maxOffset = point.getPosition();
        }
        return maxOffset / TGEffectBend.SEMI_TONE_LENGTH;
    }

    private int convertDuration(int tgDuration) {
        switch (tgDuration) {
            case 1: return 1;
            case 2: return 2;
            case 4: return 4;
            case 8: return 8;
            case 16: return 16;
            case 32: return 32;
            default: return 4;
        }
    }

    private List<Integer> getStringTunings(TGTrack track) {
        List<Integer> tunings = new ArrayList<>();
        List<TGString> strings = track.getStrings();
        for (TGString tgString : strings) {
            if (tgString != null) tunings.add(tgString.getValue());
        }
        if (tunings.isEmpty()) {
            tunings.add(40); tunings.add(45); tunings.add(50); tunings.add(55); tunings.add(59); tunings.add(64);
        }
        return tunings;
    }
}
