-- 珮儀0131
UPDATE users SET user_password = CASE 
    WHEN user_id = 1 THEN '$2y$10$otAwsO50/9KXW.zuGNNyq.jatOZXDKHuVTzftlT6.on86I/UIOe0a'
    WHEN user_id = 2 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN user_id = 3 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN user_id = 4 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN user_id = 5 THEN '$2y$10$C55GYF.6P9q256PmvqRUqeQPJ5rwKUiC7DWhsP3WkHfwS.ORx93vO'
    WHEN user_id = 6 THEN '$2y$10$1iCtREvd63kWjolzfW2ByOmx09DrqkZgFpje1.K7bjNYrMf3fCxUC'
    WHEN user_id = 7 THEN '$2y$10$fXS3wuKIFX/IEfJBarvGLe9fsJTiekTxvCuHtR3dRnLEmpo.5ZfEy'
    WHEN user_id = 8 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN user_id = 9 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
END
WHERE user_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9);


-- 言威0201
ALTER TABLE admins ADD UNIQUE(`admin_account`);


-- 玉彤0201：add_products.sql 
-- 產品 12: 美式紐奧良烤雞翅
UPDATE `products` SET 
`product_description` = '正宗紐奧良風味，開啟味蕾的狂歡盛宴！我們選用肉質Ｑ彈的國產雞翅，加入數十種紐奧良靈魂香料（紅椒、大蒜、黑胡椒及多種香草）低溫長時間醃製。每一口都能感受到煙燻的微甜與辛香料的層次，外皮金黃微焦，肉質滑嫩多汁。',
`product_ingredients` = '1.紐奧良醃漬的精選雞翅(三節翅或二節翅)。',
`product_cooking_method` = '1.氣炸鍋(推薦)：無需解凍，溫度設定180°C，氣炸約12~15 分鐘。中途建議翻面一次，色澤更均勻。\r\n2.烤箱：預熱至200°C，放入烤箱烘烤15~18 分鐘即可。\r\n3.微波爐：撕開包裝一角，以800W中高火加熱約3~5 分鐘(口感較軟嫩，皮不會脆)。',
`product_reminder` = '本產品含有大豆、含麩質之穀物(醬油)及其製品。'
WHERE `product_id` = 12;

-- 產品 13: 白酒蒜香蛤蜊麵
UPDATE `products` SET 
`product_description` = '不用精湛廚藝，也能擁有一桌浪漫的義式晚餐。我們選用鮮甜飽滿的蛤蜊，搭配特級初榨橄欖油與大量金黃蒜片，最後以乾爽的白酒提味。每一根麵條都吸飽了海洋的鮮美與酒香的優雅，讓您在家也能享受餐酒館等級的精緻饗宴。',
`product_ingredients` = '1.嚴選海味：採用高溫高壓殺菌技術，保留蛤蜊的原汁原味，顆顆鮮甜。\r\n2.靈魂醬汁：大量蒜末與辛香料慢火煸香，白酒香氣層次分明。3.Q彈麵條：進口杜蘭小麥粉製成，口感扎實，微波或拌炒皆能保持彈牙。',
`product_cooking_method` = '1.平底鍋拌炒(推薦，口感最道地)：將麵條包與醬汁包先行退冰，在平底鍋加入少許油，倒入醬汁包與蛤蜊煮至沸騰，加入麵條均勻拌炒約 1-2 分鐘，待醬汁收濃後即可起鍋。\r\n2.微波加熱：在包裝袋上撕開一個小洞，以 800W 功率微波約 3-4 分鐘，倒出至餐盤中拌勻，灑上內附的香料粉。',
`product_reminder` = '本產品含有甲殼類(蛤蜊)、含麩質之穀物(小麥)及其製品。'
WHERE `product_id` = 13;

-- 產品 14: 經典奶油培根義大利麵
UPDATE `products` SET 
`product_description` = '不需要專業廚藝，也能在家還原義大利餐酒館的經典之作。我們選用香醇的厚切培根，搭配法國進口鮮奶油與熟成帕瑪森起司。每一口都能感受到煙燻肉香與溫潤奶香的完美融合，鹹香適中，是大朋友小朋友都無法抗拒的療癒系美食。',
`product_ingredients` = '1.杜蘭小麥義大利麵 (Spaghetti)： 選用 100% 杜蘭小麥粉製成。\r\n2.特製奶油起司醬。\r\n3.厚切煙燻培根。',
`product_cooking_method` = '1.平底鍋加熱：平底鍋加入 30ml 水，倒入醬包與麵條，中火翻炒至醬汁收濃、麵條均勻掛漿即可(約 2 分鐘)。\r\n2.微波加熱：在包裝袋上撕開一個小洞，以 800W 功率微波約 3-4 分鐘，倒出至餐盤中拌勻，灑上內附的香料粉。',
`product_reminder` = '本產品含有牛奶、蛋、含麩質之穀物及其製品，不適合對其過敏體質者食用。'
WHERE `product_id` = 14;

