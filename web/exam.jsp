<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, myPackage.*" %>
<script src="proctoring.js"></script>
<script>
/* --- GLOBAL VARIABLES - SAFE FOR JSP --- */
var examActive = true;
var warningGiven = false;
var dirty = false;
var timerInterval = null;
// Get exam duration from data attribute or default to 60 minutes
var examDuration = parseInt(document.body.dataset.examDuration || "60");
// Get total questions from data attribute or default to 10
var totalQuestions = parseInt(document.body.dataset.totalQuestions || "10");
// Get course name from data attribute or default to empty
var currentCourseName = document.body.dataset.courseName || "";
var currentQuestionIndex = 0;

// Proctoring variables
var examId = '<%= session.getAttribute("examId") != null ? session.getAttribute("examId") : "0" %>';
var studentId = '<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "0" %>';

// Global stream for camera
var globalVideoStream = null;

/* --- CALCULATOR LOGIC --- */
var calcInputStr = "";

function toggleCalculator() {
    var modal = document.getElementById('calculatorModal');
    if (modal.style.display === 'block') {
        modal.style.display = 'none';
    } else {
        modal.style.display = 'block';
    }
}

function calcInput(val) {
    calcInputStr += val;
    document.getElementById('calcDisplay').textContent = calcInputStr.replace(/Math\.PI/g, '?').replace(/Math\.E/g, 'e');
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
            history.textContent = calcInputStr.replace(/Math\.PI/g, '?').replace(/Math\.E/g, 'e') + " =";
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
            history.textContent = action + "(" + val + (['sin','cos','tan'].indexOf(action) !== -1 ? "�" : "") + ") =";
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

// Drag functionality for calculator
function initCalcDraggable() {
    dragElement(document.getElementById("calculatorModal"));
}

function dragElement(elmnt) {
    var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    var header = document.getElementById("calcHeader");
    if (header) {
        header.onmousedown = dragMouseDown;
    } else {
        elmnt.onmousedown = dragMouseDown;
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
        elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
        elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
    }

    function closeDragElement() {
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

/* --- ROUGH PAPER LOGIC --- */
function toggleRoughPaper() {
    var modal = document.getElementById('roughPaperModal');
    if (modal.style.display === 'block') {
        modal.style.display = 'none';
    } else {
        modal.style.display = 'block';
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
    
    var roughModal = document.getElementById("roughPaperModal");
    var roughHeader = document.getElementById("roughHeader");
    
    if (roughHeader) {
        roughHeader.onmousedown = function(e) {
            var pos1 = 0, pos2 = 0, pos3 = e.clientX, pos4 = e.clientY;
            document.onmouseup = function() {
                document.onmouseup = null;
                document.onmousemove = null;
            };
            document.onmousemove = function(e) {
                pos1 = pos3 - e.clientX;
                pos2 = pos4 - e.clientY;
                pos3 = e.clientX;
                pos4 = e.clientY;
                roughModal.style.top = (roughModal.offsetTop - pos2) + "px";
                roughModal.style.left = (roughModal.offsetLeft - pos1) + "px";
            };
        };
    }
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
document.addEventListener('change', function(e) {
    if (!e.target.classList || !e.target.classList.contains('answer-input')) return;
    
    var wrapper = e.target.closest('.answers');
    if (!wrapper) return;
    
    var maxSel = parseInt(wrapper.getAttribute('data-max-select') || '1', 10);
    
    if (e.target.classList.contains('multi')) {
        var checkedBoxes = wrapper.querySelectorAll('input.multi:checked');
        if (checkedBoxes.length > maxSel) {
            e.target.checked = false;
            alert('You can only select up to ' + maxSel + ' options for this question.');
            return;
        }
        var qindex = e.target.getAttribute('data-qindex');
        updateHiddenForMulti(qindex);
    }
    
    var checkboxes = document.querySelectorAll('.form-check');
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].classList) {
            checkboxes[i].classList.remove('selected');
        }
    }
    
    var checkedInputs = document.querySelectorAll('.answer-input:checked');
    for (var i = 0; i < checkedInputs.length; i++) {
        var fc = checkedInputs[i].closest('.form-check');
        if (fc && fc.classList) fc.classList.add('selected');
    }
    
    updateProgress();
    dirty = true;
});

function showQuestion(index) {
    var cards = document.querySelectorAll('.question-card');
    for (var i = 0; i < cards.length; i++) {
        if (i === index) {
            cards[i].style.display = 'block';
        } else {
            cards[i].style.display = 'none';
        }
    }

    var currentQNumEl = document.getElementById('currentQNum');
    if (currentQNumEl) currentQNumEl.textContent = index + 1;

    var prevBtn = document.getElementById('prevBtn');
    var nextBtn = document.getElementById('nextBtn');
    var submitSection = document.querySelector('.submit-section');

    if (prevBtn) prevBtn.disabled = (index === 0);
    
    if (index === totalQuestions - 1) {
        if (nextBtn) {
            nextBtn.innerHTML = 'Finish <i class="fas fa-flag-checkered"></i>';
            nextBtn.style.background = '#059669';
        }
        if (submitSection) submitSection.style.display = 'flex';
    } else {
        if (nextBtn) {
            nextBtn.innerHTML = 'Next <i class="fas fa-arrow-right"></i>';
            nextBtn.style.background = '#92AB2F';
        }
        if (submitSection) submitSection.style.display = 'none';
    }
    
    currentQuestionIndex = index;
    updateProgress();
    
    var modalIcons = document.querySelectorAll('#questionGrid .question-icon');
    for (var i = 0; i < modalIcons.length; i++) {
        modalIcons[i].classList.remove('current');
        var iconIndex = parseInt(modalIcons[i].getAttribute('data-qindex'));
        if (iconIndex === index) {
            modalIcons[i].classList.add('current');
        }
    }
}

function nextQuestion() {
    if (currentQuestionIndex < totalQuestions - 1) {
        showQuestion(currentQuestionIndex + 1);
        window.scrollTo(0, 0);
    } else {
        document.querySelector('.submit-section').scrollIntoView({ behavior: 'smooth' });
    }
}

function prevQuestion() {
    if (currentQuestionIndex > 0) {
        showQuestion(currentQuestionIndex - 1);
        window.scrollTo(0, 0);
    }
}

function updateProgress() {
    var cards = document.querySelectorAll('.question-card');
    var answered = 0;
    
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var box = card.querySelector('.answers');
        if (!box) continue;
        
        var qindex = card.getAttribute('data-qindex');
        var isDragDrop = card.querySelector('.drag-drop-question') !== null;
        
        if (isDragDrop) {
            if (card.querySelectorAll('.dropped-item').length > 0) {
                answered++;
            }
        } else {
            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
            if (maxSel === 1) {
                if (box.querySelector('input.single:checked')) answered++;
            } else {
                if (box.querySelectorAll('input.multi:checked').length >= 1) answered++;
            }
        }
    }
    
    var total = cards.length;
    var pct = total ? Math.round((answered / total) * 100) : 0;
    
    var progressBar = document.getElementById('progressBar');
    var progressBarHeader = document.getElementById('progressBarHeader');
    var modalProgressBar = document.getElementById('modalProgressBar');
    if (progressBar) progressBar.style.width = pct + '%';
    if (progressBarHeader) progressBarHeader.style.width = pct + '%';
    if (modalProgressBar) modalProgressBar.style.width = pct + '%';
    
    var progressLabel = document.getElementById('progressLabel');
    var examProgressPctHeader = document.getElementById('examProgressPctHeader');
    var progressPercent = document.querySelector('.progress-percent');
    if (progressLabel) progressLabel.textContent = pct + '%';
    if (examProgressPctHeader) examProgressPctHeader.textContent = pct + '%';
    if (progressPercent) progressPercent.textContent = pct + '%';
    
    var submitAnswered = document.getElementById('submitAnswered');
    var submitUnanswered = document.getElementById('submitUnanswered');
    var floatCounter = document.getElementById('floatCounter');
    var modalAnswered = document.getElementById('modalAnswered');
    var modalUnanswered = document.getElementById('modalUnanswered');
    var modalProgressText = document.getElementById('modalProgressText');
    
    if (submitAnswered) submitAnswered.textContent = answered;
    if (submitUnanswered) submitUnanswered.textContent = total - answered;
    if (floatCounter) floatCounter.textContent = answered + '/' + total;
    if (modalAnswered) modalAnswered.textContent = answered;
    if (modalUnanswered) modalUnanswered.textContent = total - answered;
    if (modalProgressText) modalProgressText.textContent = answered + ' / ' + total;
    
    var circumference = 2 * Math.PI * 34;
    var offset = circumference - (pct / 100) * circumference;
    var progressRing = document.querySelector('.progress-ring-progress');
    if (progressRing) progressRing.style.strokeDashoffset = offset;
}

/* --- ASYNC ANSWER SAVING --- */
function saveAnswer(qindex, answer) {
    var questionCard = document.querySelector('.question-card[data-qindex="' + qindex + '"]');
    if (!questionCard) return;

    var qidInput = questionCard.querySelector('input[name="qid' + qindex + '"]');
    var questionInput = questionCard.querySelector('input[name="question' + qindex + '"]');
    if (!qidInput || !questionInput) return;
    
    var qid = qidInput.value;
    var question = questionInput.value;

    var formData = new FormData();
    formData.append('page', 'saveAnswer');
    formData.append('qid', qid);
    formData.append('question', question);
    formData.append('ans', answer);

    navigator.sendBeacon('controller.jsp', new URLSearchParams(formData));
}

document.addEventListener('change', function(e) {
    if (e.target.classList && e.target.classList.contains('answer-input')) {
        var qindex = e.target.getAttribute('data-qindex');
        var answer = '';
        if (e.target.classList.contains('multi')) {
            var wrapper = e.target.closest('.answers');
            var selectedValues = [];
            var checkboxes = wrapper.querySelectorAll('input.multi:checked');
            for (var i = 0; i < checkboxes.length; i++) {
                selectedValues.push(checkboxes[i].value);
            }
            answer = selectedValues.join('|');
        } else {
            answer = e.target.value;
        }
        saveAnswer(qindex, answer);
    }
});

/* --- TIMER MANAGEMENT --- */
function startTimer() {
    var timerEl = document.getElementById('remainingTimeHeader');
    if (!timerEl) {
        console.warn('Timer element not found, timer disabled');
        return;
    }
    
    var timeInSeconds = examDuration > 0 ? examDuration * 60 : 60 * 60;
    
    var storageKey = 'examStartTime_' + currentCourseName;
    var startTime = sessionStorage.getItem(storageKey);
    var elapsedSeconds = 0;
    
    if (startTime) {
        elapsedSeconds = Math.floor((Date.now() - parseInt(startTime)) / 1000);
        timeInSeconds = Math.max(0, timeInSeconds - elapsedSeconds);
    } else {
        sessionStorage.setItem(storageKey, Date.now().toString());
    }
    
    var time = timeInSeconds;
    
    function fmt(n) {
        return n < 10 ? '0' + n : '' + n;
    }
    
    function updateTimerDisplay() {
        var minutes = Math.floor(time / 60);
        var seconds = time % 60;
        var formattedTime = fmt(minutes) + ':' + fmt(seconds);
        timerEl.textContent = formattedTime;
        
        var headerTimer = document.getElementById('remainingTimeHeader');
        if (headerTimer) headerTimer.textContent = formattedTime;
        
        if (timerEl.classList) {
            timerEl.classList.remove('warning', 'critical', 'expired');
            if (time <= 300) timerEl.classList.add('warning');
            if (time <= 60) timerEl.classList.add('critical');
        }
    }
    
    updateTimerDisplay();
    
    if (timerInterval) clearInterval(timerInterval);
    
    timerInterval = setInterval(function() {
        time--;
        
        if (time <= 0) {
            clearInterval(timerInterval);
            if (timerEl) {
                timerEl.textContent = "00:00";
                if (timerEl.classList) {
                    timerEl.classList.add('expired');
                }
            }
            autoSubmitExam();
            return;
        }
        
        updateTimerDisplay();
    }, 1000);
}

function autoSubmitExam() {
    var multiBoxes = document.querySelectorAll('.answers[data-max-select="2"]');
    for (var i = 0; i < multiBoxes.length; i++) {
        var card = multiBoxes[i].closest('.question-card');
        if (card) {
            var qindex = card.getAttribute('data-qindex');
            if (qindex) updateHiddenForMulti(qindex);
        }
    }
    
    var dragDropAnswers = typeof getDragDropAnswers === 'function' ? getDragDropAnswers() : {};
    var keys = Object.keys(dragDropAnswers);
    for (var i = 0; i < keys.length; i++) {
        var qindex = keys[i];
        var mappings = dragDropAnswers[qindex];
        var formattedMappings = {};
        for (var tId in mappings) {
            formattedMappings['target_' + tId] = 'item_' + mappings[tId];
        }
        var ansValue = JSON.stringify(formattedMappings);
        
        var hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
        if (!hiddenAns) {
            hiddenAns = document.createElement('input');
            hiddenAns.type = 'hidden';
            hiddenAns.name = 'ans' + qindex;
            document.getElementById('myform').appendChild(hiddenAns);
        }
        hiddenAns.value = ansValue;
    }
    
    showTimeUpModal();
    cleanupExam();
    setTimeout(function() {
        document.getElementById('myform').submit();
    }, 3000);
}

function submitExam() {
    var multiBoxes = document.querySelectorAll('.answers[data-max-select="2"]');
    for (var i = 0; i < multiBoxes.length; i++) {
        var card = multiBoxes[i].closest('.question-card');
        if (card) {
            var qindex = card.getAttribute('data-qindex');
            if (qindex) updateHiddenForMulti(qindex);
        }
    }
    
    var dragDropAnswers = typeof getDragDropAnswers === 'function' ? getDragDropAnswers() : {};
    var keys = Object.keys(dragDropAnswers);
    for (var i = 0; i < keys.length; i++) {
        var qindex = keys[i];
        var mappings = dragDropAnswers[qindex];
        var formattedMappings = {};
        for (var tId in mappings) {
            formattedMappings['target_' + tId] = 'item_' + mappings[tId];
        }
        var ansValue = JSON.stringify(formattedMappings);
        
        var hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
        if (!hiddenAns) {
            hiddenAns = document.createElement('input');
            hiddenAns.type = 'hidden';
            hiddenAns.name = 'ans' + qindex;
            document.getElementById('myform').appendChild(hiddenAns);
        }
        hiddenAns.value = ansValue;
    }
    
    var answeredQuestions = 0;
    var cards = document.querySelectorAll('.question-card');
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var isDragDrop = card.querySelector('.drag-drop-question') !== null;
        if (isDragDrop) {
            if (card.querySelectorAll('.dropped-item').length > 0) {
                answeredQuestions++;
            }
        } else {
            var box = card.querySelector('.answers');
            if (!box) continue;
            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
            if (maxSel === 1) {
                if (box.querySelector('input.single:checked')) answeredQuestions++;
            } else {
                if (box.querySelectorAll('input.multi:checked').length >= 1) answeredQuestions++;
            }
        }
    }
    
    if (answeredQuestions < totalQuestions) {
        var unanswered = totalQuestions - answeredQuestions;
        if (!confirm("You have " + unanswered + " unanswered question" + 
                (unanswered > 1 ? "s" : "") + ". Submit anyway?")) {
            return;
        }
    }
    
    showConfirmSubmitModal();
}

