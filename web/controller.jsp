
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.time.LocalTime"%>
<%@page import="myPackage.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<%
if (request.getParameter("page").toString().equals("login")) {
    String userName = request.getParameter("username").toString();
    String userPass = request.getParameter("password").toString();

    if (pDAO.loginValidate(userName, userPass)) {
        session.setAttribute("userStatus", "1");
        session.setAttribute("userId", pDAO.getUserId(userName));
        response.sendRedirect("dashboard.jsp");
    } else {
        request.getSession().setAttribute("userStatus", "-1");
        response.sendRedirect("login.jsp");
    }

    }else if (request.getParameter("page").toString().equals("register")) {
    String fName = request.getParameter("fname");
    String lName = request.getParameter("lname");
    String uName = request.getParameter("uname");  
    String email = request.getParameter("email");
    String pass = request.getParameter("pass");
    String contactNo = request.getParameter("contactno");
    String city = request.getParameter("city");
    String address = request.getParameter("address");
    
    // Hash the password using BCrypt before saving to the database
    String hashedPass = PasswordUtils.bcryptHashPassword(pass);
    System.out.println("My hashed pass: "+ hashedPass);

    // Check if the lecturer's email exists
    boolean lecturerExists = pDAO.checkLecturerByEmail(email);
    
    // Log to console whether it exists or not
    if (lecturerExists) {
        System.out.println("Lecturer with email " + email + " exists.");
    } else {
        System.out.println("Lecturer with email " + email + " does not exist.");
    }

    // Assume you generate or retrieve studentId from somewhere
    String studentId = "STD-" + UUID.randomUUID().toString(); // Example of generating a student ID

    // Proceed with student registration using the hashed password and studentId
    pDAO.addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, studentId);

    // Redirect to login.jsp after successful registration
    response.sendRedirect("login.jsp");
}

else if(request.getParameter("page").toString().equals("profile")){
        
        String fName =request.getParameter("fname");
        String lName =request.getParameter("lname");
        String uName=request.getParameter("uname");
        String email=request.getParameter("email");
        String pass=request.getParameter("pass");
        String contactNo =request.getParameter("contactno");
        String city =request.getParameter("city");
        String address =request.getParameter("address");
         String uType =request.getParameter("utype");
        int uid=Integer.parseInt(session.getAttribute("userId").toString());
    
         
    pDAO.updateStudent(uid,fName,lName,uName,email,pass,contactNo,city,address,uType);
    response.sendRedirect("dashboard.jsp");
}else if(request.getParameter("page").toString().equals("courses")) {
    if(request.getParameter("operation").toString().equals("addnew")) {
        String courseName = request.getParameter("coursename");
        int totalMarks = Integer.parseInt(request.getParameter("totalmarks"));
        String time = request.getParameter("time");
        String examDate = request.getParameter("examdate"); // New exam date parameter

        // Pass the examDate to the addNewCourse method
        pDAO.addNewCourse(courseName, totalMarks, time, examDate);
        
        response.sendRedirect("adm-page.jsp?pgprt=2");
    } else if(request.getParameter("operation").toString().equals("del")) {
        pDAO.delCourse(request.getParameter("cname").toString());
        response.sendRedirect("adm-page.jsp?pgprt=2");
    }
}
else if(request.getParameter("page").toString().equals("accounts")) {
    String operation = request.getParameter("operation");
    int userId = Integer.parseInt(request.getParameter("uid"));

    if (operation.equals("del")) {
        pDAO.delStudent(userId);
        response.sendRedirect("adm-page.jsp?pgprt=1"); // Redirect to the accounts page after deletion
    }

}

else if(request.getParameter("page").toString().equals("Lecturers_accounts")) {
    if (request.getParameter("operation").equals("del")) {
        int userId = Integer.parseInt(request.getParameter("uid"));
        pDAO.deleteLecturer(userId);
        response.sendRedirect("adm-page.jsp?pgprt=6"); // Redirect back to the lecturers accounts page after deletion
    }
}

