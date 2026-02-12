-- Fix Database Schema for Exam Results
-- This script adds missing columns required for accurate results calculation and display.

-- 1. Update 'exams' table
ALTER TABLE `exams`
ADD COLUMN IF NOT EXISTS `result_status` VARCHAR(45) DEFAULT NULL AFTER `status`,
MODIFY COLUMN `total_marks` INT DEFAULT 0,
MODIFY COLUMN `obt_marks` INT DEFAULT 0;

-- 2. Update 'answers' table
ALTER TABLE `answers`
ADD COLUMN IF NOT EXISTS `question_id` INT DEFAULT 0 AFTER `exam_id`;

-- 3. Update 'questions' table
ALTER TABLE `questions`
ADD COLUMN IF NOT EXISTS `marks` INT DEFAULT 1 AFTER `correct`;

-- 4. Create missing relational tables for drag-and-drop questions
CREATE TABLE IF NOT EXISTS drop_targets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    target_label VARCHAR(255) NOT NULL,
    target_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS drag_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    item_text TEXT NOT NULL,
    correct_target_id INT,
    item_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (correct_target_id) REFERENCES drop_targets(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS drag_drop_answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    question_id INT NOT NULL,
    student_id VARCHAR(45) NOT NULL,
    drag_item_id INT NOT NULL,
    drop_target_id INT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    marks_obtained FLOAT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (drag_item_id) REFERENCES drag_items(id) ON DELETE CASCADE,
    FOREIGN KEY (drop_target_id) REFERENCES drop_targets(id) ON DELETE CASCADE,
    UNIQUE KEY unique_answer (exam_id, question_id, student_id, drag_item_id)
);

-- Verify changes
DESCRIBE `exams`;
DESCRIBE `answers`;
DESCRIBE `questions`;
