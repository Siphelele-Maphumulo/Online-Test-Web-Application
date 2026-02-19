
/* --- CALCULATOR LOGIC --- */
var calcInputStr = "";

function toggleCalculator() {
    var modal = document.getElementById('calculatorModal');
    if (!modal) return;
    if (modal.style.display === 'block') {
        modal.style.display = 'none';
    } else {
        modal.style.display = 'block';
    }
}

function calcInput(val) {
    calcInputStr += val;
    var display = document.getElementById('calcDisplay');
    if (!display) return;
    display.textContent = calcInputStr.replace(/Math\.PI/g, '?').replace(/Math\.E/g, 'e');
}

function calcAction(action) {
    var display = document.getElementById('calcDisplay');
    var history = document.getElementById('calcHistory');
    if (!display || !history) return;

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
            history.textContent = action + "(" + val + (['sin','cos','tan'].indexOf(action) !== -1 ? "deg" : "") + ") =";
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
    var modal = document.getElementById("calculatorModal");
    if (!modal) return;
    dragElement(modal);
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
    if (!modal) return;
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
            if (typeof showSystemAlertModal === 'function') {
                showSystemAlertModal('You can only select up to ' + maxSel + ' options for this question.');
            }
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
        var submitSection = document.querySelector('.submit-section');
        if (submitSection) submitSection.scrollIntoView({ behavior: 'smooth' });
    }
}

function prevQuestion() {
    if (currentQuestionIndex > 0) {
        showQuestion(currentQuestionIndex - 1);
        window.scrollTo(0, 0);
    }
}

/* --- ASYNC ANSWER SAVING --- */
function saveAnswer(qindex, answer) {
    var questionCard = document.querySelector('.question-card[data-qindex="' + qindex + '"]');
    if (!questionCard) return;

    var qidInput = questionCard.querySelector('input[name="qid' + qindex + '"]');
    var questionInput = questionCard.querySelector('input[name="question' + qindex + '"]');
    if (!qidInput || !questionInput) return;

    var params = new URLSearchParams();
    params.append('page', 'saveAnswer');
    params.append('qid', qidInput.value);
    params.append('question', questionInput.value);
    params.append('ans', answer);

    try {
        if (navigator.sendBeacon) {
            navigator.sendBeacon('controller.jsp', params);
        }
    } catch (e) {
        // ignore
    }
}

