<%@page import="myPackage.DatabaseClass"%>
<%
    String email = request.getParameter("email");
    String userType = request.getParameter("user_type");
    
    if (email == null || userType == null) {
        response.sendRedirect("signup.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Email - Code SA Institute</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        :root { --primary: #09294D; --error: #dc3545; }
        body { background: #E5E5E5; min-height: 100vh; display: flex; align-items: center; }
        .auth-card { background: #fff; border-radius: 1rem; box-shadow: 0 12px 24px rgba(0,0,0,.08); }
        .auth-title { color: var(--primary); font-weight: 700; }
        .verification-input { 
            font-size: 2rem; 
            letter-spacing: 10px; 
            font-weight: bold; 
            text-align: center;
            height: 60px;
        }
        .error-message { color: var(--error); font-size: .875rem; }
        .code-container { position: relative; }
        .code-container input { padding-right: 60px; }
        .resend-btn { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-md-6 col-lg-4">
                <div class="auth-card p-4">
                    <div class="text-center mb-4">
                        <i class="fas fa-envelope-circle-check fa-3x text-primary mb-3"></i>
                        <h2 class="auth-title">Verify Your Email</h2>
                    </div>
                    
                    <p class="text-center text-muted mb-4">
                        We've sent an 8-character verification code to:<br>
                        <strong><%= email %></strong>
                    </p>
                    
                    <%@ include file="header-messages.jsp" %>
                    
                    <form action="controller.jsp" method="POST" id="verifyForm">
                        <input type="hidden" name="page" value="verify_code">
                        <input type="hidden" name="email" value="<%= email %>">
                        <input type="hidden" name="user_type" value="<%= userType %>">
                        
                        <div class="form-group">
                            <label for="code" class="form-label">Verification Code</label>
                            <div class="code-container">
                                <input type="text" 
                                       class="form-control verification-input" 
                                       id="code" 
                                       name="code" 
                                       maxlength="8"
                                       placeholder="XXXXXXXX"
                                       required
                                       autocomplete="off"
                                       autofocus>
                                <button type="button" class="btn btn-link resend-btn" id="resendBtn" title="Resend code">
                                    <i class="fas fa-redo"></i>
                                </button>
                            </div>
                            <small class="form-text text-muted">
                                Enter the 8-character code from your email
                            </small>
                            <span id="errorCode" class="error-message"></span>
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary btn-block btn-lg" id="verifyBtn">
                                <i class="fas fa-check-circle mr-2"></i> Verify & Complete Registration
                            </button>
                        </div>
                        
                        <div class="text-center mt-3">
                            <small class="text-muted">
                                <a href="signup.jsp?user_type=<%= userType %>" class="text-decoration-none">
                                    <i class="fas fa-arrow-left mr-1"></i> Back to Signup
                                </a>
                            </small>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            // Auto-focus and auto-submit for verification code
            $('#code').on('input', function(e) {
                // Allow only alphanumeric characters
                this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
                
                if (this.value.length === 8) {
                    $('#verifyBtn').click();
                }
            });
            
            // Form submission
            $('#verifyForm').on('submit', function(e) {
                e.preventDefault();
                
                const code = $('#code').val().trim();
                const errorSpan = $('#errorCode');
                
                if (code.length !== 8) {
                    errorSpan.text('Please enter the full 8-character code.');
                    return;
                }
                
                // Disable button and show loading
                $('#verifyBtn').prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Verifying...');
                
                // Submit form
                this.submit();
            });
            
            // Resend code functionality
            $('#resendBtn').on('click', async function() {
                const email = '<%= email %>';
                const userType = '<%= userType %>';
                const btn = $(this);
                
                btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>');
                
                try {
                    const formData = new FormData();
                    formData.append('email', email);
                    formData.append('user_type', userType);
                    formData.append('page', 'send_code');
                    
                    const response = await fetch('controller.jsp', {
                        method: 'POST',
                        body: formData
                    });
                    
                    const result = await response.json();
                    
                    if (result.success) {
                        alert('Verification code resent successfully! Check your email.');
                    } else {
                        alert('Error: ' + result.message);
                    }
                } catch (error) {
                    alert('Error resending code. Please try again.');
                } finally {
                    btn.prop('disabled', false).html('<i class="fas fa-redo"></i>');
                }
            });
            
            // Auto-resend after 2 minutes if not verified
            setTimeout(function() {
                if ($('#code').val().length !== 8) {
                    $('#resendBtn').trigger('click');
                }
            }, 120000); // 2 minutes
        });
    </script>
</body>
</html>