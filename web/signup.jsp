<%@page import="myPackage.classes.User"%>
<%@page import="java.net.URL"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Register New User</title>

  <!-- If header.jsp already loads Bootstrap/Icons, you can remove these two lines -->
  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>

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
    // Get the user_type from request parameter
    String userType = request.getParameter("user_type");
    if (userType == null) {
        userType = "student"; // Default to student
    }
    String fromPage = request.getParameter("from");
    
    // Store these in session or hidden fields for use after registration
    if (userType != null) {
        session.setAttribute("signup_user_type", userType);
    }
    if (fromPage != null) {
        session.setAttribute("signup_from_page", fromPage);
    }
    
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
    
    // Check for session errors first, then URL parameters
    String sessionError = (String) session.getAttribute("error");
    String sessionMessage = (String) session.getAttribute("message");
    String urlError = request.getParameter("error");
    
    // Get ALL form values from parameters to preserve them
    String fnameParam = request.getParameter("fname");
    String lnameParam = request.getParameter("lname");
    String unameParam = request.getParameter("uname");
    String emailParam = request.getParameter("email");
    String contactParam = request.getParameter("contactno");
    
    // Map URL error codes to user-friendly messages
    String errorMessage = "";
    if (urlError != null && !urlError.isEmpty()) {
        switch(urlError) {
            case "missing_fields":
                errorMessage = "All required fields must be filled.";
                break;
            case "invalid_id":
                errorMessage = "ID number must be 8 digits.";
                // Clear only the ID field
                unameParam = "";
                break;
            case "duplicate_username":
                errorMessage = "Username/ID number already exists.";
                // Clear only the username field
                unameParam = "";
                break;
            case "duplicate_email":
                errorMessage = "Email already registered.";
                // Clear only the email field
                emailParam = "";
                break;
            case "duplicate_contact":
                errorMessage = "Contact number already registered.";
                // Clear only the contact field
                contactParam = "";
                break;
            default:
                errorMessage = "An error occurred during registration.";
        }
    }
%>

<body>

<!-- Header -->
<jsp:include page="header.jsp" />
<%@include file="modal_assets.jspf" %>


