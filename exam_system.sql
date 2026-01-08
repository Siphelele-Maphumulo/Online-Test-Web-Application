-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 31, 2025 at 07:02 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `exam_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `answers`
--

CREATE TABLE `answers` (
  `answer_id` int(11) NOT NULL,
  `exam_id` int(11) NOT NULL,
  `question` longtext NOT NULL,
  `answer` longtext NOT NULL,
  `correct_answer` longtext NOT NULL,
  `status` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `answers`
--

INSERT INTO `answers` (`answer_id`, `exam_id`, `question`, `answer`, `correct_answer`, `status`) VALUES
(171, 153, 'What is Antivirus?', 'A computer Sickness', 'A computer Sickness', 'correct'),
(172, 153, 'A password / PIN is a correct way for stoping unauthorized access!', 'True', 'True', 'correct'),
(173, 154, 'Regular software updates improve security.', 'True', 'True', 'correct'),
(174, 154, 'What is Antivirus?', 'A computer Sickness', 'A computer Sickness', 'correct'),
(175, 154, 'What does VPN stand for?', 'Virtual Public Network', 'Virtual Private Network', 'incorrect'),
(176, 154, 'Two-factor authentication makes accounts more secure.', 'True', 'True', 'correct'),
(177, 154, 'What is phishing?', 'Stealing passwords online', 'Stealing passwords online', 'correct'),
(178, 154, 'Which is a type of malware?', 'Virus', 'Virus', 'correct'),
(179, 154, 'Public Wi-Fi is always safe for banking.', 'False', 'False', 'correct'),
(180, 154, 'What does HTTPS provide?', 'Secure connection', 'Secure connection', 'correct'),
(181, 154, 'A password / PIN is a correct way for stoping unauthorized access.', 'True', 'True', 'correct'),
(182, 154, 'Firewall can protect against hackers.', 'True', 'True', 'correct'),
(183, 155, 'What is the output of len([10,20,30])?', '3', '3', 'correct'),
(184, 155, 'Which function converts a string into an integer?', 'int()', 'int()', 'correct'),
(185, 155, 'Which operator is used to check equality in Python?', '==', '==', 'correct'),
(186, 155, 'Python uses indentation to define code blocks.', 'True', 'True', 'correct'),
(187, 155, 'What will be printed by runner(model=', 'Reluctance', 'e', 'incorrect'),
(188, 155, 'Which keyword is used to define a function in Python?', 'def', 'def', 'correct'),
(189, 155, 'Which keyword is used to handle exceptions in Python?', 'catch', 'try', 'incorrect'),
(190, 155, 'What is the correct way to define a class in Python?', 'object Car:', 'class Car:', 'incorrect'),
(191, 155, 'Which of these data types is ordered and changeable?', 'list', 'list', 'correct'),
(192, 155, 'What does the âappend()â method do to a list?', 'Adds an item to the end', 'Adds an item to the end', 'correct'),
(193, 155, 'Which keyword is used to exit a loop prematurely?', 'exit', 'break', 'incorrect'),
(194, 155, 'Which code will print âOut of boundsâ when list index fails?', 'try: prices=[2.39,4.99,0.99]; selection=prices[3]; print(', 'try: prices=[2.39,4.99,0.99]; selection=prices[3]; print(\"Ok\") except IndexError: print(\"Out of bounds\")', 'incorrect'),
(195, 155, 'Which symbol is used for floor division in Python?', '//', '//', 'correct'),
(196, 155, 'Which of these is used to create a comment in Python?', '//', '#', 'incorrect'),
(197, 155, 'Which line correctly adds Oliver Twistâs phone number 5551122333 to the dictionary phone_dir?', 'phone_dir[', 'phone_dir[\"Oliver Twist\"] = \"5551122333\"', 'incorrect'),
(198, 155, 'Assuming the assignment the_list = [', '300 in the_list and the_list[1]', 'int(the_list[2]) == len(the_list), the_list.index(False) == 1', 'incorrect'),
(199, 155, 'What data type is the result of 3 / 2 in Python 3?', 'float', 'float', 'correct'),
(200, 155, 'Lists in Python are immutable.', 'False', 'False', 'correct'),
(201, 155, 'What symbol is used to start a comment in Python?', '//', '#', 'incorrect'),
(202, 155, 'What will be the output of print(10 // 3)?', '3', '3', 'correct'),
(203, 158, 'What is my correct information?', 'N/A', 'Siphelele|Andile', 'incorrect'),
(204, 158, 'What is the output for the code snippet>:\r\ndef walk(stop, start=1):\r\n    print(start, end=', 'N/A', '1 2', 'incorrect'),
(205, 158, 'What is my Age?', 'N/A', '33', 'incorrect'),
(206, 163, 'Which of these functions can be called with two arguments?', 'N/A', 'def iota(level, size=0): pass', 'incorrect'),
(207, 163, 'Which of these is used to create a comment in Python?', 'N/A', '#', 'incorrect'),
(208, 163, 'Which loop is used when the number of iterations is unknown?', 'N/A', 'while', 'incorrect'),
(209, 163, 'What does the âappend()â method do to a list?', 'N/A', 'Adds an item to the end', 'incorrect'),
(210, 163, 'Which of the following correctly creates a dictionary in Python?', 'N/A', '{1: \"one\", 2: \"two\"}', 'incorrect'),
(211, 163, 'The keyword âelifâ stands for âelse ifâ.', 'N/A', 'True', 'incorrect'),
(212, 163, 'Which keyword is used to exit a loop prematurely?', 'N/A', 'break', 'incorrect'),
(213, 163, 'Which symbol is used for floor division in Python?', 'N/A', '//', 'incorrect'),
(214, 163, 'What is the result of bool(0)?', 'N/A', 'False', 'incorrect'),
(215, 163, 'Which operator is used to check equality in Python?', 'N/A', '==', 'incorrect'),
(216, 163, 'Which data structure allows duplicate elements?', 'N/A', 'list', 'incorrect'),
(217, 163, 'What happens in this code? def velocity(x): return speed*x; speed=10; new_speed=velocity(10); new_speed=velocity(speed); print(new_speed)', 'N/A', 'Error: variable not defined', 'incorrect'),
(218, 163, 'Which of these data types is ordered and changeable?', 'N/A', 'list', 'incorrect'),
(219, 163, 'Which statement is used to stop a loop in Python?', 'N/A', 'break', 'incorrect'),
(220, 163, 'The âwhileâ loop runs at least once even if the condition is false.', 'N/A', 'False', 'incorrect'),
(221, 163, 'What is the correct way to define a class in Python?', 'N/A', 'class Car:', 'incorrect'),
(222, 163, 'The âelifâ keyword is short for âelse ifâ.', 'N/A', 'True', 'incorrect'),
(223, 163, 'What is the output of: for value in {', 'N/A', 'aco', 'incorrect'),
(224, 163, 'Lists in Python are immutable.', 'N/A', 'False', 'incorrect'),
(225, 163, 'What does the len() function return?', 'N/A', 'The number of elements', 'incorrect'),
(226, 164, 'How many hashes (#) does the code output to the screen?\r\n\r\nfloor = 0\r\nwhile floor != 0:\r\n    floor -= 1\r\n    print(', 'N/A', '#', 'incorrect'),
(227, 164, 'Build a line of code which asks the user for a float value and assigns it to the level variable.\r\n\r\nUse the Tools:\r\n=, ==, ), (, int, ', 'N/A', 'level = float (input ( \"Enter a flight level\" ))', 'incorrect'),
(228, 164, 'Build a line of code in order to obtain a loop which executes its body with the number variable going through values -2, 0, and 2 (in the same order).\r\n\r\nUse these Tools:\r\n\r\n-1, 0, -2, number, for, ), (, in, range, 1, 2, 3, 4 :', 'N/A', 'for number in range( -2, 4, 2 ):', 'incorrect'),
(229, 164, 'What will happen when the user runs the following code?\r\n\r\ntotal = 0\r\nfor i in range(4):\r\n    if 2 * i < 4:\r\n        total += 1\r\n    else:\r\n        total += 1\r\nprint(total)', 'N/A', 'The code outputs 4.', 'incorrect'),
(230, 164, 'What is the expected output of the following code?\r\n\r\ncounter = 10 * 4 - 5\r\nif counter > 0:\r\n    print(', 'N/A', '*', 'incorrect'),
(231, 164, 'Which of the following Expressions evaluate to a non-zero result?\r\n(Select two answers)', '', '2 + -2 / 2 + 2|2 + 2 * 2 // 2', 'incorrect'),
(232, 164, 'A program written in a high-level programing language is called:', 'N/A', 'a source code', 'incorrect'),
(233, 164, 'What is the expected output of the following code?\r\n\r\nequals = 0\r\nfor i in range(2):\r\n    for j in range(2):\r\n      if i == j:\r\n         equals += 1\r\n      else:\r\n         equals += 1\r\nprint(equals)', 'N/A', '4', 'incorrect'),
(234, 164, 'Arrange the code correctly to form a conditional instruction which guarantees that a certain statement is executed when the speed variable is less than 50.0.\r\n\r\nUse these Tools:\r\n\r\n:, <, >, speed, if, 50.0', 'N/A', 'if speed < 50.0 :', 'incorrect'),
(235, 164, 'Assuming that the following assignment has been successfully executed:\r\n\r\nthe_list = [\'list\',True, 3e0]\r\n\r\nWhich of the following expressions evaluate to True?', 'N/A', 'int(the_list[2]) == len(the_list)|the_list[1] in the_list', 'incorrect'),
(236, 164, 'What is the expected results of the following code?\r\n\r\nrates = (10, 20, 55.5, ', 'N/A', '2', 'incorrect'),
(237, 164, 'What is the expected output of the following code?\r\n\r\ncollection = []\r\ncollection.insert(0, 2)\r\ncollection.append(3)\r\nduplicate = collection\r\nduplicate.append(2)\r\nprint(collection[-1] + duplicate[-1])', 'N/A', '4', 'incorrect'),
(238, 164, 'Choose the correct answer which is align as the data types below:\r\n42, -6.62607015e-34, \'//\'\', False, ', 'N/A', 'INTEGER, FLOAT, STRING, BOOLEAN, STRING', 'incorrect'),
(239, 164, 'What is the expected output of the following code? If the freeway speed is 120 and urban areas is 100.\r\n\r\nurban = 100\r\nspeed = 120\r\nwhile speed > 0:\r\n    speed -= 20\r\n    if speed == urban:\r\n       break\r\n    print(', 'N/A', 'The code producers no output.', 'incorrect'),
(240, 164, 'Which is the correct order which reflects their priority, where the left-most position has the highest priority and the right has the lowest priority.', 'N/A', '*, +, -', 'incorrect'),
(241, 164, 'A process in which the source code is translated into machine code in order to be executed later is called:', 'N/A', 'compilation', 'incorrect'),
(242, 164, 'Build a line of code which asks the user for a integer value and assigns it to the counter variable.\r\n\r\nUse the Tools:\r\n\r\n=, ==, ), (, int, ', 'N/A', 'counter = int (input ( \"Enter a flight level\" ))', 'incorrect'),
(243, 164, 'What is the expected output of the following code?\r\n\r\nspeed = 3\r\nwhile speed > 0:\r\n    speed += 2\r\n    if speed == 7:\r\n       break\r\n    print(', 'N/A', '*', 'incorrect'),
(244, 164, 'What happens when the user runs the following code?\r\n\r\nspeed = 2\r\nwhile speed < 0:\r\n    speed += 2\r\n    if speed == 5:\r\n       break\r\n    print(', 'N/A', '*', 'incorrect'),
(245, 164, 'Assuming that the phone_dir dictionary contains name: number pairs, choose the code arranged correctly to create a valid line of code which adds John Wick\'s phone number (5551122333) to the directory.\r\n\r\nUse these tools:\r\n\r\n] , =, ', 'N/A', 'phone_dir [ \"John Wick\" ] = \"5551122333\"', 'incorrect'),
(246, 165, 'What is true about tuples?\r\n(Select two answers)', '', 'Tuples can be index and sliced like lists.|An empty tuple is written as().', 'incorrect'),
(247, 165, 'Which of the following Expressions evaluate to a non-zero result?\r\n(Select two answers)', '', '2 + -2 / 2 + 2|2 + 2 * 2 // 2', 'incorrect'),
(248, 165, 'What is the expected output of the following code?\r\n\r\nequals = 0\r\nfor i in range(2):\r\n    for j in range(2):\r\n      if i == j:\r\n         equals += 1\r\n      else:\r\n         equals += 1\r\nprint(equals)', 'N/A', '4', 'incorrect'),
(249, 165, 'Choose the correct answer which is align as the data types below:\r\n42, -6.62607015e-34, \'//\'\', False, ', 'N/A', 'INTEGER, FLOAT, STRING, BOOLEAN, STRING', 'incorrect'),
(250, 165, 'What is the expected results of the following code?\r\n\r\nrates = (10, 20, 55.5, ', 'N/A', '2', 'incorrect'),
(251, 165, 'Build a line of code in order to obtain a loop which executes its body with the number variable going through values -2, 0, and 2 (in the same order).\r\n\r\nUse these Tools:\r\n\r\n-1, 0, -2, number, for, ), (, in, range, 1, 2, 3, 4 :', 'N/A', 'for number in range( -2, 4, 2 ):', 'incorrect'),
(252, 165, 'Which box would you insert to this code to build a program which prints ', 'N/A', 'except', 'incorrect'),
(253, 165, 'What is the expected output of the following code?\r\n\r\ncounter = 10 * 4 - 5\r\nif counter > 0:\r\n    print(', 'N/A', '*', 'incorrect'),
(254, 165, 'Arrange the code correctly to form a conditional instruction which guarantees that a certain statement is executed when the speed variable is less than 50.0.\r\n\r\nUse these Tools:\r\n\r\n:, <, >, speed, if, 50.0', 'N/A', 'if speed < 50.0 :', 'incorrect'),
(255, 165, 'Assuming that the following assignment has been successfully executed:\r\n\r\nmy_list = [1, 4, 3, 2]\r\n\r\nSelect the expressions which will not raise any exception.\r\n(Select two expressions.)', '', 'my_list[ my_list[-1] ]|my_list[1:1]', 'incorrect'),
(256, 165, 'Which of the following correctly defines a function which returns its only argument doubled?\r\n(Select two)\r\n\r\nA)\r\n  def times_2(j):\r\n      return j + j\r\n\r\n\r\nB)\r\n  def multiply_by_2:\r\n      value += 2\r\n\r\nC)\r\n  def double(val):\r\n      return 2 * val\r\n\r\nD)\r\n  def 2_times_arg(in):\r\n      return 2 * in', '', 'A|D', 'incorrect'),
(257, 165, 'What is true about exceptions in Python?\r\n(select two answers)', '', 'According to python terminology, exceptions are raised.|Not more than one exception branch can be executed in one try-catch block.', 'incorrect'),
(258, 165, 'What is the expected output of the following code?\r\n\r\nspeed = 3\r\nwhile speed > 0:\r\n    speed += 2\r\n    if speed == 7:\r\n       break\r\n    print(', 'N/A', '*', 'incorrect'),
(259, 165, 'What happens when the user runs the following code?\r\n\r\nspeed = 2\r\nwhile speed < 0:\r\n    speed += 2\r\n    if speed == 5:\r\n       break\r\n    print(', 'N/A', '*', 'incorrect'),
(260, 165, 'What will happen when the user runs the following code?\r\n\r\ntotal = 0\r\nfor i in range(4):\r\n    if 2 * i < 4:\r\n        total += 1\r\n    else:\r\n        total += 1\r\nprint(total)', 'N/A', 'The code outputs 4.', 'incorrect'),
(261, 165, 'What is the expected result of running the following code?\r\n\r\ndef do_the_mass(parameter):\r\n    parameter[0] += variable\r\n    return parameter[0]\r\n\r\nthe_list = [x for x in range(2,3)]\r\nvariable = -1\r\ndo_the_mass(the_list)\r\nprint(the_list[0])\r\n', 'N/A', 'The code outputs 1.', 'incorrect'),
(262, 165, 'Assuming that the following assignment has been successfully executed:\r\n\r\nthe_list = [\'list\',True, 3e0]\r\n\r\nWhich of the following expressions evaluate to True?', 'N/A', 'int(the_list[2]) == len(the_list)|the_list[1] in the_list', 'incorrect'),
(263, 165, 'Assuming that the phone_dir dictionary contains name: number pairs, choose the code arranged correctly to create a valid line of code which adds John Wick\'s phone number (5551122333) to the directory.\r\n\r\nUse these tools:\r\n\r\n] , =, ', 'N/A', 'phone_dir [ \"John Wick\" ] = \"5551122333\"', 'incorrect'),
(264, 165, 'Which is the correct order which reflects their priority, where the left-most position has the highest priority and the right has the lowest priority.', 'N/A', '*, +, -', 'incorrect'),
(265, 165, 'Build a line of code which asks the user for a integer value and assigns it to the counter variable.\r\n\r\nUse the Tools:\r\n\r\n=, ==, ), (, int, ', 'N/A', 'counter = int (input ( \"Enter a flight level\" ))', 'incorrect'),
(266, 166, 'What is the expected output of the following code?\r\n\r\ndef count(stop, start):\r\n    print(start, end=', 'N/A', '1 2', 'incorrect'),
(267, 166, 'Assuming that the following assignment has been successfully executed:\r\n\r\nmy_list = [1, 4, 3, 2]\r\n\r\nSelect the expressions which will not raise any exception.\r\n(Select two expressions.)', '', 'my_list[ my_list[-1] ]|my_list[1:1]', 'incorrect'),
(268, 166, 'Arrange the code correctly to form a conditional instruction which guarantees that a certain statement is executed when the speed variable is less than 50.0.\r\n\r\nUse these Tools:\r\n\r\n:, <, >, speed, if, 50.0', 'N/A', 'if speed < 50.0 :', 'incorrect'),
(269, 166, 'What is the expected out put of the following code?\r\n\r\nmenu = {', 'N/A', '.45', 'incorrect'),
(270, 166, 'What is the expected output of the following code?\r\n\r\ncounter = 10 * 4 - 5\r\nif counter > 0:\r\n    print(', 'N/A', '*', 'incorrect'),
(271, 166, 'Which of the following Expressions evaluate to a non-zero result?\r\n(Select two answers)', '', '2 + -2 / 2 + 2|2 + 2 * 2 // 2', 'incorrect'),
(272, 166, 'What is the expected result of the following code?\r\ndef walk(down):\r\n    if down == 0:\r\n        return 0\r\n    return down + walk(down - 1)\r\n        \r\nprint(walk(3))', 'N/A', '6', 'incorrect'),
(273, 166, 'A process in which the source code is translated into machine code in order to be executed later is called:', 'N/A', 'compilation', 'incorrect'),
(274, 166, 'What is the expected output of the following code?\r\n\r\ndef runner(brand, model=', 'N/A', 'The code raises an unhandled exception', 'incorrect'),
(275, 166, 'What is the expected output of the following code?\r\n\r\nequals = 0\r\nfor i in range(2):\r\n    for j in range(2):\r\n      if i == j:\r\n         equals += 1\r\n      else:\r\n         equals += 1\r\nprint(equals)', 'N/A', '4', 'incorrect'),
(276, 166, 'To run the code given as a source file whose name has the .py extention, you need to have:', 'N/A', 'a Python interpreter', 'incorrect'),
(277, 166, 'What is the expected output of the following code?\r\n\r\ncollection = []\r\ncollection.insert(0, 2)\r\ncollection.append(3)\r\nduplicate = collection\r\nduplicate.append(2)\r\nprint(collection[-1] + duplicate[-1])', 'N/A', '4', 'incorrect'),
(278, 166, 'Build a line of code which asks the user for a float value and assigns it to the level variable.\r\n\r\nUse the Tools:\r\n=, ==, ), (, int, ', 'N/A', 'level = float (input ( \"Enter a flight level\" ))', 'incorrect'),
(279, 166, 'Which is the correct order which reflects their priority, where the left-most position has the highest priority and the right has the lowest priority.', 'N/A', '*, +, -', 'incorrect'),
(280, 166, 'Which of the following correctly defines a function which returns its only argument doubled?\r\n(Select two)\r\n\r\nA)\r\n  def times_2(j):\r\n      return j + j\r\n\r\n\r\nB)\r\n  def multiply_by_2:\r\n      value += 2\r\n\r\nC)\r\n  def double(val):\r\n      return 2 * val\r\n\r\nD)\r\n  def 2_times_arg(in):\r\n      return 2 * in', '', 'A|D', 'incorrect'),
(281, 166, 'What is true about exceptions in Python?\r\n(select two answers)', '', 'According to python terminology, exceptions are raised.|Not more than one exception branch can be executed in one try-catch block.', 'incorrect'),
(282, 166, 'Build a line of code which prints the values assigned to the width and height variable separated by a multiplication sign (*)\r\n\r\nGiven:\r\n       width, height = 100, 120\r\n\r\nuse these tools\r\n\r\ninput, (, ', 'N/A', 'print ( width, height, sep=\"*\" )', 'incorrect'),
(283, 166, 'What is the expected output of the following code?\r\npower = 1\r\nwhile power < 5:\r\n    power += 1\r\n    print(', 'N/A', 'The code producers two at signs ( @@ )', 'incorrect'),
(284, 166, 'What will happen when the user runs the following code?\r\n\r\ntotal = 0\r\nfor i in range(4):\r\n    if 2 * i < 4:\r\n        total += 1\r\n    else:\r\n        total += 1\r\nprint(total)', 'N/A', 'The code outputs 4.', 'incorrect'),
(285, 166, 'Build a line of code in order to obtain a loop which executes its body with the number variable going through values -2, 0, and 2 (in the same order).\r\n\r\nUse these Tools:\r\n\r\n-1, 0, -2, number, for, ), (, in, range, 1, 2, 3, 4 :', 'N/A', 'for number in range( -2, 4, 2 ):', 'incorrect'),
(286, 167, 'What is the expected output of the following code? If the freeway speed is 120 and urban areas is 100.\r\n\r\nurban = 100\r\nspeed = 120\r\nwhile speed > 0:\r\n    speed -= 20\r\n    if speed == urban:\r\n       break\r\n    print(', 'The code producers no output.', 'The code producers no output.', 'correct'),
(287, 167, 'What is the expected result of the following code?\r\ndef walk(down):\r\n    if down == 0:\r\n        return 0\r\n    return down + walk(down - 1)\r\n        \r\nprint(walk(3))', '6', '6', 'correct'),
(288, 167, 'A process in which the source code is translated into machine code in order to be executed later is called:', 'interpretation', 'compilation', 'incorrect'),
(289, 167, 'Build a line of code which asks the user for a integer value and assigns it to the counter variable.\r\n\r\nUse the Tools:\r\n\r\n=, ==, ), (, int, ', 'counter = int (input ( ', 'counter = int (input ( \"Enter a flight level\" ))', 'incorrect'),
(290, 167, 'Build a line of code which asks the user for a float value and assigns it to the level variable.\r\n\r\nUse the Tools:\r\n=, ==, ), (, int, ', 'level = float (input ( ', 'level = float (input ( \"Enter a flight level\" ))', 'incorrect'),
(291, 167, 'What is the expected output of the following code?\r\n\r\nspeed = 3\r\nwhile speed > 0:\r\n    speed += 2\r\n    if speed == 7:\r\n       break\r\n    print(', '*', '*', 'correct'),
(292, 167, 'What is the expected output of the following code?\r\n\r\ndef runner(brand, model=', 'The code raises an unhandled exception', 'The code raises an unhandled exception', 'correct'),
(293, 167, 'A binary code consist of:', 'a sequence of bits which encodes machine instructions', 'a sequence of bits which encodes machine instructions', 'correct'),
(294, 167, 'Build a line of code in order to obtain a loop which executes its body with the number variable going through values -2, 0, and 2 (in the same order).\r\n\r\nUse these Tools:\r\n\r\n-1, 0, -2, number, for, ), (, in, range, 1, 2, 3, 4 :', 'for number in range( -2, 4, 2 ):', 'for number in range( -2, 4, 2 ):', 'correct'),
(295, 167, 'What is the expected out put of the following code?\r\n\r\nmenu = {', '.45', '.45', 'correct'),
(296, 167, 'Assuming that the phone_dir dictionary contains name: number pairs, choose the code arranged correctly to create a valid line of code which adds John Wick\'s phone number (5551122333) to the directory.\r\n\r\nUse these tools:\r\n\r\n] , =, ', 'phone_dir [ ', 'phone_dir [ \"John Wick\" ] = \"5551122333\"', 'incorrect'),
(297, 167, 'To run the code given as a source file whose name has the .py extention, you need to have:', 'a Python interpreter', 'a Python interpreter', 'correct'),
(298, 167, 'What is true about exceptions in Python?\r\n(select two answers)', 'According to python terminology, exceptions are raised.|Not more than one exception branch can be executed in one try-catch block.', 'According to python terminology, exceptions are raised.|Not more than one exception branch can be executed in one try-catch block.', 'correct'),
(299, 167, 'Assuming that the following assignment has been successfully executed:\r\n\r\nmy_list = [1, 4, 3, 2]\r\n\r\nSelect the expressions which will not raise any exception.\r\n(Select two expressions.)', 'my_list[ my_list[-1] ]|my_list[1:1]', 'my_list[ my_list[-1] ]|my_list[1:1]', 'correct'),
(300, 167, 'What is the expected output of the following code?\r\n\r\ndef count(stop, start):\r\n    print(start, end=', '1 2 ', '1 2', 'incorrect'),
(301, 167, 'What is the expected output of the following code?\r\n\r\nequals = 0\r\nfor i in range(2):\r\n    for j in range(2):\r\n      if i == j:\r\n         equals += 1\r\n      else:\r\n         equals += 1\r\nprint(equals)', '4', '4', 'correct'),
(302, 167, 'What is the expected output of the following code?\r\n\r\ncounter = 10 * 4 - 5\r\nif counter > 0:\r\n    print(', '*', '*', 'correct'),
(303, 167, 'What is the expected result of the following code?\r\n\r\ndef velocity(x):\r\n    return speed * x\r\n\r\nspeed = 2\r\nnew_speed = velocity(2)\r\nnew_speed = velocity(speed)\r\nprint(new_speed)\r\n', '4', '4', 'correct'),
(304, 167, 'Which box would you insert to this code to build a program which prints ', 'except', 'except', 'correct'),
(305, 167, 'What is the expected result of running the following code?\r\n\r\ndef do_the_mass(parameter):\r\n    parameter[0] += variable\r\n    return parameter[0]\r\n\r\nthe_list = [x for x in range(2,3)]\r\nvariable = -1\r\ndo_the_mass(the_list)\r\nprint(the_list[0])\r\n', 'The code outputs 1.', 'The code outputs 1.', 'correct');

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL,
  `course_name` varchar(255) NOT NULL,
  `total_marks` int(11) NOT NULL,
  `time` varchar(50) NOT NULL,
  `exam_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`course_id`, `course_name`, `total_marks`, `time`, `exam_date`) VALUES
