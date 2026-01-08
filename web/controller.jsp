<%@ page import="java.lang.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>

<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<%!
/** Returns value if non-null/non-empty, otherwise fallback. */
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
        String userName = request.getParameter("username");   // currently username (could be student ID)
        String userPass = request.getParameter("password");

        if (pDAO.loginValidate(userName, userPass)) {
            session.setAttribute("userStatus", "1");
            session.setAttribute("userId", pDAO.getUserId(userName)); // DAO has getUserId(username)
            response.sendRedirect("dashboard.jsp");
        } else {
            session.setAttribute("error", "Invalid username or password");
            response.sendRedirect("login.jsp");
        }

    /* =========================
       REGISTER
       ========================= */
/* =========================
   REGISTER
   ========================= */
} else if ("register".equalsIgnoreCase(pageParam)) {
    String fName     = request.getParameter("fname");
    String lName     = request.getParameter("lname");
    String uName     = request.getParameter("uname");
    String email     = request.getParameter("email");
    String pass      = request.getParameter("pass");
    String contactNo = request.getParameter("contactno");
    String city      = request.getParameter("city");
    String address   = request.getParameter("address");

    // Hash the password
    String hashedPass = PasswordUtils.bcryptHashPassword(pass);

    // Determine user type based on email
    String staffOrStudentId;
    String emailLower = email.toLowerCase();
    if (emailLower.endsWith("@live.mut.ac.za") || 
        emailLower.endsWith("@mut.ac.za") || 
        emailLower.endsWith("@company.com") // add other staff/professional domains here
    ) {
        staffOrStudentId = "staff";  // staff user
    } else {
        staffOrStudentId = "student"; // student user
    }

    // Persist user
    pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, staffOrStudentId);

    session.setAttribute("message", "Registration successful! Please login");
    response.sendRedirect("login.jsp");

        /* =========================
       PROFILE UPDATE
       ========================= */
    } else if ("profile".equalsIgnoreCase(pageParam)) {
        if (session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int uid = Integer.parseInt(session.getAttribute("userId").toString());

        // Pull current user to avoid nulling fields
        User current = pDAO.getUserDetails(String.valueOf(uid));
        if (current == null) {
            session.setAttribute("error", "User not found.");
            response.sendRedirect("login.jsp");
            return;
        }

        // Incoming (may be null/empty if not sent by form) — we IGNORE uname & pass on purpose
        String fName   = request.getParameter("fname");
        String lName   = request.getParameter("lname");
        /* String uName = request.getParameter("uname");  // <- ignored */
        /* String passIn = request.getParameter("pass");  // <- ignored */
        String email   = request.getParameter("email");
        String contact = request.getParameter("contactno");
        String city    = request.getParameter("city");
        String address = request.getParameter("address");
        String uType   = request.getParameter("utype");

        // Merge safely with existing values
        String newFName   = nz(fName,   current.getFirstName());
        String newLName   = nz(lName,   current.getLastName());
        String newEmail   = nz(email,   current.getEmail());
        String newContact = nz(contact, current.getContact());
        String newCity    = nz(city,    current.getCity());
        String newAddress = nz(address, current.getAddress());
        String newType    = nz(uType,   current.getType());

        // HARD LOCK: keep existing login credentials (username & password) unchanged
        String newUName = current.getUserName();
        String newPass  = current.getPassword();

        try {
            int rows = pDAO.updateStudent(
                uid, newFName, newLName, newUName, newEmail,
                newPass, newContact, newCity, newAddress, newType
            );

            if (rows == 1) {
                session.setAttribute("message", "Profile updated successfully.");
                response.sendRedirect("std-page.jsp?pgprt=0");
            } else {
                session.setAttribute("error", "No changes were saved.");
                response.sendRedirect("std-page.jsp?pgprt=0&pedt=1");
            }
        } catch (Exception ex) {
            session.setAttribute("error", "Update failed: " + ex.getMessage());
            response.sendRedirect("std-page.jsp?pgprt=0&pedt=1");
        }

    /* =========================
       COURSES
       ========================= */
        } else if ("courses".equalsIgnoreCase(pageParam)) {
            String operation = request.getParameter("operation");
            if (operation == null) {
                response.sendRedirect("adm-page.jsp?pgprt=2");
                return;
            }

            if ("addnew".equalsIgnoreCase(operation)) {
                String courseName = request.getParameter("coursename");
                int totalMarks    = Integer.parseInt(request.getParameter("totalmarks"));
                String time       = request.getParameter("time");
                String examDate   = request.getParameter("examdate");

                boolean success = pDAO.addNewCourse(courseName, totalMarks, time, examDate);
                if (success) {
                    session.setAttribute("message", "Course added successfully");
                } else {
                    session.setAttribute("message", "Error: Course already exists or couldn't be added");
                }
                response.sendRedirect("adm-page.jsp?pgprt=2");

            } else if ("del".equalsIgnoreCase(operation)) {
                String cname = request.getParameter("cname");
                if (cname != null) {
                    pDAO.delCourse(cname);
                    session.setAttribute("message", "Course deleted successfully");
                }
                response.sendRedirect("adm-page.jsp?pgprt=2");
            }
    /* =========================
       ACCOUNTS (STUDENTS)
       ========================= */
    } else if ("accounts".equalsIgnoreCase(pageParam)) {
        String operation = request.getParameter("operation");
        String uidParam  = request.getParameter("uid");

        if ("del".equalsIgnoreCase(operation) && uidParam != null) {
            int userId = Integer.parseInt(uidParam);
            pDAO.delStudent(userId);
            session.setAttribute("message", "Account deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=1");

    /* =========================
       LECTURERS ACCOUNTS
       ========================= */
    } else if ("Lecturers_accounts".equalsIgnoreCase(pageParam)) {
        String operation = request.getParameter("operation");
        String uidParam  = request.getParameter("uid");

        if ("del".equalsIgnoreCase(operation) && uidParam != null) {
            int userId = Integer.parseInt(uidParam);
            pDAO.deleteLecturer(userId);
            session.setAttribute("message", "Lecturer deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=6");

/* =========================
   QUESTIONS
   ========================= */
} else if ("questions".equalsIgnoreCase(pageParam)) {
    String operation = request.getParameter("operation");
    if (operation == null) {
        response.sendRedirect("adm-page.jsp?pgprt=3");
        return;
    }

    if ("del".equalsIgnoreCase(operation)) {
        String questionIdParam = request.getParameter("qid");
        if (questionIdParam != null && !questionIdParam.isEmpty()) {
            int questionId = Integer.parseInt(questionIdParam);
            pDAO.deleteQuestion(questionId);
            session.setAttribute("message", "Question deleted successfully");
        }
        response.sendRedirect("adm-page.jsp?pgprt=3");

    } else if ("edit".equalsIgnoreCase(operation)) {
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

    } else if ("addnew".equalsIgnoreCase(operation)) {
        String questionText  = request.getParameter("question");
        String opt1          = request.getParameter("opt1");
        String opt2          = request.getParameter("opt2");
        String opt3          = request.getParameter("opt3");
        String opt4          = request.getParameter("opt4");
        String correctAnswer = request.getParameter("correct");
        String courseName    = request.getParameter("coursename");
        String questionType  = request.getParameter("questionType");

        // Handle Multiple Select questions - get the correct answers from the hidden field
        if ("MultipleSelect".equalsIgnoreCase(questionType)) {
            String correctMultiple = request.getParameter("correctMultiple");
            if (correctMultiple != null && !correctMultiple.trim().isEmpty()) {
                correctAnswer = correctMultiple; // Use the pipe-separated correct answers
            }
        }

        pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType);
        session.setAttribute("message", "Question added successfully");
        response.sendRedirect("adm-page.jsp?pgprt=3");
    }


/* =========================
   EXAMS
   ========================= */
} else if ("exams".equalsIgnoreCase(pageParam)) {
    String operation = request.getParameter("operation");
    if (operation == null) {
        response.sendRedirect("std-page.jsp");
        return;
    }

    if ("startexam".equalsIgnoreCase(operation)) {
        String cName = request.getParameter("coursename");
        if (session.getAttribute("userId") != null && cName != null) {
            int userId = Integer.parseInt(session.getAttribute("userId").toString());
            int examId = pDAO.startExam(cName, userId);
            session.setAttribute("examId", examId);
            session.setAttribute("examStarted", "1");
            response.sendRedirect("std-page.jsp?pgprt=1&coursename=" + cName);
        } else {
            response.sendRedirect("std-page.jsp");
        }

    } else if ("submitted".equalsIgnoreCase(operation)) {
        try {
            // HH:mm (no seconds, no nanos)
            String time = LocalTime.now()
                    .truncatedTo(ChronoUnit.MINUTES)
                    .format(DateTimeFormatter.ofPattern("HH:mm"));

            int size = Integer.parseInt(request.getParameter("size"));
            if (session.getAttribute("examId") != null) {
                int eId    = Integer.parseInt(session.getAttribute("examId").toString());
                int tMarks = Integer.parseInt(request.getParameter("totalmarks"));

                // Clear exam session flags
                session.removeAttribute("examId");
                session.removeAttribute("examStarted");

                // Record answers
                for (int i = 0; i < size; i++) {
                    String question = request.getParameter("question" + i);
                    String ans      = request.getParameter("ans" + i);
                    int qid         = Integer.parseInt(request.getParameter("qid" + i));
                    String qtype    = request.getParameter("qtype" + i); // Get question type
                    
                    // For multi-select questions, ans will contain pipe-separated values
                    pDAO.insertAnswer(eId, qid, question, ans);
                }

                // Calculate and finalize
                pDAO.calculateResult(eId, tMarks, time, size);
                response.sendRedirect("std-page.jsp?pgprt=1&eid=" + eId + "&showresult=1");
            } else {
                response.sendRedirect("std-page.jsp");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Error submitting exam: " + e.getMessage());
            response.sendRedirect("std-page.jsp");
        }
    }

    /* =========================
       LOGOUT
       ========================= */
    } else if ("logout".equalsIgnoreCase(pageParam)) {
        session.invalidate();
        response.sendRedirect("login.jsp");

    /* =========================
       DEFAULT
       ========================= */
    } else {
        response.sendRedirect("login.jsp");
    }

} catch (Exception e) {
    session.setAttribute("error", "An error occurred: " + e.getMessage());
    response.sendRedirect("error.jsp");
}
%>
