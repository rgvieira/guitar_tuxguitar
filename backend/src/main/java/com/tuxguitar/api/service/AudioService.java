package com.tuxguitar.api.service;

import app.tuxguitar.io.base.TGFileFormatManager;
import app.tuxguitar.io.base.TGSongReaderHandle;
import app.tuxguitar.song.factory.TGFactory;
import app.tuxguitar.song.managers.TGSongManager;
import app.tuxguitar.song.models.*;
import app.tuxguitar.util.TGContext;
import org.springframework.stereotype.Service;

import javax.sound.midi.*;
import javax.sound.sampled.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@Service
public class AudioService {

    private final TGContext context;
    private final TGFactory factory;
    private final TGFileFormatManager fileFormatManager;
    private final TGSongManager songManager;

    public AudioService() {
        this.context = new TGContext();
        this.factory = new TGFactory();
        this.fileFormatManager = TGFileFormatManager.getInstance(context);
        this.songManager = new TGSongManager(factory);
    }

    public byte[] renderToWav(InputStream inputStream) throws Exception {
        TGSongReaderHandle handle = new TGSongReaderHandle();
        handle.setFactory(factory);
        handle.setInputStream(inputStream);
        fileFormatManager.read(handle);
        TGSong song = handle.getSong();
        return renderSongToWav(song);
    }

    private byte[] renderSongToWav(TGSong song) throws Exception {
        Sequence sequence = convertSongToSequence(song);
        return sequenceToWavBytes(sequence, 44100);
    }

    private Sequence convertSongToSequence(TGSong song) throws Exception {
        Sequence sequence = new Sequence(Sequence.PPQ, 480);

        int trackCount = song.countTracks();
        for (int t = 0; t < trackCount; t++) {
            TGTrack track = song.getTrack(t);
            Track midiTrack = sequence.createTrack();
            long tick = 0;
            int measureCount = track.countMeasures();

            for (int m = 0; m < measureCount; m++) {
                TGMeasure measure = track.getMeasure(m);
                List<TGBeat> beats = measure.getBeats();

                for (TGBeat beat : beats) {
                    TGVoice voice = beat.getVoice(0);
                    if (voice == null || voice.isEmpty()) continue;

                    int durationTicks = (int) (480 * (4.0 / voice.getDuration().getValue()));

                    for (TGNote note : voice.getNotes()) {
                        int midiNote = getMidiNote(track, note);
                        if (midiNote >= 0) {
                            midiTrack.add(new MidiEvent(new ShortMessage(ShortMessage.NOTE_ON, 0, midiNote, 100), tick));
                            midiTrack.add(new MidiEvent(new ShortMessage(ShortMessage.NOTE_OFF, 0, midiNote, 0), tick + durationTicks - 1));
                        }
                    }
                    tick += durationTicks;
                }
            }
        }
        return sequence;
    }

    private int getMidiNote(TGTrack track, TGNote note) {
        try {
            int stringIndex = note.getString() - 1;
            List<TGString> strings = track.getStrings();
            if (stringIndex >= 0 && stringIndex < strings.size()) {
                TGString tgString = strings.get(stringIndex);
                return tgString.getValue() + note.getValue();
            }
        } catch (Exception e) {}
        return -1;
    }

    private byte[] sequenceToWavBytes(Sequence sequence, float sampleRate) throws Exception {
        int channels = 2;
        int sampleSizeBits = 16;
        AudioFormat format = new AudioFormat(sampleRate, sampleSizeBits, channels, true, false);

        Synthesizer synth = MidiSystem.getSynthesizer();
        synth.open();

        File sf2 = findSoundFont();
        if (sf2 != null && sf2.exists()) {
            try {
                Soundbank sb = MidiSystem.getSoundbank(sf2);
                synth.loadAllInstruments(sb);
            } catch (Exception e) {}
        }

        Sequencer sequencer = MidiSystem.getSequencer(false);
        sequencer.open();
        sequencer.setSequence(sequence);

        DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
        SourceDataLine line = (SourceDataLine) AudioSystem.getLine(info);
        line.open(format);
        line.start();

        sequencer.getTransmitter().setReceiver(synth.getReceiver());
        sequencer.start();

        ByteArrayOutputStream audioOut = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];

        while (sequencer.isRunning()) {
            int available = line.available();
            if (available > 0) {
                int bytesRead = line.read(buffer, 0, Math.min(available, buffer.length));
                if (bytesRead > 0) audioOut.write(buffer, 0, bytesRead);
            }
            Thread.sleep(5);
        }

        int drainCount = 0;
        while (line.available() > 0 && drainCount < 100) {
            int bytesRead = line.read(buffer, 0, buffer.length);
            if (bytesRead > 0) audioOut.write(buffer, 0, bytesRead);
            drainCount++;
        }

        line.stop();
        line.close();
        sequencer.stop();
        sequencer.close();
        synth.close();

        byte[] audioData = audioOut.toByteArray();
        return createWavFile(audioData, format);
    }

    private byte[] createWavFile(byte[] audioData, AudioFormat format) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        int totalDataLen = audioData.length;
        int sampleRate = (int) format.getSampleRate();
        int channels = format.getChannels();
        int bitsPerSample = format.getSampleSizeInBits();

        out.write("RIFF".getBytes());
        out.write(intToLittleEndian(totalDataLen + 36));
        out.write("WAVE".getBytes());
        out.write("fmt ".getBytes());
        out.write(intToLittleEndian(16));
        out.write(shortToLittleEndian((short) 1));
        out.write(shortToLittleEndian((short) channels));
        out.write(intToLittleEndian(sampleRate));
        out.write(intToLittleEndian(sampleRate * channels * bitsPerSample / 8));
        out.write(shortToLittleEndian((short) (channels * bitsPerSample / 8)));
        out.write(shortToLittleEndian((short) bitsPerSample));
        out.write("data".getBytes());
        out.write(intToLittleEndian(totalDataLen));
        out.write(audioData);

        return out.toByteArray();
    }

    private File findSoundFont() {
        String[] paths = {"soundfont.sf2", "src/main/resources/soundfont.sf2", System.getProperty("user.home") + "/soundfont.sf2"};
        for (String p : paths) {
            File f = new File(p);
            if (f.exists()) return f;
        }
        return null;
    }

    private byte[] intToLittleEndian(int value) {
        return new byte[] {(byte) (value & 0xFF), (byte) ((value >> 8) & 0xFF), (byte) ((value >> 16) & 0xFF), (byte) ((value >> 24) & 0xFF)};
    }

    private byte[] shortToLittleEndian(short value) {
        return new byte[] {(byte) (value & 0xFF), (byte) ((value >> 8) & 0xFF)};
    }
}
