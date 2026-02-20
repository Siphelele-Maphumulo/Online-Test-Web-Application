
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/gh/Bernardo-Castilho/dragdroptouch@master/DragDropTouch.js"></script>
<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.Exams"%>
<%@ page isELIgnored="true" %>
<%
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    
    // Generate CSRF token if not exists
    if (session.getAttribute("csrf_token") == null) {
        String csrfToken = java.util.UUID.randomUUID().toString();
        session.setAttribute("csrf_token", csrfToken);
    }
    
    // CHECK IF USER IS TRYING TO ACCESS EXAM WITHOUT ACTIVE SESSION
    String showExamForm = "true"; // Default to showing exam selection form
    
    // Only show active exam if BOTH conditions are met:
    // 1. session has examStarted = "1"
    // 2. URL has coursename parameter
    if ("1".equals(String.valueOf(session.getAttribute("examStarted"))) && 
        request.getParameter("coursename") != null && 
        !request.getParameter("coursename").isEmpty()) {
        showExamForm = "false"; // Show active exam
    } else {
        // Clear any stale exam session data
        session.removeAttribute("examStarted");
        session.removeAttribute("examId");
    }
%>

<%!
    // Function to escape HTML characters for safe display in attributes
    public String escapeHtmlAttr(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;");
    }
    
    // Null-coalescing function: returns value if non-null/non-empty, otherwise fallback
    public String nz(String v, String fallback) {
        return (v != null && !v.trim().isEmpty()) ? v.trim() : fallback;
    }

    // Helper method to format duration in minutes to readable format
    private String formatDuration(int minutes) {
        if (minutes < 60) {
            return minutes + " minute" + (minutes != 1 ? "s" : "");
        } else {
            int hours = minutes / 60;
            int remainingMinutes = minutes % 60;
            if (remainingMinutes == 0) {
                return hours + " hour" + (hours != 1 ? "s" : "");
            } else {
                return hours + " hour" + (hours != 1 ? "s" : "") + " " + 
                       remainingMinutes + " minute" + (remainingMinutes != 1 ? "s" : "");
            }
        }
    }
%>


<link rel="stylesheet" href="style-exam.css">



