<%@ page import="java.lang.*" %>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.time.LocalTime"%>
<%@page import="myPackage.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<%
try {
    String pageParam = request.getParameter("page");
    if (pageParam == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Login Handling
    if ("login".equals(pageParam)) {
        String userName = request.getParameter("username");
        String userPass = request.getParameter("password");

        if (pDAO.loginValidate(userName, userPass)) {
            session.setAttribute("userStatus", "1");
            session.setAttribute("userId", pDAO.getUserId(userName));
            response.sendRedirect("dashboard.jsp");
        } else {
            session.setAttribute("error", "Invalid username or password");
            response.sendRedirect("login.jsp");
        }

    // Registration Handling
    } else if ("register".equals(pageParam)) {
        String fName = request.getParameter("fname");
        String lName = request.getParameter("lname");
        String uName = request.getParameter("uname");  
        String email = request.getParameter("email");
        String pass = request.getParameter("pass");
        String contactNo = request.getParameter("contactno");
        String city = request.getParameter("city");
        String address = request.getParameter("address");
        
        // Hash the password using BCrypt
        String hashedPass = PasswordUtils.bcryptHashPassword(pass);
        
        // Generate student ID
        String studentId = "STD-" + UUID.randomUUID().toString().substring(0, 8);

        // Proceed with registration
        pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, studentId);
        session.setAttribute("message", "Registration successful! Please login");
        response.sendRedirect("login.jsp");

    // Profile Update Handling
    } else if ("profile".equals(pageParam)) {
        if (session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int uid = Integer.parseInt(session.getAttribute("userId").toString());
        String fName = request.getParameter("fname");
        String lName = request.getParameter("lname");
        String uName = request.getParameter("uname");
        String email = request.getParameter("email");
        String pass = request.getParameter("pass");
        String contactNo = request.getParameter("contactno");
        String city = request.getParameter("city");
        String address = request.getParameter("address");
        String uType = request.getParameter("utype");
        
        pDAO.updateStudent(uid, fName, lName, uName, email, pass, contactNo, city, address, uType);
        session.setAttribute("message", "Profile updated successfully");
        response.sendRedirect("dashboard.jsp");

    // Courses Management
    } else if ("courses".equals(pageParam)) {
        String operation = request.getParameter("operation");
        if (operation == null) {
            response.sendRedirect("adm-page.jsp?pgprt=2");
            return;
        }
        
        if ("addnew".equals(operation)) {
            String courseName = request.getParameter("coursename");
            int totalMarks = Integer.parseInt(request.getParameter("totalmarks"));
            String time = request.getParameter("time");
            String examDate = request.getParameter("examdate");
            
            pDAO.addNewCourse(courseName, totalMarks, time, examDate);
            session.setAttribute("message", "Course added successfully");
            response.sendRedirect("adm-page.jsp?pgprt=2");
        } else if ("del".equals(operation)) {
            String cname = request.getParameter("cname");
            if (cname != null) {
                pDAO.delCourse(cname);
                session.setAttribute("message", "Course deleted successfully");
            }
            response.sendRedirect("adm-page.jsp?pgprt=2");
        }

    // Accounts Management
    } else if ("accounts".equals(pageParam)) {
        String operation = request.getParameter("operation");
        String uidParam = request.getParameter("uid");
        
        if ("del".equals(operation) && uidParam != null) {
            int userId = Integer.parseInt(uidParam);
            pDAO.delStudent(userId);
            session.setAttribute("message", "Account deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=1");

    // Lecturers Accounts Management
    } else if ("Lecturers_accounts".equals(pageParam)) {
        String operation = request.getParameter("operation");
        String uidParam = request.getParameter("uid");
        
        if ("del".equals(operation) && uidParam != null) {
            int userId = Integer.parseInt(uidParam);
            pDAO.deleteLecturer(userId);
            session.setAttribute("message", "Lecturer deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=6");

    // Questions Management
    } else if ("questions".equals(pageParam)) {
        String operation = request.getParameter("operation");
        if (operation == null) {
            response.sendRedirect("adm-page.jsp?pgprt=3");
            return;
        }

        if ("del".equals(operation)) {
            String questionIdParam = request.getParameter("qid");
            if (questionIdParam != null && !questionIdParam.isEmpty()) {
                int questionId = Integer.parseInt(questionIdParam);
                pDAO.deleteQuestion(questionId);
                session.setAttribute("message", "Question deleted successfully");
            }
            response.sendRedirect("adm-page.jsp?pgprt=3");
        } else if ("edit".equals(operation)) {
            String questionIdParam = request.getParameter("qid");
            if (questionIdParam != null && !questionIdParam.isEmpty()) {
                int questionId = Integer.parseInt(questionIdParam);
                Questions question = pDAO.getQuestionById(questionId);
                if (question != null) {
                    question.setQuestion(request.getParameter("question"));
                    question.setOpt1(request.getParameter("opt1"));
                    question.setOpt2(request.getParameter("opt2"));
                    question.setOpt3(request.getParameter("opt3"));
                    question.setOpt4(request.getParameter("opt4"));
                    question.setCorrect(request.getParameter("correct"));
                    question.setCourseName(request.getParameter("coursename"));
                    
                    pDAO.updateQuestion(question);
                    session.setAttribute("message", "Question updated successfully");
                }
            }
            response.sendRedirect("adm-page.jsp?pgprt=3");
        } else if ("addnew".equals(operation)) {
            String questionText = request.getParameter("question");
            String opt1 = request.getParameter("opt1");
            String opt2 = request.getParameter("opt2");
            String opt3 = request.getParameter("opt3");
            String opt4 = request.getParameter("opt4");
            String correctAnswer = request.getParameter("correct");
            String courseName = request.getParameter("coursename");
            String questionType = request.getParameter("questionType");

            pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType);
            session.setAttribute("message", "Question added successfully");
            response.sendRedirect("adm-page.jsp?pgprt=3");
        }

    // Exams Handling
    } else if ("exams".equals(pageParam)) {
        String operation = request.getParameter("operation");
        if (operation == null) {
            response.sendRedirect("std-page.jsp");
            return;
        }
        
        if ("startexam".equals(operation)) {
            String cName = request.getParameter("coursename");
            if (session.getAttribute("userId") != null && cName != null) {
                int userId = Integer.parseInt(session.getAttribute("userId").toString());
                int examId = pDAO.startExam(cName, userId);
                session.setAttribute("examId", examId);
                session.setAttribute("examStarted", "1");
                response.sendRedirect("std-page.jsp?pgprt=1&coursename="+cName);
            } else {
                response.sendRedirect("std-page.jsp");
            }
        } else if ("submitted".equals(operation)) {
            try {
                String time = LocalTime.now().toString();
                int size = Integer.parseInt(request.getParameter("size"));
                if (session.getAttribute("examId") != null) {
                    int eId = Integer.parseInt(session.getAttribute("examId").toString());
                    int tMarks = Integer.parseInt(request.getParameter("totalmarks"));
                    session.removeAttribute("examId");
                    session.removeAttribute("examStarted");
                    
                    for(int i=0; i<size; i++) {
                        String question = request.getParameter("question"+i);
                        String ans = request.getParameter("ans"+i);
                        int qid = Integer.parseInt(request.getParameter("qid"+i));
                        pDAO.insertAnswer(eId, qid, question, ans);
                    }
                    
                    pDAO.calculateResult(eId, tMarks, time, size);
                    response.sendRedirect("std-page.jsp?pgprt=1&eid="+eId+"&showresult=1");
                }
            } catch(Exception e) {
                session.setAttribute("error", "Error submitting exam: " + e.getMessage());
                response.sendRedirect("std-page.jsp");
            }
        }

    // Logout Handling
    } else if ("logout".equals(pageParam)) {
        session.invalidate();
        response.sendRedirect("login.jsp");

    // Default case for unknown page parameters
    } else {
        response.sendRedirect("login.jsp");
    }
} catch (Exception e) {
    session.setAttribute("error", "An error occurred: " + e.getMessage());
    response.sendRedirect("error.jsp"); // You should create an error.jsp page
}
%>