-- 產品 15: 台式三杯雞
UPDATE `products` SET 
`product_description` = '不用動油鍋，也不用頂著熱氣爆香。我們選用鮮嫩多汁的國產雞腿肉，遵循傳統「一杯麻油、一杯醬油、一杯米酒」的黃金比例，慢火煸香老薑片，最後撒入靈魂九層塔。鹹甜適中、醬汁濃郁，是絕對的「白飯殺手」！',
`product_ingredients` = '1.精選國產去骨雞腿肉。\r\n2.老薑片、蒜粒、鮮切九層塔、紅辣椒(微辣提味)。\r\n3.主廚秘製醬汁。',
`product_cooking_method` = '1.隔水加熱(最推薦)：不拆袋，放入沸水中煮約 5-8 分鐘，即可倒出享用。\r\n2.微波加熱：拆袋倒入微波容器，高火(800W)加熱約 3 分鐘。3.電鍋加熱：拆袋倒入碗中，外鍋加半杯水，跳起即可。',
`product_reminder` = '本產品含有大豆、小麥(醬油來源)及芝麻(麻油來源)，不適合對其過敏體質者食用。'
WHERE `product_id` = 15;

-- 產品 16: 家傳紅燒肉
UPDATE `products` SET 
`product_description` = '「一塊紅燒肉，是家最溫暖的記憶。」嚴選帶皮五花豬肉，遵循古法長時慢燉。每一塊紅燒肉都呈現琥珀般的誘人光澤，入口即化卻不軟爛，肥而不膩、瘦而不柴。那醇厚濃育的醬香，完美滲透進肉質纖維，淋上一勺精華滷汁，就是三碗白飯也嫌不夠的靈魂美味。',
`product_ingredients` = '1.嚴選國產豬五花肉。\r\n2.主廚秘製醬汁。',
`product_cooking_method` = '1.隔水加熱(最推薦)：不需拆袋，將料理包放入沸水中煮約 8–10 分鐘，即可拆袋享用。\r\n2.微波加熱：拆袋後將內容物倒入微波專用碗，覆蓋後以 800W 加熱約 3–5 分鐘。\r\n3.電鍋加熱：拆袋後放入碗中，外鍋加入半杯水，跳起後即可上桌。',
`product_reminder` = '本產品含有大豆、小麥(醬油來源)，不適合對其過敏者食用。'
WHERE `product_id` = 16;

-- 產品 17: 清蒸蔥油鱸魚
UPDATE `products` SET 
`product_description` = '「鎖住大海的鮮甜，只需 10 分鐘，五星級名菜優雅上桌。」還在煩惱處理鮮魚的鱗片與內臟嗎？我們為您精選外銷等級的鮮嫩金目鱸魚，已去骨、去鱗、去內臟並切片處理。搭配特製的秘製蒸魚豉油與爆香蔥油，讓您在家也能輕鬆還原飯店大廚的拿手好菜。',
`product_ingredients` = '1.嚴選鱸魚片： 約 250g - 300g(已去刺、清肉)。\r\n2.特調蒸魚醬汁。\r\n3.香蔥風味油。\r\n4.乾燥蔥段/薑絲。',
`product_cooking_method` = '1.清蒸：拆袋將魚片鋪於盤中，淋上「特調蒸魚醬汁」，放入電鍋(外鍋半杯水)或蒸鍋，大火蒸約 8-10 分鐘。\r\n2.淋油：出爐後撒上蔥絲，將「香蔥風味油」加熱後淋在魚片上(或直接拌入)，即可享用。',
`product_reminder` = '本產品含有大豆、小麥(醬油來源)，不適合對其過敏者食用。'
WHERE `product_id` = 17;

