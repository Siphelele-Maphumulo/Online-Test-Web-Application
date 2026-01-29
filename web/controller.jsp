<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.*" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.logging.Level" %>
<%@ page import="java.util.logging.Logger" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>
<%@ page import="myPackage.classes.Courses" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="org.apache.pdfbox.pdmodel.PDDocument" %>
<%@ page import="org.apache.pdfbox.text.PDFTextStripper" %>
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

        if ("getCourseData".equalsIgnoreCase(operation)) {
            String courseName = nz(request.getParameter("courseName"), "");
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            if (courseName.isEmpty()) {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Course name is required");
                out.print(error.toString());
                return;
            }

            // Fetch directly from DB here to avoid requiring a rebuilt DatabaseClass on the server classpath.
            try {
                Connection conn = pDAO.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT course_name, total_marks, time, exam_date FROM courses WHERE course_name = ?"
                );
                ps.setString(1, courseName);
                ResultSet rs = ps.executeQuery();

                if (!rs.next()) {
                    JSONObject error = new JSONObject();
                    error.put("success", false);
                    error.put("message", "Course not found");
                    out.print(error.toString());
                    rs.close();
                    ps.close();
                    return;
                }

                JSONObject json = new JSONObject();
                json.put("success", true);
                json.put("courseName", rs.getString("course_name"));
                json.put("totalMarks", rs.getInt("total_marks"));
                json.put("time", rs.getString("time"));
                json.put("examDate", rs.getString("exam_date"));
                out.print(json.toString());

                rs.close();
                ps.close();
                return;
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "getCourseData failed", ex);
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Server error: " + ex.getMessage());
                out.print(error.toString());
                return;
            }
        }

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

        if (sessionToken == null || !sessionToken.equals(submittedToken)) {
            session.setAttribute("error", "Invalid request. Please try again.");
            String courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                // Redirect back to the showall page with an error
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
        if (!qid.isEmpty()) {
            boolean success = pDAO.deleteQuestion(Integer.parseInt(qid));
            if (success) {
                session.setAttribute("message","Question deleted successfully");
                // Force full page refresh by redirecting to showall.jsp
                String courseName = nz(request.getParameter("coursename"), "");
                String timestamp = String.valueOf(new Date().getTime());
                if (!courseName.isEmpty()) {
                    // Add cache-busting parameter to ensure fresh page load
                    response.sendRedirect("showall.jsp?coursename=" + courseName + "&_=" + timestamp);
                } else {
                    response.sendRedirect("showall.jsp?_=" + timestamp);
                }
                return;
            } else {
                session.setAttribute("error", "Failed to delete question ID: " + qid);
            }
        }
        // Redirect to showall.jsp even if no question ID was provided
        String courseName = nz(request.getParameter("coursename"), "");
        String timestamp = String.valueOf(new Date().getTime());
        if (!courseName.isEmpty()) {
            response.sendRedirect("showall.jsp?coursename=" + courseName + "&_=" + timestamp);
        } else {
            response.sendRedirect("showall.jsp?_=" + timestamp);
        }
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
                        
                        pDAO.updateQuestion(question);
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
                        } else if ("correctMultiple".equals(fieldName)) {
                            correctMultiple = nz(fieldValue, "");
                        }
                    } else {
                        // Process file upload field - ONLY ACCEPT IMAGES
                        String fieldName = item.getFieldName();
                        String fileName = item.getName();
                        
                        if (fieldName.equals("imageFile") && fileName != null && !fileName.isEmpty()) {
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
                
                pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, imagePath);
                session.setAttribute("message","Question added successfully");
                
                // Save last selections to session
                session.setAttribute("last_course_name", courseName);
                session.setAttribute("last_question_type", questionType);
                
                // Clean up multipart items attribute to prevent reuse
                request.removeAttribute("multipartItems");
                
                if (!courseName.isEmpty()) {
                    response.sendRedirect("showall.jsp?coursename=" + courseName);
                } else {
                    response.sendRedirect("showall.jsp");
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
            
            if ("MultipleSelect".equalsIgnoreCase(questionType)) {
                String correctMultiple = nz(request.getParameter("correctMultiple"), "");
                if (!correctMultiple.isEmpty()) correctAnswer = correctMultiple;
            }
            
            pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, null);
            session.setAttribute("message","Question added successfully");
            
            // Save last selections to session
            session.setAttribute("last_course_name", courseName);
            session.setAttribute("last_question_type", questionType);
            
            courseName = nz(request.getParameter("coursename"), "");
            if (!courseName.isEmpty()) {
                response.sendRedirect("showall.jsp?coursename=" + courseName);
            } else {
                response.sendRedirect("showall.jsp");
            }
        }
    } else if ("save_selection".equalsIgnoreCase(operation)) {
        // Save last course name and question type to session
        String lastCourseName = nz(request.getParameter("last_course_name"), "");
        String lastQuestionType = nz(request.getParameter("last_question_type"), "");
        
        if (!lastCourseName.isEmpty()) {
            session.setAttribute("last_course_name", lastCourseName);
        }
        if (!lastQuestionType.isEmpty()) {
            session.setAttribute("last_question_type", lastQuestionType);
        }
        
        // Return success response for AJAX
        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true}");
        return;
    } else if ("pdf_upload".equalsIgnoreCase(request.getParameter("action"))) {
        // Handle PDF upload and text extraction
        response.setContentType("application/json");
        PrintWriter outJSON = response.getWriter();
        
        // Check if PDFBox is available
        try {
            Class.forName("org.apache.pdfbox.pdmodel.PDDocument");
            Class.forName("org.apache.pdfbox.text.PDFTextStripper");
        } catch (Throwable e) {
            LOGGER.log(Level.WARNING, "PDFBox libraries not found", e);
            outJSON.print("{\"success\": false, \"message\": \"PDF processing libraries not installed or incompatible. Please add Apache PDFBox to WEB-INF/lib.\"}");
            return;
        }
        
        if (ServletFileUpload.isMultipartContent(request)) {
            List<FileItem> items = (List<FileItem>) request.getAttribute("multipartItems");
            
            if (items == null) {
                DiskFileItemFactory factory = new DiskFileItemFactory();
                ServletFileUpload upload = new ServletFileUpload(factory);
                try {
                    items = upload.parseRequest(request);
                } catch (Exception parseEx) {
                    LOGGER.log(Level.SEVERE, "Error parsing multipart PDF upload", parseEx);
                    JSONObject err = new JSONObject();
                    err.put("success", false);
                    err.put("message", "Error parsing upload: " + parseEx.getMessage());
                    outJSON.print(err.toString());
                    return;
                }
            }
            
            String extractedText = "";
            boolean success = false;
            
            try {
                for (FileItem item : items) {
                    if (!item.isFormField() && "pdfFile".equals(item.getFieldName())) {
                        try {
                            byte[] pdfBytes = item.get();
                            PDDocument document = null;
                            try {
                                // Load PDF via reflection to support multiple PDFBox versions.
                                // This avoids compile errors when certain overloads do not exist.
                                try {
                                    java.lang.reflect.Method m = PDDocument.class.getMethod("load", byte[].class);
                                    document = (PDDocument) m.invoke(null, pdfBytes);
                                } catch (NoSuchMethodException noByteArrayLoad) {
                                    try {
                                        java.io.InputStream in = new java.io.ByteArrayInputStream(pdfBytes);
                                        java.lang.reflect.Method m = PDDocument.class.getMethod("load", java.io.InputStream.class);
                                        document = (PDDocument) m.invoke(null, in);
                                    } catch (NoSuchMethodException noStreamLoad) {
                                        // Last resort: Loader.loadPDF (may still fail if PDFBox jars are inconsistent)
                                        Class<?> loaderClass = Class.forName("org.apache.pdfbox.Loader");
                                        java.lang.reflect.Method loadMethod = loaderClass.getMethod("loadPDF", byte[].class);
                                        document = (PDDocument) loadMethod.invoke(null, pdfBytes);
                                    }
                                }

                                PDFTextStripper stripper = new PDFTextStripper();
                                extractedText = stripper.getText(document);
                                success = true;
                            } finally {
                                if (document != null) {
                                    try { document.close(); } catch (Exception ignore) {}
                                }
                            }
                        } catch (Throwable loadError) {
                            Throwable root = loadError;
                            if (root instanceof java.lang.reflect.InvocationTargetException) {
                                Throwable target = ((java.lang.reflect.InvocationTargetException) root).getTargetException();
                                if (target != null) root = target;
                            }
                            while (root.getCause() != null && root.getCause() != root) {
                                root = root.getCause();
                            }

                            String technical = String.valueOf(root);
                            String message = "Error loading PDF: " + technical;
                            if (technical.contains("IOUtils.createMemoryOnlyStreamCache")) {
                                message = "PDFBox libraries are incompatible/mismatched (mixed versions in WEB-INF/lib). Please keep a single consistent PDFBox version set (e.g. pdfbox-3.0.6 + pdfbox-io-3.0.6 + fontbox-3.0.6) and remove older pdfbox-app/pdfbox-tools jars.";
                            }

                            LOGGER.log(Level.WARNING, message, loadError);
                            JSONObject err = new JSONObject();
                            err.put("success", false);
                            err.put("message", message);
                            outJSON.print(err.toString());
                            return;
                        }
                    }
                }
                
                if (success) {
                    JSONObject responseJson = new JSONObject();
                    responseJson.put("success", true);
                    responseJson.put("extractedText", extractedText);
                    outJSON.print(responseJson.toString());
                } else {
                    outJSON.print("{\"success\": false, \"message\": \"No PDF file found in request.\"}");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error extracting text from PDF", e);
                outJSON.print("{\"success\": false, \"message\": \"Error extracting text: " + e.getMessage() + "\"}");
            }
        } else {
            outJSON.print("{\"success\": false, \"message\": \"Not a multipart request.\"}");
        }
        return;
    } else if ("ai_generate".equalsIgnoreCase(operation)) {
        response.setContentType("application/json");
        PrintWriter outJSON = response.getWriter();
        String text = nz(request.getParameter("text"), "");
        String questionType = nz(request.getParameter("questionType"), "MCQ");
        
        if (text.isEmpty()) {
            outJSON.print("{\"success\": false, \"message\": \"No text provided for AI generation.\"}");
            return;
        }
        
        // Step 1: Decide Question Count
        int wordCount = text.split("\\s+").length;
        int numQuestions;
        String numQsParam = request.getParameter("numQuestions");
        
        if (numQsParam != null && !numQsParam.trim().isEmpty()) {
            try {
                numQuestions = Integer.parseInt(numQsParam.trim());
            } catch (NumberFormatException e) {
                if (wordCount < 300) numQuestions = 5;
                else if (wordCount < 800) numQuestions = 10;
                else numQuestions = 20;
            }
        } else {
            if (wordCount < 300) numQuestions = 5;
            else if (wordCount < 800) numQuestions = 10;
            else numQuestions = 20;
        }
        
        try {
            String aiResponse = OpenRouterClient.generateQuestions(text, questionType, numQuestions);
            if (aiResponse != null) {
                try {
                    // Clean up potential markdown code blocks
                    if (aiResponse.contains("```json")) {
                        aiResponse = aiResponse.substring(aiResponse.indexOf("```json") + 7);
                        aiResponse = aiResponse.substring(0, aiResponse.indexOf("```"));
                    } else if (aiResponse.contains("```")) {
                        aiResponse = aiResponse.substring(aiResponse.indexOf("```") + 3);
                        aiResponse = aiResponse.substring(0, aiResponse.indexOf("```"));
                    }
                    
                    JSONObject rawJson;
                    if (aiResponse.trim().startsWith("[")) {
                        JSONArray questions = new JSONArray(aiResponse);
                        rawJson = new JSONObject();
                        rawJson.put("questions", questions);
                    } else {
                        rawJson = new JSONObject(aiResponse);
                    }

                    // Step 7: Validation (Safety Net)
                    JSONArray questions = rawJson.getJSONArray("questions");
                    JSONArray validatedQuestions = new JSONArray();
                    
                    for (int i = 0; i < questions.length(); i++) {
                        JSONObject q = questions.getJSONObject(i);
                        String qText = nz(q.optString("question"), "");
                        JSONArray opts = q.optJSONArray("options");
                        String correct = nz(q.optString("correct"), "");
                        
                        if (qText.isEmpty() || correct.isEmpty()) continue;
                        
                        // Professional Sanitization: Remove "Q1:", "Question 1:" prefixes
                        qText = qText.replaceAll("^(?i)Q\\d+[:.\\s]+", "");
                        qText = qText.replaceAll("^(?i)Question\\s+\\d+[:.\\s]+", "");
                        q.put("question", qText.trim());

                        boolean isValid = false;
                        if ("FillInTheBlank".equalsIgnoreCase(questionType)) {
                            isValid = true; // FIB doesn't need options
                        } else if ("MultipleSelect".equalsIgnoreCase(questionType)) {
                            if (opts != null && opts.length() == 4) {
                                // For MultipleSelect, ensure correct answer contains valid options
                                String[] correctParts = correct.split("\\|");
                                int validParts = 0;
                                for (String part : correctParts) {
                                    for (int j = 0; j < opts.length(); j++) {
                                        if (opts.getString(j).trim().equalsIgnoreCase(part.trim())) {
                                            validParts++;
                                            break;
                                        }
                                    }
                                }
                                if (validParts > 0) isValid = true;
                            }
                        } else {
                            // Default MCQ/TrueFalse/Code
                            if (opts != null && opts.length() == 4) {
                                for (int j = 0; j < opts.length(); j++) {
                                    if (opts.getString(j).trim().equalsIgnoreCase(correct.trim())) {
                                        isValid = true;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if (isValid) {
                            q.put("type", questionType);
                            validatedQuestions.put(q);
                        }
                    }
                    
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    result.put("questions", validatedQuestions);
                    outJSON.print(result.toString());
                    
                } catch (Exception parseEx) {
                    LOGGER.log(Level.WARNING, "Failed to parse AI response as JSON: " + aiResponse, parseEx);
                    outJSON.print("{\"success\": false, \"message\": \"AI returned invalid format.\"}");
                }
            } else {
                outJSON.print("{\"success\": false, \"message\": \"AI generation failed. Please try again later.\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in AI generation endpoint", e);
            outJSON.print("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
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
                    
                    // Check if this is a multiple select question and get the hidden field value
                    String multiSelectAns = nz(request.getParameter("ans"+i+"-hidden"), "");
                    if (!multiSelectAns.isEmpty()) {
                        ans = multiSelectAns; // Use the multi-select answer instead
                    }
                    
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