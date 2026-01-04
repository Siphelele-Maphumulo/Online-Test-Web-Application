
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="page-header">
    <div class="page-title"><i class="fas fa-calendar-check"></i> Daily Register</div>
</div>
<div class="course-card">
    <form action="controller.jsp" method="post">
        <input type="hidden" name="page" value="daily_register">
        <input type="hidden" name="operation" value="mark_attendance">
        <button type="submit" class="start-exam-btn">
            <i class="fas fa-check"></i> Mark Register
        </button>
    </form>
</div>
<div class="exam-wrapper">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <div class="left-menu">
                <a class="nav-item" href="std-page.jsp?pgprt=0"><i class="fas fa-user"></i><span>Profile</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=1"><i class="fas fa-file-alt"></i><span>Exams</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=2"><i class="fas fa-chart-line"></i><span>Results</span></a>
                <a class="nav-item active" href="std-page.jsp?pgprt=3"><i class="fas fa-calendar-check"></i><span>Daily Register</span></a>
                <a class="nav-item" href="std-page.jsp?pgprt=4"><i class="fas fa-eye"></i><span>View Attendance</span></a>
            </div>
        </nav>
    </aside>
</div>
