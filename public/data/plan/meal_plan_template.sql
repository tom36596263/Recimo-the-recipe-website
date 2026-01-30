-- 1. 創建資料表
CREATE TABLE meal_plan_templates (
    template_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    cover_template_id INT NOT NULL,
    total_days INT NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (template_id),
    CONSTRAINT fk_templates_cover_id FOREIGN KEY (cover_template_id) 
        REFERENCES meal_plan_cover_template (cover_template_id)
);

-- 2. 匯入 5 筆模板資料
INSERT INTO meal_plan_templates (
    template_id, 
    title, 
    description, 
    cover_template_id, 
    total_days, 
    created_at
) VALUES
(1, '高效健身：高蛋白三日增肌減脂計畫', '專為健身族群與體態管理者規劃。本計畫核心在於高蛋白質攝取與適量複合碳水化合物的平衡，利用舒肥、清蒸與香煎等低油烹調方式，確保攝取純淨營養的同時，也能享受多國風味的料理體驗。', 1, 3, '2026-01-28 21:00:00'),
(2, '韓流食尚：經典韓式熱門料理五日計畫', '集結韓國街頭與家庭最受歡迎的靈魂料理。從火辣過癮的部隊鍋、辣炒年糕，到香甜誘人的蜂蜜炸雞與石鍋拌飯，讓您連續五天沉浸在道地的韓式味覺饗宴中。', 2, 5, '2026-01-28 21:10:00'),
(3, '異國甜點盛宴：午茶時光精選五日計畫', '專為甜點控打造的環球甜點之旅。包含日式舒芙蕾、法式可麗露、蒙布朗以及抹茶熔岩蛋糕，每日精選兩款經典甜點組合，在家也能享受精品等級的下午茶時光。', 3, 5, '2026-01-28 21:15:00'),
(4, '家常溫馨味：精選中式熱炒三日計畫', '嚴選最下飯的台式與川式經典家常菜。包含三杯雞、客家小炒、麻婆豆腐等熱炒店必點料理，搭配溫潤的藥膳雞湯或排骨湯，呈現最溫暖、最具飽足感的日常餐桌。', 4, 3, '2026-01-28 21:20:00'),
(5, '西洋約會夜：精選義法排餐三日計畫', '打造居家儀式感的首選模板。涵蓋肋眼牛排、松露燉飯、瑪格麗特披薩等義法餐廳經典，從前菜沙拉到主餐湯品皆完美搭配，適合慶祝或浪漫約會使用。', 5, 3, '2026-01-28 21:25:00');