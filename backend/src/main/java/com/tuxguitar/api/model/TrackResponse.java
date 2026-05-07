package com.tuxguitar.api.model;

import java.util.List;

public class TrackResponse {
    private String name;
    private int strings;
    private List<Integer> stringTunings;
    private boolean isPercussion;
    private List<MeasureResponse> measures;

    public TrackResponse() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getStrings() { return strings; }
    public void setStrings(int strings) { this.strings = strings; }

    public List<Integer> getStringTunings() { return stringTunings; }
    public void setStringTunings(List<Integer> stringTunings) { this.stringTunings = stringTunings; }

    public boolean isPercussion() { return isPercussion; }
    public void setPercussion(boolean percussion) { isPercussion = percussion; }

    public List<MeasureResponse> getMeasures() { return measures; }
    public void setMeasures(List<MeasureResponse> measures) { this.measures = measures; }
}
