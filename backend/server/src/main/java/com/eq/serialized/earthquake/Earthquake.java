package com.eq.serialized.earthquake;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Earthquake {

    private String action;
    private Data data;

    public String getAction() {
        return action;
    }

    public Data getData() {
        return data;
    }
// Getter and setter methods for the fields (not shown here for brevity).

    public class Data {
        public String getType() {
            return type;
        }

        public Geometry getGeometry() {
            return geometry;
        }

        public String getId() {
            return id;
        }

        public Properties getProperties() {
            return properties;
        }

        private String type;
        private Geometry geometry;
        private String id;
        private Properties properties;

        // Getter and setter methods for the fields (not shown here for brevity).
    }
}
