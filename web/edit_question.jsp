<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.User"%>
<%@page import="myPackage.classes.RearrangeItem"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.File"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Add session validation at the VERY TOP of the page
    Object userIdObj = session.getAttribute("userId");
    String userStatus = (String) session.getAttribute("userStatus");
    
    if (userIdObj == null || userStatus == null || !"1".equals(userStatus)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    DatabaseClass pDAO = DatabaseClass.getInstance();
    String qidParam = request.getParameter("qid");
    
    if (qidParam == null || qidParam.trim().isEmpty()) {
        session.setAttribute("error", "Missing question ID parameter");
        response.sendRedirect("adm-page.jsp?pgprt=3");
        return;
    }
    
    int questionId = Integer.parseInt(qidParam);
    Questions questionToEdit = null;
    String questionType = "MCQ";

    try {
        String sql = "SELECT * FROM questions WHERE question_id=?";
        Connection conn = pDAO.getConnection();
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
        questionToEdit = new Questions(
            rs.getInt("question_id"),
            rs.getString("question"),
            rs.getString("opt1"),
            rs.getString("opt2"),
            rs.getString("opt3"),
            rs.getString("opt4"),
            rs.getString("correct"),
            rs.getString("course_name"),
            rs.getString("question_type"),  // 9th parameter
            rs.getString("image_path")      // 10th parameter
        );
            questionType = rs.getString("question_type") != null ? rs.getString("question_type") : "MCQ";
            // Set totalMarks separately since constructor doesn't include it
            questionToEdit.setTotalMarks(rs.getInt("marks"));
        }
        rs.close();
        pstm.close();
        conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    String[] correctAnswers = null;
    if ("MultipleSelect".equals(questionType) && questionToEdit != null) {
        correctAnswers = questionToEdit.getCorrect().split("\\|");
    }
    
    // Get the current course name from the question being edited
    String currentCourseName = "";
    if (questionToEdit != null && questionToEdit.getCourseName() != null) {
        currentCourseName = questionToEdit.getCourseName();
    }
    
    // Drag and Drop/Rearrange data for editing
    int totalMarks = 1;
    String dragItemsJson = "[]";
    String dropTargetsJson = "[]";
    String dragCorrectTargetsJson = "[]";
    String rearrangeItemsJson_db = "[]";

    if (("DRAG_AND_DROP".equals(questionType) || "REARRANGE".equals(questionType)) && questionToEdit != null) {
        try {
            // Get marks from the question object
            if (questionToEdit.getTotalMarks() > 0) {
                totalMarks = questionToEdit.getTotalMarks();
            }
            
            // Get drag-drop data from the JSON columns
            java.util.Map<String, String> dragDropData = pDAO.getDragDropData(questionId);
            if (dragDropData != null) {
                String val;
                val = dragDropData.get("drag_items");
                dragItemsJson = (val != null && !val.trim().isEmpty() && !val.equals("null")) ? val : "[]";
                
                val = dragDropData.get("drop_targets");
                dropTargetsJson = (val != null && !val.trim().isEmpty() && !val.equals("null")) ? val : "[]";
                
                val = dragDropData.get("drag_correct_targets");
                dragCorrectTargetsJson = (val != null && !val.trim().isEmpty() && !val.equals("null")) ? val : "[]";
            }

            if ("REARRANGE".equals(questionType)) {
                ArrayList<myPackage.classes.RearrangeItem> rItems = pDAO.getRearrangeItems(questionId);
                JSONArray rArray = new JSONArray();
                for (myPackage.classes.RearrangeItem ri : rItems) {
                    rArray.put(ri.getItemText());
                }
                rearrangeItemsJson_db = rArray.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Initialize with empty data if there's an error
            dragItemsJson = "[]";
            dropTargetsJson = "[]";
            dragCorrectTargetsJson = "[]";
        }
    }

%>



<style>
    /* Use the same CSS Variables as the profile page */
    :root {
        /* Primary Colors */
        --primary-blue: #09294d;
        --secondary-blue: #1a3d6d;
        --accent-blue: #4a90e2;
        
        /* Neutral Colors */
        --white: #ffffff;
        --light-gray: #f8fafc;
        --medium-gray: #e2e8f0;
        --dark-gray: #64748b;
        --text-dark: #1e293b;
        
        /* Semantic Colors */
        --success: #059669;
        --warning: #d97706;
        --error: #dc2626;
        --info: #0891b2;
        
        /* Spacing */
        --spacing-xs: 4px;
        --spacing-sm: 8px;
        --spacing-md: 16px;
        --spacing-lg: 24px;
        --spacing-xl: 32px;
        
        /* Border Radius */
        --radius-sm: 4px;
        --radius-md: 8px;
        --radius-lg: 16px;
        
        /* Shadows */
        --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
        --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
        
        /* Transitions */
        --transition-fast: 0.15s ease;
        --transition-normal: 0.2s ease;
        --transition-slow: 0.3s ease;
    }
    
    /* Reset and Base Styles - Same as profile page */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        line-height: 1.5;
        color: var(--text-dark);
        background-color: var(--light-gray);
    }
    
    /* Layout Structure */
    .dashboard-container {
        display: flex;
        min-height: 100vh;
    }
    
    /* Sidebar Styles - Same as profile page */
    .sidebar {
        width: 200px;
        background: linear-gradient(180deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        flex-shrink: 0;
        position: sticky;
        top: 0;
        height: 100vh;
    }
    
    .sidebar-header {
        padding: var(--spacing-xl) var(--spacing-lg);
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .mut-logo {
        max-height: 150px;
        width: auto;
        filter: brightness(0) invert(1);
    }
    
    .sidebar-nav {
        padding: var(--spacing-lg) 0;
    }
    
    .nav-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-md);
        padding: var(--spacing-md) var(--spacing-lg);
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        transition: all var(--transition-normal);
        border-left: 3px solid transparent;
    }
    
    .nav-item:hover {
        background: rgba(255, 255, 255, 0.1);
        color: var(--white);
        border-left-color: var(--accent-blue);
    }
    
    .nav-item.active {
        background: rgba(255, 255, 255, 0.15);
        color: var(--white);
        border-left-color: var(--white);
    }
    
    .nav-item i {
        width: 20px;
        text-align: center;
    }
    
    .nav-item h2 {
        font-size: 14px;
        font-weight: 500;
        margin: 0;
    }
    
    /* Main Content Area */
    .main-content {
        flex: 1;
        padding: var(--spacing-lg);
        overflow-y: auto;
    }
    
    /* Page Header */
    .page-header {
        background: var(--white);
        border-radius: var(--radius-md);
        padding: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--medium-gray);
    }
    
    .page-title {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        font-size: 18px;
        font-weight: 600;
        color: var(--text-dark);
    }
    
    .stats-badge {
        background: linear-gradient(135deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: 6px 16px;
        border-radius: 20px;
        font-size: 13px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    /* Question Cards */
    .question-card {
        background: var(--white);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        border: 1px solid var(--medium-gray);
        margin-bottom: var(--spacing-lg);
        overflow: hidden;
        transition: transform var(--transition-normal), box-shadow var(--transition-normal);
    }
    
    .question-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
    }
    
    .card-header {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
        padding: var(--spacing-md) var(--spacing-lg);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .card-header span {
        font-size: 14px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    /* Question Form */
    .question-form {
        padding: var(--spacing-lg);
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: var(--spacing-md);
        margin-bottom: var(--spacing-lg);
    }
    
    .form-group {
        display: flex;
        flex-direction: column;
    }
    
    .form-label {
        font-weight: 600;
        color: var(--text-dark);
        font-size: 13px;
        margin-bottom: var(--spacing-xs);
        display: flex;
        align-items: center;
        gap: var(--spacing-xs);
    }
    
    .form-control,
    .form-select,
    .question-input,
    .option-input {
        padding: 10px 12px;
        border: 1px solid var(--medium-gray);
        border-radius: var(--radius-sm);
        font-size: 14px;
        transition: all var(--transition-fast);
        background: var(--white);
        color: var(--text-dark);
    }
    
    .form-control:focus,
    .form-select:focus,
    .question-input:focus,
    .option-input:focus {
        outline: none;
        border-color: var(--accent-blue);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
    }
    
    .form-select {
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M2 4l4 4 4-4z'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 12px center;
        background-size: 12px;
        padding-right: 32px;
    }
    
    /* Options Grid */
    .options-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: var(--spacing-sm);
        margin: var(--spacing-md) 0;
    }
    
    .question-input {
        width: 100%;
        min-height: 150px;
        resize: vertical;
    }
    
    /* Form Actions - Consistent with profile page */
    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: var(--spacing-md);
        padding-top: var(--spacing-lg);
        border-top: 1px solid var(--medium-gray);
        margin-top: var(--spacing-lg);
    }
    
    /* Buttons - Consistent with profile page */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--spacing-sm);
        padding: 10px 20px;
        border-radius: var(--radius-sm);
        font-size: 14px;
        font-weight: 500;
        text-decoration: none;
        cursor: pointer;
        border: none;
        transition: all var(--transition-normal);
    }
    
    .btn-primary {
        background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
        color: var(--white);
    }
    
    .btn-primary:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(9, 41, 77, 0.2);
    }
    
    .btn-success {
        background: linear-gradient(90deg, var(--success), #10b981);
        color: var(--white);
    }
    
    .btn-success:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(5, 150, 105, 0.2);
    }
    
    .btn-outline {
        background: transparent;
        border: 1px solid var(--medium-gray);
        color: var(--dark-gray);
    }
    
    .btn-outline:hover {
        background: var(--light-gray);
        border-color: var(--dark-gray);
    }
    
    /* Alert Messages */
    .alert {
        background: #d4edda;
        color: #155724;
        padding: var(--spacing-md);
        border-radius: var(--radius-sm);
        margin-bottom: var(--spacing-lg);
        border: 1px solid #c3e6cb;
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
    }
    
    .alert i {
        color: var(--success);
    }
    
    /* Checkbox Styling */
    .form-check {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        padding: var(--spacing-sm);
        background: var(--light-gray);
        border-radius: var(--radius-sm);
        border: 1px solid var(--medium-gray);
        transition: all var(--transition-fast);
    }
    
    .form-check:hover {
        background: var(--white);
        border-color: var(--accent-blue);
    }
    
    .form-check-label {
        font-size: 13px;
        color: var(--text-dark);
        cursor: pointer;
    }
    
    .form-check-input {
        accent-color: var(--primary-blue);
    }
    
    .form-hint {
        font-size: 12px;
        color: var(--dark-gray);
        margin-top: var(--spacing-xs);
    }
    
    .code-question-indicator {
        background: linear-gradient(135deg, var(--accent-blue), #3b82f6);
        color: var(--white);
        padding: var(--spacing-sm) var(--spacing-md);
        border-radius: var(--radius-sm);
        margin-bottom: var(--spacing-md);
        border-left: 3px solid var(--primary-blue);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        font-weight: 500;
        font-size: 13px;
    }
    
    .code-snippet {
        background: var(--primary-blue);
        color: var(--light-gray);
        border: 1px solid var(--secondary-blue);
        border-radius: var(--radius-sm);
        padding: var(--spacing-md);
        margin: var(--spacing-md) 0;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 13px;
        line-height: 1.5;
        overflow-x: auto;
        position: relative;
    }
    
    .code-header {
        color: var(--dark-gray);
        font-size: 12px;
        margin-bottom: var(--spacing-sm);
        display: flex;
        align-items: center;
        gap: var(--spacing-sm);
        border-bottom: 1px solid var(--secondary-blue);
        padding-bottom: var(--spacing-sm);
    }
    
    /* Utility Classes */
    .hidden {
        display: none;
    }
    
    /* Responsive Design - Consistent with profile page */
    @media (max-width: 768px) {
        .dashboard-container {
            flex-direction: column;
        }
        
        .sidebar {
            width: 100%;
            height: auto;
            position: static;
        }
        
        .sidebar-nav {
            display: flex;
            overflow-x: auto;
            padding: var(--spacing-sm);
        }
        
        .nav-item {
            flex-direction: column;
            padding: var(--spacing-sm);
            min-width: 80px;
            text-align: center;
            border-left: none;
            border-bottom: 3px solid transparent;
        }
        
        .nav-item.active {
            border-left: none;
            border-bottom-color: var(--white);
        }
        
        .nav-item:hover {
            border-left: none;
            border-bottom-color: var(--accent-blue);
        }
        
        .page-header {
            flex-direction: column;
            gap: var(--spacing-md);
            text-align: center;
        }
        
        .form-actions {
            flex-direction: column;
        }
        
        .btn {
            width: 100%;
        }
        
        .options-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    
    @media (max-width: 480px) {
        .main-content {
            padding: var(--spacing-md);
        }
        
        .question-form {
            padding: var(--spacing-md);
        }
        
        .options-grid {
            grid-template-columns: 1fr;
        }
        
        .card-header {
            flex-direction: column;
            gap: var(--spacing-sm);
            text-align: center;
        }
    }
    
    /* Loading State */
    .loading {
        opacity: 0.7;
        pointer-events: none;
    }
    
    .loading::after {
        content: '';
        display: inline-block;
        width: 14px;
        height: 14px;
        border: 2px solid var(--light-gray);
        border-top: 2px solid var(--primary-blue);
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-left: var(--spacing-sm);
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    /* Add these styles to eliminate scrolling */
    .main-content {
        position: relative;
        max-height: calc(100vh - 100px);
        overflow-y: auto;
        padding-right: 10px;
    }
    
    .main-content::-webkit-scrollbar {
        width: 8px;
    }
    
    .main-content::-webkit-scrollbar-track {
        background: var(--light-gray);
        border-radius: 4px;
    }
    
    .main-content::-webkit-scrollbar-thumb {
        background: var(--dark-gray);
        border-radius: 4px;
    }
    
    .question-card:first-of-type {
        margin-bottom: 30px;
    }
    
    .sticky-add-form {
        position: sticky;
        top: 20px;
        background: var(--white);
        box-shadow: var(--shadow-lg);
        border: 2px solid var(--primary-blue);
        border-radius: var(--radius-md);
        z-index: 100;
        margin-top: 20px;
    }
    
    .quick-add-indicator {
        background: linear-gradient(90deg, var(--success-light), #d4edda);
        color: var(--success);
        padding: 8px 12px;
        border-radius: var(--radius-sm);
        margin-bottom: 15px;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
        border-left: 3px solid var(--success);
        animation: fadeIn 0.5s ease;
    }
    
    .quick-add-indicator i {
        font-size: 14px;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .form-highlight {
        animation: pulseHighlight 2s ease-in-out;
    }
    
    @keyframes pulseHighlight {
        0% { box-shadow: 0 0 0 0 rgba(9, 41, 77, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(9, 41, 77, 0); }
        100% { box-shadow: 0 0 0 0 rgba(9, 41, 77, 0); }
    }
    
    
.scroll-indicator{
    position:fixed;
    right:20px;
    bottom:20px;
    width:48px;
    height:48px;
    background:#2563eb;
    color:#fff;
    border-radius:50%;
    display:flex;
    align-items:center;
    justify-content:center;
    cursor:pointer;
    z-index:1000;
    box-shadow:0 6px 20px rgba(0,0,0,.3);
}

/* Drag and Drop Styles */
.drag-items-list, .drop-targets-list, .pairings-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    min-height: 100px;
    padding: 10px;
    background: var(--light-gray);
    border: 1px solid var(--medium-gray);
    border-radius: var(--radius-sm);
}

.drag-item, .drop-target, .pairing-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    background: var(--white);
    border: 1px solid var(--medium-gray);
    border-radius: var(--radius-sm);
    transition: all var(--transition-fast);
}

.drag-item:hover, .drop-target:hover, .pairing-item:hover {
    border-color: var(--accent-blue);
    box-shadow: var(--shadow-sm);
}

.drag-item i, .drop-target i, .pairing-item i {
    color: var(--primary-blue);
    font-size: 14px;
    flex-shrink: 0;
}

.drag-item input, .drop-target input {
    flex: 1;
    border: none;
    outline: none;
    background: transparent;
    font-size: 14px;
}

.pairing-item span {
    flex: 1;
    font-size: 14px;
    color: var(--text-dark);
}

.pairing-select {
    flex: 1;
    padding: 4px 8px;
    border: 1px solid var(--medium-gray);
    border-radius: var(--radius-sm);
    font-size: 13px;
    background: var(--white);
}

.remove-btn {
    background: var(--error);
    color: var(--white);
    border: none;
    border-radius: 50%;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 12px;
    transition: all var(--transition-fast);
    flex-shrink: 0;
}

.remove-btn:hover {
    background: #b91c1c;
    transform: scale(1.1);
}

/* Drag and Drop Editor Styles */
.drag-drop-editor {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-top: 10px;
    border: 1px solid var(--medium-gray);
}

.drag-drop-column {
    background: white;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 350px;
    border: 1px solid #e9ecef;
}

.column-header {
    padding: 15px;
    display: flex;
    align-items: center;
    gap: 10px;
    color: white;
}

.column-header i {
    font-size: 1.2rem;
}

.column-header h3 {
    margin: 0;
    font-size: 1rem;
    font-weight: 600;
    flex: 1;
}

.item-count {
    background: rgba(255,255,255,0.2);
    padding: 3px 8px;
    border-radius: 20px;
    font-size: 0.85rem;
    font-weight: 600;
}

.column-content {
    padding: 15px;
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #f8f9fa;
}

.items-list {
    flex: 1;
    min-height: 200px;
    max-height: 300px;
    overflow-y: auto;
    margin-bottom: 15px;
    padding: 5px;
}

.empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 150px;
    color: var(--dark-gray);
    text-align: center;
}

.empty-state i {
    font-size: 2.5rem;
    margin-bottom: 10px;
    opacity: 0.3;
}

.empty-state p {
    margin: 0;
    font-size: 0.9rem;
}

/* Drag Item Styles */
.drag-item, .drop-target, .pairing-item {
    background: white;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    padding: 12px;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    transition: all 0.2s ease;
}

.row-draggable {
    cursor: move;
}

.row-dragging {
    opacity: 0.4;
    border: 2px dashed var(--accent-blue);
}

.drag-handle {
    cursor: move;
    color: var(--dark-gray);
}

.drag-item:hover, .drop-target:hover, .pairing-item:hover {
    box-shadow: 0 3px 8px rgba(0,0,0,0.1);
    border-color: var(--primary-blue);
}

.drag-item i, .drop-target i, .pairing-item i {
    color: var(--primary-blue);
    font-size: 1rem;
    opacity: 0.7;
}

.drop-target i {
    color: var(--success);
}

.pairing-item i {
    color: var(--warning);
}

.drag-item textarea, .drop-target textarea {
    flex: 1;
    border: 1px solid transparent;
    background: #f8f9fa;
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 0.9rem;
    transition: all 0.2s ease;
    resize: none;
    overflow: hidden;
    min-height: 38px;
}

.drag-item textarea:focus, .drop-target textarea:focus {
    background: white;
    border-color: var(--primary-blue);
    outline: none;
    box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
}

.remove-btn {
    background: none;
    border: none;
    color: #dc3545;
    font-size: 1.2rem;
    cursor: pointer;
    padding: 0 5px;
    opacity: 0.6;
    transition: all 0.2s ease;
}

.remove-btn:hover {
    opacity: 1;
    transform: scale(1.1);
}

/* Pairing Select Styles */
.pairing-select {
    flex: 1;
    padding: 8px 12px;
    border: 1px solid #e9ecef;
    border-radius: 6px;
    background: #f8f9fa;
    font-size: 0.9rem;
    cursor: pointer;
}

.pairing-select:focus {
    border-color: var(--primary-blue);
    outline: none;
    box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
}

.add-item-btn {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 10px;
    background: white;
    border: 2px dashed var(--medium-gray);
    color: var(--dark-gray);
    font-weight: 500;
    transition: all 0.2s ease;
}

.add-item-btn:hover {
    border-color: var(--primary-blue);
    color: var(--primary-blue);
    background: rgba(0,123,255,0.05);
}

.pairing-hint {
    margin-top: 10px;
    padding: 10px;
    background: #fff3cd;
    border-radius: 6px;
    color: #856404;
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.85rem;
}

.pairing-hint i {
    font-size: 1rem;
}

/* Scrollbar Styling */
.items-list::-webkit-scrollbar {
    width: 6px;
}

.items-list::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

.items-list::-webkit-scrollbar-thumb {
    background: var(--medium-gray);
    border-radius: 10px;
}

.items-list::-webkit-scrollbar-thumb:hover {
    background: var(--dark-gray);
}

/* Responsive Design */
@media (max-width: 1200px) {
    .drag-drop-editor > div {
        grid-template-columns: 1fr !important;
        gap: 15px !important;
    }
    
    .drag-drop-column {
        min-height: 300px;
    }
}

/* Orientation preview styles for drag-drop editor */
#dragDropEditor {
    transition: all 0.3s ease;
}

#dragDropEditor.horizontal-layout {
    /* Default horizontal layout - three column grid */
}

#dragDropEditor.horizontal-layout .drop-targets-list {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 15px;
    align-items: center;
}