function cleanupExam() {
    examActive = false;
    dirty = false;
    
    var storageKey = 'examStartTime_' + currentCourseName;
    sessionStorage.removeItem(storageKey);
    
    var keys = Object.keys(sessionStorage);
    for (var i = 0; i < keys.length; i++) {
        if (keys[i].startsWith('examStartTime_')) {
            sessionStorage.removeItem(keys[i]);
        }
    }
    
    if (timerInterval) {
        clearInterval(timerInterval);
        timerInterval = null;
    }
    
    window.onbeforeunload = null;
}

function setupNavigationProtection() {
    window.onbeforeunload = function(e) {
        if (examActive && dirty && !warningGiven) {
            var message = 'You have an active exam in progress. If you leave, your answers may not be saved.';
            e.returnValue = message;
            return message;
        }
    };
}

function setupProgressModal() {
    var floatBtn = document.getElementById('progressFloatBtn');
    var modal = document.getElementById('progressModal');
    var closeModal = document.querySelectorAll('.close-modal');
    var modalSubmitBtn = document.getElementById('modalSubmitBtn');
    
    if (floatBtn && modal) {
        floatBtn.addEventListener('click', function() {
            if (modal && modal.classList) {
                modal.classList.add('active');
            }
            updateProgress();
        });
        
        for (var i = 0; i < closeModal.length; i++) {
            closeModal[i].addEventListener('click', function() {
                if (modal && modal.classList) {
                    modal.classList.remove('active');
                }
            });
        }
        
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                modal.classList.remove('active');
            }
        });
        
        if (modalSubmitBtn) {
            modalSubmitBtn.addEventListener('click', function() {
                if (modal && modal.classList) {
                    modal.classList.remove('active');
                }
                submitExam();
            });
        }
    }
}

