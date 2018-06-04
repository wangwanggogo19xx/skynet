-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: 2018-06-04 07:00:37
-- 服务器版本： 10.1.28-MariaDB
-- PHP Version: 7.1.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mahjong`
--

-- --------------------------------------------------------

--
-- 表的结构 `user`
--

CREATE TABLE `user` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `accountname` char(11) NOT NULL,
  `password` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `headimg` varchar(255) NOT NULL,
  `score` smallint(6) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `user`
--

INSERT INTO `user` (`id`, `accountname`, `password`, `username`, `headimg`, `score`) VALUES
(1, '2014110457', '2014110457', '张汪', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=510921199510132495', -8),
(2, '2015110433', '123456', '庞柄宇', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=51092219960610601X', 11),
(3, '2014110666', '2014110666', '张倩', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=530381199512020523', 0),
(4, '2014110651', '2014110651', '吴红', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=500234199601274407', 0),
(5, '2014110643', '2014110643', '田雪洁', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=620503199608116021', 0),
(6, '2014110437', '2014110437', '宋小玲', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=511523199210135602', 20),
(7, '2014110447', '123456', '杨枫', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=510623199404014977', -16),
(8, '2014110426', '123456', '龙君', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=510422199502050720', -1),
(9, '2014110607', '123456', '杜东波', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=513433199408206639', 0),
(10, '2014110154', '123456', '郑鸿丹', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=51160219970128872X', -1),
(12, '2014110209', '123456', '龚伟伟', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=511623199511207513', 0),
(13, '2014110201', '9828942699', '蔡杰', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=420281199603100835', -3),
(14, '2014110320', '2014110320', '廖国翔', 'http://202.115.194.53:2222/imgSrc.ashx?idCard=450305199605291019', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `accountname` (`accountname`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `user`
--
ALTER TABLE `user`
  MODIFY `id` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
