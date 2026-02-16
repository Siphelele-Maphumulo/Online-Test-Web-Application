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
<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>
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

                            for (FileItem item : items) {
                                if (item.isFormField()) {
                                    String fieldName = item.getFieldName();
                                    String fieldValue = item.getString("UTF-8");

                                    if ("rearrangeItemsHidden".equals(fieldName)) {
                                        rearrangeItemsHidden = fieldValue;
                                    } else if ("rearrangeStyle".equals(fieldName)) {
                                        rearrangeStyle = fieldValue;
                                    } else if ("totalMarks".equals(fieldName)) {
                                        try {
                                            totalMarks = Integer.parseInt(fieldValue.trim());
                                        } catch (Exception e) {}
                                    }
                                }
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
                        
                        // Clean up multipart items attribute to prevent reuse
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
                    // Also get and set question type for regular forms
                    String questionType = nz(request.getParameter("questionType"), "");
                    question.setQuestionType(questionType);
                    
                    // Handle image removal for regular forms
                    String removeImageParam = nz(request.getParameter("removeImage"), "");
                    if ("true".equals(removeImageParam)) {
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
                        for (String val : itemsMap.values()) rearrangeItemsList.add(val);

                        pDAO.clearRearrangeData(question.getQuestionId());
                        pDAO.addRearrangeData(question.getQuestionId(), rearrangeItemsList);

                        String displayStyle = nz(request.getParameter("rearrangeStyle"), "vertical");
                        org.json.JSONObject extraDataObj = new org.json.JSONObject();
                        extraDataObj.put("style", displayStyle);
                        question.setExtraData(extraDataObj.toString());

                        Integer totalMarks = null;
                        try {
                            String tmParam = request.getParameter("totalMarks");
                            if (tmParam != null) totalMarks = Integer.parseInt(tmParam);
                        } catch (Exception e) {}

                        pDAO.updateRearrangeQuestionJson(question.getQuestionId(), pDAO.toJsonArray(rearrangeItemsList), totalMarks);
                    }

                    session.setAttribute("message","Question updated successfully");
                    
                    // Clean up multipart items attribute if it exists (for consistency)
                    if (request.getAttribute("multipartItems") != null) {
                        request.removeAttribute("multipartItems");
                    }
                    
                    // Redirect to showall.jsp after editing
                    if (!courseName.isEmpty()) {
                        response.sendRedirect("showall.jsp?coursename=" + courseName);
                    } else {
                        response.sendRedirect("showall.jsp");
                    }
                    return;
                }
            }
        }
        String courseName = nz(request.getParameter("coursename"), "");
        
        // Clean up multipart attributes if they exist
        if (request.getAttribute("multipartItems") != null) {
            request.removeAttribute("multipartItems");
        }
        if (request.getAttribute("multipartQid") != null) {
            request.removeAttribute("multipartQid");
        }
        if (request.getAttribute("multipartOperation") != null) {
            request.removeAttribute("multipartOperation");
        }
        
        if (!courseName.isEmpty()) {
            response.sendRedirect("showall.jsp?coursename=" + courseName);
        } else {
            response.sendRedirect("showall.jsp");
        }

    } else if ("addnew".equalsIgnoreCase(operation)) {
        // Check if request is multipart (has file upload)
        if (ServletFileUpload.isMultipartContent(request)) {
            // Use the pre-parsed items from the beginning of the controller
            List<FileItem> items = (List<FileItem>) request.getAttribute("multipartItems");
            
            // If items weren't pre-parsed, parse them now
            if (items == null) {
                // Create a factory for disk-based file items
                DiskFileItemFactory factory = new DiskFileItemFactory();
                
                // Set factory constraints
                factory.setSizeThreshold(1024 * 1024 * 3); // 3 MB
                // Use alternative approach for temp directory
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
                String correctMultiple = "";
                String orientation = "horizontal";
                String imagePath = null;
                boolean isAjax = false;
                
                for (FileItem item : items) {
                    if (item.isFormField()) {
                        // Process regular form field
                        String fieldName = item.getFieldName();
                        String fieldValue = item.getString("UTF-8");
                        
                        if ("ajax".equals(fieldName)) {
                            isAjax = "true".equalsIgnoreCase(fieldValue);
                        } else if ("question".equals(fieldName)) {
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
                        } else if ("correctMultiple".equals(fieldName)) {
                            correctMultiple = nz(fieldValue, "");
                        } else if ("orientation".equals(fieldName)) {
                            orientation = fieldValue;
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
                                    if (!courseName.isEmpty()) {
                                        response.sendRedirect("showall.jsp?coursename=" + courseName);
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
                
                if ("MultipleSelect".equalsIgnoreCase(questionType)) {
                    if (!correctMultiple.isEmpty()) correctAnswer = correctMultiple;
                }
                
                String extraData = null;
                if ("DRAG_AND_DROP".equalsIgnoreCase(questionType)) {
                    JSONObject extraDataObj = new JSONObject();
                    extraDataObj.put("orientation", orientation);
                    extraData = extraDataObj.toString();
                }
                
                // Insert question FIRST and capture new question ID
                int newQuestionIdInserted = pDAO.addNewQuestionReturnId(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, imagePath, extraData);
                
                application.log("=== AFTER QUESTION INSERT ===");
                application.log("Question Type: " + questionType);
                application.log("Is DRAG_AND_DROP: " + "DRAG_AND_DROP".equalsIgnoreCase(questionType));
                
                // NOW process drag and drop data AFTER question insert for DRAG_AND_DROP type
                if ("DRAG_AND_DROP".equalsIgnoreCase(questionType)) {
                    application.log("=== ENTERING DRAG DROP SECTION ===");
                    try {
                        int newQuestionId = newQuestionIdInserted;
                        application.log("New Question ID for drag drop: " + newQuestionId);
                        
                        // CRITICAL: Validate the question ID before proceeding
                        if (newQuestionId <= 0) {
                            application.log("ERROR: Invalid question ID returned: " + newQuestionId);
                            throw new Exception("Failed to get valid question ID");
                        }
                        
                        // Verify the question actually exists
                        if (!pDAO.questionExists(newQuestionId)) {
                            application.log("ERROR: Question ID " + newQuestionId + " does not exist in questions table!");
                            throw new Exception("Question ID " + newQuestionId + " not found");
                        }
                        
                        application.log("Verified question ID " + newQuestionId + " exists in questions table");
                        
                        // NOW extract drag and drop data from FileItems (AFTER question insert)
                        java.util.List<String> dragItemsList = new java.util.ArrayList<>();
                        java.util.List<String> dropTargetsList = new java.util.ArrayList<>();
                        java.util.List<String> dragCorrectTargetsList = new java.util.ArrayList<>();
                        Integer totalMarks = null;
                        
                        application.log("=== DRAG DROP PROCESSING START ===");
                        application.log("Question type: " + questionType);
                        application.log("Total FileItems processed: " + items.size());
                        
                        for (FileItem item : items) {
                            if (item.isFormField()) {
                                String fieldName = item.getFieldName();
                                String fieldValue = item.getString("UTF-8");
                                
                                application.log("Processing field: " + fieldName + " = " + fieldValue);

                                if ("totalMarks".equals(fieldName)) {
                                    try {
                                        if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                            totalMarks = Integer.parseInt(fieldValue.trim());
                                        }
                                    } catch (NumberFormatException nfe) {
                                        application.log("Invalid totalMarks value: " + fieldValue);
                                    }
                                }
                                
                                if (fieldName.startsWith("dragItem_text_")) {
                                    String targetParam = fieldName.replace("dragItem_text_", "dragItem_target_");
                                    String targetValue = "";
                                    
                                    // Find the corresponding target value
                                    for (FileItem targetItem : items) {
                                        if (targetItem.isFormField() && targetItem.getFieldName().equals(targetParam)) {
                                            targetValue = targetItem.getString("UTF-8");
                                            break;
                                        }
                                    }
                                    
                                    application.log("Found drag item: '" + fieldValue + "' -> target: '" + targetValue + "'");
                                    
                                    if (!fieldValue.trim().isEmpty()) {
                                        dragItemsList.add(fieldValue);
                                        dragCorrectTargetsList.add(targetValue);
                                    }
                                } else if (fieldName.startsWith("dropTarget_")) {
                                    application.log("Found drop target: '" + fieldValue + "'");
                                    if (!fieldValue.trim().isEmpty()) {
                                        dropTargetsList.add(fieldValue.trim());
                                    }
                                }
                            }
                        }
                        
                        application.log("Drag items count: " + dragItemsList.size());
                        application.log("Drop targets count: " + dropTargetsList.size());
                        application.log("Correct targets count: " + dragCorrectTargetsList.size());
                        
                        // Use the new clean relational method
                        pDAO.addDragDropData(newQuestionId, dragItemsList, dropTargetsList, dragCorrectTargetsList);

                        // Also persist a copy into questions table columns for visibility/debugging
                        pDAO.updateDragDropQuestionColumns(newQuestionId, dragItemsList, dropTargetsList, dragCorrectTargetsList, totalMarks);
                        
                        application.log("=== DRAG DROP DATA SAVED USING RELATIONAL TABLES ===");
                        
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "Error saving drag drop data", e);
                        session.setAttribute("error", "Question saved but drag drop data had errors: " + e.getMessage());
                        application.log("Error saving drag drop data: " + e.getMessage());
                    }
                        } else if ("REARRANGE".equalsIgnoreCase(questionType)) {
                            application.log("=== ENTERING REARRANGE SECTION ===");
                            try {
                                int newQuestionId = newQuestionIdInserted;
                                java.util.List<String> rearrangeItemsList = new java.util.ArrayList<>();
                                String displayStyle = "vertical";
                                Integer totalMarks = null;

                                // Collect items in order
                                java.util.Map<Integer, String> itemsMap = new java.util.TreeMap<>();

                                for (FileItem item : items) {
                                    if (item.isFormField()) {
                                        String fieldName = item.getFieldName();
                                        String fieldValue = item.getString("UTF-8");

                                        if (fieldName.startsWith("rearrangeItem_")) {
                                            int idx = Integer.parseInt(fieldName.substring(14));
                                            if (!fieldValue.trim().isEmpty()) {
                                                itemsMap.put(idx, fieldValue.trim());
                                            }
                                        } else if ("rearrangeStyle".equals(fieldName)) {
                                            displayStyle = fieldValue;
                                        } else if ("totalMarks".equals(fieldName)) {
                                            try {
                                                totalMarks = Integer.parseInt(fieldValue.trim());
                                            } catch (Exception e) {}
                                        }
                                    }
                                }

                                for (String val : itemsMap.values()) {
                                    rearrangeItemsList.add(val);
                                }

                                // Update extra_data with display style
                                org.json.JSONObject extraDataObj = new org.json.JSONObject();
                                extraDataObj.put("style", displayStyle);

                                Questions q = pDAO.getQuestionById(newQuestionId);
                                q.setExtraData(extraDataObj.toString());

                                // Save items to relational table
                                pDAO.addRearrangeData(newQuestionId, rearrangeItemsList);

                                // Save items as JSON in drag_items column for fallback
                                pDAO.updateRearrangeQuestionJson(newQuestionId, pDAO.toJsonArray(rearrangeItemsList), totalMarks);

                                application.log("=== REARRANGE DATA SAVED successfully ===");
                            } catch (Exception e) {
                                LOGGER.log(Level.SEVERE, "Error saving rearrange data", e);
                                application.log("Error saving rearrange data: " + e.getMessage());
                            }
                }
                
                session.setAttribute("message","Question added successfully");
                
                // Save last selections to session
                session.setAttribute("last_course_name", courseName);
                session.setAttribute("last_question_type", questionType);
                
                if (isAjax) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\": true, \"message\": \"Question added successfully\", \"qid\": " + newQuestionIdInserted + "}");
                    return;
                }
                
                // Redirect to success page with modal
                if (!courseName.isEmpty()) {
                    response.sendRedirect("question-success.jsp?coursename=" + java.net.URLEncoder.encode(courseName, "UTF-8"));
                } else {
                    response.sendRedirect("question-success.jsp");
                }
                return;
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Error uploading image: " + e.getMessage());
                
                // Clean up multipart items attribute to prevent reuse
                request.removeAttribute("multipartItems");
                
                response.sendRedirect("showall.jsp");
                return;
            }
        } else {
            // Handle regular form submission (without file upload)
            String questionText  = nz(request.getParameter("question"), "");
            String opt1          = nz(request.getParameter("opt1"), "");
            String opt2          = nz(request.getParameter("opt2"), "");
            String opt3          = nz(request.getParameter("opt3"), "");
            String opt4          = nz(request.getParameter("opt4"), "");
            String correctAnswer = nz(request.getParameter("correct"), "");
            String courseName    = nz(request.getParameter("coursename"), "");
            String questionType  = nz(request.getParameter("questionType"), "");
            String orientation   = nz(request.getParameter("orientation"), "horizontal");
            boolean isAjax = "true".equalsIgnoreCase(request.getParameter("ajax"));
            
            if ("MultipleSelect".equalsIgnoreCase(questionType)) {
                String correctMultiple = nz(request.getParameter("correctMultiple"), "");
                if (!correctMultiple.isEmpty()) correctAnswer = correctMultiple;
            }
            
            String extraData = null;
            if ("DRAG_AND_DROP".equalsIgnoreCase(questionType)) {
                JSONObject extraDataObj = new JSONObject();
                extraDataObj.put("orientation", orientation);
                extraData = extraDataObj.toString();
            }
            
            int newQuestionIdInserted = pDAO.addNewQuestionReturnId(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, null, extraData);
            
            // Save drag and drop data using proper relational tables for DRAG_AND_DROP type
            if ("DRAG_AND_DROP".equalsIgnoreCase(questionType)) {
                try {
                    int newQuestionId = newQuestionIdInserted;
                    
                    // Get total marks from request parameter
                    int totalMarks = 1; // default
                    String totalMarksParam = request.getParameter("totalMarks");
                    if (totalMarksParam != null && !totalMarksParam.trim().isEmpty()) {
                        try {
                            totalMarks = Integer.parseInt(totalMarksParam.trim());
                        } catch (NumberFormatException e) {
                            application.log("Invalid totalMarks value: " + totalMarksParam + ", using default 1");
                        }
                    }
                    
                    // Collect drag items and targets
                    java.util.List<String> dragItemsList = new java.util.ArrayList<>();
                    java.util.List<String> dropTargetsList = new java.util.ArrayList<>();
                    java.util.List<String> dragCorrectTargetsList = new java.util.ArrayList<>();
                    
                    // Get drag items and their correct targets
                    Enumeration<String> paramNames = request.getParameterNames();
                    while (paramNames.hasMoreElements()) {
                        String paramName = paramNames.nextElement();
                        if (paramName.startsWith("dragItem_text_")) {
                            String itemText = nz(request.getParameter(paramName), "");
                            String targetParam = paramName.replace("dragItem_text_", "dragItem_target_");
                            String targetValue = nz(request.getParameter(targetParam), "");
                            
                            if (!itemText.trim().isEmpty()) {
                                dragItemsList.add(itemText);
                                dragCorrectTargetsList.add(targetValue);
                            }
                        }
                    }
                    
                    // Get drop targets
                    paramNames = request.getParameterNames();
                    while (paramNames.hasMoreElements()) {
                        String paramName = paramNames.nextElement();
                        if (paramName.startsWith("dropTarget_")) {
                            String targetLabel = nz(request.getParameter(paramName), "");
                            if (!targetLabel.trim().isEmpty()) {
                                dropTargetsList.add(targetLabel.trim());
                            }
                        }
                    }
                    
                    application.log("Regular form - Total marks for drag-drop: " + totalMarks);
                    application.log("Regular form - Drag items count: " + dragItemsList.size());
                    application.log("Regular form - Drop targets count: " + dropTargetsList.size());
                    application.log("Regular form - Correct targets count: " + dragCorrectTargetsList.size());

                    // Use the new clean relational method
                    pDAO.addDragDropData(newQuestionId, dragItemsList, dropTargetsList, dragCorrectTargetsList);

                    // Also persist a copy into questions table columns for visibility/debugging
                    pDAO.updateDragDropQuestionColumns(newQuestionId, dragItemsList, dropTargetsList, dragCorrectTargetsList, totalMarks);

                    application.log("=== DRAG DROP DATA SAVED USING RELATIONAL TABLES (REGULAR FORM) ===");

                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Error saving drag drop data", e);
                    session.setAttribute("error", "Question saved but drag drop data had errors: " + e.getMessage());
                }
            } else if ("REARRANGE".equalsIgnoreCase(questionType)) {
                try {
                    int newQuestionId = newQuestionIdInserted;
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
                    for (String val : itemsMap.values()) rearrangeItemsList.add(val);

                    pDAO.addRearrangeData(newQuestionId, rearrangeItemsList);

                    String displayStyle = nz(request.getParameter("rearrangeStyle"), "vertical");
                    org.json.JSONObject extraDataObj = new org.json.JSONObject();
                    extraDataObj.put("style", displayStyle);

                    Questions q = pDAO.getQuestionById(newQuestionId);
                    q.setExtraData(extraDataObj.toString());
                    pDAO.updateQuestion(q);

                    Integer totalMarks = null;
                    try {
                        String tmParam = request.getParameter("totalMarks");
                        if (tmParam != null) totalMarks = Integer.parseInt(tmParam);
                    } catch (Exception e) {}

                    pDAO.updateRearrangeQuestionJson(newQuestionId, pDAO.toJsonArray(rearrangeItemsList), totalMarks);
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Error saving rearrange data (regular)", e);
                }
            }
            
            session.setAttribute("message","Question added successfully");
            // Save last selections to session
            session.setAttribute("last_course_name", courseName);
            session.setAttribute("last_question_type", questionType);

            if (isAjax) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": true, \"message\": \"Question added successfully\", \"qid\": " + newQuestionIdInserted + "}");
                return;
            }

            courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("question-success.jsp?coursename=" + java.net.URLEncoder.encode(courseName, "UTF-8")+"&questionType="+questionType);
            } else {
                response.sendRedirect("question-success.jsp?questionType="+questionType);
            }
            return;
        }
    } else if ("submit_drag_drop".equalsIgnoreCase(operation)) {
        // Handle drag-drop answer submission
        String examIdStr = nz(request.getParameter("examId"), "");
        String questionIdStr = nz(request.getParameter("questionId"), "");
        String studentId = nz(request.getParameter("studentId"), "");
        
        if (examIdStr.isEmpty() || questionIdStr.isEmpty() || studentId.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Missing required parameters\"}");
            return;
        }
        
        try {
            int examId = Integer.parseInt(examIdStr);
            int questionId = Integer.parseInt(questionIdStr);
            
            // Parse the selected matches
            Map<Integer, Integer> selectedMatches = new HashMap<>();
            Enumeration<String> paramNames = request.getParameterNames();
            
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("match_")) {
                    String dragItemIdStr = paramName.substring(6); // Remove "match_" prefix
                    String targetIdStr = nz(request.getParameter(paramName), "");
                    
                    try {
                        int dragItemId = Integer.parseInt(dragItemIdStr);
                        int targetId = Integer.parseInt(targetIdStr);
                        selectedMatches.put(dragItemId, targetId);
                    } catch (NumberFormatException e) {
                        // Skip invalid parameters
                    }
                }
            }
            
            // Submit answers and get marks
            float marksObtained = pDAO.submitDragDropAnswers(examId, questionId, studentId, selectedMatches);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"marksObtained\": " + marksObtained + "}");
            return;
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error submitting drag-drop answers", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Failed to submit answers\"}");
            return;
        }
    } else if ("ai_generate".equalsIgnoreCase(operation)) {
        response.setContentType("application/json");
        PrintWriter outJSON = response.getWriter();
        String text = nz(request.getParameter("text"), "");
        String questionType = nz(request.getParameter("questionType"), "MCQ");
        boolean isMarkingGuideline = "true".equalsIgnoreCase(request.getParameter("isMarkingGuideline"));
        
        if (text.isEmpty()) {
            outJSON.print("{\"success\": false, \"message\": \"No text provided for AI generation.\"}");
            return;
        }
        
        int numQuestions = 10;
        String numQsParam = request.getParameter("numQuestions");
        if (numQsParam != null && !numQsParam.trim().isEmpty()) {
            try {
                numQuestions = Integer.parseInt(numQsParam.trim());
            } catch (NumberFormatException e) {}
        }
        
        try {
            String aiResponse = OpenRouterClient.generateQuestions(text, questionType, numQuestions, isMarkingGuideline);
            if (aiResponse == null || aiResponse.trim().isEmpty()) {
                outJSON.print("{\"success\": false, \"message\": \"AI generation failed or returned empty response.\"}");
                return;
            }

            // Clean AI response if it contains markdown
            if (aiResponse.contains("```json")) {
                aiResponse = aiResponse.substring(aiResponse.indexOf("```json") + 7);
                if (aiResponse.contains("```")) {
                    aiResponse = aiResponse.substring(0, aiResponse.indexOf("```"));
                }
            } else if (aiResponse.contains("```")) {
                aiResponse = aiResponse.substring(aiResponse.indexOf("```") + 3);
                if (aiResponse.contains("```")) {
                    aiResponse = aiResponse.substring(0, aiResponse.indexOf("```"));
                }
            }
            
            aiResponse = aiResponse.trim();
            
            try {
                // Try to parse as JSONArray first (preferred)
                if (aiResponse.startsWith("[")) {
                    JSONArray questionsArr = new JSONArray(aiResponse);
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    result.put("questions", questionsArr);
                    outJSON.print(result.toString());
                } else if (aiResponse.startsWith("{")) {
                    JSONObject resObj = new JSONObject(aiResponse);
                    if (resObj.has("questions")) {
                        resObj.put("success", true);
                        outJSON.print(resObj.toString());
                    } else if (resObj.has("question")) {
                        // Single question wrapped in object
                        JSONArray arr = new JSONArray();
                        arr.put(resObj);
                        JSONObject result = new JSONObject();
                        result.put("success", true);
                        result.put("questions", arr);
                        outJSON.print(result.toString());
                    } else {
                        outJSON.print("{\"success\": false, \"message\": \"AI returned JSON but no questions were found.\"}");
                    }
                } else {
                    // Try to find JSON within the text if it didn't start with [ or {
                    int firstBracket = aiResponse.indexOf("[");
                    int firstBrace = aiResponse.indexOf("{");
                    int start = -1;
                    if (firstBracket != -1 && (firstBrace == -1 || firstBracket < firstBrace)) start = firstBracket;
                    else if (firstBrace != -1) start = firstBrace;
                    
                    if (start != -1) {
                        String potentialJson = aiResponse.substring(start);
                        try {
                            if (potentialJson.startsWith("[")) {
                                JSONArray arr = new JSONArray(potentialJson);
                                JSONObject result = new JSONObject();
                                result.put("success", true);
                                result.put("questions", arr);
                                outJSON.print(result.toString());
                            } else {
                                JSONObject obj = new JSONObject(potentialJson);
                                obj.put("success", true);
                                outJSON.print(obj.toString());
                            }
                        } catch (JSONException je) {
                            outJSON.print("{\"success\": false, \"message\": \"Found potential JSON but failed to parse: " + je.getMessage() + "\"}");
                        }
                    } else {
                        outJSON.print("{\"success\": false, \"message\": \"AI returned non-JSON response.\"}");
                    }
                }
            } catch (JSONException e) {
                LOGGER.log(Level.WARNING, "JSON Parsing Error. Response was: " + aiResponse, e);
                outJSON.print("{\"success\": false, \"message\": \"Failed to parse AI JSON response: " + e.getMessage() + "\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in ai_generate", e);
            outJSON.print("{\"success\": false, \"message\": \"Internal Error: " + e.getMessage() + "\"}");
        }
        return;

    } else if ("extract_text".equalsIgnoreCase(operation)) {
        response.setContentType("application/json");
        PrintWriter outJSON = response.getWriter();
        
        try {
            if (ServletFileUpload.isMultipartContent(request)) {
                List<FileItem> items = (List<FileItem>) request.getAttribute("multipartItems");
                if (items == null) {
                    DiskFileItemFactory factory = new DiskFileItemFactory();
                    ServletFileUpload upload = new ServletFileUpload(factory);
                    items = upload.parseRequest(request);
                }

                String extractedText = "";
                boolean foundFile = false;

                for (FileItem item : items) {
                    if (!item.isFormField() && ("questionFile".equals(item.getFieldName()) || "pdfFile".equals(item.getFieldName()))) {
                        foundFile = true;
                        byte[] pdfBytes = item.get();
                        extractedText = PDFExtractor.extractCleanText(pdfBytes);
                        break;
                    }
                }

                if (foundFile) {
                    JSONObject res = new JSONObject();
                    res.put("success", true);
                    res.put("extractedText", extractedText);
                    outJSON.print(res.toString());
                } else {
                    outJSON.print("{\"success\": false, \"message\": \"No file found in request.\"}");
                }
            } else {
                outJSON.print("{\"success\": false, \"message\": \"Request is not multipart.\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error extracting text using PDFExtractor", e);
            outJSON.print("{\"success\": false, \"message\": \"Extraction error: " + e.getMessage() + "\"}");
        }
        return;

    } else {
        session.setAttribute("error", "Invalid operation for questions");
        String courseName = nz(request.getParameter("coursename"), "");
        if (!courseName.isEmpty()) {
            response.sendRedirect("showall.jsp?coursename=" + courseName);
        } else {
            response.sendRedirect("showall.jsp");
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
} else if ("saveAnswer".equalsIgnoreCase(pageParam)) {
    // Handle async answer saving during exam
    try {
        int qid = Integer.parseInt(nz(request.getParameter("qid"), "0"));
        String question = nz(request.getParameter("question"), "");
        String ans = nz(request.getParameter("ans"), "");
        
        Object examIdObj = session.getAttribute("examId");
        if (examIdObj != null && qid > 0) {
            int examId = Integer.parseInt(examIdObj.toString());
            pDAO.insertAnswer(examId, qid, question, ans);
            // application.log("Async save: QID " + qid + " -> " + ans);
        }
    } catch (Exception e) {
        application.log("Error in saveAnswer: " + e.getMessage());
    }
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
                    String qtype     = nz(request.getParameter("qtype"+i), "");
                    int qid         = Integer.parseInt(nz(request.getParameter("qid"+i), "0"));
                    
                    // Check if this is a multiple select question and get the hidden field value
                    String multiSelectAns = nz(request.getParameter("ans"+i+"-hidden"), "");
                    if (!multiSelectAns.isEmpty()) {
                        ans = multiSelectAns; // Use the multi-select answer instead
                    }
                    
                    // Handle drag-drop questions - FIXED JSON PARSING
                    if ("dragdrop".equals(qtype)) {
                        application.log("Processing drag-drop question " + qid + ": ans=" + ans);
                        if (ans != null && !ans.trim().isEmpty() && ans.startsWith("{")) {
                            try {
                                // Parse JSON mapping from format: {"target_15":"item_14","target_16":"item_15"}
                                java.util.Map<Integer, Integer> dragDropMatches = new java.util.HashMap<>();
                                
                                org.json.JSONObject userObj = new org.json.JSONObject(ans);
                                java.util.Iterator<String> keys = userObj.keys();
                                
                                while (keys.hasNext()) {
                                    String key = keys.next();
                                    // Key format: "target_15" or "zone_15"
                                    String value = userObj.getString(key);
                                    
                                    // Extract target ID from key
                                    Integer targetId = null;
                                    if (key.startsWith("target_")) {
                                        try {
                                            targetId = Integer.parseInt(key.substring(7));
                                        } catch (NumberFormatException e) {}
                                    } else if (key.startsWith("zone_")) {
                                        try {
                                            targetId = Integer.parseInt(key.substring(5));
                                        } catch (NumberFormatException e) {}
                                    }
                                    
                                    // Extract item ID from value
                                    Integer itemId = null;
                                    if (value.startsWith("item_")) {
                                        try {
                                            itemId = Integer.parseInt(value.substring(5));
                                        } catch (NumberFormatException e) {}
                                    }
                                    
                                    if (targetId != null && itemId != null) {
                                        // IMPORTANT: Map is itemId -> targetId
                                        dragDropMatches.put(itemId, targetId);
                                        application.log("Drag-drop match: item " + itemId + " -> target " + targetId);
                                    }
                                }
                                
                                if (!dragDropMatches.isEmpty() && userId > 0) {
                                    float marks = pDAO.submitDragDropAnswers(eId, qid, String.valueOf(userId), dragDropMatches);
                                    application.log("Drag-drop marks for Q" + qid + ": " + marks);
                                } else {
                                    application.log("Drag-drop: No matches found or invalid userId. Matches: " + dragDropMatches.size() + ", userId: " + userId);
                                }
                            } catch (Exception e) {
                                application.log("Error processing drag-drop JSON for Q" + qid + ": " + e.getMessage());
                            }
                        } else {
                            application.log("Drag-drop answer empty or invalid format for Q" + qid + ": " + ans);
                        }
                    }
                    
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