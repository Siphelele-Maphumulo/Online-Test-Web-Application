<%@ page import="javax.servlet.http.HttpSession" %>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<%
    // Check if current page should show loader (exclude login and signup pages)
    String currentPage = request.getRequestURI().toLowerCase();
    boolean isLoginPage = currentPage.contains("login.jsp");
    boolean isSignupPage = currentPage.contains("signup.jsp") || 
                          currentPage.contains("lecture_signup.jsp") ||
                          currentPage.contains("register.html");
    boolean showPageLoader = !isLoginPage && !isSignupPage && request.getAttribute("disableLoader") == null && session.getAttribute("disableLoader") == null;
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
        
        // Hide loader after 0.5 seconds
        setTimeout(function() {
            loader.classList.add('hidden');
            setTimeout(function() {
                loader.style.display = 'none';
            }, 300); // Wait for fade-out transition
        }, 500); // 0.5 seconds
    }
})();
</script>
<% } %>

<!-- Professional Header -->
<header class="header">
    <div class="container-fluid">
        <div class="header-content-wrapper">
            <!-- Logo Section -->
            <div class="header-logo-section">
                <a href="index.jsp" class="logo-link">
                    <img src="IMG/mut-45yearslogo-whitetrans1024x362-1-12@2x.png" 
                         alt="MUT Logo" 
                         class="header-logo">
                </a>
            </div>

            <!-- Title Section -->
            <div class="header-title-section">
                <h1 class="header-title">Online Assessment System</h1>
                <p class="header-subtitle">CodeSA Institute | Professional Testing Platform</p>
            </div>

            <!-- Navigation Section -->
            <div class="header-nav-section">
                <nav class="header-nav">
                    <button class="mobile-nav-toggle" id="mobileNavToggle" aria-label="Toggle navigation">
                        <i class="fas fa-bars"></i>
                    </button>
                    <div class="nav-links" id="navLinks">
                        <% 
                            boolean isLoggedIn = session.getAttribute("userStatus") != null 
                                                && session.getAttribute("userStatus").equals("1");
                        %>

                        <% if (!isLoggedIn && !isSignupPage) { %>
                        <a href="signup.jsp" class="nav-link signup-link">
                            <i class="fas fa-user-plus"></i>
                            <span class="link-text">Sign Up</span>
                        </a>
                        <% } %>

                        <% if (!isLoggedIn && !isSignupPage) { %>
                        <a href="#" class="nav-link lecture-link" id="lecturerRequestLink">
                            <i class="fas fa-chalkboard-user"></i>
                            <span class="link-text">Lecture</span>
                        </a>
                        <% } %>

                        <% if (!isLoggedIn && !isLoginPage) { %>
                        <a href="login.jsp" class="nav-link login-link">
                            <i class="fas fa-sign-in-alt"></i>
                            <span class="link-text">Login</span>
                        </a>
                        <% } %>

                        <% if (isLoggedIn) { %>
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

<div id="lecturerRequestModal" class="lr-modal" aria-hidden="true">
    <div class="lr-modal-dialog" role="dialog" aria-modal="true">
        <div class="lr-modal-header">
            <div class="lr-modal-title">Lecturer Request</div>
            <button type="button" class="lr-modal-close" id="lrModalCloseBtn">&times;</button>
        </div>
        <form id="lecturerRequestForm" autocomplete="off">
            <div class="lr-modal-body">
                <div class="lr-field">
                    <label for="lrFirstNames">First Names</label>
                    <input type="text" id="lrFirstNames" name="firstNames" required>
                </div>
                <div class="lr-field">
                    <label for="lrSurname">Surname</label>
                    <input type="text" id="lrSurname" name="surname" required>
                </div>
                <div class="lr-field">
                    <label for="lrStaffNumber">Staff Number (6 Digits of ID)</label>
                    <input type="text" id="lrStaffNumber" name="staffNumber" inputmode="numeric" maxlength="6" required>
                </div>
                <div class="lr-field">
                    <label for="lrEmail">Email</label>
                    <input type="email" id="lrEmail" name="email" required>
                </div>
                <div class="lr-field">
                    <label for="lrCourse">Course</label>
                    <input type="text" id="lrCourse" name="course" required>
                </div>
                <div class="lr-field">
                    <label for="lrContact">Contact</label>
                    <input type="text" id="lrContact" name="contact" required>
                </div>
                <div id="lrFormMessage" class="lr-form-message" style="display:none;"></div>
            </div>
            <div class="lr-modal-footer">
                <button type="button" class="btn btn-secondary" id="lrCancelBtn">Cancel</button>
                <button type="submit" class="btn btn-primary" id="lrSubmitBtn">
                    <i class="fas fa-paper-plane"></i>
                    <span class="link-text">Request</span>
                </button>
            </div>
        </form>
    </div>
</div>

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
    padding: 8px 0;
    border-bottom: 2px solid var(--text-white);
    position: sticky;
    top: 0;
    z-index: 1000;
    box-shadow: 0 2px 12px rgba(0,0,0,0.15);
    font-family: 'Segoe UI', 'Roboto', sans-serif;
    color: var(--text-white);
}

