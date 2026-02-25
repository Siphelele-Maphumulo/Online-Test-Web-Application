/* ============================================
   PROFESSIONAL PROCTORING SYSTEM v6.0
   ULTRA-STRICT MODE - ZERO TOLERANCE
   REAL-TIME WARNINGS & IMMEDIATE ENFORCEMENT
   ============================================ */

class ProctoringSystem {
    constructor(examId, studentId) {
        this.examActive = true;
        this.violations = [];
        this.warningCount = 0;
        this.MAX_WARNINGS = 8; // Increased from 3 - more attempts before termination
        this.cameraActive = false;
        this.lastFrameProcessed = Date.now();
        this.frameCheckInterval = null;
        this.terminated = false; // Add flag to prevent multiple terminations
        
        // ULTRA STRICT Detection thresholds - MINIMAL DELAYS
        this.NOISE_THRESHOLD = 35; // Stricter (was 45)
        this.EYE_OFF_SCREEN_THRESHOLD = 800; // 0.8 seconds (was 2000)
        this.FACE_LOST_THRESHOLD = 500; // 0.5 seconds grace (was 1500)
        this.HEAD_MOVEMENT_THRESHOLD = 0.15; // Stricter (was 0.25)
        this.HEAD_MOVEMENT_DURATION = 1000; // 1 second (was 3000)
        this.MOUTH_MOVEMENT_THRESHOLD = 1.0;
        this.LOOKING_DOWN_ANGLE = -5; // Stricter (was -10)
        this.MULTIPLE_FACES_THRESHOLD = 1; // Zero tolerance
        
        // Immediate violation thresholds
        this.IMMEDIATE_VIOLATIONS = {
            'MULTIPLE_FACES': true,      // Instant termination
            'TAB_HIDDEN': true,           // Instant termination
            'WINDOW_BLUR': 500,            // 0.5 sec then warning
            'DEV_TOOLS': true,              // Instant termination
            'COPY_PASTE': true               // Instant violation
        };
        
        // State tracking with ultra-precise timing
        this.lastEyeContact = Date.now();
        this.lastFaceDetected = Date.now();
        this.faceLostStartTime = null;
        this.windowBlurStartTime = null;
        this.headMovementStartTime = null;
        this.gazeAwayStartTime = null;
        this.speechStartTime = null;
        this.countdownOverlay = null;
        this.countdownInterval = null;
        this.backgroundNoiseBaseline = 40;
        this.calibrationComplete = false;
        this.previousNosePosition = null;
        this.previousMouthHeight = null;
        
        // Violation logging - NO COOLDOWN for critical violations
        this.lastViolationLog = {};
        this.VIOLATION_COOLDOWN = 1000; // Reduced from 5000ms
        this.CRITICAL_VIOLATION_TYPES = ['CRITICAL', 'SECURITY', 'MULTIPLE_FACES'];
        
        // Media streams
        this.audioStream = null;
        this.videoStream = null;
        this.faceapi = null;
        this.detectionInterval = null;
        this.audioMonitor = null;
        this.heartbeatInterval = null;
        this.cameraHealthInterval = null;
        
        // Exam identifiers
        this.examId = examId;
        this.studentId = studentId;
        this.sessionId = this.generateSessionId();
        
        // Countdown state - FASTER termination
        this.countdownActive = false;
        this.countdownValue = 10; // Reduced from 5 seconds
        this.GRACE_PERIOD = 500; // 0.5 seconds grace (was 1500)
        this.COUNTDOWN_DURATION = 7000; // 3 seconds total countdown (was 5000)
        this.TOTAL_TERMINATION_TIME = this.GRACE_PERIOD + this.COUNTDOWN_DURATION; // 3.5 seconds total
        this.terminationReason = null;
        
        // Camera reconnection attempts
        this.cameraReconnectAttempts = 0;
        this.MAX_RECONNECT_ATTEMPTS = 10; // Reduced from 3
    }

    generateSessionId() {
        return 'PROCTOR-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
    }

