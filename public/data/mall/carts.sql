CREATE TABLE `carts` (
  `carts_id` INT PRIMARY KEY NOT NULL ,
  `user_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  -- 設定外來鍵約束，確保資料一致性
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
);

-- 匯入測試資料
INSERT INTO `carts` (`carts_id`, `user_id`, `product_id`, `quantity`) VALUES 
(1, 1, 1, 2),
(2, 1, 10, 1),
(3, 3, 5, 3),
(4, 5, 20, 1),
(5, 7, 15, 5);