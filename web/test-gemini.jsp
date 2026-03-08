<%@ page import="myPackage.GeminiClient" %>
<%@ page import="org.json.JSONObject" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Gemini API Test</title>
</head>
<body>
    <h1>Gemini API Connection Test</h1>
    <%
        try {
            // A simple 1x1 black pixel in base64
            String testImage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==";

            out.println("<h2>Testing analyzeFacePhoto...</h2>");
            JSONObject faceResult = GeminiClient.analyzeFacePhoto(testImage);
            out.println("<pre>" + faceResult.toString(2) + "</pre>");

            out.println("<h2>Testing verifyHoldingId...</h2>");
            JSONObject holdingResult = GeminiClient.verifyHoldingId(testImage);
            out.println("<pre>" + holdingResult.toString(2) + "</pre>");

        } catch (Exception e) {
            out.println("<h2 style='color:red;'>Test Failed</h2>");
            out.println("<pre>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
        }
    %>
</body>
</html>
