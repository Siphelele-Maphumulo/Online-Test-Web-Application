<%@ page import="javax.servlet.http.HttpSession" %>

<%
    // Check if current page should show loader (exclude login and signup pages)
    String currentPage = request.getRequestURI().toLowerCase();
    boolean isLoginPage = currentPage.contains("login.jsp");
    boolean isSignupPage = currentPage.contains("signup.jsp") || 
                          currentPage.contains("lecture_signup.jsp") ||
                          currentPage.contains("register.html");
    boolean showPageLoader = !isLoginPage && !isSignupPage;
%>

<% if (showPageLoader) { %>
<!-- Page Loader - Shows for 2 seconds on all pages except login/signup -->
<div id="pageLoader" class="page-loader-overlay">
    <div class="page-loader-content">
        <div class="page-loader-spinner">
            <img src="./IMG/Design.png" class="page-loader-img" alt="Loading" aria-hidden="true">
        </div>
        <div class="page-loader-text">Loading...</div>
    </div>
</div>

<style>
/* Page Loader Styles */
.page-loader-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(5px);
    z-index: 99999;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 1;
    visibility: visible;
    transition: opacity 0.3s ease-out, visibility 0.3s ease-out;
}

.page-loader-overlay.hidden {
    opacity: 0;
    visibility: hidden;
}

.page-loader-content {
    text-align: center;
}

.page-loader-spinner {
    width: 60px;
    height: 60px;
    border: 5px solid #f3f3f3;
    border-top: 5px solid #09294d;
    border-radius: 50%;
    animation: pageLoaderSpin 1s linear infinite;
    margin: 0 auto 20px;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
}

.page-loader-img {
    width: 32px;
    height: 32px;
    position: absolute;
    filter: brightness(0) invert(1); /* Makes image white */
    animation: pageLoaderImgSpin 1s linear infinite;
    object-fit: contain;
}

@keyframes pageLoaderSpin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

@keyframes pageLoaderImgSpin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.page-loader-text {
    font-size: 16px;
    font-weight: 500;
    color: #09294d;
    font-family: 'Segoe UI', 'Roboto', sans-serif;
    animation: pageLoaderPulse 1.5s ease-in-out infinite;
}

@keyframes pageLoaderPulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}
</style>

<script>
// Page Loader - Show for exactly 2 seconds
(function() {
    var loader = document.getElementById('pageLoader');
    if (loader) {
        // Ensure loader is visible immediately
        loader.style.display = 'flex';
        
        // Hide loader after 2 seconds
        setTimeout(function() {
            loader.classList.add('hidden');
            setTimeout(function() {
                loader.style.display = 'none';
            }, 300); // Wait for fade-out transition
        }, 2000); // 2 seconds
    }
})();
</script>
<% } %>

<!-- Professional Header -->
<header class="header">
    <div class="container-fluid">
        <div class="row align-items-center">

            <!-- Logo Column -->
            <div class="col-3 col-md-2">
                <a href="index.jsp" class="logo-link">
                    <img src="IMG/mut-45yearslogo-whitetrans1024x362-1-12@2x.png" 
                         alt="MUT Logo" 
                         class="header-logo">
                </a>
            </div>

            <!-- Title Column -->
            <div class="col-6 col-md-8 text-center">
                <h1 class="header-title">Web-Based Online Assessment System</h1>
                <p class="header-subtitle">CodeSA Institute | Professional Testing Platform</p>
            </div>

            <!-- Navigation Column -->
            <div class="col-3 col-md-2">
                <nav class="header-nav">
                    <div class="nav-links">
                        <% 
                            boolean isLoggedIn = session.getAttribute("userStatus") != null 
                                                && session.getAttribute("userStatus").equals("1");
                            // currentPage, isLoginPage, and isSignupPage are already declared at the top
                        %>

                        <% if (!isLoggedIn && !isSignupPage) { %>
                        <a href="signup.jsp" class="nav-link signup-link">
                            <i class="fas fa-user-plus"></i>
                            <span class="link-text">Sign Up</span>
                        </a>
                        <% } %>

                        <% if (!isLoggedIn && !isLoginPage) { %>
                        <a href="login.jsp" class="nav-link login-link">
                            <i class="fas fa-sign-in-alt"></i>
                            <span class="link-text">Login</span>
                        </a>
                        <% } %>

                        <% if (isLoggedIn) { %>
                        <!-- Logout Button -->
                        <button type="button" class="nav-link logout-link" id="logoutBtn">
                            <i class="fas fa-sign-out-alt"></i>
                            <span class="link-text">Logout</span>
                        </button>
                        <% } %>
                    </div>
                </nav>
            </div>

        </div>
    </div>