function showTimeUpModal() {
    var modal = document.getElementById('timeUpModal');
    if (modal) {
        modal.classList.add('active');
        
        var countdown = 3;
        var countdownEl = document.getElementById('timeUpCountdown');
        var interval = setInterval(function() {
            countdown--;
            if (countdownEl) countdownEl.textContent = countdown;
            if (countdown <= 0) {
                clearInterval(interval);
            }
        }, 1000);
    }
}

function showConfirmSubmitModal() {
    var modal = document.getElementById('confirmSubmitModal');
    var confirmBtn = document.getElementById('confirmSubmitBtn');
    
    if (modal) {
        modal.classList.add('active');
        
        if (confirmBtn) {
            confirmBtn.onclick = function() {
                closeConfirmSubmitModal();
                
                cleanupExam();
                
                var btn = document.getElementById('submitBtn');
                if (btn) {
                    btn.disabled = true;
                    if (btn.classList) {
                        btn.classList.add('loading');
                    }
                    var btnText = btn.querySelector('.btn-text');
                    var btnLoading = btn.querySelector('.btn-loading');
                    if (btnText) btnText.style.display = 'none';
                    if (btnLoading) btnLoading.style.display = 'inline';
                }
                
                setTimeout(function() {
                    document.getElementById('myform').submit();
                }, 500);
            };
        }
    }
}

