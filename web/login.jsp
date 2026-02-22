<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Login | MUT</title>

    <!-- Local CSS (FAST) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/all.min.css">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        
        :root {
            --primary-color: #09294D;
            --secondary-color: #0056b3;
            --error-color: #dc3545;
            --input-height: 3.125rem;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #dcdcdc, #c0c0c0);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .login-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            border-radius: 20px;
            box-shadow: 0 12px 30px rgba(0,0,0,.25);
            background: rgba(255,255,255,.15);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255,255,255,.3);
        }

        .card-header {
            text-align: center;
            padding: 1.5rem;
            color: #fff;
        }

        .card-header h2 {
            font-weight: 700;
            margin: 0;
        }

        .card-body {
            padding: 2rem;
            color: #fff;
        }

        .input-group {
            height: var(--input-height);
            margin-bottom: 1.2rem;
        }

        .input-group-text {
            width: 3rem;
            justify-content: center;
            background: #f1f3f5;
            border-right: none;
        }

        .form-control {
            border-left: none;
        }

        .form-control:focus {
            box-shadow: 0 0 0 .25rem rgba(9,41,77,.25);
            border-color: var(--primary-color);
        }

        .btn-login {
            height: calc(var(--input-height) + 10px);
            background: var(--primary-color);
            color: #fff;
            font-weight: 500;
            border-radius: 8px;
            width: 100%;
            max-width: 300px;
            margin: 10px auto 0;
        }

        .btn-login:hover {
            background: var(--secondary-color);
        }

        .forgot-password {
            display: block;
            text-align: center;
            margin-top: 1rem;
            color: #fff;
            font-size: .9rem;
            text-decoration: none;
        }

        .forgot-password:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

<!-- Header -->
<jsp:include page="header.jsp"/>

<%
    String sessionError   = (String) session.getAttribute("error");
    String sessionSuccess = (String) session.getAttribute("success");
%>

<div class="login-container">
    <div class="login-card">
        <div class="card-header">
            <h2><i class="fas fa-sign-in-alt me-2"></i>Login</h2>
        </div>

        <div class="card-body">
            <form method="post" action="controller.jsp">
                <input type="hidden" name="page" value="login"/>

                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                    <input type="text"
                           class="form-control"
                           name="username"
                           placeholder="MUT Identity Number"
                           required
                           autofocus>
                </div>

                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password"
                           class="form-control"
                           name="password"
                           placeholder="Password"
                           required>
                </div>

                <div class="d-grid gap-2">
                <button type="submit" class="btn btn-login">
                    <i class="fas fa-sign-in-alt me-2"></i>Login
                </button>
                </div>

                <a href="Forgot_Password.jsp" class="forgot-password">
                    <i class="fas fa-question-circle me-2"></i>Forgot Password?
                </a>
            </form>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="mt-auto">
    <jsp:include page="footer.jsp"/>
</footer>

<!-- Toasts -->
<div class="position-fixed top-0 end-0 p-3" style="z-index:1080">

    <!-- Error -->
    <div id="toastError" class="toast text-bg-danger border-0" data-bs-delay="5000">
        <div class="d-flex">
            <div class="toast-body">
                <%= sessionError != null ? sessionError : "" %>
            </div>
            <button class="btn-close btn-close-white m-auto me-2" data-bs-dismiss="toast"></button>
        </div>
    </div>

    <!-- Success -->
    <div id="toastSuccess" class="toast text-bg-success border-0 mt-2" data-bs-delay="4000">
        <div class="d-flex">
            <div class="toast-body">
                <%= sessionSuccess != null ? sessionSuccess : "" %>
            </div>
            <button class="btn-close btn-close-white m-auto me-2" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<!-- Bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function () {

    <% if (sessionError != null) { %>
        new bootstrap.Toast(document.getElementById('toastError')).show();
        <% session.removeAttribute("error"); %>
    <% } %>

    <% if (sessionSuccess != null) { %>
        new bootstrap.Toast(document.getElementById('toastSuccess')).show();
        <% session.removeAttribute("success"); %>
    <% } %>

});
</script>

</body>
</html>
