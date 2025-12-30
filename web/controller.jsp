<%@ page import="java.lang.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

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
        String staffOrStudentId = "STD-" + UUID.randomUUID().toString().substring(0,8);

        pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, "");

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
                pDAO.deleteCourseCascade(cname);
                session.setAttribute("message","Course deleted successfully");
            }
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
            pDAO.deleteUserCascade(userId);
            session.setAttribute("message","Account deleted successfully");
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
            pDAO.deleteUserCascade(userId);
            session.setAttribute("message","Lecturer deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=6");

    /* =========================
       RESULTS
       ========================= */
    } else if ("results".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        String eidParam  = nz(request.getParameter("eid"), "");
        if ("del".equalsIgnoreCase(operation) && !eidParam.isEmpty()) {
            int examId = Integer.parseInt(eidParam);
            pDAO.deleteExamCascade(examId);
            session.setAttribute("message","Result deleted successfully");
        } else if ("edit".equalsIgnoreCase(operation) && !eidParam.isEmpty()) {
            int examId = Integer.parseInt(eidParam);
            int obtMarks = Integer.parseInt(nz(request.getParameter("obtMarks"), "0"));
            int totalMarks = Integer.parseInt(nz(request.getParameter("totalMarks"), "0"));
            pDAO.updateExamResult(examId, obtMarks, totalMarks);
            session.setAttribute("message","Result updated successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=5");

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
        }

    /* =========================
       EXAMS
       ========================= */
    } else if ("exams".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("startexam".equalsIgnoreCase(operation)) {
            String cName = nz(request.getParameter("coursename"), "");
            if (session.getAttribute("userId") != null && !cName.isEmpty()) {
                int userId = Integer.parseInt(session.getAttribute("userId").toString());
                int examId = pDAO.startExam(cName, userId);
                session.setAttribute("examId", examId);
                session.setAttribute("examStarted","1");
                response.sendRedirect("std-page.jsp?pgprt=1&coursename="+cName);
            } else {
                response.sendRedirect("std-page.jsp");
            }

        } else if ("submitted".equalsIgnoreCase(operation)) {
            try {
                String time = LocalTime.now().truncatedTo(ChronoUnit.MINUTES)
                              .format(DateTimeFormatter.ofPattern("HH:mm"));
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
        }



} catch(Exception e){
    session.setAttribute("error","An unexpected error occurred: "+e.getMessage());
    response.sendRedirect("error.jsp");
}
%>