    async initialize(stream) {
        console.log('🔒 ULTRA-STRICT PROCTORING - REAL-TIME ENFORCEMENT ACTIVE');
        
        try {
            // Show proctoring status
            this.showProfessionalProctorBar();
            
            // CRITICAL: Ensure camera is active
            if (!stream) {
                console.log('📹 Requesting camera access...');
                stream = await this.forceCameraActivation();
            }
            
            if (!stream || !stream.active) {
                throw new Error('Camera stream is not active');
            }
            
            this.videoStream = stream;
            
            // Verify camera tracks
            const videoTracks = stream.getVideoTracks();
            if (videoTracks.length === 0) {
                throw new Error('No video tracks in stream');
            }
            
            console.log(`📹 Camera active: ${videoTracks[0].label}`);
            
            // Load face detection FAST
            await this.loadFaceApi();
            
            // Initialize video monitoring FIRST with HIGHEST priority
            await this.initVideoMonitoring(stream);
            
            // Start immediate monitoring
            this.startFastMonitoring();
            
            // Initialize other systems
            await this.initAudioMonitoring(stream);
            this.initEnvironmentLockdown();
            this.initBehavioralMonitoring();
            this.initSecurityMeasures();
            
            // Force immediate face detection
            this.runFaceDetection();
            
            // Log start
            this.logToServer('INFO', 'Ultra-strict proctoring activated');
            
            return true;
            
        } catch (err) {
            console.error('❌ Proctoring activation failed:', err);
            this.showProfessionalError('Camera access required');
            throw err;
        }
    }

    startFastMonitoring() {
        // Run detection EVERY 100ms for near real-time response
        if (this.detectionInterval) {
            clearInterval(this.detectionInterval);
        }
        this.detectionInterval = setInterval(() => this.runFaceDetection(), 100);
        
        // Force camera check every 500ms
        if (this.cameraHealthInterval) {
            clearInterval(this.cameraHealthInterval);
        }
        this.cameraHealthInterval = setInterval(() => this.checkCameraHealth(), 500);
        
        console.log('✅ Fast monitoring active - 100ms detection intervals');
    }

    async forceCameraActivation() {
        // Try multiple constraints
        const constraints = [
            {
                video: {
                    width: { ideal: 640 },
                    height: { ideal: 480 },
                    frameRate: { ideal: 30 }
                },
                audio: true
            },
            {
                video: true,
                audio: true
            }
        ];
        
        for (const constraint of constraints) {
            try {
                const stream = await navigator.mediaDevices.getUserMedia(constraint);
                stream.getVideoTracks().forEach(track => track.enabled = true);
                return stream;
            } catch (err) {
                console.log('Camera constraint failed:', err);
            }
        }
        
        throw new Error('Could not activate camera');
    }

    showProfessionalProctorBar() {
        const existing = document.getElementById('proctor-professional-bar');
        if (existing) existing.remove();
        
        const bar = document.createElement('div');
        bar.id = 'proctor-professional-bar';
        bar.style.cssText = 
            'position: fixed; top: 0; left: 0; width: 100%; background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); ' +
            'color: white; padding: 8px 20px; font-size: 13px; z-index: 99999; ' +
            'display: flex; align-items: center; justify-content: space-between; ' +
            'box-shadow: 0 4px 15px rgba(0,0,0,0.3); border-bottom: 2px solid #ef4444;'; // Red border for strict mode
        
        bar.innerHTML = `
            <div style="display: flex; align-items: center; gap: 20px;">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="camera-indicator" style="width: 12px; height: 12px; background: #10b981; border-radius: 50%; animation: proctorPulse 0.5s infinite;"></span>
                    <span style="font-weight: 600; color: #ef4444;">STRICT PROCTOR</span>
                </div>
                <div style="display: flex; gap: 20px;">
                    <span>📹 Camera: <span id="proctor-camera-status" style="color: #10b981;">ACTIVE</span></span>
                    <span>🎤 Audio: <span id="proctor-audio-status" style="color: #10b981;">ACTIVE</span></span>
                    <span>👤 Face: <span id="proctor-face-status" style="color: #f97316;">SCANNING</span></span>
                </div>
            </div>
            <div style="display: flex; align-items: center; gap: 15px;">
                <span style="background: #ef4444; padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: bold;">
                    WARNINGS: <span id="proctor-warning-count">0</span>/5
                </span>
                <span style="color: #94a3b8;" id="proctor-timestamp">${new Date().toLocaleTimeString()}</span>
            </div>
        `;
        
        document.body.appendChild(bar);
        
        const style = document.createElement('style');
        style.textContent = `
            @keyframes proctorPulse {
                0% { opacity: 1; transform: scale(1); }
                50% { opacity: 0.5; transform: scale(1.3); }
                100% { opacity: 1; transform: scale(1); }
            }
            .proctor-flash {
                animation: proctorFlash 0.1s ease-out;
            }
            @keyframes proctorFlash {
                0% { background-color: #ef4444; }
                100% { background-color: transparent; }
            }
            @keyframes warningFlash {
                0% { opacity: 1; background: #ef4444; }
                50% { opacity: 0.8; background: #dc2626; }
                100% { opacity: 1; background: #ef4444; }
            }
            @keyframes countdownPulse {
                0% { opacity: 1; }
                50% { opacity: 0.9; background: rgba(220, 38, 38, 0.98); }
                100% { opacity: 1; }
            }
        `;
        document.head.appendChild(style);
        
        document.body.style.marginTop = '45px';
    }

