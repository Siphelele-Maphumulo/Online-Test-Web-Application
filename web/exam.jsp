<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONArray"%>
<%
    // Initialize database connection
    DatabaseClass pDAO = DatabaseClass.getInstance();
    
    // Generate CSRF token if not exists
    if (session.getAttribute("csrf_token") == null) {
        String csrfToken = java.util.UUID.randomUUID().toString();
        session.setAttribute("csrf_token", csrfToken);
    }
    
    // Determine if we should show exam form or active exam
    String showExamForm = "true"; // Default to showing exam selection form
    String courseName = "";
    ArrayList<Questions> questionsList = new ArrayList<>();
    int totalQ = 0;
    int examDuration = 60;
    
    // Check if we should show active exam
    if ("1".equals(String.valueOf(session.getAttribute("examStarted"))) &&
        request.getParameter("coursename") != null &&
        !request.getParameter("coursename").isEmpty()) {
        showExamForm = "false";
        courseName = request.getParameter("coursename");
        if (courseName != null && !courseName.isEmpty()) {
            questionsList = pDAO.getQuestions(courseName, 20);
            if (questionsList != null) {
                totalQ = questionsList.size();
                if (totalQ > 0) {
                    examDuration = pDAO.getExamDuration(courseName);
                }
            }
        }
    } else {
        // Clear any stale exam session data
        session.removeAttribute("examStarted");
        session.removeAttribute("examId");
    }
    
    // Store as page attributes for JavaScript access
    pageContext.setAttribute("showExamForm", showExamForm);
    pageContext.setAttribute("jsCourseName", courseName);
    pageContext.setAttribute("jsTotalQ", totalQ);
    pageContext.setAttribute("jsExamDuration", examDuration);
%>