(3, 'Python Entry Level', 10, '30', '2025-10-31'),
(5, 'PECP 302 Exam', 30, '30', '2025-10-31');

-- --------------------------------------------------------

--
-- Table structure for table `exams`
--

CREATE TABLE `exams` (
  `exam_id` int(11) NOT NULL,
  `std_id` varchar(45) NOT NULL,
  `course_name` varchar(45) NOT NULL,
  `total_marks` int(45) NOT NULL,
  `obt_marks` int(45) DEFAULT NULL,
  `date` varchar(45) DEFAULT NULL,
  `start_time` varchar(45) NOT NULL,
  `end_time` varchar(45) DEFAULT NULL,
  `exam_time` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lectures`
--

CREATE TABLE `lectures` (
  `user_id` int(11) NOT NULL DEFAULT 0,
  `first_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `user_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password` char(60) NOT NULL,
  `user_type` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `contact_no` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `city` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `address` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lectures`
--

INSERT INTO `lectures` (`user_id`, `first_name`, `last_name`, `user_name`, `email`, `password`, `user_type`, `contact_no`, `city`, `address`) VALUES
(2, 'Siyabonga', 'Patel', '94827361', 'sp@live.mut.ac.za', '$2a$10$dl4mh4mfotxv7ZdT7ai5cubsvalZIzrl3ueb2ay5B1sPoI0rIbMUe', 'student', '0712345678', 'Durban', 'Umhlanga, Durban'),
(5, 'Sneha', 'Dlamini', '25461378', 'sd@live.mut.ac.za', '$2a$10$dl4mh4mfotxv7ZdT7ai5cubsvalZIzrl3ueb2ay5B1sPoI0rIbMUe', 'student', '0765678901', 'Durban', 'Isipingo, Durban'),
(6, 'Thandi', 'Zuma', '12345678', 'tz@live.mut.ac.za', '$2a$10$dl4mh4mfotxv7ZdT7ai5cubsvalZIzrl3ueb2ay5B1sPoI0rIbMUe', 'staff', '0796789012', 'Durban', 'Phoenix, Durban'),
(9, 'Kabelo', 'Dube', '64178239', 'kd@live.mut.ac.za', '$2a$10$dl4mh4mfotxv7ZdT7ai5cubsvalZIzrl3ueb2ay5B1sPoI0rIbMUe', 'student', '0749012345', 'Durban', 'Congella, Durban'),
(10, 'Anaya', 'Khumalo', '15834927', 'ak@live.mut.ac.za', '$2a$10$dl4mh4mfotxv7ZdT7ai5cubsvalZIzrl3ueb2ay5B1sPoI0rIbMUe', 'student', '0790123456', 'Durban', 'Durban North, Durban');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `question_id` int(11) NOT NULL,
  `course_name` varchar(45) NOT NULL,
  `question` longtext NOT NULL,
  `opt1` longtext NOT NULL,
  `opt2` longtext NOT NULL,
  `opt3` longtext DEFAULT NULL,
  `opt4` longtext DEFAULT NULL,
  `correct` longtext NOT NULL,
  `question_type` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`question_id`, `course_name`, `question`, `opt1`, `opt2`, `opt3`, `opt4`, `correct`, `question_type`) VALUES
(1, 'Python Entry Level', 'Python is a compiled language.', 'True', 'False', NULL, NULL, 'False', 'TrueFalse'),
(2, 'Python Entry Level', 'Which keyword is used to define a function in Python?', 'func', 'define', 'def', 'lambda', 'def', 'MultipleChoice'),
(3, 'Python Entry Level', 'What data type is the result of 3 / 2 in Python 3?', 'int', 'float', 'double', 'str', 'float', 'MultipleChoice'),
(4, 'Python Entry Level', 'Which of these is used to create a comment in Python?', '//', '#', '--', '/* */', '#', 'MultipleChoice'),
(5, 'Python Entry Level', 'Lists in Python are immutable.', 'True', 'False', NULL, NULL, 'False', 'TrueFalse'),
(6, 'Python Entry Level', 'What is the correct file extension for Python files?', '.pt', '.pyt', '.py', '.python', '.py', 'MultipleChoice'),
(7, 'Python Entry Level', 'Which statement is used to stop a loop in Python?', 'exit', 'stop', 'break', 'quit', 'break', 'MultipleChoice'),
(8, 'Python Entry Level', 'The “elif” keyword is short for “else if”.', 'True', 'False', NULL, NULL, 'True', 'TrueFalse'),
(9, 'Python Entry Level', 'What function is used to get user input from the console?', 'input()', 'read()', 'get()', 'scan()', 'input()', 'MultipleChoice'),
(10, 'Python Entry Level', 'Which of these data types is ordered and changeable?', 'tuple', 'set', 'list', 'dictionary', 'list', 'MultipleChoice'),
(11, 'Python Entry Level', 'A tuple in Python can be modified after creation.', 'True', 'False', NULL, NULL, 'False', 'TrueFalse'),
(12, 'Python Entry Level', 'Which keyword is used to handle exceptions in Python?', 'try', 'handle', 'catch', 'error', 'try', 'MultipleChoice'),
(13, 'Python Entry Level', 'Python uses indentation to define code blocks.', 'True', 'False', NULL, NULL, 'True', 'TrueFalse'),
(14, 'Python Entry Level', 'What is the output of len([10,20,30])?', '2', '3', '4', '5', '3', 'MultipleChoice'),
(15, 'Python Entry Level', 'Which function returns the largest item in a list?', 'big()', 'max()', 'largest()', 'top()', 'max()', 'MultipleChoice'),
(16, 'Python Entry Level', 'Which symbol is used for floor division in Python?', '/', '//', '%', '**', '//', 'MultipleChoice'),
(17, 'Python Entry Level', 'The “while” loop runs at least once even if the condition is false.', 'True', 'False', NULL, NULL, 'False', 'TrueFalse'),
(18, 'Python Entry Level', 'Which keyword is used to create a class in Python?', 'object', 'struct', 'class', 'define', 'class', 'MultipleChoice'),
(19, 'Python Entry Level', 'What does the “append()” method do to a list?', 'Adds an item to the end', 'Removes an item', 'Sorts the list', 'Deletes all items', 'Adds an item to the end', 'MultipleChoice'),
(20, 'Python Entry Level', 'Which of these is a valid variable name in Python?', '2var', '_var', 'my-var', 'var name', '_var', 'MultipleChoice'),
(21, 'Python Entry Level', 'Which of the following is NOT a valid Python data type?', 'list', 'tuple', 'record', 'set', 'record', 'MultipleChoice'),
(22, 'Python Entry Level', 'What symbol is used to start a comment in Python?', '#', '//', '--', '/*', '#', 'MultipleChoice'),
(23, 'Python Entry Level', 'Which method adds an item to the end of a list?', 'add()', 'append()', 'insert()', 'push()', 'append()', 'MultipleChoice'),
(25, 'Python Entry Level', 'What is the output of: print(2 ** 3)?', '5', '6', '8', '9', '8', 'MultipleChoice'),
(26, 'Python Entry Level', 'Which loop is used when the number of iterations is unknown?', 'for', 'while', 'loop', 'repeat', 'while', 'MultipleChoice'),
(27, 'Python Entry Level', 'In Python, indentation is used to:', 'Mark code comments', 'Indicate code blocks', 'Separate functions', 'Create new variables', 'Indicate code blocks', 'MultipleChoice'),
(28, 'Python Entry Level', 'What will be the output of print(10 // 3)?', '3', '3.3', '4', 'Error', '3', 'MultipleChoice'),
(29, 'Python Entry Level', 'What keyword is used to handle exceptions?', 'catch', 'try', 'error', 'rescue', 'try', 'MultipleChoice'),
(30, 'Python Entry Level', 'Which of the following is a valid variable name?', '1variable', 'var_1', 'var-1', 'var 1', 'var_1', 'MultipleChoice'),
(31, 'Python Entry Level', 'Python identifiers are case-sensitive.', 'True', 'False', NULL, NULL, 'True', 'TrueFalse'),
(32, 'Python Entry Level', 'What function is used to display output to the screen?', 'show()', 'output()', 'display()', 'print()', 'print()', 'MultipleChoice'),
(33, 'Python Entry Level', 'Which keyword is used to exit a loop prematurely?', 'stop', 'exit', 'break', 'quit', 'break', 'MultipleChoice'),
(34, 'Python Entry Level', 'What is the correct way to define a class in Python?', 'object Car:', 'define Car:', 'class Car:', 'function Car:', 'class Car:', 'MultipleChoice'),
(35, 'Python Entry Level', 'Which operator is used to check equality in Python?', '=', '==', '===', '!=', '==', 'MultipleChoice'),
(36, 'Python Entry Level', 'What is the result of bool(0)?', 'True', 'False', NULL, NULL, 'False', 'TrueFalse'),
(37, 'Python Entry Level', 'What does the len() function return?', 'The number of elements', 'The size in bytes', 'The last element', 'The type of data', 'The number of elements', 'MultipleChoice'),
(38, 'Python Entry Level', 'Which data structure allows duplicate elements?', 'set', 'dictionary', 'tuple', 'list', 'list', 'MultipleChoice'),
(39, 'Python Entry Level', 'The keyword “elif” stands for “else if”.', 'True', 'False', NULL, NULL, 'True', 'TrueFalse'),
(41, 'Python Entry Level', 'Assuming the assignment the_list = [\"list\", False, 3e0] has executed, which of these evaluate to True? (Select two)', 'int(the_list[2]) == len(the_list)', '300 in the_list and the_list[1]', 'the_list[1] in the_list', 'the_list.index(False) == 1', 'int(the_list[2]) == len(the_list), the_list.index(False) == 1', 'MultipleChoice'),
(42, 'Python Entry Level', 'Which line correctly adds Oliver Twist’s phone number 5551122333 to the dictionary phone_dir?', 'phone_dir[\"Oliver Twist\"] = \"5551122333\"', 'phone_dir = [\"Oliver Twist\", \"5551122333\"]', 'phone_dir(\"Oliver Twist\") = 5551122333', 'add(phone_dir, \"Oliver Twist\": \"5551122333\")', 'phone_dir[\"Oliver Twist\"] = \"5551122333\"', 'MultipleChoice'),
(46, 'Python Entry Level', 'Given the function do_the_mass(parameter), what does the following code print? the_list=[x for x in range(2,3)]; variable=-1; do_the_mass(the_list); print(the_list[0])', '2', '0', '1', 'Raises an exception', '1', 'MultipleChoice'),
(47, 'Python Entry Level', 'Which are true about exceptions in Python? (Select two)', 'Exceptions are raised, not thrown.', 'Multiple except branches can execute per try.', 'Python encourages graceful error handling.', 'Exceptions are always ignored.', 'Exceptions are raised, not thrown; Python encourages graceful error handling.', 'MultipleChoice'),
(48, 'Python Entry Level', 'Which code will print “Out of bounds” when list index fails?', 'try: prices=[2.39,4.99,0.99]; selection=prices[3]; print(\"Ok\") except IndexError: print(\"Out of bounds\")', 'try: ... except: ...', 'try: ... default: ...', 'None of the above', 'try: prices=[2.39,4.99,0.99]; selection=prices[3]; print(\"Ok\") except IndexError: print(\"Out of bounds\")', 'MultipleChoice'),
(49, 'Python Entry Level', 'Which function definitions correctly double the input? (Select two)', 'def times_2(x): return x + x', 'def multiply_by_2: value += 2', 'def 2_times_arg(in): return 2 * in', 'def double(value): return 2 * value', 'times_2, double', 'MultipleChoice'),
(50, 'Python Entry Level', 'What will be printed by runner(model=\"Reluctance\", 2019)[1]?', 'Reluctance', 'The code raises an unhandled exception.', 'True', 'e', 'e', 'MultipleChoice'),
(51, 'Python Entry Level', 'Which of these functions can be called with two arguments?', 'def kappa(level): pass', 'def iota(level, size=0): pass', 'def mu(None): pass', 'def lambda(): pass', 'def iota(level, size=0): pass', 'MultipleChoice'),
(52, 'Python Entry Level', 'What is the output of: def count(start): print(start,end=\" \"); if start>0: count(start-1); count(3)', '3 2 1', '0 1 2 3', '3 2 1 0', '1 2 3', '3 2 1 0', 'MultipleChoice'),
(53, 'Python Entry Level', 'What happens in this code? def velocity(x): return speed*x; speed=10; new_speed=velocity(10); new_speed=velocity(speed); print(new_speed)', 'Error: variable not defined', '30', '10', '20', 'Error: variable not defined', 'MultipleChoice'),
(96, 'PECP 302 Exam', 'A program written in a high-level programing language is called:', 'a binary code', 'machine code', 'a source code', 'the ASCII code', 'a source code', 'MCQ'),
(97, 'PECP 302 Exam', 'Build a line of code which asks the user for a float value and assigns it to the level variable.\r\n\r\nUse the Tools:\r\n=, ==, ), (, int, \"Enter a flight level\", input, float, :', 'level = int (input ( \"Enter a flight level\" )) :', 'level : float (input ( \"Enter a flight level\" ))', 'level = float (input ( \"Enter a flight level\" ))', 'level == float (input ( \"Enter a flight level\" ))', 'level = float (input ( \"Enter a flight level\" ))', 'MCQ'),
(98, 'PECP 302 Exam', 'A process in which the source code is translated into machine code in order to be executed later is called:', 'linking', 'compilation', 'edition', 'interpretation', 'compilation', 'MCQ'),
(99, 'PECP 302 Exam', 'Choose the correct answer which is align as the data types below:\r\n42, -6.62607015e-34, \'//\'\', False, \"All the King\'s Men\"', 'INTEGER, BOOLEAN, STRING, FLOAT, STRING', 'INTEGER, FLOAT, STRING, BOOLEAN, STRING', 'INTEGER, FLOAT, STRING, BOOLEAN, STRING', 'ERROR', 'INTEGER, FLOAT, STRING, BOOLEAN, STRING', 'MCQ'),
(100, 'PECP 302 Exam', 'Which of the following Expressions evaluate to a non-zero result?\r\n(Select two answers)', '2 + -2 / 2 + 2', '2 - 2 * 2 + 2', '2 // 2 * 2 - 2', '2 + 2 * 2 // 2', '2 + -2 / 2 + 2|2 + 2 * 2 // 2', 'MultipleSelect'),
(101, 'PECP 302 Exam', 'Build a line of code which asks the user for a integer value and assigns it to the counter variable.Use the Tools:=, ==, ), (, int, ', 'counter : float (input ( ', 'counter = int (input ( ', 'counter = int (input ( ', 'counter = input (int ( ', 'counter = int (input ( ', 'MCQ'),
(102, 'PECP 302 Exam', 'Which is the correct order which reflects their priority, where the left-most position has the highest priority and the right has the lowest priority.', '-, +, *', '+ , /, -', '*, +, -', '+, *, -', '*, +, -', 'MCQ'),
(103, 'PECP 302 Exam', 'Build a line of code in order to obtain a loop which executes its body with the number variable going through values -2, 0, and 2 (in the same order).\r\n\r\nUse these Tools:\r\n\r\n-1, 0, -2, number, for, ), (, in, range, 1, 2, 3, 4 :', 'for number in range( -2, 4, 2 ):', 'for number in range( -2, 2, 2 ):', 'for number in range( -2, 0, 2 ):', 'for number in range( 2, 4, -2 ):', 'for number in range( -2, 4, 2 ):', 'MCQ'),
(104, 'PECP 302 Exam', 'Arrange the code correctly to form a conditional instruction which guarantees that a certain statement is executed when the speed variable is less than 50.0.\r\n\r\nUse these Tools:\r\n\r\n:, <, >, speed, if, 50.0', 'if < speed : 50.0', 'if speed > 50.0 :', 'if : speed > 50.0', 'if speed < 50.0 :', 'if speed < 50.0 :', 'MCQ'),
(105, 'PECP 302 Exam', 'What is the expected output of the following code?\r\n\r\nequals = 0\r\nfor i in range(2):\r\n    for j in range(2):\r\n      if i == j:\r\n         equals += 1\r\n      else:\r\n         equals += 1\r\nprint(equals)', '4', '1', 'The code outputs nothing', '3', '4', 'MCQ'),
(106, 'PECP 302 Exam', 'What is the expected output of the following code?\r\n\r\ncounter = 10 * 4 - 5\r\nif counter > 0:\r\n    print(\"*\")\r\nelif counter >= 35:\r\n    print(\"**\")\r\nelse:\r\n    print(\"***\")', '**', '*', '***', 'The code producers no output.', '*', 'MCQ'),
(107, 'PECP 302 Exam', 'What happens when the user runs the following code?\r\n\r\nspeed = 2\r\nwhile speed < 0:\r\n    speed += 2\r\n    if speed == 5:\r\n       break\r\n    print(\"*\", end=\"\")\r\nelse:\r\n    print(\"*\")', '**', '*', '***', 'The code producers no output.', '*', 'MCQ'),
(108, 'PECP 302 Exam', 'What is the expected output of the following code?\r\n\r\nspeed = 3\r\nwhile speed > 0:\r\n    speed += 2\r\n    if speed == 7:\r\n       break\r\n    print(\"*\", end=\"\")\r\nelse:\r\n    print(\"*\")', '*', '**', '***', 'The code producers no output.', '*', 'MCQ'),
(109, 'PECP 302 Exam', 'What is the expected output of the following code? If the freeway speed is 120 and urban areas is 100.\r\n\r\nurban = 100\r\nspeed = 120\r\nwhile speed > 0:\r\n    speed -= 20\r\n    if speed == urban:\r\n       break\r\n    print(\"*\", end=\"\")\r\nelse:\r\n    print(\"*\")\r\n', '*', '**', '***', 'The code producers no output.', 'The code producers no output.', 'MCQ'),
(110, 'PECP 302 Exam', 'How many hashes (#) does the code output to the screen?\r\n\r\nfloor = 0\r\nwhile floor != 0:\r\n    floor -= 1\r\n    print(\"#\", end=\"\")\r\nelse:\r\n    print(\"#\")', '#', '##', '###', 'Zero (The code outputs nothing)', '#', 'MCQ'),
(111, 'PECP 302 Exam', 'What will happen when the user runs the following code?\r\n\r\ntotal = 0\r\nfor i in range(4):\r\n    if 2 * i < 4:\r\n        total += 1\r\n    else:\r\n        total += 1\r\nprint(total)', 'The code outputs 3.', 'The code enters an infinite loop.', 'The code outputs 4.', 'The code outputs 2.', 'The code outputs 4.', 'MCQ'),
(112, 'PECP 302 Exam', 'What is the expected results of the following code?\r\n\r\nrates = (10, 20, 55.5, \"1kg\")\r\nnew = rates[3:]\r\nfor rate in rates[-1:]:\r\n    new += (rate,)\r\nprint(len(new))', '1', 'The code will cause an unhandled exception..', '2', '5', '2', 'MCQ'),
(113, 'PECP 302 Exam', 'What is the expected output of the following code?\r\n\r\ncollection = []\r\ncollection.insert(0, 2)\r\ncollection.append(3)\r\nduplicate = collection\r\nduplicate.append(2)\r\nprint(collection[-1] + duplicate[-1])', '4', '6', '5', 'The code raises an exception and outputs nothing.', '4', 'MCQ'),
(114, 'PECP 302 Exam', 'Assuming that the following assignment has been successfully executed:\r\n\r\nthe_list = [\'list\',True, 3e0]\r\n\r\nWhich of the following expressions evaluate to True?', 'int(the_list[2]) == len(the_list)', '300 in the_list and the_list[1]', 'the_list[1] in the_list', 'the_list.index(True) == 0', 'int(the_list[2]) == len(the_list)|the_list[1] in the_list', 'MultipleSelect'),
(115, 'PECP 302 Exam', 'Assuming that the phone_dir dictionary contains name: number pairs, choose the code arranged correctly to create a valid line of code which adds John Wick\'s phone number (5551122333) to the directory.\r\n\r\nUse these tools:\r\n\r\n] , =, \"John Wick\", [, phone_dir, \"5551122333\"\r\n', '\"John Wick\"  [ phone_dir ] = \"5551122333\"', 'phone_dir = [ \"John Wick\" ] \"5551122333\"', 'phone_dir [ \"5551122333\" ] = \"John Wick\"', 'phone_dir [ \"John Wick\" ] = \"5551122333\"', 'phone_dir [ \"John Wick\" ] = \"5551122333\"', 'MCQ'),
(116, 'PECP 302 Exam', 'Assuming that the following assignment has been successfully executed:\r\n\r\nmy_list = [1, 4, 3, 2]\r\n\r\nSelect the expressions which will not raise any exception.\r\n(Select two expressions.)', 'my_list[ my_list[-1] ]', 'my_list[4]', 'my_list[1:1]', 'my_list[-5]', 'my_list[ my_list[-1] ]|my_list[1:1]', 'MultipleSelect'),
(117, 'PECP 302 Exam', 'What is true about tuples?\r\n(Select two answers)', 'The len() function cannot be applied to tuples.', 'Tuples can be index and sliced like lists.', 'Tuples are immutable, which mean they cannot be changed during their life time.', 'An empty tuple is written as().', 'Tuples can be index and sliced like lists.|An empty tuple is written as().', 'MultipleSelect'),
(118, 'PECP 302 Exam', 'What is the expected out put of the following code?\r\n\r\nmenu = {\"coke\": 9.50, \"burger\": 34.99, \"chips\": 15.99 }\r\n\r\nfor key in menu.value():\r\n    print(str(key)[1], end=\"\")', '9.50', 'cokeburgerchips', '.45', '9.534.9915.99', '.45', 'MCQ'),
(119, 'PECP 302 Exam', 'What is the expected result of running the following code?\r\n\r\ndef do_the_mass(parameter):\r\n    parameter[0] += variable\r\n    return parameter[0]\r\n\r\nthe_list = [x for x in range(2,3)]\r\nvariable = -1\r\ndo_the_mass(the_list)\r\nprint(the_list[0])\r\n', 'The code outputs 1.', 'The code outputs -1.', 'The code outputs 2.', 'The code outputs 0.', 'The code outputs 1.', 'MCQ'),
(120, 'PECP 302 Exam', 'What is true about exceptions in Python?\r\n(select two answers)', 'According to python terminology, exceptions are raised.', 'Not more than one exception branch can be executed in one try-catch block.', 'Python\'s philosophy encouranges developers to make all posible efforts to protect the program from the occurence of exception.', 'According to python terminology, exception are thrown.', 'According to python terminology, exceptions are raised.|Not more than one exception branch can be executed in one try-catch block.', 'MultipleSelect'),
(121, 'PECP 302 Exam', 'Which box would you insert to this code to build a program which prints \"Out of bounds\" to screen.\r\n(one code box will be used.)\r\n\r\ncode boxes:\r\nexcept IndexError,  except,  default\r\n\r\nCode snippet:\r\n\r\nprices = [2.39, 4.99, 0.99]\r\ntry:\r\n   selection = prices[3]\r\n   print(\"OK\")\r\n   [ insert box ]\r\n   print(\"Out of bounds\")\r\n   print(\"Failed\")\r\n\r\n', 'except IndexError', 'except', 'default', '', 'except', 'MCQ'),
(122, 'PECP 302 Exam', 'Which of the following correctly defines a function which returns its only argument doubled?\r\n(Select two)\r\n\r\nA)\r\n  def times_2(j):\r\n      return j + j\r\n\r\n\r\nB)\r\n  def multiply_by_2:\r\n      value += 2\r\n\r\nC)\r\n  def double(val):\r\n      return 2 * val\r\n\r\nD)\r\n  def 2_times_arg(in):\r\n      return 2 * in', 'A', 'B', 'C', 'D', 'A|D', 'MultipleSelect'),
(123, 'PECP 302 Exam', 'What is the expected output of the following code?\r\n\r\ndef runner(brand, model=\"\", year=2021, convertible=True):\r\n    return brand + model + str(convertible)\r\n\r\nprint(runner(model=\"reluctance\", 2019)[1])', 'The code raises an unhandled exception', 'Reluctance', 'True', 'e', 'The code raises an unhandled exception', 'MCQ'),
(124, 'PECP 302 Exam', 'Which of the following function can be invoked with two arguments?\r\n\r\nA)\r\n  def kappa(level):\r\n      pass\r\n\r\n\r\nB)\r\n  def iota(level, size=0):\r\n      pass\r\n\r\nC)\r\n  def mu(None):\r\n      pass\r\n\r\nD)\r\n  def lamba():\r\n      pass\r\n              ', 'A', 'B', 'C', 'D', 'B', 'MCQ'),
(125, 'PECP 302 Exam', 'What is the expected output of the following code?def walk(stop, start):    print(start, end=', '3 2 1', '0 1 2 3', '3 2 1 0', '1 2', '1 2', 'MCQ'),
(126, 'PECP 302 Exam', 'What is the expected result of the following code?\r\n\r\ndef velocity(x):\r\n    return speed * x\r\n\r\nspeed = 2\r\nnew_speed = velocity(2)\r\nnew_speed = velocity(speed)\r\nprint(new_speed)\r\n', '8', '4', '2', 'The code producers error as output.', '4', 'MCQ'),
(127, 'PECP 302 Exam', 'Build a line of code which prints the values assigned to the width and height variable separated by a multiplication sign (*)\r\n\r\nGiven:\r\n       width, height = 100, 120\r\n\r\nuse these tools\r\n\r\ninput, (, \";\", print, end=\"\", ), width, height,  sep=\"*\",', 'print ( width; height, sep=\"*\" )', 'input ( width, height, sep=\"*\" )', 'print ( width, height, end=\"*\" )', 'print ( width, height, sep=\"*\" )', 'print ( width, height, sep=\"*\" )', 'MCQ'),
(128, 'PECP 302 Exam', 'A program which is used to transform source file into an executable binary file is called:', 'an IDE', 'a compiler', 'a debugger', 'an interpreter', 'a compiler', 'MCQ'),
(129, 'PECP 302 Exam', 'What is the expected output of the following code?\r\npower = 1\r\nwhile power < 5:\r\n    power += 1\r\n    print(\"@\", end=\"\")\r\n    if power == 3:\r\n        break\r\nelse:\r\n    print(\"@\")', 'The code producers one at sign( @ )', 'The code producers two at signs ( @@ )', 'The code producers Three at signs ( @@@ )', 'The code enter an infinite loop.', 'The code producers two at signs ( @@ )', 'MCQ'),
(130, 'PECP 302 Exam', 'What is the expected result of the following code?\r\ndef walk(down):\r\n    if down == 0:\r\n        return 0\r\n    return down + walk(down - 1)\r\n        \r\nprint(walk(3))', '0', '2', '3', '6', '6', 'MCQ'),
(131, 'PECP 302 Exam', 'To run the code given as a source file whose name has the .py extention, you need to have:', 'Python compiler', 'Terminal', 'windows', 'a Python interpreter', 'a Python interpreter', 'MCQ'),
(132, 'PECP 302 Exam', 'A binary code consist of:', 'a set of a certain alphabet symbols', 'a sequence of bits which encodes machine instructions', 'a list of keywords', 'a sequence ASCII characters', 'a sequence of bits which encodes machine instructions', 'MCQ');

-- --------------------------------------------------------

--
-- Table structure for table `results`
--

CREATE TABLE `results` (
  `exam_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `obtained_marks` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `id` int(11) NOT NULL,
  `email` varchar(256) NOT NULL,
  `staffNum` varchar(6) NOT NULL,
  `FullNames` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`id`, `email`, `staffNum`, `FullNames`) VALUES
