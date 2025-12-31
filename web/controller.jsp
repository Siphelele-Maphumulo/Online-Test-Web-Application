<%@ page import="java.lang.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

<!-- Add these SQL imports -->
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.ResultSet" %>


<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();

/** Returns value if non-null/non-empty, otherwise fallback. */
%>
<%!
private String nz(String v, String fallback){
    return (v != null && !v.trim().isEmpty()) ? v.trim() : fallback;
}
%>

<%
try {
    String pageParam = request.getParameter("page");
    if (pageParam == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    /* =========================
       LOGIN
       ========================= */
    if ("login".equalsIgnoreCase(pageParam)) {
        String userName = nz(request.getParameter("username"), "");
        String userPass = nz(request.getParameter("password"), "");

        if (pDAO.loginValidate(userName, userPass)) {
            session.setAttribute("userStatus", "1");
            session.setAttribute("userId", pDAO.getUserId(userName));
            // Forward to transition page so client-side loader has time to display
            request.setAttribute("targetUrl", "dashboard.jsp");
            request.setAttribute("message", "Logging you in...");
            request.setAttribute("delayMs", Integer.valueOf(5000));
            request.getRequestDispatcher("transition.jsp").forward(request, response);
            return;
        } else {
            session.setAttribute("error", "Invalid username or password");
            response.sendRedirect("login.jsp");
        }

    /* =========================
       REGISTER
       ========================= */
    } else if ("register".equalsIgnoreCase(pageParam)) {
        String fName     = nz(request.getParameter("fname"), "");
        String lName     = nz(request.getParameter("lname"), "");
        String uName     = nz(request.getParameter("uname"), "");
        String email     = nz(request.getParameter("email"), "");
        String pass      = nz(request.getParameter("pass"), "");
        String contactNo = nz(request.getParameter("contactno"), "");
        String city      = nz(request.getParameter("city"), "");
        String address   = nz(request.getParameter("address"), "");

        String userType = nz(request.getParameter("user_type"), "");
        String fromPage = nz(request.getParameter("from_page"), "");

        String hashedPass = PasswordUtils.bcryptHashPassword(pass);

        pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, userType);

        boolean isAdminOrLecture = "admin".equalsIgnoreCase(userType) || "lecture".equalsIgnoreCase(userType)
                                   || "account".equalsIgnoreCase(fromPage);

        if (isAdminOrLecture) {
            session.setAttribute("message", "Student added successfully!");
            response.sendRedirect("accounts.jsp");
        } else {
            session.setAttribute("message", "Registration successful! Please login");
            response.sendRedirect("login.jsp");
        }

    /* =========================
       STAFF REGISTER
       ========================= */
    } else if ("registerStaff".equalsIgnoreCase(pageParam)) {
        String fullNames  = nz(request.getParameter("fullNames"), "");
        String staffNum   = nz(request.getParameter("staffNum"), "");
        String email      = nz(request.getParameter("email"), "");
        String courseName = nz(request.getParameter("course_name"), "");
        String fromPage   = nz(request.getParameter("from_page"), "");
        String userType   = nz(request.getParameter("user_type"), "");

        pDAO.addNewStaff(staffNum, email, fullNames, courseName);
        session.setAttribute("message", "Lecturer registered successfully!");

        if ("account".equalsIgnoreCase(fromPage) || "admin".equalsIgnoreCase(userType) || "lecture".equalsIgnoreCase(userType)) {
            response.sendRedirect("adm-page.jsp?pgprt=6");
        } else {
            response.sendRedirect("staff_Numbers.jsp");
        }

    /* =========================
       PROFILE UPDATE
       ========================= */
    } else if ("profile".equalsIgnoreCase(pageParam)) {
        if (session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int uid = Integer.parseInt(session.getAttribute("userId").toString());
        String contact = nz(request.getParameter("contactno"), "");
        String city    = nz(request.getParameter("city"), "");
        String address = nz(request.getParameter("address"), "");
        String courseName = nz(request.getParameter("course_name"), "");

        User current = pDAO.getUserDetails(String.valueOf(uid));
        if (current == null) {
            session.setAttribute("error", "User not found");
            response.sendRedirect("login.jsp");
            return;
        }

        if ("lecture".equalsIgnoreCase(current.getType())) {
            int rows = pDAO.updateLecturer(uid, current.getFirstName(), current.getLastName(), current.getUserName(),
                            current.getEmail(), current.getPassword(), contact, city, address, current.getType(), courseName);
            if (rows > 0) session.setAttribute("message","Profile updated successfully!");
            else session.setAttribute("error","Failed to update profile.");
            response.sendRedirect("adm-page.jsp?pgprt=0");
        } else {
            int rows = pDAO.updateStudent(uid, current.getFirstName(), current.getLastName(), current.getUserName(),
                            current.getEmail(), current.getPassword(), contact, city, address, current.getType());
            if (rows > 0) session.setAttribute("message","Profile updated successfully!");
            else session.setAttribute("error","Failed to update profile.");
            response.sendRedirect("std-page.jsp?pgprt=0");
        }

    /* =========================
       COURSES
       ========================= */
    } else if ("courses".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("addnew".equalsIgnoreCase(operation)) {
            String courseName = nz(request.getParameter("coursename"), "");
            int totalMarks    = Integer.parseInt(nz(request.getParameter("totalmarks"), "0"));
            String time       = nz(request.getParameter("time"), "");
            String examDate   = nz(request.getParameter("examdate"), "");

            boolean success = pDAO.addNewCourse(courseName, totalMarks, time, examDate);
            session.setAttribute("message", success ? "Course added successfully" : "Error adding course");
            response.sendRedirect("adm-page.jsp?pgprt=2");

        } else if ("del".equalsIgnoreCase(operation)) {
            String cname = nz(request.getParameter("cname"), "");
            if (!cname.isEmpty()) {
                pDAO.delCourse(cname);
                session.setAttribute("message","Course deleted successfully");
            }
            response.sendRedirect("adm-page.jsp?pgprt=2");
        } else if ("toggle_status".equalsIgnoreCase(operation)) {
            String cname = nz(request.getParameter("cname"), "");
            if (!cname.isEmpty()) {
                pDAO.toggleCourseStatus(cname);
                session.setAttribute("message","Course status updated successfully");
            }
            response.sendRedirect("adm-page.jsp?pgprt=2");
        } else if ("update_course".equalsIgnoreCase(operation)) {
            String originalCourseName = nz(request.getParameter("original_course_name"), "");
            String courseName = nz(request.getParameter("coursename"), "");
            int totalMarks = Integer.parseInt(nz(request.getParameter("totalmarks"), "0"));
            String time = nz(request.getParameter("time"), "");
            String examDate = nz(request.getParameter("examdate"), "");
            
            boolean success = pDAO.updateCourse(originalCourseName, courseName, totalMarks, time, examDate);
            session.setAttribute("message", success ? "Course updated successfully" : "Error updating course");
            response.sendRedirect("adm-page.jsp?pgprt=2");
        } else {
            session.setAttribute("error", "Invalid operation for courses");
            response.sendRedirect("adm-page.jsp?pgprt=2");
        }

    /* =========================
       EDIT USER (UPDATE ACCOUNT)
       ========================= */
    } else if ("accounts".equalsIgnoreCase(pageParam) && "edit".equalsIgnoreCase(nz(request.getParameter("operation"), ""))) {
        try {
            int userId = Integer.parseInt(request.getParameter("uid"));
            String firstName = nz(request.getParameter("fname"), "");
            String lastName  = nz(request.getParameter("lname"), "");
            String userName  = nz(request.getParameter("uname"), "");
            String email     = nz(request.getParameter("email"), "");
            String password  = request.getParameter("pass");
            String userType  = nz(request.getParameter("type"), "");
            String contact   = nz(request.getParameter("contactno"), "");
            String city      = nz(request.getParameter("city"), "");
            String address   = nz(request.getParameter("address"), "");
            String courseName= nz(request.getParameter("course_name"), "");

            User existingUser = pDAO.getUserDetails(String.valueOf(userId));
            if (existingUser == null) {
                session.setAttribute("error","User not found.");
                response.sendRedirect("edit-user.jsp?uid=" + userId);
                return;
            }

            // Check if username already exists for another user
            User userByUsername = pDAO.getUserByUsername(userName);
            if (userByUsername != null && userByUsername.getUserId() != userId) {
                session.setAttribute("error","Username already exists. Please choose a different username.");
                response.sendRedirect("edit-user.jsp?uid=" + userId);
                return;
            }

            // Check if email already exists for another user
            User userByEmail = pDAO.getUserByEmail(email);
            if (userByEmail != null && userByEmail.getUserId() != userId) {
                session.setAttribute("error","Email already exists. Please use a different email.");
                response.sendRedirect("edit-user.jsp?uid=" + userId);
                return;
            }

            if (password == null || password.trim().isEmpty()) {
                password = existingUser.getPassword();
            } else {
                password = BCrypt.hashpw(password, BCrypt.gensalt());
            }

            if (!"lecture".equalsIgnoreCase(userType)) {
                courseName = "";
            }

            User updatedUser = new User(userId, firstName, lastName, userName, email, password, userType, contact, city, address, courseName);

            boolean success = pDAO.updateUser(updatedUser);
            if (success) {
                session.setAttribute("message", "User updated successfully!");
                response.sendRedirect("lecture".equalsIgnoreCase(userType) ? "adm-page.jsp?pgprt=6" : "adm-page.jsp?pgprt=1");
            } else {
                session.setAttribute("error", "Failed to update user.");
                response.sendRedirect("edit-user.jsp?uid=" + userId);
            }

        } catch(Exception e){
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
            response.sendRedirect("edit-user.jsp?uid=" + request.getParameter("uid"));
        }
        return;

    /* =========================
       ACCOUNTS (STUDENTS)
       ========================= */
    } else if ("accounts".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        String uidParam  = nz(request.getParameter("uid"), "");
        if ("del".equalsIgnoreCase(operation) && !uidParam.isEmpty()) {
            int userId = Integer.parseInt(uidParam);
            // Use cascade delete instead of simple delete
            pDAO.deleteUserCascade(userId);
            session.setAttribute("message","Account and all associated data deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=1");

    /* =========================
       LECTURERS ACCOUNTS
       ========================= */
    } else if ("Lecturers_accounts".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        String uidParam  = nz(request.getParameter("uid"), "");
        if ("del".equalsIgnoreCase(operation) && !uidParam.isEmpty()) {
            int userId = Integer.parseInt(uidParam);
            // Use cascade delete for consistency
            pDAO.deleteUserCascade(userId);
            session.setAttribute("message","Lecturer and all associated data deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=6");

    /* =========================
       QUESTIONS
       ========================= */
    } else if ("questions".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("del".equalsIgnoreCase(operation)) {
            String qid = nz(request.getParameter("qid"), "");
            if (!qid.isEmpty()) pDAO.deleteQuestion(Integer.parseInt(qid));
            session.setAttribute("message","Question deleted successfully");
            response.sendRedirect("adm-page.jsp?pgprt=3");

        } else if ("edit".equalsIgnoreCase(operation)) {
            String qid = nz(request.getParameter("qid"), "");
            if (!qid.isEmpty()) {
                Questions question = pDAO.getQuestionById(Integer.parseInt(qid));
                if (question != null) {
                    question.setQuestion(nz(request.getParameter("question"), ""));
                    question.setOpt1(nz(request.getParameter("opt1"), ""));
                    question.setOpt2(nz(request.getParameter("opt2"), ""));
                    question.setOpt3(nz(request.getParameter("opt3"), ""));
                    question.setOpt4(nz(request.getParameter("opt4"), ""));
                    question.setCorrect(nz(request.getParameter("correct"), ""));
                    question.setCourseName(nz(request.getParameter("coursename"), ""));
                    pDAO.updateQuestion(question);
                    session.setAttribute("message","Question updated successfully");
                }
            }
            response.sendRedirect("adm-page.jsp?pgprt=3");

        } else if ("addnew".equalsIgnoreCase(operation)) {
            String questionText  = nz(request.getParameter("question"), "");
            String opt1          = nz(request.getParameter("opt1"), "");
            String opt2          = nz(request.getParameter("opt2"), "");
            String opt3          = nz(request.getParameter("opt3"), "");
            String opt4          = nz(request.getParameter("opt4"), "");
            String correctAnswer = nz(request.getParameter("correct"), "");
            String courseName    = nz(request.getParameter("coursename"), "");
            String questionType  = nz(request.getParameter("questionType"), "");

            if ("MultipleSelect".equalsIgnoreCase(questionType)) {
                String correctMultiple = nz(request.getParameter("correctMultiple"), "");
                if (!correctMultiple.isEmpty()) correctAnswer = correctMultiple;
            }

            pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType);
            session.setAttribute("message","Question added successfully");
            response.sendRedirect("adm-page.jsp?pgprt=3");
        } else {
            session.setAttribute("error", "Invalid operation for questions");
            response.sendRedirect("adm-page.jsp?pgprt=3");
        }

/* =========================
   RESULTS
   ========================= */
} else if ("results".equalsIgnoreCase(pageParam)) {
    String operation = nz(request.getParameter("operation"), "");
    
    if ("edit".equalsIgnoreCase(operation)) {
        int examId = Integer.parseInt(nz(request.getParameter("eid"), "0"));
        int obtMarks = Integer.parseInt(nz(request.getParameter("obtMarks"), "0"));
        int totalMarks = Integer.parseInt(nz(request.getParameter("totalMarks"), "0"));
        String status = nz(request.getParameter("status"), "");
        
        // Calculate percentage
        double percentage = 0;
        if (totalMarks > 0) {
            percentage = ((double) obtMarks / totalMarks) * 100;
        }
        
        // Update result status based on percentage if not manually set
        if (status.isEmpty()) {
            status = (percentage >= 45.0) ? "Pass" : "Fail";
        }
        
        // Update the exam in database
        try {
            Connection conn = pDAO.getConnection();
            String sql = "UPDATE exams SET obt_marks=?, result_status=? WHERE exam_id=?";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setInt(1, obtMarks);
            pstm.setString(2, status);
            pstm.setInt(3, examId);
            pstm.executeUpdate();
            pstm.close();
            
            session.setAttribute("message", "Result updated successfully!");
        } catch (SQLException ex) {
            session.setAttribute("error", "Error updating result: " + ex.getMessage());
        }
        response.sendRedirect("adm-page.jsp?pgprt=5");
        
    } else if ("delete".equalsIgnoreCase(operation)) {
        // Validate CSRF token
        String csrfToken = request.getParameter("csrf_token");
        String sessionToken = (String) session.getAttribute("csrf_token");

        if (csrfToken == null || !csrfToken.equals(sessionToken)) {
            session.setAttribute("error", "Security token mismatch. Please try again.");
            response.sendRedirect("adm-page.jsp?pgprt=5");
            return;
        }
        int examId = Integer.parseInt(nz(request.getParameter("eid"), "0"));
        
        try {
            Connection conn = pDAO.getConnection();
            
            // First delete answers for this exam
            String deleteAnswersSql = "DELETE FROM answers WHERE exam_id=?";
            PreparedStatement pstm1 = conn.prepareStatement(deleteAnswersSql);
            pstm1.setInt(1, examId);
            pstm1.executeUpdate();
            pstm1.close();
            
            // Then delete the exam
            String deleteExamSql = "DELETE FROM exams WHERE exam_id=?";
            PreparedStatement pstm2 = conn.prepareStatement(deleteExamSql);
            pstm2.setInt(1, examId);
            pstm2.executeUpdate();
            pstm2.close();
            
            session.setAttribute("message", "Exam result deleted successfully!");
        } catch (SQLException ex) {
            session.setAttribute("error", "Error deleting result: " + ex.getMessage());
            ex.printStackTrace();
        }
        response.sendRedirect("adm-page.jsp?pgprt=5");
    } else {
        session.setAttribute("error", "Invalid operation for results");
        response.sendRedirect("adm-page.jsp?pgprt=5");
    }

/* =========================
   EXAMS
   ========================= */
} else if ("exams".equalsIgnoreCase(pageParam)) {

    String operation = nz(request.getParameter("operation"), "");
    if (page.equals("exams")) {
        if (operation.equals("startexam")) {
            // Verify CSRF token
            String csrfToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");
            
            if (csrfToken == null || !csrfToken.equals(sessionToken)) {
                response.sendRedirect("std-page.jsp?pgprt=1&error=Invalid CSRF token");
                return;
            }
            
            String coursename = request.getParameter("coursename");
            
            // Check if course is active
            boolean isActive = pDAO.isCourseActive(coursename);
            
            if (!isActive) {
                response.sendRedirect("std-page.jsp?pgprt=1&error=This exam is not active");
                return;
            }
            
            // Start new exam and get the exam ID
            int userId = 0;
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj != null) {
                userId = Integer.parseInt(userIdObj.toString());
            } else {
                // Try to get user ID from username
                String username = (String) session.getAttribute("uname");
                if (username != null) {
                    userId = pDAO.getUserId(username);
                }
            }
            
            if (userId == 0) {
                response.sendRedirect("std-page.jsp?pgprt=1&error=User not logged in");
                return;
            }
            
            int examId = pDAO.startExam(coursename, userId);
            
            if (examId > 0) {
                // Set session attributes
                session.setAttribute("examStarted", "1");
                session.setAttribute("examId", examId);
                
                // Redirect to exam page with URL encoding
                String encodedCourseName = java.net.URLEncoder.encode(coursename, "UTF-8");
                response.sendRedirect("std-page.jsp?pgprt=1&coursename=" + encodedCourseName);
            } else {
                response.sendRedirect("std-page.jsp?pgprt=1&error=Failed to start exam");
            }
        }

    } else if ("submitted".equalsIgnoreCase(operation)) {
        try {
            String time = java.time.LocalTime.now().truncatedTo(java.time.temporal.ChronoUnit.MINUTES)
                          .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
            int size = Integer.parseInt(nz(request.getParameter("size"), "0"));
            if (session.getAttribute("examId") != null) {
                int eId    = Integer.parseInt(session.getAttribute("examId").toString());
                int tMarks = Integer.parseInt(nz(request.getParameter("totalmarks"), "0"));

                for (int i=0;i<size;i++){
                    String question = nz(request.getParameter("question"+i), "");
                    String ans      = nz(request.getParameter("ans"+i), "");
                    int qid         = Integer.parseInt(nz(request.getParameter("qid"+i), "0"));
                    pDAO.insertAnswer(eId, qid, question, ans);
                }

                pDAO.calculateResult(eId, tMarks, time, size);

                session.removeAttribute("examId");
                session.removeAttribute("examStarted");

                response.sendRedirect("std-page.jsp?pgprt=1&eid="+eId+"&showresult=1");
            } else {
                response.sendRedirect("std-page.jsp");
            }
        } catch(Exception e){
            session.setAttribute("error","Error submitting exam: "+e.getMessage());
            response.sendRedirect("std-page.jsp");
        }
        
    } else if ("checkCourseStatus".equalsIgnoreCase(operation)) {
        // Handle AJAX request to check if a course is active
        String courseNameToCheck = nz(request.getParameter("courseName"), "");
        if (!courseNameToCheck.isEmpty()) {
            boolean isActive = pDAO.isCourseActive(courseNameToCheck);
            response.setContentType("text/plain");
            response.getWriter().write(String.valueOf(isActive));
            return;
        }
    
    
    } else {
        session.setAttribute("error", "Invalid operation for exams");
        response.sendRedirect("std-page.jsp");
    }
    /* =========================
       CHECK USERNAME
       ========================= */
    } else if ("check_username".equalsIgnoreCase(pageParam)) {
        String username = request.getParameter("username");
        boolean exists = pDAO.checkUserExists(username);
        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
        return;
        
    /* =========================
       ADMIN RESULTS
       ========================= */
    } else if ("admin-results".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("delete_result".equalsIgnoreCase(operation)) {
            String submittedToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");

            if (sessionToken == null || !sessionToken.equals(submittedToken)) {
                session.setAttribute("error", "Invalid request. Please try again.");
                response.sendRedirect("adm-page.jsp?pgprt=5");
                return;
            }

            try {
                int examId = Integer.parseInt(nz(request.getParameter("examId"), "0"));
                if (examId > 0) {
                    boolean success = pDAO.deleteExamResult(examId);
                    if (success) {
                        session.setAttribute("message", "Exam result deleted successfully.");
                    } else {
                        session.setAttribute("error", "Failed to delete exam result.");
                    }
                } else {
                    session.setAttribute("error", "Invalid Exam ID.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid Exam ID format.");
            }
            response.sendRedirect("adm-page.jsp?pgprt=5");
        }
    
        
    /* =========================
       LOGOUT
       ========================= */
    } else if ("logout".equalsIgnoreCase(pageParam)) {
        // Invalidate session immediately then forward to a transition page so the client loader can be visible
        session.invalidate();
        request.setAttribute("targetUrl", "login.jsp");
        request.setAttribute("message", "Securely logging you out...");
        request.setAttribute("delayMs", Integer.valueOf(3000));
        request.getRequestDispatcher("transition.jsp").forward(request, response);
        return;
        
    } else {
        // Handle case when page parameter is not recognized
        session.setAttribute("error", "Invalid page parameter: " + pageParam);
        response.sendRedirect("login.jsp");
    }

} catch(Exception e){
    session.setAttribute("error","An unexpected error occurred: "+e.getMessage());
    response.sendRedirect("error.jsp");
}
%>