<!-- Main -->
  <main class="flex-fill d-flex align-items-center">
    <div class="container py-4">
      <div class="row justify-content-center">
        <div class="col-12 col-md-10 col-lg-8 col-xl-6">
          <div class="auth-card p-4 p-md-5">
            <h2 class="auth-title h4 mb-3 text-center"><%= title %></h2>
            <p class="text-center text-muted mb-4"><%= subtitle %></p>

            <!-- Display messages if any -->
            <% if (sessionMessage != null && !sessionMessage.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= sessionMessage %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            <% } %>
            
            <% if (sessionError != null && !sessionError.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= sessionError %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            <% } else if (urlError != null && !urlError.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= errorMessage %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            <% } %>

            <!-- Add hidden fields for user_type and from_page -->
            <form id="registerForm" action="controller.jsp" method="POST">
              <input type="hidden" name="page" value="register"/>
              <input type="hidden" id="hiddenUserType" name="user_type" value="<%= userType != null ? userType : "" %>"/>
              <input type="hidden" name="from_page" value="<%= fromPage != null ? fromPage : "" %>"/>
              
              <!-- You might also want to pass the referrer for admin/lecture users -->
              <input type="hidden" name="referrer_id" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "" %>"/>

              <div class="form-row">
                <div class="col-12 col-md-6">
                  <label class="sr-only" for="fname">First Name</label>
                  <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input id="fname" type="text" name="fname" class="form-control" placeholder="First Name" 
                           value="<%= fnameParam != null ? fnameParam : "" %>" required/>
                  </div>
                  <span id="errorFirstName" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="lname">Last Name</label>
                  <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input id="lname" type="text" name="lname" class="form-control" placeholder="Last Name" 
                           value="<%= lnameParam != null ? lnameParam : "" %>" required/>
                  </div>
                  <span id="errorLastName" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="uname">8 digits of ID Number</label>
                  <div class="input-icon">
                    <i class="fas fa-id-badge"></i>
                    <input id="uname" type="text" name="uname" class="form-control" placeholder="8 digits of ID Number" 
                           value="<%= unameParam != null ? unameParam : "" %>" required/>
                  </div>
                  <span id="errorUsername" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="contactno">Contact No</label>
                  <div class="input-icon">
                    <i class="fas fa-phone"></i>
                    <input id="contactno" type="tel" name="contactno" class="form-control" placeholder="Contact No" 
                           value="<%= contactParam != null ? contactParam : "" %>" required/>
                  </div>
                  <span id="errorContact" class="error-message"></span>
                </div>

                <div class="col-12">
                  <label class="sr-only" for="email"><%= emailLabel %></label>
                  <div class="input-icon">
                    <i class="fas fa-envelope"></i>
                    <input id="email" type="email" name="email" class="form-control" placeholder="<%= emailLabel %>" 
                           value="<%= emailParam != null ? emailParam : "" %>" required/>
                  </div>
                  <span id="errorEmail" class="error-message"></span>
                </div>
                  
                <br><br>
                
                <div class="col-12 col-md-6">
                  <label class="sr-only" for="pass">Password</label>
                  <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input id="pass" type="password" name="pass" class="form-control" placeholder="Password" required/>
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('pass', this)"></i>
                  </div>
                  <span id="errorPassword" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="cpass">Confirm Password</label>
                  <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input id="cpass" type="password" name="cpass" class="form-control" placeholder="Confirm Password" required/>
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('cpass', this)"></i>
                  </div>
                  <span id="errorConfirmPassword" class="error-message"></span>
                </div>

                <div class="col-12 mt-2">
                  <button type="submit" class="btn btn-primary btn-auth btn-block">
                    <i class="fa-solid fa-user-plus mr-1"></i> Sign Up
                  </button>
                </div>

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

<script>
// Show any messages from server on page load
window.onload = function() {
    <% if (sessionError != null && !sessionError.isEmpty()) { %>
        showAlert('<%= sessionError %>', 'error');
        <% session.removeAttribute("error"); %>
    <% } else if (urlError != null && !urlError.isEmpty()) { %>
        showAlert('<%= errorMessage %>', 'error');
        
        // Focus on the problematic field based on error type
        switch('<%= urlError %>') {
            case 'duplicate_username':
            case 'invalid_id':
                document.getElementById('uname').focus();
                break;
            case 'duplicate_email':
                document.getElementById('email').focus();
                break;
            case 'duplicate_contact':
                document.getElementById('contactno').focus();
                break;
            default:
                // For other errors, just show the alert
                break;
        }
    <% } %>
    
    <% if (sessionMessage != null && !sessionMessage.isEmpty()) { %>
        showAlert('<%= sessionMessage %>', 'success');
        <% session.removeAttribute("message"); %>
    <% } %>
};

// =======================================================================================
// REAL-TIME VALIDATION (CLIENT-SIDE)
// =======================================================================================

/**
 * Validates and checks for duplicates in real-time
 */
async function validateField(fieldId, endpoint, errorMessage) {
    const field = document.getElementById(fieldId);
    const value = field.value.trim();
    
    // Clear previous error
    const fieldName = fieldId.charAt(0).toUpperCase() + fieldId.slice(1);
    const errorSpan = document.getElementById('error' + fieldName);
    if (errorSpan) errorSpan.textContent = '';
    
    if (!value) return true; // Empty fields will be caught by required attribute
    
    try {
        // Check for duplicates via AJAX
        const url = 'controller.jsp?page=' + endpoint + '&' + 
                   (endpoint === 'check_username' ? 'username' : 
                    endpoint === 'check_email' ? 'email' : 'contactno') + 
                   '=' + encodeURIComponent(value);
        
        const response = await fetch(url);
        if (!response.ok) throw new Error('Network error');
        
        const data = await response.json();
        
        if (data.exists) {
            if (errorSpan) {
                errorSpan.textContent = errorMessage;
            } else {
                showAlert(errorMessage, 'error');
            }
            // Clear only this field and focus on it
            field.value = '';
            field.focus();
            return false;
        }
        return true;
    } catch (error) {
        console.error('Validation error:', error);
        return true; // Allow submission if validation fails
    }
}

