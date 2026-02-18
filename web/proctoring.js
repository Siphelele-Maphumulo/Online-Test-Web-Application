/* ============================================
   PROFESSIONAL PROCTORING SYSTEM v3.0 
   Continuous Camera Stream Implementation
   ============================================ */ 

class ProctoringSystem {
    constructor(examId, studentId) {
        this.examActive = true;
        this.violations = [];
        this.warningCount = 0;
        this.MAX_WARNINGS = 3;
        
        // Detection thresholds
        this.NOISE_THRESHOLD = 55;
        this.EYE_OFF_SCREEN_THRESHOLD = 3000; // 3 seconds
        this.FACE_LOST_THRESHOLD = 2000; // 2 seconds
        this.MOUTH_MOVEMENT_THRESHOLD = 2;
        this.LOOKING_DOWN_ANGLE = -15;
        
        // State tracking
        this.lastEyeContact = Date.now();
        this.lastFaceDetected = Date.now();
        this.backgroundNoiseBaseline = 40;
        this.calibrationComplete = false;
        this.previousNosePosition = null;
        this.previousMouthHeight = null;
        
        // Media streams
        this.audioStream = null;
        this.videoStream = null;
        this.faceapi = null;
        this.detectionInterval = null;
        this.audioMonitor = null;
        
        // Get IDs from constructor
        this.examId = examId;
        this.studentId = studentId;
    }

    async initialize(stream) {
        console.log('🔒 Starting continuous proctoring with persistent camera...');
        
        // Show proctoring status to user
        this.showStatusBanner();
        
        try {
            // Use the provided stream or request new one
            if (stream) {
                this.videoStream = stream;
            } else {
                // Request single stream with both video and audio
                this.videoStream = await navigator.mediaDevices.getUserMedia({
                    video: {
                        width: { ideal: 640 },
                        height: { ideal: 480 },
                        frameRate: { ideal: 15 }
                    },
                    audio: {
                        echoCancellation: false,
                        noiseSuppression: false,
                        autoGainControl: false
                    }
                });
            }
            
            console.log('✅ Camera and microphone access granted - stream kept alive');
            
            // Load face detection library
            await this.loadFaceApi();
            
            // Initialize all monitoring systems with the SAME stream
            await this.initAudioMonitoring(this.videoStream);
            await this.initVideoMonitoring(this.videoStream);
            this.initEnvironmentLockdown();
            this.initBehavioralMonitoring();
            
            // Start continuous monitoring loop
            this.startMonitoringLoop();
            
            console.log('✅ Continuous proctoring system active');
            this.logToServer('INFO', 'Proctoring started successfully with persistent camera');
            
        } catch (err) {
            console.error('Permission error:', err);
            alert('Camera and microphone access is required for this exam. Please refresh and allow permissions.');
            throw err;
        }
    }

    showStatusBanner() {
        // Remove existing banner if any
        const existing = document.getElementById('proctoring-banner');
        if (existing) existing.remove();
        
        const banner = document.createElement('div');
        banner.id = 'proctoring-banner';
        banner.style.cssText = 
            'position: fixed; top: 10px; right: 10px; background: #09294d; color: white; ' +
            'padding: 8px 15px; border-radius: 20px; font-size: 12px; z-index: 9999; ' +
            'display: flex; align-items: center; gap: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.2);';
        banner.innerHTML = 
            '<span class="live-indicator" style="width: 10px; height: 10px; background: #10b981; border-radius: 50%; animation: pulse 2s infinite;"></span>' +
            '<span>🔴 RECORDING</span>' +
            '<span id="violation-counter" style="background: #ef4444; padding: 2px 6px; border-radius: 10px; font-size: 10px;">0</span>';
        document.body.appendChild(banner);
        
        // Add pulse animation
        const style = document.createElement('style');
        style.textContent = 
            '@keyframes pulse { ' +
            '0% { opacity: 1; transform: scale(1); } ' +
            '50% { opacity: 0.5; transform: scale(1.2); } ' +
            '100% { opacity: 1; transform: scale(1); } ' +
            '}';
        document.head.appendChild(style);
    }