document.addEventListener('change', function(e) {
    if (!e.target.classList || !e.target.classList.contains('answer-input')) return;
    var qindex = e.target.getAttribute('data-qindex');
    if (qindex == null) return;

    var answer = '';
    if (e.target.classList.contains('multi')) {
        var wrapper = e.target.closest('.answers');
        if (wrapper) {
            var selectedValues = [];
            var checkboxes = wrapper.querySelectorAll('input.multi:checked');
            for (var i = 0; i < checkboxes.length; i++) {
                selectedValues.push(checkboxes[i].value);
            }
            answer = selectedValues.join('|');
        }
    } else {
        answer = e.target.value;
    }

    saveAnswer(qindex, answer);
});

                /* --- TIMER MANAGEMENT --- */
                function startTimer() {
                    var timerEl = document.getElementById('remainingTimeHeader');
                    if(!timerEl) {
                        console.warn('Timer element not found, timer disabled');
                        return;
                    }

                    // Calculate initial time
                    var timeInSeconds = examDuration > 0 ? examDuration * 60 : 60 * 60;

                    // Check if we have a saved start time
                    var storageKey = 'examStartTime_' + currentCourseName;
                    var startTime = sessionStorage.getItem(storageKey);
                    var elapsedSeconds = 0;

                    if(startTime) {
                        // Resume from saved time
                        elapsedSeconds = Math.floor((Date.now() - parseInt(startTime)) / 1000);
                        timeInSeconds = Math.max(0, timeInSeconds - elapsedSeconds);
                    } else {
                        // Start new timer
                        sessionStorage.setItem(storageKey, Date.now().toString());
                    }

                    var time = timeInSeconds;

                    function fmt(n) {
                        return String(n).padStart(2, '0');
                    }

                    function updateTimerDisplay() {
                        var minutes = Math.floor(time / 60);
                        var seconds = time % 60;
                        var formattedTime = fmt(minutes) + ':' + fmt(seconds);
                        timerEl.textContent = formattedTime;

                        var headerTimer = document.getElementById('remainingTimeHeader');
                        if (headerTimer) headerTimer.textContent = formattedTime;

                        // Color coding
                        if (timerEl.classList) {
                            timerEl.classList.remove('warning', 'critical', 'expired');
                            if(time <= 300) timerEl.classList.add('warning');
                            if(time <= 60) timerEl.classList.add('critical');
                        }
                    }

                    updateTimerDisplay();

                    // Clear any existing interval
                    if(timerInterval) clearInterval(timerInterval);

                    // Start new interval
                    timerInterval = setInterval(function() {
                        time--;

                        if(time <= 0) {
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
                    // Save all answers before submitting
                    document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
                        var qindex = box.closest('.question-card').getAttribute('data-qindex');
                        if(qindex) updateHiddenForMulti(qindex);
                    });

                    // Handle Drag and Drop answers - save before auto-submit
                    const dragDropAnswers = getDragDropAnswers();
                    Object.keys(dragDropAnswers).forEach(qindex => {
                        const mappings = dragDropAnswers[qindex];
                        const formattedMappings = {};
                        for (let tId in mappings) {
                            formattedMappings['target_' + tId] = 'item_' + mappings[tId];
                        }
                        const ansValue = JSON.stringify(formattedMappings);

                        let hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
                        if (!hiddenAns) {
                            hiddenAns = document.createElement('input');
                            hiddenAns.type = 'hidden';
                            hiddenAns.name = 'ans' + qindex;
                            document.getElementById('myform').appendChild(hiddenAns);
                        }
                        hiddenAns.value = ansValue;
                    });

                    // Show time up modal
                    showTimeUpModal();

                    // Clean up and submit
                    cleanupExam();
                    setTimeout(function() {
                        document.getElementById('myform').submit();
                    }, 3000);
                }

                /* --- EXAM SUBMISSION --- */
                function submitExam() {
                    // Save all multi-select answers
                    document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
                        var card = box.closest('.question-card');
                        if (!card) return;
                        var qindex = card.getAttribute('data-qindex');
                        if (qindex) updateHiddenForMulti(qindex);
                    });

                    // Handle Drag and Drop answers - PHASE 5 Integration
                    const dragDropAnswers = getDragDropAnswers();
                    Object.keys(dragDropAnswers).forEach(qindex => {
                        const mappings = dragDropAnswers[qindex];
                        const formattedMappings = {};
                        for (let tId in mappings) {
                            formattedMappings['target_' + tId] = 'item_' + mappings[tId];
                        }
                        const ansValue = JSON.stringify(formattedMappings);

                        let hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
                        if (!hiddenAns) {
                            hiddenAns = document.createElement('input');
                            hiddenAns.type = 'hidden';
                            hiddenAns.name = 'ans' + qindex;
                            document.getElementById('myform').appendChild(hiddenAns);
                        }
                        hiddenAns.value = ansValue;
                    });

                    var answeredQuestions = 0;
                    document.querySelectorAll('.question-card').forEach(function(card){
                        const isDragDrop = card.querySelector('.drag-drop-question') !== null;
                        if (isDragDrop) {
                            if (card.querySelectorAll('.dropped-item').length > 0) {
                                answeredQuestions++;
                            }
                        } else {
                            var box = card.querySelector('.answers');
                            if(!box) return;
                            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
                            if(maxSel === 1) {
                                if(box.querySelector('input.single:checked')) answeredQuestions++;
                            } else {
                                if(box.querySelectorAll('input.multi:checked').length >= 1) answeredQuestions++;
                            }
                        }
                    });

                    // Check for unanswered questions
                    if(answeredQuestions < totalQuestions) {
                        var unanswered = totalQuestions - answeredQuestions;
                        showSystemConfirmModal(
                            "You have " + unanswered + " unanswered question" + (unanswered > 1 ? "s" : "") + ". Submit anyway?",
                            function(proceed) {
                                if (!proceed) return;
                                showConfirmSubmitModal();
                            }
                        );
                        return;
                    }

                    // Final confirmation - show modal
                    showConfirmSubmitModal();
                }

                /* --- CLEANUP FUNCTION --- */
                function cleanupExam() {
                    examActive = false;
                    dirty = false;

                    // Clear session storage
                    var storageKey = 'examStartTime_' + currentCourseName;
                    sessionStorage.removeItem(storageKey);

                    // Clear all exam session storage
                    Object.keys(sessionStorage).forEach(function(key) {
                        if(key.startsWith('examStartTime_')) {
                            sessionStorage.removeItem(key);
                        }
                    });

                    // Clear timer interval
                    if(timerInterval) {
                        clearInterval(timerInterval);
                        timerInterval = null;
                    }

                    // Remove navigation protection
                    window.onbeforeunload = null;
                }

                function showSystemAlertModal(message) {
                    var modal = document.getElementById('systemAlertModal');
                    var msg = document.getElementById('systemAlertMessage');
                    if (msg) msg.textContent = message || '';
                    if (modal && modal.classList) {
                        modal.classList.add('active');
                    }
                }

                function closeSystemAlertModal() {
                    var modal = document.getElementById('systemAlertModal');
                    if (modal && modal.classList) {
                        modal.classList.remove('active');
                    }
                }

                var _systemConfirmCallback = null;

                function showSystemConfirmModal(message, onResult) {
                    _systemConfirmCallback = (typeof onResult === 'function') ? onResult : null;
                    var modal = document.getElementById('systemConfirmModal');
                    var msg = document.getElementById('systemConfirmMessage');
                    if (msg) msg.textContent = message || '';
                    if (modal && modal.classList) {
                        modal.classList.add('active');
                    }
                }

                function closeSystemConfirmModal(result) {
                    var modal = document.getElementById('systemConfirmModal');
                    if (modal && modal.classList) {
                        modal.classList.remove('active');
                    }
                    if (_systemConfirmCallback) {
                        try { _systemConfirmCallback(!!result); } catch (e) {}
                    }
                    _systemConfirmCallback = null;
                }

                /* --- NAVIGATION PROTECTION --- */
                function setupNavigationProtection() {
                    // Prevent leaving the page
                    window.onbeforeunload = function(e) {
                        if(examActive && dirty && !warningGiven) {
                            var message = 'You have an active exam in progress. If you leave, your answers may not be saved.';
                            e.returnValue = message;
                            return message;
                        }
                    };

                    // Intercept navigation clicks
                    document.addEventListener('click', function(e) {
                        if(!examActive) return;

                        var link = e.target.closest('a');
                        if(link && link.href) {
                            // Check if it's navigation away from exam page
                            var currentUrl = window.location.href;
                            var targetUrl = link.href;

                            // Allow navigation within exam pages
                            if(!targetUrl.includes('std-page.jsp?pgprt=1') &&
                            !targetUrl.includes('controller.jsp?page=exams')) {

                                e.preventDefault();

                                // Show warning modal
                                showNavigationWarning(function(proceed) {
                                    if(proceed) {
                                        warningGiven = true;
                                        cleanupExam();
                                        window.location.href = link.href;
                                    }
                                });
                            }
                        }
                    });
                }

                /* --- FLOATING PROGRESS BUTTON & MODAL --- */
                function setupProgressModal() {
                    var floatBtn = document.getElementById('progressFloatBtn');
                    var modal = document.getElementById('progressModal');
                    var closeModal = document.querySelectorAll('.close-modal');
                    var modalSubmitBtn = document.getElementById('modalSubmitBtn');

                    if(floatBtn && modal) {
                        floatBtn.addEventListener('click', function() {
                            if (modal && modal.classList) {
                                modal.classList.add('active');
                            }
                            updateProgress();
                        });

                        closeModal.forEach(function(btn) {
                            btn.addEventListener('click', function() {
                                if (modal && modal.classList) {
                                    modal.classList.remove('active');
                                }
                            });
                        });

                        modal.addEventListener('click', function(e) {
                            if(e.target === modal) {
                                modal.classList.remove('active');
                            }
                        });

                        if(modalSubmitBtn) {
                            modalSubmitBtn.addEventListener('click', function() {
                                if (modal && modal.classList) {
                                    modal.classList.remove('active');
                                }
                                submitExam();
                            });
                        }
                    }
                }

                // Leave-window enforcement: 1 attempt, 5 seconds to return
                var leaveAttempts = 0;
                var leaveCountdownInterval = null;
                var leaveTimeout = null;

                function showLeaveWindowModal() {
                    var modal = document.getElementById('leaveWindowModal');
                    var countdownEl = document.getElementById('leaveWindowCountdown');
                    if (countdownEl) countdownEl.textContent = '5';
                    if (modal && modal.classList) {
                        modal.classList.add('active');
                    }
                }

                function hideLeaveWindowModal() {
                    var modal = document.getElementById('leaveWindowModal');
                    if (modal && modal.classList) {
                        modal.classList.remove('active');
                    }
                }

                function terminateForLeavingWindow() {
                    try {
                        hideLeaveWindowModal();
                    } catch (e) {}

                    // Mark state and submit similarly to time-up
                    var form = document.getElementById('myform');
                    if (form) {
                        var input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = 'left_window_terminated';
                        input.value = 'true';
                        form.appendChild(input);
                    }

                    // Use the same safe submit path as time-up
                    autoSubmitExam();
                }

                function startLeaveWindowCountdown() {
                    if (!examActive) return;

                    // Only one grace attempt
                    leaveAttempts++;
                    if (leaveAttempts > 1) {
                        terminateForLeavingWindow();
                        return;
                    }

                    showLeaveWindowModal();

                    var secondsLeft = 5;
                    var countdownEl = document.getElementById('leaveWindowCountdown');
                    if (leaveCountdownInterval) clearInterval(leaveCountdownInterval);
                    if (leaveTimeout) clearTimeout(leaveTimeout);

                    leaveCountdownInterval = setInterval(function() {
                        secondsLeft--;
                        if (countdownEl) countdownEl.textContent = String(Math.max(0, secondsLeft));
                        if (secondsLeft <= 0) {
                            clearInterval(leaveCountdownInterval);
                            leaveCountdownInterval = null;
                        }
                    }, 1000);

                    leaveTimeout = setTimeout(function() {
                        terminateForLeavingWindow();
                    }, 5000);
                }

                function cancelLeaveWindowCountdown() {
                    if (leaveCountdownInterval) {
                        clearInterval(leaveCountdownInterval);
                        leaveCountdownInterval = null;
                    }
                    if (leaveTimeout) {
                        clearTimeout(leaveTimeout);
                        leaveTimeout = null;
                    }
                    hideLeaveWindowModal();
                }

                window.addEventListener('blur', function() {
                    if (!examActive) return;
                    startLeaveWindowCountdown();
                });

                window.addEventListener('focus', function() {
                    if (!examActive) return;
                    cancelLeaveWindowCountdown();
                });

                /* --- TIME UP MODAL FUNCTIONS --- */
                function showTimeUpModal() {
                    var modal = document.getElementById('timeUpModal');
                    if (modal) {
                        modal.classList.add('active');

                        // Countdown
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

                /* --- CONFIRM SUBMIT MODAL FUNCTIONS --- */
                function showConfirmSubmitModal() {
                    var modal = document.getElementById('confirmSubmitModal');
                    var confirmBtn = document.getElementById('confirmSubmitBtn');

                    if (modal) {
                        modal.classList.add('active');

                        // Set up confirm button handler
                        if (confirmBtn) {
                            confirmBtn.onclick = function() {
                                closeConfirmSubmitModal();

                                cleanupExam();

                                // Show loading state
                                var btn = document.getElementById('submitBtn');
                                if(btn) {
                                    btn.disabled = true;
                                    if (btn.classList) {
                                        btn.classList.add('loading');
                                    }
                                    var btnText = btn.querySelector('.btn-text');
                                    var btnLoading = btn.querySelector('.btn-loading');
                                    if(btnText) btnText.style.display = 'none';
                                    if(btnLoading) btnLoading.style.display = 'inline';
                                }

                                // Submit form
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

                /* --- INITIALIZATION --- */
                document.addEventListener('DOMContentLoaded', function() {
                    // Initialize components
                    showQuestion(0);
                    startTimer();
                    initCalcDraggable();
                    initRoughPaper();
                    setupNavigationProtection();
                    setupProgressModal();

                    // Set up submit button handlers
                    var submitBtn = document.getElementById('submitBtn');
                    if(submitBtn) {
                        submitBtn.addEventListener('click', submitExam);
                    }

                    // Clear session storage when page unloads (if exam is not active)
                    window.addEventListener('beforeunload', function() {
                        if(!examActive) {
                            var storageKey = 'examStartTime_' + currentCourseName;
                            sessionStorage.removeItem(storageKey);
                        }
                    });
                });

                /* --- SIMPLIFIED DRAG AND DROP FUNCTIONALITY - NO BACKTICKS --- */
let userMappings = {};

function initializeDragDropQuestions() {
    const dragDropQuestions = document.querySelectorAll('.drag-drop-question');

    dragDropQuestions.forEach(function(questionContainer, idx) {
        const card = questionContainer.closest('.question-card');
        if (!card) return;

        const questionIndex = card.getAttribute('data-qindex');
        userMappings[questionIndex] = {};

        const dragItemsContainer = document.getElementById('dragItems_' + questionIndex);
        const dropTargetsContainer = document.getElementById('dropTargets_' + questionIndex);

        // SIMPLE parsing with NO template literals
        let itemsData = [];
        let targetsData = [];

        try {
            var itemsJson = questionContainer.getAttribute('data-items-json');
            var targetsJson = questionContainer.getAttribute('data-targets-json');

            if (itemsJson && itemsJson != 'null' && itemsJson != 'undefined') {
                itemsData = JSON.parse(itemsJson);
            }
            if (targetsJson && targetsJson != 'null' && targetsJson != 'undefined') {
                targetsData = JSON.parse(targetsJson);
            }
        } catch (e) {
            console.log('Error parsing drag-drop JSON for question ' + (parseInt(questionIndex) + 1));
            itemsData = [];
            targetsData = [];
        }

        // Check for orientation in extra_data
        try {
            var extraDataStr = questionContainer.getAttribute('data-extra-data');
            var isLandscape = false;

            if (extraDataStr) {
                var extraData = JSON.parse(extraDataStr);
                if (extraData.orientation === 'vertical') {
                    var container = questionContainer.querySelector('.drag-drop-container');
                    if (container) container.classList.add('vertical-layout');
                } else if (extraData.orientation === 'landscape') {
                    isLandscape = true;
                } else if (extraData.orientation === 'horizontal') {
                    // Apply horizontal layout class
                    var container = questionContainer.querySelector('.drag-drop-container');
                    if (container) container.classList.add('horizontal-layout');
                }
            }

            // Auto-detect landscape based on keywords or structure if not explicitly set
            var questionText = card.querySelector('.question-text') ? card.querySelector('.question-text').textContent.toLowerCase() : '';
            if (questionText.includes('code') || questionText.includes('line') || questionText.includes('order')) {
                isLandscape = true;
            }

            if (isLandscape) {
                var container = questionContainer.querySelector('.drag-drop-container');
                if (container) container.classList.add('landscape-layout');
            }
        } catch (e) {
            console.log('Error parsing extra data for orientation');
        }

        // Call render function
        renderDragDropInterface(questionIndex, dragItemsContainer, dropTargetsContainer, itemsData, targetsData);
    });
}

/* --- DRAG AND DROP RANDOMIZATION --- */
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        const temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

function renderDragDropInterface(qIdx, dragContainer, dropContainer, items, targets) {
    console.log('Rendering drag-drop for question ' + (parseInt(qIdx) + 1));

    // Handle simple string arrays
    var normalizedItems = [];
    for (var i = 0; i < items.length; i++) {
        if (typeof items[i] === 'string') {
            normalizedItems.push({ id: 'item_' + i, text: items[i] });
        } else {
            normalizedItems.push(items[i]);
        }
    }

    var normalizedTargets = [];
    for (var i = 0; i < targets.length; i++) {
        if (typeof targets[i] === 'string') {
            normalizedTargets.push({ id: 'target_' + i, label: targets[i] });
        } else {
            normalizedTargets.push(targets[i]);
        }
    }

    // RANDOMIZE: Shuffle only items (targets stay in original order)
    var shuffledItems = shuffleArray(normalizedItems.slice());
    // Keep targets in original order - but we allow manual reordering now
    var orderedTargets = normalizedTargets.slice();

    // Render Items (randomized order)
    dragContainer.innerHTML = '';
    for (var i = 0; i < shuffledItems.length; i++) {
        var item = shuffledItems[i];
        var el = document.createElement('div');
        el.className = 'drag-item';
        el.draggable = true;
        el.id = 'q' + qIdx + '_item_' + item.id;
        el.setAttribute('data-item-id', item.id);
        el.setAttribute('data-text', item.text);
        el.textContent = item.text;

        el.addEventListener('dragstart', handleDragStart);
        el.addEventListener('dragend', handleDragEnd);

        dragContainer.appendChild(el);
    }

    // Render Targets
    dropContainer.innerHTML = '';
    for (var i = 0; i < orderedTargets.length; i++) {
        var target = orderedTargets[i];
        var el = document.createElement('div');
        el.id = 'q' + qIdx + '_target_' + target.id;
        el.setAttribute('data-target-id', target.id);
        el.draggable = true; // Targets are now draggable for reordering

        // Handle [[target]] placeholder
        var label = target.label || "";
        var parts = label.split('[[target]]');

        if (parts.length > 1) {
            el.className = 'drop-target inline-target';
            el.innerHTML = '<span>' + parts[0] + '</span>' +
                           '<div class="drop-zone-inline"><div class="placeholder">Drop</div></div>' +
                           '<span>' + (parts[1] || "") + '</span>';
        } else {
            el.className = 'drop-target';
            el.innerHTML = '<div class="drop-target-header">' + label + '</div>' +
                           '<div class="placeholder">Drop here</div>';
        }

        // Listeners for item drops
        el.addEventListener('dragover', handleDragOver);
        el.addEventListener('dragenter', handleDragEnter);
        el.addEventListener('dragleave', handleDragLeave);
        el.addEventListener('drop', handleDrop);

        // Listeners for target reordering
        el.addEventListener('dragstart', handleTargetDragStart);
        el.addEventListener('dragend', handleTargetDragEnd);

        dropContainer.appendChild(el);
    }

    // Initialize waiting states for empty targets
    updateWaitingStates();
}

function shuffleDraggableItems(qIdx) {
    const dragContainer = document.getElementById('dragItems_' + qIdx);
    const dragItems = Array.from(dragContainer.children);

    // Shuffle items
    const shuffled = shuffleArray(dragItems);

    // Clear and re-append in shuffled order
    dragContainer.innerHTML = '';
    shuffled.forEach(item => dragContainer.appendChild(item));
}

function shuffleDropTargets(qIdx) {
    const dropContainer = document.getElementById('dropTargets_' + qIdx);
    const dropTargets = Array.from(dropContainer.children);

    // Shuffle targets
    const shuffled = shuffleArray(dropTargets);

    // Clear and re-append in shuffled order
    dropContainer.innerHTML = '';
    shuffled.forEach(target => dropContainer.appendChild(target));
}

/* --- IMAGE RANDOMIZATION --- */
function randomizeImages() {
    const questionCards = document.querySelectorAll('.question-card');

    questionCards.forEach(card => {
        const imageContainer = card.querySelector('.question-image-container');
        if (imageContainer) {
            // Random chance to show image above or below question text
            if (Math.random() > 0.5) {
                // Already in default position
            } else {
                // Move image after question text
                const questionContent = card.querySelector('.question-content');
                const questionText = card.querySelector('.question-text');
                if (questionText && imageContainer) {
                    questionContent.insertBefore(imageContainer, questionText.nextSibling);
                }
            }
        }
    });
}

// Call this after DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    randomizeImages();
    initializeDragDropQuestions();
    initializeRearrangeQuestions();
});

// DRAG HANDLERS
let draggedTargetRow = null;

function handleTargetDragStart(e) {
    if (e.target.classList.contains('dropped-item') || e.target.closest('.dropped-item')) return;
    draggedTargetRow = this;
    this.classList.add('target-reordering');
    e.dataTransfer.setData('text/target-id', this.id);
    e.dataTransfer.effectAllowed = 'move';

    // Create a ghost image or just let it be
}

function handleTargetDragEnd(e) {
    this.classList.remove('target-reordering');
    draggedTargetRow = null;
}

function handleDragStart(e) {
    e.target.classList.add('dragging');
    e.dataTransfer.setData('text/plain', e.target.id);
    e.dataTransfer.setData('text/type', 'item');
    e.dataTransfer.effectAllowed = 'move';
}

function handleDragEnd(e) {
    e.target.classList.remove('dragging');
}

function handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';

    // Handle target reordering shifting
    if (draggedTargetRow && this !== draggedTargetRow && this.classList.contains('drop-target')) {
        if (this.parentNode === draggedTargetRow.parentNode) {
            const container = this.parentNode;
            const children = Array.from(container.children);
            const draggedIndex = children.indexOf(draggedTargetRow);
            const targetIndex = children.indexOf(this);

            if (draggedIndex < targetIndex) {
                container.insertBefore(draggedTargetRow, this.nextSibling);
            } else {
                container.insertBefore(draggedTargetRow, this);
            }
        }
    }
}

function handleDragEnter(e) {
    e.preventDefault();
    if (draggedTargetRow) return; // Don't highlight for target reordering

    var target = e.target.closest('.drop-target');
    if (target) {
        var zone = target.querySelector('.drop-zone-inline') || target;
        zone.classList.add('drag-over');
        target.classList.remove('waiting');
    }
}

function handleDragLeave(e) {
    if (draggedTargetRow) return;

    var target = e.target.closest('.drop-target');
    if (target) {
        var zone = target.querySelector('.drop-zone-inline') || target;
        zone.classList.remove('drag-over');
        // Add waiting state back if target doesn't have items
        if (!target.querySelector('.dropped-item')) {
            target.classList.add('waiting');
        }
    }
}

function createDroppedItem(qIdx, targetId, itemId, text) {
    var el = document.createElement('div');
    el.className = 'dropped-item';
    el.draggable = true;
    el.id = 'q' + qIdx + '_dropped_' + itemId;
    el.setAttribute('data-item-id', itemId);
    el.setAttribute('data-text', text);
    el.innerHTML = '<span>' + text + '</span>' +
                  '<button type="button" class="remove-btn" title="Remove">&times;</button>';

    el.addEventListener('dragstart', handleDragStart);
    el.addEventListener('dragend', handleDragEnd);

    el.querySelector('.remove-btn').onclick = function() {
        removeItemFromTarget(qIdx, targetId, itemId, text);
    };
    return el;
}

function handleDrop(e) {
    e.preventDefault();

    if (draggedTargetRow) {
        // Target reordering drop - handled in dragover for shifting
        return;
    }

    var target = e.target.closest('.drop-target');
    if (!target) return;

    var zone = target.querySelector('.drop-zone-inline') || target;
    zone.classList.remove('drag-over');
    target.classList.remove('waiting');

    var itemId = e.dataTransfer.getData('text/plain');
    var draggedEl = document.getElementById(itemId);
    if (!draggedEl || !draggedEl.classList.contains('drag-item') && !draggedEl.classList.contains('dropped-item')) return;

    var qIdx = target.id.split('_')[0].substring(1);
    var targetId = target.getAttribute('data-target-id');
    var itemDataId = draggedEl.getAttribute('data-item-id');
    var itemText = draggedEl.getAttribute('data-text');

    // Handle item moving from another target
    var sourceTargetId = null;
    if (draggedEl.classList.contains('dropped-item')) {
        var sourceTarget = draggedEl.closest('.drop-target');
        if (sourceTarget) {
            sourceTargetId = sourceTarget.getAttribute('data-target-id');
            // Remove from source target mapping
            if (userMappings[qIdx]) delete userMappings[qIdx][sourceTargetId];
            draggedEl.remove();
            // Show placeholder in source target if empty
            if (!sourceTarget.querySelector('.dropped-item') && !sourceTarget.querySelector('.placeholder')) {
                var ph = document.createElement('div');
                ph.className = 'placeholder';
                ph.textContent = 'Drop here';
                sourceTarget.appendChild(ph);
            }
        }
    } else {
        // From pool - hide original
        draggedEl.style.display = 'none';
    }

    // Swapping logic: if target already has an item
    if (target.querySelector('.dropped-item')) {
        var existingDropped = target.querySelector('.dropped-item');
        var existingId = existingDropped.getAttribute('data-item-id');
        var existingText = existingDropped.getAttribute('data-text');

        if (sourceTargetId) {
            // Swap: move existing item to source target
            var sourceTarget = document.getElementById('q' + qIdx + '_target_' + sourceTargetId);
            if (sourceTarget) {
                var sZone = sourceTarget.querySelector('.drop-zone-inline') || sourceTarget;
                // Remove placeholder from source target if it was just added
                var ph = sZone.querySelector('.placeholder');
                if (ph) ph.remove();

                var swappedEl = createDroppedItem(qIdx, sourceTargetId, existingId, existingText);
                sZone.appendChild(swappedEl);
                userMappings[qIdx][sourceTargetId] = existingId;
            }
        } else {
            // Move existing back to pool if new item came from pool
            restoreItemToPool(qIdx, existingId, existingText);
        }
        existingDropped.remove();
    }

    // Add new item to target
    var droppedEl = createDroppedItem(qIdx, targetId, itemDataId, itemText);
    zone.appendChild(droppedEl);

    // Remove placeholder
    var placeholder = zone.querySelector('.placeholder');
    if (placeholder) placeholder.remove();

    // Update mappings
    if (!userMappings[qIdx]) userMappings[qIdx] = {};
    userMappings[qIdx][targetId] = itemDataId;

    updateProgress();

    // Save answer
    saveDragDropAnswer(qIdx);

    // Add waiting state to all empty targets
    updateWaitingStates();
}

function updateWaitingStates() {
    var allTargets = document.querySelectorAll('.drop-target');
    allTargets.forEach(function(target) {
        var zone = target.querySelector('.drop-zone-inline') || target;
        if (!zone.querySelector('.dropped-item')) {
            target.classList.add('waiting');
            if (!zone.querySelector('.placeholder')) {
                 var ph = document.createElement('div');
                 ph.className = 'placeholder';
                 ph.textContent = target.classList.contains('inline-target') ? 'Drop' : 'Drop here';
                 zone.appendChild(ph);
            }
        } else {
            target.classList.remove('waiting');
            var ph = zone.querySelector('.placeholder');
            if (ph) ph.remove();
        }
    });
}

function restoreItemToPool(qIdx, itemId, text) {
    var pool = document.getElementById('dragItems_' + qIdx);
    var originalItem = document.getElementById('q' + qIdx + '_item_' + itemId);
    if (originalItem) {
        originalItem.style.display = 'flex';
    }
}

function removeItemFromTarget(qIdx, targetId, itemId, text) {
    var target = document.getElementById('q' + qIdx + '_target_' + targetId);
    if (target) {
        var zone = target.querySelector('.drop-zone-inline') || target;
        var droppedItem = zone.querySelector('.dropped-item');
        if (droppedItem) droppedItem.remove();
        if (!zone.querySelector('.placeholder')) {
            var placeholder = document.createElement('div');
            placeholder.className = 'placeholder';
            placeholder.textContent = target.classList.contains('inline-target') ? 'Drop' : 'Drop here';
            zone.appendChild(placeholder);
        }
    }

    restoreItemToPool(qIdx, itemId, text);
    if (userMappings[qIdx]) {
        delete userMappings[qIdx][targetId];
    }

    updateProgress();
    saveDragDropAnswer(qIdx);
}

function saveDragDropAnswer(qIdx) {
    if (!userMappings[qIdx]) return;

    var mappings = userMappings[qIdx];
    var formattedMappings = {};

    for (var tId in mappings) {
        formattedMappings['target_' + tId] = 'item_' + mappings[tId];
    }

    var answer = JSON.stringify(formattedMappings);

    // Save using existing saveAnswer function
    if (typeof saveAnswer === 'function') {
        saveAnswer(qIdx, answer);
    }
}

function getDragDropAnswers() {
    return userMappings;
}

// Initialize drag-drop questions when DOM is ready - already handled in main DOMContentLoaded listener

/* --- REARRANGE QUESTION FUNCTIONALITY --- */
function initializeRearrangeQuestions() {
    const rearrangeQuestions = document.querySelectorAll('.rearrange-question');

    rearrangeQuestions.forEach(function(questionContainer, idx) {
        const card = questionContainer.closest('.question-card');
        if (!card) return;

        const questionIndex = card.getAttribute('data-qindex');

        const itemsJson = questionContainer.getAttribute('data-items-json');
        let itemsData = [];

        try {
            if (itemsJson && itemsJson !== 'null' && itemsJson !== 'undefined') {
                itemsData = JSON.parse(itemsJson);
            }
        } catch (e) {
            console.log('Error parsing rearrange JSON for question ' + (parseInt(questionIndex) + 1));
            itemsData = [];
        }

        // Render the rearrange interface
        renderRearrangeInterface(questionIndex, questionContainer, itemsData);
    });
}

function renderRearrangeInterface(qIdx, container, items) {
    // Normalize items
    const normalizedItems = [];
    for (let i = 0; i < items.length; i++) {
        if (typeof items[i] === 'string') {
            normalizedItems.push({ id: 'item_' + i, text: items[i], correctPosition: i + 1 });
        } else {
            normalizedItems.push(items[i]);
        }
    }

    // Create the rearrange container
    const rearrangeContainer = document.createElement('div');
    rearrangeContainer.className = 'rearrange-container';

    // Create the items list that can be reordered
    const itemsList = document.createElement('div');
    itemsList.className = 'rearrange-items-list';
    itemsList.id = 'rearrangeItemsList_' + qIdx;

    // Shuffle items for student to rearrange
    const shuffledItems = [...normalizedItems];

    // Fisher-Yates shuffle algorithm with a check to ensure it's not in the correct order
    let isCorrectOrder = true;
    let attempts = 0;

    while (isCorrectOrder && attempts < 10) {
        for (let i = shuffledItems.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [shuffledItems[i], shuffledItems[j]] = [shuffledItems[j], shuffledItems[i]];
        }

        // Check if current order matches the original normalized order
        if (shuffledItems.length <= 1) {
            isCorrectOrder = false;
        } else {
            isCorrectOrder = shuffledItems.every((item, index) => item.id === normalizedItems[index].id);
        }
        attempts++;
    }

    // Add shuffled items to the list
    shuffledItems.forEach((item, index) => {
        const itemElement = createRearrangeItemElement(qIdx, item.id, item.text, index);
        itemsList.appendChild(itemElement);
    });

    rearrangeContainer.appendChild(itemsList);
    container.appendChild(rearrangeContainer);

    // Make the list sortable
    makeSortable(itemsList, qIdx);
}

function createRearrangeItemElement(qIdx, itemId, text, position) {
    const element = document.createElement('div');
    element.className = 'rearrange-item';
    element.draggable = true;
    element.id = 'q' + qIdx + '_rearrange_' + itemId;
    element.setAttribute('data-item-id', itemId);
    element.setAttribute('data-text', text);

    element.innerHTML = '<i class="fas fa-grip-vertical drag-handle"></i>' +
        '<span class="item-position">' + (position + 1) + '</span>' +
        '<span class="item-text">' + text + '</span>';

    // Add drag events
    element.addEventListener('dragstart', handleRearrangeDragStart);
    element.addEventListener('dragend', handleRearrangeDragEnd);
    element.addEventListener('dragover', handleRearrangeDragOver);
    element.addEventListener('dragenter', handleRearrangeDragEnter);
    element.addEventListener('dragleave', handleRearrangeDragLeave);
    element.addEventListener('drop', handleRearrangeDrop);

    return element;
}

// Rearrange drag handlers
function handleRearrangeDragStart(e) {
    e.target.classList.add('dragging');
    e.dataTransfer.setData('text/plain', e.target.id);
    e.dataTransfer.effectAllowed = 'move';
}

function handleRearrangeDragEnd(e) {
    e.target.classList.remove('dragging');

    // Update positions after drag ends
    const list = e.target.parentElement;
    const qIdx = list.id.replace('rearrangeItemsList_', '');
    updateRearrangePositions(list, qIdx);
    saveRearrangeAnswer(qIdx);
}

function handleRearrangeDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
}

function handleRearrangeDragEnter(e) {
    e.preventDefault();
    e.target.classList.add('drag-over');
}

function handleRearrangeDragLeave(e) {
    e.target.classList.remove('drag-over');
}

function handleRearrangeDrop(e) {
    e.preventDefault();
    e.target.classList.remove('drag-over');

    const draggedId = e.dataTransfer.getData('text/plain');
    const draggedElement = document.getElementById(draggedId);
    const targetElement = e.target.closest('.rearrange-item');

    if (draggedElement && targetElement && draggedElement !== targetElement) {
        // Determine drop position
        const rect = targetElement.getBoundingClientRect();
        const next = (e.clientY - rect.top) / (rect.bottom - rect.top) > 0.5 ? targetElement.nextSibling : targetElement;

        const list = targetElement.parentElement;
        list.insertBefore(draggedElement, next);

        // Update positions
        updateRearrangePositions(list, list.id.replace('rearrangeItemsList_', ''));

        // Save answer
        saveRearrangeAnswer(list.id.replace('rearrangeItemsList_', ''));
    }
}

function makeSortable(list, qIdx) {
    let draggedItem = null;

    list.addEventListener('dragstart', function(e) {
        draggedItem = e.target;
        if (draggedItem.classList.contains('rearrange-item')) {
            draggedItem.classList.add('dragging');
            e.dataTransfer.setData('text/plain', draggedItem.id);
            e.dataTransfer.effectAllowed = 'move';
        }
    });

    list.addEventListener('dragend', function() {
        if (draggedItem) {
            draggedItem.classList.remove('dragging');
            draggedItem = null;

            // Update positions after drag completes
            updateRearrangePositions(list, qIdx);
            saveRearrangeAnswer(qIdx);
        }
    });

    list.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';

        if (draggedItem && draggedItem.classList.contains('rearrange-item')) {
            const afterElement = getDragAfterElement(list, e.clientY);
            const currentSibling = draggedItem.nextSibling;

            if (currentSibling !== afterElement) {
                list.insertBefore(draggedItem, afterElement);
            }
        }
    });
}