<div class="exam-wrapper">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <div class="left-menu">
                <a class="nav-item" href="std-page.jsp?pgprt=0"><i class="fas fa-user"></i><span>Profile</span></a>
                <a class="nav-item active" href="std-page.jsp?pgprt=1"><i class="fas fa-file-alt"></i><span>Lunch Exam</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=2"><i class="fas fa-chart-line"></i><span>Results</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=3"><i class="fas fa-chart-line"></i><span>Exam Results</span></a>
            </div>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="content-area">
        <% if ("false".equals(showExamForm)) { 
            // SHOW ACTIVE EXAM
            // Set user details in session for verification
            Object userIdObj = session.getAttribute("userId");
            String userIdStr = null;
            if (userIdObj != null) {
                userIdStr = userIdObj.toString();
            }
            if (userIdStr != null && !userIdStr.isEmpty()) {
                try {
                    myPackage.classes.User user = pDAO.getUserDetails(userIdStr);
                    if (user != null) {
                        session.setAttribute("uname", user.getUserName());
                        session.setAttribute("userFullName", user.getFirstName() + " " + user.getLastName());
                    }
                } catch (Exception e) {
                    // Handle error gracefully
                }
            }
            
            String courseName = request.getParameter("coursename");
            ArrayList<Questions> questionsList = pDAO.getQuestions(courseName, 20);
            int totalQ = questionsList.size();
        %>
            <!-- EXAM ACTIVE HEADER -->
            <div class="exam-header-container">
                <div class="top-progress-bar-row">
                    <div class="progress-info-left">Exam Progress (<span id="examProgressPctHeader">0%</span>)</div>
                    <div class="progress-container-center">
                        <div class="progress-fill" id="progressBarHeader"></div>
                    </div>
                    <div class="time-left-right">Time Left: <span id="remainingTimeHeader">--:--</span></div>
                </div>
                <div class="nav-header-row">
                    <div class="utility-icons">
                        <button type="button" class="util-btn" onclick="toggleCalculator()" title="Scientific Calculator">
                            <i class="fas fa-calculator"></i>
                        </button>
                        <button type="button" class="util-btn" onclick="toggleRoughPaper()" title="Rough Paper">
                            <i class="fas fa-sticky-note"></i>
                        </button>
                    </div>
                    <div class="question-counter" style="cursor: pointer;" onclick="showQuestionNavigationModal()" title="Click to navigate to any question">Question <span id="currentQNum">1</span>/<%= totalQ %></div>
                    <div class="nav-buttons">
                        <button type="button" class="exam-nav-btn btn-first" onclick="goToFirstQuestion()" title="Go to first question">
                            <i class="fas fa-step-backward"></i>
                        </button>
                        <button type="button" class="exam-nav-btn btn-prev" id="prevBtn" onclick="prevQuestion()" disabled>
                            <i class="fas fa-arrow-left"></i> Prev
                        </button>
                        <button type="button" class="exam-nav-btn btn-next" id="nextBtn" onclick="nextQuestion()">
                            Next <i class="fas fa-arrow-right"></i>
                        </button>
                        <button type="button" class="exam-nav-btn btn-last" onclick="goToLastQuestion()" title="Go to last question">
                            <i class="fas fa-step-forward"></i>
                        </button>
                    </div>
                </div>

                <!-- SYSTEM ALERT MODAL (replaces alert() to keep fullscreen) -->
                <div id="systemAlertModal" class="alert-modal">
                    <div class="alert-modal-content" style="max-width: 520px; width: 92%;">
                        <div class="alert-modal-header" style="background: #09294d; color: white; padding: 18px 20px; border-radius: 12px 12px 0 0; display: flex; justify-content: space-between; align-items: center;">
                            <h3 style="margin: 0; display: flex; align-items: center; gap: 10px; font-size: 18px;">
                                <i class="fas fa-info-circle"></i>
                                Notice
                            </h3>
                            <button type="button" class="close-modal-btn" onclick="closeSystemAlertModal()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
                        </div>
                        <div class="alert-modal-body" style="padding: 18px 20px;">
                            <p id="systemAlertMessage" style="margin: 0; color: #334155; font-size: 15px; line-height: 1.5;"></p>
                        </div>
                        <div class="alert-modal-footer" style="padding: 14px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end;">
                            <button type="button" class="btn-secondary" onclick="closeSystemAlertModal()">OK</button>
                        </div>
                    </div>
                </div>

                <!-- LEAVE WINDOW MODAL -->
                <div id="leaveWindowModal" class="alert-modal">
                    <div class="alert-modal-content alert-modal-warning" style="max-width: 560px; width: 92%;">
                        <div class="alert-modal-icon">
                            <i class="fas fa-window-restore"></i>
                        </div>
                        <div class="alert-modal-body">
                            <h3>Return to the exam</h3>
                            <p>You left the exam window. Please return within <strong><span id="leaveWindowCountdown">5</span></strong> seconds.</p>
                            <p style="margin: 0; font-size: 13px; color: #64748b;">If you do not return in time, your exam will be submitted automatically.</p>
                        </div>
                    </div>
                </div>

                <!-- CONFIRM ACTION MODAL (replaces confirm() to keep fullscreen) -->
                <div id="systemConfirmModal" class="alert-modal">
                    <div class="alert-modal-content" style="max-width: 560px; width: 92%;">
                        <div class="alert-modal-header" style="background: #09294d; color: white; padding: 18px 20px; border-radius: 12px 12px 0 0; display: flex; justify-content: space-between; align-items: center;">
                            <h3 style="margin: 0; display: flex; align-items: center; gap: 10px; font-size: 18px;">
                                <i class="fas fa-question-circle"></i>
                                Confirm
                            </h3>
                            <button type="button" class="close-modal-btn" onclick="closeSystemConfirmModal(false)" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
                        </div>
                        <div class="alert-modal-body" style="padding: 18px 20px;">
                            <p id="systemConfirmMessage" style="margin: 0; color: #334155; font-size: 15px; line-height: 1.5;"></p>
                        </div>
                        <div class="alert-modal-footer" style="padding: 14px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px;">
                            <button type="button" class="btn-secondary" onclick="closeSystemConfirmModal(false)">Cancel</button>
                            <button type="button" class="btn-primary" id="systemConfirmOkBtn" onclick="closeSystemConfirmModal(true)">Proceed</button>
                        </div>
                    </div>
                </div>
            </div>

            <form id="myform" action="controller.jsp" method="post">
                <input type="hidden" name="page" value="exams">
                <input type="hidden" name="operation" value="submitted">
                <input type="hidden" name="examId" value="<%= session.getAttribute("examId") != null ? session.getAttribute("examId") : "0" %>">
                <input type="hidden" name="size" value="<%= totalQ %>">
                <input type="hidden" name="totalmarks" value="<%= pDAO.getTotalMarksByName(courseName) %>">
                <input type="hidden" name="coursename" value="<%= courseName %>">

                <div class="questions-container">
                <% for (int i=0; i<totalQ; i++){
                    Questions q = questionsList.get(i);
                    boolean isMultiTwo = false;
                    boolean isDragDrop = false;
                    boolean isRearrange = false;
                    try{
                        String qt = q.getQuestion().toLowerCase();
                        String questionType = q.getQuestionType();
                        isMultiTwo = "MultipleSelect".equalsIgnoreCase(questionType) ||
                                    qt.contains("select two") || qt.contains("choose two") || 
                                    qt.contains("pick two") || qt.contains("multiple answers") || 
                                    qt.contains("two options") || qt.contains("multiple select") ||
                                    qt.contains("select multiple") || qt.contains("choose multiple");
                        isDragDrop = "DRAG_AND_DROP".equalsIgnoreCase(questionType);
                        isRearrange = "REARRANGE".equalsIgnoreCase(questionType);
                    } catch(Exception e) { 
                        isMultiTwo = false; 
                        isDragDrop = false;
                    }

                    String fullQuestion = q.getQuestion(), questionPart = "", codePart = "";
                    if(fullQuestion.contains("```")){
                        String[] parts = fullQuestion.split("```");
                        if(parts.length >= 2) {
                            questionPart = parts[0].trim();
                            codePart = parts[1].trim();
                        } else {
                            questionPart = fullQuestion.replace("```", "").trim();
                        }
                    } else {
                        boolean isCodeQuestion = fullQuestion.contains("def ") || fullQuestion.contains("function ") || 
                                                fullQuestion.contains("public ") || fullQuestion.contains("class ") ||
                                                fullQuestion.contains("print(") || fullQuestion.contains("console.") || 
                                                fullQuestion.contains("<?php") || fullQuestion.contains("import ") ||
                                                fullQuestion.contains("int ") || fullQuestion.contains("String ") || 
                                                fullQuestion.contains("printf(") || fullQuestion.contains("cout ");
                        if(isCodeQuestion) {
                            codePart = fullQuestion;
                            questionPart = "What is the output/result of this code?";
                        } else {
                            questionPart = fullQuestion;
                        }
                    }
                    
                    java.util.List<String> opts = new java.util.ArrayList<>();
                    if(q.getOpt1() != null && !q.getOpt1().trim().isEmpty()) opts.add(q.getOpt1());
                    if(q.getOpt2() != null && !q.getOpt2().trim().isEmpty()) opts.add(q.getOpt2());
                    if(q.getOpt3() != null && !q.getOpt3().trim().isEmpty()) opts.add(q.getOpt3());
                    if(q.getOpt4() != null && !q.getOpt4().trim().isEmpty()) opts.add(q.getOpt4());
                    
                    // Randomize the options for the question
                    java.util.Collections.shuffle(opts, new java.util.Random(new java.util.Date().getTime()));
                %>
                    <div class="question-card" data-qindex="<%= i %>">
                        <div class="question-header">
                            <div class="question-label"><%= i+1 %></div>
                            <div class="question-content">
                                <% if(!questionPart.isEmpty() && !questionPart.equals("What is the output/result of this code?")){ %>
                                    <p class="question-text"><%= questionPart %></p>
                                <% } %>
                                
                                <!-- Question Image -->
                                <% if(q.getImagePath() != null && !q.getImagePath().isEmpty()){ 
                                    String imagePath = q.getImagePath();
                                    imagePath = imagePath.trim();
                                    imagePath = imagePath.replace('\\', '/');

                                    if (!imagePath.startsWith("http")) {
                                        String ctx = request.getContextPath();
                                        if (imagePath.startsWith(ctx + "/")) {
                                            // already context-relative
                                        } else if (imagePath.startsWith("/")) {
                                            imagePath = ctx + imagePath;
                                        } else {
                                            imagePath = ctx + "/" + imagePath;
                                        }
                                    }
                                %>
                                    <div class="question-image-container">
                                        <img src="<%= imagePath %>" alt="Question Image" class="question-image" loading="lazy" onerror="this.onerror=null; this.style.display='none'; var msg=this.parentNode.querySelector('.question-image-error'); if(msg) msg.style.display='block';">
                                        <div class="question-image-error" style="display:none; font-size: 12px; color: #ef4444; margin-top: 8px;">Image could not be loaded.</div>
                                    </div>
                                <% } %>
                                
                                <% if(!codePart.isEmpty()){ %>
                                    <div class="code-question-indicator"><i class="fas fa-code"></i><strong>Code Analysis Question</strong></div>
                                    <div class="code-snippet">
                                        <div class="code-header"><i class="fas fa-code"></i><span>Code to Analyze</span></div>
                                        <pre><%= codePart %></pre>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="answers" data-max-select="<%= isMultiTwo?"2":"1" %>">
                            <% if(isDragDrop){ 
                                // Serialize relational data to JSON for JS
                                org.json.JSONArray itemsArray = new org.json.JSONArray();
                                if (q.getDragItems() != null && !q.getDragItems().isEmpty()) {
                                    for (myPackage.classes.DragItem di : q.getDragItems()) {
                                        org.json.JSONObject jo = new org.json.JSONObject();
                                        jo.put("id", di.getId());
                                        jo.put("text", di.getItemText());
                                        itemsArray.put(jo);
                                    }
                                } else if (q.getDragItemsJson() != null && !q.getDragItemsJson().isEmpty()) {
                                    // Fallback to JSON column if relational list is empty
                                    try {
                                        itemsArray = new org.json.JSONArray(q.getDragItemsJson());
                                    } catch (Exception e) {
                                        // Silently handle JSON parsing errors
                                    }
                                }
                                
                                org.json.JSONArray targetsArray = new org.json.JSONArray();
                                if (q.getDropTargets() != null && !q.getDropTargets().isEmpty()) {
                                    for (myPackage.classes.DropTarget dt : q.getDropTargets()) {
                                        org.json.JSONObject jo = new org.json.JSONObject();
                                        jo.put("id", dt.getId());
                                        jo.put("label", dt.getTargetLabel());
                                        targetsArray.put(jo);
                                    }
                                } else if (q.getDropTargetsJson() != null && !q.getDropTargetsJson().isEmpty()) {
                                    // Fallback to JSON column if relational list is empty
                                    try {
                                        targetsArray = new org.json.JSONArray(q.getDropTargetsJson());
                                    } catch (Exception e) {
                                        // Silently handle JSON parsing errors
                                    }
                                }
                            %>
                                <div class="drag-drop-question" 
                                     data-items-json="<%= escapeHtmlAttr(itemsArray.toString()) %>" 
                                     data-targets-json="<%= escapeHtmlAttr(targetsArray.toString()) %>"
                                     data-extra-data="<%= escapeHtmlAttr(nz(q.getExtraData(), "{}")) %>">
                                    <div class="drag-drop-instructions">
                                        <i class="fas fa-hand-rock"></i>
                                        <div>
                                            <strong>Drag and Drop the Items</strong>
                                            <p>Match each item from the left panel to its corresponding target on the right.</p>
                                        </div>
                                    </div>
                                    
                                    <div class="drag-drop-container">
                                        <div class="draggable-items-panel">
                                            <div class="panel-header">
                                                <i class="fas fa-grip-vertical"></i> Draggable Items
                                                <button type="button" class="shuffle-btn" onclick="shuffleDraggableItems('<%= i %>')" title="Shuffle Items">
                                                    <i class="fas fa-random"></i>
                                                </button>
                                            </div>
                                            <div class="drag-items-list" id="dragItems_<%= i %>">
                                                <!-- Drag items will be loaded dynamically -->
                                            </div>
                                        </div>
                                        
                                        <div class="drop-targets-panel">
                                            <div class="panel-header">
                                                <i class="fas fa-bullseye"></i> Drop Targets
                                            </div>
                                            <div class="drop-targets-list" id="dropTargets_<%= i %>">
                                                <!-- Drop targets will be loaded dynamically -->
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <input type="hidden" name="dragDropQuestion_<%= i %>" value="true">
                                    <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">

                                    <!-- Step 12: Visible Debugging -->
                                    <div style="background: #fff3cd; border: 1px solid #ffeeba; padding: 10px; margin: 10px 0; font-size: 11px; display: none;" class="drag-debug">
                                        <strong>Debug Info (Question <%= i+1 %>):</strong>
                                        <div>Items: <code id="debug-items-<%= i %>"></code></div>
                                        <div>Targets: <code id="debug-targets-<%= i %>"></code></div>
                                    </div>
                                    <script>
                                        (function() {
                                            const itemsJson = '<%= escapeHtmlAttr(itemsArray.toString()) %>';
                                            const targetsJson = '<%= escapeHtmlAttr(targetsArray.toString()) %>';
                                            console.log('Question <%= i+1 %> Data:', { itemsJson, targetsJson });
                                            document.getElementById('debug-items-<%= i %>').textContent = itemsJson;
                                            document.getElementById('debug-targets-<%= i %>').textContent = targetsJson;
                                            // Uncomment to show debug info in UI
                                            // document.querySelector('.drag-debug').style.display = 'block';
                                        })();
                                    </script>
                                </div>
                            <% } else if(isRearrange) { 
                                org.json.JSONArray itemsArray = new org.json.JSONArray();
                                if (q.getRearrangeItems() != null && !q.getRearrangeItems().isEmpty()) {
                                    for (myPackage.classes.RearrangeItem ri : q.getRearrangeItems()) {
                                        org.json.JSONObject jo = new org.json.JSONObject();
                                        jo.put("id", ri.getId());
                                        jo.put("text", ri.getItemText());
                                        itemsArray.put(jo);
                                    }
                                } else if (q.getRearrangeItemsJson() != null && !q.getRearrangeItemsJson().isEmpty()) {
                                    try {
                                        itemsArray = new org.json.JSONArray(q.getRearrangeItemsJson());
                                    } catch (Exception e) {}
                                }
                            %>
                                <div class="rearrange-question" 
                                     data-items-json="<%= escapeHtmlAttr(itemsArray.toString()) %>"
                                     data-extra-data="<%= escapeHtmlAttr(nz(q.getExtraData(), "{}")) %>">
                                    <div class="rearrange-instructions">
                                        <i class="fas fa-sort-amount-down"></i>
                                        <div>
                                            <strong>Rearrange the Items</strong>
                                            <p>Drag and drop the items below into the correct sequence order.</p>
                                        </div>
                                    </div>
                                    <div class="rearrange-interface" id="rearrange_<%= i %>">
                                        <!-- Rearrange items will be loaded dynamically -->
                                    </div>
                                    <input type="hidden" name="rearrangeQuestion_<%= i %>" value="true">
                                </div>
                            <% } else { %>
                                <% if(isMultiTwo){ %>
                                    <div class="multi-select-note"><i class="fas fa-check-double"></i><strong>Choose up to 2 answers</strong></div>
                                <% } %>
                                <% for(int oi=0; oi<opts.size(); oi++){
                                    String optVal = opts.get(oi);
                                    String inputId = "q"+i+"o"+(oi+1);
                                %>
                                    <div class="form-check">
                                        <input class="form-check-input answer-input <%= isMultiTwo?"multi":"single" %>" 
                                            type="<%= isMultiTwo?"checkbox":"radio" %>" 
                                            id="<%= inputId %>" 
                                            name="<%= isMultiTwo ? ("ans"+i+"_"+oi) : ("ans"+i) %>" 
                                            value="<%= optVal %>" 
                                            data-qindex="<%= i %>">
                                        <label class="form-check-label" for="<%= inputId %>"><%= optVal %></label>
                                    </div>
                                <% } %>
                                <% if(isMultiTwo){ %>
                                    <input type="hidden" id="ans<%= i %>-hidden" name="ans<%= i %>" value="">
                                <% } %>
                            <% } %>
                        </div>
                        <input type="hidden" name="question<%= i %>" value="<%= q.getQuestion() %>">
                        <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">
                        <input type="hidden" name="qtype<%= i %>" value="<%= isDragDrop?"dragdrop":(isRearrange?"rearrange":(isMultiTwo?"multi2":"single")) %>">
                    </div>
                <% } %>
                </div>

                <!-- FLOATING PROGRESS BUTTON -->
                <button type="button" id="progressFloatBtn" class="progress-float-btn" title="Exam Progress">
                    <i class="fas fa-chart-pie"></i><span class="float-counter" id="floatCounter">0/<%= totalQ %></span>
                </button>

                <!-- PROGRESS / SUBMIT MODAL -->
                <div id="progressModal" class="progress-modal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3><i class="fas fa-tachometer-alt"></i> Exam Progress</h3>
                            <button type="button" class="close-modal">&times;</button>
                        </div>
                        <div class="modal-body">
                            <div class="progress-summary">
                                <div class="progress-circle" data-progress="0">
                                    <svg class="progress-ring" width="80" height="80">
                                        <circle class="progress-ring-circle" stroke="#e2e8f0" stroke-width="6" fill="transparent" r="34" cx="40" cy="40"/>
                                        <circle class="progress-ring-progress" stroke="#059669" stroke-width="6" fill="transparent" r="34" cx="40" cy="40" stroke-dasharray="213.628" stroke-dashoffset="213.628"/>
                                    </svg>
                                    <div class="progress-text"><span class="progress-percent">0%</span><small>Complete</small></div>
                                </div>
                                <div class="stats-grid">
                                    <div class="stat-box answered"><i class="fas fa-check-circle"></i><span class="stat-count" id="modalAnswered">0</span><span class="stat-label">Answered</span></div>
                                    <div class="stat-box unanswered"><i class="fas fa-circle-notch"></i><span class="stat-count" id="modalUnanswered"><%= totalQ %></span><span class="stat-label">Unanswered</span></div>
                                    <div class="stat-box total"><i class="fas fa-clipboard-list"></i><span class="stat-count"><%= totalQ %></span><span class="stat-label">Total</span></div>
                                </div>
                            </div>
                            <div class="progress-bar-container">
                                <div class="progress-info"><span>Question Progress</span><span id="modalProgressText">0 / <%= totalQ %></span></div>
                                <div class="progress"><div class="progress-bar" id="modalProgressBar" style="width:0%"></div></div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn-secondary close-modal">Continue Exam</button>
                            <button type="button" id="modalSubmitBtn" class="btn-primary"><i class="fas fa-paper-plane"></i> Submit Exam</button>
                        </div>
                    </div>
                </div>

                <!-- TIME UP MODAL -->
                <div id="timeUpModal" class="alert-modal">
                    <div class="alert-modal-content alert-modal-warning">
                        <div class="alert-modal-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="alert-modal-body">
                            <h3>Time is Up!</h3>
                            <p>Your exam will be submitted automatically.</p>
                            <p class="alert-modal-timer">Submitting in <span id="timeUpCountdown">3</span> seconds...</p>
                        </div>
                    </div>
                </div>

                <!-- CONFIRM SUBMIT MODAL -->
                <div id="confirmSubmitModal" class="alert-modal">
                    <div class="alert-modal-content alert-modal-danger">
                        <div class="alert-modal-icon">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="alert-modal-body">
                            <h3>Confirm Submission</h3>
                            <p>Are you sure you want to submit your exam?</p>
                            <p class="alert-modal-warning-text">This action cannot be undone.</p>
                        </div>
                        <div class="alert-modal-footer">
                            <button type="button" class="btn-alert-secondary" onclick="closeConfirmSubmitModal()">Cancel</button>
                            <button type="button" class="btn-alert-danger" id="confirmSubmitBtn">Submit Exam</button>
                        </div>
                    </div>
                </div>

                <!-- QUESTION NAVIGATION MODAL -->
                <div id="questionNavModal" class="alert-modal" style="display: none;">
                    <div class="alert-modal-content" style="max-width: 800px; width: 90%;">
                        <div class="alert-modal-header" style="background: #09294d; color: white; padding: 20px; border-radius: 12px 12px 0 0;">
                            <h3 style="margin: 0; display: flex; align-items: center; gap: 10px;">
                                <i class="fas fa-list-ol"></i>
                                Question Navigation
                            </h3>
                            <button type="button" class="close-modal-btn" onclick="closeQuestionNavModal()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
                        </div>
                        <div class="alert-modal-body" style="padding: 20px;">
                            <p style="margin-bottom: 20px; color: #64748b;">Click on any question number to navigate directly to that question.</p>
                            <div id="questionGrid" class="question-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(60px, 1fr)); gap: 12px; max-height: 400px; overflow-y: auto; padding: 10px;">
                                <!-- Question icons will be populated by JavaScript -->
                            </div>
                        </div>
                        <div class="alert-modal-footer" style="padding: 15px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                            <div style="display: flex; gap: 15px; align-items: center;">
                                <div style="display: flex; align-items: center; gap: 5px;">
                                    <div style="width: 20px; height: 20px; background: #10b981; border-radius: 4px;"></div>
                                    <span style="font-size: 14px; color: #64748b;">Answered</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 5px;">
                                    <div style="width: 20px; height: 20px; background: #ef4444; border-radius: 4px;"></div>
                                    <span style="font-size: 14px; color: #64748b;">Unanswered</span>
                                </div>
                            </div>
                            <button type="button" class="btn-secondary" onclick="closeQuestionNavModal()">Close</button>
                        </div>
                    </div>
                </div>

                <!-- SUBMIT SECTION -->
                <div class="submit-section">
                    <div class="submit-card">
                        <div class="submit-header"><i class="fas fa-flag-checkered"></i><span>Ready to Submit</span></div>
                        <div class="submit-content">
                            <div class="warning-box">
                                <div class="warning-icon"><i class="fas fa-exclamation-triangle"></i></div>
                                <div class="warning-text">
                                    <strong>Final Review Required</strong>
                                    <p>Unanswered questions will be marked as incorrect. Please review all answers before submission.</p>
                                </div>
                            </div>
                            <div class="submit-stats">
                                <div class="stat-item"><span class="stat-number" id="submitAnswered">0</span><span class="stat-label">Answered</span></div>
                                <div class="stat-divider"></div>
                                <div class="stat-item"><span class="stat-number" id="submitUnanswered" style="cursor: pointer; text-decoration: underline;" onclick="handleUnansweredClick()"><%= totalQ %></span><span class="stat-label">Unanswered</span></div>
                                <div class="stat-divider"></div>
                                <div class="stat-item"><span class="stat-number"><%= totalQ %></span><span class="stat-label">Total</span></div>
                            </div>
                        </div>
                        <div class="submit-footer">
                            <button type="button" id="submitBtn" class="submit-btn">
                                <i class="fas fa-paper-plane"></i><span class="btn-text">Submit Exam</span>
                                <span class="btn-loading" style="display:none;"><i class="fas fa-spinner fa-spin"></i> Submitting...</span>
                            </button>
                            <div class="submit-guarantee"><i class="fas fa-shield-alt"></i><span>Your responses are securely recorded</span></div>
                        </div>
                    </div>
                </div>

                <!-- FIXED BOTTOM PANEL REMOVED -->
            </form>

            <!-- SCRIPT BLOCK -->
            <script>
/* --- GLOBAL VARIABLES - SAFE FOR JSP --- */
var examActive = true;
var warningGiven = false;
var dirty = false;
var timerInterval = null;

// Read values from server-side (JSP) to avoid relying on dataset/body attributes.
var examDuration = parseInt('<%= pDAO.getExamDuration(courseName) %>' || '60', 10);
var totalQuestions = parseInt('<%= totalQ %>' || '10', 10);
var currentCourseName = '<%= courseName %>' || '';
var currentQuestionIndex = 0;

// Proctoring variables - get from JSP safely
var examId = '<%= session.getAttribute("examId") != null ? session.getAttribute("examId") : "0" %>';
var studentId = '<%= session.getAttribute("userId") != null ? session.getAttribute("userId").toString() : "0" %>';

// Make variables globally available for external scripts
window.examId = examId;
window.studentId = studentId;

// Global stream for camera
var globalVideoStream = null;
            </script><script src="exam_logic.js"></script>

            <% } else if ("1".equals(request.getParameter("showresult"))) {
                        // SHOW RESULTS PAGE
                        Exams result = pDAO.getResultByExamId(Integer.parseInt(request.getParameter("eid")));
                        
                        // IMPORTANT: Clear exam session when showing results
                        session.removeAttribute("examStarted");
                        session.removeAttribute("examId");
                        
                        // Clear any pending exam timer data
                        session.removeAttribute("remainingTime");
                        session.removeAttribute("courseName");
                        
                        // Get result details directly from Exams object - NO REFLECTION NEEDED
                        String studentFullName = "Student";
                        String courseName = "Unknown Course";
                        String examDate = "N/A";
                        String startTime = "N/A";
                        String endTime = "N/A";
                        int obtainedMarks = 0;
                        int totalMarks = 0;
                        String resultStatus = "Unknown";
                        
                        // Fallback for status if it's missing or just "completed"
                        if (result != null) {
                            studentFullName = result.getFullName();
                            if (studentFullName == null || studentFullName.trim().isEmpty()) {
                                studentFullName = result.getUserName();
                            }
                            if (studentFullName == null || studentFullName.trim().isEmpty()) {
                                studentFullName = result.getEmail();
                            }
                            
                            courseName = result.getcName();
                            examDate = result.getDate();
                            startTime = result.getStartTime();
                            endTime = result.getEndTime();
                            obtainedMarks = result.getObtMarks();
                            totalMarks = result.gettMarks();
                            resultStatus = result.getStatus();
                            if (resultStatus == null || resultStatus.isEmpty() || resultStatus.equalsIgnoreCase("completed")) {
                                double percentage = (totalMarks > 0) ? (double) obtainedMarks / totalMarks * 100 : 0;
                                resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
                            }
                        }
                    %>
            <!-- RESULTS -->
            <div class="page-header">
                <div class="page-title"><i class="fas fa-chart-line"></i> Exam Result</div>
                <div class="stats-badge"><i class="fas fa-graduation-cap"></i> <%= resultStatus %></div>
            </div>
            <div class="result-card">
                <div class="result-grid">
                    <div class="result-item"><strong><i class="fas fa-calendar-alt"></i> Exam Date</strong><div class="result-value"><%= examDate %></div></div>
                    <div class="result-item"><strong><i class="fas fa-book"></i> Course Name</strong><div class="result-value"><%= courseName %></div></div>
                    <div class="result-item"><strong><i class="fas fa-clock"></i> Start Time</strong><div class="result-value"><%= startTime %></div></div>
                    <div class="result-item"><strong><i class="fas fa-clock"></i> End Time</strong><div class="result-value"><%= endTime %></div></div>
                    <div class="result-item"><strong><i class="fas fa-star"></i> Obtained Marks</strong><div class="result-value"><%= obtainedMarks %></div></div>
                    <div class="result-item"><strong><i class="fas fa-star-half-alt"></i> Total Marks</strong><div class="result-value"><%= totalMarks %></div></div>
                    <div class="result-item">
                        <strong><i class="fas fa-flag"></i> Result Status</strong>
                        <div class="result-value <%= resultStatus.equalsIgnoreCase("Pass")?"status-pass":"status-fail" %>">
                            <i class="fas <%= resultStatus.equalsIgnoreCase("Pass")?"fa-check-circle":"fa-times-circle" %>"></i> <%= resultStatus %>
                        </div>
                    </div>
                    <div class="result-item">
                        <strong><i class="fas fa-chart-pie"></i> Percentage</strong>
                        <div class="result-value">
                            <% 
                                double percentage = 0;
                                if(totalMarks > 0) {
                                    percentage = (double)obtainedMarks / totalMarks * 100;
                                }
                            %>
                            <span class="percentage-badge"><%= String.format("%.1f", percentage) %>%</span>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons
                <div style="text-align: center; margin-top: 20px;">
                    <a href="std-page.jsp?pgprt=2&eid=<%= request.getParameter("eid") %>" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd); margin-right: 10px;">
                        <i class="fas fa-eye"></i>
                        View Details
                    </a> -->
                </div>
                </div>
                                <!-- Action Buttons -->
                <div style="text-align: center; margin-top: 20px;">
                    <% String viewEid = (result != null) ? String.valueOf(result.getExamId()) : request.getParameter("eid"); %>
                    <a href="std-page.jsp?pgprt=2&eid=<%= viewEid %>" class="action-btn" style="background: linear-gradient(135deg, #4a90e2, #357abd); margin-right: 10px;">
                        <i class="fas fa-eye"></i>
                        View Details
                    </a>
                </div>
                <!-- RELAUNCH SECTION -->
                <div style="margin-top: 30px; padding: 20px; background: #f8fafc; border-radius: 10px; text-align: center; border-top: 2px solid #e2e8f0;">
                    <p style="margin-bottom: 20px; color: #64748b;">Ready to take another exam? Select a course below.</p>
                    <a href="std-page.jsp?pgprt=1"
                       class="btn-primary"
                       style="padding: 12px 30px; font-size: 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none;">
                        <h3 style="margin-bottom: 0; color: #ffffff;">
                            <i class="fas fa-redo"></i> Take Another Exam
                        </h3>
                    </a>
                </div>
            </div>
            
            <!-- CLEAR EXAM SESSION DATA -->
            <script>
                // Clear all exam session data when viewing results
                Object.keys(sessionStorage).forEach(function(key) {
                    if(key.startsWith('examStartTime_')) {
                        sessionStorage.removeItem(key);
                    }
                });
                
                // Also clear any other exam-related data
                sessionStorage.clear();
        
        // Verification JavaScript for name validation and digital signature
        document.addEventListener('DOMContentLoaded', function() {
            // Auto-start proctoring if flag is set (from exam start page)
            try {
                const proctorAutoStart = sessionStorage.getItem('proctorAutoStart');
                if (proctorAutoStart === '1' && typeof ProctoringSystem === 'function') {
                    console.log('🔒 Auto-starting proctoring system...');
                    
                    // Clear the flag immediately
                    sessionStorage.removeItem('proctorAutoStart');
                    
                    // Initialize proctoring
                    async function startProctoring() {
                        try {
                            // Request camera and microphone
                            const stream = await navigator.mediaDevices.getUserMedia({ 
                                video: {
                                    width: { ideal: 1280 },
                                    height: { ideal: 720 },
                                    frameRate: { ideal: 30 }
                                }, 
                                audio: true 
                            });
                            
                            // Create proctor instance
                            const proctor = new ProctoringSystem(
                                '<%= request.getParameter("eid") != null ? request.getParameter("eid") : "0" %>',
                                '<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "0" %>'
                            );
                            
                            window.proctor = proctor;
                            await proctor.initialize(stream);
                            
                            console.log('✅ Proctoring auto-started successfully');
                            
                        } catch (err) {
                            console.error('❌ Proctoring auto-start failed:', err);
                            
                            // Show manual start option
                            const startBtn = document.createElement('button');
                            startBtn.innerHTML = '🔒 Start Proctoring';
                            startBtn.style.cssText = 
                                'position: fixed; top: 20px; right: 20px; background: #ef4444; color: white; ' +
                                'padding: 15px 25px; border: none; border-radius: 8px; cursor: pointer; ' +
                                'font-size: 16px; font-weight: 600; z-index: 9999; box-shadow: 0 4px 15px rgba(0,0,0,0.3);';
                            
                            startBtn.onclick = async () => {
                                try {
                                    startBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Starting...';
                                    startBtn.disabled = true;
                                    
                                    const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                                    const proctor = new ProctoringSystem(
                                        '<%= request.getParameter("eid") != null ? request.getParameter("eid") : "0" %>',
                                        '<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "0" %>'
                                    );
                                    
                                    window.proctor = proctor;
                                    await proctor.initialize(stream);
                                    
                                    startBtn.remove();
                                    console.log('✅ Manual proctoring started successfully');
                                    
                                } catch (manualErr) {
                                    console.error('Manual proctoring start failed:', manualErr);
                                    startBtn.innerHTML = '❌ Failed - Retry';
                                    startBtn.disabled = false;
                                    startBtn.style.background = '#dc2626';
                                }
                            };
                            
                            document.body.appendChild(startBtn);
                        }
                    }
                    
                    // Start proctoring
                    startProctoring();
                    
                    // Add proctoring status indicator
                    setInterval(() => {
                        if (window.proctor && window.proctor.examActive) {
                            console.log('✅ Proctoring is active and monitoring');
                        } else {
                            console.warn('⚠️ Proctoring is not active');
                        }
                    }, 10000); // Check every 10 seconds
                }
            } catch (err) {
                console.warn('Could not check proctor auto-start flag:', err);
            }
            
            const nameInput = document.getElementById('nameInput');
            const digitalSignature = document.getElementById('digitalSignature');
            
            if (nameInput) {
                nameInput.addEventListener('input', function(e) {
                    const nameInput = e.target.value.trim();
                    const nameValidation = document.getElementById('nameValidation');
                    const honorCodeCheckbox = document.getElementById('honorCodeCheckbox');
                    
                    if (nameInput.length < 2) {
                        if (nameValidation) {
                            nameValidation.style.display = 'block';
                            nameValidation.style.color = '#ef4444';
                            nameValidation.innerHTML = '<i class="fas fa-times-circle"></i> Name is too short';
                        }
                        if (honorCodeCheckbox) honorCodeCheckbox.disabled = true;
                        const signatureSection = document.getElementById('signatureSection');
                        if (signatureSection) signatureSection.style.display = 'none';
                        return;
                    }
                    
                    // Check if name exists in system (using session user info)
                    const currentUserName = '<%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "" %>';
                    const currentUserFullName = '<%= session.getAttribute("userFullName") != null ? session.getAttribute("userFullName") : "" %>';
                    
                    if (nameInput.toLowerCase() === currentUserName.toLowerCase() || 
                        nameInput.toLowerCase() === currentUserFullName.toLowerCase()) {
                        if (nameValidation) {
                            nameValidation.style.display = 'block';
                            nameValidation.style.color = '#22c55e';
                            nameValidation.innerHTML = '<i class="fas fa-check-circle"></i> Name verified in system';
                        }
                        if (honorCodeCheckbox) honorCodeCheckbox.disabled = false;
                        window.verifiedUserName = nameInput;
                    } else {
                        if (nameValidation) {
                            nameValidation.style.display = 'block';
                            nameValidation.style.color = '#ef4444';
                            nameValidation.innerHTML = '<i class="fas fa-times-circle"></i> Name not found in system. Please enter your registered name.';
                        }
                        if (honorCodeCheckbox) honorCodeCheckbox.disabled = true;
                        const signatureSection = document.getElementById('signatureSection');
                        if (signatureSection) signatureSection.style.display = 'none';
                    }
                });
            }
            
            const honorCodeCheckbox = document.getElementById('honorCodeCheckbox');
            if (honorCodeCheckbox) {
                honorCodeCheckbox.addEventListener('change', function(e) {
                    const signatureSection = document.getElementById('signatureSection');
                    const displayName = document.getElementById('displayName');
                    
                    if (e.target.checked && window.verifiedUserName) {
                        if (signatureSection) {
                            signatureSection.style.display = 'block';
                            if (displayName) displayName.textContent = window.verifiedUserName;
                        }
                    } else {
                        if (signatureSection) signatureSection.style.display = 'none';
                    }
                });
            }
            
            if (digitalSignature) {
                digitalSignature.addEventListener('input', function(e) {
                    const signature = e.target.value.trim();
                    const signatureValidation = document.getElementById('signatureValidation');
                    
                    if (signature.length < 2) {
                        if (signatureValidation) {
                            signatureValidation.style.display = 'block';
                            signatureValidation.style.color = '#ef4444';
                            signatureValidation.innerHTML = '<i class="fas fa-times-circle"></i> Please enter your full name';
                        }
                        return;
                    }
                    
                    if (signature === window.verifiedUserName) {
                        if (signatureValidation) {
                            signatureValidation.style.display = 'block';
                            signatureValidation.style.color = '#22c55e';
                            signatureValidation.innerHTML = '<i class="fas fa-check-circle"></i> Digital signature confirmed';
                        }
                    } else {
                        if (signatureValidation) {
                            signatureValidation.style.display = 'block';
                            signatureValidation.style.color = '#ef4444';
                            signatureValidation.innerHTML = '<i class="fas fa-times-circle"></i> Names do not match. Please retype your name exactly as shown above.';
                        }
                    }
                });
            }
        });
    </script>
    <% } else { 
            // SHOW COURSE SELECTION FORM (DEFAULT VIEW)
            // Clear any stale session data
            session.removeAttribute("examStarted");
            session.removeAttribute("examId");
            session.removeAttribute("remainingTime");
            session.removeAttribute("courseName");
        %>
        <!-- EXAM SELECTION -->
        <div class="page-header">
            <div class="page-title"><i class="fas fa-file-alt"></i> Take Exam</div>
            <div class="stats-badge"><i class="fas fa-clipboard-check"></i> Available Exams</div>
        </div>

        <div class="course-card">
            <form action="controller.jsp" method="post" id="examStartForm">
                <input type="hidden" name="page" value="exams">
                <input type="hidden" name="operation" value="startexam">
                <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") != null ? session.getAttribute("csrf_token") : "" %>">
<!--                <label class="form-label"><i class="fas fa-book"></i> Select Course</label>-->
                <select name="coursename" class="form-select" required id="courseSelect">
                    <option value="">Choose a course...</option>
        
            <% 
                // Get only ACTIVE courses - using the new method
                ArrayList<String> activeCourseNames = pDAO.getActiveCourseNames();
                if (activeCourseNames != null && !activeCourseNames.isEmpty()) {
                    for(String courseName : activeCourseNames){ 
                        if (courseName != null && !courseName.trim().isEmpty()) {
                            int duration = pDAO.getExamDuration(courseName);
            %>
            <option value="<%= courseName %>" data-duration="<%= duration %>">
                <%= courseName %> (<%= formatDuration(duration) %>)
            </option>
            <% 
                        }
                    }
                } else {
            %>
            <option value="" disabled>No exams available</option>
            <% } %>
                </select>

                <!-- Course Info Display -->
                <div id="courseInfo" style="margin-top: 10px; padding: 10px; background: #f0f9ff; border-radius: 6px; display: none;">
                    <i class="fas fa-info-circle" style="color: #3b82f6;"></i>
                    <span id="courseInfoText"></span>
                </div>

                <!-- No Exams Message -->
                <% if (activeCourseNames == null || activeCourseNames.isEmpty()) { %>
                <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin-top: 15px; text-align: center; border: 1px solid #e2e8f0;">
                    <i class="fas fa-calendar-times" style="color: #64748b; font-size: 24px; margin-bottom: 10px;"></i>
                    <p style="color: #64748b; margin: 0;">No active exams are currently available. Please check back later.</p>
                </div>
                <% } %>

                <button type="submit" class="start-exam-btn" id="startExamBtn" 
                        <% if (activeCourseNames == null || activeCourseNames.isEmpty()) { %>disabled<% } %>>
                    <i class="fas fa-play"></i> Take Exam
                </button>
            </form>
        </div>
            
<!-- CLEAR EXAM SESSION DATA -->
<script>
    function requestFullscreenSafe() {
        try {
            if (document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement) {
                return;
            }

            var el = document.documentElement;
            var req = el.requestFullscreen || el.webkitRequestFullscreen || el.mozRequestFullScreen || el.msRequestFullscreen;
            if (req) {
                var p = req.call(el);
                if (p && typeof p.catch === 'function') {
                    p.catch(function() {});
                }
            }
        } catch (e) {
            // ignore
        }
    }

    // Global modal-based messaging (replaces alert() to preserve fullscreen)
    window.closeSystemAlertModal = window.closeSystemAlertModal || function () {
        try {
            var modal = document.getElementById('systemAlertModal');
            if (modal && modal.classList) {
                modal.classList.remove('active');
            }
        } catch (e) {
            // ignore
        }
    };

    window.showSystemAlertModal = window.showSystemAlertModal || function (message) {
        try {
            var modal = document.getElementById('systemAlertModal');

            // Create the modal if it doesn't exist on the current view
            if (!modal) {
                modal = document.createElement('div');
                modal.id = 'systemAlertModal';
                modal.className = 'alert-modal';
                modal.innerHTML = '' +
                    '<div class="alert-modal-content" style="max-width: 520px; width: 92%;">' +
                        '<div class="alert-modal-header" style="background: #09294d; color: white; padding: 18px 20px; border-radius: 12px 12px 0 0; display: flex; justify-content: space-between; align-items: center;">' +
                            '<h3 style="margin: 0; display: flex; align-items: center; gap: 10px; font-size: 18px;">' +
                                '<i class="fas fa-info-circle"></i>' +
                                'Notice' +
                            '</h3>' +
                            '<button type="button" class="close-modal-btn" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>' +
                        '</div>' +
                        '<div class="alert-modal-body" style="padding: 18px 20px;">' +
                            '<p id="systemAlertMessage" style="margin: 0; color: #334155; font-size: 15px; line-height: 1.5;"></p>' +
                        '</div>' +
                        '<div class="alert-modal-footer" style="padding: 14px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end;">' +
                            '<button type="button" class="btn-secondary">OK</button>' +
                        '</div>' +
                    '</div>';
                document.body.appendChild(modal);

                // Wire close handlers
                var closeBtn = modal.querySelector('.close-modal-btn');
                if (closeBtn) closeBtn.addEventListener('click', window.closeSystemAlertModal);
                var okBtn = modal.querySelector('.btn-secondary');
                if (okBtn) okBtn.addEventListener('click', window.closeSystemAlertModal);

                // Clicking outside closes
                modal.addEventListener('click', function (e) {
                    if (e.target === modal) window.closeSystemAlertModal();
                });
            }

            var msg = document.getElementById('systemAlertMessage');
            if (msg) msg.textContent = message || '';
            if (modal && modal.classList) {
                modal.classList.add('active');
            }
        } catch (e) {
            // ignore
        }
    };

    // Clear all exam session data when on course selection page
    Object.keys(sessionStorage).forEach(function(key) {
        if(key.startsWith('examStartTime_')) {
            sessionStorage.removeItem(key);
        }
    });
    
    // Clear all session storage to ensure clean state
    sessionStorage.clear();
    
    // Show course info when selected
    document.getElementById('courseSelect').addEventListener('change', function() {
        var selectedOption = this.options[this.selectedIndex];
        var courseInfo = document.getElementById('courseInfo');
        var courseInfoText = document.getElementById('courseInfoText');
        
        if(selectedOption.value) {
            var duration = selectedOption.getAttribute('data-duration') || '60';
            courseInfoText.textContent = 'This exam has a duration of ' + duration + ' minutes.';
            courseInfo.style.display = 'block';
        } else {
            courseInfo.style.display = 'none';
        }
    });
    
    // Check course status function
    function checkCourseStatus(courseName, callback) {
        console.log('Checking course status for:', courseName);

        // Get CSRF token
        const csrfTokenInput = document.querySelector('input[name="csrf_token"]');
        if (!csrfTokenInput || !csrfTokenInput.value) {
            console.error('CSRF token not found');
            callback(true); // Assume active on error
            return;
        }

        // Create form data
        const formData = new FormData();
        formData.append('page', 'exams');
        formData.append('operation', 'checkCourseStatus');
        formData.append('courseName', courseName);
        formData.append('csrf_token', csrfTokenInput.value);

        console.log('Sending AJAX request to check course status...');

        // Send AJAX request with timeout
        const timeout = 5000; // 5 second timeout

        // Create abort controller for timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => {
            controller.abort();
            console.log('Request timeout');
        }, timeout);

        fetch('controller.jsp', {
            method: 'POST',
            body: formData,
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);

            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.status + ' ' + response.statusText);
            }
            return response.text();
        })
        .then(data => {
            console.log('Raw response data:', data);
            console.log('Response length:', data.length);

            // Trim and parse response
            const trimmedData = data.trim();
            console.log('Trimmed data:', trimmedData);

            // Check if response is "true" or "false"
            if (trimmedData === 'true' || trimmedData === 'false') {
                const isActive = trimmedData === 'true';
                console.log('Course is active:', isActive);
                callback(isActive);
            } else {
                console.error('Unexpected response format:', trimmedData);
                // If we get an unexpected response, assume course is active
                // because getActiveCourseNames() already filtered inactive ones
                console.log('Assuming course is active due to unexpected response format');
                callback(true);
            }
        })
        .catch(error => {
            clearTimeout(timeoutId);
            console.error('Error checking course status:', error);
            console.error('Error name:', error.name);
            console.error('Error message:', error.message);

            // Show error message only if it's not an abort error
            if (error.name === 'AbortError') {
                console.log('Request aborted due to timeout');
            } else {
                console.log('Error:', error.message);
            }
            // Default to true on error (since getActiveCourseNames already filtered)
            callback(true);
        });
    }
    
    // Confirm before starting exam (using modal instead of alert)
    document.getElementById('examStartForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        var courseSelect = document.getElementById('courseSelect');
        if(!courseSelect || !courseSelect.value) {
            if (typeof showSystemAlertModal === 'function') {
                showSystemAlertModal('Please select a course.');
            }
            return;
        }
        
        var selectedOption = courseSelect.options[courseSelect.selectedIndex];
        var courseName = selectedOption.value;
        var duration = selectedOption.getAttribute('data-duration') || '60';
        
        // Get modal elements
        var confirmationModal = document.getElementById('confirmationModal');
        var inactiveModal = document.getElementById('inactiveModal');
        var modalCourseName = document.getElementById('modalCourseName');
        var modalDuration = document.getElementById('modalDuration');
        var inactiveCourseName = document.getElementById('inactiveCourseName');
        
        if (!confirmationModal || !inactiveModal || !modalCourseName || !modalDuration || !inactiveCourseName) {
            console.error('Modal elements not found');
            if (typeof showSystemAlertModal === 'function') {
                showSystemAlertModal('System error: Modal elements not found. Please refresh the page.');
            }
            return;
        }
        
        checkCourseStatus(courseName, function(isActive) {
            if (isActive) {
                modalCourseName.textContent = courseName;
                modalDuration.textContent = duration + ' minutes';
                // Show Diagnostics first
                // Attempt fullscreen immediately from this user gesture (required by browsers).
                requestFullscreenSafe();
                document.getElementById('diagnosticsModal').style.display = 'flex';
                runDiagnostics();
            } else {
                inactiveCourseName.textContent = courseName;
                inactiveModal.style.display = 'flex';
            }
        });
    });
