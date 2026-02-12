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

-- Verify changes
DESCRIBE `exams`;
DESCRIBE `answers`;
DESCRIBE `questions`;