-- 產品 18: 麻婆豆腐燒
UPDATE `products` SET 
`product_description` = '工作忙碌了一整天，想吃熱呼呼的下飯菜卻不想進廚房大動干戈？ 我們的「麻婆豆腐燒」選用特製郫縣豆瓣醬，結合大紅袍花椒的微辣與清香，搭配滑嫩紮實的板豆腐與鮮美豬肉末，經慢火熬煮入味。一口咬下，先是豆瓣的鹹香，隨之而來的是花椒微麻的層次感，最後是豆腐的清甜豆香。這不只是一份料理包，更是您餐桌上的救星。',
`product_ingredients` = '1.非基因改造板豆腐、國產豬後腿肉末。\r\n2.主廚特調醬汁。',
`product_cooking_method` = '1.隔水加熱：無需解凍，將內包裝放入沸水中加熱約 5–8 分鐘，撕開倒入碗中即可。\r\n2.微波加熱：解凍後，撕開倒至微波容器中，使用 800W 加熱約 2–3 分鐘。\r\n主廚小撇步： 上桌前撒上新鮮蔥花或少許花椒粉，風味更上一層樓！',
`product_reminder` = '本產品含有大豆、小麥(醬油來源)及其製品。'
WHERE `product_id` = 18;

-- 產品 19: 客家小炒
UPDATE `products` SET 
`product_description` = '記憶中那道最下飯的客家滋味，現在 5 分鐘就能上桌！我們嚴選特級五花肉與香鮮魷魚，搭配經典五香豆乾，大火快炒出靈魂般的「焦香味」。乾魷魚的鮮味與豬肉油脂完美融合，每一口都是鹹香帶勁。不管是忙碌的晚餐還是深夜的下酒菜，只要加熱，就是餐廳大廚的現炒水準。',
`product_ingredients` = '1台灣產豬五花肉。\r\n2.香乾魷魚。\r\n3.豆乾。\r\n4.特製客家醬油。',
`product_cooking_method` = '1.隔水加熱：水滾後，將料理包(不拆袋)放入沸水中加熱約 3-5 分鐘。\r\n2.微波加熱：拆袋後倒入可微波容器，以 800W 加熱約 2 分鐘。3.大火快炒(最推薦)：拆袋後倒入鍋中，加入少許蔥段快炒 1 分鐘，鑊氣更足！',
`product_reminder` = '本產品含有大豆、小麥、軟體動物類(魷魚)、甲殼類(蝦米)，不適合其過敏體質者食用。'
WHERE `product_id` = 19;

-- 產品 20: 藥膳麻油雞湯
UPDATE `products` SET 
`product_description` = '寒流來襲的夜晚，最渴望的那一碗暖湯。我們嚴選在地優質仿土雞腿肉，肉質Q彈不軟爛，搭配傳承三代的特級黑麻油與老薑爆香，辛辣中帶點溫潤。不只是麻油雞，我們更加入精心調配的漢方藥膳（當歸、紅棗、枸杞），以傳統工法慢火熬製，湯頭清甜甘潤，絕無化學添加。加熱只需 10 分鐘，讓忙碌的你，隨時都能享受暖胃更暖心的進補饗宴。',
`product_ingredients` = '1.嚴選土雞腿肉。\r\n2.主廚特調湯包。',
`product_cooking_method` = '1. 隔水加熱：不需拆袋，整包放入沸水中加熱約 8-10 分鐘。\r\n2.微波加熱：拆袋後倒入可微波容器，高火加熱約 3-5 分鐘。\r\n3. 電鍋加熱：拆袋倒入碗中，外鍋加半杯水，跳起即可。\r\n美味小撇步：建議可自行加入高麗菜、凍豆腐或麵線，風味更佳！',
`product_reminder` = '本產品含有芝麻(麻油)及其製品。特別提醒：內含米酒與中藥材，孕婦或特殊疾病患者請諮詢醫師後食用。'
WHERE `product_id` = 20;


-- 珮儀0201：newcarts.sql
ALTER TABLE carts ADD UNIQUE KEY user_product_unique (user_id, product_id);


-- 珮儀0201：newusers.sql
UPDATE `users` SET `user_password` = CASE 
    WHEN `user_id` = 1 THEN '$2y$10$otAwsO50/9KXW.zuGNNyq.jatOZXDKHuVTzftlT6.on86I/UIOe0a'
    WHEN `user_id` = 2 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN `user_id` = 3 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN `user_id` = 4 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN `user_id` = 5 THEN '$2y$10$C55GYF.6P9q256PmvqRUqeQPJ5rwKUiC7DWhsP3WkHfwS.ORx93vO'
    WHEN `user_id` = 6 THEN '$2y$10$1iCtREvd63kWjolzfW2ByOmx09DrqkZgFpje1.K7bjNYrMf3fCxUC'
    WHEN `user_id` = 7 THEN '$2y$10$fXS3wuKIFX/IEfJBarvGLe9fsJTiekTxvCuHtR3dRnLEmpo.5ZfEy'
    WHEN `user_id` = 8 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
    WHEN `user_id` = 9 THEN '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu'