</script>
        <% } %>

        <!-- Scientific Calculator -->
        <div id="calculatorModal" class="calculator-modal">
            <div class="calc-header" id="calcHeader">
                <div class="calc-title"><i class="fas fa-calculator"></i> Scientific Calculator</div>
                <button type="button" class="close-modal" onclick="toggleCalculator()" style="color: #666; font-size: 20px; border:none; background:none; cursor:pointer;">&times;</button>
            </div>
            <div class="calc-display">
                <div id="calcHistory" class="calc-history"></div>
                <div id="calcDisplay" class="calc-main-val">0</div>
            </div>
            <div class="calc-buttons">
                <button type="button" class="calc-btn sci" onclick="calcAction('sin')">sin</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('cos')">cos</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('tan')">tan</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('sqrt')">?</button>
                
                <button type="button" class="calc-btn sci" onclick="calcAction('log')">log</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('ln')">ln</button>
                <button type="button" class="calc-btn sci" onclick="calcAction('pow')">x^y</button>
                <button type="button" class="calc-btn op" onclick="calcAction('clear')">AC</button>

                <button type="button" class="calc-btn" onclick="calcInput('7')">7</button>
                <button type="button" class="calc-btn" onclick="calcInput('8')">8</button>
                <button type="button" class="calc-btn" onclick="calcInput('9')">9</button>
                <button type="button" class="calc-btn op" onclick="calcInput('/')">/</button>

                <button type="button" class="calc-btn" onclick="calcInput('4')">4</button>
                <button type="button" class="calc-btn" onclick="calcInput('5')">5</button>
                <button type="button" class="calc-btn" onclick="calcInput('6')">6</button>
                <button type="button" class="calc-btn op" onclick="calcInput('*')">&times;</button>

                <button type="button" class="calc-btn" onclick="calcInput('1')">1</button>
                <button type="button" class="calc-btn" onclick="calcInput('2')">2</button>
                <button type="button" class="calc-btn" onclick="calcInput('3')">3</button>
                <button type="button" class="calc-btn op" onclick="calcInput('-')">-</button>

                <button type="button" class="calc-btn" onclick="calcInput('0')">0</button>
                <button type="button" class="calc-btn" onclick="calcInput('.')">.</button>
                <button type="button" class="calc-btn op" onclick="calcInput('+')">+</button>
                <button type="button" class="calc-btn op" onclick="calcAction('backspace')"><i class="fas fa-backspace"></i></button>
                
                <button type="button" class="calc-btn sci" onclick="calcInput('Math.PI')">?</button>
                <button type="button" class="calc-btn sci" onclick="calcInput('Math.E')">e</button>
                <button type="button" class="calc-btn eq" onclick="calcAction('equal')">=</button>
            </div>
        </div>

        <!-- Rough Paper -->
        <div id="roughPaperModal" class="rough-paper-modal">
            <div class="rough-header" id="roughHeader">
                <div><i class="fas fa-sticky-note"></i> Rough Paper</div>
                <button type="button" onclick="toggleRoughPaper()" style="border:none; background:none; cursor:pointer; font-size: 18px;">&times;</button>
            </div>
            <div class="rough-content">
                <textarea id="roughTextarea" class="rough-textarea" placeholder="Use this space for your rough work... (auto-saves)"></textarea>
            </div>
        </div>
    </main>
