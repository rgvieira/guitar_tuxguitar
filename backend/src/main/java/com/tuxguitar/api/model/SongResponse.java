package com.tuxguitar.api.model;

import java.util.List;

public class SongResponse {
    private String title;
    private String artist;
    private String album;
    private int bpm;
    private int timeSignatureNumerator;
    private int timeSignatureDenominator;
    private int keySignature;
    private List<TrackResponse> tracks;

    public SongResponse() {}

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getArtist() { return artist; }
    public void setArtist(String artist) { this.artist = artist; }

    public String getAlbum() { return album; }
    public void setAlbum(String album) { this.album = album; }

    public int getBpm() { return bpm; }
    public void setBpm(int bpm) { this.bpm = bpm; }

    public int getTimeSignatureNumerator() { return timeSignatureNumerator; }
    public void setTimeSignatureNumerator(int n) { this.timeSignatureNumerator = n; }

    public int getTimeSignatureDenominator() { return timeSignatureDenominator; }
    public void setTimeSignatureDenominator(int d) { this.timeSignatureDenominator = d; }

    public int getKeySignature() { return keySignature; }
    public void setKeySignature(int keySignature) { this.keySignature = keySignature; }

    public List<TrackResponse> getTracks() { return tracks; }
    public void setTracks(List<TrackResponse> tracks) { this.tracks = tracks; }
}