#dragDropEditor.horizontal-layout .drop-target {
    min-width: 120px;
    flex: 1 1 auto;
}

#dragDropEditor.vertical-layout {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

#dragDropEditor.vertical-layout > div {
    width: 100%;
}

#dragDropEditor.landscape-layout {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 20px;
    align-items: start;
}

#dragDropEditor.landscape-layout .draggable-items-panel {
    padding: 15px;
    background: #f1f5f9;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
}

#dragDropEditor.landscape-layout .drop-targets-panel {
    padding: 15px;
    background: #ffffff;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
}

#dragDropEditor.landscape-layout .drop-targets-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

</style>

<div class="dashboard-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="IMG/mut.png" alt="CodeSA Institute Pty LTD Logo" class="mut-logo">
        </div>
        <nav class="sidebar-nav">
            <a href="adm-page.jsp?pgprt=0" class="nav-item">
                <i class="fas fa-user"></i>
                <h2>Profile</h2>
            </a>
            <a href="adm-page.jsp?pgprt=2" class="nav-item">
                <i class="fas fa-book"></i>
                <h2>Courses</h2>
            </a>
            <a href="adm-page.jsp?pgprt=3" class="nav-item active">
                <i class="fas fa-question-circle"></i>
                <h2>Questions</h2>
            </a>
            <a href="adm-page.jsp?pgprt=5" class="nav-item">
                <i class="fas fa-chart-bar"></i>
                <h2>Results</h2>
            </a>
            <a href="adm-page.jsp?pgprt=1" class="nav-item">
                <i class="fas fa-users"></i>
                <h2>Accounts</h2>
            </a>

            <a href="adm-page.jsp?pgprt=7" class="nav-item">
               <i class="fas fa-users"></i>
               <h2>Registers</h2>
           </a>
        </nav>
    </aside>
    
    <main class="main-content">
        <header class="page-header">
            <div class="page-title">
                <i class="fas fa-edit"></i>Edit Question
                <span class="question-type-badge"><i class="fas fa-tag"></i><%= questionType %></span>
            </div>
            <div class="stats-badge">
                <i class="fas fa-hashtag"></i>Question ID: <%= questionToEdit.getQuestionId() %>
                &nbsp;&nbsp;
                <i class="fas fa-book"></i>Course: <%= currentCourseName %>
            </div>
        </header>
        
        <% String message = (String) session.getAttribute("message");
           if (message != null) { %>
            <div class="alert"><i class="fas fa-check-circle"></i> <%= message %></div>
        <% session.removeAttribute("message"); } %>

        <div class="question-card" id="editQuestionPanel">
            <div class="card-header"><span><i class="fas fa-edit"></i> Edit Question</span><i class="fas fa-question-circle" style="opacity: 0.8;"></i></div>
            <div class="question-form">
                <form action="controller.jsp" method="POST" id="editQuestionForm" enctype="multipart/form-data">
                    <input type="hidden" name="page" value="questions">
                    <input type="hidden" name="operation" value="edit">
                    <input type="hidden" name="qid" value="<%= questionToEdit.getQuestionId() %>">
                    <input type="hidden" name="coursename" value="<%= currentCourseName %>">
                    <input type="hidden" id="currentImagePath" name="currentImagePath" value="<%= questionToEdit.getImagePath() != null ? questionToEdit.getImagePath() : "" %>">
                    <input type="hidden" id="questionTypeHidden" name="questionType" value="<%= questionType %>">

                    <div class="form-grid">
                        <div class="form-group">