</header>

        <!-- Display success/error messages -->
        <% 
            String message = (String) session.getAttribute("message");
            if (message != null) {
        %>
            <div class="alert">
                <i class="fas fa-check-circle"></i> <%= message %>
            </div>
        <%
                session.removeAttribute("message");
            }
        %>


<!-- Logout Loader Overlay -->
<div id="logoutLoader" class="logout-loader">
    <div class="loader-content">
        <div class="loader-wave"></div>
        <div class="loader-text">
            Securely logging you out&nbsp;
            <span class="dot">.</span>
            <span class="dot">.</span>
            <span class="dot">.</span>
        </div>
    </div>
</div>

<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" 
      integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" 
      crossorigin="anonymous" 
      referrerpolicy="no-referrer" />

<style>
/* ---------- Logout Loader ---------- */
.logout-loader {
    position: fixed;
    inset: 0;
    background: #09294d;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 99999;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.5s ease;
}

.logout-loader.show {
    opacity: 1;
    pointer-events: all;
}

.loader-content { text-align: center; }

.loader-wave {
    width: 14vmin;
    height: 14vmin;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.15);
    position: relative;
    animation: breath 2.2s infinite ease-in-out;
    margin: 0 auto;
}

.loader-wave::before,
.loader-wave::after {
    content: '';
    position: absolute;
    inset: 0;
    border-radius: inherit;
    background: inherit;
    animation: breath 2.2s infinite ease-in-out;
}

.loader-wave::before { animation-delay: 0.7s; }
.loader-wave::after { animation-delay: 1.4s; }

@keyframes breath {
    0%, 100% { transform: scale(1); opacity: 0.4; }
    50% { transform: scale(1.4); opacity: 0.8; }
}

.loader-text {
    color: #fff;
    font-size: 1.1rem;
    margin-top: 2.5rem;
    letter-spacing: 0.5px;
    font-family: 'Segoe UI', 'Roboto', sans-serif;
}

.dot {
    animation: dotPulse 1.2s infinite;
    opacity: 0.3;
}
.dot:nth-child(2) { animation-delay: 0.2s; }
.dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes dotPulse {
    0%, 60%, 100% { opacity: 0.3; }
    30% { opacity: 1; }
}

/* ---------- Header ---------- */
:root {
    --primary-blue: #09294d;
    --secondary-blue: #1a3d6d;
    --text-white: #ffffff;
    --text-light: #e0e9ff;
    --transition-speed: 0.2s;
}

.header {
    background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
    padding: 12px 0;
    border-bottom: 2px solid var(--text-white);
    position: sticky;
    top: 0;
    z-index: 1000;
    box-shadow: 0 2px 12px rgba(0,0,0,0.15);
    font-family: 'Segoe UI', 'Roboto', sans-serif;
    color: var(--text-white);
}

.header-logo { max-height: 42px; width: auto; transition: transform 0.3s ease; }
.logo-link:hover .header-logo { transform: translateY(-1px); opacity: 0.95; }
.header-title { color: var(--text-white); font-size: 1.125rem; font-weight: 600; margin: 0; text-shadow: 0 1px 3px rgba(0,0,0,0.25); }
.header-subtitle { color: var(--text-light); font-size: 0.75rem; margin: 2px 0 0; opacity: 0.9; }

