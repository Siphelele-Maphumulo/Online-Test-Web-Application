<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.Exams" %>
<%@ page import="myPackage.classes.User" %>

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

    int examId = Integer.parseInt(request.getParameter("examId"));
    DatabaseClass pDAO = DatabaseClass.getInstance();
    Exams exam = pDAO.getResultByExamId(examId);
    int studentId = Integer.parseInt(exam.getStdId());
    Map<String, String> verification = pDAO.getIdentityVerification(studentId, examId);
    ArrayList<Map<String, String>> incidents = pDAO.getProctoringIncidents(examId);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Integrity Report - #<%= examId %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', sans-serif; padding: 40px; background: #f1f5f9; color: #1e293b; }
        .report-container { max-width: 1000px; margin: 0 auto; background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-top: 8px solid #09294d; }
        .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 40px; border-bottom: 2px solid #f1f5f9; padding-bottom: 20px; }
        .title h1 { margin: 0; font-size: 24px; color: #09294d; }
        .title p { margin: 5px 0 0; color: #64748b; }
        .status-badge { padding: 8px 16px; border-radius: 20px; font-weight: bold; font-size: 14px; }
        .status-clean { background: #d1fae5; color: #065f46; }
        .status-flagged { background: #fee2e2; color: #991b1b; }
        
        .section { margin-bottom: 40px; }
        .section-title { font-size: 18px; font-weight: bold; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; color: #334155; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; }
        .info-box { background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; }
        .info-label { font-size: 11px; color: #64748b; text-transform: uppercase; letter-spacing: 1px; }
        .info-value { font-weight: 600; margin-top: 5px; }

        .incident-list { display: flex; flex-direction: column; gap: 15px; }
        .incident-item { display: grid; grid-template-columns: 150px 1fr 200px; gap: 20px; padding: 20px; border: 1px solid #e2e8f0; border-radius: 10px; }
        .screenshot { width: 100%; border-radius: 6px; border: 1px solid #cbd5e1; }
        
        @media print {
            body { padding: 0; background: white; }
            .report-container { box-shadow: none; width: 100%; max-width: none; }
            .btn-print { display: none; }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <div class="header">
            <div class="title">
                <h1>Automated Exam Integrity Report</h1>
                <p>Session ID: #<%= examId %> | Generated on: <%= new java.util.Date() %></p>
            </div>
            <div style="text-align: right;">
                <div class="status-badge <%= incidents.isEmpty() ? "status-clean" : "status-flagged" %>">
                    <%= incidents.isEmpty() ? "PASSED INTEGRITY CHECK" : "FLAGGED FOR REVIEW" %>
                </div>
                <button class="btn-print" onclick="window.print()" style="margin-top: 15px; cursor: pointer; padding: 8px 16px; border-radius: 4px; border: 1px solid #cbd5e1; background: white;">
                    <i class="fas fa-print"></i> Print Report
                </button>
            </div>
        </div>

        <div class="section">
            <div class="section-title"><i class="fas fa-info-circle"></i> Candidate & Exam Information</div>
            <div class="info-grid">
                <div class="info-box"><div class="info-label">Student Name</div><div class="info-value"><%= exam.getFullName() %></div></div>
                <div class="info-box"><div class="info-label">Student ID</div><div class="info-value"><%= exam.getStdId() %></div></div>
                <div class="info-box"><div class="info-label">Email</div><div class="info-value"><%= exam.getEmail() %></div></div>
                <div class="info-box"><div class="info-label">Course</div><div class="info-value"><%= exam.getcName() %></div></div>
                <div class="info-box"><div class="info-label">Exam Date</div><div class="info-value"><%= exam.getDate() %></div></div>
                <div class="info-box"><div class="info-label">Score Obtained</div><div class="info-value"><%= exam.getObtMarks() %> / <%= exam.gettMarks() %></div></div>
            </div>
        </div>

        <div class="section">
            <div class="section-title"><i class="fas fa-user-check"></i> Identity Verification</div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px;">
                <div style="text-align: center;">
                    <p style="font-size: 12px; color: #64748b; margin-bottom: 10px;">Verification Photo</p>
                    <img src="<%= request.getContextPath() + "/" + verification.get("face_photo") %>" style="width: 250px; border-radius: 8px; border: 4px solid #f1f5f9;">
                </div>
                <div style="text-align: center;">
                    <p style="font-size: 12px; color: #64748b; margin-bottom: 10px;">ID Document</p>
                    <img src="<%= request.getContextPath() + "/" + verification.get("id_photo") %>" style="width: 250px; border-radius: 8px; border: 4px solid #f1f5f9;">
                </div>
            </div>
            <div style="margin-top: 20px; background: #f8fafc; padding: 15px; border-radius: 8px; font-size: 14px;">
                <p><strong>Honor Code Status:</strong> Accepted</p>
                <p><strong>Acceptance Timestamp:</strong> <%= verification.get("timestamp") %></p>
            </div>
        </div>

        <div class="section">
            <div class="section-title"><i class="fas fa-exclamation-triangle"></i> Incident Log (<%= incidents.size() %>)</div>
            <% if (incidents.isEmpty()) { %>
                <div style="padding: 20px; background: #ecfdf5; color: #065f46; border-radius: 8px;">
                    No proctoring violations were recorded during this session.
                </div>
            <% } else { %>
                <div class="incident-list">
                    <% for (Map<String, String> inc : incidents) { %>
                        <div class="incident-item">
                            <div>
                                <div style="font-weight: bold; color: #991b1b;"><%= inc.get("type") %></div>
                                <div style="font-size: 12px; color: #64748b; margin-top: 5px;"><%= inc.get("timestamp") %></div>
                            </div>
                            <div style="font-size: 14px;"><%= inc.get("description") %></div>
                            <div>
                                <% if (inc.get("screenshot") != null) { %>
                                    <img src="<%= request.getContextPath() + "/" + inc.get("screenshot") %>" class="screenshot">
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

        <div style="margin-top: 60px; padding-top: 20px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center;">
            This report is automatically generated by the Online Assessment System Proctoring Engine. 
            Final decision rests with the human examiner.
        </div>
    </div>
</body>
</html>