</div>

<!-- Identity Verification Modal -->
<div id="identityVerificationModal" class="modal-overlay" style="display: none;">
    <div class="modal-container" style="max-width: 800px; width: 95%;">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-user-shield"></i> Exam Policy and Candidate Identity Verification</h3>
        </div>
        <div class="modal-body">
            <!-- Step Navigation -->
            <div style="display: flex; justify-content: space-around; margin-bottom: 30px; border-bottom: 2px solid #f1f5f9; padding-bottom: 15px;">
                <div id="step-nav-1" style="text-align: center; color: var(--primary-blue); font-weight: bold;">
                    <div style="width: 30px; height: 30px; border-radius: 50%; background: var(--primary-blue); color: white; display: flex; align-items: center; justify-content: center; margin: 0 auto 5px;">1</div>
                    <span style="font-size: 12px;">Code of Honor</span>
                </div>
                <div id="step-nav-2" style="text-align: center; color: #cbd5e1;">
                    <div style="width: 30px; height: 30px; border-radius: 50%; background: #cbd5e1; color: white; display: flex; align-items: center; justify-content: center; margin: 0 auto 5px;">2</div>
                    <span style="font-size: 12px;">Face Photo</span>
                </div>
                <div id="step-nav-3" style="text-align: center; color: #cbd5e1;">
                    <div style="width: 30px; height: 30px; border-radius: 50%; background: #cbd5e1; color: white; display: flex; align-items: center; justify-content: center; margin: 0 auto 5px;">3</div>
                    <span style="font-size: 12px;">ID Verification</span>
                </div>
                <div id="step-nav-4" style="text-align: center; color: #cbd5e1;">
                    <div style="width: 30px; height: 30px; border-radius: 50%; background: #cbd5e1; color: white; display: flex; align-items: center; justify-content: center; margin: 0 auto 5px;">4</div>
                    <span style="font-size: 12px;">Summary</span>
                </div>
            </div>

            <!-- Step 1: Code of Honor -->
            <div id="verification-step-1" class="verification-step">
                <h4 style="margin-bottom: 15px; color: var(--primary-blue);">Candidate Identity Verification Step 1: Name Verification</h4>
                
                <!-- Name Verification Field -->
                <div id="nameVerificationSection" style="margin-bottom: 25px; padding: 20px; background: #f0f9ff; border-radius: 8px; border: 1px solid #bae6fd;">
                    <label style="display: block; font-size: 14px; font-weight: 600; margin-bottom: 10px; color: var(--primary-blue);">Please enter your name to begin:</label>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" id="studentNameInput" placeholder="Enter your registered name" style="flex: 1; padding: 12px; border: 2px solid #cbd5e1; border-radius: 6px; font-size: 15px;">
                        <button type="button" id="verifyNameBtn" class="btn-primary" style="padding: 0 25px; border-radius: 6px;">Verify</button>
                    </div>
                    <div id="nameVerificationMessage" style="margin-top: 10px; font-size: 13px; display: none;"></div>
                </div>

                <!-- Honor Code Section (Initially Hidden) -->
                <div id="honorCodeSection" style="display: none;">
                    <h4 style="margin-bottom: 15px; color: var(--primary-blue);">Code of Honor</h4>
                    <div style="background: #f8fafc; padding: 20px; border-radius: 8px; border: 1px solid #e2e8f0; max-height: 250px; overflow-y: auto; font-size: 14px; line-height: 1.6;">
                        <p><strong>HONOR CODE AGREEMENT</strong></p>
                        <p>As a candidate for this examination, I hereby acknowledge and agree to the following conditions:</p>
                        <ul>
                            <li>I will not use any unauthorized materials, including but not limited to textbooks, notes, or electronic devices during the exam.</li>
                            <li>I will not communicate with any other individual by any means during the examination.</li>
                            <li>I will remain within the view of the camera at all times and will not leave my seat without proper authorization.</li>
                            <li>I understand that my session will be monitored via audio and video, and any suspicious behavior will be flagged for review.</li>
                            <li>I will not copy, record, or distribute any part of the examination content.</li>
                            <li>I confirm that I am the person registered to take this exam.</li>
                        </ul>
                        <p>Violation of these rules may lead to immediate disqualification and further disciplinary action by the institution.</p>
                    </div>
                    <div style="margin-top: 20px; display: flex; align-items: center; gap: 10px;">
                        <input type="checkbox" id="honorCodeCheckbox" style="width: 20px; height: 20px; cursor: pointer;">
                        <label for="honorCodeCheckbox" style="font-size: 14px; font-weight: 600; cursor: pointer;">I agree to the Code of Honor and understand the consequences of cheating.</label>
                    </div>
                    <div id="signatureSection" style="margin-top: 15px; display: none;">
                        <label style="display: block; font-size: 14px; margin-bottom: 5px; color: #64748b;">Type your full name as digital signature:</label>
                        <input type="text" id="digitalSignature" placeholder="Enter your full name" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 4px;">
                    </div>
                </div>
            </div>

            <!-- Step 2: Face Photo -->
<div id="verification-step-2" class="verification-step" style="display: none;">
    <div class="step-header">
        <span class="step-badge">Step 2 of 4</span>
        <h4 class="step-title">Face Photo Verification</h4>
        <p class="step-description">Please capture a clear photo of your face for identity verification</p>
    </div>

    <div class="verification-grid">
        <!-- Camera Preview Section -->
        <div class="camera-section">
            <div class="camera-container">
                <video id="faceVideo" autoplay playsinline class="camera-feed"></video>
                <canvas id="faceOverlay" class="camera-overlay"></canvas>
                <div id="faceAlignmentGuide" class="face-guide"></div>
                
                <!-- Camera Status Indicator -->
                <div id="cameraStatus" class="camera-status">
                    <i class="fas fa-video"></i>
                    <span>Camera active</span>
                </div>
            </div>

            <!-- Capture Button -->
            <button type="button" id="captureFaceBtn" class="btn-capture">
                <i class="fas fa-camera"></i>
                <span>Capture Photo</span>
            </button>

            <!-- Retake Option (shown after capture) -->
            <div id="retakeSection" class="retake-section" style="display: none;">
                <button type="button" id="retakeFaceBtn" class="btn-text">
                    <i class="fas fa-redo-alt"></i> Retake Photo
                </button>
            </div>
        </div>

        <!-- Instructions & Preview Section -->
        <div class="info-section">
            <!-- Live Preview (shown before capture) -->
            <div id="liveInstructions" class="instruction-card">
                <div class="instruction-header">
                    <i class="fas fa-info-circle"></i>
                    <h5>Photo Guidelines</h5>
                </div>
                
                <div class="guideline-list">
                    <div class="guideline-item">
                        <div class="guideline-icon success-bg">
                            <i class="fas fa-check"></i>
                        </div>
                        <div class="guideline-text">
                            <strong>Position your face</strong>
                            <span>Keep your face within the dashed oval guide</span>
                        </div>
                    </div>
                    
                    <div class="guideline-item">
                        <div class="guideline-icon warning-bg">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="guideline-text">
                            <strong>Avoid wearing</strong>
                            <span>Hats, sunglasses, masks, or anything covering your face</span>
                        </div>
                    </div>
                    
                    <div class="guideline-item">
                        <div class="guideline-icon warning-bg">
                            <i class="fas fa-sun"></i>
                        </div>
                        <div class="guideline-text">
                            <strong>Ensure proper lighting</strong>
                            <span>Avoid strong backlighting - your face should be well-lit and clearly visible</span>
                        </div>
                    </div>
                    
                    <div class="guideline-item">
                        <div class="guideline-icon warning-bg">
                            <i class="fas fa-user-friends"></i>
                        </div>
                        <div class="guideline-text">
                            <strong>Be alone in frame</strong>
                            <span>Ensure no other people appear in the camera frame</span>
                        </div>
                    </div>
                    
                    <div class="guideline-item">
                        <div class="guideline-icon success-bg">
                            <i class="fas fa-eye"></i>
                        </div>
                        <div class="guideline-text">
                            <strong>Look directly at camera</strong>
                            <span>Face the camera directly with eyes visible</span>
                        </div>
                    </div>
                </div>

                <!-- Lighting Quality Indicator (Dynamic) -->
                <div id="lightingIndicator" class="quality-indicator" style="display: none;">
                    <div class="indicator-label">
                        <span>Lighting Quality</span>
                        <span id="lightingScore">Good</span>
                    </div>
                    <div class="progress-bar">
                        <div id="lightingProgress" class="progress-fill good" style="width: 80%"></div>
                    </div>
                </div>
            </div>

            <!-- Captured Preview (shown after capture) -->
            <div id="faceCapturedPreview" class="preview-card" style="display: none;">
                <div class="preview-header">
                    <i class="fas fa-check-circle success-icon"></i>
                    <h5>Photo Captured Successfully</h5>
                </div>
                
                <div class="preview-image-container">
                    <img id="faceImgPreview" class="preview-image" alt="Captured face photo">
                    <div class="preview-badge">VERIFIED</div>
                </div>

                <!-- Quality Check Results -->
                <div class="quality-checks">
                    <div class="check-item passed">
                        <i class="fas fa-check-circle"></i>
                        <span>Face properly positioned</span>
                    </div>
                    <div class="check-item passed">
                        <i class="fas fa-check-circle"></i>
                        <span>No face coverings detected</span>
                    </div>
                    <div class="check-item passed">
                        <i class="fas fa-check-circle"></i>
                        <span>Lighting adequate</span>
                    </div>
                    <div class="check-item passed">
                        <i class="fas fa-check-circle"></i>
                        <span>Single person in frame</span>
                    </div>
                </div>

                <p class="preview-note">
                    <i class="fas fa-shield-alt"></i>
                    This photo will be stored securely and used for identity verification throughout your exam.
                </p>
            </div>
        </div>
    </div>
