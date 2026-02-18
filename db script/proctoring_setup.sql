-- Proctoring incidents log 
CREATE TABLE IF NOT EXISTS proctoring_incidents ( 
    id INT AUTO_INCREMENT PRIMARY KEY, 
    exam_id INT NOT NULL, 
    student_id INT NOT NULL, 
    incident_type VARCHAR(50) NOT NULL, 
    description TEXT, 
    screenshot_path VARCHAR(255), 
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    INDEX idx_exam (exam_id), 
    INDEX idx_student (student_id) 
); 
 
-- Student verifications 
CREATE TABLE IF NOT EXISTS student_verifications ( 
    id INT AUTO_INCREMENT PRIMARY KEY, 
    student_id INT NOT NULL, 
    exam_id INT NOT NULL, 
    honor_code_accepted BOOLEAN DEFAULT FALSE, 
    honor_code_timestamp TIMESTAMP NULL, 
    face_photo_path VARCHAR(255), 
    id_photo_path VARCHAR(255), 
    status VARCHAR(50) DEFAULT 'pending', 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    UNIQUE KEY unique_student_exam (student_id, exam_id) 
); 
 
-- Drag-drop answers table 
CREATE TABLE IF NOT EXISTS drag_drop_answers ( 
    id INT AUTO_INCREMENT PRIMARY KEY, 
    exam_id INT NOT NULL, 
    question_id INT NOT NULL, 
    student_id VARCHAR(50) NOT NULL, 
    drag_item_id INT NOT NULL, 
    drop_target_id INT, 
    is_correct BOOLEAN DEFAULT FALSE, 
    marks_obtained FLOAT DEFAULT 0, 
    INDEX idx_exam_question (exam_id, question_id) 
); 
 
-- Rearrange answers table 
CREATE TABLE IF NOT EXISTS rearrange_answers ( 
    id INT AUTO_INCREMENT PRIMARY KEY, 
    exam_id INT NOT NULL, 
    question_id INT NOT NULL, 
    student_id VARCHAR(50) NOT NULL, 
    item_id INT NOT NULL, 
    student_position INT, 
    is_correct BOOLEAN DEFAULT FALSE, 
    marks_obtained FLOAT DEFAULT 0, 
    INDEX idx_exam_question (exam_id, question_id) 
); 
