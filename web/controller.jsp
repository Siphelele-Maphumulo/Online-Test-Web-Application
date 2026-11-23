<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
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
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Base64" %>
<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>
<%@ page import="myPackage.classes.Exams" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.apache.pdfbox.pdmodel.PDDocument" %>
<%@ page import="org.apache.pdfbox.text.PDFTextStripper" %>
<%@ page import="org.json.JSONException" %>
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
    
    // Special handling for multipart form submissions
    // For multipart forms, we can't rely on request.getParameter() initially
    // So we check if this might be a questions edit operation
    if (pageParam == null && ServletFileUpload.isMultipartContent(request)) {
        // Parse the multipart request to extract the page parameter
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(1024 * 1024 * 3); // 3 MB
        factory.setRepository(new File(request.getServletContext().getAttribute("javax.servlet.context.tempdir") != null 
            ? request.getServletContext().getAttribute("javax.servlet.context.tempdir").toString() 
            : "/tmp"));
        
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(1024 * 1024 * 10); // 10 MB
        
        try {
            List<FileItem> items = upload.parseRequest(request);
            
            // First pass: extract page, operation, and qid parameters
            String operationParam = null;
            String qidParam = null;
            for (FileItem item : items) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    if ("page".equals(fieldName)) {
                        pageParam = item.getString("UTF-8");
                    } else if ("operation".equals(fieldName)) {
                        operationParam = item.getString("UTF-8");
                    } else if ("qid".equals(fieldName)) {
                        qidParam = item.getString("UTF-8");
                    }
                }
            }
            
            // If page parameter was found in multipart data, we continue
            // Otherwise, we redirect to login
            if (pageParam == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Store operation parameter in request for later use
            request.setAttribute("multipartOperation", operationParam);
            
            // Store qid parameter in request for later use
            request.setAttribute("multipartQid", qidParam);
            
            // Store the parsed items in request attributes for later use by the respective handlers
            request.setAttribute("multipartItems", items);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
            return;
        }
    } else if (pageParam == null) {
        // For non-multipart requests, redirect if no page parameter
        response.sendRedirect("login.jsp");
        return;
    }
    
    // For multipart requests, we continue processing after storing the items
    // The page and operation parameters have been extracted and stored

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

    } else if ("verify_student_name".equalsIgnoreCase(pageParam)) {
        String enteredName = request.getParameter("enteredName");
        String userId = request.getParameter("userId");
        String fullName = pDAO.verifyStudentName(enteredName, userId);
        boolean success = (fullName != null);
        
        response.setContentType("application/json");
        if (success) {
            response.getWriter().write("{\"success\": true, \"fullName\": \"" + fullName + "\"}");
        } else {
            response.getWriter().write("{\"success\": false}");
        }
        return;

    } else if ("analyze_face".equalsIgnoreCase(pageParam)) {
        String faceImage = request.getParameter("faceImage");
        StringBuilder reason = new StringBuilder();
        
        boolean isValid = myPackage.IdentityVerificationProvider.isFacePhotoValid(faceImage, reason);
        
        JSONObject result = new JSONObject();
        result.put("success", isValid);
        result.put("reason", reason.toString());
        
        response.setContentType("application/json");
        response.getWriter().write(result.toString());
        return;

    } else if ("analyze_id".equalsIgnoreCase(pageParam)) {
        String idImage = request.getParameter("idImage");
        StringBuilder reason = new StringBuilder();
        
        boolean isValid = myPackage.IdentityVerificationProvider.isIdPhotoValid(idImage, reason);
        
        JSONObject result = new JSONObject();
        result.put("success", isValid);
        result.put("reason", reason.toString());
        
        response.setContentType("application/json");
        response.getWriter().write(result.toString());
        return;

    } else if ("verify_id".equalsIgnoreCase(pageParam)) {
        String idImage = request.getParameter("idImage");
        StringBuilder reason = new StringBuilder();
        
        boolean holdingId = myPackage.IdentityVerificationProvider.isHoldingId(idImage, reason);
        
        JSONObject result = new JSONObject();
        result.put("success", holdingId);
        result.put("reason", reason.toString());
        
        response.setContentType("application/json");
        response.getWriter().write(result.toString());
        return;

    /* =========================
       LOGOUT
       ========================= */
    } else if ("logout".equalsIgnoreCase(pageParam)) {
        if (session != null) {
            session.invalidate();
        }
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.sendRedirect("login.jsp");
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

        // Set success message
        session.setAttribute("success", "Registration successful! You can now login.");

        // Determine redirect based on user type
        boolean isAdminOrLecturer = "admin".equalsIgnoreCase(userType)
                || "lecture".equalsIgnoreCase(userType)
                || "lecturer".equalsIgnoreCase(userType);

        if (isAdminOrLecturer || "account".equalsIgnoreCase(fromPage)) {
            session.setAttribute("message", "User added successfully!");
            response.sendRedirect("accounts.jsp");
        } else {
            session.setAttribute("success", "Registration successful! Please login.");
            response.sendRedirect("login.jsp");
        }

    } catch (RuntimeException ex) {
        // The addNewUser method throws RuntimeException on SQL failure.
        // Re-check for duplicates that may have slipped past the pre-checks.
        boolean usernameCheck = pDAO.checkUsernameExists(uName);
        boolean emailCheck    = pDAO.checkEmailExists(email);
        boolean contactCheck  = contactNo != null && !contactNo.isEmpty()
                                && pDAO.checkContactNoExists(contactNo);

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
            // Build a meaningful error message from the root cause
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
        // Catch any other exceptions (e.g., password hashing errors)
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
       ADMIN / LECTURER STUDENT RESULTS
       ========================= */
    } else if ("admin-results".equalsIgnoreCase(pageParam)) {
        Object userIdObject = session.getAttribute("userId");
        myPackage.classes.User currentUser = null;
        if (userIdObject != null) {
            currentUser = pDAO.getUserDetails(userIdObject.toString());
        }

        boolean canManageResults = currentUser != null
                && ("admin".equalsIgnoreCase(currentUser.getType())
                || "lecture".equalsIgnoreCase(currentUser.getType())
                || "lecturer".equalsIgnoreCase(currentUser.getType()));

        if (!canManageResults) {
            session.setAttribute("error", "You do not have permission to delete student results.");
            response.sendRedirect("adm-page.jsp?pgprt=5");
            return;
        }

        String submittedToken = request.getParameter("csrf_token");
        String sessionToken = (String) session.getAttribute("csrf_token");
        if (sessionToken == null || submittedToken == null || !sessionToken.equals(submittedToken)) {
            session.setAttribute("error", "Invalid request. Please try again.");
            response.sendRedirect("adm-page.jsp?pgprt=5");
            return;
        }

        String operation = nz(request.getParameter("operation"), "");

        if ("delete_result".equalsIgnoreCase(operation)) {
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
                    session.setAttribute("error", "Invalid exam ID.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid exam ID format.");
            }
        } else if ("edit_result".equalsIgnoreCase(operation)) {
            try {
                int examId = Integer.parseInt(nz(request.getParameter("eid"), "0"));
                int obtainedMarks = Integer.parseInt(nz(request.getParameter("obtMarks"), "-1"));
                int totalMarks = Integer.parseInt(nz(request.getParameter("totalMarks"), "-1"));
                String status = nz(request.getParameter("status"), "");

                if (examId <= 0 || obtainedMarks < 0 || obtainedMarks > totalMarks || totalMarks < 0) {
                    session.setAttribute("error", "Invalid result values.");
                } else if (pDAO.updateExamResult(examId, obtainedMarks, totalMarks, status)) {
                    session.setAttribute("message", "Exam result updated successfully.");
                } else {
                    session.setAttribute("error", "Failed to update exam result.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid result values.");
            }
        } else if ("bulk_delete".equalsIgnoreCase(operation)) {
            String[] examIds = request.getParameterValues("examIds");
            if (examIds != null && examIds.length > 0) {
                pDAO.deleteExamResults(examIds);
                session.setAttribute("message", "Selected exam results deleted successfully.");
            } else {
                session.setAttribute("error", "No exam results selected for deletion.");
            }
        } else {
            session.setAttribute("error", "Invalid delete operation.");
        }

        response.sendRedirect("adm-page.jsp?pgprt=5");
        return;

/* =========================
   QUESTIONS
   ========================= */
} else if ("questions".equalsIgnoreCase(pageParam)) {
    // For multipart requests, operation parameter may be stored as attribute
    String operation = nz((String) request.getAttribute("multipartOperation"), "");
    if (operation.isEmpty()) {
        operation = nz(request.getParameter("operation"), "");
    }
    
    // --- START CSRF VALIDATION ---
    if ("del".equalsIgnoreCase(operation) || "bulk_delete".equalsIgnoreCase(operation)) {
        String submittedToken = request.getParameter("csrf_token");
        String sessionToken = (String) session.getAttribute("csrf_token");

        // DEBUG LOGGING
        LOGGER.info("CSRF Validation - Submitted: " + submittedToken);
        LOGGER.info("CSRF Validation - Session: " + sessionToken);
        
        if (sessionToken == null || submittedToken == null || !sessionToken.equals(submittedToken)) {
            LOGGER.warning("CSRF validation failed for delete operation");
            session.setAttribute("error", "Invalid request. Please try again.");
            
            String courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("showall.jsp?coursename=" + java.net.URLEncoder.encode(courseName, "UTF-8") + "&error=csrf");
        } else {
                response.sendRedirect("showall.jsp?error=csrf");
            }
            return;
        }
    }
    // --- END CSRF VALIDATION ---
    
    if ("del".equalsIgnoreCase(operation)) {
        // For multipart requests, qid parameter may be stored as attribute
        String qid = nz((String) request.getAttribute("multipartQid"), "");
        if (qid.isEmpty()) {
            // For non-multipart requests, get qid from regular parameter
            qid = nz(request.getParameter("qid"), "");
        }
        
        // Get course name for redirect
        String courseName = nz(request.getParameter("coursename"), "");
        
        // Debug logging
        LOGGER.info("DELETE QUESTION - qid: " + qid + ", course: " + courseName);
        
        if (!qid.isEmpty()) {
            try {
                int questionId = Integer.parseInt(qid);
                
                // FIX: First delete drag-drop related data if it exists
                try {
                    pDAO.clearDragDropQuestionData(questionId);
                } catch (Exception e) {
                    LOGGER.warning("Error clearing drag-drop data: " + e.getMessage());
                    // Continue with deletion even if this fails
                }
                
                // Then delete the question
                boolean success = pDAO.deleteQuestion(questionId);
                
                LOGGER.info("DELETE QUESTION - success for ID " + questionId + ": " + success);
                
        if (success) {
                    session.setAttribute("message", "Question deleted successfully");
        } else {
                    session.setAttribute("error", "Failed to delete question ID: " + qid);
                }
            } catch (NumberFormatException e) {
                LOGGER.warning("DELETE QUESTION - Invalid qid format: " + qid);
                session.setAttribute("error", "Invalid question ID format: " + qid);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "DELETE QUESTION - Exception for qid " + qid, e);
                session.setAttribute("error", "Error deleting question: " + e.getMessage());
            }
        } else {
            LOGGER.warning("DELETE QUESTION - Empty qid parameter");
            session.setAttribute("error", "Question ID is required for deletion");
        }
        
        // Redirect back to showall.jsp
        String timestamp = String.valueOf(new Date().getTime());
        if (!courseName.isEmpty()) {
            response.sendRedirect("showall.jsp?coursename=" + java.net.URLEncoder.encode(courseName, "UTF-8") + "&_=" + timestamp);
        } else {
            response.sendRedirect("showall.jsp?_=" + timestamp);
        }
        return;
    } else if ("bulk_delete".equalsIgnoreCase(operation)) {
        String[] questionIds = request.getParameterValues("questionIds");
        String courseName = nz(request.getParameter("coursename"), "");
        
        if (questionIds != null && questionIds.length > 0) {
            // Convert string array to int array
            int[] questionIdArray = new int[questionIds.length];
            int validCount = 0;
            
            // Validate and convert question IDs
            for (String qid : questionIds) {
                try {
                    int id = Integer.parseInt(qid);
                    questionIdArray[validCount++] = id;
                } catch (NumberFormatException e) {
                    // Skip invalid IDs
                    LOGGER.warning("Invalid question ID skipped: " + qid);
                }
            }
            
            // Create properly sized array with only valid IDs
            int[] validQuestionIds = new int[validCount];
            for (int i = 0; i < validCount; i++) {
                validQuestionIds[i] = questionIdArray[i];
            }
            questionIdArray = validQuestionIds;

            if (questionIdArray.length > 0) {
                // Use the new bulk delete method
                int deletedCount = pDAO.deleteQuestions(questionIdArray);
                
                if (deletedCount > 0) {
                    session.setAttribute("message", deletedCount + " question(s) deleted successfully!");
                    // Redirect to showall.jsp after successful bulk delete
                    String timestamp = String.valueOf(new Date().getTime());
                    if (!courseName.isEmpty()) {
                        response.sendRedirect("showall.jsp?coursename=" + courseName + "&_=" + timestamp);
        } else {
                        response.sendRedirect("showall.jsp?_=" + timestamp);
                    }
                    return;
        } else {
                    session.setAttribute("error", "Failed to delete selected questions.");
                }
        } else {
            session.setAttribute("error", "No valid questions selected for deletion.");
        }
        } else {
            session.setAttribute("error", "No questions selected for deletion.");
        }
        
        // Redirect to showall.jsp after unsuccessful bulk delete
        String timestamp = String.valueOf(new Date().getTime());
        if (!courseName.isEmpty()) {
            response.sendRedirect("showall.jsp?coursename=" + courseName + "&_=" + timestamp);
        } else {
            response.sendRedirect("showall.jsp?_=" + timestamp);
        }
    } else if ("edit".equalsIgnoreCase(operation)) {
        // For multipart requests, qid parameter may be stored as attribute
        String qid = nz((String) request.getAttribute("multipartQid"), "");
        if (qid.isEmpty()) {
            // For non-multipart requests, get qid from regular parameter
            qid = nz(request.getParameter("qid"), "");
        }
        if (!qid.isEmpty()) {
            Questions question = pDAO.getQuestionById(Integer.parseInt(qid));
            if (question != null) {
                // Handle multipart form data if present (for image uploads)
                if (ServletFileUpload.isMultipartContent(request)) {
                    // Use the pre-parsed items from the beginning of the controller
                    List<FileItem> items = (List<FileItem>) request.getAttribute("multipartItems");
                    
                    // If items weren't pre-parsed, parse them now
                    if (items == null) {
                        DiskFileItemFactory factory = new DiskFileItemFactory();
                        
                        // Set factory constraints
                        factory.setSizeThreshold(1024 * 1024 * 3); // 3 MB
                        factory.setRepository(new File(request.getServletContext().getAttribute("javax.servlet.context.tempdir") != null 
                            ? request.getServletContext().getAttribute("javax.servlet.context.tempdir").toString() 
                            : "/tmp"));
                        
                        // Create a new file upload handler
                        ServletFileUpload upload = new ServletFileUpload(factory);
                        
                        // Set overall request size constraint
                        upload.setSizeMax(1024 * 1024 * 10); // 10 MB
                        
                        // Parse the request
                        items = upload.parseRequest(request);
                    }
                    
                    try {
                        
                        String questionText = "";
                        String opt1 = "";
                        String opt2 = "";
                        String opt3 = "";
                        String opt4 = "";
                        String correctAnswer = "";
                        String courseName = "";
                        String questionType = "";
                        String currentImagePath = "";
                        boolean removeImage = false;
                        String imagePath = null;
                        
                        for (FileItem item : items) {
                            if (item.isFormField()) {
                                // Process regular form field
                                String fieldName = item.getFieldName();
                                String fieldValue = item.getString("UTF-8");
                                
                                if ("question".equals(fieldName)) {
                                    questionText = nz(fieldValue, "");
                                } else if ("opt1".equals(fieldName)) {
                                    opt1 = nz(fieldValue, "");
                                } else if ("opt2".equals(fieldName)) {
                                    opt2 = nz(fieldValue, "");
                                } else if ("opt3".equals(fieldName)) {
                                    opt3 = nz(fieldValue, "");
                                } else if ("opt4".equals(fieldName)) {
                                    opt4 = nz(fieldValue, "");
                                } else if ("correct".equals(fieldName)) {
                                    correctAnswer = nz(fieldValue, "");
                                } else if ("coursename".equals(fieldName)) {
                                    courseName = nz(fieldValue, "");
                                } else if ("questionType".equals(fieldName)) {
                                    questionType = nz(fieldValue, "");
                                } else if ("currentImagePath".equals(fieldName)) {
                                    currentImagePath = nz(fieldValue, "");
                                } else if ("removeImage".equals(fieldName)) {
                                    removeImage = "true".equals(fieldValue);
                                }
        } else {
                                // Process file upload field - ONLY ACCEPT IMAGES
                                String fieldName = item.getFieldName();
                                String fileName = item.getName();
                                
                                if (fieldName.equals("imageFile") && fileName != null && !fileName.isEmpty()) {
                                    // Skip image validation for drag and drop questions
                                    if (!"DRAG_AND_DROP".equals(questionType)) {
                                        // Check file extension
                                        String fileExtension = "";
                                        int dotIndex = fileName.lastIndexOf('.');
                                        if (dotIndex > 0) {
                                            fileExtension = fileName.substring(dotIndex).toLowerCase();
                                        }
                                        
                                        // List of allowed image extensions
                                        String[] allowedExtensions = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"};
                                        boolean isImage = false;
                                        for (String ext : allowedExtensions) {
                                            if (fileExtension.equals(ext)) {
                                                isImage = true;
                                                break;
                                            }
                                        }
                                        
                                        if (!isImage) {
                                            session.setAttribute("error", "Only image files are allowed (JPG, JPEG, PNG, GIF, WEBP, BMP).");
                                            String redirectCourse = nz(request.getParameter("coursename"), "");
                                            if (!redirectCourse.isEmpty()) {
                                                response.sendRedirect("showall.jsp?coursename=" + redirectCourse);
        } else {
                                                response.sendRedirect("showall.jsp");
                                            }
                                            return;
                                        }
                                    }
                                    
                                    // Create uploads directory if it doesn't exist
                                    String uploadPath = getServletContext().getRealPath("/uploads/images");
                                    File uploadDir = new File(uploadPath);
                                    if (!uploadDir.exists()) {
                                        uploadDir.mkdirs();
                                    }
                                    
                                    // Generate unique filename using current time
                                    long timestamp = new java.util.Date().getTime();
                                    String uniqueFileName = timestamp + "_" + new File(fileName).getName();
                                    File uploadedFile = new File(uploadDir, uniqueFileName);
                                    
                                    // Save the file
                                    item.write(uploadedFile);
                                    
                                    // Set the image path to be saved in database
                                    imagePath = "uploads/images/" + uniqueFileName;
                                }
                            }
                        }
                        
                        // Update question object with extracted values
                        question.setQuestion(questionText);
                        question.setOpt1(opt1);
                        question.setOpt2(opt2);
                        question.setOpt3(opt3);
                        question.setOpt4(opt4);
                        question.setCorrect(correctAnswer);
                        question.setCourseName(courseName);
                        question.setQuestionType(questionType);
                        
                        // Handle image logic
                        if (removeImage) {
                            // Remove old image file if it exists
                            if (question.getImagePath() != null && !question.getImagePath().isEmpty()) {
                                try {
                                    File oldImage = new File(getServletContext().getRealPath("/" + question.getImagePath()));
                                    if (oldImage.exists()) {
                                        oldImage.delete();
                                    }
                                } catch (Exception e) {
                                    // Log error but continue
                                    application.log("Error deleting old image: " + e.getMessage());
                                }
                            }
                            question.setImagePath(null);
                        } else if (imagePath != null) {
                            // New image uploaded - remove old image file if it exists
                            if (question.getImagePath() != null && !question.getImagePath().isEmpty()) {
                                try {
                                    File oldImage = new File(getServletContext().getRealPath("/" + question.getImagePath()));
                                    if (oldImage.exists()) {
                                        oldImage.delete();
                                    }
                                } catch (Exception e) {
                                    // Log error but continue
                                    application.log("Error deleting old image: " + e.getMessage());
                                }
                            }
                            question.setImagePath(imagePath);
        } else {
                            // Keep existing image path if no new image was uploaded and not removing
                            if (currentImagePath != null && !currentImagePath.isEmpty() && question.getImagePath() == null) {
                                question.setImagePath(currentImagePath);
                            }
                        }
                        
                        // 🔹 STEP 10 — Controller Must Simply Store JSON
                        // Controller should NOT re-encode.
                        String dragItemsHidden = "";
                        String dropTargetsHidden = "";
                        String correctTargetsHidden = "";
                        String orientation = "horizontal";
                        Integer totalMarks = null;
                        
                        if ("DRAG_AND_DROP".equalsIgnoreCase(questionType)) {
                            application.log("=== EDIT DRAG DROP PROCESSING START (SIMPLE JSON) ===");
                            
                            for (FileItem item : items) {
                                if (item.isFormField()) {
                                    String fieldName = item.getFieldName();
                                    String fieldValue = item.getString("UTF-8");
                                    
                                    if ("totalMarks".equals(fieldName)) {
                                        try {
                                            if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                                totalMarks = Integer.parseInt(fieldValue.trim());
                                            }
                                        } catch (NumberFormatException e) {
                                            application.log("Invalid totalMarks value: " + fieldValue);
                                        }
                                    } else if ("dragItemsHidden".equals(fieldName)) {
                                        dragItemsHidden = fieldValue;
                                    } else if ("dropTargetsHidden".equals(fieldName)) {
                                        dropTargetsHidden = fieldValue;
                                    } else if ("correctTargetsHidden".equals(fieldName)) {
                                        correctTargetsHidden = fieldValue;
                                    } else if ("orientation".equals(fieldName)) {
                                        orientation = fieldValue;
                                    }
                                }
                            }
                            
                            application.log("Collected JSON Data - DragItems: " + dragItemsHidden.length() + " chars");
                            
                            // Store orientation in extra_data
                            JSONObject extraDataObj = new JSONObject();
                            extraDataObj.put("orientation", orientation);
                            question.setExtraData(extraDataObj.toString());
                            
                            // For drag-drop questions, keep opts/correct empty (not used) to satisfy NOT NULL constraints.
                            question.setOpt1("");
                            question.setOpt2("");
                            question.setOpt3("");
                            question.setOpt4("");
                            question.setCorrect("");
                        } else if ("REARRANGE".equalsIgnoreCase(questionType)) {
                            application.log("=== EDIT REARRANGE PROCESSING START ===");
                            String rearrangeItemsHidden = "";
                            String rearrangeStyle = "vertical";
                            java.util.List<String> rearrangeItemsList = new java.util.ArrayList<>();
                            java.util.Map<Integer, String> itemsMap = new java.util.TreeMap<>();
                            
                            for (FileItem item : items) {
                                if (item.isFormField()) {
                                    String fieldName = item.getFieldName();
                                    String fieldValue = item.getString("UTF-8");
                                    
                                    if ("rearrangeItemsHidden".equals(fieldName)) {
                                        rearrangeItemsHidden = fieldValue;
                                    } else if (fieldName.startsWith("rearrangeItem_")) {
                                        int idx = Integer.parseInt(fieldName.substring(14));
                                        if (!fieldValue.trim().isEmpty()) {
                                            itemsMap.put(idx, fieldValue.trim());
                                        }
                                    } else if ("rearrangeStyle".equals(fieldName)) {
                                        rearrangeStyle = fieldValue;
                                    } else if ("totalMarks".equals(fieldName)) {
                                        try {
                                            totalMarks = Integer.parseInt(fieldValue.trim());
                                        } catch (Exception e) {}
                                    }
                                }
                            }
                            
                            // If rearrangeItemsHidden is empty, try to use itemsMap
                            if (rearrangeItemsHidden.isEmpty() && !itemsMap.isEmpty()) {
                                for (String val : itemsMap.values()) rearrangeItemsList.add(val);
                                rearrangeItemsHidden = pDAO.toJsonArray(rearrangeItemsList);
                            }
                            
                            // Store style in extra_data
                            JSONObject extraDataObj = new JSONObject();
                            extraDataObj.put("style", rearrangeStyle);
                            question.setExtraData(extraDataObj.toString());
                            
                            // Clear opts/correct
                            question.setOpt1("");
                            question.setOpt2("");
                            question.setOpt3("");
                            question.setOpt4("");
                            question.setCorrect("");
                            
                            // Update question first
                            pDAO.updateQuestion(question);
                            
                            // Sync relational table
                            if (!rearrangeItemsHidden.isEmpty()) {
                                try {
                                    org.json.JSONArray itemsArr = new org.json.JSONArray(rearrangeItemsHidden);
                                    java.util.List<String> itemsList = new java.util.ArrayList<>();
                                    for(int i=0; i<itemsArr.length(); i++) itemsList.add(itemsArr.getString(i));
                                    
                                    pDAO.clearRearrangeData(question.getQuestionId());
                                    pDAO.addRearrangeData(question.getQuestionId(), itemsList);
                                    
                                    // Update JSON fallback
                                    pDAO.updateRearrangeQuestionJson(question.getQuestionId(), rearrangeItemsHidden, totalMarks);
                                } catch (Exception e) {
                                    application.log("Error syncing rearrange items: " + e.getMessage());
                                }
                            }
                            
                            application.log("=== EDIT REARRANGE PROCESSING END ===");
                            
                            session.setAttribute("message","Question updated successfully");
                            request.removeAttribute("multipartItems");
                            if (!courseName.isEmpty()) response.sendRedirect("showall.jsp?coursename=" + courseName);
                            else response.sendRedirect("showall.jsp");
                            return;
                        }
                        
                        pDAO.updateQuestion(question);

                        if ("DRAG_AND_DROP".equalsIgnoreCase(questionType)) {
                            // SYNC RELATIONAL TABLES FOR ACCURATE SCORING
                            if (!dragItemsHidden.isEmpty() && !dropTargetsHidden.isEmpty() && !correctTargetsHidden.isEmpty()) {
                                try {
                                    org.json.JSONArray itemsArr = new org.json.JSONArray(dragItemsHidden);
                                    org.json.JSONArray targetsArr = new org.json.JSONArray(dropTargetsHidden);
                                    org.json.JSONArray mappingsArr = new org.json.JSONArray(correctTargetsHidden);
                                    
                                    java.util.List<String> dragItemsList = new java.util.ArrayList<>();
                                    java.util.List<String> dropTargetsList = new java.util.ArrayList<>();
                                    java.util.List<String> dragCorrectTargetsList = new java.util.ArrayList<>();
                                    
                                    for(int i=0; i<itemsArr.length(); i++) dragItemsList.add(itemsArr.getString(i));
                                    for(int i=0; i<targetsArr.length(); i++) dropTargetsList.add(targetsArr.getString(i));
                                    for(int i=0; i<mappingsArr.length(); i++) dragCorrectTargetsList.add(mappingsArr.getString(i));
                                    
                                    // Clear old relational data and re-add fresh data
                                    pDAO.clearDragDropQuestionData(question.getQuestionId());
                                    pDAO.addDragDropData(question.getQuestionId(), dragItemsList, dropTargetsList, dragCorrectTargetsList);
                                    application.log("Successfully synced relational tables for edited question ID: " + question.getQuestionId());
                                } catch (Exception e) {
                                    application.log("FAILED to sync relational tables for question ID " + question.getQuestionId() + ": " + e.getMessage());
                                }
                            }
                            
                            // Simply update JSON columns directly without re-encoding
                            pDAO.updateDragDropQuestionJson(question.getQuestionId(), dragItemsHidden, dropTargetsHidden, correctTargetsHidden, totalMarks);
                            application.log("=== EDIT DRAG DROP PROCESSING END (SIMPLE JSON) ===");
                        }

                        session.setAttribute("message","Question updated successfully");
                        
                        // Clean up multipart items attribute to prevent reuse
                        request.removeAttribute("multipartItems");
                        
                        // Redirect to showall.jsp after editing
                        if (!courseName.isEmpty()) {
                            response.sendRedirect("showall.jsp?coursename=" + courseName);
                        } else {
                            response.sendRedirect("showall.jsp");
                        }
                        return;
                    } catch (Exception e) {
                        e.printStackTrace();
                        session.setAttribute("error", "Error updating question: " + e.getMessage());
                        String courseName = nz(request.getParameter("coursename"), "");
                        request.removeAttribute("multipartItems");
                        if (!courseName.isEmpty()) {
                            response.sendRedirect("showall.jsp?coursename=" + courseName);
                        } else {
                            response.sendRedirect("showall.jsp");
                        }
                        return;
                    }
                } else {
                    // Handle regular form submission (without file upload)
                    question.setQuestion(nz(request.getParameter("question"), ""));
                    question.setOpt1(nz(request.getParameter("opt1"), ""));
                    question.setOpt2(nz(request.getParameter("opt2"), ""));
                    question.setOpt3(nz(request.getParameter("opt3"), ""));
                    question.setOpt4(nz(request.getParameter("opt4"), ""));
                    question.setCorrect(nz(request.getParameter("correct"), ""));

                    String courseName = nz(request.getParameter("coursename"), "");
                    question.setCourseName(courseName);

                    String questionType = nz(request.getParameter("questionType"), "");
                    question.setQuestionType(questionType);

                    String removeImageParam = nz(request.getParameter("removeImage"), "");
                    if ("true".equals(removeImageParam)) {
                        if (question.getImagePath() != null && !question.getImagePath().isEmpty()) {
                            try {
                                File oldImage = new File(getServletContext().getRealPath("/" + question.getImagePath()));
                                if (oldImage.exists()) {
                                    oldImage.delete();
                                }
                            } catch (Exception imageError) {
                                application.log("Error deleting old image: " + imageError.getMessage());
                            }
                        }
                        question.setImagePath(null);
                    }

                    pDAO.updateQuestion(question);

                    if ("REARRANGE".equalsIgnoreCase(questionType)) {
                        java.util.List<String> rearrangeItemsList = new java.util.ArrayList<>();
                        java.util.Map<Integer, String> itemsMap = new java.util.TreeMap<>();

                        Enumeration<String> paramNames = request.getParameterNames();
                        while (paramNames.hasMoreElements()) {
                            String paramName = paramNames.nextElement();
                            if (paramName.startsWith("rearrangeItem_")) {
                                int idx = Integer.parseInt(paramName.substring(14));
                                String val = request.getParameter(paramName);
                                if (val != null && !val.trim().isEmpty()) {
                                    itemsMap.put(idx, val.trim());
                                }
                            }
                        }
                        for (String val : itemsMap.values()) {
                            rearrangeItemsList.add(val);
                        }

                        pDAO.clearRearrangeData(question.getQuestionId());
                        pDAO.addRearrangeData(question.getQuestionId(), rearrangeItemsList);

                        String displayStyle = nz(request.getParameter("rearrangeStyle"), "vertical");
                        org.json.JSONObject extraDataObj = new org.json.JSONObject();
                        extraDataObj.put("style", displayStyle);
                        question.setExtraData(extraDataObj.toString());

                        Integer totalMarks = null;
                        try {
                            String tmParam = request.getParameter("totalMarks");
                            if (tmParam != null) {
                                totalMarks = Integer.parseInt(tmParam);
                            }
                        } catch (Exception ignored) {}

                        pDAO.updateRearrangeQuestionJson(question.getQuestionId(), pDAO.toJsonArray(rearrangeItemsList), totalMarks);
                    }

                    session.setAttribute("message", "Question updated successfully");
                    if (request.getAttribute("multipartItems") != null) {
                        request.removeAttribute("multipartItems");
                    }

                    if (!courseName.isEmpty()) {
                        response.sendRedirect("showall.jsp?coursename=" + courseName);
                    } else {
                        response.sendRedirect("showall.jsp");
                    }
                    return;
                }
            }
        }
    } else if ("exams".equalsIgnoreCase(pageParam)) {
        String examOperation = nz(request.getParameter("operation"), "");

        if ("startexam".equalsIgnoreCase(examOperation)) {
            String submittedToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");
            if (sessionToken == null || submittedToken == null || !sessionToken.equals(submittedToken)) {
                session.setAttribute("error", "Invalid request. Please try again.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            String courseName = nz(request.getParameter("coursename"), "");
            if (courseName.isEmpty()) {
                session.setAttribute("error", "Please select a course.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            if (!pDAO.isCourseActive(courseName)) {
                session.setAttribute("error", "This exam is not active.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            try {
                if (!pDAO.hasQuestions(courseName)) {
                    session.setAttribute("error", "No questions are available for the selected course.");
                    response.sendRedirect("std-page.jsp?pgprt=1");
                    return;
                }
            } catch (SQLException questionCheckError) {
                LOGGER.log(Level.SEVERE, "Failed to verify exam questions for course: " + courseName, questionCheckError);
                session.setAttribute("error", "Unable to verify questions for this exam. Please try again.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            Object userIdObject = session.getAttribute("userId");
            int userId = 0;
            if (userIdObject != null) {
                try {
                    userId = Integer.parseInt(userIdObject.toString());
                } catch (NumberFormatException ignored) {}
            }

            if (userId <= 0) {
                session.setAttribute("error", "User not logged in.");
                response.sendRedirect("login.jsp");
                return;
            }

            try {
                int examId = pDAO.startExam(courseName, userId);
                if (examId > 0) {
                    try {
                        pDAO.registerExamStart(userId, examId, courseName);
                    } catch (SQLException ignored) {}

                    session.setAttribute("examStarted", "1");
                    session.setAttribute("examId", examId);
                    session.setAttribute("examCourse", courseName);
                    response.sendRedirect("std-page.jsp?pgprt=1&coursename="
                            + java.net.URLEncoder.encode(courseName, "UTF-8"));
                } else {
                    session.setAttribute("error", "Failed to start exam.");
                    response.sendRedirect("std-page.jsp?pgprt=1");
                }
            } catch (SQLException examError) {
                LOGGER.log(Level.SEVERE, "Failed to start exam", examError);
                session.setAttribute("error", "Failed to start exam: " + examError.getMessage());
                response.sendRedirect("std-page.jsp?pgprt=1");
            }
            return;

        } else if ("submitted".equalsIgnoreCase(examOperation)) {
            String submittedToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");
            if (sessionToken == null || submittedToken == null || !sessionToken.equals(submittedToken)) {
                session.setAttribute("error", "Invalid request. Please try again.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            String courseName = nz(request.getParameter("coursename"), "");
            if (courseName.isEmpty()) {
                session.setAttribute("error", "Please select a course.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            Object userIdObject = session.getAttribute("userId");
            int userId = 0;
            if (userIdObject != null) {
                try {
                    userId = Integer.parseInt(userIdObject.toString());
                } catch (NumberFormatException ignored) {}
            }

            if (userId <= 0) {
                session.setAttribute("error", "User not logged in.");
                response.sendRedirect("login.jsp");
                return;
            }

            try {
                // Calculate total and obtained marks
                String[] questionIds = request.getParameterValues("questionId");
                String[] obtainedMarksStr = request.getParameterValues("obtainedMarks");
                String[] totalMarksStr = request.getParameterValues("totalMarks");
                String[] statuses = request.getParameterValues("status");

                if (questionIds != null && obtainedMarksStr != null && totalMarksStr != null && statuses != null) {
                    for (int i = 0; i < questionIds.length; i++) {
                        int questionId = Integer.parseInt(questionIds[i]);
                        int obtainedMarks = Integer.parseInt(obtainedMarksStr[i]);
                        int totalMarks = Integer.parseInt(totalMarksStr[i]);
                        String status = statuses[i];

                        // Update each result individually
                        pDAO.updateExamResult(questionId, obtainedMarks, totalMarks, status);
                    }
                }

                // Mark the current exam record as completed using existing APIs
                Object examIdObject = session.getAttribute("examId");
                if (examIdObject != null) {
                    int submittedExamId = Integer.parseInt(examIdObject.toString());
                    pDAO.updateExamResult(submittedExamId, 0, 0, "Pass");
                }

                session.removeAttribute("examStarted");
                session.removeAttribute("examId");
                session.removeAttribute("examCourse");
                session.setAttribute("message", "Exam submitted successfully.");
            } catch (Exception e) {
                session.setAttribute("error", "Error submitting exam: " + e.getMessage());
                LOGGER.log(Level.SEVERE, "Error submitting exam", e);
            }

            response.sendRedirect("std-page.jsp?pgprt=1");
            return;

        } else if ("resume".equalsIgnoreCase(examOperation)) {
            String submittedToken = request.getParameter("csrf_token");
            String sessionToken = (String) session.getAttribute("csrf_token");
            if (sessionToken == null || submittedToken == null || !sessionToken.equals(submittedToken)) {
                session.setAttribute("error", "Invalid request. Please try again.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            String courseName = nz(request.getParameter("coursename"), "");
            if (courseName.isEmpty()) {
                session.setAttribute("error", "Please select a course.");
                response.sendRedirect("std-page.jsp?pgprt=1");
                return;
            }

            Object userIdObject = session.getAttribute("userId");
            int userId = 0;
            if (userIdObject != null) {
                try {
                    userId = Integer.parseInt(userIdObject.toString());
                } catch (NumberFormatException ignored) {}
            }

            if (userId <= 0) {
                session.setAttribute("error", "User not logged in.");
                response.sendRedirect("login.jsp");
                return;
            }

            try {
                Object examIdObject = session.getAttribute("examId");
                if (examIdObject != null && session.getAttribute("examCourse") != null
                        && courseName.equalsIgnoreCase(session.getAttribute("examCourse").toString())) {
                    int examId = Integer.parseInt(examIdObject.toString());
                    session.setAttribute("examStarted", "1");
                    response.sendRedirect("std-page.jsp?pgprt=1&coursename="
                            + java.net.URLEncoder.encode(courseName, "UTF-8"));
                } else {
                    session.setAttribute("error", "No active exam found for resuming.");
                    response.sendRedirect("std-page.jsp?pgprt=1");
                }
            } catch (Exception e) {
                session.setAttribute("error", "Error resuming exam: " + e.getMessage());
                LOGGER.log(Level.SEVERE, "Error resuming exam", e);
                response.sendRedirect("std-page.jsp?pgprt=1");
            }
            return;
        }
    }

    /* =========================
       STUDENT RESULTS
       ========================= */
} else if ("results".equalsIgnoreCase(pageParam)) {
        if (session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int uid = Integer.parseInt(session.getAttribute("userId").toString());
        String courseName = nz(request.getParameter("coursename"), "");

        // For instructors, show all results for the course
        if ("lecture".equalsIgnoreCase((String) session.getAttribute("userType")) || "lecturer".equalsIgnoreCase((String) session.getAttribute("userType"))) {
            // Instructor view - show all students' results for the course
            request.setAttribute("resultsList", pDAO.getAllResultsByCourse(courseName));
        } else {
            // Student view - show only their own result
            request.setAttribute("resultsList", pDAO.getResultsByUserIdAndCourse(uid, courseName));
        }

        request.setAttribute("courseName", courseName);
        request.getRequestDispatcher("results.jsp").forward(request, response);
        return;

    /* =========================
       SETTINGS
       ========================= */
    } else if ("settings".equalsIgnoreCase(pageParam)) {
        if (session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int uid = Integer.parseInt(session.getAttribute("userId").toString());
        User user = pDAO.getUserDetails(String.valueOf(uid));
        request.setAttribute("user", user);

        request.getRequestDispatcher("settings.jsp").forward(request, response);
        return;

    /* =========================
       DEFAULT REDIRECT
       ========================= */
    } else {
        response.sendRedirect("login.jsp");
        return;
    }
} catch (Exception e) {
    e.printStackTrace();
    session.setAttribute("error", "An error occurred: " + e.getMessage());
    response.sendRedirect("login.jsp");
}
%>
