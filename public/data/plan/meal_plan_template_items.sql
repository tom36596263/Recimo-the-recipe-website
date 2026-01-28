-- 創建資料表
CREATE TABLE meal_plan_template_items (
    item_id INT NOT NULL PRIMARY KEY,
    template_id INT NOT NULL,
    recipe_id INT NOT NULL,
    day_number INT NOT NULL,
    meal_type TINYINT NOT NULL COMMENT '0:早餐, 1:午餐, 2:晚餐',
    sort_order INTEGER NOT NULL,
    CONSTRAINT fk_item_template FOREIGN KEY (template_id) 
        REFERENCES meal_plan_templates(template_id),
    CONSTRAINT fk_item_recipe FOREIGN KEY (recipe_id) 
        REFERENCES recipes(recipe_id)
);

-- 匯入 49 筆明細資料
INSERT INTO meal_plan_template_items (item_id, template_id, recipe_id, day_number, meal_type, sort_order) VALUES
-- Template 1 Items (ID 1-13)
(1, 1, 11, 1, 1, 1), (2, 1, 8, 1, 1, 2), (3, 1, 15, 1, 2, 1), (4, 1, 58, 1, 2, 2),
(5, 1, 45, 2, 0, 1), (6, 1, 12, 2, 1, 1), (7, 1, 55, 2, 1, 2), (8, 1, 14, 2, 2, 1),
(9, 1, 34, 3, 0, 1), (10, 1, 62, 3, 1, 1), (11, 1, 10, 3, 1, 2), (12, 1, 20, 3, 2, 1), (13, 1, 54, 3, 2, 2),
-- Template 2 Items (ID 14-21)
(14, 2, 52, 1, 1, 1), (15, 2, 51, 1, 1, 2), (16, 2, 49, 2, 2, 1), (17, 2, 53, 2, 2, 2),
(18, 2, 50, 3, 2, 1), (19, 2, 17, 4, 2, 1), (20, 2, 51, 4, 2, 2), (21, 2, 52, 5, 1, 1),
-- Template 3 Items (ID 22-31)
(22, 3, 32, 1, 0, 1), (23, 3, 35, 1, 0, 2), (24, 3, 33, 2, 0, 1), (25, 3, 34, 2, 0, 2),
(26, 3, 2, 3, 0, 1), (27, 3, 38, 3, 0, 2), (28, 3, 40, 4, 0, 1), (29, 3, 42, 4, 0, 2),
(30, 3, 41, 5, 0, 1), (31, 3, 43, 5, 0, 2),
-- Template 4 Items (ID 32-40)
(32, 4, 26, 1, 2, 1), (33, 4, 66, 1, 2, 2), (34, 4, 55, 1, 2, 3), (35, 4, 30, 2, 2, 1),
(36, 4, 28, 2, 2, 2), (37, 4, 31, 2, 2, 3), (38, 4, 3, 3, 2, 1), (39, 4, 29, 3, 2, 2), (40, 4, 56, 3, 2, 3),
-- Template 5 Items (ID 41-49)
(41, 5, 1, 1, 2, 1), (42, 5, 23, 1, 2, 2), (43, 5, 9, 1, 2, 3), (44, 5, 62, 2, 1, 1),
(45, 5, 4, 2, 2, 1), (46, 5, 25, 2, 2, 2), (47, 5, 63, 3, 2, 1), (48, 5, 22, 3, 2, 2), (49, 5, 24, 3, 2, 3);