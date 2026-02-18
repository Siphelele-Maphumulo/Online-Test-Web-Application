<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="myPackage.DatabaseClass" %>
<%@ page import="myPackage.classes.Exams" %>
<%@ page import="myPackage.classes.User" %>

<%
    DatabaseClass pDAO = DatabaseClass.getInstance();
    ArrayList<Exams> allExams = pDAO.getAllExamsWithResults();
    // Sort by most recent
    Collections.sort(allExams, (a, b) -> b.getDate().compareTo(a.getDate()));
%>

<div class="dashboard-container">
    <!-- Sidebar Navigation -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="CodeSA Institute Pty LTD Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <a href="adm-page.jsp?pgprt=0" class="nav-item">
                <i class="fas fa-user"></i>
                <h2>Profile</h2>
            </a>
            <a href="adm-page.jsp?pgprt=2" class="nav-item">
                <i class="fas fa-book"></i>
                <h2>Courses</h2>
            </a>
            <a href="adm-page.jsp?pgprt=3" class="nav-item">
                <i class="fas fa-question-circle"></i>
                <h2>Questions</h2>
            </a>
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item">
                <i class="fas fa-users"></i>
                <h2>Accounts</h2>
            </a>
            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Registers</h2>
            </a>
            <a href="adm-page.jsp?pgprt=9" class="nav-item active">
                <i class="fas fa-user-shield"></i>
                <h2>Proctoring</h2>
            </a>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Page Header -->
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-user-shield"></i>
                Proctoring Dashboard
            </div>
            <div class="stats-badge">
                <i class="fas fa-eye"></i>
                Real-time Monitoring
            </div>
        </header>

<div class="filter-card">
    <h4 style="margin-bottom: 15px; color: var(--primary-blue);">Integrity Monitoring Overview</h4>
    <p style="font-size: 14px; color: #64748b;">Review identity verifications and flagged cheating incidents for all exam sessions.</p>
</div>

<div class="data-table-container">
    <table class="data-table">
        <thead>
            <tr>
                <th>Exam ID</th>
                <th>Student</th>
                <th>Course</th>
                <th>Date</th>
                <th>Identity</th>
                <th>Flags</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% 
                if (allExams == null || allExams.isEmpty()) {
            %>
                <tr>
                    <td colspan="7" class="empty-state">
                        <i class="fas fa-folder-open fa-3x"></i>
                        <h3>No Exam Sessions Found</h3>
                        <p>When students start exams, they will appear here.</p>
                    </td>
                </tr>
            <%
                } else {
                    for (Exams exam : allExams) {
                        int examId = exam.getExamId();
                        int studentId = Integer.parseInt(exam.getStdId());
                        Map<String, String> verification = pDAO.getIdentityVerification(studentId, examId);
                        ArrayList<Map<String, String>> incidents = pDAO.getProctoringIncidents(examId);
                        boolean isVerified = verification != null && "verified".equals(verification.get("status"));
            %>
                <tr>
                    <td><strong>#<%= examId %></strong></td>
                    <td>
                        <div style="font-weight: 600;"><%= exam.getFullName() %></div>
                        <div style="font-size: 11px; color: #64748b;"><%= exam.getEmail() %></div>
                    </td>
                    <td><%= exam.getcName() %></td>
                    <td><%= exam.getDate() %></td>
                    <td>
                        <% if (isVerified) { %>
                            <span class="badge badge-success" title="View Verification" style="cursor: pointer;" onclick="viewVerification(<%= studentId %>, <%= examId %>)">
                                <i class="fas fa-check-circle"></i> Verified
                            </span>
                        <% } else { %>
                            <span class="badge badge-warning">Pending</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (incidents != null && !incidents.isEmpty()) { %>
                            <span class="badge badge-danger" title="View Flags" style="cursor: pointer;" onclick="viewIncidents(<%= examId %>)">
                                <i class="fas fa-exclamation-triangle"></i> <%= incidents.size() %> Flags
                            </span>
                        <% } else { %>
                            <span class="badge badge-success"><i class="fas fa-shield-alt"></i> Clean</span>
                        <% } %>
                    </td>
                    <td>
                        <button class="action-btn" onclick="viewDetailedReport(<%= examId %>)">
                            <i class="fas fa-file-alt"></i> Report
                        </button>
                    </td>
                </tr>
            <%
                    }
                }
            %>
        </tbody>
    </table>
</div>

<!-- Incident Details Modal -->
<div id="incidentModal" class="alert-modal" style="display: none;">
    <div class="alert-modal-content" style="max-width: 900px; width: 95%;">
        <div class="alert-modal-header" style="background: var(--primary-blue); color: white; padding: 20px; border-radius: 12px 12px 0 0;">
            <h3 style="margin: 0;"><i class="fas fa-history"></i> Proctoring Incident Timeline</h3>
            <button type="button" class="close-modal-btn" onclick="closeIncidentModal()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
        </div>
        <div id="incidentModalBody" style="padding: 20px; max-height: 500px; overflow-y: auto;">
            <!-- Incidents will be loaded here -->
        </div>
    </div>
</div>

<!-- Verification Details Modal -->
<div id="verificationModal" class="alert-modal" style="display: none;">
    <div class="alert-modal-content" style="max-width: 700px; width: 90%;">
        <div class="alert-modal-header" style="background: var(--success); color: white; padding: 20px; border-radius: 12px 12px 0 0;">
            <h3 style="margin: 0;"><i class="fas fa-id-card"></i> Identity Verification Photos</h3>
            <button type="button" class="close-modal-btn" onclick="closeVerificationModal()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
        </div>
        <div id="verificationModalBody" style="padding: 20px; text-align: center;">
            <!-- Photos will be loaded here -->
        </div>
    </div>
</div>

    </main>
</div>

<script>
    async function viewIncidents(examId) {
        const modal = document.getElementById('incidentModal');
        const body = document.getElementById('incidentModalBody');
        body.innerHTML = '<div style="text-align:center; padding:20px;"><i class="fas fa-spinner fa-spin fa-2x"></i><p>Loading incidents...</p></div>';
        modal.style.display = 'flex';

        try {
            // In a real app, this would be an AJAX call. For now, we use a simple fetch
            const response = await fetch('proctoring_api.jsp?action=get_incidents&examId=' + examId);
            const html = await response.text();
            body.innerHTML = html;
        } catch (e) {
            body.innerHTML = '<p style="color:red;">Error loading incidents. ' + e.message + '</p>';
        }
    }

    function closeIncidentModal() {
        document.getElementById('incidentModal').style.display = 'none';
    }

    async function viewVerification(studentId, examId) {
        const modal = document.getElementById('verificationModal');
        const body = document.getElementById('verificationModalBody');
        body.innerHTML = '<div style="text-align:center; padding:20px;"><i class="fas fa-spinner fa-spin fa-2x"></i></div>';
        modal.style.display = 'flex';

        try {
            const response = await fetch('proctoring_api.jsp?action=get_verification&studentId=' + studentId + '&examId=' + examId);
            const html = await response.text();
            body.innerHTML = html;
        } catch (e) {
            body.innerHTML = '<p style="color:red;">Error loading verification photos.</p>';
        }
    }

    function closeVerificationModal() {
        document.getElementById('verificationModal').style.display = 'none';
    }

    function viewDetailedReport(examId) {
        window.open('proctoring_report.jsp?examId=' + examId, '_blank');
    }
</script>