END
WHERE `user_id` IN (1, 2, 3, 4, 5, 6, 7, 8, 9);


-- 言威0202
-- 增加唯一限制，防止重複記錄洗板
ALTER TABLE browsing_history 
ADD UNIQUE KEY unique_user_recipe (user_id, recipe_id);

-- 修改時間欄位，讓它自動更新
ALTER TABLE browsing_history 
MODIFY viewed_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;


-- 陳彤0202
--預設封面圖新增第12筆資料
INSERT INTO meal_plan_cover_template (cover_template_id, template_url, template_name) 
VALUES (12, 'img/plan-covers/template/12.svg', '健身飲食');

--預設封面圖修改前11筆資料
UPDATE meal_plan_cover_template
SET 
    template_url = CASE cover_template_id
        WHEN 1 THEN 'img/plan-covers/template/1.svg'
        WHEN 2 THEN 'img/plan-covers/template/2.svg'
        WHEN 3 THEN 'img/plan-covers/template/3.svg'
        WHEN 4 THEN 'img/plan-covers/template/4.svg'
        WHEN 5 THEN 'img/plan-covers/template/5.svg'
        WHEN 6 THEN 'img/plan-covers/template/6.svg'
        WHEN 7 THEN 'img/plan-covers/template/7.svg'
        WHEN 8 THEN 'img/plan-covers/template/8.svg'
        WHEN 9 THEN 'img/plan-covers/template/9.svg'
        WHEN 10 THEN 'img/plan-covers/template/10.svg'
        WHEN 11 THEN 'img/plan-covers/template/11.svg'
    END,
    template_name = CASE cover_template_id
        WHEN 1 THEN '山林風景'
        WHEN 8 THEN '慶祝派對'
        ELSE template_name
    END
WHERE cover_template_id IN (1,2,3,4,5,6,7,8,9,10,11);

--更新備餐計畫的預設封面圖id欄位
UPDATE meal_plans 
SET cover_template_id = CASE plan_id
    WHEN 1 THEN 12
    WHEN 2 THEN 11
    WHEN 3 THEN 7
    WHEN 6 THEN 1
    WHEN 7 THEN 9
    ELSE cover_template_id
END
WHERE plan_id IN (1, 2, 3, 4, 5, 6, 7);


-- 言威0202
ALTER TABLE `favorites` CHANGE `folder_id` `folder_id` INT(11) NOT NULL;


-- 玉彤0202
ALTER TABLE ingredients 
ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 COMMENT '上下架狀態: 1=上架, 0=下架';


-- 玉彤0203
ALTER TABLE products 
ADD COLUMN product_is_hot TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0:一般, 1:熱銷' 
AFTER `product_release`;


-- 子涵0203
-- 針對檢舉案 1
UPDATE recipe_gallery SET gallery_text = '這圖是我網路抓的，這食譜做的真爛，浪費我時間！' WHERE gallery_id = 5;
-- 針對檢舉案 2
UPDATE recipe_gallery SET gallery_text = '想天天吃松露？加 LINE: money999 帶你操作虛擬幣，月入百萬！' WHERE gallery_id = 12;
-- 針對檢舉案 3
UPDATE recipe_gallery SET gallery_text = '教這什麼鬼？再發這種廢文我就去你家堵你，給我小心點！' WHERE gallery_id = 25;

-- 對應檢舉案 ID 1: 疑似垃圾廣告
UPDATE recipe_comments 
SET comment_text = '推薦大家一個可以邊煮飯邊領福利的好地方，點擊連結 [https://link.test] 領取 500 元購物金，名額有限！' 
WHERE comment_id = 12;

-- 對應檢舉案 ID 3: 不友善的評論
UPDATE recipe_comments 
SET comment_text = '這食譜寫得不太專業，感覺分享的人根本沒有實測過，照著做完全失敗，真的不推薦大家浪費食材。' 
WHERE comment_id = 60;

-- 對應檢舉案 ID 5: 版權爭議指控
UPDATE recipe_comments 
SET comment_text = '這張成品照跟我之前在國外網站看到的幾乎一模一樣，請問作者有經過授權嗎？這種搬運行為不太好吧。' 
WHERE comment_id = 4;


-- 珮儀0204
ALTER TABLE users ADD COLUMN line_id VARCHAR(100) DEFAULT NULL AFTER user_id;