    async loadFaceApi() {
        return new Promise((resolve) => {
            // Check if already loaded
            if (window.faceapi) {
                this.faceapi = window.faceapi;
                resolve();
                return;
            }

            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js';
            script.onload = async () => {
                try {
                    // Use local models from web/models for offline capability
                    await faceapi.nets.tinyFaceDetector.load('models/');
                    await faceapi.nets.faceLandmark68Net.load('models/');
                    await faceapi.nets.faceExpressionNet.load('models/');
                    this.faceapi = faceapi;
                    console.log('✅ Face detection models loaded from local files');
                    resolve();
                } catch (err) {
                    console.warn('Could not load face-api models, using fallback detection', err);
                    resolve(); // Continue with fallback
                }
            };
            script.onerror = () => {
                console.warn('Could not load face-api.js, using fallback detection');
                resolve(); // Continue without face-api
            };
            document.head.appendChild(script);
        });
    }

    async initAudioMonitoring(stream) {
        try {
            // Use the audio track from the shared stream
            this.audioStream = stream;

            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const source = audioContext.createMediaStreamSource(stream);
            const analyser = audioContext.createAnalyser();
            analyser.fftSize = 2048;

            source.connect(analyser);

            const bufferLength = analyser.frequencyBinCount;
            const dataArray = new Uint8Array(bufferLength);

            // Calibration phase (first 5 seconds)
            setTimeout(() => this.calibrateNoise(analyser), 5000);

            // Continuous monitoring
            this.audioMonitor = setInterval(() => {
                analyser.getByteFrequencyData(dataArray);
                this.analyzeAudio(dataArray);
            }, 500);

            console.log('✅ Audio monitoring initialized with shared stream');

        } catch (err) {
            this.logViolation('CRITICAL', 'Audio monitoring unavailable - microphone access denied');
        }
    }

    calibrateNoise(analyser) {
        const dataArray = new Uint8Array(analyser.frequencyBinCount);
        let sum = 0;

        // Take 10 samples
        for (let i = 0; i < 10; i++) {
            analyser.getByteFrequencyData(dataArray);
            sum += dataArray.reduce((a, b) => a + b, 0) / dataArray.length;
        }

        this.backgroundNoiseBaseline = sum / 10;
        this.calibrationComplete = true;
        console.log('✅ Noise baseline calibrated:', this.backgroundNoiseBaseline.toFixed(2));
    }

    analyzeAudio(dataArray) {
        if (!this.calibrationComplete) return;

        const average = dataArray.reduce(function(a, b) { return a + b; }, 0) / dataArray.length;
        const dbLevel = 20 * Math.log10(average || 1);

        // DETECTION 1: Background Noise
        if (dbLevel > this.backgroundNoiseBaseline + 15) {
            this.logViolation('AUDIO', 'Excessive background noise detected (' + Math.round(dbLevel) + 'dB)');
        }

        // DETECTION 2: Multiple Voices
        const variance = this.calculateVariance(dataArray);
        if (variance > 500) {
            this.logViolation('AUDIO', 'Multiple voices/conversation detected in background');
        }

        // DETECTION 3: Sudden Silence
        if (average < 5 && dbLevel < 20) {
            this.logViolation('AUDIO', 'Suspicious silence - possible phone use or leaving seat');
        }
    }

    calculateVariance(dataArray) {
        const mean = dataArray.reduce((a, b) => a + b, 0) / dataArray.length;
        const variance = dataArray.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / dataArray.length;
        return variance;
    }

    async initVideoMonitoring(stream) {
        try {
            // Use the existing stream
            this.videoStream = stream;

            // Create hidden video element for processing
            let videoElement = document.getElementById('proctorVideo');
            if (!videoElement) {
                videoElement = document.createElement('video');
                videoElement.id = 'proctorVideo';
                videoElement.style.display = 'none';
                videoElement.muted = true;
                document.body.appendChild(videoElement);
            }

            videoElement.srcObject = this.videoStream;
            await videoElement.play();

            // Store reference for face detection
            this.videoElement = videoElement;

            // Create canvas for processing
            this.videoCanvas = document.createElement('canvas');
            this.videoContext = this.videoCanvas.getContext('2d');

            // Start continuous face detection
            this.startFaceDetection(videoElement);

            console.log('✅ Video monitoring initialized with continuous stream');

        } catch (err) {
            this.logViolation('CRITICAL', 'Camera monitoring unavailable - webcam access denied');
        }
    }

