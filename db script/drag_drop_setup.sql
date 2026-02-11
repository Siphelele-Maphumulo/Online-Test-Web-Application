-- Create tables for Drag and Drop Question Type

CREATE TABLE IF NOT EXISTS `question_drag_drop_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) NOT NULL,
  `item_text` varchar(255) NOT NULL,
  `item_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `question_drop_zones` (
  `zone_id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) NOT NULL,
  `zone_label` varchar(255) NOT NULL,
  `correct_item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`zone_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
