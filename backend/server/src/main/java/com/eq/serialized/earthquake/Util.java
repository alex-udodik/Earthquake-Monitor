package com.eq.serialized.earthquake;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Util {

    public static String ConvertToJSON(Earthquake eq) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        String jsonString = mapper.writeValueAsString(eq);

        return  jsonString;
    }
}