-- 陳彤0204：meal_plan_daily_targets.sql
-- 1. 創建資料表
CREATE TABLE meal_plan_daily_targets (
    daily_target_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    plan_id INT NOT NULL,
    target_date DATE NOT NULL,
    target_kcal INT DEFAULT 2000 COMMENT '當天的目標熱量值，若為 NULL 則邏輯預設為 2000',
    CONSTRAINT fk_target_plan FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id) ON DELETE CASCADE
);

-- 2. 匯入初始資料 (根據 meal_plans 的日期區間)
INSERT INTO meal_plan_daily_targets (plan_id, target_date, target_kcal) VALUES
-- 計畫 1: 2026-01-19 ~ 2026-01-21
(1, '2026-01-19', 2000),
(1, '2026-01-20', 2000),
(1, '2026-01-21', 2000),

-- 計畫 2: 2026-01-22 ~ 2026-01-24
(2, '2026-01-22', 2000),
(2, '2026-01-23', 2000),
(2, '2026-01-24', 2000),

-- 計畫 3: 2026-02-16 ~ 2026-02-20
(3, '2026-02-16', 2000),
(3, '2026-02-17', 2000),
(3, '2026-02-18', 2000),
(3, '2026-02-19', 2000),
(3, '2026-02-20', 2000),

-- 計畫 4: 2026-02-10 ~ 2026-02-15
(4, '2026-02-10', 2000),
(4, '2026-02-11', 2000),
(4, '2026-02-12', 2000),
(4, '2026-02-13', 2000),
(4, '2026-02-14', 2000),
(4, '2026-02-15', 2000),

-- 計畫 5: 2026-02-16 ~ 2026-02-18
(5, '2026-02-16', 2000),
(5, '2026-02-17', 2000),
(5, '2026-02-18', 2000),

-- 計畫 6: 2026-03-13 ~ 2026-03-15
(6, '2026-03-13', 2000),
(6, '2026-03-14', 2000),
(6, '2026-03-15', 2000),

-- 計畫 7: 2026-05-19 ~ 2026-05-21
(7, '2026-05-19', 2000),
(7, '2026-05-20', 2000),
(7, '2026-05-21', 2000);


-- 陳彤0204
-- 1. 暫時關閉外鍵檢查（確保修改順利）
SET FOREIGN_KEY_CHECKS = 0;

-- 2. 修改 plan_id 的約束：刪除舊的，補上帶有 CASCADE 的新的
ALTER TABLE meal_plan_items DROP FOREIGN KEY fk_meal_plan_items_plan_id;
ALTER TABLE meal_plan_items ADD CONSTRAINT fk_meal_plan_items_plan_id 
    FOREIGN KEY (plan_id) REFERENCES meal_plans (plan_id) ON DELETE CASCADE;

-- 3. 修改 recipe_id 的約束（通常食譜被刪除時，計畫項目也應一併移除）
ALTER TABLE meal_plan_items DROP FOREIGN KEY fk_meal_plan_items_recipe_id;
ALTER TABLE meal_plan_items ADD CONSTRAINT fk_meal_plan_items_recipe_id 
    FOREIGN KEY (recipe_id) REFERENCES recipes (recipe_id) ON DELETE CASCADE;

-- 4. 重新開啟外鍵檢查
SET FOREIGN_KEY_CHECKS = 1;


-- 子涵0204
UPDATE recipe_gallery 

SET gallery_url = REPLACE(gallery_url, 'img/social/32/gallery/', 'img/social/gallery/');

ALTER TABLE recipes

MODIFY COLUMN recipe_kcal_per_100g DECIMAL(10,2),
MODIFY COLUMN recipe_protein_per_100g DECIMAL(10,2),
MODIFY COLUMN recipe_fat_per_100g DECIMAL(10,2),
MODIFY COLUMN recipe_carbs_per_100g DECIMAL(10,2);


-- 子涵0204
ALTER TABLE `recipes` 
MODIFY COLUMN `recipe_kcal_per_100g` DECIMAL(8,2),
MODIFY COLUMN `recipe_protein_per_100g` DECIMAL(8,2),
MODIFY COLUMN `recipe_fat_per_100g` DECIMAL(8,2),
MODIFY COLUMN `recipe_carbs_per_100g` DECIMAL(8,2);


-- 批次更新 1-79 筆資料的營養成分與標題
-- 基於新版 SQL 資料內容

START TRANSACTION;