// Attach real-time validation for duplicate checking
document.getElementById('uname').addEventListener('blur', async () => {
    // First validate format
    const unameField = document.getElementById('uname');
    const value = unameField.value.trim();
    const errorSpan = document.getElementById('errorUsername');
    
    if (value && !/^\d{8}$/.test(value)) {
        errorSpan.textContent = 'ID number must be exactly 8 digits.';
        unameField.value = '';
        unameField.focus();
        return;
    }
    
    // Then check for duplicates
    if (value) {
        await validateField('uname', 'check_username', 'This ID number is already registered.');
    }
});

document.getElementById('email').addEventListener('blur', async () => {
    // First validate format
    const emailField = document.getElementById('email');
    const value = emailField.value.trim();
    const errorSpan = document.getElementById('errorEmail');
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    
    if (value && !emailRegex.test(value)) {
        errorSpan.textContent = 'Please enter a valid email address.';
        emailField.value = '';
        emailField.focus();
        return;
    }
    
    // Then check for duplicates
    if (value) {
        await validateField('email', 'check_email', 'This email is already registered.');
    }
});

document.getElementById('contactno').addEventListener('blur', async () => {
    // First validate format
    const contactField = document.getElementById('contactno');
    const value = contactField.value.trim();
    const errorSpan = document.getElementById('errorContact');
    
    if (value && !/^[\d\s\+\-\(\)]{8,15}$/.test(value)) {
        errorSpan.textContent = 'Please enter a valid contact number (8-15 digits).';
        contactField.value = '';
        contactField.focus();
        return;
    }
    
    // Then check for duplicates
    if (value) {
        await validateField('contactno', 'check_contact', 'This contact number is already in use.');
    }
});

// =======================================================================================
// FINAL FORM VALIDATION ON SUBMIT
// =======================================================================================

