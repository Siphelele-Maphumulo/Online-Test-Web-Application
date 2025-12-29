<%@ page import="javax.servlet.http.HttpSession" %>

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
                            String currentPage = request.getRequestURI();
                            boolean isLoginPage = currentPage.contains("login.jsp");
                            boolean isSignupPage = currentPage.contains("signup.jsp");
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
.nav-link { color: var(--text-white); text-decoration: none; font-weight: 500; font-size: 0.8125rem; padding: 6px 12px; border-radius: 4px; transition: all var(--transition-speed) ease; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); display: flex; align-items: center; gap: 6px; cursor: pointer; }
button.nav-link { border: 1px solid rgba(255,255,255,0.15); background: rgba(255,255,255,0.08); }
button.nav-link:hover { background: rgba(255,255,255,0.18); transform: translateY(-2px); border-color: rgba(255,255,255,0.3); }
.nav-link i { font-size: 0.6875rem; }

.login-link:hover { background: rgba(74,144,226,0.2); }
.signup-link:hover { background: rgba(46,204,113,0.2); }
.logout-link:hover { background: rgba(231,76,60,0.2); }

@media (max-width: 767.98px) { .header-logo { max-height: 36px; } .header-title { font-size: 0.875rem; } .header-subtitle { font-size: 0.625rem; } .nav-link { padding: 5px 8px; font-size: 0.75rem; } }

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

