CREATE TABLE admins (
    admin_id INT NOT NULL,
    admin_level TINYINT NOT NULL,
    admin_account VARCHAR(100) NOT NULL,
    admin_password VARCHAR(10) NOT NULL,
    admin_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (admin_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO admins (admin_id, admin_level, admin_account, admin_password, admin_name) VALUES
(1, 2, 'recimo@gmail.com', 'G2Recimo', 'Recimo'),
(2, 1, 'admin@test.com', '123456', '小R(測試人員)'),
(3, 1, 'tom@gmail.com', '123456', 'tom'),
(4, 1, 'wei@gmail.com', '123456', 'wei'),
(5, 1, 'helenKuo@gmail.com', '888888', 'HelenKuo'),
(6, 1, 'pei@gmail.com', 'Aa111111', 'pei'),
(7, 1, 'yutung@gmail.com', 'yutung123', 'yutung'),
(8, 1, 'hsu@test.com', '123456', 'Hsu'),
(9, 0, '123@test.com', '123456', '小小R(測試停用)');