document.getElementById('registerForm').addEventListener('submit', async function(event) {
    event.preventDefault();
    
    const submitButton = this.querySelector('button[type="submit"]');
    const originalText = submitButton.innerHTML;
    submitButton.disabled = true;
    submitButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Validating...';
    
    // Clear all error messages before validation
    document.querySelectorAll('.error-message').forEach(span => {
        span.textContent = '';
    });
    
    // Get field values
    const username = document.getElementById('uname').value.trim();
    const email = document.getElementById('email').value.trim();
    const contact = document.getElementById('contactno').value.trim();
    const password = document.getElementById('pass').value;
    const confirmPassword = document.getElementById('cpass').value;
    let hasError = false;
    let firstErrorField = null;
    
    // Validate ID number format
    if (!/^\d{8}$/.test(username)) {
        document.getElementById('errorUsername').textContent = 'ID number must be exactly 8 digits.';
        if (!firstErrorField) firstErrorField = document.getElementById('uname');
        hasError = true;
    }
    
    // Validate password
    if (password.length < 6) {
        document.getElementById('errorPassword').textContent = 'Password must be at least 6 characters long.';
        if (!firstErrorField) firstErrorField = document.getElementById('pass');
        hasError = true;
    }
    
    if (password !== confirmPassword) {
        document.getElementById('errorConfirmPassword').textContent = 'Passwords do not match.';
        if (!firstErrorField) firstErrorField = document.getElementById('cpass');
        hasError = true;
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        document.getElementById('errorEmail').textContent = 'Please enter a valid email address.';
        if (!firstErrorField) firstErrorField = document.getElementById('email');
        hasError = true;
    }
    
    // Validate contact number (basic validation)
    if (contact && !/^[\d\s\+\-\(\)]{8,15}$/.test(contact)) {
        document.getElementById('errorContact').textContent = 'Please enter a valid contact number (8-15 digits).';
        if (!firstErrorField) firstErrorField = document.getElementById('contactno');
        hasError = true;
    }
    
    // If there are format errors, clear only the problematic field and focus
    if (hasError) {
        if (firstErrorField) {
            firstErrorField.value = '';
            firstErrorField.focus();
        }
        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
        return;
    }
    
    // Check for duplicates before submission
    try {
        submitButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Checking duplicates...';
        
        // Check username/ID
        const usernameCheck = await validateField('uname', 'check_username', 'This ID number is already registered.');
        if (!usernameCheck) {
            submitButton.disabled = false;
            submitButton.innerHTML = originalText;
            return;
        }
        
        // Check email
        const emailCheck = await validateField('email', 'check_email', 'This email is already registered.');
        if (!emailCheck) {
            submitButton.disabled = false;
            submitButton.innerHTML = originalText;
            return;
        }
        
        // Check contact number if provided
        if (contact) {
            const contactCheck = await validateField('contactno', 'check_contact', 'This contact number is already in use.');
            if (!contactCheck) {
                submitButton.disabled = false;
                submitButton.innerHTML = originalText;
                return;
            }
        }
        
        // Special check for staff emails if user is registering as student
        const userType = document.getElementById('hiddenUserType').value;
        if (userType === 'student' || !userType) {
            try {
                submitButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Finalizing...';
                
                const staffCheckUrl = 'controller.jsp?page=check_staff_email&email=' + encodeURIComponent(email);
                const response = await fetch(staffCheckUrl);
                if (response.ok) {
                    const data = await response.json();
                    if (data.exists) {
                        // Show confirmation modal for staff email
                        showConfirm(
                            'This email is registered as a lecturer/staff email. Are you sure you want to register as a student?',
                            () => {
                                submitButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Creating account...';
                                // Proceed with form submission
                                document.getElementById('registerForm').submit();
                            },
                            {
                                title: 'Staff Email Detected',
                                confirmText: 'Yes, Register as Student',
                                cancelText: 'Cancel'
                            }
                        );
                        submitButton.disabled = false;
                        submitButton.innerHTML = originalText;
                        return;
                    }
                }
            } catch (error) {
                console.error('Staff email check failed:', error);
                // Continue with registration even if check fails
            }
        }
        
        // All validations passed - submit the form
        submitButton.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Creating account...';
        this.submit();
        
    } catch (error) {
        console.error('Validation error:', error);
        showAlert('An error occurred during validation. Please try again.', 'error');
        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
    }
});

function togglePassword(fieldId, icon){
    const input = document.getElementById(fieldId);
    const revealing = input.type === "password";
    input.type = revealing ? "text" : "password";
    icon.classList.toggle("fa-eye");
    icon.classList.toggle("fa-eye-slash");
}

// Helper function to clear individual field errors on input
function clearFieldError(fieldId) {
    const field = document.getElementById(fieldId);
    const fieldName = fieldId.charAt(0).toUpperCase() + fieldId.slice(1);
    const errorSpan = document.getElementById('error' + fieldName);
    if (errorSpan) {
        errorSpan.textContent = '';
    }
}

// Attach event listeners to clear errors when user starts typing
document.getElementById('uname').addEventListener('input', () => clearFieldError('uname'));
document.getElementById('email').addEventListener('input', () => clearFieldError('email'));
document.getElementById('contactno').addEventListener('input', () => clearFieldError('contactno'));
document.getElementById('pass').addEventListener('input', () => clearFieldError('pass'));
document.getElementById('cpass').addEventListener('input', () => clearFieldError('cpass'));
</script>

  <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>