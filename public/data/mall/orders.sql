-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- 主機： localhost:8889
-- 產生時間： 2026-01-28 07:44:58
-- 伺服器版本： 5.7.24
-- PHP 版本： 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫: `recimo_products`
--

-- --------------------------------------------------------

--
-- 資料表結構 `orders`
--

CREATE TABLE `orders` (
  `ORDER_ID` bigint(20) NOT NULL COMMENT '訂單ID (主鍵)',
  `USER_ID` int(11) NOT NULL COMMENT '會員ID',
  `LOGISTICS_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物流ID (建議改為文字型態)',
  `SUBTOTAL` int(11) NOT NULL COMMENT '小計',
  `DISCOUNT_AMOUNT` int(11) DEFAULT '0' COMMENT '折扣金額',
  `SHIPPING_FEE` int(11) DEFAULT '0' COMMENT '運費',
  `TOTAL_AMOUNT` int(11) NOT NULL COMMENT '總實付金額',
  `CREATED` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下單時間',
  `RECIPIENT_NAME` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收件人姓名',
  `RECIPIENT_PHONE` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收件人電話',
  `SHIPPING_ADDRESS` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配送地址',
  `ORDER_STATUS` int(11) NOT NULL DEFAULT '0' COMMENT '訂單狀態: 0訂購成功,1確認,2出貨,3送達,-1取消',
  `PAYMENT_METHOD` int(11) NOT NULL COMMENT '付款方式: 0貨到付款, 1信用卡',
  `PAYMENT_STATUS` int(11) NOT NULL DEFAULT '0' COMMENT '付款狀態: 0未付, 1已付'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `orders`
--

INSERT INTO `orders` (`ORDER_ID`, `USER_ID`, `LOGISTICS_ID`, `SUBTOTAL`, `DISCOUNT_AMOUNT`, `SHIPPING_FEE`, `TOTAL_AMOUNT`, `CREATED`, `RECIPIENT_NAME`, `RECIPIENT_PHONE`, `SHIPPING_ADDRESS`, `ORDER_STATUS`, `PAYMENT_METHOD`, `PAYMENT_STATUS`) VALUES
(111018, 1, '1211031', 310, 0, 0, 310, '2026-01-22 10:00:00', '王小花', '0952875365', '桃園市中壢區中正路111號', 1, 1, 1),
(111019, 2, '1211031', 350, 0, 0, 350, '2026-01-22 10:00:00', '張小花', '0952875365', '桃園市中壢區中正路111號', 1, 1, 1);

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`ORDER_ID`),
  ADD KEY `fk_orders_user` (`USER_ID`);

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`USER_ID`) REFERENCES `users` (`USER_ID`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
