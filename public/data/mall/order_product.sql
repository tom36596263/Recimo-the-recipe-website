-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- 主機： localhost:8889
-- 產生時間： 2026-01-28 07:42:01
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
-- 資料表結構 `order_product`
--

CREATE TABLE `order_product` (
  `ORDER_PRODUCT_ID` int(11) NOT NULL COMMENT '明細ID (主鍵)',
  `ORDER_ID` bigint(20) NOT NULL COMMENT '訂單ID (外鍵)',
  `PRODUCT_ID` int(11) NOT NULL COMMENT '產品ID',
  `PRODUCT_NAME` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '產品名稱 (建議新增此欄位做快照)',
  `SNAPSHOT_PRICE` int(11) NOT NULL COMMENT '訂購時單價',
  `QUANTITY` int(11) NOT NULL COMMENT '訂購數量',
  `SUBTOTAL` int(11) NOT NULL COMMENT '項目小計'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `order_product`
--

INSERT INTO `order_product` (`ORDER_PRODUCT_ID`, `ORDER_ID`, `PRODUCT_ID`, `PRODUCT_NAME`, `SNAPSHOT_PRICE`, `QUANTITY`, `SUBTOTAL`) VALUES
(1, 111018, 1, '舒肥雞胸藜麥飯', 160, 1, 160),
(2, 111018, 4, '豆腐漢堡排佐野菇', 150, 1, 150),
(3, 111019, 2, '香煎鮭魚糙米便當', 200, 1, 200),
(4, 111019, 4, '豆腐漢堡排佐野菇', 150, 1, 150);

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `order_product`
--
ALTER TABLE `order_product`
  ADD PRIMARY KEY (`ORDER_PRODUCT_ID`),
  ADD KEY `fk_order` (`ORDER_ID`),
  ADD KEY `fk_product` (`PRODUCT_ID`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `order_product`
--
ALTER TABLE `order_product`
  MODIFY `ORDER_PRODUCT_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '明細ID (主鍵)', AUTO_INCREMENT=5;

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `order_product`
--
ALTER TABLE `order_product`
  ADD CONSTRAINT `fk_order` FOREIGN KEY (`ORDER_ID`) REFERENCES `orders` (`ORDER_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product` FOREIGN KEY (`PRODUCT_ID`) REFERENCES `products` (`PRODUCT_ID`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
