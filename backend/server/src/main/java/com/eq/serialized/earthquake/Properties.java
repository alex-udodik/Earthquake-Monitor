package com.eq.serialized.earthquake;

public class Properties {

    private String source_id;
    private String source_catalog;
    private String lastupdate;
    private String time;
    private String flynn_region;
    private double lat;
    private double lon;
    private double depth;
    private String evtype;
    private String auth;
    private double mag;
    private String magtype;
    private String unid;

    public String getSource_id() {
        return source_id;
    }

    public String getSource_catalog() {
        return source_catalog;
    }

    public String getLastupdate() {
        return lastupdate;
    }

    public String getTime() {
        return time;
    }

    public String getFlynn_region() {
        return flynn_region;
    }

    public double getLat() {
        return lat;
    }

    public double getLon() {
        return lon;
    }

    public double getDepth() {
        return depth;
    }

    public String getEvtype() {
        return evtype;
    }

    public String getAuth() {
        return auth;
    }

    public double getMag() {
        return mag;
    }

    public String getMagtype() {
        return magtype;
    }

    public String getUnid() {
        return unid;
    }
}