.header-content-wrapper {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
}

.header-logo-section { flex: 0 0 auto; }
.header-title-section { flex: 1; text-align: center; }
.header-nav-section { flex: 0 0 auto; }

.header-logo { max-height: 40px; width: auto; transition: transform 0.3s ease; }
.logo-link:hover .header-logo { transform: translateY(-1px); opacity: 0.95; }
.header-title { color: var(--text-white); font-size: 1.1rem; font-weight: 600; margin: 0; text-shadow: 0 1px 3px rgba(0,0,0,0.25); }
.header-subtitle { color: var(--text-light); font-size: 0.7rem; margin: 2px 0 0; opacity: 0.9; }

.header-nav { position: relative; }
.mobile-nav-toggle {
    display: none;
    background: none;
    border: 1px solid rgba(255,255,255,0.3);
    color: white;
    font-size: 1.2rem;
    padding: 5px 10px;
    border-radius: 4px;
    cursor: pointer;
}

.nav-links { display: flex; gap: 8px; align-items: center; }
.nav-link { color: var(--text-white); text-decoration: none; font-weight: 500; font-size: 0.8125rem; padding: 8px 12px; border-radius: 4px; transition: all var(--transition-speed) ease; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); display: flex; align-items: center; gap: 6px; cursor: pointer; white-space: nowrap; }
button.nav-link { border: 1px solid rgba(255,255,255,0.15); background: rgba(255,255,255,0.08); }
button.nav-link:hover { background: rgba(255,255,255,0.18); transform: translateY(-2px); border-color: rgba(255,255,255,0.3); }
.nav-link i { font-size: 0.75rem; }

@media (max-width: 991px) {
    .header-title { font-size: 0.95rem; }
    .header-subtitle { font-size: 0.65rem; }
}

@media (max-width: 767.98px) {
    .header-content-wrapper { padding: 5px 10px; }
    .header-title-section { display: none; }
    .header-logo { max-height: 28px; }
    .mobile-nav-toggle { display: block; }
    
    .nav-links {
        display: none;
        position: fixed;
        top: 60px;
        left: 0;
        right: 0;
        background: var(--primary-blue);
        flex-direction: column;
        width: 100%;
        padding: 20px;
        border-radius: 0;
        box-shadow: 0 10px 15px rgba(0,0,0,0.3);
        border: none;
        border-top: 1px solid rgba(255,255,255,0.1);
        margin-top: 0;
        z-index: 1001;
    }
    
    .nav-links.active { display: flex; }
    .nav-link { width: 100%; justify-content: center; padding: 15px; font-size: 1rem; }
}

.login-link:hover { background: rgba(74,144,226,0.2);  }
.signup-link:hover { background: rgba(46,204,113,0.2);  }
.logout-link:hover { background: rgba(231,76,60,0.2); }
.lecture-link:hover { background: rgba(255, 193, 7, 0.18); }

.lr-modal {
    position: fixed;
    inset: 0;
    display: none;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.55);
    z-index: 99998;
}

.lr-modal-dialog {
    width: min(420px, 92vw);
    height: auto;
    background: #ffffff;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 18px 60px rgba(0,0,0,0.25);
    border: 1px solid rgba(0,0,0,0.08);
}

.lr-modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 16px;
    background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
    color: #fff;
}

.lr-modal-title {
    font-weight: 600;
    letter-spacing: 0.2px;
}

.lr-modal-close {
    background: transparent;
    border: 0;
    color: #fff;
    font-size: 12px;
    line-height: 1;
    cursor: pointer;
    padding: 0 6px;
}

.lr-modal-body { padding: 12px 16px; }