</div>

            <!-- Step 3: ID Verification -->
            <div id="verification-step-3" class="verification-step" style="display: none;">
                <h4 style="margin-bottom: 15px; color: var(--primary-blue);">Candidate Identity Verification Step 3: ID Verification</h4>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div style="text-align: center;">
                        <div style="background: #000; border-radius: 8px; overflow: hidden; aspect-ratio: 4/3;">
                            <video id="idVideo" autoplay playsinline style="width: 100%; height: 100%; object-fit: cover;"></video>
                        </div>
                        <button type="button" id="captureIdBtn" class="btn-primary" style="margin-top: 15px; width: 100%;">
                            <i class="fas fa-id-card"></i> Capture ID Photo
                        </button>
                    </div>
                    <div style="background: #fffbeb; padding: 20px; border-radius: 8px; border-left: 4px solid var(--warning);">
                        <p style="font-weight: 600; color: #92400e; margin-bottom: 10px;">ID Guidelines:</p>
                        <ul style="font-size: 13px; color: #92400e; line-height: 1.8;">
                            <li>Hold your government-issued ID close to the camera.</li>
                            <li>Ensure your name and photo on the ID are clearly visible.</li>
                            <li>Avoid glare on the ID surface.</li>
                            <li>Keep the ID flat and steady.</li>
                        </ul>
                        <div id="idCapturedPreview" style="margin-top: 15px; display: none;">
                            <p style="font-size: 12px; font-weight: bold; color: var(--success); margin-bottom: 5px;"><i class="fas fa-check-circle"></i> ID Photo Captured Successfully</p>
                            <img id="idImgPreview" style="width: 100%; border-radius: 4px; border: 1px solid #cbd5e1;">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Step 4: Summary -->
            <div id="verification-step-4" class="verification-step" style="display: none; text-align: center; padding: 40px 0;">
                <div style="width: 80px; height: 80px; background: #d1fae5; color: var(--success); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 40px; margin: 0 auto 20px;">
                    <i class="fas fa-check"></i>
                </div>
                <h3 style="color: var(--text-dark); margin-bottom: 10px;">Verification Complete!</h3>
                <p style="color: #64748b; margin-bottom: 30px;">All identity checks have been successfully completed. You are now authorized to begin the examination.</p>
                
                <div style="display: flex; justify-content: center; gap: 15px;">
                    <div style="width: 120px;">
                        <img id="summaryFaceImg" style="width: 100%; border-radius: 8px; border: 2px solid var(--success);">
                        <p style="font-size: 11px; margin-top: 5px;">Face Photo</p>
                    </div>
                    <div style="width: 120px;">
                        <img id="summaryIdImg" style="width: 100%; border-radius: 8px; border: 2px solid var(--success);">
                        <p style="font-size: 11px; margin-top: 5px;">ID Card</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button id="verifyPrevBtn" class="btn-secondary" style="display: none;">Previous</button>
            <button id="verifyNextBtn" class="btn-primary">Next</button>
            <button id="verifyFinalBtn" class="btn-primary" style="display: none; background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));">Proceed to Exam</button>
        </div>
    </div>
</div>

<!-- Diagnostics Modal -->
<div id="diagnosticsModal" class="modal-overlay" style="display: none;">
    <div class="modal-container" style="max-width: 650px;">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-diagnoses"></i> Diagnostics Check</h3>
        </div>
        <div class="modal-body">
            <div class="diagnostics-intro">
                <h4>Diagnostics Check</h4>
            </div>
            
            <div class="diagnostics-grid">
                <div class="diag-item" id="diag-internet">
                    <div class="diag-info">
                        <strong>Active Internet Connection</strong>
                    </div>
                    <div class="diag-status" id="status-internet"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
                
                <div class="diag-item" id="diag-browser">
                    <div class="diag-info">
                        <strong>Internet Browser</strong>
                    </div>
                    <div class="diag-status" id="status-browser"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
                
                <div class="diag-item" id="diag-javascript">
                    <div class="diag-info">
                        <strong>JavaScript Enabled</strong>
                    </div>
                    <div class="diag-status" id="status-javascript"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
                
                <div class="diag-item" id="diag-resolution">
                    <div class="diag-info">
                        <strong>Screen Resolution</strong>
                    </div>
                    <div class="diag-status" id="status-resolution"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
                
                <div class="diag-item" id="diag-os">
                    <div class="diag-info">
                        <strong>Operating System</strong>
                    </div>
                    <div class="diag-status" id="status-os"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
                
                <div class="diag-item" id="diag-camera">
                    <div class="diag-info">
                        <strong>Camera Enabled</strong>
                    </div>
                    <div class="diag-status" id="status-camera"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
                
                <div class="diag-item" id="diag-environment">
                    <div class="diag-info">
                        <strong>Exam Environment</strong>
                    </div>
                    <div class="diag-status" id="status-environment"><i class="fas fa-spinner fa-spin"></i></div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button id="diagCancelButton" class="btn-secondary">Cancel</button>
            <button id="diagRetryButton" class="btn-secondary" style="display: none;">Retry</button>
            <button id="diagProceedButton" class="btn-primary" disabled>Continue</button>
        </div>
    </div>
</div>

<!-- Confirmation Modal (for course selection) -->
<div id="confirmationModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Confirm Exam Start</h3>
        </div>
        <div class="modal-body">
            <p>Are you ready to start the "<strong id="modalCourseName"></strong>" exam?</p>
            <ul>
                <li><i class="fas fa-clock"></i><strong>Exam Duration:</strong> <span id="modalDuration"></span> minutes</li>
                <li><i class="fas fa-hourglass-start"></i>The timer will start immediately.</li>
                <li><i class="fas fa-lock"></i>You cannot leave the page until you submit.</li>
            </ul>
        </div>
        <div class="modal-footer">
            <button id="cancelButton" class="btn-secondary">Cancel</button>
            <button id="beginButton" class="btn-primary">Begin Exam</button>
        </div>
    </div>
</div>

<!-- Inactive Course Modal -->
<div id="inactiveModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header" style="background-color: #dc3545;">
            <h3 class="modal-title"><i class="fas fa-exclamation-circle"></i> Course Not Available</h3>
        </div>
        <div class="modal-body">
            <div style="text-align: center; margin-bottom: 20px;">
                <i class="fas fa-lock fa-3x" style="color: #dc3545; margin-bottom: 15px;"></i>
                <h4 style="color: #dc3545; margin-bottom: 10px;">Exam Temporarily Unavailable</h4>
            </div>
            <p>The "<strong id="inactiveCourseName"></strong>" exam is currently <strong style="color: #dc3545;">NOT ACTIVE</strong>.</p>
            <ul style="color: #6c757d;">
                <li><i class="fas fa-calendar-times"></i> This exam has been deactivated by the administrator</li>
                <li><i class="fas fa-user-clock"></i> Please check back later or contact your instructor</li>
                <li><i class="fas fa-book"></i> You can select another available course</li>
            </ul>
            <div style="background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin-top: 15px;">
                <i class="fas fa-info-circle" style="color: #17a2b8;"></i>
                <small>Only exams marked as "Active" can be taken by students.</small>
            </div>
        </div>
        <div class="modal-footer">
            <button id="closeInactiveModal" class="btn-secondary">Close</button>
            <button id="selectOtherCourse" class="btn-outline">Select Another Course</button>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="delete-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color: #dc3545;"></i> Delete Exam Result</h3>
            <span class="close-modal" onclick="closeDeleteModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="deleteModalMessage">Are you sure you want to delete this exam result?</p>
        </div>
        <div class="modal-footer">
            <button onclick="closeDeleteModal()" class="btn-outline">Cancel</button>
            <button onclick="confirmDelete()" class="btn-danger">
                <i class="fas fa-trash"></i> Delete
            </button>
        </div>
    </div>
</div>

