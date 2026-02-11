<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>

<%!
    private String[] parseSimpleJsonArray(String json) {
        if (json == null) return new String[0];
        json = json.trim();
        if (json.length() < 2) return new String[0];
        if ("[]".equals(json)) return new String[0];
        if (json.startsWith("[") && json.endsWith("]")) {
            json = json.substring(1, json.length() - 1).trim();
        }
        if (json.isEmpty()) return new String[0];

        // Expecting a simple JSON array of strings produced by DatabaseClass.toJsonArray
        // Example: ["A","B"]
        String[] parts = json.split("(?<=\"),(?=\")");
        for (int i = 0; i < parts.length; i++) {
            String s = parts[i].trim();
            if (s.startsWith("\"") && s.endsWith("\"")) {
                s = s.substring(1, s.length() - 1);
            }
            s = s.replace("\\\\\"", "\"");
            s = s.replace("\\\\n", "\n");
            s = s.replace("\\\\r", "\r");
            s = s.replace("\\\\t", "\t");
            s = s.replace("\\\\\\\\", "\\");
            parts[i] = s;
        }
        return parts;
    }

    // Helper method to check if an array contains a specific answer
    private boolean containsAnswer(String[] correctAnswers, String option) {
        if (correctAnswers == null || option == null) return false;
        for (String correctAnswer : correctAnswers) {
            if (correctAnswer.trim().equals(option.trim())) {
                return true;
            }
        }
        return false;
    }
%>

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

// Generate new CSRF token for each page load
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrfToken);

String courseName = request.getParameter("coursename");
ArrayList list = (courseName != null) ? pDAO.getAllQuestions(courseName) : new ArrayList();
%>

