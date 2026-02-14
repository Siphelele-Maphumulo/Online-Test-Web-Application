<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>

<%
    // Add session validation at the VERY TOP of the page
    Object userIdObj = session.getAttribute("userId");
    String userStatus = (String) session.getAttribute("userStatus");
    
    if (userIdObj == null || userStatus == null || !"1".equals(userStatus)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String courseName = request.getParameter("coursename");
    if (courseName == null || courseName.isEmpty()) {
        courseName = (String) session.getAttribute("last_course_name");
    }
    
    DatabaseClass pDAO = DatabaseClass.getInstance();
    int totalQuestions = 0;
    
    if (courseName != null && !courseName.isEmpty()) {
        try {
            ArrayList<Questions> questions = pDAO.getAllQuestions(courseName);
            totalQuestions = questions.size();
        } catch (Exception e) {
            totalQuestions = 0;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Question Added Successfully</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-blue: #09294d;
            --secondary-blue: #1a3d6d;
            --accent-blue: #4a90e2;
            --success: #059669;
            --white: #ffffff;
            --light-gray: #f8fafc;
            --dark-gray: #64748b;
            --text-dark: #1e293b;
            --radius-md: 12px;
            --radius-lg: 20px;
            --shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-dark);
        }

        .success-container {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 32px;
            box-shadow: var(--shadow-lg);
            text-align: center;
            max-width: 400px;
            width: 90%;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            overflow: hidden;
            z-index: 1000;
        }

        .success-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 6px;
            background: linear-gradient(90deg, var(--success), #10b981);
        }

        .success-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--success), #10b981);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            animation: scaleIn 0.5s ease-out;
        }

        .success-icon i {
            color: var(--white);
            font-size: 32px;
        }

        @keyframes scaleIn {
            0% { transform: scale(0); opacity: 0; }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); opacity: 1; }
        }

        h1 {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 12px;
        }

        .subtitle {
            font-size: 16px;
            color: var(--dark-gray);
            margin-bottom: 32px;
            line-height: 1.5;
        }

        .course-info {
            background: var(--light-gray);
            border-radius: var(--radius-md);
            padding: 16px;
            margin-bottom: 32px;
            border-left: 4px solid var(--accent-blue);
        }

        .course-name {
            font-size: 18px;
            font-weight: 600;
            color: var(--primary-blue);
            margin-bottom: 4px;
        }

        .question-count {
            font-size: 14px;
            color: var(--dark-gray);
        }

        .timer-display {
            font-size: 48px;
            font-weight: 700;
            color: var(--primary-blue);
            margin-bottom: 8px;
            font-variant-numeric: tabular-nums;
        }

        .timer-label {
            font-size: 14px;
            color: var(--dark-gray);
            margin-bottom: 32px;
        }

        .action-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 14px 28px;
            border: none;
            border-radius: var(--radius-md);
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            min-width: 160px;
            justify-content: center;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
            color: var(--white);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(9, 41, 77, 0.2);
        }

        .btn-success {
            background: linear-gradient(135deg, var(--success), #10b981);
            color: var(--white);
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(5, 150, 105, 0.2);
        }

        .btn-outline {
            background: transparent;
            border: 2px solid var(--medium-gray);
            color: var(--dark-gray);
        }

        .btn-outline:hover {
            background: var(--light-gray);
            border-color: var(--dark-gray);
        }

        .progress-bar {
            width: 100%;
            height: 4px;
            background: var(--light-gray);
            border-radius: 2px;
            overflow: hidden;
            margin-bottom: 24px;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--success), #10b981);
            border-radius: 2px;
            transition: width 1s linear;
        }

        @media (max-width: 640px) {
            .success-container {
                padding: 32px 24px;
                margin: 20px;
            }
            
            h1 {
                font-size: 24px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-icon">
            <i class="fas fa-check"></i>
        </div>
        
        <h1>Question Added Successfully!</h1>
        <p class="subtitle">Your question has been saved to the question bank.</p>
        
        <% if (courseName != null && !courseName.isEmpty()) { %>
        <div class="course-info">
            <div class="course-name"><%= courseName %></div>
            <div class="question-count">Total questions: <%= totalQuestions %></div>
        </div>
        <% } %>
        
        <div class="timer-display" id="countdown">5</div>
        <div class="timer-label">Auto-redirecting to questions list...</div>
        
        <div class="progress-bar">
            <div class="progress-fill" id="progressBar" style="width: 100%;"></div>
        </div>
        
        <div class="action-buttons">
            <a href="adm-page.jsp?pgprt=3" class="btn btn-primary">
                <i class="fas fa-plus"></i>
                Add Another Question
            </a>
            <a href="showall.jsp<%= courseName != null && !courseName.isEmpty() ? "?coursename=" + java.net.URLEncoder.encode(courseName, "UTF-8") : "" %>" class="btn btn-success">
                <i class="fas fa-list"></i>
                View Questions
            </a>
        </div>
    </div>

    <script>
        let countdown = 10;
        const countdownElement = document.getElementById('countdown');
        const progressBar = document.getElementById('progressBar');
        
        // Set redirect URL based on course name
        const redirectUrl = <% if (courseName != null && !courseName.isEmpty()) { %>
            'showall.jsp?coursename=<%= java.net.URLEncoder.encode(courseName, "UTF-8") %>';
        <% } else { %>
            'showall.jsp';
        <% } %>
        
        function updateCountdown() {
            countdown--;
            countdownElement.textContent = countdown;
            
            // Update progress bar
            const progressPercentage = (countdown / 10) * 100;
            progressBar.style.width = progressPercentage + '%';
            
            if (countdown <= 0) {
                // Redirect to showall.jsp
                window.location.href = redirectUrl;
            }
        }
        
        // Start countdown
        const countdownInterval = setInterval(updateCountdown, 1000);
        
        // Clear interval if user clicks any button
        document.querySelectorAll('.btn').forEach(button => {
            button.addEventListener('click', () => {
                clearInterval(countdownInterval);
            });
        });
        
        // Add some entrance animations
        document.addEventListener('DOMContentLoaded', () => {
            const container = document.querySelector('.success-container');
            container.style.animation = 'slideInUp 0.6s ease-out';
        });
        
        // Add slide in animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideInUp {
                from {
                    transform: translateY(30px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>