function getDragAfterElement(container, y) {
    const draggableElements = [...container.querySelectorAll('.rearrange-item:not(.dragging)')];

    return draggableElements.reduce((closest, child) => {
        const box = child.getBoundingClientRect();
        const offset = y - box.top - box.height / 2;

        if (offset < 0 && offset > closest.offset) {
            return { offset: offset, element: child };
        } else {
            return closest;
        }
    }, { offset: Number.NEGATIVE_INFINITY }).element;
}

function updateRearrangePositions(list, qIdx) {
    const items = list.querySelectorAll('.rearrange-item');
    items.forEach((item, index) => {
        const positionSpan = item.querySelector('.item-position');
        if (positionSpan) {
            positionSpan.textContent = index + 1;
        }
    });
}

function saveRearrangeAnswer(qIdx) {
    const list = document.getElementById('rearrangeItemsList_' + qIdx);
    if (!list) return;

    const items = list.querySelectorAll('.rearrange-item');
    const orderedItemIds = [];

    items.forEach(item => {
        const itemId = item.getAttribute('data-item-id');
        if (itemId) {
            orderedItemIds.push(itemId.replace('item_', '')); // Extract numeric ID
        }
    });

    // Convert to integer IDs
    const orderedIds = orderedItemIds.map(id => parseInt(id));

    const answer = JSON.stringify(orderedIds);

    // Save using existing saveAnswer function
    if (typeof saveAnswer === 'function') {
        saveAnswer(qIdx, answer);
    }
}

