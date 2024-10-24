
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>


            <!-- SIDEBAR -->
            <div class="sidebar" style="background-color:#3b5998">
                <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
                    <div style="flex: 1;">
                        <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
                    </div>
                    <div class="left-menu">
                        <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
                        <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
                        <a class="active" href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
                        <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
                    </div>
                </div>
            </div>
            
            <!-- CONTENT AREA -->
            <div class="content-area" >
                <center>
        <%
           if(request.getParameter("coursename")!=null){
               ArrayList list=pDAO.getAllQuestions(request.getParameter("coursename"));
               for(int i=0;i<list.size();i++){
                   Questions question=(Questions)list.get(i);
                   
                   %>
                   <div class="question-panel">
						<div class="question" >
                                                    <label class="question-label"><%=i+1 %></label>
						<%=question.getQuestion() %>	
<a href="controller.jsp?page=questions&operation=delQuestion&qid=<%=question.getQuestionId() %>" 
                                                                             onclick="return confirm('Are you sure you want to delete this ?');" >
    <div class="delete-btn" style="position: absolute;right: 10px;top: -20px;">delete</div></a>
                                                </div>
						<div class="answer">
                                                        <label class="show"><%=question.getOpt1() %></label>
							<label class="show"><%=question.getOpt2() %></label>
							<label class="show"><%=question.getOpt3() %></label>
							<label class="show"><%=question.getOpt4() %></label>
                                                        <label class="show-correct"><%=question.getCorrect() %></label>
						</div>
					</div>
                   
                   <%
               }
          } %>
       </center>
            </div>