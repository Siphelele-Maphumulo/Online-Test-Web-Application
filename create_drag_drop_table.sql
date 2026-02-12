CREATE TABLE IF NOT EXISTS `drag_drop_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exam_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `drag_item_id` int(11) NOT NULL,
  `drop_target_id` int(11) DEFAULT NULL,
  `is_correct` tinyint(1) DEFAULT 0,
  `marks_obtained` decimal(5,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `exam_id` (`exam_id`),
  KEY `question_id` (`question_id`),
  KEY `drag_item_id` (`drag_item_id`),
  KEY `drop_target_id` (`drop_target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
