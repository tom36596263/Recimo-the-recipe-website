CREATE TABLE remove_bg_ingredients (
    id INT AUTO_INCREMENT PRIMARY KEY AUTO_INCREMENT,
    url VARCHAR(255),
    recipe_name VARCHAR(255),
    recipe_image_url VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO remove_bg_ingredients (id, url, recipe_name, recipe_image_url) VALUES
    (1, 'img/remove-bg-ingredients/1.png', '經典瑪格麗特披薩', 'img/recipes/1/cover.png'),
    (2, 'img/remove-bg-ingredients/2.png', '抹茶熔岩蛋糕', 'img/recipes/2/cover.png'),
    (3, 'img/remove-bg-ingredients/3.png', '四川宮保雞丁', 'img/recipes/3/cover.png'),
    (4, 'img/remove-bg-ingredients/4.png', '奶油松露野菇寬麵', 'img/recipes/4/cover.png'),
    (5, 'img/remove-bg-ingredients/5.png', '泰式青咖哩雞', 'img/recipes/5/cover.png'),
    (6, 'img/remove-bg-ingredients/6.png', '經典班尼迪克蛋', 'img/recipes/6/cover.png'),
    (7, 'img/remove-bg-ingredients/7.png', '濃厚豚骨叉燒拉麵', 'img/recipes/7/cover.png'),
    (8, 'img/remove-bg-ingredients/8.png', '經典自製鷹嘴豆泥', 'img/recipes/8/cover.png'),
    (9, 'img/remove-bg-ingredients/9.png', '法式洋蔥濃湯', 'img/recipes/9/cover.png'),
    (10, 'img/remove-bg-ingredients/10.png', '蒜香檸檬烤大蝦', 'img/recipes/10/cover.png'),
    (11, 'img/remove-bg-ingredients/11.png', '舒肥雞胸藜麥飯', 'img/recipes/11/cover.png'),
    (12, 'img/remove-bg-ingredients/12.png', '香煎鮭魚糙米便當', 'img/recipes/12/cover.png'),
    (13, 'img/remove-bg-ingredients/13.png', '蒜香毛豆嫩豬排', 'img/recipes/13/cover.png'),
    (14, 'img/remove-bg-ingredients/14.png', '豆腐漢堡排佐野菇', 'img/recipes/14/cover.png'),
    (15, 'img/remove-bg-ingredients/15.png', '檸檬紙包魚片', 'img/recipes/15/cover.png'),
    (16, 'img/remove-bg-ingredients/16.png', '日式壽喜燒牛丼', 'img/recipes/16/cover.png'),
    (17, 'img/remove-bg-ingredients/17.png', '韓式泡菜炒豬肉', 'img/recipes/17/cover.png'),
    (18, 'img/remove-bg-ingredients/18.png', '北海道咖哩雞', 'img/recipes/18/cover.png'),
    (19, 'img/remove-bg-ingredients/19.png', '味增薑汁燒肉', 'img/recipes/19/cover.png'),
    (20, 'img/remove-bg-ingredients/20.png', '照燒鮭魚排', 'img/recipes/20/cover.png');