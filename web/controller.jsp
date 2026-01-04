<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%@ page import="myPackage.*" %>
<%@ page import="myPackage.classes.User" %>
<%@ page import="myPackage.classes.Questions" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>

<%!
    private String nz(String v, String fallback) {
        return (v != null && !v.trim().isEmpty()) ? v.trim() : fallback;
    }
%>

<%
DatabaseClass pDAO = DatabaseClass.getInstance();

try {

    String pageParam = request.getParameter("page");
    if (pageParam == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    /* =========================================================
       LOGIN
       ========================================================= */
    if ("login".equalsIgnoreCase(pageParam)) {

        String username = nz(request.getParameter("username"), "");
        String password = nz(request.getParameter("password"), "");

        if (pDAO.loginValidate(username, password)) {
            session.setAttribute("userStatus", "1");
            session.setAttribute("userId", pDAO.getUserId(username));

            request.setAttribute("targetUrl", "dashboard.jsp");
            request.setAttribute("message", "Logging you in...");
            request.setAttribute("delayMs", 5000);
            request.getRequestDispatcher("transition.jsp").forward(request, response);
            return;
        } else {
            session.setAttribute("error", "Invalid username or password");
            response.sendRedirect("login.jsp");
        }

    /* =========================================================
       REGISTER STUDENT
       ========================================================= */
    } else if ("register".equalsIgnoreCase(pageParam)) {

        String fname     = nz(request.getParameter("fname"), "");
        String lname     = nz(request.getParameter("lname"), "");
        String uname     = nz(request.getParameter("uname"), "");
        String email     = nz(request.getParameter("email"), "");
        String pass      = nz(request.getParameter("pass"), "");
        String contact   = nz(request.getParameter("contactno"), "");
        String city      = nz(request.getParameter("city"), "");
        String address   = nz(request.getParameter("address"), "");
        String userType  = nz(request.getParameter("user_type"), "");
        String fromPage  = nz(request.getParameter("from_page"), "");

        String hashed = PasswordUtils.bcryptHashPassword(pass);
        pDAO.addNewUser(fname, lname, uname, email, hashed, contact, city, address, userType);

        boolean adminFlow =
                "admin".equalsIgnoreCase(userType) ||
                "lecture".equalsIgnoreCase(userType) ||
                "account".equalsIgnoreCase(fromPage);

        session.setAttribute("message",
                adminFlow ? "Student added successfully!" : "Registration successful! Please login");

        response.sendRedirect(adminFlow ? "accounts.jsp" : "login.jsp");

    /* =========================================================
       REGISTER STAFF
       ========================================================= */
    } else if ("registerStaff".equalsIgnoreCase(pageParam)) {

        pDAO.addNewStaff(
                nz(request.getParameter("staffNum"), ""),
                nz(request.getParameter("email"), ""),
                nz(request.getParameter("fullNames"), ""),
                nz(request.getParameter("course_name"), "")
        );

        session.setAttribute("message", "Lecturer registered successfully!");
        response.sendRedirect("adm-page.jsp?pgprt=6");
        
    

    /* =========================================================
       PROFILE UPDATE
       ========================================================= */
    } else if ("profile".equalsIgnoreCase(pageParam)) {

        if (session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int uid = Integer.parseInt(session.getAttribute("userId").toString());
        User user = pDAO.getUserDetails(String.valueOf(uid));

        if (user == null) {
            session.setAttribute("error", "User not found");
            response.sendRedirect("login.jsp");
            return;
        }

        String contact = nz(request.getParameter("contactno"), "");
        String city    = nz(request.getParameter("city"), "");
        String address = nz(request.getParameter("address"), "");
        String course  = nz(request.getParameter("course_name"), "");

        boolean updated;

        if ("lecture".equalsIgnoreCase(user.getType())) {
            updated = pDAO.updateLecturer(
                    uid,
                    user.getFirstName(),
                    user.getLastName(),
                    user.getUserName(),
                    user.getEmail(),
                    user.getPassword(),
                    contact, city, address,
                    user.getType(),
                    course
            ) > 0;

            response.sendRedirect("adm-page.jsp?pgprt=0");
        } else {
            updated = pDAO.updateStudent(
                    uid,
                    user.getFirstName(),
                    user.getLastName(),
                    user.getUserName(),
                    user.getEmail(),
                    user.getPassword(),
                    contact, city, address,
                    user.getType()
            ) > 0;

            response.sendRedirect("std-page.jsp?pgprt=0");
        }

        session.setAttribute(updated ? "message" : "error",
                updated ? "Profile updated successfully!" : "Failed to update profile.");

    /* =========================================================
       LOGOUT
       ========================================================= */
    } else if ("logout".equalsIgnoreCase(pageParam)) {

        session.invalidate();
        request.setAttribute("targetUrl", "login.jsp");
        request.setAttribute("message", "Securely logging you out...");
        request.setAttribute("delayMs", 3000);
        request.getRequestDispatcher("transition.jsp").forward(request, response);
        return;

    /* =========================================================
       INVALID PAGE
       ========================================================= */
    } else {
        session.setAttribute("error", "Invalid page parameter");
        response.sendRedirect("login.jsp");
    }

} catch (Exception e) {
    session.setAttribute("error", "Unexpected error: " + e.getMessage());
    response.sendRedirect("error.jsp");
}
%>