<script>
    // Confirmation Modal JavaScript
    document.addEventListener('DOMContentLoaded', function () {
        const form = document.getElementById('examStartForm');
        const courseSelect = document.getElementById('courseSelect');
        const confirmationModal = document.getElementById('confirmationModal');
        const modalCourseName = document.getElementById('modalCourseName');
        const modalDuration = document.getElementById('modalDuration');
        const beginButton = document.getElementById('beginButton');
        const cancelButton = document.getElementById('cancelButton');
        
        // Inactive Modal elements
        const inactiveModal = document.getElementById('inactiveModal');
        const closeInactiveModal = document.getElementById('closeInactiveModal');
        const selectOtherCourse = document.getElementById('selectOtherCourse');
        
        // Initialize question navigation
        const questionNavModal = document.getElementById('questionNavModal');
        if (questionNavModal) {
            // Close modal when clicking the close button
            const closeBtn = questionNavModal.querySelector('.close-modal-btn');
            if (closeBtn) {
                closeBtn.addEventListener('click', closeQuestionNavModal);
            }
        }

        // Initialize modal display to none
        if (confirmationModal) confirmationModal.style.display = 'none';
        if (inactiveModal) inactiveModal.style.display = 'none';

        if (beginButton) {
            beginButton.addEventListener('click', async function (e) {
                // Ensure proctoring starts before the exam begins.
                e.preventDefault();

                try {
                    // Reuse the verification camera stream if available; otherwise request permissions once.
                    if (window.verificationStream && window.verificationStream.getTracks && window.verificationStream.getTracks().length > 0) {
                        // ok
                    } else if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                        window.verificationStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                    }

                    if (typeof ProctoringSystem === 'function') {
                        try {
                            var proctor = new ProctoringSystem();
                            window.proctor = proctor;
                            if (typeof proctor.initialize === 'function') {
                                await proctor.initialize(window.verificationStream);
                            }
                        } catch (proctorErr) {
                            console.warn('Proctoring failed to initialize, continuing with exam start.', proctorErr);
                        }
                    }

                    // Clear any stale session storage keys before leaving this page.
                    // Important: do this BEFORE setting the proctor auto-start flag.
                    try {
                        sessionStorage.clear();
                    } catch (storageErr) {
                        console.warn('Could not clear sessionStorage.', storageErr);
                    }

                    // The exam start triggers a navigation; browsers will stop camera streams on unload.
                    // Set a flag so proctoring is automatically restarted on the exam page.
                    try {
                        sessionStorage.setItem('proctorAutoStart', '1');
                    } catch (storageErr) {
                        console.warn('Could not set proctor auto-start flag.', storageErr);
                    }

                    if (form) {
                        form.submit();
                    }
                } catch (err) {
                    if (typeof showSystemAlertModal === 'function') {
                        showSystemAlertModal('Camera and microphone access is required for this exam. Please allow permissions and try again.');
                    }
                    console.error('Permission error:', err);
                }
            });
        }

        if (cancelButton) {
            cancelButton.addEventListener('click', function () {
                if (confirmationModal) confirmationModal.style.display = 'none';
            });
        }
        
        // Inactive Modal handlers
        if (closeInactiveModal) {
            closeInactiveModal.addEventListener('click', function () {
                if (inactiveModal) inactiveModal.style.display = 'none';
            });
        }
        
        if (selectOtherCourse) {
            selectOtherCourse.addEventListener('click', function () {
                if (inactiveModal) inactiveModal.style.display = 'none';
                // Clear the course selection
                if (courseSelect) {
                    courseSelect.value = '';
                    const courseInfo = document.getElementById('courseInfo');
                    if (courseInfo) courseInfo.style.display = 'none';
                }
            });
        }

        // Close modals when clicking outside
        if (confirmationModal) {
            confirmationModal.addEventListener('click', function (e) {
                if (e.target === confirmationModal) {
                    confirmationModal.style.display = 'none';
                }
            });
        }
        
        if (inactiveModal) {
            inactiveModal.addEventListener('click', function (e) {
                if (e.target === inactiveModal) {
                    inactiveModal.style.display = 'none';
                }
            });
        }
    });

    // Global variables for delete modal
    let deleteExamId = null;
    let deleteStudentName = null;
    let deleteCourseName = null;

    function showDeleteModal(examId) {
        deleteExamId = examId;
        const modal = document.getElementById('deleteModal');
        if (!modal) {
            console.error('Delete modal not found!');
            if (typeof showSystemAlertModal === 'function') {
                showSystemAlertModal('Error: Delete modal not found.');
            }
            return;
        }
        modal.style.display = 'block';
        // Clean up text
        const cleanStudentName = studentName ? studentName.replace(/'/g, "\\'") : 'Unknown Student';
        const cleanCourseName = courseName ? courseName.replace(/'/g, "\\'") : 'Unknown Course';
        
        modalMessage.innerHTML = 'Are you sure you want to delete the exam result for:<br><br>' +
                                 '<strong>Student:</strong> ' + cleanStudentName + '<br>' +
                                 '<strong>Course:</strong> ' + cleanCourseName + '<br>' +
                                '// <strong>Exam ID:</strong> ' + examId + '<br><br>' +
                                 '<span style="color: #dc3545; font-weight: bold;">' +
                                 '<i class="fas fa-exclamation-triangle"></i> This action cannot be undone!</span>';
        
        modal.style.display = 'flex';
    }
    
    function closeDeleteModal() {
        const modal = document.getElementById('deleteModal');
        if (modal) {
            modal.style.display = 'none';
        }
        deleteExamId = null;
        deleteStudentName = null;
        deleteCourseName = null;
    }
    
    function confirmDelete() {
        if (!deleteExamId) {
            if (typeof showSystemAlertModal === 'function') {
                showSystemAlertModal('No exam selected for deletion.');
            }
            return;
        }
        
        console.log('Confirming delete for exam ID:', deleteExamId);
        
        // Show loading state
        const deleteBtn = document.querySelector('#deleteModal .modal-footer .btn-danger');
        if (deleteBtn) {
            const originalText = deleteBtn.innerHTML;
            deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
            deleteBtn.disabled = true;
            
            // Revert button after 5 seconds if something goes wrong
            setTimeout(() => {
                deleteBtn.innerHTML = originalText;
                deleteBtn.disabled = false;
            }, 5000);
        }

        // Submit delete request
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'controller.jsp';

        // Add CSRF token
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'csrf_token';
        csrfInput.value = '<%= session.getAttribute("csrf_token") != null ? session.getAttribute("csrf_token") : "" %>';
        form.appendChild(csrfInput);

        const pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        pageInput.value = 'results';
        form.appendChild(pageInput);

        const operationInput = document.createElement('input');
        operationInput.type = 'hidden';
        operationInput.name = 'operation';
        operationInput.value = 'delete';
        form.appendChild(operationInput);

        const examIdInput = document.createElement('input');
        examIdInput.type = 'hidden';
        examIdInput.name = 'eid';
        examIdInput.value = deleteExamId;
        form.appendChild(examIdInput);

        console.log('Submitting delete form for exam ID:', deleteExamId);
        document.body.appendChild(form);
        form.submit();
    }

    // Close delete modal when clicking outside
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('deleteModal');
        if (event.target === modal) {
            closeDeleteModal();
        }
        
        const inactiveModal = document.getElementById('inactiveModal');
        if (event.target === inactiveModal) {
            inactiveModal.style.display = 'none';
        }
    });

    // Add keyboard support for modals
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeDeleteModal();
            const inactiveModal = document.getElementById('inactiveModal');
            if (inactiveModal && inactiveModal.style.display === 'flex') {
                inactiveModal.style.display = 'none';
            }
        }
    });
    
    // Question Navigation Functions
    function handleUnansweredClick() {
        const unansweredCount = parseInt(document.getElementById('submitUnanswered').textContent);
        
        if (unansweredCount === 1) {
            // If only one unanswered question, go directly to it
            goToFirstUnansweredQuestion();
        } else if (unansweredCount > 1) {
            // If multiple unanswered questions, show navigation modal
            showQuestionNavigationModal();
        }
    }
    
    function goToFirstUnansweredQuestion() {
        const questionCards = document.querySelectorAll('.question-card');
        
        for (let i = 0; i < questionCards.length; i++) {
            const card = questionCards[i];
            const answersContainer = card.querySelector('.answers');
            const qindex = card.getAttribute('data-qindex');
            
            if (answersContainer && !isQuestionAnswered(answersContainer)) {
                scrollToQuestion(qindex);
                return;
            }
        }
    }
    
    function showQuestionNavigationModal() {
        const modal = document.getElementById('questionNavModal');
        const grid = document.getElementById('questionGrid');
        
        if (!modal || !grid) {
            console.error('Question navigation modal or grid not found');
            return;
        }
        
        // Clear existing content
        grid.innerHTML = '';
        
        // Get all question cards
        const questionCards = document.querySelectorAll('.question-card');
        
        // Get current question index
        const currentQNum = parseInt(document.getElementById('currentQNum')?.textContent || '1') - 1;
        
        // Create question icons
        questionCards.forEach((card, index) => {
            const qindex = card.getAttribute('data-qindex');
            const answersContainer = card.querySelector('.answers');
            const isAnswered = answersContainer && isQuestionAnswered(answersContainer);
            
            const icon = document.createElement('div');
            icon.className = 'question-icon ' + (isAnswered ? 'answered' : 'unanswered');
            if (parseInt(qindex) === currentQNum) {
                icon.classList.add('current');
            }
            icon.textContent = parseInt(qindex) + 1;
            icon.setAttribute('data-qindex', qindex);
            icon.title = 'Question ' + (parseInt(qindex) + 1) + ' (' + (isAnswered ? 'Answered' : 'Unanswered') + ')';
            
            // Use IIFE to capture the qindex value properly
            icon.addEventListener('click', (function(questionIndex) {
                return function() {
                    closeQuestionNavModal();
                    scrollToQuestion(questionIndex);
                };
            })(qindex));
            
            grid.appendChild(icon);
        });
        
        // Show modal
        modal.style.display = 'flex';
    }
    
    function closeQuestionNavModal() {
        const modal = document.getElementById('questionNavModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }
    
    function goToFirstQuestion() {
        const firstQuestionIndex = 0;
        scrollToQuestion(firstQuestionIndex.toString());
    }
    
    function goToLastQuestion() {
        const questionCards = document.querySelectorAll('.question-card');
        const lastQuestionIndex = questionCards.length - 1;
        scrollToQuestion(lastQuestionIndex.toString());
    }
    
    function scrollToQuestion(qindex) {
        // First, make sure the question is visible
        if (typeof showQuestion === 'function') {
            // Use the existing showQuestion function to display the selected question
            showQuestion(parseInt(qindex));
        } else {
            // Fallback: manually show the question
            const questionCards = document.querySelectorAll('.question-card');
            questionCards.forEach(function(card, idx) {
                if (idx == qindex) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
            
            // Update the question counter
            const currentQNumEl = document.getElementById('currentQNum');
            if (currentQNumEl) currentQNumEl.textContent = parseInt(qindex) + 1;
            
            // Update navigation buttons
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            
            if (prevBtn) prevBtn.disabled = (qindex === 0);
            
            const totalQuestions = document.querySelectorAll('.question-card').length;
            if (qindex === totalQuestions - 1) {
                if (nextBtn) {
                    nextBtn.innerHTML = 'Finish <i class="fas fa-flag-checkered"></i>';
                    nextBtn.style.background = '#059669';
                }
            } else {
                if (nextBtn) {
                    nextBtn.innerHTML = 'Next <i class="fas fa-arrow-right"></i>';
                    nextBtn.style.background = '#92AB2F';
                }
            }
        }
        
        // Small delay to ensure the question is visible before scrolling
        setTimeout(function() {
            const questionCard = document.querySelector('.question-card[data-qindex="' + qindex + '"]');
            if (questionCard) {
                questionCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
                
                // Add temporary highlight effect
                questionCard.style.boxShadow = '0 0 0 3px #3b82f6';
                questionCard.style.transition = 'box-shadow 0.3s';
                
                setTimeout(function() {
                    questionCard.style.boxShadow = '';
                }, 2000);
            }
        }, 100);
    }
    
    function isQuestionAnswered(answersContainer) {
        // Check for different question types
        const singleSelect = answersContainer.querySelector('input.single:checked');
        const multiSelect = answersContainer.querySelectorAll('input.multi:checked').length > 0;
        const textAnswer = answersContainer.querySelector('textarea');
        const hasText = textAnswer && textAnswer.value.trim() !== '';
        
        // For drag and drop questions
        const droppedItems = answersContainer.querySelectorAll('.dropped-item').length > 0;
        
        return singleSelect || multiSelect || hasText || droppedItems;
    }
    
    // Test function to verify horizontal orientation layout
    function testHorizontalOrientation() {
        console.log('Testing horizontal orientation layout:');
        
        // Find all drag-drop questions
        const dragDropContainers = document.querySelectorAll('.drag-drop-container');
        
        dragDropContainers.forEach(function(container, index) {
            if (container.classList.contains('horizontal-layout')) {
                console.log('Question ' + (index + 1) + ' has horizontal layout');
                
                const dropTargetsList = container.querySelector('.drop-targets-list');
                if (dropTargetsList) {
                    const style = getComputedStyle(dropTargetsList);
                    console.log('  justify-content: ' + style.justifyContent);
                    console.log('  flex-direction: ' + style.flexDirection);
                    
                    // Check if drop targets are aligned to the right
                    const isRightAligned = style.justifyContent === 'flex-end';
                    console.log('  Right aligned: ' + isRightAligned);
                    
                    // Check drop target sizes
                    const dropTargets = dropTargetsList.querySelectorAll('.drop-target');
                    dropTargets.forEach(function(target, targetIndex) {
                        const targetStyle = getComputedStyle(target);
                        console.log('  Target ' + (targetIndex + 1) + ': width=' + targetStyle.width + ', height=' + targetStyle.height);
                    });
                }
            }
        });
    }
    
    // Close question navigation modal when clicking outside
    window.addEventListener('click', function(event) {
        const questionNavModal = document.getElementById('questionNavModal');
        if (event.target === questionNavModal) {
            closeQuestionNavModal();
        }
    });

    /* --- DIAGNOSTICS LOGIC --- */
    function runDiagnostics() {
        console.log('Starting diagnostics...');
        const checks = [
            { id: 'status-internet', check: async () => ({ pass: navigator.onLine }) },
            { id: 'status-browser', check: async () => {
                const ua = navigator.userAgent;
                const isChrome = /Chrome/.test(ua) && /Google Inc/.test(navigator.vendor);
                let version = 0;
                if (isChrome) {
                    const match = ua.match(/Chrome\/(\d+)/);
                    version = match ? parseInt(match[1]) : 0;
                }
                return { pass: isChrome && version >= 100 }; // Chrome 100+ required
            }},
            { id: 'status-javascript', check: async () => ({ pass: true }) },
            { id: 'status-resolution', check: async () => ({ pass: window.screen.width >= 1536 && window.screen.height >= 864 }) },
            { id: 'status-os', check: async () => {
                const p = navigator.platform.toLowerCase();
                let isWin11 = false;
                if (navigator.userAgentData) {
                    const uaData = await navigator.userAgentData.getHighEntropyValues(["platformVersion"]);
                    // Windows 11 platform version starts from 13.0.0
                    isWin11 = uaData.platform === "Windows" && parseInt(uaData.platformVersion.split('.')[0]) >= 13;
                } else {
                    // Fallback to generic Windows check if userAgentData is not supported
                    isWin11 = p.includes("win");
                }
                return { pass: isWin11 };
            }},
            { id: 'status-camera', check: async () => {
                try {
                    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) return { pass: false };
                    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
                    stream.getTracks().forEach(t => t.stop());
                    return { pass: true };
                } catch (e) { return { pass: false }; }
            }},
            { id: 'status-environment', check: async () => {
                // Check if full screen is available for lockdown
                const fullScreenAvailable = document.fullscreenEnabled || 
                                           document.webkitFullscreenEnabled || 
                                           document.mozFullScreenEnabled || 
                                           document.msFullscreenEnabled;
                return { pass: !!fullScreenAvailable };
            }}
        ];

        // Screen resolution should not block proceeding (accessibility/device constraints).
        const nonBlockingCheckIds = { 'status-resolution': true };

        let passedCount = 0;
        let completedCount = 0;
        
        // Reset UI
        checks.forEach(c => {
            const el = document.getElementById(c.id);
            if (el) el.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
        });
        document.getElementById('diagProceedButton').disabled = true;
        document.getElementById('diagRetryButton').style.display = 'none';

        checks.forEach((c, i) => {
            setTimeout(async () => {
                const result = await c.check();
                const el = document.getElementById(c.id);
                if (el) {
                    if (result.pass) {
                        el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
                        if (!nonBlockingCheckIds[c.id]) {
                            passedCount++;
                        }
                    } else {
                        el.innerHTML = '<i class="fas fa-times-circle status-fail"></i>';
                        // Non-blocking checks do not affect gating.
                        if (nonBlockingCheckIds[c.id]) {
                            // treat as neutral for pass/fail gating
                        }
                    }
                }
                completedCount++;
                if (completedCount === checks.length) {
                    const requiredCount = checks.length - Object.keys(nonBlockingCheckIds).length;
                    finishDiagnostics(passedCount === requiredCount);
                }
            }, i * 300);
        });
    }

    function finishDiagnostics(allPassed) {
        const proceedBtn = document.getElementById('diagProceedButton');
        const retryBtn = document.getElementById('diagRetryButton');
        
        if (allPassed) {
            proceedBtn.disabled = false;
            proceedBtn.classList.add('pulse-animation');
        } else {
            retryBtn.style.display = 'inline-block';
        }
    }

    // Modal button listeners
    document.getElementById('diagCancelButton').onclick = () => {
        document.getElementById('diagnosticsModal').style.display = 'none';
    };

    document.getElementById('diagRetryButton').onclick = () => {
        runDiagnostics();
    };

    document.getElementById('diagProceedButton').onclick = () => {
        document.getElementById('diagnosticsModal').style.display = 'none';
        startIdentityVerification();
    };

    /* --- IDENTITY VERIFICATION LOGIC --- */
    let currentVerifyStep = 1;
    let capturedFaceData = null;
    let capturedIdData = null;
    let verificationStream = null;

    // User details from server-side (embedded as JavaScript variables)
    const userName = '<%= session.getAttribute("uname") != null ? session.getAttribute("uname") : "" %>';
    const userFullName = '<%= session.getAttribute("userFullName") != null ? session.getAttribute("userFullName") : "" %>';
    const userId = '<%= session.getAttribute("userId") != null ? session.getAttribute("userId").toString() : "" %>';

    // Name verification functionality
    function startIdentityVerification() {
        document.getElementById('identityVerificationModal').style.display = 'flex';
        showVerifyStep(1);
        
        // Setup name verification listeners
        const verifyBtn = document.getElementById('verifyNameBtn');
        const nameInput = document.getElementById('studentNameInput');
        
        if (verifyBtn && nameInput) {
            verifyBtn.onclick = async () => {
                const name = nameInput.value.trim();
                const messageDiv = document.getElementById('nameVerificationMessage');
                const honorSection = document.getElementById('honorCodeSection');
                
                if (!name) {
                    messageDiv.style.display = 'block';
                    messageDiv.style.color = '#ef4444';
                    messageDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> Please enter your name';
                    return;
                }
                
                verifyBtn.disabled = true;
                verifyBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
                
                try {
                    // DEBUG: Log what we're sending
                    console.log('DEBUG: Sending verification request');
                    console.log('DEBUG: enteredName:', name);
                    console.log('DEBUG: userId:', userId);
                    
                    const response = await fetch('controller.jsp?page=verify_student_name&enteredName=' + encodeURIComponent(name) + '&userId=' + encodeURIComponent(userId));
                    const data = await response.json();
                    
                    // DEBUG: Log the response
                    console.log('DEBUG: Verification response:', data);
                    console.log('DEBUG: Response status:', response.status);
                    
                    if (data.success) {
                        messageDiv.style.display = 'block';
                        messageDiv.style.color = '#10b981';
                        messageDiv.innerHTML = '<i class="fas fa-check-circle"></i> Name verified successfully! Welcome, <strong>' + data.fullName + '</strong>';
                        
                        // Show honor code section
                        honorSection.style.display = 'block';
                        
                        // Update digital signature placeholder
                        const signatureInput = document.getElementById('digitalSignature');
                        if (signatureInput) {
                            signatureInput.placeholder = 'Type: ' + data.fullName;
                            signatureInput.dataset.expected = data.fullName;
                        }
                        
                        // Store verified name
                        window.verifiedFullName = data.fullName;
                        
                        // Disable name input and button
                        nameInput.disabled = true;
                        verifyBtn.style.display = 'none';
                    } else {
                        messageDiv.style.display = 'block';
                        messageDiv.style.color = '#ef4444';
                        messageDiv.innerHTML = '<i class="fas fa-times-circle"></i> Name verification failed. Please try again.';
                        verifyBtn.disabled = false;
                        verifyBtn.innerHTML = 'Verify';
                    }
                } catch (err) {
                    console.error('Verification error:', err);
                    verifyBtn.disabled = false;
                    verifyBtn.innerHTML = 'Verify';
                }
            };
            
            // Allow Enter key to trigger verification
            nameInput.onkeypress = (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    verifyBtn.click();
                }
            };
        }
        
        // Setup honor code checkbox listener
        const honorCheckbox = document.getElementById('honorCodeCheckbox');
        if (honorCheckbox) {
            honorCheckbox.onchange = (e) => {
                const sigSection = document.getElementById('signatureSection');
                if (e.target.checked) {
                    sigSection.style.display = 'block';
                } else {
                    sigSection.style.display = 'none';
                }
            };
        }
    }

    async function showVerifyStep(step) {
        // Keep the same stream running across steps (face -> ID -> summary)

        // Hide all steps
            document.querySelectorAll('.verification-step').forEach(function(el) { el.style.display = 'none'; });
        // Show current step
        document.getElementById('verification-step-' + step).style.display = 'block';

        // Update nav UI
        for (let i = 1; i <= 4; i++) {
            const nav = document.getElementById('step-nav-' + i);
            const circle = nav.querySelector('div');
            if (i < step) {
                circle.style.background = 'var(--success)';
                circle.innerHTML = '<i class="fas fa-check"></i>';
                nav.style.color = 'var(--success)';
            } else if (i === step) {
                circle.style.background = 'var(--primary-blue)';
                circle.textContent = i;
                nav.style.color = 'var(--primary-blue)';
                nav.style.fontWeight = 'bold';
            } else {
                circle.style.background = '#cbd5e1';
                circle.textContent = i;
                nav.style.color = '#cbd5e1';
                nav.style.fontWeight = 'normal';
            }
        }

        // Handle buttons
        document.getElementById('verifyPrevBtn').style.display = (step > 1 && step < 4) ? 'inline-block' : 'none';
        document.getElementById('verifyNextBtn').style.display = (step < 4) ? 'inline-block' : 'none';
        document.getElementById('verifyFinalBtn').style.display = (step === 4) ? 'inline-block' : 'none';

        // Initialize camera if needed
        if (step === 2) {
            try {
                if (!verificationStream) {
                    verificationStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                    window.verificationStream = verificationStream;
                }
                document.getElementById('faceVideo').srcObject = verificationStream;
                document.getElementById('faceVideo').play();
            } catch (err) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Could not access camera for face verification.');
                }
            }
        } else if (step === 3) {
            try {
                if (!verificationStream) {
                    verificationStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                    window.verificationStream = verificationStream;
                }
                document.getElementById('idVideo').srcObject = verificationStream;
                document.getElementById('idVideo').play();
            } catch (err) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Could not access camera for ID verification.');
                }
            }
        } else if (step === 4) {
            document.getElementById('summaryFaceImg').src = capturedFaceData;
            document.getElementById('summaryIdImg').src = capturedIdData;
        }

        currentVerifyStep = step;
    }

    document.getElementById('verifyNextBtn').onclick = async () => {
        if (currentVerifyStep === 1) {
            if (!window.verifiedFullName) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Please verify your name first.');
                }
                return;
            }
            const agreed = document.getElementById('honorCodeCheckbox').checked;
            const sigInput = document.getElementById('digitalSignature');
            const sig = sigInput ? sigInput.value.trim() : "";
            const expectedSig = sigInput ? sigInput.dataset.expected : "";
            
            if (!agreed) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Please agree to the Code of Honor to proceed.');
                }
                return;
            }
            
            if (!sig || sig !== expectedSig) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Digital signature does not match. Please type your full name exactly as: ' + expectedSig);
                }
                return;
            }
            showVerifyStep(2);
        } else if (currentVerifyStep === 2) {
            if (!capturedFaceData) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Please capture your face photo first.');
                }
                return;
            }
            showVerifyStep(3);
        } else if (currentVerifyStep === 3) {
            if (!capturedIdData) {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('Please capture your ID photo first.');
                }
                return;
            }
            // Save everything to backend
            await saveVerificationToBackend();
            showVerifyStep(4);
        }
    };

    document.getElementById('verifyPrevBtn').onclick = () => {
        showVerifyStep(currentVerifyStep - 1);
    };

    // Add missing showQualityError function
    function showQualityError(message) {
        // Create or get error display element
        let errorDiv = document.getElementById('faceQualityError');
        if (!errorDiv) {
            errorDiv = document.createElement('div');
            errorDiv.id = 'faceQualityError';
            
            // Find where to insert it (after camera container)
            const cameraSection = document.querySelector('.camera-section');
            if (cameraSection) {
                cameraSection.appendChild(errorDiv);
            }
        }
        
        errorDiv.innerHTML = `
            <div style="margin-top: 15px; padding: 15px; background: #fee2e2; border: 1px solid #ef4444; border-radius: 8px; color: #b91c1c; animation: slideIn 0.3s ease;">
                <div style="display: flex; gap: 10px; align-items: flex-start;">
                    <i class="fas fa-exclamation-triangle" style="font-size: 20px; color: #ef4444;"></i>
                    <div>
                        <strong style="display: block; margin-bottom: 5px; font-size: 14px;">Quality Check Failed</strong>
                        <span style="font-size: 13px;">${message}</span>
                        <div style="margin-top: 10px; font-size: 12px; color: #7f1d1d; background: #fff5f5; padding: 10px; border-radius: 6px;">
                            <strong>Quick fixes:</strong>
                            <ul style="margin-top: 5px; padding-left: 20px;">
                                <li>Center your face in oval guide</li>
                                <li>Remove any hats, sunglasses, or masks</li>
                                <li>Ensure good lighting on your face</li>
                                <li>Position yourself 30-50cm from camera</li>
                            </ul>
                        </div>
                    </div>
                </div>
                <button onclick="this.parentElement.parentElement.remove(); resetCaptureButton()" style="position: absolute; top: 5px; right: 5px; background: none; border: none; color: #ef4444; cursor: pointer; font-size: 16px;">&times;</button>
            </div>
        `;
        
        // Auto-remove after 8 seconds
        setTimeout(() => {
            if (errorDiv.parentNode) {
                errorDiv.remove();
            }
        }, 8000);
    }
    
    // Function to reset capture button state
    function resetCaptureButton() {
        const button = document.getElementById('captureFaceBtn');
        if (button) {
            button.innerHTML = '<i class="fas fa-camera"></i> Capture Photo';
            button.disabled = false;
        }
    }

    // SIMPLIFIED - Just basic lighting checks, no complex face detection

    
    // AI-Powered Face Analysis
    document.getElementById('captureFaceBtn').onclick = async () => {
        const video = document.getElementById('faceVideo');
        
        // Show checking status
        const originalText = document.getElementById('captureFaceBtn').innerHTML;
        document.getElementById('captureFaceBtn').innerHTML = '<i class="fas fa-spinner fa-spin"></i> AI Analyzing...';
        document.getElementById('captureFaceBtn').disabled = true;
        
        try {
            // Capture the photo
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);
            capturedFaceData = canvas.toDataURL('image/jpeg');
            
            // Send to server for AI analysis
            const formData = new URLSearchParams();
            formData.append('page', 'analyze_face');
            formData.append('faceImage', capturedFaceData);
            
            const response = await fetch('controller.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });
            
            const result = await response.json();
            
            if (!result.success) {
                showQualityError(result.reason);
                document.getElementById('captureFaceBtn').innerHTML = originalText;
                document.getElementById('captureFaceBtn').disabled = false;
                return;
            }
            
            // AI says it's good - proceed
            document.getElementById('faceImgPreview').src = capturedFaceData;
            document.getElementById('faceCapturedPreview').style.display = 'block';
            document.getElementById('liveInstructions').style.display = 'none';
            document.getElementById('retakeSection').style.display = 'block';
            
            // Update quality indicators to show all passed
            const checks = document.querySelectorAll('.check-item');
            if (checks.length >= 4) {
                checks[0].innerHTML = '<i class="fas fa-check-circle" style="color:#10b981"></i><span>Face properly positioned</span>';
                checks[1].innerHTML = '<i class="fas fa-check-circle" style="color:#10b981"></i><span>No face coverings detected</span>';
                checks[2].innerHTML = '<i class="fas fa-check-circle" style="color:#10b981"></i><span>Lighting adequate</span>';
                checks[3].innerHTML = '<i class="fas fa-check-circle" style="color:#10b981"></i><span>Single person in frame</span>';
            }
            
            // Hide any error messages
            const errorDiv = document.getElementById('faceQualityError');
            if (errorDiv) errorDiv.remove();
            
        } catch (err) {
            console.error('Error:', err);
            showQualityError('Could not analyze photo. Please try again.');
            document.getElementById('captureFaceBtn').innerHTML = originalText;
            document.getElementById('captureFaceBtn').disabled = false;
        }
    };

    // Retake button handler
    document.getElementById('retakeFaceBtn').onclick = () => {
        document.getElementById('faceCapturedPreview').style.display = 'none';
        document.getElementById('liveInstructions').style.display = 'block';
        document.getElementById('retakeSection').style.display = 'none';
        document.getElementById('captureFaceBtn').disabled = false;
    };

    // Lighting analysis for Face Photo verification
    function analyzeLighting(videoElement) {
        const canvas = document.createElement('canvas');
        canvas.width = 100;
        canvas.height = 100;
        const ctx = canvas.getContext('2d');
        
        // Draw a frame from video
        ctx.drawImage(videoElement, 0, 0, 100, 100);
        
        // Get pixel data
        const imageData = ctx.getImageData(0, 0, 100, 100);
        const data = imageData.data;
        
        // Calculate average brightness
        let totalBrightness = 0;
        for (let i = 0; i < data.length; i += 4) {
            const brightness = (data[i] + data[i + 1] + data[i + 2]) / 3;
            totalBrightness += brightness;
        }
        const avgBrightness = totalBrightness / (data.length / 4);
        
        // Check for backlight (sample top vs center)
        let topBrightness = 0;
        for (let x = 0; x < 100; x += 10) {
            const idx = (10 * 100 + x) * 4;
            topBrightness += (data[idx] + data[idx+1] + data[idx+2]) / 3;
        }
        topBrightness = topBrightness / 10;
        
        let centerBrightness = 0;
        for (let y = 40; y < 60; y++) {
            for (let x = 40; x < 60; x++) {
                const idx = (y * 100 + x) * 4;
                centerBrightness += (data[idx] + data[idx+1] + data[idx+2]) / 3;
            }
        }
        centerBrightness = centerBrightness / 400;
        
        const backlightRatio = topBrightness / centerBrightness;
        
        // Update lighting indicator
        const indicator = document.getElementById('lightingIndicator');
        const score = document.getElementById('lightingScore');
        const progress = document.getElementById('lightingProgress');
        
        if (indicator && score && progress) {
            indicator.style.display = 'block';
            
            if (backlightRatio > 2.0) {
                score.textContent = 'Poor (Backlit!)';
                progress.className = 'progress-fill poor';
                progress.style.width = '30%';
                score.style.color = '#ef4444';
            } else if (avgBrightness < 60) {
                score.textContent = 'Too Dark';
                progress.className = 'progress-fill poor';
                progress.style.width = '20%';
                score.style.color = '#ef4444';
            } else if (avgBrightness > 220) {
                score.textContent = 'Too Bright';
                progress.className = 'progress-fill warning';
                progress.style.width = '95%';
                score.style.color = '#f59e0b';
            } else if (avgBrightness > 100) {
                score.textContent = 'Good';
                progress.className = 'progress-fill good';
                progress.style.width = '80%';
                score.style.color = '#10b981';
            } else {
                score.textContent = 'Fair';
                progress.className = 'progress-fill warning';
                progress.style.width = '50%';
                score.style.color = '#f59e0b';
            }
        }
    }

    // Start lighting analysis when camera is active
    document.getElementById('faceVideo').addEventListener('play', function() {
        // Show lighting indicator
        document.getElementById('lightingIndicator').style.display = 'block';
        
        // Analyze lighting every 500ms for real-time feedback
        setInterval(() => analyzeLighting(this), 500);
    });

    // Simple ID verification - just checks if holding ID/card/paper
    document.getElementById('captureIdBtn').onclick = async () => {
        const video = document.getElementById('idVideo');
        
        // Show checking status
        const originalText = document.getElementById('captureIdBtn').innerHTML;
        document.getElementById('captureIdBtn').innerHTML = '<i class="fas fa-spinner fa-spin"></i> Checking ID...';
        document.getElementById('captureIdBtn').disabled = true;
        
        try {
            // Capture the photo
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);
            capturedIdData = canvas.toDataURL('image/jpeg');
            
            // Send to server for simple verification
            const formData = new URLSearchParams();
            formData.append('page', 'verify_id');
            formData.append('idImage', capturedIdData);
            
            const response = await fetch('controller.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });
            
            const result = await response.json();
            
            if (!result.success) {
                showSimpleIdError(result.reason);
                document.getElementById('captureIdBtn').innerHTML = originalText;
                document.getElementById('captureIdBtn').disabled = false;
                return;
            }
            
            // ID detected - proceed
            document.getElementById('idImgPreview').src = capturedIdData;
            document.getElementById('idCapturedPreview').style.display = 'block';
            
            // Hide any error messages
            const errorDiv = document.getElementById('simpleIdError');
            if (errorDiv) errorDiv.remove();
            
        } catch (err) {
            console.error('Error:', err);
            showSimpleIdError('Could not verify ID. Please try again.');
            document.getElementById('captureIdBtn').innerHTML = originalText;
            document.getElementById('captureIdBtn').disabled = false;
        }
    };