    async startFaceDetection(videoElement) {
        this.videoElement = videoElement;

        // Run detection every 500ms
        this.detectionInterval = setInterval(async () => {
            if (!this.examActive || !videoElement.videoWidth) return;

            try {
                if (this.faceapi && videoElement.videoWidth > 0) {
                    // Use face-api for advanced detection
                    const detections = await this.faceapi
                        .detectAllFaces(videoElement, new this.faceapi.TinyFaceDetectorOptions())
                        .withFaceLandmarks()
                        .withFaceExpressions();

                    this.processFaceDetections(detections);
                } else {
                    // Fallback: simple motion detection
                    this.processFallbackDetection(videoElement);
                }
            } catch (err) {
                // Silent fail - continue with next frame
            }
        }, 500);
    }

    processFaceDetections(detections) {
        if (detections.length === 0) {
            // DETECTION 4: No face in frame
            if (Date.now() - this.lastFaceDetected > this.FACE_LOST_THRESHOLD) {
                this.logViolation('VISUAL', 'No face detected in camera - you left the frame');
            }
            return;
        }

        this.lastFaceDetected = Date.now();

        // DETECTION 5: Multiple faces
        if (detections.length > 1) {
            this.logViolation('VISUAL', 'Multiple people detected in camera frame');
        }

        const face = detections[0];

        // DETECTION 6: Gaze away from screen
        const lookingAtScreen = this.detectGazeDirection(face.landmarks);
        if (!lookingAtScreen) {
            if (Date.now() - this.lastEyeContact > this.EYE_OFF_SCREEN_THRESHOLD) {
                this.logViolation('VISUAL', 'Looking away from screen for >3 seconds');
            }
        } else {
            this.lastEyeContact = Date.now();
        }

        // DETECTION 7: Head movement
        const headMovement = this.detectHeadMovement(face.landmarks);
        if (headMovement > 0.3) {
            this.logViolation('VISUAL', 'Excessive head movement detected');
        }

        // DETECTION 8: Face partially covered
        if (this.detectFaceObstruction(face.landmarks)) {
            this.logViolation('VISUAL', 'Face partially obscured - possible phone or notes');
        }

        // DETECTION 9: Looking down
        const headPose = this.estimateHeadPose(face.landmarks);
        if (headPose.pitch < this.LOOKING_DOWN_ANGLE) {
            this.logViolation('VISUAL', 'Looking down - possible phone use');
        }

        // DETECTION 10: Reading lips
        if (this.detectLipMovement(face.landmarks, face.expressions)) {
            this.logViolation('BEHAVIOR', 'Lip movement detected - possible verbal communication');
        }
    }

    detectGazeDirection(landmarks) {
        if (!landmarks) return true;

        try {
            const leftEye = landmarks.getLeftEye();
            const rightEye = landmarks.getRightEye();

            // Calculate eye aspect ratio
            const leftEAR = this.eyeAspectRatio(leftEye);
            const rightEAR = this.eyeAspectRatio(rightEye);

            // If eyes are closed or looking away
            if (leftEAR < 0.15 || rightEAR < 0.15) {
                return false;
            }

            return true;
        } catch (err) {
            return true;
        }
    }

    eyeAspectRatio(eye) {
        if (!eye || eye.length < 6) return 0.3;

        try {
            const A = Math.hypot(eye[1].x - eye[5].x, eye[1].y - eye[5].y);
            const B = Math.hypot(eye[2].x - eye[4].x, eye[2].y - eye[4].y);
            const C = Math.hypot(eye[0].x - eye[3].x, eye[0].y - eye[3].y);
            return (A + B) / (2 * C);
        } catch (err) {
            return 0.3;
        }
    }

    detectHeadMovement(landmarks) {
        if (!landmarks) return 0;

        try {
            const nose = landmarks.getNose();
            if (!nose || nose.length === 0) return 0;

            if (!this.previousNosePosition) {
                this.previousNosePosition = { x: nose[0].x, y: nose[0].y };
                return 0;
            }

            const movement = Math.hypot(
                nose[0].x - this.previousNosePosition.x,
                nose[0].y - this.previousNosePosition.y
            ) / 100;

            this.previousNosePosition = { x: nose[0].x, y: nose[0].y };
            return movement;
        } catch (err) {
            return 0;
        }
    }

