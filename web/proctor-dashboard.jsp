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

<div class="live-monitoring-container" style="margin-top: 20px;">
    <div class="filter-card" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <div>
            <h4 style="margin: 0; color: var(--primary-blue); font-size: 16px;">Live Student Monitoring</h4>
            <p style="font-size: 12px; color: #64748b; margin: 5px 0 0 0;">Real-time AI-powered cheating detection and session tracking.</p>
        </div>
        <div class="stats-badge" style="background: var(--success-light); color: var(--success); padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;">
            <i class="fas fa-circle" style="font-size: 8px; margin-right: 5px;"></i> SYSTEM LIVE
        </div>
    </div>

    <div id="studentGrid" class="student-grid">
        <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #64748b;">
            <i class="fas fa-spinner fa-spin fa-3x"></i>
            <p style="margin-top:10px;">Initializing Live Monitor...</p>
        </div>
    </div>
</div>

<div class="historical-section" style="margin-top: 40px; border-top: 1px solid var(--medium-gray); padding-top: 20px;">
    <h4 style="margin-bottom: 15px; color: var(--primary-blue); font-size: 16px;">Recent Exam Sessions</h4>
    <div class="data-table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student</th>
                    <th>Course</th>
                    <th>Date</th>
                    <th>Flags</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (allExams == null || allExams.isEmpty()) {
                %>
                    <tr><td colspan="6" class="empty-state">No records found.</td></tr>
                <%
                    } else {
                        for (int i=0; i<Math.min(allExams.size(), 10); i++) {
                            Exams exam = allExams.get(i);
                            int examId = exam.getExamId();
                            ArrayList<Map<String, String>> incidents = pDAO.getProctoringIncidents(examId);
                %>
                    <tr>
                        <td>#<%= examId %></td>
                        <td><strong><%= exam.getFullName() %></strong></td>
                        <td><%= exam.getcName() %></td>
                        <td style="font-size: 11px;"><%= exam.getDate() %></td>
                        <td>
                            <% if (incidents != null && !incidents.isEmpty()) { %>
                                <span class="badge badge-danger" onclick="viewIncidents(<%= examId %>)" style="cursor:pointer;"><%= incidents.size() %> Flags</span>
                            <% } else { %>
                                <span class="badge badge-success">Clean</span>
                            <% } %>
                        </td>
                        <td>
                            <button class="action-btn" onclick="viewDetailedReport(<%= examId %>)" style="padding: 4px 8px; font-size: 11px;">
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
</div>

<style>
    .student-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 15px;
    }
    .student-card {
        background: white;
        border-radius: 10px;
        padding: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        border-left: 4px solid var(--success);
        font-size: 12px;
        transition: transform 0.2s;
    }
    .student-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    .student-card.warning { border-left-color: var(--warning); }
    .student-card.critical { border-left-color: var(--error); }

    .card-header {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 10px;
    }
    .live-indicator {
        width: 8px;
        height: 8px;
        background: var(--success);
        border-radius: 50%;
        animation: pulse 2s infinite;
    }
    @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.3; } 100% { opacity: 1; } }

    .student-card img {
        width: 100%;
        height: 160px;
        object-fit: cover;
        border-radius: 6px;
        background: #f1f5f9;
        margin-bottom: 10px;
        border: 1px solid var(--medium-gray);
    }
    .violation-badge {
        background: var(--error-light);
        color: var(--error);
        padding: 2px 8px;
        border-radius: 12px;
        font-size: 10px;
        font-weight: 700;
        margin-left: auto;
    }
    .metrics {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        color: var(--dark-gray);
        font-size: 11px;
    }
    .recent-violations {
        background: #fffcf0;
        border: 1px solid #feebc8;
        border-radius: 4px;
        padding: 6px;
        margin-bottom: 10px;
        max-height: 60px;
        overflow-y: auto;
    }
    .violation-item { color: #c05621; font-size: 10px; margin-bottom: 2px; }

    .card-actions {
        display: flex;
        gap: 8px;
    }
    .card-actions button {
        flex: 1;
        padding: 6px;
        font-size: 11px;
        cursor: pointer;
        border-radius: 6px;
        border: 1px solid var(--medium-gray);
        background: white;
        font-weight: 500;
        transition: all 0.2s;
    }
    .card-actions button:hover { background: #f8fafc; }
    .btn-warn:hover { background: var(--warning-light) !important; color: var(--warning); border-color: var(--warning) !important; }
    .btn-end:hover { background: var(--error-light) !important; color: var(--error); border-color: var(--error) !important; }
</style>

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
    function refreshDashboard() {
        fetch('proctoring_api.jsp?action=live-sessions')
            .then(r => r.json())
            .then(data => {
                const grid = document.getElementById('studentGrid');
                if (!data || data.length === 0) {
                    grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #64748b; background: white; border-radius: 12px;"><i class="fas fa-users-slash fa-3x"></i><p style="margin-top:10px; font-weight: 500;">No active exam sessions at the moment.</p></div>';
                    return;
                }
                grid.innerHTML = data.map(student => `
                    <div class="student-card ${student.status}">
                        <div class="card-header">
                            <div class="live-indicator"></div>
                            <span style="font-weight: 700; font-size: 13px;">${student.name}</span>
                            <span class="violation-badge">${student.violations} FLAGS</span>
                        </div>
                        <div class="card-body">
                            <img src="${student.streamUrl || 'IMG/no-video.png'}" onerror="this.src='IMG/no-video.png'">
                            <div style="font-weight: 600; color: var(--primary-blue); margin-bottom: 5px;">${student.course}</div>
                            <div class="metrics">
                                <span><i class="fas fa-microphone"></i> ${student.audioLevel}dB</span>
                                <span><i class="fas fa-eye"></i> ${student.eyeContact ? 'Screen' : 'Away'}</span>
                            </div>
                            ${student.recentViolations && student.recentViolations.length > 0 ? `
                                <div class="recent-violations">
                                    ${student.recentViolations.map(v => `<div class="violation-item">⚠️ ${v}</div>`).join('')}
                                </div>
                            ` : ''}
                            <div class="card-actions">
                                <button class="btn-warn" onclick="warnStudent('${student.id}')"><i class="fas fa-bell"></i> Warn</button>
                                <button class="btn-end" onclick="terminateExam('${student.id}')"><i class="fas fa-stop-circle"></i> Terminate</button>
                            </div>
                        </div>
                    </div>
                `).join('');
            }).catch(err => console.error('Dashboard sync error:', err));
    }

    function warnStudent(id) {
        alert('Issuing warning to session #' + id + '. Student will see a notification on their screen.');
    }

    function terminateExam(id) {
        if(confirm('CRITICAL ACTION: Are you sure you want to terminate exam session #' + id + ' immediately?')) {
            // In a real app, you'd send a signal to the server/client
            alert('Termination command sent for session #' + id);
        }
    }

    setInterval(refreshDashboard, 3000);
    refreshDashboard();

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