function getRearrangeAnswers() {
    const rearrangeQuestions = document.querySelectorAll('.rearrange-question');
    const answers = {};

    rearrangeQuestions.forEach(function(questionContainer) {
        const card = questionContainer.closest('.question-card');
        if (!card) return;

        const qIdx = card.getAttribute('data-qindex');
        const list = document.getElementById('rearrangeItemsList_' + qIdx);

        if (list) {
            const items = list.querySelectorAll('.rearrange-item');
            const orderedItemIds = [];

            items.forEach(item => {
                const itemId = item.getAttribute('data-item-id');
                if (itemId) {
                    orderedItemIds.push(parseInt(itemId.replace('item_', '')));
                }
            });

            answers[qIdx] = orderedItemIds;
        }
    });

    return answers;
}

// Modify the submitExam function to handle rearrange answers
function submitExam() {

    // Save all multi-select answers
    document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
        var card = box.closest('.question-card');
        if (!card) return;
        var qindex = card.getAttribute('data-qindex');
        if (qindex) updateHiddenForMulti(qindex);
    });

    // Handle Drag and Drop answers
    const dragDropAnswers = getDragDropAnswers();
    Object.keys(dragDropAnswers).forEach(qindex => {
        const mappings = dragDropAnswers[qindex];
        const formattedMappings = {};
        for (let tId in mappings) {
            formattedMappings['target_' + tId] = 'item_' + mappings[tId];
        }
        const ansValue = JSON.stringify(formattedMappings);

        let hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
        if (!hiddenAns) {
            hiddenAns = document.createElement('input');
            hiddenAns.type = 'hidden';
            hiddenAns.name = 'ans' + qindex;
            document.getElementById('myform').appendChild(hiddenAns);
        }
        hiddenAns.value = ansValue;
    });

    // Handle Rearrange answers
    const rearrangeAnswers = getRearrangeAnswers();
    Object.keys(rearrangeAnswers).forEach(qindex => {
        const orderedIds = rearrangeAnswers[qindex];
        const ansValue = JSON.stringify(orderedIds);

        let hiddenAns = document.querySelector('input[name="ans' + qindex + '"]');
        if (!hiddenAns) {
            hiddenAns = document.createElement('input');
            hiddenAns.type = 'hidden';
            hiddenAns.name = 'ans' + qindex;
            document.getElementById('myform').appendChild(hiddenAns);
        }
        hiddenAns.value = ansValue;
    });

    var answeredQuestions = 0;
    document.querySelectorAll('.question-card').forEach(function(card){
        const isDragDrop = card.querySelector('.drag-drop-question') !== null;
        const isRearrange = card.querySelector('.rearrange-question') !== null;

        if (isDragDrop) {
            if (card.querySelectorAll('.dropped-item').length > 0) {
                answeredQuestions++;
            }
        } else if (isRearrange) {
            // For rearrange, consider answered if there are items in the list
            const list = card.querySelector('.rearrange-items-list');
            if (list && list.querySelectorAll('.rearrange-item').length > 0) {
                answeredQuestions++;
            }
        } else {
            var box = card.querySelector('.answers');
            if(!box) return;
            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
            if(maxSel === 1) {
                if(box.querySelector('input.single:checked')) answeredQuestions++;
            } else {
                if(box.querySelectorAll('input.multi:checked').length >= 1) answeredQuestions++;
            }
        }
    });

    // Check for unanswered questions
    if(answeredQuestions < totalQuestions) {
        var unanswered = totalQuestions - answeredQuestions;
        showSystemConfirmModal(
            "You have " + unanswered + " unanswered question" + (unanswered > 1 ? "s" : "") + ". Submit anyway?",
            function(proceed) {
                if (!proceed) return;
                showConfirmSubmitModal();
            }
        );
        return;
    }

    // Final confirmation - show modal
    showConfirmSubmitModal();
}