    async loadFaceApi() {
        if (window.faceapi) {
            this.faceapi = window.faceapi;
            return;
        }

        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js';
            script.onload = async () => {
                this.faceapi = faceapi;
                try {
                    // Load only essential models for speed
                    await faceapi.nets.tinyFaceDetector.load('/models');
                    await faceapi.nets.faceLandmark68Net.load('/models');
                    console.log('✅ Face API loaded');
                    resolve();
                } catch (err) {
                    reject(err);
                }
            };
            script.onerror = reject;
            document.head.appendChild(script);
        });
    }

    async initVideoMonitoring(stream) {
        const video = document.createElement('video');
        video.id = 'proctor-video-feed';
        video.style.display = 'none';
        video.srcObject = stream;
        video.autoplay = true;
        video.muted = true;
        video.playsInline = true;
        
        document.body.appendChild(video);
        
        await new Promise((resolve, reject) => {
            const timeout = setTimeout(() => reject(new Error('Video timeout')), 5000);
            
            video.onloadeddata = () => {
                clearTimeout(timeout);
                resolve();
            };
            
            video.onerror = reject;
            video.play().catch(reject);
        });
        
        this.videoElement = video;
        console.log('✅ Video monitoring ready');
    }

    async runFaceDetection() {
        if (!this.examActive) return;
        if (!this.videoElement || !this.videoElement.videoWidth) return;
        
        try {
            this.lastFrameProcessed = Date.now();
            
            const detections = await this.faceapi
                .detectAllFaces(this.videoElement, new this.faceapi.TinyFaceDetectorOptions({
                    inputSize: 320, // Smaller = faster detection
                    scoreThreshold: 0.3 // Lower threshold for faster detection
                }))
                .withFaceLandmarks();
            
            this.processUltraStrictDetections(detections);
            
            // Update UI
            const cameraStatus = document.getElementById('proctor-camera-status');
            if (cameraStatus) cameraStatus.style.color = '#10b981';
            
            const faceStatus = document.getElementById('proctor-face-status');
            if (faceStatus) {
                faceStatus.textContent = detections.length > 0 ? 'DETECTED' : 'LOST';
                faceStatus.style.color = detections.length > 0 ? '#10b981' : '#ef4444';
            }
            
        } catch (err) {
            console.error('Detection error:', err);
        }
    }

    processUltraStrictDetections(detections) {
        // IMMEDIATE TERMINATION: Multiple faces
        if (detections.length > this.MULTIPLE_FACES_THRESHOLD) {
            this.logViolation('CRITICAL', `Multiple faces detected (${detections.length})`);
            this.autoSubmitForCheating('Multiple individuals detected - Exam terminated');
            return;
        }
        
        // Face lost handling - FAST response
        if (detections.length === 0) {
            if (!this.faceLostStartTime) {
                this.faceLostStartTime = Date.now();
                console.log('Face lost - starting fast countdown');
            }
            
            const timeLost = Date.now() - this.faceLostStartTime;
            
            // Immediate warning flash for any face loss
            if (timeLost > 100) {
                document.body.classList.add('proctor-flash');
                setTimeout(() => document.body.classList.remove('proctor-flash'), 100);
            }
            
            this.handleUltraFastCountdown(timeLost, 'FACE NOT VISIBLE');
            return;
        }
        
        // Face detected - reset
        if (this.faceLostStartTime) {
            const lostDuration = Date.now() - this.faceLostStartTime;
            if (lostDuration > 100) {
                console.log(`Face returned after ${lostDuration}ms`);
            }
        }
        this.faceLostStartTime = null;
        this.hideProfessionalCountdown();
        
        const face = detections[0];
        
        // Check gaze - STRICT
        const gazeDirection = this.analyzeGazeDirection(face.landmarks);
        if (gazeDirection === 'AWAY' || gazeDirection === 'DOWN') {
            if (!this.gazeAwayStartTime) {
                this.gazeAwayStartTime = Date.now();
            }
            
            const gazeTime = Date.now() - this.gazeAwayStartTime;
            
            // Warning after just 0.5 seconds of looking away
            if (gazeTime > 500) {
                this.logViolation('VISUAL', 'Looking away from screen');
            }
        } else {
            this.gazeAwayStartTime = null;
        }
        
        // Check head movement - STRICT
        const headMovement = this.detectHeadMovement(face.landmarks);
        if (headMovement > this.HEAD_MOVEMENT_THRESHOLD) {
            if (!this.headMovementStartTime) {
                this.headMovementStartTime = Date.now();
            }
            
            const movementTime = Date.now() - this.headMovementStartTime;
            
            // Warning after just 0.5 seconds of head movement
            if (movementTime > 500) {
                this.logViolation('VISUAL', 'Excessive head movement');
            }
        } else {
            this.headMovementStartTime = null;
        }
    }

    analyzeGazeDirection(landmarks) {
        const leftEye = landmarks.getLeftEye();
        const rightEye = landmarks.getRightEye();
        const nose = landmarks.getNose();
        
        if (!leftEye.length || !rightEye.length || !nose.length) return 'UNKNOWN';
        
        const eyeCenterX = (leftEye[0].x + rightEye[3].x) / 2;
        const noseX = nose[0].x;
        
        // Stricter gaze detection
        const offset = Math.abs(eyeCenterX - noseX) / 100;
        if (offset > 0.3) return 'AWAY'; // Reduced from 0.5
        
        const eyeY = (leftEye[0].y + rightEye[3].y) / 2;
        const noseY = nose[0].y;
        
        // Stricter looking down detection
        if (eyeY > noseY + 10) return 'DOWN'; // Reduced from 20
        
        return 'CENTER';
    }

    detectHeadMovement(landmarks) {
        const nose = landmarks.getNose();
        if (!nose || nose.length === 0) return 0;
        
        if (!this.previousNosePosition) {
            this.previousNosePosition = { x: nose[0].x, y: nose[0].y };
            return 0;
        }
        
        const movement = Math.hypot(
            nose[0].x - this.previousNosePosition.x,
            nose[0].y - this.previousNosePosition.y
        ) / 30; // More sensitive (was /50)
        
        this.previousNosePosition = { x: nose[0].x, y: nose[0].y };
        return movement;
    }

    handleUltraFastCountdown(timeLost, reason) {
        // Ultra short grace period - 500ms
        if (timeLost < 500) {
            return;
        }
        
        // Calculate remaining seconds (3 second countdown)
        const elapsedCountdown = Math.floor((timeLost - 500) / 1000);
        const remaining = Math.max(0, 5 - elapsedCountdown);
        
        if (remaining > 0 && !this.countdownActive) {
            this.countdownActive = true;
            this.showUltraFastCountdown(remaining, reason);
        } else if (remaining > 0 && this.countdownActive) {
            if (remaining !== this.countdownValue) {
                this.countdownValue = remaining;
                this.updateUltraFastCountdown(remaining);
            }
        }
        
        // Terminate after 3.5 seconds total
        if (timeLost >= 3500) {
            this.autoSubmitForCheating(reason);
        }
    }

    showUltraFastCountdown(seconds, reason) {
        if (this.countdownOverlay) {
            this.countdownOverlay.remove();
        }
        
        this.countdownOverlay = document.createElement('div');
        this.countdownOverlay.id = 'proctor-countdown-overlay';
        this.countdownOverlay.style.cssText = 
            'position: fixed; top: 0; left: 0; width: 100%; height: 100%; ' +
            'background: rgba(239, 68, 68, 0.95); color: white; z-index: 100000; ' +
            'display: flex; flex-direction: column; align-items: center; justify-content: center; ' +
            'text-align: center; font-family: "Inter", sans-serif; ' +
            'animation: countdownPulse 0.5s infinite;';
        
        this.countdownOverlay.innerHTML = `
            <div style="font-size: 48px; font-weight: 800; margin-bottom: 20px;">⚠️ STRICT VIOLATION</div>
            <div style="font-size: 24px; margin-bottom: 30px;">${reason}</div>
            <div style="font-size: 180px; font-weight: 900; line-height: 1;">${seconds}</div>
            <div style="font-size: 18px; margin-top: 20px;">Return immediately or exam terminates</div>
            <div style="margin-top: 40px; font-size: 14px; opacity: 0.8;">Warning ${this.warningCount + 1}/3</div>
        `;
        
        document.body.appendChild(this.countdownOverlay);
        this.playCountdownBeep();
    }

    updateUltraFastCountdown(seconds) {
        const overlay = document.getElementById('proctor-countdown-overlay');
        if (!overlay) return;
        
        const numberDiv = overlay.querySelector('div[style*="font-size: 180px"]');
        if (numberDiv) {
            numberDiv.textContent = seconds;
        }
        
        this.playCountdownBeep();
    }

    playCountdownBeep() {
        try {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioContext.createOscillator();
            const gainNode = audioContext.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(audioContext.destination);
            
            oscillator.frequency.value = 880;
            gainNode.gain.value = 0.2;
            
            oscillator.start();
            oscillator.stop(audioContext.currentTime + 0.1);
        } catch (err) {}
    }

    hideProfessionalCountdown() {
        if (this.countdownActive) {
            this.countdownActive = false;
            const overlay = document.getElementById('proctor-countdown-overlay');
            if (overlay) overlay.remove();
        }
    }

    checkCameraHealth() {
        if (!this.examActive) return;
        
        const now = Date.now();
        const timeSinceLastFrame = now - this.lastFrameProcessed;
        
        // If no frames for 1 second, camera issue
        if (timeSinceLastFrame > 1000) {
            console.warn('Camera stall detected');
            
            const cameraStatus = document.getElementById('proctor-camera-status');
            if (cameraStatus) {
                cameraStatus.style.color = '#ef4444';
                cameraStatus.textContent = 'STALLED';
            }
            
            this.attemptCameraRecovery();
        }
    }

    async attemptCameraRecovery() {
        if (this.cameraReconnectAttempts >= this.MAX_RECONNECT_ATTEMPTS) {
            this.autoSubmitForCheating('Camera connection lost');
            return;
        }
        
        this.cameraReconnectAttempts++;
        
        try {
            if (this.videoStream) {
                this.videoStream.getTracks().forEach(t => t.stop());
            }
            
            const newStream = await this.forceCameraActivation();
            
            if (this.videoElement) {
                this.videoElement.srcObject = newStream;
                await this.videoElement.play();
            }
            
            this.videoStream = newStream;
            this.lastFrameProcessed = Date.now();
            this.cameraReconnectAttempts = 0;
            
        } catch (err) {
            console.error('Camera recovery failed:', err);
        }
    }

    async initAudioMonitoring(stream) {
        try {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const source = audioContext.createMediaStreamSource(stream);
            const analyser = audioContext.createAnalyser();
            
            analyser.fftSize = 1024; // Smaller for faster processing
            source.connect(analyser);
            
            const dataArray = new Uint8Array(analyser.frequencyBinCount);
            
            // Quick calibration
            setTimeout(() => this.calibrateNoise(analyser), 1000);
            
            this.audioMonitor = setInterval(() => {
                if (!this.examActive) return;
                
                analyser.getByteFrequencyData(dataArray);
                this.analyzeUltraStrictAudio(dataArray);
                
            }, 150); // Faster audio analysis
        } catch (err) {}
    }

    calibrateNoise(analyser) {
        const dataArray = new Uint8Array(analyser.frequencyBinCount);
        let samples = [];
        
        for (let i = 0; i < 10; i++) {
            analyser.getByteFrequencyData(dataArray);
            const avg = dataArray.reduce((a, b) => a + b, 0) / dataArray.length;
            samples.push(avg);
        }
        
        samples.sort((a, b) => a - b);
        this.backgroundNoiseBaseline = samples[5];
        this.calibrationComplete = true;
    }

    analyzeUltraStrictAudio(dataArray) {
        if (!this.calibrationComplete) return;
        
        const average = dataArray.reduce((a, b) => a + b, 0) / dataArray.length;
        
        // Stricter noise detection
        if (average > this.backgroundNoiseBaseline + 30) {
            this.logViolation('AUDIO', 'Background noise detected');
        }
        
        // Quick speech detection
        const variance = this.calculateVariance(dataArray);
        if (variance > 150) {
            if (!this.speechStartTime) {
                this.speechStartTime = Date.now();
            }
            
            const speechTime = Date.now() - this.speechStartTime;
            if (speechTime > 500) { // 0.5 seconds of speech
                this.logViolation('AUDIO', 'Sustained speech detected');
            }
        } else {
            this.speechStartTime = null;
        }
    }

    calculateVariance(dataArray) {
        const mean = dataArray.reduce((a, b) => a + b, 0) / dataArray.length;
        return dataArray.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / dataArray.length;
    }

    initEnvironmentLockdown() {
        // Tab visibility - ZERO TOLERANCE
        document.addEventListener('visibilitychange', () => {
            if (!this.examActive) return;
            
            if (document.hidden) {
                this.logViolation('CRITICAL', 'Tab hidden - cheating attempt');
                this.autoSubmitForCheating('Tab hidden during exam');
            }
        });
        
        // Window blur - FAST response
        window.addEventListener('blur', () => {
            if (!this.examActive) return;
            
            if (!this.windowBlurStartTime) {
                this.windowBlurStartTime = Date.now();
            }
            
            const blurTime = Date.now() - this.windowBlurStartTime;
            
            // Warning after 0.5 seconds
            if (blurTime > 500 && blurTime < 2000) {
                this.logViolation('SECURITY', 'Window focus lost');
                this.handleUltraFastCountdown(blurTime, 'WINDOW FOCUS LOST');
            }
            
            // Terminate after 2 seconds
            if (blurTime >= 2000) {
                this.autoSubmitForCheating('Window focus lost for 2+ seconds');
            }
        });
        
        window.addEventListener('focus', () => {
            this.windowBlurStartTime = null;
            this.hideProfessionalCountdown();
        });
        
        // Fullscreen enforcement
        this.enforceFullScreen();
        
        // Block all copy/paste
        document.addEventListener('copy', (e) => {
            e.preventDefault();
            this.logViolation('SECURITY', 'Copy attempted');
            return false;
        });
        
        document.addEventListener('paste', (e) => {
            e.preventDefault();
            this.logViolation('SECURITY', 'Paste attempted');
            return false;
        });
        
        document.addEventListener('contextmenu', (e) => {
            e.preventDefault();
            this.logViolation('SECURITY', 'Right-click attempted');
            return false;
        });
        
        // Block all function keys and shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.altKey || e.ctrlKey || e.metaKey || e.key.startsWith('F')) {
                e.preventDefault();
                this.logViolation('SECURITY', `Forbidden key: ${e.key}`);
                return false;
            }
        });
    }

    enforceFullScreen() {
        const enterFullScreen = () => {
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen().catch(() => {});
            }
        };
        
        enterFullScreen();
        
        document.addEventListener('fullscreenchange', () => {
            if (!document.fullscreenElement && this.examActive) {
                this.logViolation('SECURITY', 'Exited fullscreen');
                enterFullScreen();
            }
        });
    }

    initBehavioralMonitoring() {
        let lastMouseMove = Date.now();
        
        document.addEventListener('mousemove', (e) => {
            lastMouseMove = Date.now();
            
            // Screen edge detection
            if (e.clientX <= 5 || e.clientY <= 5 || 
                e.clientX >= window.innerWidth - 5 || 
                e.clientY >= window.innerHeight - 5) {
                this.logViolation('BEHAVIOR', 'Mouse at screen edge');
            }
        });
        
        // Mouse inactivity check
        setInterval(() => {
            if (!this.examActive) return;
            
            if (Date.now() - lastMouseMove > 10000) { // 10 seconds
                this.logViolation('BEHAVIOR', 'Mouse inactive');
            }
        }, 2000);
    }

    initSecurityMeasures() {
        // Dev tools detection
        setInterval(() => {
            if (!this.examActive) return;
            
            const widthThreshold = window.outerWidth - window.innerWidth > 160;
            const heightThreshold = window.outerHeight - window.innerHeight > 160;
            
            if (widthThreshold || heightThreshold) {
                this.logViolation('SECURITY', 'Dev tools detected');
                this.autoSubmitForCheating('Developer tools detected');
            }
        }, 1000);
    }

    logViolation(type, description) {
        if (!this.examActive) return;
        
        // Skip cooldown for critical violations
        if (!this.CRITICAL_VIOLATION_TYPES.includes(type)) {
            const now = Date.now();
            if (this.lastViolationLog[type] && now - this.lastViolationLog[type] < this.VIOLATION_COOLDOWN) {
                return;
            }
            this.lastViolationLog[type] = Date.now();
        }
        
        const violation = {
            timestamp: new Date().toISOString(),
            type: type,
            description: description,
            examId: this.examId,
            studentId: this.studentId,
            sessionId: this.sessionId,
            warningCount: this.warningCount + 1
        };
        
        this.violations.push(violation);
        this.warningCount++;
        
        // Update UI
        const warningEl = document.getElementById('proctor-warning-count');
        if (warningEl) warningEl.textContent = this.warningCount;
        
        // Flash screen
        document.body.classList.add('proctor-flash');
        setTimeout(() => document.body.classList.remove('proctor-flash'), 100);
        
        // Show warning
        this.showUltraFastWarning(violation);
        
        // Capture evidence
        this.captureEvidence(violation);
        
        // Send to server
        this.sendViolationToServer(violation);
        
        // Auto-submit after max warnings
        if (this.warningCount >= this.MAX_WARNINGS) {
            this.autoSubmitForCheating(`Maximum warnings (${this.MAX_WARNINGS}) exceeded`);
        }
    }

    showUltraFastWarning(violation) {
        const toast = document.createElement('div');
        toast.style.cssText = 
            'position: fixed; top: 60px; right: 20px; background: #ef4444; ' +
            'color: white; padding: 12px 20px; border-radius: 6px; z-index: 100001; ' +
            'box-shadow: 0 10px 25px rgba(0,0,0,0.5); font-weight: bold; ' +
            'animation: warningFlash 0.5s infinite;';
        
        toast.innerHTML = `⚠️ ${violation.type}: ${violation.description}`;
        document.body.appendChild(toast);
        
        setTimeout(() => {
            if (toast.parentNode) toast.remove();
        }, 2000);
    }

    async captureEvidence(violation) {
        if (!this.videoElement || !this.videoElement.videoWidth) return;
        
        try {
            const canvas = document.createElement('canvas');
            canvas.width = this.videoElement.videoWidth;
            canvas.height = this.videoElement.videoHeight;
            
            const ctx = canvas.getContext('2d');
            ctx.drawImage(this.videoElement, 0, 0);
            
            ctx.fillStyle = 'rgba(239,68,68,0.7)';
            ctx.fillRect(0, canvas.height - 25, canvas.width, 25);
            ctx.fillStyle = 'white';
            ctx.font = 'bold 12px monospace';
            ctx.fillText(`VIOLATION: ${violation.type} - ${new Date().toISOString()}`, 10, canvas.height - 8);
            
            violation.screenshot = canvas.toDataURL('image/jpeg', 0.7);
        } catch (err) {}
    }

    sendViolationToServer(violation) {
        const formData = new FormData();
        formData.append('page', 'proctoring');
        formData.append('operation', 'log_violation');
        formData.append('violation_data', JSON.stringify(violation));
        
        if (navigator.sendBeacon) {
            navigator.sendBeacon('controller.jsp', formData);
        }
    }

    logToServer(type, message) {
        const violation = {
            timestamp: new Date().toISOString(),
            type: 'INFO',
            description: message,
            examId: this.examId,
            studentId: this.studentId,
            sessionId: this.sessionId
        };
        this.sendViolationToServer(violation);
    }

    showProfessionalError(message) {
        alert(`Proctoring Error: ${message}`);
    }

    autoSubmitForCheating(reason) {
        if (this.terminated) return;
        this.terminated = true;
        this.examActive = false;
        this.hideProfessionalCountdown();
        
        // Show termination message
        alert(`EXAM TERMINATED: ${reason}`);
        
        // Submit the form with cheating flag
        const form = document.getElementById('myform');
        if (form) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'cheating_terminated';
            input.value = 'true';
            form.appendChild(input);
            
            // Add reason
            const reasonInput = document.createElement('input');
            reasonInput.type = 'hidden';
            reasonInput.name = 'termination_reason';
            reasonInput.value = reason;
            form.appendChild(reasonInput);
            
            console.log('🔒 Proctoring: Submitting exam with cheating_terminated=true');
            
            setTimeout(() => {
                form.submit();
            }, 1500);
        }
    }

    stop() {
        this.examActive = false;
        
        const intervals = [
            this.detectionInterval,
            this.audioMonitor,
            this.cameraHealthInterval
        ];
        
        intervals.forEach(interval => {
            if (interval) clearInterval(interval);
        });
        
        if (this.videoStream) {
            this.videoStream.getTracks().forEach(t => t.stop());
        }
        
        if (this.videoElement) {
            this.videoElement.remove();
        }
        
        const elements = ['proctor-professional-bar', 'proctor-countdown-overlay'];
        elements.forEach(id => {
            const el = document.getElementById(id);
            if (el) el.remove();
        });
        
        document.body.style.marginTop = '0';
    }
}