function closeConfirmSubmitModal() {
    var modal = document.getElementById('confirmSubmitModal');
    if (modal) {
        modal.classList.remove('active');
    }
}

document.addEventListener('DOMContentLoaded', function() {
    showQuestion(0);
    startTimer();
    initCalcDraggable();
    initRoughPaper();
    setupNavigationProtection();
    setupProgressModal();
    
    var submitBtn = document.getElementById('submitBtn');
    if (submitBtn) {
        submitBtn.addEventListener('click', submitExam);
    }
    
    window.addEventListener('beforeunload', function() {
        if (!examActive) {
            var storageKey = 'examStartTime_' + currentCourseName;
            sessionStorage.removeItem(storageKey);
        }
    });
});

/* --- DIAGNOSTICS LOGIC - FIXED --- */
function runDiagnostics() {
    console.log('Starting diagnostics...');
    
    // Show the diagnostics modal
    var modal = document.getElementById('diagnosticsModal');
    if (modal) {
        modal.style.display = 'flex';
    }
    
    // Reset all status indicators to spinner
    var statusIds = ['status-internet', 'status-browser', 'status-javascript', 
                     'status-resolution', 'status-os', 'status-camera', 'status-environment'];
    
    for (var i = 0; i < statusIds.length; i++) {
        var el = document.getElementById(statusIds[i]);
        if (el) {
            el.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
        }
    }
    
    document.getElementById('diagProceedButton').disabled = true;
    document.getElementById('diagRetryButton').style.display = 'none';
    
    // Check internet
    setTimeout(function() {
        var el = document.getElementById('status-internet');
        if (el) {
            if (navigator.onLine) {
                el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
            } else {
                el.innerHTML = '<i class="fas fa-times-circle status-fail"></i>';
            }
        }
    }, 300);
    
    // Check browser
    setTimeout(function() {
        var el = document.getElementById('status-browser');
        if (el) {
            var ua = navigator.userAgent;
            var isChrome = /Chrome/.test(ua) && /Google Inc/.test(navigator.vendor);
            if (isChrome) {
                el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
            } else {
                el.innerHTML = '<i class="fas fa-times-circle status-fail"></i> (Chrome recommended)';
            }
        }
    }, 600);
    
    // JavaScript is always enabled if we're here
    setTimeout(function() {
        var el = document.getElementById('status-javascript');
        if (el) {
            el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
        }
    }, 900);
    
    // Check resolution
    setTimeout(function() {
        var el = document.getElementById('status-resolution');
        if (el) {
            if (window.screen.width >= 1024 && window.screen.height >= 768) {
                el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
            } else {
                el.innerHTML = '<i class="fas fa-times-circle status-fail"></i> (1024x768 minimum)';
            }
        }
    }, 1200);
    
    // Check OS (simplified)
    setTimeout(function() {
        var el = document.getElementById('status-os');
        if (el) {
            el.innerHTML = '<i class="fas fa-check-circle status-pass"></i> (Windows/Mac/Linux)';
        }
    }, 1500);
    
    // Check camera
    setTimeout(function() {
        var el = document.getElementById('status-camera');
        if (el) {
            if (navigator.mediaDevices && navigator.mediaDevices.enumerateDevices) {
                navigator.mediaDevices.enumerateDevices().then(function(devices) {
                    var hasCamera = false;
                    for (var i = 0; i < devices.length; i++) {
                        if (devices[i].kind === 'videoinput') {
                            hasCamera = true;
                            break;
                        }
                    }
                    if (hasCamera) {
                        el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
                    } else {
                        el.innerHTML = '<i class="fas fa-times-circle status-fail"></i>';
                    }
                }).catch(function() {
                    el.innerHTML = '<i class="fas fa-times-circle status-fail"></i>';
                });
            } else {
                el.innerHTML = '<i class="fas fa-times-circle status-fail"></i>';
            }
        }
    }, 1800);
    
    // Check fullscreen support
    setTimeout(function() {
        var el = document.getElementById('status-environment');
        if (el) {
            var fullScreenAvailable = document.fullscreenEnabled || 
                                      document.webkitFullscreenEnabled || 
                                      document.mozFullScreenEnabled;
            if (fullScreenAvailable) {
                el.innerHTML = '<i class="fas fa-check-circle status-pass"></i>';
            } else {
                el.innerHTML = '<i class="fas fa-times-circle status-fail"></i>';
            }
        }
        
        // Enable proceed button after all checks
        document.getElementById('diagProceedButton').disabled = false;
        document.getElementById('diagRetryButton').style.display = 'inline-block';
    }, 2100);
}

function finishDiagnostics(allPassed) {
    // This function is kept for compatibility
}

// Modal button listeners
document.getElementById('diagCancelButton').onclick = function() {
    document.getElementById('diagnosticsModal').style.display = 'none';
};

document.getElementById('diagRetryButton').onclick = function() {
    runDiagnostics();
};

document.getElementById('diagProceedButton').onclick = function() {
    document.getElementById('diagnosticsModal').style.display = 'none';
    startIdentityVerification();
};

/* --- SIMPLIFIED PROCTORING SYSTEM --- */
var currentVerifyStep = 1;
var capturedFaceData = null;
var capturedIdData = null;

function startIdentityVerification() {
    document.getElementById('identityVerificationModal').style.display = 'flex';
    showVerifyStep(1);
}