.lr-field { margin-bottom: 10px; }
.lr-field label { display: block; font-size: 0.85rem; margin-bottom: 6px; color: #1f2a37; font-weight: 600; }
.lr-field input {
    width: 100%;
    padding: 5px 8px;
    border: 1px solid rgba(15, 23, 42, 0.18);
    border-radius: 8px;
    outline: none;
    font-size: 0.95rem;
}
.lr-field input:focus { border-color: rgba(9, 41, 77, 0.55); box-shadow: 0 0 0 3px rgba(9, 41, 77, 0.12); }

.lr-form-message { margin-top: 8px; font-size: 0.9rem; padding: 10px 12px; border-radius: 8px; }
.lr-form-message.ok { background: rgba(46,204,113,0.12); color: #146c2e; border: 1px solid rgba(46,204,113,0.25); }
.lr-form-message.err { background: rgba(231,76,60,0.10); color: #8a1f14; border: 1px solid rgba(231,76,60,0.22); }

.lr-modal-footer {
    display: flex;
    justify-content: center;
    gap: 5px;
    padding: 10px 8px 6px;
}


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

    const lrLink = document.getElementById('lecturerRequestLink');
    const lrModal = document.getElementById('lecturerRequestModal');
    const lrCloseBtn = document.getElementById('lrModalCloseBtn');
    const lrCancelBtn = document.getElementById('lrCancelBtn');
    const lrForm = document.getElementById('lecturerRequestForm');
    const lrMsg = document.getElementById('lrFormMessage');
    const lrSubmitBtn = document.getElementById('lrSubmitBtn');

    const showLrMsg = function (type, text) {
        if (!lrMsg) return;
        lrMsg.className = 'lr-form-message ' + (type === 'ok' ? 'ok' : 'err');
        lrMsg.textContent = text;
        lrMsg.style.display = 'block';
    };

    const closeLrModal = function () {
        if (!lrModal) return;
        lrModal.style.display = 'none';
        lrModal.setAttribute('aria-hidden', 'true');
        if (lrMsg) lrMsg.style.display = 'none';
        try { if (lrSubmitBtn) { lrSubmitBtn.disabled = false; lrSubmitBtn.classList.remove('loading'); } } catch (e) {}
    };

    if (lrLink && lrModal) {
        lrLink.addEventListener('click', function (e) {
            e.preventDefault();
            lrModal.style.display = 'flex';
            lrModal.setAttribute('aria-hidden', 'false');
        });
    }
    if (lrCloseBtn) lrCloseBtn.addEventListener('click', closeLrModal);
    if (lrCancelBtn) lrCancelBtn.addEventListener('click', closeLrModal);
    if (lrModal) {
        lrModal.addEventListener('click', function (e) {
            if (e.target === lrModal) closeLrModal();
        });
    }

    // Mobile Nav Toggle
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const navLinks = document.getElementById('navLinks');
    if (mobileNavToggle && navLinks) {
        mobileNavToggle.addEventListener('click', function() {
            navLinks.classList.toggle('active');
        });
        // Close when clicking outside
        document.addEventListener('click', function(e) {
            if (!mobileNavToggle.contains(e.target) && !navLinks.contains(e.target)) {
                navLinks.classList.remove('active');
            }
        });
    }

    if (lrForm) {
        lrForm.addEventListener('submit', async function (e) {
            e.preventDefault();

            const firstNames = (document.getElementById('lrFirstNames') || {}).value || '';
            const surname = (document.getElementById('lrSurname') || {}).value || '';
            const staffNumber = (document.getElementById('lrStaffNumber') || {}).value || '';
            const email = (document.getElementById('lrEmail') || {}).value || '';
            const course = (document.getElementById('lrCourse') || {}).value || '';
            const contact = (document.getElementById('lrContact') || {}).value || '';

            if (!firstNames.trim() || !surname.trim() || !staffNumber.trim() || !email.trim() || !course.trim() || !contact.trim()) {
                showLrMsg('err', 'Please fill in all fields.');
                return;
            }
            if (!/^\d{6}$/.test(staffNumber.trim())) {
                showLrMsg('err', 'Staff Number must be exactly 6 digits.');
                return;
            }
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
                showLrMsg('err', 'Please enter a valid email address.');
                return;
            }

            try {
                if (lrSubmitBtn) { lrSubmitBtn.classList.add('loading'); lrSubmitBtn.disabled = true; }

                const params = new URLSearchParams();
                params.append('action', 'lecturer_request');
                params.append('firstNames', firstNames);
                params.append('surname', surname);
                params.append('staffNumber', staffNumber);
                params.append('email', email);
                params.append('course', course);
                params.append('contact', contact);

                const resp = await fetch('controller.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: params.toString()
                });

                let data = null;
                try { data = await resp.json(); } catch (parseErr) {}

                if (!resp.ok || !data) {
                    showLrMsg('err', 'Request failed. Please try again.');
                    if (lrSubmitBtn) { lrSubmitBtn.disabled = false; lrSubmitBtn.classList.remove('loading'); }
                    return;
                }

                if (data.success) {
                    showLrMsg('ok', data.message || 'Request sent successfully.');
                    try { lrForm.reset(); } catch (err) {}
                    setTimeout(function () {
                        window.location.href = 'signup.jsp';
                    }, 1400);
                } else {
                    showLrMsg('err', data.message || 'Request failed.');
                    if (lrSubmitBtn) { lrSubmitBtn.disabled = false; lrSubmitBtn.classList.remove('loading'); }
                }
            } catch (err) {
                showLrMsg('err', 'Request failed. Please try again.');
                if (lrSubmitBtn) { lrSubmitBtn.disabled = false; lrSubmitBtn.classList.remove('loading'); }
            }
        });
    }
});
</script>