<style>
    :root {
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #4a90e2;
        --white: #ffffff;
        --light-gray: #f8fafc;
        --medium-gray: #e2e8f0;
        --dark-gray: #64748b;
        --text-dark: #1e293b;
        --success: #059669;
        --warning: #d97706;
        --error: #dc2626;
        --info: #0891b2;
        --radius-md: 8px;
        --radius-sm: 4px;
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
        --spacing-md: 16px;
        --spacing-lg: 24px;
    }

    body {
        font-family: 'Inter', -apple-system, sans-serif;
        background-color: var(--light-gray);
        color: var(--text-dark);
        margin: 0;
    }

    .dashboard-container { display: flex; min-height: 100vh; }
    
    .sidebar {
        width: 200px;
        background: linear-gradient(180deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        position: sticky;
        top: 0;
        height: 100vh;
    }

    .sidebar-header { padding: 32px 24px; text-align: center; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
    .mut-logo { max-height: 120px; width: auto; filter: brightness(0) invert(1); }
    .sidebar-nav { padding: 24px 0; }
    .nav-item {
        display: flex; align-items: center; gap: 16px; padding: 16px 24px;
        color: rgba(255, 255, 255, 0.8); text-decoration: none; transition: 0.2s;
    }
    .nav-item:hover, .nav-item.active { background: rgba(255, 255, 255, 0.1); color: var(--white); }
    .nav-item.active { border-left: 4px solid var(--white); }
    .nav-item h2 { font-size: 14px; font-weight: 500; margin: 0; }

    .main-content { flex: 1; padding: var(--spacing-lg); overflow-y: auto; }

    .page-header {
        background: var(--white); border-radius: var(--radius-md); padding: var(--spacing-lg);
        margin-bottom: var(--spacing-lg); display: flex; justify-content: space-between;
        align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    .page-title { display: flex; align-items: center; gap: 8px; font-size: 20px; font-weight: 600; }
    .stats-badge {
        background: var(--primary-blue); color: var(--white); padding: 6px 16px;
        border-radius: 20px; font-size: 13px; display: flex; align-items: center; gap: 6px;
    }

    .questions-container { max-width: 1000px; margin: 0 auto; }

    .course-banner {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white); padding: 20px 24px; border-radius: var(--radius-md);
        margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;
    }
    .course-info h2 { margin: 0; font-size: 18px; }
    .course-stats { font-size: 12px; opacity: 0.9; margin-top: 4px; }

    .question-card {
        background: var(--white); border-radius: var(--radius-md); box-shadow: var(--shadow-md);
        margin-bottom: 24px; border: 1px solid var(--medium-gray); overflow: hidden;
    }
    .question-header {
        padding: 16px 24px; background: #fcfcfc; border-bottom: 1px solid #eee;
        display: flex; justify-content: space-between; align-items: center;
    }
    .q-number-box {
        display: flex; align-items: center; gap: 12px;
    }
    .q-badge {
        width: 32px; height: 32px; background: var(--primary-blue); color: white;
        border-radius: 50%; display: flex; align-items: center; justify-content: center;
        font-weight: bold; font-size: 14px;
    }
    .q-type-label {
        font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;
        background: #eee; padding: 2px 8px; border-radius: 4px; color: #666;
    }

    .question-body { padding: 24px; }
    .question-text { font-size: 16px; font-weight: 500; margin-bottom: 20px; color: #334155; }
    
    .options-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;
    }
    .option-card {
        padding: 16px; border: 1px solid #e2e8f0; border-radius: 6px; background: #f8fafc;
        position: relative; transition: 0.2s;
    }
    .option-card.correct { border-color: var(--success); background-color: #ecfdf5; }
    .option-card.correct-multi { border-color: var(--info); background-color: #f0f9ff; }
    .option-marker { font-size: 11px; font-weight: 700; color: #94a3b8; margin-bottom: 4px; display: block; }
    .option-content { font-size: 14px; color: #1e293b; }
    .correct-tag {
        position: absolute; top: 8px; right: 8px; font-size: 10px;
        background: var(--success); color: white; padding: 2px 6px; border-radius: 4px;
    }

    /* Drag and Drop Preview Styles */
    .dd-preview {
        background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;
    }
    .dd-grid { display: grid; grid-template-columns: 1fr auto 1fr; gap: 20px; align-items: center; }
    .dd-column h4 { font-size: 13px; color: #64748b; margin-top: 0; margin-bottom: 12px; text-align: center; }
    .dd-item-list { display: flex; flex-direction: column; gap: 8px; }
    .dd-pair {
        display: flex; align-items: center; justify-content: space-between;
        background: white; padding: 10px 16px; border-radius: 6px; border: 1px solid #e2e8f0;
        font-size: 14px;
    }
    .dd-drag-text { color: var(--primary-blue); font-weight: 600; }
    .dd-arrow { color: #cbd5e1; }
    .dd-target-text { color: var(--success); font-weight: 600; }
    
    .dd-targets-pool {
        margin-top: 20px; padding-top: 15px; border-top: 1px dashed #cbd5e1;
    }
    .target-badge {
        display: inline-block; background: #f1f5f9; border: 1px solid #e2e8f0;
        padding: 4px 12px; border-radius: 16px; font-size: 12px; margin-right: 8px;
        color: #475569;
    }

    .question-footer {
        padding: 12px 24px; background: #f8fafc; border-top: 1px solid #eee;
        display: flex; justify-content: space-between; align-items: center;
    }
    .qid-info { font-size: 12px; color: #94a3b8; }
    .actions { display: flex; gap: 8px; }
    
    .btn-icon {
        width: 36px; height: 36px; display: flex; align-items: center; justify-content: center;
        border-radius: 6px; text-decoration: none; transition: 0.2s; border: none; cursor: pointer;
    }
    .btn-edit { background: #e0f2fe; color: #0369a1; }
    .btn-edit:hover { background: #bae6fd; }
    .btn-delete { background: #fee2e2; color: #b91c1c; }
    .btn-delete:hover { background: #fecaca; }

    .floating-back {
        position: fixed; bottom: 30px; left: 230px;
        background: var(--white); border: 1px solid var(--medium-gray);
        padding: 10px 20px; border-radius: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        text-decoration: none; color: var(--text-dark); font-weight: 500;
        display: flex; align-items: center; gap: 8px; z-index: 100;
    }
    .floating-back:hover { background: var(--light-gray); transform: translateY(-2px); }

    .no-data {
        text-align: center; padding: 60px; background: white; border-radius: var(--radius-md);
        box-shadow: var(--shadow-md); color: var(--dark-gray);
    }
    .no-data i { font-size: 48px; margin-bottom: 16px; opacity: 0.3; }

    /* Modal */
    .modal-backdrop {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;
    }
    .modal-box {
        background: white; border-radius: 12px; width: 90%; max-width: 450px;
        overflow: hidden; animation: slideIn 0.3s ease;
    }
    @keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .modal-header { padding: 20px; background: #f8fafc; border-bottom: 1px solid #eee; font-weight: 600; }
    .modal-body { padding: 24px; font-size: 15px; line-height: 1.5; color: #475569; }
    .modal-footer { padding: 16px 24px; background: #f8fafc; display: flex; justify-content: flex-end; gap: 12px; }
    .btn-cancel { background: #eee; color: #666; padding: 8px 16px; border-radius: 6px; cursor: pointer; border: none; }
    .btn-confirm-del { background: var(--error); color: white; padding: 8px 16px; border-radius: 6px; cursor: pointer; border: none; }

</style>

<div class="dashboard-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="Logo" class="mut-logo">
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
            <a href="adm-page.jsp?pgprt=3" class="nav-item active">
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
        </nav>
    </aside>

    <main class="main-content">
        <!-- Display session messages -->
        <div class="messages-container">
            <% 
                String successMsg = (String) session.getAttribute("message");
                String errorMsg = (String) session.getAttribute("error");
                if (successMsg != null && !successMsg.trim().isEmpty()) {
            %>
                <div class="alert alert-success" style="padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; background: #ecfdf5; color: #059669; border: 1px solid #10b981;">
                    <span><i class="fas fa-check-circle"></i> <%= successMsg %></span>
                    <i class="fas fa-times" style="cursor:pointer" onclick="this.parentElement.style.display='none'"></i>
                </div>
            <% session.removeAttribute("message"); }
                if (errorMsg != null && !errorMsg.trim().isEmpty()) {
            %>
                <div class="alert alert-error" style="padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; background: #fef2f2; color: #dc2626; border: 1px solid #ef4444;">
                    <span><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></span>
                    <i class="fas fa-times" style="cursor:pointer" onclick="this.parentElement.style.display='none'"></i>
                </div>
            <% session.removeAttribute("error"); } %>
        </div>

        <div class="questions-container">
            <header class="page-header">
                <div class="page-title">
                    <i class="fas fa-list"></i> Question Bank
                </div>
                <div class="stats-badge">
                    <i class="fas fa-database"></i> Total: <%= list.size() %>
                </div>
            </header>

            <% if (courseName != null && !courseName.isEmpty()) { %>
                <div class="course-banner">
                    <div class="course-info">
                        <h2><%= courseName %></h2>
                        <div class="course-stats">Management portal for exam questions</div>
                    </div>
                    <div class="stats-badge" style="background: rgba(255,255,255,0.2);">
                        <i class="fas fa-check-circle"></i> Active
                    </div>
                </div>

                <% if (list.isEmpty()) { %>
                    <div class="no-data">
                        <i class="fas fa-folder-open"></i>
                        <p>No questions have been added to this course yet.</p>
                        <a href="adm-page.jsp?pgprt=3" class="btn btn-primary">Add First Question</a>
                    </div>
                <% } else { %>
                    <% for (int i = 0; i < list.size(); i++) {
                        Questions q = (Questions) list.get(i);
                        String qType = q.getQuestionType() != null ? q.getQuestionType() : "MCQ";
                        boolean isDD = "DRAG_AND_DROP".equals(qType);
                        boolean isFIB = "FillInTheBlank".equalsIgnoreCase(qType);
                        boolean isMS = "MultipleSelect".equals(qType);
                        String[] correctAns = isMS ? q.getCorrect().split("\\|") : new String[]{q.getCorrect()};
                    %>
                        <div class="question-card">
                            <div class="question-header">
                                <div class="q-number-box">
                                    <div class="q-badge"><%= i + 1 %></div>
                                    <span class="q-type-label"><%= qType %></span>
                                </div>
                                <div class="actions">
                                    <a href="edit_question.jsp?qid=<%= q.getQuestionId() %>&coursename=<%= courseName %>" class="btn-icon btn-edit" title="Edit Question">
                                        <i class="fas fa-pen"></i>
                                    </a>
                                    <button class="btn-icon btn-delete" onclick="showDeleteModal(<%= q.getQuestionId() %>, '<%= courseName %>')" title="Delete Question">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                            
                            <div class="question-body">
                                <div class="question-text"><%= q.getQuestion() %></div>

                                <% if (q.getImagePath() != null && !q.getImagePath().isEmpty()) { %>
                                    <div style="margin-bottom: 20px; border: 1px solid #eee; padding: 10px; border-radius: 8px; display: inline-block;">
                                        <img src="<%= q.getImagePath() %>" style="max-width: 100%; max-height: 250px; border-radius: 4px;">
                                    </div>
                                <% } %>

                                <% if (isDD) {
                                    Map<String, String> dd = pDAO.getDragDropData(q.getQuestionId());
                                    String[] items = parseSimpleJsonArray(dd.get("drag_items"));
                                    String[] targets = parseSimpleJsonArray(dd.get("drop_targets"));
                                    String[] correctMap = parseSimpleJsonArray(dd.get("drag_correct_targets"));
                                %>
                                    <div class="dd-preview">
                                        <div class="dd-column">
                                            <h4><i class="fas fa-link"></i> Correct Pairings Preview</h4>
                                            <div class="dd-item-list">
                                                <% for (int j = 0; j < items.length; j++) {
                                                    String target = (j < correctMap.length) ? correctMap[j] : "Not Assigned";
                                                %>
                                                    <div class="dd-pair">
                                                        <span class="dd-drag-text"><%= items[j] %></span>
                                                        <span class="dd-arrow"><i class="fas fa-arrow-right"></i></span>
                                                        <span class="dd-target-text"><%= target %></span>
                                                    </div>
                                                <% } %>
                                            </div>
                                        </div>
                                        <div class="dd-targets-pool">
                                            <span style="font-size: 12px; color: #94a3b8; display: block; margin-bottom: 8px;">Available Drop Targets:</span>
                                            <% for (String t : targets) { %>
                                                <span class="target-badge"><%= t %></span>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } else if (isFIB) { %>
                                    <div class="option-card correct" style="max-width: 400px;">
                                        <span class="option-marker">ACCEPTED ANSWER</span>
                                        <div class="option-content"><%= q.getCorrect() %></div>
                                        <span class="correct-tag"><i class="fas fa-check"></i></span>
                                    </div>
                                <% } else { %>
                                    <div class="options-grid">
                                        <%
                                        String[] opts = {q.getOpt1(), q.getOpt2(), q.getOpt3(), q.getOpt4()};
                                        char[] labels = {'A', 'B', 'C', 'D'};
                                        for (int j = 0; j < 4; j++) {
                                            if (opts[j] == null || opts[j].isEmpty()) continue;
                                            boolean isCorrect = containsAnswer(correctAns, opts[j]);
                                        %>
                                            <div class="option-card <%= isCorrect ? (isMS ? "correct-multi" : "correct") : "" %>">
                                                <span class="option-marker">OPTION <%= labels[j] %></span>
                                                <div class="option-content"><%= opts[j] %></div>
                                                <% if (isCorrect) { %>
                                                    <span class="correct-tag" style="<%= isMS ? "background: var(--info);" : "" %>">
                                                        <i class="fas fa-check"></i>
                                                    </span>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="question-footer">
                                <div class="qid-info">ID: #<%= q.getQuestionId() %> | Course: <%= courseName %></div>
                                <% if (isMS) { %>
                                    <span class="q-type-label" style="background: #e0f2fe; color: #0369a1;">Multiple Select</span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            <% } else { %>
                <div class="no-data">
                    <i class="fas fa-search"></i>
                    <p>No course selected. Please return to the course list.</p>
                    <a href="adm-page.jsp?pgprt=3" class="btn btn-primary">Go to Courses</a>
                </div>
            <% } %>
        </div>
    </main>
</div>

<a href="adm-page.jsp?pgprt=3" class="floating-back">
    <i class="fas fa-chevron-left"></i> Back to Courses
</a>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="modal-backdrop">
    <div class="modal-box">
        <div class="modal-header">Confirm Deletion</div>
        <div class="modal-body">
            Are you sure you want to delete this question? This action cannot be undone.
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="hideDeleteModal()">Cancel</button>
            <button class="btn-confirm-del" id="confirmDelBtn">Delete Question</button>
        </div>
    </div>
</div>

<script>
    let questionToDelete = null;
    let courseToDeleteFrom = null;

    function showDeleteModal(qid, cname) {
        questionToDelete = qid;
        courseToDeleteFrom = cname;
        document.getElementById('deleteModal').style.display = 'flex';
    }

    function hideDeleteModal() {
        document.getElementById('deleteModal').style.display = 'none';
    }

    document.getElementById('confirmDelBtn').onclick = function() {
        if (questionToDelete && courseToDeleteFrom) {
            window.location.href = `controller.jsp?page=questions&operation=del&qid=${questionToDelete}&coursename=${courseToDeleteFrom}&csrf_token=<%= csrfToken %>`;
        }
    };

    // Close modal on outside click
    window.onclick = function(event) {
        const modal = document.getElementById('deleteModal');
        if (event.target == modal) hideDeleteModal();
    }
</script>
