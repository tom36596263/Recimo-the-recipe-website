-- 1. 建立資料表 (整合自增主鍵與欄位設定)
CREATE TABLE IF NOT EXISTS `order_products` (
  `order_product_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `snapshot_price` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `subtotal` int(11) NOT NULL,
  
  -- 定義主鍵
  PRIMARY KEY (`order_product_id`),
  
  -- 定義索引與外鍵約束
  CONSTRAINT `fk_order` FOREIGN KEY (`order_id`) 
    REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) 
    REFERENCES `products` (`product_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 插入初始化資料 (欄位名稱同步小寫)
INSERT INTO `order_products` (
  `order_product_id`, `order_id`, `product_id`, `product_name`, `snapshot_price`, `quantity`, `subtotal`
) VALUES
(1, 111018, 1, '舒肥雞胸藜麥飯', 160, 1, 160),
(2, 111018, 4, '豆腐漢堡排佐野菇', 150, 1, 150),
(3, 111019, 2, '香煎鮭魚糙米便當', 200, 1, 200),
(4, 111019, 4, '豆腐漢堡排佐野菇', 150, 1, 150);