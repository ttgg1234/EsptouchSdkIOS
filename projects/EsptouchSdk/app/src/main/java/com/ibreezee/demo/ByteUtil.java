package com.ibreezee.demo;

import java.io.UnsupportedEncodingException;

public class ByteUtil {

    public static final String ESPTOUCH_ENCODING_CHARSET = "UTF-8";
    public static byte[] getBytesByString(String string) {
        try {
            return string.getBytes(ESPTOUCH_ENCODING_CHARSET);
        } catch (UnsupportedEncodingException e) {
            throw new IllegalArgumentException("the charset is invalid");
        }
    }
}