(4, 'Ndovela@mut.ac.za', '778899', 'Mrs Ndovela'),
(16, 'mutangamb@mut.ac.za.com', '987654', 'Dr Mutanga'),
(17, 'motsilili.phomolo@mut.ac.za', '112233', 'Mr Motshilili');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `user_id` int(11) NOT NULL,
  `first_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `user_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password` char(60) NOT NULL,
  `user_type` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `contact_no` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `city` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `address` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`user_id`, `first_name`, `last_name`, `user_name`, `email`, `password`, `user_type`, `contact_no`, `city`, `address`) VALUES
(63, 'Siphelele', 'Maphumulo', '21904759', '21904759@live.mut.ac.za', '$2a$10$1qzMw6eVYftDVZZvhUasaufjWUTqFbm6xSVr9JwtMjJKC96IDCWrS', 'student', '0686764623', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `name` varchar(25) NOT NULL,
  `age` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `first_name` varchar(256) NOT NULL,
  `last_name` varchar(256) DEFAULT NULL,
  `user_name` varchar(256) NOT NULL,
  `email` varchar(256) NOT NULL,
  `password` char(60) NOT NULL,
  `user_type` varchar(256) NOT NULL,
  `contact_no` varchar(256) DEFAULT NULL,
  `city` varchar(256) DEFAULT NULL,
  `address` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='		';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `first_name`, `last_name`, `user_name`, `email`, `password`, `user_type`, `contact_no`, `city`, `address`) VALUES
(1, 'K', 'Mzobe', '1234567', 'Mzobe@mut.ac.za', '$2a$10$A7c283MFCHYoA8psRQnd3eeTYdjLaOcppG8Q2tlCGU7XncHM0Kk5a', 'lecture', '0651245787', 'Durban', 'Kwahlabisa, Bhekeceleni Road'),
(2, 'Siphelele', 'Maphumulo', '21904759', '21904759@live.mut.ac.za', '$2a$10$1qzMw6eVYftDVZZvhUasaufjWUTqFbm6xSVr9JwtMjJKC96IDCWrS', 'student', '0686764623', 'Durban', 'Umlazi S 210 Road 2'),
(3, '246810', 'Marlo', '246810', 'Dr.Marlo@mut.ac.za', '$2a$10$TBxhCxJtZYAZ8/6abSPt0eiLIvUsOmcmYAZ0PKFLulM1puR0Kecie', 'admin', '0678956233', 'Durban', '82 Bluff Road Aparthment 25'),
(31, 'Jabu', 'Pule', '7654321', '7654321@live.mut.ca.za', '$2a$10$TBxhCxJtZYAZ8/6abSPt0eiLIvUsOmcmYAZ0PKFLulM1puR0Kecie', 'student', '0311234567', 'Durban', 'Enandi, Mbhatha Road, 26'),
(32, 'Palisa', 'Mzwiri', '6543210', '6543210@live.mut.ac.za', '$2a$10$40yAhPxkyvEUPw3n7czFouJVxg5NXFSaLtxBgxsIL/6hYdGZMZTBK', 'student', '0316543210', 'Johannesburg', 'Sandton, Van Ribik Ave. 421'),
(37, 'S', 'Mhlongo', '219047', 'SMhlongo@mut.ac.za', '$2a$10$4Th3h9oPy0YjUo86xjEhw.oitziQlvO2b/X8JmHVfSkscvAkdcOyS', 'student', '0316543289', 'Durban', 'Umlazi S210, 210'),
(52, 'P', 'Ndovela', '778899', 'Ndovela@mut.ac.za', '$2a$10$dl4mh4mfotxv7ZdT7ai5cubsvalZIzrl3ueb2ay5B1sPoI0rIbMUe', 'lecture', '0316543210', 'Durban', 'Viale Ferdinando Baldelli, 41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`answer_id`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`course_id`),
  ADD UNIQUE KEY `course_name` (`course_name`);

--
-- Indexes for table `exams`
--
ALTER TABLE `exams`
  ADD PRIMARY KEY (`exam_id`);

--
-- Indexes for table `lectures`
--
ALTER TABLE `lectures`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`question_id`);

--
-- Indexes for table `results`
--
ALTER TABLE `results`
  ADD PRIMARY KEY (`exam_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `answers`
--
ALTER TABLE `answers`
  MODIFY `answer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=306;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `course_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `exams`
--
ALTER TABLE `exams`
  MODIFY `exam_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=168;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `results`
--
ALTER TABLE `results`
  ADD CONSTRAINT `results_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`),
  ADD CONSTRAINT `results_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
