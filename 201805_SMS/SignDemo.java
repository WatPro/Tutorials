////////////////////////////////////////////////////////////////////////////////
////////   This Demo is adopoted from the official guide:               ////////
////////       https://help.aliyun.com/document_detail/56189.html       ////////
////////   Minor change was made.                                       ////////
////////////////////////////////////////////////////////////////////////////////

public class SignDemo {

    public static void main(String[] args) 
          throws 
          java.io.UnsupportedEncodingException, 
          java.security.InvalidKeyException,
          java.security.NoSuchAlgorithmException {
        String accessKeyId = "testId";
        String accessSecret = "testSecret";
        String secretKey = accessSecret + "&";
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        df.setTimeZone(new java.util.SimpleTimeZone(0, "GMT"));// Must be Greenwich Mean Time
        java.util.Map<String, String> paras = new java.util.HashMap<String, String>();
        // 1. System Parameters
        paras.put("SignatureMethod", "HMAC-SHA1");
          // Use Signature Nonce 45e25e9b-0a6f-4070-8c85-2956eda1b466 in the demo 
          // In production, UUID is recommanded for signature nonce in the 
          //   official guide. 
          // paras.put("SignatureNonce", java.util.UUID.randomUUID().toString());
        paras.put("SignatureNonce", "45e25e9b-0a6f-4070-8c85-2956eda1b466");
        paras.put("AccessKeyId", accessKeyId);
        paras.put("SignatureVersion", "1.0");
          // Use Timestamp 2017-07-12T02:42:19Z in the demo 
          // paras.put("Timestamp", df.format(new java.util.Date())); 
        paras.put("Timestamp", "2017-07-12T02:42:19Z");
        paras.put("Format", "XML");
        // 2. Action API Parameters
        paras.put("Action", "SendSms");
        paras.put("Version", "2017-05-25");
        paras.put("RegionId", "cn-hangzhou");
        paras.put("PhoneNumbers", "15300000001");
        paras.put("SignName", "阿里云短信测试专用");
        paras.put("TemplateParam", "{\"customer\":\"test\"}");
        paras.put("TemplateCode", "SMS_71390007");
        paras.put("OutId", "123");
        // 3. Remove the pair with key Signature, 
        //    in the case that it is included accidentally. 
        //    (Not really necessary, could be ignored)
        if (paras.containsKey("Signature"))
            paras.remove("Signature");
        // 4. Sort parameters by keys
        java.util.TreeMap<String, String> sortParas = new java.util.TreeMap<String, String>();
        sortParas.putAll(paras);
        // 5. Construct the string to sign
        java.util.Iterator<String> it = sortParas.keySet().iterator();
        StringBuilder sortQueryStringTmp = new StringBuilder();
        while (it.hasNext()) {
            String key = it.next();
            sortQueryStringTmp.append("&")
                .append(specialUrlEncode(key))
                .append("=")
                .append(specialUrlEncode(paras.get(key)));
        }
        String sortedQueryString = sortQueryStringTmp.substring(1);// Remove the leading sign &
        StringBuilder stringToSign = new StringBuilder();
        stringToSign.append("GET").append("&");
        stringToSign.append(specialUrlEncode("/")).append("&");
        stringToSign.append(specialUrlEncode(sortedQueryString));
        String signature = sign(secretKey, stringToSign.toString());
          // paras.put("Signature", signature);
        StringBuilder QueryStringTmp = new StringBuilder();
        QueryStringTmp
            .append("Signature")
            .append("=")
            .append(specialUrlEncode(signature))
            .append(sortQueryStringTmp);
        // Print out intermediate and final results 
        System.out.println("Sorted Parameters: ");
        System.out.println();
        it = sortParas.keySet().iterator();
        while (it.hasNext()) {
            String key = it.next();
            System.out.println(key + "=" + paras.get(key));
        }
        System.out.println();
        System.out.println("Sorted Query String: ");
        System.out.println();
        System.out.println(sortedQueryString);
        System.out.println();
        System.out.println("String To Sign: ");
        System.out.println();
        System.out.println(stringToSign.toString());
        System.out.println();
        System.out.println("HMAC Cryptographic Key: ");
        System.out.println();
        System.out.println(secretKey);
        System.out.println();
        System.out.println("Signature: ");
        System.out.println();
        System.out.println(signature);
        System.out.println();
        System.out.println("URL (GET method): ");
        System.out.println();
        System.out.println("http://dysmsapi.aliyuncs.com/?" + QueryStringTmp);
    }
    public static String specialUrlEncode(String value) 
          throws 
          java.io.UnsupportedEncodingException {
        return java.net.URLEncoder.encode(value, "UTF-8")
            .replace("+", "%20")
            .replace("*", "%2A")
            .replace("%7E", "~");
    }
    public static String sign(String accessSecret, String stringToSign)
          throws 
          java.io.UnsupportedEncodingException, 
          java.security.InvalidKeyException,
          java.security.NoSuchAlgorithmException {
        javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA1");
        mac.init(new javax.crypto.spec.SecretKeySpec(accessSecret.getBytes("UTF-8"), "HmacSHA1"));
        byte[] signData = mac.doFinal(stringToSign.getBytes("UTF-8"));
        return java.util.Base64.getEncoder().encodeToString(signData);
    }

}
 