    detectFaceObstruction(landmarks) {
        if (!landmarks) return false;

        try {
            const jaw = landmarks.getJawOutline();
            const mouth = landmarks.getMouth();

            if (!jaw || jaw.length === 0 || !mouth || mouth.length === 0) return false;

            const jawWidth = Math.abs(jaw[0].x - jaw[jaw.length - 1].x);
            const mouthWidth = Math.abs(mouth[0].x - mouth[6].x);

            // If mouth area is too small, might be covered
            return mouthWidth < jawWidth * 0.2;
        } catch (err) {
            return false;
        }
    }

    estimateHeadPose(landmarks) {
        if (!landmarks) return { pitch: 0 };

        try {
            const nose = landmarks.getNose();
            const leftEye = landmarks.getLeftEye();
            const rightEye = landmarks.getRightEye();

            if (!nose || nose.length === 0 || !leftEye || leftEye.length === 0 || !rightEye || rightEye.length === 0) {
                return { pitch: 0 };
            }

            const eyeY = (leftEye[0].y + rightEye[0].y) / 2;
            const pitch = nose[0].y - eyeY;

            return { pitch };
        } catch (err) {
            return { pitch: 0 };
        }
    }

    detectLipMovement(landmarks, expressions) {
        if (!landmarks) return false;

        try {
            const mouth = landmarks.getMouth();
            if (!mouth || mouth.length < 14) return false;

            if (!this.previousMouthHeight) {
                this.previousMouthHeight = Math.abs(mouth[13].y - mouth[14].y);
                return false;
            }

            const mouthHeight = Math.abs(mouth[13].y - mouth[14].y);
            const movement = Math.abs(mouthHeight - this.previousMouthHeight);

            this.previousMouthHeight = mouthHeight;

            // If mouth is moving significantly while not smiling
            return movement > this.MOUTH_MOVEMENT_THRESHOLD &&  
                   (!expressions || expressions.happy < 0.5);
        } catch (err) {
            return false;
        }
    }

    processFallbackDetection(videoElement) {
        if (!this.videoCanvas) return;

        try {
            this.videoCanvas.width = videoElement.videoWidth;
            this.videoCanvas.height = videoElement.videoHeight;
            this.videoContext.drawImage(videoElement, 0, 0);

            const frame = this.videoContext.getImageData(0, 0, this.videoCanvas.width, this.videoCanvas.height);

            if (this.lastFrame) {
                // Simple motion detection
                let diff = 0;
                for (let i = 0; i < frame.data.length; i += 40) {
                    diff += Math.abs(frame.data[i] - this.lastFrame.data[i]);
                }

                const avgDiff = diff / (frame.data.length / 40);

                if (avgDiff < 5) {
                    // No movement - possible frozen video or no face
                    if (Date.now() - this.lastFaceDetected > this.FACE_LOST_THRESHOLD) {
                        this.logViolation('VISUAL', 'No face/movement detected');
                    }
                } else {
                    this.lastFaceDetected = Date.now();
                }

                if (avgDiff > 50) {
                    this.logViolation('VISUAL', 'Excessive movement detected');
                }
            }

            this.lastFrame = frame;
            this.lastFaceDetected = Date.now();
        } catch (err) {
            // Silent fail
        }
    }