<%! 
    // Helper method for duration formatting
    public String formatDuration(int minutes) { 
        if (minutes < 60) { 
            return minutes + " minute" + (minutes != 1 ? "s" : "" ); 
        } else { 
            int hours = minutes / 60; 
            int remainingMinutes = minutes % 60; 
            if (remainingMinutes == 0) { 
                return hours + " hour" + (hours != 1 ? "s" : "" ); 
            } else { 
                return hours + " hour" + (hours != 1 ? "s" : "" ) + " " + remainingMinutes + " minute" + (remainingMinutes != 1 ? "s" : "" ); 
            } 
        } 
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Examination System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-blue: #09294d;
            --accent-blue: #3b82f6;
            --success: #10b981;
            --warning: #f59e0b;
            --error: #ef4444;
            --white: #ffffff;
            --light-gray: #f8fafc;
            --medium-gray: #e2e8f0;
            --dark-gray: #64748b;
            --text-dark: #1e293b;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--light-gray);
            color: var(--text-dark);
        }
        
        .exam-wrapper {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 200px;
            background: var(--primary-blue);
            color: var(--white);
            position: fixed;
            height: 100vh;
            padding: 20px 0;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        
        .sidebar-header {
            text-align: center;
            margin-bottom: 30px;
            padding: 0 20px;
        }
        
        .mut-logo {
            max-width: 120px;
            filter: brightness(0) invert(1);
        }
        
        .sidebar-nav {
            padding: 0 20px;
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 8px;
            transition: all 0.3s ease;
        }
        
        .nav-item:hover {
            background: rgba(255,255,255,0.1);
            color: var(--white);
        }
        
        .nav-item.active {
            background: var(--accent-blue);
            color: var(--white);
        }
        
        .content-area {
            flex: 1;
            margin-left: 200px;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .page-header {
            background: var(--primary-blue);
            color: var(--white);
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(9, 41, 77, 0.15);
        }
        
        .page-title {
            font-size: 1.5rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .timer {
            background: var(--warning);
            color: var(--white);
            padding: 10px 20px;
            border-radius: 30px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .card {
            background: var(--white);
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-bottom: 20px;
        }
        
        .question-card {
            background: var(--white);
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 20px;
            border: 1px solid var(--medium-gray);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .question-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.12);
        }
        
        .question-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            gap: 15px;
        }
        
        .question-number {
            background: var(--primary-blue);
            color: var(--white);
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        
        .question-text {
            font-size: 1.1rem;
            font-weight: 500;
            color: var(--text-dark);
            line-height: 1.6;
        }
        
        .option {
            padding: 15px;
            margin: 10px 0;
            border: 2px solid var(--medium-gray);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
        }
        
        .option:hover {
            border-color: var(--accent-blue);
            background: rgba(59, 130, 246, 0.05);
        }
        
        .option input {
            margin-right: 15px;
            width: 18px;
            height: 18px;
            cursor: pointer;
        }
        
        .option label {
            cursor: pointer;
            font-size: 1rem;
            color: var(--text-dark);
            flex: 1;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 1.1rem;
        }
        
        .form-control {
            width: 100%;
            padding: 14px;
            border: 2px solid var(--medium-gray);
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        
        .btn {
            background: var(--primary-blue);
            color: var(--white);
            padding: 14px 28px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }
        
        .btn:hover {
            background: #0d3060;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(9, 41, 77, 0.2);
        }
        
        .btn:disabled {
            background: var(--medium-gray);
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .btn-success {
            background: var(--success);
        }
        
        .btn-success:hover {
            background: #059669;
        }
        
        .alert {
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        
        .alert-warning {
            background: #fffbeb;
            border: 1px solid #fcd34d;
            color: #92400e;
        }
        
        .alert-warning i {
            margin-right: 10px;
            color: #f59e0b;
        }
        
        .submit-section {
            position: fixed;
            bottom: 0;
            left: 200px;
            right: 0;
            background: var(--white);
            padding: 20px;
            border-top: 1px solid var(--medium-gray);
            box-shadow: 0 -4px 12px rgba(0,0,0,0.1);
            z-index: 100;
        }
        
        .submit-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .time-display {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 1.1rem;
        }
        
        .time-remaining {
            background: var(--warning);
            color: var(--white);
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .question-image {
            max-width: 100%;
            max-height: 300px;
            border-radius: 8px;
            margin: 15px 0;
            display: block;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            
            .content-area {
                margin-left: 0;
                padding: 15px;
            }
            
            .submit-section {
                left: 0;
                padding: 15px;
            }
            
            .page-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="exam-wrapper">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
            </div>
            <nav class="sidebar-nav">
                <a href="std-page.jsp?pgprt=0" class="nav-item">
                    <i class="fas fa-user"></i>
                    <span>Profile</span>
                </a>
                <a href="std-page.jsp?pgprt=1" class="nav-item active">
                    <i class="fas fa-file-alt"></i>
                    <span>Exams</span>
                </a>
                <a href="std-page.jsp?pgprt=2" class="nav-item">
                    <i class="fas fa-graduation-cap"></i>
                    <span>Courses</span>
                </a>
                <a href="std-page.jsp?pgprt=3" class="nav-item">
                    <i class="fas fa-chart-line"></i>
                    <span>Results</span>
                </a>
            </nav>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="content-area">
            <div class="container">
                <% if ("false".equals(showExamForm)) { 
                    // ACTIVE EXAM MODE
                    if (questionsList != null && !questionsList.isEmpty() && totalQ > 0) { %>
                    
                    <div class="page-header">
                        <div class="page-title">
                            <i class="fas fa-file-alt"></i>
                            <%= courseName %> Exam
                        </div>
                        <div class="timer">
                            <i class="fas fa-clock"></i>
                            <span id="timer"><%= examDuration %>:00</span>
                        </div>
                    </div>

                    <form id="examForm" action="controller.jsp" method="post">
                        <input type="hidden" name="page" value="exams">
                        <input type="hidden" name="operation" value="submitted">
                        <input type="hidden" name="size" value="<%= totalQ %>">
                        <input type="hidden" name="totalmarks" value="<%= pDAO.getTotalMarksByName(courseName) %>">
                        <input type="hidden" name="coursename" value="<%= courseName %>">

                        <% for (int i = 0; i < totalQ; i++) {
                            Questions q = questionsList.get(i);
                            ArrayList<String> opts = new ArrayList<>();
                            if(q.getOpt1() != null && !q.getOpt1().trim().isEmpty()) opts.add(q.getOpt1());
                            if(q.getOpt2() != null && !q.getOpt2().trim().isEmpty()) opts.add(q.getOpt2());
                            if(q.getOpt3() != null && !q.getOpt3().trim().isEmpty()) opts.add(q.getOpt3());
                            if(q.getOpt4() != null && !q.getOpt4().trim().isEmpty()) opts.add(q.getOpt4());
                            
                            java.util.Collections.shuffle(opts);
                        %>
                        
                        <div class="question-card">
                            <div class="question-header">
                                <div class="question-number"><%= i+1 %></div>
                                <div class="question-text"><%= q.getQuestion() %></div>
                            </div>
                            
                            <% if(q.getImagePath() != null && !q.getImagePath().isEmpty()) { %>
                                <div style="text-align: center;">
                                    <img src="<%= q.getImagePath() %>" alt="Question Image" class="question-image">
                                </div>
                            <% } %>
                            
                            <div>
                                <% for(int oi = 0; oi < opts.size(); oi++) {
                                    String optVal = opts.get(oi);
                                    String inputId = "q" + i + "o" + (oi+1);
                                %>
                                    <div class="option">
                                        <input type="radio" id="<%= inputId %>" name="ans<%= i %>" value="<%= optVal %>">
                                        <label for="<%= inputId %>"><%= optVal %></label>
                                    </div>
                                <% } %>
                            </div>
                            <input type="hidden" name="question<%= i %>" value="<%= q.getQuestion() %>">
                            <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">
                        </div>
                        <% } %>
                    </form>

                    <!-- Submit Section -->
                    <div class="submit-section">
                        <div class="submit-content">
                            <div class="time-display">
                                Time Remaining: 
                                <span class="time-remaining">
                                    <i class="fas fa-clock"></i>
                                    <span id="timeDisplay"><%= examDuration %>:00</span>
                                </span>
                            </div>
                            <button type="button" class="btn btn-success" onclick="submitExam()">
                                <i class="fas fa-paper-plane"></i>
                                Submit Exam
                            </button>
                        </div>
                    </div>

                <% } else { %>
                    <!-- NO QUESTIONS AVAILABLE -->
                    <div class="page-header">
                        <div class="page-title">
                            <i class="fas fa-exclamation-triangle"></i>
                            Exam Not Available
                        </div>
                    </div>
                    <div class="card">
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <strong>No Questions Found</strong>
                            <p>The selected exam does not have any questions or is not properly configured.</p>
                        </div>
                        <a href="std-page.jsp?pgprt=1" class="btn">
                            <i class="fas fa-arrow-left"></i>
                            Back to Exam Selection
                        </a>
                    </div>
                <% } %>

                <% } else if ("1".equals(request.getParameter("showresult"))) { 
                    // RESULTS MODE
                    String examId = request.getParameter("eid");
                    if (examId != null && !examId.isEmpty()) {
                        try {
                            int eId = Integer.parseInt(examId);
                            Exams exam = pDAO.getResultByExamId(eId);
                            if (exam != null) {
                %>
                                <div class="page-header">
                                    <div class="page-title">
                                        <i class="fas fa-poll"></i>
                                        Exam Results
                                    </div>
                                </div>
                                <div class="card">
                                    <h2 style="margin-bottom: 20px; color: var(--primary-blue);">Your Results</h2>
                                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px;">
                                        <div style="background: var(--light-gray); padding: 20px; border-radius: 12px; text-align: center;">
                                            <div style="font-size: 2rem; font-weight: 700; color: var(--primary-blue);"><%= exam.getObtMarks() %></div>
                                            <div style="color: var(--dark-gray);">Marks Obtained</div>
                                        </div>
                                        <div style="background: var(--light-gray); padding: 20px; border-radius: 12px; text-align: center;">
                                            <div style="font-size: 2rem; font-weight: 700; color: var(--primary-blue);"><%= exam.gettMarks() %></div>
                                            <div style="color: var(--dark-gray);">Total Marks</div>
                                        </div>
                                        <div style="background: var(--light-gray); padding: 20px; border-radius: 12px; text-align: center;">
<%
String percentageColor = (exam.getObtMarks() * 100.0 / exam.gettMarks()) >= 45 ? "var(--success)" : "var(--error)";
String percentageValue = String.format("%.1f", (exam.getObtMarks() * 100.0 / exam.gettMarks()));
%>
                                            <div style="font-size: 2rem; font-weight: 700; color: <%= percentageColor %>;">
                                                <%= percentageValue %>%
                                            </div>
                                            <div style="color: var(--dark-gray);">Percentage</div>
                                        </div>
                                        <div style="background: var(--light-gray); padding: 20px; border-radius: 12px; text-align: center;">
<%
                                            String statusColor = (exam.getObtMarks() * 100.0 / exam.gettMarks()) >= 45 ? "var(--success)" : "var(--error)";
                                            String statusText = (exam.getObtMarks() * 100.0 / exam.gettMarks()) >= 45 ? "PASS" : "FAIL";
                                            %>
                                            <div style="font-size: 2rem; font-weight: 700; color: <%= statusColor %>;">
                                                <%= statusText %>
                                            </div>
                                            <div style="color: var(--dark-gray);">Status</div>
                                        </div>
                                    </div>
                                    <a href="std-page.jsp?pgprt=1" class="btn">
                                        <i class="fas fa-arrow-left"></i>
                                        Back to Exams
                                    </a>
                                </div>
                <%          } else { %>
                                <div class="page-header">
                                    <div class="page-title">Results Not Found</div>
                                </div>
                                <div class="card">
                                    <p>Exam results could not be retrieved.</p>
                                    <a href="std-page.jsp?pgprt=1" class="btn">Back to Exams</a>
                                </div>
                <%          }
                        } catch (NumberFormatException e) { %>
                            <div class="page-header">
                                <div class="page-title">Invalid Exam ID</div>
                            </div>
                            <div class="card">
                                <p>Invalid exam identifier provided.</p>
                                <a href="std-page.jsp?pgprt=1" class="btn">Back to Exams</a>
                            </div>
                <%      }
                    } else { %>
                        <div class="page-header">
                            <div class="page-title">No Results Available</div>
                        </div>
                        <div class="card">
                            <p>No exam results to display.</p>
                            <a href="std-page.jsp?pgprt=1" class="btn">Back to Exams</a>
                        </div>
                <%  } %>

                <% } else { 
                    // COURSE SELECTION MODE
                    ArrayList<String> activeCourseNames = pDAO.getActiveCourseNames();
                %>
                
                <div class="page-header">
                    <div class="page-title">
                        <i class="fas fa-clipboard-list"></i>
                        Select Exam
                    </div>
                </div>

                <div class="card">
                    <form action="controller.jsp" method="post" id="examStartForm">
                        <input type="hidden" name="page" value="exams">
                        <input type="hidden" name="operation" value="startexam">
                        <input type="hidden" name="csrf_token" value="<%= session.getAttribute("csrf_token") %>">
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book"></i>
                                Select Course
                            </label>
                            <select name="coursename" class="form-control" required id="courseSelect">
                                <option value="">Choose a course...</option>
                                <% 
                                if (activeCourseNames != null && !activeCourseNames.isEmpty()) {
                                    for(String course : activeCourseNames) { 
                                        if (course != null && !course.trim().isEmpty()) {
                                            int duration = pDAO.getExamDuration(course);
                                %>
                                <option value="<%= course %>" data-duration="<%= duration %>">
                                    <%= course %> (<%= formatDuration(duration) %>)
                                </option>
                                <% 
                                        }
                                    }
                                } else {
                                %>
                                <option value="" disabled>No exams available</option>
                                <% } %>
                            </select>
                        </div>

                        <button type="submit" class="btn" id="startExamBtn">
                            <i class="fas fa-play"></i>
                            Start Exam
                        </button>
                    </form>
                </div>

                <% } %>
            </div>
        </main>
    </div>

    <script>
        // --- GLOBAL VARIABLES ---
<%
        String jsExamActive = "false".equals(showExamForm) ? "true" : "false";
        String jsExamDuration = pageContext.getAttribute("jsExamDuration") != null ? pageContext.getAttribute("jsExamDuration").toString() : "60";
        String jsTotalQ = pageContext.getAttribute("jsTotalQ") != null ? pageContext.getAttribute("jsTotalQ").toString() : "0";
        String jsCourseName = pageContext.getAttribute("jsCourseName") != null ? pageContext.getAttribute("jsCourseName").toString() : "";
        %>
        var examActive = <%= jsExamActive %>;
        var warningGiven = false;
        var dirty = false;
        var timerInterval = null;
        
        // Get values from JSP with null checks
        var examDuration = <%= jsExamDuration %>;
        var totalQuestions = <%= jsTotalQ %>;
        var currentCourseName = '<%= jsCourseName %>';
        
        // Timer variables
        var timeLeft = examDuration * 60;

        // Start timer if exam is active
        if (examActive && examDuration > 0) {
            startTimer();
        }

        function startTimer() {
            timerInterval = setInterval(function() {
                timeLeft--;
                
                var minutes = Math.floor(timeLeft / 60);
                var seconds = timeLeft % 60;
                
                var timeString = minutes.toString().padStart(2, '0') + ':' + 
                                seconds.toString().padStart(2, '0');
                
                // Update timer displays
                var timerElements = document.querySelectorAll('#timer, #timeDisplay');
                timerElements.forEach(function(element) {
                    if (element) {
                        element.textContent = timeString;
                    }
                });
                
                // Warning when time is low
                if (timeLeft <= 300) { // 5 minutes
                    var timers = document.querySelectorAll('.timer, .time-remaining');
                    timers.forEach(function(timer) {
                        timer.style.background = 'var(--error)';
                    });
                }
                
                // Auto-submit when time expires
                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                    alert('Time is up! Your exam will be submitted automatically.');
                    submitExam();
                }
            }, 1000);
        }

        function submitExam() {
            var answeredCount = 0;
            var radios = document.querySelectorAll('input[type="radio"]');
            
            // Count total questions and answered ones
            var questions = document.querySelectorAll('.question-card');
            var totalQ = questions.length;
            
            // Count answered questions
            for (var i = 0; i < radios.length; i++) {
                if (radios[i].checked) {
                    answeredCount++;
                }
            }
            
            var unanswered = totalQ - answeredCount;
            
            if (unanswered > 0) {
                if (!confirm("You have " + unanswered + " unanswered question" + 
                    (unanswered > 1 ? "s" : "") + ". Submit anyway?")) {
                    return;
                }
            }
            
            if (confirm("Are you sure you want to submit your exam?")) {
                // Disable submit button
                var submitBtn = document.querySelector('.submit-section .btn');
                if (submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
                }
                
                // Submit form
                document.getElementById('examForm').submit();
            }
        }

        // Handle form submission for starting exam
        document.getElementById('examStartForm')?.addEventListener('submit', function(e) {
            var courseSelect = document.getElementById('courseSelect');
            if (!courseSelect || !courseSelect.value) {
                e.preventDefault();
                alert('Please select a course.');
                return false;
            }
        });

        // Navigation warning
        window.addEventListener('beforeunload', function(e) {
            if (examActive) {
                e.preventDefault();
                e.returnValue = 'You have an active exam in progress. Are you sure you want to leave?';
                return e.returnValue;
            }
        });
    </script>
</body>
</html>