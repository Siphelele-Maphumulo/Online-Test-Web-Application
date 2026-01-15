-- =============================================
-- Script to create verification_codes table
-- for password reset functionality
-- =============================================

-- Drop table if exists (for clean reinstall)
DROP TABLE IF EXISTS `verification_codes`;

-- Create verification_codes table
CREATE TABLE `verification_codes` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(100) NOT NULL,
  `code` VARCHAR(8) NOT NULL,
  `user_type` VARCHAR(20) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_email` (`email`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores verification codes for password reset';

-- Add a cleanup event to automatically delete expired codes (older than 1 hour)
-- This helps keep the table clean and efficient
DELIMITER $$

CREATE EVENT IF NOT EXISTS `cleanup_expired_verification_codes`
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
  DELETE FROM verification_codes 
  WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);
END$$

DELIMITER ;

-- Enable event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- Display success message
SELECT 'verification_codes table created successfully!' AS Message;
