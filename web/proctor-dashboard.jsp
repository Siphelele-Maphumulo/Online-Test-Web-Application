<%@ page import="java.util.*, myPackage.*, myPackage.classes.*" %> 
<% 
    // Only proctors/admins can access 
    if (session.getAttribute("userId") == null) { 
        response.sendRedirect("login.jsp"); 
        return; 
    } 
     
    String userType = (String) session.getAttribute("userType"); 
    if (!"admin".equalsIgnoreCase(userType) && !"proctor".equalsIgnoreCase(userType)) { 
        response.sendRedirect("std-page.jsp"); 
        return; 
    } 
     
    DatabaseClass db = DatabaseClass.getInstance(); 
    ArrayList<Map<String, Object>> activeExams = db.getActiveProctoredExams(); 
%> 
 
<!DOCTYPE html> 
<html> 
<head> 
    <title>Proctor Dashboard - Live Monitoring</title> 
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"> 
    <style> 
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        } 
         
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif; 
            background: #f8fafc; 
        } 
         
        .dashboard { 
            display: grid; 
            grid-template-columns: 250px 1fr; 
            min-height: 100vh; 
        } 
         
        .sidebar { 
            background: #09294d; 
            color: white; 
            padding: 20px; 
        } 
         
        .sidebar h2 { 
            margin-bottom: 30px; 
            font-size: 20px; 
        } 
         
        .stats { 
            background: rgba(255,255,255,0.1); 
            padding: 15px; 
            border-radius: 10px; 
            margin-bottom: 20px; 
        } 
         
        .stats div { 
            margin: 10px 0; 
            font-size: 14px; 
        } 
         
        .stats span { 
            float: right; 
            font-weight: bold; 
            color: #92AB2F; 
        } 
         
        .main { 
            padding: 30px; 
        } 
         
        .header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 30px; 
        } 
         
        .header h1 { 
            font-size: 24px; 
            color: #09294d; 
        } 
         
        .refresh-btn { 
            background: #09294d; 
            color: white; 
            border: none; 
            padding: 10px 20px; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 14px; 
            display: flex; 
            align-items: center; 
            gap: 8px; 
        } 
         
        .refresh-btn:hover { 
            background: #1a3d6d; 
        } 
         
        .student-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); 
            gap: 20px; 
        } 
         
        .student-card { 
            background: white; 
            border-radius: 12px; 
            padding: 20px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
            border-left: 4px solid #10b981; 
            transition: transform 0.2s; 
        } 
         
        .student-card:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 4px 20px rgba(0,0,0,0.15); 
        } 
         
        .student-card.warning { 
            border-left-color: #f59e0b; 
        } 
         
        .student-card.critical { 
            border-left-color: #ef4444; 
        } 
         
        .card-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 15px; 
            padding-bottom: 10px; 
            border-bottom: 1px solid #e2e8f0; 
        } 
         
        .live-indicator { 
            width: 10px; 
            height: 10px; 
            background: #10b981; 
            border-radius: 50%; 
            display: inline-block; 
            animation: pulse 2s infinite; 
        } 
         
        @keyframes pulse { 
            0% { opacity: 1; transform: scale(1); } 
            50% { opacity: 0.3; transform: scale(1.2); } 
            100% { opacity: 1; transform: scale(1); } 
        } 
         
        .violation-badge { 
            background: #fee2e2; 
            color: #ef4444; 
            padding: 4px 10px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: bold; 
        } 
         
        .card-body { 
            margin-bottom: 15px; 
        } 
         
        .metrics { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 10px; 
            margin: 15px 0; 
            padding: 10px; 
            background: #f8fafc; 
            border-radius: 8px; 
        } 
         
        .metric-item { 
            display: flex; 
            align-items: center; 
            gap: 8px; 
            font-size: 13px; 
        } 
         
        .metric-item i { 
            width: 16px; 
        } 
         
        .good { 
            color: #10b981; 
        } 
         
        .bad { 
            color: #ef4444; 
        } 
         
        .violations-list { 
            background: #f8fafc; 
            padding: 10px; 
            border-radius: 8px; 
            font-size: 12px; 
            max-height: 100px; 
            overflow-y: auto; 
            margin-bottom: 15px; 
        } 
         
        .violation { 
            color: #b91c1c; 
            margin: 5px 0; 
            padding: 4px; 
            border-bottom: 1px solid #e2e8f0; 
        } 
         
        .actions { 
            display: flex; 
            gap: 10px; 
        } 
         
        .actions button { 
            flex: 1; 
            padding: 8px; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 12px; 
            font-weight: 600; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            gap: 5px; 
        } 
         
        .warn-btn { 
            background: #f59e0b; 
            color: white; 
        } 
         
        .warn-btn:hover { 
            background: #d97706; 
        } 
         
        .terminate-btn { 
            background: #ef4444; 
            color: white; 
        } 
         
        .terminate-btn:hover { 
            background: #dc2626; 
        } 
         
        .screenshot { 
            width: 100%; 
            height: 150px; 
            background: #1e293b; 
            border-radius: 6px; 
            margin-bottom: 10px; 
            overflow: hidden; 
            position: relative; 
        } 
         
        .screenshot img { 
            width: 100%; 
            height: 100%; 
            object-fit: cover; 
        } 
         
        .screenshot .placeholder { 
            color: white; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            height: 100%; 
            font-size: 12px; 
            background: #334155; 
        } 
         
        .modal { 
            display: none; 
            position: fixed; 
            top: 0; 
            left: 0; 
            right: 0; 
            bottom: 0; 
            background: rgba(0,0,0,0.7); 
            z-index: 1000; 
            align-items: center; 
            justify-content: center; 
        } 
         
        .modal.active { 
            display: flex; 
        } 
         
        .modal-content { 
            background: white; 
            border-radius: 12px; 
            width: 90%; 
            max-width: 800px; 
            max-height: 90vh; 
            overflow-y: auto; 
            padding: 30px; 
        } 
         
        .incident-item { 
            background: #f8fafc; 
            padding: 15px; 
            margin-bottom: 10px; 
            border-radius: 8px; 
            border-left: 3px solid #ef4444; 
        } 
         
        .incident-time { 
            font-size: 11px; 
            color: #64748b; 
        } 
         
        .incident-type { 
            font-weight: bold; 
            color: #09294d; 
            margin: 5px 0; 
        } 
         
        .no-exams { 
            text-align: center; 
            padding: 50px; 
            color: #64748b; 
        } 
         
        .no-exams i { 
            font-size: 50px; 
            margin-bottom: 20px; 
            color: #cbd5e1; 
        } 
    </style> 
