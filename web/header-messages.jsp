<%-- header-messages.jsp --%>
<style>
    /* Alert message styles */
    .alert-message-container {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
        max-width: 400px;
        animation: slideInRight 0.5s ease-out;
    }
    
    .alert {
        padding: 16px 20px;
        border-radius: var(--radius-md);
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 12px;
        box-shadow: var(--shadow-lg);
        position: relative;
        border-left: 4px solid transparent;
        animation: fadeIn 0.3s ease-out;
    }
    
    .alert-success {
        background: linear-gradient(135deg, #d4edda, #c3e6cb);
        color: #155724;
        border-left-color: var(--success);
    }
    
    .alert-error {
        background: linear-gradient(135deg, #f8d7da, #f5c6cb);
        color: #721c24;
        border-left-color: var(--error);
    }
    
    .alert-info {
        background: linear-gradient(135deg, #d1ecf1, #bee5eb);
        color: #0c5460;
        border-left-color: var(--info);
    }
    
    .alert-warning {
        background: linear-gradient(135deg, #fff3cd, #ffeaa7);
        color: #856404;
        border-left-color: var(--warning);
    }
    
    .alert i {
        font-size: 18px;
    }
    
    .alert-close {
        margin-left: auto;
        background: none;
        border: none;
        color: inherit;
        cursor: pointer;
        font-size: 14px;
        opacity: 0.7;
        transition: opacity var(--transition-fast);
    }
    
    .alert-close:hover {
        opacity: 1;
    }
    
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .fade-out {
        animation: fadeOut 0.5s ease-out forwards;
    }
    
    @keyframes fadeOut {
        from { opacity: 1; transform: translateY(0); }
        to { opacity: 0; transform: translateY(-10px); }
    }
</style>

<div class="alert-message-container" id="alertContainer">
    <% 
        String message = (String) session.getAttribute("message");
        String error = (String) session.getAttribute("error");
        
        if (message != null) {
    %>
        <div class="alert alert-success" id="messageAlert">
            <i class="fas fa-check-circle"></i>
            <span><%= message %></span>
            <button class="alert-close" onclick="closeAlert('messageAlert')">
                <i class="fas fa-times"></i>
            </button>
        </div>
    <%
            session.removeAttribute("message");
        }
        
        if (error != null) {
    %>
        <div class="alert alert-error" id="errorAlert">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= error %></span>
            <button class="alert-close" onclick="closeAlert('errorAlert')">
                <i class="fas fa-times"></i>
            </button>
        </div>
    <%
            session.removeAttribute("error");
        }
    %>
</div>

<script>
    // Auto-close alerts after 5 seconds
    document.addEventListener('DOMContentLoaded', function() {
        const alerts = document.querySelectorAll('.alert');
        
        alerts.forEach(alert => {
            setTimeout(() => {
                if (alert.parentElement) {
                    closeAlert(alert.id);
                }
            }, 5000);
        });
        
        // Also close when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.closest('.alert') && !event.target.closest('.alert-close')) {
                alerts.forEach(alert => {
                    if (alert.parentElement) {
                        closeAlert(alert.id);
                    }
                });
            }
        });
    });
    
    function closeAlert(alertId) {
        const alert = document.getElementById(alertId);
        if (alert) {
            alert.classList.add('fade-out');
            setTimeout(() => {
                if (alert.parentElement) {
                    alert.remove();
                }
            }, 500);
        }
    }
</script>