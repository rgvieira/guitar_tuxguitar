package com.tuxguitar.api.model;

import java.util.List;

public class BeatResponse {
    private List<NoteResponse> notes;
    private int duration;
    private boolean isRest;
    private boolean hasFermata;
    private String text;
    private int direction;

    public BeatResponse() {}

    public List<NoteResponse> getNotes() { return notes; }
    public void setNotes(List<NoteResponse> notes) { this.notes = notes; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public boolean isRest() { return isRest; }
    public void setRest(boolean rest) { isRest = rest; }

    public boolean isHasFermata() { return hasFermata; }
    public void setHasFermata(boolean hasFermata) { this.hasFermata = hasFermata; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public int getDirection() { return direction; }
    public void setDirection(int direction) { this.direction = direction; }
}