<label class="form-label"><i class="fas fa-book" style="color: var(--accent-blue);"></i>Select Course</label>
<select name="coursename" class="form-select" id="courseSelectEdit" required>
    <!-- Add current course as selected option first -->
    <option value="<%= currentCourseName %>" selected><%= currentCourseName %></option>
    
    <!-- Then list all other courses -->
    <%
        ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
        for (String course : allCourseNames) { 
            // Skip current course because it's already added
            if (!course.equals(currentCourseName)) {
    %>
        <option value="<%= course %>"><%= course %></option>
    <%
            }
        }
    %>
</select>

<!-- Store original course -->
<input type="hidden" name="originalCourse" value="<%= currentCourseName %>">

                        </div>

                        <div class="form-group">
                            <label class="form-label"><i class="fas fa-question" style="color: var(--info);"></i>Question Type</label>
                            <select id="questionTypeSelect" class="form-select" onchange="if(typeof toggleEditOptions === 'function') toggleEditOptions()">
                                <option value="MCQ" <%= "MCQ".equals(questionType) ? "selected" : "" %>>Multiple Choice (Single Answer)</option>
                                <option value="MultipleSelect" <%= "MultipleSelect".equals(questionType) ? "selected" : "" %>>Multiple Select (Choose Two)</option>
                                <option value="TrueFalse" <%= "TrueFalse".equals(questionType) ? "selected" : "" %>>True / False</option>
                                <option value="Code" <%= "Code".equals(questionType) ? "selected" : "" %>>Code Snippet</option>
                                <option value="DRAG_AND_DROP" <%= "DRAG_AND_DROP".equals(questionType) ? "selected" : "" %>>Drag and Drop</option>
                                <option value="REARRANGE" <%= "REARRANGE".equals(questionType) ? "selected" : "" %>>Rearrange (Order Items)</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-pencil-alt" style="color: var(--success);"></i>Your Question</label>
                        <textarea name="question" id="editQuestionTextarea" class="question-input" rows="3"><%= questionToEdit.getQuestion() %></textarea>
                        <small class="form-hint">Enter your question text (optional if uploading an image)</small>
                        <!-- Preview for Code Snippets -->
                        <div id="codePreview" style="display: none; margin-top: 10px;">
                            <div class="code-question-indicator"><i class="fas fa-code"></i><strong>Code Analysis Question Preview</strong></div>
                            <div class="code-snippet">
                                <div class="code-header"><i class="fas fa-code"></i><span>Code to Analyze</span></div>
                                <pre id="previewCode"></pre>
                            </div>
                        </div>
                    </div>

                    <div id="editMcqOptions">
                        <div class="form-group">
                            <label class="form-label"><i class="fas fa-list-ol"></i> Options</label>
                            <div class="options-grid">
                                <textarea name="opt1" id="editOpt1" class="option-input" required rows="2"><%= questionToEdit.getOpt1() %></textarea>
                                <textarea name="opt2" id="editOpt2" class="option-input" required rows="2"><%= questionToEdit.getOpt2() %></textarea>
                                <textarea name="opt3" id="editOpt3" class="option-input" rows="2"><%= questionToEdit.getOpt3() != null ? questionToEdit.getOpt3() : "" %></textarea>
                                <textarea name="opt4" id="editOpt4" class="option-input" rows="2"><%= questionToEdit.getOpt4() != null ? questionToEdit.getOpt4() : "" %></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-check-circle" style="color: var(--success);"></i>Correct Answer</label>
                        <div id="editCorrectAnswerContainer">
                            <textarea id="editCorrectAnswer" name="correct" class="form-control" required rows="2"><%= questionToEdit.getCorrect() %></textarea>
                            <small class="form-hint">Must match one of the options exactly</small>
                        </div>

                        <div id="editTrueFalseContainer" style="display:none;">
                            <select id="editTrueFalseSelect" name="correct" class="form-select">
                                <option value="" disabled selected>Select the correct answer</option>
                                <option value="True" <%= "True".equalsIgnoreCase(questionToEdit.getCorrect()) ? "selected" : "" %>>True</option>
                                <option value="False" <%= "False".equalsIgnoreCase(questionToEdit.getCorrect()) ? "selected" : "" %>>False</option>
                            </select>
                            <small class="form-hint">Select the correct answer for True/False question</small>
                        </div>

                        <div id="editMultipleCorrectContainer" style="display:none;">
                            <div class="options-grid">
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt1" class="form-check-input edit-correct-checkbox" value="">
                                    <label for="editCorrectOpt1" class="form-check-label">Option 1</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt2" class="form-check-input edit-correct-checkbox" value="">
                                    <label for="editCorrectOpt2" class="form-check-label">Option 2</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt3" class="form-check-input edit-correct-checkbox" value="">
                                    <label for="editCorrectOpt3" class="form-check-label">Option 3</label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" id="editCorrectOpt4" class="form-check-input edit-correct-checkbox" value="">
                                    <label for="editCorrectOpt4" class="form-check-label">Option 4</label>
                                </div>
                            </div>
                            <small class="form-hint">Select exactly 2 correct answers</small>
                        </div>
                    </div>
                    
                    <!-- Drag and Drop Section - FIXED LAYOUT -->
                    <div id="editDragDropOptions" style="display: none;">
                        <!-- Total Marks and Orientation - Row -->
                        <div class="form-grid" style="margin-bottom: 20px;">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-star" style="color: var(--warning);"></i>
                                    Total Marks
                                </label>
                                <input type="number" id="totalMarksInput" name="totalMarks" class="form-control" 
                                       value="1" min="1" max="100" required>
                                <small class="form-hint">Total marks for this drag-and-drop question</small>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-columns" style="color: var(--info);"></i>
                                    Orientation
                                </label>
                                <select name="orientation" id="editOrientationSelect" class="form-select">
                                    <option value="horizontal">Horizontal (Side by Side)</option>
                                    <option value="vertical">Vertical (Stacked)</option>
                                    <option value="landscape">Landscape (Code Style)</option>
                                </select>
                                <small class="form-hint">How items and targets are laid out</small>
                            </div>
                        </div>

                        <!-- Drag and Drop Editor Container -->
                        <div id="dragDropEditor" class="drag-drop-editor" style="display: none;">
                            <!-- Three Column Layout -->
                            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 25px; margin-top: 10px;">
                                
                                <!-- Column 1: Draggable Items -->
                                <div class="drag-drop-column">
                                    <div class="column-header" style="background: linear-gradient(135deg, var(--primary-blue), #0056b3);">
                                        <i class="fas fa-grip-vertical"></i>
                                        <h3>Draggable Items</h3>
                                        <span class="item-count" id="dragItemCount">0</span>
                                    </div>
                                    <div class="column-content">
                                        <div id="dragItemsContainer" class="items-list drag-items-list">
                                            <!-- Items will be populated here -->
                                            <div class="empty-state">
                                                <i class="fas fa-arrows-alt"></i>
                                                <p>No draggable items yet</p>
                                            </div>
                                        </div>
                                        <button type="button" class="btn btn-outline add-item-btn" onclick="addDragItem()">
                                            <i class="fas fa-plus-circle"></i>
                                            Add Draggable Item
                                        </button>
                                    </div>
                                </div>
                                
                                <!-- Column 2: Drop Targets -->
                                <div class="drag-drop-column">
                                    <div class="column-header" style="background: linear-gradient(135deg, var(--success), #1e7e34);">
                                        <i class="fas fa-bullseye"></i>
                                        <h3>Drop Targets</h3>
                                        <span class="item-count" id="dropTargetCount">0</span>
                                    </div>
                                    <div class="column-content">
                                        <div id="dropTargetsContainer" class="items-list drop-targets-list">
                                            <!-- Targets will be populated here -->
                                            <div class="empty-state">
                                                <i class="fas fa-bullseye"></i>
                                                <p>No drop targets yet</p>
                                            </div>
                                        </div>
                                        <button type="button" class="btn btn-outline add-item-btn" onclick="addDropTarget()">
                                            <i class="fas fa-plus-circle"></i>
                                            Add Drop Target
                                        </button>
                                    </div>
                                </div>
                                
                                <!-- Column 3: Correct Pairings -->
                                <div class="drag-drop-column">
                                    <div class="column-header" style="background: linear-gradient(135deg, var(--warning), #d39e00);">
                                        <i class="fas fa-link"></i>
                                        <h3>Correct Pairings</h3>
                                        <span class="item-count" id="pairingCount">0</span>
                                    </div>
                                    <div class="column-content">
                                        <div id="correctPairingsContainer" class="items-list pairings-list">
                                            <!-- Pairings will be populated here -->
                                            <div class="empty-state">
                                                <i class="fas fa-link"></i>
                                                <p>Add items and targets to create pairings</p>
                                            </div>
                                        </div>
                                        <div class="pairing-hint">
                                            <i class="fas fa-info-circle"></i>
                                            <small>Select which drag item belongs to each drop target</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Hidden fields for data storage -->
                        <input type="hidden" id="dragItemsHidden" name="dragItemsHidden" value="">
                        <input type="hidden" id="dropTargetsHidden" name="dropTargetsHidden" value="">
                        <input type="hidden" id="correctTargetsHidden" name="correctTargetsHidden" value="">
                    </div>
                    
                    <!-- Rearrange Section -->
                    <div id="editRearrangeOptions" style="display: none;">
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-star" style="color: var(--warning);"></i>
                                    Total Marks
                                </label>
                                <input type="number" id="rearrangeTotalMarks" name="totalMarks" class="form-control" 
                                       value="1" min="1" max="100">
                                <small class="form-hint">Total marks for this rearrange question</small>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-paint-brush" style="color: var(--info);"></i>
                                    Display Style
                                </label>
                                <select name="rearrangeStyle" id="editRearrangeStyleSelect" class="form-select">
                                    <option value="vertical">Vertical (Stacked)</option>
                                    <option value="horizontal">Horizontal (Side by Side)</option>
                                    <option value="grid">Grid Layout</option>
                                </select>
                                <small class="form-hint">How items are displayed</small>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-th" style="color: var(--info);"></i>
                                Items to Rearrange
                            </label>
                            <div class="alert alert-info" style="margin-bottom: 15px; font-size: 13px; background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; padding: 10px;">
                                <i class="fas fa-info-circle"></i>
                                <span>Add items in their <strong>correct order</strong>. Students will need to rearrange them.</span>
                            </div>
                            <div id="rearrangeItemsContainer" class="items-list">
                                <!-- Items will be added here -->
                            </div>
                            <button type="button" class="btn btn-outline add-item-btn" onclick="addRearrangeItem()">
                                <i class="fas fa-plus-circle"></i>
                                Add Rearrange Item
                            </button>
                        </div>
                        
                        <input type="hidden" id="rearrangeItemsHidden" name="rearrangeItemsHidden" value="">
                    </div>
                    
                    <!-- Image Upload Section -->
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-image" style="color: var(--info);"></i> Upload Question Image (Optional)</label>
                        <div id="currentImageDisplay" style="margin-bottom: 15px;">
                            <% if (questionToEdit.getImagePath() != null && !questionToEdit.getImagePath().isEmpty()) { %>
                                <div class="file-name-display" style="display: flex; align-items: center; gap: 10px; padding: 10px; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: var(--radius-sm);">
                                    <i class="fas fa-image"></i>
                                    <span>Current Image: <%= new File(questionToEdit.getImagePath()).getName() %></span>
                                    <button type="button" class="remove-file-btn" onclick="removeCurrentImage()">×</button>
                                </div>
                                <div style="margin-top: 10px; text-align: center;">
                                    <img src="<%= questionToEdit.getImagePath() %>" alt="Current Question Image" style="max-width: 200px; max-height: 200px; border-radius: var(--radius-sm); border: 1px solid var(--medium-gray);">
                                </div>
                            <% } else { %>
                                <div class="form-hint">No image currently uploaded</div>
                            <% } %>
                        </div>
                        <div class="drop-zone" id="editImageDropZone">
                            <div class="drop-zone-content">
                                <i class="fas fa-cloud-upload-alt drop-icon"></i>
                                <p class="drop-text">Drag & drop a new image here or click to browse</p>
                                <p class="drop-hint">Supports JPG, PNG, GIF, WebP (Max 3MB)</p>
                                <input type="file" name="imageFile" class="form-control" id="editImageFile" accept=".jpg,.jpeg,.png,.gif,.webp" style="display: none;">
                            </div>
                        </div>
                        <div id="editImageFileNameDisplay" class="file-name-display" style="display: none; margin-top: 10px;">
                            <i class="fas fa-image"></i>
                            <span id="editImageFileName"></span>
                            <button type="button" class="remove-file-btn" onclick="removeEditImageFile()">×</button>
                        </div>
                        <small class="form-hint">Upload a new image to replace the current one (optional)</small>
                    </div>
                    
                    <!-- Image Preview Section -->
                    <div id="editImagePreviewSection" class="form-group" style="display: none;">
                        <label class="form-label"><i class="fas fa-eye" style="color: var(--success);"></i> Image Preview</label>
                        <div style="text-align: center; padding: 10px; border: 1px solid var(--medium-gray); border-radius: var(--radius-sm);">
                            <img id="editImagePreview" src="#" alt="Image Preview" style="max-width: 100%; max-height: 200px; display: none; border-radius: var(--radius-sm);">
                            <p id="editPreviewPlaceholder" style="color: var(--dark-gray); margin: 0;">New image will appear here</p>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="adm-page.jsp?coursename=<%= currentCourseName %>&pgprt=4" class="btn btn-outline"><i class="fas fa-times"></i> Cancel</a>
                        <button type="submit" class="btn btn-primary" id="editSubmitBtn" onclick="return validateAndSubmit(event)"><i class="fas fa-save"></i> Update Question</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<script src="drag_drop_edit.js"></script>

