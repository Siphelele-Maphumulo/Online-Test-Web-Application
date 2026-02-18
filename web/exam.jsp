<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, myPackage.*" %>
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

// Capture face
document.getElementById('captureFaceBtn').onclick = function() {
    var video = document.getElementById('faceVideo');
    var canvas = document.createElement('canvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);
    capturedFaceData = canvas.toDataURL('image/jpeg');
    document.getElementById('faceImgPreview').src = capturedFaceData;
    document.getElementById('faceCapturedPreview').style.display = 'block';
};

// Capture ID
document.getElementById('captureIdBtn').onclick = function() {
    var video = document.getElementById('idVideo');
    var canvas = document.createElement('canvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);
    capturedIdData = canvas.toDataURL('image/jpeg');
    document.getElementById('idImgPreview').src = capturedIdData;
    document.getElementById('idCapturedPreview').style.display = 'block';
};

// Next button
document.getElementById('verifyNextBtn').onclick = async function() {
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

// Previous button
document.getElementById('verifyPrevBtn').onclick = function() {
    showVerifyStep(currentVerifyStep - 1);
};

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

// Final button - Start proctoring with the SAME stream
document.getElementById('verifyFinalBtn').onclick = async function() {
    document.getElementById('identityVerificationModal').style.display = 'none';
    
    // Start proctoring with the existing stream
    if (typeof ProctoringSystem === 'function') {
        var proctor = new ProctoringSystem(examId, studentId);
        window.proctor = proctor;
        await proctor.initialize(globalVideoStream);
    } else {
        console.warn('ProctoringSystem not available');
    }
    
    document.getElementById('confirmationModal').style.display = 'flex';
};

// Begin exam button
document.getElementById('beginButton').onclick = function(e) {
    e.preventDefault();
    document.getElementById('examStartForm').submit();
};

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