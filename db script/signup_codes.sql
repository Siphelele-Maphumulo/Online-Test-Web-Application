CREATE TABLE `signup_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_names` varchar(100) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `email_address` varchar(100) NOT NULL,
  `code` varchar(8) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
