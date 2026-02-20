-- 1. 如果資料表已存在，先刪除（若要保留原資料請跳過此行）
DROP TABLE IF EXISTS meal_plan_cover_template;

-- 2. 重新創建資料表
CREATE TABLE meal_plan_cover_template (
    cover_template_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    template_url VARCHAR(255) NOT NULL,
    template_name VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 匯入最新的 12 筆封面圖資料
INSERT INTO meal_plan_cover_template (cover_template_id, template_url, template_name) VALUES
(1, 'img/plan-covers/template/1.svg', '山林風景'),
(2, 'img/plan-covers/template/2.svg', '野炊時光'),
(3, 'img/plan-covers/template/3.svg', '露營趣'),
(4, 'img/plan-covers/template/4.svg', '戶外野餐'),
(5, 'img/plan-covers/template/5.svg', '燒烤派對'),
(6, 'img/plan-covers/template/6.svg', '美式速食'),
(7, 'img/plan-covers/template/7.svg', '麵食主義'),
(8, 'img/plan-covers/template/8.svg', '慶祝派對'),
(9, 'img/plan-covers/template/9.svg', '精選排餐'),
(10, 'img/plan-covers/template/10.svg', '咖啡午茶'),
(11, 'img/plan-covers/template/11.svg', '手作烘焙'),
(12, 'img/plan-covers/template/12.svg', '健身飲食');