<script>
    // 🔹 STEP 3 — Pass JSON Data to JavaScript
    const dragItemsFromDB = <%= dragItemsJson %>;
    const dropTargetsFromDB = <%= dropTargetsJson %>;
    const correctTargetsFromDB = <%= dragCorrectTargetsJson %>;
    const rearrangeItemsFromDB = <%= rearrangeItemsJson_db %>;
    const totalMarksFromDB = <%= totalMarks %>;
    
    console.log('=== JSON Data from DB ===');
    console.log('Drag Items:', dragItemsFromDB);
    console.log('Drop Targets:', dropTargetsFromDB);
    console.log('Correct Targets:', correctTargetsFromDB);
    console.log('Total Marks:', totalMarksFromDB);
    
    // Modal functions for edit form
    function showModal(title, message) {
        // Create modal if it doesn't exist
        let modal = document.getElementById('validationModal');
        if (!modal) {
            // Create modal container
            modal = document.createElement('div');
            modal.id = 'validationModal';
            modal.style.cssText = `
                display: block;
                position: fixed;
                z-index: 10000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.4);
            `;
            
            // Create modal content
            const modalContent = document.createElement('div');
            modalContent.style.cssText = `
                background-color: #fefefe;
                margin: 15% auto;
                padding: 20px;
                border: none;
                border-radius: 8px;
                width: 50%;
                max-width: 500px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                position: relative;
            `;
            
            // Create close button
            const closeBtn = document.createElement('span');
            closeBtn.innerHTML = '&times;';
            closeBtn.style.cssText = `
                color: #aaa;
                float: right;
                font-size: 28px;
                font-weight: bold;
                cursor: pointer;
                line-height: 1;
            `;
            closeBtn.onclick = function() {
                modal.style.display = 'none';
            };
            
            // Create title element
            const titleEl = document.createElement('h3');
            titleEl.id = 'modalTitle';
            titleEl.style.cssText = `
                margin-top: 0;
                margin-bottom: 15px;
                color: #333;
                border-bottom: 1px solid #eee;
                padding-bottom: 10px;
            `;
            
            // Create message element
            const messageEl = document.createElement('p');
            messageEl.id = 'modalMessage';
            messageEl.style.cssText = `
                margin: 15px 0;
                color: #666;
                line-height: 1.5;
            `;
            
            // Create OK button
            const okBtn = document.createElement('button');
            okBtn.innerHTML = 'OK';
            okBtn.style.cssText = `
                background: linear-gradient(90deg, var(--primary-blue), var(--secondary-blue));
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 4px;
                cursor: pointer;
                float: right;
            `;
            okBtn.onclick = function() {
                modal.style.display = 'none';
            };
            
            // Assemble the modal
            modalContent.appendChild(closeBtn);
            modalContent.appendChild(titleEl);
            modalContent.appendChild(messageEl);
            modalContent.appendChild(okBtn);
            modal.appendChild(modalContent);
            
            document.body.appendChild(modal);
        }
        
        // Update modal content
        let icon = 'fa-exclamation-triangle';
        if (title === 'Success') icon = 'fa-check-circle';
        document.getElementById('modalTitle').innerHTML = '<i class="fas ' + icon + '"></i> ' + title;
        document.getElementById('modalMessage').textContent = message;
        
        // Show modal
        modal.style.display = 'block';
    }
    
    // Smart parsing functions for multi-line input in edit form
    function parseMultiLineInput(text, sourceField, silent = false) {
        if (!text || !text.trim()) return;
        
        const lines = text.split('\n').map(line => line.trim()).filter(line => line !== '');
        
        if (sourceField === 'question') {
            // Parse from question textarea using keyword detection
            parseFromQuestionTextarea(lines, silent);
        } else if (sourceField.startsWith('opt')) {
            // Parse from option textarea using keyword detection
            parseFromOptionTextarea(lines, sourceField, silent);
        }
    }

    function parseFromQuestionTextarea(lines, silent = false) {
        const questionTextarea = document.getElementById('editQuestionTextarea');
        const opt1 = document.getElementById('editOpt1');
        const opt2 = document.getElementById('editOpt2');
        const opt3 = document.getElementById('editOpt3');
        const opt4 = document.getElementById('editOpt4');
        const correct = document.getElementById('editCorrectAnswer');
        
        // Try simple line-by-line parsing first
        const result = parseSimpleFormat(lines);
        
        if (result.success) {
            // Populate form fields - FIXED MAPPING
            if (result.question) {
                questionTextarea.value = result.question;
            }
            opt1.value = result.options[0] || '';
            opt2.value = result.options[1] || '';
            opt3.value = result.options[2] || '';
            opt4.value = result.options[3] || '';
            correct.value = result.correct || result.options[0] || '';

            // Auto-update question type
            if (result.type) {
                const typeSelect = document.getElementById('questionTypeSelect');
                if (typeSelect) {
                    typeSelect.value = result.type;
                    if (typeof toggleEditOptions === 'function') toggleEditOptions();
                }
            }
            
            // Debug the field values
            console.log('Setting field values:');
            console.log('Question textarea:', questionTextarea.value);
            console.log('Option 1:', opt1.value);
            console.log('Option 2:', opt2.value);
            console.log('Option 3:', opt3.value);
            console.log('Option 4:', opt4.value);
            console.log('Correct Answer:', correct.value);

            // Validate correct answer against options
            const options = result.options.map(opt => opt.trim()).filter(opt => opt !== '');
            const correctVal = result.correct ? result.correct.trim() : '';

            if (correctVal && options.length > 0 && !options.includes(correctVal)) {
                showModal('Correct Answer Mismatch', 
                    'The parsed correct answer ("' + correctVal + '") does not match any of the provided options.\n\n' +
                    'Available options:\n' + options.map((o, i) => (i + 1) + '. ' + o).join('\n') + '\n\n' +
                    'Please manually select or correct the correct answer.');
                return;
            }
            
            if (!silent) {
                showModal('Success', 'Question parsed successfully!\n\n' + 
                    (result.question ? 'Question: ' + result.question + '\n' : '') +
                    'Option 1: ' + (result.options[0] || '') + '\n' + 
                    'Option 2: ' + (result.options[1] || '') + '\n' + 
                    'Option 3: ' + (result.options[2] || '') + '\n' + 
                    'Option 4: ' + (result.options[3] || '') + '\n' + 
                    'Correct: ' + (result.correct || result.options[0] || ''));
            }
            return;
        }
        
        // Fallback to the original complex parsing
        parseComplexFormat(lines, 'question', silent);
    }

    function parseFromOptionTextarea(lines, sourceOption, silent = false) {
        const opt1 = document.getElementById('editOpt1');
        const opt2 = document.getElementById('editOpt2');
        const opt3 = document.getElementById('editOpt3');
        const opt4 = document.getElementById('editOpt4');
        const correct = document.getElementById('editCorrectAnswer');
        
        // Try simple line-by-line parsing first
        const result = parseSimpleFormat(lines);
        
        if (result.success) {
            // Populate form fields based on source option
            if (sourceOption === 'opt1') {
                opt1.value = result.options[0] || '';
                opt2.value = result.options[1] || '';
                opt3.value = result.options[2] || '';
                opt4.value = result.options[3] || '';
                correct.value = result.correct || result.options[0] || '';
            } else if (sourceOption === 'opt2') {
                opt2.value = result.options[0] || '';
                opt3.value = result.options[1] || '';
                opt4.value = result.options[2] || '';
                opt1.value = result.options[3] || '';
                correct.value = result.correct || result.options[0] || '';
            }
            
            // Validate correct answer against options
            const options = result.options.map(opt => opt.trim()).filter(opt => opt !== '');
            const correctVal = result.correct ? result.correct.trim() : '';

            if (correctVal && options.length > 0 && !options.includes(correctVal)) {
                showModal('Correct Answer Mismatch', 
                    'The parsed correct answer ("' + correctVal + '") does not match any of the provided options.\n\n' +
                    'Available options:\n' + options.map((o, i) => (i + 1) + '. ' + o).join('\n') + '\n\n' +
                    'Please manually select or correct the correct answer.');
                return;
            }

            if (!silent) {
                showModal('Success', 'Options parsed successfully!\n\n' + 
                    'First Option: ' + (result.options[0] || '') + '\n' + 
                    'Second Option: ' + (result.options[1] || '') + '\n' + 
                    'Third Option: ' + (result.options[2] || '') + '\n' + 
                    'Fourth Option: ' + (result.options[3] || '') + '\n' + 
                    'Correct Answer: ' + (result.correct || result.options[0] || ''));
            }
            return;
        }
        
        // Fallback to the original complex parsing
        parseComplexFormat(lines, sourceOption, silent);
    }

    // Simple format parser for common layouts
    function parseSimpleFormat(lines) {
        const result = {
            success: false,
            question: '',
            options: ['', '', '', ''],
            correct: '',
            type: 'MCQ'
        };
        
        console.log('=== PARSING START ==='); // Debug log
        console.log('Parsing lines:', lines); // Debug log
        
        // Check for the exact format you mentioned
        if (lines.length >= 5) {
            // Process each line to find options and correct answer
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                const lowerLine = line.toLowerCase().trim();
                
                if (lowerLine.startsWith('your question:')) {
                    // Extract everything after "Your Question:"
                    const colonIndex = line.indexOf(':');
                    if (colonIndex > -1) {
                        result.question = line.substring(colonIndex + 1).trim();
                        console.log('Extracted question:', result.question); // Debug log
                    }
                } else if (lowerLine.startsWith('option 1:')) {
                    const colonIndex = line.indexOf(':');
                    if (colonIndex > -1) {
                        result.options[0] = line.substring(colonIndex + 1).trim();
                        console.log('Option 1:', result.options[0]); // Debug log
                    }
                } else if (lowerLine.startsWith('option 2:')) {
                    const colonIndex = line.indexOf(':');
                    if (colonIndex > -1) {
                        result.options[1] = line.substring(colonIndex + 1).trim();
                        console.log('Option 2:', result.options[1]); // Debug log
                    }
                } else if (lowerLine.startsWith('option 3:')) {
                    const colonIndex = line.indexOf(':');
                    if (colonIndex > -1) {
                        result.options[2] = line.substring(colonIndex + 1).trim();
                        console.log('Option 3:', result.options[2]); // Debug log
                    }
                } else if (lowerLine.startsWith('option 4:')) {
                    const colonIndex = line.indexOf(':');
                    if (colonIndex > -1) {
                        result.options[3] = line.substring(colonIndex + 1).trim();
                        console.log('Option 4:', result.options[3]); // Debug log
                    }
                } else if (lowerLine.startsWith('correct answer:')) {
                    const colonIndex = line.indexOf(':');
                    if (colonIndex > -1) {
                        result.correct = line.substring(colonIndex + 1).trim();
                        console.log('Correct answer:', result.correct); // Debug log
                    }
                }
            }
            
            // If we have at least a question or any options, consider it successful
            if (result.question || result.options.some(opt => opt !== '') || result.correct) {
                result.success = true;
                console.log('Parsing successful with question or options'); // Debug log

                // Auto-detect type
                result.type = detectQuestionType(result.question, result.options, result.correct);
                
                // Sanitize correct answer
                if (result.correct) {
                    result.correct = sanitizeCorrectAnswer(result);
                }
            }
        }
        
        console.log('Final parsing result:', result); // Debug log
        console.log('=== PARSING END ==='); // Debug log
        return result;
    }

    // Complex format parser (fallback) - Improved version
    function parseComplexFormat(lines, sourceField, silent = false) {
        const questionTextarea = document.getElementById('editQuestionTextarea');
        const opt1 = document.getElementById('editOpt1');
        const opt2 = document.getElementById('editOpt2');
        const opt3 = document.getElementById('editOpt3');
        const opt4 = document.getElementById('editOpt4');
        const correct = document.getElementById('editCorrectAnswer');
        
        // Process each line to find options and correct answer
        let questionText = '';
        let option1 = '';
        let option2 = '';
        let option3 = '';
        let option4 = '';
        let correctAnswer = '';

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lowerLine = line.toLowerCase().trim();
            
            if (lowerLine.startsWith('your question:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    questionText = line.substring(colonIndex + 1).trim();
                }
            } else if (lowerLine.startsWith('option 1:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    option1 = line.substring(colonIndex + 1).trim();
                }
            } else if (lowerLine.startsWith('option 2:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    option2 = line.substring(colonIndex + 1).trim();
                }
            } else if (lowerLine.startsWith('option 3:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    option3 = line.substring(colonIndex + 1).trim();
                }
            } else if (lowerLine.startsWith('option 4:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    option4 = line.substring(colonIndex + 1).trim();
                }
            } else if (lowerLine.startsWith('correct answer:')) {
                const colonIndex = line.indexOf(':');
                if (colonIndex > -1) {
                    correctAnswer = line.substring(colonIndex + 1).trim();
                }
            }
        }
        
        // Populate form fields
        if (questionText || option1 || option2 || option3 || option4) {
            if (questionText && sourceField === 'question') {
                questionTextarea.value = questionText;
            }
            if (option1) opt1.value = option1;
            if (option2) opt2.value = option2;
            if (option3) opt3.value = option3;
            if (option4) opt4.value = option4;
            if (correctAnswer) correct.value = correctAnswer;

            // Auto-detect and sanitize
            const optionsArray = [option1, option2, option3, option4];
            const detectedType = detectQuestionType(questionText, optionsArray, correctAnswer);
            const sanitizedCorrect = sanitizeCorrectAnswer({ correct: correctAnswer, options: optionsArray });
            
            if (sanitizedCorrect) {
                correct.value = sanitizedCorrect;
            }

            const typeSelect = document.getElementById('questionTypeSelect');
            if (typeSelect) {
                typeSelect.value = detectedType;
                if (typeof toggleEditOptions === 'function') toggleEditOptions();
            }
            
            // Validate correct answer against options
            const opts = [option1, option2, option3, option4].map(opt => opt.trim()).filter(opt => opt !== '');
            const correctVal = correctAnswer ? correctAnswer.trim() : '';

            if (correctVal && opts.length > 0 && !opts.includes(correctVal)) {
                showModal('Correct Answer Mismatch', 
                    'The parsed correct answer ("' + correctVal + '") does not match any of the provided options.\n\n' +
                    'Available options:\n' + opts.map((o, i) => (i + 1) + '. ' + o).join('\n') + '\n\n' +
                    'Please manually select or correct the correct answer.');
                return;
            }

            if (!silent) {
                showModal('Success', 'Question parsed successfully!\n\n' + 
                    (questionText ? 'Question: ' + questionText + '\n' : '') +
                    'Option 1: ' + option1 + '\n' + 
                    'Option 2: ' + option2 + '\n' + 
                    'Option 3: ' + option3 + '\n' + 
                    'Option 4: ' + option4 + '\n' + 
                    'Correct: ' + correctAnswer);
            }
        }
    }


    
    /**
     * Auto-detects the question type based on content, options, and correct answer.
     */
    function detectQuestionType(question, options, correct) {
        const qText = (question || "").toLowerCase();
        const cVal = (correct || "").trim().toLowerCase();
        const opts = (options || []).filter(o => o && o.trim() !== '');
        
        // 1. Detect Code Snippet
        const codeKeywords = /(?:def |function |public |class |print\(|console\.|<[^>]*>|\{|\}|import |int |String |printf\(|cout |output of the code|following code|code snippet)/i;
        if (codeKeywords.test(question) || (question && question.includes('\n') && question.split('\n').filter(l => l.trim()).length > 3)) {
            return 'Code';
        } 
        // 2. Detect True/False
        if (cVal === 'true' || cVal === 'false' || (opts.length === 2 && (opts.some(o => o.toLowerCase() === 'true') || opts.some(o => o.toLowerCase() === 'false')))) {
            return 'TrueFalse';
        } 
        // 3. Detect Multiple Select
        if ((correct && correct.includes('|')) || qText.includes('(select two)') || qText.includes('(select 2)') || qText.includes('(select all)') || qText.includes('(select all that apply)')) {
            return 'MultipleSelect';
        } 
        // 4. Default to MCQ
        return 'MCQ';
    }

    /**
     * Sanitizes the correct answer by matching it against options or extracting from Option X format.
     */
    function sanitizeCorrectAnswer(q) {
        if (!q || !q.correct) return "";
        const correctText = q.correct.trim();
        const options = (q.options || []).map(opt => opt ? opt.trim() : "");
        
        // If it's a MultipleSelect question or contains pipes, process parts separately
        if (correctText.includes('|')) {
            const parts = correctText.split('|').map(p => p.trim()).filter(p => p !== "");
            const sanitizedParts = parts.map(part => {
                return sanitizeSingleAnswer(part, options);
            });
            return [...new Set(sanitizedParts)].join('|');
        }
        
        return sanitizeSingleAnswer(correctText, options);
    }

    /**
     * Internal helper to sanitize a single answer string against options
     */
    function sanitizeSingleAnswer(answerText, options) {
        if (!answerText) return "";
        const text = answerText.trim();
        
        // 1. Check for exact match
        if (options.includes(text)) return text;
        
        // 2. Check for "Option X: text" format
        const optionMatch = text.match(/Option\s+(\d+)[:\s]*(.*)/i);
        if (optionMatch) {
            const index = parseInt(optionMatch[1]) - 1;
            const textAfterPrefix = optionMatch[2].trim();
            if (index >= 0 && index < options.length && options[index]) {
                if (!textAfterPrefix || options[index].includes(textAfterPrefix) || textAfterPrefix.includes(options[index])) {
                    return options[index];
                }
            }
        }
        
        // 3. Check for single number (1-4)
        if (text.length === 1 && !isNaN(text)) {
            const num = parseInt(text);
            if (num >= 1 && num <= 4 && options[num-1]) return options[num-1];
        }
        
        // 4. Fuzzy match
        for (let opt of options) {
            const trimmedOpt = opt ? opt.trim() : "";
            if (trimmedOpt && trimmedOpt.length > 2) {
                if (text.toLowerCase() === trimmedOpt.toLowerCase()) return trimmedOpt;
                if (text.toLowerCase().includes(trimmedOpt.toLowerCase()) || trimmedOpt.toLowerCase().includes(text.toLowerCase())) {
                    return trimmedOpt;
                }
            }
        }
        
        return text;
    }

    // Function to check if text contains parsing patterns
    function containsParsingPatterns(text) {
        const lines = text.split('\n').map(line => line.trim()).filter(line => line !== '');
        
        // Check for function name patterns
        const functionPatterns = ['input()', 'read()', 'get()', 'scan()'];
        let hasFunctionPatterns = false;
        
        lines.forEach(line => {
            functionPatterns.forEach(pattern => {
                if (line.toLowerCase().includes(pattern.toLowerCase())) {
                    hasFunctionPatterns = true;
                }
            });
        });
        
        // Check for question patterns - more flexible
        const questionPatterns = [
            /what.*question/i,
            /what.*function/i,
            /what.*correct/i,
            /what.*way/i,
            /your.*question/i,
            /question:/i,
            /q:/i,
            /option\s*[:\-]?\s*→/i,
            /correct\s*[:\-]?\s*answer/i
        ];
        
        const hasQuestionPattern = lines.some(line => 
            questionPatterns.some(pattern => pattern.test(line))
        );
        
        // Check for arrow patterns (→)
        const hasArrowPattern = lines.some(line => line.includes('→'));
        
        // Check for colon patterns with option keywords
        const optionKeywords = ['first option', 'second option', 'third option', 'fourth option', 'option 1', 'option 2', 'option 3', 'option 4'];
        const hasOptionPattern = lines.some(line => 
            optionKeywords.some(keyword => line.toLowerCase().includes(keyword.toLowerCase()))
        );
        
        return hasFunctionPatterns || hasQuestionPattern || hasArrowPattern || hasOptionPattern;
    }

    function initializeSmartParsing() {
        const questionTextarea = document.getElementById('editQuestionTextarea');
        const opt1 = document.getElementById('editOpt1');
        const opt2 = document.getElementById('editOpt2');
        const opt3 = document.getElementById('editOpt3');
        const opt4 = document.getElementById('editOpt4');
        
        // Store timeout references
        let questionTimeout = null;
        let optTimeouts = [null, null, null, null];
        
        // Function to clear and set timeout
        function setParseTimeout(textarea, sourceField, timeoutRef) {
            // Clear existing timeout
            if (timeoutRef) {
                clearTimeout(timeoutRef);
            }
            
            // Set new timeout for 5 seconds
            timeoutRef = setTimeout(() => {
                const text = textarea.value.trim();
                if (text) {
                    // Check if text contains parsing patterns
                    if (containsParsingPatterns(text)) {
                        parseMultiLineInput(text, sourceField, true); // Silent parsing
                    }
                }
            }, 5000); // 5 seconds
            
            return timeoutRef;
        }
        
        // Add event listeners for automatic parsing
        if (questionTextarea) {
            questionTextarea.addEventListener('input', function() {
                questionTimeout = setParseTimeout(this, 'question', questionTimeout);
            });
            
            questionTextarea.addEventListener('paste', function() {
                // Give a moment for paste to complete
                setTimeout(() => {
                    questionTimeout = setParseTimeout(this, 'question', questionTimeout);
                }, 100);
            });
        }
        
        // Add event listeners for option textareas
        [opt1, opt2, opt3, opt4].forEach((opt, index) => {
            if (opt) {
                opt.addEventListener('input', function() {
                    optTimeouts[index] = setParseTimeout(this, 'opt' + (index + 1), optTimeouts[index]);
                });
                
                opt.addEventListener('paste', function() {
                    // Give a moment for paste to complete
                    setTimeout(() => {
                        optTimeouts[index] = setParseTimeout(this, 'opt' + (index + 1), optTimeouts[index]);
                    }, 100);
                });
            }
        });
    }
    
    // Add this function to update option labels
    function updateEditCorrectOptionLabels() {
        for (let i = 1; i <= 4; i++) {
            const optInput = document.getElementById(`editOpt${i}`);
            const checkbox = document.getElementById(`editCorrectOpt${i}`);
            const label = document.querySelector(`label[for="editCorrectOpt${i}"]`);
            
            if (optInput && checkbox && label) {
                const value = optInput.value.trim();
                label.textContent = value || `Option ${i}`;
                checkbox.value = value;
                checkbox.disabled = !value;
                
                // If option is empty, uncheck it
                if (!value && checkbox.checked) {
                    checkbox.checked = false;
                }
            }
        }
    }
    
    function toggleEditOptions() {
        const qType = document.getElementById("questionTypeSelect").value;
        const mcq = document.getElementById("editMcqOptions");
        const single = document.getElementById("editCorrectAnswerContainer");
        const multiple = document.getElementById("editMultipleCorrectContainer");
        const trueFalse = document.getElementById("editTrueFalseContainer");
        const dragDrop = document.getElementById("editDragDropOptions");
        const rearrange = document.getElementById("editRearrangeOptions");
        const dragDropEditor = document.getElementById("dragDropEditor");
        const correct = document.getElementById("editCorrectAnswer");
        const trueFalseSelect = document.getElementById("editTrueFalseSelect");
        
        document.getElementById("questionTypeHidden").value = qType;
    
        // Hide all option containers first
        mcq.style.display = "none";
        single.style.display = "none";
        multiple.style.display = "none";
        trueFalse.style.display = "none";
        dragDrop.style.display = "none";
        rearrange.style.display = "none";
        dragDropEditor.style.display = "none";
        
        // Remove required attributes from all elements
        correct.required = false;
        if (trueFalseSelect) trueFalseSelect.required = false;
        document.getElementById('editOpt1').required = false;
        document.getElementById('editOpt2').required = false;
        document.getElementById('editOpt3').required = false;
        document.getElementById('editOpt4').required = false;
    
        // Handle each question type
        if (qType === "TrueFalse") {
            // Show True/False container
            trueFalse.style.display = "block";
            trueFalseSelect.required = true;
            
            // Hide MCQ options
            mcq.style.display = "none";
            
            // Automatically set True/False options
            const opt1 = document.getElementById('editOpt1');
            const opt2 = document.getElementById('editOpt2');
            const opt3 = document.getElementById('editOpt3');
            const opt4 = document.getElementById('editOpt4');
            
            // Set True/False options
            if (opt1) opt1.value = 'True';
            if (opt2) opt2.value = 'False';
            if (opt3) opt3.value = '';
            if (opt4) opt4.value = '';
            
            // Update the select options to match
            const trueOption = document.querySelector('#editTrueFalseSelect option[value="True"]');
            const falseOption = document.querySelector('#editTrueFalseSelect option[value="False"]');
            
            if (trueOption) trueOption.textContent = 'True';
            if (falseOption) falseOption.textContent = 'False';
            
            // Set the correct answer in the hidden field when selection changes
            trueFalseSelect.addEventListener('change', function() {
                correct.value = this.value;
            });
            
            // Initialize with current value or default to True
            if (trueFalseSelect.value) {
                correct.value = trueFalseSelect.value;
            } else {
                // Default to True if no value is set
                trueFalseSelect.value = 'True';
                correct.value = 'True';
            }
            
        } else if (qType === "DRAG_AND_DROP") {
            // Show drag and drop section
            dragDrop.style.display = "block";
            dragDropEditor.style.display = "grid";
            
            // Hide MCQ options
            mcq.style.display = "none";
            
            // Initialize drag-drop data
            if (typeof initializeDragDrop === 'function') {
                setTimeout(() => {
                    initializeDragDrop();
                    // Prepare initial data
                    if (typeof prepareDragDropDataForSubmit === 'function') {
                        prepareDragDropDataForSubmit();
                    }
                }, 100);
            }
            
        } else if (qType === "REARRANGE") {
            // Show rearrange section
            rearrange.style.display = "block";
            
            // Hide MCQ options
            mcq.style.display = "none";
            
            // Initialize rearrange data
            setTimeout(() => {
                initializeRearrangeEdit();
            }, 100);

        } else if (qType === "MultipleSelect") {
            // Show MCQ options and multiple select container
            mcq.style.display = "block";
            multiple.style.display = "block";
            
            // Require first two options
            document.getElementById('editOpt1').required = true;
            document.getElementById('editOpt2').required = true;
            
            // Clear True/False specific options if they exist
            const opt1 = document.getElementById('editOpt1');
            const opt2 = document.getElementById('editOpt2');
            const opt3 = document.getElementById('editOpt3');
            const opt4 = document.getElementById('editOpt4');
            
            // If switching from True/False, clear the options
            if (opt1 && opt1.value === 'True' && opt2 && opt2.value === 'False') {
                // Only clear if both are exactly True/False
                if (opt3.value === '' && opt4.value === '') {
                    opt1.value = '';
                    opt2.value = '';
                    correct.value = '';
                }
            }
            
            // Update labels and initialize checkboxes
            setTimeout(() => {
                updateEditCorrectOptionLabels();
                initializeMultipleSelectCheckboxes();
                
                // Update correct answer field when checkboxes change
                document.querySelectorAll('.edit-correct-checkbox').forEach(cb => {
                    // Remove existing event listeners to avoid duplicates
                    const newCb = cb.cloneNode(true);
                    cb.parentNode.replaceChild(newCb, cb);
                    
                    newCb.addEventListener('change', function() {
                        if (document.querySelectorAll('.edit-correct-checkbox:checked').length > 2) {
                            this.checked = false;
                            alert("You can only select 2 correct answers.");
                            return;
                        }
                        
                        const selectedValues = [];
                        document.querySelectorAll('.edit-correct-checkbox:checked').forEach(checkbox => {
                            const optionId = checkbox.id.replace('editCorrectOpt', 'editOpt');
                            const optionInput = document.getElementById(optionId);
                            if (optionInput && optionInput.value.trim()) {
                                selectedValues.push(optionInput.value.trim());
                            } else if (checkbox.value && checkbox.value !== 'on') {
                                selectedValues.push(checkbox.value.trim());
                            }
                        });
                        
                        const filteredValues = selectedValues.filter(ans => ans && ans.toLowerCase() !== 'on');
                        correct.value = filteredValues.join('|');
                    });
                });
            }, 50);
            
        } else {
            // MCQ or Code type
            mcq.style.display = "block";
            single.style.display = "block";
            
            // Require first two options
            document.getElementById('editOpt1').required = true;
            document.getElementById('editOpt2').required = true;
            
            // Clear True/False specific options if they exist
            const opt1 = document.getElementById('editOpt1');
            const opt2 = document.getElementById('editOpt2');
            const opt3 = document.getElementById('editOpt3');
            const opt4 = document.getElementById('editOpt4');
            
            // If switching from True/False, clear the options
            if (opt1 && opt1.value === 'True' && opt2 && opt2.value === 'False') {
                // Only clear if both are exactly True/False
                if (opt3.value === '' && opt4.value === '') {
                    opt1.value = '';
                    opt2.value = '';
                    correct.value = '';
                }
            }
            
            // Set placeholder based on type
            correct.placeholder = qType === 'Code' ? "Expected output" : "Correct Answer";
            correct.required = true;
            
            // For MCQ, ensure correct answer matches one of the options
            if (qType === "MCQ") {
                const currentCorrect = correct.value;
                const opts = [
                    document.getElementById('editOpt1').value.trim(),
                    document.getElementById('editOpt2').value.trim(),
                    document.getElementById('editOpt3').value.trim(),
                    document.getElementById('editOpt4').value.trim()
                ].filter(Boolean);
                
                // If current correct answer doesn't match any option, clear it
                if (currentCorrect && opts.length > 0 && !opts.includes(currentCorrect)) {
                    correct.value = '';
                }
            }
        }
    
        // Update code preview if needed
        const questionText = document.getElementById("editQuestionTextarea").value;
        if (typeof updateCodePreview === 'function') {
            updateCodePreview(questionText, qType);
        }
    }

// Function to check if question suggests code snippet type
function checkForCodeSnippetEdit() {
    const questionText = document.getElementById("editQuestionTextarea").value;
    const questionType = document.getElementById("questionTypeSelect").value;
    
    // Count lines and check for code indicators
    const lines = questionText.split('\n').filter(line => line.trim() !== '');
    const hasCodeIndicators = /(?:def |function |public |class |print\(|console\.\|<[^>]*>\|\{|\}|import |int |String |printf\(|cout )/.test(questionText);
    
    // If question is longer than 3 lines or contains code indicators and is not already Code type
    if ((lines.length > 3 || hasCodeIndicators) && questionType !== 'Code') {
        if (confirm("This question appears to contain code or multiple lines. Would you like to change the question type to 'Code Snippet'?")) {
            document.getElementById("questionTypeSelect").value = "Code";
            if (typeof toggleEditOptions === 'function') toggleEditOptions();
        }
    }
    
    // Update preview if it's a code question
    updateCodePreview(questionText, questionType);
}

// Function to update code snippet preview
function updateCodePreview(questionText, questionType) {
    const previewDiv = document.getElementById('codePreview');
    const previewCode = document.getElementById('previewCode');
    
    if (questionType === 'Code') {
        let questionPart = "";
        let codePart = "";
        
        if(questionText.includes('```')){
            const parts = questionText.split('```', 3);
            if(parts.length >= 2) {
                questionPart = parts[0].trim();
                codePart = parts[1].trim();
            } else {
                questionPart = questionText.replace(/```/g, "").trim();
            }
        } else {
            codePart = questionText;
            questionPart = "What is the output/result of this code?";
        }
        
        previewCode.textContent = codePart;
        previewDiv.style.display = 'block';
    } else {
        previewDiv.style.display = 'none';
    }
}

// Initialize preview on page load
window.addEventListener('DOMContentLoaded', function() {
    const initialQuestionText = document.getElementById("editQuestionTextarea").value;
    const initialQuestionType = document.getElementById("questionTypeSelect").value;
    updateCodePreview(initialQuestionText, initialQuestionType);
});

    // Add this new function to initialize multiple select checkboxes properly
    function initializeMultipleSelectCheckboxes() {
        // First update the labels
        updateEditCorrectOptionLabels();
        
        // Get current correct answers
        const correctField = document.getElementById('editCorrectAnswer');
        const currentCorrect = correctField.value;
        const correctAnswers = currentCorrect ? currentCorrect.split('|') : [];
        
        // Reset all checkboxes
        document.querySelectorAll('.edit-correct-checkbox').forEach(cb => {
            cb.checked = false;
        });
        
        // Check the ones that match current correct answers
        if (correctAnswers.length > 0) {
            document.querySelectorAll('.edit-correct-checkbox').forEach(cb => {
                if (cb.value && correctAnswers.includes(cb.value)) {
                    cb.checked = true;
                }
            });
        }
    }

    // Add this function to validate before submit
    function validateAndSubmit(event) {
        event.preventDefault();
        
        const qType = document.getElementById("questionTypeSelect").value;
        let msg = '';

        // Check if there's an image
        const imageFileInput = document.getElementById('editImageFile');
        const hasImageFile = imageFileInput && imageFileInput.files.length > 0;
        const currentImagePath = document.getElementById('currentImagePath').value;
        const hasCurrentImage = currentImagePath && currentImagePath.trim() !== '';
        const willRemoveImage = document.querySelector('input[name="removeImage"]') !== null;
        const hasImage = (hasImageFile || (hasCurrentImage && !willRemoveImage));

        // Question text validation
        const questionText = document.getElementById('editQuestionTextarea').value.trim();
        if (!hasImage && !questionText) {
            msg = "Question text is required when no image is uploaded.";
        }

        // Type-specific validation
        if (qType === "TrueFalse") {
            const correctValue = document.getElementById('editTrueFalseSelect').value;
            if (!correctValue) {
                msg = "Please select the correct answer for True/False question.";
            } else {
                document.getElementById('editCorrectAnswer').value = correctValue;
            }
            
        } else if (qType === "DRAG_AND_DROP") {
            if (typeof prepareDragDropDataForSubmit === 'function') {
                prepareDragDropDataForSubmit();
            }
            
            const dragItems = typeof collectDragItemsFromUI === 'function' ? collectDragItemsFromUI() : [];
            const dropTargets = typeof collectDropTargetsFromUI === 'function' ? collectDropTargetsFromUI() : [];
            const correctTargets = typeof collectCorrectPairingsFromUI === 'function' ? collectCorrectPairingsFromUI() : [];
            
            if (dragItems.length < 1) {
                msg = "At least 1 draggable item is required.";
            } else if (dropTargets.length < 1) {
                msg = "At least 1 drop target is required.";
            } else {
                const incompletePairings = correctTargets.filter(val => val === "");
                if (incompletePairings.length > 0 || correctTargets.length !== dragItems.length) {
                    msg = "All draggable items must have a correct target assigned.";
                }
            }
            
        } else if (qType === "REARRANGE") {
            prepareRearrangeDataForSubmit();
            const items = collectRearrangeItemsFromUI();
            if (items.length < 2) {
                msg = "At least 2 items are required for rearrange questions.";
            }
        } else if (qType === "MultipleSelect") {
            const opt1 = document.getElementById('editOpt1').value.trim();
            const opt2 = document.getElementById('editOpt2').value.trim();
            
            if (!opt1 || !opt2) {
                msg = "At least Option 1 and Option 2 are required.";
            } else {
                const selectedCount = document.querySelectorAll('.edit-correct-checkbox:checked').length;
                if (selectedCount !== 2) {
                    msg = "Select exactly 2 correct answers.";
                }
            }
            
        } else {
            // MCQ or Code
            const opt1 = document.getElementById('editOpt1').value.trim();
            const opt2 = document.getElementById('editOpt2').value.trim();
            
            if (!opt1 || !opt2) {
                msg = "At least Option 1 and Option 2 are required.";
            } else {
                const opts = ['editOpt1', 'editOpt2', 'editOpt3', 'editOpt4']
                    .map(id => document.getElementById(id).value.trim())
                    .filter(Boolean);
                    
                if (new Set(opts).size !== opts.length) {
                    msg = "Options must be unique.";
                }
                
                if (qType === "MCQ") {
                    const correctValue = document.getElementById('editCorrectAnswer').value.trim();
                    if (correctValue && !opts.includes(correctValue)) {
                        msg = "Correct answer must match one of the provided options exactly.";
                    }
                }
            }
        }

        if (msg) {
            alert(msg);
            return false;
        }
        
        // Show loading state
        const submitBtn = document.getElementById('editSubmitBtn');
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
        submitBtn.disabled = true;
        
        // Submit the form
        document.getElementById('editQuestionForm').submit();
        return true;
    }

    // Image upload functions for edit
    function initEditImageUpload() {
        const editImageFileInput = document.getElementById('editImageFile');
        const editImageDropZone = document.getElementById('editImageDropZone');
        
        if (editImageFileInput && editImageDropZone) {
            // Click to browse
            editImageDropZone.addEventListener('click', () => {
                editImageFileInput.click();
            });
            
            // File input change
            editImageFileInput.addEventListener('change', function() {
                if (this.files && this.files[0]) {
                    displayEditImageFileName(this.files[0]);
                }
            });
            
            // Drag and drop events
            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                editImageDropZone.addEventListener(eventName, preventEditImageDefaults, false);
            });
            
            function preventEditImageDefaults(e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            ['dragenter', 'dragover'].forEach(eventName => {
                editImageDropZone.addEventListener(eventName, highlightEditImage, false);
            });
            
            ['dragleave', 'drop'].forEach(eventName => {
                editImageDropZone.addEventListener(eventName, unhighlightEditImage, false);
            });
            
            function highlightEditImage() {
                editImageDropZone.classList.add('drag-over');
            }
            
            function unhighlightEditImage() {
                editImageDropZone.classList.remove('drag-over');
            }
            
            editImageDropZone.addEventListener('drop', handleEditImageDrop, false);
            
            function handleEditImageDrop(e) {
                const dt = e.dataTransfer;
                const files = dt.files;
                
                if (files.length > 0) {
                    const file = files[0];
                    // Check if it's an image file
                    if (file.type.match('image.*')) {
                        // Set the file to the hidden input
                        const dataTransfer = new DataTransfer();
                        dataTransfer.items.add(file);
                        editImageFileInput.files = dataTransfer.files;
                        displayEditImageFileName(file);
                    } else {
                        alert('Please select an image file (JPG, PNG, GIF).');
                    }
                }
            }
            
            function displayEditImageFileName(file) {
                const editImageFileNameDisplay = document.getElementById('editImageFileNameDisplay');
                const editImageFileNameSpan = document.getElementById('editImageFileName');
                const editImagePreview = document.getElementById('editImagePreview');
                const editPreviewPlaceholder = document.getElementById('editPreviewPlaceholder');
                const editImagePreviewSection = document.getElementById('editImagePreviewSection');
                
                editImageFileNameSpan.textContent = file.name;
                editImageFileNameDisplay.style.display = 'flex';
                editImageDropZone.style.display = 'none';
                
                // Show image preview if it's an image file
                if (file.type.match('image.*')) {
                    const reader = new FileReader();
                    
                    reader.onload = function(e) {
                        editImagePreview.src = e.target.result;
                        editImagePreview.style.display = 'block';
                        editPreviewPlaceholder.style.display = 'none';
                        editImagePreviewSection.style.display = 'block';
                    };
                    
                    reader.readAsDataURL(file);
                }
            }
        }
    }
    
    function removeEditImageFile() {
        const editImageFileInput = document.getElementById('editImageFile');
        const editImageFileNameDisplay = document.getElementById('editImageFileNameDisplay');
        const editImageDropZone = document.getElementById('editImageDropZone');
        const editImagePreviewSection = document.getElementById('editImagePreviewSection');
        
        // Reset file input
        editImageFileInput.value = '';
        
        // Hide file name display and show drop zone
        editImageFileNameDisplay.style.display = 'none';
        editImageDropZone.style.display = 'block';
        
        // Also hide the preview section
        editImagePreviewSection.style.display = 'none';
    }
    
    function removeCurrentImage() {
        // Show confirmation dialog
        if (confirm('Are you sure you want to remove the current image?')) {
            // Add a hidden input field to indicate the image should be removed
            const removeImageInput = document.createElement('input');
            removeImageInput.type = 'hidden';
            removeImageInput.name = 'removeImage';
            removeImageInput.value = 'true';
            document.getElementById('editQuestionForm').appendChild(removeImageInput);
            
            // Hide the current image display
            document.getElementById('currentImageDisplay').innerHTML = '<div class="form-hint">Image will be removed on update</div>';
            
            // Also hide the preview section if it exists
            const editImagePreviewSection = document.getElementById('editImagePreviewSection');
            if (editImagePreviewSection) {
                editImagePreviewSection.style.display = 'none';
            }
        }
    }
    

    // Additional Setup for DOMContentLoaded:
    // Make sure your DOMContentLoaded event handler includes proper initialization:
    document.addEventListener('DOMContentLoaded', function() {
        // Initial toggle based on current type
        if (typeof toggleEditOptions === 'function') toggleEditOptions();
        
        // Initialize option values for checkboxes
        for (let i = 1; i <= 4; i++) {
            const optInput = document.getElementById(`editOpt${i}`);
            const checkbox = document.getElementById(`editCorrectOpt${i}`);
            const label = document.querySelector(`label[for="editCorrectOpt${i}"]`);

            if (optInput && checkbox && label) {
                // Set initial values
                const value = optInput.value.trim();
                label.textContent = value || `Option ${i}`;
                checkbox.value = value;
                checkbox.disabled = !value;
                
                // Add change listener
                optInput.addEventListener('input', () => {
                    const newValue = optInput.value.trim();
                    label.textContent = newValue || `Option ${i}`;
                    checkbox.value = newValue;
                    checkbox.disabled = !newValue;
                    if (!newValue) {
                        checkbox.checked = false;
                    }
                });
            }
        }

        // Initialize multiple select checkboxes if needed
        if (document.getElementById('questionTypeSelect').value === "MultipleSelect") {
            // Small delay to ensure DOM is fully ready
            setTimeout(() => {
                initializeMultipleSelectCheckboxes();
            }, 100);
        }

        // Add event listeners for checkboxes
        document.querySelectorAll('.edit-correct-checkbox').forEach(cb => {
            cb.addEventListener('change', function() {
                if (document.querySelectorAll('.edit-correct-checkbox:checked').length > 2) {
                    this.checked = false;
                    alert("You can only select 2 correct answers.");
                    return;
                }
                
                // Update the correct answer field with selected values
                const selectedValues = [];
                document.querySelectorAll('.edit-correct-checkbox:checked').forEach(checkbox => {
                    const optionId = checkbox.id.replace('editCorrectOpt', 'editOpt');
                    const optionInput = document.getElementById(optionId);
                    if (optionInput && optionInput.value.trim()) {
                        selectedValues.push(optionInput.value.trim());
                    } else if (checkbox.value && checkbox.value !== 'on') {
                        selectedValues.push(checkbox.value.trim());
                    }
                });
                
                const filteredValues = selectedValues.filter(ans => ans && ans.toLowerCase() !== 'on');
                const correctAnswerField = document.getElementById('editCorrectAnswer');
                if (correctAnswerField) {
                    correctAnswerField.value = filteredValues.join('|');
                }
            });
        });

        // Add event listeners
        document.getElementById('questionTypeSelect').addEventListener('change', toggleEditOptions);
        document.getElementById('editQuestionForm').addEventListener('submit', validateAndSubmit);
        
        // Initialize other functionalities
        if (typeof initEditImageUpload === 'function') {
            initEditImageUpload();
        }
        
        if (typeof initializeSmartParsing === 'function') {
            initializeSmartParsing();
        }
        
        // Initialize drag-drop if current question type is DRAG_AND_DROP
        if ('<%= questionType %>' === 'DRAG_AND_DROP') {
            if (typeof initializeDragDrop === 'function') {
                initializeDragDrop();
            }
            
            // Set orientation from extra_data
            try {
                const extraDataStr = '<%= questionToEdit.getExtraData() != null ? questionToEdit.getExtraData().replace("'", "\'") : "{}" %>';
                const extraData = JSON.parse(extraDataStr);
                if (extraData && extraData.orientation) {
                    document.getElementById('editOrientationSelect').value = extraData.orientation;
                }
            } catch (e) {
                console.error('Error parsing extra_data for orientation:', e);
            }
                        
            // Initialize orientation preview
            initEditOrientationPreview();
        }
    });
    
    // Initialize orientation preview for drag-drop questions in edit mode
    function initEditOrientationPreview() {
        const orientationSelect = document.getElementById('editOrientationSelect');
        const dragDropEditor = document.getElementById('dragDropEditor');
        
        if (orientationSelect && dragDropEditor) {
            // Function to update preview
            function updateOrientationPreview() {
                const selectedOrientation = orientationSelect.value;
                
                // Remove all orientation classes
                dragDropEditor.classList.remove('horizontal-layout', 'vertical-layout', 'landscape-layout');
                
                // Add selected orientation class
                if (selectedOrientation === 'vertical') {
                    dragDropEditor.classList.add('vertical-layout');
                } else if (selectedOrientation === 'landscape') {
                    dragDropEditor.classList.add('landscape-layout');
                } else {
                    // Default to horizontal
                    dragDropEditor.classList.add('horizontal-layout');
                }
                
                console.log('Orientation changed to:', selectedOrientation);
                
                // Test if drop targets are properly laid out horizontally for horizontal orientation
                if (selectedOrientation === 'horizontal') {
                    const dropTargetsList = dragDropEditor.querySelector('.drop-targets-list');
                    const isHorizontal = dropTargetsList && getComputedStyle(dropTargetsList).flexDirection === 'row';
                    console.log('Drop targets horizontal layout:', isHorizontal);
                }
            }
            
            // Add event listener
            orientationSelect.addEventListener('change', updateOrientationPreview);
            
            // Initialize with current selection
            updateOrientationPreview();
        }
    }
    
    // Rearrange functions for edit
    function initializeRearrangeEdit() {
        const container = document.getElementById("rearrangeItemsContainer");
        if (!container) return;
        container.innerHTML = "";

        if (typeof rearrangeItemsFromDB !== "undefined" && rearrangeItemsFromDB.length > 0) {
            rearrangeItemsFromDB.forEach(item => {
                addRearrangeItemToUI(item);
            });
        } else {
            addRearrangeItemToUI("");
            addRearrangeItemToUI("");
        }
        
        // Load style from extra_data
        try {
            const extraDataStr = '<%= questionToEdit != null && questionToEdit.getExtraData() != null ? questionToEdit.getExtraData().replace("'", "\\'") : "{}" %>';
            const extraData = JSON.parse(extraDataStr);
            if (extraData && extraData.style) {
                document.getElementById('editRearrangeStyleSelect').value = extraData.style;
            }
        } catch (e) {
            console.error('Error parsing extra_data for rearrange style:', e);
        }
        
        // Load marks
        const marksInput = document.getElementById("rearrangeTotalMarks");
        if (marksInput) {
            marksInput.value = totalMarksFromDB || rearrangeItemsFromDB.length || 1;
        }
    }

    function addRearrangeItem() {
        addRearrangeItemToUI("");
    }

    function addRearrangeItemToUI(text) {
        const container = document.getElementById("rearrangeItemsContainer");
        const index = container.querySelectorAll(".drag-item").length + 1;
        const div = document.createElement("div");
        div.className = "drag-item row-draggable";
        div.draggable = true;
        div.innerHTML = `
            <i class="fas fa-grip-vertical drag-handle"></i>
            <textarea name="rearrangeItem_${index}" class="form-control" rows="1" placeholder="Item text..." oninput="autoResize(this)">${escapeHtml(text)}</textarea>
            <button type="button" class="remove-btn" onclick="this.parentElement.remove()">×</button>
        `;
        
        div.addEventListener('dragstart', handleRowDragStart);
        div.addEventListener('dragover', handleRowDragOver);
        div.addEventListener('drop', handleRowDrop);
        div.addEventListener('dragend', handleRowDragEnd);
        
        container.appendChild(div);
        autoResize(div.querySelector('textarea'));
    }

    function collectRearrangeItemsFromUI() {
        const inputs = document.querySelectorAll("#rearrangeItemsContainer textarea");
        return Array.from(inputs).map(input => input.value.trim()).filter(v => v !== "");
    }

    function prepareRearrangeDataForSubmit() {
        const items = collectRearrangeItemsFromUI();
        document.getElementById("rearrangeItemsHidden").value = JSON.stringify(items);
    }

    function escapeHtml(text) {
        if (!text) return "";
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // Test function to verify orientation functionality in edit mode
    function testEditOrientation() {
        console.log('Testing orientation functionality in edit mode:');
        const orientationSelect = document.getElementById('editOrientationSelect');
        const dragDropEditor = document.getElementById('dragDropEditor');
        
        if (orientationSelect && dragDropEditor) {
            console.log('Current orientation:', orientationSelect.value);
            console.log('Editor classes:', dragDropEditor.className);
            
            // Test all orientations
            ['horizontal', 'vertical', 'landscape'].forEach(orientation => {
                orientationSelect.value = orientation;
                orientationSelect.dispatchEvent(new Event('change'));
                console.log(`${orientation} layout applied:`, dragDropEditor.classList.contains(`${orientation}-layout`));
                
                // Check if drop targets are laid out horizontally for horizontal orientation
                if (orientation === 'horizontal') {
                    const dropTargetsList = dragDropEditor.querySelector('.drop-targets-list');
                    const isHorizontal = dropTargetsList && getComputedStyle(dropTargetsList).flexDirection === 'row';
                    console.log('Drop targets horizontal layout:', isHorizontal);
                }
            });
            
            // Reset to original value
            orientationSelect.value = 'horizontal';
            orientationSelect.dispatchEvent(new Event('change'));
        } else {
            console.log('Orientation elements not found in edit mode');
        }
    }
</script>