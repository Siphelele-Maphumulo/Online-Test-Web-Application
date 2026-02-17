<%-- 
    Shared Loader Component for Heavy-Load Pages
    Use: <%@ include file="loader.jsp" %>
--%>
<style>
    /* Page Loader - Full Screen Overlay */
    .page-loader {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(5px);
        z-index: 9999;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        transition: opacity 0.3s ease-out, visibility 0.3s ease-out;
    }
    
    .page-loader.hidden {
        opacity: 0;
        visibility: hidden;
    }
    
    /* Spinner Animation */
    .loader-spinner {
        width: 60px;
        height: 60px;
        border: 5px solid #f3f3f3;
        border-top: 5px solid #3b82f6;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-bottom: 20px;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    /* Loading Text */
    .loader-text {
        font-size: 16px;
        font-weight: 500;
        color: #1e293b;
        margin-top: 10px;
        animation: pulse 1.5s ease-in-out infinite;
    }
    
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }
    
    /* Progress Bar */
    .loader-progress {
        width: 300px;
        height: 4px;
        background: #e2e8f0;
        border-radius: 2px;
        margin-top: 20px;
        overflow: hidden;
    }
    
    .loader-progress-bar {
        height: 100%;
        background: linear-gradient(90deg, #3b82f6, #60a5fa);
        border-radius: 2px;
        animation: progress 2s ease-in-out infinite;
        width: 30%;
    }
    
    @keyframes progress {
        0% { transform: translateX(-100%); }
        50% { transform: translateX(300%); }
        100% { transform: translateX(300%); }
    }
    
    /* Skeleton Loader for Content */
    .skeleton-loader {
        display: block;
        background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
        background-size: 200% 100%;
        animation: loading 1.5s infinite;
        border-radius: 8px;
    }
    
    @keyframes loading {
        0% { background-position: 200% 0; }
        100% { background-position: -200% 0; }
    }
    
    /* Inline Loader for Buttons/Forms */
    .inline-loader {
        display: inline-block;
        width: 16px;
        height: 16px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-top: 2px solid #ffffff;
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
        margin-right: 8px;
        vertical-align: middle;
    }
</style>

<div id="pageLoader" class="page-loader">
    <div class="loader-spinner"></div>
    <div class="loader-text">Loading...</div>
    <div class="loader-progress">
        <div class="loader-progress-bar"></div>
    </div>
</div>

<script>
    // Hide loader when page is fully loaded
    window.addEventListener('load', function() {
        var loader = document.getElementById('pageLoader');
        if (loader) {
            loader.classList.add('hidden');
            setTimeout(function() {
                loader.style.display = 'none';
            }, 100);
        }
    });
    
    // Also hide on DOMContentLoaded for faster perceived performance
    document.addEventListener('DOMContentLoaded', function() {
        // Show content immediately if it's ready
        var mainContent = document.getElementById('main-content');
        if (mainContent) {
            mainContent.style.display = 'block';
        }
    });
    
    // Function to show loader programmatically
    function showLoader(message) {
        var loader = document.getElementById('pageLoader');
        if (loader) {
            var text = loader.querySelector('.loader-text');
            if (text && message) {
                text.textContent = message;
            }
            loader.classList.remove('hidden');
            loader.style.display = 'flex';
        }
    }
    
    // Function to hide loader programmatically
    function hideLoader() {
        var loader = document.getElementById('pageLoader');
        if (loader) {
            loader.classList.add('hidden');
            setTimeout(function() {
                loader.style.display = 'none';
            }, 100);
        }
    }
</script>