// Auto-initialization when exam starts
document.addEventListener('DOMContentLoaded', function() {
    // Check if we're on an exam page
    const examForm = document.getElementById('myform');
    if (!examForm) return;
    
    // Check if proctor should auto-start
    try {
        const shouldAutoStart = sessionStorage.getItem('proctorAutoStart') === '1';
        if (!shouldAutoStart) return;
        
        // Clear flag
        sessionStorage.removeItem('proctorAutoStart');
        
        // Get exam and student IDs
        const examId = document.querySelector('input[name="examId"]')?.value || '0';
        const studentId = document.querySelector('input[name="studentId"]')?.value || 
                         window.studentId || 
                         document.querySelector('[data-student-id]')?.getAttribute('data-student-id') || 
                         '0';
        
        // Initialize proctoring
        (async function() {
            try {
                // Request camera access
                const stream = await navigator.mediaDevices.getUserMedia({ 
                    video: {
                        width: { ideal: 640 },
                        height: { ideal: 480 },
                        frameRate: { ideal: 30 }
                    }, 
                    audio: true 
                });
                
                // Create and initialize proctor
                const proctor = new ProctoringSystem(examId, studentId);
                window.proctor = proctor;
                await proctor.initialize(stream);
                
                console.log('✅ Proctoring auto-started successfully');
                
            } catch (err) {
                console.error('❌ Proctoring auto-start failed:', err);
                
                // Show manual start option
                const startBtn = document.createElement('button');
                startBtn.innerHTML = '🔒 START PROCTORING (Required)';
                startBtn.style.cssText = 
                    'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); ' +
                    'background: #ef4444; color: white; padding: 20px 40px; border: none; ' +
                    'border-radius: 8px; cursor: pointer; font-size: 20px; font-weight: bold; ' +
                    'z-index: 100000; box-shadow: 0 10px 25px rgba(0,0,0,0.5);';
                
                startBtn.onclick = async () => {
                    try {
                        startBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Starting...';
                        startBtn.disabled = true;
                        
                        const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                        const proctor = new ProctoringSystem(examId, studentId);
                        window.proctor = proctor;
                        await proctor.initialize(stream);
                        
                        startBtn.remove();
                        
                    } catch (manualErr) {
                        console.error('Manual proctoring start failed:', manualErr);
                        startBtn.innerHTML = '❌ Failed - Click to Retry';
                        startBtn.disabled = false;
                    }
                };
                
                document.body.appendChild(startBtn);
            }
        })();
        
    } catch (err) {
        console.warn('Proctor auto-start check failed:', err);
    }
});