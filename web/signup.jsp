<%@page import="myPackage.classes.User"%>
<%@page import="java.net.URL"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Register New User</title>

  <!-- Bootstrap and Font Awesome -->
  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
  
  <!-- Include modal assets -->
  <%@ include file="modal_assets.jspf" %>

  <style>
    :root{ --primary:#09294D; --error:#dc3545; }
    body{ background:#E5E5E5; min-height:100vh; display:flex; flex-direction:column; }
    .auth-card{ background:#fff; border:1px solid rgba(9,41,77,.12); border-radius:1rem; box-shadow:0 12px 24px rgba(0,0,0,.08); }
    .auth-title{ color:var(--primary); font-weight:700; letter-spacing:.2px; }
    .input-icon{ position:relative; }
    .input-icon > i{ position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--primary); opacity:.6; pointer-events:none; }
    .input-icon input{ padding-left:40px; }
    .toggle-password{ position:absolute; right:12px; top:50%; transform:translateY(-50%); color:#777; cursor:pointer; }
    .error-message{ color:var(--error); font-size:.875rem; margin-top:4px; }
    .form-row > .col-md-6{ margin-bottom:1rem; }
    .btn-auth{ background:linear-gradient(135deg, var(--primary), #1e4580); border:none; }
    .btn-auth:hover{ background:#1e4580; }
    
    @media (max-width:575.98px){ .auth-card{ border-radius:.75rem; } .auth-title{ font-size:1.25rem; } }
  </style>
</head>
<%
    // IMPORTANT: Set response encoding
    response.setContentType("text/html;charset=UTF-8");
    
    // Get parameters
    String userType = request.getParameter("user_type");
    if (userType == null) {
        userType = "student";
    }
    String fromPage = request.getParameter("from");
    
    String title = "Create your account";
    String subtitle = "Please fill in your details to sign up.";
    if ("student".equalsIgnoreCase(userType)) {
        title = "Creating Student Account";
        subtitle = "You are creating a student account.";
    } else if ("lecture".equalsIgnoreCase(userType) || "lecturer".equalsIgnoreCase(userType)) {
        title = "Creating Lecturer Account";
        subtitle = "You are creating a lecturer account with elevated privileges.";
    } else if ("admin".equalsIgnoreCase(userType)) {
        title = "Creating Administrator Account";
        subtitle = "You are creating an administrator account with elevated privileges.";
    }
    
    String emailLabel = "Email";
    if ("student".equalsIgnoreCase(userType)) {
        emailLabel = "Student account email";
    } else if ("lecture".equalsIgnoreCase(userType) || "lecturer".equalsIgnoreCase(userType)) {
        emailLabel = "Lecturer account email";
    } else if ("admin".equalsIgnoreCase(userType)) {
        emailLabel = "Administrator account email";
    }
    
    // Get session messages
    String sessionError = (String) session.getAttribute("error");
    String sessionSuccess = (String) session.getAttribute("success");
    String sessionMessage = (String) session.getAttribute("message");
    String urlError = request.getParameter("error");
%>

<body>

<!-- Header -->
<jsp:include page="header.jsp" />


<!-- Main -->
<main class="flex-fill d-flex align-items-center">
    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-12 col-md-10 col-lg-8 col-xl-6">
                <div class="auth-card p-4 p-md-5">
                    <h2 class="auth-title h4 mb-3 text-center"><%= title %></h2>
                    <p class="text-center text-muted mb-4"><%= subtitle %></p>

                    <!-- SINGLE FORM ELEMENT - No nested forms! -->
                    <form id="registerForm" action="controller.jsp" method="POST">
                        <input type="hidden" name="page" value="register"/>
                        <input type="hidden" id="hiddenUserType" name="user_type" value="<%= userType %>"/>
                        <% if (fromPage != null) { %>
                            <input type="hidden" name="from_page" value="<%= fromPage %>"/>
                        <% } %>
                        
                        <% if (session.getAttribute("userId") != null) { %>
                            <input type="hidden" name="referrer_id" value="<%= session.getAttribute("userId") %>"/>
                        <% } %>

                        <div class="form-row">
                            <!-- First Name -->
                            <div class="col-12 col-md-6">
                                <label class="sr-only" for="fname">First Name</label>
                                <div class="input-icon">
                                    <i class="fas fa-user"></i>
                                    <input id="fname" type="text" name="fname" class="form-control" placeholder="First Name" 
                                           value="<%= request.getAttribute("fname") != null ? request.getAttribute("fname") : "" %>" required/>
                                </div>
                                <span id="errorFirstName" class="error-message"></span>
                            </div>

                            <!-- Last Name -->
                            <div class="col-12 col-md-6">
                                <label class="sr-only" for="lname">Last Name</label>
                                <div class="input-icon">
                                    <i class="fas fa-user"></i>
                                    <input id="lname" type="text" name="lname" class="form-control" placeholder="Last Name" 
                                           value="<%= request.getAttribute("lname") != null ? request.getAttribute("lname") : "" %>" required/>
                                </div>
                                <span id="errorLastName" class="error-message"></span>
                            </div>

                            <!-- ID Number -->
                            <div class="col-12 col-md-6">
                                <label class="sr-only" for="uname">8 digits of ID Number</label>
                                <div class="input-icon">
                                    <i class="fas fa-id-badge"></i>
                                    <input id="uname" type="text" name="uname" class="form-control" placeholder="8 digits of ID Number" 
                                           value="<%= request.getAttribute("uname") != null ? request.getAttribute("uname") : "" %>" required/>
                                </div>
                                <span id="errorUsername" class="error-message"></span>
                            </div>

                            <!-- Contact No -->
                            <div class="col-12 col-md-6">
                                <label class="sr-only" for="contactno">Contact No</label>
                                <div class="input-icon">
                                    <i class="fas fa-phone"></i>
                                    <input id="contactno" type="tel" name="contactno" class="form-control" placeholder="Contact No" 
                                           value="<%= request.getAttribute("contactno") != null ? request.getAttribute("contactno") : "" %>"/>
                                </div>
                                <span id="errorContact" class="error-message"></span>
                            </div>

                            <!-- Email -->
                            <div class="col-12">
                                <label class="sr-only" for="email"><%= emailLabel %></label>
                                <div class="input-icon">
                                    <i class="fas fa-envelope"></i>
                                    <input id="email" type="email" name="email" class="form-control" placeholder="<%= emailLabel %>" 
                                           value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required/>
                                </div>
                                <span id="errorEmail" class="error-message"></span>
                            </div>

                            <!-- Password -->
                            <div class="col-12 col-md-6 mt-3">
                                <label class="sr-only" for="pass">Password</label>
                                <div class="input-icon">
                                    <i class="fas fa-lock"></i>
                                    <input id="pass" type="password" name="pass" class="form-control" placeholder="Password" required/>
                                    <i class="fas fa-eye toggle-password" onclick="togglePassword('pass', this)"></i>
                                </div>
                                <span id="errorPassword" class="error-message"></span>
                            </div>

                            <!-- Confirm Password -->
                            <div class="col-12 col-md-6 mt-3">
                                <label class="sr-only" for="cpass">Confirm Password</label>
                                <div class="input-icon">
                                    <i class="fas fa-lock"></i>
                                    <input id="cpass" type="password" name="cpass" class="form-control" placeholder="Confirm Password" required/>
                                    <i class="fas fa-eye toggle-password" onclick="togglePassword('cpass', this)"></i>
                                </div>
                                <span id="errorConfirmPassword" class="error-message"></span>
                            </div>

                            <!-- Submit Button -->
                            <div class="col-12 mt-4">
                                <button type="submit" class="btn btn-primary btn-auth btn-block" id="submitBtn">
                                    <i class="fa-solid fa-user-plus mr-1"></i> Sign Up
                                </button>
                            </div>

                            <!-- Login Link -->
                            <div class="col-12 text-center mt-3">
                                <small class="text-muted">
                                    Already have an account?
                                    <a href="login.jsp">Log in</a>
                                </small>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Footer -->
<footer class="mt-auto">
    <jsp:include page="footer.jsp"/>
</footer>

<!-- JavaScript -->
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
$(document).ready(function () {

    /* ==========================
       PASSWORD VISIBILITY TOGGLE
       ========================== */
    window.togglePassword = function (fieldId, icon) {
        const input = document.getElementById(fieldId);
        input.type = input.type === "password" ? "text" : "password";
        icon.classList.toggle("fa-eye");
        icon.classList.toggle("fa-eye-slash");
    };

    /* ==========================
       SESSION MODAL MESSAGES
       ========================== */
    <% if (sessionError != null && !sessionError.isEmpty()) { %>
        showAlert('<%= sessionError %>', 'error', { title: 'Registration Error' });
        <% session.removeAttribute("error"); %>
    <% } %>

    <% if (sessionSuccess != null && !sessionSuccess.isEmpty()) { %>
        showAlert('<%= sessionSuccess %>', 'success', { title: 'Success' });
        <% session.removeAttribute("success"); %>
    <% } %>

    <% if (sessionMessage != null && !sessionMessage.isEmpty()) { %>
        showAlert('<%= sessionMessage %>', 'info', { title: 'Information' });
        <% session.removeAttribute("message"); %>
    <% } %>

    /* ==========================
       FOCUS ERROR FIELD (SERVER)
       ========================== */
    <% String errorField = (String) session.getAttribute("errorField"); %>
    <% if (errorField != null) { %>
        setTimeout(function () {
            const field = document.getElementById('<%= errorField %>');
            if (field) {
                field.focus();
                field.style.borderColor = '#dc3545';
                field.style.boxShadow = '0 0 0 0.2rem rgba(220,53,69,.25)';
            }
        }, 300);
        <% session.removeAttribute("errorField"); %>
    <% } %>

    /* ==========================
       TIMEOUT HOLDERS
       ========================== */
    let usernameTimeout, emailTimeout, contactTimeout;

    /* ==========================
       ID NUMBER VALIDATION
       ========================== */
    $('#uname').on('input', function () {
        clearTimeout(usernameTimeout);
        const value = this.value.trim();
        const error = $('#errorUsername');

        if (!value) return error.text('');

        usernameTimeout = setTimeout(function () {
            if (!/^\d{8}$/.test(value)) {
                return error.text('ID number must be exactly 8 digits.');
            }

            $.getJSON('controller.jsp', {
                page: 'check_username',
                username: value
            }).done(res => {
                error.text(res.exists ? 'This ID number is already registered.' : '');
            });
        }, 3000);
    });

    /* ==========================
       EMAIL VALIDATION
       ========================== */
    $('#email').on('input', function () {
        clearTimeout(emailTimeout);
        const value = this.value.trim();
        const error = $('#errorEmail');

        if (!value) return error.text('');

        emailTimeout = setTimeout(function () {
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
                return error.text('Please enter a valid email address.');
            }

            $.getJSON('controller.jsp', {
                page: 'check_email',
                email: value
            }).done(res => {
                error.text(res.exists ? 'This email is already registered.' : '');
            });
        }, 3000);
    });

    /* ==========================
       CONTACT VALIDATION
       ========================== */
    $('#contactno').on('input', function () {
        clearTimeout(contactTimeout);
        const value = this.value.trim();
        const error = $('#errorContact');

        if (!value) return error.text('');

        contactTimeout = setTimeout(function () {
            if (!/^[\d\s\+\-\(\)]{8,15}$/.test(value)) {
                return error.text('Please enter a valid contact number (8?15 digits).');
            }

            $.getJSON('controller.jsp', {
                page: 'check_contact',
                contactno: value
            }).done(res => {
                error.text(res.exists ? 'This contact number is already registered.' : '');
            });
        }, 3000);
    });

    /* ==========================
       PASSWORD MATCH (LIVE)
       ========================== */
    $('#pass, #cpass').on('input', function () {
        const match = $('#pass').val() === $('#cpass').val();
        $('#errorConfirmPassword').text(match ? '' : 'Passwords do not match.');
        $('#submitBtn').prop('disabled', !match);
    });

    /* ==========================
       CLEAR FIELD STYLES ON TYPE
       ========================== */
    $('input').on('input', function () {
        $(this).css({ borderColor: '', boxShadow: '' });
    });

    /* ==========================
       FORM SUBMISSION (FIXED)
       ========================== */
    $('#registerForm').on('submit', function (e) {
        e.preventDefault();

        $('.error-message').text('');
        let isValid = true;
        let firstError = null;

        const id = $('#uname').val().trim();
        const email = $('#email').val().trim();
        const pass = $('#pass').val();
        const cpass = $('#cpass').val();
        const contact = $('#contactno').val().trim();

        if (!/^\d{8}$/.test(id)) {
            $('#errorUsername').text('ID number must be exactly 8 digits.');
            firstError ??= 'uname';
            isValid = false;
        }

        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            $('#errorEmail').text('Invalid email address.');
            firstError ??= 'email';
            isValid = false;
        }

        if (pass.length < 6) {
            $('#errorPassword').text('Password must be at least 6 characters.');
            firstError ??= 'pass';
            isValid = false;
        }

        if (pass !== cpass) {
            $('#errorConfirmPassword').text('Passwords do not match.');
            firstError ??= 'cpass';
            isValid = false;
        }

        if (contact && !/^[\d\s\+\-\(\)]{8,15}$/.test(contact)) {
            $('#errorContact').text('Invalid contact number.');
            firstError ??= 'contactno';
            isValid = false;
        }

        if (!isValid) {
            const field = document.getElementById(firstError);
            if (field) field.focus();
            return;
        }

        /* ? ONLY NOW SHOW LOADING */
        $('#submitBtn')
            .prop('disabled', true)
            .html('<i class="fas fa-spinner fa-spin"></i> Registering...');

        this.submit();
    });

    /* ==========================
       CLEANUP
       ========================== */
    $(window).on('beforeunload', function () {
        clearTimeout(usernameTimeout);
        clearTimeout(emailTimeout);
        clearTimeout(contactTimeout);
    });
});
</script>


</body>
</html>