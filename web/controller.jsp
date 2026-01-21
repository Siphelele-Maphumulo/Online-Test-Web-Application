<%@ page import="java.lang.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.logging.Level" %>
<%@ page import="java.util.logging.Logger" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="org.apache.pdfbox.pdmodel.PDDocument" %>
<%@ page import="org.apache.pdfbox.text.PDFTextStripper" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>

<%
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
final Logger LOGGER = Logger.getLogger("controller.jsp");

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
       DUPLICATE CHECKING ENDPOINTS
       ========================= */
    if ("check_username".equalsIgnoreCase(pageParam)) {
        String username = request.getParameter("username");
        boolean exists = pDAO.checkUsernameExists(username);
        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
        return;

    } else if ("check_email".equalsIgnoreCase(pageParam)) {
        String email = request.getParameter("email");
        boolean exists = pDAO.checkEmailExists(email);
        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
        return;

    } else if ("check_contact".equalsIgnoreCase(pageParam)) {
        String contactNo = request.getParameter("contactno");
        boolean exists = pDAO.checkContactNoExists(contactNo);
        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
        return;

    } else if ("check_staff_email".equalsIgnoreCase(pageParam)) {
        String email = request.getParameter("email");
        boolean exists = pDAO.checkStaffEmailExists(email);
        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
        return;

    } else if ("check_user_exists".equalsIgnoreCase(pageParam)) {
        String username = request.getParameter("username");
        boolean exists = pDAO.checkUserExists(username);
        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
        return;

    /* =========================
       LOGIN
       ========================= */
    } else if ("login".equalsIgnoreCase(pageParam)) {
        String userName = nz(request.getParameter("username"), "");
        String userPass = nz(request.getParameter("password"), "");

        if (pDAO.loginValidate(userName, userPass)) {
            session.setAttribute("success", "Welcome back!");
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
   REGISTER (WITH ENHANCED VALIDATION)
   ========================= */
} else if ("register".equalsIgnoreCase(pageParam)) {
    
    // Use character encoding for proper parameter handling
    request.setCharacterEncoding("UTF-8");
    
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
    
    // Store all form data in request attributes for repopulation
    request.setAttribute("fname", fName);
    request.setAttribute("lname", lName);
    request.setAttribute("uname", uName);
    request.setAttribute("email", email);
    request.setAttribute("contactno", contactNo);
    request.setAttribute("city", city);
    request.setAttribute("address", address);

    // Validate required fields
    if (fName.isEmpty() || lName.isEmpty() || uName.isEmpty() || email.isEmpty() || pass.isEmpty()) {
        session.setAttribute("error", "Please fill in all required fields");
        session.setAttribute("errorField", "required");
        request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
        return;
    }

    // Validate ID number format (8 digits)
    if (!uName.matches("\\d{8}")) {
        session.setAttribute("error", "ID number must be exactly 8 digits");
        session.setAttribute("errorField", "uname");
        // Clear only the ID field
        request.setAttribute("uname", "");
        request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
        return;
    }

    // Check for duplicates in ORDER: username → contact → email
    // 1. Check username first
    if (pDAO.checkUsernameExists(uName)) {
        session.setAttribute("error", "This ID number is already registered");
        session.setAttribute("errorField", "uname");
        // Clear only the ID field
        request.setAttribute("uname", "");
        request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
        return;
    }

    // 2. Check contact number second
    if (contactNo != null && !contactNo.isEmpty()) {
        if (pDAO.checkContactNoExists(contactNo)) {
            session.setAttribute("error", "This contact number is already registered");
            session.setAttribute("errorField", "contactno");
            // Clear only the contact field
            request.setAttribute("contactno", "");
            request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
            return;
        }
    }

    // 3. Check email last
    if (pDAO.checkEmailExists(email)) {
        session.setAttribute("error", "This email is already registered");
        session.setAttribute("errorField", "email");
        // Clear only the email field
        request.setAttribute("email", "");
        request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
        return;
    }

    try {
        // Hash password
        String hashedPass = PasswordUtils.bcryptHashPassword(pass);
        
        // Call the ORIGINAL addNewUser method which is void
        pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, userType);

        // Clear any previous error fields
        session.removeAttribute("errorField");
        
        // Set success message - FIXED: Use session attribute
        session.setAttribute("success", "Registration successful! You can now login.");
        
        // Determine redirect based on user type
        boolean isAdminOrLecturer = "admin".equalsIgnoreCase(userType) || 
                                   "lecture".equalsIgnoreCase(userType) || 
                                   "lecturer".equalsIgnoreCase(userType);
        
        if (isAdminOrLecturer || "account".equalsIgnoreCase(fromPage)) {
            // For admin/lecturer registrations
            session.setAttribute("message", "User added successfully!");
            response.sendRedirect("accounts.jsp");
        } else {
            // Store success message in session ONLY
            session.setAttribute("success", "Registration successful! Please login.");

            // Redirect cleanly (NO query params)
            response.sendRedirect("login.jsp");

        }
        
    } catch (RuntimeException ex) {
        // The addNewUser method throws RuntimeException on SQL failure
        
        // Check if duplicates were created despite checks
        boolean usernameCheck = pDAO.checkUsernameExists(uName);
        boolean emailCheck = pDAO.checkEmailExists(email);
        boolean contactCheck = contactNo != null && !contactNo.isEmpty() && pDAO.checkContactNoExists(contactNo);
        
        if (usernameCheck) {
            session.setAttribute("error", "This ID number is already registered");
            session.setAttribute("errorField", "uname");
            request.setAttribute("uname", "");
        } else if (contactCheck) {
            session.setAttribute("error", "This contact number is already registered");
            session.setAttribute("errorField", "contactno");
            request.setAttribute("contactno", "");
        } else if (emailCheck) {
            session.setAttribute("error", "This email is already registered");
            session.setAttribute("errorField", "email");
            request.setAttribute("email", "");
        } else {
            // Get the root cause
            Throwable cause = ex.getCause();
            String errorMsg = "Registration failed. ";
            if (cause != null && cause.getMessage() != null) {
                if (cause.getMessage().contains("Duplicate")) {
                    errorMsg += "The information may already be registered.";
                } else {
                    errorMsg += "Database error: " + cause.getMessage();
                }
            } else {
                errorMsg += "Please check all fields and try again.";
            }
            session.setAttribute("error", errorMsg);
            session.setAttribute("errorField", "general");
        }
        
        // Forward to signup page with all form data preserved
        request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
        
    } catch (Exception e) {
        // Catch any other exceptions (like password hashing errors)
        
        session.setAttribute("error", "Registration failed: " + e.getMessage());
        session.setAttribute("errorField", "general");
        
        // Forward to signup page with all form data preserved
        request.getRequestDispatcher("signup.jsp?user_type=" + userType).forward(request, response);
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

        if ("account".equalsIgnoreCase(fromPage) || "admin".equalsIgnoreCase(userType) || "lecture".equalsIgnoreCase(userType) || "lecturer".equalsIgnoreCase(userType)) {
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

        if ("lecture".equalsIgnoreCase(current.getType()) || "lecturer".equalsIgnoreCase(current.getType())) {
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
            
            // Check if contact number already exists for another user
            if (contact != null && !contact.trim().isEmpty()) {
                // We need to check if contact exists for another user
                // We'll create a method to check this, but for now we'll skip
            }

            if (password == null || password.trim().isEmpty()) {
                password = existingUser.getPassword();
            } else {
                password = BCrypt.hashpw(password, BCrypt.gensalt());
            }

            if (!"lecture".equalsIgnoreCase(userType) && !"lecturer".equalsIgnoreCase(userType)) {
                courseName = "";
            }

            User updatedUser = new User(userId, firstName, lastName, userName, email, password, userType, contact, city, address, courseName);

            boolean success = pDAO.updateUser(updatedUser);
            if (success) {
                session.setAttribute("message", "User updated successfully!");
                response.sendRedirect("lecture".equalsIgnoreCase(userType) || "lecturer".equalsIgnoreCase(userType) ? "adm-page.jsp?pgprt=6" : "adm-page.jsp?pgprt=1");
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
        
        // Handle PDF upload operation separately
        if ("pdf_upload".equalsIgnoreCase(request.getParameter("action"))) {
            // Simulate PDF processing
            String courseName = request.getParameter("courseName");
            
            // In a real implementation, we would extract questions from the PDF file
            // For simulation, we'll return sample questions
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            // Sample questions JSON
            String jsonResponse = "{\"success\": true, \"message\": \"Questions extracted successfully (simulation)\", \"count\": 3, \"questions\":[{" +
                "{\"question\": \"What is the capital of France?\", \"type\": \"MCQ\", \"options\": [\"Paris\", \"London\", \"Berlin\", \"Madrid\"], \"correct\": \"Paris\", \"courseName\": \"" + courseName + "\"}," +
                "{\"question\": \"Which planet is known as the Red Planet?\", \"type\": \"MCQ\", \"options\": [\"Earth\", \"Venus\", \"Mars\", \"Jupiter\"], \"correct\": \"Mars\", \"courseName\": \"" + courseName + "\"}," +
                "{\"question\": \"What is 2 + 2?\", \"type\": \"MCQ\", \"options\": [\"3\", \"4\", \"5\", \"6\"], \"correct\": \"4\", \"courseName\": \"" + courseName + "\"}" +
            "]}";
            
            response.getWriter().write(jsonResponse);
            return;
        }
        
        if ("del".equalsIgnoreCase(operation)) {
            String qid = nz(request.getParameter("qid"), "");
            if (!qid.isEmpty()) pDAO.deleteQuestion(Integer.parseInt(qid));
            session.setAttribute("message","Question deleted successfully");
            String courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("adm-page.jsp?coursename=" + courseName + "&pgprt=4");
            } else {
                response.sendRedirect("adm-page.jsp?pgprt=3");
            }
        } else if ("bulk_delete".equalsIgnoreCase(operation)) {
            String[] questionIds = request.getParameterValues("questionIds");
            String courseName = nz(request.getParameter("coursename"), "");
            
            if (questionIds != null && questionIds.length > 0) {
                for (String qid : questionIds) {
                    try {
                        int id = Integer.parseInt(qid);
                        pDAO.deleteQuestion(id);
                    } catch (NumberFormatException e) {
                        // Skip invalid IDs
                    }
                }
                session.setAttribute("message", questionIds.length + " question(s) deleted successfully!");
            } else {
                session.setAttribute("error", "No questions selected for deletion.");
            }
            
            if (!courseName.isEmpty()) {
                response.sendRedirect("adm-page.jsp?coursename=" + courseName + "&pgprt=4");
            } else {
                response.sendRedirect("adm-page.jsp?pgprt=3");
            }
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
                    String courseName = nz(request.getParameter("coursename"), "");
                    question.setCourseName(courseName);
                    String questionType = nz(request.getParameter("questionType"), "MCQ");
                    question.setQuestionType(questionType);
                    pDAO.updateQuestion(question);
                    session.setAttribute("message","Question updated successfully");
                    
                    // Redirect to the same page with the course selected
                    if (!courseName.isEmpty()) {
                        response.sendRedirect("adm-page.jsp?coursename=" + courseName + "&pgprt=4");
                    } else {
                        response.sendRedirect("adm-page.jsp?pgprt=3");
                    }
                    return;
                }
            }
            String courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("adm-page.jsp?coursename=" + courseName + "&pgprt=4");
            } else {
                response.sendRedirect("adm-page.jsp?pgprt=3");
            }

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
            courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("adm-page.jsp?coursename=" + courseName + "&pgprt=4");
            } else {
                response.sendRedirect("adm-page.jsp?pgprt=3");
            }
        } else {
            session.setAttribute("error", "Invalid operation for questions");
            String courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("adm-page.jsp?coursename=" + courseName + "&pgprt=4");
            } else {
                response.sendRedirect("adm-page.jsp?pgprt=3");
            }
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
        // Handle both single and bulk delete operations
        String[] examIds = request.getParameterValues("eids"); // For bulk delete
        String singleExamId = request.getParameter("eid");  // For single delete
        
        if (examIds != null && examIds.length > 0) {
            // Bulk delete
            pDAO.deleteExamResults(examIds);
            session.setAttribute("message", "Selected exam results deleted successfully!");
        } else if (singleExamId != null && !singleExamId.isEmpty()) {
            // Single delete
            try {
                int examId = Integer.parseInt(singleExamId);
                boolean success = pDAO.deleteExamResult(examId);
                if (success) {
                    session.setAttribute("message", "Exam result deleted successfully!");
                } else {
                    session.setAttribute("error", "Failed to delete exam result.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid Exam ID format.");
            }
        } else {
            session.setAttribute("error", "No exam result selected for deletion.");
        }
        response.sendRedirect("adm-page.jsp?pgprt=5");
    } else {
        session.setAttribute("error", "Invalid operation for results");
        response.sendRedirect("adm-page.jsp?pgprt=5");
    }

