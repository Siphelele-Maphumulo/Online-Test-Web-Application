<%@page import="myPackage.OpenRouterClient"%>
<%@page import="myPackage.OpenRouterConfig"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>OpenRouter API Test</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding: 40px; background-color: #f8fafc; color: #1e293b; line-height: 1.5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        h1 { margin-top: 0; color: #0f172a; border-bottom: 2px solid #e2e8f0; padding-bottom: 15px; }
        .success { color: #15803d; background: #f0fdf4; padding: 15px; border-radius: 8px; border-left: 4px solid #22c55e; margin-bottom: 20px; }
        .error { color: #b91c1c; background: #fef2f2; padding: 15px; border-radius: 8px; border-left: 4px solid #ef4444; margin-bottom: 20px; }
        .info { color: #1d4ed8; background: #eff6ff; padding: 15px; border-radius: 8px; border-left: 4px solid #3b82f6; margin-bottom: 20px; }
        pre { background: #1e293b; color: #e2e8f0; padding: 15px; border-radius: 8px; overflow-x: auto; font-family: 'ui-monospace', 'Cascadia Code', 'Source Code Pro', Menlo, Monaco, Consolas, monospace; font-size: 14px; }
        code { background: #f1f5f9; padding: 2px 4px; border-radius: 4px; font-family: monospace; }
        ul { padding-left: 20px; }
        li { margin-bottom: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>OpenRouter API Connection Test</h1>
        
        <%
            String apiKey = OpenRouterConfig.getApiKey();
            if (apiKey == null) {
        %>
            <div class="error">
                <h3>❌ API Key Not Found</h3>
                <p>Could not find OpenRouter API key in any of these locations:</p>
                <ul>
                    <li>System property: <code>openrouter.api.key</code></li>
                    <li>Environment variable: <code>OPENROUTER_API_KEY</code></li>
                    <li>Properties file: <code>/WEB-INF/classes/openrouter.properties</code></li>
                </ul>
                <p>Please check your configuration.</p>
            </div>
        <%
            } else {
                String maskedKey = apiKey.length() > 10 ? 
                    apiKey.substring(0, 10) + "..." + apiKey.substring(apiKey.length() - 5) : 
                    "Invalid Key Format";
        %>
            <div class="success">
                <h3>✅ API Key Found</h3>
                <p>Key: <code><%= maskedKey %></code></p>
                <p>Model configured: <code><%= OpenRouterConfig.getModel() %></code></p>
            </div>
            
            <div class="info">
                <h3>🔍 Testing API with sample text...</h3>
                <p>Sending sample text to OpenRouter to verify connection...</p>
            </div>
            
            <%
                try {
                    String testText = "Calculate: Taxation paid WORKINGS: 148000 + 1736000 + 220000 = 2104000 ANSWER: 2104000";
                    String result = OpenRouterClient.generateQuestions(testText, "MCQ", 2, true);
                    
                    if (result == null) {
            %>
                <div class="error">
                    <h3>❌ API Call Failed</h3>
                    <p><code>OpenRouterClient.generateQuestions</code> returned <code>null</code>. Check Tomcat logs for detailed error.</p>
                </div>
            <%
                    } else {
            %>
                <div class="success">
                    <h3>✅ API Call Successful!</h3>
                    <p>Response received:</p>
                    <pre><%= result %></pre>
                </div>
            <%
                    }
                } catch (Exception e) {
            %>
                <div class="error">
                    <h3>❌ Unexpected Exception During Test</h3>
                    <p><%= e.getMessage() %></p>
                    <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                </div>
            <%
                }
            }
        %>
        
        <h3>Debug Information:</h3>
        <pre>
System Property 'openrouter.api.key': <%= System.getProperty("openrouter.api.key", "not set") %>
Environment Variable 'OPENROUTER_API_KEY': <%= System.getenv("OPENROUTER_API_KEY") != null ? "found" : "not set" %>
Classpath Location of Config: <%= OpenRouterConfig.class.getResource("/openrouter.properties") != null ? "found" : "not found" %>
        </pre>
    </div>
</body>
</html>
