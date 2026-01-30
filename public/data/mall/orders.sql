-- 1. 建立資料表 (整合自增主鍵、欄位設定與外鍵)
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `logistics_id` varchar(50) DEFAULT NULL,
  `subtotal` int(11) NOT NULL,
  `discount_amount` int(11) DEFAULT '0',
  `shipping_fee` int(11) DEFAULT '0',
  `total_amount` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `recipient_name` varchar(50) NOT NULL,
  `recipient_phone` varchar(20) NOT NULL,
  `shipping_address` varchar(255) NOT NULL,
  `order_status` int(11) NOT NULL DEFAULT '0',
  `payment_method` int(11) NOT NULL,
  `payment_status` int(11) NOT NULL DEFAULT '0',
  
  PRIMARY KEY (`order_id`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 插入初始化資料
INSERT INTO `orders` (
  `order_id`, `user_id`, `logistics_id`, `subtotal`, `discount_amount`, `shipping_fee`, 
  `total_amount`, `created`, `recipient_name`, `recipient_phone`, `shipping_address`, 
  `order_status`, `payment_method`, `payment_status`
) VALUES
(111018, 1, '1211031', 310, 0, 0, 310, '2026-01-22 10:00:00', '王小花', '0952875365', '桃園市中壢區中正路111號', 1, 1, 1),
(111019, 2, '1211031', 350, 0, 0, 350, '2026-01-22 10:00:00', '張小花', '0952875365', '桃園市中壢區中正路111號', 1, 1, 1);