/* =========================
   EXAMS - START EXAM
   ========================= */
} else if ("exams".equalsIgnoreCase(pageParam)) {
    String operation = nz(request.getParameter("operation"), "");
    
    if ("startexam".equalsIgnoreCase(operation)) {
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
            // REGISTER EXAM START
            try {
                boolean registered = pDAO.registerExamStart(userId, examId, coursename);
                
                // Optional: You can log to application log if needed
                // application.log("Exam register entry created for student " + userId + " for exam " + examId);
                
            } catch (SQLException e) {
                // Log error to application log
                application.log("Error registering exam start: " + e.getMessage(), e);
                // Continue even if registration fails - don't block exam start
            }
            
            // Set session attributes
            session.setAttribute("examStarted", "1");
            session.setAttribute("examId", examId);
            session.setAttribute("examCourse", coursename);
            
            // Redirect to exam page with URL encoding
            String encodedCourseName = java.net.URLEncoder.encode(coursename, "UTF-8");
            response.sendRedirect("std-page.jsp?pgprt=1&coursename=" + encodedCourseName);
        } else {
            response.sendRedirect("std-page.jsp?pgprt=1&error=Failed to start exam");
        }
        
    } else if ("submitted".equalsIgnoreCase(operation)) {
        try {
            String endTime = java.time.LocalTime.now().truncatedTo(java.time.temporal.ChronoUnit.MINUTES)
                           .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
            
            int size = Integer.parseInt(nz(request.getParameter("size"), "0"));
            if (session.getAttribute("examId") != null) {
                int eId    = Integer.parseInt(session.getAttribute("examId").toString());
                int tMarks = Integer.parseInt(nz(request.getParameter("totalmarks"), "0"));
                
                // Get student ID
                int userId = 0;
                Object userIdObj = session.getAttribute("userId");
                if (userIdObj != null) {
                    userId = Integer.parseInt(userIdObj.toString());
                }

                for (int i=0;i<size;i++){
                    String question = nz(request.getParameter("question"+i), "");
                    String ans      = nz(request.getParameter("ans"+i), "");
                    int qid         = Integer.parseInt(nz(request.getParameter("qid"+i), "0"));
                    pDAO.insertAnswer(eId, qid, question, ans);
                }

                pDAO.calculateResult(eId, tMarks, endTime, size);
                
                // REGISTER EXAM COMPLETION
                if (userId > 0) {
                    try {
                        boolean registered = pDAO.registerExamCompletion(userId, eId, endTime);
                        // Optional: Log completion
                        // application.log("Exam completion registered for student " + userId + " for exam " + eId);
                    } catch (SQLException e) {
                        // Log error to application log
                        application.log("Error registering exam completion: " + e.getMessage(), e);
                        // Continue even if registration fails
                    }
                }

                session.removeAttribute("examId");
                session.removeAttribute("examStarted");
                session.removeAttribute("examCourse");

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
       ADMIN RESULTS
       ========================= */
    } else if ("admin-results".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("bulk_delete".equalsIgnoreCase(operation)) {
            String submittedToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");
            if (sessionToken == null || !sessionToken.equals(submittedToken)) {
                session.setAttribute("error", "Invalid request. Please try again.");
                response.sendRedirect("adm-page.jsp?pgprt=5");
                return;
            }
            String[] examIds = request.getParameterValues("examIds");
            if (examIds != null && examIds.length > 0) {
                pDAO.deleteExamResults(examIds);
                session.setAttribute("message", "Selected exam results deleted successfully.");
            } else {
                session.setAttribute("error", "No exam results selected for deletion.");
            }
            response.sendRedirect("adm-page.jsp?pgprt=5");
        } else if ("delete_result".equalsIgnoreCase(operation)) {
            String submittedToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");

            if (sessionToken == null || !sessionToken.equals(submittedToken)) {
                session.setAttribute("error", "Invalid request. Please try again.");
                response.sendRedirect("adm-page.jsp?pgprt=5");
                return;
            }

            try {
                int examId = Integer.parseInt(nz(request.getParameter("eid"), "0"));
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
       EXAM REGISTER
       ========================= */
    } else if ("exam-register".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("bulk_delete".equalsIgnoreCase(operation)) {
            String[] registerIds = request.getParameterValues("registerIds");
            if (registerIds != null && registerIds.length > 0) {
                pDAO.deleteExamRegisterRecords(registerIds);
                session.setAttribute("message", "Selected exam register records deleted successfully.");
            } else {
                session.setAttribute("error", "No records selected for deletion.");
            }
            response.sendRedirect("adm-page.jsp?pgprt=7");
        }
    /* =========================
       CLASS REGISTER
       ========================= */
    } else if ("class-register".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("bulk_delete".equalsIgnoreCase(operation)) {
            String[] registerIds = request.getParameterValues("registerIds");
            if (registerIds != null && registerIds.length > 0) {
                pDAO.deleteDailyRegisterRecords(registerIds);
                session.setAttribute("message", "Selected class register records deleted successfully.");
            } else {
                session.setAttribute("error", "No records selected for deletion.");
            }
            response.sendRedirect("adm-page.jsp?pgprt=8");
        }

    /* =========================
       DAILY REGISTER (STUDENT)
       ========================= */
    } else if ("daily-register".equalsIgnoreCase(pageParam)) {
        String operation = nz(request.getParameter("operation"), "");
        if ("bulk_delete".equalsIgnoreCase(operation)) {
            String[] registerIds = request.getParameterValues("registerIds");
            if (registerIds != null && registerIds.length > 0) {
                pDAO.deleteDailyRegisterRecords(registerIds);
                session.setAttribute("message", "Selected attendance records deleted successfully.");
            } else {
                session.setAttribute("error", "No records selected for deletion.");
            }
            response.sendRedirect("std-page.jsp?pgprt=3");
        }
        
    /* =========================
       FORGOT PASSWORD
       ========================= */
    } else if ("forgot_password".equalsIgnoreCase(pageParam)) {
        String action = nz(request.getParameter("action"), "");
        
        if ("check_email".equalsIgnoreCase(action)) {
            // Check if email exists in users table
            String email = nz(request.getParameter("email"), "");
            response.setContentType("text/plain");
            
            LOGGER.info("Checking email: '" + email + "'");
            boolean exists = pDAO.checkEmailExists(email);
            LOGGER.info("Email exists: " + exists);
            
            if (exists) {
                response.getWriter().write("exists");
            } else {
                response.getWriter().write("not_exists");
            }
            response.getWriter().flush();
            return;
            
        } else if ("send_code".equalsIgnoreCase(action)) {
            // Generate and send verification code
            String email = nz(request.getParameter("email"), "");
            response.setContentType("text/plain");
            
            // Get user details
            User user = pDAO.getUserByEmail(email);
            if (user != null) {
                try {
                    // Generate 8-character code
                    String code = Email.generateRandomCode();
                    LOGGER.info("Generated code: " + code + " for email: " + email);
                    
                    // Store code in database
                    boolean stored = pDAO.storeVerificationCode(email, code, user.getType());
                    LOGGER.info("Code stored in database: " + stored);
                    
                    if (stored) {
                        // Send email with code
                        try {
                            Email.sendPasswordResetEmail(email, user.getFirstName(), code);
                            LOGGER.info("Email sent successfully to: " + email);
                            response.getWriter().write("success");
                        } catch (Exception emailEx) {
                            LOGGER.log(Level.SEVERE, "Failed to send email to: " + email, emailEx);
                            // Code is stored but email failed - still return success so user can check DB
                            response.getWriter().write("success");
                        }
                    } else {
                        response.getWriter().write("error");
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Error in send_code action", e);
                    response.getWriter().write("error");
                }
            } else {
                response.getWriter().write("error");
            }
            return;
            
        } else if ("verify_code".equalsIgnoreCase(action)) {
            // Verify the code entered by user
            String email = nz(request.getParameter("email"), "");
            String code = nz(request.getParameter("code"), "").toUpperCase();
            response.setContentType("text/plain");
            
            if (pDAO.verifyResetCode(email, code)) {
                response.getWriter().write("valid");
            } else {
                response.getWriter().write("invalid");
            }
            return;
            
        } else if ("resend_code".equalsIgnoreCase(action)) {
            // Resend verification code
            String email = nz(request.getParameter("email"), "");
            response.setContentType("text/plain");
            
            User user = pDAO.getUserByEmail(email);
            if (user != null) {
                try {
                    // Generate new code
                    String code = Email.generateRandomCode();
                    
                    // Store new code
                    boolean stored = pDAO.storeVerificationCode(email, code, user.getType());
                    
                    if (stored) {
                        // Send email
                        Email.sendPasswordResetEmail(email, user.getFirstName(), code);
                        response.getWriter().write("success");
                    } else {
                        response.getWriter().write("error");
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Error resending verification code", e);
                    response.getWriter().write("error");
                }
            } else {
                response.getWriter().write("error");
            }
            return;
            
        } else if ("reset_password".equalsIgnoreCase(action)) {
            // Reset the password after code verification
            String email = nz(request.getParameter("email"), "");
            String code = nz(request.getParameter("code"), "").toUpperCase();
            String password = nz(request.getParameter("password"), "");
            String confirmPassword = nz(request.getParameter("confirm_password"), "");
            response.setContentType("text/plain");
            
            // Validate passwords match
            if (!password.equals(confirmPassword)) {
                response.getWriter().write("password_mismatch");
                return;
            }
            
            // Validate password strength
            if (password.length() < 8) {
                response.getWriter().write("weak_password");
                return;
            }
            
            try {
                // Hash the new password
                String hashedPassword = PasswordUtils.bcryptHashPassword(password);
                
                // Update password in database
                boolean updated = pDAO.updatePasswordByEmail(email, hashedPassword, code);
                
                if (updated) {
                    response.getWriter().write("success");
                } else {
                    response.getWriter().write("error");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error resetting password", e);
                response.getWriter().write("error");
            }
            return;
        }
        
    /* =========================
       STUDENT SIGNUP WITH EMAIL VERIFICATION
       ========================= */
    } else if ("student_signup".equalsIgnoreCase(pageParam)) {
        String action = nz(request.getParameter("action"), "");
        
        if ("send_verification".equalsIgnoreCase(action)) {
            // Send verification code to student email
            String email = nz(request.getParameter("email"), "");
            String firstName = nz(request.getParameter("fname"), "");
            response.setContentType("text/plain");
            
            try {
                // Generate 8-character code
                String code = Email.generateRandomCode();
                LOGGER.info("Generated verification code for student signup: " + email);
                
                // Store code in database with user_type = 'student'
                boolean stored = pDAO.storeVerificationCode(email, code, "student");
                
                if (stored) {
                    // Send email with code
                    try {
                        Email.sendVerificationEmail(email, firstName, code);
                        LOGGER.info("Verification email sent successfully to: " + email);
                        response.getWriter().write("success");
                    } catch (Exception emailEx) {
                        LOGGER.log(Level.SEVERE, "Failed to send verification email", emailEx);
                        response.getWriter().write("email_error");
                    }
                } else {
                    response.getWriter().write("error");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error in send_verification action", e);
                response.getWriter().write("error");
            }
            return;
            
        } else if ("verify_and_register".equalsIgnoreCase(action)) {
            // Verify code and complete registration
            String email = nz(request.getParameter("email"), "");
            String code = nz(request.getParameter("code"), "").toUpperCase();
            String formDataJson = nz(request.getParameter("formData"), "");
            response.setContentType("text/plain");
            
            try {
                // Verify the code (checks expiration - 30 minutes)
                boolean codeValid = pDAO.verifyResetCode(email, code);
                
                if (!codeValid) {
                    response.getWriter().write("invalid_code");
                    return;
                }
                
                // Parse form data from JSON
                JSONObject jsonData = new JSONObject(formDataJson);
                
                String fName = jsonData.optString("fname", "");
                String lName = jsonData.optString("lname", "");
                String uName = jsonData.optString("uname", "");
                String pass = jsonData.optString("pass", "");
                String contactNo = jsonData.optString("contactno", "");
                String city = jsonData.optString("city", "");
                String address = jsonData.optString("address", "");
                String userType = jsonData.optString("user_type", "student");
                
                // Final validation
                if (fName.isEmpty() || lName.isEmpty() || uName.isEmpty() || email.isEmpty() || pass.isEmpty()) {
                    response.getWriter().write("missing_fields");
                    return;
                }
                
                // Check for duplicates one final time
                if (pDAO.checkUsernameExists(uName)) {
                    response.getWriter().write("username_taken");
                    return;
                }
                
                if (pDAO.checkEmailExists(email)) {
                    response.getWriter().write("email_taken");
                    return;
                }
                
                // Hash password
                String hashedPass = PasswordUtils.bcryptHashPassword(pass);
                
                // Register the user
                pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, userType);
                
                // DELETE the verification code after successful registration
                pDAO.deleteVerificationCode(email, code);
                LOGGER.info("Student registered successfully and verification code deleted: " + email);
                
                response.getWriter().write("success");
                
            } catch (JSONException je) {
                LOGGER.log(Level.SEVERE, "JSON parsing error", je);
                response.getWriter().write("json_error");
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error in verify_and_register action", e);
                response.getWriter().write("error: " + e.getMessage());
            }
            return;
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