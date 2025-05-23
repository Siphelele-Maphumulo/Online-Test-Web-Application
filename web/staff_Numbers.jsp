<%@page import="java.time.LocalTime"%>
<%@page import="myPackage.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<%
    String pageParam = request.getParameter("page");
    
    if (pageParam != null) {
        // Handle login functionality
        if (pageParam.equals("login")) {
            String userName = request.getParameter("username");
            String userPass = request.getParameter("password");

            if (pDAO.loginValidate(userName, userPass)) {
                session.setAttribute("userStatus", "1");
                session.setAttribute("userId", pDAO.getUserId(userName));
                response.sendRedirect("dashboard.jsp");
            } else {
                request.getSession().setAttribute("userStatus", "-1");
                response.sendRedirect("login.jsp");
            }
        }

        else if (pageParam.equals("register")) {
            // Handle registration of lecturers
            String staffNum = request.getParameter("staffNum");
            String email = request.getParameter("email");
            String fullNames = request.getParameter("fullNames");

            // Check if lecturer already exists
            boolean lecturerExists = pDAO.checkLecturerByEmail(email);
            
            if (lecturerExists) {
                System.out.println("Lecturer with email " + email + " exists.");
                request.setAttribute("error", "Lecturer with this email already exists.");
                // You might want to send the request to a page that includes the modal
                request.getRequestDispatcher("register.jsp").forward(request, response);
            } else {
                System.out.println("Adding new lecturer: " + fullNames);
                pDAO.addNewStaff(staffNum, email, fullNames);
                response.sendRedirect("success.jsp"); // Redirect to a success page or wherever
            }
        }

        else if (pageParam.equals("logout")) {
            // Handle logout
            session.setAttribute("userStatus", "0");
            session.removeAttribute("examId");
            session.removeAttribute("examStarted");
            response.sendRedirect("index.jsp");
        }
    }
%> 