-- 更新基礎食譜與衍生食譜的所有欄位
UPDATE recipes SET 
    recipe_kcal_per_100g = CASE recipe_id
        WHEN 1 THEN 1928.40 WHEN 2 THEN 1384.20 WHEN 3 THEN 767.35 WHEN 4 THEN 933.36 WHEN 5 THEN 1641.45 
        WHEN 6 THEN 1372.16 WHEN 7 THEN 713.30 WHEN 8 THEN 977.25 WHEN 9 THEN 3505.83 WHEN 10 THEN 691.66 
        WHEN 11 THEN 526.81 WHEN 12 THEN 641.60 WHEN 13 THEN 718.20 WHEN 14 THEN 915.10 WHEN 15 THEN 210.32 
        WHEN 16 THEN 823.40 WHEN 17 THEN 691.76 WHEN 18 THEN 2264.90 WHEN 19 THEN 1291.90 WHEN 20 THEN 508.98 
        WHEN 21 THEN 1384.90 WHEN 22 THEN 1188.00 WHEN 23 THEN 1329.57 WHEN 24 THEN 843.35 WHEN 25 THEN 803.24 
        WHEN 26 THEN 879.85 WHEN 27 THEN 3204.00 WHEN 28 THEN 796.45 WHEN 29 THEN 1290.55 WHEN 30 THEN 1232.10 
        WHEN 31 THEN 2687.15 WHEN 32 THEN 337.00 WHEN 33 THEN 1401.00 WHEN 34 THEN 397.00 WHEN 35 THEN 1489.00 
        WHEN 36 THEN 1467.95 WHEN 37 THEN 2652.78 WHEN 38 THEN 1503.32 WHEN 39 THEN 2229.00 WHEN 40 THEN 3035.50 
        WHEN 41 THEN 2108.70 WHEN 42 THEN 2773.90 WHEN 43 THEN 1964.10 WHEN 44 THEN 1020.35 WHEN 45 THEN 385.68 
        WHEN 46 THEN 645.70 WHEN 47 THEN 1734.30 WHEN 48 THEN 912.10 WHEN 49 THEN 1400.06 WHEN 50 THEN 2124.45 
        WHEN 51 THEN 1054.80 WHEN 52 THEN 903.55 WHEN 53 THEN 1900.06 WHEN 54 THEN 854.40 WHEN 55 THEN 1054.65 
        WHEN 56 THEN 1136.75 WHEN 57 THEN 975.05 WHEN 58 THEN 937.34 WHEN 59 THEN 3247.81 WHEN 60 THEN 1053.25 
        WHEN 61 THEN 774.44 WHEN 62 THEN 898.66 WHEN 63 THEN 1102.16 WHEN 64 THEN 1133.85 WHEN 65 THEN 1226.55 
        WHEN 66 THEN 977.36 WHEN 67 THEN 1385.64 WHEN 68 THEN 5166.80 WHEN 69 THEN 3294.40 WHEN 70 THEN 421.50 
        WHEN 71 THEN 1651.20 WHEN 72 THEN 1444.25 WHEN 73 THEN 1654.05 WHEN 74 THEN 1529.20 WHEN 75 THEN 1574.25 
        WHEN 76 THEN 1474.05 WHEN 77 THEN 843.80 WHEN 78 THEN 1106.15 WHEN 79 THEN 809.90 ELSE recipe_kcal_per_100g END,
    
    recipe_protein_per_100g = CASE recipe_id
        WHEN 1 THEN 119.96 WHEN 2 THEN 26.78 WHEN 3 THEN 68.04 WHEN 4 THEN 22.79 WHEN 5 THEN 60.36 
        WHEN 6 THEN 39.86 WHEN 7 THEN 35.96 WHEN 8 THEN 35.10 WHEN 9 THEN 127.37 WHEN 10 THEN 96.63 
        WHEN 11 THEN 44.69 WHEN 12 THEN 38.26 WHEN 13 THEN 62.07 WHEN 14 THEN 63.90 WHEN 15 THEN 31.86 
        WHEN 16 THEN 40.94 WHEN 17 THEN 40.11 WHEN 18 THEN 212.84 WHEN 19 THEN 22.85 WHEN 20 THEN 33.32 
        WHEN 21 THEN 66.59 WHEN 22 THEN 35.24 WHEN 23 THEN 90.46 WHEN 24 THEN 62.40 WHEN 25 THEN 42.95 
        WHEN 26 THEN 60.70 WHEN 27 THEN 297.11 WHEN 28 THEN 96.31 WHEN 29 THEN 126.48 WHEN 30 THEN 106.93 
        WHEN 31 THEN 218.48 WHEN 32 THEN 17.00 WHEN 33 THEN 85.00 WHEN 34 THEN 6.61 WHEN 35 THEN 44.00 
        WHEN 36 THEN 23.54 WHEN 37 THEN 49.43 WHEN 38 THEN 21.45 WHEN 39 THEN 45.96 WHEN 40 THEN 38.16 
        WHEN 41 THEN 32.13 WHEN 42 THEN 43.40 WHEN 43 THEN 21.91 WHEN 44 THEN 14.68 WHEN 45 THEN 23.53 
        WHEN 46 THEN 23.81 WHEN 47 THEN 38.32 WHEN 48 THEN 40.18 WHEN 49 THEN 53.24 WHEN 50 THEN 90.27 
        WHEN 51 THEN 28.99 WHEN 52 THEN 36.10 WHEN 53 THEN 92.09 WHEN 54 THEN 84.81 WHEN 55 THEN 61.93 
        WHEN 56 THEN 85.59 WHEN 57 THEN 97.87 WHEN 58 THEN 71.67 WHEN 59 THEN 233.04 WHEN 60 THEN 58.00 
        WHEN 61 THEN 81.77 WHEN 62 THEN 53.55 WHEN 63 THEN 51.47 WHEN 64 THEN 84.34 WHEN 65 THEN 112.87 
        WHEN 66 THEN 72.52 WHEN 67 THEN 56.60 WHEN 68 THEN 71.99 WHEN 69 THEN 111.76 WHEN 70 THEN 15.14 
        WHEN 71 THEN 62.17 WHEN 72 THEN 61.84 WHEN 73 THEN 74.54 WHEN 74 THEN 35.09 WHEN 75 THEN 28.81 
        WHEN 76 THEN 27.90 WHEN 77 THEN 67.89 WHEN 78 THEN 67.55 WHEN 79 THEN 61.62 ELSE recipe_protein_per_100g END,

    recipe_fat_per_100g = CASE recipe_id
        WHEN 1 THEN 57.06 WHEN 2 THEN 91.25 WHEN 3 THEN 40.25 WHEN 4 THEN 56.33 WHEN 5 THEN 136.63 
        WHEN 6 THEN 106.28 WHEN 7 THEN 35.56 WHEN 8 THEN 63.63 WHEN 9 THEN 55.23 WHEN 10 THEN 29.17 
        WHEN 11 THEN 8.64 WHEN 12 THEN 21.77 WHEN 13 THEN 41.69 WHEN 14 THEN 63.55 WHEN 15 THEN 3.95 
        WHEN 16 THEN 33.93 WHEN 17 THEN 48.13 WHEN 18 THEN 88.26 WHEN 19 THEN 112.75 WHEN 20 THEN 30.29 
        WHEN 21 THEN 61.11 WHEN 22 THEN 44.30 WHEN 23 THEN 91.45 WHEN 24 THEN 23.54 WHEN 25 THEN 35.10 
        WHEN 26 THEN 54.31 WHEN 27 THEN 143.25 WHEN 28 THEN 40.16 WHEN 29 THEN 44.70 WHEN 30 THEN 78.45 
        WHEN 31 THEN 106.47 WHEN 32 THEN 18.00 WHEN 33 THEN 70.00 WHEN 34 THEN 19.40 WHEN 35 THEN 124.00 
        WHEN 36 THEN 96.32 WHEN 37 THEN 99.02 WHEN 38 THEN 91.50 WHEN 39 THEN 111.02 WHEN 40 THEN 173.86 
        WHEN 41 THEN 68.79 WHEN 42 THEN 172.49 WHEN 43 THEN 92.12 WHEN 44 THEN 62.42 WHEN 45 THEN 12.23 
        WHEN 46 THEN 40.91 WHEN 47 THEN 98.33 WHEN 48 THEN 14.60 WHEN 49 THEN 24.97 WHEN 50 THEN 144.03 
        WHEN 51 THEN 96.95 WHEN 52 THEN 46.01 WHEN 53 THEN 102.04 WHEN 54 THEN 33.31 WHEN 55 THEN 62.95 
        WHEN 56 THEN 47.43 WHEN 57 THEN 42.33 WHEN 58 THEN 67.19 WHEN 59 THEN 68.79 WHEN 60 THEN 60.29 
        WHEN 61 THEN 30.31 WHEN 62 THEN 62.72 WHEN 63 THEN 96.80 WHEN 64 THEN 21.78 WHEN 65 THEN 13.11 
        WHEN 66 THEN 70.40 WHEN 67 THEN 97.00 WHEN 68 THEN 504.93 WHEN 69 THEN 180.14 WHEN 70 THEN 6.66 
        WHEN 71 THEN 61.85 WHEN 72 THEN 45.07 WHEN 73 THEN 62.55 WHEN 74 THEN 102.95 WHEN 75 THEN 106.20 
        WHEN 76 THEN 84.05 WHEN 77 THEN 43.03 WHEN 78 THEN 40.23 WHEN 79 THEN 40.19 ELSE recipe_fat_per_100g END,

    recipe_carbs_per_100g = CASE recipe_id
        WHEN 1 THEN 254.27 WHEN 2 THEN 116.04 WHEN 3 THEN 31.63 WHEN 4 THEN 85.42 WHEN 5 THEN 62.01 
        WHEN 6 THEN 65.02 WHEN 7 THEN 62.37 WHEN 8 THEN 77.91 WHEN 9 THEN 594.47 WHEN 10 THEN 15.16 
        WHEN 11 THEN 66.14 WHEN 12 THEN 67.48 WHEN 13 THEN 22.22 WHEN 14 THEN 25.55 WHEN 15 THEN 8.41 
        WHEN 16 THEN 82.36 WHEN 17 THEN 23.68 WHEN 18 THEN 213.44 WHEN 19 THEN 43.91 WHEN 20 THEN 19.60 
        WHEN 21 THEN 145.24 WHEN 22 THEN 135.31 WHEN 23 THEN 35.73 WHEN 24 THEN 84.68 WHEN 25 THEN 76.82 
        WHEN 26 THEN 28.63 WHEN 27 THEN 244.66 WHEN 28 THEN 8.29 WHEN 29 THEN 131.25 WHEN 30 THEN 20.24 
        WHEN 31 THEN 172.20 WHEN 32 THEN 27.00 WHEN 33 THEN 109.00 WHEN 34 THEN 50.72 WHEN 35 THEN 51.00 
        WHEN 36 THEN 139.52 WHEN 37 THEN 404.32 WHEN 38 THEN 152.79 WHEN 39 THEN 270.40 WHEN 40 THEN 350.87 
        WHEN 41 THEN 324.02 WHEN 42 THEN 273.30 WHEN 43 THEN 256.61 WHEN 44 THEN 105.27 WHEN 45 THEN 47.52 
        WHEN 46 THEN 51.18 WHEN 47 THEN 194.79 WHEN 48 THEN 160.62 WHEN 49 THEN 227.44 WHEN 50 THEN 97.50 
        WHEN 51 THEN 18.10 WHEN 52 THEN 85.05 WHEN 53 THEN 149.66 WHEN 54 THEN 46.71 WHEN 55 THEN 70.16 
        WHEN 56 THEN 54.13 WHEN 57 THEN 37.90 WHEN 58 THEN 14.14 WHEN 59 THEN 357.41 WHEN 60 THEN 79.34 
        WHEN 61 THEN 54.72 WHEN 62 THEN 31.89 WHEN 63 THEN 11.97 WHEN 64 THEN 149.21 WHEN 65 THEN 141.97 
        WHEN 66 THEN 16.02 WHEN 67 THEN 78.37 WHEN 68 THEN 105.68 WHEN 69 THEN 283.69 WHEN 70 THEN 74.93 
        WHEN 71 THEN 212.74 WHEN 72 THEN 196.82 WHEN 73 THEN 197.61 WHEN 74 THEN 117.22 WHEN 75 THEN 129.70 
        WHEN 76 THEN 149.03 WHEN 77 THEN 45.95 WHEN 78 THEN 119.23 WHEN 79 THEN 54.69 ELSE recipe_carbs_per_100g END,

    -- 修正衍生食譜的標題
    recipe_title = CASE recipe_id
        WHEN 71 THEN '經典瑪格麗特披薩'
        WHEN 72 THEN '經典瑪格麗特披薩'
        WHEN 73 THEN '經典瑪格麗特披薩'
        WHEN 74 THEN '抹茶熔岩蛋糕'
        WHEN 75 THEN '抹茶熔岩蛋糕'
        WHEN 76 THEN '抹茶熔岩蛋糕'
        WHEN 77 THEN '四川宮保雞丁'
        WHEN 78 THEN '四川宮保雞丁'
        WHEN 79 THEN '四川宮保雞丁'
        ELSE recipe_title END;

COMMIT;