if (request.getParameter("page") != null && request.getParameter("page").equals("questions")) {
    String operation = request.getParameter("operation");

    // Handling delete operation
    if (operation != null && operation.equals("del")) {
        String questionIdParam = request.getParameter("qid");
        if (questionIdParam != null && !questionIdParam.isEmpty()) {
            try {
                int questionId = Integer.parseInt(questionIdParam);
                pDAO.deleteQuestion(questionId); // Call the delete method
                response.sendRedirect("adm-page.jsp?pgprt=3"); // Redirect after deletion
            } catch (NumberFormatException e) {
                out.println("Error: Invalid question ID format.");
            } catch (Exception e) {
                out.println("Error: An exception occurred while deleting the question.");
            }
        } else {
            out.println("Error: Question ID is invalid.");
        }
    }
    
    // Handling edit operation
else if (operation != null && operation.equals("edit")) {
    String questionIdParam = request.getParameter("qid");
    if (questionIdParam != null && !questionIdParam.isEmpty()) {
        try {
            int questionId = Integer.parseInt(questionIdParam);
            Questions question = pDAO.getQuestionById(questionId);
            if (question != null) {
                // Retrieve updated parameters from the form
                String updatedQuestionText = request.getParameter("question");
                String updatedOpt1 = request.getParameter("opt1");
                String updatedOpt2 = request.getParameter("opt2");
                String updatedOpt3 = request.getParameter("opt3");
                String updatedOpt4 = request.getParameter("opt4");
                String updatedCorrectAnswer = request.getParameter("correct");
                String courseName = request.getParameter("coursename"); // Get selected course

                // Update the question object with new values
                question.setQuestion(updatedQuestionText);
                question.setOpt1(updatedOpt1);
                question.setOpt2(updatedOpt2);
                question.setOpt3(updatedOpt3);
                question.setOpt4(updatedOpt4);
                question.setCorrect(updatedCorrectAnswer);
                question.setCourseName(courseName); // Set the new course name

                // Save changes to the database
                boolean success = pDAO.updateQuestion(question);
                if (success) {
                    response.sendRedirect("adm-page.jsp?pgprt=3"); 
                } else {
                    out.println("Error: Could not update the question.");
                }
            } else {
                out.println("Error: Question not found.");
            }
        } catch (NumberFormatException e) {
            out.println("Error: Invalid question ID format.");
        } catch (Exception e) {
            out.println("Error: An exception occurred while editing the question.");
        }
    } else {
        out.println("Error: Question ID is invalid.");
    }
}

    // Handling add operation
    else if (operation != null && operation.equals("addnew")) {
        String questionText = request.getParameter("question");
        String opt1 = request.getParameter("opt1");
        String opt2 = request.getParameter("opt2");
        String opt3 = request.getParameter("opt3");
        String opt4 = request.getParameter("opt4");
        String correctAnswer = request.getParameter("correct");
        String courseName = request.getParameter("coursename");
        String questionType = request.getParameter("questionType");

        pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType);
        response.sendRedirect("adm-page.jsp?pgprt=3"); // Redirect after adding the question
    }
}



else if(request.getParameter("page").toString().equals("exams")){
    if(request.getParameter("operation").toString().equals("startexam")){
        String cName=request.getParameter("coursename");
        int userId=Integer.parseInt(session.getAttribute("userId").toString());
        
        int examId=pDAO.startExam(cName,userId);
        session.setAttribute("examId",examId);
        session.setAttribute("examStarted","1");
        response.sendRedirect("std-page.jsp?pgprt=1&coursename="+cName);
    }else if(request.getParameter("operation").toString().equals("submitted")){
        try{
        String time=LocalTime.now().toString();
        int size=Integer.parseInt(request.getParameter("size"));
        int eId=Integer.parseInt(session.getAttribute("examId").toString());
        int tMarks=Integer.parseInt(request.getParameter("totalmarks"));
        session.removeAttribute("examId");
        session.removeAttribute("examStarted");
        for(int i=0;i<size;i++){
            String question=request.getParameter("question"+i);
            String ans=request.getParameter("ans"+i);
            
            int qid=Integer.parseInt(request.getParameter("qid"+i));
            
            pDAO.insertAnswer(eId,qid,question,ans);
        }
        System.out.println(tMarks+" conn\t Size: "+size);
        pDAO.calculateResult(eId,tMarks,time,size);
        
        response.sendRedirect("std-page.jsp?pgprt=1&eid="+eId+"&showresult=1");
        }catch(Exception e){
            e.printStackTrace();
        }
        
        
    }

}else if(request.getParameter("page").toString().equals("logout")){
    session.setAttribute("userStatus","0");
    session.removeAttribute("examId");
    session.removeAttribute("examStarted");
    response.sendRedirect("login.jsp");
}



%>
