CREATE TABLE `users` (
  `user_id` INT PRIMARY KEY NOT NULL,
  `user_name` VARCHAR(10) NOT NULL,
  `user_email` VARCHAR(40) NOT NULL,
  `user_phone` VARCHAR(10),
  `user_address` VARCHAR(40),
  `user_password` VARCHAR(10) NOT NULL,
  `user_startdate` DATETIME  NOT NULL,
  `user_url` VARCHAR(100),
  `is_verified` BOOLEAN NOT NULL,
  `is_active` BOOLEAN NOT NULL
);
INSERT INTO `users` (`user_id`, `user_name`, `user_email`, `user_phone`, `user_address`, `user_password`, `user_startdate`, `user_url`, `is_verified`, `is_active`) VALUES
(1, 'Recimo官方', 'recimo@gmail.com', '0912345678', '桃園市中壢區復興路46號8樓', 'G2Recimo', '2025-12-09 00:00:00', '/img/site/Recimo_avatar.svg', 1, 1),
(2, '小R(測試人員)', 'admin@test.com', '0923456789', '桃園市中壢區復興路46號9樓', '123456', '2020-01-22 22:25:00', NULL, 1, 1),
(3, 'tom', 'tom@gmail.com', '0934567890', '桃園市中壢區復興路46號8樓', '123456', '2026-01-27 19:30:00', '/img/site/T_avatar.svg', 1, 1),
(4, 'wei', 'wei@gmail.com', '0945678901', '桃園市中壢區復興路46號8樓', '123456', '2026-01-27 19:30:00', '/img/site/W_avatar.svg', 0, 1),
(5, 'HelenKuo', 'helenKuo@gmail.com', '0956789012', '桃園市中壢區復興路46號8樓', '888888', '2026-01-27 19:30:00', '/img/site/H_avatar.svg', 1, 1),
(6, 'pei', 'pei@gmail.com', '0911111111', '桃園市中壢區復興路46號8樓', 'Aa111111', '2026-01-23 16:20:00', '/img/site/P_avatar.svg', 1, 1),
(7, 'yutung', 'yutung@gmail.com', '0922222222', '桃園市中壢區復興路46號8樓', 'yutung123', '2026-01-27 19:30:00', '/img/site/yutung_avatar.svg', 1, 1),
(8, 'Hsu', 'hsu@test.com', '0933333333', '桃園市中壢區復興路46號8樓', '123456', '2026-01-27 19:30:00', '/img/site/H_avatar.svg', 1, 1),
(9, '小小R(測試停用)', '123@test.com', '0900000000', '桃園市中壢區復興路46號9樓', '123456', '2026-01-27 20:00:00', NULL, 1, 0);