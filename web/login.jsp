<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="x-dns-prefetch-control" content="off"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="robots" content="noindex"/>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --header-login: #555555;
            --primary-color: #09294D;
            --secondary-color: #0056b3;
            --error-color: #dc3545;
            --light-gray: #f8f9fa;
            --input-height: 3.125rem; /* Consistent height for all inputs */
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            color: #333;
        }
        
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex: 1;
    padding: 2rem;
    background: linear-gradient(135deg, #dcdcdc, #c0c0c0); /* Background gradient */
    min-height: 100vh;
}

.login-card {
    width: 100%;
    max-width: 420px;
    border-radius: 20px;
    overflow: hidden;
    position: relative;
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
    background: rgba(255, 255, 255, 0.1); /* Semi-transparent for glass effect */
    backdrop-filter: blur(15px);
    border: 1px solid rgba(255, 255, 255, 0.3);
}

/* Optional shiny overlay */
.login-card::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
    transform: rotate(25deg);
    pointer-events: none;
    animation: shine 8s infinite linear;
    z-index: 1;
}

.card-header {
    position: relative;
    z-index: 2;
    background-color: transparent;
    color: white;
    text-align: center;
    padding: 1.5rem;
}

.card-header h2 {
    margin: 0;
    font-weight: 700;
    font-size: 1.8rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.card-body {
    position: relative;
    z-index: 2;
    padding: 2rem;
    background: rgba(255, 255, 255, 0.05);
    color: white;
}

/* Shine animation */
@keyframes shine {
    0% { transform: translateX(-100%) rotate(25deg); }
    100% { transform: translateX(100%) rotate(25deg); }
}
        
        /* Input Group Styling */
        .input-group {
            margin-bottom: 1.25rem;
            height: var(--input-height);
        }
        
        .input-group-text {
            background-color: #f1f3f5;
            border: 1px solid #ddd;
            border-right: none;
            border-radius: 8px 0 0 8px !important;
            width: 3rem;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
        }
        
        .input-group-text i {
            font-size: 1rem;
            color: #6c757d;
        }
        
        .form-control {
            height: 100%;
            padding: 0.75rem 1rem;
            border-radius: 0 8px 8px 0 !important;
            border: 1px solid #ddd;
            border-left: none;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.25rem rgba(9, 41, 77, 0.25);
        }
        
        .form-control.input-with-icon {
            padding-left: 0.75rem;
        }
        
        .btn-login {
            background-color: var(--primary-color);
            color: white;
            height: var(--input-height);
            border-radius: 8px;
            border: none;
            font-weight: 500;
            letter-spacing: 0.5px;
            transition: all 0.3s;
        }
        
        .btn-login:hover {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
        }
        
        .error-message {
            color: var(--error-color);
            font-size: 0.9rem;
            text-align: center;
            margin: 0.75rem 0;
            font-weight: 500;
        }
        
        .forgot-password {
            display: block;
            text-align: center;
            margin-top: 1rem;
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .forgot-password:hover {
            text-decoration: underline;
            color: var(--secondary-color);
        }
        
        footer {
            background-color: var(--light-gray);
            padding: 1rem 0;
            text-align: center;
            margin-top: auto;
        }
        
        /* Responsive adjustments */
        @media (max-width: 576px) {
            .login-container {
                padding: 1rem;
            }
            
            .card-body {
                padding: 1.5rem;
            }
            
            :root {
                --input-height: 2.75rem; /* Slightly smaller on mobile */
            }
        }
    </style>
    
    <title>Login | MUT</title>
</head>

<body>
    <!-- Include the header -->
    <jsp:include page="header.jsp" />

    <div class="login-container">
        <div class="card login-card">
            <div class="card-header">
                <h2><i class="fas fa-sign-in-alt me-2"></i>Login</h2>
            </div>
            <div class="card-body">
                <form method="post" action="controller.jsp">
                    <input type="hidden" name="page" value="login"> 
                    
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                        <input type="text" class="form-control input-with-icon" placeholder="MUT Identity Number" name="username" required>
                    </div>
                    
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" class="form-control input-with-icon" placeholder="Password" name="password" required>
                    </div>

                    <% if (request.getSession().getAttribute("userStatus") != null && request.getSession().getAttribute("userStatus").equals("-1")) { %>
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle me-2"></i>MUT Email or password is incorrect
                        </div>
                    <% } %>

                    <button type="submit" class="btn btn-login w-100 mb-3">
                        <i class="fas fa-sign-in-alt me-2"></i>Login
                    </button>
                    
                    <a class="forgot-password" href="#">
                        <i class="fas fa-question-circle me-2"></i>Forgot Password?
                    </a>
                </form>
            </div>
        </div>
    </div>

    <!-- Include the footer -->
    <footer class="mt-auto">
        <jsp:include page="footer.jsp" />
    </footer>

    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Focus on first input field when page loads
        document.addEventListener('DOMContentLoaded', function() {
            const usernameInput = document.querySelector('input[name="username"]');
            if (usernameInput) {
                usernameInput.focus();
            }
        });
    </script>
</body>
</html>