// Modify the updateProgress function to handle rearrange questions
function updateProgress() {

    var cards = document.querySelectorAll('.question-card');
    var answered = 0;

    cards.forEach(function(card){
        var box = card.querySelector('.answers');
        if(!box) return;

        const qindex = card.getAttribute('data-qindex');
        const isDragDrop = card.querySelector('.drag-drop-question') !== null;
        const isRearrange = card.querySelector('.rearrange-question') !== null;

        if (isDragDrop) {
            // Question is answered if at least one target has an item
            if (card.querySelectorAll('.dropped-item').length > 0) {
                answered++;
            }
        } else if (isRearrange) {
            // For rearrange questions, check if items exist in the list
            const list = card.querySelector('.rearrange-items-list');
            if (list && list.querySelectorAll('.rearrange-item').length > 0) {
                answered++;
            }
        } else {
            var maxSel = parseInt(box.getAttribute('data-max-select') || '1', 10);
            if(maxSel === 1){
                if(box.querySelector('input.single:checked')) answered++;
            } else {
                if(box.querySelectorAll('input.multi:checked').length >= 1) answered++;
            }
        }
    });

    // Update progress bars and labels with the correct count
    var total = cards.length;
    var pct = total ? Math.round((answered / total) * 100) : 0;

    // Update progress bars
    var progressBar = document.getElementById('progressBar');
    var progressBarHeader = document.getElementById('progressBarHeader');
    var modalProgressBar = document.getElementById('modalProgressBar');
    if(progressBar) progressBar.style.width = pct + '%';
    if(progressBarHeader) progressBarHeader.style.width = pct + '%';
    if(modalProgressBar) modalProgressBar.style.width = pct + '%';

    // Update labels
    var progressLabel = document.getElementById('progressLabel');
    var examProgressPctHeader = document.getElementById('examProgressPctHeader');
    var progressPercent = document.querySelector('.progress-percent');
    if(progressLabel) progressLabel.textContent = pct + '%';
    if(examProgressPctHeader) examProgressPctHeader.textContent = pct + '%';
    if(progressPercent) progressPercent.textContent = pct + '%';

    // Update counters
    var submitAnswered = document.getElementById('submitAnswered');
    var submitUnanswered = document.getElementById('submitUnanswered');
    var floatCounter = document.getElementById('floatCounter');
    var modalAnswered = document.getElementById('modalAnswered');
    var modalUnanswered = document.getElementById('modalUnanswered');
    var modalProgressText = document.getElementById('modalProgressText');

    if(submitAnswered) submitAnswered.textContent = answered;
    if(submitUnanswered) submitUnanswered.textContent = total - answered;
    if(floatCounter) floatCounter.textContent = answered + '/' + total;
    if(modalAnswered) modalAnswered.textContent = answered;
    if(modalUnanswered) modalUnanswered.textContent = total - answered;
    if(modalProgressText) modalProgressText.textContent = answered + ' / ' + total;

    // Update circular progress
    var circumference = 2 * Math.PI * 34;
    var offset = circumference - (pct / 100) * circumference;
    var progressRing = document.querySelector('.progress-ring-progress');
    if(progressRing) progressRing.style.strokeDashoffset = offset;
}

// Initialize rearrange questions when DOM is ready - already handled in main DOMContentLoaded listener