</head> 
<body> 
    <div class="dashboard"> 
        <div class="sidebar"> 
            <h2>Proctor Dashboard</h2> 
            <div class="stats"> 
                <div>Active Exams: <span id="activeCount"><%= activeExams.size() %></span></div> 
                <div>Flagged Students: <span id="flaggedCount"> 
                    <%= activeExams.stream().filter(e -> ((Integer)e.get("violations")) > 2).count() %> 
                </span></div> 
            </div> 
            <div class="stats"> 
                <div>🔴 Critical: <span id="criticalCount"> 
                    <%= activeExams.stream().filter(e -> ((Integer)e.get("violations")) > 5).count() %> 
                </span></div> 
                <div>🟡 Warning: <span id="warningCount"> 
                    <%= activeExams.stream().filter(e -> { 
                        int v = (Integer)e.get("violations"); 
                        return v > 2 && v <= 5; 
                    }).count() %> 
                </span></div> 
                <div>🟢 Clean: <span id="cleanCount"> 
                    <%= activeExams.stream().filter(e -> ((Integer)e.get("violations")) <= 2).count() %> 
                </span></div> 
            </div> 
        </div> 
         
        <div class="main"> 
            <div class="header"> 
                <h1>Live Proctoring</h1> 
                <button class="refresh-btn" onclick="refreshDashboard()"> 
                    <i class="fas fa-sync-alt"></i> Refresh 
                </button> 
            </div> 
             
            <div class="student-grid" id="studentGrid"> 
                <% if (activeExams.isEmpty()) { %> 
                    <div class="no-exams" style="grid-column: 1/-1;"> 
                        <i class="fas fa-video"></i> 
                        <h3>No Active Exams</h3> 
                        <p>There are currently no students taking exams.</p> 
                    </div> 
                <% } else { %> 
                    <% for (Map<String, Object> student : activeExams) {  
                        String status = (String) student.get("status"); 
                        int violations = (Integer) student.get("violations"); 
                        List<String> recentViolations = (List<String>) student.get("recentViolations"); 
                    %> 
                    <div class="student-card <%= status %>" data-id="<%= student.get("id") %>"> 
                        <div class="card-header"> 
                            <div style="display: flex; align-items: center; gap: 10px;"> 
                                <span class="live-indicator"></span> 
                                <h3><%= student.get("name") %></h3> 
                            </div> 
                            <span class="violation-badge"><%= violations %> violations</span> 
                        </div> 
                         
                        <div class="card-body"> 
                            <div style="font-size: 12px; color: #64748b; margin-bottom: 5px;"> 
                                <%= student.get("course") %> | ID: <%= student.get("id") %> 
                            </div> 
                             
                            <div class="screenshot" onclick="viewIncidents(<%= student.get("id") %>)"> 
                                <% if (student.get("streamUrl") != null && !student.get("streamUrl").toString().isEmpty()) { %> 
                                    <img src="<%= student.get("streamUrl") %>" alt="Latest screenshot"> 
                                <% } else { %> 
                                    <div class="placeholder"> 
                                        <i class="fas fa-camera"></i> No screenshot 
                                    </div> 
                                <% } %> 
                            </div> 
                             
                            <div class="metrics"> 
                                <div class="metric-item"> 
                                    <i class="fas fa-microphone"></i> 
                                    <span>Audio: <span class="<%= (Integer)student.get("audioLevel") > 60 ? "bad" : "good" %>"> 
                                        <%= student.get("audioLevel") %>dB 
                                    </span></span> 
                                </div> 
                                <div class="metric-item"> 
                                    <i class="fas fa-eye"></i> 
                                    <span>Eye Contact: <span class="<%= (Boolean)student.get("eyeContact") ? "good" : "bad" %>"> 
                                        <%= (Boolean)student.get("eyeContact") ? "✅" : "❌" %> 
                                    </span></span> 
                                </div> 
                            </div> 
                             
                            <% if (recentViolations != null && !recentViolations.isEmpty()) { %> 
                            <div class="violations-list"> 
                                <% for (String v : recentViolations) { %> 
                                    <div class="violation">⚠️ <%= v %></div> 
                                <% } %> 
                            </div> 
                            <% } %> 
                        </div> 
                         
                        <div class="actions"> 
                            <button class="warn-btn" onclick="warnStudent(<%= student.get("id") %>)"> 
                                <i class="fas fa-exclamation-triangle"></i> Warn 
                            </button> 
                            <button class="terminate-btn" onclick="terminateExam(<%= student.get("id") %>)"> 
                                <i class="fas fa-ban"></i> Terminate 
                            </button> 
                        </div> 
                    </div> 
                    <% } %> 
                <% } %> 
            </div> 
        </div> 
    </div> 
     
    <!-- Incidents Modal --> 
    <div id="incidentsModal" class="modal"> 
        <div class="modal-content"> 
            <h2 style="margin-bottom: 20px;">Incident History</h2> 
            <div id="incidentsList"></div> 
            <button style="margin-top: 20px; padding: 10px; background: #09294d; color: white; border: none; border-radius: 6px; cursor: pointer;" onclick="closeModal()">Close</button> 
        </div> 
    </div> 
     
    <script> 
        function refreshDashboard() { 
            location.reload(); 
        } 
         
        function viewIncidents(examId) { 
            // In a real system, you would fetch incidents via AJAX 
            // For now, just show a message 
            alert('View incidents for exam ' + examId); 
        } 
         
        function warnStudent(examId) { 
            if (confirm('Send warning to student?')) { 
                fetch('controller.jsp', { 
                    method: 'POST', 
                    headers: { 
                        'Content-Type': 'application/x-www-form-urlencoded', 
                    }, 
                    body: 'page=proctoring&operation=send_warning&examId=' + examId 
                }).then(() => { 
                    alert('Warning sent'); 
                }); 
            } 
        } 
         
        function terminateExam(examId) { 
            if (confirm('⚠️ TERMINATE EXAM? This will end the student\'s exam immediately.')) { 
                fetch('controller.jsp', { 
                    method: 'POST', 
                    headers: { 
                        'Content-Type': 'application/x-www-form-urlencoded', 
                    }, 
                    body: 'page=proctoring&operation=terminate_exam&examId=' + examId 
                }).then(() => { 
                    alert('Exam terminated'); 
                    refreshDashboard(); 
                }); 
            } 
        } 
         
        function closeModal() { 
            document.getElementById('incidentsModal').classList.remove('active'); 
        } 
         
        // Auto-refresh every 10 seconds 
        setInterval(refreshDashboard, 10000); 
    </script> 
</body> 
</html> 