// Simple error display
function showSimpleIdError(message) {
    let errorDiv = document.getElementById('simpleIdError');
    if (!errorDiv) {
        errorDiv = document.createElement('div');
        errorDiv.id = 'simpleIdError';
        
        // Insert after capture button
        const idSection = document.querySelector('#verification-step-3 .info-section') || 
                         document.querySelector('#verification-step-3 > div:last-child');
        if (idSection) {
            idSection.appendChild(errorDiv);
        }
    }
    
    errorDiv.innerHTML = `
        <div style="margin-top: 15px; padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; color: #856404; animation: slideIn 0.3s ease;">
            <div style="display: flex; gap: 10px; align-items: center;">
                <i class="fas fa-id-card" style="font-size: 20px; color: #856404;"></i>
                <div>
                    <strong style="display: block; margin-bottom: 3px;">ID Not Detected</strong>
                    <span style="font-size: 13px;">${message}</span>
                </div>
            </div>
            <div style="margin-top: 10px; font-size: 12px; padding: 8px; background: #fff9e6; border-radius: 4px;">
                <strong>Tips:</strong>
                <ul style="margin-top: 5px; padding-left: 20px;">
                    <li>Hold your ID card toward the camera</li>
                    <li>Make sure it's clearly visible</li>
                    <li>Avoid glare on the surface</li>
                    <li>Keep it flat and steady</li>
                </ul>
            </div>
            <button onclick="this.parentElement.remove()" style="position: absolute; top: 5px; right: 5px; background: none; border: none; color: #856404; cursor: pointer;">&times;</button>
        </div>
    `;
    
    // Auto-remove after 8 seconds
    setTimeout(() => {
        if (errorDiv.parentNode) {
            errorDiv.remove();
        }
    }, 8000);
}

    async function saveVerificationToBackend() {
        const formData = new URLSearchParams();
        formData.append('page', 'proctoring');
        formData.append('operation', 'save_verification');
        // Note: userId and examId will be injected via JSP or session
        formData.append('studentId', '<%= session.getAttribute("userId") != null ? session.getAttribute("userId").toString() : "0" %>');
        formData.append('examId', '<%= session.getAttribute("examId") != null ? session.getAttribute("examId") : "0" %>');
        formData.append('honorAccepted', 'true');
        formData.append('facePhoto', capturedFaceData);
        formData.append('idPhoto', capturedIdData);

        try {
            const response = await fetch('controller.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });
            console.log('Verification saved:', await response.json());
        } catch (err) {
            console.error('Error saving verification:', err);
        }
    }

    document.getElementById('verifyFinalBtn').onclick = () => {
        document.getElementById('identityVerificationModal').style.display = 'none';
        document.getElementById('confirmationModal').style.display = 'flex';
    };

    </script>
    <style>
    /* Step Header Styles */
    .step-header {
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 2px solid #eef2f6;
    }

    .step-badge {
        display: inline-block;
        padding: 4px 12px;
        background: #e6f0ff;
        color: #0047ab;
        font-size: 12px;
        font-weight: 600;
        border-radius: 20px;
        margin-bottom: 8px;
        letter-spacing: 0.5px;
    }

    .step-title {
        font-size: 20px;
        font-weight: 600;
        color: #1a2b3c;
        margin-bottom: 6px;
    }

    .step-description {
        font-size: 14px;
        color: #5a6b7c;
        margin: 0;
    }

    /* Verification Grid Layout */
    .verification-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 24px;
    }

    /* Camera Section */
    .camera-section {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .camera-container {
        background: #0a0f14;
        border-radius: 12px;
        overflow: hidden;
        position: relative;
        aspect-ratio: 4/3;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        border: 1px solid #e2e8f0;
    }

    .camera-feed {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .camera-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
    }

    .face-guide {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 200px;
        height: 260px;
        border: 3px dashed rgba(255, 255, 255, 0.7);
        border-radius: 50% 50% 40% 40%;
        box-shadow: 0 0 0 2px rgba(0, 71, 171, 0.3);
        animation: pulse 2s infinite;
    }

    @keyframes pulse {
        0% { border-color: rgba(255, 255, 255, 0.7); }
        50% { border-color: rgba(0, 71, 171, 0.9); }
        100% { border-color: rgba(255, 255, 255, 0.7); }
    }

    .camera-status {
        position: absolute;
        bottom: 12px;
        left: 12px;
        background: rgba(0, 0, 0, 0.6);
        color: #10b981;
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        display: flex;
        align-items: center;
        gap: 6px;
        backdrop-filter: blur(4px);
    }

    .camera-status i {
        font-size: 12px;
    }

    /* Capture Button */
    .btn-capture {
        background: linear-gradient(135deg, #0047ab, #2563eb);
        color: white;
        border: none;
        border-radius: 8px;
        padding: 14px 20px;
        font-size: 16px;
        font-weight: 500;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 4px 12px rgba(0, 71, 171, 0.3);
    }

    .btn-capture:hover:not(:disabled) {
        background: linear-gradient(135deg, #003a8c, #1e4fd9);
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0, 71, 171, 0.4);
    }

    .btn-capture:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    .btn-capture i {
        font-size: 18px;
    }

    /* Retake Button */
    .retake-section {
        text-align: center;
    }

    .btn-text {
        background: none;
        border: 1px solid #cbd5e1;
        color: #475569;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .btn-text:hover {
        background: #f1f5f9;
        border-color: #94a3b8;
        color: #1e293b;
    }

    /* Info Section */
    .info-section {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .instruction-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
    }

    .instruction-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 16px;
    }

    .instruction-header i {
        font-size: 20px;
        color: #0047ab;
    }

    .instruction-header h5 {
        font-size: 16px;
        font-weight: 600;
        color: #1a2b3c;
        margin: 0;
    }

    .guideline-list {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .guideline-item {
        display: flex;
        gap: 12px;
        align-items: flex-start;
    }

    .guideline-icon {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .guideline-icon i {
        font-size: 14px;
        color: white;
    }

    .success-bg {
        background: #10b981;
    }

    .warning-bg {
        background: #f59e0b;
    }

    .guideline-text {
        flex: 1;
    }

    .guideline-text strong {
        display: block;
        font-size: 14px;
        color: #1e293b;
        margin-bottom: 4px;
    }

    .guideline-text span {
        font-size: 13px;
        color: #64748b;
        line-height: 1.5;
    }

    /* Quality Indicator */
    .quality-indicator {
        margin-top: 20px;
        padding: 16px;
        background: #f8fafc;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
    }

    .indicator-label {
        display: flex;
        justify-content: space-between;
        font-size: 13px;
        color: #475569;
        margin-bottom: 8px;
    }

    #lightingScore {
        font-weight: 600;
        color: #10b981;
    }

    .progress-bar {
        height: 6px;
        background: #e2e8f0;
        border-radius: 3px;
        overflow: hidden;
    }

    .progress-fill {
        height: 100%;
        border-radius: 3px;
        transition: width 0.3s ease;
    }

    .progress-fill.good {
        background: #10b981;
    }

    .progress-fill.warning {
        background: #f59e0b;
    }

    .progress-fill.poor {
        background: #ef4444;
    }

    /* Preview Card */
    .preview-card {
        background: #f0f9ff;
        border: 1px solid #bae6fd;
        border-radius: 12px;
        padding: 20px;
        animation: slideIn 0.3s ease;
    }

    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .preview-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 16px;
    }

    .success-icon {
        font-size: 24px;
        color: #10b981;
    }

    .preview-header h5 {
        font-size: 16px;
        font-weight: 600;
        color: #0a4b2e;
        margin: 0;
    }

    .preview-image-container {
        position: relative;
        margin-bottom: 20px;
        border-radius: 8px;
        overflow: hidden;
        border: 2px solid #10b981;
    }

    .preview-image {
        width: 100%;
        display: block;
    }

    .preview-badge {
        position: absolute;
        top: 12px;
        right: 12px;
        background: rgba(16, 185, 129, 0.9);
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        backdrop-filter: blur(4px);
    }

    .quality-checks {
        background: #ffffff;
        border-radius: 8px;
        padding: 16px;
        margin-bottom: 16px;
    }

    .check-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 8px 0;
        border-bottom: 1px solid #e2e8f0;
    }

    .check-item:last-child {
        border-bottom: none;
    }

    .check-item i {
        font-size: 16px;
    }

    .check-item.passed i {
        color: #10b981;
    }

    .check-item span {
        font-size: 13px;
        color: #334155;
    }

    .preview-note {
        font-size: 12px;
        color: #0284c7;
        background: #e6f0ff;
        padding: 12px;
        border-radius: 6px;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        .verification-grid {
            grid-template-columns: 1fr;
        }
        
        .camera-container {
            max-width: 500px;
            margin: 0 auto;
        }
    }
    </style>
