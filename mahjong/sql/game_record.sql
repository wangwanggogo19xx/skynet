-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: 2018-06-04 07:01:41
-- 服务器版本： 10.1.28-MariaDB
-- PHP Version: 7.1.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+08:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mahjong`
--

-- --------------------------------------------------------

--
-- 表的结构 `game_record`
--

CREATE TABLE `game_record` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `player1` smallint(6) NOT NULL,
  `player1_score` smallint(6) NOT NULL,
  `player2` smallint(6) NOT NULL,
  `player2_score` smallint(6) NOT NULL,
  `player3` smallint(6) NOT NULL,
  `player3_score` smallint(6) NOT NULL,
  `player4` smallint(6) NOT NULL,
  `player4_score` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- CREATE TABLE `game_record` (
--   `id` smallint(6) PRIMARY KEY NOT NULL AUTO_INCREMENT,
--   `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
--   `player1` smallint(6) NOT NULL,
--   `player1_score` smallint(6) NOT NULL,
--   `player2` smallint(6) NOT NULL,
--   `player2_score` smallint(6) NOT NULL,
--   `player3` smallint(6) NOT NULL,
--   `player3_score` smallint(6) NOT NULL,
--   `player4` smallint(6) NOT NULL,
--   `player4_score` smallint(6) NOT NULL,
--   FOREIGN KEY (`player1`) REFERENCES `user` (`id`),
--   FOREIGN KEY (`player2`) REFERENCES `user` (`id`),
--   FOREIGN KEY (`player3`) REFERENCES `user` (`id`),
--   FOREIGN KEY (`player4`) REFERENCES `user` (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
--
-- 转存表中的数据 `game_record`
--

INSERT INTO `game_record` (`id`, `timestamp`, `player1`, `player1_score`, `player2`, `player2_score`, `player3`, `player3_score`, `player4`, `player4_score`) VALUES
(1, '2018-05-11 11:21:30', 10, 0, 1, 0, 8, 0, 7, 0),
(2, '2018-05-06 12:23:55', 10, 0, 1, 0, 8, 0, 7, 0),
(3, '2018-05-06 12:24:45', 10, 0, 1, 0, 8, 0, 7, 0),
(4, '2018-05-06 12:29:34', 10, 0, 1, 0, 8, 0, 7, 0),
(5, '2018-05-06 12:30:32', 10, 0, 1, 0, 8, 0, 7, 0),
(6, '2018-05-06 12:32:43', 10, 0, 1, 0, 8, 0, 7, 0),
(7, '2018-05-06 12:34:03', 10, 0, 1, 0, 8, 0, 7, 0),
(8, '2018-05-07 00:53:04', 1, 1, 7, 0, 6, 0, 10, -1),
(9, '2018-05-07 01:05:14', 10, 1, 1, -4, 7, 0, 6, 3),
(10, '2018-05-07 01:59:02', 1, 6, 7, -1, 6, -2, 2, -3),
(11, '2018-05-07 02:14:12', 1, -3, 2, -2, 7, 1, 6, 4),
(12, '2018-05-07 02:30:19', 1, 0, 2, 1, 7, 0, 6, -1),
(13, '2018-05-07 02:50:07', 1, 2, 2, 1, 7, 1, 6, -4),
(14, '2018-05-07 03:06:58', 1, 3, 6, -1, 2, -3, 7, 1),
(15, '2018-05-07 05:50:07', 2, -6, 1, 1, 6, 4, 7, 1),
(16, '2018-05-07 06:12:53', 1, -1, 2, 4, 6, 1, 7, -4),
(17, '2018-05-07 06:18:13', 1, 4, 2, 4, 6, -2, 7, -6),
(18, '2018-05-07 08:12:29', 1, -4, 2, 1, 6, 4, 8, -1),
(19, '2018-05-07 08:30:50', 1, 0, 2, -5, 7, -1, 6, 6),
(20, '2018-05-07 08:39:04', 1, 1, 2, 1, 7, 2, 6, -4),
(21, '2018-05-07 09:09:58', 1, -8, 6, 4, 7, 1, 2, 3),
(22, '2018-05-07 10:44:52', 1, 0, 2, 2, 7, 0, 6, -2),
(23, '2018-05-07 10:55:18', 1, -5, 2, -1, 7, 6, 6, 0),
(24, '2018-05-07 13:33:10', 1, -3, 2, 1, 6, 3, 7, -1),
(25, '2018-05-07 13:51:05', 1, 4, 2, -2, 6, -3, 7, 1),
(26, '2018-05-07 13:55:17', 1, 4, 2, 0, 6, 1, 7, -5),
(27, '2018-05-07 14:01:01', 1, 6, 2, -2, 6, -2, 7, -2),
(28, '2018-05-08 02:06:41', 2, 1, 1, 2, 7, -4, 6, 1),
(29, '2018-05-08 06:36:00', 1, -2, 7, 1, 2, 8, 6, -7),
(30, '2018-05-08 06:40:58', 1, 1, 7, -3, 2, 1, 6, 1),
(31, '2018-05-08 06:47:10', 1, -3, 7, 1, 2, 0, 6, 2),
(32, '2018-05-08 08:12:58', 1, -2, 1, 1, 1, 0, 1, 1),
(33, '2018-05-08 08:18:04', 1, -3, 1, 1, 1, 1, 1, 1),
(34, '2018-05-08 08:26:51', 1, -5, 1, 4, 1, 1, 1, 0),
(35, '2018-05-08 08:36:37', 1, -10, 1, 2, 1, 1, 1, 7),
(36, '2018-05-08 09:01:00', 1, 1, 1, 0, 1, -2, 1, 1),
(37, '2018-05-08 09:04:29', 1, 2, 1, 1, 1, 0, 1, -3),
(38, '2018-05-08 09:10:54', 1, -1, 1, 1, 1, -1, 1, 1),
(39, '2018-05-08 09:17:17', 1, 1, 1, 6, 1, 3, 1, -10),
(40, '2018-05-08 10:48:54', 1, -2, 1, -3, 1, 4, 1, 1),
(41, '2018-05-08 10:58:11', 1, -4, 1, -4, 1, 2, 1, 6),
(42, '2018-05-08 11:06:59', 1, -1, 1, 1, 1, 0, 1, 0),
(43, '2018-05-08 11:13:20', 1, -4, 1, 1, 1, -1, 1, 4),
(44, '2018-05-08 11:19:33', 1, 2, 1, 1, 1, 3, 1, -6),
(45, '2018-05-08 11:28:32', 1, 1, 1, -2, 1, 1, 1, 0),
(46, '2018-05-08 11:31:59', 1, -4, 1, 0, 1, -8, 1, 12),
(47, '2018-05-08 11:36:28', 1, 2, 1, 1, 1, -4, 1, 1),
(48, '2018-05-08 13:23:55', 1, 0, 2, -2, 6, 1, 7, 1),
(49, '2018-05-09 00:56:17', 2, 6, 1, -8, 7, 1, 6, 1),
(50, '2018-05-09 01:00:54', 2, 1, 1, 1, 7, -1, 6, -1),
(51, '2018-05-09 04:37:00', 6, -3, 1, -2, 7, 1, 2, 4),
(52, '2018-05-10 01:47:37', 1, 2, 2, 2, 6, -4, 7, 0),
(53, '2018-05-10 02:53:08', 1, 0, 6, 0, 2, 0, 7, 0),
(54, '2018-05-10 06:28:57', 1, -7, 2, 1, 7, 8, 6, -2),
(55, '2018-05-10 06:37:15', 1, 0, 2, 0, 6, 0, 7, 0),
(56, '2018-05-10 06:43:28', 1, 0, 2, 0, 6, 0, 7, 0),
(57, '2018-05-10 07:10:07', 1, 0, 2, 0, 7, 0, 6, 0),
(58, '2018-05-10 07:21:50', 1, 0, 2, 0, 6, 0, 7, 0),
(59, '2018-05-10 08:01:05', 2, 0, 1, 0, 6, 0, 7, 0),
(60, '2018-05-10 08:42:35', 1, 0, 2, 0, 6, 0, 7, 0),
(61, '2018-05-10 12:42:22', 13, -3, 1, 4, 6, 1, 2, -2),
(62, '2018-05-10 12:59:11', 1, 0, 6, 0, 2, 0, 13, 0),
(63, '2018-05-11 01:59:36', 1, -1, 2, 1, 6, -1, 7, 1),
(64, '2018-05-11 05:21:03', 1, -5, 2, 2, 6, 4, 7, -1),
(65, '2018-05-11 06:12:34', 1, 1, 2, 7, 7, -8, 6, 0),
(66, '2018-05-11 08:00:10', 1, -1, 6, 1, 2, 1, 7, -1),
(67, '2018-05-11 11:46:47', 1, 0, 2, 1, 6, 1, 7, -2),
(68, '2018-05-11 11:52:16', 1, 8, 2, -14, 6, 2, 7, 4),
(69, '2018-05-11 12:02:05', 1, -8, 2, 1, 6, 6, 7, 1),
(70, '2018-05-11 12:14:21', 1, 0, 2, -2, 6, 0, 7, 2),
(71, '2018-05-11 12:39:20', 1, 0, 2, 1, 7, -1, 6, 0),
(72, '2018-05-11 12:52:03', 1, 0, 2, 1, 7, -1, 6, 0),
(73, '2018-05-12 02:14:27', 2, -4, 1, 2, 7, -2, 6, 4),
(74, '2018-05-12 02:33:40', 1, 0, 10, 0, 12, 0, 8, 0),
(75, '2018-05-12 02:36:50', 2, 0, 3, 0, 7, 0, 6, 0),
(76, '2018-05-12 03:02:31', 1, 4, 7, -8, 2, 2, 6, 2),
(77, '2018-05-12 06:53:01', 6, 0, 1, 0, 7, 0, 2, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `game_record`
--
ALTER TABLE `game_record`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player1` (`player1`),
  ADD KEY `player2` (`player2`),
  ADD KEY `player3` (`player3`),
  ADD KEY `player4` (`player4`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `game_record`
--
ALTER TABLE `game_record`
  MODIFY `id` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- 限制导出的表
--

--
-- 限制表 `game_record`
--
ALTER TABLE `game_record`
  ADD CONSTRAINT `game_record_ibfk_1` FOREIGN KEY (`player1`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `game_record_ibfk_2` FOREIGN KEY (`player2`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `game_record_ibfk_3` FOREIGN KEY (`player3`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `game_record_ibfk_4` FOREIGN KEY (`player4`) REFERENCES `user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
