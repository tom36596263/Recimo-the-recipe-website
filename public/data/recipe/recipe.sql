-- 1. 建立資料表 (如果還沒建立)
CREATE TABLE IF NOT EXISTS recipes (
    recipe_id INT PRIMARY KEY,
    author_id INT,
    linked_product_id INT NULL,
    parent_recipe_id INT NULL,
    personal_folder_id INT NULL,
    adaptation_title VARCHAR(255) NULL,
    adaptation_note TEXT NULL,
    recipe_title VARCHAR(255),
    recipe_image_url VARCHAR(255),
    recipe_descreption TEXT,
    recipe_servings INT,
    recipe_total_time TIME,
    recipe_difficulty DECIMAL(3,1),
    recipe_like_count INT,
    recipe_kcal_per_100g DECIMAL(10,2),
    recipe_protein_per_100g DECIMAL(10,2),
    recipe_fat_per_100g DECIMAL(10,2),
    recipe_carbs_per_100g DECIMAL(10,2),
    status INT,
    recipe_created_at DATETIME,
    recipe_last_updated DATETIME
);

-- 2. 匯入資料
INSERT INTO recipes (
    recipe_id, author_id, linked_product_id, parent_recipe_id, personal_folder_id, 
    adaptation_title, adaptation_note, recipe_title, recipe_image_url, 
    recipe_descreption, recipe_servings, recipe_total_time, recipe_difficulty, 
    recipe_like_count, recipe_kcal_per_100g, recipe_protein_per_100g, 
    recipe_fat_per_100g, recipe_carbs_per_100g, status, recipe_created_at, recipe_last_updated
) VALUES 
(1, 1, NULL, NULL, NULL, NULL, NULL, '經典瑪格麗特披薩', 'img/recipes/1/cover.png', '義大利最經典的披薩，以新鮮羅勒、莫札瑞拉起司與番茄糊組成，完美呈現紅白綠三色。', 2, '01:30:00', 3.0, 0, 245.5, 10.3, 7.9, 33.1, 0, '2026-01-15 20:00:00', '2026-01-15 20:00:00'),
(2, 1, NULL, NULL, NULL, NULL, NULL, '抹茶熔岩蛋糕', 'img/recipes/2/cover.png', '口感濃郁的抹茶蛋糕，切開時有如岩漿般的抹茶巧克力流出，是抹茶控絕不能錯過的甜點。', 2, '00:40:00', 3.5, 0, 412.5, 7.9, 27.2, 34.6, 0, '2026-01-15 20:10:00', '2026-01-15 20:10:00'),
(3, 1, NULL, NULL, NULL, NULL, NULL, '四川宮保雞丁', 'img/recipes/3/cover.png', '川菜精髓之一，講究「糊辣荔枝味」，口感酸甜微麻，搭配酥脆花生與滑嫩雞丁，非常下飯。', 2, '00:35:00', 3.0, 0, 208.6, 15.8, 12.8, 7.4, 0, '2026-01-15 20:30:00', '2026-01-15 20:30:00'),
(4, 1, NULL, NULL, NULL, NULL, NULL, '奶油松露野菇寬麵', 'img/recipes/4/cover.png', '濃郁的鮮奶油與高品質黑松露醬交織出極致香氣，搭配嚼勁十足的寬麵與焦香野菇，是西餐廳等級的美味。', 1, '00:25:00', 2.5, 0, 215.8, 6.4, 13.2, 18.5, 0, '2026-01-15 20:35:00', '2026-01-15 20:35:00'),
(5, 1, NULL, NULL, NULL, NULL, NULL, '泰式青咖哩雞', 'img/recipes/5/cover.png', '道地的泰式經典名菜，青咖哩醬的辛辣與椰奶的香醇交織，搭配滑嫩雞腿肉與掃取醬汁精華的茄子，香氣誘人。', 3, '00:40:00', 3.0, 0, 165.8, 6.5, 12.8, 6.2, 0, '2026-01-15 20:40:00', '2026-01-15 20:40:00'),
(6, 1, NULL, NULL, NULL, NULL, NULL, '經典班尼迪克蛋', 'img/recipes/6/cover.png', '早午餐中的王者。酥脆的馬芬鋪上鹹香培根與完美的半熟水波蛋，最後淋上濃郁絲滑的荷蘭醬，口感極其豐富。', 2, '00:30:00', 4.0, 0, 285.4, 11.2, 22.5, 14.8, 0, '2026-01-15 20:50:00', '2026-01-15 20:50:00'),
(7, 1, NULL, NULL, NULL, NULL, NULL, '濃厚豚骨叉燒拉麵', 'img/recipes/7/cover.png', '道地的日式拉麵。乳白色的濃厚豚骨湯底，搭配低溫烹調的叉燒與半熟溏心蛋，每一口都能感受到滿滿的膠原蛋白與誠意。', 1, '00:20:00', 2.0, 0, 118.5, 5.8, 6.2, 9.4, 0, '2026-01-15 21:00:00', '2026-01-15 21:00:00'),
(8, 1, NULL, NULL, NULL, NULL, NULL, '經典自製鷹嘴豆泥', 'img/recipes/8/cover.png', '中東地區最具代表性的國民美食。以鷹嘴豆與塔希尼芝麻醬交織出濃郁風味，口感綿密滑順。', 2, '00:15:00', 1.5, 0, 270.6, 8.0, 18.5, 20.7, 0, '2026-01-15 21:10:00', '2026-01-15 21:10:00'),
(9, 1, NULL, NULL, NULL, NULL, NULL, '法式洋蔥濃湯', 'img/recipes/9/cover.png', '法式料理的經典靈魂。透過長時間慢火拌炒，將洋蔥的辛辣轉化為深邃的焦糖甜味。', 2, '01:10:00', 3.5, 0, 85.4, 3.8, 4.2, 7.1, 0, '2026-01-15 21:15:00', '2026-01-15 21:15:00'),
(10, 1, NULL, NULL, NULL, NULL, NULL, '蒜香檸檬烤大蝦', 'img/recipes/10/cover.png', '簡單卻不失華麗的宴客料理。大虎蝦經過蒜末與黑胡椒醃漬入味，搭配奶油與檸檬片烘烤。', 2, '00:30:00', 2.0, 0, 128.5, 18.9, 5.8, 0.7, 0, '2026-01-15 21:20:00', '2026-01-15 21:20:00');