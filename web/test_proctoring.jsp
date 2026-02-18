<%@ page import="java.util.*, myPackage.DatabaseClass, org.json.*" %>
<%
    DatabaseClass db = DatabaseClass.getInstance();
    ArrayList<Map<String, Object>> active = db.getActiveProctoredExams();
    out.println("Active sessions count: " + active.size());
    if (!active.isEmpty()) {
        out.println("First session: " + new JSONObject(active.get(0)).toString());
    }
    
    // Test log_violation format
    Map<String, String> violation = new HashMap<>();
    violation.put("type", "TEST");
    violation.put("description", "Testing proctoring overhaul");
    violation.put("examId", "1");
    violation.put("studentId", "1");
    violation.put("screenshot", "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc_15adeXl5eW19Y2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5jp6vLz5+fn6/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1FVWV1hZWmNkZWZnaGlqc_15adeXl5eW19Y2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5jp6vLz5+fn6/9oADAMBAAIRAxEAPwAf/9k=");
    
    boolean success = db.logProctoringIncident(1, 1, "TEST", "Testing proctoring overhaul", "uploads/proctoring/test.jpg");
    out.println("Log incident success: " + success);
%>