.header-nav { display: flex; justify-content: flex-end; }
.nav-links { display: flex; gap: 8px; align-items: center; }
.nav-link { color: var(--text-white); text-decoration: none; font-weight: 500; font-size: 0.8125rem; padding: 8px 16px; border-radius: 4px; transition: all var(--transition-speed) ease; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); display: flex; align-items: center; gap: 6px; cursor: pointer; min-width: 100px; text-align: center; justify-content: center; }
button.nav-link { border: 1px solid rgba(255,255,255,0.15); background: rgba(255,255,255,0.08); }
button.nav-link:hover { background: rgba(255,255,255,0.18); transform: translateY(-2px); border-color: rgba(255,255,255,0.3); }
.nav-link i { font-size: 0.6875rem; }

.login-link:hover { background: rgba(74,144,226,0.2); }
.signup-link { background: linear-gradient(135deg, #2ecc71, #27ae60) !important; font-weight: 600; }
.signup-link:hover { background: linear-gradient(135deg, #27ae60, #219653) !important; transform: translateY(-2px); box-shadow: 0 4px 8px rgba(46, 204, 113, 0.3); }
.logout-link:hover { background: rgba(231,76,60,0.2); }

@media (max-width: 767.98px) { .header-logo { max-height: 36px; } .header-title { font-size: 0.875rem; } .header-subtitle { font-size: 0.625rem; } .nav-link { padding: 6px 10px; font-size: 0.75rem; min-width: 80px; } .signup-link { padding: 7px 12px !important; font-weight: 600; } }

/* Loading state for submit/logout buttons */
button.nav-link.loading,
input[type="submit"].loading,
button[type="submit"].loading {
    opacity: 0.9;
    pointer-events: none;
    cursor: default;
}
button.nav-link.loading::after,
input[type="submit"].loading::after,
button[type="submit"].loading::after {
    content: '';
    display: inline-block;
    width: 14px;
    height: 14px;
    margin-left: 8px;
    vertical-align: middle;
    border: 2px solid rgba(255,255,255,0.85);
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.logout-loader {
    transition: opacity 1s ease; /* was 0.5s */
} 

</style>

<script>
// Unified header script: form submit loading, form resets, and logout loader with minimum display time
document.addEventListener('DOMContentLoaded', function () {
    const MIN_DISPLAY_TIME = 3000; // minimum loader time in ms
    const logoutButtons = document.querySelectorAll('#logoutBtn');
    const logoutLoader = document.getElementById('logoutLoader');

    // Form handling: show loading state on submit, handle reset buttons
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function (e) {
            // find either button or input submit
            const submit = this.querySelector('button[type="submit"], input[type="submit"]');
            if (submit) {
                submit.classList.add('loading');
                submit.disabled = true;
            }
        });
    });

    const resetButtons = document.querySelectorAll('button[type="reset"]');
    resetButtons.forEach(btn => {
        btn.addEventListener('click', function () {
            const form = this.closest('form');
            if (form) form.reset();
        });
    });

    // Logout handler: show loader and ensure minimum display time before navigating
    if (logoutButtons && logoutButtons.length && logoutLoader) {
        logoutButtons.forEach(btn => {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                const start = Date.now();

                // disable button to avoid double clicks
                try { btn.disabled = true; } catch (err) {}
                btn.classList.add('loading');

                // show overlay
                logoutLoader.classList.add('show');
                logoutLoader.setAttribute('aria-hidden', 'false');
                document.body.style.pointerEvents = 'none';

                // Ensure a smooth and minimum visible duration, then navigate
                const navigate = function () {
                    window.location.href = 'controller.jsp?page=logout';
                };

                const elapsed = Date.now() - start;
                const wait = Math.max(0, MIN_DISPLAY_TIME - elapsed);
                setTimeout(navigate, wait);
            });
        });
    }
});
</script>

