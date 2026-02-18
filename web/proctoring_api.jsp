<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>

<%
    // Role check
    if (session.getAttribute("userStatus") == null || !"1".equals(session.getAttribute("userStatus").toString())) {
        response.sendError(403, "Access Denied");
        return;
    }
    
    // Check if user is admin or lecturer
    myPackage.classes.User currUser = myPackage.DatabaseClass.getInstance().getUserDetails(session.getAttribute("userId").toString());
    if (currUser == null || (!"admin".equalsIgnoreCase(currUser.getType()) && !"lecture".equalsIgnoreCase(currUser.getType()))) {
        response.sendError(403, "Access Denied - Admins and Lecturers Only");
        return;
    }

    String action = request.getParameter("action");
    DatabaseClass pDAO = DatabaseClass.getInstance();

    if ("get_incidents".equalsIgnoreCase(action)) {
        int examId = Integer.parseInt(request.getParameter("examId"));
        ArrayList<Map<String, String>> incidents = pDAO.getProctoringIncidents(examId);

        if (incidents.isEmpty()) {
            out.print("<p>No incidents found.</p>");
        } else {
%>
            <div style="display: flex; flex-direction: column; gap: 15px;">
                <% for (Map<String, String> inc : incidents) { %>
                    <div style="display: grid; grid-template-columns: 100px 1fr 150px; gap: 15px; background: #f8fafc; padding: 15px; border-radius: 8px; border-left: 4px solid var(--error);">
                        <div style="font-weight: bold; color: var(--error);"><%= inc.get("type") %></div>
                        <div>
                            <div style="font-size: 14px;"><%= inc.get("description") %></div>
                            <div style="font-size: 11px; color: #64748b; margin-top: 5px;"><%= inc.get("timestamp") %></div>
                        </div>
                        <div style="text-align: right;">
                            <% if (inc.get("screenshot") != null && !inc.get("screenshot").isEmpty()) { %>
                                <img src="<%= request.getContextPath() + "/" + inc.get("screenshot") %>" style="width: 120px; border-radius: 4px; cursor: pointer;" onclick="window.open(this.src)">
                            <% } else { %>
                                <span style="font-size: 11px; color: #94a3b8;">No screenshot</span>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
<%
        }
    } else if ("get_verification".equalsIgnoreCase(action)) {
        int studentId = Integer.parseInt(request.getParameter("studentId"));
        int examId = Integer.parseInt(request.getParameter("examId"));
        Map<String, String> data = pDAO.getIdentityVerification(studentId, examId);

        if (data.isEmpty()) {
            out.print("<p>No verification data found.</p>");
        } else {
%>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px; text-align: center;">
                <div>
                    <h4 style="margin-bottom: 10px;">Face Photo</h4>
                    <% if (data.get("face_photo") != null) { %>
                        <img src="<%= request.getContextPath() + "/" + data.get("face_photo") %>" style="width: 100%; border-radius: 8px; border: 2px solid #e2e8f0;">
                    <% } else { %>
                        <p>Not available</p>
                    <% } %>
                </div>
                <div>
                    <h4 style="margin-bottom: 10px;">ID Card Photo</h4>
                    <% if (data.get("id_photo") != null) { %>
                        <img src="<%= request.getContextPath() + "/" + data.get("id_photo") %>" style="width: 100%; border-radius: 8px; border: 2px solid #e2e8f0;">
                    <% } else { %>
                        <p>Not available</p>
                    <% } %>
                </div>
            </div>
            <div style="margin-top: 20px; padding: 15px; background: #ecfdf5; border-radius: 8px; border: 1px solid #a7f3d0; text-align: left;">
                <p><strong><i class="fas fa-check-circle" style="color: var(--success);"></i> Honor Code Accepted</strong></p>
                <p style="font-size: 13px; margin-top: 5px;">Timestamp: <%= data.get("timestamp") %></p>
                <p style="font-size: 13px;">Status: <span class="badge badge-success"><%= data.get("status") %></span></p>
            </div>
<%
        }
    }
%>