async function showVerifyStep(step) {
    // Hide all steps
    var steps = document.querySelectorAll('.verification-step');
    for (var i = 0; i < steps.length; i++) {
        steps[i].style.display = 'none';
    }
    document.getElementById('verification-step-' + step).style.display = 'block';

    // Update step navigation
    for (var i = 1; i <= 4; i++) {
        var nav = document.getElementById('step-nav-' + i);
        var circle = nav.querySelector('div');
        if (i < step) {
            circle.style.background = '#10b981';
            circle.innerHTML = '?';
            nav.style.color = '#10b981';
        } else if (i === step) {
            circle.style.background = '#09294d';
            circle.textContent = i;
            nav.style.color = '#09294d';
            nav.style.fontWeight = 'bold';
        } else {
            circle.style.background = '#cbd5e1';
            circle.textContent = i;
            nav.style.color = '#cbd5e1';
        }
    }

    // Handle buttons
    document.getElementById('verifyPrevBtn').style.display = (step > 1 && step < 4) ? 'inline-block' : 'none';
    document.getElementById('verifyNextBtn').style.display = (step < 4) ? 'inline-block' : 'none';
    document.getElementById('verifyFinalBtn').style.display = (step === 4) ? 'inline-block' : 'none';

    // Start camera for step 2 and KEEP IT RUNNING
    if (step === 2) {
        try {
            globalVideoStream = await navigator.mediaDevices.getUserMedia({ 
                video: { width: 640, height: 480 },
                audio: true 
            });
            var video = document.getElementById('faceVideo');
            video.srcObject = globalVideoStream;
            video.play();
        } catch (err) {
            alert('Camera access is required for this exam. Please allow camera permissions.');
        }
    }
    
    // Use same stream for step 3
    if (step === 3 && globalVideoStream) {
        var video = document.getElementById('idVideo');
        video.srcObject = globalVideoStream;
        video.play();
    }
    
    // Show captured images in summary
    if (step === 4) {
        document.getElementById('summaryFaceImg').src = capturedFaceData;
        document.getElementById('summaryIdImg').src = capturedIdData;
    }

    currentVerifyStep = step;
}

// Initialize button listeners after DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Capture face
    const captureFaceBtn = document.getElementById('captureFaceBtn');
    if (captureFaceBtn) {
        captureFaceBtn.onclick = function() {
            var video = document.getElementById('faceVideo');
            var canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);
            capturedFaceData = canvas.toDataURL('image/jpeg');
            document.getElementById('faceImgPreview').src = capturedFaceData;
            document.getElementById('faceCapturedPreview').style.display = 'block';
        };
    }

    // Capture ID
    const captureIdBtn = document.getElementById('captureIdBtn');
    if (captureIdBtn) {
        captureIdBtn.onclick = function() {
            var video = document.getElementById('idVideo');
            var canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);
            capturedIdData = canvas.toDataURL('image/jpeg');
            document.getElementById('idImgPreview').src = capturedIdData;
            document.getElementById('idCapturedPreview').style.display = 'block';
        };
    }

    // Next button
    const verifyNextBtn = document.getElementById('verifyNextBtn');
    if (verifyNextBtn) {
        verifyNextBtn.onclick = async function() {
            if (currentVerifyStep === 1) {
                var agreed = document.getElementById('honorCodeCheckbox').checked;
                var sig = document.getElementById('digitalSignature').value.trim();
                if (!agreed || !sig) {
                    alert('Please agree to the Code of Honor and provide your digital signature.');
                    return;
                }
                showVerifyStep(2);
            } else if (currentVerifyStep === 2) {
                if (!capturedFaceData) {
                    alert('Please capture your face photo first.');
                    return;
                }
                showVerifyStep(3);
            } else if (currentVerifyStep === 3) {
                if (!capturedIdData) {
                    alert('Please capture your ID photo first.');
                    return;
                }
                await saveVerificationToBackend();
                showVerifyStep(4);
            }
        };
    }

    // Previous button
    const verifyPrevBtn = document.getElementById('verifyPrevBtn');
    if (verifyPrevBtn) {
        verifyPrevBtn.onclick = function() {
            showVerifyStep(currentVerifyStep - 1);
        };
    }

    // Final button - Start proctoring with the SAME stream
    const verifyFinalBtn = document.getElementById('verifyFinalBtn');
    if (verifyFinalBtn) {
        verifyFinalBtn.onclick = async function() {
            document.getElementById('identityVerificationModal').style.display = 'none';

            // Start proctoring with the existing stream
            if (typeof ProctoringSystem === 'function') {
                var proctor = new ProctoringSystem(examId, studentId);
                window.proctor = proctor;
                await proctor.initialize(globalVideoStream);
            } else {
                console.warn('ProctoringSystem not available');
            }

            document.getElementById('finalConfirmationModal').style.display = 'flex';
        };
    }
});