    initEnvironmentLockdown() {
        var self = this;
        // PREVENT SCREEN CAPTURE
        document.addEventListener('keyup', function(e) {
            if (e.key === 'PrintScreen') {
                self.logViolation('LOCKDOWN', 'Print screen attempted');
                navigator.clipboard.writeText('').catch(function() {});
            }
        });

        // DETECT ALT+TAB and window switching
        let lastFocusTime = Date.now();
        window.addEventListener('blur', function() {
            lastFocusTime = Date.now();
            self.logViolation('LOCKDOWN', 'Window focus lost - possible Alt+Tab');
        });

        window.addEventListener('focus', function() {
            if (Date.now() - lastFocusTime > 2000) {
                // This was a real switch, not just a brief flicker
            }
        });

        // BLOCK RIGHT CLICK
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            self.logViolation('LOCKDOWN', 'Right-click attempted');
            return false;
        });

        // BLOCK KEYBOARD SHORTCUTS
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.altKey || e.metaKey) {
                e.preventDefault();
                self.logViolation('LOCKDOWN', 'Forbidden key combination: ' + e.key);
            }

            // Block function keys
            if (e.key.startsWith('F') && e.key.length > 1 && !isNaN(parseInt(e.key.substring(1)))) {
                e.preventDefault();
                self.logViolation('LOCKDOWN', 'Function key pressed: ' + e.key);
            }
        });

        // FORCE FULLSCREEN
        this.enforceFullscreen();
    }

    enforceFullscreen() {
        // Request fullscreen at start
        setTimeout(() => {
            if (document.documentElement.requestFullscreen) {
                document.documentElement.requestFullscreen().catch(() => {});
            }
        }, 1000);

        // Check every 3 seconds
        setInterval(() => {
            if (!document.fullscreenElement && this.examActive) {
                this.logViolation('LOCKDOWN', 'Exited fullscreen mode');

                // Try to re-enter fullscreen
                try {
                    document.documentElement.requestFullscreen();
                } catch (err) {}
            }
        }, 3000);
    }

    initBehavioralMonitoring() {
        // Track mouse behavior
        let mouseMovements = [];
        let mouseStoppedTime = Date.now();
        let lastMousePosition = { x: 0, y: 0 };

        document.addEventListener('mousemove', (e) => {
            const now = Date.now();

            // Check if mouse went to screen edge
            if (e.clientX <= 5 || e.clientY <= 5 ||  
                e.clientX >= window.innerWidth - 5 ||  
                e.clientY >= window.innerHeight - 5) {
                this.logViolation('BEHAVIOR', 'Mouse moved to screen edge - possible second monitor');
            }

            // Track mouse speed
            if (lastMousePosition.x !== 0) {
                const distance = Math.hypot(e.clientX - lastMousePosition.x, e.clientY - lastMousePosition.y);
                const time = now - mouseStoppedTime;
                const speed = distance / time;

                if (speed > 5) {
                    // Very fast mouse movement - possible automated script
                    mouseMovements.push(speed);

                    if (mouseMovements.length > 10) {
                        mouseMovements.shift();

                        const avgSpeed = mouseMovements.reduce((a, b) => a + b, 0) / mouseMovements.length;
                        if (avgSpeed > 8) {
                            this.logViolation('BEHAVIOR', 'Unusually fast mouse movements - possible automation');
                            mouseMovements = [];
                        }
                    }
                }
            }

            lastMousePosition = { x: e.clientX, y: e.clientY };
            mouseStoppedTime = now;
        });

        // Detect if student leaves the page
        document.addEventListener('visibilitychange', () => {
            if (document.hidden && this.examActive) {
                this.logViolation('BEHAVIOR', 'Tab/window hidden - possible cheating');
            }
        });
    }

    startMonitoringLoop() {
        // Check for developer tools
        setInterval(() => {
            if (!this.examActive) return;

            const widthThreshold = window.outerWidth - window.innerWidth > 160;
            const heightThreshold = window.outerHeight - window.innerHeight > 160;

            if (widthThreshold || heightThreshold) {
                this.logViolation('SECURITY', 'Developer tools detected - possible inspection');
            }

            // Check for VM/Remote Desktop
            const userAgent = navigator.userAgent.toLowerCase();
            if (userAgent.includes('virtualbox') ||  
                userAgent.includes('vmware') || 
                userAgent.includes('parallels')) {
                this.logViolation('SECURITY', 'Virtual machine detected');
            }

            // Check for multiple monitors
            if (window.screen.width > 2000) {
                // Ultra-wide or multiple monitors
                this.logViolation('SECURITY', 'Wide screen detected - possible multiple monitors');
            }

        }, 5000);

        // Heartbeat to keep session alive
        setInterval(() => {
            if (this.examActive) {
                console.log('Proctoring heartbeat - monitoring active');
            }
        }, 30000);
    }

    logViolation(type, description) {
        if (!this.examActive) return;

        const violation = {
            timestamp: new Date().toISOString(),
            type: type,
            description: description,
            examId: this.examId,
            studentId: this.studentId
        };

        this.violations.push(violation);
        this.warningCount++;

        // Update counter in UI
        const counter = document.getElementById('violation-counter');
        if (counter) counter.textContent = this.warningCount;

        // Capture screenshot evidence
        this.captureEvidence(violation);

        // Show warning to student
        this.showWarning(violation);

        // Auto-submit after MAX_WARNINGS
        if (this.warningCount >= this.MAX_WARNINGS) {
            this.autoSubmitForCheating();
        } else {
            // Send to server
            this.sendViolationToServer(violation);
        }
    }

    async captureEvidence(violation) {
        if (!this.videoElement || !this.videoElement.videoWidth) return;

        try {
            const canvas = document.createElement('canvas');
            canvas.width = this.videoElement.videoWidth;
            canvas.height = this.videoElement.videoHeight;
            canvas.getContext('2d').drawImage(this.videoElement, 0, 0);
            violation.screenshot = canvas.toDataURL('image/jpeg', 0.6);
        } catch (err) {
            // Can't capture screenshot
        }
    }

    showWarning(violation) {
        // Create warning modal
        const warningModal = document.createElement('div');
        warningModal.style.cssText = 
            'position: fixed; top: 20px; left: 50%; transform: translateX(-50%); ' +
            'background: #fee2e2; border: 2px solid #ef4444; border-radius: 8px; ' +
            'padding: 15px 25px; z-index: 10000; box-shadow: 0 4px 20px rgba(0,0,0,0.3); ' +
            'text-align: center; animation: slideDown 0.3s ease-out;';

        warningModal.innerHTML = 
            '<div style="color: #b91c1c; font-weight: bold; margin-bottom: 5px;">' +
                '⚠️ Proctoring Warning (' + this.warningCount + '/' + this.MAX_WARNINGS + ')' +
            '</div>' +
            '<div style="color: #7f1d1d; font-size: 14px;">' +
                violation.type + ': ' + violation.description +
            '</div>' +
            '<div style="color: #991b1b; font-size: 12px; margin-top: 5px;">' +
                'This incident has been recorded.' +
            '</div>';

        document.body.appendChild(warningModal);

        // Add animation
        const style = document.createElement('style');
        style.textContent = 
            '@keyframes slideDown { ' +
            'from { opacity: 0; transform: translate(-50%, -20px); } ' +
            'to { opacity: 1; transform: translate(-50%, 0); } ' +
            '}';
        document.head.appendChild(style);

        // Remove after 5 seconds
        setTimeout(() => {
            if (warningModal.parentNode) {
                warningModal.remove();
            }
        }, 5000);
    }

    autoSubmitForCheating() {
        this.examActive = false;

        // Show final message
        alert('EXAM TERMINATED: Maximum violations exceeded. Your exam will be submitted for review.');

        const form = document.getElementById('myform');
        if (form) {
            // Add cheating flag
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'cheating_terminated';
            input.value = 'true';
            form.appendChild(input);

            // Submit immediately
            form.submit();
        }
    }

    sendViolationToServer(violation) {
        const formData = new FormData();
        formData.append('page', 'proctoring');
        formData.append('operation', 'log_violation');
        formData.append('violation_data', JSON.stringify(violation));

        // Use sendBeacon for reliability during page unload
        if (navigator.sendBeacon) {
            navigator.sendBeacon('controller.jsp', formData);
        } else {
            fetch('controller.jsp', {  
                method: 'POST',  
                body: formData, 
                keepalive: true  
            }).catch(() => {});
        }
    }

    logToServer(type, message) {
        const violation = {
            timestamp: new Date().toISOString(),
            type: 'INFO',
            description: message,
            examId: this.examId,
            studentId: this.studentId
        };
        this.sendViolationToServer(violation);
    }

    stop() {
        this.examActive = false;

        if (this.detectionInterval) {
            clearInterval(this.detectionInterval);
        }

        if (this.audioMonitor) {
            clearInterval(this.audioMonitor);
        }

        // Stop the shared stream (both audio and video tracks)
        if (this.audioStream) {
            this.audioStream.getTracks().forEach(t => t.stop());
            this.audioStream = null;
        }

        if (this.videoStream) {
            this.videoStream = null;
        }

        // Remove video element
        const videoElement = document.getElementById('proctorVideo');
        if (videoElement) {
            videoElement.remove();
        }

        console.log('🛑 Proctoring stopped and streams released');
    }
}