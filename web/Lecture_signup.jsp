<%@page import="myPackage.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>

<%
    String pageParam = request.getParameter("page");

    if (pageParam != null) {

        if (pageParam.equals("login")) {
            String userName = request.getParameter("username");
            String userPass = request.getParameter("password");

            if (pDAO.loginValidate(userName, userPass)) {
                session.setAttribute("userStatus", "1");
                session.setAttribute("userId", pDAO.getUserId(userName));
                response.sendRedirect("dashboard.jsp");
            } else {
                session.setAttribute("userStatus", "-1");
                response.sendRedirect("login.jsp");
            }
        }

        else if (pageParam.equals("register")) {

            String staffNum   = request.getParameter("staffNum"); // ANY value allowed
            String email      = request.getParameter("email");
            String fullNames  = request.getParameter("fullNames");
            String courseName = request.getParameter("course_name"); // NEW

            boolean lecturerExists = pDAO.checkLecturerByEmail(email);

            if (lecturerExists) {
                request.setAttribute("error", "Lecturer with this email already exists.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // No restriction on staff number
            // Updated to include course_name
            pDAO.addNewStaff(staffNum, email, fullNames, courseName);

            response.sendRedirect("success.jsp");
        }

        else if (pageParam.equals("logout")) {
            session.invalidate();
            response.sendRedirect("index.jsp");
        }
    }
%>