// Save verification to server
async function saveVerificationToBackend() {
    var formData = new URLSearchParams();
    formData.append('page', 'proctoring');
    formData.append('operation', 'save_verification');
    formData.append('studentId', studentId);
    formData.append('examId', examId);
    formData.append('honorAccepted', 'true');
    formData.append('facePhoto', capturedFaceData);
    formData.append('idPhoto', capturedIdData);

    try {
        await fetch('controller.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        });
    } catch (err) {
        console.error('Error saving verification:', err);
    }
}


// Begin exam button (Final)
document.addEventListener('DOMContentLoaded', function() {
    const finalBeginBtn = document.getElementById('beginExamBtnFinal');
    if (finalBeginBtn) {
        finalBeginBtn.onclick = function(e) {
            e.preventDefault();
            const form = document.getElementById('examStartForm');
            if (form) {
                form.submit();
            } else {
                console.error('examStartForm not found');
            }
        };
    }
});

// Simple ProctoringSystem if not loaded from external file
if (typeof ProctoringSystem === 'undefined') {
    window.ProctoringSystem = function(examId, studentId) {
        this.examId = examId;
        this.studentId = studentId;
        this.examActive = true;
        this.warningCount = 0;
        this.MAX_WARNINGS = 3;
        
        this.initialize = async function(stream) {
            console.log('Proctoring active with continuous camera');
            this.showStatusBanner();
            this.initEnvironmentLockdown();
        };
        
        this.showStatusBanner = function() {
            var banner = document.createElement('div');
            banner.id = 'proctoring-banner';
            banner.style.cssText = 'position: fixed; top: 10px; right: 10px; background: #09294d; color: white; padding: 8px 15px; border-radius: 20px; z-index: 9999;';
            banner.innerHTML = '<span>? RECORDING</span> <span id="violation-counter">0</span>';
            document.body.appendChild(banner);
        };
        
        this.initEnvironmentLockdown = function() {
            document.addEventListener('contextmenu', function(e) {
                e.preventDefault();
                return false;
            });
            
            window.addEventListener('blur', function() {
                this.logViolation('LOCKDOWN', 'Tab switched');
            }.bind(this));
        };
        
        this.logViolation = function(type, desc) {
            if (!this.examActive) return;
            this.warningCount++;
            var counter = document.getElementById('violation-counter');
            if (counter) counter.textContent = this.warningCount;
            
            if (this.warningCount >= this.MAX_WARNINGS) {
                alert('EXAM TERMINATED: Maximum violations exceeded');
                var form = document.getElementById('myform');
                if (form) {
                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'cheating_terminated';
                    input.value = 'true';
                    form.appendChild(input);
                    form.submit();
                }
            }
        };
    };
}
</script>

<style>
    /* PROCTORING MODALS STYLING */
    .proctoring-modal {
        display: none;
        position: fixed;
        z-index: 9999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0,0,0,0.8);
        backdrop-filter: blur(5px);
        align-items: center;
        justify-content: center;
    }

    .proctoring-modal-content {
        background-color: #fefefe;
        padding: 30px;
        border-radius: 12px;
        width: 90%;
        max-width: 650px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        max-height: 90vh;
        overflow-y: auto;
    }

    .proctoring-header {
        border-bottom: 2px solid #f1f5f9;
        padding-bottom: 15px;
        margin-bottom: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .proctoring-header h2 {
        color: #09294d;
        margin: 0;
        font-size: 24px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .diag-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px;
        border-bottom: 1px solid #f1f5f9;
    }

    .diag-item:last-child {
        border-bottom: none;
    }

    .diag-label {
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .status-pass { color: #10b981; }
    .status-fail { color: #ef4444; }

    /* Verification Steps */
    .verification-steps-nav {
        display: flex;
        justify-content: space-between;
        margin-bottom: 30px;
        position: relative;
    }

    .verification-steps-nav::before {
        content: '';
        position: absolute;
        top: 15px;
        left: 0;
        right: 0;
        height: 2px;
        background: #e2e8f0;
        z-index: 1;
    }

    .step-nav-item {
        position: relative;
        z-index: 2;
        background: #fff;
        padding: 0 10px;
        text-align: center;
        font-size: 12px;
        color: #64748b;
    }

    .step-circle {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #cbd5e1;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 5px;
        font-weight: bold;
        transition: all 0.3s ease;
    }

    .video-container {
        position: relative;
        width: 100%;
        max-width: 480px;
        margin: 0 auto 20px;
        background: #000;
        border-radius: 8px;
        overflow: hidden;
    }

    .video-container video {
        width: 100%;
        display: block;
    }

    .capture-preview {
        display: none;
        margin-top: 10px;
        text-align: center;
    }

    .capture-preview img {
        max-width: 200px;
        border: 2px solid #10b981;
        border-radius: 4px;
    }

    .honor-code-box {
        background: #f8fafc;
        padding: 20px;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        margin-bottom: 20px;
        max-height: 200px;
        overflow-y: auto;
        font-size: 14px;
    }

    .proctoring-footer {
        margin-top: 30px;
        display: flex;
        justify-content: flex-end;
        gap: 15px;
    }

    .btn-diag {
        padding: 10px 20px;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        border: none;
        transition: all 0.2s;
    }

    .btn-diag-primary {
        background: #09294d;
        color: white;
    }

    .btn-diag-primary:hover:not(:disabled) {
        background: #1e3a8a;
        transform: translateY(-1px);
    }

    .btn-diag-secondary {
        background: #e2e8f0;
        color: #475569;
    }

    .btn-diag-primary:disabled {
        background: #94a3b8;
        cursor: not-allowed;
    }

    /* EXAM TOOLS MODALS */
    .exam-tool-modal {
        display: none;
        position: fixed;
        z-index: 10001;
        background: white;
        border-radius: 8px;
        box-shadow: 0 5px 25px rgba(0,0,0,0.2);
        border: 1px solid #e2e8f0;
    }

    .tool-header {
        background: #09294d;
        color: white;
        padding: 10px 15px;
        border-radius: 8px 8px 0 0;
        cursor: move;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .tool-body {
        padding: 15px;
    }

    /* Calculator */
    #calculatorModal {
        width: 320px;
        top: 100px;
        left: 100px;
    }

    .calc-display {
        background: #f1f5f9;
        padding: 15px;
        text-align: right;
        font-family: monospace;
        font-size: 20px;
        margin-bottom: 10px;
        border-radius: 4px;
        min-height: 60px;
        word-break: break-all;
    }

    .calc-buttons {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 5px;
    }

    .calc-btn {
        padding: 10px;
        border: 1px solid #e2e8f0;
        background: #fff;
        border-radius: 4px;
        cursor: pointer;
    }

    .calc-btn:hover { background: #f8fafc; }
    .calc-btn.op { background: #f1f5f9; color: #09294d; font-weight: bold; }

    /* Rough Paper */
    #roughPaperModal {
        width: 400px;
        top: 150px;
        left: 150px;
    }

    #roughTextarea {
        width: 100%;
        height: 250px;
        padding: 10px;
        border: 1px solid #e2e8f0;
        border-radius: 4px;
        font-family: inherit;
        resize: both;
    }
</style>

<!-- CALCULATOR MODAL -->
<div id="calculatorModal" class="exam-tool-modal">
    <div id="calcHeader" class="tool-header">
        <span><i class="fas fa-calculator"></i> Scientific Calculator</span>
        <button onclick="toggleCalculator()" class="btn-close btn-close-white" style="font-size: 10px;"></button>
    </div>
    <div class="tool-body">
        <div id="calcHistory" style="font-size: 12px; color: #64748b; text-align: right; height: 18px;"></div>
        <div id="calcDisplay" class="calc-display">0</div>
        <div class="calc-buttons">
            <button class="calc-btn op" onclick="calcAction('clear')">C</button>
            <button class="calc-btn op" onclick="calcAction('backspace')">?</button>
            <button class="calc-btn op" onclick="calcAction('pow')">x?</button>
            <button class="calc-btn op" onclick="calcAction('sqrt')">?</button>

            <button class="calc-btn op" onclick="calcAction('sin')">sin</button>
            <button class="calc-btn op" onclick="calcAction('cos')">cos</button>
            <button class="calc-btn op" onclick="calcAction('tan')">tan</button>
            <button class="calc-btn op" onclick="calcInput('/')">/</button>

            <button class="calc-btn" onclick="calcInput('7')">7</button>
            <button class="calc-btn" onclick="calcInput('8')">8</button>
            <button class="calc-btn" onclick="calcInput('9')">9</button>
            <button class="calc-btn op" onclick="calcInput('*')">×</button>

            <button class="calc-btn" onclick="calcInput('4')">4</button>
            <button class="calc-btn" onclick="calcInput('5')">5</button>
            <button class="calc-btn" onclick="calcInput('6')">6</button>
            <button class="calc-btn op" onclick="calcInput('-')">-</button>

            <button class="calc-btn" onclick="calcInput('1')">1</button>
            <button class="calc-btn" onclick="calcInput('2')">2</button>
            <button class="calc-btn" onclick="calcInput('3')">3</button>
            <button class="calc-btn op" onclick="calcInput('+')">+</button>

            <button class="calc-btn" onclick="calcInput('0')">0</button>
            <button class="calc-btn" onclick="calcInput('.')">.</button>
            <button class="calc-btn op" onclick="calcInput('Math.PI')">?</button>
            <button class="calc-btn btn-diag-primary" onclick="calcAction('equal')" style="grid-column: span 1;">=</button>
        </div>
    </div>
</div>

<!-- ROUGH PAPER MODAL -->
<div id="roughPaperModal" class="exam-tool-modal">
    <div id="roughHeader" class="tool-header">
        <span><i class="fas fa-pen-nib"></i> Rough Work Area</span>
        <button onclick="toggleRoughPaper()" class="btn-close btn-close-white" style="font-size: 10px;"></button>
    </div>
    <div class="tool-body">
        <textarea id="roughTextarea" placeholder="Use this area for your rough calculations and notes. Your notes are saved automatically during this session."></textarea>
    </div>
</div>

<!-- TIME UP MODAL -->
<div id="timeUpModal" class="proctoring-modal">
    <div class="proctoring-modal-content" style="max-width: 400px; text-align: center;">
        <i class="fas fa-hourglass-end fa-4x text-danger mb-3"></i>
        <h2>Time is Up!</h2>
        <p>Your allocated time for this assessment has expired.</p>
        <p>Your answers are being submitted automatically...</p>
        <div class="spinner-border text-primary mt-3" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-2">Redirecting in <span id="timeUpCountdown">3</span> seconds</p>
    </div>
</div>

<!-- CONFIRM SUBMIT MODAL -->
<div id="confirmSubmitModal" class="proctoring-modal">
    <div class="proctoring-modal-content" style="max-width: 500px;">
        <div class="proctoring-header">
            <h2><i class="fas fa-question-circle"></i> Confirm Submission</h2>
        </div>
        <div class="proctoring-body">
            <p>Are you sure you want to submit your assessment? You will not be able to change your answers after submission.</p>
            <div id="unansweredWarning" class="alert alert-warning" style="display:none;">
                <i class="fas fa-exclamation-triangle"></i> You still have unanswered questions.
            </div>
        </div>
        <div class="proctoring-footer">
            <button onclick="closeConfirmSubmitModal()" class="btn-diag btn-diag-secondary">Go Back</button>
            <button id="confirmSubmitBtn" class="btn-diag btn-diag-primary">Submit Final Answers</button>
        </div>
    </div>
</div>

<!-- DIAGNOSTICS MODAL -->
<div id="diagnosticsModal" class="proctoring-modal">
    <div class="proctoring-modal-content">
        <div class="proctoring-header">
            <h2><i class="fas fa-microchip"></i> System Diagnostics</h2>
        </div>
        <div class="proctoring-body">
            <p>Please wait while we verify your system requirements for a secure exam environment.</p>
            <div class="diag-list">
                <div class="diag-item">
                    <span class="diag-label"><i class="fas fa-wifi"></i> Internet Connection</span>
                    <span id="status-internet"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
                <div class="diag-item">
                    <span class="diag-label"><i class="fab fa-chrome"></i> Browser Compatibility</span>
                    <span id="status-browser"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
                <div class="diag-item">
                    <span class="diag-label"><i class="fas fa-code"></i> JavaScript Enabled</span>
                    <span id="status-javascript"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
                <div class="diag-item">
                    <span class="diag-label"><i class="fas fa-desktop"></i> Screen Resolution</span>
                    <span id="status-resolution"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
                <div class="diag-item">
                    <span class="diag-label"><i class="fas fa-laptop"></i> Operating System</span>
                    <span id="status-os"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
                <div class="diag-item">
                    <span class="diag-label"><i class="fas fa-camera"></i> Camera Access</span>
                    <span id="status-camera"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
                <div class="diag-item">
                    <span class="diag-label"><i class="fas fa-expand"></i> Fullscreen Support</span>
                    <span id="status-environment"><i class="fas fa-spinner fa-spin"></i></span>
                </div>
            </div>
        </div>
        <div class="proctoring-footer">
            <button id="diagCancelButton" class="btn-diag btn-diag-secondary">Cancel</button>
            <button id="diagRetryButton" class="btn-diag btn-diag-secondary" style="display:none;">Retry</button>
            <button id="diagProceedButton" class="btn-diag btn-diag-primary" disabled>Proceed</button>
        </div>
    </div>
</div>

<!-- IDENTITY VERIFICATION MODAL -->
<div id="identityVerificationModal" class="proctoring-modal">
    <div class="proctoring-modal-content">
        <div class="proctoring-header">
            <h2><i class="fas fa-user-shield"></i> Identity Verification</h2>
        </div>

        <div class="verification-steps-nav">
            <div class="step-nav-item" id="step-nav-1">
                <div class="step-circle">1</div>
                <span>Honor Code</span>
            </div>
            <div class="step-nav-item" id="step-nav-2">
                <div class="step-circle">2</div>
                <span>Face Photo</span>
            </div>
            <div class="step-nav-item" id="step-nav-3">
                <div class="step-circle">3</div>
                <span>ID Photo</span>
            </div>
            <div class="step-nav-item" id="step-nav-4">
                <div class="step-circle">4</div>
                <span>Summary</span>
            </div>
        </div>

        <div class="verification-body">
            <!-- Step 1: Honor Code -->
            <div id="verification-step-1" class="verification-step">
                <h3>Code of Honor</h3>
                <div class="honor-code-box">
                    <p>By taking this assessment, I agree to the following:</p>
                    <ul>
                        <li>I will complete all work independently.</li>
                        <li>I will not use any unauthorized materials or devices.</li>
                        <li>I will remain in the camera view throughout the duration of the exam.</li>
                        <li>I understand that my session is being recorded for integrity purposes.</li>
                        <li>I will not record or distribute any part of this assessment.</li>
                    </ul>
                </div>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" id="honorCodeCheckbox">
                    <label class="form-check-label" for="honorCodeCheckbox">
                        I agree to the Code of Honor and understand the consequences of any violation.
                    </label>
                </div>
                <div class="form-group">
                    <label for="digitalSignature">Digital Signature (Type your full name)</label>
                    <input type="text" id="digitalSignature" class="form-control" placeholder="Enter your full name">
                </div>
            </div>

            <!-- Step 2: Face Capture -->
            <div id="verification-step-2" class="verification-step" style="display:none;">
                <h3>Capture Face Photo</h3>
                <p>Ensure your face is clearly visible and well-lit.</p>
                <div class="video-container">
                    <video id="faceVideo" autoplay muted></video>
                </div>
                <div class="text-center">
                    <button id="captureFaceBtn" class="btn-diag btn-diag-primary"><i class="fas fa-camera"></i> Capture Photo</button>
                </div>
                <div id="faceCapturedPreview" class="capture-preview">
                    <p class="text-success"><i class="fas fa-check-circle"></i> Photo captured successfully!</p>
                    <img id="faceImgPreview" src="" alt="Face Preview">
                </div>
            </div>

            <!-- Step 3: ID Capture -->
            <div id="verification-step-3" class="verification-step" style="display:none;">
                <h3>Capture ID Card</h3>
                <p>Hold your student ID card up to the camera.</p>
                <div class="video-container">
                    <video id="idVideo" autoplay muted></video>
                </div>
                <div class="text-center">
                    <button id="captureIdBtn" class="btn-diag btn-diag-primary"><i class="fas fa-camera"></i> Capture ID</button>
                </div>
                <div id="idCapturedPreview" class="capture-preview">
                    <p class="text-success"><i class="fas fa-check-circle"></i> ID captured successfully!</p>
                    <img id="idImgPreview" src="" alt="ID Preview">
                </div>
            </div>

            <!-- Step 4: Summary -->
            <div id="verification-step-4" class="verification-step" style="display:none;">
                <h3>Verification Complete</h3>
                <p>Review your captured photos before starting the exam.</p>
                <div class="row">
                    <div class="col-md-6 text-center">
                        <p><strong>Face Photo</strong></p>
                        <img id="summaryFaceImg" src="" style="width:100%; max-width:180px; border-radius:8px;">
                    </div>
                    <div class="col-md-6 text-center">
                        <p><strong>ID Photo</strong></p>
                        <img id="summaryIdImg" src="" style="width:100%; max-width:180px; border-radius:8px;">
                    </div>
                </div>
                <div class="alert alert-success mt-3">
                    <i class="fas fa-check-circle"></i> All verification steps completed. You are now ready to begin the exam.
                </div>
            </div>
        </div>

        <div class="proctoring-footer">
            <button id="verifyPrevBtn" class="btn-diag btn-diag-secondary" style="display:none;">Previous</button>
            <button id="verifyNextBtn" class="btn-diag btn-diag-primary">Next</button>
            <button id="verifyFinalBtn" class="btn-diag btn-diag-primary" style="display:none;">Begin Proctoring</button>
        </div>
    </div>
</div>

<!-- FINAL CONFIRMATION MODAL -->
<div id="finalConfirmationModal" class="proctoring-modal">
    <div class="proctoring-modal-content" style="max-width: 500px; text-align: center;">
        <div class="proctoring-header" style="justify-content: center;">
            <h2><i class="fas fa-check-circle text-success"></i> Ready to Begin</h2>
        </div>
        <div class="proctoring-body">
            <i class="fas fa-shield-alt fa-4x mb-3" style="color: #09294d;"></i>
            <p style="font-size: 18px; font-weight: 600;">Proctoring is now active.</p>
            <p>Your camera and microphone are recording. Please remain in view throughout the entire exam.</p>
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i> Exiting fullscreen or switching tabs will be recorded as violations.
            </div>
        </div>
        <div class="proctoring-footer" style="justify-content: center;">
            <button id="beginExamBtnFinal" class="btn-diag btn-diag-primary" style="padding: 15px 40px; font-size: 18px;">START EXAM NOW</button>
        </div>
    </div>
</div>
<jsp:include page="exam_content.jsp" />
