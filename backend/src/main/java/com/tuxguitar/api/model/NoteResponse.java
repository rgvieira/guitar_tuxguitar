package com.tuxguitar.api.model;

public class NoteResponse {
    private int string;
    private int value;
    private String accidental;
    private boolean isTieOrigin;
    private boolean isTieDestination;
    private boolean isDeadNote;
    private boolean isHammerOn;
    private boolean isPullOff;
    private boolean isSlide;
    private Integer slideTarget;
    private boolean isVibrato;
    private boolean isBend;
    private Integer bendStrength;
    private boolean isHarmonic;
    private Integer ghostFret;

    public NoteResponse() {}

    public int getString() { return string; }
    public void setString(int string) { this.string = string; }

    public int getValue() { return value; }
    public void setValue(int value) { this.value = value; }

    public String getAccidental() { return accidental; }
    public void setAccidental(String accidental) { this.accidental = accidental; }

    public boolean isTieOrigin() { return isTieOrigin; }
    public void setTieOrigin(boolean tieOrigin) { isTieOrigin = tieOrigin; }

    public boolean isTieDestination() { return isTieDestination; }
    public void setTieDestination(boolean tieDestination) { isTieDestination = tieDestination; }

    public boolean isDeadNote() { return isDeadNote; }
    public void setDeadNote(boolean deadNote) { isDeadNote = deadNote; }

    public boolean isHammerOn() { return isHammerOn; }
    public void setHammerOn(boolean hammerOn) { isHammerOn = hammerOn; }

    public boolean isPullOff() { return isPullOff; }
    public void setPullOff(boolean pullOff) { isPullOff = pullOff; }

    public boolean isSlide() { return isSlide; }
    public void setSlide(boolean slide) { isSlide = slide; }

    public Integer getSlideTarget() { return slideTarget; }
    public void setSlideTarget(Integer slideTarget) { this.slideTarget = slideTarget; }

    public boolean isVibrato() { return isVibrato; }
    public void setVibrato(boolean vibrato) { isVibrato = vibrato; }

    public boolean isBend() { return isBend; }
    public void setBend(boolean bend) { isBend = bend; }

    public Integer getBendStrength() { return bendStrength; }
    public void setBendStrength(Integer bendStrength) { this.bendStrength = bendStrength; }

    public boolean isHarmonic() { return isHarmonic; }
    public void setHarmonic(boolean harmonic) { isHarmonic = harmonic; }

    public Integer getGhostFret() { return ghostFret; }
    public void setGhostFret(Integer ghostFret) { this.ghostFret = ghostFret; }
}
