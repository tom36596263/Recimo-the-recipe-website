-- 創建資料表
CREATE TABLE meal_plan_cover_template (
    cover_template_id INT NOT NULL PRIMARY KEY,
    template_url VARCHAR(255) NOT NULL,
    template_name VARCHAR(50) NOT NULL
);

-- 匯入 11 筆封面圖資料
INSERT INTO meal_plan_cover_template (cover_template_id, template_url, template_name) VALUES
(1, 'img/mealplan/camping_landscape.png', '山林露營風景'),
(2, 'img/mealplan/bonfire_icon.png', '野炊時光'),
(3, 'img/mealplan/tent_icon.png', '露營趣'),
(4, 'img/mealplan/picnic_icon.png', '戶外野餐'),
(5, 'img/mealplan/bbq_icon.png', '燒烤派對'),
(6, 'img/mealplan/burger_icon.png', '美式速食'),
(7, 'img/mealplan/noodle_icon.png', '麵食主義'),
(8, 'img/mealplan/seafood_icon.png', '鮮美海鮮'),
(9, 'img/mealplan/steak_icon.png', '精選排餐'),
(10, 'img/mealplan/coffee_icon.png', '咖啡午茶'),
(11, 'img/mealplan/bread_icon.png', '手作烘焙');