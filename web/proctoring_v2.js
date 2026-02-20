    class ProctoringSystem { 
        constructor() { 
            this.examActive = true; 
            this.terminated = false; // Flag to prevent multiple submissions
            this.violations = []; 
            this.warningCount = 0; 
            this.MAX_WARNINGS = 5; // Increased from 3 - more attempts before termination

            // Anti-false-positive controls
            this.violationCooldownMs = 15000; // do not count the same violation repeatedly within this window
            this.lastViolationAt = {}; // key -> timestamp
            this.examStartAt = Date.now();
            this.gracePeriodMs = 15000; // ignore most violations during initial startup

            // Natural behavior tolerance
            // Audio/head movement must be sustained for a short period before flagging.
            this.audioSampleMs = 500;
            this.noiseSpikeMinDurationMs = 2500; // tolerate short cough/sneeze/typing bursts
            this.voiceVarianceMinDurationMs = 5000;
            this.headMovementMinDurationMs = 2500;
            this.noiseSpikeStartAt = null;
            this.voiceVarianceStartAt = null;
            this.headMovementStartAt = null;
            this.fastMouseStartAt = null;
            this.lastFastMouseFlagAt = 0;

            // Detection thresholds (calibrated for real cheating scenarios) 
            this.NOISE_THRESHOLD = 37.6; // dB - background noise (47 * 0.8 = 37.6, 20% more sensitive)
            this.MULTIPLE_VOICES_THRESHOLD = 400; // frequency variance (500 * 0.8 = 400, 20% more sensitive)
            this.EYE_OFF_SCREEN_THRESHOLD = 2700; // 2.7 seconds (3000 * 0.9 = 2700, 10% more sensitive)
            this.HEAD_MOVEMENT_THRESHOLD = 0.153; // 17% movement (0.17 * 0.9 = 0.153, 10% more sensitive)
            this.FACE_LOST_THRESHOLD = 500; // 0.5 seconds - Immediate detection
            this.MOUTH_MOVEMENT_THRESHOLD = 1.8; // pixels of movement (2 * 0.9 = 1.8, 10% more sensitive)
            this.LOOKING_DOWN_ANGLE = -13.5; // degrees pitch (-15 * 0.9 = -13.5, 10% more sensitive)

            // Countdown state for faster termination
            this.countdownActive = false;
            this.countdownValue = 3; // 3 seconds countdown
            this.countdownOverlay = null;

            // Behavioral thresholds
            this.FAST_MOUSE_SPEED_PX_PER_S = 6000; // extremely fast movements (px/sec)
            this.FAST_MOUSE_SUSTAIN_MS = 700; // must be sustained before flagging
            this.FAST_MOUSE_COOLDOWN_MS = 15000; // prevent repeated false positives

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

            // Face detection 
            this.faceapi = null; 
            this.detectionInterval = null; 
            this.audioMonitor = null;
        } 

        async initialize(sharedStream) { 
            console.log('🔒 Initializing Professional Proctoring System...'); 

            // Show proctoring status to user 
            this.showStatusBanner(); 

            // Load face detection library 
            await this.loadFaceApi(); 

            // Reuse already-approved stream from verification if provided
            if (sharedStream) {
                this.audioStream = sharedStream;
                this.videoStream = sharedStream;
            }

            // Initialize all monitoring systems 
            await this.initAudioMonitoring(); 
            await this.initVideoMonitoring(); 
            this.initEnvironmentLockdown(); 
            this.initBehavioralMonitoring(); 

            // Start continuous monitoring loop 
            this.startMonitoringLoop(); 

            console.log('✅ Proctoring System Active'); 
            this.logToServer('INFO', 'Proctoring started successfully'); 
        } 

        showStatusBanner() { 
            const banner = document.createElement('div'); 
            banner.id = 'proctoring-banner'; 
            banner.style.cssText = 'position: fixed; bottom: 12px; left: 50%; transform: translateX(-50%); background: #09294d; color: white; padding: 8px 15px; border-radius: 20px; font-size: 12px; z-index: 9999; display: flex; align-items: center; gap: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.2);'; 
            banner.innerHTML = '<span class="live-indicator" style="width: 10px; height: 10px; background: #10b981; border-radius: 50%; animation: pulse 2s infinite;"></span>' + 
                '<span>Proctoring Active</span>' + 
                '<span id="violation-counter" style="background: #ef4444; padding: 2px 6px; border-radius: 10px; font-size: 10px;">0</span>'; 
            document.body.appendChild(banner); 

            // Add pulse animation 
            const style = document.createElement('style'); 
            style.textContent = ` 
                @keyframes pulse { 
                    0% { opacity: 1; transform: scale(1); } 
                    50% { opacity: 0.5; transform: scale(1.2); } 
                    100% { opacity: 1; transform: scale(1); } 
                } 
            `; 
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
                        // Use CDN models instead of local files for simplicity 
                        await faceapi.nets.tinyFaceDetector.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights'); 
                        await faceapi.nets.faceLandmark68Net.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights'); 
                        await faceapi.nets.faceExpressionNet.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights'); 
                        this.faceapi = faceapi; 
                        console.log('✅ Face detection models loaded from CDN'); 
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

        async initAudioMonitoring() { 
            try { 
                if (!this.audioStream) {
                    this.audioStream = await navigator.mediaDevices.getUserMedia({
                        audio: {
                            echoCancellation: false,
                            noiseSuppression: false,
                            autoGainControl: false
                        }
                    });
                }

                const audioContext = new (window.AudioContext || window.webkitAudioContext)(); 
                const source = audioContext.createMediaStreamSource(this.audioStream); 
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

            const now = Date.now();
            const noiseThreshold = this.backgroundNoiseBaseline + 12; // slightly stricter so speaking is detected reliably

            // DETECTION 1: Background Noise (someone talking nearby, TV, etc.) 
            if (dbLevel > noiseThreshold) {
                if (!this.noiseSpikeStartAt) this.noiseSpikeStartAt = now;
                if (now - this.noiseSpikeStartAt >= this.noiseSpikeMinDurationMs) {
                    this.logViolation('AUDIO', 'Sustained loud background noise detected (' + Math.round(dbLevel) + 'dB)');
                    this.noiseSpikeStartAt = now; // reset window after logging
                }
            } else {
                this.noiseSpikeStartAt = null;
            }

            // DETECTION 2: Multiple Voices (using frequency variance) 
            const variance = this.calculateVariance(dataArray); 
            if (variance > this.MULTIPLE_VOICES_THRESHOLD) {
                if (!this.voiceVarianceStartAt) this.voiceVarianceStartAt = now;
                if (now - this.voiceVarianceStartAt >= this.voiceVarianceMinDurationMs) {
                    this.logViolation('AUDIO', 'Sustained multiple voices/conversation detected in background');
                    this.voiceVarianceStartAt = now;
                }
            } else {
                this.voiceVarianceStartAt = null;
            }

            // DETECTION 3: Sudden Silence (possible phone call or leaving) 
            // Disabled as it triggers false positives in quiet rooms.
        } 

        calculateVariance(dataArray) { 
            const mean = dataArray.reduce((a, b) => a + b, 0) / dataArray.length; 
            const variance = dataArray.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / dataArray.length; 
            return variance; 
        } 

        async initVideoMonitoring() { 
            try { 
                if (!this.videoStream) {
                    this.videoStream = await navigator.mediaDevices.getUserMedia({
                        video: {
                            width: { ideal: 640 },
                            height: { ideal: 480 },
                            frameRate: { ideal: 15 }
                        }
                    });
                }

                // Create hidden video element for processing 
                let videoElement = document.getElementById('faceVideo'); 
                if (!videoElement) { 
                    videoElement = document.createElement('video'); 
                    videoElement.id = 'proctorVideo'; 
                    videoElement.style.display = 'none'; 
                    document.body.appendChild(videoElement); 
                } 

                videoElement.srcObject = this.videoStream; 
                videoElement.muted = true; 
                await videoElement.play(); 

                // Create canvas for processing 
                this.videoCanvas = document.createElement('canvas'); 
                this.videoContext = this.videoCanvas.getContext('2d'); 

                // Start face detection 
                this.startFaceDetection(videoElement); 

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
                const timeLost = Date.now() - this.lastFaceDetected;
                // DETECTION 4: No face in frame 
                if (timeLost > this.FACE_LOST_THRESHOLD) { 
                    this.handleCountdown(timeLost, 'FACE NOT DETECTED');
                } 
                return; 
            } 

            this.lastFaceDetected = Date.now(); 
            this.hideCountdown();

            // DETECTION 5: Multiple faces 
            if (detections.length > 1) { 
                this.logViolation('VISUAL', 'Multiple people detected in camera frame'); 
            } 

            const face = detections[0]; 

            // DETECTION 6: Gaze away from screen (using eye landmarks) 
            const lookingAtScreen = this.detectGazeDirection(face.landmarks); 
            if (!lookingAtScreen) { 
                if (Date.now() - this.lastEyeContact > this.EYE_OFF_SCREEN_THRESHOLD) { 
                    this.logViolation('VISUAL', 'Looking away from screen for >3 seconds'); 
                } 
            } else { 
                this.lastEyeContact = Date.now(); 
            } 

            // DETECTION 7: Head movement (looking around suspiciously) 
            const headMovement = this.detectHeadMovement(face.landmarks); 
            if (headMovement > this.HEAD_MOVEMENT_THRESHOLD) {
                const now = Date.now();
                if (!this.headMovementStartAt) this.headMovementStartAt = now;
                if (now - this.headMovementStartAt >= this.headMovementMinDurationMs) {
                    this.logViolation('VISUAL', 'Sustained excessive head movement detected');
                    this.headMovementStartAt = now;
                }
            } else {
                this.headMovementStartAt = null;
            }

            // DETECTION 8: Face partially covered (hand over face, phone) 
            if (this.detectFaceObstruction(face.landmarks)) { 
                this.logViolation('VISUAL', 'Face partially obscured - possible phone or notes'); 
            } 

            // DETECTION 9: Looking down (possible phone in lap) 
            const headPose = this.estimateHeadPose(face.landmarks); 
            if (headPose.pitch < this.LOOKING_DOWN_ANGLE) { 
                this.logViolation('VISUAL', 'Looking down - possible phone use'); 
            } 

            // DETECTION 10: Reading lips (communicating answers) 
            if (this.detectLipMovement(face.landmarks, face.expressions)) { 
                this.logViolation('BEHAVIOR', 'Lip movement detected - possible verbal communication'); 
            } 
        } 

        detectGazeDirection(landmarks) { 
            if (!landmarks) return true; 

            try { 
                const leftEye = landmarks.getLeftEye(); 
                const rightEye = landmarks.getRightEye(); 

                // Calculate eye aspect ratio (blink detection) 
                const leftEAR = this.eyeAspectRatio(leftEye); 
                const rightEAR = this.eyeAspectRatio(rightEye); 

                // If eyes are closed or looking away 
                if (leftEAR < 0.15 || rightEAR < 0.15) { 
                    return false; 
                } 

                // Check pupil position (simplified) 
                const leftPupil = leftEye[0]; 
                const rightPupil = rightEye[3]; 

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

                // Use inter-eye distance as a scale reference so movement is measured as a percentage.
                // This avoids false positives when camera distance/zoom changes.
                let faceScale = 100; 
                try {
                    const leftEye = landmarks.getLeftEye();
                    const rightEye = landmarks.getRightEye();
                    if (leftEye && leftEye.length > 0 && rightEye && rightEye.length > 0) {
                        const lx = leftEye[0].x;
                        const ly = leftEye[0].y;
                        const rx = rightEye[3] ? rightEye[3].x : rightEye[0].x;
                        const ry = rightEye[3] ? rightEye[3].y : rightEye[0].y;
                        const d = Math.hypot(rx - lx, ry - ly);
                        if (d && d > 20) faceScale = d;
                    }
                } catch (e) {
                    // keep default
                }

                if (!this.previousNosePosition) { 
                    this.previousNosePosition = { x: nose[0].x, y: nose[0].y, scale: faceScale }; 
                    return 0; 
                } 

                const pxMove = Math.hypot( 
                    nose[0].x - this.previousNosePosition.x, 
                    nose[0].y - this.previousNosePosition.y 
                );

                const scale = this.previousNosePosition.scale || faceScale || 100;
                const movement = pxMove / scale; // normalized ratio (e.g. 0.20 = 20% of face scale)

                this.previousNosePosition = { x: nose[0].x, y: nose[0].y, scale: faceScale }; 
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

                // If mouth is moving significantly while not smiling (talking) 
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

                    if (avgDiff > 30) { 
                        this.logViolation('VISUAL', 'Significant movement detected in frame'); 
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

                // Check if mouse went to screen edge (possible second monitor) 
                if (e.clientX <= 5 || e.clientY <= 5 ||  
                    e.clientX >= window.innerWidth - 5 ||  
                    e.clientY >= window.innerHeight - 5) { 
                    this.logViolation('BEHAVIOR', 'Mouse moved to screen edge - possible second monitor'); 
                } 

                // Track mouse speed 
                if (lastMousePosition.x !== 0) { 
                    const distance = Math.hypot(e.clientX - lastMousePosition.x, e.clientY - lastMousePosition.y); 
                    const dt = now - mouseStoppedTime; 

                    // Avoid noisy spikes when the browser reports extremely small dt
                    if (dt >= 20) {
                        const speedPxPerS = (distance / dt) * 1000;

                        // Only consider truly extreme sustained speed, not normal quick gestures
                        const isExtreme = speedPxPerS >= this.FAST_MOUSE_SPEED_PX_PER_S;
                        if (isExtreme) {
                            // sustain logic
                            if (!this.fastMouseStartAt) this.fastMouseStartAt = now;

                            const sustainedMs = now - this.fastMouseStartAt;
                            const cooldownOk = !this.lastFastMouseFlagAt || ((now - this.lastFastMouseFlagAt) >= this.FAST_MOUSE_COOLDOWN_MS);

                            if (sustainedMs >= this.FAST_MOUSE_SUSTAIN_MS && cooldownOk) {
                                this.lastFastMouseFlagAt = now;
                                this.fastMouseStartAt = null;
                                mouseMovements = [];
                                this.logViolation('BEHAVIOR', 'Unusually fast sustained mouse movements - possible automation');
                            }
                        } else {
                            this.fastMouseStartAt = null;
                        }

                        // Keep light telemetry for debugging / future tuning (non-actionable)
                        mouseMovements.push(speedPxPerS);
                        if (mouseMovements.length > 20) mouseMovements.shift();
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

                // Check for VM/Remote Desktop (basic detection) 
                const userAgent = navigator.userAgent.toLowerCase(); 
                if (userAgent.includes('virtualbox') ||  
                    userAgent.includes('vmware') || 
                    userAgent.includes('parallels')) { 
                    this.logViolation('SECURITY', 'Virtual machine detected'); 
                } 

                // Check for multiple monitors (simplified) 
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

        shouldCountViolation(type, description) {
            // Never terminate due to system capability issues
            if (type === 'CRITICAL') return false;

            // SECURITY heuristics are noisy; log them but do not count as warnings.
            if (type === 'SECURITY') return false;

            // Very noisy in normal exam usage
            if (type === 'LOCKDOWN') {
                // Only count exiting fullscreen; ignore other lockdown noise like right click/keys.
                if (description && description.indexOf('Exited fullscreen mode') !== -1) return true;
                return false;
            }

            return true;
        }

        isInGracePeriod() {
            return (Date.now() - this.examStartAt) < this.gracePeriodMs;
        }

        logViolation(type, description) { 
            if (!this.examActive) return; 

            // Ignore most violations during initial startup to avoid instant termination.
            if (this.isInGracePeriod() && type !== 'CRITICAL') {
                // allow logging to server for visibility, but do not count as warning
                try {
                    this.sendViolationToServer({
                        timestamp: new Date().toISOString(),
                        type: type,
                        description: description,
                        examId: window.examId || '0',
                        studentId: window.studentId || '0'
                    });
                } catch (e) {}
                return;
            }

            // Debounce repeated violations
            var key = String(type) + '|' + String(description);
            var now = Date.now();
            if (this.lastViolationAt[key] && (now - this.lastViolationAt[key]) < this.violationCooldownMs) {
                return;
            }
            this.lastViolationAt[key] = now;

            const violation = { 
                timestamp: new Date().toISOString(), 
                type: type, 
                description: description, 
                examId: (function(){
                    try {
                        var el = document.querySelector('input[name="examId"]');
                        return (el && el.value) ? el.value : window.examId;
                    } catch (e) {
                        return window.examId || '0';
                    }
                })(),
                studentId: window.studentId || '0' 
            }; 

            this.violations.push(violation); 

            var countThis = this.shouldCountViolation(type, description);
            if (countThis) {
                this.warningCount++; 
            }

            // Update counter in UI 
            const counter = document.getElementById('violation-counter'); 
            if (counter) counter.textContent = this.warningCount; 

            // Capture screenshot evidence 
            this.captureEvidence(violation); 

            // Show warning to student 
            if (countThis) {
                this.showWarning(violation); 
            }

            // Auto-submit after MAX_WARNINGS 
            if (countThis && this.warningCount >= this.MAX_WARNINGS) { 
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
            warningModal.style.cssText = 'position: fixed; top: 20px; left: 50%; transform: translateX(-50%); background: #fee2e2; border: 2px solid #ef4444; border-radius: 8px; padding: 15px 25px; z-index: 10000; box-shadow: 0 4px 20px rgba(0,0,0,0.3); text-align: center; animation: slideDown 0.3s ease-out;'; 

            warningModal.innerHTML = '<div style="color: #b91c1c; font-weight: bold; margin-bottom: 5px;">' + 
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
            style.textContent = ` 
                @keyframes slideDown { 
                    from { opacity: 0; transform: translate(-50%, -20px); } 
                    to { opacity: 1; transform: translate(-50%, 0); } 
                } 
            `; 
            document.head.appendChild(style); 

            // Remove after 5 seconds 
            setTimeout(() => { 
                if (warningModal.parentNode) { 
                    warningModal.remove(); 
                } 
            }, 5000); 
        } 

        autoSubmitForCheating() { 
            if (this.terminated) return;
            this.terminated = true;
            this.examActive = false; 
            this.hideCountdown();

            // Show final message in modal to keep fullscreen, then auto-submit
            try {
                if (typeof showSystemAlertModal === 'function') {
                    showSystemAlertModal('EXAM TERMINATED: Cheating detected or multiple violations. Your exam is being submitted.');
                }
            } catch (e) {}

            const form = document.getElementById('myform'); 
            if (form) { 
                // 📦 Gather all answers before termination to ensure accurate scoring
                if (typeof window.gatherAllAnswers === 'function') {
                    window.gatherAllAnswers();
                } else if (typeof gatherAllAnswers === 'function') {
                    gatherAllAnswers();
                }

                // Add cheating flag 
                const input = document.createElement('input'); 
                input.type = 'hidden'; 
                input.name = 'cheating_terminated'; 
                input.value = 'true'; 
                form.appendChild(input); 

                console.log('🔒 Proctoring: Submitting exam with cheating_terminated=true');

                // Submit shortly to allow the modal to be seen
                setTimeout(function() {
                    form.submit();
                }, 1500);
            } 
        } 

        handleCountdown(timeLost, reason) {
            if (this.terminated) return;
            
            // 0.5s grace period
            if (timeLost < 500) return;

            const remaining = Math.max(0, 5 - Math.floor((timeLost - 500) / 1000));
            
            if (remaining > 0) {
                if (!this.countdownActive) {
                    this.showCountdown(remaining, reason);
                } else if (remaining !== this.countdownValue) {
                    this.updateCountdown(remaining);
                }
            }

            // Terminate after 5 seconds total
            if (timeLost >= 5000) {
                this.autoSubmitForCheating();
            }
        }

        showCountdown(seconds, reason) {
            this.countdownActive = true;
            this.countdownValue = seconds;
            
            this.countdownOverlay = document.createElement('div');
            this.countdownOverlay.id = 'proctor-countdown';
            this.countdownOverlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(239,68,68,0.9);color:white;z-index:10000;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;font-family:sans-serif;';
            this.countdownOverlay.innerHTML = '<h1 style="font-size:48px;">⚠️ VIOLATION DETECTED</h1>' +
                '<p style="font-size:24px;">' + reason + '</p>' +
                '<div style="font-size:120px;font-weight:bold;margin:20px 0;">' + seconds + '</div>' +
                '<p>Return immediately or exam will be terminated!</p>';
            document.body.appendChild(this.countdownOverlay);
        }

        updateCountdown(seconds) {
            this.countdownValue = seconds;
            if (this.countdownOverlay) {
                const countDiv = this.countdownOverlay.querySelector('div');
                if (countDiv) countDiv.textContent = seconds;
            }
        }

        hideCountdown() {
            this.countdownActive = false;
            if (this.countdownOverlay) {
                this.countdownOverlay.remove();
                this.countdownOverlay = null;
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
                examId: window.examId || '0', 
                studentId: window.studentId || '0' 
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

            if (this.audioStream) { 
                this.audioStream.getTracks().forEach(t => t.stop()); 
            } 

            if (this.videoStream) { 
                this.videoStream.getTracks().forEach(t => t.stop()); 
            } 

            console.log('🛑 Proctoring stopped'); 
        } 
    } 

    // Auto-restart proctoring after the exam starts (page navigation/reload stops media streams).
    document.addEventListener('DOMContentLoaded', function () {
        try {
            // Only auto-start when the actual exam form is present.
            var examForm = document.getElementById('myform');
            if (!examForm) return;

            if (window.proctor) return;

            var shouldAutoStart = false;
            try {
                shouldAutoStart = sessionStorage.getItem('proctorAutoStart') === '1';
            } catch (e) {
                shouldAutoStart = false;
            }

            if (!shouldAutoStart) return;

            // Clear the flag immediately to avoid double-starts.
            try {
                sessionStorage.removeItem('proctorAutoStart');
            } catch (e) {
                // ignore
            }

            (async function () {
                try {
                    var stream = null;
                    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                        stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                    }

                    var p = new ProctoringSystem();
                    window.proctor = p;
                    await p.initialize(stream);
                } catch (err) {
                    console.error('Auto-start proctoring failed:', err);
                }
            })();
        } catch (outerErr) {
            console.error('Auto-start proctoring setup failed:', outerErr);
        }
    });

    // Begin button proctoring hook moved to the confirmation modal handler above.
