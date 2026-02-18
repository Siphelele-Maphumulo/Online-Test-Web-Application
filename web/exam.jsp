<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, myPackage.*" %>
<script src="proctoring.js"></script>

<style>
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        display: none;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        backdrop-filter: blur(4px);
    }
    .modal-container {
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        width: 90%;
        max-width: 500px;
        overflow: hidden;
        animation: modalFadeIn 0.3s ease-out;
    }
    @keyframes modalFadeIn {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .modal-header {
        background: #09294d;
        color: white;
        padding: 15px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .modal-title { margin: 0; font-size: 18px; }
    .modal-body { padding: 20px; }
    .modal-footer { padding: 15px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: right; }

    .diag-item {
        display: flex;
        justify-content: space-between;
        padding: 10px 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .status-pass { color: #10b981; }
    .status-fail { color: #ef4444; }

    .verification-steps-nav {
        display: flex;
        justify-content: space-between;
        margin-bottom: 25px;
        position: relative;
    }
    .step-nav-item {
        flex: 1;
        text-align: center;
        position: relative;
        z-index: 1;
    }
    .step-nav-item div {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        background: #cbd5e1;
        color: white;
        line-height: 30px;
        margin: 0 auto 5px;
        font-weight: bold;
    }
    .step-nav-item span { font-size: 11px; color: #64748b; }

    .video-container {
        position: relative;
        background: #000;
        border-radius: 8px;
        overflow: hidden;
        margin-bottom: 15px;
    }
    .captured-preview {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: #fff;
    }

    .btn-primary { background: #09294d; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
    .btn-secondary { background: #64748b; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
    .btn-success { background: #10b981; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
    .btn-outline { background: transparent; border: 1px solid #cbd5e1; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
</style>

<!-- MODALS -->
<div id="diagnosticsModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-stethoscope"></i> System Diagnostics</h3>
        </div>
        <div class="modal-body">
            <p>We're checking your system to ensure a smooth exam experience.</p>
            <div class="diag-item">
                <span><i class="fas fa-wifi"></i> Internet Connection</span>
                <span id="status-internet"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
            <div class="diag-item">
                <span><i class="fas fa-browser"></i> Browser Compatibility</span>
                <span id="status-browser"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
            <div class="diag-item">
                <span><i class="fas fa-code"></i> JavaScript Enabled</span>
                <span id="status-javascript"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
            <div class="diag-item">
                <span><i class="fas fa-desktop"></i> Screen Resolution</span>
                <span id="status-resolution"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
            <div class="diag-item">
                <span><i class="fas fa-laptop"></i> Operating System</span>
                <span id="status-os"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
            <div class="diag-item">
                <span><i class="fas fa-video"></i> Camera Access</span>
                <span id="status-camera"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
            <div class="diag-item">
                <span><i class="fas fa-expand"></i> Fullscreen Support</span>
                <span id="status-environment"><i class="fas fa-spinner fa-spin"></i></span>
            </div>
        </div>
        <div class="modal-footer">
            <button id="diagCancelButton" class="btn-secondary">Cancel</button>
            <button id="diagRetryButton" class="btn-outline" style="display:none;">Retry</button>
            <button id="diagProceedButton" class="btn-primary" disabled>Proceed</button>
        </div>
    </div>
</div>

<div id="identityVerificationModal" class="modal-overlay" style="display: none;">
    <div class="modal-container" style="max-width: 800px;">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-user-shield"></i> Identity Verification</h3>
        </div>
        <div class="modal-body">
            <div class="verification-steps-nav">
                <div id="step-nav-1" class="step-nav-item"><div>1</div><span>Honor Code</span></div>
                <div id="step-nav-2" class="step-nav-item"><div>2</div><span>Face Photo</span></div>
                <div id="step-nav-3" class="step-nav-item"><div>3</div><span>ID Photo</span></div>
                <div id="step-nav-4" class="step-nav-item"><div>4</div><span>Summary</span></div>
            </div>

            <div id="verification-step-1" class="verification-step">
                <h4>Code of Honor</h4>
                <div class="honor-code-box" style="background:#f8fafc; padding:15px; border-radius:8px; border-left:4px solid #09294d;">
                    <p>I hereby certify that I am the person whose name and ID appear on this account. I agree to take this exam honestly and without any unauthorized assistance.</p>
                </div>
                <div class="form-check mt-3" style="margin-top:15px;">
                    <input class="form-check-input" type="checkbox" id="honorCodeCheckbox">
                    <label class="form-check-label" for="honorCodeCheckbox">I agree to the Code of Honor</label>
                </div>
                <div class="mt-3" style="margin-top:15px;">
                    <label>Digital Signature (Full Name)</label>
                    <input type="text" id="digitalSignature" class="form-control" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px;" placeholder="Type your full name">
                </div>
            </div>

            <div id="verification-step-2" class="verification-step" style="display:none;">
                <h4>Capture Face Photo</h4>
                <div class="video-container">
                    <video id="faceVideo" autoplay playsinline muted style="width: 100%; max-height: 400px; background: #000;"></video>
                    <div id="faceCapturedPreview" class="captured-preview" style="display:none;">
                        <img id="faceImgPreview" src="" alt="Face Preview" style="width: 100%;">
                    </div>
                </div>
                <button id="captureFaceBtn" class="btn-primary mt-3"><i class="fas fa-camera"></i> Capture Photo</button>
            </div>

            <div id="verification-step-3" class="verification-step" style="display:none;">
                <h4>Capture ID Card Photo</h4>
                <div class="video-container">
                    <video id="idVideo" autoplay playsinline muted style="width: 100%; max-height: 400px; background: #000;"></video>
                    <div id="idCapturedPreview" class="captured-preview" style="display:none;">
                        <img id="idImgPreview" src="" alt="ID Preview" style="width: 100%;">
                    </div>
                </div>
                <button id="captureIdBtn" class="btn-primary mt-3"><i class="fas fa-id-card"></i> Capture ID</button>
            </div>

            <div id="verification-step-4" class="verification-step" style="display:none;">
                <h4>Verification Summary</h4>
                <div class="summary-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div>
                        <h5>Face Photo</h5>
                        <img id="summaryFaceImg" src="" style="width:100%; border-radius:8px;">
                    </div>
                    <div>
                        <h5>ID Photo</h5>
                        <img id="summaryIdImg" src="" style="width:100%; border-radius:8px;">
                    </div>
                </div>
                <div class="alert alert-success mt-3" style="margin-top:15px; background:#d1fae5; color:#065f46; padding:10px; border-radius:6px;">
                    <i class="fas fa-check-circle"></i> Identity captured successfully. Click Finalize to start the exam.
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button id="verifyPrevBtn" class="btn-secondary" style="display:none;">Previous</button>
            <button id="verifyNextBtn" class="btn-primary">Next</button>
            <button id="verifyFinalBtn" class="btn-success" style="display:none;">Finalize</button>
        </div>
    </div>
</div>

<div id="calculatorModal" class="modal-overlay" style="display: none;">
    <div id="calcContainer" class="modal-container" style="max-width: 300px; padding: 0;">
        <div id="calcHeader" class="modal-header" style="cursor: move; padding: 10px 15px;">
            <h3 class="modal-title"><i class="fas fa-calculator"></i> Calculator</h3>
            <button onclick="toggleCalculator()" class="close-button" style="background:none; border:none; font-size:24px; color:white; cursor:pointer;">&times;</button>
        </div>
        <div class="modal-body" style="padding: 15px;">
            <div id="calcHistory" style="height: 20px; font-size: 12px; text-align: right; color: #666; margin-bottom: 5px;"></div>
            <div id="calcDisplay" style="background: #f4f4f4; padding: 10px; font-size: 24px; text-align: right; margin-bottom: 10px; border-radius: 4px; overflow: hidden; min-height: 40px;">0</div>
            <div class="calc-buttons" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 5px;">
                <button onclick="calcAction('clear')" style="grid-column: span 2; background: #fee2e2; color: #dc2626; border:1px solid #ddd; padding:10px; cursor:pointer;">C</button>
                <button onclick="calcAction('backspace')" style="background: #f1f5f9; border:1px solid #ddd; padding:10px; cursor:pointer;"><i class="fas fa-backspace"></i></button>
                <button onclick="calcInput('/')" style="background: #e2e8f0; border:1px solid #ddd; padding:10px; cursor:pointer;">/</button>
                <button onclick="calcInput('7')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">7</button>
                <button onclick="calcInput('8')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">8</button>
                <button onclick="calcInput('9')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">9</button>
                <button onclick="calcInput('*')" style="background: #e2e8f0; border:1px solid #ddd; padding:10px; cursor:pointer;">*</button>
                <button onclick="calcInput('4')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">4</button>
                <button onclick="calcInput('5')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">5</button>
                <button onclick="calcInput('6')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">6</button>
                <button onclick="calcInput('-')" style="background: #e2e8f0; border:1px solid #ddd; padding:10px; cursor:pointer;">-</button>
                <button onclick="calcInput('1')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">1</button>
                <button onclick="calcInput('2')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">2</button>
                <button onclick="calcInput('3')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">3</button>
                <button onclick="calcInput('+')" style="background: #e2e8f0; border:1px solid #ddd; padding:10px; cursor:pointer;">+</button>
                <button onclick="calcInput('0')" style="grid-column: span 2; border:1px solid #ddd; padding:10px; cursor:pointer;">0</button>
                <button onclick="calcInput('.')" style="border:1px solid #ddd; padding:10px; cursor:pointer;">.</button>
                <button onclick="calcAction('equal')" style="background: #09294d; color: white; border:1px solid #ddd; padding:10px; cursor:pointer;">=</button>
            </div>
            <div class="calc-scientific" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 5px; margin-top: 5px;">
                <button onclick="calcAction('sin')" style="font-size: 10px; border:1px solid #ddd; padding:5px; cursor:pointer;">sin</button>
                <button onclick="calcAction('cos')" style="font-size: 10px; border:1px solid #ddd; padding:5px; cursor:pointer;">cos</button>
                <button onclick="calcAction('tan')" style="font-size: 10px; border:1px solid #ddd; padding:5px; cursor:pointer;">tan</button>
                <button onclick="calcAction('log')" style="font-size: 10px; border:1px solid #ddd; padding:5px; cursor:pointer;">log</button>
                <button onclick="calcAction('sqrt')" style="font-size: 10px; border:1px solid #ddd; padding:5px; cursor:pointer;">sqrt</button>
                <button onclick="calcAction('pow')" style="font-size: 10px; border:1px solid #ddd; padding:5px; cursor:pointer;">x^y</button>
            </div>
        </div>
    </div>
</div>

<div id="roughPaperModal" class="modal-overlay" style="display: none;">
    <div class="modal-container" style="max-width: 500px; padding: 0;">
        <div id="roughHeader" class="modal-header" style="cursor: move; padding: 10px 15px;">
            <h3 class="modal-title"><i class="fas fa-sticky-note"></i> Rough Paper</h3>
            <button onclick="toggleRoughPaper()" class="close-button" style="background:none; border:none; font-size:24px; color:white; cursor:pointer;">&times;</button>
        </div>
        <div class="modal-body" style="padding: 15px;">
            <textarea id="roughTextarea" style="width: 100%; height: 300px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; resize: none; font-family: 'Courier New', Courier, monospace;" placeholder="Write your notes here... (Notes will be saved automatically)"></textarea>
        </div>
    </div>
</div>

<div id="finalConfirmationModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-check-circle"></i> Ready to Begin</h3>
        </div>
        <div class="modal-body">
            <p>Your identity has been verified and the proctoring system is active.</p>
            <ul style="text-align: left; font-size: 13px; list-style: none; padding: 0;">
                <li style="margin-bottom: 5px;"><i class="fas fa-video" style="color: #10b981;"></i> Camera is recording</li>
                <li style="margin-bottom: 5px;"><i class="fas fa-microphone" style="color: #10b981;"></i> Microphone is active</li>
                <li style="margin-bottom: 5px;"><i class="fas fa-lock" style="color: #10b981;"></i> Lockdown mode enabled</li>
            </ul>
            <p><strong>Click the button below to start your exam. Good luck!</strong></p>
        </div>
        <div class="modal-footer">
            <form id="examStartForm" action="controller.jsp" method="post" style="width:100%;">
                <input type="hidden" name="page" value="exams">
                <input type="hidden" name="operation" value="startexam">
                <input type="hidden" name="coursename" value="<%= request.getParameter("coursename") %>">
                <button id="beginExamBtnFinal" type="submit" class="btn-success" style="width: 100%; padding: 15px; font-size: 18px; cursor:pointer;">Begin Exam Now</button>
            </form>
        </div>
    </div>
</div>

<div id="timeUpModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header" style="background: #dc2626; color: white;">
            <h3 class="modal-title" style="color: white;"><i class="fas fa-hourglass-end"></i> Time's Up!</h3>
        </div>
        <div class="modal-body" style="padding: 30px; text-align: center;">
            <div style="font-size: 48px; color: #dc2626; margin-bottom: 20px;">
                <i class="fas fa-clock"></i>
            </div>
            <h4>Your time has expired.</h4>
            <p>Your exam is being submitted automatically. Please wait...</p>
            <div id="timeUpCountdown" style="font-size: 24px; font-weight: bold; margin-top: 10px;">3</div>
        </div>
    </div>
</div>

<div id="confirmSubmitModal" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-paper-plane"></i> Confirm Submission</h3>
        </div>
        <div class="modal-body">
            <p>Are you sure you want to submit your exam? Once submitted, you cannot change your answers.</p>
        </div>
        <div class="modal-footer">
            <button onclick="closeConfirmSubmitModal()" class="btn-secondary" style="cursor:pointer;">Cancel</button>
            <button id="confirmSubmitBtn" class="btn-primary" style="background: #10b981; border: none; cursor:pointer;">Submit Exam</button>
        </div>
    </div>
</div>

<jsp:include page="exam_content.jsp"/>

<script>
/* --- GLOBAL VARIABLES --- */
var examActive = true;
var warningGiven = false;
var dirty = false;
var timerInterval = null;
var examDuration = parseInt(document.body.dataset.examDuration || "60");
var totalQuestions = parseInt(document.body.dataset.totalQuestions || "10");
var currentCourseName = document.body.dataset.courseName || "";
var currentQuestionIndex = 0;

var examId = '<%= session.getAttribute("examId") != null ? session.getAttribute("examId") : "0" %>';
var studentId = '<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "0" %>';

var globalVideoStream = null;

/* --- CALCULATOR LOGIC --- */
var calcInputStr = "";

function toggleCalculator() {
    var modal = document.getElementById('calculatorModal');
    if (modal.style.display === 'flex') {
        modal.style.display = 'none';
    } else {
        modal.style.display = 'flex';
    }
}

function calcInput(val) {
    calcInputStr += val;
    document.getElementById('calcDisplay').textContent = calcInputStr.replace(/Math\.PI/g, 'π').replace(/Math\.E/g, 'e');
}

function calcAction(action) {
    var display = document.getElementById('calcDisplay');
    var history = document.getElementById('calcHistory');

    if (action === 'clear') {
        calcInputStr = "";
        display.textContent = "0";
        history.textContent = "";
    } else if (action === 'backspace') {
        calcInputStr = calcInputStr.slice(0, -1);
        display.textContent = calcInputStr || "0";
    } else if (action === 'equal') {
        try {
            var result = eval(calcInputStr);
            history.textContent = calcInputStr.replace(/Math\.PI/g, 'π').replace(/Math\.E/g, 'e') + " =";
            calcInputStr = result.toString();
            display.textContent = calcInputStr;
        } catch (e) {
            display.textContent = "Error";
            calcInputStr = "";
        }
    } else if (['sin', 'cos', 'tan', 'log', 'ln', 'sqrt'].indexOf(action) !== -1) {
        try {
            var val = eval(calcInputStr || "0");
            var res = 0;
            var rad = val * (Math.PI / 180);
            switch(action) {
                case 'sin': res = Math.sin(rad); break;
                case 'cos': res = Math.cos(rad); break;
                case 'tan': res = Math.tan(rad); break;
                case 'log': res = Math.log10(val); break;
                case 'ln': res = Math.log(val); break;
                case 'sqrt': res = Math.sqrt(val); break;
            }
            history.textContent = action + "(" + val + ") =";
            res = Math.round(res * 100000000) / 100000000;
            calcInputStr = res.toString();
            display.textContent = calcInputStr;
        } catch (e) {
            display.textContent = "Error";
        }
    } else if (action === 'pow') {
        calcInputStr += "**";
        display.textContent = calcInputStr;
    }
}

function dragElement(elmnt) {
    var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    var header = elmnt.querySelector('.modal-header');
    if (header) {
        header.onmousedown = dragMouseDown;
    }

    function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        document.onmousemove = elementDrag;
    }

    function elementDrag(e) {
        e = e || window.event;
        e.preventDefault();
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;

        var container = elmnt.querySelector('.modal-container');
        if (container) {
            container.style.position = 'absolute';
            container.style.top = (container.offsetTop - pos2) + "px";
            container.style.left = (container.offsetLeft - pos1) + "px";
        }
    }

    function closeDragElement() {
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

/* --- ROUGH PAPER LOGIC --- */
function toggleRoughPaper() {
    var modal = document.getElementById('roughPaperModal');
    if (modal.style.display === 'flex') {
        modal.style.display = 'none';
    } else {
        modal.style.display = 'flex';
    }
}

function initRoughPaper() {
    var textarea = document.getElementById('roughTextarea');
    if (!textarea) return;
    
    var saved = sessionStorage.getItem('exam_rough_notes');
    if (saved) textarea.value = saved;

    textarea.addEventListener('input', function() {
        sessionStorage.setItem('exam_rough_notes', this.value);
    });
}

/* --- MULTI-SELECT HIDDEN FIELD --- */
function updateHiddenForMulti(qindex) {
    var box = document.querySelector('.question-card[data-qindex="' + qindex + '"] .answers');
    if (!box) return;
    var selectedValues = [];
    var checkboxes = box.querySelectorAll('input.multi:checked');
    for (var i = 0; i < checkboxes.length; i++) {
        selectedValues.push(checkboxes[i].value);
    }
    var hidden = document.getElementById('ans' + qindex + '-hidden');
    if (hidden) {
        hidden.value = selectedValues.join('|');
    }
}

/* --- ANSWER SELECTION & PROGRESS --- */
function updateProgress() {
    var cards = document.querySelectorAll('.question-card');
    var answered = 0;
    
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var box = card.querySelector('.answers');
        if (!box) continue;
        
        var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
        if (maxSel === 1) {
            if (box.querySelector('input.single:checked')) answered++;
        } else {
            if (box.querySelectorAll('input.multi:checked').length >= 1) answered++;
        }
    }
    
    var total = cards.length;
    var pct = total ? Math.round((answered / total) * 100) : 0;
    
    var progressBar = document.getElementById('progressBar');
    var modalProgressBar = document.getElementById('modalProgressBar');
    if (progressBar) progressBar.style.width = pct + '%';
    if (modalProgressBar) modalProgressBar.style.width = pct + '%';
    
    var progressLabel = document.getElementById('progressLabel');
    if (progressLabel) progressLabel.textContent = pct + '%';
}

/* --- ASYNC ANSWER SAVING --- */
function saveAnswer(qindex, answer) {
    var questionCard = document.querySelector('.question-card[data-qindex="' + qindex + '"]');
    if (!questionCard) return;

    var qidInput = questionCard.querySelector('input[name="qid' + qindex + '"]');
    if (!qidInput) return;
    
    var qid = qidInput.value;
    var formData = new URLSearchParams();
    formData.append('page', 'saveAnswer');
    formData.append('qid', qid);
    formData.append('ans', answer);

    navigator.sendBeacon('controller.jsp', formData);
}

/* --- TIMER MANAGEMENT --- */
function startTimer() {
    var timerEl = document.getElementById('remainingTime');
    if (!timerEl) return;
    
    var timeInSeconds = 3600; // Default 1 hour
    var storageKey = 'examStartTime_' + currentCourseName;
    var startTime = sessionStorage.getItem(storageKey);
    
    if (startTime) {
        var elapsed = Math.floor((Date.now() - parseInt(startTime)) / 1000);
        timeInSeconds = Math.max(0, timeInSeconds - elapsed);
    } else {
        sessionStorage.setItem(storageKey, Date.now().toString());
    }
    
    var time = timeInSeconds;
    
    function fmt(n) { return n < 10 ? '0' + n : '' + n; }
    
    timerInterval = setInterval(function() {
        time--;
        if (time <= 0) {
            clearInterval(timerInterval);
            timerEl.textContent = "00:00";
            autoSubmitExam();
            return;
        }
        var minutes = Math.floor(time / 60);
        var seconds = time % 60;
        timerEl.textContent = fmt(minutes) + ':' + fmt(seconds);
    }, 1000);
}

function autoSubmitExam() {
    var modal = document.getElementById('timeUpModal');
    if (modal) modal.style.display = 'flex';
    setTimeout(function() {
        document.getElementById('myform').submit();
    }, 3000);
}

function submitExam() {
    var modal = document.getElementById('confirmSubmitModal');
    if (modal) modal.style.display = 'flex';
}

function closeConfirmSubmitModal() {
    var modal = document.getElementById('confirmSubmitModal');
    if (modal) modal.style.display = 'none';
}

/* --- DIAGNOSTICS LOGIC --- */
function runDiagnostics() {
    var modal = document.getElementById('diagnosticsModal');
    if (modal) modal.style.display = 'flex';
    
    var statusIds = ['status-internet', 'status-browser', 'status-javascript', 
                     'status-resolution', 'status-os', 'status-camera', 'status-environment'];
    
    statusIds.forEach(id => {
        var el = document.getElementById(id);
        if (el) el.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    });

    setTimeout(() => {
        document.getElementById('status-internet').innerHTML = navigator.onLine ? '<i class="fas fa-check-circle status-pass"></i>' : '<i class="fas fa-times-circle status-fail"></i>';
        document.getElementById('status-browser').innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        document.getElementById('status-javascript').innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        document.getElementById('status-resolution').innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        document.getElementById('status-os').innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        document.getElementById('status-camera').innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        document.getElementById('status-environment').innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        
        document.getElementById('diagProceedButton').disabled = false;
        document.getElementById('diagRetryButton').style.display = 'inline-block';
    }, 2000);
}

/* --- IDENTITY VERIFICATION --- */
var currentVerifyStep = 1;
var capturedFaceData = null;
var capturedIdData = null;

function startIdentityVerification() {
    document.getElementById('identityVerificationModal').style.display = 'flex';
    showVerifyStep(1);
}

async function showVerifyStep(step) {
    for (var i = 1; i <= 4; i++) {
        document.getElementById('verification-step-' + i).style.display = (i === step) ? 'block' : 'none';
        var nav = document.getElementById('step-nav-' + i);
        if (nav) nav.style.opacity = (i === step) ? '1' : '0.5';
    }

    document.getElementById('verifyPrevBtn').style.display = (step > 1 && step < 4) ? 'inline-block' : 'none';
    document.getElementById('verifyNextBtn').style.display = (step < 4) ? 'inline-block' : 'none';
    document.getElementById('verifyFinalBtn').style.display = (step === 4) ? 'inline-block' : 'none';

    if (step === 2 && !globalVideoStream) {
        try {
            globalVideoStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
            document.getElementById('faceVideo').srcObject = globalVideoStream;
        } catch (err) {
            alert('Camera access required');
        }
    }
    
    if (step === 3 && globalVideoStream) {
        document.getElementById('idVideo').srcObject = globalVideoStream;
    }
    
    if (step === 4) {
        document.getElementById('summaryFaceImg').src = capturedFaceData;
        document.getElementById('summaryIdImg').src = capturedIdData;
    }
    currentVerifyStep = step;
}

/* --- INITIALIZATION --- */
document.addEventListener('DOMContentLoaded', function() {
    startTimer();
    initRoughPaper();

    document.getElementById('diagCancelButton').onclick = () => document.getElementById('diagnosticsModal').style.display = 'none';
    document.getElementById('diagRetryButton').onclick = runDiagnostics;
    document.getElementById('diagProceedButton').onclick = () => {
        document.getElementById('diagnosticsModal').style.display = 'none';
        startIdentityVerification();
    };

    document.getElementById('captureFaceBtn').onclick = () => {
        var video = document.getElementById('faceVideo');
        var canvas = document.createElement('canvas');
        canvas.width = video.videoWidth; canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        capturedFaceData = canvas.toDataURL('image/jpeg');
        document.getElementById('faceImgPreview').src = capturedFaceData;
        document.getElementById('faceCapturedPreview').style.display = 'block';
    };

    document.getElementById('captureIdBtn').onclick = () => {
        var video = document.getElementById('idVideo');
        var canvas = document.createElement('canvas');
        canvas.width = video.videoWidth; canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        capturedIdData = canvas.toDataURL('image/jpeg');
        document.getElementById('idImgPreview').src = capturedIdData;
        document.getElementById('idCapturedPreview').style.display = 'block';
    };

    document.getElementById('verifyNextBtn').onclick = () => {
        if (currentVerifyStep === 1) {
            if (!document.getElementById('honorCodeCheckbox').checked) return alert('Agree to Honor Code');
            showVerifyStep(2);
        } else if (currentVerifyStep === 2) {
            if (!capturedFaceData) return alert('Capture face photo');
            showVerifyStep(3);
        } else if (currentVerifyStep === 3) {
            if (!capturedIdData) return alert('Capture ID photo');
            showVerifyStep(4);
        }
    };

    document.getElementById('verifyPrevBtn').onclick = () => showVerifyStep(currentVerifyStep - 1);

    document.getElementById('verifyFinalBtn').onclick = async () => {
        document.getElementById('identityVerificationModal').style.display = 'none';
        if (typeof ProctoringSystem === 'function') {
            window.proctor = new ProctoringSystem(examId, studentId);
            await window.proctor.initialize(globalVideoStream);
        }
        document.getElementById('finalConfirmationModal').style.display = 'flex';
    };
    
    var confirmSubmitBtn = document.getElementById('confirmSubmitBtn');
    if (confirmSubmitBtn) {
        confirmSubmitBtn.onclick = function() {
            document.getElementById('myform').submit();
        };
    }

    dragElement(document.getElementById('calculatorModal'));
    dragElement(document.getElementById('roughPaperModal'));
});
</script>
