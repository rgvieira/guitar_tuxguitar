package com.tuxguitar.api.model;

import java.util.List;

public class MeasureResponse {
    private int number;
    private Integer timeSignatureNumerator;
    private Integer timeSignatureDenominator;
    private Integer tempo;
    private List<BeatResponse> beats;

    public MeasureResponse() {}

    public int getNumber() { return number; }
    public void setNumber(int number) { this.number = number; }

    public Integer getTimeSignatureNumerator() { return timeSignatureNumerator; }
    public void setTimeSignatureNumerator(Integer n) { this.timeSignatureNumerator = n; }

    public Integer getTimeSignatureDenominator() { return timeSignatureDenominator; }
    public void setTimeSignatureDenominator(Integer d) { this.timeSignatureDenominator = d; }

    public Integer getTempo() { return tempo; }
    public void setTempo(Integer tempo) { this.tempo = tempo; }

    public List<BeatResponse> getBeats() { return beats; }
    public void setBeats(List<BeatResponse> beats) { this.beats = beats; }
}