<script src="proctoring_v2.js"></script>
<script>
// ==================== DRAG AND DROP FUNCTIONALITY ====================

class DragDropManager {
    constructor() {
        this.draggedElement = null;
        this.draggedData = null;
        this.originalParent = null;
        this.init();
    }

    init() {
        document.addEventListener('DOMContentLoaded', () => {
            this.initializeDragDrop();
            this.initializeRearrange();
        });
    }

    initializeDragDrop() {
        const dragContainers = document.querySelectorAll('.drag-drop-container');
        
        dragContainers.forEach((container, questionIndex) => {
            const itemsJson = container.dataset.itemsJson;
            const targetsJson = container.dataset.targetsJson;
            
            if (itemsJson && targetsJson) {
                try {
                    const items = JSON.parse(itemsJson);
                    const targets = JSON.parse(targetsJson);
                    
                    this.populateDragItems(questionIndex, items);
                    this.populateDropTargets(questionIndex, targets);
                    this.setupDragEvents(questionIndex);
                } catch (e) {
                    console.error('Error parsing drag/drop data:', e);
                }
            }
        });
    }

    populateDragItems(questionIndex, items) {
        const itemsContainer = document.getElementById(`dragItems_${questionIndex}`);
        if (!itemsContainer || !items) return;

        itemsContainer.innerHTML = '';
        
        items.forEach((item, index) => {
            const dragElement = document.createElement('div');
            dragElement.className = 'drag-item';
            dragElement.draggable = true;
            dragElement.dataset.itemId = item.id;
            dragElement.dataset.itemText = item.text;
            dragElement.innerHTML = `
                <i class="fas fa-grip-vertical"></i>
                <span>${item.text}</span>
            `;
            itemsContainer.appendChild(dragElement);
        });
    }

    populateDropTargets(questionIndex, targets) {
        const targetsContainer = document.getElementById(`dropTargets_${questionIndex}`);
        if (!targetsContainer || !targets) return;

        targetsContainer.innerHTML = '';
        
        targets.forEach((target, index) => {
            const targetElement = document.createElement('div');
            targetElement.className = 'drop-target';
            targetElement.dataset.targetId = target.id;
            targetElement.dataset.correctItem = target.correctItemId;
            targetElement.innerHTML = `
                <div class="target-label">${target.text}</div>
                <div class="drop-zone"></div>
            `;
            targetsContainer.appendChild(targetElement);
        });
    }

    setupDragEvents(questionIndex) {
        const container = document.querySelector(`#dragDrop_${questionIndex} .drag-drop-container`);
        if (!container) return;

        // Drag events
        container.addEventListener('dragstart', (e) => {
            if (e.target.classList.contains('drag-item')) {
                this.draggedElement = e.target;
                this.draggedData = {
                    itemId: e.target.dataset.itemId,
                    itemText: e.target.dataset.itemText
                };
                this.originalParent = e.target.parentElement;
                e.target.classList.add('dragging');
                e.dataTransfer.effectAllowed = 'move';
            }
        });

        container.addEventListener('dragend', (e) => {
            if (e.target.classList.contains('drag-item')) {
                e.target.classList.remove('dragging');
                this.draggedElement = null;
                this.draggedData = null;
                this.originalParent = null;
            }
        });

        // Drop events
        container.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'move';
            
            const dropZone = e.target.closest('.drop-zone');
            if (dropZone) {
                dropZone.classList.add('drag-over');
            }
        });

        container.addEventListener('dragleave', (e) => {
            const dropZone = e.target.closest('.drop-zone');
            if (dropZone) {
                dropZone.classList.remove('drag-over');
            }
        });

        container.addEventListener('drop', (e) => {
            e.preventDefault();
            
            const dropZone = e.target.closest('.drop-zone');
            if (dropZone && this.draggedElement) {
                dropZone.classList.remove('drag-over');
                
                // Remove any existing item in this drop zone
                const existingItem = dropZone.querySelector('.dropped-item');
                if (existingItem) {
                    existingItem.remove();
                }
                
                // Clone and place the dragged item
                const droppedItem = this.draggedElement.cloneNode(true);
                droppedItem.classList.remove('dragging');
                droppedItem.classList.add('dropped-item');
                droppedItem.draggable = false;
                dropZone.appendChild(droppedItem);
                
                // Update JSON input for form submission
                this.updateDragDropJson(questionIndex);
            }
        });
    }

    updateDropInput(questionIndex, dropZone) {
        // Instead of creating individual inputs, we'll collect all drop data
        // and create a single JSON input when the form is submitted
        this.updateDragDropJson(questionIndex);
    }

    updateDragDropJson(questionIndex) {
        const container = document.querySelector(`#dragDrop_${questionIndex} .drag-drop-container`);
        if (!container) return;

        const dropTargets = container.querySelectorAll('.drop-target');
        const matches = {};

        dropTargets.forEach(target => {
            const targetId = target.dataset.targetId;
            const droppedItem = target.querySelector('.dropped-item');
            const itemId = droppedItem ? droppedItem.dataset.itemId : '';
            
            if (itemId) {
                matches[`target_${targetId}`] = `item_${itemId}`;
            }
        });

        // Find or create the JSON input
        let input = document.getElementById(`dragDropJson_${questionIndex}`);
        if (!input) {
            input = document.createElement('input');
            input.type = 'hidden';
            input.id = `dragDropJson_${questionIndex}`;
            input.name = `question${questionIndex}`; // This will be picked up as the answer
            container.appendChild(input);
        }
        
        input.value = JSON.stringify(matches);
        console.log('🔍 Drag drop JSON for question', questionIndex, ':', input.value);
        console.log('🔍 Expected format: {"target_X":"item_Y"}');
        
        // Debug: Show what correct mappings should be
        const correctMappings = {};
        dropTargets.forEach(target => {
            const targetId = target.dataset.targetId;
            const correctItemId = target.dataset.correctItem;
            if (correctItemId) {
                correctMappings[`target_${targetId}`] = `item_${correctItemId}`;
            }
        });
        console.log('🔍 Correct mappings should be:', correctMappings);
    }

    initializeRearrange() {
        const rearrangeContainers = document.querySelectorAll('.rearrange-interface');
        
        rearrangeContainers.forEach((container, questionIndex) => {
            const itemsJson = container.dataset.itemsJson;
            
            if (itemsJson) {
                try {
                    const items = JSON.parse(itemsJson);
                    this.populateRearrangeItems(questionIndex, items);
                    this.setupRearrangeEvents(questionIndex);
                } catch (e) {
                    console.error('Error parsing rearrange data:', e);
                }
            }
        });
    }

    populateRearrangeItems(questionIndex, items) {
        const container = document.getElementById(`rearrange_${questionIndex}`);
        if (!container || !items) return;

        container.innerHTML = '';
        
        items.forEach((item, index) => {
            const itemElement = document.createElement('div');
            itemElement.className = 'rearrange-item';
            itemElement.draggable = true;
            itemElement.dataset.itemId = item.id;
            itemElement.dataset.originalIndex = index;
            itemElement.innerHTML = `
                <i class="fas fa-grip-vertical"></i>
                <span>${item.text}</span>
            `;
            container.appendChild(itemElement);
        });
    }

    setupRearrangeEvents(questionIndex) {
        const container = document.getElementById(`rearrange_${questionIndex}`);
        if (!container) return;

        let draggedItem = null;

        container.addEventListener('dragstart', (e) => {
            if (e.target.classList.contains('rearrange-item')) {
                draggedItem = e.target;
                e.target.classList.add('dragging');
                e.dataTransfer.effectAllowed = 'move';
            }
        });

        container.addEventListener('dragend', (e) => {
            if (e.target.classList.contains('rearrange-item')) {
                e.target.classList.remove('dragging');
            }
        });

        container.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'move';
            
            const afterElement = this.getDragAfterElement(container, e.clientY);
            if (afterElement == null) {
                container.appendChild(draggedItem);
            } else {
                container.insertBefore(draggedItem, afterElement);
            }
        });

        container.addEventListener('drop', (e) => {
            e.preventDefault();
            this.updateRearrangeInput(questionIndex);
        });
    }

    getDragAfterElement(container, y) {
        const draggableElements = [...container.querySelectorAll('.rearrange-item:not(.dragging)')];
        
        return draggableElements.reduce((closest, child) => {
            const box = child.getBoundingClientRect();
            const offset = y - box.top - box.height / 2;
            
            if (offset < 0 && offset > closest.offset) {
                return { offset: offset, element: child };
            } else {
                return closest;
            }
        }, { offset: Number.NEGATIVE_INFINITY }).element;
    }

    updateRearrangeInput(questionIndex) {
        const container = document.getElementById(`rearrange_${questionIndex}`);
        const items = [...container.querySelectorAll('.rearrange-item')];
        const itemIds = items.map(item => parseInt(item.dataset.itemId));
        
        // Find or create hidden input
        let input = document.getElementById(`rearrange_${questionIndex}`);
        if (!input) {
            input = document.createElement('input');
            input.type = 'hidden';
            input.id = `rearrange_${questionIndex}`;
            input.name = `question${questionIndex}`; // This will be picked up as the answer
            container.appendChild(input);
        }
        
        // Use JSON array format as expected by backend
        input.value = JSON.stringify(itemIds);
        console.log('🔍 Rearrange JSON for question', questionIndex, ':', input.value);
        console.log('🔍 Expected format: [1,3,2,4]');
        
        // Debug: Show what correct order should be
        const correctOrder = items.map(item => parseInt(item.dataset.originalIndex) + 1);
        console.log('🔍 Original order should be:', correctOrder);
        console.log('🔍 Current item order:', items.map((item, idx) => `pos${idx}: item${item.dataset.itemId}`));
    }
}

// Shuffle function for drag items
function shuffleDraggableItems(questionIndex) {
    const container = document.getElementById(`dragItems_${questionIndex}`);
    if (!container) return;
    
    const items = [...container.children];
    for (let i = items.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        container.appendChild(items[j]);
    }
}

// Initialize the drag drop manager
const dragDropManager = new DragDropManager();
</script>
