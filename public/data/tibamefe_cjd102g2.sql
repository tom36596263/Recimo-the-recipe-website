-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- 主機： localhost:8889
-- 產生時間： 2026-02-10 01:17:20
-- 伺服器版本： 5.7.24
-- PHP 版本： 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫: `tibamefe_cjd102g2`
--

-- --------------------------------------------------------

--
-- 資料表結構 `admins`
--

CREATE TABLE `admins` (
  `admin_id` int(11) NOT NULL,
  `admin_level` tinyint(4) NOT NULL,
  `admin_account` varchar(100) NOT NULL,
  `admin_password` varchar(10) NOT NULL,
  `admin_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 傾印資料表的資料 `admins`
--

INSERT INTO `admins` (`admin_id`, `admin_level`, `admin_account`, `admin_password`, `admin_name`) VALUES
(1, 2, 'recimo@gmail.com', 'G2Recimo', 'Recimo'),
(2, 1, 'admin@test.com', '123456', '小R(測試人員)'),
(3, 1, 'tom@gmail.com', '123456', 'tom'),
(4, 1, 'wei@gmail.com', '123456', 'wei'),
(5, 1, 'helenKuo@gmail.com', '888888', 'HelenKuo'),
(6, 1, 'pei@gmail.com', 'Aa111111', 'pei'),
(7, 1, 'yutung@gmail.com', 'yutung123', 'yutung'),
(8, 1, 'hsu@test.com', '123456', 'Hsu'),
(9, 0, '123@test.com', '123456', '小小R(測試停用)');

-- --------------------------------------------------------

--
-- 資料表結構 `announcement`
--

CREATE TABLE `announcement` (
  `announcement_id` int(11) NOT NULL,
  `announcement_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `announcement_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `announcement_content` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `announcement_photo_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `announced_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `browsing_history`
--

CREATE TABLE `browsing_history` (
  `browsing_history_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `viewed_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `carts`
--

CREATE TABLE `carts` (
  `carts_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `carts`
--

INSERT INTO `carts` (`carts_id`, `user_id`, `product_id`, `quantity`) VALUES
(1, 1, 1, 2),
(2, 1, 10, 1),
(3, 3, 5, 3),
(4, 5, 20, 1),
(5, 7, 15, 5);

-- --------------------------------------------------------

--
-- 資料表結構 `cooking_logs`
--

CREATE TABLE `cooking_logs` (
  `cooking_log_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `actual_time` time DEFAULT NULL,
  `satisfaction_rating` decimal(3,1) DEFAULT NULL,
  `technique_rating` tinyint(4) DEFAULT NULL,
  `complexity_rating` tinyint(4) DEFAULT NULL,
  `log_summary` text COLLATE utf8mb4_unicode_ci,
  `log_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logged_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `cooking_logs`
--

INSERT INTO `cooking_logs` (`cooking_log_id`, `recipe_id`, `user_id`, `actual_time`, `satisfaction_rating`, `technique_rating`, `complexity_rating`, `log_summary`, `log_image_url`, `logged_at`) VALUES
(1, 1, 5, '01:45:00', '4.5', 1, 1, '第一次嘗試手揉披薩麵糰，雖然揉得手有點痠，但成品的外皮非常酥脆。發酵時間因為室溫較低稍微延長了15分鐘。莫札瑞拉起司的奶香味跟新鮮羅勒非常搭！', 'img/logs/u5/log_1/cover.png', '2026-01-28 14:30:00'),
(2, 1, 2, '01:25:00', '5.0', 0, 0, '這是我第一次用這個系統記錄烹飪過程！經典瑪格麗特的步驟很清晰，手揉麵糰雖然有點累但很有趣。成品非常漂亮，起司融化的樣子超誘人！', 'img/logs/u2/log_2/cover.png', '2026-02-01 12:00:00'),
(3, 1, 3, '01:10:00', '3.8', 2, 1, '這次嘗試縮短了發酵時間，結果餅皮口感稍微偏硬。揉麵技術還需要加強，麵糰表面一直不夠光滑。不過番茄糊的味道調得很棒，整體還是算及格。', 'img/logs/u3/log_3/cover.png', '2026-02-05 18:45:00'),
(4, 1, 4, '01:20:00', '4.2', 1, 1, '這是我第二次挑戰手工披薩，麵糰發酵得很飽滿。雖然在桿開麵皮時花了不少時間才弄成圓形，但看到起司在烤箱裡冒泡的樣子非常有成就感！口感外酥內軟，全家人都很滿意。', 'img/logs/u4/log_4/cover.png', '2026-02-10 19:30:00'),
(5, 1, 6, '01:15:00', '4.8', 0, 0, '這次做得非常順手！特別是麵糰發酵的狀態簡直完美，烤出來的孔洞很漂亮。不過新鮮羅勒放得有點少，下次想嘗試多放一倍，香氣應該會更濃郁。', 'img/logs/u6/log_5/cover.png', '2026-02-15 13:00:00'),
(6, 1, 7, '01:35:00', '4.0', 1, 1, '第一次親手製作披薩皮，感覺比想像中更有成就感！雖然在揉麵糰時花了不少力氣，但餅皮烤出來的口感非常有彈性。可惜羅勒葉放得稍微早了點，顏色變得深了些，下次會等稍微降溫再放。', 'img/logs/u7/log_6/cover.png', '2026-02-20 18:15:00'),
(7, 1, 8, '01:40:00', '4.7', 1, 0, '瑪格麗特真的是披薩之王！這次特別用了披薩石板來烘烤，底部受熱非常均勻，口感變得很酥脆，非常有窯烤的感覺。麵糰揉完後有先放在冰箱低溫發酵一段時間，麥香味似乎更明顯了。', 'img/logs/u8/log_7/cover.png', '2026-02-25 20:10:00'),
(8, 3, 2, '00:40:00', '4.8', 1, 1, '這道菜最迷人的就是那種『荔枝味』，酸甜與微麻的平衡非常到位。雞肉因為有經過醃漬和快速滑油，口感真的很嫩。最後加入的花生是靈魂，一定要保持酥脆！', 'img/logs/u2/log_8/cover.png', '2026-03-05 18:30:00'),
(9, 2, 2, '00:45:00', '4.6', 1, 1, '熔岩蛋糕最難的就是烤溫控制，這次烤了9分鐘，切開後抹茶漿緩緩流出，非常成功！白巧克力的甜度剛好被抹茶的微苦中和，是一款視覺與味覺兼具的甜點。建議模具一定要塗夠奶油，脫模才會漂亮。', 'img/logs/u2/log_9/cover.png', '2026-03-10 15:20:00'),
(10, 5, 2, '00:50:00', '4.9', 1, 1, '這道泰式青咖哩非常道地！椰奶分次加入讓醬汁質地非常柔滑，青咖哩醬先炒過後的香氣層次完全不同。圓茄子吸收了滿滿的咖哩精華，微辣中帶有椰糖的甘甜，超級下飯。', 'img/logs/u2/log_10/cover.png', '2026-03-15 12:00:00'),
(11, 4, 2, '00:30:00', '4.5', 1, 1, '第一次在家煮松露意麵，鮮奶油的乳化比想像中快。松露醬的味道很濃郁，但要注意煮麵水的鹽度，這次稍微鹹了一點點。野菇炒到金黃色真的比較香！', 'img/logs/u2/log_11/cover.png', '2026-03-20 19:00:00'),
(12, 4, 2, '00:22:00', '5.0', 0, 0, '第二次做這道菜，節奏掌握得更好了，剛好在麵煮好的同時醬汁也準備好。這次調整了鹽巴量，成品非常完美！這已經變成我的招牌拿手菜了。', 'img/logs/u2/log_12/cover.png', '2026-03-25 12:30:00'),
(13, 10, 2, '00:45:00', '4.2', 1, 1, '第一次處理大虎蝦，去腸泥花了比預期更多的時間。烤出來的味道非常鮮美，蒜香跟奶油真的是絕配。下次烤的時間可以縮短一兩分鐘，讓蝦肉更 Q 彈。', 'img/logs/u2/log_13/cover.png', '2026-04-05 18:30:00'),
(14, 10, 2, '00:38:00', '4.5', 1, 0, '第二次做這道菜，去腸泥的手法熟練多了。這次多加了一些蒜末，整體的香氣更上一層樓。檸檬汁在出爐後擠上去確實能讓鮮甜度更明顯。', 'img/logs/u2/log_14/cover.png', '2026-04-12 19:15:00'),
(15, 10, 2, '00:35:00', '4.8', 0, 0, '已經完全掌握這道菜的節奏了。這次特別選用了較大隻的虎蝦，肉質飽滿。調整了烤箱溫度，180度烤13分鐘是最完美的狀態，蝦肉完全沒縮水。', 'img/logs/u2/log_15/cover.png', '2026-04-20 12:00:00'),
(16, 10, 2, '00:32:00', '5.0', 0, 0, '這已經成為我的拿手好菜！這次邀請朋友來家裡聚餐，大家都對這道大蝦讚不絕口。奶油與檸檬的比例調配得很完美，視覺上也很有餐廳水準。', 'img/logs/u2/log_16/cover.png', '2026-04-28 20:00:00'),
(17, 27, 2, '01:30:00', '4.0', 1, 1, '第一次嘗試家傳紅燒肉，步驟雖多但還算好上手。最難的地方在於炒糖色，一開始很怕冰糖燒焦所以火開得很小，導致顏色不夠深，但味道還是很不錯，肉質有燉爛。', 'img/logs/u2/log_17/cover.png', '2026-05-05 19:00:00'),
(18, 27, 2, '01:15:00', '4.6', 1, 1, '第二次製作，重點放在炒糖色。這次火候抓得比較好，肉塊上色的琥珀色非常漂亮。加入薑片跟蔥段後的香氣很足，家人都說很有外婆家的味道。', 'img/logs/u2/log_18/cover.png', '2026-05-12 18:30:00'),
(19, 27, 2, '01:10:00', '5.0', 0, 0, '這已經成為我的拿手家常菜！最後的大火收汁做得非常完美，醬汁濃稠且油亮地掛在肉上，口感軟糯、肥而不膩。這次完全照著食譜時間走，效果極佳。', 'img/logs/u2/log_19/cover.png', '2026-05-20 19:45:00');

-- --------------------------------------------------------

--
-- 資料表結構 `faqs`
--

CREATE TABLE `faqs` (
  `faq_id` int(11) NOT NULL,
  `faq_type` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `faq_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `faq_answer` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `faqs`
--

INSERT INTO `faqs` (`faq_id`, `faq_type`, `faq_title`, `faq_answer`) VALUES
(1, 'Recimo商城', 'Recimo 商城賣什麼？與食譜有什麼關係？', '我們專門販售由「官方食譜」轉化而成的即食料理包。您可以將其視為食譜的實體縮影，讓您省去備料繁瑣，在家也能快速還原與官方食譜一模一樣的美味。'),
(2, 'Recimo商城', '下單後多久會出貨？', '待管理員在後台確認訂單後，通常於 1-2 個工作天內完成備貨並出貨。出貨後，您會收到「商品運送進度通知」。'),
(3, 'Recimo商城', '如果收到料理包後發現品質有問題該怎麼辦？', '請立即拍照並透過網站的「聯絡我們表單」反映。管理員會在後台查看您的訂單詳情並進行售後處理。'),
(4, 'Recimo功能', '沒登入可以使用網站嗎？', '未登入狀態下，您可以瀏覽「食譜總覽」並使用「靈感廚房」小遊戲。但若要使用個人筆記、備餐計畫，則需註冊 Recimo ID。'),
(5, 'Recimo功能', '可以把別人食譜排進「備餐計劃」嗎？', '可以，只需點擊食譜下方的「加入收藏」，即可在行事曆介面中拖曳排入。'),
(6, '食譜與社群', '可以怎麼「改編食譜」？', '當您參考官方食譜想加入自己的創意時，可以點擊食譜內頁的「筆/編輯食譜/改編食譜」的按鈕，進行編輯。不必擔心會修改到官方食譜，系統會保留原食譜，完成改編後您的改編食譜會上傳至原食譜內頁中「改編輯」內。'),
(7, '食譜與社群', '留言被檢舉會發生什麼事？', '若留言違反社群守則並經管理員審核屬實，該留言將被移除，您也會在登入後頁面中的「小鈴鐺」收到通知。');

-- --------------------------------------------------------

--
-- 資料表結構 `favorites`
--

CREATE TABLE `favorites` (
  `favorite_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `folder_id` int(11) NOT NULL,
  `like_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `favorites_folders`
--

CREATE TABLE `favorites_folders` (
  `favorites_folder_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `folder_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `follows`
--

CREATE TABLE `follows` (
  `follow_id` int(11) NOT NULL,
  `follower_id` int(11) NOT NULL COMMENT '追蹤者 ID',
  `followed_id` int(11) NOT NULL COMMENT '被追蹤者 ID',
  `followed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '追蹤時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='使用者追蹤關係表';

--
-- 傾印資料表的資料 `follows`
--

INSERT INTO `follows` (`follow_id`, `follower_id`, `followed_id`, `followed_at`) VALUES
(1, 4, 1, '2026-01-15 10:30:00'),
(2, 4, 3, '2026-01-16 14:20:00'),
(3, 4, 5, '2026-01-17 09:15:00'),
(4, 4, 6, '2026-01-18 16:45:00'),
(5, 3, 4, '2026-01-19 11:00:00'),
(6, 5, 4, '2026-01-20 13:30:00'),
(7, 1, 4, '2026-01-21 15:00:00'),
(8, 6, 4, '2026-01-22 10:20:00');

-- --------------------------------------------------------

--
-- 資料表結構 `ingredients`
--

CREATE TABLE `ingredients` (
  `ingredient_id` int(11) NOT NULL,
  `ingredient_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `main_category` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `sub_category` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `ingredient_image_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kcal_per_100g` decimal(6,2) DEFAULT '0.00',
  `protein_per_100g` decimal(6,2) DEFAULT '0.00',
  `fat_per_100g` decimal(6,2) DEFAULT '0.00',
  `carbs_per_100g` decimal(6,2) DEFAULT '0.00',
  `unit_name` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gram_conversion` decimal(10,2) DEFAULT '1.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '上下架狀態: 1=上架, 0=下架'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `ingredients`
--

INSERT INTO `ingredients` (`ingredient_id`, `ingredient_name`, `main_category`, `sub_category`, `ingredient_image_url`, `kcal_per_100g`, `protein_per_100g`, `fat_per_100g`, `carbs_per_100g`, `unit_name`, `gram_conversion`, `is_active`) VALUES
(1, '蒜頭 (整粒)', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/garlic-clove.png', '149.00', '6.40', '0.50', '33.10', '瓣', '5.00', 1),
(2, '蒜末', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/minced-garlic.png', '149.00', '6.40', '0.50', '33.10', '克', '1.00', 1),
(3, '洋蔥 (整顆)', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/onion-whole.png', '40.00', '1.10', '0.10', '9.30', '顆', '150.00', 1),
(4, '洋蔥絲', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/onion-sliced.png', '40.00', '1.10', '0.10', '9.30', '克', '1.00', 1),
(5, '洋蔥丁', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/onion-diced.png', '40.00', '1.10', '0.10', '9.30', '克', '1.00', 1),
(6, '紅蔥頭', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/shallots.png', '72.00', '2.50', '0.10', '16.80', '顆', '15.00', 1),
(7, '珍珠洋蔥', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/pearl-onion.png', '35.00', '1.00', '0.10', '8.00', '顆', '10.00', 1),
(8, '薑 (塊)', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/ginger-whole.png', '80.00', '1.80', '0.80', '17.80', '克', '1.00', 1),
(9, '薑片', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/ginger-sliced.png', '80.00', '1.80', '0.80', '17.80', '克', '1.00', 1),
(10, '薑絲', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/ginger-shredded.png', '80.00', '1.80', '0.80', '17.80', '克', '1.00', 1),
(11, '薑泥', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/ginger-grated.png', '80.00', '1.80', '0.80', '17.80', '克', '1.00', 1),
(12, '南薑', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/galangal.png', '71.00', '1.00', '1.00', '15.00', '克', '1.00', 1),
(13, '蔥 (整支)', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/scallion-whole.png', '32.00', '1.80', '0.20', '7.30', '支', '15.00', 1),
(14, '蔥段', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/scallion-sections.png', '32.00', '1.80', '0.20', '7.30', '克', '1.00', 1),
(15, '蔥絲', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/scallion-shredded.png', '32.00', '1.80', '0.20', '7.30', '克', '1.00', 1),
(16, '蔥花', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/scallion-chopped.png', '32.00', '1.80', '0.20', '7.30', '克', '1.00', 1),
(17, '辣椒 (整根)', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/chili-whole.png', '40.00', '1.90', '0.40', '8.80', '根', '10.00', 1),
(18, '辣椒絲', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/chili-sliced.png', '40.00', '1.90', '0.40', '8.80', '克', '1.00', 1),
(19, '檸檬皮屑', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/lemon-zest.png', '47.00', '1.50', '0.30', '16.00', '克', '1.00', 1),
(20, '油蔥酥', 'fresh-produce', 'aromatics', 'img/ingredients/fresh-produce/aromatics/fried-shallots.png', '605.00', '4.50', '45.00', '45.00', '克', '1.00', 1),
(21, '巴西里', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/parsley.png', '36.00', '2.90', '0.80', '6.30', '克', '1.00', 1),
(22, '百里香', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/thyme.png', '101.00', '5.60', '1.70', '24.50', '克', '1.00', 1),
(23, '羅勒葉', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/basil-leaves.png', '23.00', '3.10', '0.60', '2.70', '克', '1.00', 1),
(24, '泰式羅勒', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/thai-basil.png', '23.00', '3.10', '0.60', '2.70', '克', '1.00', 1),
(25, '九層塔', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/taiwanese-basil.png', '26.00', '2.90', '0.50', '4.10', '克', '1.00', 1),
(26, '打拋葉', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/holy-basil.png', '23.00', '3.10', '0.60', '2.70', '克', '1.00', 1),
(27, '香菜', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/cilantro.png', '23.00', '2.10', '0.50', '3.70', '克', '1.00', 1),
(28, '迷迭香', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/rosemary.png', '131.00', '3.30', '5.90', '20.70', '克', '1.00', 1),
(29, '薄荷葉', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/mint-leaves.png', '44.00', '3.30', '0.70', '8.40', '克', '1.00', 1),
(30, '蒔蘿', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/dill.png', '43.00', '3.50', '1.10', '7.00', '克', '1.00', 1),
(31, '香茅', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/lemongrass.png', '99.00', '1.80', '0.50', '25.30', '支', '20.00', 1),
(32, '斑蘭葉', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/pandan-leaf.png', '40.00', '1.00', '0.30', '9.00', '片', '5.00', 1),
(33, '細香蔥', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/chives.png', '30.00', '3.30', '0.70', '4.40', '克', '1.00', 1),
(34, '檸檬葉', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/kaffir-lime-leaves.png', '126.00', '7.00', '3.00', '20.00', '片', '1.00', 1),
(35, '山芹菜 (鴨兒芹)', 'fresh-produce', 'fresh-herbs', 'img/ingredients/fresh-produce/fresh-herbs/mitsuba.png', '23.00', '2.20', '0.10', '4.50', '克', '1.00', 1),
(36, '青江菜', 'fresh-produce', 'leafy-greens', 'img/ingredients/fresh-produce/leafy-greens/bok-choy.png', '13.00', '1.50', '0.20', '2.20', '株', '50.00', 1),
(37, '菠菜', 'fresh-produce', 'leafy-greens', 'img/ingredients/fresh-produce/leafy-greens/spinach.png', '23.00', '2.90', '0.40', '3.60', '克', '1.00', 1),
(38, '空心菜', 'fresh-produce', 'leafy-greens', 'img/ingredients/fresh-produce/leafy-greens/water-spinach.png', '19.00', '2.60', '0.20', '3.10', '克', '1.00', 1),
(39, '地瓜葉', 'fresh-produce', 'leafy-greens', 'img/ingredients/fresh-produce/leafy-greens/sweet-potato-leaves.png', '27.00', '3.20', '0.30', '4.60', '克', '1.00', 1),
(40, '芹菜葉', 'fresh-produce', 'leafy-greens', 'img/ingredients/fresh-produce/leafy-greens/celery-leaves.png', '16.00', '1.20', '0.20', '3.40', '克', '1.00', 1),
(41, '高麗菜絲', 'fresh-produce', 'cruciferous', 'img/ingredients/fresh-produce/cruciferous/shredded-cabbage.png', '25.00', '1.30', '0.10', '5.80', '克', '1.00', 1),
(42, '大白菜 (山東白菜)', 'fresh-produce', 'cruciferous', 'img/ingredients/fresh-produce/cruciferous/napa-cabbage.png', '13.00', '1.10', '0.10', '2.40', '克', '1.00', 1),
(43, '花椰菜', 'fresh-produce', 'cruciferous', 'img/ingredients/fresh-produce/cruciferous/cauliflower.png', '25.00', '1.90', '0.30', '5.00', '朵', '20.00', 1),
(44, '青花菜', 'fresh-produce', 'cruciferous', 'img/ingredients/fresh-produce/cruciferous/broccoli.png', '34.00', '2.80', '0.40', '6.60', '朵', '15.00', 1),
(45, '韭菜花', 'fresh-produce', 'cruciferous', 'img/ingredients/fresh-produce/cruciferous/chive-flowers.png', '30.00', '2.00', '0.30', '6.00', '克', '1.00', 1),
(46, '西洋芹', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/celery-stalk.png', '14.00', '0.70', '0.20', '3.00', '支', '40.00', 1),
(47, '芹菜段', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/celery-sections.png', '14.00', '0.70', '0.20', '3.00', '克', '1.00', 1),
(48, '蘆筍', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/asparagus.png', '20.00', '2.20', '0.10', '3.90', '根', '15.00', 1),
(49, '玉米筍', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/baby-corn.png', '26.00', '2.20', '0.40', '5.00', '根', '10.00', 1),
(50, '筍絲', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/bamboo-shoots-shredded.png', '25.00', '2.30', '0.20', '4.50', '克', '1.00', 1),
(51, '筍片', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/bamboo-shoots-sliced.png', '25.00', '2.30', '0.20', '4.50', '克', '1.00', 1),
(52, '蘿蔓生菜', 'fresh-produce', 'salad-greens', 'img/ingredients/fresh-produce/salad-greens/romaine-lettuce.png', '17.00', '1.20', '0.30', '3.30', '片', '15.00', 1),
(53, '芝麻葉 (火箭菜)', 'fresh-produce', 'salad-greens', 'img/ingredients/fresh-produce/salad-greens/arugula.png', '25.00', '2.60', '0.70', '3.70', '克', '1.00', 1),
(54, '結球萵苣', 'fresh-produce', 'salad-greens', 'img/ingredients/fresh-produce/salad-greens/iceberg-lettuce.png', '14.00', '0.90', '0.10', '3.00', '克', '1.00', 1),
(55, '紅蘿蔔塊', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/carrot-chunks.png', '41.00', '0.90', '0.20', '9.60', '克', '1.00', 1),
(56, '紅蘿蔔丁', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/carrot-diced.png', '41.00', '0.90', '0.20', '9.60', '克', '1.00', 1),
(57, '紅蘿蔔絲', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/carrot-shredded.png', '41.00', '0.90', '0.20', '9.60', '克', '1.00', 1),
(58, '白蘿蔔泥', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/radish-grated.png', '18.00', '0.60', '0.10', '4.10', '克', '1.00', 1),
(59, '白蘿蔔 (輪狀)', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/radish-sliced.png', '18.00', '0.60', '0.10', '4.10', '片', '30.00', 1),
(60, '甜菜根', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/beetroot.png', '43.00', '1.60', '0.20', '10.00', '克', '1.00', 1),
(61, '蓮藕 (生)', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/lotus-root-raw.png', '74.00', '2.60', '0.10', '17.00', '克', '1.00', 1),
(62, '蓮藕 (熟)', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/lotus-root-cooked.png', '66.00', '2.00', '0.10', '16.00', '片', '20.00', 1),
(63, '荸薺', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/water-chestnut.png', '97.00', '1.40', '0.10', '24.00', '顆', '15.00', 1),
(64, '豆薯', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/jicama.png', '38.00', '0.70', '0.10', '9.00', '克', '1.00', 1),
(65, '馬鈴薯 (大)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/potato-large.png', '77.00', '2.00', '0.10', '17.00', '顆', '200.00', 1),
(66, '馬鈴薯 (小)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/potato-small.png', '77.00', '2.00', '0.10', '17.00', '顆', '50.00', 1),
(67, '馬鈴薯泥', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/mashed-potato.png', '88.00', '2.00', '1.50', '17.00', '克', '1.00', 1),
(68, '地瓜 (白)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/sweet-potato-white.png', '116.00', '1.60', '0.10', '28.00', '顆', '150.00', 1),
(69, '地瓜 (紫)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/sweet-potato-purple.png', '118.00', '1.50', '0.20', '27.00', '顆', '150.00', 1),
(70, '地瓜 (紅/黃)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/sweet-potato-yellow.png', '115.00', '1.50', '0.10', '27.00', '顆', '150.00', 1),
(71, '地瓜片', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/sweet-potato-slices.png', '115.00', '1.50', '0.10', '27.00', '克', '1.00', 1),
(72, '芋頭塊', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/taro-chunks.png', '112.00', '1.50', '0.20', '26.00', '克', '1.00', 1),
(73, '芋頭球', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/taro-balls.png', '112.00', '1.50', '0.20', '26.00', '顆', '30.00', 1),
(74, '山藥 (白)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/yam-white.png', '73.00', '1.50', '0.10', '17.00', '克', '1.00', 1),
(75, '山藥 (紫)', 'fresh-produce', 'tubers-starches', 'img/ingredients/fresh-produce/tubers-starches/yam-purple.png', '85.00', '1.70', '0.10', '20.00', '克', '1.00', 1),
(76, '南瓜', 'fresh-produce', 'squashes-gourds', 'img/ingredients/fresh-produce/squashes-gourds/pumpkin.png', '69.00', '1.00', '0.10', '17.00', '克', '1.00', 1),
(77, '櫛瓜', 'fresh-produce', 'squashes-gourds', 'img/ingredients/fresh-produce/squashes-gourds/zucchini.png', '17.00', '1.20', '0.30', '3.10', '條', '200.00', 1),
(78, '小黃瓜 (整條)', 'fresh-produce', 'squashes-gourds', 'img/ingredients/fresh-produce/squashes-gourds/cucumber-whole.png', '13.00', '0.60', '0.10', '2.80', '條', '100.00', 1),
(79, '小黃瓜片', 'fresh-produce', 'squashes-gourds', 'img/ingredients/fresh-produce/squashes-gourds/cucumber-sliced.png', '13.00', '0.60', '0.10', '2.80', '克', '1.00', 1),
(80, '小黃瓜丁', 'fresh-produce', 'squashes-gourds', 'img/ingredients/fresh-produce/squashes-gourds/cucumber-diced.png', '13.00', '0.60', '0.10', '2.80', '克', '1.00', 1),
(81, '苦瓜', 'fresh-produce', 'squashes-gourds', 'img/ingredients/fresh-produce/squashes-gourds/bitter-melon.png', '19.00', '1.00', '0.10', '4.30', '條', '400.00', 1),
(82, '圓茄子', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/eggplant-round.png', '25.00', '1.00', '0.20', '5.90', '顆', '250.00', 1),
(83, '長茄子', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/eggplant-long.png', '25.00', '1.00', '0.20', '5.90', '條', '150.00', 1),
(84, '日本圓茄', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/eggplant-japanese.png', '25.00', '1.00', '0.20', '5.90', '顆', '200.00', 1),
(85, '泰國圓茄', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/eggplant-thai.png', '30.00', '1.20', '0.20', '6.50', '顆', '40.00', 1),
(86, '紅甜椒', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/bell-pepper-red.png', '26.00', '1.00', '0.30', '6.00', '顆', '150.00', 1),
(87, '黃甜椒', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/bell-pepper-yellow.png', '27.00', '1.00', '0.20', '6.30', '顆', '150.00', 1),
(88, '牛番茄', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/tomato-beefsteak.png', '18.00', '0.90', '0.20', '3.90', '顆', '150.00', 1),
(89, '小番茄', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/tomato-cherry.png', '24.00', '1.00', '0.20', '5.10', '顆', '10.00', 1),
(90, '綜合菇類', 'fresh-produce', 'mushrooms', 'img/ingredients/fresh-produce/mushrooms/mixed-mushrooms.png', '30.00', '3.00', '0.30', '4.50', '克', '1.00', 1),
(91, '鴻喜菇', 'fresh-produce', 'mushrooms', 'img/ingredients/fresh-produce/mushrooms/shimeji.png', '31.00', '2.50', '0.50', '5.00', '包', '100.00', 1),
(92, '香菇', 'fresh-produce', 'mushrooms', 'img/ingredients/fresh-produce/mushrooms/shiitake.png', '34.00', '2.20', '0.50', '6.80', '朵', '20.00', 1),
(93, '木耳 (整朵)', 'fresh-produce', 'mushrooms', 'img/ingredients/fresh-produce/mushrooms/wood-ear-whole.png', '24.00', '1.10', '0.10', '6.50', '朵', '30.00', 1),
(94, '木耳絲', 'fresh-produce', 'mushrooms', 'img/ingredients/fresh-produce/mushrooms/wood-ear-shredded.png', '24.00', '1.10', '0.10', '6.50', '克', '1.00', 1),
(95, '裙帶菜', 'fresh-produce', 'algae', 'img/ingredients/fresh-produce/algae/wakame.png', '45.00', '3.00', '0.60', '9.00', '克', '1.00', 1),
(96, '海帶絲', 'fresh-produce', 'algae', 'img/ingredients/fresh-produce/algae/shredded-kelp.png', '15.00', '1.00', '0.10', '3.50', '克', '1.00', 1),
(97, '海苔 (片)', 'fresh-produce', 'algae', 'img/ingredients/fresh-produce/algae/nori-sheet.png', '300.00', '35.00', '3.00', '40.00', '片', '2.50', 1),
(98, '海苔 (絲/粉)', 'fresh-produce', 'algae', 'img/ingredients/fresh-produce/algae/nori-shredded.png', '300.00', '35.00', '3.00', '40.00', '克', '1.00', 1),
(99, '四季豆', 'fresh-produce', 'fresh-legumes', 'img/ingredients/fresh-produce/fresh-legumes/green-beans.png', '31.00', '1.80', '0.20', '7.00', '克', '1.00', 1),
(100, '毛豆仁', 'fresh-produce', 'fresh-legumes', 'img/ingredients/fresh-produce/fresh-legumes/edamame.png', '121.00', '11.90', '5.20', '8.90', '克', '1.00', 1),
(101, '黃豆芽', 'fresh-produce', 'fresh-legumes', 'img/ingredients/fresh-produce/fresh-legumes/soybean-sprouts.png', '34.00', '4.00', '1.50', '2.50', '克', '1.00', 1),
(102, '綠豆芽', 'fresh-produce', 'fresh-legumes', 'img/ingredients/fresh-produce/fresh-legumes/mung-bean-sprouts.png', '30.00', '3.00', '0.20', '5.90', '克', '1.00', 1),
(103, '豌豆', 'fresh-produce', 'fresh-legumes', 'img/ingredients/fresh-produce/fresh-legumes/peas.png', '81.00', '5.40', '0.40', '14.50', '克', '1.00', 1),
(104, '長豇豆', 'fresh-produce', 'fresh-legumes', 'img/ingredients/fresh-produce/fresh-legumes/long-beans.png', '47.00', '2.80', '0.40', '8.00', '克', '1.00', 1),
(105, '金鑽鳳梨', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/pineapple-golden-diamond.png', '50.00', '0.50', '0.10', '13.00', '份', '110.00', 1),
(106, '牛奶鳳梨', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/pineapple-milk.png', '50.00', '0.50', '0.10', '13.00', '份', '110.00', 1),
(107, '愛文芒果', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/mango-irwin.png', '50.00', '0.40', '0.20', '13.00', '顆', '350.00', 1),
(108, '金煌芒果', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/mango-jin-huang.png', '52.00', '0.50', '0.20', '14.00', '顆', '600.00', 1),
(109, '香蕉', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/banana.png', '89.00', '1.10', '0.30', '23.00', '根', '120.00', 1),
(110, '芭蕉', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/plantain.png', '90.00', '1.20', '0.30', '23.50', '根', '100.00', 1),
(111, '蛋蕉', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/egg-banana.png', '92.00', '1.20', '0.30', '24.00', '根', '60.00', 1),
(112, '青木瓜', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/green-papaya.png', '27.00', '0.60', '0.10', '7.00', '克', '1.00', 1),
(113, '熟木瓜', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/ripe-papaya.png', '39.00', '0.50', '0.10', '10.00', '顆', '500.00', 1),
(114, '紅肉火龍果', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/dragon-fruit-red.png', '50.00', '1.10', '0.20', '12.30', '顆', '400.00', 1),
(115, '白肉火龍果', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/dragon-fruit-white.png', '51.00', '1.10', '0.20', '12.40', '顆', '400.00', 1),
(116, '百香果', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/passion-fruit.png', '66.00', '2.20', '0.70', '11.20', '顆', '60.00', 1),
(117, '榴槤', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/durian.png', '147.00', '1.50', '5.30', '27.00', '克', '1.00', 1),
(118, '山竹', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/mangosteen.png', '73.00', '0.40', '0.60', '18.00', '顆', '30.00', 1),
(119, '紅毛丹', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/rambutan.png', '82.00', '0.70', '0.20', '21.00', '顆', '30.00', 1),
(120, '釋迦', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/custard-apple.png', '104.00', '1.50', '0.30', '26.00', '顆', '350.00', 1),
(121, '鳳梨釋迦', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/atemoya.png', '99.00', '1.20', '0.40', '25.00', '顆', '500.00', 1),
(122, '椰子水', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/coconut-water.png', '19.00', '0.70', '0.20', '3.70', '毫升', '1.00', 1),
(123, '椰子肉', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/coconut-meat.png', '354.00', '3.30', '33.50', '15.20', '克', '1.00', 1),
(124, '甘蔗汁', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/sugarcane-juice.png', '58.00', '0.20', '0.10', '15.00', '毫升', '1.00', 1),
(125, '龍眼', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/longan.png', '70.00', '1.00', '0.10', '18.00', '顆', '10.00', 1),
(126, '荔枝', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/lychee.png', '65.00', '0.80', '0.40', '16.50', '顆', '20.00', 1),
(127, '人心果', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/sapodilla.png', '83.00', '0.40', '1.10', '20.00', '顆', '80.00', 1),
(128, '仙桃', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/egg-fruit.png', '138.00', '1.60', '0.20', '36.00', '顆', '200.00', 1),
(129, '巴西莓果泥', 'fruits', 'tropical-fruits', 'img/ingredients/fruits/tropical-fruits/acai-puree.png', '70.00', '1.00', '5.00', '4.00', '克', '1.00', 1),
(130, '西瓜 (大)', 'fruits', 'melons', 'img/ingredients/fruits/melons/watermelon-large.png', '33.00', '0.80', '0.10', '8.00', '份', '180.00', 1),
(131, '西瓜 (小)', 'fruits', 'melons', 'img/ingredients/fruits/melons/watermelon-small.png', '34.00', '0.70', '0.10', '8.50', '份', '180.00', 1),
(132, '哈密瓜', 'fruits', 'melons', 'img/ingredients/fruits/melons/cantaloupe.png', '34.00', '0.80', '0.20', '8.00', '份', '150.00', 1),
(133, '美濃瓜', 'fruits', 'melons', 'img/ingredients/fruits/melons/honeydew-melon.png', '36.00', '0.50', '0.10', '9.00', '顆', '400.00', 1),
(134, '檸檬 (黃)', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/lemon-yellow.png', '29.00', '1.10', '0.30', '9.00', '顆', '100.00', 1),
(135, '檸檬 (綠)', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/lemon-green.png', '30.00', '1.00', '0.30', '9.30', '顆', '100.00', 1),
(136, '檸檬角', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/lemon-wedge.png', '30.00', '1.00', '0.30', '9.30', '角', '15.00', 1),
(137, '萊姆', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/lime.png', '30.00', '0.70', '0.20', '10.50', '顆', '80.00', 1),
(138, '葡萄柚', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/grapefruit.png', '32.00', '0.70', '0.10', '8.00', '顆', '300.00', 1),
(139, '葡萄柚果肉', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/grapefruit-pulp.png', '32.00', '0.70', '0.10', '8.00', '克', '1.00', 1),
(140, '柳橙', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/orange.png', '47.00', '0.90', '0.10', '12.00', '顆', '150.00', 1),
(141, '椪柑', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/ponkan.png', '45.00', '0.80', '0.10', '11.50', '顆', '180.00', 1),
(142, '文旦', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/pomelo.png', '38.00', '0.70', '0.10', '9.50', '顆', '450.00', 1),
(143, '草莓', 'fruits', 'berries', 'img/ingredients/fruits/berries/strawberry.png', '32.00', '0.70', '0.30', '7.70', '顆', '15.00', 1),
(144, '藍莓', 'fruits', 'berries', 'img/ingredients/fruits/berries/blueberry.png', '57.00', '0.70', '0.30', '14.50', '顆', '1.50', 1),
(145, '葡萄', 'fruits', 'berries', 'img/ingredients/fruits/berries/grape.png', '69.00', '0.70', '0.20', '18.00', '顆', '10.00', 1),
(146, '桑椹', 'fruits', 'berries', 'img/ingredients/fruits/berries/mulberry.png', '43.00', '1.40', '0.40', '10.00', '顆', '3.00', 1),
(147, '蘋果', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/apple-red.png', '52.00', '0.30', '0.20', '14.00', '顆', '180.00', 1),
(148, '青蘋果', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/apple-green.png', '50.00', '0.30', '0.20', '13.50', '顆', '180.00', 1),
(149, '櫻桃', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/cherry.png', '50.00', '1.00', '0.30', '12.00', '顆', '8.00', 1),
(150, '水蜜桃', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/peach.png', '39.00', '0.90', '0.30', '9.50', '顆', '150.00', 1),
(151, '李子', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/plum.png', '46.00', '0.70', '0.30', '11.40', '顆', '50.00', 1),
(152, '梨', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/pear.png', '42.00', '0.40', '0.10', '11.00', '顆', '200.00', 1),
(153, '甜柿', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/persimmon-fresh.png', '70.00', '0.60', '0.20', '18.50', '顆', '200.00', 1),
(154, '柿餅', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/persimmon-dried.png', '274.00', '1.40', '0.60', '73.00', '個', '50.00', 1),
(155, '枇杷', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/loquat.png', '47.00', '0.40', '0.20', '12.00', '顆', '30.00', 1),
(156, '無花果', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/fig.png', '74.00', '0.80', '0.30', '19.00', '顆', '50.00', 1),
(157, '紅石榴', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/pomegranate.png', '83.00', '1.70', '1.20', '19.00', '顆', '250.00', 1),
(158, '楊桃', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/star-fruit.png', '31.00', '1.00', '0.30', '6.70', '顆', '200.00', 1),
(159, '蓮霧', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/wax-apple.png', '34.00', '0.50', '0.20', '8.50', '顆', '100.00', 1),
(160, '珍珠芭樂', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/guava-white.png', '38.00', '0.80', '0.20', '9.70', '顆', '350.00', 1),
(161, '紅心芭樂', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/guava-red.png', '38.00', '0.80', '0.20', '9.70', '顆', '350.00', 1),
(162, '酪梨', 'fruits', 'temperate-fruits', 'img/ingredients/fruits/temperate-fruits/avocado.png', '160.00', '2.00', '14.70', '8.50', '顆', '200.00', 1),
(163, '雞胸肉', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/chicken-breast.png', '109.00', '23.30', '1.10', '0.00', '克', '1.00', 1),
(164, '雞腿肉塊', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/chicken-thigh-chunks.png', '150.00', '18.50', '8.00', '0.00', '克', '1.00', 1),
(165, '雞翅', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/chicken-wings.png', '210.00', '17.50', '15.00', '0.00', '隻', '45.00', 1),
(166, '雞丁', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/chicken-diced.png', '150.00', '18.50', '8.00', '0.00', '克', '1.00', 1),
(167, '火雞胸肉', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/turkey-breast.png', '104.00', '24.00', '0.70', '0.00', '克', '1.00', 1),
(168, '全鴨', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/duck-whole.png', '240.00', '16.00', '19.00', '0.00', '隻', '2000.00', 1),
(169, '生鴨腿', 'meat-poultry', 'poultry', 'img/ingredients/meat-poultry/poultry/duck-leg-raw.png', '210.00', '17.00', '15.00', '0.00', '隻', '200.00', 1),
(170, '牛肉片', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-slices.png', '250.00', '18.00', '19.00', '0.00', '克', '1.00', 1),
(171, '牛腱', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-shank.png', '140.00', '21.00', '6.00', '0.00', '克', '1.00', 1),
(172, '菲力牛排', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-filet.png', '215.00', '20.00', '15.00', '0.00', '客', '180.00', 1),
(173, '肋眼牛排', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-ribeye.png', '290.00', '17.00', '25.00', '0.00', '客', '280.00', 1),
(174, '戰斧牛排', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-tomahawk.png', '250.00', '18.00', '20.00', '0.00', '客', '1000.00', 1),
(175, '牛腩', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-brisket.png', '330.00', '15.00', '30.00', '0.00', '克', '1.00', 1),
(176, '牛肋條', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-rib-fingers.png', '380.00', '14.00', '36.00', '0.00', '克', '1.00', 1),
(177, '牛舌', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/beef-tongue.png', '224.00', '15.00', '18.00', '0.00', '克', '1.00', 1),
(178, '里肌豬排', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-loin-chop.png', '180.00', '20.00', '11.00', '0.00', '片', '120.00', 1),
(179, '五花肉 (塊)', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-belly-block.png', '360.00', '14.00', '34.00', '0.00', '克', '1.00', 1),
(180, '五花肉條', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-belly-strip.png', '360.00', '14.00', '34.00', '0.00', '條', '150.00', 1),
(181, '豬小排 (塊)', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-rib-chunks.png', '240.00', '17.00', '19.00', '0.00', '克', '1.00', 1),
(182, '豬肋排 (整排)', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-ribs-rack.png', '280.00', '16.00', '24.00', '0.00', '排', '500.00', 1),
(183, '羊腿 (整隻)', 'meat-poultry', 'lamb', 'img/ingredients/meat-poultry/lamb/lamb-leg-whole.png', '200.00', '18.00', '14.00', '0.00', '隻', '2500.00', 1),
(184, '法式羊排', 'meat-poultry', 'lamb', 'img/ingredients/meat-poultry/lamb/lamb-french-rack.png', '260.00', '16.00', '22.00', '0.00', '支', '80.00', 1),
(185, '羊絞肉', 'meat-poultry', 'lamb', 'img/ingredients/meat-poultry/lamb/ground-lamb.png', '280.00', '17.00', '24.00', '0.00', '克', '1.00', 1),
(186, '豬絞肉', 'meat-poultry', 'ground-meat', 'img/ingredients/meat-poultry/ground-meat/ground-pork.png', '230.00', '18.00', '18.00', '0.00', '克', '1.00', 1),
(187, '混合牛豬絞肉', 'meat-poultry', 'ground-meat', 'img/ingredients/meat-poultry/ground-meat/ground-beef-pork-mix.png', '250.00', '18.00', '20.00', '0.00', '克', '1.00', 1),
(188, '香腸肉 (散裝)', 'meat-poultry', 'ground-meat', 'img/ingredients/meat-poultry/ground-meat/sausage-meat.png', '320.00', '14.00', '28.00', '3.00', '克', '1.00', 1),
(189, '火腿', 'meat-poultry', 'cured-meats', 'img/ingredients/meat-poultry/cured-meats/ham.png', '120.00', '16.00', '5.00', '3.00', '片', '25.00', 1),
(190, '培根', 'meat-poultry', 'cured-meats', 'img/ingredients/meat-poultry/cured-meats/bacon.png', '400.00', '12.00', '38.00', '1.00', '片', '20.00', 1),
(191, '加拿大培根', 'meat-poultry', 'cured-meats', 'img/ingredients/meat-poultry/cured-meats/canadian-bacon.png', '160.00', '20.00', '8.00', '2.00', '片', '25.00', 1),
(192, '帕瑪火腿', 'meat-poultry', 'cured-meats', 'img/ingredients/meat-poultry/cured-meats/prosciutto.png', '230.00', '25.00', '14.00', '0.00', '片', '15.00', 1),
(193, '薩拉米香腸', 'meat-poultry', 'cured-meats', 'img/ingredients/meat-poultry/cured-meats/salami.png', '330.00', '22.00', '26.00', '2.00', '片', '5.00', 1),
(194, '叉燒肉', 'meat-poultry', 'cured-meats', 'img/ingredients/meat-poultry/cured-meats/char-siu.png', '280.00', '18.00', '18.00', '10.00', '克', '1.00', 1),
(195, '香腸', 'meat-poultry', 'processed-meats', 'img/ingredients/meat-poultry/processed-meats/sausage.png', '340.00', '13.00', '30.00', '5.00', '根', '50.00', 1),
(196, '熱狗', 'meat-poultry', 'processed-meats', 'img/ingredients/meat-poultry/processed-meats/hot-dog.png', '290.00', '12.00', '25.00', '4.00', '根', '60.00', 1),
(197, '午餐肉', 'meat-poultry', 'processed-meats', 'img/ingredients/meat-poultry/processed-meats/spam.png', '310.00', '13.00', '27.00', '3.00', '克', '1.00', 1),
(198, '滷大腸', 'meat-poultry', 'processed-meats', 'img/ingredients/meat-poultry/processed-meats/braised-intestine.png', '180.00', '12.00', '14.00', '1.00', '克', '1.00', 1),
(199, '豬血糕', 'meat-poultry', 'processed-meats', 'img/ingredients/meat-poultry/processed-meats/pig-blood-cake.png', '190.00', '7.00', '1.00', '38.00', '塊', '80.00', 1),
(200, '肝醬', 'meat-poultry', 'processed-meats', 'img/ingredients/meat-poultry/processed-meats/pate.png', '320.00', '14.00', '28.00', '3.00', '克', '1.00', 1),
(201, '鮭魚排', 'seafood', 'fish', 'img/ingredients/seafood/fish/salmon-steak.png', '208.00', '20.00', '13.00', '0.00', '克', '1.00', 1),
(202, '鯛魚片', 'seafood', 'fish', 'img/ingredients/seafood/fish/tilapia-fillet.png', '110.00', '20.00', '2.50', '0.00', '克', '1.00', 1),
(203, '鱸魚片', 'seafood', 'fish', 'img/ingredients/seafood/fish/sea-bass-fillet.png', '97.00', '18.50', '2.00', '0.00', '片', '150.00', 1),
(204, '鱸魚 (整尾)', 'seafood', 'fish', 'img/ingredients/seafood/fish/sea-bass-whole.png', '97.00', '18.50', '2.00', '0.00', '尾', '500.00', 1),
(205, '鱈魚排', 'seafood', 'fish', 'img/ingredients/seafood/fish/cod-steak.png', '82.00', '17.80', '0.70', '0.00', '克', '1.00', 1),
(206, '鮪魚生魚片', 'seafood', 'fish', 'img/ingredients/seafood/fish/tuna-sashimi.png', '130.00', '28.00', '0.60', '0.00', '克', '1.00', 1),
(207, '燻鮭魚片', 'seafood', 'fish', 'img/ingredients/seafood/fish/smoked-salmon.png', '117.00', '18.00', '4.50', '0.00', '片', '30.00', 1),
(208, '蒲燒鰻魚', 'seafood', 'fish', 'img/ingredients/seafood/fish/kabayaki-eel.png', '289.00', '19.00', '20.00', '8.00', '克', '1.00', 1),
(209, '小魚乾', 'seafood', 'fish', 'img/ingredients/seafood/fish/dried-anchovies.png', '332.00', '65.00', '6.00', '0.50', '克', '1.00', 1),
(210, '大虎蝦', 'seafood', 'crustaceans', 'img/ingredients/seafood/crustaceans/tiger-prawn.png', '95.00', '21.00', '1.00', '0.50', '隻', '45.00', 1),
(211, '龍蝦肉', 'seafood', 'crustaceans', 'img/ingredients/seafood/crustaceans/lobster-meat.png', '89.00', '19.00', '0.90', '0.00', '克', '1.00', 1),
(212, '乾蝦米', 'seafood', 'crustaceans', 'img/ingredients/seafood/crustaceans/dried-shrimp.png', '250.00', '50.00', '3.00', '2.00', '克', '1.00', 1),
(213, '新鮮蛤蜊', 'seafood', 'shellfish', 'img/ingredients/seafood/shellfish/fresh-clams.png', '55.00', '9.50', '0.80', '2.00', '顆', '20.00', 1),
(214, '淡菜', 'seafood', 'shellfish', 'img/ingredients/seafood/shellfish/mussels.png', '86.00', '12.00', '2.20', '3.50', '顆', '25.00', 1),
(215, '生蠔 (帶殼)', 'seafood', 'shellfish', 'img/ingredients/seafood/shellfish/oyster-in-shell.png', '60.00', '7.00', '1.50', '4.00', '顆', '100.00', 1),
(216, '鮮蚵 (去殼)', 'seafood', 'shellfish', 'img/ingredients/seafood/shellfish/shucked-oyster.png', '60.00', '7.00', '1.50', '4.00', '克', '1.00', 1),
(217, '生干貝', 'seafood', 'shellfish', 'img/ingredients/seafood/shellfish/scallop.png', '75.00', '15.00', '0.80', '2.50', '顆', '30.00', 1),
(218, '鮑魚', 'seafood', 'shellfish', 'img/ingredients/seafood/shellfish/abalone.png', '80.00', '16.00', '0.60', '2.00', '顆', '40.00', 1),
(219, '花枝圈', 'seafood', 'cephalopods', 'img/ingredients/seafood/cephalopods/squid-rings.png', '92.00', '16.00', '1.00', '3.00', '克', '1.00', 1),
(220, '章魚腳', 'seafood', 'cephalopods', 'img/ingredients/seafood/cephalopods/octopus-leg.png', '82.00', '15.00', '1.00', '2.00', '克', '1.00', 1),
(221, '乾魷魚條', 'seafood', 'cephalopods', 'img/ingredients/seafood/cephalopods/dried-squid-strips.png', '313.00', '65.00', '4.00', '2.50', '克', '1.00', 1),
(222, '螺肉', 'seafood', 'mollusks', 'img/ingredients/seafood/mollusks/snail-meat.png', '90.00', '16.50', '1.20', '2.00', '克', '1.00', 1),
(223, '韓式魚板', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/korean-fish-cake.png', '180.00', '13.00', '6.00', '18.00', '片', '50.00', 1),
(224, '日式魚板', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/narutomaki.png', '95.00', '12.00', '0.80', '10.00', '片', '10.00', 1),
(225, '竹輪', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/chikuwa.png', '121.00', '13.50', '2.00', '12.00', '根', '40.00', 1),
(226, '甜不辣', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/tempura.png', '196.00', '11.00', '8.00', '20.00', '片', '35.00', 1),
(227, '魚丸', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/fish-ball.png', '110.00', '12.00', '2.50', '10.00', '顆', '20.00', 1),
(228, '鮭魚卵', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/salmon-roe.png', '250.00', '25.00', '14.00', '3.00', '克', '1.00', 1),
(229, '柴魚片', 'seafood', 'processed-seafood', 'img/ingredients/seafood/processed-seafood/bonito-flakes.png', '350.00', '75.00', '4.00', '0.50', '克', '1.00', 1),
(230, '雞蛋', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/chicken-egg.png', '143.00', '12.60', '9.50', '0.70', '顆', '50.00', 1),
(231, '生蛋黃', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/egg-yolk-raw.png', '322.00', '15.90', '26.50', '3.60', '個', '18.00', 1),
(232, '溏心蛋', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/soft-boiled-egg.png', '155.00', '13.00', '10.00', '2.00', '顆', '50.00', 1),
(233, '水煮蛋', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/hard-boiled-egg.png', '155.00', '13.00', '10.60', '1.10', '顆', '50.00', 1),
(234, '水波蛋', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/poached-egg.png', '143.00', '12.60', '9.50', '0.70', '顆', '45.00', 1),
(235, '鹹蛋 (生)', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/salted-egg-raw.png', '185.00', '13.50', '13.50', '1.50', '顆', '60.00', 1),
(236, '鹹蛋 (熟)', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/salted-egg-cooked.png', '185.00', '13.50', '13.50', '1.50', '顆', '60.00', 1),
(237, '皮蛋', 'dairy-eggs-soy', 'eggs', 'img/ingredients/dairy-eggs-soy/eggs/century-egg.png', '171.00', '13.10', '12.10', '2.40', '顆', '65.00', 1),
(238, '鮮乳', 'dairy-eggs-soy', 'dairy-liquids', 'img/ingredients/dairy-eggs-soy/dairy-liquids/milk.png', '62.00', '3.20', '3.50', '4.80', '毫升', '1.00', 1),
(239, '鮮奶油', 'dairy-eggs-soy', 'dairy-liquids', 'img/ingredients/dairy-eggs-soy/dairy-liquids/heavy-cream.png', '340.00', '2.10', '36.00', '2.80', '毫升', '1.00', 1),
(240, '酸奶油', 'dairy-eggs-soy', 'cultured-dairy', 'img/ingredients/dairy-eggs-soy/cultured-dairy/sour-cream.png', '193.00', '2.10', '19.30', '4.60', '克', '1.00', 1),
(241, '希臘優格', 'dairy-eggs-soy', 'cultured-dairy', 'img/ingredients/dairy-eggs-soy/cultured-dairy/greek-yogurt.png', '97.00', '9.00', '5.00', '4.00', '克', '1.00', 1),
(242, '莫札瑞拉 (球)', 'dairy-eggs-soy', 'fresh-cheese', 'img/ingredients/dairy-eggs-soy/fresh-cheese/mozzarella-ball.png', '280.00', '22.00', '22.00', '2.00', '顆', '125.00', 1),
(243, '莫札瑞拉 (絲)', 'dairy-eggs-soy', 'fresh-cheese', 'img/ingredients/dairy-eggs-soy/fresh-cheese/mozzarella-shredded.png', '280.00', '22.00', '22.00', '2.00', '克', '1.00', 1),
(244, '奶油乳酪', 'dairy-eggs-soy', 'fresh-cheese', 'img/ingredients/dairy-eggs-soy/fresh-cheese/cream-cheese.png', '342.00', '5.90', '34.00', '4.10', '克', '1.00', 1),
(245, '馬斯卡彭', 'dairy-eggs-soy', 'fresh-cheese', 'img/ingredients/dairy-eggs-soy/fresh-cheese/mascarpone.png', '429.00', '4.00', '46.00', '3.00', '克', '1.00', 1),
(246, '瑞可塔', 'dairy-eggs-soy', 'fresh-cheese', 'img/ingredients/dairy-eggs-soy/fresh-cheese/ricotta.png', '174.00', '11.00', '13.00', '3.00', '克', '1.00', 1),
(247, '起司鍋醬', 'dairy-eggs-soy', 'fresh-cheese', 'img/ingredients/dairy-eggs-soy/fresh-cheese/fondue-sauce.png', '250.00', '15.00', '18.00', '7.00', '克', '1.00', 1),
(248, '切達 (片)', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/cheddar-slice.png', '400.00', '25.00', '33.00', '1.30', '片', '20.00', 1),
(249, '切達 (絲)', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/cheddar-shredded.png', '400.00', '25.00', '33.00', '1.30', '克', '1.00', 1),
(250, '切達 (塊)', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/cheddar-block.png', '400.00', '25.00', '33.00', '1.30', '克', '1.00', 1),
(251, '帕馬森粉', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/parmesan-powder.png', '431.00', '38.00', '28.00', '4.00', '克', '1.00', 1),
(252, '費塔 (塊)', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/feta-block.png', '264.00', '14.00', '21.00', '4.00', '克', '1.00', 1),
(253, '費塔 (碎)', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/feta-crumbled.png', '264.00', '14.00', '21.00', '4.00', '克', '1.00', 1),
(254, '藍紋起司', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/blue-cheese.png', '353.00', '21.00', '29.00', '2.30', '克', '1.00', 1),
(255, '卡士達醬', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/custard.png', '122.00', '3.00', '4.00', '18.00', '克', '1.00', 1),
(256, '豆腐 (整塊)', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/tofu-block.png', '80.00', '8.00', '4.00', '3.00', '盒', '300.00', 1),
(257, '豆腐丁', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/tofu-diced.png', '80.00', '8.00', '4.00', '3.00', '克', '1.00', 1),
(258, '油豆腐泡', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/fried-tofu-puffs.png', '250.00', '15.00', '20.00', '3.00', '顆', '10.00', 1),
(259, '豆乾絲', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/dried-tofu-shreds.png', '160.00', '18.00', '8.00', '4.00', '克', '1.00', 1),
(260, '無糖豆漿', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/soy-milk-unsweetened.png', '33.00', '3.30', '2.00', '0.70', '毫升', '1.00', 1),
(261, '韓式春醬', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/chunjang.png', '210.00', '10.00', '8.00', '25.00', '克', '1.00', 1),
(262, '炸法拉費球', 'dairy-eggs-soy', 'plant-based-protein', 'img/ingredients/dairy-eggs-soy/plant-based-protein/falafel.png', '330.00', '13.00', '18.00', '31.00', '顆', '25.00', 1),
(263, '白米', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/white-rice-raw.png', '350.00', '7.00', '0.50', '77.00', '克', '1.00', 1),
(264, '糙米', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/brown-rice-raw.png', '360.00', '8.00', '2.50', '72.00', '克', '1.00', 1),
(265, '紫米', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/purple-rice-raw.png', '353.00', '8.50', '2.50', '70.00', '克', '1.00', 1),
(266, '黑米', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/black-rice-raw.png', '340.00', '8.00', '2.00', '72.00', '克', '1.00', 1),
(267, '糯米 (圓)', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/glutinous-rice-round.png', '348.00', '6.50', '0.50', '78.00', '克', '1.00', 1),
(268, '糯米 (長)', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/glutinous-rice-long.png', '348.00', '6.50', '0.50', '78.00', '克', '1.00', 1),
(269, '五穀米', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/multi-grain-rice.png', '355.00', '9.00', '2.00', '72.00', '克', '1.00', 1),
(270, '藜麥', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/quinoa.png', '368.00', '14.10', '6.10', '64.00', '克', '1.00', 1),
(271, '小米', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/millet.png', '378.00', '11.00', '4.20', '73.00', '克', '1.00', 1),
(272, '白飯', 'grains-pasta-bakery', 'rice-grains', 'img/ingredients/grains-pasta-bakery/rice-grains/steamed-rice.png', '130.00', '2.70', '0.30', '28.00', '碗', '200.00', 1),
(273, '薏仁', 'grains-pasta-bakery', 'cereals', 'img/ingredients/grains-pasta-bakery/cereals/barley.png', '354.00', '12.00', '2.30', '73.00', '克', '1.00', 1),
(274, '燕麥片', 'grains-pasta-bakery', 'cereals', 'img/ingredients/grains-pasta-bakery/cereals/rolled-oats.png', '389.00', '16.90', '6.90', '66.00', '克', '1.00', 1),
(275, '蕎麥', 'grains-pasta-bakery', 'cereals', 'img/ingredients/grains-pasta-bakery/cereals/buckwheat.png', '343.00', '13.00', '3.40', '71.00', '克', '1.00', 1),
(276, '義大利麵 (直)', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/spaghetti.png', '355.00', '13.00', '1.50', '71.00', '克', '1.00', 1),
(277, '義大利麵 (扁)', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/linguine.png', '355.00', '13.00', '1.50', '71.00', '克', '1.00', 1),
(278, '義大利麵 (寬)', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/fettuccine.png', '355.00', '13.00', '1.50', '71.00', '克', '1.00', 1),
(279, '通心粉', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/macaroni.png', '355.00', '13.00', '1.50', '71.00', '克', '1.00', 1),
(280, '麵疙瘩', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/gnocchi.png', '130.00', '3.50', '0.50', '28.00', '克', '1.00', 1),
(281, '千層麵皮', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/lasagna-sheets.png', '350.00', '12.00', '1.50', '70.00', '片', '40.00', 1),
(282, '寬蛋麵', 'grains-pasta-bakery', 'pasta', 'img/ingredients/grains-pasta-bakery/pasta/egg-noodles.png', '380.00', '14.00', '4.50', '68.00', '克', '1.00', 1),
(283, '油麵', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/oil-noodles.png', '160.00', '5.00', '2.50', '30.00', '克', '1.00', 1),
(284, '陽春麵', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/white-noodles.png', '350.00', '11.00', '1.20', '72.00', '克', '1.00', 1),
(285, '紅麵線', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/red-vermicelli.png', '330.00', '10.00', '1.00', '70.00', '克', '1.00', 1),
(286, '烏龍麵', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/udon.png', '125.00', '3.50', '0.50', '26.00', '包', '200.00', 1),
(287, '蕎麥麵', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/soba.png', '340.00', '13.00', '2.00', '68.00', '克', '1.00', 1),
(288, '日式炒麵', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/yakisoba.png', '180.00', '6.00', '4.00', '30.00', '克', '1.00', 1),
(289, '越南河粉 (乾)', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/viet-pho-dry.png', '350.00', '6.00', '0.50', '80.00', '克', '1.00', 1),
(290, '越南河粉 (濕)', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/viet-pho-fresh.png', '140.00', '2.50', '0.20', '32.00', '克', '1.00', 1),
(291, '越南米線', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/viet-rice-vermicelli.png', '350.00', '6.00', '0.50', '80.00', '克', '1.00', 1),
(292, '寬河粉', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/wide-rice-noodles.png', '350.00', '6.00', '0.50', '80.00', '克', '1.00', 1),
(293, '冬粉', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/glass-noodles.png', '345.00', '0.20', '0.10', '85.00', '把', '40.00', 1),
(294, '韓式年糕', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/tteokbokki.png', '230.00', '4.00', '0.50', '52.00', '克', '1.00', 1),
(295, '泡麵', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/instant-noodles.png', '450.00', '9.00', '18.00', '63.00', '包', '85.00', 1),
(296, '蒟蒻絲', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/shirataki.png', '10.00', '0.20', '0.00', '3.00', '份', '100.00', 1),
(297, '生吐司', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/shokupan.png', '280.00', '8.50', '6.50', '47.00', '片', '60.00', 1),
(298, '牛奶吐司', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/milk-toast.png', '270.00', '8.00', '5.00', '48.00', '片', '45.00', 1),
(299, '厚片吐司', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/thick-toast.png', '260.00', '8.00', '4.00', '48.00', '片', '80.00', 1),
(300, '法棍', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/baguette.png', '270.00', '9.50', '1.00', '55.00', '條', '250.00', 1),
(301, '漢堡包', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/burger-bun.png', '280.00', '9.00', '5.00', '50.00', '個', '80.00', 1),
(302, '熱狗麵包', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/hot-dog-bun.png', '275.00', '8.50', '4.50', '50.00', '個', '60.00', 1),
(303, '貝果', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/bagel.png', '260.00', '10.00', '1.50', '50.00', '個', '100.00', 1),
(304, '布里歐', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/brioche.png', '350.00', '9.00', '16.00', '42.00', '個', '60.00', 1),
(305, '英式馬芬', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/english-muffin.png', '235.00', '8.00', '1.50', '46.00', '個', '65.00', 1),
(306, '口袋餅', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/pita-bread.png', '275.00', '9.00', '1.20', '55.00', '個', '60.00', 1),
(307, '烤餅', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/naan.png', '310.00', '9.00', '9.00', '48.00', '個', '90.00', 1),
(308, '麵包丁', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/croutons.png', '400.00', '10.00', '12.00', '65.00', '克', '1.00', 1),
(309, '德國扭結麵包', 'grains-pasta-bakery', 'breads', 'img/ingredients/grains-pasta-bakery/breads/pretzel.png', '330.00', '10.00', '3.00', '65.00', '個', '80.00', 1),
(310, '墨西哥玉米餅皮', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/tortilla-corn.png', '210.00', '5.50', '3.00', '45.00', '片', '30.00', 1),
(311, '刈包皮', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/gua-bao-bun.png', '260.00', '7.00', '2.50', '52.00', '個', '70.00', 1),
(312, '荷葉餅', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/peking-duck-wrapper.png', '280.00', '8.00', '3.50', '54.00', '片', '20.00', 1),
(313, '越南米紙', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/rice-paper.png', '340.00', '0.50', '0.10', '82.00', '片', '10.00', 1),
(314, '餛飩皮', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/wonton-wrappers.png', '280.00', '9.00', '1.50', '58.00', '克', '1.00', 1),
(315, '春捲皮', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/spring-roll-wrappers.png', '290.00', '8.50', '1.00', '61.00', '片', '25.00', 1),
(316, '銅鑼燒皮', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/dorayaki-pancake.png', '280.00', '6.50', '4.50', '53.00', '片', '30.00', 1),
(317, '肉桂捲生麵團', 'grains-pasta-bakery', 'wrappers', 'img/ingredients/grains-pasta-bakery/wrappers/cinnamon-roll-dough.png', '320.00', '5.00', '12.00', '48.00', '個', '100.00', 1),
(318, '披薩餅皮', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/pizza-dough.png', '260.00', '8.00', '2.50', '51.00', '個', '250.00', 1),
(319, '起酥皮', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/puff-pastry.png', '550.00', '7.00', '38.00', '45.00', '片', '40.00', 1),
(320, '希臘千層酥皮', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/phyllo-dough.png', '300.00', '7.00', '6.00', '54.00', '片', '20.00', 1);
INSERT INTO `ingredients` (`ingredient_id`, `ingredient_name`, `main_category`, `sub_category`, `ingredient_image_url`, `kcal_per_100g`, `protein_per_100g`, `fat_per_100g`, `carbs_per_100g`, `unit_name`, `gram_conversion`, `is_active`) VALUES
(321, '派皮', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/pie-crust.png', '450.00', '6.00', '30.00', '40.00', '個', '200.00', 1),
(322, '塔皮 (熟)', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/tart-shell-baked.png', '480.00', '6.50', '28.00', '50.00', '個', '30.00', 1),
(323, '馬卡龍殼', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/macaron-shell.png', '420.00', '7.00', '18.00', '58.00', '個', '10.00', 1),
(324, '炸甜捲餅殼', 'grains-pasta-bakery', 'pastry-shells', 'img/ingredients/grains-pasta-bakery/pastry-shells/cannoli-shell.png', '490.00', '8.00', '25.00', '58.00', '個', '25.00', 1),
(325, '玉米脆片', 'grains-pasta-bakery', 'snacks', 'img/ingredients/grains-pasta-bakery/snacks/tortilla-chips.png', '500.00', '7.00', '25.00', '60.00', '克', '1.00', 1),
(326, '手指餅乾', 'grains-pasta-bakery', 'snacks', 'img/ingredients/grains-pasta-bakery/snacks/ladyfingers.png', '380.00', '8.00', '6.00', '75.00', '個', '10.00', 1),
(327, '牡蠣餅乾', 'grains-pasta-bakery', 'snacks', 'img/ingredients/grains-pasta-bakery/snacks/oyster-crackers.png', '440.00', '9.00', '12.00', '72.00', '克', '1.00', 1),
(328, '吉拿棒 (半成品)', 'grains-pasta-bakery', 'snacks', 'img/ingredients/grains-pasta-bakery/snacks/churros-frozen.png', '310.00', '4.50', '15.00', '38.00', '根', '40.00', 1),
(329, '比利時鬆餅', 'grains-pasta-bakery', 'snacks', 'img/ingredients/grains-pasta-bakery/snacks/belgian-waffle.png', '400.00', '7.50', '20.00', '48.00', '個', '90.00', 1),
(330, '全麥餅乾碎', 'grains-pasta-bakery', 'snacks', 'img/ingredients/grains-pasta-bakery/snacks/graham-cracker-crumbs.png', '430.00', '7.00', '13.00', '72.00', '克', '1.00', 1),
(331, '醬油', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/soy-sauce.png', '53.00', '8.00', '0.10', '5.00', '克', '1.00', 1),
(332, '蒸魚醬油', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/steamed-fish-soy-sauce.png', '65.00', '7.00', '0.10', '9.00', '克', '1.00', 1),
(333, '日式醬油露', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/tsuyu.png', '90.00', '4.00', '0.00', '18.00', '克', '1.00', 1),
(334, '蠔油', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/oyster-sauce.png', '51.00', '1.40', '0.20', '11.00', '克', '1.00', 1),
(335, '魚露', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/fish-sauce.png', '35.00', '5.00', '0.10', '3.60', '克', '1.00', 1),
(336, '濃縮咖啡', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/espresso.png', '9.00', '0.10', '0.20', '1.70', '毫升', '1.00', 1),
(337, '烏醋', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/black-vinegar.png', '35.00', '0.50', '0.00', '8.00', '克', '1.00', 1),
(338, '麥芽醋', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/malt-vinegar.png', '18.00', '0.00', '0.00', '0.00', '克', '1.00', 1),
(339, '巴薩米克醋膏', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/balsamic-glaze.png', '180.00', '0.50', '0.00', '45.00', '克', '1.00', 1),
(340, '米酒', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/rice-wine.png', '120.00', '0.10', '0.00', '1.00', '毫升', '1.00', 1),
(341, '白葡萄酒', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/white-wine.png', '82.00', '0.10', '0.00', '2.60', '毫升', '1.00', 1),
(342, '紅酒', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/red-wine.png', '85.00', '0.10', '0.00', '2.60', '毫升', '1.00', 1),
(343, '黑蘭姆酒', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/dark-rum.png', '231.00', '0.00', '0.00', '0.00', '毫升', '1.00', 1),
(344, '啤酒', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/beer.png', '43.00', '0.50', '0.00', '3.60', '毫升', '1.00', 1),
(345, '橄欖油', 'condiments-sauces-oils', 'cooking-oils', 'img/ingredients/condiments-sauces-oils/cooking-oils/olive-oil.png', '884.00', '0.00', '100.00', '0.00', '克', '1.00', 1),
(346, '黑麻油', 'condiments-sauces-oils', 'cooking-oils', 'img/ingredients/condiments-sauces-oils/cooking-oils/black-sesame-oil.png', '884.00', '0.00', '100.00', '0.00', '克', '1.00', 1),
(347, '辣油', 'condiments-sauces-oils', 'cooking-oils', 'img/ingredients/condiments-sauces-oils/cooking-oils/chili-oil.png', '884.00', '0.00', '100.00', '0.00', '克', '1.00', 1),
(348, '椰奶', 'condiments-sauces-oils', 'liquid-fats', 'img/ingredients/condiments-sauces-oils/liquid-fats/coconut-milk.png', '230.00', '2.30', '24.00', '6.00', '毫升', '1.00', 1),
(349, '椰漿', 'condiments-sauces-oils', 'liquid-fats', 'img/ingredients/condiments-sauces-oils/liquid-fats/coconut-cream.png', '330.00', '3.00', '34.00', '6.50', '毫升', '1.00', 1),
(350, '雞高湯', 'condiments-sauces-oils', 'stocks', 'img/ingredients/condiments-sauces-oils/stocks/chicken-stock.png', '36.00', '2.50', '1.20', '0.00', '毫升', '1.00', 1),
(351, '牛高湯', 'condiments-sauces-oils', 'stocks', 'img/ingredients/condiments-sauces-oils/stocks/beef-stock.png', '40.00', '3.00', '1.50', '0.00', '毫升', '1.00', 1),
(352, '魚高湯', 'condiments-sauces-oils', 'stocks', 'img/ingredients/condiments-sauces-oils/stocks/fish-stock.png', '32.00', '2.00', '1.00', '0.00', '毫升', '1.00', 1),
(353, '柴魚高湯', 'condiments-sauces-oils', 'stocks', 'img/ingredients/condiments-sauces-oils/stocks/dashi-stock.png', '15.00', '1.20', '0.10', '1.50', '毫升', '1.00', 1),
(354, '綠咖哩醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/green-curry-paste.png', '150.00', '3.00', '10.00', '12.00', '克', '1.00', 1),
(355, '叻沙醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/laksa-paste.png', '220.00', '4.50', '18.00', '10.00', '克', '1.00', 1),
(356, '沙爹醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/satay-sauce.png', '350.00', '12.00', '25.00', '20.00', '克', '1.00', 1),
(357, '海鮮醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/hoisin-sauce.png', '220.00', '2.00', '1.50', '50.00', '克', '1.00', 1),
(358, '甜麵醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/sweet-bean-sauce.png', '240.00', '8.00', '5.00', '40.00', '克', '1.00', 1),
(359, '豆瓣醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/doubanjiang.png', '150.00', '9.00', '8.00', '10.00', '克', '1.00', 1),
(360, '韓式辣椒醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/gochujang.png', '210.00', '4.00', '1.00', '45.00', '克', '1.00', 1),
(361, '參巴辣椒醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/sambal.png', '120.00', '3.00', '7.00', '12.00', '克', '1.00', 1),
(362, '羅望子醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/tamarind-paste.png', '239.00', '2.80', '0.60', '62.00', '克', '1.00', 1),
(363, '味噌', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/miso.png', '199.00', '12.00', '6.00', '26.00', '克', '1.00', 1),
(364, '海山醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/haishan-sauce.png', '160.00', '1.00', '0.50', '38.00', '克', '1.00', 1),
(365, '甜辣醬', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/sweet-chili-sauce.png', '180.00', '1.00', '0.20', '43.00', '克', '1.00', 1),
(366, '紅油', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/chili-oil-sauce.png', '800.00', '0.50', '85.00', '5.00', '克', '1.00', 1),
(367, '番茄糊', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/tomato-paste.png', '82.00', '4.30', '0.50', '18.00', '克', '1.00', 1),
(368, '番茄醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/ketchup.png', '101.00', '1.30', '0.10', '25.00', '克', '1.00', 1),
(369, '碎番茄', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/crushed-tomatoes.png', '32.00', '1.50', '0.20', '7.00', '克', '1.00', 1),
(370, '美乃滋', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/mayonnaise.png', '680.00', '1.00', '75.00', '1.00', '克', '1.00', 1),
(371, '塔塔醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/tartar-sauce.png', '210.00', '1.50', '15.00', '18.00', '克', '1.00', 1),
(372, '豬排醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/tonkatsu-sauce.png', '130.00', '1.00', '0.10', '30.00', '克', '1.00', 1),
(373, '伍斯特醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/worcestershire-sauce.png', '78.00', '0.00', '0.00', '19.00', '克', '1.00', 1),
(374, '章魚燒醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/takoyaki-sauce.png', '120.00', '1.50', '0.10', '28.00', '克', '1.00', 1),
(375, '墨西哥捲餅醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/taco-sauce.png', '50.00', '1.20', '0.50', '10.00', '克', '1.00', 1),
(376, '荷蘭醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/hollandaise-sauce.png', '535.00', '2.50', '58.00', '2.00', '克', '1.00', 1),
(377, '莎莎醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/salsa.png', '36.00', '1.50', '0.20', '7.00', '克', '1.00', 1),
(378, '酪梨醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/guacamole.png', '157.00', '2.00', '14.00', '9.00', '克', '1.00', 1),
(379, '黃芥末醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/mustard-yellow.png', '66.00', '4.40', '4.00', '5.00', '克', '1.00', 1),
(380, '綠芥末醬 (哇沙比)', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/wasabi.png', '109.00', '2.20', '0.60', '24.00', '克', '1.00', 1),
(381, '芝麻醬', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/sesame-paste.png', '600.00', '18.00', '54.00', '12.00', '克', '1.00', 1),
(382, '花生醬', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/peanut-butter.png', '588.00', '25.00', '50.00', '20.00', '克', '1.00', 1),
(383, '巧克力醬', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/chocolate-sauce.png', '278.00', '2.00', '1.00', '65.00', '克', '1.00', 1),
(384, '榛果可可醬', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/hazelnut-spread.png', '539.00', '6.30', '31.00', '57.00', '克', '1.00', 1),
(385, '栗子泥', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/chestnut-purees.png', '250.00', '2.00', '1.50', '55.00', '克', '1.00', 1),
(386, '紅豆泥', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/red-bean-paste.png', '260.00', '6.00', '0.50', '58.00', '克', '1.00', 1),
(387, '蜂蜜', 'condiments-sauces-oils', 'syrups-extracts', 'img/ingredients/condiments-sauces-oils/syrups-extracts/honey.png', '304.00', '0.30', '0.00', '82.00', '克', '1.00', 1),
(388, '楓糖漿', 'condiments-sauces-oils', 'syrups-extracts', 'img/ingredients/condiments-sauces-oils/syrups-extracts/maple-syrup.png', '260.00', '0.00', '0.00', '67.00', '克', '1.00', 1),
(389, '香草精', 'condiments-sauces-oils', 'syrups-extracts', 'img/ingredients/condiments-sauces-oils/syrups-extracts/vanilla-extract.png', '288.00', '0.10', '0.10', '12.00', '克', '1.00', 1),
(390, '高筋麵粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/bread-flour.png', '366.00', '12.00', '1.50', '73.00', '克', '1.00', 1),
(391, '中筋麵粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/all-purpose-flour.png', '364.00', '11.00', '1.20', '76.00', '克', '1.00', 1),
(392, '低筋麵粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/cake-flour.png', '364.00', '8.00', '1.00', '79.00', '克', '1.00', 1),
(393, '全麥麵粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/whole-wheat-flour.png', '339.00', '13.70', '1.90', '72.00', '克', '1.00', 1),
(394, '玉米粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/corn-starch.png', '381.00', '0.30', '0.10', '91.00', '克', '1.00', 1),
(395, '太白粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/potato-starch.png', '333.00', '0.10', '0.10', '83.00', '克', '1.00', 1),
(396, '細地瓜粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/sweet-potato-flour-fine.png', '341.00', '0.20', '0.10', '85.00', '克', '1.00', 1),
(397, '粗地瓜粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/sweet-potato-flour-coarse.png', '341.00', '0.20', '0.10', '85.00', '克', '1.00', 1),
(398, '木薯粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/tapioca-starch.png', '358.00', '0.20', '0.00', '88.00', '克', '1.00', 1),
(399, '糯米粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/glutinous-rice-flour.png', '348.00', '6.50', '0.60', '78.00', '克', '1.00', 1),
(400, '在來米粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/rice-flour.png', '350.00', '6.00', '0.60', '79.00', '克', '1.00', 1),
(401, '澄粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/wheat-starch.png', '350.00', '0.40', '0.10', '85.00', '克', '1.00', 1),
(402, '天婦羅粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/tempura-flour.png', '360.00', '10.00', '1.50', '75.00', '克', '1.00', 1),
(403, '麵包粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/breadcrumbs.png', '370.00', '12.00', '4.50', '70.00', '克', '1.00', 1),
(404, '西谷米', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/sago.png', '350.00', '0.20', '0.10', '86.00', '克', '1.00', 1),
(405, '抹茶粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/matcha-powder.png', '320.00', '30.00', '5.00', '38.00', '克', '1.00', 1),
(406, '可可粉', 'pantry-spices-nuts', 'flours', 'img/ingredients/pantry-spices-nuts/flours/cocoa-powder.png', '228.00', '20.00', '14.00', '58.00', '克', '1.00', 1),
(407, '小蘇打粉', 'pantry-spices-nuts', 'baking-additives', 'img/ingredients/pantry-spices-nuts/baking-additives/baking-soda.png', '0.00', '0.00', '0.00', '0.00', '克', '1.00', 1),
(408, '泡打粉', 'pantry-spices-nuts', 'baking-additives', 'img/ingredients/pantry-spices-nuts/baking-additives/baking-powder.png', '50.00', '0.00', '0.00', '25.00', '克', '1.00', 1),
(409, '吉利丁片', 'pantry-spices-nuts', 'baking-additives', 'img/ingredients/pantry-spices-nuts/baking-additives/gelatin-sheet.png', '340.00', '85.00', '0.00', '0.00', '片', '2.50', 1),
(410, '白糖', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/white-sugar.png', '387.00', '0.00', '0.00', '99.90', '克', '1.00', 1),
(411, '紅糖', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/brown-sugar.png', '380.00', '0.00', '0.00', '98.00', '克', '1.00', 1),
(412, '黑糖', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/muscovado-sugar.png', '365.00', '0.50', '0.00', '94.00', '克', '1.00', 1),
(413, '糖粉', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/powdered-sugar.png', '389.00', '0.00', '0.00', '99.80', '克', '1.00', 1),
(414, '冰糖', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/rock-sugar.png', '387.00', '0.00', '0.00', '99.90', '克', '1.00', 1),
(415, '珍珠糖', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/pearl-sugar.png', '387.00', '0.00', '0.00', '99.90', '克', '1.00', 1),
(416, '細鹽', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/fine-salt.png', '0.00', '0.00', '0.00', '0.00', '克', '1.00', 1),
(417, '粗海鹽', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/sea-salt-coarse.png', '0.00', '0.00', '0.00', '0.00', '克', '1.00', 1),
(418, '黑胡椒粒', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/black-pepper-whole.png', '251.00', '10.00', '3.00', '64.00', '克', '1.00', 1),
(419, '黑胡椒粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/black-pepper-powder.png', '251.00', '10.00', '3.00', '64.00', '克', '1.00', 1),
(420, '白胡椒粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/white-pepper-powder.png', '296.00', '10.00', '2.00', '68.00', '克', '1.00', 1),
(421, '韓式辣椒粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/gochugaru.png', '280.00', '14.00', '12.00', '50.00', '克', '1.00', 1),
(422, '紅椒粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/paprika.png', '282.00', '14.00', '13.00', '54.00', '克', '1.00', 1),
(423, '煙燻辣椒粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/smoked-paprika.png', '282.00', '14.00', '13.00', '54.00', '克', '1.00', 1),
(424, '咖哩粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/curry-powder.png', '325.00', '14.00', '14.00', '55.00', '克', '1.00', 1),
(425, '薑黃粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/turmeric.png', '354.00', '8.00', '10.00', '65.00', '克', '1.00', 1),
(426, '孜然粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/cumin-powder.png', '375.00', '18.00', '22.00', '44.00', '克', '1.00', 1),
(427, '五香粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/five-spice-powder.png', '320.00', '12.00', '8.00', '55.00', '克', '1.00', 1),
(428, '肉桂粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/cinnamon-powder.png', '247.00', '4.00', '1.20', '80.00', '克', '1.00', 1),
(429, '肉豆蔻 (整顆)', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/nutmeg-whole.png', '525.00', '6.00', '36.00', '49.00', '顆', '5.00', 1),
(430, '肉豆蔻粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/nutmeg-powder.png', '525.00', '6.00', '36.00', '49.00', '克', '1.00', 1),
(431, '蒜粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/garlic-powder.png', '331.00', '16.00', '0.70', '73.00', '克', '1.00', 1),
(432, '洋蔥粉', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/onion-powder.png', '341.00', '10.00', '1.00', '80.00', '克', '1.00', 1),
(433, '義大利香料', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/italian-seasoning.png', '270.00', '12.00', '10.00', '50.00', '克', '1.00', 1),
(434, '坦都里醃料', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/tandoori-masala.png', '320.00', '13.00', '12.00', '45.00', '克', '1.00', 1),
(435, '印度綜合香料', 'pantry-spices-nuts', 'seasoning-powders', 'img/ingredients/pantry-spices-nuts/seasoning-powders/garam-masala.png', '340.00', '13.00', '12.00', '45.00', '克', '1.00', 1),
(436, '八角', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/star-anise.png', '337.00', '17.00', '16.00', '50.00', '顆', '1.00', 1),
(437, '花椒粒', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/sichuan-peppercorns.png', '280.00', '12.00', '8.00', '40.00', '克', '1.00', 1),
(438, '肉桂棒', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/cinnamon-stick.png', '247.00', '4.00', '1.20', '80.00', '根', '5.00', 1),
(439, '孜然粒', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/cumin-seeds.png', '375.00', '18.00', '22.00', '44.00', '克', '1.00', 1),
(440, '番紅花', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/saffron.png', '310.00', '11.00', '6.00', '65.00', '克', '1.00', 1),
(441, '香草莢', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/vanilla-bean.png', '288.00', '0.10', '0.10', '12.00', '根', '3.00', 1),
(442, '豆豉', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/fermented-black-beans.png', '210.00', '18.00', '8.00', '16.00', '克', '1.00', 1),
(443, '肉骨茶包', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/bak-kut-teh-spices.png', '300.00', '10.00', '5.00', '50.00', '包', '35.00', 1),
(444, '油蔥酥', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/fried-shallots.png', '605.00', '4.50', '45.00', '45.00', '克', '1.00', 1),
(445, '伯爵茶葉', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/earl-grey-tea.png', '1.00', '0.00', '0.00', '0.20', '克', '1.00', 1),
(446, '黑巧克力塊', 'pantry-spices-nuts', 'chocolate', 'img/ingredients/pantry-spices-nuts/chocolate/dark-chocolate-chunks.png', '546.00', '4.90', '31.00', '61.00', '克', '1.00', 1),
(447, '黑巧克力磚', 'pantry-spices-nuts', 'chocolate', 'img/ingredients/pantry-spices-nuts/chocolate/dark-chocolate-block.png', '546.00', '4.90', '31.00', '61.00', '克', '1.00', 1),
(448, '花生 (帶殼)', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/peanuts-in-shell.png', '567.00', '25.80', '49.20', '16.10', '顆', '5.00', 1),
(449, '花生仁', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/peanut-kernels.png', '567.00', '25.80', '49.20', '16.10', '克', '1.00', 1),
(450, '花生粉', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/peanut-powder.png', '567.00', '25.80', '49.20', '16.10', '克', '1.00', 1),
(451, '花生碎', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/peanut-crushed.png', '567.00', '25.80', '49.20', '16.10', '克', '1.00', 1),
(452, '杏仁 (整粒)', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/almonds-whole.png', '579.00', '21.20', '49.90', '21.60', '顆', '1.20', 1),
(453, '杏仁粉', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/almond-flour.png', '579.00', '21.20', '49.90', '21.60', '克', '1.00', 1),
(454, '腰果', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/cashews.png', '553.00', '18.20', '43.80', '30.20', '顆', '1.50', 1),
(455, '核桃', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/walnuts.png', '654.00', '15.20', '65.20', '13.70', '顆', '4.00', 1),
(456, '胡桃', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/pecans.png', '691.00', '9.20', '72.00', '13.90', '顆', '4.00', 1),
(457, '松子', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/pine-nuts.png', '673.00', '13.70', '68.40', '13.10', '克', '1.00', 1),
(458, '開心果 (整粒)', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/pistachios-whole.png', '562.00', '20.20', '45.30', '27.20', '顆', '1.00', 1),
(459, '開心果碎', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/pistachios-crushed.png', '562.00', '20.20', '45.30', '27.20', '克', '1.00', 1),
(460, '榛果', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/hazelnuts.png', '628.00', '15.00', '60.80', '16.70', '顆', '1.20', 1),
(461, '熟栗子', 'pantry-spices-nuts', 'nuts', 'img/ingredients/pantry-spices-nuts/nuts/chestnuts-roasted.png', '245.00', '3.20', '2.20', '53.00', '顆', '10.00', 1),
(462, '白芝麻', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/sesame-white.png', '573.00', '17.70', '49.70', '23.40', '克', '1.00', 1),
(463, '黑芝麻', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/sesame-black.png', '573.00', '17.70', '49.70', '23.40', '克', '1.00', 1),
(464, '芝麻粉', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/sesame-powder.png', '573.00', '17.70', '49.70', '23.40', '克', '1.00', 1),
(465, '亞麻仁籽', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/flaxseed.png', '534.00', '18.30', '42.20', '28.90', '克', '1.00', 1),
(466, '奇亞籽', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/chia-seeds.png', '486.00', '16.50', '30.70', '42.10', '克', '1.00', 1),
(467, '葵瓜子', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/sunflower-seeds.png', '584.00', '20.80', '51.50', '20.00', '克', '1.00', 1),
(468, '南瓜子', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/pumpkin-seeds.png', '559.00', '30.20', '49.10', '10.70', '克', '1.00', 1),
(469, '山粉圓', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/basil-seeds.png', '450.00', '15.00', '25.00', '40.00', '克', '1.00', 1),
(470, '愛玉子', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/aiyu-seeds.png', '20.00', '1.00', '0.50', '3.00', '克', '1.00', 1),
(471, '白果', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/ginkgo-nuts.png', '182.00', '4.30', '1.70', '37.60', '顆', '2.00', 1),
(472, '蓮子', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/lotus-seeds.png', '332.00', '15.40', '2.00', '64.50', '顆', '1.50', 1),
(473, '芡實', 'pantry-spices-nuts', 'seeds', 'img/ingredients/pantry-spices-nuts/seeds/fox-nuts.png', '350.00', '9.50', '0.50', '76.00', '克', '1.00', 1),
(474, '鷹嘴豆 (乾)', 'pantry-spices-nuts', 'dried-legumes', 'img/ingredients/pantry-spices-nuts/dried-legumes/chickpeas-dry.png', '364.00', '19.30', '6.00', '60.70', '克', '1.00', 1),
(475, '鷹嘴豆 (煮熟)', 'pantry-spices-nuts', 'dried-legumes', 'img/ingredients/pantry-spices-nuts/dried-legumes/chickpeas-cooked.png', '164.00', '8.90', '2.60', '27.40', '克', '1.00', 1),
(476, '大紅豆', 'pantry-spices-nuts', 'dried-legumes', 'img/ingredients/pantry-spices-nuts/dried-legumes/kidney-beans.png', '333.00', '23.60', '0.80', '60.00', '克', '1.00', 1),
(477, '紅豆 (生)', 'pantry-spices-nuts', 'dried-legumes', 'img/ingredients/pantry-spices-nuts/dried-legumes/red-beans-raw.png', '329.00', '21.00', '0.60', '61.50', '克', '1.00', 1),
(478, '茄汁焗豆', 'pantry-spices-nuts', 'dried-legumes', 'img/ingredients/pantry-spices-nuts/dried-legumes/baked-beans.png', '105.00', '5.00', '0.50', '20.00', '克', '1.00', 1),
(479, '葡萄乾', 'pantry-spices-nuts', 'dried-fruits', 'img/ingredients/pantry-spices-nuts/dried-fruits/raisins.png', '299.00', '3.10', '0.50', '79.00', '克', '1.00', 1),
(480, '蔓越莓乾', 'pantry-spices-nuts', 'dried-fruits', 'img/ingredients/pantry-spices-nuts/dried-fruits/dried-cranberries.png', '308.00', '0.10', '1.40', '82.00', '克', '1.00', 1),
(481, '枸杞', 'pantry-spices-nuts', 'dried-fruits', 'img/ingredients/pantry-spices-nuts/dried-fruits/goji-berries.png', '349.00', '14.30', '0.40', '77.00', '克', '1.00', 1),
(482, '紅棗', 'pantry-spices-nuts', 'dried-fruits', 'img/ingredients/pantry-spices-nuts/dried-fruits/red-dates.png', '281.00', '4.40', '0.50', '72.00', '顆', '5.00', 1),
(483, '桂圓', 'pantry-spices-nuts', 'dried-fruits', 'img/ingredients/pantry-spices-nuts/dried-fruits/dried-longan.png', '273.00', '5.00', '0.10', '68.00', '克', '1.00', 1),
(484, '無花果乾', 'pantry-spices-nuts', 'dried-fruits', 'img/ingredients/pantry-spices-nuts/dried-legumes/dried-figs.png', '249.00', '3.30', '0.90', '63.00', '顆', '15.00', 1),
(485, '酸黃瓜 (整條)', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/pickles-whole.png', '11.00', '0.30', '0.20', '2.30', '條', '25.00', 1),
(486, '酸黃瓜片', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/pickles-chopped.png', '11.00', '0.30', '0.20', '2.30', '克', '1.00', 1),
(487, '酸豆', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/capers.png', '23.00', '2.40', '0.90', '4.90', '克', '1.00', 1),
(488, '黑橄欖', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/black-olives.png', '115.00', '0.80', '10.70', '6.30', '顆', '5.00', 1),
(489, '墨西哥辣椒片', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/jalapenos-pickled.png', '27.00', '0.90', '0.90', '4.70', '克', '1.00', 1),
(490, '醃黃蘿蔔', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/pickled-radish-yellow.png', '25.00', '0.50', '0.10', '5.50', '克', '1.00', 1),
(491, '韓式泡菜', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/kimchi.png', '15.00', '1.10', '0.50', '2.40', '克', '1.00', 1),
(492, '酸菜', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/pickled-mustard-greens.png', '25.00', '1.50', '0.20', '4.50', '克', '1.00', 1),
(493, '梅乾菜', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/dried-mustard-greens.png', '200.00', '15.00', '2.00', '30.00', '克', '1.00', 1),
(494, '朝鮮薊 (醃漬)', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/artichokes-pickled.png', '47.00', '3.30', '0.20', '10.50', '克', '1.00', 1),
(495, '蒟蒻結', 'pantry-spices-nuts', 'canned-vegetables', 'img/ingredients/pantry-spices-nuts/canned-vegetables/konjac-knots.png', '10.00', '0.10', '0.00', '3.00', '結', '15.00', 1),
(496, '水', 'others', 'liquids', 'img/ingredients/others/liquids/water.png', '0.00', '0.00', '0.00', '0.00', '毫升', '1.00', 1),
(497, '酵母粉', 'pantry-spices-nuts', 'baking-additives', 'img/ingredients/pantry-spices-nuts/baking-additives/yeast-powder.png', '325.00', '40.00', '7.00', '40.00', '克', '1.00', 1),
(498, '白巧克力', 'pantry-spices-nuts', 'chocolate', 'img/ingredients/pantry-spices-nuts/chocolate/white-chocolate.png', '540.00', '6.00', '32.00', '58.00', '克', '1.00', 1),
(499, '無鹽奶油', 'dairy-eggs-soy', 'dairy-liquids', 'img/ingredients/dairy-eggs-soy/dairy-liquids/unsalted-butter.png', '717.00', '0.80', '81.00', '0.10', '克', '1.00', 1),
(500, '乾辣椒段', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/dried-chili-segments.png', '320.00', '12.00', '6.00', '55.00', '克', '1.00', 1),
(501, '黑松露醬', 'condiments-sauces-oils', 'western-sauces', 'img/ingredients/condiments-sauces-oils/western-sauces/black-truffle-sauce.png', '252.00', '4.50', '22.00', '9.00', '克', '1.00', 1),
(502, '椰糖', 'pantry-spices-nuts', 'sugars', 'img/ingredients/pantry-spices-nuts/sugars/palm-sugar.png', '375.00', '0.00', '0.00', '92.00', '克', '1.00', 1),
(503, '檸檬汁', 'fruits', 'citrus', 'img/ingredients/fruits/citrus/lemon-juice.png', '22.00', '0.40', '0.20', '6.90', '毫升', '1.00', 1),
(504, '白醋', 'condiments-sauces-oils', 'vinegars-wines', 'img/ingredients/condiments-sauces-oils/vinegars-wines/white-vinegar.png', '18.00', '0.00', '0.00', '0.10', '毫升', '1.00', 1),
(505, '拉麵麵條', 'grains-pasta-bakery', 'asian-noodles', 'img/ingredients/grains-pasta-bakery/asian-noodles/ramen-noodles.png', '150.00', '5.00', '1.20', '30.00', '份', '150.00', 1),
(506, '豚骨高湯', 'condiments-sauces-oils', 'stocks', 'img/ingredients/condiments-sauces-oils/stocks/tonkotsu-broth.png', '85.00', '4.50', '7.00', '1.00', '毫升', '1.00', 1),
(507, '拉麵味醂醬汁', 'condiments-sauces-oils', 'asian-sauces', 'img/ingredients/condiments-sauces-oils/asian-sauces/ramen-tare.png', '120.00', '3.00', '0.00', '25.00', '毫升', '1.00', 1),
(508, '塔希尼芝麻醬', 'condiments-sauces-oils', 'sweet-spreads', 'img/ingredients/condiments-sauces-oils/sweet-spreads/tahini.png', '595.00', '17.00', '53.00', '21.00', '克', '1.00', 1),
(509, '格魯耶爾起司', 'dairy-eggs-soy', 'aged-cheese', 'img/ingredients/dairy-eggs-soy/aged-cheese/gruyere.png', '413.00', '29.80', '32.30', '0.40', '克', '1.00', 1),
(510, '味醂', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/mirin.png', '230.00', '0.00', '0.00', '50.00', '毫升', '1.00', 1),
(511, '醬油膏', 'condiments-sauces-oils', 'liquid-seasonings', 'img/ingredients/condiments-sauces-oils/liquid-seasonings/thick-soy-sauce.png', '150.00', '5.00', '0.00', '30.00', '克', '1.00', 1),
(512, '梅花豬肉片', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-collar-slices.png', '240.00', '18.00', '18.00', '0.00', '克', '1.00', 1),
(513, '咖哩塊', 'pantry-spices-nuts', 'seasoning-blocks', 'img/ingredients/pantry-spices-nuts/seasoning-blocks/curry-roux.png', '510.00', '6.00', '35.00', '43.00', '塊', '20.00', 1),
(514, '豬腹肉片', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-belly-slices.png', '518.00', '9.00', '53.00', '0.00', '克', '1.00', 1),
(515, '義大利燉米', 'grains-pasta-bakery', 'grains', 'img/ingredients/grains-pasta-bakery/grains/arborio-rice.png', '355.00', '7.00', '0.50', '80.00', '克', '1.00', 1),
(516, '黑芝麻油', 'condiments-sauces-oils', 'oils', 'img/ingredients/condiments-sauces-oils/oils/black-sesame-oil.png', '884.00', '0.00', '100.00', '0.00', '克', '1.00', 1),
(517, '白蘿蔔 (整根)', 'fresh-produce', 'root-vegetables', 'img/ingredients/fresh-produce/root-vegetables/white-radish-whole.png', '18.00', '0.60', '0.10', '4.10', '根', '500.00', 1),
(518, '甜玉米', 'fresh-produce', 'stalk-vegetables', 'img/ingredients/fresh-produce/stalk-vegetables/sweet-corn.png', '107.00', '3.50', '2.20', '22.00', '根', '250.00', 1),
(519, '豬肉絲', 'meat-poultry', 'pork', 'img/ingredients/meat-poultry/pork/pork-shredds.png', '155.00', '18.50', '8.50', '0.00', '克', '1.00', 1),
(520, '罐裝剝皮辣椒', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/peeled-chili-canned.png', '85.00', '1.50', '3.80', '11.20', '罐', '450.00', 1),
(521, '牛絞肉', 'meat-poultry', 'beef', 'img/ingredients/meat-poultry/beef/ground-beef.png', '250.00', '18.20', '19.40', '0.00', '克', '1.00', 1),
(522, '鯷魚 (油浸)', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/anchovies-oil.png', '210.00', '20.40', '14.20', '0.00', '克', '1.00', 1),
(523, '醬瓜 (花瓜)', 'pantry-spices-nuts', 'pickles-preserves', 'img/ingredients/pantry-spices-nuts/pickles-preserves/pickled-cucumber-canned.png', '78.00', '1.20', '0.20', '18.00', '罐', '180.00', 1),
(524, '月桂葉', 'pantry-spices-nuts', 'whole-spices', 'img/ingredients/pantry-spices-nuts/whole-spices/bay-leaves.png', '313.00', '7.60', '8.40', '75.00', '片', '0.50', 1),
(525, '青椒', 'fresh-produce', 'nightshades', 'img/ingredients/fresh-produce/nightshades/green-bell-pepper.png', '20.00', '0.90', '0.20', '4.60', '顆', '40.00', 1),
(526, '小白菜', 'fresh-produce', 'leafy-greens', 'img/ingredients/fresh-produce/leafy-greens/bok-choy-small.png', '13.00', '1.50', '0.20', '2.20', '株', '40.00', 1);

-- --------------------------------------------------------

--
-- 資料表結構 `log_ingredients`
--

CREATE TABLE `log_ingredients` (
  `log_ingredient_id` int(11) NOT NULL,
  `cooking_log_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `log_ingredients`
--

INSERT INTO `log_ingredients` (`log_ingredient_id`, `cooking_log_id`, `ingredient_id`) VALUES
(1, 1, 390),
(2, 1, 496),
(3, 1, 497),
(4, 1, 345),
(5, 1, 416),
(6, 1, 242),
(7, 1, 367),
(8, 1, 23),
(9, 1, 345),
(10, 2, 390),
(11, 2, 496),
(12, 2, 497),
(13, 2, 345),
(14, 2, 416),
(15, 2, 242),
(16, 2, 367),
(17, 2, 23),
(18, 2, 345),
(19, 3, 390),
(20, 3, 496),
(21, 3, 497),
(22, 3, 345),
(23, 3, 416),
(24, 3, 242),
(25, 3, 367),
(26, 3, 23),
(27, 3, 345),
(28, 4, 390),
(29, 4, 496),
(30, 4, 497),
(31, 4, 345),
(32, 4, 416),
(33, 4, 242),
(34, 4, 367),
(35, 4, 23),
(36, 4, 345),
(37, 5, 390),
(38, 5, 496),
(39, 5, 497),
(40, 5, 345),
(41, 5, 416),
(42, 5, 242),
(43, 5, 367),
(44, 5, 23),
(45, 5, 345),
(46, 6, 390),
(47, 6, 496),
(48, 6, 497),
(49, 6, 345),
(50, 6, 416),
(51, 6, 242),
(52, 6, 367),
(53, 6, 23),
(54, 6, 345),
(55, 7, 390),
(56, 7, 496),
(57, 7, 497),
(58, 7, 345),
(59, 7, 416),
(60, 7, 242),
(61, 7, 367),
(62, 7, 23),
(63, 7, 345),
(64, 8, 164),
(65, 8, 500),
(66, 8, 437),
(67, 8, 449),
(68, 8, 14),
(69, 8, 9),
(70, 8, 2),
(71, 8, 331),
(72, 8, 340),
(73, 8, 410),
(74, 8, 395),
(75, 9, 498),
(76, 9, 499),
(77, 9, 230),
(78, 9, 410),
(79, 9, 392),
(80, 9, 405),
(81, 10, 164),
(82, 10, 354),
(83, 10, 348),
(84, 10, 82),
(85, 10, 335),
(86, 10, 502),
(87, 10, 34),
(88, 10, 24),
(89, 10, 345),
(90, 11, 278),
(91, 11, 91),
(92, 11, 92),
(93, 11, 239),
(94, 11, 501),
(95, 11, 251),
(96, 11, 2),
(97, 11, 499),
(98, 11, 419),
(99, 11, 416),
(100, 12, 278),
(101, 12, 91),
(102, 12, 92),
(103, 12, 239),
(104, 12, 501),
(105, 12, 251),
(106, 12, 2),
(107, 12, 499),
(108, 12, 419),
(109, 12, 416),
(110, 13, 210),
(111, 13, 2),
(112, 13, 499),
(113, 13, 503),
(114, 13, 21),
(115, 13, 419),
(116, 13, 416),
(117, 13, 136),
(118, 14, 210),
(119, 14, 2),
(120, 14, 499),
(121, 14, 503),
(122, 14, 21),
(123, 14, 419),
(124, 14, 416),
(125, 14, 136),
(126, 15, 210),
(127, 15, 2),
(128, 15, 499),
(129, 15, 503),
(130, 15, 21),
(131, 15, 419),
(132, 15, 416),
(133, 15, 136),
(134, 16, 210),
(135, 16, 2),
(136, 16, 499),
(137, 16, 503),
(138, 16, 21),
(139, 16, 419),
(140, 16, 416),
(141, 16, 136),
(142, 17, 177),
(143, 17, 414),
(144, 17, 331),
(145, 17, 340),
(146, 17, 14),
(147, 17, 1),
(148, 17, 2),
(149, 17, 497),
(150, 18, 177),
(151, 18, 414),
(152, 18, 331),
(153, 18, 340),
(154, 18, 14),
(155, 18, 1),
(156, 18, 2),
(157, 18, 497),
(158, 19, 177),
(159, 19, 414),
(160, 19, 331),
(161, 19, 340),
(162, 19, 14),
(163, 19, 1),
(164, 19, 2),
(165, 19, 497);

-- --------------------------------------------------------

--
-- 資料表結構 `log_step_note`
--

CREATE TABLE `log_step_note` (
  `log_step_note_id` int(11) NOT NULL,
  `cooking_log_id` int(11) NOT NULL,
  `step_id` int(11) NOT NULL,
  `step_note` text COLLATE utf8mb4_unicode_ci,
  `step_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `log_step_note`
--

INSERT INTO `log_step_note` (`log_step_note_id`, `cooking_log_id`, `step_id`, `step_note`, `step_image_url`) VALUES
(1, 1, 1, '麵粉有先過篩，混合得很均勻。', 'img/logs/u5/log_1/steps/1.png'),
(2, 1, 2, '手揉了大約15分鐘才達到光滑不黏手的狀態，下次想試試攪拌機。', 'img/logs/u5/log_1/steps/2.png'),
(3, 1, 3, '今天天氣冷，放在微波爐裡放一杯熱水幫忙發酵，效果很好。', 'img/logs/u5/log_1/steps/3.png'),
(4, 1, 4, '桿麵皮的時候麵糰一直縮，稍微讓它靜置5分鐘後就好桿多了。', 'img/logs/u5/log_1/steps/4.png'),
(5, 1, 5, '起司撕成小塊分散鋪放，看起來比較美觀。', 'img/logs/u5/log_1/steps/5.png'),
(6, 1, 6, '烤箱預熱一定要足夠，邊緣烤到微微焦黃最香。', 'img/logs/u5/log_1/steps/6.png'),
(7, 1, 7, '羅勒葉一定要出爐後再放，顏色才會綠，不會變黑。', 'img/logs/u5/log_1/steps/7.png'),
(8, 2, 1, '乾性食材混合均勻，沒有結塊。', 'img/logs/u2/log_2/steps/1.png'),
(9, 2, 2, '揉麵團大約花了12分鐘，手感變得很Q彈。', 'img/logs/u2/log_2/steps/2.png'),
(10, 2, 3, '發酵得很成功，麵糰真的膨脹兩倍大。', 'img/logs/u2/log_2/steps/3.png'),
(11, 2, 4, '桿平時要注意中間不要太薄，否則醬汁會滲透。', 'img/logs/u2/log_2/steps/4.png'),
(12, 2, 5, '用了新鮮的莫札瑞拉，水分比較多，我有稍微吸乾。', 'img/logs/u2/log_2/steps/5.png'),
(13, 2, 6, '烤箱溫度設到最高，底層烤得很脆。', 'img/logs/u2/log_2/steps/6.png'),
(14, 2, 7, '最後淋上橄欖油簡直畫龍點睛！', 'img/logs/u2/log_2/steps/7.png'),
(15, 3, 1, '乾粉混合時不小心灑了一些出來，比例可能微偏。', 'img/logs/u3/log_3/steps/1.png'),
(16, 3, 2, '揉得有點久，手感還是很黏，最後補了一點點麵粉。', 'img/logs/u3/log_3/steps/2.png'),
(17, 3, 3, '趕時間只發酵了40分鐘，大小看起來還可以。', 'img/logs/u3/log_3/steps/3.png'),
(18, 3, 4, '桿麵皮桿不出完美的圓形，變成了橢圓形。', 'img/logs/u3/log_3/steps/4.png'),
(19, 3, 5, '起司放得比食譜建議的多，因為我愛吃起司。', 'img/logs/u3/log_3/steps/5.png'),
(20, 3, 6, '烤箱溫度好像不太夠，烤了18分鐘才上色。', 'img/logs/u3/log_3/steps/6.png'),
(21, 3, 7, '羅勒葉稍微被烤箱餘溫弄黃了，下次要等冷一點再放。', 'img/logs/u3/log_3/steps/7.png'),
(22, 4, 1, '依照食譜比例混合，攪拌盆要保持乾燥才好操作。', 'img/logs/u4/log_4/steps/1.png'),
(23, 4, 2, '這次揉麵比較順手，大約10分鐘就出筋了。', 'img/logs/u4/log_4/steps/2.png'),
(24, 4, 3, '放在烤箱旁利用餘溫發酵，剛好一小時變兩倍大。', 'img/logs/u4/log_4/steps/3.png'),
(25, 4, 4, '桿麵皮時發現中間太厚，邊緣太薄，下次要再調整力道。', 'img/logs/u4/log_4/steps/4.png'),
(26, 4, 5, '莫札瑞拉起司我有先用廚房紙巾壓乾水分，避免烤完濕噠噠。', 'img/logs/u4/log_4/steps/5.png'),
(27, 4, 6, '烤了13分鐘，餅皮邊緣出現豹紋斑點，非常漂亮！', 'img/logs/u4/log_4/steps/6.png'),
(28, 4, 7, '新鮮羅勒一定要撕碎後再灑，香氣釋放更完全。', 'img/logs/u4/log_4/steps/7.png'),
(29, 5, 1, '混合乾料時有先把鹽跟酵母分開放，避免直接接觸影響活性。', 'img/logs/u6/log_5/steps/1.png'),
(30, 5, 2, '揉麵時的水溫控制在30度左右，手感非常柔軟。', 'img/logs/u6/log_5/steps/2.png'),
(31, 5, 3, '發酵一小時後的香氣很迷人，麵糰彈性極佳。', 'img/logs/u6/log_5/steps/3.png'),
(32, 5, 4, '用手推開麵糰而不是用桿麵棍，保留了邊緣的氣泡感。', 'img/logs/u6/log_5/steps/4.png'),
(33, 5, 5, '起司鋪得比較散，這樣融化後才不會整片都是白的。', 'img/logs/u6/log_5/steps/5.png'),
(34, 5, 6, '烘烤時廚房全是起司香，12分鐘準時出爐。', 'img/logs/u6/log_5/steps/6.png'),
(35, 5, 7, '羅勒葉在出爐後微溫時放上去，顏色最翠綠。', 'img/logs/u6/log_5/steps/7.png'),
(36, 6, 1, '混合乾料時有確實過篩，顆粒感很少。', 'img/logs/u7/log_6/steps/1.png'),
(37, 6, 2, '揉麵揉了大約 15 分鐘，手臂有點痠，但麵糰變得很光滑。', 'img/logs/u7/log_6/steps/2.png'),
(38, 6, 3, '發酵環境大約 28 度，剛好一小時就發到兩倍大了。', 'img/logs/u7/log_6/steps/3.png'),
(39, 6, 4, '用手慢慢推開麵糰，餅皮邊緣留了一點厚度，希望能烤出酥脆感。', 'img/logs/u7/log_6/steps/4.png'),
(40, 6, 5, '莫札瑞拉起司切得比較大塊，口感應該會更濃郁。', 'img/logs/u7/log_6/steps/5.png'),
(41, 6, 6, '烤箱預熱很久，烤到 10 分鐘時邊緣就開始金黃了。', 'img/logs/u7/log_6/steps/6.png'),
(42, 6, 7, '出爐的熱氣讓羅勒葉香氣瞬間爆發，非常誘人。', 'img/logs/u7/log_6/steps/7.png'),
(43, 7, 1, '乾性食材混合得很均勻，鹽巴我有稍微減量一點點。', 'img/logs/u8/log_7/steps/1.png'),
(44, 7, 2, '揉麵揉到手有點痠，但看到麵糰變光滑很有成就感。', 'img/logs/u8/log_7/steps/2.png'),
(45, 7, 3, '發酵箱設定 30 度，麵糰膨脹得很漂亮。', 'img/logs/u8/log_7/steps/3.png'),
(46, 7, 4, '桿麵皮時儘量保持厚薄一致，番茄糊抹得剛好。', 'img/logs/u8/log_7/steps/4.png'),
(47, 7, 5, '新鮮莫札瑞拉起司真的不一樣，奶香味超濃。', 'img/logs/u8/log_7/steps/5.png'),
(48, 7, 6, '石板預熱了 40 分鐘，餅皮放上去瞬間就蓬起來了。', 'img/logs/u8/log_7/steps/6.png'),
(49, 7, 7, '最後淋上初榨橄欖油，那種油亮的色澤非常完美。', 'img/logs/u8/log_7/steps/7.png'),
(50, 8, 15, '確實醃漬了20分鐘，雞肉丁看起來吸收了醬汁，變得很有彈性。', 'img/logs/u2/log_8/steps/15.png'),
(51, 8, 16, '滑油的速度要快，表面一變色就撈起來，這樣最後口感才不會乾柴。', 'img/logs/u2/log_8/steps/16.png'),
(52, 8, 17, '小火煸炒乾辣椒時香氣超迷人，顏色變深但不能焦掉。', 'img/logs/u2/log_8/steps/17.png'),
(53, 8, 18, '薑片跟蒜末一入鍋，川菜那種濃郁的辛香味就出來了。', 'img/logs/u2/log_8/steps/18.png'),
(54, 8, 19, '大火翻炒時動作要快，讓糖跟醬油均勻包裹住雞丁。', 'img/logs/u2/log_8/steps/19.png'),
(55, 8, 20, '芡汁不能太多，只要讓醬汁呈現透亮的掛糊狀就好。', 'img/logs/u2/log_8/steps/20.png'),
(56, 8, 21, '花生最後一刻才撒入，確實保持了極致的酥脆口感！', 'img/logs/u2/log_8/steps/21.png'),
(57, 9, 8, '隔水加熱時要注意碗底不要碰到水，以免巧克力過熱變質。', 'img/logs/u2/log_9/steps/8.png'),
(58, 9, 9, '打發到體積明顯變大且顏色泛白，這樣蛋糕口感才會輕盈。', 'img/logs/u2/log_9/steps/9.png'),
(59, 9, 10, '抹茶粉容易結塊，過篩這個步驟絕對不能省。', 'img/logs/u2/log_9/steps/10.png'),
(60, 9, 11, '混合時動作要輕，避免消泡，麵糊顏色呈現非常漂亮的深綠色。', 'img/logs/u2/log_9/steps/11.png'),
(61, 9, 12, '模具內壁塗完奶油後，我還灑了一點點薄麵粉確保脫模順利。', 'img/logs/u2/log_9/steps/12.png'),
(62, 9, 13, '我的烤箱火力較強，烤到第8分鐘邊緣固定、中心微晃就趕快出爐了。', 'img/logs/u2/log_9/steps/13.png'),
(63, 9, 14, '稍微放涼再脫模，蛋糕形狀很完整，灑上抹茶粉裝飾後質感滿分。', 'img/logs/u2/log_9/steps/14.png'),
(64, 10, 28, '雞腿肉切得大小均勻，茄子切完後先泡水防止變黑。', 'img/logs/u2/log_10/steps/28.png'),
(65, 10, 29, '炒咖哩醬時火不能太大，看到綠色的油脂冒出來就表示香氣開了。', 'img/logs/u2/log_10/steps/29.png'),
(66, 10, 30, '分次加椰奶真的有差，醬汁完全沒有分離，非常乳化。', 'img/logs/u2/log_10/steps/30.png'),
(67, 10, 31, '檸檬葉撕開後香氣更濃，雞肉煮到剛好轉白保持嫩度。', 'img/logs/u2/log_10/steps/31.png'),
(68, 10, 32, '小火燉煮15分鐘後茄子完全入味，魚露跟椰糖比例抓得剛好。', 'img/logs/u2/log_10/steps/32.png'),
(69, 10, 33, '最後撒入的泰式羅勒是靈魂，拌勻馬上起鍋，香氣最清新。', 'img/logs/u2/log_10/steps/33.png'),
(70, 11, 22, '寬麵真的要提前一分鐘撈起來，因為後面還要進鍋煮。', 'img/logs/u2/log_11/steps/22.png'),
(71, 11, 23, '奶油融化得很快，蒜末要小心不要炒焦。', 'img/logs/u2/log_11/steps/23.png'),
(72, 11, 24, '菇類縮水很多，要炒到邊緣微焦才有那種香氣。', 'img/logs/u2/log_11/steps/24.png'),
(73, 11, 25, '加入煮麵水後醬汁變得很亮，乳化效果很好。', 'img/logs/u2/log_11/steps/25.png'),
(74, 11, 26, '松露醬一放進去，整個廚房都是香的！', 'img/logs/u2/log_11/steps/26.png'),
(75, 11, 27, '起司粉撒下去後醬汁瞬間變濃稠，效果驚人。', 'img/logs/u2/log_11/steps/27.png'),
(76, 12, 22, '這次準時8分鐘撈起，麵芯的口感剛好。', 'img/logs/u2/log_12/steps/22.png'),
(77, 12, 23, '熟練了，同時開兩爐作業也沒問題。', 'img/logs/u2/log_12/steps/23.png'),
(78, 12, 24, '這次菇類炒得更焦一點，風味更集中。', 'img/logs/u2/log_12/steps/24.png'),
(79, 12, 25, '鮮奶油與水的比例抓得很準。', 'img/logs/u2/log_12/steps/25.png'),
(80, 12, 26, '這款黑松露醬真的很超值，掛糊效果極佳。', 'img/logs/u2/log_12/steps/26.png'),
(81, 12, 27, '黑胡椒多撒了一點，層次感更棒。', 'img/logs/u2/log_12/steps/27.png'),
(82, 13, 58, '腸泥有點難挑，要很有耐心。', 'img/logs/u2/log_13/steps/58.png'),
(83, 13, 59, '蒜末要確實抹進蝦背裡。', 'img/logs/u2/log_13/steps/59.png'),
(84, 13, 60, '擺盤時檸檬片放上去後顏色很好看。', 'img/logs/u2/log_13/steps/60.png'),
(85, 13, 61, '守在烤箱前看著蝦子變紅很有趣。', 'img/logs/u2/log_13/steps/61.png'),
(86, 13, 62, '新鮮巴西里碎末讓香味提升不少。', 'img/logs/u2/log_13/steps/62.png'),
(87, 14, 58, '這次用牙籤處理得比上次順手多了。', 'img/logs/u2/log_14/steps/58.png'),
(88, 14, 59, '多放了兩顆大蒜，味道更香。', 'img/logs/u2/log_14/steps/59.png'),
(89, 14, 60, '奶油塊放多一點點，烤出來的湯汁很鮮。', 'img/logs/u2/log_14/steps/60.png'),
(90, 14, 61, '烤了15分鐘，熟度剛好。', 'img/logs/u2/log_14/steps/61.png'),
(91, 14, 62, '檸檬汁要在趁熱時淋上去。', 'img/logs/u2/log_14/steps/62.png'),
(92, 15, 58, '備料工作進度飛快。', 'img/logs/u2/log_15/steps/58.png'),
(93, 15, 59, '醃漬時間控制在剛好15分鐘。', 'img/logs/u2/log_15/steps/59.png'),
(94, 15, 60, '擺放整齊後拍照很漂亮。', 'img/logs/u2/log_15/steps/60.png'),
(95, 15, 61, '改用180度烤13分鐘，口感更脆彈。', 'img/logs/u2/log_15/steps/61.png'),
(96, 15, 62, '這次巴西里切得很細，層次感很好。', 'img/logs/u2/log_15/steps/62.png'),
(97, 16, 58, '一次處理十幾隻蝦也很輕鬆。', 'img/logs/u2/log_16/steps/58.png'),
(98, 16, 59, '胡椒粉我多加了一些，帶點辛香。', 'img/logs/u2/log_16/steps/59.png'),
(99, 16, 60, '準備入烤箱，視覺滿分。', 'img/logs/u2/log_16/steps/60.png'),
(100, 16, 61, '時間掌控爐火純青。', 'img/logs/u2/log_16/steps/61.png'),
(101, 16, 62, '完美收尾，上桌秒殺。', 'img/logs/u2/log_16/steps/62.png'),
(102, 17, 151, '冷水下鍋確實煮出很多浮沫，洗乾淨後肉塊看起來乾淨很多。', 'img/logs/u2/log_17/steps/151.png'),
(103, 17, 152, '乾煸的時候要小心噴油，豬油釋出的香氣很重。', 'img/logs/u2/log_17/steps/152.png'),
(104, 17, 153, '糖色炒得有點淡，下次火可以稍微再大一點點點。', 'img/logs/u2/log_17/steps/153.png'),
(105, 17, 154, '小火燉煮了50分鐘，肉塊已經軟了。', 'img/logs/u2/log_17/steps/154.png'),
(106, 17, 155, '收汁的時候不敢開太大火，結果花了不少時間才變黏稠。', 'img/logs/u2/log_17/steps/155.png'),
(107, 18, 151, '這次薑片放多了一點點去腥。', 'img/logs/u2/log_18/steps/151.png'),
(108, 18, 152, '肉塊煸到微焦金黃，味道層次比較多。', 'img/logs/u2/log_18/steps/152.png'),
(109, 18, 153, '糖色成功！琥珀色的光澤很誘人。', 'img/logs/u2/log_18/steps/153.png'),
(110, 18, 154, '這次蓋鍋蓋燜得很徹底，肉質更入味。', 'img/logs/u2/log_18/steps/154.png'),
(111, 18, 155, '大火收汁後的亮澤度比起上次好太多了。', 'img/logs/u2/log_18/steps/155.png'),
(112, 19, 151, '動作熟練，備料時間縮短不少。', 'img/logs/u2/log_19/steps/151.png'),
(113, 19, 152, '煸出的豬油倒出來一點，避免整體太油膩。', 'img/logs/u2/log_19/steps/152.png'),
(114, 19, 153, '精準掌控上色時機，辛香料爆得很香。', 'img/logs/u2/log_19/steps/153.png'),
(115, 19, 154, '燉煮時間剛好60分鐘，入口即化。', 'img/logs/u2/log_19/steps/154.png'),
(116, 19, 155, '完美收官，醬汁緊緊裹住每塊肉。', 'img/logs/u2/log_19/steps/155.png');

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plans`
--

CREATE TABLE `meal_plans` (
  `plan_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `source_template_id` int(11) DEFAULT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `cover_type` tinyint(4) NOT NULL COMMENT '0:系統自動合成, 1:官方預設, 2:使用者上傳',
  `custom_cover_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cover_template_id` int(11) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `meal_plans`
--

INSERT INTO `meal_plans` (`plan_id`, `user_id`, `source_template_id`, `title`, `cover_type`, `custom_cover_url`, `cover_template_id`, `start_date`, `end_date`, `created_at`) VALUES
(1, 2, NULL, '健康均衡三日自煮計畫', 1, NULL, 12, '2026-01-19', '2026-01-21', '2026-01-18 12:30:00'),
(2, 2, NULL, '活力輕食三日自煮計畫', 1, NULL, 11, '2026-01-22', '2026-01-24', '2026-01-21 02:00:00'),
(3, 2, NULL, '春節團圓年菜五日計畫', 1, NULL, 7, '2026-02-16', '2026-02-20', '2026-01-22 00:30:00'),
(4, 2, NULL, '環球味蕾：從浪漫歐陸到經典台韓六日饗宴', 1, NULL, 4, '2026-02-10', '2026-02-15', '2026-01-28 12:30:00'),
(5, 2, NULL, '2026 丙午馬年：除夕至初二團圓年菜計畫', 1, NULL, 5, '2026-02-16', '2026-02-18', '2026-01-28 12:35:00'),
(6, 2, NULL, '春意盎然：三月山林露營三日計畫', 1, NULL, 1, '2026-03-13', '2026-03-15', '2026-01-28 12:43:00'),
(7, 2, NULL, '520 浪漫食光：情侶專屬奢華饗宴計畫', 1, NULL, 9, '2026-05-19', '2026-05-21', '2026-01-28 12:50:00');

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plan_cover_template`
--

CREATE TABLE `meal_plan_cover_template` (
  `cover_template_id` int(11) NOT NULL,
  `template_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `template_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `meal_plan_cover_template`
--

INSERT INTO `meal_plan_cover_template` (`cover_template_id`, `template_url`, `template_name`) VALUES
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

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plan_daily_targets`
--

CREATE TABLE `meal_plan_daily_targets` (
  `daily_target_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `target_date` date NOT NULL,
  `target_kcal` int(11) DEFAULT '2000' COMMENT '當天的目標熱量值，若為 NULL 則邏輯預設為 2000'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `meal_plan_daily_targets`
--

INSERT INTO `meal_plan_daily_targets` (`daily_target_id`, `plan_id`, `target_date`, `target_kcal`) VALUES
(1, 1, '2026-01-19', 2000),
(2, 1, '2026-01-20', 2000),
(3, 1, '2026-01-21', 2000),
(4, 2, '2026-01-22', 2000),
(5, 2, '2026-01-23', 2000),
(6, 2, '2026-01-24', 2000),
(7, 3, '2026-02-16', 2000),
(8, 3, '2026-02-17', 2000),
(9, 3, '2026-02-18', 2000),
(10, 3, '2026-02-19', 2000),
(11, 3, '2026-02-20', 2000),
(12, 4, '2026-02-10', 2000),
(13, 4, '2026-02-11', 2000),
(14, 4, '2026-02-12', 2000),
(15, 4, '2026-02-13', 2000),
(16, 4, '2026-02-14', 2000),
(17, 4, '2026-02-15', 2000),
(18, 5, '2026-02-16', 2000),
(19, 5, '2026-02-17', 2000),
(20, 5, '2026-02-18', 2000),
(21, 6, '2026-03-13', 2000),
(22, 6, '2026-03-14', 2000),
(23, 6, '2026-03-15', 2000),
(24, 7, '2026-05-19', 2000),
(25, 7, '2026-05-20', 2000),
(26, 7, '2026-05-21', 2000);

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plan_folders`
--

CREATE TABLE `meal_plan_folders` (
  `meal_plan_folder_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `folder_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plan_items`
--

CREATE TABLE `meal_plan_items` (
  `item_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `planned_date` datetime NOT NULL,
  `meal_type` tinyint(4) NOT NULL COMMENT '0:早餐, 1:午餐, 2:晚餐',
  `sort_order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `meal_plan_items`
--

INSERT INTO `meal_plan_items` (`item_id`, `plan_id`, `recipe_id`, `planned_date`, `meal_type`, `sort_order`) VALUES
(1, 1, 11, '2026-01-19 12:00:00', 1, 1),
(2, 1, 8, '2026-01-19 12:00:00', 1, 2),
(3, 1, 4, '2026-01-19 18:00:00', 2, 1),
(4, 1, 9, '2026-01-19 18:00:00', 2, 2),
(5, 1, 6, '2026-01-20 08:30:00', 0, 1),
(6, 1, 12, '2026-01-20 12:00:00', 1, 1),
(7, 1, 15, '2026-01-20 12:00:00', 1, 2),
(8, 1, 3, '2026-01-20 18:00:00', 2, 1),
(9, 1, 17, '2026-01-20 18:00:00', 2, 2),
(10, 1, 16, '2026-01-21 12:00:00', 1, 1),
(11, 1, 14, '2026-01-21 12:00:00', 1, 2),
(12, 1, 5, '2026-01-21 18:00:00', 2, 1),
(13, 1, 2, '2026-01-21 18:00:00', 2, 2),
(14, 2, 11, '2026-01-22 12:00:00', 1, 1),
(15, 2, 20, '2026-01-22 18:00:00', 2, 1),
(16, 2, 34, '2026-01-23 08:30:00', 0, 1),
(17, 2, 15, '2026-01-23 12:00:00', 1, 1),
(18, 2, 14, '2026-01-23 18:00:00', 2, 1),
(19, 2, 12, '2026-01-24 12:00:00', 1, 1),
(20, 2, 24, '2026-01-24 18:00:00', 2, 1),
(21, 3, 27, '2026-02-16 18:30:00', 2, 1),
(22, 3, 28, '2026-02-16 18:30:00', 2, 2),
(23, 3, 31, '2026-02-16 18:30:00', 2, 3),
(24, 3, 33, '2026-02-16 20:00:00', 2, 4),
(25, 3, 16, '2026-02-17 12:00:00', 1, 1),
(26, 3, 26, '2026-02-17 18:00:00', 2, 1),
(27, 3, 30, '2026-02-18 12:00:00', 1, 1),
(28, 3, 3, '2026-02-18 18:00:00', 2, 1),
(29, 3, 10, '2026-02-18 18:00:00', 2, 2),
(30, 3, 35, '2026-02-19 15:00:00', 0, 1),
(31, 3, 29, '2026-02-19 18:00:00', 2, 1),
(32, 3, 24, '2026-02-20 12:00:00', 1, 1),
(33, 3, 36, '2026-02-20 18:00:00', 2, 1),
(34, 4, 21, '2026-02-10 18:30:00', 2, 1),
(35, 4, 9, '2026-02-10 18:30:00', 2, 2),
(36, 4, 40, '2026-02-10 20:00:00', 2, 3),
(37, 4, 69, '2026-02-11 12:00:00', 1, 1),
(38, 4, 55, '2026-02-11 12:00:00', 1, 2),
(39, 4, 26, '2026-02-11 18:30:00', 2, 1),
(40, 4, 66, '2026-02-11 18:30:00', 2, 2),
(41, 4, 54, '2026-02-11 18:30:00', 2, 3),
(42, 4, 52, '2026-02-12 12:00:00', 1, 1),
(43, 4, 51, '2026-02-12 12:00:00', 1, 2),
(44, 4, 53, '2026-02-12 18:30:00', 2, 1),
(45, 4, 49, '2026-02-12 18:30:00', 2, 2),
(46, 4, 62, '2026-02-13 12:00:00', 1, 1),
(47, 4, 10, '2026-02-13 12:00:00', 1, 2),
(48, 4, 63, '2026-02-13 19:00:00', 2, 1),
(49, 4, 22, '2026-02-13 19:00:00', 2, 2),
(50, 4, 38, '2026-02-13 21:00:00', 2, 3),
(51, 4, 6, '2026-02-14 09:00:00', 0, 1),
(52, 4, 64, '2026-02-14 12:00:00', 1, 1),
(53, 4, 61, '2026-02-14 12:00:00', 1, 2),
(54, 4, 65, '2026-02-14 19:00:00', 2, 1),
(55, 4, 42, '2026-02-14 20:30:00', 2, 2),
(56, 4, 41, '2026-02-14 20:30:00', 2, 3),
(57, 4, 32, '2026-02-15 10:00:00', 0, 1),
(58, 4, 59, '2026-02-15 12:30:00', 1, 1),
(59, 4, 70, '2026-02-15 12:30:00', 1, 2),
(60, 4, 1, '2026-02-15 18:30:00', 2, 1),
(61, 4, 74, '2026-02-15 20:00:00', 2, 2),
(62, 5, 27, '2026-02-16 18:30:00', 2, 1),
(63, 5, 28, '2026-02-16 18:30:00', 2, 2),
(64, 5, 30, '2026-02-16 18:30:00', 2, 3),
(65, 5, 31, '2026-02-16 18:30:00', 2, 4),
(66, 5, 33, '2026-02-16 20:30:00', 2, 5),
(67, 5, 68, '2026-02-17 12:00:00', 1, 1),
(68, 5, 14, '2026-02-17 12:00:00', 1, 2),
(69, 5, 26, '2026-02-17 18:30:00', 2, 1),
(70, 5, 66, '2026-02-17 18:30:00', 2, 2),
(71, 5, 55, '2026-02-17 18:30:00', 2, 3),
(72, 5, 65, '2026-02-18 12:00:00', 1, 1),
(73, 5, 62, '2026-02-18 12:00:00', 1, 2),
(74, 5, 59, '2026-02-18 18:30:00', 2, 1),
(75, 5, 10, '2026-02-18 18:30:00', 2, 2),
(76, 5, 56, '2026-02-18 18:30:00', 2, 3),
(77, 5, 41, '2026-02-18 20:30:00', 2, 4),
(78, 6, 1, '2026-03-13 18:30:00', 2, 1),
(79, 6, 23, '2026-03-13 18:30:00', 2, 2),
(80, 6, 6, '2026-03-14 09:00:00', 0, 1),
(81, 6, 62, '2026-03-14 12:30:00', 1, 1),
(82, 6, 60, '2026-03-14 12:30:00', 1, 2),
(83, 6, 50, '2026-03-14 18:30:00', 2, 1),
(84, 6, 34, '2026-03-15 08:30:00', 0, 1),
(85, 6, 45, '2026-03-15 08:30:00', 0, 2),
(86, 6, 7, '2026-03-15 12:30:00', 1, 1),
(87, 6, 68, '2026-03-15 12:30:00', 1, 2),
(88, 7, 72, '2026-05-19 18:30:00', 2, 1),
(89, 7, 23, '2026-05-19 18:30:00', 2, 2),
(90, 7, 62, '2026-05-20 12:00:00', 1, 1),
(91, 7, 24, '2026-05-20 12:00:00', 1, 2),
(92, 7, 63, '2026-05-20 19:00:00', 2, 1),
(93, 7, 22, '2026-05-20 19:00:00', 2, 2),
(94, 7, 9, '2026-05-20 19:00:00', 2, 3),
(95, 7, 74, '2026-05-20 21:00:00', 2, 4),
(96, 7, 32, '2026-05-21 10:00:00', 0, 1),
(97, 7, 64, '2026-05-21 12:30:00', 1, 1),
(98, 7, 15, '2026-05-21 12:30:00', 1, 2);

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plan_templates`
--

CREATE TABLE `meal_plan_templates` (
  `template_id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `cover_template_id` int(11) NOT NULL,
  `total_days` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `meal_plan_templates`
--

INSERT INTO `meal_plan_templates` (`template_id`, `title`, `description`, `cover_template_id`, `total_days`, `created_at`, `is_active`) VALUES
(1, '高效健身：高蛋白三日增肌減脂計畫', '專為健身族群與體態管理者規劃。本計畫核心在於高蛋白質攝取與適量複合碳水化合物的平衡，利用舒肥、清蒸與香煎等低油烹調方式，確保攝取純淨營養的同時，也能享受多國風味的料理體驗。', 1, 3, '2026-01-28 21:00:00', 0),
(2, '韓流食尚：經典韓式熱門料理五日計畫', '集結韓國街頭與家庭最受歡迎的靈魂料理。從火辣過癮的部隊鍋、辣炒年糕，到香甜誘人的蜂蜜炸雞與石鍋拌飯，讓您連續五天沉浸在道地的韓式味覺饗宴中。', 2, 5, '2026-01-28 21:10:00', 0),
(3, '異國甜點盛宴：午茶時光精選五日計畫', '專為甜點控打造的環球甜點之旅。包含日式舒芙蕾、法式可麗露、蒙布朗以及抹茶熔岩蛋糕，每日精選兩款經典甜點組合，在家也能享受精品等級的下午茶時光。', 3, 5, '2026-01-28 21:15:00', 0),
(4, '家常溫馨味：精選中式熱炒三日計畫', '嚴選最下飯的台式與川式經典家常菜。包含三杯雞、客家小炒、麻婆豆腐等熱炒店必點料理，搭配溫潤的藥膳雞湯或排骨湯，呈現最溫暖、最具飽足感的日常餐桌。', 4, 3, '2026-01-28 21:20:00', 0),
(5, '西洋約會夜：精選義法排餐三日計畫', '打造居家儀式感的首選模板。涵蓋肋眼牛排、松露燉飯、瑪格麗特披薩等義法餐廳經典，從前菜沙拉到主餐湯品皆完美搭配，適合慶祝或浪漫約會使用。', 5, 3, '2026-01-28 21:25:00', 0);

-- --------------------------------------------------------

--
-- 資料表結構 `meal_plan_template_items`
--

CREATE TABLE `meal_plan_template_items` (
  `item_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `meal_type` tinyint(4) NOT NULL COMMENT '0:早餐, 1:午餐, 2:晚餐',
  `sort_order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `meal_plan_template_items`
--

INSERT INTO `meal_plan_template_items` (`item_id`, `template_id`, `recipe_id`, `day_number`, `meal_type`, `sort_order`) VALUES
(1, 1, 11, 1, 1, 1),
(2, 1, 8, 1, 1, 2),
(3, 1, 15, 1, 2, 1),
(4, 1, 58, 1, 2, 2),
(5, 1, 45, 2, 0, 1),
(6, 1, 12, 2, 1, 1),
(7, 1, 55, 2, 1, 2),
(8, 1, 14, 2, 2, 1),
(9, 1, 34, 3, 0, 1),
(10, 1, 62, 3, 1, 1),
(11, 1, 10, 3, 1, 2),
(12, 1, 20, 3, 2, 1),
(13, 1, 54, 3, 2, 2),
(14, 2, 52, 1, 1, 1),
(15, 2, 51, 1, 1, 2),
(16, 2, 49, 2, 2, 1),
(17, 2, 53, 2, 2, 2),
(18, 2, 50, 3, 2, 1),
(19, 2, 17, 4, 2, 1),
(20, 2, 51, 4, 2, 2),
(21, 2, 52, 5, 1, 1),
(22, 3, 32, 1, 0, 1),
(23, 3, 35, 1, 0, 2),
(24, 3, 33, 2, 0, 1),
(25, 3, 34, 2, 0, 2),
(26, 3, 2, 3, 0, 1),
(27, 3, 38, 3, 0, 2),
(28, 3, 40, 4, 0, 1),
(29, 3, 42, 4, 0, 2),
(30, 3, 41, 5, 0, 1),
(31, 3, 43, 5, 0, 2),
(32, 4, 26, 1, 2, 1),
(33, 4, 66, 1, 2, 2),
(34, 4, 55, 1, 2, 3),
(35, 4, 30, 2, 2, 1),
(36, 4, 28, 2, 2, 2),
(37, 4, 31, 2, 2, 3),
(38, 4, 3, 3, 2, 1),
(39, 4, 29, 3, 2, 2),
(40, 4, 56, 3, 2, 3),
(41, 5, 1, 1, 2, 1),
(42, 5, 23, 1, 2, 2),
(43, 5, 9, 1, 2, 3),
(44, 5, 62, 2, 1, 1),
(45, 5, 4, 2, 2, 1),
(46, 5, 25, 2, 2, 2),
(47, 5, 63, 3, 2, 1),
(48, 5, 22, 3, 2, 2),
(49, 5, 24, 3, 2, 3);

-- --------------------------------------------------------

--
-- 資料表結構 `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `notification_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_content` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_photo_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `orders`
--

CREATE TABLE `orders` (
  `order_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `logistics_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subtotal` int(11) NOT NULL,
  `discount_amount` int(11) DEFAULT '0',
  `shipping_fee` int(11) DEFAULT '0',
  `total_amount` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `recipient_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `shipping_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_status` int(11) NOT NULL DEFAULT '0',
  `payment_method` int(11) NOT NULL,
  `payment_status` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `logistics_id`, `subtotal`, `discount_amount`, `shipping_fee`, `total_amount`, `created`, `recipient_name`, `recipient_phone`, `shipping_address`, `order_status`, `payment_method`, `payment_status`) VALUES
(111018, 1, '1211031', 310, 0, 0, 310, '2026-01-22 10:00:00', '王小花', '0952875365', '桃園市中壢區中正路111號', 1, 1, 1),
(111019, 2, '1211031', 350, 0, 0, 350, '2026-01-22 10:00:00', '張小花', '0952875365', '桃園市中壢區中正路111號', 1, 1, 1);

-- --------------------------------------------------------

--
-- 資料表結構 `order_products`
--

CREATE TABLE `order_products` (
  `order_product_id` int(11) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `snapshot_price` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `subtotal` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `order_products`
--

INSERT INTO `order_products` (`order_product_id`, `order_id`, `product_id`, `product_name`, `snapshot_price`, `quantity`, `subtotal`) VALUES
(1, 111018, 1, '舒肥雞胸藜麥飯', 160, 1, 160),
(2, 111018, 4, '豆腐漢堡排佐野菇', 150, 1, 150),
(3, 111019, 2, '香煎鮭魚糙米便當', 200, 1, 200),
(4, 111019, 4, '豆腐漢堡排佐野菇', 150, 1, 150);

-- --------------------------------------------------------

--
-- 資料表結構 `personal_folders`
--

CREATE TABLE `personal_folders` (
  `personal_folder_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `folder_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_category` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_image` json NOT NULL,
  `product_description` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_price` decimal(10,2) NOT NULL,
  `product_kcal` decimal(10,2) DEFAULT NULL,
  `product_carbs` decimal(5,2) DEFAULT NULL,
  `product_fat` decimal(5,2) DEFAULT NULL,
  `product_fiber` decimal(5,2) DEFAULT NULL,
  `product_protein` decimal(5,2) DEFAULT NULL,
  `product_saturated_fat` decimal(5,2) DEFAULT NULL,
  `product_sugar` decimal(5,2) DEFAULT NULL,
  `product_sodium` decimal(10,2) DEFAULT NULL,
  `product_net_weight` decimal(10,2) NOT NULL,
  `product_ingredients` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_cooking_method` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_storage_method` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_reminder` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_release` tinyint(1) NOT NULL DEFAULT '0',
  `product_is_hot` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:一般, 1:熱銷'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `products`
--

INSERT INTO `products` (`product_id`, `product_name`, `product_category`, `product_image`, `product_description`, `product_price`, `product_kcal`, `product_carbs`, `product_fat`, `product_fiber`, `product_protein`, `product_saturated_fat`, `product_sugar`, `product_sodium`, `product_net_weight`, `product_ingredients`, `product_cooking_method`, `product_storage_method`, `product_reminder`, `product_release`, `product_is_hot`) VALUES
(1, '舒肥雞胸藜麥飯', '低卡健身系列', '[{\"id\": 1, \"is_cover\": true, \"image_url\": \"img/mall/PROD-001_01.jpg\", \"sort_order\": 1}, {\"id\": 2, \"is_cover\": false, \"image_url\": \"img/mall/PROD-001_02.jpg\", \"sort_order\": 2}, {\"id\": 3, \"is_cover\": false, \"image_url\": \"img/mall/PROD-001_03.jpg\", \"sort_order\": 3}]', '想吃得健康，又不想犧牲美味？我們的「舒肥雞胸藜麥飯」專為忙碌的現代人、健身族與體重管理者設計。採用低溫烹調技術鎖住肉汁，搭配超級食物大軍，讓你每一口都吃進飽足感與純淨營養。', '160.00', '250.00', '42.00', '4.20', '5.50', '28.50', '0.80', '0.50', '420.00', '250.00', '1.嚴選低溫舒肥嫩雞胸。\n2.黃金兩色藜麥糙米飯(三色藜麥、優質糙米)。\n3.五彩均衡鮮蔬(青花菜、鮮甜紅蘿蔔 / 黃玉米筍、栗子地瓜 / 烤南瓜、毛豆仁)。', '1.微波加熱：撕開包裝一角以800W 加熱約2-3分鐘。\n2.隔水加熱：整包放入熱水中浸泡5-8分鐘(不建議沸騰加熱以維持肉質嫩度)。\n3.電鍋加熱：解凍後放入內鍋，外鍋加少許水，跳起即可。', '冷凍 -18度 以下可保存 12 個月。', '本產品含有穀類製品，過敏者請留意。', 1, 0),
(2, '香煎鮭魚糙米便當', '低卡健身系列', '[{\"id\": 4, \"is_cover\": true, \"image_url\": \"img/mall/PROD-002_01.jpg\", \"sort_order\": 1}, {\"id\": 5, \"is_cover\": false, \"image_url\": \"img/mall/PROD-002_02.jpg\", \"sort_order\": 2}, {\"id\": 6, \"is_cover\": false, \"image_url\": \"img/mall/PROD-002_03.jpg\", \"sort_order\": 3}]', '「每一口都是山海與大地的交織。」 掀開餐盒，首先映入眼簾的是煎得焦香亮澤的鮭魚排，撒上少許黑胡椒與海鹽提味，入口即化；搭配著散發淡淡稻米香氣的糙米飯，咀嚼間能感受到層次分明的口感。配菜的鮮甜則平衡了魚肉的油脂，讓整份便當吃起來清爽無壓力。', '220.00', '580.00', '72.50', '4.20', '8.00', '35.00', '6.00', '5.00', '800.00', '480.00', '1.嚴選阿拉斯加鮭魚。\n2.季節時蔬與配菜(綠色蔬菜、玉米筍或是地瓜等)。\n3.Q彈糙米飯。', '1.微波加熱：噴灑少許水於米飯上，中火加熱 2-3 分鐘。\n2.電鍋加熱：外鍋放入半杯水，跳起後燜 5 分鐘即可。', '冷凍 -18度 以下可保存 12 個月。', '本產品含有魚類及蛋類，過敏者請留意。', 1, 0),
(3, '蒜香毛豆嫩豬排', '低卡健身系列', '[{\"id\": 7, \"is_cover\": true, \"image_url\": \"img/mall/PROD-003_01.jpg\", \"sort_order\": 1}, {\"id\": 8, \"is_cover\": false, \"image_url\": \"img/mall/PROD-003_02.jpg\", \"sort_order\": 2}, {\"id\": 9, \"is_cover\": false, \"image_url\": \"img/mall/PROD-003_03.jpg\", \"sort_order\": 3}]', '這款料理包選用台灣在地活菌豬，搭配飽滿翠綠的非基改毛豆，並注入大量爆香蒜碎。豬排經過獨家斷筋技術處理，口感滑嫩不乾柴，每一口都能品嚐到濃郁的蒜香與豆香。', '180.00', '318.00', '15.00', '14.20', '2.50', '32.50', '8.00', '6.00', '1000.00', '200.00', '1.嚴選秘製嫩豬排。\n2.清甜毛豆仁。\n3.職人調味特製蒜蓉醬包。', '1.香煎：熱鍋倒入少許油，將豬排雙面各煎約 1.5 分鐘至金黃色。\n2.拌炒：加入毛豆仁與特製蒜蓉醬包，快速翻炒約 1 分鐘，待醬汁收乾鎖入肉質。', '冷凍 -18度 以下可保存 12 個月。', '本產品含有大豆及其製品和含麩質之穀物及其製品，過敏者請留意。', 1, 0),
(4, '豆腐漢堡排佐野菇', '低卡健身系列', '[{\"id\": 10, \"is_cover\": true, \"image_url\": \"img/mall/PROD-004_01.jpg\", \"sort_order\": 1}, {\"id\": 11, \"is_cover\": false, \"image_url\": \"img/mall/PROD-004_02.jpg\", \"sort_order\": 2}, {\"id\": 12, \"is_cover\": false, \"image_url\": \"img/mall/PROD-004_03.jpg\", \"sort_order\": 3}]', '打破你對健康料理「淡而無味」的刻板印象！ 我們選用非基因改造黃豆製作的嫩豆腐，打造出如雲朵般綿密軟嫩的漢堡排。搭配細火慢燉的綜合野菇芡汁，濃郁的蕈菇香氣與清爽的漢堡排完美融合，是一道讓身體零負擔、心靈大滿足的精緻主食。', '150.00', '232.00', '2.00', '11.60', '2.50', '18.50', '4.00', '6.00', '1000.00', '200.00', '1.非基因改造板豆腐漢堡排。\n2.新鮮洋蔥。\n3.新鮮蕈菇類： 香菇、鴻喜菇、雪白菇、金針菇(切段或切片，增加多層次咬感)。\n4.職人調配野菇醬。', '1.微波加熱：解凍後，撕開包裝倒入盤中，強火 微波 2-3 分鐘。\n2.進階吃法(推薦)：解凍後，將漢堡排取出用平底鍋稍微煎至兩面微焦，再淋上加熱後的野菇醬，香氣更升級！', '冷凍 -18度 以下可保存 12 個月。', '本產品含有大豆(豆腐/醬油)。', 1, 0),
(5, '檸檬紙包魚片', '低卡健身系列', '[{\"id\": 13, \"is_cover\": true, \"image_url\": \"img/mall/PROD-005_01.jpg\", \"sort_order\": 1}, {\"id\": 14, \"is_cover\": false, \"image_url\": \"img/mall/PROD-005_02.jpg\", \"sort_order\": 2}, {\"id\": 15, \"is_cover\": false, \"image_url\": \"img/mall/PROD-005_03.jpg\", \"sort_order\": 3}]', '選用肉質細緻的頂級白肉魚片(如鱸魚或鯛魚)，搭配新鮮切片黃檸檬與特調義式香料醬汁。不需動油鍋，僅需進烤箱或氣炸鍋，即可享受宛如高級餐館現做的鮮甜滋味。', '210.00', '215.00', '6.40', '8.20', '2.50', '28.50', '2.50', '3.00', '800.00', '150.00', '1.優質白肉魚片(去刺)。\n2.蔬菜：鮮甜蘆筍、彩色甜椒、黃節瓜、新鮮黃檸檬片。\n3.新鮮洋蔥。\n4.調味醬包：初榨橄欖油、海鹽、黑胡椒、蒜末、迷悉香、白葡萄酒。', '1.烤箱(推薦)：烤箱預熱至 200°C，將魚片與蔬菜放入紙包中，淋上醬汁並密封。放入烤箱烘烤 15–18 分鐘 即可。\n2.氣炸鍋：溫度設定 180°C，將紙包密封好放入，氣炸約 12–15 分鐘。', '冷凍 -18度 以下可保存 12 個月。', '生產線亦處理甲殼類、大豆、牛奶及其製品，過敏者請留意。', 1, 0),
(6, '日式壽喜燒牛丼', '日韓風味系列', '[{\"id\": 16, \"is_cover\": true, \"image_url\": \"img/mall/PROD-006_01.jpg\", \"sort_order\": 1}, {\"id\": 17, \"is_cover\": false, \"image_url\": \"img/mall/PROD-006_02.jpg\", \"sort_order\": 2}, {\"id\": 18, \"is_cover\": false, \"image_url\": \"img/mall/PROD-006_03.jpg\", \"sort_order\": 3}]', '嚴選油脂分布均勻的優質牛胸腹肉，搭配鮮甜日本洋蔥，浸入由純釀造醬油、味醂、清酒與職人鰹魚高湯調製而成的秘製壽喜燒醬汁。長時間慢火燉煮，肉質鮮嫩不乾柴，每一口都能嚐到鹹甜適中的道地江戶前風味。', '170.00', '386.00', '15.60', '28.40', '1.20', '16.80', '15.00', '20.00', '1200.00', '200.00', '1.嚴選牛胸腹肉：挑選油脂比例適中的美國/澳洲牛肉，切成 1.5mm 最佳口感薄片，確保口感鮮嫩。\n2.鮮甜在地洋蔥：採用大量新鮮洋蔥，慢火熬煮至半透明，釋放天然澱粉質與甜味。\n3.職人秘製壽喜燒醬。', '1.隔水加熱(推薦)：無需解凍，將料理包直接放入沸水中加熱約 5-7 分鐘，撕開即可淋在飯上。\n2.微波加熱：請先將內容物倒入可微波容器中，覆蓋後以 800W 加熱約2-3分鐘。（請勿將鋁箔袋直接放入微波爐）\n3.電鍋加熱：解凍後放入碗中，外鍋加入半杯水，蒸至開關跳起即可。\n4.主廚私房吃法：趁熱打入一顆溫泉蛋或撒上些許七味粉與紅生薑，風味更具層次感！', '冷凍 -18度 以下可保存 12 個月。', '本產品與其他含有堅果、魚類、奶類、甲殼類、蛋的產品於同一產線生產，食物過敏者請留意。', 1, 0),
(7, '韓式泡菜炒豬肉', '日韓風味系列', '[{\"id\": 19, \"is_cover\": true, \"image_url\": \"img/mall/PROD-007_01.jpg\", \"sort_order\": 1}, {\"id\": 20, \"is_cover\": false, \"image_url\": \"img/mall/PROD-007_02.jpg\", \"sort_order\": 2}, {\"id\": 21, \"is_cover\": false, \"image_url\": \"img/mall/PROD-007_03.jpg\", \"sort_order\": 3}]', '這道經典的韓式家常菜，我們選用熟成恰到好處的發酵老泡菜，搭配油脂分佈均勻的特選豬五花切片。泡菜的酸辣爽脆與豬肉的油脂香氣在鍋中交織，淋上獨門大醬祕製醬汁，每一口都是鹹、香、辣的完美平衡。', '165.00', '462.50', '4.10', '33.80', '3.00', '31.00', '11.00', '12.00', '1600.00', '250.00', '1.道地風味：嚴選韓式發酵泡菜，酸辣帶勁，非一般化學調味。\n2.軟嫩多汁：豬肉預先醃製入味，大火快炒也不乾柴。\n3.職人秘製壽喜燒醬。', '1.隔水加熱(最推薦)：不拆袋直接放入沸水中，加熱約 5-8 分鐘，拆袋倒出即可享用。\n2.平底鍋熱炒(香氣最足)：解凍後拆袋倒入鍋中，加入少許油，中火翻炒 3 分鐘至醬汁微微收乾，香氣更濃郁。\n3.鍋加熱： 解凍後放入碗中，外鍋加入半杯水，蒸至開關跳起即可。\n4.微波加熱：拆袋倒入可微波容器，蓋上上蓋。以 800W 加熱約 3-4 分鐘。\n5. 美味小撇步：出鍋前撒上一把新鮮青蔥段或鋪上一片起司，風味層次更加分！', '冷凍 -18度 以下可保存 6 個月。', '本產品含有大豆、小麥、魚類、甲殼類(蝦)及芝麻，不適合對其過敏體質者食用。', 1, 0),
(8, '北海道咖哩雞', '日韓風味系列', '[{\"id\": 22, \"is_cover\": true, \"image_url\": \"img/mall/PROD-008_01.jpg\", \"sort_order\": 1}, {\"id\": 23, \"is_cover\": false, \"image_url\": \"img/mall/PROD-008_02.jpg\", \"sort_order\": 2}, {\"id\": 24, \"is_cover\": false, \"image_url\": \"img/mall/PROD-008_03.jpg\", \"sort_order\": 3}]', '不同於傳統褐色的辛辣咖哩，我們的北海道白咖哩以優質牛乳與鮮奶油為基底，佐以多種辛香料低溫慢火熬煮。入口是如絲綢般的醇厚乳香，隨之而來的是咖哩的微辛層次，最後帶出在地時蔬的清甜。', '155.00', '420.00', '26.00', '25.20', '2.80', '22.40', '11.00', '16.00', '1200.00', '280.00', '1.嚴選食材：採用新鮮去骨雞腿肉，大塊入味，鮮嫩不乾柴。\n2.大地精華：搭配鬆軟馬鈴薯與鮮甜胡蘿蔔，重現道地北海道風味。', '1.隔水加熱：將料理包(無需拆封)放入沸水中，加熱約 5-8 分鐘。\n2.微波加熱：撕開包裝倒入微波專用容器，以 800W 加熱約 2-3 分鐘。\n3.職人吃法：建議搭配熱騰騰的白飯或剛烤好的法棍麵包，灑上少許荷蘭芹(Parsley)風味更佳。', '冷凍 -18度 以下可保存 12 個月。', '本產品含有牛奶、羊奶、含麩質之穀物及其製品。生產線亦處理甲殼類、蛋、魚類、大豆、芝麻及其製品，過敏者請留意。', 1, 0),
(9, '照燒鮭魚排', '日韓風味系列', '[{\"id\": 25, \"is_cover\": true, \"image_url\": \"img/mall/PROD-009_01.jpg\", \"sort_order\": 1}, {\"id\": 26, \"is_cover\": false, \"image_url\": \"img/mall/PROD-009_02.jpg\", \"sort_order\": 2}, {\"id\": 27, \"is_cover\": false, \"image_url\": \"img/mall/PROD-009_03.jpg\", \"sort_order\": 3}]', '鮭魚富含豐富的 Omega-3 與優質蛋白質，經過低溫醃製入味，煎烤後外皮微焦酥香，內裡魚肉鮮嫩多汁。甜鹹適中的照燒風味，無論是搭配白飯做成「照燒鮭魚丼」，還是配上溫沙拉，都是全家大小最愛的營養首選！', '230.00', '215.00', '5.60', '13.20', '0.00', '18.50', '5.00', '15.00', '1200.00', '150.00', '1.真材實料：嚴選厚切鮭魚，拒絕碎肉組合。\n2.職人秘製醬汁。', '1.香煎法：解凍後，將鮭魚排表面水分稍微拭乾。平底鍋倒入少許油，以中小火兩面各煎約 3 分鐘，最後倒入剩餘醬汁稍微收汁即可。\n2.氣炸鍋：無需解凍，溫度設定 180°C，氣炸 10-12 分鐘(中途可翻面一次)，至表面呈金黃色。\n3.烤箱法：烤箱預熱至 200°C，放入鮭魚排烤約 15 分鐘。', '冷凍 -18度 以下可保存 12 個月。', '本產品含有魚類、大豆及含麩質之穀物(醬油來源)，不適合對其過敏體質者食用。', 1, 0),
(10, '經典義大利肉醬麵', '歐美西式系列', '[{\"id\": 28, \"is_cover\": true, \"image_url\": \"img/mall/PROD-010_01.jpg\", \"sort_order\": 1}, {\"id\": 29, \"is_cover\": false, \"image_url\": \"img/mall/PROD-010_02.jpg\", \"sort_order\": 2}, {\"id\": 30, \"is_cover\": false, \"image_url\": \"img/mall/PROD-010_03.jpg\", \"sort_order\": 3}]', '這不僅是一包肉醬，而是時間的沉澱。我們選用優質紐澳草飼牛與國產豬肉，以7:3黃金比例混合，打造多層次的咬勁與香氣。搭配新鮮番茄、洋蔥、芹菜與胡蘿蔔，經由4小時低溫慢燉，讓蔬菜的清甜完全融入肉汁。每一口都能感受到濃郁番茄酸甜與厚實肉香在舌尖交織。無需繁複煮食，只要幾分鐘，讓家中餐桌瞬間變成道地的義式小餐館。', '145.00', '290.00', '27.60', '13.80', '2.80', '8.50', '10.00', '12.00', '1300.00', '360.00', '1.直人秘製肉醬包。\n2.手工麵條。', '1.水煮加熱(推薦)：將醬包(不拆袋)放入沸水中煮 5 分鐘。同時另鍋煮熟麵條，最後將醬汁淋上即可。\n2.微波加熱：撕開醬包倒入碗中，強火(800W)加熱約 2 分鐘。\n3.職人煮法：醬包解凍後倒入平底鍋，加入煮好的麵條與 20cc 煮麵水，中火拌炒 1 分鐘，讓醬汁吸附在麵條上更美味。', '冷凍 -18度 以下可保存 12 個月。', '本產品含有麩質之穀物(小麥)製品,食物過敏者請留意。', 1, 0),
(11, '奶油松露野菇燉飯', '歐美西式系列', '[{\"id\": 31, \"is_cover\": true, \"image_url\": \"img/mall/PROD-011_01.jpg\", \"sort_order\": 1}, {\"id\": 32, \"is_cover\": false, \"image_url\": \"img/mall/PROD-011_02.jpg\", \"sort_order\": 2}, {\"id\": 33, \"is_cover\": false, \"image_url\": \"img/mall/PROD-011_03.jpg\", \"sort_order\": 3}]', '「極致香氣，瞬間綻放。」當義大利頂級黑松露的獨特木質芬芳，遇上濃郁溫潤的法式鮮奶油，每一口燉飯都包裹著飽滿的菇鮮與奶香。我們堅持選用高品質義大利米與綜合野菇，透過慢火熬煮的濃縮精華，讓您只需 5 分鐘，就能在家中復刻米其林等級的優雅滋味。', '195.00', '495.00', '57.90', '24.60', '5.40', '10.50', '15.00', '8.00', '1200.00', '0.00', '1.燉飯底：義大利產卡納羅利米 (Carnaroli)/ 台灣優質一等米、鮮奶油、奶油、洋蔥、蒜末、蔬菜高湯。\n2.蕈菇類：香菇、杏鮑菇、蘑菇、黑松露醬(黑松露、橄欖油、鹽)。\n3.調味：帕瑪森起司、白葡萄酒、岩鹽、黑胡椒、百里香。', '1.隔水加熱：不拆袋放入沸水中，加熱約 5-8 分鐘即可倒出享用。\n2.微波加熱：拆袋倒入微波專用碗，中火加熱約 3 分鐘(視微波功率調整)。\n3.主廚推薦：倒入平底鍋中，加入 20ml 水或牛奶，小火翻炒至濃稠狀，起鍋前撒上起司粉 or 點綴一點橄欖油，風味更佳。', '冷凍 -18度 以下可保存 6個月。', '本產品含有牛奶及其製品(奶油、起司、鮮奶油)，不適合對其過敏體質者食用。', 1, 0),
(12, '美式紐奧良烤雞翅', '歐美西式系列', '[{\"id\": 34, \"is_cover\": true, \"image_url\": \"img/mall/PROD-012_01.jpg\", \"sort_order\": 1}, {\"id\": 35, \"is_cover\": false, \"image_url\": \"img/mall/PROD-012_02.jpg\", \"sort_order\": 2}, {\"id\": 36, \"is_cover\": false, \"image_url\": \"img/mall/PROD-012_03.jpg\", \"sort_order\": 3}]', '正宗紐奧良風味，開啟味蕾的狂歡盛宴！我們選用肉質Ｑ彈的國產雞翅，加入數十種紐奧良靈魂香料（紅椒、大蒜、黑胡椒及多種香草）低溫長時間醃製。每一口都能感受到煙燻的微甜與辛香料的層次，外皮金黃微焦，肉質滑嫩多汁。', '160.00', '430.00', '28.40', '10.00', '0.00', '33.00', '10.00', '8.00', '1000.00', '200.00', '1.紐奧良醃漬的精選雞翅(三節翅或二節翅)。', '1.氣炸鍋(推薦)：無需解凍，溫度設定180°C，氣炸約12~15 分鐘。中途建議翻面一次，色澤更均勻。\r\n2.烤箱：預熱至200°C，放入烤箱烘烤15~18 分鐘即可。\r\n3.微波爐：撕開包裝一角，以800W中高火加熱約3~5 分鐘(口感較軟嫩，皮不會脆)。', '冷凍保存。', '本產品含有大豆、含麩質之穀物(醬油)及其製品。', 1, 0),
(13, '白酒蒜香蛤蜊麵', '歐美西式系列', '[{\"id\": 37, \"is_cover\": true, \"image_url\": \"img/mall/PROD-013_01.jpg\", \"sort_order\": 1}, {\"id\": 38, \"is_cover\": false, \"image_url\": \"img/mall/PROD-013_02.jpg\", \"sort_order\": 2}, {\"id\": 39, \"is_cover\": false, \"image_url\": \"img/mall/PROD-013_03.jpg\", \"sort_order\": 3}]', '不用精湛廚藝，也能擁有一桌浪漫的義式晚餐。我們選用鮮甜飽滿的蛤蜊，搭配特級初榨橄欖油與大量金黃蒜片，最後以乾爽的白酒提味。每一根麵條都吸飽了海洋的鮮美與酒香的優雅，讓您在家也能享受餐酒館等級的精緻饗宴。', '185.00', '485.00', '65.00', '12.50', '0.00', '18.20', '3.00', '3.00', '1200.00', '350.00', '1.嚴選海味：採用高溫高壓殺菌技術，保留蛤蜊的原汁原味，顆顆鮮甜。\r\n2.靈魂醬汁：大量蒜末與辛香料慢火煸香，白酒香氣層次分明。3.Q彈麵條：進口杜蘭小麥粉製成，口感扎實，微波或拌炒皆能保持彈牙。', '1.平底鍋拌炒(推薦，口感最道地)：將麵條包與醬汁包先行退冰，在平底鍋加入少許油，倒入醬汁包與蛤蜊煮至沸騰，加入麵條均勻拌炒約 1-2 分鐘，待醬汁收濃後即可起鍋。\r\n2.微波加熱：在包裝袋上撕開一個小洞，以 800W 功率微波約 3-4 分鐘，倒出至餐盤中拌勻，灑上內附的香料粉。', '冷凍保存。', '本產品含有甲殼類(蛤蜊)、含麩質之穀物(小麥)及其製品。', 1, 0),
(14, '經典奶油培根義大利麵', '歐美西式系列', '[{\"id\": 40, \"is_cover\": true, \"image_url\": \"img/mall/PROD-014_01.jpg\", \"sort_order\": 1}, {\"id\": 41, \"is_cover\": false, \"image_url\": \"img/mall/PROD-014_02.jpg\", \"sort_order\": 2}, {\"id\": 42, \"is_cover\": false, \"image_url\": \"img/mall/PROD-014_03.jpg\", \"sort_order\": 3}]', '不需要專業廚藝，也能在家還原義大利餐酒館的經典之作。我們選用香醇的厚切培根，搭配法國進口鮮奶油與熟成帕瑪森起司。每一口都能感受到煙燻肉香與溫潤奶香的完美融合，鹹香適中，是大朋友小朋友都無法抗拒的療癒系美食。', '145.00', '245.00', '23.80', '12.50', '0.00', '9.20', '20.00', '6.00', '1400.00', '350.00', '1.杜蘭小麥義大利麵 (Spaghetti)： 選用 100% 杜蘭小麥粉製成。\r\n2.特製奶油起司醬。\r\n3.厚切煙燻培根。', '1.平底鍋加熱：平底鍋加入 30ml 水，倒入醬包與麵條，中火翻炒至醬汁收濃、麵條均勻掛漿即可(約 2 分鐘)。\r\n2.微波加熱：在包裝袋上撕開一個小洞，以 800W 功率微波約 3-4 分鐘，倒出至餐盤中拌勻，灑上內附的香料粉。', '冷凍保存。', '本產品含有牛奶、蛋、含麩質之穀物及其製品，不適合對其過敏體質者食用。', 1, 0),
(15, '台式三杯雞', '台式家常系列', '[{\"id\": 43, \"is_cover\": true, \"image_url\": \"img/mall/PROD-015_01.jpg\", \"sort_order\": 1}, {\"id\": 44, \"is_cover\": false, \"image_url\": \"img/mall/PROD-015_02.jpg\", \"sort_order\": 2}, {\"id\": 45, \"is_cover\": false, \"image_url\": \"img/mall/PROD-015_03.jpg\", \"sort_order\": 3}]', '不用動油鍋，也不用頂著熱氣爆香。我們選用鮮嫩多汁的國產雞腿肉，遵循傳統「一杯麻油、一杯醬油、一杯米酒」的黃金比例，慢火煸香老薑片，最後撒入靈魂九層塔。鹹甜適中、醬汁濃郁，是絕對的「白飯殺手」！', '165.00', '336.00', '9.20', '20.40', '0.00', '29.00', '9.00', '15.00', '1300.00', '200.00', '1.精選國產去骨雞腿肉。\r\n2.老薑片、蒜粒、鮮切九層塔、紅辣椒(微辣提味)。\r\n3.主廚秘製醬汁。', '1.隔水加熱(最推薦)：不拆袋，放入沸水中煮約 5-8 分鐘，即可倒出享用。\r\n2.微波加熱：拆袋倒入微波容器，高火(800W)加熱約 3 分鐘。3.電鍋加熱：拆袋倒入碗中，外鍋加半杯水，跳起即可。', '冷凍保存。', '本產品含有大豆、小麥(醬油來源)及芝麻(麻油來源)，不適合對其過敏體質者食用。', 1, 0),
(16, '家傳紅燒肉', '台式家常系列', '[{\"id\": 46, \"is_cover\": true, \"image_url\": \"img/mall/PROD-016_01.jpg\", \"sort_order\": 1}, {\"id\": 47, \"is_cover\": false, \"image_url\": \"img/mall/PROD-016_02.jpg\", \"sort_order\": 2}, {\"id\": 48, \"is_cover\": false, \"image_url\": \"img/mall/PROD-016_03.jpg\", \"sort_order\": 3}]', '「一塊紅燒肉，是家最溫暖的記憶。」嚴選帶皮五花豬肉，遵循古法長時慢燉。每一塊紅燒肉都呈現琥珀般的誘人光澤，入口即化卻不軟爛，肥而不膩、瘦而不柴。那醇厚濃育的醬香，完美滲透進肉質纖維，淋上一勺精華滷汁，就是三碗白飯也嫌不夠的靈魂美味。', '180.00', '585.00', '12.50', '45.00', '0.00', '32.50', '18.00', '20.00', '1500.00', '250.00', '1.嚴選國產豬五花肉。\r\n2.主廚秘製醬汁。', '1.隔水加熱(最推薦)：不需拆袋，將料理包放入沸水中煮約 8–10 分鐘，即可拆袋享用。\r\n2.微波加熱：拆袋後將內容物倒入微波專用碗，覆蓋後以 800W 加熱約 3–5 分鐘。\r\n3.電鍋加熱：拆袋後放入碗中，外鍋加入半杯水，跳起後即可上桌。', '冷凍保存。', '本產品含有大豆、小麥(醬油來源)，不適合對其過敏者食用。', 1, 0),
(17, '清蒸蔥油鱸魚', '台式家常系列', '[{\"id\": 49, \"is_cover\": true, \"image_url\": \"img/mall/PROD-017_01.jpg\", \"sort_order\": 1}, {\"id\": 50, \"is_cover\": false, \"image_url\": \"img/mall/PROD-017_02.jpg\", \"sort_order\": 2}, {\"id\": 51, \"is_cover\": false, \"image_url\": \"img/mall/PROD-017_03.jpg\", \"sort_order\": 3}]', '「鎖住大海的鮮甜，只需 10 分鐘，五星級名菜優雅上桌。」還在煩惱處理鮮魚的鱗片與內臟嗎？我們為您精選外銷等級的鮮嫩金目鱸魚，已去骨、去鱗、去內臟並切片處理。搭配特製的秘製蒸魚豉油與爆香蔥油，讓您在家也能輕鬆還原飯店大廚的拿手好菜。', '250.00', '469.70', '6.30', '25.20', '0.00', '54.60', '3.50', '3.00', '1000.00', '350.00', '1.嚴選鱸魚片： 約 250g - 300g(已去刺、清肉)。\r\n2.特調蒸魚醬汁。\r\n3.香蔥風味油。\r\n4.乾燥蔥段/薑絲。', '1.清蒸：拆袋將魚片鋪於盤中，淋上「特調蒸魚醬汁」，放入電鍋(外鍋半杯水)或蒸鍋，大火蒸約 8-10 分鐘。\r\n2.淋油：出爐後撒上蔥絲，將「香蔥風味油」加熱後淋在魚片上(或直接拌入)，即可享用。', '冷凍保存。', '本產品含有大豆、小麥(醬油來源)，不適合對其過敏者食用。', 1, 0),
(18, '麻婆豆腐燒', '台式家常系列', '[{\"id\": 52, \"is_cover\": true, \"image_url\": \"img/mall/PROD-018_01.jpg\", \"sort_order\": 1}, {\"id\": 53, \"is_cover\": false, \"image_url\": \"img/mall/PROD-018_02.jpg\", \"sort_order\": 2}, {\"id\": 54, \"is_cover\": false, \"image_url\": \"img/mall/PROD-018_03.jpg\", \"sort_order\": 3}]', '工作忙碌了一整天，想吃熱呼呼的下飯菜卻不想進廚房大動干戈？ 我們的「麻婆豆腐燒」選用特製郫縣豆瓣醬，結合大紅袍花椒的微辣與清香，搭配滑嫩紮實的板豆腐與鮮美豬肉末，經慢火熬煮入味。一口咬下，先是豆瓣的鹹香，隨之而來的是花椒微麻的層次感，最後是豆腐的清甜豆香。這不只是一份料理包，更是您餐桌上的救星。', '130.00', '325.00', '12.00', '22.00', '0.00', '18.50', '8.00', '7.00', '1500.00', '250.00', '1.非基因改造板豆腐、國產豬後腿肉末。\r\n2.主廚特調醬汁。', '1.隔水加熱：無需解凍，將內包裝放入沸水中加熱約 5–8 分鐘，撕開倒入碗中即可。\r\n2.微波加熱：解凍後，撕開倒至微波容器中，使用 800W 加熱約 2–3 分鐘。\r\n主廚小撇步： 上桌前撒上新鮮蔥花或少許花椒粉，風味更上一層樓！', '冷凍保存。', '本產品含有大豆、小麥(醬油來源)及其製品。', 1, 0),
(19, '客家小炒', '台式家常系列', '[{\"id\": 55, \"is_cover\": true, \"image_url\": \"img/mall/PROD-019_01.jpg\", \"sort_order\": 1}, {\"id\": 56, \"is_cover\": false, \"image_url\": \"img/mall/PROD-019_02.jpg\", \"sort_order\": 2}, {\"id\": 57, \"is_cover\": false, \"image_url\": \"img/mall/PROD-019_03.jpg\", \"sort_order\": 3}]', '記憶中那道最下飯的客家滋味，現在 5 分鐘就能上桌！我們嚴選特級五花肉與香鮮魷魚，搭配經典五香豆乾，大火快炒出靈魂般的「焦香味」。乾魷魚的鮮味與豬肉油脂完美融合，每一口都是鹹香帶勁。不管是忙碌的晚餐還是深夜的下酒菜，只要加熱，就是餐廳大廚的現炒水準。', '155.00', '525.00', '14.50', '38.00', '0.00', '31.30', '13.00', '8.00', '1500.00', '250.00', '1台灣產豬五花肉。\r\n2.香乾魷魚。\r\n3.豆乾。\r\n4.特製客家醬油。', '1.隔水加熱：水滾後，將料理包(不拆袋)放入沸水中加熱約 3-5 分鐘。\r\n2.微波加熱：拆袋後倒入可微波容器，以 800W 加熱約 2 分鐘。3.大火快炒(最推薦)：拆袋後倒入鍋中，加入少許蔥段快炒 1 分鐘，鑊氣更足！', '冷凍保存。', '本產品含有大豆、小麥、軟體動物類(魷魚)、甲殼類(蝦米)，不適合其過敏體質者食用。', 1, 0),
(20, '藥膳麻油雞湯', '台式家常系列', '[{\"id\": 58, \"is_cover\": true, \"image_url\": \"img/mall/PROD-020_01.jpg\", \"sort_order\": 1}, {\"id\": 59, \"is_cover\": false, \"image_url\": \"img/mall/PROD-020_02.jpg\", \"sort_order\": 2}, {\"id\": 60, \"is_cover\": false, \"image_url\": \"img/mall/PROD-020_03.jpg\", \"sort_order\": 3}]', '寒流來襲的夜晚，最渴望的那一碗暖湯。我們嚴選在地優質仿土雞腿肉，肉質Q彈不軟爛，搭配傳承三代的特級黑麻油與老薑爆香，辛辣中帶點溫潤。不只是麻油雞，我們更加入精心調配的漢方藥膳（當歸、紅棗、枸杞），以傳統工法慢火熬製，湯頭清甜甘潤，絕無化學添加。加熱只需 10 分鐘，讓忙碌的你，隨時都能享受暖胃更暖心的進補饗宴。', '190.00', '585.00', '9.50', '44.00', '0.00', '37.50', '12.00', '8.00', '1200.00', '500.00', '1.嚴選土雞腿肉。\r\n2.主廚特調湯包。', '1. 隔水加熱：不需拆袋，整包放入沸水中加熱約 8-10 分鐘。\r\n2.微波加熱：拆袋後倒入可微波容器，高火加熱約 3-5 分鐘。\r\n3. 電鍋加熱：拆袋倒入碗中，外鍋加半杯水，跳起即可。\r\n美味小撇步：建議可自行加入高麗菜、凍豆腐或麵線，風味更佳！', '冷凍保存。', '本產品含有芝麻(麻油)及其製品。特別提醒：內含米酒與中藥材，孕婦或特殊疾病患者請諮詢醫師後食用。', 1, 0);

-- --------------------------------------------------------

--
-- 資料表結構 `recipes`
--

CREATE TABLE `recipes` (
  `recipe_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `linked_product_id` int(11) DEFAULT NULL,
  `parent_recipe_id` int(11) DEFAULT NULL,
  `personal_folder_id` int(11) DEFAULT NULL,
  `adaptation_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adaptation_note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recipe_title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipe_image_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipe_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recipe_servings` int(11) NOT NULL,
  `recipe_total_time` time DEFAULT NULL,
  `recipe_difficulty` decimal(2,1) NOT NULL,
  `recipe_like_count` int(11) NOT NULL,
  `recipe_kcal_per_100g` decimal(8,2) DEFAULT NULL,
  `recipe_protein_per_100g` decimal(8,2) DEFAULT NULL,
  `recipe_fat_per_100g` decimal(8,2) DEFAULT NULL,
  `recipe_carbs_per_100g` decimal(8,2) DEFAULT NULL,
  `status` tinyint(4) NOT NULL,
  `recipe_created_at` datetime NOT NULL,
  `recipe_last_updated` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `recipes`
--

INSERT INTO `recipes` (`recipe_id`, `author_id`, `linked_product_id`, `parent_recipe_id`, `personal_folder_id`, `adaptation_title`, `adaptation_note`, `recipe_title`, `recipe_image_url`, `recipe_description`, `recipe_servings`, `recipe_total_time`, `recipe_difficulty`, `recipe_like_count`, `recipe_kcal_per_100g`, `recipe_protein_per_100g`, `recipe_fat_per_100g`, `recipe_carbs_per_100g`, `status`, `recipe_created_at`, `recipe_last_updated`) VALUES
(1, 1, NULL, NULL, NULL, NULL, NULL, '經典瑪格麗特披薩', 'img/recipes/1/cover.png', '義大利最經典的披薩，以新鮮羅勒、莫札瑞拉起司與番茄糊組成，完美呈現紅白綠三色。', 2, '01:30:00', '3.0', 0, '1928.40', '119.96', '57.06', '254.27', 0, '2026-01-15 20:00:00', '2026-01-15 20:00:00'),
(2, 1, NULL, NULL, NULL, NULL, NULL, '抹茶熔岩蛋糕', 'img/recipes/2/cover.png', '口感濃郁的抹茶蛋糕，切開時有如岩漿般的抹茶巧克力流出，是抹茶控絕不能錯過的甜點。', 2, '00:40:00', '3.5', 0, '1384.20', '26.78', '91.25', '116.04', 0, '2026-01-15 20:10:00', '2026-01-15 20:10:00'),
(3, 1, NULL, NULL, NULL, NULL, NULL, '四川宮保雞丁', 'img/recipes/3/cover.png', '川菜精髓之一，講究「糊辣荔枝味」，口感酸甜微麻，搭配酥脆花生與滑嫩雞丁，非常下飯。', 2, '00:35:00', '3.0', 0, '767.35', '68.04', '40.25', '31.63', 0, '2026-01-15 20:30:00', '2026-01-15 20:30:00'),
(4, 1, NULL, NULL, NULL, NULL, NULL, '奶油松露野菇寬麵', 'img/recipes/4/cover.png', '濃郁的鮮奶油與高品質黑松露醬交織出極致香氣，搭配嚼勁十足的寬麵與焦香野菇，是西餐廳等級的美味。', 1, '00:25:00', '2.5', 0, '933.36', '22.79', '56.33', '85.42', 0, '2026-01-15 20:35:00', '2026-01-15 20:35:00'),
(5, 1, NULL, NULL, NULL, NULL, NULL, '泰式青咖哩雞', 'img/recipes/5/cover.png', '道地的泰式經典名菜，青咖哩醬的辛辣與椰奶的香醇交織，搭配滑嫩雞腿肉與吸收醬汁精華的茄子，香氣誘人。', 3, '00:40:00', '3.0', 0, '1641.45', '60.36', '136.63', '62.01', 0, '2026-01-15 20:40:00', '2026-01-15 20:40:00'),
(6, 1, NULL, NULL, NULL, NULL, NULL, '經典班尼迪克蛋', 'img/recipes/6/cover.png', '早午餐中的王者。酥脆的馬芬鋪上鹹香培根與完美的半熟水波蛋，最後淋上濃郁絲滑的荷蘭醬，口感極其豐富。', 2, '00:30:00', '4.0', 0, '1372.16', '39.86', '106.28', '65.02', 0, '2026-01-15 20:50:00', '2026-01-15 20:50:00'),
(7, 1, NULL, NULL, NULL, NULL, NULL, '濃厚豚骨叉燒拉麵', 'img/recipes/7/cover.png', '道地的日式拉麵。乳白色的濃厚豚骨湯底，搭配低溫烹調的叉燒與半熟溏心蛋，每一口都能感受到滿滿的膠原蛋白與誠意。', 1, '00:20:00', '2.0', 0, '713.30', '35.96', '35.56', '62.37', 0, '2026-01-15 21:00:00', '2026-01-15 21:00:00'),
(8, 1, NULL, NULL, NULL, NULL, NULL, '經典自製鷹嘴豆泥', 'img/recipes/8/cover.png', '中東地區最具代表性的國民美食。以鷹嘴豆與塔希尼芝麻醬交織出濃郁風味，口感綿密滑順，不論是搭配口袋餅或是當作蔬菜沾醬都非常適合。', 2, '00:15:00', '1.5', 0, '977.25', '35.10', '63.63', '77.91', 0, '2026-01-15 21:10:00', '2026-01-15 21:10:00'),
(9, 1, NULL, NULL, NULL, NULL, NULL, '法式洋蔥濃湯', 'img/recipes/9/cover.png', '法式料理的經典靈魂。透過長時間慢火拌炒，將洋蔥的辛辣轉化為深邃的焦糖甜味，搭配濃郁高湯與焗烤起司麵包，暖心又奢華。', 2, '01:10:00', '3.5', 0, '3505.83', '127.37', '55.23', '594.47', 0, '2026-01-15 21:15:00', '2026-01-15 21:15:00'),
(10, 1, NULL, NULL, NULL, NULL, NULL, '蒜香檸檬烤大蝦', 'img/recipes/10/cover.png', '簡單卻不失華麗的宴客料理。大虎蝦經過蒜末與黑胡椒醃漬入味，搭配奶油與檸檬片烘烤，蝦肉 Q 彈且散發濃郁的蒜香與清新檸檬香氣。', 2, '00:30:00', '2.0', 0, '691.66', '96.63', '29.17', '15.16', 0, '2026-01-15 21:20:00', '2026-01-15 21:20:00'),
(11, 1, 1, NULL, NULL, NULL, NULL, '舒肥雞胸藜麥飯', 'img/recipes/11/cover.png', '健身愛好者的首選！利用低溫舒肥技術保留雞胸肉的滑嫩多汁，搭配高纖維的藜麥飯與新鮮時蔬，輕盈、美味且無負擔。', 1, '01:20:00', '2.5', 0, '526.81', '44.69', '8.64', '66.14', 0, '2026-01-15 21:30:00', '2026-01-15 21:30:00'),
(12, 1, 2, NULL, NULL, NULL, NULL, '香煎鮭魚糙米便當', 'img/recipes/12/cover.png', '兼具高纖維與優質 Omega-3 的營養便當。利用鮭魚天然出的魚油拌炒時蔬，不僅減少額外油脂攝取，更讓蔬菜帶有海鮮的鮮甜感。', 1, '00:50:00', '2.0', 0, '641.60', '38.26', '21.77', '67.48', 0, '2026-01-16 09:00:00', '2026-01-16 09:00:00'),
(13, 1, 3, NULL, NULL, NULL, NULL, '蒜香毛豆嫩豬排', 'img/recipes/13/cover.png', '鹹甜適中的家常美味。利用刀背拍鬆的豬排吸飽了蒜香與味醂的滋味，搭配營養豐富的毛豆，是一道色香味俱全的下飯好菜。', 2, '00:30:00', '2.0', 0, '718.20', '62.07', '41.69', '22.22', 0, '2026-01-16 10:00:00', '2026-01-16 10:00:00'),
(14, 1, 4, NULL, NULL, NULL, NULL, '豆腐漢堡排佐野菇', 'img/recipes/14/cover.png', '兼顧健康與美味的漢堡排。將板豆腐與豬絞肉以黃金比例混合，肉質鮮嫩多汁且不油膩，搭配鹹甜的野菇醬汁，是一道老少咸宜的日式家常菜。', 2, '00:40:00', '2.5', 0, '915.10', '63.90', '63.55', '25.55', 0, '2026-01-16 11:00:00', '2026-01-16 11:00:00'),
(15, 1, 5, NULL, NULL, NULL, NULL, '檸檬紙包魚片', 'img/recipes/15/cover.png', '健康清爽的法式家常做法。利用烘焙紙將魚片與蔬菜密封，在烤箱中產生蒸氣循環，完美保留鯛魚的鮮美多汁與檸檬百里香的清新氣息。', 1, '00:25:00', '1.5', 0, '210.32', '31.86', '3.95', '8.41', 0, '2026-01-16 12:00:00', '2026-01-16 12:00:00'),
(16, 1, 6, NULL, NULL, NULL, NULL, '日式壽喜燒牛丼', 'img/recipes/16/cover.png', '道地的日式連鎖店風味。以比例完美的壽喜燒醬汁熬煮洋蔥與牛肉，最後淋上滑嫩的半熟蛋液，甜鹹適中的滋味與白飯是絕配。', 1, '00:20:00', '2.0', 0, '823.40', '40.94', '33.93', '82.36', 0, '2026-01-16 13:00:00', '2026-01-16 13:00:00'),
(17, 1, 7, NULL, NULL, NULL, NULL, '韓式泡菜炒豬肉', 'img/recipes/17/cover.png', '白飯殺手！酸辣爽口的韓式泡菜與油脂均勻的梅花豬肉片是大絕配，搭配韓式辣醬翻炒，是一道充滿韓式道地風味的熱炒料理。', 2, '00:20:00', '1.5', 0, '691.76', '40.11', '48.13', '23.68', 0, '2026-01-16 14:00:00', '2026-01-16 14:00:00'),
(18, 1, 8, NULL, NULL, NULL, NULL, '北海道咖哩雞', 'img/recipes/18/cover.png', '充滿北國風情的溫暖料理。在濃郁的日式咖哩中加入鮮奶油，勾勒出如白雪般的滑順奶香，搭配大塊鬆軟的根莖類蔬菜，每一口都飽含層次感。', 3, '00:50:00', '2.5', 0, '2264.90', '212.84', '88.26', '213.44', 0, '2026-01-16 15:00:00', '2026-01-16 15:00:00'),
(19, 1, NULL, NULL, NULL, NULL, NULL, '味噌薑汁燒肉', 'img/recipes/19/cover.png', '日本家庭料理的經典代表！利用味噌的醇厚取代單純醬油，結合辛香薑泥與油脂豐潤的豬腹肉，鹹甜濃郁的滋味配上清脆的高麗菜絲，是極致的白飯殺手。', 2, '00:20:00', '1.5', 0, '1291.90', '22.85', '112.75', '43.91', 0, '2026-01-16 16:00:00', '2026-01-16 16:00:00'),
(20, 1, 9, NULL, NULL, NULL, NULL, '照燒鮭魚排', 'img/recipes/20/cover.png', '經典日式風味。外皮酥脆的鮭魚排裹上鹹甜濃郁的自製照燒醬，亮澤的醬汁掛在魚肉上極其誘人，搭配清爽的水煮青花菜，是一道兼具營養與視覺層次的家常料理。', 1, '00:25:00', '2.0', 0, '508.98', '33.32', '30.29', '19.60', 0, '2026-01-16 17:00:00', '2026-01-16 17:00:00'),
(21, 1, 10, NULL, NULL, NULL, NULL, '經典義大利肉醬麵', 'img/recipes/21/cover.png', '最經典的義式療癒料理。以慢火熬煮的波隆那肉醬，融合番茄的微酸與牛豬肉的濃厚脂香，每一根麵條都緊緊裹滿了精華醬汁。', 2, '00:45:00', '2.5', 0, '1384.90', '66.59', '61.11', '145.24', 0, '2026-01-19 19:00:00', '2026-01-19 19:00:00'),
(22, 1, 11, NULL, NULL, NULL, NULL, '奶油松露野菇燉飯', 'img/recipes/22/cover.png', '義大利料理的極致展現。選用澱粉含量高的 Arborio 米，透過不斷攪拌與分次加入高湯，釋放出米粒精華，最後拌入黑松露醬與起司，濃郁絲滑且香氣撲鼻。', 2, '00:45:00', '3.5', 0, '1188.00', '35.24', '44.30', '135.31', 0, '2026-01-19 20:00:00', '2026-01-19 20:00:00'),
(23, 1, 12, NULL, NULL, NULL, NULL, '美式紐奧良烤雞翅', 'img/recipes/23/cover.png', '派對必備的經典美味！以紅椒粉與多種香料醃漬入味，透過高溫烘烤鎖住肉汁，最後刷上蜂蜜水，呈現出令人垂涎的焦糖光澤與微甜微辣的層次感。', 2, '01:30:00', '2.0', 0, '1329.57', '90.46', '91.45', '35.73', 0, '2026-01-19 21:00:00', '2026-01-19 21:00:00'),
(24, 1, 13, NULL, NULL, NULL, NULL, '白酒蒜香蛤蜊麵', 'img/recipes/24/cover.png', '地中海風味的縮影。利用白葡萄酒激發蛤蜊的鮮甜，並透過快速拌炒讓橄欖油與蛤蜊原汁完美乳化成濃郁醬汁，包裹住每根 Q 彈的細扁麵。', 1, '00:25:00', '3.0', 0, '843.35', '62.40', '23.54', '84.68', 0, '2026-01-19 21:30:00', '2026-01-19 21:30:00'),
(25, 1, 14, NULL, NULL, NULL, NULL, '經典奶油培根義大利麵', 'img/recipes/25/cover.png', '羅馬經典的家常風味。不使用過多調味，僅憑蛋黃、熟成起司與培根的油脂乳化成濃厚醬汁。這道料理的靈魂在於精準的餘溫掌控，交織出絲滑且充滿黑胡椒香氣的極致口感。', 1, '00:20:00', '3.5', 0, '803.24', '42.95', '35.10', '76.82', 0, '2026-01-19 22:00:00', '2026-01-19 22:00:00'),
(26, 1, 15, NULL, NULL, NULL, NULL, '台式三杯雞', 'img/recipes/26/cover.png', '最正宗的台式熱炒風味。透過黑麻油低溫煸香老薑，再以醬油、米酒與砂糖黃金比例燉煮，最後利用餘溫逼出九層塔的強烈香氣。色澤油亮、鹹甜下飯。', 2, '00:30:00', '2.5', 0, '879.85', '60.70', '54.31', '28.63', 0, '2026-01-19 23:00:00', '2026-01-19 23:00:00'),
(27, 1, 16, NULL, NULL, NULL, NULL, '家傳紅燒肉', 'img/recipes/27/cover.png', '濃油赤醬的傳承美味。選用肥瘦相間的五花肉，透過傳統的炒糖色技術，讓肉塊呈現誘人的深琥珀色。經過長時間小火慢燉，油脂完美釋放，口感軟糯、醇厚而不膩。', 4, '01:10:00', '3.0', 0, '3204.00', '297.11', '143.25', '244.66', 0, '2026-01-20 09:00:00', '2026-01-20 09:00:00'),
(28, 1, 17, NULL, NULL, NULL, NULL, '清蒸蔥油鱸魚', 'img/recipes/28/cover.png', '廣東餐館最常見的經典大菜。利用大火蒸氣快速鎖住鱸魚的鮮美，最後淋上燒熱的蔥油，讓鮮香層次瞬間爆發，魚肉口感如絲緞般滑嫩。', 2, '00:20:00', '2.0', 0, '796.45', '96.31', '40.16', '8.29', 0, '2026-01-20 10:30:00', '2026-01-20 10:30:00'),
(29, 1, 18, NULL, NULL, NULL, NULL, '麻婆豆腐燒', 'img/recipes/29/cover.png', '川菜中知名度最高的一道家常料理。透過豆瓣醬炒出的紅油賦予豆腐深邃的辣味，搭配花椒的麻與牛肉般的絞肉焦香，口感滑嫩且極度開胃下飯。', 2, '00:25:00', '3.0', 0, '1290.55', '126.48', '44.70', '131.25', 0, '2026-01-20 14:00:00', '2026-01-20 14:00:00'),
(30, 1, 19, NULL, NULL, NULL, NULL, '客家小炒', 'img/recipes/30/cover.png', '正宗台式客家風味。這道料理的靈魂在於將五花肉與豆乾煸至焦香，搭配泡發魷魚的鮮甜與芹菜的清脆，鹹鮮帶甜且帶有強烈的鑊氣，是極致的下酒與下飯菜。', 2, '00:40:00', '3.0', 0, '1232.10', '106.93', '78.45', '20.24', 0, '2026-01-20 15:30:00', '2026-01-20 15:30:00'),
(31, 1, 20, NULL, NULL, NULL, NULL, '藥膳麻油雞湯', 'img/recipes/31/cover.png', '暖心暖胃的台式經典補湯。選用優質黑麻油低溫煸炒老薑至乾燥收縮，激發出溫潤香氣，搭配全米酒或半水酒燉煮出的甘甜雞湯，是寒冬裡最幸福的滋味。', 3, '00:35:00', '2.5', 0, '2687.15', '218.48', '106.47', '172.20', 0, '2026-01-20 19:00:00', '2026-01-20 19:00:00'),
(32, 1, NULL, NULL, NULL, NULL, NULL, '經典日式舒芙蕾鬆餅', 'img/recipes/32/cover.png', '如雲朵般蓬鬆柔軟。這道日式排隊名店的靈魂在於細膩的蛋白霜與精準的鍋內蒸烤，每一口都充滿濃郁蛋香與香草香氣，入口即化，是午後最奢華的享受。', 1, '00:30:00', '4.0', 0, '337.00', '17.00', '18.00', '27.00', 0, '2026-01-20 20:00:00', '2026-01-20 20:00:00'),
(33, 1, NULL, NULL, NULL, NULL, NULL, '焦糖牛奶雞蛋布丁', 'img/recipes/33/cover.png', '大人小孩都愛的療癒甜點。底層是帶著微苦香氣的深琥珀色焦糖，上層則是質地細緻、如絲綢般滑順的雞蛋布丁。透過過篩與低溫水浴烘烤，徹底消除氣泡，達到完美的入口即化感。', 4, '01:00:00', '3.0', 0, '1401.00', '85.00', '70.00', '109.00', 0, '2026-01-20 21:00:00', '2026-01-20 21:00:00'),
(34, 1, NULL, NULL, NULL, NULL, NULL, '蜂蜜奶油厚片吐司', 'img/recipes/34/cover.png', '簡單卻不簡單的極致美味。透過井字切痕讓濃郁的無鹽奶油滲透進厚實的麵包纖維中，高溫烘烤出酥脆的金黃外皮，最後淋上絲滑蜂蜜，甜鹹交織的經典滋味令人難以抗拒。', 1, '00:10:00', '1.0', 0, '397.00', '6.61', '19.40', '50.72', 0, '2026-01-20 20:30:00', '2026-01-20 20:30:00'),
(35, 1, NULL, NULL, NULL, NULL, NULL, '香草生乳奶酪', 'img/recipes/35/cover.png', '純淨且濃郁的白滑享受。以 1:1 的鮮奶與鮮奶油黃金比例調製，加入香草精勾勒出高雅香氣。每一口都能感受到絲絨般的生乳質感，是甜點菜單上最經典不敗的選擇。', 4, '04:20:00', '1.5', 0, '1489.00', '44.00', '124.00', '51.00', 0, '2026-01-20 21:30:00', '2026-01-20 21:30:00'),
(36, 1, NULL, NULL, NULL, NULL, NULL, '家常香蕉磅蛋糕', 'img/recipes/36/cover.png', '充滿熟成香蕉自然甜味的家常美味。透過傳統的磅蛋糕製作法（Creaming Method），將奶油打發至蓬鬆輕盈，烘烤出的蛋糕組織扎實且濕潤，是消耗過熟香蕉的最佳方案。', 6, '01:00:00', '2.5', 0, '1467.95', '23.54', '96.32', '139.52', 0, '2026-01-20 20:30:00', '2026-01-20 20:30:00'),
(37, 1, NULL, NULL, NULL, NULL, NULL, '蔓越莓燕麥餅乾', 'img/recipes/37/cover.png', '充滿嚼勁與穀物香氣的健康系甜點。這款餅乾結合了燕麥的質樸口感與蔓越莓乾的酸甜，使用黑糖能讓餅乾中心保持濕潤軟嚼，外層則帶著微脆，是下午茶的最佳伴侶。', 12, '00:30:00', '2.0', 0, '2652.78', '49.43', '99.02', '404.32', 0, '2026-01-20 21:00:00', '2026-01-20 21:00:00'),
(38, 1, NULL, NULL, NULL, NULL, NULL, '伯爵茶瑪德蓮', 'img/recipes/38/cover.png', '優雅的法式午茶經典。選用佛手柑香氣濃郁的伯爵茶葉，搭配溫潤的蜂蜜與香醇奶油。透過長時間靜置麵糊，使茶香與蛋奶完美融合，烘烤出擁有迷人金黃色澤與可愛凸肚臍的濕潤小蛋糕。', 6, '01:30:00', '3.0', 0, '1503.32', '21.45', '91.50', '152.79', 0, '2026-01-21 14:00:00', '2026-01-21 14:00:00'),
(39, 1, NULL, NULL, NULL, NULL, NULL, '楓糖核桃司康', 'img/recipes/39/cover.png', '道地的英式酥餅風味。利用冰奶油與麵粉搓出的粗砂質地，創造出司康特有的酥鬆口感。楓糖的優雅甜味與脆口核桃完美契合，是週末早午餐或下午茶的絕佳選擇。', 4, '00:45:00', '3.0', 0, '2229.00', '45.96', '111.02', '270.40', 0, '2026-01-21 15:30:00', '2026-01-21 15:30:00'),
(40, 1, NULL, NULL, NULL, NULL, NULL, '黑巧克力布朗尼', 'img/recipes/40/cover.png', '濃郁紮實的極致巧克力體驗。這款布朗尼擁有如生巧克力般的濕潤核心，表層帶著裂紋微脆。透過優質黑巧克力磚與無糖可可粉的雙重堆疊，呈現出微苦不膩、層次深邃的質感。', 9, '00:45:00', '2.0', 0, '3035.50', '38.16', '173.86', '350.87', 0, '2026-01-21 21:00:00', '2026-01-21 21:00:00'),
(41, 1, NULL, NULL, NULL, NULL, NULL, '法式經典可麗露', 'img/recipes/41/cover.png', '波爾多地區的傳奇甜點。外層擁有如巧克力般深褐色的酥脆焦糖殼，內裡卻是滑順、充滿孔洞的 Q 彈組織。這道甜點極其考驗耐心與火候，必須經過 24 小時的麵糊熟成，才能讓香草與蘭姆酒的香氣達到巔峰。', 12, '25:30:00', '4.5', 0, '2108.70', '32.13', '68.79', '324.02', 0, '2026-01-22 10:00:00', '2026-01-22 10:00:00'),
(42, 1, NULL, NULL, NULL, NULL, NULL, '法式經典檸檬塔', 'img/recipes/42/cover.png', '甜點店的永恆經典。完美的檸檬塔結合了充滿杏仁香氣的酥脆塔殼，以及酸爽清新、質地如絲綢般滑順的檸檬凝乳。透過精準的溫度控制與奶油乳化技術，呈現出酸甜平衡的極致美味。', 6, '02:30:00', '3.5', 0, '2773.90', '43.40', '172.49', '273.30', 0, '2026-01-22 14:00:00', '2026-01-22 14:00:00'),
(43, 1, NULL, NULL, NULL, NULL, NULL, '法式經典蒙布朗', 'img/recipes/43/cover.png', '以白朗峰命名的經典法式甜點。底層是入口即化的酥脆蛋白餅，核心包裹著輕盈的鮮奶油與一整顆糖漬栗子，外層覆蓋著如山脈般的細緻栗子奶油，最後灑上如殘雪般的糖粉，口感層次分明且優雅。', 6, '02:00:00', '4.0', 0, '1964.10', '21.91', '92.12', '256.61', 0, '2026-01-22 16:00:00', '2026-01-22 16:00:00'),
(44, 1, NULL, NULL, NULL, NULL, NULL, '日式水果三明治', 'img/recipes/44/cover.png', '風靡日本的經典甜點。選用質地柔軟、帶有奶香的生吐司，包裹著打發至結實的香甜鮮奶油與當季鮮果。透過精密的擺放設計與充分冷藏定型，切開後的橫切面如藝術品般迷人，口感輕盈不膩。', 2, '01:20:00', '2.0', 0, '1020.35', '14.68', '62.42', '105.27', 0, '2026-01-22 17:00:00', '2026-01-22 17:00:00'),
(45, 1, NULL, NULL, NULL, NULL, NULL, '藍莓優格果實杯', 'img/recipes/45/cover.png', '兼具高顏值與營養的輕食選擇。使用質地濃稠、蛋白質豐富的希臘優格作為基底，搭配酥脆燕麥片與新鮮多汁的藍莓，透過層次堆疊打造出豐富的咀嚼感，是健康早餐或午後點心的完美替代方案。', 1, '00:10:00', '1.0', 0, '385.68', '23.53', '12.23', '47.52', 0, '2026-01-22 17:30:00', '2026-01-22 17:30:00'),
(46, 1, NULL, NULL, NULL, NULL, NULL, '黑芝麻豆乳凍', 'img/recipes/46/cover.png', '兼具健康與濃郁滋味的日式風甜點。選用高品質黑芝麻粉搭配純淨無糖豆漿，透過低溫熬煮激發出深層的穀物香氣。質地介於布丁與奶酪之間，滑順Q彈，每一口都是滿滿的芝麻韻味。', 3, '04:30:00', '1.5', 0, '645.70', '23.81', '40.91', '51.18', 0, '2026-01-22 18:00:00', '2026-01-22 18:00:00'),
(47, 1, NULL, NULL, NULL, NULL, NULL, '全麥堅果小圓餅', 'img/recipes/47/cover.png', '純植物性的健康酥餅。捨棄了奶油與精緻砂糖，改以風味純淨的橄欖油與天然楓糖調味，搭配富含口感的烘烤核桃與杏仁，每一口都能品嚐到穀物的原始清香，是追求低負擔飲食的完美點心。', 4, '00:35:00', '1.5', 0, '1734.30', '38.32', '98.33', '194.79', 0, '2026-01-22 18:30:00', '2026-01-22 18:30:00'),
(48, 1, NULL, NULL, NULL, NULL, NULL, '微甜紅豆奶凍', 'img/recipes/48/cover.png', '充滿古早味的純粹滋味。手工慢火熬煮的蜜紅豆，保留了豆粒的飽滿與鬆軟質感，沉澱在絲滑濃郁的鮮奶凍底層。不需烤箱，透過簡單的冷凝法，讓奶香與豆香完美結合，是炎炎夏日或飯後最療癒的清爽點心。', 4, '13:00:00', '2.5', 0, '912.10', '40.18', '14.60', '160.62', 0, '2026-01-22 19:30:00', '2026-01-22 19:30:00'),
(49, 1, NULL, NULL, NULL, NULL, NULL, '家常韓式辣炒年糕', 'img/recipes/49/cover.png', '道地的韓國街頭國民美食。以富有嚼勁的年糕條配上鮮美的韓式魚板，裹滿甜辣適中的濃厚醬汁。透過魚高湯的底蘊與高麗菜的自然甜味，交織出層次豐富的火熱口感，是暖心又過癮的家常美味。', 2, '00:30:00', '2.0', 0, '1400.06', '53.24', '24.97', '227.44', 0, '2026-01-22 20:00:00', '2026-01-22 20:00:00'),
(50, 1, NULL, NULL, NULL, NULL, NULL, '經典韓式部隊鍋', 'img/recipes/50/cover.png', '融合美式食材與韓式靈魂的超人氣鍋物。將濃郁的韓式甜辣湯底，與午餐肉、起司、泡麵等經典配料一同燉煮。隨著起司緩緩融化包裹住Q彈的麵條，每一口都能感受到多層次的鹹香與滿足感，是多人聚餐的首選。', 3, '00:30:00', '2.0', 0, '2124.45', '90.27', '144.03', '97.50', 0, '2026-01-22 21:00:00', '2026-01-22 21:00:00'),
(51, 1, NULL, NULL, NULL, NULL, NULL, '靈魂泡菜豬肉豆腐鍋', 'img/recipes/51/cover.png', '這是一道充滿深度火氣的韓式靈魂料理。透過黑芝麻油低溫爆香，將熟成老泡菜的酸爽與豬五花的甘甜油脂充分融合。洗米水燉煮出的湯頭濃郁帶有層次，配上吸滿湯汁的滑嫩豆腐，每一口都是最道地的韓式風味。', 2, '00:25:00', '1.5', 0, '1054.80', '28.99', '96.95', '18.10', 0, '2026-01-23 11:30:00', '2026-01-23 11:30:00'),
(52, 1, NULL, NULL, NULL, NULL, NULL, '經典石鍋拌飯', 'img/recipes/52/cover.png', '視覺與味覺的雙重饗宴。五色蔬菜鋪滿在熱騰騰的白飯上，搭配香氣撲鼻的炒牛肉與特製甜辣拌飯醬。最吸引人之處在於石鍋高溫烤出的香脆鍋巴，與所有食材拌勻後，每一口都能品嚐到多層次的豐富口感。', 1, '00:40:00', '3.0', 0, '903.55', '36.10', '46.01', '85.05', 0, '2026-01-23 14:00:00', '2026-01-23 14:00:00'),
(53, 1, NULL, NULL, NULL, NULL, NULL, '韓式蜂蜜炸雞', 'img/recipes/53/cover.png', '大人小孩都無法抗拒的經典韓式美味。不同於辣味炸雞，蜂蜜奶油風味強調的是蒜香與蜜香的優雅結合。透過兩次油炸技術達到外皮極致酥脆，最後裹上充滿光澤的濃厚金黃醬汁，每一口都是鹹甜交織的誘惑。', 2, '00:45:00', '3.0', 0, '1900.06', '92.09', '102.04', '149.66', 0, '2026-01-23 15:00:00', '2026-01-23 15:00:00'),
(54, 1, NULL, NULL, NULL, NULL, NULL, '鮮菇枸杞紅棗雞湯', 'img/recipes/54/cover.png', '暖心滋補的家常好湯。選用彈牙的雞腿肉，搭配多種新鮮菇類帶出的自然鮮甜。透過乾香菇與紅棗燉煮出的深邃底蘊，最後點綴飽滿枸杞，湯頭清澈甘甜而不油膩，是四季皆宜的營養膳食。', 3, '01:00:00', '1.5', 0, '854.40', '84.81', '33.31', '46.71', 0, '2026-01-23 16:30:00', '2026-01-23 16:30:00'),
(55, 1, NULL, NULL, NULL, NULL, NULL, '家常排骨玉米蘿蔔湯', 'img/recipes/55/cover.png', '最樸實卻最雋永的台式家常湯品。透過慢火燉煮，將排骨的肉香、白蘿蔔的清甜與玉米的濃厚果糖完美融合。不需要多餘的調味料，僅靠食材間的鮮味堆疊，就能煮出一鍋清澈見底、溫潤入心的鮮美高湯。', 4, '01:00:00', '1.5', 0, '1054.65', '61.93', '62.95', '70.16', 0, '2026-01-23 13:00:00', '2026-01-23 13:00:00'),
(56, 1, NULL, NULL, NULL, NULL, NULL, '經典家常酸辣湯', 'img/recipes/56/cover.png', '中式麵食館的靈魂伴侶。這道湯品講究「酸、辣、鹹、鮮」的層次平衡，透過細緻的刀工將食材化為絲滑口感。掌握先勾芡後淋蛋液的秘訣，讓湯頭濃郁透亮，最後注入大量的烏醋與白胡椒，熱氣騰騰中散發迷人的辛香與酸度。', 4, '00:30:00', '2.5', 0, '1136.75', '85.59', '47.43', '54.13', 0, '2026-01-23 14:00:00', '2026-01-23 14:00:00'),
(57, 1, NULL, NULL, NULL, NULL, NULL, '剝皮辣椒蛤蜊雞湯', 'img/recipes/57/cover.png', '這是一款兼具甘、甜、辣、鮮的層次系湯品。選用醃漬入味的剝皮辣椒，其特有的微辣發酵湯底與蛤蜊的海洋鮮甜完美融合，不但能勾勒出雞腿肉的軟嫩，更是一道極佳的暖胃滋補聖品。', 3, '00:50:00', '2.0', 0, '975.05', '97.87', '42.33', '37.90', 0, '2026-01-23 15:30:00', '2026-01-23 15:30:00'),
(58, 1, NULL, NULL, NULL, NULL, NULL, '番茄排骨蛋花湯', 'img/recipes/58/cover.png', '色彩明亮、酸甜開胃的暖心湯品。不同於一般的蛋花湯，這道料理加入了燉至軟嫩的豬小排，增加湯頭的厚度與肉香。透過先炒後煮的技巧，讓番茄的鮮紅茄紅素與天然酸香完美融入湯中，最後以輕柔蛋花收尾，口感豐富且清爽不膩。', 4, '00:55:00', '1.5', 0, '937.34', '71.67', '67.19', '14.14', 0, '2026-01-23 16:00:00', '2026-01-23 16:00:00'),
(59, 1, NULL, NULL, NULL, NULL, NULL, '經典川味紅燒牛肉麵', 'img/recipes/59/cover.png', '台灣國民美食的巔峰之作。選用帶筋的牛腱肉，經過慢火燉煮後口感 Q 彈軟嫩，入口即化。湯頭以豆瓣醬爆香為基底，結合紅白蘿蔔的清甜與八角的辛香，熬出濃郁紅亮的靈魂湯底，搭配勁道的麵條，每一口都是深厚的滿足感。', 4, '02:30:00', '4.0', 0, '3247.81', '233.04', '68.79', '357.41', 0, '2026-01-23 18:00:00', '2026-01-23 18:00:00'),
(60, 1, NULL, NULL, NULL, NULL, NULL, '經典墨西哥牛肉塔可', 'img/recipes/60/cover.png', '充滿南美熱情的街頭美食。選用香氣十足的玉米餅皮，包覆著以孜然與紅椒粉炒製的惹味牛絞肉，搭配清爽的生菜絲、多汁的番茄與鮮製莎莎醬，最後抹上酸奶油與擠上綠檸檬汁，鹹甜酸辣多重滋味在口中爆發。', 2, '00:25:00', '2.0', 0, '1053.25', '58.00', '60.29', '79.34', 0, '2026-01-23 21:00:00', '2026-01-23 21:00:00'),
(61, 1, NULL, NULL, NULL, NULL, NULL, '泰式冬蔭功海鮮湯', 'img/recipes/61/cover.png', '泰國最具代表性的國寶級湯品。以新鮮大虎蝦頭煸炒出的蝦油為底，熬煮香茅、南薑與檸檬葉的清新辛香。結合了海鮮的鮮甜、檸檬的果酸與泰式辣椒的溫潤甜辣，最後加入椰奶勾勒出絲滑圓潤的口感，酸辣開胃，層次極其豐富。', 2, '00:40:00', '3.5', 0, '774.44', '81.77', '30.31', '54.72', 0, '2026-01-23 21:15:00', '2026-01-23 21:15:00'),
(62, 1, NULL, NULL, NULL, NULL, NULL, '經典凱薩雞肉沙拉', 'img/recipes/62/cover.png', '舉世聞名的沙拉之王。這道料理的靈魂在於手工鮮製的凱薩醬，融合了鯷魚的鹹鮮、蒜香與帕馬森起司的濃郁風味。搭配爽脆的蘿蔓生菜與香酥麵包丁，再鋪上低脂嫩煎雞胸肉，口感層次極其豐富，是輕食與前菜的不二之選。', 2, '00:30:00', '2.5', 0, '898.66', '53.55', '62.72', '31.89', 0, '2026-01-23 22:00:00', '2026-01-23 22:00:00'),
(63, 1, NULL, NULL, NULL, NULL, NULL, '香煎肋眼牛排佐食蔬', 'img/recipes/63/cover.png', '享受餐廳級的高級排餐。這道料理採用經典的法式淋油技術 (Basting)，利用融化的奶油、大蒜與新鮮迷迭香不斷澆淋，賦予牛排深層的香草乳香。搭配利用餘油煸炒的清甜蘆筍與番茄，不僅解膩更能襯托出牛肉的鮮甜多汁。', 1, '00:25:00', '3.0', 0, '1102.16', '51.47', '96.80', '11.97', 0, '2026-01-27 19:00:00', '2026-01-27 19:00:00'),
(64, 1, NULL, NULL, NULL, NULL, NULL, '越式鮮蝦生春捲', 'img/recipes/64/cover.png', '風靡全球的越式健康輕食。利用半透明且帶有彈性的米紙，包裹著鮮甜的熟大蝦、柔嫩豬肉片與香氣撲鼻的九層塔、薄荷葉。米線提供的飽足感與生菜的清脆交織，搭配特製的魚露檸檬沾醬，酸甜微辣，是夏日最舒心的開胃首選。', 2, '00:35:00', '2.5', 0, '1133.85', '84.34', '21.78', '149.21', 0, '2026-01-27 19:20:00', '2026-01-27 19:20:00'),
(65, 1, NULL, NULL, NULL, NULL, NULL, '地中海風情西班牙海鮮燉飯', 'img/recipes/65/cover.png', '西班牙餐桌上的華麗靈魂。選用昂貴的番紅花賦予米飯金黃色澤與獨特香氣，鋪滿鮮蝦、淡菜與透抽，利用寬口淺鍋燉煮，讓每一粒米都吸飽海鮮與高湯的精華。最迷人之處莫過於鍋底那層微焦酥脆的鍋巴 (Socarrat)，搭配鮮榨檸檬汁，展現極致的地中海鮮美。', 2, '00:50:00', '3.5', 0, '1226.55', '112.87', '13.11', '141.97', 0, '2026-01-27 19:30:00', '2026-01-27 19:30:00'),
(66, 1, NULL, NULL, NULL, NULL, NULL, '家傳鹹蛋黃瓜仔肉', 'img/recipes/66/cover.png', '最令人懷念的白飯殺手。利用醬瓜的甘甜與鹹蛋白的鹹鮮，完美提升豬絞肉的風味層次。透過「同方向攪拌」的技巧讓肉質 Q 彈不乾柴，最後嵌入油潤的鹹蛋黃一同蒸煮，湯汁拌飯更是一絕，是每個台灣家庭餐桌上的溫溫暖印記。', 3, '00:30:00', '1.5', 0, '977.36', '72.52', '70.40', '16.02', 0, '2026-01-27 19:45:00', '2026-01-27 19:45:00'),
(67, 1, NULL, NULL, NULL, NULL, NULL, '經典鮮紅俄式羅宋湯', 'img/recipes/67/cover.png', '俄式料理的靈魂。這道湯品以牛腩慢火熬出的醇厚基底為核心，加入甜菜根賦予湯頭如紅寶石般的迷人色澤。大量的鮮甜蔬菜經長時間燉煮，與月桂葉的辛香融合，最後拌入一抹酸奶油，交織出絲滑且微酸的異國風味。', 4, '01:30:00', '3.0', 0, '1385.64', '56.60', '97.00', '78.37', 0, '2026-01-27 20:00:00', '2026-01-27 20:00:00'),
(68, 1, NULL, NULL, NULL, NULL, NULL, '職人級日式鮮蝦天婦羅', 'img/recipes/68/cover.png', '完美的日式炸物美學。掌握「冰鎮麵衣」與「精準油溫」兩大關鍵，讓外皮呈現金黃薄透、絲毫不油膩的輕盈脆感。嚴選大虎蝦透過特殊斷筋處理，炸出筆直挺拔的視覺美感，搭配特製的天婦羅蘿蔔泥沾醬，讓每一口海鮮與時蔬都呈現最純粹的甘甜。', 2, '00:40:00', '4.0', 0, '5166.80', '71.99', '504.93', '105.68', 0, '2026-01-27 20:30:00', '2026-01-27 20:30:00'),
(69, 1, NULL, NULL, NULL, NULL, NULL, '古早味手切台式滷肉飯', 'img/recipes/69/cover.png', '台灣最具代表性的靈魂小吃。嚴選肥瘦勻稱的五花肉，堅持以手切條狀保留口感，經過乾鍋煸炒逼出多餘油脂，再與大量的油蔥酥、五香粉慢火細燉。熬煮出濃稠發亮的焦糖色醬汁，每一口都充滿了厚實的肉香與膠質，配上一片鹹甜解膩的黃蘿蔔，是無可取代的家鄉味。', 4, '01:45:00', '3.0', 0, '3294.40', '111.76', '180.14', '283.69', 0, '2026-01-27 21:00:00', '2026-01-27 21:00:00'),
(70, 1, NULL, NULL, NULL, NULL, NULL, '經典夜市風味蚵仔煎', 'img/recipes/70/cover.png', '台灣夜市最具代表性的傳奇小吃。嚴選肥美飽滿的鮮蚵，搭配精準比例調製的半透明粉漿，煎至邊緣焦香酥脆、中心 Q 彈滑順。加入雞蛋的香氣與小白菜的清脆，最後淋上由海山醬與甜辣醬特製而成的粉紅醬汁，酸甜回甘，完美重現街頭經典美味。', 1, '00:20:00', '3.0', 0, '421.50', '15.14', '6.66', '74.93', 0, '2026-01-27 21:30:00', '2026-01-27 21:30:00'),
(71, 2, NULL, 1, NULL, '創意蒜香蜂蜜風味', '低溫熬製蒜油搭配清甜蜂蜜，打造驚喜的紐約風甜鹹層次。', '經典瑪格麗特披薩', 'img/recipes/71/cover.png', '經典瑪格麗特的華麗轉身。傳承了紅白綠的經典配色，透過自製蒜香橄欖油大幅提升香氣基準，出爐後點綴的琥珀色蜂蜜與新鮮羅勒完美契合，是一款完美融合傳統與創新的甜鹹味覺饗宴。', 2, '01:45:00', '3.5', 0, '1651.20', '62.17', '61.85', '212.74', 0, '2026-01-27 21:00:00', '2026-01-27 21:00:00'),
(72, 3, NULL, 1, NULL, '極致松露布拉塔升級版', '奢華松露醬底搭配整顆布拉塔起司，切開流出濃郁奶香與森林氣息。', '經典瑪格麗特披薩', 'img/recipes/72/cover.png', '經典瑪格麗特的奢華進化版。以鮮甜番茄糊為基底，出爐後放上整顆圓潤的布拉塔起司，切開後流心的鮮奶油與黑松露醬的森林氣息交織。紅白綠的視覺之上，疊加了松露的深邃與布拉塔的醇厚，是極致的味覺體驗。', 2, '01:30:00', '3.5', 0, '1444.25', '61.84', '45.07', '196.82', 0, '2026-01-27 21:30:00', '2026-01-27 21:30:00'),
(73, 4, NULL, 1, NULL, '辛辣肉食主義改編', '薩拉米肉香交織墨西哥椒與靈魂辣油，獻給嗜辣者的野性風味。', '經典瑪格麗特披薩', 'img/recipes/73/cover.png', '瑪格麗特的野性進化版。保留了番茄與起司的核心靈魂，疊加了義式薩拉米香腸的熟成肉香，以及墨西哥辣椒片（Jalapeños）的辛辣刺激。這款披薩不僅擁有經典的酥脆餅皮，每一口更有著油脂爆發與酸辣交織的極致快感。', 2, '01:30:00', '3.0', 0, '1654.05', '74.54', '62.55', '197.61', 0, '2026-01-27 21:45:00', '2026-01-27 21:45:00'),
(74, 5, NULL, 2, NULL, '流沙鹹蛋黃驚喜版', '抹茶熔岩內藏金黃鹹蛋黃流沙，雙色流心視覺震撼，鹹甜不膩。', '抹茶熔岩蛋糕', 'img/recipes/74/cover.png', '驚喜不斷的視覺系甜點。當叉子切開翠綠的抹茶蛋糕體，湧出的不僅是濃郁的抹茶熔岩，更夾雜著金黃油潤的鹹蛋黃流沙。鹹甜交織的獨特風味，搭配外層鬆軟的布朗尼口感，是將經典抹茶熔岩推向極致的改編之作。', 2, '00:55:00', '4.0', 0, '1529.20', '35.09', '102.95', '117.22', 0, '2026-01-27 22:00:00', '2026-01-27 22:00:00'),
(75, 6, NULL, 2, NULL, '法式莓果起司層次版', '馬斯卡彭起司增加絲滑乳香，點綴藍莓爆漿果酸，優雅的大人味。', '抹茶熔岩蛋糕', 'img/recipes/75/cover.png', '一場優雅的法式抹茶慶典。翠綠柔軟的抹茶蛋糕體中，隱藏著由馬斯卡彭起司與新鮮藍莓構成的柔軟核心。起司的醇厚乳香軟化了抹茶的稜角，酸甜莓果則讓每一口都顯得輕盈不膩，是味覺與視覺的雙重饗宴。', 2, '00:45:00', '3.0', 0, '1574.25', '28.81', '106.20', '129.70', 0, '2026-01-27 22:15:00', '2026-01-27 22:15:00'),
(76, 7, NULL, 2, NULL, '栗香蘭姆大人味', '融入蒙布朗概念，蘭姆酒香栗子泥搭配微苦抹茶，酒漬餘韻悠長。', '抹茶熔岩蛋糕', 'img/recipes/76/cover.png', '當東方的抹茶遇上法式的栗子。濃郁的抹茶蛋糕包裹著充滿蘭姆酒香的栗子流心，切開後緩緩流出的深邃內餡，不僅有著白巧克力的甜，更有著栗子特有的沈穩香氣與酒漬餘韻，是味覺上的極致享受。', 2, '00:45:00', '3.5', 0, '1474.05', '27.90', '84.05', '149.03', 0, '2026-01-27 22:30:00', '2026-01-27 22:30:00'),
(77, 8, NULL, 3, NULL, '熱帶果香創意改編', '以金鑽鳳梨果酸模擬荔枝味，搭配脆口腰果，口感明亮清爽。', '四川宮保雞丁', 'img/recipes/77/cover.png', '經典川菜的果感進化。保留了宮保雞丁靈魂的糊辣香氣，創新加入金鑽鳳梨塊一同翻炒。鳳梨受熱後滲出的微酸果汁，與秘製醬汁完美乳化，包裹在滑嫩的雞丁上，搭配酥脆腰果，是一道讓人食慾大開的創意熱炒。', 2, '00:40:00', '3.0', 0, '843.80', '67.89', '43.03', '45.95', 0, '2026-01-27 22:45:00', '2026-01-27 22:45:00'),
(78, 2, NULL, 3, NULL, '酥脆黏口蜂蜜掛汁版', '地瓜粉酥炸外皮掛上濃稠蜂蜜檸檬醬，打造鹽酥雞般的極致脆感。', '四川宮保雞丁', 'img/recipes/78/cover.png', '一場台式炸雞與川式宮保的華麗聯姻。雞丁披上粗顆粒的金黃地瓜粉外衣，大火酥炸後鎖住肉汁，再投入由蜂蜜、乾辣椒與花椒熬製的特製亮面醬汁中快速翻裹。極致的酥脆外殼掛上甜辣交織的蜜汁，是下酒與配飯的終極武器。', 2, '00:45:00', '3.5', 0, '1106.15', '67.55', '40.23', '119.23', 0, '2026-01-27 22:50:00', '2026-01-27 22:50:00'),
(79, 3, NULL, 3, NULL, '川式蔬食老皮嫩肉版', '豆腐煎出「老皮」褶皺以吸飽烏醋醬汁，層次豐富的蔬食新選擇。', '四川宮保雞丁', 'img/recipes/79/cover.png', '宮保雞丁的蔬食完美變奏。將板豆腐慢火煎至六面金黃起皺，形成如同「老皮」般的紋理，隨即投入由花椒、乾辣椒與烏醋調製的經典宮保醬汁中。豆腐孔洞吸滿了酸甜微辣的精華，搭配香脆花生，展現出不輸肉類料理的強大氣場。', 2, '00:40:00', '2.5', 0, '809.90', '61.62', '40.19', '54.69', 0, '2026-01-27 22:55:00', '2026-01-27 22:55:00');

-- --------------------------------------------------------

--
-- 資料表結構 `recipe_comments`
--

CREATE TABLE `recipe_comments` (
  `comment_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_at` datetime NOT NULL,
  `is_display` tinyint(1) DEFAULT '1',
  `like_count` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `recipe_comments`
--

INSERT INTO `recipe_comments` (`comment_id`, `recipe_id`, `user_id`, `comment_text`, `comment_at`, `is_display`, `like_count`) VALUES
(1, 1, 5, '餅皮又脆又香，番茄醬汁比例完美！', '2024-01-01 10:00:00', 1, 12),
(2, 1, 3, '這道經典瑪格麗特披薩是我吃過最好做的食譜。', '2024-01-02 12:30:00', 1, 8),
(3, 1, 8, '羅勒葉一定要最後放，香味才留得住。', '2024-01-03 18:15:00', 1, 5),
(4, 2, 2, '這張成品照跟我之前在國外網站看到的幾乎一模一樣，請問作者有經過授權嗎？這種搬運行為不太好吧。', '2024-01-05 14:00:00', 1, 25),
(5, 2, 6, '照著步驟做真的沒失敗，這甜點招待朋友超有面子。', '2024-01-06 15:20:00', 1, 14),
(6, 2, 4, '建議烤箱溫度要控制好，不然裡面會太熟變固體。', '2024-01-07 11:10:00', 1, 21),
(7, 2, 7, '太甜了，下次會減少一點糖量。', '2024-01-08 09:45:00', 1, 2),
(8, 3, 5, '這道宮保雞丁非常下飯，辣度剛剛好。', '2024-01-10 20:00:00', 1, 17),
(9, 3, 2, '雞胸肉竟然可以處理得這麼嫩，太強了。', '2024-01-11 19:30:00', 1, 23),
(10, 3, 8, '我多加了些花生米，口感層次更豐富。', '2024-01-12 12:00:00', 1, 9),
(11, 4, 4, '松露味真的超高級，感覺像在餐廳吃飯。', '2024-01-15 13:00:00', 1, 28),
(12, 4, 3, '推薦大家一個可以邊煮飯邊領福利的好地方，點擊連結 [https://link.test] 領取 500 元購物金，名額有限！', '2024-01-16 21:10:00', 1, 11),
(13, 4, 6, '野菇炒香是重點，謝謝分享祕訣！', '2024-01-17 12:45:00', 1, 6),
(14, 4, 5, '雖然熱量高，但真的停不下來。', '2024-01-18 19:00:00', 1, 4),
(15, 5, 7, '椰奶讓辣味變得很順口，配泰國米超讚。', '2024-01-20 18:30:00', 1, 19),
(16, 5, 2, '青咖哩醬我是自己買現成的，照這食譜煮依然好喝。', '2024-01-21 17:20:00', 1, 3),
(17, 5, 8, '雞腿肉煮得很入味，這道菜全家人都愛。', '2024-01-22 12:15:00', 1, 22),
(18, 6, 4, '荷蘭醬的比例抓得很準，不會太膩。', '2024-01-25 08:30:00', 1, 15),
(19, 6, 3, '水波蛋切開的那一瞬間太療癒了。', '2024-01-26 09:00:00', 1, 27),
(20, 6, 6, '早午餐就靠這一道征服小孩的胃了。', '2024-01-27 10:45:00', 1, 13),
(21, 7, 2, '湯頭真的要熬很久，但成果非常值得。', '2024-02-01 22:00:00', 1, 20),
(22, 7, 5, '叉燒肉入口即化，這滷汁配方太厲害了。', '2024-02-02 21:30:00', 1, 24),
(23, 7, 7, '在家也能吃到專業拉麵店的水準！', '2024-02-03 12:00:00', 1, 16),
(24, 8, 8, '沒想到自製鷹嘴豆泥這麼簡單，口感好綿密。', '2024-02-05 14:00:00', 1, 7),
(25, 8, 3, '配上口袋餅真的很健康，是減脂期的好夥伴。', '2024-02-06 15:00:00', 1, 11),
(26, 8, 4, '橄欖油多加一點會更香喔！', '2024-02-07 10:30:00', 1, 0),
(27, 9, 6, '洋蔥一定要炒到焦糖化才有靈魂。', '2024-02-10 18:00:00', 1, 21),
(28, 9, 2, '法式長棍麵包加起司後再烤一下簡直完美。', '2024-02-11 19:15:00', 1, 14),
(29, 9, 5, '冬天喝這碗湯真的好暖胃。', '2024-02-12 20:30:00', 1, 10),
(30, 10, 7, '大蝦的蒜香味很足，檸檬去腥效果很好。', '2024-02-15 11:00:00', 1, 18),
(31, 10, 8, '很適合當派對開胃菜，大家都搶著吃。', '2024-02-16 12:40:00', 1, 5),
(32, 10, 3, '蝦子一定要挑新鮮的，口感才會彈牙。', '2024-02-17 15:20:00', 1, 12),
(33, 11, 4, '舒肥後的雞胸肉一點都不柴，超嫩！', '2024-02-20 12:00:00', 1, 26),
(34, 11, 6, '藜麥飯很有嚼勁，飽足感十足。', '2024-02-21 13:30:00', 1, 8),
(35, 11, 2, '健身人的救星食譜，推薦給大家。', '2024-02-22 18:50:00', 1, 15),
(36, 12, 5, '鮭魚煎得焦香帶嫩，配糙米飯很清爽。', '2024-02-25 11:30:00', 1, 17),
(37, 12, 7, '便當菜色很豐富，下次想試試看換成藜麥。', '2024-02-26 12:20:00', 1, 3),
(38, 12, 8, '帶去辦公室當午餐剛剛好，冷了也好吃。', '2024-02-27 14:10:00', 1, 9),
(39, 13, 3, '蒜香味很濃，毛豆加在裡面意外地搭。', '2024-03-01 19:00:00', 1, 6),
(40, 13, 4, '豬排很軟嫩，這道菜備餐非常快。', '2024-03-02 20:30:00', 1, 11),
(41, 13, 6, '簡單又美味的家常菜，給讚！', '2024-03-03 12:15:00', 1, 4),
(42, 14, 2, '豆腐讓漢堡排變得好輕盈，熱量負擔少很多。', '2024-03-05 18:30:00', 1, 13),
(43, 14, 5, '野菇醬汁是精華，讓整道菜高級了起來。', '2024-03-06 19:40:00', 1, 19),
(44, 14, 7, '雖然是蔬食為主的漢堡，但吃起來很滿足。', '2024-03-07 12:00:00', 1, 2),
(45, 15, 8, '紙包魚完整保留了魚的鮮味，肉質超軟。', '2024-03-10 11:00:00', 1, 25),
(46, 15, 3, '檸檬和香料的味道滲透進去，真的非常清爽。', '2024-03-11 12:50:00', 1, 10),
(47, 15, 4, '這道做法很簡單，懶人必學！', '2024-03-12 18:10:00', 1, 7),
(48, 16, 6, '洋蔥甜味充分融入牛肉中，真的很好吃。', '2024-03-15 12:30:00', 1, 22),
(49, 16, 2, '拌入生蛋黃後口感更滑順了。', '2024-03-16 13:40:00', 1, 16),
(50, 16, 5, '這道牛丼完勝外面的連鎖店。', '2024-03-17 19:20:00', 1, 8),
(51, 17, 7, '泡菜的酸度跟豬肉結合得非常好，超級開胃。', '2024-03-20 20:00:00', 1, 18),
(52, 17, 8, '我最後加了一點芝麻，香味更濃了。', '2024-03-21 18:30:00', 1, 5),
(53, 17, 3, '喜歡辣的人一定要多加一點辣椒粉。', '2024-03-22 11:15:00', 1, 12),
(54, 18, 4, '北海道咖哩就是有一種獨特的甜味 and 濃郁感。', '2024-03-25 12:45:00', 1, 20),
(55, 18, 6, '加了馬鈴薯和紅蘿蔔一起燉，真的很有料。', '2024-03-26 19:00:00', 1, 14),
(56, 18, 2, '適合全家大小一起吃的口味。', '2024-03-27 10:30:00', 1, 3),
(57, 19, 5, '薑汁的微辣加上味增的鹹香，這道菜無敵。', '2024-04-01 12:20:00', 1, 27),
(58, 19, 7, '豬肉片一定要選帶點油脂的才會Q彈。', '2024-04-02 18:40:00', 1, 9),
(59, 19, 8, '快速上手又好吃的經典日式料理。', '2024-04-03 21:10:00', 1, 5),
(60, 20, 3, '這食譜寫得不太專業，感覺分享的人根本沒有實測過，照著做完全失敗，真的不推薦大家浪費食材。', '2024-04-05 13:00:00', 1, 21),
(61, 20, 4, '簡單煎一下就很好吃，魚皮酥脆是關鍵。', '2024-04-06 12:30:00', 1, 15),
(62, 20, 6, '這道配白飯真的可以吃兩碗。', '2024-04-07 19:15:00', 1, 28);

-- --------------------------------------------------------

--
-- 資料表結構 `recipe_gallery`
--

CREATE TABLE `recipe_gallery` (
  `gallery_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `gallery_text` text,
  `upload_at` datetime NOT NULL,
  `gallery_url` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 傾印資料表的資料 `recipe_gallery`
--

INSERT INTO `recipe_gallery` (`gallery_id`, `recipe_id`, `user_id`, `gallery_text`, `upload_at`, `gallery_url`) VALUES
(1, 1, 5, '經典瑪格麗特披薩，餅皮酥脆，羅勒葉的香氣真的畫龍點睛！', '2026-01-17 10:30:00', 'img/social/gallery/1/1.jpg'),
(2, 1, 2, '換個角度拍瑪格麗特披薩，牽絲的起司看起來太誘人了。', '2026-01-17 11:15:00', 'img/social/gallery/1/2.jpg'),
(3, 1, 8, '週末午餐的披薩派對，自製的瑪格麗特就是香。', '2026-01-17 12:00:00', 'img/social/gallery/1/3.jpg'),
(4, 2, 4, '抹茶熔岩蛋糕成功爆漿！抹茶味超級濃厚，微苦不膩。', '2026-01-17 13:20:00', 'img/social/gallery/2/1.jpg'),
(5, 2, 7, '這圖是我網路抓的，這食譜做的真爛，浪費我時間！', '2026-01-17 13:45:00', 'img/social/gallery/2/2.jpg'),
(6, 3, 3, '四川宮保雞丁，火候掌握得剛好，雞肉鮮嫩多汁。', '2026-01-18 10:00:00', 'img/social/gallery/3/1.jpg'),
(7, 3, 6, '花生米一定要最後放才酥脆，這道宮保雞丁超下飯。', '2026-01-18 10:15:00', 'img/social/gallery/3/2.jpg'),
(8, 3, 2, '今天的晚餐主角，香辣過癮的四川口味。', '2026-01-18 10:30:00', 'img/social/gallery/3/3.jpg'),
(9, 3, 8, '特寫一下宮保雞丁的色澤，很有食慾吧！', '2026-01-18 10:45:00', 'img/social/gallery/3/4.jpg'),
(10, 4, 5, '奶油松露野菇寬麵，松露醬的味道一打開就散發出來了。', '2026-01-18 11:00:00', 'img/social/gallery/4/1.jpg'),
(11, 4, 4, '選用了新鮮野菇，跟奶油醬汁完美融合在寬麵上。', '2026-01-18 11:15:00', 'img/social/gallery/4/2.jpg'),
(12, 4, 7, '想天天吃松露？加 LINE: money999 帶你操作虛擬幣，月入百萬！', '2026-01-18 11:30:00', 'img/social/gallery/4/3.jpg'),
(13, 4, 3, '最後撒上現磨起司粉，松露寬麵層次感爆發。', '2026-01-18 11:45:00', 'img/social/gallery/4/4.jpg'),
(14, 5, 6, '泰式青咖哩雞，香蘭葉與椰奶的結合真的好道地。', '2026-01-18 12:00:00', 'img/social/gallery/5/1.jpg'),
(15, 5, 2, '稍微偏辣的青咖哩，拌在飯上可以連吃兩碗。', '2026-01-18 12:15:00', 'img/social/gallery/5/2.jpg'),
(16, 5, 8, '燉煮後的雞肉吸滿青咖哩醬汁，非常入味。', '2026-01-18 12:30:00', 'img/social/gallery/5/3.jpg'),
(17, 6, 5, '經典班尼迪克蛋，水波蛋切開後的蛋液流出好療癒。', '2026-01-18 13:00:00', 'img/social/gallery/6/1.jpg'),
(18, 6, 4, '荷蘭醬比例調得很成功，濃稠度剛好。', '2026-01-18 13:15:00', 'img/social/gallery/6/2.jpg'),
(19, 6, 7, '完美的早午餐，班尼迪克蛋配上酥脆瑪芬。', '2026-01-18 13:30:00', 'img/social/gallery/6/3.jpg'),
(20, 7, 3, '濃厚豚骨叉燒拉麵，湯頭熬了超久，非常醇厚。', '2026-01-18 14:00:00', 'img/social/gallery/7/1.jpg'),
(21, 7, 6, '特製叉燒肉肥而不膩，入口即化。', '2026-01-18 14:15:00', 'img/social/gallery/7/2.jpg'),
(22, 8, 2, '經典自製鷹嘴豆泥，淋上橄欖油和紅椒粉，味道好清新。', '2026-01-18 15:00:00', 'img/social/gallery/8/1.jpg'),
(23, 8, 8, '拿來沾皮塔餅吃非常順口，健康的下午茶點心。', '2026-01-18 15:15:00', 'img/social/gallery/8/2.jpg'),
(24, 8, 5, '打得很細膩的鷹嘴豆泥，口感綿密。', '2026-01-18 15:30:00', 'img/social/gallery/8/3.jpg'),
(25, 8, 4, '教這什麼鬼？再發這種廢文我就去你家堵你，給我小心點！', '2026-01-18 15:45:00', 'img/social/gallery/8/4.jpg'),
(26, 9, 7, '法式洋蔥濃湯，洋蔥炒到焦糖化後的甜味太棒了。', '2026-01-18 16:00:00', 'img/social/gallery/9/1.png'),
(27, 9, 3, '鋪上法國麵包和起司進爐烤，濃湯精華都在這。', '2026-01-18 16:15:00', 'img/social/gallery/9/2.png'),
(28, 9, 6, '冷冷的冬天，來碗暖暖的洋蔥濃湯超幸福。', '2026-01-18 16:30:00', 'img/social/gallery/9/3.png'),
(29, 9, 2, '起司烤到微焦，配上濃郁洋蔥湯頭，絕配。', '2026-01-18 16:45:00', 'img/social/gallery/9/4.png'),
(30, 10, 8, '蒜香檸檬烤大蝦，檸檬的酸爽跟蝦子的甜味結合。', '2026-01-18 17:00:00', 'img/social/gallery/10/1.jpg'),
(31, 10, 5, '蒜末均勻鋪在蝦背上烤，香氣逼人。', '2026-01-18 17:15:00', 'img/social/gallery/10/2.jpg'),
(32, 10, 4, '簡單的調味就能帶出烤大蝦的鮮甜。', '2026-01-18 17:30:00', 'img/social/gallery/10/3.jpg'),
(33, 11, 7, '舒肥雞胸藜麥飯，低脂又高蛋白的健康組合。', '2026-01-18 18:00:00', 'img/social/gallery/11/1.png'),
(34, 11, 3, '舒肥後的雞胸肉真的不乾柴，藜麥飯很有口感。', '2026-01-18 18:15:00', 'img/social/gallery/11/2.png'),
(35, 11, 6, '健身後的餐點，藜麥飯跟雞胸肉補充滿滿能量。', '2026-01-18 18:30:00', 'img/social/gallery/11/3.png'),
(36, 11, 2, '色香味俱全的輕食餐盒，舒肥雞胸大推。', '2026-01-18 18:45:00', 'img/social/gallery/11/4.png'),
(37, 12, 8, '香煎鮭魚糙米便當，魚皮煎得金黃酥脆。', '2026-01-18 19:00:00', 'img/social/gallery/12/1.jpg'),
(38, 12, 5, '鮭魚油脂香氣十足，搭配健康糙米飯很有飽足感。', '2026-01-18 19:15:00', 'img/social/gallery/12/2.jpg'),
(39, 12, 4, '營養均衡的一餐，香煎鮭魚真的是百吃不厭。', '2026-01-18 19:30:00', 'img/social/gallery/12/3.png'),
(40, 13, 7, '蒜香毛豆嫩豬排，第一次嘗試這樣的搭配，驚艷的清爽。', '2026-01-18 20:00:00', 'img/social/gallery/13/1.png'),
(41, 13, 3, '豬排醃製得很入味，配上蒜香毛豆增加口感。', '2026-01-18 20:15:00', 'img/social/gallery/13/2.jpg'),
(42, 13, 6, '這道蒜香豬排很適合當家常主菜。', '2026-01-18 20:30:00', 'img/social/gallery/13/3.jpg'),
(43, 13, 2, '毛豆的甜跟蒜香完美中和了豬排的厚重感。', '2026-01-18 20:45:00', 'img/social/gallery/13/4.png'),
(44, 14, 8, '豆腐漢堡排佐野菇，蔬食者的極致享受。', '2026-01-18 21:00:00', 'img/social/gallery/14/1.png'),
(45, 14, 5, '豆腐排做得很紮實，野菇醬汁鮮甜濃郁。', '2026-01-18 21:15:00', 'img/social/gallery/14/2.jpg'),
(46, 15, 4, '檸檬紙包魚片，鎖住了魚肉所有的鮮甜水分。', '2026-01-19 09:00:00', 'img/social/gallery/15/1.png'),
(47, 15, 7, '打開紙包那一刻香氣噴發，檸檬味清新解膩。', '2026-01-19 09:15:00', 'img/social/gallery/15/2.png'),
(48, 15, 3, '無油烹飪的極致，紙包魚片健康又美味。', '2026-01-19 09:30:00', 'img/social/gallery/15/3.png'),
(49, 16, 6, '日式壽喜燒牛丼，蛋黃液裹在肥美牛肉片上太邪惡了。', '2026-01-19 10:00:00', 'img/social/gallery/16/1.png'),
(50, 16, 2, '鹹甜適中的壽喜燒醬汁，牛丼白飯殺手。', '2026-01-19 10:15:00', 'img/social/gallery/16/2.png'),
(51, 16, 8, '洋蔥煮到透亮吸滿醬汁，牛丼就是要這樣吃。', '2026-01-19 10:30:00', 'img/social/gallery/16/3.jpg'),
(52, 16, 5, '自製豪華版牛丼，肉片疊得跟山一樣高。', '2026-01-19 10:45:00', 'img/social/gallery/16/4.png'),
(53, 16, 4, '壽喜燒牛丼特寫，這肉質色澤太夢幻。', '2026-01-19 11:00:00', 'img/social/gallery/16/5.png'),
(54, 17, 7, '韓式泡菜炒豬肉，酸辣夠味，配韓劇剛好。', '2026-01-19 12:00:00', 'img/social/gallery/17/1.png'),
(55, 17, 3, '泡菜炒出香氣後加入豬五花，肥肉部分焦香美味。', '2026-01-19 12:15:00', 'img/social/gallery/17/2.png'),
(56, 17, 6, '這道韓式炒豬肉不管是配飯還是包生菜都很讚。', '2026-01-19 12:30:00', 'img/social/gallery/17/3.png'),
(57, 17, 2, '濃郁的紅色醬汁，這就是道地的韓式口味。', '2026-01-19 12:45:00', 'img/social/gallery/17/4.png'),
(58, 18, 8, '北海道咖哩雞，湯底加了大量蔬菜泥，非常濃醇。', '2026-01-19 13:00:00', 'img/social/gallery/18/1.png'),
(59, 18, 5, '北海道風格就是溫潤，咖哩雞裡面的馬鈴薯軟爛綿密。', '2026-01-19 13:15:00', 'img/social/gallery/18/2.png'),
(60, 18, 4, '濃縮了蔬菜精華的北海道咖哩，口感特別豐富。', '2026-01-19 13:30:00', 'img/social/gallery/18/3.png'),
(61, 18, 7, '這道咖哩雞非常有家鄉味，熱氣騰騰很幸福。', '2026-01-19 13:45:00', 'img/social/gallery/18/4.png'),
(62, 19, 3, '味噌薑汁燒肉，味噌鹹香跟薑汁的微辣層次分明。', '2026-01-19 18:00:00', 'img/social/gallery/19/1.png'),
(63, 19, 6, '薑泥炒出香氣後加入味噌，燒肉瞬間風味升級。', '2026-01-19 18:15:00', 'img/social/gallery/19/2.png'),
(64, 19, 2, '日式家庭餐桌必備，味噌薑汁燒肉完美示範。', '2026-01-19 18:30:00', 'img/social/gallery/19/3.png'),
(65, 20, 8, '照燒鮭魚排，照燒醬汁收得乾乾亮亮的，色澤滿分。', '2026-01-19 19:00:00', 'img/social/gallery/20/1.jpg'),
(66, 20, 5, '魚肉中心剛好熟透，照燒風味帶點甜感非常好吃。', '2026-01-19 19:15:00', 'img/social/gallery/20/2.jpg');

-- --------------------------------------------------------

--
-- 資料表結構 `recipe_ingredients`
--

CREATE TABLE `recipe_ingredients` (
  `recipe_ingredient_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `unit_name` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `is_modified` tinyint(1) DEFAULT '0',
  `remark` text COLLATE utf8_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- 傾印資料表的資料 `recipe_ingredients`
--

INSERT INTO `recipe_ingredients` (`recipe_ingredient_id`, `recipe_id`, `ingredient_id`, `amount`, `unit_name`, `is_modified`, `remark`) VALUES
(1, 1, 390, '250.00', '克', 0, '中粉過篩後備用，可確保麵糰口感更細緻'),
(2, 1, 496, '3.00', '克', 0, ''),
(3, 1, 497, '150.00', '毫升', 0, '常溫水即可，若冬天可使用微溫水幫助發酵'),
(4, 1, 345, '10.00', '克', 0, ''),
(5, 1, 416, '2.00', '克', 0, ''),
(6, 1, 242, '125.00', '克', 0, '置於室溫完全軟化，直到手指可輕鬆壓下的程度'),
(7, 1, 367, '50.00', '克', 0, ''),
(8, 1, 23, '10.00', '克', 0, ''),
(9, 1, 345, '5.00', '克', 0, ''),
(10, 2, 498, '100.00', '克', 0, '徹底洗淨並吸乾水分，避免影響風味'),
(11, 2, 499, '60.00', '克', 0, ''),
(12, 2, 230, '2.00', '顆', 0, ''),
(13, 2, 410, '20.00', '克', 0, ''),
(14, 2, 392, '40.00', '克', 0, ''),
(15, 2, 405, '15.00', '克', 0, '裝飾用，建議出餐前再撒上以維持視覺美感'),
(16, 3, 164, '300.00', '克', 0, '均勻切塊，大小一致可確保烹飪時受熱均勻'),
(17, 3, 500, '15.00', '克', 0, ''),
(18, 3, 437, '5.00', '克', 0, ''),
(19, 3, 449, '30.00', '克', 0, ''),
(20, 3, 14, '20.00', '克', 0, ''),
(21, 3, 9, '10.00', '克', 0, '去皮切片，片狀厚度約 0.2 公分左右最佳'),
(22, 3, 2, '10.00', '克', 0, ''),
(23, 3, 331, '15.00', '克', 0, ''),
(24, 3, 340, '10.00', '毫升', 0, ''),
(25, 3, 410, '5.00', '克', 0, ''),
(26, 3, 395, '5.00', '克', 0, ''),
(27, 4, 278, '100.00', '克', 0, '先充分浸泡軟化後再進行後續處理'),
(28, 4, 91, '50.00', '克', 0, '切細末，可讓香味更容易融入醬汁'),
(29, 4, 92, '50.00', '克', 0, ''),
(30, 4, 239, '100.00', '毫升', 0, ''),
(31, 4, 501, '15.00', '克', 0, ''),
(32, 4, 251, '10.00', '克', 0, ''),
(33, 4, 2, '10.00', '克', 0, ''),
(34, 4, 499, '15.00', '克', 0, ''),
(35, 4, 419, '1.00', '克', 0, ''),
(36, 4, 416, '5.00', '克', 0, ''),
(37, 5, 164, '250.00', '克', 0, '建議選用肉質結實的部位，燉煮後口感較佳'),
(38, 5, 354, '50.00', '克', 0, ''),
(39, 5, 348, '400.00', '毫升', 0, ''),
(40, 5, 82, '200.00', '克', 0, ''),
(41, 5, 335, '15.00', '克', 0, ''),
(42, 5, 502, '20.00', '克', 0, ''),
(43, 5, 34, '5.00', '克', 0, ''),
(44, 5, 24, '10.00', '克', 0, ''),
(45, 5, 345, '15.00', '克', 0, '提味用，可依據個人口味調整最後灑上的份量'),
(46, 6, 305, '2.00', '個', 0, '選用新鮮度高的食材，成品香氣會更足'),
(47, 6, 230, '2.00', '顆', 0, ''),
(48, 6, 191, '2.00', '片', 0, ''),
(49, 6, 231, '2.00', '個', 0, ''),
(50, 6, 499, '100.00', '克', 0, ''),
(51, 6, 503, '15.00', '毫升', 0, ''),
(52, 6, 504, '10.00', '毫升', 0, ''),
(53, 6, 422, '2.00', '克', 0, ''),
(54, 6, 416, '1.00', '克', 0, ''),
(55, 7, 505, '1.00', '份', 0, '一人份基準，烹調前請先撥鬆以利均勻受熱'),
(56, 7, 506, '400.00', '毫升', 0, ''),
(57, 7, 507, '30.00', '毫升', 0, ''),
(58, 7, 194, '3.00', '片', 0, ''),
(59, 7, 232, '1.00', '顆', 0, ''),
(60, 7, 97, '2.00', '片', 0, ''),
(61, 7, 94, '20.00', '克', 0, ''),
(62, 7, 51, '20.00', '克', 0, ''),
(63, 7, 16, '5.00', '克', 0, '少許即可，主要用於提升顏色層次'),
(64, 8, 475, '200.00', '克', 0, '選用當季新鮮品項，口感會更為鮮甜'),
(65, 8, 508, '50.00', '克', 0, ''),
(66, 8, 503, '30.00', '毫升', 0, ''),
(67, 8, 1, '1.00', '瓣', 0, '稍微拍碎，讓爆香時蒜油精華能快速釋放'),
(68, 8, 345, '30.00', '克', 0, ''),
(69, 8, 426, '2.00', '克', 0, ''),
(70, 8, 416, '2.00', '克', 0, ''),
(71, 8, 497, '20.00', '毫升', 0, ''),
(72, 9, 3, '3.00', '顆', 0, '使用常溫蛋，製作出的質地會更加穩定'),
(73, 9, 351, '500.00', '毫升', 0, ''),
(74, 9, 499, '30.00', '克', 0, ''),
(75, 9, 341, '50.00', '毫升', 0, ''),
(76, 9, 300, '4.00', '片', 0, ''),
(77, 9, 509, '40.00', '克', 0, ''),
(78, 9, 22, '2.00', '克', 0, ''),
(79, 9, 416, '2.00', '克', 0, ''),
(80, 9, 419, '1.00', '克', 0, ''),
(81, 10, 210, '10.00', '隻', 0, '去腸泥並保留尾部，不僅美觀且口感較乾淨'),
(82, 10, 2, '15.00', '克', 0, ''),
(83, 10, 499, '30.00', '克', 0, ''),
(84, 10, 503, '20.00', '毫升', 0, ''),
(85, 10, 21, '5.00', '克', 0, ''),
(86, 10, 419, '1.00', '克', 0, ''),
(87, 10, 416, '2.00', '克', 0, ''),
(88, 10, 136, '4.00', '角', 0, '上桌食用前再擠上新鮮汁液，可去腥提味'),
(89, 11, 163, '150.00', '克', 0, '切成長條狀，厚度約 1 公分最能保持彈性口感'),
(90, 11, 270, '20.00', '克', 0, ''),
(91, 11, 263, '60.00', '克', 0, ''),
(92, 11, 43, '80.00', '克', 0, ''),
(93, 11, 49, '50.00', '克', 0, ''),
(94, 11, 345, '5.00', '克', 0, ''),
(95, 11, 416, '2.00', '克', 0, ''),
(96, 11, 419, '1.00', '克', 0, ''),
(97, 12, 201, '150.00', '克', 0, '去除筋膜後切薄片，醃漬時會更入味'),
(98, 12, 264, '80.00', '克', 0, ''),
(99, 12, 99, '80.00', '克', 0, ''),
(100, 12, 57, '30.00', '克', 0, ''),
(101, 12, 417, '2.00', '克', 0, ''),
(102, 12, 136, '1.00', '角', 0, '隨餐附上，可增加清爽度'),
(103, 13, 178, '2.00', '片', 0, '確認已完全退冰，並抹乾表面水分'),
(104, 13, 100, '100.00', '克', 0, ''),
(105, 13, 2, '15.00', '克', 0, ''),
(106, 13, 331, '15.00', '克', 0, ''),
(107, 13, 510, '15.00', '毫升', 0, ''),
(108, 13, 340, '10.00', '毫升', 0, ''),
(109, 13, 345, '10.00', '克', 0, ''),
(110, 14, 256, '1.00', '盒', 0, '切成約 2 公分正方塊，下鍋時動作輕巧避免破碎'),
(111, 14, 186, '200.00', '克', 0, ''),
(112, 14, 5, '50.00', '克', 0, ''),
(113, 14, 91, '50.00', '克', 0, ''),
(114, 14, 92, '50.00', '克', 0, ''),
(115, 14, 511, '20.00', '克', 0, ''),
(116, 14, 345, '15.00', '克', 0, ''),
(117, 14, 416, '2.00', '克', 0, ''),
(118, 15, 202, '150.00', '克', 0, '選用脂肪分佈均勻的部位，快炒後口感更嫩滑'),
(119, 15, 4, '30.00', '克', 0, ''),
(120, 15, 48, '50.00', '克', 0, ''),
(121, 15, 341, '15.00', '毫升', 0, ''),
(122, 15, 22, '2.00', '克', 0, ''),
(123, 15, 417, '2.00', '克', 0, ''),
(124, 15, 136, '2.00', '角', 0, '裝飾兼調味用'),
(125, 16, 170, '150.00', '克', 0, '預先處理乾淨，確保沒有殘留雜質'),
(126, 16, 4, '50.00', '克', 0, ''),
(127, 16, 230, '1.00', '顆', 0, ''),
(128, 16, 272, '1.00', '碗', 0, '推薦使用隔夜飯，水分較少，炒起來顆粒分明'),
(129, 16, 331, '20.00', '克', 0, ''),
(130, 16, 410, '10.00', '克', 0, ''),
(131, 16, 510, '20.00', '毫升', 0, ''),
(132, 16, 16, '5.00', '克', 0, ''),
(133, 17, 512, '200.00', '克', 0, '撕成適合入口的小片狀，增加表面積吸收醬汁'),
(134, 17, 491, '150.00', '克', 0, ''),
(135, 17, 4, '50.00', '克', 0, '切成長段約 4-5 公分，烹煮後外觀較整齊'),
(136, 17, 14, '20.00', '克', 0, ''),
(137, 17, 360, '30.00', '克', 0, ''),
(138, 17, 462, '2.00', '克', 0, ''),
(139, 17, 345, '10.00', '克', 0, ''),
(140, 18, 164, '250.00', '克', 0, '厚度建議適中，以免在燉煮過程中縮水過多'),
(141, 18, 56, '150.00', '克', 0, '切均勻細絲，可縮短熟化時間並增加層次'),
(142, 18, 57, '80.00', '克', 0, ''),
(143, 18, 3, '100.00', '克', 0, ''),
(144, 18, 513, '50.00', '克', 0, ''),
(145, 18, 239, '20.00', '毫升', 0, ''),
(146, 18, 497, '400.00', '毫升', 0, ''),
(147, 18, 345, '15.00', '克', 0, ''),
(148, 19, 514, '200.00', '克', 0, '徹底清洗並去除泥沙，建議烹飪前保持低溫'),
(149, 19, 31, '100.00', '克', 0, ''),
(150, 19, 2, '10.00', '克', 0, ''),
(151, 19, 363, '20.00', '克', 0, ''),
(152, 19, 510, '20.00', '毫升', 0, ''),
(153, 19, 340, '10.00', '毫升', 0, ''),
(154, 19, 345, '5.00', '克', 0, ''),
(155, 20, 201, '150.00', '克', 0, '使用斷筋處理，可避免受熱後嚴重縮小'),
(156, 20, 43, '80.00', '克', 0, ''),
(157, 20, 331, '15.00', '毫升', 0, ''),
(158, 20, 510, '15.00', '毫升', 0, ''),
(159, 20, 410, '5.00', '克', 0, ''),
(160, 20, 340, '10.00', '毫升', 0, ''),
(161, 20, 2, '5.00', '克', 0, ''),
(162, 20, 462, '1.00', '克', 0, ''),
(163, 20, 16, '5.00', '克', 0, ''),
(164, 20, 345, '10.00', '克', 0, '提升整體配色質感'),
(165, 21, 277, '160.00', '克', 0, NULL),
(166, 21, 187, '200.00', '克', 0, NULL),
(167, 21, 5, '50.00', '克', 0, NULL),
(168, 21, 2, '10.00', '克', 0, NULL),
(169, 21, 57, '30.00', '克', 0, NULL),
(170, 21, 367, '30.00', '克', 0, NULL),
(171, 21, 369, '200.00', '克', 0, NULL),
(172, 21, 433, '2.00', '克', 0, NULL),
(173, 21, 251, '10.00', '克', 0, NULL),
(174, 21, 345, '15.00', '克', 0, NULL),
(175, 21, 416, '5.00', '克', 0, NULL),
(176, 22, 515, '150.00', '克', 0, NULL),
(177, 22, 91, '50.00', '克', 0, NULL),
(178, 22, 92, '50.00', '克', 0, NULL),
(179, 22, 501, '20.00', '克', 0, NULL),
(180, 22, 239, '30.00', '毫升', 0, NULL),
(181, 22, 3, '50.00', '克', 0, NULL),
(182, 22, 341, '50.00', '毫升', 0, NULL),
(183, 22, 350, '500.00', '毫升', 0, NULL),
(184, 22, 499, '20.00', '克', 0, NULL),
(185, 22, 251, '20.00', '克', 0, NULL),
(186, 23, 165, '500.00', '克', 0, NULL),
(187, 23, 422, '10.00', '克', 0, NULL),
(188, 23, 431, '5.00', '克', 0, NULL),
(189, 23, 432, '5.00', '克', 0, NULL),
(190, 23, 419, '2.00', '克', 0, NULL),
(191, 23, 416, '5.00', '克', 0, NULL),
(192, 23, 410, '5.00', '克', 0, NULL),
(193, 23, 345, '15.00', '克', 0, NULL),
(194, 23, 387, '20.00', '克', 0, NULL),
(195, 24, 279, '100.00', '克', 0, NULL),
(196, 24, 218, '300.00', '克', 0, NULL),
(197, 24, 2, '15.00', '克', 0, NULL),
(198, 24, 500, '2.00', '克', 0, NULL),
(199, 24, 341, '50.00', '毫升', 0, NULL),
(200, 24, 21, '5.00', '克', 0, NULL),
(201, 24, 345, '20.00', '克', 0, NULL),
(202, 24, 416, '5.00', '克', 0, NULL),
(203, 25, 277, '100.00', '克', 0, NULL),
(204, 25, 191, '60.00', '克', 0, NULL),
(205, 25, 231, '2.00', '顆', 0, NULL),
(206, 25, 251, '30.00', '克', 0, NULL),
(207, 25, 419, '2.00', '克', 0, NULL),
(208, 25, 239, '30.00', '毫升', 0, NULL),
(209, 25, 416, '5.00', '克', 0, NULL),
(210, 26, 164, '300.00', '克', 0, NULL),
(211, 26, 516, '30.00', '克', 0, NULL),
(212, 26, 1, '20.00', '克', 0, NULL),
(213, 26, 2, '10.00', '顆', 0, NULL),
(214, 26, 13, '1.00', '根', 0, NULL),
(215, 26, 331, '30.00', '毫升', 0, NULL),
(216, 26, 340, '30.00', '毫升', 0, NULL),
(217, 26, 410, '15.00', '克', 0, NULL),
(218, 26, 25, '20.00', '克', 0, NULL),
(219, 27, 177, '600.00', '克', 0, NULL),
(220, 27, 414, '30.00', '克', 0, NULL),
(221, 27, 331, '60.00', '毫升', 0, NULL),
(222, 27, 340, '30.00', '毫升', 0, NULL),
(223, 27, 14, '20.00', '克', 0, NULL),
(224, 27, 1, '15.00', '克', 0, NULL),
(225, 27, 2, '15.00', '顆', 0, NULL),
(226, 27, 497, '500.00', '毫升', 0, NULL),
(227, 28, 204, '1.00', '尾', 0, NULL),
(228, 28, 1, '15.00', '克', 0, NULL),
(229, 28, 16, '20.00', '克', 0, NULL),
(230, 28, 13, '5.00', '克', 0, NULL),
(231, 28, 331, '30.00', '毫升', 0, NULL),
(232, 28, 345, '30.00', '毫升', 0, NULL),
(233, 29, 256, '300.00', '克', 0, NULL),
(234, 29, 186, '100.00', '克', 0, NULL),
(235, 29, 362, '30.00', '克', 0, NULL),
(236, 29, 2, '15.00', '克', 0, NULL),
(237, 29, 1, '10.00', '克', 0, NULL),
(238, 29, 16, '10.00', '克', 0, NULL),
(239, 29, 331, '15.00', '毫升', 0, NULL),
(240, 29, 410, '5.00', '克', 0, NULL),
(241, 29, 428, '10.00', '克', 0, NULL),
(242, 29, 434, '2.00', '克', 0, NULL),
(243, 29, 497, '200.00', '毫升', 0, NULL),
(244, 30, 221, '80.00', '克', 0, NULL),
(245, 30, 177, '200.00', '克', 0, NULL),
(246, 30, 254, '100.00', '克', 0, NULL),
(247, 30, 54, '100.00', '克', 0, NULL),
(248, 30, 16, '20.00', '克', 0, NULL),
(249, 30, 2, '15.00', '克', 0, NULL),
(250, 30, 13, '5.00', '克', 0, NULL),
(251, 30, 331, '20.00', '毫升', 0, NULL),
(252, 30, 410, '5.00', '克', 0, NULL),
(253, 30, 340, '15.00', '毫升', 0, NULL),
(254, 30, 345, '10.00', '克', 0, NULL),
(255, 31, 164, '500.00', '克', 0, NULL),
(256, 31, 1, '50.00', '克', 0, NULL),
(257, 31, 516, '45.00', '克', 0, NULL),
(258, 31, 340, '300.00', '毫升', 0, NULL),
(259, 31, 497, '300.00', '毫升', 0, NULL),
(260, 31, 482, '8.00', '顆', 0, NULL),
(261, 31, 481, '5.00', '克', 0, NULL),
(262, 31, 416, '2.00', '克', 0, NULL),
(263, 32, 230, '2.00', '顆', 0, NULL),
(264, 32, 260, '35.00', '克', 0, NULL),
(265, 32, 235, '20.00', '毫升', 0, NULL),
(266, 32, 410, '25.00', '克', 0, NULL),
(267, 32, 504, '2.00', '滴', 0, NULL),
(268, 32, 426, '1.00', '克', 0, NULL),
(269, 32, 345, '5.00', '克', 0, NULL),
(270, 33, 230, '3.00', '顆', 0, NULL),
(271, 33, 235, '400.00', '毫升', 0, NULL),
(272, 33, 410, '90.00', '克', 0, NULL),
(273, 33, 504, '3.00', '滴', 0, NULL),
(274, 33, 497, '30.00', '毫升', 0, NULL),
(275, 34, 299, '1.00', '片', 0, NULL),
(276, 34, 499, '20.00', '克', 0, NULL),
(277, 34, 387, '15.00', '克', 0, NULL),
(278, 35, 235, '250.00', '毫升', 0, NULL),
(279, 35, 239, '250.00', '毫升', 0, NULL),
(280, 35, 410, '40.00', '克', 0, NULL),
(281, 35, 504, '1.00', '茶匙', 0, NULL),
(282, 35, 409, '2.50', '片', 0, NULL),
(283, 36, 109, '2.00', '根', 0, NULL),
(284, 36, 260, '200.00', '克', 0, NULL),
(285, 36, 499, '100.00', '克', 0, NULL),
(286, 36, 410, '80.00', '克', 0, NULL),
(287, 36, 230, '2.00', '顆', 0, NULL),
(288, 36, 426, '5.00', '克', 0, NULL),
(289, 37, 499, '100.00', '克', 0, NULL),
(290, 37, 412, '80.00', '克', 0, NULL),
(291, 37, 410, '50.00', '克', 0, NULL),
(292, 37, 230, '1.00', '顆', 0, NULL),
(293, 37, 389, '1.00', '茶匙', 0, NULL),
(294, 37, 391, '150.00', '克', 0, NULL),
(295, 37, 274, '150.00', '克', 0, NULL),
(296, 37, 407, '3.00', '克', 0, NULL),
(297, 37, 416, '2.00', '克', 0, NULL),
(298, 37, 480, '80.00', '克', 0, NULL),
(299, 38, 230, '2.00', '顆', 0, NULL),
(300, 38, 410, '60.00', '克', 0, NULL),
(301, 38, 392, '100.00', '克', 0, NULL),
(302, 38, 408, '3.00', '克', 0, NULL),
(303, 38, 499, '100.00', '克', 0, NULL),
(304, 38, 445, '2.00', '克', 0, NULL),
(305, 38, 387, '15.00', '克', 0, NULL),
(306, 39, 391, '300.00', '克', 0, NULL),
(307, 39, 408, '10.00', '克', 0, NULL),
(308, 39, 416, '2.00', '克', 0, NULL),
(309, 39, 499, '80.00', '克', 0, NULL),
(310, 39, 455, '60.00', '克', 0, NULL),
(311, 39, 238, '100.00', '毫升', 0, NULL),
(312, 39, 388, '40.00', '克', 0, NULL),
(313, 40, 447, '200.00', '克', 0, NULL),
(314, 40, 499, '120.00', '克', 0, NULL),
(315, 40, 410, '150.00', '克', 0, NULL),
(316, 40, 230, '2.00', '顆', 0, NULL),
(317, 40, 391, '80.00', '克', 0, NULL),
(318, 40, 406, '30.00', '克', 0, NULL),
(319, 40, 416, '1.00', '克', 0, NULL),
(320, 41, 238, '500.00', '毫升', 0, NULL),
(321, 41, 499, '50.00', '克', 0, NULL),
(322, 41, 389, '1.00', '茶匙', 0, NULL),
(323, 41, 410, '200.00', '克', 0, NULL),
(324, 41, 392, '125.00', '克', 0, NULL),
(325, 41, 231, '2.00', '個', 0, NULL),
(326, 41, 343, '40.00', '毫升', 0, NULL),
(327, 42, 392, '150.00', '克', 0, NULL),
(328, 42, 499, '175.00', '克', 0, NULL),
(329, 42, 413, '40.00', '克', 0, NULL),
(330, 42, 453, '20.00', '克', 0, NULL),
(331, 42, 230, '4.00', '顆', 0, NULL),
(332, 42, 503, '120.00', '毫升', 0, NULL),
(333, 42, 19, '5.00', '克', 0, NULL),
(334, 42, 410, '100.00', '克', 0, NULL),
(335, 43, 230, '2.00', '顆', 0, NULL),
(336, 43, 410, '100.00', '克', 0, NULL),
(337, 43, 239, '150.00', '毫升', 0, NULL),
(338, 43, 385, '200.00', '克', 0, NULL),
(339, 43, 499, '30.00', '克', 0, NULL),
(340, 43, 343, '10.00', '毫升', 0, NULL),
(341, 43, 461, '6.00', '顆', 0, NULL),
(342, 43, 413, '10.00', '克', 0, NULL),
(343, 44, 297, '2.00', '片', 0, NULL),
(344, 44, 239, '150.00', '毫升', 0, NULL),
(345, 44, 410, '15.00', '克', 0, NULL),
(346, 44, 143, '6.00', '顆', 0, NULL),
(347, 44, 107, '0.50', '顆', 0, NULL),
(348, 45, 241, '200.00', '克', 0, NULL),
(349, 45, 144, '50.00', '克', 0, NULL),
(350, 45, 274, '30.00', '克', 0, NULL),
(351, 45, 387, '15.00', '克', 0, NULL),
(352, 45, 29, '2.00', '片', 0, NULL),
(353, 46, 260, '400.00', '毫升', 0, NULL),
(354, 46, 464, '30.00', '克', 0, NULL),
(355, 46, 410, '40.00', '克', 0, NULL),
(356, 46, 409, '2.00', '片', 0, NULL),
(357, 46, 239, '50.00', '毫升', 0, NULL),
(358, 47, 393, '200.00', '克', 0, NULL),
(359, 47, 345, '60.00', '克', 0, NULL),
(360, 47, 388, '60.00', '克', 0, NULL),
(361, 47, 452, '30.00', '克', 0, NULL),
(362, 47, 455, '30.00', '克', 0, NULL),
(363, 47, 416, '1.00', '克', 0, NULL),
(364, 48, 477, '100.00', '克', 0, NULL),
(365, 48, 496, '300.00', '毫升', 0, NULL),
(366, 48, 410, '80.00', '克', 0, NULL),
(367, 48, 238, '400.00', '毫升', 0, NULL),
(368, 48, 409, '3.00', '片', 0, NULL),
(369, 49, 294, '300.00', '克', 0, NULL),
(370, 49, 223, '100.00', '克', 0, NULL),
(371, 49, 360, '45.00', '克', 0, NULL),
(372, 49, 421, '10.00', '克', 0, NULL),
(373, 49, 41, '150.00', '克', 0, NULL),
(374, 49, 13, '2.00', '支', 0, NULL),
(375, 49, 233, '2.00', '顆', 0, NULL),
(376, 49, 352, '400.00', '毫升', 0, NULL),
(377, 49, 410, '15.00', '克', 0, NULL),
(378, 49, 331, '15.00', '毫升', 0, NULL),
(379, 49, 462, '2.00', '克', 0, NULL),
(380, 50, 179, '150.00', '克', 0, NULL),
(381, 50, 197, '100.00', '克', 0, NULL),
(382, 50, 196, '2.00', '根', 0, NULL),
(383, 50, 491, '100.00', '克', 0, NULL),
(384, 50, 256, '0.50', '盒', 0, NULL),
(385, 50, 3, '0.50', '顆', 0, NULL),
(386, 50, 478, '1.00', '大匙', 0, NULL),
(387, 50, 295, '1.00', '包', 0, NULL),
(388, 50, 248, '1.00', '片', 0, NULL),
(389, 50, 352, '600.00', '毫升', 0, NULL),
(390, 50, 360, '30.00', '克', 0, NULL),
(391, 50, 421, '10.00', '克', 0, NULL),
(392, 50, 2, '10.00', '克', 0, NULL),
(393, 51, 514, '150.00', '克', 0, NULL),
(394, 51, 491, '150.00', '克', 0, NULL),
(395, 51, 256, '150.00', '克', 0, NULL),
(396, 51, 3, '0.30', '顆', 0, NULL),
(397, 51, 2, '10.00', '克', 0, NULL),
(398, 51, 421, '5.00', '克', 0, NULL),
(399, 51, 516, '10.00', '毫升', 0, NULL),
(400, 51, 496, '500.00', '毫升', 0, NULL),
(401, 52, 272, '1.00', '碗', 0, NULL),
(402, 52, 101, '50.00', '克', 0, NULL),
(403, 52, 37, '50.00', '克', 0, NULL),
(404, 52, 77, '50.00', '克', 0, NULL),
(405, 52, 57, '30.00', '克', 0, NULL),
(406, 52, 92, '2.00', '朵', 0, NULL),
(407, 52, 170, '100.00', '克', 0, NULL),
(408, 52, 230, '1.00', '顆', 0, NULL),
(409, 52, 360, '30.00', '克', 0, NULL),
(410, 52, 516, '20.00', '毫升', 0, NULL),
(411, 52, 410, '5.00', '克', 0, NULL),
(412, 53, 165, '500.00', '克', 0, NULL),
(413, 53, 394, '100.00', '克', 0, NULL),
(414, 53, 2, '20.00', '克', 0, NULL),
(415, 53, 331, '20.00', '毫升', 0, NULL),
(416, 53, 387, '60.00', '克', 0, NULL),
(417, 53, 499, '30.00', '克', 0, NULL),
(418, 53, 462, '5.00', '克', 0, NULL),
(419, 53, 416, '2.00', '克', 0, NULL),
(420, 53, 419, '1.00', '克', 0, NULL),
(421, 54, 164, '400.00', '克', 0, NULL),
(422, 54, 90, '200.00', '克', 0, NULL),
(423, 54, 92, '4.00', '朵', 0, NULL),
(424, 54, 481, '10.00', '克', 0, NULL),
(425, 54, 482, '6.00', '顆', 0, NULL),
(426, 54, 9, '15.00', '克', 0, NULL),
(427, 54, 340, '30.00', '毫升', 0, NULL),
(428, 54, 496, '1000.00', '毫升', 0, NULL),
(429, 54, 416, '5.00', '克', 0, NULL),
(430, 55, 181, '300.00', '克', 0, NULL),
(431, 55, 517, '0.60', '根', 0, NULL),
(432, 55, 518, '1.00', '根', 0, NULL),
(433, 55, 9, '15.00', '克', 0, NULL),
(434, 55, 496, '1500.00', '毫升', 0, NULL),
(435, 55, 416, '5.00', '克', 0, NULL),
(436, 55, 27, '5.00', '克', 0, NULL),
(437, 56, 519, '100.00', '克', 0, NULL),
(438, 56, 256, '1.00', '盒', 0, NULL),
(439, 56, 94, '50.00', '克', 0, NULL),
(440, 56, 57, '50.00', '克', 0, NULL),
(441, 56, 50, '50.00', '克', 0, NULL),
(442, 56, 230, '2.00', '顆', 0, NULL),
(443, 56, 16, '10.00', '克', 0, NULL),
(444, 56, 350, '1000.00', '毫升', 0, NULL),
(445, 56, 331, '30.00', '毫升', 0, NULL),
(446, 56, 420, '5.00', '克', 0, NULL),
(447, 56, 337, '45.00', '毫升', 0, NULL),
(448, 56, 395, '30.00', '克', 0, NULL),
(449, 56, 516, '5.00', '毫升', 0, NULL),
(450, 57, 164, '400.00', '克', 0, NULL),
(451, 57, 520, '0.50', '罐', 0, NULL),
(452, 57, 213, '200.00', '克', 0, NULL),
(453, 57, 1, '4.00', '瓣', 0, NULL),
(454, 57, 9, '10.00', '克', 0, NULL),
(455, 57, 340, '30.00', '毫升', 0, NULL),
(456, 57, 496, '1200.00', '毫升', 0, NULL),
(457, 58, 181, '300.00', '克', 0, NULL),
(458, 58, 38, '300.00', '克', 0, NULL),
(459, 58, 230, '2.00', '顆', 0, NULL),
(460, 58, 9, '10.00', '克', 0, NULL),
(461, 58, 16, '5.00', '克', 0, NULL),
(462, 58, 496, '1200.00', '毫升', 0, NULL),
(463, 58, 416, '5.00', '克', 0, NULL),
(464, 58, 410, '2.00', '克', 0, NULL),
(465, 59, 171, '600.00', '克', 0, NULL),
(466, 59, 284, '400.00', '克', 0, NULL),
(467, 59, 517, '0.60', '根', 0, NULL),
(468, 59, 55, '150.00', '克', 0, NULL),
(469, 59, 36, '4.00', '株', 0, NULL),
(470, 59, 14, '30.00', '克', 0, NULL),
(471, 59, 9, '20.00', '克', 0, NULL),
(472, 59, 1, '5.00', '瓣', 0, NULL),
(473, 59, 359, '45.00', '克', 0, NULL),
(474, 59, 331, '60.00', '毫升', 0, NULL),
(475, 59, 340, '30.00', '毫升', 0, NULL),
(476, 59, 436, '3.00', '顆', 0, NULL),
(477, 59, 410, '15.00', '克', 0, NULL),
(478, 59, 351, '1500.00', '毫升', 0, NULL),
(479, 60, 310, '4.00', '片', 0, NULL),
(480, 60, 521, '250.00', '克', 0, NULL),
(481, 60, 5, '50.00', '克', 0, NULL),
(482, 60, 88, '1.00', '顆', 0, NULL),
(483, 60, 27, '10.00', '克', 0, NULL),
(484, 60, 136, '2.00', '角', 0, NULL),
(485, 60, 377, '60.00', '克', 0, NULL),
(486, 60, 54, '40.00', '克', 0, NULL),
(487, 60, 240, '30.00', '克', 0, NULL),
(488, 60, 426, '5.00', '克', 0, NULL),
(489, 60, 422, '5.00', '克', 0, NULL),
(490, 61, 210, '6.00', '隻', 0, NULL),
(491, 61, 213, '150.00', '克', 0, NULL),
(492, 61, 90, '100.00', '克', 0, NULL),
(493, 61, 89, '6.00', '顆', 0, NULL),
(494, 61, 31, '2.00', '支', 0, NULL),
(495, 61, 12, '20.00', '克', 0, NULL),
(496, 61, 34, '4.00', '片', 0, NULL),
(497, 61, 335, '30.00', '毫升', 0, NULL),
(498, 61, 348, '100.00', '毫升', 0, NULL),
(499, 61, 503, '45.00', '毫升', 0, NULL),
(500, 61, 422, '10.00', '克', 0, NULL),
(501, 61, 410, '10.00', '克', 0, NULL),
(502, 61, 2, '10.00', '克', 0, NULL),
(503, 61, 496, '800.00', '毫升', 0, NULL),
(504, 62, 52, '200.00', '克', 0, NULL),
(505, 62, 308, '30.00', '克', 0, NULL),
(506, 62, 163, '150.00', '克', 0, NULL),
(507, 62, 251, '20.00', '克', 0, NULL),
(508, 62, 522, '10.00', '克', 0, NULL),
(509, 62, 2, '10.00', '克', 0, NULL),
(510, 62, 231, '1.00', '個', 0, NULL),
(511, 62, 345, '45.00', '毫升', 0, NULL),
(512, 62, 503, '15.00', '毫升', 0, NULL),
(513, 63, 173, '1.00', '客', 0, '厚度建議 2.5-3 公分，料理前需先置於室溫回溫 30 分鐘'),
(514, 63, 28, '5.00', '克', 0, '使用新鮮整株迷迭香，香氣釋放效果遠優於乾燥香料'),
(515, 63, 1, '2.00', '瓣', 0, '不去皮直接拍扁，可防止蒜頭在高溫下過快焦黑'),
(516, 63, 499, '20.00', '克', 0, '提供濃郁乳香並作為傳熱介質，是法式淋油的核心'),
(517, 63, 417, '2.00', '克', 0, '粗鹽能提供更好的顆粒感與鹹味層次'),
(518, 63, 418, '1.00', '克', 0, '建議現磨黑胡椒，香氣最為辛辣清新'),
(519, 63, 48, '100.00', '克', 0, '去除尾部纖維較硬處，是理想的低碳配菜'),
(520, 63, 89, '60.00', '克', 0, ''),
(521, 63, 345, '10.00', '毫升', 0, '選用高發煙點的橄欖油進行初始大火煎製'),
(522, 64, 313, '6.00', '片', 0, '乾燥米紙質地脆弱，取出時需小心，浸水時間不可過長'),
(523, 64, 291, '100.00', '克', 0, '燙熟後務必過冷水並瀝乾，可保持米線 Q 彈且互不黏連'),
(524, 64, 210, '6.00', '隻', 0, '燙熟後去殼對半片開，平舖在米紙上顏色最美'),
(525, 64, 512, '100.00', '克', 0, '川燙後切成薄片，提供油脂香氣與咬勁'),
(526, 64, 52, '100.00', '克', 0, ''),
(527, 64, 25, '10.00', '克', 0, '越式風味的靈魂，建議整片葉子包入香氣最足'),
(528, 64, 29, '10.00', '克', 0, ''),
(529, 64, 45, '6.00', '根', 0, '選用細長的韭菜梗，收口時留一段露在外面是道地做法'),
(530, 64, 335, '20.00', '毫升', 0, ''),
(531, 64, 503, '20.00', '毫升', 0, ''),
(532, 64, 410, '10.00', '克', 0, ''),
(533, 64, 2, '5.00', '克', 0, ''),
(534, 64, 496, '20.00', '毫升', 0, '用於調釋沾醬，冷開水即可'),
(535, 65, 515, '150.00', '克', 0, '義大利米雖非傳統 Bomba 米，但其高澱粉特性仍能做出優秀質地，切記不可洗米'),
(536, 65, 440, '0.10', '克', 0, '世界上最昂貴的香料，只需一小撮即可提供標誌性的金黃色與藥草香'),
(537, 65, 214, '6.00', '顆', 0, '需刷洗外殼並去除足絲，擺在表面呈現放射狀最美觀'),
(538, 65, 219, '100.00', '克', 0, ''),
(539, 65, 210, '6.00', '隻', 0, '保留蝦殼煎出蝦油，是 Paella 香氣層次的關鍵'),
(540, 65, 5, '50.00', '克', 0, ''),
(541, 65, 86, '50.00', '克', 0, '切成細丁炒軟，與番紅花共同構建紅黃相間的色澤'),
(542, 65, 350, '400.00', '毫升', 0, '需維持熱態，分次加入以精準控制米飯熟度'),
(543, 65, 341, '30.00', '毫升', 0, ''),
(544, 65, 136, '2.00', '角', 0, '盛盤後裝飾，食用前擠上可平衡海鮮的濃厚味'),
(545, 65, 422, '2.00', '克', 0, '提供煙燻香氣與紅潤色澤'),
(546, 66, 186, '300.00', '克', 0, '建議選用 3:7 肥瘦比，口感濕潤不乾硬'),
(547, 66, 236, '2.00', '顆', 0, '蛋白提供鹹度，蛋黃提供油脂香氣與視覺核心'),
(548, 66, 523, '50.00', '克', 0, '包含固體醬瓜與少許醬汁，是甘甜味的來源'),
(549, 66, 16, '10.00', '克', 0, ''),
(550, 66, 2, '10.00', '克', 0, ''),
(551, 66, 331, '10.00', '毫升', 0, '因鹹蛋白已有鹹味，醬油僅需少量增色提味'),
(552, 66, 420, '1.00', '克', 0, ''),
(553, 66, 496, '30.00', '毫升', 0, '加入少許水與肉攪拌，可使蒸出來的成品質地更鬆軟'),
(554, 67, 175, '300.00', '克', 0, '切成約 3 公分方塊，燉煮後縮水大小最剛好'),
(555, 67, 60, '200.00', '克', 0, '羅宋湯的靈魂色澤來源，切細絲或薄片以便釋放顏色'),
(556, 67, 5, '100.00', '克', 0, '炒至半透明狀可為湯底提供基礎甜味'),
(557, 67, 55, '100.00', '克', 0, ''),
(558, 67, 65, '150.00', '克', 0, '馬鈴薯釋放的澱粉能讓湯頭帶有天然的濃稠感'),
(559, 67, 41, '100.00', '克', 0, '切成寬條狀，最後加入以保留些許爽脆口感'),
(560, 67, 367, '30.00', '克', 0, '增加湯頭厚度與酸甜層次，需先入鍋略炒去除生味'),
(561, 67, 524, '2.00', '片', 0, '提供乾燥香草特有的深邃木質香氣'),
(562, 67, 240, '30.00', '克', 0, '食用前放在湯面，提供解膩的酸度與乳香'),
(563, 67, 496, '1200.00', '毫升', 0, ''),
(564, 67, 417, '2.00', '克', 0, ''),
(565, 67, 419, '1.00', '克', 0, ''),
(566, 68, 210, '6.00', '隻', 0, '去殼留尾，去除腸泥並在腹部劃刀以確保炸後筆直'),
(567, 68, 402, '100.00', '克', 0, '含麵衣與預沾用的乾粉'),
(568, 68, 496, '150.00', '毫升', 0, '務必使用帶碎冰的冰水，是麵衣酥脆不回軟的關鍵'),
(569, 68, 58, '50.00', '克', 0, '輕微壓乾水分後拌入沾醬，可解膩並增加鮮甜感'),
(570, 68, 333, '40.00', '毫升', 0, '與水 1:2 稀釋，作為清爽的蘸汁底'),
(571, 68, 71, '2.00', '片', 0, '厚度控制在 0.5 公分，炸熟後鬆軟香甜'),
(572, 68, 83, '2.00', '條', 0, '切成長條或扇狀，表面劃花刀以便吸附麵衣'),
(573, 68, 525, '1.00', '顆', 0, '去籽切塊，提供清爽的微苦風味層次'),
(574, 68, 345, '500.00', '毫升', 0, '需準備足量油以維持恆溫，避免食材入鍋後油溫驟降'),
(575, 69, 180, '400.00', '克', 0, '手切成約 0.5 公分寬、3 公分長的條狀，燉煮後口感最分明'),
(576, 69, 444, '50.00', '克', 0, '滷肉飯香氣的核心來源，份量不可過少'),
(577, 69, 427, '2.00', '克', 0, '提供深層的台式香料底蘊'),
(578, 69, 331, '80.00', '毫升', 0, '建議混合生抽與老抽，兼顧鹹度與紅亮色澤'),
(579, 69, 414, '30.00', '克', 0, '炒出糖色後能賦予滷肉迷人的光澤感'),
(580, 69, 340, '50.00', '毫升', 0, ''),
(581, 69, 272, '4.00', '碗', 0, ''),
(582, 69, 230, '4.00', '顆', 0, '事先煮熟去殼，隨肉燥一同燉煮入味成滷蛋'),
(583, 69, 490, '4.00', '片', 0, '清脆微酸的口感能有效解除肉燥的油膩感'),
(584, 69, 496, '800.00', '毫升', 0, ''),
(585, 70, 216, '100.00', '克', 0, '選用肉質肥美、外緣黑環明顯的鮮蚵，洗淨瀝乾避免過多水分'),
(586, 70, 230, '1.00', '顆', 0, ''),
(587, 70, 526, '2.00', '株', 0, '切成約 5 公分長段，增加脆口層次'),
(588, 70, 397, '40.00', '克', 0, '2:1 比例中的主角，提供主要的 Q 彈咬勁'),
(589, 70, 395, '20.00', '克', 0, '增加粉漿的透明感與滑順度'),
(590, 70, 496, '120.00', '毫升', 0, '與粉類混合均勻，粉漿需呈現流動液狀'),
(591, 70, 364, '30.00', '毫升', 0, '海山醬是台式淋醬的基底，提供獨特的鹹甜味'),
(592, 70, 365, '15.00', '毫升', 0, '增加微辣感與紅潤光澤'),
(593, 70, 16, '5.00', '克', 0, ''),
(594, 71, 390, '250.00', '克', 0, '同原版高粉比例，確保餅皮韌性'),
(595, 71, 497, '3.00', '克', 0, ''),
(596, 71, 496, '150.00', '毫升', 0, ''),
(597, 71, 416, '2.00', '克', 0, ''),
(598, 71, 345, '30.00', '毫升', 1, '增量後的橄欖油，部分用於低溫煉製蒜油'),
(599, 71, 2, '15.00', '克', 1, '新增食材，用於熬製靈魂蒜油'),
(600, 71, 367, '50.00', '克', 0, ''),
(601, 71, 242, '125.00', '克', 0, ''),
(602, 71, 23, '10.00', '克', 0, ''),
(603, 71, 387, '15.00', '毫升', 1, '新增食材，出爐後淋上，創造甜鹹味覺衝擊'),
(604, 72, 390, '250.00', '克', 0, ''),
(605, 72, 497, '3.00', '克', 0, ''),
(606, 72, 496, '150.00', '毫升', 0, ''),
(607, 72, 416, '2.00', '克', 0, ''),
(608, 72, 345, '10.00', '克', 0, ''),
(609, 72, 367, '50.00', '克', 0, '抹醬層，建議選用酸度明顯的番茄糊以平衡起司濃厚度'),
(610, 72, 242, '125.00', '克', 1, '改用整顆布拉塔起司(Burrata)，出爐後置於披薩中心，切開後讓流心鋪滿餅皮'),
(611, 72, 501, '15.00', '克', 1, '新增食材，塗抹在番茄糊之上共同烘烤，散發迷人香氣'),
(612, 72, 23, '10.00', '克', 0, ''),
(613, 73, 390, '250.00', '克', 0, ''),
(614, 73, 497, '3.00', '克', 0, ''),
(615, 73, 496, '150.00', '毫升', 0, ''),
(616, 73, 416, '2.00', '克', 0, ''),
(617, 73, 347, '15.00', '毫升', 1, '改用辣油取代普通橄欖油，從餅皮基底就帶有微辛香氣'),
(618, 73, 367, '50.00', '克', 0, ''),
(619, 73, 243, '125.00', '克', 1, '改用莫札瑞拉絲，較易於與肉類油脂結合'),
(620, 73, 193, '60.00', '克', 1, '新增食材，切薄片擺放，烘烤後邊緣會微捲酥脆'),
(621, 73, 489, '20.00', '克', 1, '新增食材，提供酸辣度與清爽的脆度'),
(622, 73, 23, '10.00', '克', 0, ''),
(623, 74, 498, '100.00', '克', 0, ''),
(624, 74, 499, '60.00', '克', 0, ''),
(625, 74, 230, '2.00', '顆', 0, ''),
(626, 74, 410, '20.00', '克', 0, ''),
(627, 74, 392, '40.00', '克', 0, ''),
(628, 74, 405, '15.00', '克', 0, ''),
(629, 74, 236, '1.00', '顆', 1, '新增食材，僅取熟鹹蛋黃並壓碎，製作核心流沙球'),
(630, 74, 239, '10.00', '毫升', 1, '新增食材，混合鹹蛋黃調整稠度，確保流動感'),
(631, 75, 498, '100.00', '克', 0, ''),
(632, 75, 499, '50.00', '克', 0, ''),
(633, 75, 230, '2.00', '顆', 0, ''),
(634, 75, 410, '30.00', '克', 0, ''),
(635, 75, 392, '40.00', '克', 0, ''),
(636, 75, 405, '15.00', '克', 0, ''),
(637, 75, 245, '50.00', '克', 1, '新增食材，提供乳霜般絲滑的流心質地'),
(638, 75, 144, '10.00', '顆', 1, '新增食材，藏於起司內餡中，提供清新酸度'),
(639, 76, 498, '100.00', '克', 0, ''),
(640, 76, 499, '50.00', '克', 0, ''),
(641, 76, 230, '2.00', '顆', 0, ''),
(642, 76, 410, '20.00', '克', 1, '因栗子泥自帶甜味，稍微減少白糖用量'),
(643, 76, 392, '40.00', '克', 0, ''),
(644, 76, 405, '15.00', '克', 0, ''),
(645, 76, 385, '60.00', '克', 1, '新增食材，選用質地細緻的栗子泥製作中心核心'),
(646, 76, 343, '5.00', '毫升', 1, '新增食材，少許黑蘭姆酒能大幅提升抹茶與栗子的香氣層次'),
(647, 77, 164, '300.00', '克', 0, '選用帶皮雞腿丁，與鳳梨酵素作用後口感會極其滑嫩'),
(648, 77, 500, '15.00', '克', 0, ''),
(649, 77, 437, '5.00', '克', 0, ''),
(650, 77, 454, '40.00', '克', 1, '改用腰果取代花生，提供更溫潤的堅果乳香與酥脆感'),
(651, 77, 105, '100.00', '克', 1, '新增食材，選用成熟鳳梨切丁，提供天然果酸與水分'),
(652, 77, 14, '20.00', '克', 0, ''),
(653, 77, 2, '10.00', '克', 0, ''),
(654, 77, 331, '15.00', '毫升', 0, ''),
(655, 77, 340, '10.00', '毫升', 0, ''),
(656, 77, 410, '5.00', '克', 1, '減量砂糖，因為鳳梨受熱後會釋放天然糖分'),
(657, 78, 164, '300.00', '克', 0, '切成一口大小，酥炸後體積會微縮，口感最緊實'),
(658, 78, 397, '80.00', '克', 1, '新增食材，選用粗顆粒地瓜粉，是製作酥脆外殼的靈魂'),
(659, 78, 500, '15.00', '克', 0, ''),
(660, 78, 437, '5.00', '克', 0, ''),
(661, 78, 451, '30.00', '克', 1, '改用花生碎，增加與醬汁的附著表面積，口感更均衡'),
(662, 78, 387, '40.00', '毫升', 1, '新增食材，提供醬汁高度光澤感與厚實甜味'),
(663, 78, 503, '15.00', '毫升', 1, '新增食材，以檸檬清新果酸取代傳統食醋'),
(664, 78, 331, '15.00', '毫升', 0, ''),
(665, 78, 340, '10.00', '毫升', 0, ''),
(666, 78, 14, '20.00', '克', 0, ''),
(667, 79, 256, '2.00', '盒', 1, '改用板豆腐，需先重壓 20 分鐘去水，切成 2 公分方塊'),
(668, 79, 500, '15.00', '克', 0, ''),
(669, 79, 437, '5.00', '克', 0, ''),
(670, 79, 449, '30.00', '克', 0, ''),
(671, 79, 331, '30.00', '毫升', 0, ''),
(672, 79, 337, '15.00', '毫升', 1, '新增食材，烏醋的深沉酸味比白醋更契合豆腐的豆香'),
(673, 79, 410, '10.00', '克', 0, ''),
(674, 79, 395, '5.00', '克', 0, '用於調製芡汁，讓醬汁能掛在豆腐的老皮上'),
(675, 79, 14, '20.00', '克', 0, ''),
(676, 79, 2, '10.00', '克', 0, '');

-- --------------------------------------------------------

--
-- 資料表結構 `recipe_tag`
--

CREATE TABLE `recipe_tag` (
  `recipe_tag_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `recipe_tag`
--

INSERT INTO `recipe_tag` (`recipe_tag_id`, `tag_id`, `recipe_id`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 2),
(5, 5, 2),
(6, 6, 2),
(7, 7, 3),
(8, 8, 3),
(9, 9, 3),
(10, 2, 4),
(11, 10, 4),
(12, 11, 4),
(13, 12, 5),
(14, 13, 5),
(15, 14, 5),
(16, 15, 6),
(17, 16, 6),
(18, 17, 6),
(19, 18, 7),
(20, 19, 7),
(21, 20, 7),
(22, 21, 8),
(23, 22, 8),
(24, 23, 8),
(25, 24, 9),
(26, 25, 9),
(27, 26, 9),
(28, 27, 10),
(29, 28, 10),
(30, 29, 10),
(31, 30, 11),
(32, 31, 11),
(33, 32, 11),
(34, 33, 12),
(35, 18, 12),
(36, 30, 12),
(37, 34, 13),
(38, 8, 13),
(39, 38, 13),
(40, 18, 14),
(41, 34, 14),
(42, 35, 14),
(43, 30, 15),
(44, 36, 15),
(45, 37, 15),
(46, 18, 16),
(47, 39, 16),
(48, 40, 16),
(49, 41, 17),
(50, 38, 17),
(51, 8, 17),
(52, 13, 18),
(53, 14, 18),
(54, 9, 18),
(55, 18, 19),
(56, 38, 19),
(57, 34, 19),
(58, 18, 20),
(59, 27, 20),
(60, 34, 20),
(61, 2, 21),
(62, 10, 21),
(63, 14, 21),
(64, 2, 22),
(65, 3, 22),
(66, 42, 22),
(67, 17, 23),
(68, 28, 23),
(69, 9, 23),
(70, 2, 24),
(71, 27, 24),
(72, 10, 24),
(73, 2, 25),
(74, 10, 25),
(75, 16, 25),
(76, 43, 26),
(77, 8, 26),
(78, 9, 26),
(79, 44, 27),
(80, 14, 27),
(81, 38, 27),
(82, 44, 28),
(83, 27, 28),
(84, 45, 28),
(85, 7, 29),
(86, 34, 29),
(87, 46, 29),
(88, 47, 30),
(89, 8, 30),
(90, 38, 30),
(91, 43, 31),
(92, 25, 31),
(93, 48, 31),
(94, 18, 32),
(95, 4, 32),
(96, 49, 32),
(97, 4, 33),
(98, 28, 33),
(99, 50, 33),
(100, 4, 34),
(101, 28, 34),
(102, 49, 34),
(103, 4, 35),
(104, 49, 35),
(105, 50, 35),
(106, 4, 36),
(107, 28, 36),
(108, 51, 36),
(109, 4, 37),
(110, 28, 37),
(111, 52, 37),
(112, 4, 38),
(113, 28, 38),
(114, 53, 38),
(115, 4, 39),
(116, 28, 39),
(117, 54, 39),
(118, 4, 40),
(119, 28, 40),
(120, 55, 40),
(121, 4, 41),
(122, 24, 41),
(123, 56, 41),
(124, 4, 42),
(125, 24, 42),
(126, 57, 42),
(127, 4, 43),
(128, 24, 43),
(129, 58, 43),
(130, 4, 44),
(131, 18, 44),
(132, 59, 44),
(133, 4, 45),
(134, 30, 45),
(135, 60, 45),
(136, 4, 46),
(137, 50, 46),
(138, 49, 46),
(139, 4, 47),
(140, 30, 47),
(141, 52, 47),
(142, 4, 48),
(143, 50, 48),
(144, 61, 48),
(145, 41, 49),
(146, 3, 49),
(147, 34, 49),
(148, 41, 50),
(149, 25, 50),
(150, 14, 50),
(151, 41, 51),
(152, 25, 51),
(153, 38, 51),
(154, 41, 52),
(155, 3, 52),
(156, 62, 52),
(157, 41, 53),
(158, 9, 53),
(159, 63, 53),
(160, 44, 54),
(161, 25, 54),
(162, 48, 54),
(163, 44, 55),
(164, 25, 55),
(165, 34, 55),
(166, 44, 56),
(167, 25, 56),
(168, 34, 56),
(169, 43, 57),
(170, 25, 57),
(171, 9, 57),
(172, 44, 58),
(173, 25, 58),
(174, 34, 58),
(175, 40, 59),
(176, 20, 59),
(177, 43, 59),
(178, 64, 60),
(179, 65, 60),
(180, 40, 60),
(181, 12, 61),
(182, 25, 61),
(183, 27, 61),
(184, 17, 62),
(185, 22, 62),
(186, 66, 62),
(187, 40, 63),
(188, 17, 63),
(189, 67, 63),
(190, 68, 64),
(191, 69, 64),
(192, 27, 64),
(193, 70, 65),
(194, 71, 65),
(195, 27, 65),
(196, 34, 66),
(197, 38, 66),
(198, 72, 66),
(199, 73, 67),
(200, 25, 67),
(201, 40, 67),
(202, 18, 68),
(203, 74, 68),
(204, 75, 68),
(205, 43, 69),
(206, 3, 69),
(207, 38, 69),
(208, 43, 70),
(209, 76, 70),
(210, 27, 70),
(211, 2, 71),
(212, 1, 71),
(213, 28, 71),
(214, 2, 72),
(215, 11, 72),
(216, 1, 72),
(217, 1, 73),
(218, 38, 73),
(219, 64, 73),
(220, 4, 74),
(221, 6, 74),
(222, 43, 74),
(223, 4, 75),
(224, 6, 75),
(225, 49, 75),
(226, 4, 76),
(227, 6, 76),
(228, 58, 76),
(229, 7, 77),
(230, 9, 77),
(231, 8, 77),
(232, 7, 78),
(233, 75, 78),
(234, 43, 78),
(235, 46, 79),
(236, 23, 79),
(237, 8, 79);

-- --------------------------------------------------------

--
-- 資料表結構 `remove_bg_ingredients`
--

CREATE TABLE `remove_bg_ingredients` (
  `id` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recipe_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recipe_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `remove_bg_ingredients`
--

INSERT INTO `remove_bg_ingredients` (`id`, `url`, `recipe_name`, `recipe_image_url`) VALUES
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

-- --------------------------------------------------------

--
-- 資料表結構 `reported_comments`
--

CREATE TABLE `reported_comments` (
  `reported_comment_id` int(11) NOT NULL,
  `comment_id` int(11) NOT NULL,
  `reporter_id` int(11) NOT NULL,
  `report_type` tinyint(4) NOT NULL,
  `report_reason` text NOT NULL,
  `status` tinyint(4) DEFAULT '0',
  `handler_id` int(11) DEFAULT NULL,
  `reported_at` datetime NOT NULL,
  `update_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 傾印資料表的資料 `reported_comments`
--

INSERT INTO `reported_comments` (`reported_comment_id`, `comment_id`, `reporter_id`, `report_type`, `report_reason`, `status`, `handler_id`, `reported_at`, `update_at`) VALUES
(1, 12, 2, 1, '在留言區發送加 LINE 領紅包的訊息，明顯是詐騙資訊。', 0, NULL, '2024-01-17 09:00:00', NULL),
(3, 60, 8, 2, '評論包含侮辱性字眼（髒話）並無端攻擊食譜作者。', 0, NULL, '2024-04-05 15:20:00', NULL),
(5, 4, 7, 2, '惡意辱罵作者抄襲但未提供任何具體理由，純屬挑釁。', 1, 2, '2024-01-06 10:15:00', '2024-01-06 11:00:00');

-- --------------------------------------------------------

--
-- 資料表結構 `reported_galleries`
--

CREATE TABLE `reported_galleries` (
  `reported_gallery_id` int(11) NOT NULL,
  `gallery_id` int(11) NOT NULL,
  `reporter_id` int(11) NOT NULL,
  `report_type` tinyint(4) NOT NULL,
  `report_reason` text NOT NULL,
  `status` tinyint(4) DEFAULT '0',
  `handler_id` int(11) DEFAULT NULL,
  `reported_at` datetime NOT NULL,
  `update_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 傾印資料表的資料 `reported_galleries`
--

INSERT INTO `reported_galleries` (`reported_gallery_id`, `gallery_id`, `reporter_id`, `report_type`, `report_reason`, `status`, `handler_id`, `reported_at`, `update_at`) VALUES
(1, 5, 5, 3, '盜用網路圖片且公然侮辱食譜作者，語氣極度惡劣。', 0, NULL, '2026-01-21 09:15:00', NULL),
(2, 12, 7, 1, '在成品分享區散佈疑似投資詐騙的 LINE 帳號資訊。', 1, 2, '2026-01-21 10:30:00', '2026-01-21 10:45:00'),
(3, 25, 8, 3, '涉及恐嚇與偏激謾罵，內容與食譜分享無關，純屬惡意鬧板。', 0, NULL, '2026-01-21 11:45:00', NULL);

-- --------------------------------------------------------

--
-- 資料表結構 `reported_recipes`
--

CREATE TABLE `reported_recipes` (
  `reported_recipe_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `reporter_id` int(11) NOT NULL,
  `report_type` tinyint(4) NOT NULL,
  `report_reason` text NOT NULL,
  `status` tinyint(4) DEFAULT '0',
  `handler_id` int(11) DEFAULT NULL,
  `reported_at` datetime NOT NULL,
  `update_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 傾印資料表的資料 `reported_recipes`
--

INSERT INTO `reported_recipes` (`reported_recipe_id`, `recipe_id`, `reporter_id`, `report_type`, `report_reason`, `status`, `handler_id`, `reported_at`, `update_at`) VALUES
(1, 6, 2, 2, '關於荷蘭醬的製作步驟，文中提到的攪拌溫度與實際操作有落差，容易導致油水分離，建議官方確認步驟描述。', 0, NULL, '2026-01-20 14:00:00', NULL),
(2, 11, 3, 1, '食譜下方的關聯商品連結點開後跳出大量與食譜無關的抽獎廣告，懷疑連結安全性。', 0, NULL, '2026-01-22 16:20:00', NULL),
(3, 14, 6, 4, '這道豆腐漢堡排的分類似乎放錯了，標籤標示為全素，但食材內含有豬絞肉，請官方修正分類。', 0, NULL, '2026-01-25 09:30:00', NULL);

-- --------------------------------------------------------

--
-- 資料表結構 `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `reviewer_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reviewer_avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `review_comment` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `review_rating` decimal(2,1) NOT NULL,
  `reviewed_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `steps`
--

CREATE TABLE `steps` (
  `step_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `step_order` int(11) DEFAULT NULL,
  `step_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step_total_time` time DEFAULT NULL,
  `step_content` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_modified` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `steps`
--

INSERT INTO `steps` (`step_id`, `recipe_id`, `step_order`, `step_title`, `step_total_time`, `step_content`, `step_image_url`, `is_modified`) VALUES
(1, 1, 1, '混合乾性食材', '00:05:00', '將高筋麵粉、酵母粉與鹽在攪拌盆中混合均勻。', 'img/recipes/1/steps/1.png', 0),
(2, 1, 2, '揉製麵糰', '00:15:00', '分次加入溫水與橄欖油，揉搓至麵糰表面光滑且不黏手。', 'img/recipes/1/steps/2.png', 0),
(3, 1, 3, '第一次發酵', '01:00:00', '蓋上濕布，放在溫暖處發酵 1 小時，直到麵糰變成兩倍大。', 'img/recipes/1/steps/3.png', 0),
(4, 1, 4, '麵糰整形與塗抹底醬', '00:10:00', '將發酵好的麵糰桿成圓餅狀，在表面均勻抹上一層番茄糊。', 'img/recipes/1/steps/4.png', 0),
(5, 1, 5, '鋪放配料', '00:05:00', '將新鮮莫札瑞拉起司切片或撕碎，均勻擺放在番茄糊上。', 'img/recipes/1/steps/5.png', 0),
(6, 1, 6, '烘烤', '00:15:00', '放入預熱至 230°C 的烤箱烘烤 12-15 分鐘，直到邊緣呈金黃色且起司融化。', 'img/recipes/1/steps/6.png', 0),
(7, 1, 7, '裝飾與出爐', '00:02:00', '出爐後放上新鮮羅勒葉，淋上少許特級初榨橄欖油即可享用。', 'img/recipes/1/steps/7.png', 0),
(8, 2, 1, '融化巧克力與奶油', '00:10:00', '將白巧克力與無鹽奶油放入碗中，隔水加熱至完全融化並拌勻，放涼備用。', 'img/recipes/2/steps/1.png', 0),
(9, 2, 2, '打發雞蛋與糖', '00:08:00', '將雞蛋與砂糖放入碗中，使用攪拌器打發至呈淡黃色且體積略微膨脹發泡。', 'img/recipes/2/steps/2.png', 0),
(10, 2, 3, '混合粉類', '00:05:00', '將低筋麵粉與抹茶粉過篩加入蛋糊中，以刮刀輕輕翻拌均勻。', 'img/recipes/2/steps/3.png', 0),
(11, 2, 4, '混合麵糊', '00:03:00', '將步驟1的巧克力奶油糊倒入抹茶蛋糊中，再次混合均勻成為蛋糕麵糊。', 'img/recipes/2/steps/4.png', 0),
(12, 2, 5, '入模準備', '00:05:00', '在模具內側塗抹少許奶油防沾，將麵糊平均倒入模具中約八分滿。', 'img/recipes/2/steps/5.png', 0),
(13, 2, 6, '烘烤', '00:10:00', '放入預熱 200°C 的烤箱烤 8-10 分鐘。觀察表面成型但輕按中心仍有柔軟感即可。', 'img/recipes/2/steps/6.png', 0),
(14, 2, 7, '出爐與脫模', '00:05:00', '出爐後稍放涼約 2-3 分鐘，小心脫模後擺盤即可享用。', 'img/recipes/2/steps/7.png', 0),
(15, 3, 1, '醃漬雞丁', '00:20:00', '雞肉丁中加入部分醬油、米酒與太白粉拌勻，醃漬約 20 分鐘使肉質入味且滑嫩。', 'img/recipes/3/steps/1.png', 0),
(16, 3, 2, '預熱與滑油', '00:05:00', '熱鍋下油，放入雞丁快速翻炒至表面變色（約八分熟）後立即撈起備用。', 'img/recipes/3/steps/2.png', 0),
(17, 3, 3, '爆香香料', '00:03:00', '原鍋留少許底油，放入乾辣椒段與花椒粒，小火煸炒至乾辣椒顏色轉深、散發麻辣香氣。', 'img/recipes/3/steps/3.png', 0),
(18, 3, 4, '入辛香料拌炒', '00:02:00', '加入薑片與蒜末爆香，與辣椒段、花椒粒混合均勻。', 'img/recipes/3/steps/4.png', 0),
(19, 3, 5, '回鍋與調味', '00:03:00', '將雞丁回鍋，加入剩餘醬油、砂糖與蔥段，大火快速翻炒均勻。', 'img/recipes/3/steps/5.png', 0),
(20, 3, 6, '勾芡與收汁', '00:01:00', '淋入少許芡汁（太白粉水），讓醬料均勻包裹在每一塊雞丁上。', 'img/recipes/3/steps/6.png', 0),
(21, 3, 7, '加入花生出爐', '00:01:00', '最後撒入去皮熟花生，迅速拌勻後即可出爐，以保持花生的酥脆口感。', 'img/recipes/3/steps/7.png', 0),
(22, 4, 1, '煮義大利麵', '00:10:00', '準備一鍋滾水並加入適量鹽巴，放入寬麵煮約 8-9 分鐘（比包裝建議少 1 分鐘），撈起並保留一碗煮麵水。', 'img/recipes/4/steps/1.png', 0),
(23, 4, 2, '爆香蒜末與奶油', '00:02:00', '平底鍋中放入無鹽奶油，加熱融化後放入蒜末，以中小火煸炒至香氣散發。', 'img/recipes/4/steps/2.png', 0),
(24, 4, 3, '拌炒野菇', '00:05:00', '放入鴻喜菇與香菇切片，轉大火將菇類水分炒乾，直至邊緣微焦呈金黃色。', 'img/recipes/4/steps/3.png', 0),
(25, 4, 4, '乳化醬汁', '00:03:00', '倒入鮮奶油與適量煮麵水，小火煮滾讓油脂與水分充分乳化。', 'img/recipes/4/steps/4.png', 0),
(26, 4, 5, '麵條合鍋', '00:02:00', '將煮好的寬麵放入鍋中，加入黑松露醬，均勻翻炒使麵條完整掛上醬汁。', 'img/recipes/4/steps/5.png', 0),
(27, 4, 6, '調味與收汁', '00:02:00', '加入帕瑪森起司粉攪拌至濃稠，撒上少許黑胡椒粉調味即可起鍋。', 'img/recipes/4/steps/6.png', 0),
(28, 5, 1, '備料', '00:10:00', '將雞腿肉切成一口大小，圓茄子去蒂頭後切成半月形塊狀備用。', 'img/recipes/5/steps/1.png', 0),
(29, 5, 2, '炒製咖哩底醬', '00:05:00', '鍋中放入少許橄欖油，以中小火將青咖哩醬炒至散發香氣且油脂微微滲出。', 'img/recipes/5/steps/2.png', 0),
(30, 5, 3, '加入椰奶', '00:03:00', '分兩至三次緩緩加入椰奶，每次加入皆需與咖哩醬完全拌勻，直到成濃稠亮澤的綠色醬汁。', 'img/recipes/5/steps/3.png', 0),
(31, 5, 4, '烹煮肉類與蔬菜', '00:05:00', '加入雞腿肉丁煮至轉白，隨後放入圓茄子塊與手撕的檸檬葉。', 'img/recipes/5/steps/4.png', 0),
(32, 5, 5, '燉煮與調味', '00:15:00', '轉小火燉煮約 15 分鐘直到茄子變軟熟透。加入魚露與椰糖拌勻，調整出鮮鹹帶微甜的風味。', 'img/recipes/5/steps/5.png', 0),
(33, 5, 6, '提香與完成', '00:02:00', '最後撒入新鮮泰式羅勒葉，稍微拌勻後即可熄火盛盤。', 'img/recipes/5/steps/6.png', 0),
(34, 6, 1, '調製荷蘭醬基底', '00:05:00', '取一鋼盆放入生蛋黃與檸檬汁，架在熱水鍋上方（不接觸水面），持續攪拌至蛋液發泡且變淺色。', 'img/recipes/6/steps/1.png', 0),
(35, 6, 2, '乳化荷蘭醬', '00:05:00', '慢慢分次加入融化的無鹽奶油，持續快速攪拌至液體呈濃稠滑順的醬汁狀，加鹽調味後保溫備用。', 'img/recipes/6/steps/2.png', 0),
(36, 6, 3, '準備煮蛋水', '00:05:00', '煮一鍋水至微滾狀態（冒小泡），加入白醋，白醋能幫助蛋白凝固。', 'img/recipes/6/steps/3.png', 0),
(37, 6, 4, '製作水波蛋', '00:05:00', '在水中攪拌出微弱渦流，將蛋打入碗中後滑入鍋心，小火煮約 3 分鐘，待蛋白凝固但蛋黃仍半熟，撈起瀝乾。', 'img/recipes/6/steps/4.png', 0),
(38, 6, 5, '烘烤馬芬與煎培根', '00:05:00', '將英式馬芬橫切並烤至酥脆金黃；同時將加拿大培根稍微煎香。', 'img/recipes/6/steps/5.png', 0),
(39, 6, 6, '組合與裝飾', '00:02:00', '依序放上馬芬、培根、水波蛋，淋上豐厚的荷蘭醬，最後撒上少許紅椒粉即可。', 'img/recipes/6/steps/6.png', 0),
(40, 7, 1, '加熱高湯', '00:05:00', '將豚骨高湯倒入鍋中，以中火加熱至微沸狀態，保持熱度備用。', 'img/recipes/7/steps/1.png', 0),
(41, 7, 2, '預熱湯碗與底醬', '00:02:00', '在拉麵碗中倒入拉麵味醂醬汁。若有溫碗習慣，可先用熱水沖碗後倒掉再放醬汁。', 'img/recipes/7/steps/2.png', 0),
(42, 7, 3, '烹煮麵條', '00:03:00', '準備另一鍋大滾水，散開拉麵麵條放入，依照喜好的軟硬度煮約 2-3 分鐘。', 'img/recipes/7/steps/3.png', 0),
(43, 7, 4, '沖湯與濾麵', '00:01:00', '將沸騰的高湯沖入裝有醬汁的碗中攪拌均勻。將煮好的麵條徹底瀝乾水分放入湯中。', 'img/recipes/7/steps/4.png', 0),
(44, 7, 5, '整理麵條與配料', '00:02:00', '用筷子將麵條挑順整齊，依序擺上日式叉燒肉片、木耳絲與筍片。', 'img/recipes/7/steps/5.png', 0),
(45, 7, 6, '最終裝飾', '00:01:00', '將溏心蛋對切擺放，撒上青蔥花，並在碗邊插上兩片海苔，即可趁熱享用。', 'img/recipes/7/steps/6.png', 0),
(46, 8, 1, '處理鷹嘴豆與大蒜', '00:03:00', '將煮熟的鷹嘴豆充分瀝乾水分，放入食物處理機中；大蒜去皮切半後一同放入。', 'img/recipes/8/steps/1.png', 0),
(47, 8, 2, '初步攪碎', '00:02:00', '先將鷹嘴豆與大蒜攪打成粗碎狀，這有助於後續混合更均勻。', 'img/recipes/8/steps/2.png', 0),
(48, 8, 3, '加入核心醬料', '00:02:00', '加入塔希尼芝麻醬、檸檬汁、孜然粉與鹽巴。', 'img/recipes/8/steps/3.png', 0),
(49, 8, 4, '乳化與調整稠度', '00:05:00', '啟動處理機，在攪打過程中慢慢淋入橄欖油與冰水。冰水能讓豆泥顏色更白皙且質地更蓬鬆。', 'img/recipes/8/steps/4.png', 0),
(50, 8, 5, '裝盛與裝飾', '00:03:00', '將打好的豆泥挖入盤中，用湯匙背面壓出螺旋狀凹槽，淋上額外的橄欖油，可隨喜好撒上紅椒粉或搭配口袋餅享用。', 'img/recipes/8/steps/5.png', 0),
(51, 9, 1, '處理洋蔥', '00:10:00', '將黃洋蔥去皮對半切開，順著纖維切成一致的薄絲，這有助於後續受熱均勻。', 'img/recipes/9/steps/1.png', 0),
(52, 9, 2, '慢炒焦糖化', '00:40:00', '鍋中放入奶油融化，加入洋蔥絲，以中小火持續拌炒 30-40 分鐘。過程中若太乾可滴少許水，直到洋蔥呈深咖啡色的焦糖狀態。', 'img/recipes/9/steps/2.png', 0),
(53, 9, 3, '白酒熗鍋', '00:03:00', '倒入白葡萄酒，利用酒液刨開鍋底沉積的焦香物質 (Deglazing)，攪拌至酒精略微蒸發。', 'img/recipes/9/steps/3.png', 0),
(54, 9, 4, '燉煮湯底', '00:20:00', '加入牛高湯與新鮮百里香，大火煮滾後轉小火，蓋上鍋蓋微滾燉煮約 20 分鐘，使風味融合。', 'img/recipes/9/steps/4.png', 0),
(55, 9, 5, '基礎調味', '00:02:00', '移除百里香梗，加入鹽與黑胡椒調整至適當口味，將湯盛入可耐高溫烤箱的碗中。', 'img/recipes/9/steps/5.png', 0),
(56, 9, 6, '焗烤準備', '00:05:00', '在湯面上各放上兩片法式長棍麵包，並在麵包上鋪滿厚厚的格魯耶爾起司碎。', 'img/recipes/9/steps/6.png', 0),
(57, 9, 7, '烘烤完成', '00:05:00', '放入預熱好的烤箱（或使用上火功能），烤至起司起泡、呈現微焦的金黃棕色即可出爐。', 'img/recipes/9/steps/7.png', 0),
(58, 10, 1, '處理虎蝦', '00:10:00', '將大虎蝦剪去鬚足，並用牙籤從蝦背第二節挑出腸泥，洗淨後用紙巾擦乾水分。', 'img/recipes/10/steps/1.png', 0),
(59, 10, 2, '醃漬調味', '00:15:00', '蝦身放入碗中，均勻抹上鹽、黑胡椒粉與大部分的蒜末，靜置 15 分鐘使之入味。', 'img/recipes/10/steps/2.png', 0),
(60, 10, 3, '擺盤準備', '00:05:00', '烤盤鋪上烘焙紙，擺放好醃漬好的蝦，在蝦身上點綴少許奶油塊與檸檬切片。', 'img/recipes/10/steps/3.png', 0),
(61, 10, 4, '烘烤', '00:15:00', '放入預熱至 180°C 的烤箱中層，烘烤約 15 分鐘，直到蝦身完全轉紅並微彎曲。', 'img/recipes/10/steps/4.png', 0),
(62, 10, 5, '出爐裝飾', '00:02:00', '取出後淋上剩餘的鮮檸檬汁，並撒上新鮮巴西里碎增加香氣與視覺層次。', 'img/recipes/10/steps/5.png', 0),
(63, 11, 1, '雞胸肉醃漬', '00:05:00', '將雞胸肉洗淨擦乾，兩面均勻抹上鹽與黑胡椒粉調味。', 'img/recipes/11/steps/1.png', 0),
(64, 11, 2, '真空密封', '00:02:00', '將雞胸肉放入耐熱密封袋中，排盡空氣後封口，可加入少許橄欖油增加肉質滑潤感。', 'img/recipes/11/steps/2.png', 0),
(65, 11, 3, '低溫舒肥', '01:00:00', '將水浴鍋預熱至 60°C，放入雞胸肉進行舒肥，持續 1 小時。', 'img/recipes/11/steps/3.png', 0),
(66, 11, 4, '烹煮藜麥飯', '00:30:00', '將白米與藜麥洗淨後，以 1:1.1 的水米比例放入電鍋煮熟，完成後悶 10 分鐘更香 Q。', 'img/recipes/11/steps/4.png', 0),
(67, 11, 5, '水煮時蔬', '00:05:00', '花椰菜與玉米筍切至適當大小，放入加了少許鹽的滾水中燙熟，撈起瀝乾備用。', 'img/recipes/11/steps/5.png', 0),
(68, 11, 6, '切片與盛盤', '00:03:00', '將舒肥完的雞胸肉取出切成厚片。碗中盛裝藜麥飯，鋪上雞胸肉，並依序擺放花椰菜與玉米筍即可。', 'img/recipes/11/steps/6.png', 0),
(69, 12, 1, '糙米浸泡與烹煮', '00:40:00', '糙米洗淨後先浸泡 30 分鐘，放入電鍋以 1:1.2 的比例加水煮熟備用。', 'img/recipes/12/steps/1.png', 0),
(70, 12, 2, '鮭魚預處理', '00:05:00', '鮭魚菲力洗淨後用廚房紙巾徹底抹乾表面水分，兩面撒上少許海鹽靜置片刻。', 'img/recipes/12/steps/2.png', 0),
(71, 12, 3, '香煎鮭魚', '00:08:00', '取一平底鍋充分預熱（不放油），魚皮朝下放入，中小火煎至魚皮酥脆上色，再翻面煎至全熟撈起。', 'img/recipes/12/steps/3.png', 0),
(72, 12, 4, '魚油炒時蔬', '00:05:00', '利用鍋中剩餘的天然鮭魚油，放入四季豆與紅蘿蔔絲，加少許鹽快速翻炒至熟透。', 'img/recipes/12/steps/4.png', 0),
(73, 12, 5, '便當組裝', '00:02:00', '在便當盒中盛入糙米飯，鋪上煎好的鮭魚，擺放四季豆與紅蘿蔔，最後放上一片檸檬增添香氣。', 'img/recipes/12/steps/5.png', 0),
(74, 13, 1, '肉品斷筋與拍鬆', '00:05:00', '將里肌豬排洗淨擦乾，用刀背均勻交叉拍打肉身，使組織鬆軟，並切斷邊緣白色筋膜防止受熱捲曲。', 'img/recipes/13/steps/1.png', 0),
(75, 13, 2, '醃漬入味', '00:15:00', '將豬排放入碗中，加入蒜末、醬油、味醂與米酒拌勻，靜置醃漬 15 分鐘。', 'img/recipes/13/steps/2.png', 0),
(76, 13, 3, '煎製豬排', '00:06:00', '熱鍋加入橄欖油，放入豬排，中火煎至兩面呈金黃焦香且完全熟透後撈起。', 'img/recipes/13/steps/3.png', 0),
(77, 13, 4, '拌炒毛豆', '00:04:00', '利用原鍋餘油與剩餘醃汁放入毛豆仁，大火快速翻炒至毛豆熟透並收汁入味。', 'img/recipes/13/steps/4.png', 0),
(78, 13, 5, '切條與盛盤', '00:02:00', '將煎好的豬排切成條狀，與炒好的毛豆一同盛入盤中即可享用。', 'img/recipes/13/steps/5.png', 0),
(79, 14, 1, '豆腐脫水與處理', '00:15:00', '板豆腐用重物壓約 15 分鐘除去多餘水分，接著放入碗中用手捏成碎末狀。', 'img/recipes/14/steps/1.png', 0),
(80, 14, 2, '揉製肉糰', '00:05:00', '將豬絞肉、豆腐碎、洋蔥丁與少許鹽放入盆中，持續抓揉至產生黏性。', 'img/recipes/14/steps/2.png', 0),
(81, 14, 3, '整形肉餅', '00:05:00', '將混合好的肉糰分成適當大小，在雙手間來回拍打排出空氣，捏成圓盤餅狀。', 'img/recipes/14/steps/3.png', 0),
(82, 14, 4, '煎製漢堡排', '00:08:00', '熱鍋加入橄欖油，放入漢堡排，中小火煎至兩面全熟且呈現誘人金黃色後取出盛盤。', 'img/recipes/14/steps/4.png', 0),
(83, 14, 5, '製作野菇醬汁', '00:05:00', '利用原鍋餘油放入鴻喜菇與香菇炒軟，加入醬油膏與少許水煮至濃稠。', 'img/recipes/14/steps/5.png', 0),
(84, 14, 6, '淋醬完成', '00:02:00', '將煮好的野菇醬汁均勻淋在漢堡排上即可上桌。', 'img/recipes/14/steps/6.png', 0),
(85, 15, 1, '墊底與堆疊', '00:05:00', '撕一張大於魚片兩倍長的烘焙紙鋪在烤盤上，中心處先鋪上洋蔥絲墊底，再放上洗淨抹乾的鯛魚片。', 'img/recipes/15/steps/1.png', 0),
(86, 15, 2, '擺放配菜與調味', '00:03:00', '在魚片上擺放蘆筍與檸檬切片，均勻撒上粗海鹽、新鮮百里香葉，最後淋入一匙白葡萄酒。', 'img/recipes/15/steps/2.png', 0),
(87, 15, 3, '紙包密封', '00:02:00', '將烘焙紙兩端對折，由邊緣開始像折水餃摺痕般緊密捲起封口，確保蒸氣不會散失。', 'img/recipes/15/steps/3.png', 0),
(88, 15, 4, '烘烤過程', '00:15:00', '放入預熱至 200°C 的烤箱中層，烘烤約 15 分鐘。此時紙包會微微鼓起是正常現象。', 'img/recipes/15/steps/4.png', 0),
(89, 15, 5, '出爐享用', '00:02:00', '取出紙包直接放在餐盤上，小心地用剪刀剪開中心（注意高溫蒸氣），趁熱享用。', 'img/recipes/15/steps/5.png', 0),
(90, 16, 1, '炒香洋蔥', '00:05:00', '熱鍋不放油或放極少許油，放入洋蔥絲中火翻炒，直至洋蔥變軟並呈現透明感。', 'img/recipes/16/steps/1.png', 0),
(91, 16, 2, '熬煮壽喜燒醬汁', '00:03:00', '在鍋中加入醬油、砂糖與味醂（比例約為醬油1：糖0.5：味醂1），煮滾讓糖完全溶解。', 'img/recipes/16/steps/2.png', 0),
(92, 16, 3, '涮煮牛肉', '00:03:00', '將牛五花肉片平鋪於洋蔥醬汁上，煮至肉片轉紅褐色約八分熟。', 'img/recipes/16/steps/3.png', 0),
(93, 16, 4, '淋蛋液與悶煮', '00:01:00', '將雞蛋粗略打散，由鍋中心向外圓圈狀淋入。蓋上鍋蓋悶 30 秒，待蛋液呈半熟歐姆蛋狀即可關火。', 'img/recipes/16/steps/4.png', 0),
(94, 16, 5, '盛碗與點綴', '00:02:00', '將整鍋配料與醬汁平滑地推淋在熱騰騰的白飯上，撒上蔥花即可享用。', 'img/recipes/16/steps/5.png', 0),
(95, 17, 1, '爆香洋蔥', '00:03:00', '熱鍋加入橄欖油，放入洋蔥絲以中火炒至軟化且散發甜味。', 'img/recipes/17/steps/1.png', 0),
(96, 17, 2, '拌炒豬肉', '00:05:00', '加入梅花豬肉片轉大火翻炒，直至肉片變色約八分熟。', 'img/recipes/17/steps/2.png', 0),
(97, 17, 3, '加入泡菜與辣醬', '00:05:00', '放入韓式泡菜與韓式辣醬，持續翻炒使泡菜汁與辣醬均勻包裹在肉片上。', 'img/recipes/17/steps/3.png', 0),
(98, 17, 4, '下蔥段提味', '00:02:00', '加入青蔥段快速拌炒至斷生，即可關火。', 'img/recipes/17/steps/4.png', 0),
(99, 17, 5, '盛盤撒芝麻', '00:01:00', '將料理盛入盤中，均勻撒上白芝麻增添香氣與層次感。', 'img/recipes/17/steps/5.png', 0),
(100, 18, 1, '蔬菜炒香', '00:08:00', '熱鍋加入橄欖油，放入洋蔥塊炒至半透明，隨後加入馬鈴薯與紅蘿蔔塊翻炒，讓蔬菜表面微焦帶出甜味。', 'img/recipes/18/steps/1.png', 0),
(101, 18, 2, '煎製雞肉', '00:05:00', '將雞腿肉塊放入鍋中，與蔬菜一同拌炒至外皮呈現誘人的金黃色。', 'img/recipes/18/steps/2.png', 0),
(102, 18, 3, '燉煮食材', '00:15:00', '倒入清水沒過食材，大火煮滾後撇去表面浮沫，轉小火蓋上鍋蓋燉煮約 15 分鐘直到蔬菜熟軟。', 'img/recipes/18/steps/3.png', 0),
(103, 18, 4, '融化咖哩塊', '00:05:00', '暫時關火（防止結塊），將咖哩塊放入鍋中攪拌至完全融化。', 'img/recipes/18/steps/4.png', 0),
(104, 18, 5, '二次燉煮', '00:05:00', '重新開小火，持續攪拌燉煮至醬汁呈現適當的濃稠度。', 'img/recipes/18/steps/5.png', 0),
(105, 18, 6, '奶香點綴', '00:02:00', '起鍋前加入鮮奶油（或鮮乳）快速拌勻，讓色澤轉為溫潤的淺棕色，並增加濃郁乳香味後即可盛盤。', 'img/recipes/18/steps/6.png', 0),
(106, 19, 1, '調製味增薑汁', '00:03:00', '將薑磨成泥，與味噌、味醂、米酒放入小碗中攪拌均勻，直到味噌完全溶解成為特製醬汁。', 'img/recipes/19/steps/1.png', 0),
(107, 19, 2, '處理高麗菜', '00:05:00', '將高麗菜洗淨切成極細絲，放入冰水中浸泡片刻使其更為清脆，瀝乾後鋪在盤底備用。', 'img/recipes/19/steps/2.png', 0),
(108, 19, 3, '煎製肉片', '00:05:00', '熱鍋加入少許油，放入豬腹肉片攤平中火煎炒，直至兩面變色且邊緣微帶焦香。', 'img/recipes/19/steps/3.png', 0),
(109, 19, 4, '醬汁翻炒', '00:05:00', '倒入調好的味增薑汁醬，大火快速翻炒，讓醬汁均勻裹上每片肉片並略微濃縮收汁。', 'img/recipes/19/steps/4.png', 0),
(110, 19, 5, '盛盤', '00:02:00', '將熱騰騰的燒肉盛放在鋪好的高麗菜絲上，即可端上桌享用。', 'img/recipes/19/steps/5.png', 0),
(111, 20, 1, '鮭魚預處理', '00:05:00', '將鮭魚菲力洗淨，使用廚房紙巾徹底擦乾表面水分，在雙面抹上極少許鹽巴靜置片刻。', 'img/recipes/20/steps/1.png', 0),
(112, 20, 2, '調製照燒醬汁', '00:03:00', '將醬油、味醂、砂糖、米酒與薑泥混合均勻備用，確保砂糖略微溶解。', 'img/recipes/20/steps/2.png', 0),
(113, 20, 3, '水煮配菜', '00:05:00', '準備一鍋滾水加入少許鹽，放入青花菜燙熟後撈起，瀝乾擺入盤中備用。', 'img/recipes/20/steps/3.png', 0),
(114, 20, 4, '煎製鮭魚', '00:08:00', '熱鍋加入橄欖油，鮭魚皮朝下放入，以中火煎至皮酥脆上色，翻面繼續煎至約八分熟。', 'img/recipes/20/steps/4.png', 0),
(115, 20, 5, '掛漿收汁', '00:04:00', '倒入調好的照燒醬汁，轉小火熬煮。用湯匙不斷將醬汁淋在魚排上，直到醬汁濃縮至濃稠且均勻附著。', 'img/recipes/20/steps/5.png', 0),
(116, 20, 6, '盛盤裝飾', '00:01:00', '將鮭魚盛放在青花菜旁，撒上白芝麻與蔥絲點綴，增加香氣層次。', 'img/recipes/20/steps/6.png', 0),
(117, 21, 1, '炒香蔬菜底', '00:08:00', '熱鍋加入橄欖油，放入洋蔥丁、大蒜末與紅蘿蔔丁，以中小火翻炒至洋蔥變軟呈半透明狀。', 'img/recipes/21/steps/1.png', 0),
(118, 21, 2, '炒製絞肉', '00:05:00', '加入牛豬混合絞肉，用鏟子將肉切碎並炒至變色溢出油脂香氣。', 'img/recipes/21/steps/2.png', 0),
(119, 21, 3, '熬煮肉醬', '00:25:00', '加入番茄糊翻炒出香氣，隨後倒入罐裝碎番茄與義大利香料，加入少許水或煮麵水，小火燉煮約 25 分鐘至醬汁濃稠。', 'img/recipes/21/steps/3.png', 0),
(120, 21, 4, '烹煮麵條', '00:10:00', '準備一鍋滾水加入鹽巴，放入義大利直麵煮至八分熟（比包裝建議少 1-2 分鐘）。', 'img/recipes/21/steps/4.png', 0),
(121, 21, 5, '混合拌炒', '00:03:00', '將煮好的麵條撈起直接放入肉醬鍋中，加入少許煮麵水快速翻炒，讓麵條吸收醬汁。', 'img/recipes/21/steps/5.png', 0),
(122, 21, 6, '盛盤與裝飾', '00:01:00', '將麵條捲起盛入盤中，撒上大量的帕瑪森起司粉，即可趁熱享用。', 'img/recipes/21/steps/6.png', 0),
(123, 22, 1, '野菇煸炒', '00:08:00', '鍋中放入部分無鹽奶油，將鴻喜菇與香菇片放入，以中大火炒至水分收乾且表面焦香，撈起備用。', 'img/recipes/22/steps/1.png', 0),
(124, 22, 2, '炒香燉米', '00:05:00', '原鍋補入奶油與洋蔥末炒至透明，加入義大利燉米翻炒，使米粒均勻裹上油脂，直到邊緣呈現透明狀。', 'img/recipes/22/steps/2.png', 0),
(125, 22, 3, '白酒熗鍋與初步燉煮', '00:05:00', '倒入白葡萄酒，利用酒液刨開鍋底焦垢，持續攪拌直到酒氣蒸發且液體被米粒吸收。', 'img/recipes/22/steps/3.png', 0),
(126, 22, 4, '分次加入高湯', '00:20:00', '轉中小火，分次加入溫熱的雞高湯（每次約一杓），需不斷攪拌讓米粒釋放澱粉，待高湯被完全吸收後再加下一杓，持續約 18-20 分鐘。', 'img/recipes/22/steps/4.png', 0),
(127, 22, 5, '加入核心配料', '00:04:00', '當米粒達到外軟內 Q (Al dente) 的口感時，拌入先前炒好的野菇、鮮奶油與黑松露醬，攪拌均勻。', 'img/recipes/22/steps/5.png', 0),
(128, 22, 6, '熄火乳化 (Mantecatura)', '00:03:00', '熄火，加入剩下的奶油與帕瑪森起司粉，快速攪拌產生乳化效果，讓醬汁呈現絲滑黏稠狀後即可盛盤。', 'img/recipes/22/steps/6.png', 0),
(129, 23, 1, '清潔與醃漬', '01:05:00', '將雞翅洗淨並徹底用廚房紙巾擦乾表面水分。在大型密封袋或碗中放入雞翅、橄欖油及紐奧良醃料（紅椒粉、蒜粉、洋蔥粉、黑胡椒、鹽、砂糖），均勻揉捏使香料覆蓋全體，密封醃漬至少 1 小時（醃過夜效果更佳）。', 'img/recipes/23/steps/1.png', 0),
(130, 23, 2, '預熱烤箱', '00:05:00', '烤箱預熱至 200°C。在烤盤上放上烤網，這能讓雞翅在烘烤時熱氣流通，表皮更為酥脆。', 'img/recipes/23/steps/2.png', 0),
(131, 23, 3, '首次烘烤', '00:18:00', '將醃漬好的雞翅整齊排列在烤網上，放入烤箱烘烤約 15-20 分鐘，直到肉質熟透且表皮開始轉金黃色。', 'img/recipes/23/steps/3.png', 0),
(132, 23, 4, '調製與刷蜂蜜水', '00:02:00', '將蜂蜜與等比例的少量溫水混勻。取出雞翅，在表面均勻刷上一層薄薄的蜂蜜水。', 'img/recipes/23/steps/4.png', 0),
(133, 23, 5, '二次烘烤上色', '00:04:00', '將刷好醬的雞翅回爐再烤 3-5 分鐘。期間需密切觀察，直到表面呈現油亮誘人的焦糖棕色。', 'img/recipes/23/steps/5.png', 0),
(134, 23, 6, '盛盤與享用', '00:01:00', '出爐後稍微靜置 1-2 分鐘，讓肉汁回流，即可盛盤趁熱享用。', 'img/recipes/23/steps/6.png', 0),
(135, 24, 1, '煮麵與備料', '00:10:00', '準備一鍋滾水加入鹽巴，放入義大利細扁麵煮約 8 分鐘（比包裝建議時間少 2 分鐘），撈起並保留一碗煮麵水。', 'img/recipes/24/steps/1.png', 0),
(136, 24, 2, '煸香底味', '00:03:00', '平底鍋中放入特級初榨橄欖油，以低溫煸炒蒜片與乾辣椒絲，直到蒜片呈現微金黃色且香氣溢出。', 'img/recipes/24/steps/2.png', 0),
(137, 24, 3, '悶煮蛤蜊', '00:05:00', '轉大火放入新鮮蛤蜊，倒入白葡萄酒後立即蓋上鍋蓋，悶煮至蛤蜊全部彈開，隨即將蛤蜊暫時撈起以防過老。', 'img/recipes/24/steps/3.png', 0),
(138, 24, 4, '乳化拌炒', '00:03:00', '將煮好的麵條與少許煮麵水加入鍋中的蛤蜊原汁，轉大火快速拌炒，利用澱粉水讓油水混合乳化成濃稠醬汁。', 'img/recipes/24/steps/4.png', 0),
(139, 24, 5, '裝飾與收尾', '00:02:00', '將蛤蜊倒回鍋中拌勻，撒上新鮮巴西里碎，最後淋上一匙初榨橄欖油增加光澤與香氣，即可盛盤。', 'img/recipes/24/steps/5.png', 0),
(140, 25, 1, '調製蛋黃起司醬', '00:05:00', '在碗中放入 2 顆蛋黃、帕瑪森起司粉、鮮奶油與大量的現磨黑胡椒粒，攪拌均勻至略微濃稠的糊狀備用。', 'img/recipes/25/steps/1.png', 0),
(141, 25, 2, '烹煮麵條', '00:10:00', '準備一鍋滾水加入鹽巴，放入義大利直麵煮至彈牙 (Al dente)，撈起並保留一小碗煮麵水。', 'img/recipes/25/steps/2.png', 0),
(142, 25, 3, '煸炒培根', '00:05:00', '平底鍋不放油，放入培根條以中小火煸炒，直到培根邊緣呈現焦脆色澤且釋放出天然油脂。', 'img/recipes/25/steps/3.png', 0),
(143, 25, 4, '混合麵條與油脂', '00:02:00', '將煮好的麵條直接撈入培根鍋中快速翻炒，讓每根麵條均勻包裹上培根的油脂。', 'img/recipes/25/steps/4.png', 0),
(144, 25, 5, '離火乳化（關鍵步驟）', '00:03:00', '將平底鍋熄火並移開熱源。稍微降溫後倒入步驟 1 的蛋黃糊，快速持續攪拌，利用麵條與鍋具的餘溫使蛋液乳化成滑順醬汁，避免過熱變成炒蛋。', 'img/recipes/25/steps/5.png', 0),
(145, 25, 6, '調整稠度與盛盤', '00:02:00', '若醬汁太過濃稠，可加入少許煮麵水調整至理想狀態。盛盤後撒上額外的黑胡椒即可。', 'img/recipes/25/steps/6.png', 0),
(146, 26, 1, '低溫煸薑', '00:05:00', '鍋中倒入黑芝麻油，以小火慢慢煸炒老薑片，直到薑片邊緣呈現微捲曲的焦香狀態（注意火候不可太大，避免麻油發苦）。', 'img/recipes/26/steps/1.png', 0),
(147, 26, 2, '爆香與煎肉', '00:05:00', '放入整粒大蒜與紅辣椒段爆香，隨後轉大火，加入雞腿肉塊翻炒，直到肉表面呈現焦糖金黃色。', 'img/recipes/26/steps/2.png', 0),
(148, 26, 3, '燉煮入味', '00:10:00', '倒入醬油、米酒與砂糖。大火燒開煮出醬香後，轉小火蓋上鍋蓋悶煮約 10 分鐘，使肉質軟嫩且均勻上色。', 'img/recipes/26/steps/3.png', 0),
(149, 26, 4, '大火收汁', '00:05:00', '打開鍋蓋轉大火快速翻炒收汁，直到醬汁濃縮並呈現黏稠光澤，緊緊裹在雞塊上。', 'img/recipes/26/steps/4.png', 0),
(150, 26, 5, '九層塔提味', '00:01:00', '熄火。撒入大量的九層塔（泰式羅勒），利用鍋中的餘溫快速拌炒均勻，逼出強烈香氣後即可起鍋盛盤。', 'img/recipes/26/steps/5.png', 0),
(151, 27, 1, '汆燙去雜質', '00:10:00', '五花肉切成 3 公分見方的塊狀。冷水下鍋，加入少許薑片與米酒一起煮沸，燙出浮沫後撈起，用冷水沖洗乾淨並瀝乾備用。', 'img/recipes/27/steps/1.png', 0),
(152, 27, 2, '乾煸出油', '00:08:00', '熱鍋不放油，將肉塊下鍋以中火煸炒，直到五花肉本身的豬油釋出，且表面呈現微微金黃焦香。', 'img/recipes/27/steps/2.png', 0),
(153, 27, 3, '炒糖色與爆香', '00:05:00', '放入冰糖拌炒至融化並呈現琥珀色，讓肉塊均勻裹上糖色，隨後放入蔥段、薑片、大蒜粒翻炒出香氣。', 'img/recipes/27/steps/3.png', 0),
(154, 27, 4, '慢火燉煮', '00:50:00', '倒入醬油與米酒，加入淹過肉塊的水。大火燒開後轉小火，蓋上鍋蓋燉煮約 45-60 分鐘，直到肉質達到理想的軟糯程度。', 'img/recipes/27/steps/4.png', 0),
(155, 27, 5, '大火收汁', '00:05:00', '打開鍋蓋轉大火，將餘下的醬汁濃縮收乾，直到醬汁呈現黏稠狀且緊緊掛在紅燒肉上，色澤更趨油亮即可出爐。', 'img/recipes/27/steps/5.png', 0),
(156, 28, 1, '魚身處理與去腥', '00:05:00', '將鱸魚洗淨並徹底擦乾，在魚身兩側各斜劃 2-3 刀以便受熱均勻。在盤底鋪上少許蔥段與薑片，將魚放上後，表面再鋪上一層薑絲。', 'img/recipes/28/steps/1.png', 0),
(157, 28, 2, '大火清蒸', '00:10:00', '準備蒸鍋，水滾後放入魚盤，蓋上鍋蓋以大火蒸 8-10 分鐘。蒸好後關火悶 2 分鐘（可用筷子輕戳魚肉，若能輕易穿透即熟透）。', 'img/recipes/28/steps/2.png', 0),
(158, 28, 3, '瀝乾倒湯', '00:02:00', '取出魚盤，將盤中帶有腥味的魚湯倒掉，移除蒸過的薑絲與蔥段，重新鋪上新鮮的青蔥絲與辣椒絲。', 'img/recipes/28/steps/3.png', 0),
(159, 28, 4, '熱油潑淋（關鍵步驟）', '00:02:00', '小鍋中將橄欖油燒至微微冒煙，迅速將熱油淋在蔥絲與辣椒絲上，利用高溫激發辛香料的香氣。', 'img/recipes/28/steps/4.png', 0),
(160, 28, 5, '澆淋醬油', '00:01:00', '最後沿著魚盤邊緣澆上蒸魚醬油（不要直接淋在魚肉表面，以保持外觀與鮮甜），即可上桌。', 'img/recipes/28/steps/5.png', 0),
(161, 29, 1, '豆腐預處理', '00:08:00', '將板豆腐切成 2 公分的小方塊。準備一鍋水加入少許鹽煮沸，放入豆腐汆燙 2 分鐘。這能去除豆腥味並使豆腐結構更緊實，不易在後續燒煮時破碎。', 'img/recipes/29/steps/1.png', 0),
(162, 29, 2, '煸炒肉末與紅油', '00:05:00', '熱鍋不放油，先放入豬絞肉煸炒至乾香吐油，接著加入蒜末、薑泥與辣豆瓣醬，以中小火炒出紅油與豆香味。', 'img/recipes/29/steps/2.png', 0),
(163, 29, 3, '燒煮入味', '00:07:00', '倒入醬油、糖與清水煮沸，輕輕放入瀝乾的豆腐塊。轉小火慢燒，期間可用鏟背輕輕推動，讓豆腐吸收醬汁精華。', 'img/recipes/29/steps/3.png', 0),
(164, 29, 4, '勾芡收汁', '00:03:00', '將太白粉與水以 1:2 比例調勻。分三次緩緩淋入鍋中，邊淋邊推動，直到醬汁濃稠並緊緊裹住豆腐。', 'img/recipes/29/steps/4.png', 0),
(165, 29, 5, '完成與盛盤', '00:02:00', '盛盤後撒上大量蔥花，最後依照個人喜好撒上花椒粉，增加香氣層次。', 'img/recipes/29/steps/5.png', 0),
(166, 30, 1, '魷魚泡發與切絲', '00:15:00', '乾魷魚事先用溫鹽水泡發約 2-3 小時至軟化，洗淨後逆紋切成細長條狀備用。', 'img/recipes/30/steps/1.png', 0),
(167, 30, 2, '五花肉煸油', '00:08:00', '五花肉切成條狀。熱鍋放少許油，放入五花肉中火煸炒，直到逼出豬油且肉色金黃、邊緣微焦。', 'img/recipes/30/steps/2.png', 0),
(168, 30, 3, '煸炒豆乾', '00:05:00', '利用鍋中的豬油，放入豆乾絲一同煸炒，直到豆乾表面呈現微乾焦黃且帶有彈性。', 'img/recipes/30/steps/3.png', 0),
(169, 30, 4, '加入魷魚與爆香', '00:04:00', '放入魷魚條大火翻炒至散發乾貨特有的香氣，接著加入大蒜末與辣椒片爆香。', 'img/recipes/30/steps/4.png', 0),
(170, 30, 5, '蔬菜合炒', '00:03:00', '放入芹菜段與蔥段，保持大火快速翻炒，讓芹菜略微斷生並保持翠綠。', 'img/recipes/30/steps/5.png', 0),
(171, 30, 6, '調味收汁', '00:02:00', '沿鍋邊淋入醬油、米酒並撒上砂糖。持續大火快炒讓醬汁均勻包裹食材並收乾，直到鍋底無餘汁且香氣濃郁即可。', 'img/recipes/30/steps/6.png', 0),
(172, 31, 1, '低溫煸香薑片', '00:08:00', '冷鍋倒入黑芝麻油，放入切好的老薑薄片，以小火慢慢煸炒。直到薑片邊緣開始萎縮變皺且呈現微焦狀態（切記火不可大，避免麻油變苦）。', 'img/recipes/31/steps/1.png', 0),
(173, 31, 2, '拌炒雞腿肉', '00:05:00', '放入雞腿肉塊，轉中大火與薑片拌炒，直到雞肉表面轉白收縮，並微微呈現金黃油亮的色澤。', 'img/recipes/31/steps/2.png', 0),
(174, 31, 3, '加入藥膳與液體', '00:02:00', '倒入米酒與清水（比例可依喜好調整，此處採 1:1），隨後放入洗淨的紅棗與枸杞。', 'img/recipes/31/steps/3.png', 0),
(175, 31, 4, '燉煮融合', '00:20:00', '大火煮滾後，轉小火蓋上鍋蓋燉煮約 20 分鐘。若希望酒味淡一點，煮滾時可不蓋鍋蓋讓酒精揮發。', 'img/recipes/31/steps/4.png', 0),
(176, 31, 5, '最後調味', '00:01:00', '依個人口味加入極少許鹽巴提鮮（麻油雞通常不放過多鹽，以免搶味），拌勻後即可起鍋盛盤。', 'img/recipes/31/steps/5.png', 0),
(177, 32, 1, '分離蛋黃與蛋白', '00:03:00', '將兩顆雞蛋分離，蛋白放入冰鎮過的攪拌盆 （蛋白霜穩定的關鍵）。', 'img/recipes/32/steps/1.png', 0),
(178, 32, 2, '製作蛋黃糊', '00:07:00', '蛋黃加入牛奶、香草精拌勻，再篩入低筋麵粉與泡打粉，攪拌至無顆粒狀。 ', 'img/recipes/32/steps/2.png', 0),
(179, 32, 3, '打發蛋白霜', '00:10:00', '砂糖分三次加入蛋白，使用電動打蛋器打至 「硬性發泡」（提起打蛋器有直立尖角）。。', 'img/recipes/32/steps/3.png', 0),
(180, 32, 4, '混合麵糊', '00:05:00', '取 1/3 蛋白霜加入蛋黃糊拌勻，再倒回剩餘蛋白霜中，用「切拌法」輕柔混合，避免消泡。', 'img/recipes/32/steps/4.png', 0),
(181, 32, 5, '低溫煎烤與蒸氣', '00:08:00', '平底鍋抹薄油，小火預熱。用冰淇淋勺挖取麵糊堆疊高度，加入一匙水，蓋鍋蓋悶煎 4 分鐘。', 'img/recipes/32/steps/5.png', 0),
(182, 32, 6, '翻面與盛盤', '00:05:00', '底部呈金黃色後小心翻面，再悶煎 3 分鐘即可出爐。', 'img/recipes/32/steps/6.png', 0),
(183, 33, 1, '熬煮焦糖液', '00:10:00', '將 50g 砂糖與 15ml 冷水放入鍋中，以小火加熱（過程中切勿攪拌）。待糖液轉為深琥珀色並散發焦香味後熄火，迅速倒入 15ml 熱水拌勻。趁熱倒入模具底部並靜置至凝固。', 'img/recipes/33/steps/1.png', 0),
(184, 33, 2, '加熱甜鮮乳', '00:05:00', '將鮮乳與 40g 砂糖放入鍋中，小火加熱至砂糖完全溶解即可熄火（約 50-60°C，不需沸騰），隨後滴入香草精拌勻。', 'img/recipes/33/steps/2.png', 0),
(185, 33, 3, '蛋奶液結合', '00:05:00', '雞蛋在碗中輕輕打散（避免產生過多泡沫）。將微溫的牛奶液分次緩緩倒入蛋液中，邊倒邊攪拌均勻，確保雞蛋不被燙熟。', 'img/recipes/33/steps/3.png', 0),
(186, 33, 4, '過篩去雜質', '00:03:00', '將混合好的布丁液透過細濾網過篩至少兩次，濾掉繫帶與氣泡，這是確保布丁口感滑順無孔洞的關鍵。', 'img/recipes/33/steps/4.png', 0),
(187, 33, 5, '水浴烘烤', '00:45:00', '將布丁液倒入模具，放在深烤盤中。在烤盤內注入約模具一半高度的熱水。放入預熱 150°C 的烤箱烘烤約 40 分鐘，直到布丁中心輕晃呈現布丁般的彈性感。', 'img/recipes/33/steps/5.png', 0),
(188, 33, 6, '冷藏與脫模', '00:05:00', '出爐冷卻後，放入冰箱冷藏至少 4 小時。食用時用小刀沿邊緣劃一圈，倒扣在盤子上，讓焦糖醬汁自然流下。', 'img/recipes/33/steps/6.png', 0),
(189, 34, 1, '劃開吐司切痕', '00:02:00', '在厚片吐司表面使用麵包刀劃出深約 1 公分的「井」字型切痕（注意不要切斷底部），這有助於烘烤時受熱均勻，並讓抹醬深入麵包芯部。', 'img/recipes/34/steps/1.png', 0),
(190, 34, 2, '填入奶油抹醬', '00:02:00', '將無鹽奶油切成小塊填入「井」字切痕中，並在吐司表面也均勻抹上一層薄薄的奶油。', 'img/recipes/34/steps/2.png', 0),
(191, 34, 3, '烘烤至酥脆', '00:05:00', '放入預熱至 180°C 的烤箱中，烘烤約 5 分鐘，直到吐司表面呈現微焦的誘人金黃色與酥脆質感。', 'img/recipes/34/steps/3.png', 0),
(192, 34, 4, '淋上蜂蜜收尾', '00:01:00', '出爐後趁熱淋上適量蜂蜜。熱氣會使蜂蜜與半融化的奶油完美結合，滲入切痕中，即可享用。', 'img/recipes/34/steps/4.png', 0),
(193, 35, 1, '泡軟吉利丁片', '00:05:00', '準備一盆冰水（需完全蓋過片狀），放入吉利丁片浸泡約 5 分鐘。待吉利丁片完全軟化後，撈起並徹底擠乾水分，置於小碗備用。', 'img/recipes/35/steps/1.png', 0),
(194, 35, 2, '加熱液體混合物', '00:08:00', '將鮮乳、鮮奶油與砂糖倒入鍋中，以小火慢加熱，邊加熱邊輕輕攪拌讓砂糖溶解。當液體周圍微冒泡（約 60°C）時立即熄火，避免沸騰影響乳化穩定度。', 'img/recipes/35/steps/2.png', 0),
(195, 35, 3, '混合凝固與調味', '00:05:00', '趁熱加入香草精攪拌均勻，接著放入擠乾水分的吉利丁片，持續攪拌直到吉利丁片完全溶解於乳液中。', 'img/recipes/35/steps/3.png', 0),
(196, 35, 4, '裝杯與冷藏', '04:00:00', '將奶酪液均勻倒入模具或杯中。若表面有氣泡，可用牙籤戳破或噴少許高度酒消泡。蓋上保鮮膜，放入冰箱冷藏至少 4 小時直至凝固完全。', 'img/recipes/35/steps/4.png', 0),
(197, 36, 1, '預備香蕉與奶油', '00:05:00', '將熟透的香蕉剝皮後壓成泥狀備用。無鹽奶油切成小塊，置於室溫軟化至手指可以輕易按壓下痕跡的程度（不可融化為液態）。', 'img/recipes/36/steps/1.png', 0),
(198, 36, 2, '奶油打發', '00:08:00', '將軟化的奶油與砂糖放入盆中，用打蛋器高速攪打。直到奶油顏色轉白且質地呈現蓬鬆、輕盈的羽毛狀（這是蛋糕口感細緻的關鍵）。', 'img/recipes/36/steps/2.png', 0),
(199, 36, 3, '分次拌入蛋液', '00:05:00', '雞蛋先打散。將蛋液分成 3-4 次慢慢加入奶油糊中，每次加入都要確保完全攪拌吸收後再加下一次，以防止油水分離導致麵糊結塊。', 'img/recipes/36/steps/3.png', 0),
(200, 36, 4, '粉類與香蕉泥混和', '00:05:00', '將低筋麵粉與泡打粉混勻後篩入盆中。加入香蕉泥，改用橡皮刮刀以切拌的手法攪拌均勻，直到看不見乾粉即可，切記不要過度攪拌以免產生筋性。', 'img/recipes/36/steps/4.png', 0),
(201, 36, 5, '入模烘烤', '00:45:00', '將麵糊倒入鋪好烘焙紙的長條烤模，表面抹平。放入預熱至 170°C 的烤箱烘烤約 40-45 分鐘。若表面上色過快，中途可蓋上鋁箔紙。', 'img/recipes/36/steps/5.png', 0),
(202, 36, 6, '熟成測試與脫模', '00:05:00', '使用竹籤插入蛋糕中心，拔出後若無濕麵糊沾黏即表示熟透。出爐後連同烤模放在架上冷卻 10 分鐘再脫模，完全冷卻後切片口感更佳。', 'img/recipes/36/steps/6.png', 0),
(203, 37, 1, '奶油打發', '00:08:00', '將無鹽奶油置於室溫軟化。加入黑糖與砂糖，使用電動打蛋器以中高速攪打至顏色轉淺、質地呈現蓬鬆狀。', 'img/recipes/37/steps/1.png', 0),
(204, 37, 2, '拌入濕性材料', '00:02:00', '加入一顆雞蛋與香草精，持續攪拌直到與奶油糊完全融合，質地呈現滑順狀態。', 'img/recipes/37/steps/2.png', 0),
(205, 37, 3, '粉類過篩與混合', '00:05:00', '將中筋麵粉、小蘇打粉與鹽混合過篩。分兩次加入奶油糊中，改用刮刀以切拌方式混合至看不見乾粉即可，避免過度攪拌。', 'img/recipes/37/steps/3.png', 0),
(206, 37, 4, '加入燕麥與果乾', '00:03:00', '倒入燕麥片與蔓越莓乾，用刮刀輕輕拌勻，讓配料均勻分佈在麵糰中。', 'img/recipes/37/steps/4.png', 0),
(207, 37, 5, '成形排盤', '00:05:00', '烤箱預熱 175°C。取適量麵糰揉成圓球（約高爾夫球大小），整齊排列在鋪有烘焙紙的烤盤上，並用手掌略微壓扁。', 'img/recipes/37/steps/5.png', 0),
(208, 37, 6, '烘烤與冷卻', '00:12:00', '放入烤箱烘烤約 10-12 分鐘，直到餅乾邊緣呈現焦糖金黃色。取出後留在烤盤上冷卻 5 分鐘使其定型，再移至架上完全冷卻。', 'img/recipes/37/steps/6.png', 0),
(209, 38, 1, '茶葉預處理', '00:05:00', '將伯爵茶葉使用研缽或調理機磨至細碎，若是使用茶包則直接拆開取出內部的細粉末備用，以確保茶香能均勻釋放。', 'img/recipes/38/steps/1.png', 0),
(210, 38, 2, '蛋糖液混合', '00:05:00', '將雞蛋與砂糖放入盆中打散，加入蜂蜜混合均勻。不需要打發，只需輕輕攪拌至砂糖略微溶解即可。', 'img/recipes/38/steps/2.png', 0),
(211, 38, 3, '拌入乾粉類', '00:05:00', '將低筋麵粉與泡打粉過篩加入蛋液中，撒入磨好的伯爵茶葉碎，使用打蛋器以輕柔的手法拌勻至無粉粒狀態。', 'img/recipes/38/steps/3.png', 0),
(212, 38, 4, '奶油乳化與靜置', '01:05:00', '將無鹽奶油加熱融化至微溫狀態，分次緩緩倒入麵糊中，攪拌至表面呈現光澤且完全乳化。蓋上保鮮膜，放入冰箱冷藏靜置至少 1 小時（此步驟為長出凸肚臍的關鍵）。', 'img/recipes/38/steps/4.png', 0),
(213, 38, 5, '入模準備', '00:05:00', '烤箱預熱至 200°C。將瑪德蓮烤模抹上一層薄薄奶油並撒上少許麵粉。將靜置好的麵糊取出裝入擠花袋，填入模具約八分滿。', 'img/recipes/38/steps/5.png', 0),
(214, 38, 6, '高溫烘烤', '00:10:00', '放入烤箱以 200°C 烘烤約 8-10 分鐘。觀察中心點膨脹出明顯的「凸肚臍」且邊緣呈現深金黃色後即可出爐，稍冷後脫模即可。', 'img/recipes/38/steps/6.png', 0),
(215, 39, 1, '混合乾性材料', '00:05:00', '將中筋麵粉、泡打粉與鹽混合過篩至大盆中。將核桃稍微切碎，可先入烤箱 150°C 烘烤 5 分鐘逼出香氣，冷卻後備用。', 'img/recipes/39/steps/1.png', 0),
(216, 39, 2, '切拌奶油', '00:08:00', '從冰箱取出剛切丁的「冰」無鹽奶油放入粉盆。使用刮板以「切、拌」的手法將奶油與麵粉混合，直到呈現類似粗砂或碎米狀（奶油需保持塊狀不融化）。', 'img/recipes/39/steps/2.png', 0),
(217, 39, 3, '拌入堅果', '00:01:00', '將切碎的核桃加入粉盆中，稍微攪動讓核桃均勻分佈在乾粉中。', 'img/recipes/39/steps/3.png', 0),
(218, 39, 4, '混合濕性液體', '00:02:00', '在另一個量杯中，將鮮乳與楓糖漿攪拌均勻備用。', 'img/recipes/39/steps/4.png', 0),
(219, 39, 5, '輕壓成團', '00:05:00', '在粉盆中心挖一個洞，倒入液體。使用刮刀由底部向上撥動，以輕壓而非搓揉的方式混合至無粉狀（切記勿過度揉捏，以免產生筋性導致口感變硬）。', 'img/recipes/39/steps/5.png', 0),
(220, 39, 6, '摺疊與切塊', '00:05:00', '將麵糰移至撒有手粉的桌面上，輕輕壓成 2.5 公分厚的圓餅狀。使用刀子或切模將其對切成 8 等份的三角形。', 'img/recipes/39/steps/6.png', 0),
(221, 39, 7, '表面裝飾', '00:02:00', '將司康整齊排列在烤盤上。在表面均勻刷上少許鮮乳（這能讓成品更有光澤感）。', 'img/recipes/39/steps/7.png', 0),
(222, 39, 8, '高溫烘烤', '00:18:00', '放入預熱 200°C 的烤箱，烘烤約 15-20 分鐘。直到司康側邊出現橫向裂紋（狼牙口），且表面與底部呈金黃焦香即可出爐。', 'img/recipes/39/steps/8.png', 0),
(223, 40, 1, '隔水融化巧克力', '00:08:00', '將黑巧克力磚切碎，與無鹽奶油塊一同放入耐熱盆中。採用隔水加熱（水溫不需沸騰，避免巧克力過熱變質）的方式，攪拌至兩者完全融化且質地光滑。', 'img/recipes/40/steps/1.png', 0),
(224, 40, 2, '冷卻降溫', '00:05:00', '將巧克力盆移離火源，在室溫下稍作冷卻至不燙手的微溫狀態。這能避免後續加入雞蛋時將其燙熟。', 'img/recipes/40/steps/2.png', 0),
(225, 40, 3, '攪拌砂糖與蛋', '00:05:00', '在巧克力液中加入砂糖拌勻。接著將雞蛋分次加入，每加入一顆都要確實攪拌，直到麵糊呈現細緻且帶有亮度的狀態。', 'img/recipes/40/steps/3.png', 0),
(226, 40, 4, '乾粉類過篩', '00:02:00', '將中筋麵粉、可可粉與鹽混合，均勻篩入巧克力麵糊盆中，以防粉類結塊影響口感。', 'img/recipes/40/steps/4.png', 0),
(227, 40, 5, '輕柔切拌混合', '00:03:00', '使用刮刀以翻拌（Fold）的手法混合。直到看不見白色乾粉即可停止攪拌，切記勿過度運作以免攪入過多空氣或產生筋性。', 'img/recipes/40/steps/5.png', 0),
(228, 40, 6, '入模準備', '00:02:00', '烤箱預熱 175°C。將方形烤模鋪上烘焙紙，將布朗尼麵糊倒入模具中，並用刮刀將表面抹平齊。', 'img/recipes/40/steps/6.png', 0),
(229, 40, 7, '烘烤與熟成測試', '00:30:00', '放入烤箱中層烘烤 25-30 分鐘。使用竹籤插入中心，拔出時若沾有些許「濕潤的碎屑」即代表完成（若竹籤全乾則表示烤過頭，口感會較乾硬）。', 'img/recipes/40/steps/7.png', 0),
(230, 40, 8, '冷卻切塊', '00:20:00', '出爐後在模具中完全放涼，巧克力結構才會定型。冷卻後取出切成長方塊即可享用，冷藏後口感更為紮實。', 'img/recipes/40/steps/8.png', 0),
(231, 41, 1, '加熱香草牛奶液', '00:10:00', '將鮮乳、無鹽奶油與香草精放入鍋中，以中小火加熱至奶油融化，且邊緣微微冒泡（即將沸騰前）即可熄火。靜置冷卻至微溫（約 50°C）備用。', 'img/recipes/41/steps/1.png', 0),
(232, 41, 2, '混合乾料與蛋黃', '00:05:00', '在大盆中將砂糖與過篩的低筋麵粉拌勻。加入蛋黃，並倒入約 100ml 的微溫牛奶液，用打蛋器輕輕攪拌成濃稠無粉粒的糊狀。', 'img/recipes/41/steps/2.png', 0),
(233, 41, 3, '完成稀麵糊', '00:05:00', '將剩餘的牛奶液分次倒入，持續輕攪至融合。最後拌入蘭姆酒，此時麵糊應呈非常稀的液態流動狀。', 'img/recipes/41/steps/3.png', 0),
(234, 41, 4, '過篩與靜置熟成', '24:00:00', '將麵糊透過細濾網過篩至少兩次以確保無結塊。蓋上保鮮膜緊貼液面，放入冰箱冷藏靜置熟成至少 24 小時（最高可至 48 小時），這是形成蜂巢組織的關鍵步驟。', 'img/recipes/41/steps/4.png', 0),
(235, 41, 5, '烤模預熱與抹油', '00:10:00', '將麵糊移出冰箱回溫。烤箱連同烤盤預熱至 230°C。在可麗露模具內部均勻塗抹一層薄薄的無鹽奶油或蜂蠟，並倒扣瀝出多餘油脂。', 'img/recipes/41/steps/5.png', 0),
(236, 41, 6, '入模與首段高溫烘烤', '00:15:00', '輕輕攪拌回溫後的麵糊（避免產生氣泡），倒入模具中約 8-9 分滿。放入烤箱以 230°C 烤 15 分鐘，使外皮迅速定型並焦糖化。', 'img/recipes/41/steps/6.png', 0),
(237, 41, 7, '二段恆溫燉烤', '00:50:00', '將烤箱溫度調降至 190°C，繼續烘烤 45-50 分鐘。若麵糊在過程中因沸騰過度衝出模具，可暫時取出稍微敲擊桌面再放回。烤至頂部呈現深焦褐色且帶有硬殼感。', 'img/recipes/41/steps/7.png', 0),
(238, 41, 8, '脫模與冷卻', '00:10:00', '出爐後立即倒扣脫模，將可麗露置於架上冷卻。需完全冷卻後，外層焦糖殼才會變硬酥脆，內部則會保持濕潤，即可享用。', 'img/recipes/41/steps/8.png', 0),
(239, 42, 1, '塔皮麵糰製作', '00:15:00', '將 75g 軟化奶油與糖粉打發至發白。分次加入一顆雞蛋液拌勻。篩入低筋麵粉與杏仁粉，以刮刀切拌成團（切勿揉捏以免出筋）。用保鮮膜包覆，放入冰箱冷藏至少 1 小時靜置。', 'img/recipes/42/steps/1.png', 0),
(240, 42, 2, '桿皮與入模', '00:10:00', '取出冰硬的麵糰，桿成約 0.3 公分厚的圓片，平鋪於塔模內。去除多餘邊緣並用叉子在底部戳出小孔，防止烘烤時隆起。', 'img/recipes/42/steps/2.png', 0),
(241, 42, 3, '盲烤塔殼', '00:25:00', '在塔皮上鋪烘焙紙並放上鎮石（或豆類）。放入預熱 180°C 的烤箱烤 15 分鐘，移除鎮石後再烤 10 分鐘至表面呈現均勻金黃色。取出徹底放涼。', 'img/recipes/42/steps/3.png', 0),
(242, 42, 4, '熬煮檸檬凝乳', '00:15:00', '將 3 顆雞蛋、砂糖、檸檬汁與檸檬皮屑混合攪勻。隔水加熱（水微滾）並持續攪拌，直到液體變為濃稠糊狀（中心溫度約 82°C）即可離火。', 'img/recipes/42/steps/4.png', 0),
(243, 42, 5, '奶油乳化（關鍵）', '00:10:00', '待檸檬凝乳降溫至約 60°C 時，分次加入 100g 室溫奶油塊。使用均質機或手動打蛋器快速攪拌，讓奶油完全乳化進醬汁中，呈現絲滑光澤感。', 'img/recipes/42/steps/5.png', 0),
(244, 42, 6, '填餡與冷藏定型', '01:05:00', '將完成的檸檬凝乳趁熱倒入放涼的塔殼中抹平。室溫冷卻後放入冰箱冷藏至少 2 小時，待內餡凝固後即可脫模並切片享用。', 'img/recipes/42/steps/6.png', 0),
(245, 43, 1, '製作打發蛋白霜', '00:10:00', '將 2 顆雞蛋的蛋白放入無油無水的盆中，分三次加入 60g 砂糖，打發至呈現結實、拉起有直立尖角的硬性發泡狀態。', 'img/recipes/43/steps/1.png', 0),
(246, 43, 2, '低溫烘烤蛋白餅底', '01:00:00', '將蛋白霜裝入圓形花嘴，在烤盤上擠出 6 個直徑約 5 公分的圓餅。放入預熱 100°C 的烤箱低溫烘烤 60 分鐘，直到完全乾燥酥脆，取出放涼。', 'img/recipes/43/steps/2.png', 0),
(247, 43, 3, '製作香緹鮮奶油', '00:08:00', '將鮮奶油與 15g 砂糖混合，墊冰水打發至 9 分發（紋路深且挺立）。裝入擠花袋備用。', 'img/recipes/43/steps/3.png', 0),
(248, 43, 4, '調製栗子奶油餡', '00:10:00', '將栗子泥、軟化奶油與蘭姆酒混合拌勻。若質地太乾可加入極少許剩餘鮮奶油，攪拌至絲滑，裝入蒙布朗專用的多孔花嘴。', 'img/recipes/43/steps/4.png', 0),
(249, 43, 5, '內部結構組合', '00:05:00', '在蛋白餅底中心擠上一小球鮮奶油，放上一整顆熟栗子（糖漬栗子），再用鮮奶油由下往上將栗子完全覆蓋包裹成錐形。', 'img/recipes/43/steps/5.png', 0),
(250, 43, 6, '螺旋擠餡與裝飾', '00:10:00', '手持蒙布朗花嘴，由下而上、由外向內以螺旋狀均勻地將栗子奶油擠在鮮奶油表面。最後篩上糖粉模擬山頂積雪即可完成。', 'img/recipes/43/steps/6.png', 0),
(251, 44, 1, '打發硬性鮮奶油', '00:10:00', '將冰鮮奶油與砂糖放入盆中，盆底墊冰水。使用電動打蛋器打發至「硬性發泡」狀態（紋路極深、拉起尖角直立不塌陷）。三明治用的奶油需比蛋糕裝飾用的更硬，切開才不會流動。', 'img/recipes/44/steps/1.png', 0),
(252, 44, 2, '水果預處理', '00:05:00', '草莓去蒂頭，芒果切成長條狀。水果洗淨後必須用廚房紙巾徹底擦乾水分，避免水分滲出導致奶油融化。', 'img/recipes/44/steps/2.png', 0),
(253, 44, 3, '底層奶油塗抹', '00:02:00', '將兩片生吐司去邊（或依喜好保留）。在兩片吐司的一面皆均勻塗上約 0.5 公分厚的鮮奶油層。', 'img/recipes/44/steps/3.png', 0),
(254, 44, 4, '水果定位排列', '00:03:00', '選定對角線作為切線位置。將水果整齊排列在對角線上，其餘空白處也填入水果。記住大顆水果（如草莓）的中心點要在切線上，切開才會漂亮。', 'img/recipes/44/steps/4.png', 0),
(255, 44, 5, '填補空隙與覆蓋', '00:05:00', '將剩餘的鮮奶油厚厚地覆蓋在水果上，並用刮刀仔細填滿水果間的每個縫隙。蓋上另一片吐司，輕輕壓平。', 'img/recipes/44/steps/5.png', 0),
(256, 44, 6, '包覆與冷藏定型', '01:00:00', '使用保鮮膜將三明治緊緊包裹，並在保鮮膜上標註「對角切線」的位置。放入冰箱冷藏至少 1 小時定型，讓奶油、吐司與水果緊密契合。', 'img/recipes/44/steps/6.png', 0),
(257, 44, 7, '對角切割', '00:05:00', '準備一把鋒利的刀，先浸入熱水擦乾。對準標註的切線一刀切下。每切一刀都要擦淨刀面再重複，呈現完美的切面。', 'img/recipes/44/steps/7.png', 0),
(258, 45, 1, '食材預備與器皿挑選', '00:02:00', '準備一個洗淨瀝乾的透明玻璃杯或廣口瓶，以便展示漂亮的側面層次。藍莓洗淨後擦乾水分，薄荷葉洗淨備用。', 'img/recipes/45/steps/1.png', 0),
(259, 45, 2, '鋪設優格基底', '00:01:00', '在杯底填入約 1/3 份量的希臘優格，用小湯勺背面稍微抹平邊緣，讓層次線條更清晰。', 'img/recipes/45/steps/2.png', 0),
(260, 45, 3, '增加脆口層次', '00:01:00', '撒上一層燕麥片（或烤過的堅果碎）。燕麥片能吸收部分優格水分，同時提供飽足感與酥脆口感。', 'img/recipes/45/steps/3.png', 0),
(261, 45, 4, '添加果實與甜味', '00:01:00', '鋪上一層新鮮藍莓，並淋上少許蜂蜜增加風味深度與潤滑感。', 'img/recipes/45/steps/4.png', 0),
(262, 45, 5, '循環堆疊至滿', '00:03:00', '重複上述步驟（優格、燕麥、藍莓、蜂蜜），直到裝滿杯子。每一層都要輕壓一下，避免中間產生過大的空洞。', 'img/recipes/45/steps/5.png', 0),
(263, 45, 6, '頂層點綴與裝飾', '00:02:00', '在最上層點綴幾顆較大的藍莓，放上新鮮薄荷葉增加清新香氣。建議現做現吃以保持燕麥的脆度，或冷藏 20 分鐘後享用風味更佳。', 'img/recipes/45/steps/6.png', 0),
(264, 46, 1, '泡軟吉利丁', '00:05:00', '將吉利丁片剪成小段，完全浸泡在冰水中（需加冰塊保持低溫）約 5 分鐘，待其軟化如綢緞狀。撈起後用力擠乾多餘水分備用。', 'img/recipes/46/steps/1.png', 0),
(265, 46, 2, '混合基底與加熱', '00:08:00', '在小鍋中倒入無糖豆漿、黑芝麻粉與砂糖。開小火加熱，期間需持續使用手動打蛋器攪拌，確保黑芝麻粉均勻散開且砂糖完全溶解。', 'img/recipes/46/steps/2.png', 0),
(266, 46, 3, '精準溫控與定型', '00:02:00', '當豆漿液溫熱且邊緣出現微小氣泡（約 60-70°C）時立即熄火。切記不可煮沸，以免豆漿產生皮膜或破壞吉利丁的凝固力。', 'img/recipes/46/steps/3.png', 0),
(267, 46, 4, '融入吉利丁', '00:02:00', '將擠乾水分的吉利丁片放入溫熱的豆漿液中，持續攪拌直到吉利丁完全隱形溶解。', 'img/recipes/46/steps/4.png', 0),
(268, 46, 5, '提升滑順質感', '00:03:00', '倒入少許鮮奶油增加乳脂含量與厚度，攪拌均勻。這能讓豆乳凍口感更接近奶酪，減少單薄感。', 'img/recipes/46/steps/5.png', 0),
(269, 46, 6, '兩次過篩', '00:05:00', '將液體透過細濾網過篩至少兩次，濾掉未溶解的芝麻顆粒與氣泡。這是確保豆乳凍口感絲滑的關鍵細節。', 'img/recipes/46/steps/6.png', 0),
(270, 46, 7, '分裝與冷藏', '04:00:00', '將濾好的液體平均倒入玻璃杯或模具中。蓋上保鮮膜，放入冰箱冷藏至少 4 小時（建議隔夜）直到完全凝固。食用時可點綴少許黑芝麻粒。', 'img/recipes/46/steps/7.png', 0),
(271, 47, 1, '堅果切碎處理', '00:05:00', '將杏仁果與核桃用刀切成約 0.3-0.5 公分的小碎粒。不要切得太細碎，保留一點顆粒感能增加餅乾的咀嚼香氣。', 'img/recipes/47/steps/1.png', 0),
(272, 47, 2, '乾粉混合', '00:02:00', '在大盆中放入全麥麵粉與鹽。全麥麵粉顆粒較粗不需過篩，直接用手動打蛋器攪拌均勻即可。', 'img/recipes/47/steps/2.png', 0),
(273, 47, 3, '加入油糖潤濕', '00:02:00', '將橄欖油與楓糖漿一次性倒入粉盆中。這兩者將提供餅乾酥脆的質地與天然的甜度。', 'img/recipes/47/steps/3.png', 0),
(274, 47, 4, '按壓混合成團', '00:05:00', '使用刮刀以「按壓、切拌」的方式讓粉類吸收水分。切記不要像揉麵糰一樣過度施力，直到剛好成團、看不見乾粉即可。', 'img/recipes/47/steps/4.png', 0),
(275, 47, 5, '拌入堅果碎', '00:01:00', '將切好的堅果碎倒入麵糰中，輕輕拌勻，讓堅果均勻分散在麵糰各處。', 'img/recipes/47/steps/5.png', 0),
(276, 47, 6, '捏製成型', '00:05:00', '烤箱預熱 170°C。取約 15-20g 的麵糰，先在手掌揉成小圓球，再輕輕壓扁成直徑約 4 公分的圓餅狀，整齊排放在烤盤上。', 'img/recipes/47/steps/6.png', 0),
(277, 47, 7, '恆溫烘烤', '00:18:00', '放入烤箱中層烘烤 15-18 分鐘。由於是全麥麵粉，色澤本就較深，需觀察邊緣微微焦乾即代表完成。', 'img/recipes/47/steps/7.png', 0),
(278, 47, 8, '完全冷卻定型', '00:05:00', '出爐後先留在烤盤上 5 分鐘，剛烤好時口感較軟，待完全放涼後，質地會變得乾爽酥脆，即可盛盤。', 'img/recipes/47/steps/8.png', 0),
(279, 48, 1, '紅豆預泡處理', '08:00:00', '將生紅豆洗淨，加入足量的水浸泡至少 8 小時（或隔夜）。這能縮短燉煮時間並確保紅豆內芯徹底軟化。', 'img/recipes/48/steps/1.png', 0),
(280, 48, 2, '慢火燉煮紅豆', '00:40:00', '瀝乾泡豆水，重新加入 300ml 水。以大火煮滾後轉小火燉煮約 40 分鐘，直到紅豆用手指輕壓即可化開，但外皮仍保持完整不破裂。', 'img/recipes/48/steps/2.png', 0),
(281, 48, 3, '熬製蜜紅豆', '00:10:00', '加入約 60g 砂糖至紅豆鍋中，持續小火拌煮至水分收乾，讓糖份徹底滲入豆芯變成「蜜紅豆」。取出放涼備用。', 'img/recipes/48/steps/3.png', 0),
(282, 48, 4, '吉利丁泡軟', '00:05:00', '將吉利丁片剪段，浸泡在冰水中約 5 分鐘。待變軟後撈起，徹底擠乾水分備用。', 'img/recipes/48/steps/4.png', 0),
(283, 48, 5, '加熱牛奶液', '00:05:00', '將鮮乳與剩餘的 20g 砂糖放入小鍋，以微火加熱至約 60°C（鍋邊冒細小氣泡、手感微燙）。切勿煮滾以免破壞乳香與凝固效果。', 'img/recipes/48/steps/5.png', 0),
(284, 48, 6, '溶解吉利丁', '00:02:00', '熄火，加入擠乾的吉利丁片。使用攪拌器不斷攪動，直到吉利丁完全溶解於牛奶中，呈現光滑液體狀。', 'img/recipes/48/steps/6.png', 0),
(285, 48, 7, '層次入模', '00:03:00', '在容器（或玻璃杯）底部鋪上厚厚一層蜜紅豆。緩緩倒入牛奶液，若有氣泡可用小匙撇除，以確保外觀美觀。', 'img/recipes/48/steps/7.png', 0),
(286, 48, 8, '冷藏與脫模', '04:00:00', '放入冰箱冷藏至少 4 小時至完全凝固。食用前可用溫熱毛巾稍微包裹容器外側，即可輕鬆倒扣切塊享用。', 'img/recipes/48/steps/8.png', 0),
(287, 49, 1, '食材預處理', '00:08:00', '將韓式年糕條浸泡在冷水中約 10 分鐘使其軟化；韓式魚板切成長方片狀；蔥切成長段；高麗菜撕或切成一口大小的塊狀備用。', 'img/recipes/49/steps/1.png', 0),
(288, 49, 2, '熬煮甜辣基底湯頭', '00:05:00', '在平底鍋中倒入魚高湯，煮滾後加入韓式辣椒醬、韓式辣椒粉、砂糖與醬油。充分攪拌均勻，確保辣椒醬完全融化無塊狀。', 'img/recipes/49/steps/2.png', 0),
(289, 49, 3, '烹煮年糕與魚板', '00:07:00', '將瀝乾的年糕與魚板放入鍋中。轉中小火熬煮，期間需不時用鏟子推動鍋底，避免年糕因澱粉釋出而黏鍋。煮至年糕變軟且開始膨脹。', 'img/recipes/49/steps/3.png', 0),
(290, 49, 4, '加入配料入味', '00:05:00', '放入高麗菜塊與剝好殼的水煮蛋。持續燉煮，讓高麗菜釋放甜味並軟化，同時讓水煮蛋表皮裹上一層深紅色的醬汁。', 'img/recipes/49/steps/4.png', 0),
(291, 49, 5, '收汁至濃厚狀態', '00:03:00', '繼續以中小火加熱，直到醬汁因水分蒸發變得濃稠（呈紅亮掛糊狀）。此時可試味道，依個人喜好增減糖或辣椒粉。', 'img/recipes/49/steps/5.png', 0),
(292, 49, 6, '最後點綴與盛盤', '00:02:00', '撒入蔥段快速拌勻後熄火。盛盤後撒上白芝麻增加香氣與視覺美感，趁熱享用口感最佳。', 'img/recipes/49/steps/6.png', 0),
(293, 50, 1, '調製祕製湯底醬', '00:05:00', '在小碗中將韓式辣椒醬、韓式辣椒粉、蒜泥與少許醬油混合均勻。若喜歡更滑順的口感，可加入少許高湯先將醬料化開備用。', 'img/recipes/50/steps/1.png', 0),
(294, 50, 2, '食材切分預備', '00:08:00', '將午餐肉、熱狗與豆腐切成厚度均勻的片狀；洋蔥切成粗絲；豬五花肉切成易入口的小段。洗淨金針菇並去除根部備用。', 'img/recipes/50/steps/2.png', 0),
(295, 50, 3, '環狀擺盤邏輯', '00:05:00', '準備一個淺型平底鍋。將洋蔥與泡菜鋪在鍋底，其餘切好的午餐肉、熱狗、豆腐、豬五花與金針菇環繞著鍋緣依序重疊擺放整齊。', 'img/recipes/50/steps/3.png', 0),
(296, 50, 4, '中心靈魂配料', '00:02:00', '在鍋子中心留出的空位放入一整塊泡麵。在麵體上方放上一大匙焗豆罐頭，最後鋪上一片切達起司片。', 'img/recipes/50/steps/4.png', 0),
(297, 50, 5, '加入高湯與燉煮', '00:05:00', '將調好的湯底醬放在泡麵旁。緩緩沿著鍋邊倒入魚高湯（或清水），注意不要沖散擺好的食材。蓋上鍋蓋大火煮滾。', 'img/recipes/50/steps/5.png', 0),
(298, 50, 6, '起司融合與開動', '00:05:00', '煮滾後轉中火。用湯匙輕輕將醬料攪散融入湯中。待麵條煮至個人喜好的軟硬度，且起司片半融化地覆蓋在麵條上時，即可整鍋端上桌享用。', 'img/recipes/50/steps/6.png', 0),
(299, 51, 1, '食材初步分切', '00:05:00', '將老泡菜切成約 3 公分的段狀；洋蔥切絲；板豆腐切成 1 公分厚的片狀；豬腹肉片切成一半長度。準備好蒜末備用。', 'img/recipes/51/steps/1.png', 0),
(300, 51, 2, '芝麻油爆香', '00:02:00', '取一石鍋或厚底鍋，倒入黑芝麻油。開中小火，放入蒜末與洋蔥絲翻炒，直到洋蔥變透明且散發出強烈香氣。', 'img/recipes/51/steps/2.png', 0),
(301, 51, 3, '炒香豬肉片', '00:03:00', '加入豬腹肉片，轉中火翻炒至肉片變色且溢出油脂。豬油與芝麻油的混合是此鍋湯底香氣的基石。', 'img/recipes/51/steps/3.png', 0),
(302, 51, 4, '翻炒泡菜激發酸香', '00:03:00', '倒入泡菜與少許泡菜汁。持續翻炒約 2-3 分鐘，直到泡菜邊緣略顯焦糖化，這能去除泡菜生冷感並轉化為醇厚的酸度。', 'img/recipes/51/steps/4.png', 0),
(303, 51, 5, '燉煮湯底', '00:10:00', '加入水（若有洗米水更佳，能增加湯頭厚度）。煮滾後撇去表面浮沫，轉小火蓋上鍋蓋燉煮 10 分鐘，讓食材風味完全融合。', 'img/recipes/51/steps/5.png', 0),
(304, 51, 6, '調色與完成', '00:02:00', '撒入韓式辣椒粉調整辣度與成色，最後平鋪入板豆腐塊，煮至豆腐熱透並入味後，即可整鍋端上桌享用。', 'img/recipes/51/steps/6.png', 0),
(305, 52, 1, '涼拌蔬菜處理', '00:10:00', '將黃豆芽與菠菜分別放入滾水中燙熟，撈起後立即沖冷水並擠乾水分。切成小段後加入少許黑芝麻油、鹽拌勻備用。', 'img/recipes/52/steps/1.png', 0),
(306, 52, 2, '熱炒絲狀配菜', '00:08:00', '將櫛瓜、紅蘿蔔、香菇切成均勻細絲。平底鍋下少許油，將這三種食材分別入鍋炒至熟軟，撒微量鹽調味後盛起分開擺放。', 'img/recipes/52/steps/2.png', 0),
(307, 52, 3, '炒香肉片', '00:05:00', '利用原鍋餘油將牛肉片（或絞肉）炒至變色熟透。可加少許醬油與糖增添底味，盛起備用。', 'img/recipes/52/steps/3.png', 0),
(308, 52, 4, '特製拌飯醬調製', '00:02:00', '在一小碗中混合韓式辣椒醬、黑芝麻油與砂糖。若喜歡稀一點的質地，可加入極少許水或味醂攪拌至滑順。', 'img/recipes/52/steps/4.png', 0),
(309, 52, 5, '石鍋燒熱與鋪飯', '00:05:00', '在石鍋（或厚底鑄鐵鍋）內壁均勻塗上一層薄薄的黑芝麻油。裝入白飯並用湯匙輕壓平整。放在爐火上以中小火加熱約 3-5 分鐘，直到聽見微弱的滋滋聲，代表底部正在形成鍋巴。', 'img/recipes/52/steps/5.png', 0),
(310, 52, 6, '精美環狀擺盤', '00:05:00', '趁鍋子尚熱，將處理好的黃豆芽、菠菜、櫛瓜絲、紅蘿蔔絲、香菇絲與牛肉片依色彩區隔，在飯上排成一個漂亮的圓環形。', 'img/recipes/52/steps/6.png', 0),
(311, 52, 7, '點綴與最後成型', '00:05:00', '在蔬菜中心打入一顆生蛋黃（不習慣吃生蛋者可改用半熟荷包蛋）。放上調好的拌飯醬，整鍋端上桌。趁石鍋餘溫還在時，用力攪拌均勻即可享用。', 'img/recipes/52/steps/7.png', 0),
(312, 53, 1, '雞肉醃漬底味', '00:15:00', '將雞翅或雞腿肉洗淨擦乾，加入鹽與黑胡椒粉抓勻，靜置 15 分鐘讓底味滲入肉質中。', 'img/recipes/53/steps/1.png', 0),
(313, 53, 2, '裹粉與返潮', '00:05:00', '將醃好的雞肉均勻裹上一層厚厚的玉米粉（或炸雞專用粉）。靜置約 5 分鐘待其表面略微變潮（返潮），這能確保炸粉與肉質緊密貼合，不易脫落。', 'img/recipes/53/steps/2.png', 0),
(314, 53, 3, '初炸熟成', '00:08:00', '熱油鍋至 170°C。分批放入雞肉，炸約 7-8 分鐘至表面呈現淡金黃色且內部熟透。撈起置於架上瀝油，靜置 2 分鐘散發內部水氣。', 'img/recipes/53/steps/3.png', 0),
(315, 53, 4, '二炸搶酥', '00:02:00', '將油溫拉高至 190°C。再次放入炸雞進行二次快炸，約 1-2 分鐘直到外皮轉為深金黃色且觸感僵硬酥脆。撈起瀝油備用。', 'img/recipes/53/steps/4.png', 0),
(316, 53, 5, '爆香蒜末基底', '00:03:00', '另取一平底鍋，放入無鹽奶油以微火融化。加入蒜末炒至香氣溢出且顏色略微轉黃（注意不可炒焦，以免產生苦味）。', 'img/recipes/53/steps/5.png', 0),
(317, 53, 6, '熬煮蜂蜜醬汁', '00:02:00', '倒入醬油與蜂蜜，轉中小火攪拌均勻。煮至醬汁開始冒出綿密的大氣泡且質地變得濃稠濃郁。', 'img/recipes/53/steps/6.png', 0),
(318, 53, 7, '快速裹醬與盛盤', '00:02:00', '熄火，立刻放入炸好的雞肉。快速翻拌，讓每一塊炸雞都均勻裹上一層發亮的金黃醬汁。撒上白芝麻，即可趁熱盛盤享用。', 'img/recipes/53/steps/7.png', 0),
(319, 54, 1, '乾料與菇類預處理', '00:15:00', '乾香菇沖洗後用少量溫水泡軟（保留香菇水增香）；枸杞與紅棗稍微沖洗備用。新鮮菇類（香菇、鴻喜菇等）去除根部並切成易入口大小。', 'img/recipes/54/steps/1.png', 0),
(320, 54, 2, '雞肉冷水汆燙', '00:08:00', '將雞腿肉塊放入鍋中，加入足量冷水，開中火煮至滾。隨著溫度上升，血水雜質會析出形成浮渣。煮滾後撈起雞肉，用冷水沖洗乾淨備用。', 'img/recipes/54/steps/2.png', 0),
(321, 54, 3, '燉煮基底湯頭', '00:05:00', '湯鍋中重新加入 1000ml 水與剛才的香菇水。放入汆燙好的雞肉、薑片、泡好的乾香菇、紅棗以及米酒。', 'img/recipes/54/steps/3.png', 0),
(322, 54, 4, '文火慢燉雞肉', '00:30:00', '大火煮滾後撇去表面剩餘的少量浮沫，轉小火蓋上鍋蓋，燉煮約 30 分鐘，讓雞肉纖維變軟且香菇與紅棗風味滲入湯中。', 'img/recipes/54/steps/4.png', 0),
(323, 54, 5, '加入鮮菇增鮮', '00:08:00', '放入所有準備好的新鮮菇類。菇類不耐長煮，維持中火煮約 5-8 分鐘，使其釋放多醣體的甘甜，同時保持脆嫩口感。', 'img/recipes/54/steps/5.png', 0),
(324, 54, 6, '最後調味與點綴', '00:02:00', '最後放入枸杞煮約 1 分鐘（枸杞煮久會變酸且褪色）。依個人口味加入適量鹽調味，拌勻後即可熄火盛入大碗中享用。', 'img/recipes/54/steps/6.png', 0),
(325, 55, 1, '排骨去腥處理', '00:10:00', '將豬小排放入鍋中，加入足以淹沒肉塊的「冷水」。開中火煮至水滾後持續 2 分鐘，待血水雜質析出變成浮渣。撈起排骨，用清水將表面殘餘浮渣洗淨備用。', 'img/recipes/55/steps/1.png', 0),
(326, 55, 2, '蔬菜切塊預備', '00:08:00', '白蘿蔔削皮後，使用「滾刀塊」手法切成均勻大小（斷面多較易入味）；甜玉米去除外皮與鬚毛，切成約 3-4 公分寬的段狀備用。', 'img/recipes/55/steps/2.png', 0),
(327, 55, 3, '燉煮肉底高湯', '00:25:00', '湯鍋中重新裝入 1500ml 的清水，放入汆燙好的排骨與薑片。大火煮滾後轉小火，蓋上鍋蓋燉煮約 20-25 分鐘，讓排骨初步軟化並釋放肉味。', 'img/recipes/55/steps/3.png', 0),
(328, 55, 4, '加入蔬菜同燉', '00:25:00', '將白蘿蔔塊與玉米段放入湯鍋。再次煮滾後維持小火燉煮約 20-30 分鐘，直到白蘿蔔呈現半透明狀、口感綿軟，且玉米的甜味滲入湯汁。', 'img/recipes/55/steps/4.png', 0),
(329, 55, 5, '調味與最後收尾', '00:02:00', '加入鹽進行調味，用湯匙輕輕攪勻試味。確保鹹度能帶出蔬菜的甘甜。熄火前可依個人喜好撒上洗淨的香菜碎增添香氣。', 'img/recipes/55/steps/5.png', 0),
(330, 56, 1, '刀工預備與抓醃', '00:10:00', '將豬肉絲用少許醬油抓勻醃漬 5 分鐘；黑木耳、紅蘿蔔、熟筍切成均勻細絲；豆腐先切片再疊切成條狀（放入水中防止黏連）；雞蛋打散；太白粉與水以 1:2 調勻。', 'img/recipes/56/steps/1.png', 0),
(331, 56, 2, '煮滾高湯與熟成食材', '00:05:00', '鍋中倒入高湯煮滾。先放入肉絲撥散，接著加入木耳絲、紅蘿蔔絲與筍絲。再次煮滾後轉中小火煮約 3 分鐘，確保食材鮮味完全釋放至湯中。', 'img/recipes/56/steps/2.png', 0),
(332, 56, 3, '基礎定味與加入豆腐', '00:02:00', '加入醬油提供紅亮的湯色，並以少許鹽調整基準鹹度。緩緩滑入豆腐條，用湯匙背面輕輕推開，避免將嫩豆腐推碎。', 'img/recipes/56/steps/3.png', 0),
(333, 56, 4, '關鍵：芡汁勾芡', '00:03:00', '維持湯汁微滾狀態，將粉水再次攪勻，以繞圈方式緩緩倒入鍋中。一邊倒一邊輕推湯底，直到湯頭呈現濃稠且帶有光澤的厚度。', 'img/recipes/56/steps/4.png', 0),
(334, 56, 5, '關鍵：黃金蛋花', '00:02:00', '待芡汁煮滾起大泡時，將蛋液由高處繞圈淋入。靜置 10 秒鎖定不要攪拌，等蛋液略微定型後再輕輕推動，即可形成薄透如雲朵般的漂亮蛋花。', 'img/recipes/56/steps/5.png', 0),
(335, 56, 6, '熄火與酸辣調色', '00:01:00', '熄火。趁熱撒入大量白胡椒粉與倒入烏醋。切記胡椒與醋不可在沸騰時久煮，否則香氣會逸散、醋味會變苦。', 'img/recipes/56/steps/6.png', 0),
(336, 56, 7, '最後裝飾盛盤', '00:01:00', '淋上黑芝麻油增添亮澤與香氣，撒上蔥花即可裝碗。食用前可再依個人喜好追加烏醋。', 'img/recipes/56/steps/7.png', 0),
(337, 57, 1, '雞肉與海鮮初步預備', '00:15:00', '將雞腿肉塊冷水下鍋，煮滾汆燙去除雜質血水後洗淨瀝乾。新鮮蛤蜊放入鹽水中吐沙至少 1 小時並刷洗乾淨外殼備用。', 'img/recipes/57/steps/1.png', 0),
(338, 57, 2, '爆香辛香料基底', '00:03:00', '熱鍋下少許油，放入拍裂的蒜頭與薑片，以中小火煸炒至蒜頭表面微黃出香，這能讓湯頭帶有一層油脂潤滑感。', 'img/recipes/57/steps/2.png', 0),
(339, 57, 3, '煸炒雞肉與注水', '00:05:00', '放入雞腿肉塊稍微翻炒至表皮緊縮，接著倒入水與米酒，開大火煮滾後撇去表面剩餘的少量浮渣。', 'img/recipes/57/steps/3.png', 0),
(340, 57, 4, '精華注入：剝皮辣椒', '00:02:00', '加入約 6-8 根剝皮辣椒（可依喜好切段）以及約半罐的辣椒汁。湯汁是鮮味的來源，請務必保留。', 'img/recipes/57/steps/4.png', 0),
(341, 57, 5, '文火慢燉入味', '00:20:00', '轉小火並蓋上鍋蓋，燉煮約 20-25 分鐘，讓雞肉軟爛並充分吸收剝皮辣椒的甜辣風味。', 'img/recipes/57/steps/5.png', 0),
(342, 57, 6, '海味點綴與最後調味', '00:05:00', '轉大火，放入蛤蜊煮至開口立即關火。此時先試湯頭味道，由於剝皮辣椒與蛤蜊均有鹽分，通常不需額外加鹽，若不足再微量添加。', 'img/recipes/57/steps/6.png', 0),
(343, 58, 1, '排骨去腥與番茄預備', '00:10:00', '將豬小排冷水下鍋，煮滾後汆燙 2 分鐘撈起，沖淨表面雜質。同時將牛番茄洗淨並切成一口大小的塊狀；兩顆雞蛋打散成蛋液備用。', 'img/recipes/58/steps/1.png', 0),
(344, 58, 2, '油炒番茄釋放茄紅素', '00:05:00', '炒鍋下少許油，放入番茄塊以中火翻炒。炒至番茄邊緣略微糊化、滲出紅色汁液，這是讓湯頭濃郁紅亮的關鍵步驟。', 'img/recipes/58/steps/2.png', 0),
(345, 58, 3, '合鍋燉煮', '00:05:00', '將炒好的番茄連同汁液移入湯鍋，放入處理好的排骨、薑片，並倒入 1200ml 的清水。', 'img/recipes/58/steps/3.png', 0),
(346, 58, 4, '文火慢燉至軟嫩', '00:30:00', '大火煮滾後撇去浮沫，轉小火蓋上鍋蓋燉煮約 30 分鐘。直到排骨肉質變軟，番茄軟爛入味，湯頭呈現自然的橘紅色。', 'img/recipes/58/steps/4.png', 0),
(347, 58, 5, '調味平衡酸鹼', '00:02:00', '依口味加入鹽調味。若選用的番茄偏酸，可加入極少許砂糖，能讓湯頭口感更溫潤、鮮味更明顯。', 'img/recipes/58/steps/5.png', 0),
(348, 58, 6, '淋入滑嫩蛋花', '00:03:00', '轉中大火讓湯保持微滾狀態。以「繞圈」方式緩緩淋入蛋液。靜置 5 秒讓蛋花稍微定型，再輕輕推動。熄火撒上蔥花即可享用。', 'img/recipes/58/steps/6.png', 0),
(349, 59, 1, '牛肉去腥汆燙', '00:15:00', '將牛腱切成約 3-4 公分的厚塊（燉煮後會縮水，不宜太小）。冷水下鍋煮滾，汆燙 5 分鐘出除血水雜質，撈起後沖冷水洗淨備用。', 'img/recipes/59/steps/1.png', 0),
(350, 59, 2, '蔬菜切塊預備', '00:10:00', '白蘿蔔與紅蘿蔔去皮切成滾刀塊；薑切片、蔥切段、蒜頭拍裂；青江菜洗淨對切備用。', 'img/recipes/59/steps/2.png', 0),
(351, 59, 3, '爆香底料與豆瓣醬', '00:05:00', '熱鍋下油，中小火放入蔥段、薑片、蒜頭爆香。接著加入辣豆瓣醬翻炒至溢出紅油，這是湯頭香氣的重要來源。', 'img/recipes/59/steps/3.png', 0),
(352, 59, 4, '煸炒牛肉與上色', '00:05:00', '將汆燙好的牛腱肉塊入鍋，與醬料共同拌炒至肉塊表面上色並鎖住肉汁。', 'img/recipes/59/steps/4.png', 0),
(353, 59, 5, '注入高湯與調味', '00:05:00', '倒入醬油、糖、米酒炒出香氣，隨後加入八角。倒入牛骨高湯（或水）直到沒過食材，大火煮滾並撇去浮沫。', 'img/recipes/59/steps/5.png', 0),
(354, 59, 6, '文火慢燉入味', '01:30:00', '放入紅白蘿蔔塊，轉極小火蓋上鍋蓋燉煮約 1.5 到 2 小時。直到牛肉能用筷子輕易穿透，且紅白蘿蔔入味透明即可。', 'img/recipes/59/steps/6.png', 0),
(355, 59, 7, '烹煮麵條與配菜', '00:08:00', '另燒一鍋水煮沸。先將青江菜燙熟撈起；接著下陽春麵煮至喜歡的軟度（約 3-5 分鐘），撈起瀝乾放入大碗中。', 'img/recipes/59/steps/7.png', 0),
(356, 59, 8, '組合與盛盤', '00:02:00', '在麵碗上擺放牛肉、蘿蔔塊與青江菜。沖入滾燙的紅燒牛肉湯頭，撒上少許蔥花裝飾即可享用。', 'img/recipes/59/steps/8.png', 0),
(357, 60, 1, '生鮮配料預處理', '00:08:00', '將洋蔥與番茄切成細丁；結球萵苣生菜切成長絲；香菜洗淨後粗略切碎；綠檸檬切成契形角備用。所有蔬菜務必瀝乾水分以保持餅皮酥脆。', 'img/recipes/60/steps/1.png', 0),
(358, 60, 2, '爆香洋蔥與牛肉', '00:05:00', '熱鍋下少許油，放入洋蔥丁中火炒至透明微黃。接著加入牛絞肉，用鏟子將肉塊完全攪散，炒至水分蒸發且顏色轉為深褐色。', 'img/recipes/60/steps/2.png', 0),
(359, 60, 3, '塔可風味調味', '00:02:00', '在鍋中撒入孜然粉、紅椒粉與細鹽。持續翻炒 1-2 分鐘讓肉燥均勻裹上香料香氣。若質地太乾，可加入一匙水幫助香料融合，收汁後盛起備用。', 'img/recipes/60/steps/3.png', 0),
(360, 60, 4, '乾烙玉米餅皮', '00:03:00', '取一乾淨平底鍋（不需放油），將墨西哥玉米餅皮放入。以中火每面各烙 20-30 秒，直到餅皮散發穀物香氣且微微鼓起即可取出。', 'img/recipes/60/steps/4.png', 0),
(361, 60, 5, '底部堆疊組合', '00:02:00', '趁餅皮微熱時，依序鋪上一層生菜絲、兩大勺炒好的牛肉燥與適量的番茄丁。', 'img/recipes/60/steps/5.png', 0),
(362, 60, 6, '淋醬與最後點綴', '00:05:00', '在頂部淋上酸奶油與莎莎醬，撒上新鮮香菜碎。盛盤時附上檸檬角，食用前由使用者親自擠上鮮榨檸檬汁效果最佳。', 'img/recipes/60/steps/6.png', 0),
(363, 61, 1, '海鮮與香料處理', '00:15:00', '將大虎蝦剪去鬚足並去除腸泥，切下蝦頭備用，蝦身剝殼（保留尾巴較美觀）。香茅斜切段後用刀背拍碎；南薑切薄片；檸檬葉撕開以釋放香氣；小番茄對半切。', 'img/recipes/61/steps/1.png', 0),
(364, 61, 2, '煸炒蝦頭與熬湯', '00:08:00', '熱鍋下少許油，放入蝦頭中火煸炒至顏色轉紅並滲出橘紅色蝦油。倒入 800ml 水煮滾，隨後放入香茅、南薑、檸檬葉。蓋上鍋蓋微火燉煮 10 分鐘熬出香氣。', 'img/recipes/61/steps/2.png', 0),
(365, 61, 3, '過濾與加入蔬菜', '00:05:00', '將蝦頭撈出棄置。在清澈的香料湯頭中放入綜合菇類與小番茄塊，煮至菇類熟軟並釋放鮮甜味。', 'img/recipes/61/steps/3.png', 0),
(366, 61, 4, '海鮮熟成', '00:05:00', '轉大火，放入蝦身與吐沙乾淨的蛤蜊。煮至蛤蜊完全開口、蝦子變色彎曲即可，切勿久煮以免縮水影響口感。', 'img/recipes/61/steps/4.png', 0),
(367, 61, 5, '調製冬蔭風味', '00:05:00', '加入魚露、特製辣醬組（紅椒粉+糖+蒜末）與椰奶。充分攪拌讓湯頭轉為誘人的粉橘色並呈現微濃稠狀。煮滾後立刻試味。', 'img/recipes/61/steps/5.png', 0),
(368, 61, 6, '酸度點綴與完成', '00:02:00', '熄火。立刻倒入新鮮檸檬汁並輕輕攪勻。此步驟必須在熄火後進行，以免高溫破壞檸檬的果香味並產生苦澀感。盛盤後可加少許香菜裝飾。', 'img/recipes/61/steps/6.png', 0),
(369, 62, 1, '雞胸肉烹調與靜置', '00:10:00', '雞胸肉抹上少許鹽與黑胡椒，入鍋煎至兩面金黃熟透。取出後靜置 5 分鐘鎖住肉汁，再切成約 1 公分厚的片狀備用。', 'img/recipes/62/steps/1.png', 0),
(370, 62, 2, '生菜預處理', '00:08:00', '將蘿蔓生菜逐片洗淨，使用蔬果脫水器徹底甩乾水分（水分會稀釋醬汁）。用手將葉片撕成適合入口的大片狀，放入冰箱冷藏保持脆度。', 'img/recipes/62/steps/2.png', 0),
(371, 62, 3, '凱薩醬基底調製', '00:05:00', '將油浸鯷魚用叉子壓成泥狀。在碗中混合鯷魚泥、蒜末、生蛋黃與檸檬汁，攪拌至均勻滑順。', 'img/recipes/62/steps/3.png', 0),
(372, 62, 4, '關鍵：乳化滴油技術', '00:05:00', '一邊快速攪拌基底，一邊「極少量且緩慢」地滴入橄欖油。直到醬汁呈現如同美乃滋般濃稠且發亮的乳化狀態。最後拌入帕馬森起司粉。', 'img/recipes/62/steps/4.png', 0),
(373, 62, 5, '均勻沾裹醬汁', '00:02:00', '取一大盆，放入冰鎮過的生菜。倒入適量凱薩醬，用沙拉夾輕輕翻拌，確保每一片葉片正反面都薄薄掛上一層醬汁。', 'img/recipes/62/steps/5.png', 0),
(374, 62, 6, '盛盤與裝飾', '00:02:00', '將生菜疊放於盤中。撒上香酥麵包丁，刨上額外的帕馬森起司碎，最後擺上雞胸肉片。建議完成後立即食用以享用最佳脆度。', 'img/recipes/62/steps/6.png', 0),
(375, 63, 1, '回溫與調味', '00:05:00', '牛排務必回溫並用廚房紙巾徹底擦乾表面（水分是焦脆的大敵）。雙面均勻灑上厚厚的海鹽與黑胡椒。', 'img/recipes/63/steps/1.png', 0),
(376, 63, 2, '高溫封肉 (Sear)', '00:05:00', '鐵鍋燒至冒煙後下橄欖油，放入牛排大火煎至單面焦脆。不要頻繁翻動，直到產生深褐色的梅納反應皮殼再翻面。', 'img/recipes/63/steps/2.png', 0),
(377, 63, 3, '香料奶油淋油 (Basting)', '00:05:00', '轉中火，放入無鹽奶油、拍扁的蒜頭與迷迭香。待奶油冒泡後，將鍋子稍微傾斜，不斷用湯匙將滾燙的香料奶油淋在牛排表面。', 'img/recipes/63/steps/3.png', 0),
(378, 63, 4, '靜置鎖汁 (Resting)', '00:08:00', '牛排起鍋後放置在溫熱的盤子或架子上。靜置 5-10 分鐘，讓肉纖維重新吸收肉汁，這是切開後不流血水的關鍵技術。', 'img/recipes/63/steps/4.png', 0),
(379, 63, 5, '餘油炒時蔬', '00:02:00', '利用鍋中剩餘的牛油與香料殘渣，快速拌炒蘆筍與小番茄直到微軟，撒入少許鹽調味，與牛排一同盛盤即可。', 'img/recipes/63/steps/5.png', 0),
(380, 64, 1, '主料預處理', '00:15:00', '米線煮熟後沖冷水瀝乾。豬肉片川燙熟；大虎蝦燙熟去殼，從背部剖半成兩片薄片並去除腸泥。生菜與香草洗淨瀝乾。', 'img/recipes/64/steps/1.png', 0),
(381, 64, 2, '米紙濕潤處理', '00:02:00', '準備一盤溫開水（約 40°C）。將乾米紙快速浸入水中 2-3 秒後立即取出平舖在大盤上。米紙會隨即軟化並帶有黏性。', 'img/recipes/64/steps/2.png', 0),
(382, 64, 3, '層疊包裹食材', '00:08:00', '在米紙下 1/3 處依序放上生菜、米線、香草葉與肉片。上方 1/3 處留空，並在中間偏上位置放上 2-3 片蝦仁（紅色皮朝下）。', 'img/recipes/64/steps/3.png', 0),
(383, 64, 4, '捲包成型技術', '00:05:00', '從底部向上捲起包住肉與米線，左右兩側向內摺疊封口（可夾入一根韭菜）。持續向上捲緊至覆蓋蝦仁，最後完全封口。', 'img/recipes/64/steps/4.png', 0),
(384, 64, 5, '調製特製魚露醬', '00:05:00', '將魚露、檸檬汁、糖、水、蒜末混合拌勻，直到糖完全溶解。可依個人口味加入切碎的紅辣椒絲。沾醬搭配食用即可。', 'img/recipes/64/steps/5.png', 0),
(385, 65, 1, '番紅花釋放香氣', '00:05:00', '將番紅花絲放入小杯中，加入 50ml 熱高湯浸泡。直到液體轉為濃郁的金黃橙色，這是燉飯靈魂色澤的來源。', 'img/recipes/65/steps/1.png', 0),
(386, 65, 2, '煸炒海鮮精華', '00:08:00', '寬口平底鍋下橄欖油，放入大蝦與透抽兩面快速煎至 5 分熟後盛起備用。鍋底留下的海鮮油脂將用來炒米。', 'img/recipes/65/steps/2.png', 0),
(387, 65, 3, '炒米與底層調味', '00:05:00', '原鍋爆香洋蔥丁與甜椒丁。倒入燉米翻炒至米粒邊緣透明，吸滿蝦油香氣。加入紅椒粉拌勻，倒入白酒燒乾除腥。', 'img/recipes/65/steps/3.png', 0),
(388, 65, 4, '靜置燉煮 (不翻動)', '00:20:00', '倒入番紅花湯與剩餘高湯（高湯量需淹過米飯）。轉中小火煮滾後，將米攤平。此後嚴禁翻動，讓米粒在靜止中吸收湯汁並在底部結成鍋巴。', 'img/recipes/65/steps/4.png', 0),
(389, 65, 5, '擺放海鮮與淡菜', '00:10:00', '當湯汁收至 8 分乾且米飯呈 8 分熟時，將預煎的蝦子、透抽與洗淨的淡菜美觀地鋪在米飯上方。蓋上鍋蓋小火悶煮至淡菜全開。', 'img/recipes/65/steps/5.png', 0),
(390, 65, 6, '成就鍋巴與完成', '00:02:00', '開大火煮 1-2 分鐘，聽到鍋底發出「嗶啵」聲時代表 Socarrat 鍋巴已成形。熄火，撒上巴西里碎與檸檬角，整鍋上桌。', 'img/recipes/65/steps/6.png', 0),
(391, 66, 1, '食材精細化處理', '00:08:00', '將醬瓜切成小碎丁。將鹹蛋去殼，取出蛋黃備用（可對切增加擺放數量）；鹹蛋白則切成碎末備用。蔥切花、蒜切末。', 'img/recipes/66/steps/1.png', 0),
(392, 66, 2, '肉餡風味調製', '00:05:00', '在大碗中放入豬絞肉，加入醬瓜丁、鹹蛋白碎、蒜末、醬油、白胡椒粉，以及最重要的『醬瓜罐頭汁』與水。', 'img/recipes/66/steps/2.png', 0),
(393, 66, 3, '攪拌出筋技術', '00:05:00', '用手或筷子朝『同一個方向』快速攪拌肉餡，直到水分被肉吸收，且肉質呈現微微的黏性（出筋），這樣蒸完後才不會散成一團。', 'img/recipes/66/steps/3.png', 0),
(394, 66, 4, '深盤塑形擺放', '00:02:00', '將肉餡平鋪在深盤中，表面用湯匙稍微抹平，中間按壓出小凹槽，整齊擺入鹹蛋黃（剖面朝上更漂亮）。', 'img/recipes/66/steps/4.png', 0),
(395, 66, 5, '電鍋蒸煮與盛盤', '00:15:00', '放入電鍋，外鍋加入一米杯水（約蒸 15 分鐘）。跳起後悶 2 分鐘，撒上蔥花點綴即可上桌。盤底滲出的精華湯汁千萬別倒掉，是拌飯首選。', 'img/recipes/66/steps/5.png', 0),
(396, 67, 1, '肉類汆燙與鮮蔬備料', '00:15:00', '牛腩切塊後冷水下鍋汆燙，洗淨浮渣備用。甜菜根去皮切細絲；洋蔥、紅蘿蔔、馬鈴薯切塊；高麗菜切成約 3 公分的寬條。', 'img/recipes/67/steps/1.png', 0),
(397, 67, 2, '煸炒肉類與洋蔥', '00:08:00', '熱鍋下少許油，先將洋蔥丁炒至軟化透明。接著放入牛腩塊翻炒至表面微焦，鎖住肉汁並炒出脂香味。', 'img/recipes/67/steps/2.png', 0),
(398, 67, 3, '色澤釋放與長時間慢燉', '01:00:00', '加入水、甜菜根絲、番茄糊與月桂葉。大火煮滾後轉極小火，蓋上鍋蓋燉煮 1 小時。此時甜菜根會將湯頭染成鮮紅色。', 'img/recipes/67/steps/3.png', 0),
(399, 67, 4, '根莖蔬菜熟化', '00:20:00', '放入紅蘿蔔與馬鈴薯塊。繼續燉煮 20 分鐘，直到馬鈴薯邊緣微圓潤，代表部分澱粉已融入湯中讓湯汁變濃稠。', 'img/recipes/67/steps/4.png', 0),
(400, 67, 5, '調味與最後點綴', '00:05:00', '加入高麗菜煮至軟化。撈出月桂葉，加入海鹽與黑胡椒調味（番茄糊已有鹹味，需分次添加）。', 'img/recipes/67/steps/5.png', 0),
(401, 67, 6, '盛盤與乳化享用', '00:02:00', '盛入深碗中，在中央放上一大匙酸奶油。建議食用時再將酸奶油撥散與鮮紅湯頭融合，風味最為道地。', 'img/recipes/67/steps/6.png', 0),
(402, 68, 1, '蝦子斷筋與蔬菜處理', '00:15:00', '大蝦去殼留尾並去除腸泥。在蝦腹部斜劃 3-4 刀（深至 1/3），將蝦翻身按壓背部，聽到斷裂聲代表筋膜已斷，可防止炸時捲曲。地瓜、茄子、青椒切好並抹乾水分。', 'img/recipes/68/steps/1.png', 0),
(403, 68, 2, '冰鎮麵衣調製', '00:03:00', '準備一個大碗裝滿冰水，加入天婦羅粉。用筷子「隨意撥動」數下即可。**切記不可過度攪拌**，保留少量粉粒能讓麵衣更輕薄，過度攪拌會產生麩質導致變韌。', 'img/recipes/68/steps/2.png', 0),
(404, 68, 3, '兩段式上粉', '00:05:00', '先將食材拍上一層薄薄的乾天婦羅粉，抖掉餘粉後，再拎住尾端或邊緣，浸入冰麵衣中快速均勻包裹。', 'img/recipes/68/steps/3.png', 0),
(405, 68, 4, '恆溫酥炸技術', '00:10:00', '油溫加熱至 170°C（滴入麵衣會沉到一半立刻浮起）。依序放入地瓜、茄子等蔬菜，最後放入炸蝦。炸至麵衣變硬、色澤金黃即撈起。可用手指輕彈麵衣聽其清脆聲。', 'img/recipes/68/steps/4.png', 0),
(406, 68, 5, '瀝油與靜置', '00:05:00', '取出天婦羅後放置在瀝油架上靜置 1 分鐘，利用餘溫熟透內部並讓表面多餘油脂流走，確保口感乾爽。', 'img/recipes/68/steps/5.png', 0),
(407, 68, 6, '特調沾醬組合', '00:02:00', '將日式醬油露與溫開水調勻，在盤邊堆上白蘿蔔泥。食用時將天婦羅浸入沾醬，搭配蘿蔔泥一同入口，鮮美絕倫。', 'img/recipes/68/steps/6.png', 0),
(408, 69, 1, '煸炒五花肉', '00:15:00', '乾鍋不放油，放入手切五花肉條，以中火緩慢煸炒。直到肉條表面呈現微焦金黃，且鍋中逼出大量透明豬油為止。', 'img/recipes/69/steps/1.png', 0),
(409, 69, 2, '炒糖色與醬香', '00:05:00', '放入冰糖炒至融化呈琥珀色。接著倒入醬油，利用高溫讓醬油與豬油產生「醬噴」香氣，並均勻包裹在肉條上。', 'img/recipes/69/steps/2.png', 0),
(410, 69, 3, '關鍵香料拌炒', '00:03:00', '撒入五香粉與大量的油蔥酥。快速翻炒讓油蔥酥吸收肉汁香氣，注意火候不可太大，避免油蔥酥燒焦變苦。', 'img/recipes/69/steps/3.png', 0),
(411, 69, 4, '入味燉煮', '01:20:00', '倒入水（或高湯）與米酒，液面需完全淹沒食材。放入剝殼的水煮蛋。大火煮滾後轉微火，蓋上鍋蓋燉煮 1-1.5 小時。', 'img/recipes/69/steps/4.png', 0),
(412, 69, 5, '收汁檢查', '00:02:00', '燉至湯汁呈現濃稠掛勺狀態，且肉皮部分呈現透明軟糯感。試味調整鹹甜度即可熄火。', 'img/recipes/69/steps/5.png', 0),
(413, 69, 6, '盛盤組合', '00:01:00', '在熱騰騰的白飯上淋上飽滿的滷肉與醬汁，擺上一顆滷蛋與一片黃蘿蔔即可開動。', 'img/recipes/69/steps/6.png', 0),
(414, 70, 1, '比例粉漿調製', '00:03:00', '將粗地瓜粉與太白粉以 2:1 比例混合，加入水充分攪拌至完全溶解，確保沒有粉粒沉澱。攪拌均勻後粉漿應呈現乳白色流動狀。', 'img/recipes/70/steps/1.png', 0),
(415, 70, 2, '鮮蚵熱鍋煎香', '00:03:00', '平底鍋下較多油，燒熱後放入洗淨的鮮蚵。大火煎至鮮蚵邊緣稍微收縮、香氣溢出。注意動作要輕，避免鮮蚵破裂。', 'img/recipes/70/steps/2.png', 0),
(416, 70, 3, '淋漿與結成皮殼', '00:04:00', '粉漿再次攪拌均勻後，由鍋中心向外繞圈淋入，覆蓋住所有鮮蚵。維持大火，待粉漿邊緣轉為透明、中心凝固並出現焦香皮殼。', 'img/recipes/70/steps/3.png', 0),
(417, 70, 4, '加入蛋液與蔬菜', '00:03:00', '在粉漿中央打入雞蛋並用鏟子輕輕劃散，隨即鋪上滿滿的小白菜段。蛋液會幫助蔬菜黏著在粉漿上。', 'img/recipes/70/steps/4.png', 0),
(418, 70, 5, '翻面與熟成', '00:05:00', '技巧性地將整片蚵仔煎翻面。繼續煎至雞蛋焦香、小白菜完全熟軟且粉漿兩面都呈現誘人的微焦狀態。', 'img/recipes/70/steps/5.png', 0),
(419, 70, 6, '淋醬與盛盤', '00:02:00', '將蚵仔煎摺疊盛盤。將海山醬與甜辣醬預熱拌勻（可加少許水調釋），厚厚地淋在表面，最後撒上蔥花即可享用。', 'img/recipes/70/steps/6.png', 0),
(420, 71, 1, '熬製靈魂蒜油', '00:10:00', '將橄欖油與蒜末放入小鍋中，以極小火低溫加熱。直到蒜末呈現微微金黃色即熄火放涼，濾出大蒜油備用。這是改編版的核心香氣。', 'img/recipes/71/steps/1.png', 1),
(421, 71, 2, '低溫發酵餅皮', '01:10:00', '將麵粉、酵母、水、鹽與『一半的蒜油』混合，揉至光滑後發酵約 1 小時至兩倍大。蒜油中的微量蒜香會滲入麵糰基底。', 'img/recipes/71/steps/2.png', 1),
(422, 71, 3, '餅皮成型與抹醬', '00:05:00', '將發酵好的麵糰桿成圓餅狀。首先在餅皮刷上一層薄薄的『剩餘蒜油』，再均勻抹上番茄糊，加強蒜味層次。', 'img/recipes/71/steps/3.png', 1),
(423, 71, 4, '配料鋪設與烘烤', '00:15:00', '放上切片的水牛起司。放入預熱至 230°C 的烤箱，烘烤 12-15 分鐘直到起司沸騰冒泡、邊緣金黃酥脆。', 'img/recipes/71/steps/4.png', 0),
(424, 71, 5, '最後調味與完工', '00:05:00', '出爐後，立即撒上新鮮羅勒葉。接著以繞圈方式淋上天然蜂蜜，利用披薩的餘溫讓蜂蜜與起司油脂融合。即可切片享用。', 'img/recipes/71/steps/5.png', 1);
INSERT INTO `steps` (`step_id`, `recipe_id`, `step_order`, `step_title`, `step_total_time`, `step_content`, `step_image_url`, `is_modified`) VALUES
(425, 72, 1, '基礎餅皮製作', '01:10:00', '將麵粉、酵母、水、鹽與橄欖油混合揉至光滑，低溫發酵 1 小時至兩倍大。此步驟保留經典配方，確保餅皮基底穩定。', 'img/recipes/72/steps/1.png', 0),
(426, 72, 2, '黑松露番茄底醬佈置', '00:05:00', '將餅皮桿開，先均勻塗抹番茄糊，接著在番茄糊上均勻點上黑松露醬並略微推開。松露醬在高溫下會與番茄水分結合，香氣更具穿透力。', 'img/recipes/72/steps/2.png', 1),
(427, 72, 3, '高溫酥烤', '00:12:00', '將『僅塗抹醬料』的餅皮送入預熱 230°C 烤箱烘烤。注意：此版本先不放起司，以防起司在烘烤過程中釋放過多水分弄濕餅皮。', 'img/recipes/72/steps/3.png', 1),
(428, 72, 4, '布拉塔起司置中', '00:01:00', '披薩出爐後，將整顆濕潤的布拉塔起司小心放在披薩中心位置。利用披薩出爐的餘溫讓起司外皮稍稍軟化。', 'img/recipes/72/steps/4.png', 1),
(429, 72, 5, '切開流心與裝飾', '00:02:00', '用刀尖在起司中心劃開十字，讓裡面的乳酪絲與鮮奶油自然流出。撒上新鮮羅勒葉，淋上一點特級橄欖油即可趁熱切片。', 'img/recipes/72/steps/5.png', 1),
(430, 73, 1, '辛辣麵糰揉製', '01:10:00', '將麵粉、酵母、水、鹽混合。特別加入『辣油』一同揉搓至麵糰光滑，讓辛香料分子嵌入麩質中。發酵 1 小時至兩倍大。', 'img/recipes/73/steps/1.png', 1),
(431, 73, 2, '抹醬與底層起司', '00:05:00', '桿開餅皮，均勻抹上番茄糊。先撒上一層莫札瑞拉起司絲作為接著劑，準備承載重負荷的配料。', 'img/recipes/73/steps/2.png', 1),
(432, 73, 3, '鋪設辣味配料', '00:05:00', '在起司上均勻擺放薩拉米香腸片。接著點綴墨西哥辣椒片。建議薩拉米不要重疊，以免烘烤不均。', 'img/recipes/73/steps/3.png', 1),
(433, 73, 4, '高溫烘烤', '00:15:00', '放入預熱至 230°C 的烤箱。烘烤期間薩拉米會釋放紅色油脂，與融化的起司融合，直到邊緣呈焦糖色且酥脆。', 'img/recipes/73/steps/4.png', 0),
(434, 73, 5, '點綴與最後增香', '00:02:00', '出爐後撒上新鮮羅勒葉，並根據個人喜好再滴上幾滴辣油增加光澤感，切片上桌。', 'img/recipes/73/steps/5.png', 1),
(435, 74, 1, '製作金沙流沙球', '00:15:00', '將熟鹹蛋黃壓碎，拌入鮮奶油調成糊狀。揉成兩個小圓球後放入冷凍庫快速冷凍至硬，這是確保烤後維持核心完整且不與抹茶糊混合的關鍵技術。', 'img/recipes/74/steps/1.png', 1),
(436, 74, 2, '抹茶巧克力基底調製', '00:08:00', '將白巧克力與奶油隔水加熱融化拌勻，稍微放涼。此步驟需注意溫度，避免抹茶粉在高溫下變色。', 'img/recipes/74/steps/2.png', 0),
(437, 74, 3, '全蛋打發與粉類混合', '00:10:00', '雞蛋與糖打發至發泡。分次拌入抹茶巧克力糊、過篩的低粉與抹茶粉，以切拌法混勻避免產生麩質影響口感。', 'img/recipes/74/steps/3.png', 0),
(438, 74, 4, '模具填裝與置入核心', '00:05:00', '在刷過奶油的模具中先倒入一半抹茶麵糊。從冷凍取出金沙球放在中心，再倒入剩餘麵糊覆蓋。金沙球位置需固定在正中央。', 'img/recipes/74/steps/4.png', 1),
(439, 74, 5, '高溫快烤與脫模', '00:10:00', '放入預熱 200°C 烤箱烤 8-10 分鐘。待外層成型但中心仍有晃動感時出爐。稍放涼 1 分鐘後脫模，切開即有雙色熔岩效果。', 'img/recipes/74/steps/5.png', 1),
(440, 75, 1, '莓果起司內餡預備', '00:05:00', '將馬斯卡彭起司置於室溫軟化。將新鮮藍莓洗淨抹乾，均勻拌入起司中。此步驟不需要加糖，利用藍莓天然酸度與白巧克力的甜味形成對比。', 'img/recipes/75/steps/1.png', 1),
(441, 75, 2, '抹茶糊基礎調製', '00:08:00', '白巧克力與無鹽奶油隔水加熱融化，拌入過篩的抹茶粉，攪拌至色澤鮮綠且無顆粒。注意水溫不可沸騰，以免抹茶變苦。', 'img/recipes/75/steps/2.png', 0),
(442, 75, 3, '蛋液混合與粉類加入', '00:10:00', '全蛋加糖攪拌均勻（不需要打發），倒入抹茶巧克力糊拌勻，最後篩入低筋麵粉輕輕拌成濃稠麵糊。', 'img/recipes/75/steps/3.png', 0),
(443, 75, 4, '分層填裝技術', '00:05:00', '在杯子模具內壁抹油撒粉，倒入 1/3 的抹茶麵糊。中間放入一大匙藍莓馬斯卡彭起司，再覆蓋剩餘麵糊至 8 分滿。', 'img/recipes/75/steps/4.png', 1),
(444, 75, 5, '烘烤與優雅呈盤', '00:12:00', '放入預熱 190°C 的烤箱烤 10-12 分鐘。稍放涼脫模後，表面可撒上防潮糖粉。切開後藍莓與起司抹茶交織流出，視覺滿分。', 'img/recipes/75/steps/5.png', 1),
(445, 76, 1, '蘭姆栗子內餡調製', '00:05:00', '將栗子泥放入碗中，滴入黑蘭姆酒充分拌勻，使其質地變得略微鬆軟。將拌好的栗子泥分成兩等份，揉成圓球備用。', 'img/recipes/76/steps/1.png', 1),
(446, 76, 2, '融化抹茶巧克力', '00:08:00', '白巧克力與無鹽奶油隔水加熱融化，拌入過篩抹茶粉，攪拌至表面泛出亮光且無顆粒。注意溫度需控制在 50°C 以下。', 'img/recipes/76/steps/2.png', 0),
(447, 76, 3, '蛋糊混拌技術', '00:10:00', '全蛋與砂糖攪拌至微發泡且顏色轉淡，倒入抹茶巧克力糊，接著篩入低筋麵粉。使用刮刀以翻拌方式混合均勻。', 'img/recipes/76/steps/3.png', 0),
(448, 76, 4, '核心置入與填裝', '00:05:00', '在模具中倒入約 1/2 高度的麵糊。在中央放入蘭姆栗子球，接著倒入剩餘麵糊至 8 分滿，輕敲模具震出大氣泡。', 'img/recipes/76/steps/4.png', 1),
(449, 76, 5, '精準烘烤與靜置', '00:10:00', '放入預熱 200°C 烤箱烤 8-10 分鐘。出爐後靜置 2 分鐘再小心脫模。栗子泥在高溫下會變軟並與抹茶漿融合，口感迷人。', 'img/recipes/76/steps/5.png', 1),
(450, 77, 1, '雞丁果汁醃漬', '00:20:00', '雞腿肉切丁，加入醬油、米酒與『一大匙現擠鳳梨汁』拌勻。鳳梨蛋白酶能預先軟化肉質，醃漬 20 分鐘後抓入少許太白粉備用。', 'img/recipes/77/steps/1.png', 1),
(451, 77, 2, '鳳梨焦糖化處理', '00:05:00', '熱鍋少許油，先將鳳梨丁下鍋快速翻炒至表面微焦。這能鎖住果汁並產生焦糖香氣，盛起備用。', 'img/recipes/77/steps/2.png', 1),
(452, 77, 3, '糊辣香氣萃取', '00:05:00', '原鍋下油，低溫煸香花椒粒後撈出。接著下乾辣椒段炒至深紫色（糊辣味），放入蒜末、薑片爆出辛香味。', 'img/recipes/77/steps/3.png', 0),
(453, 77, 4, '大火快炒與掛汁', '00:05:00', '下雞丁轉大火快炒至 8 分熟。倒入預調的醬汁（醬油、糖、醋）與預炒過的鳳梨，快速翻炒讓醬汁與鳳梨汁乳化並緊裹食材。', 'img/recipes/77/steps/4.png', 1),
(454, 77, 5, '腰果點綴盛盤', '00:01:00', '起鍋前撒入蔥段與酥脆腰果，隨意拌炒兩下保持堅果脆度，即可盛盤。這是一道酸、甜、苦、辣、鹹五味俱全的改編料理。', 'img/recipes/77/steps/5.png', 1),
(455, 78, 1, '雞丁酥炸準備', '00:15:00', '雞肉切丁後用醬油、米酒醃漬。接著將雞丁分次投入粗地瓜粉中，確保每一塊都均勻裹粉，靜置 5 分鐘待『返潮』後才炸，可防粉漿剝落。', 'img/recipes/78/steps/1.png', 1),
(456, 78, 2, '二次油炸技術', '00:10:00', '以 160°C 油溫進行初炸熟化，撈起後升高油溫至 190°C 進行二次搶酥 30 秒。這能逼出多餘油脂並讓外皮達到極致清脆。', 'img/recipes/78/steps/2.png', 1),
(457, 78, 3, '宮保蜂蜜醬熬煮', '00:05:00', '起鍋下少許油煸香花椒與乾辣椒。倒入蜂蜜、檸檬汁與少許醬油。以中火熬煮至醬汁泡泡變大且呈現濃稠掛勺狀（醬汁濃縮是關鍵）。', 'img/recipes/78/steps/3.png', 1),
(458, 78, 4, '高速掛汁翻拌', '00:02:00', '將炸好的脆皮雞丁倒入醬汁鍋中，快速大火翻拌，讓每一塊雞丁都均勻裹上一層發亮的金黃醬汁，隨即下蔥段拌勻。', 'img/recipes/78/steps/4.png', 1),
(459, 78, 5, '盛盤與花生點綴', '00:01:00', '盛盤後，大方撒上大量花生碎。花生碎會黏附在蜜汁外殼上，提供絕佳的堅果香氣與雙重脆感。', 'img/recipes/78/steps/5.png', 1),
(460, 79, 1, '豆腐脫水與切塊', '00:20:00', '板豆腐切厚片，用廚房紙巾包裹後上方壓重物靜置 20 分鐘。脫水後的豆腐煎起來會更脆且不易破碎。最後切成 2 公分正方丁。', 'img/recipes/79/steps/1.png', 1),
(461, 79, 2, '老皮效果乾煎', '00:10:00', '熱鍋下油，將豆腐丁均勻鋪平。以中大火乾煎至六面皆呈金黃色，且表皮出現微小的皺折（老皮）。盛起瀝油備用。', 'img/recipes/79/steps/2.png', 1),
(462, 79, 3, '香料低溫煸香', '00:05:00', '原鍋留少許油，放入花椒粒煸至香氣散發後撈出。接著下乾辣椒段炒至紅褐色，加入蒜末爆香。', 'img/recipes/79/steps/3.png', 0),
(463, 79, 4, '宮保芡汁燴煮', '00:03:00', '倒入由醬油、烏醋、糖與太白粉水調成的醬汁。待醬汁煮至濃稠起大泡時，倒入豆腐丁快速翻拌，讓『老皮』吸滿湯汁。', 'img/recipes/79/steps/4.png', 1),
(464, 79, 5, '收汁盛盤', '00:02:00', '最後加入蔥段與熟花生翻炒均勻，讓花生沾上微量醬汁即可起鍋。此時豆腐應呈現發亮的焦糖色澤。', 'img/recipes/79/steps/5.png', 1);

-- --------------------------------------------------------

--
-- 資料表結構 `step_ingredients`
--

CREATE TABLE `step_ingredients` (
  `step_ingredient_id` int(11) NOT NULL,
  `step_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `step_ingredient_amount` decimal(10,2) NOT NULL,
  `unit_name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `step_ingredients`
--

INSERT INTO `step_ingredients` (`step_ingredient_id`, `step_id`, `ingredient_id`, `step_ingredient_amount`, `unit_name`) VALUES
(1, 1, 390, '250.00', '克'),
(2, 1, 496, '3.00', '克'),
(3, 1, 416, '2.00', '克'),
(4, 2, 497, '150.00', '毫升'),
(5, 2, 345, '10.00', '克'),
(6, 4, 367, '50.00', '克'),
(7, 5, 242, '125.00', '克'),
(8, 7, 23, '10.00', '克'),
(9, 7, 345, '5.00', '克'),
(10, 8, 498, '100.00', '克'),
(11, 8, 499, '60.00', '克'),
(12, 9, 230, '2.00', '顆'),
(13, 9, 410, '20.00', '克'),
(14, 10, 392, '40.00', '克'),
(15, 10, 405, '15.00', '克'),
(16, 15, 164, '300.00', '克'),
(17, 15, 331, '10.00', '克'),
(18, 15, 340, '10.00', '毫升'),
(19, 15, 395, '3.00', '克'),
(20, 17, 500, '15.00', '克'),
(21, 17, 437, '5.00', '克'),
(22, 18, 9, '10.00', '克'),
(23, 18, 2, '10.00', '克'),
(24, 19, 331, '5.00', '克'),
(25, 19, 410, '5.00', '克'),
(26, 19, 14, '20.00', '克'),
(27, 20, 395, '2.00', '克'),
(28, 21, 449, '30.00', '克'),
(29, 22, 278, '100.00', '克'),
(30, 22, 416, '5.00', '克'),
(31, 23, 499, '15.00', '克'),
(32, 23, 2, '10.00', '克'),
(33, 24, 91, '50.00', '克'),
(34, 24, 92, '50.00', '克'),
(35, 25, 239, '100.00', '毫升'),
(36, 26, 501, '15.00', '克'),
(37, 27, 251, '10.00', '克'),
(38, 27, 419, '1.00', '克'),
(39, 28, 164, '250.00', '克'),
(40, 28, 82, '200.00', '克'),
(41, 29, 345, '15.00', '克'),
(42, 29, 354, '50.00', '克'),
(43, 30, 348, '400.00', '毫升'),
(44, 31, 34, '5.00', '克'),
(45, 32, 335, '15.00', '克'),
(46, 32, 502, '20.00', '克'),
(47, 33, 24, '10.00', '克'),
(48, 34, 231, '2.00', '個'),
(49, 34, 503, '15.00', '毫升'),
(50, 35, 499, '100.00', '克'),
(51, 35, 416, '1.00', '克'),
(52, 36, 504, '10.00', '毫升'),
(53, 37, 230, '2.00', '顆'),
(54, 38, 305, '2.00', '個'),
(55, 38, 191, '2.00', '片'),
(56, 39, 422, '2.00', '克'),
(57, 40, 506, '400.00', '毫升'),
(58, 41, 507, '30.00', '毫升'),
(59, 42, 505, '1.00', '份'),
(60, 44, 194, '3.00', '片'),
(61, 44, 94, '20.00', '克'),
(62, 44, 51, '20.00', '克'),
(63, 45, 232, '1.00', '顆'),
(64, 45, 16, '5.00', '克'),
(65, 45, 97, '2.00', '片'),
(66, 46, 475, '200.00', '克'),
(67, 46, 1, '1.00', '瓣'),
(68, 48, 508, '50.00', '克'),
(69, 48, 503, '30.00', '毫升'),
(70, 48, 426, '2.00', '克'),
(71, 48, 416, '2.00', '克'),
(72, 49, 345, '20.00', '克'),
(73, 49, 497, '20.00', '毫升'),
(74, 50, 345, '10.00', '克'),
(75, 51, 3, '3.00', '顆'),
(76, 52, 499, '30.00', '克'),
(77, 53, 341, '50.00', '毫升'),
(78, 54, 351, '500.00', '毫升'),
(79, 54, 22, '2.00', '克'),
(80, 55, 416, '2.00', '克'),
(81, 55, 419, '1.00', '克'),
(82, 56, 300, '4.00', '片'),
(83, 56, 509, '40.00', '克'),
(84, 58, 210, '10.00', '隻'),
(85, 59, 2, '10.00', '克'),
(86, 59, 419, '1.00', '克'),
(87, 59, 416, '2.00', '克'),
(88, 60, 499, '30.00', '克'),
(89, 60, 136, '4.00', '角'),
(90, 62, 503, '20.00', '毫升'),
(91, 62, 21, '5.00', '克'),
(92, 63, 163, '150.00', '克'),
(93, 63, 416, '2.00', '克'),
(94, 63, 419, '1.00', '克'),
(95, 64, 345, '5.00', '克'),
(96, 66, 263, '60.00', '克'),
(97, 66, 270, '20.00', '克'),
(98, 67, 43, '80.00', '克'),
(99, 67, 49, '50.00', '克'),
(100, 69, 264, '80.00', '克'),
(101, 70, 201, '150.00', '克'),
(102, 70, 417, '2.00', '克'),
(103, 72, 99, '80.00', '克'),
(104, 72, 57, '30.00', '克'),
(105, 73, 136, '1.00', '角'),
(106, 74, 178, '2.00', '片'),
(107, 75, 2, '15.00', '克'),
(108, 75, 331, '15.00', '克'),
(109, 75, 510, '15.00', '毫升'),
(110, 75, 340, '10.00', '毫升'),
(111, 76, 345, '10.00', '克'),
(112, 77, 100, '100.00', '克'),
(113, 79, 256, '1.00', '盒'),
(114, 80, 186, '200.00', '克'),
(115, 80, 5, '50.00', '克'),
(116, 80, 416, '2.00', '克'),
(117, 83, 91, '50.00', '克'),
(118, 83, 92, '50.00', '克'),
(119, 83, 511, '20.00', '克'),
(120, 85, 202, '150.00', '克'),
(121, 85, 4, '30.00', '克'),
(122, 86, 48, '50.00', '克'),
(123, 86, 136, '2.00', '角'),
(124, 86, 341, '15.00', '毫升'),
(125, 86, 22, '2.00', '克'),
(126, 86, 417, '2.00', '克'),
(127, 90, 4, '50.00', '克'),
(128, 91, 331, '20.00', '克'),
(129, 91, 410, '10.00', '克'),
(130, 91, 510, '20.00', '毫升'),
(131, 92, 170, '150.00', '克'),
(132, 93, 230, '1.00', '顆'),
(133, 94, 272, '1.00', '碗'),
(134, 94, 16, '5.00', '克'),
(135, 95, 4, '50.00', '克'),
(136, 95, 345, '10.00', '克'),
(137, 96, 512, '200.00', '克'),
(138, 97, 491, '150.00', '克'),
(139, 97, 360, '30.00', '克'),
(140, 98, 14, '20.00', '克'),
(141, 99, 462, '2.00', '克'),
(142, 100, 3, '100.00', '克'),
(143, 100, 56, '150.00', '克'),
(144, 100, 57, '80.00', '克'),
(145, 100, 345, '15.00', '克'),
(146, 101, 164, '250.00', '克'),
(147, 102, 497, '400.00', '毫升'),
(148, 103, 513, '50.00', '克'),
(149, 105, 239, '20.00', '毫升'),
(150, 106, 2, '10.00', '克'),
(151, 106, 363, '20.00', '克'),
(152, 106, 510, '20.00', '毫升'),
(153, 106, 340, '10.00', '毫升'),
(154, 107, 31, '100.00', '克'),
(155, 108, 345, '5.00', '克'),
(156, 108, 514, '200.00', '克'),
(157, 111, 201, '150.00', '克'),
(158, 112, 331, '15.00', '毫升'),
(159, 112, 510, '15.00', '毫升'),
(160, 112, 410, '5.00', '克'),
(161, 112, 340, '10.00', '毫升'),
(162, 112, 2, '5.00', '克'),
(163, 113, 43, '80.00', '克'),
(164, 114, 345, '10.00', '克'),
(165, 116, 462, '1.00', '克'),
(166, 116, 16, '5.00', '克'),
(167, 117, 5, '50.00', '克'),
(168, 117, 2, '10.00', '克'),
(169, 117, 57, '30.00', '克'),
(170, 117, 345, '15.00', '克'),
(171, 118, 187, '200.00', '克'),
(172, 119, 367, '30.00', '克'),
(173, 119, 369, '200.00', '克'),
(174, 119, 433, '2.00', '克'),
(175, 120, 277, '160.00', '克'),
(176, 120, 416, '5.00', '克'),
(177, 122, 251, '10.00', '克'),
(178, 123, 91, '50.00', '克'),
(179, 123, 92, '50.00', '克'),
(180, 123, 499, '10.00', '克'),
(181, 124, 3, '50.00', '克'),
(182, 124, 515, '150.00', '克'),
(183, 125, 341, '50.00', '毫升'),
(184, 126, 350, '500.00', '毫升'),
(185, 127, 239, '30.00', '毫升'),
(186, 127, 501, '20.00', '克'),
(187, 128, 499, '10.00', '克'),
(188, 128, 251, '20.00', '克'),
(189, 129, 165, '500.00', '克'),
(190, 129, 345, '15.00', '克'),
(191, 129, 422, '10.00', '克'),
(192, 129, 431, '5.00', '克'),
(193, 129, 432, '5.00', '克'),
(194, 129, 419, '2.00', '克'),
(195, 129, 416, '5.00', '克'),
(196, 129, 410, '5.00', '克'),
(197, 132, 387, '20.00', '克'),
(198, 135, 279, '100.00', '克'),
(199, 135, 416, '5.00', '克'),
(200, 136, 345, '15.00', '克'),
(201, 136, 2, '15.00', '克'),
(202, 136, 500, '2.00', '克'),
(203, 137, 218, '300.00', '克'),
(204, 137, 341, '50.00', '毫升'),
(205, 139, 21, '5.00', '克'),
(206, 139, 345, '5.00', '克'),
(207, 140, 231, '2.00', '顆'),
(208, 140, 251, '30.00', '克'),
(209, 140, 419, '1.00', '克'),
(210, 140, 239, '30.00', '毫升'),
(211, 141, 277, '100.00', '克'),
(212, 141, 416, '5.00', '克'),
(213, 142, 191, '60.00', '克'),
(214, 145, 419, '1.00', '克'),
(215, 146, 516, '30.00', '克'),
(216, 146, 1, '20.00', '克'),
(217, 147, 2, '10.00', '顆'),
(218, 147, 13, '1.00', '根'),
(219, 147, 164, '300.00', '克'),
(220, 148, 331, '30.00', '毫升'),
(221, 148, 340, '30.00', '毫升'),
(222, 148, 410, '15.00', '克'),
(223, 150, 25, '20.00', '克'),
(224, 151, 177, '600.00', '克'),
(225, 153, 414, '30.00', '克'),
(226, 153, 14, '20.00', '克'),
(227, 153, 1, '15.00', '克'),
(228, 153, 2, '15.00', '顆'),
(229, 154, 331, '60.00', '毫升'),
(230, 154, 340, '30.00', '毫升'),
(231, 154, 497, '500.00', '毫升'),
(232, 156, 204, '1.00', '尾'),
(233, 156, 1, '10.00', '克'),
(234, 156, 16, '10.00', '克'),
(235, 158, 16, '10.00', '克'),
(236, 158, 13, '5.00', '克'),
(237, 159, 345, '30.00', '毫升'),
(238, 160, 331, '30.00', '毫升'),
(239, 161, 256, '300.00', '克'),
(240, 162, 186, '100.00', '克'),
(241, 162, 362, '30.00', '克'),
(242, 162, 2, '15.00', '克'),
(243, 162, 1, '10.00', '克'),
(244, 163, 331, '15.00', '毫升'),
(245, 163, 410, '5.00', '克'),
(246, 163, 497, '200.00', '毫升'),
(247, 164, 428, '10.00', '克'),
(248, 165, 16, '10.00', '克'),
(249, 165, 434, '2.00', '克'),
(250, 166, 221, '80.00', '克'),
(251, 167, 177, '200.00', '克'),
(252, 167, 345, '10.00', '克'),
(253, 168, 254, '100.00', '克'),
(254, 169, 2, '15.00', '克'),
(255, 169, 13, '5.00', '克'),
(256, 170, 54, '100.00', '克'),
(257, 170, 16, '20.00', '克'),
(258, 171, 331, '20.00', '毫升'),
(259, 171, 410, '5.00', '克'),
(260, 171, 340, '15.00', '毫升'),
(261, 172, 516, '45.00', '克'),
(262, 172, 1, '50.00', '克'),
(263, 173, 164, '500.00', '克'),
(264, 174, 340, '300.00', '毫升'),
(265, 174, 497, '300.00', '毫升'),
(266, 174, 482, '8.00', '顆'),
(267, 174, 481, '5.00', '克'),
(268, 176, 416, '2.00', '克'),
(269, 177, 230, '2.00', '顆'),
(270, 178, 235, '20.00', '毫升'),
(271, 178, 504, '2.00', '滴'),
(272, 178, 260, '35.00', '克'),
(273, 178, 426, '1.00', '克'),
(274, 179, 410, '25.00', '克'),
(275, 181, 345, '5.00', '克'),
(276, 183, 410, '50.00', '克'),
(277, 183, 497, '30.00', '毫升'),
(278, 184, 235, '400.00', '毫升'),
(279, 184, 410, '40.00', '克'),
(280, 184, 504, '3.00', '滴'),
(281, 185, 230, '3.00', '顆'),
(282, 189, 299, '1.00', '片'),
(283, 190, 499, '20.00', '克'),
(284, 192, 387, '15.00', '克'),
(285, 193, 409, '2.50', '片'),
(286, 194, 235, '250.00', '毫升'),
(287, 194, 239, '250.00', '毫升'),
(288, 194, 410, '40.00', '克'),
(289, 195, 504, '1.00', '茶匙'),
(290, 197, 109, '2.00', '根'),
(291, 198, 499, '100.00', '克'),
(292, 198, 410, '80.00', '克'),
(293, 199, 230, '2.00', '顆'),
(294, 200, 260, '200.00', '克'),
(295, 200, 426, '5.00', '克'),
(296, 203, 499, '100.00', '克'),
(297, 203, 412, '80.00', '克'),
(298, 203, 410, '50.00', '克'),
(299, 204, 230, '1.00', '顆'),
(300, 204, 389, '1.00', '茶匙'),
(301, 205, 391, '150.00', '克'),
(302, 205, 407, '3.00', '克'),
(303, 205, 416, '2.00', '克'),
(304, 206, 274, '150.00', '克'),
(305, 206, 480, '80.00', '克'),
(306, 209, 445, '2.00', '克'),
(307, 210, 230, '2.00', '顆'),
(308, 210, 410, '60.00', '克'),
(309, 210, 387, '15.00', '克'),
(310, 211, 392, '100.00', '克'),
(311, 211, 408, '3.00', '克'),
(312, 212, 499, '100.00', '克'),
(313, 215, 391, '300.00', '克'),
(314, 215, 408, '10.00', '克'),
(315, 215, 416, '2.00', '克'),
(316, 216, 499, '80.00', '克'),
(317, 217, 455, '60.00', '克'),
(318, 218, 238, '100.00', '毫升'),
(319, 218, 388, '40.00', '克'),
(320, 221, 238, '5.00', '毫升'),
(321, 223, 447, '200.00', '克'),
(322, 223, 499, '120.00', '克'),
(323, 225, 410, '150.00', '克'),
(324, 225, 230, '2.00', '顆'),
(325, 226, 391, '80.00', '克'),
(326, 226, 406, '30.00', '克'),
(327, 226, 416, '1.00', '克'),
(328, 231, 238, '500.00', '毫升'),
(329, 231, 499, '50.00', '克'),
(330, 231, 389, '1.00', '茶匙'),
(331, 232, 410, '200.00', '克'),
(332, 232, 392, '125.00', '克'),
(333, 232, 231, '2.00', '個'),
(334, 233, 343, '40.00', '毫升'),
(335, 239, 499, '75.00', '克'),
(336, 239, 413, '40.00', '克'),
(337, 239, 230, '1.00', '顆'),
(338, 239, 392, '150.00', '克'),
(339, 239, 453, '20.00', '克'),
(340, 242, 230, '3.00', '顆'),
(341, 242, 410, '100.00', '克'),
(342, 242, 503, '120.00', '毫升'),
(343, 242, 19, '5.00', '克'),
(344, 243, 499, '100.00', '克'),
(345, 245, 230, '2.00', '顆'),
(346, 245, 410, '60.00', '克'),
(347, 247, 239, '150.00', '毫升'),
(348, 247, 410, '15.00', '克'),
(349, 248, 385, '200.00', '克'),
(350, 248, 499, '30.00', '克'),
(351, 248, 343, '10.00', '毫升'),
(352, 249, 461, '6.00', '顆'),
(353, 250, 413, '10.00', '克'),
(354, 251, 239, '150.00', '毫升'),
(355, 251, 410, '15.00', '克'),
(356, 252, 143, '6.00', '顆'),
(357, 252, 107, '0.50', '顆'),
(358, 253, 297, '2.00', '片'),
(359, 259, 241, '200.00', '克'),
(360, 260, 274, '30.00', '克'),
(361, 261, 144, '50.00', '克'),
(362, 261, 387, '15.00', '克'),
(363, 263, 29, '2.00', '片'),
(364, 264, 409, '2.00', '片'),
(365, 265, 260, '400.00', '毫升'),
(366, 265, 464, '30.00', '克'),
(367, 265, 410, '40.00', '克'),
(368, 268, 239, '50.00', '毫升'),
(369, 271, 452, '30.00', '克'),
(370, 271, 455, '30.00', '克'),
(371, 272, 393, '200.00', '克'),
(372, 272, 416, '1.00', '克'),
(373, 273, 345, '60.00', '克'),
(374, 273, 388, '60.00', '克'),
(375, 279, 477, '100.00', '克'),
(376, 280, 496, '300.00', '毫升'),
(377, 281, 410, '60.00', '克'),
(378, 282, 409, '3.00', '片'),
(379, 283, 238, '400.00', '毫升'),
(380, 283, 410, '20.00', '克'),
(381, 287, 294, '300.00', '克'),
(382, 287, 223, '100.00', '克'),
(383, 288, 352, '400.00', '毫升'),
(384, 288, 360, '45.00', '克'),
(385, 288, 421, '10.00', '克'),
(386, 290, 41, '150.00', '克'),
(387, 290, 233, '2.00', '顆'),
(388, 292, 13, '2.00', '支'),
(389, 292, 462, '2.00', '克'),
(390, 293, 360, '30.00', '克'),
(391, 293, 421, '10.00', '克'),
(392, 293, 2, '10.00', '克'),
(393, 295, 197, '100.00', '克'),
(394, 295, 196, '2.00', '根'),
(395, 295, 491, '100.00', '克'),
(396, 296, 295, '1.00', '包'),
(397, 296, 478, '1.00', '大匙'),
(398, 296, 248, '1.00', '片'),
(399, 300, 516, '10.00', '毫升'),
(400, 300, 2, '10.00', '克'),
(401, 300, 3, '0.30', '顆'),
(402, 301, 514, '150.00', '克'),
(403, 302, 491, '150.00', '克'),
(404, 303, 496, '500.00', '毫升'),
(405, 304, 421, '5.00', '克'),
(406, 304, 256, '150.00', '克'),
(407, 305, 101, '50.00', '克'),
(408, 305, 37, '50.00', '克'),
(409, 306, 77, '50.00', '克'),
(410, 306, 57, '30.00', '克'),
(411, 306, 92, '2.00', '朵'),
(412, 307, 170, '100.00', '克'),
(413, 308, 360, '30.00', '克'),
(414, 308, 516, '5.00', '毫升'),
(415, 308, 410, '5.00', '克'),
(416, 309, 516, '15.00', '毫升'),
(417, 309, 272, '1.00', '碗'),
(418, 311, 230, '1.00', '顆'),
(419, 312, 165, '500.00', '克'),
(420, 312, 416, '2.00', '克'),
(421, 312, 419, '1.00', '克'),
(422, 313, 394, '100.00', '克'),
(423, 316, 499, '30.00', '克'),
(424, 316, 2, '20.00', '克'),
(425, 317, 331, '20.00', '毫升'),
(426, 317, 387, '60.00', '克'),
(427, 318, 462, '5.00', '克'),
(428, 319, 92, '4.00', '朵'),
(429, 320, 164, '400.00', '克'),
(430, 321, 482, '6.00', '顆'),
(431, 321, 9, '15.00', '克'),
(432, 321, 340, '30.00', '毫升'),
(433, 323, 90, '200.00', '克'),
(434, 324, 481, '10.00', '克'),
(435, 324, 416, '5.00', '克'),
(436, 325, 181, '300.00', '克'),
(437, 326, 517, '0.60', '根'),
(438, 326, 518, '1.00', '根'),
(439, 327, 9, '15.00', '克'),
(440, 327, 496, '1500.00', '毫升'),
(441, 329, 416, '5.00', '克'),
(442, 329, 27, '5.00', '克'),
(443, 330, 519, '100.00', '克'),
(444, 331, 350, '1000.00', '毫升'),
(445, 332, 256, '1.00', '盒'),
(446, 333, 395, '30.00', '克'),
(447, 334, 230, '2.00', '顆'),
(448, 335, 420, '5.00', '克'),
(449, 335, 337, '45.00', '毫升'),
(450, 336, 16, '10.00', '克'),
(451, 337, 164, '400.00', '克'),
(452, 337, 213, '200.00', '克'),
(453, 338, 1, '4.00', '瓣'),
(454, 338, 9, '10.00', '克'),
(455, 339, 340, '30.00', '毫升'),
(456, 339, 496, '1200.00', '毫升'),
(457, 340, 520, '0.50', '罐'),
(458, 343, 181, '300.00', '克'),
(459, 343, 38, '300.00', '克'),
(460, 343, 230, '2.00', '顆'),
(461, 344, 38, '300.00', '克'),
(462, 345, 9, '10.00', '克'),
(463, 345, 496, '1200.00', '毫升'),
(464, 347, 416, '5.00', '克'),
(465, 347, 410, '2.00', '克'),
(466, 348, 230, '2.00', '顆'),
(467, 348, 16, '5.00', '克'),
(468, 349, 171, '600.00', '克'),
(469, 351, 14, '30.00', '克'),
(470, 351, 9, '20.00', '克'),
(471, 351, 1, '5.00', '瓣'),
(472, 351, 359, '45.00', '克'),
(473, 353, 331, '60.00', '毫升'),
(474, 353, 340, '30.00', '毫升'),
(475, 353, 436, '3.00', '顆'),
(476, 353, 410, '15.00', '克'),
(477, 353, 351, '1500.00', '毫升'),
(478, 354, 517, '0.60', '根'),
(479, 354, 55, '150.00', '克'),
(480, 355, 284, '400.00', '克'),
(481, 355, 36, '4.00', '株'),
(482, 358, 5, '50.00', '克'),
(483, 358, 521, '250.00', '克'),
(484, 359, 426, '5.00', '克'),
(485, 359, 422, '5.00', '克'),
(486, 359, 416, '2.00', '克'),
(487, 360, 310, '4.00', '片'),
(488, 362, 377, '60.00', '克'),
(489, 362, 240, '30.00', '克'),
(490, 362, 27, '10.00', '克'),
(491, 362, 136, '2.00', '角'),
(492, 363, 210, '6.00', '隻'),
(493, 364, 496, '800.00', '毫升'),
(494, 364, 31, '2.00', '支'),
(495, 364, 12, '20.00', '克'),
(496, 364, 34, '4.00', '片'),
(497, 365, 90, '100.00', '克'),
(498, 365, 89, '6.00', '顆'),
(499, 366, 213, '150.00', '克'),
(500, 367, 335, '30.00', '毫升'),
(501, 367, 348, '100.00', '毫升'),
(502, 368, 503, '45.00', '毫升'),
(503, 369, 163, '150.00', '克'),
(504, 370, 52, '200.00', '克'),
(505, 371, 522, '10.00', '克'),
(506, 371, 2, '10.00', '克'),
(507, 371, 231, '1.00', '個'),
(508, 371, 503, '15.00', '毫升'),
(509, 372, 345, '45.00', '毫升'),
(510, 372, 251, '20.00', '克'),
(511, 374, 308, '30.00', '克'),
(512, 375, 173, '1.00', '客'),
(513, 375, 417, '2.00', '克'),
(514, 375, 418, '1.00', '克'),
(515, 376, 345, '10.00', '毫升'),
(516, 377, 499, '20.00', '克'),
(517, 377, 1, '2.00', '瓣'),
(518, 377, 28, '5.00', '克'),
(519, 379, 48, '100.00', '克'),
(520, 379, 89, '60.00', '克'),
(521, 380, 291, '100.00', '克'),
(522, 380, 210, '6.00', '隻'),
(523, 380, 512, '100.00', '克'),
(524, 381, 313, '6.00', '片'),
(525, 382, 25, '10.00', '克'),
(526, 383, 45, '6.00', '根'),
(527, 384, 335, '20.00', '毫升'),
(528, 384, 503, '20.00', '毫升'),
(529, 384, 410, '10.00', '克'),
(530, 385, 440, '0.10', '克'),
(531, 386, 210, '6.00', '隻'),
(532, 386, 219, '100.00', '克'),
(533, 387, 515, '150.00', '克'),
(534, 387, 341, '30.00', '毫升'),
(535, 388, 350, '400.00', '毫升'),
(536, 389, 214, '6.00', '顆'),
(537, 390, 136, '2.00', '角'),
(538, 391, 236, '2.00', '顆'),
(539, 391, 523, '50.00', '克'),
(540, 392, 186, '300.00', '克'),
(541, 392, 331, '10.00', '毫升'),
(542, 392, 496, '30.00', '毫升'),
(543, 395, 16, '10.00', '克'),
(544, 396, 175, '300.00', '克'),
(545, 397, 5, '100.00', '克'),
(546, 398, 496, '1200.00', '毫升'),
(547, 398, 60, '200.00', '克'),
(548, 398, 367, '30.00', '克'),
(549, 398, 524, '2.00', '片'),
(550, 399, 55, '100.00', '克'),
(551, 399, 65, '150.00', '克'),
(552, 400, 41, '100.00', '克'),
(553, 401, 240, '30.00', '克'),
(554, 402, 210, '6.00', '隻'),
(555, 403, 402, '100.00', '克'),
(556, 403, 496, '150.00', '毫升'),
(557, 405, 345, '500.00', '毫升'),
(558, 405, 71, '2.00', '片'),
(559, 405, 83, '2.00', '條'),
(560, 407, 333, '40.00', '毫升'),
(561, 407, 58, '50.00', '克'),
(562, 408, 180, '400.00', '克'),
(563, 409, 331, '80.00', '毫升'),
(564, 409, 414, '30.00', '克'),
(565, 410, 444, '50.00', '克'),
(566, 410, 427, '2.00', '克'),
(567, 411, 230, '4.00', '顆'),
(568, 411, 496, '800.00', '毫升'),
(569, 413, 272, '1.00', '碗'),
(570, 413, 490, '1.00', '片'),
(571, 414, 397, '40.00', '克'),
(572, 414, 395, '20.00', '克'),
(573, 415, 216, '100.00', '克'),
(574, 417, 230, '1.00', '顆'),
(575, 417, 526, '2.00', '株'),
(576, 419, 364, '30.00', '毫升'),
(577, 419, 365, '15.00', '毫升'),
(578, 420, 345, '30.00', '毫升'),
(579, 420, 2, '15.00', '克'),
(580, 421, 390, '250.00', '克'),
(581, 422, 367, '50.00', '克'),
(582, 423, 242, '125.00', '克'),
(583, 424, 23, '10.00', '克'),
(584, 424, 387, '15.00', '毫升'),
(585, 425, 390, '250.00', '克'),
(586, 426, 367, '50.00', '克'),
(587, 426, 501, '15.00', '克'),
(588, 428, 242, '125.00', '克'),
(589, 429, 23, '10.00', '克'),
(590, 430, 347, '10.00', '毫升'),
(591, 431, 367, '50.00', '克'),
(592, 431, 243, '125.00', '克'),
(593, 432, 193, '60.00', '克'),
(594, 432, 489, '20.00', '克'),
(595, 434, 23, '10.00', '克'),
(596, 434, 347, '5.00', '毫升'),
(597, 435, 236, '1.00', '顆'),
(598, 435, 239, '10.00', '毫升'),
(599, 436, 498, '100.00', '克'),
(600, 436, 499, '60.00', '克'),
(601, 437, 392, '40.00', '克'),
(602, 437, 405, '15.00', '克'),
(603, 440, 245, '50.00', '克'),
(604, 440, 144, '10.00', '顆'),
(605, 441, 498, '100.00', '克'),
(606, 441, 499, '50.00', '克'),
(607, 442, 392, '40.00', '克'),
(608, 442, 405, '15.00', '克'),
(609, 445, 385, '60.00', '克'),
(610, 445, 343, '5.00', '毫升'),
(611, 446, 498, '100.00', '克'),
(612, 446, 499, '50.00', '克'),
(613, 447, 392, '40.00', '克'),
(614, 447, 405, '15.00', '克'),
(615, 447, 410, '20.00', '克'),
(616, 450, 164, '300.00', '克'),
(617, 451, 105, '100.00', '克'),
(618, 452, 500, '15.00', '克'),
(619, 452, 437, '5.00', '克'),
(620, 454, 454, '40.00', '克'),
(621, 454, 331, '15.00', '毫升'),
(622, 455, 397, '80.00', '克'),
(623, 457, 387, '40.00', '毫升'),
(624, 457, 503, '15.00', '毫升'),
(625, 457, 500, '15.00', '克'),
(626, 459, 451, '30.00', '克'),
(627, 460, 256, '2.00', '盒'),
(628, 462, 500, '15.00', '克'),
(629, 462, 437, '5.00', '克'),
(630, 463, 331, '30.00', '毫升'),
(631, 463, 337, '15.00', '毫升'),
(632, 464, 449, '30.00', '克');

-- --------------------------------------------------------

--
-- 資料表結構 `support_tickets`
--

CREATE TABLE `support_tickets` (
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_email` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ticket_type` tinyint(4) NOT NULL,
  `ticket_subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ticket_content` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint(4) DEFAULT NULL,
  `reply_content` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `replied_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `tags`
--

CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL,
  `tag_name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tag_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `tags`
--

INSERT INTO `tags` (`tag_id`, `tag_name`, `tag_type`) VALUES
(1, '披薩', '料理種類'),
(2, '義式料理', '異國風味'),
(3, '主食', '餐點分類'),
(4, '甜點', '餐點分類'),
(5, '蛋糕', '料理種類'),
(6, '抹茶', '風味分類'),
(7, '川菜', '異國風味'),
(8, '熱炒', '料理方式'),
(9, '雞肉料理', '食材分類'),
(10, '西式麵食', '料理種類'),
(11, '松露風味', '風味分類'),
(12, '泰式料理', '異國風味'),
(13, '咖哩', '料理種類'),
(14, '燉煮', '料理方式'),
(15, '早午餐', '餐點分類'),
(16, '蛋料理', '食材分類'),
(17, '美式料理', '異國風味'),
(18, '日式料理', '異國風味'),
(19, '拉麵', '料理種類'),
(20, '麵食', '餐點分類'),
(21, '中東料理', '異國風味'),
(22, '冷盤', '餐點分類'),
(23, '全素/五辛素', '飲食禁忌'),
(24, '法式料理', '異國風味'),
(25, '湯品', '餐點分類'),
(26, '焗烤', '料理方式'),
(27, '海鮮料理', '食材分類'),
(28, '烤箱料理', '料理方式'),
(29, '地中海風味', '異國風味'),
(30, '健康餐', '餐點分類'),
(31, '舒肥', '料理方式'),
(32, '低脂高蛋白', '風味分類'),
(33, '便當', '餐點分類'),
(34, '家常菜', '餐點分類'),
(35, '漢堡排', '料理種類'),
(36, '紙包料理', '料理方式'),
(37, '低卡料理', '風味分類'),
(38, '豬肉料理', '食材分類'),
(39, '丼飯', '料理種類'),
(40, '牛肉料理', '食材分類'),
(41, '韓式料理', '異國風味'),
(42, '燉飯', '料理種類'),
(43, '台式料理', '異國風味'),
(44, '中式料理', '異國風味'),
(45, '清蒸', '料理方式'),
(46, '豆腐料理', '食材分類'),
(47, '客家料理', '異國風味'),
(48, '溫補料理', '餐點分類'),
(49, '下午茶', '餐點分類'),
(50, '布丁/果凍', '料理種類'),
(51, '磅蛋糕', '料理種類'),
(52, '餅乾', '料理種類'),
(53, '瑪德蓮', '料理種類'),
(54, '司康', '料理種類'),
(55, '布朗尼', '料理種類'),
(56, '可麗露', '料理種類'),
(57, '塔/派', '料理種類'),
(58, '蒙布朗', '料理種類'),
(59, '三明治', '料理種類'),
(60, '優格杯', '料理種類'),
(61, '奶凍', '料理種類'),
(62, '石鍋拌飯', '料理種類'),
(63, '炸雞', '料理種類'),
(64, '墨西哥料理', '異國風味'),
(65, '塔可', '料理種類'),
(66, '沙拉', '餐點分類'),
(67, '牛排', '料理種類'),
(68, '越式料理', '異國風味'),
(69, '輕食', '餐點分類'),
(70, '西班牙料理', '異國風味'),
(71, '西班牙大鍋飯', '料理種類'),
(72, '蒸煮料理', '料理方式'),
(73, '俄式料理', '異國風味'),
(74, '天婦羅', '料理種類'),
(75, '炸物', '料理方式'),
(76, '夜市小吃', '餐點分類'),
(77, '煎炸料理', '料理方式');

-- --------------------------------------------------------

--
-- 資料表結構 `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `line_id` varchar(100) DEFAULT NULL,
  `user_name` varchar(50) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `user_phone` varchar(20) DEFAULT NULL,
  `user_address` varchar(255) DEFAULT NULL,
  `user_password` varchar(255) NOT NULL,
  `user_startdate` datetime NOT NULL,
  `user_url` varchar(255) DEFAULT NULL,
  `user_bio` text COMMENT '個人簡介',
  `user_cover_image` varchar(255) DEFAULT NULL COMMENT '封面圖片',
  `is_verified` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- 傾印資料表的資料 `users`
--

INSERT INTO `users` (`user_id`, `line_id`, `user_name`, `user_email`, `user_phone`, `user_address`, `user_password`, `user_startdate`, `user_url`, `user_bio`, `user_cover_image`, `is_verified`, `is_active`) VALUES
(1, NULL, 'Recimo官方', 'recimo@gmail.com', '0912345678', '桃園市中壢區復興路46號8樓', '$2y$10$otAwsO50/9KXW.zuGNNyq.jatOZXDKHuVTzftlT6.on86I/UIOe0a', '2025-12-09 00:00:00', 'img/site/Recimo_avatar.svg', 'Recimo 官方帳號，為您提供最優質的食譜', 'img/profile/2.png', 1, 1),
(2, NULL, '小R(測試人員)', 'admin@test.com', '0923456789', '桃園市中壢區復興路46號9樓', '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu', '2020-01-22 22:25:00', NULL, NULL, NULL, 1, 1),
(3, NULL, 'tom', 'tom@gmail.com', '0934567890', '桃園市中壢區復興路46號8樓', '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu', '2026-01-27 19:30:00', 'img/site/T_avatar.svg', NULL, NULL, 1, 1),
(4, NULL, 'wei', 'wei@gmail.com', '0945678901', '桃園市中壢區復興路46號8樓', '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu', '2026-01-27 19:30:00', 'img/site/W_avatar.svg', '美食愛好者，熱愛烹飪與分享', 'img/profile/2.png', 1, 1),
(5, NULL, 'HelenKuo', 'helenKuo@gmail.com', '0956789012', '桃園市中壢區復興路46號8樓', '$2y$10$C55GYF.6P9q256PmvqRUqeQPJ5rwKUiC7DWhsP3WkHfwS.ORx93vO', '2026-01-27 19:30:00', 'img/site/H_avatar.svg', NULL, NULL, 1, 1),
(6, NULL, 'pei', 'pei@gmail.com', '0911111111', '桃園市中壢區復興路46號8樓', '$2y$10$1iCtREvd63kWjolzfW2ByOmx09DrqkZgFpje1.K7bjNYrMf3fCxUC', '2026-01-23 16:20:00', 'img/site/P_avatar.svg', NULL, NULL, 1, 1),
(7, NULL, 'yutung', 'yutung@gmail.com', '0922222222', '桃園市中壢區復興路46號8樓', '$2y$10$fXS3wuKIFX/IEfJBarvGLe9fsJTiekTxvCuHtR3dRnLEmpo.5ZfEy', '2026-01-27 19:30:00', 'img/site/yutung_avatar.svg', NULL, NULL, 1, 1),
(8, NULL, 'Hsu', 'hsu@test.com', '0933333333', '桃園市中壢區復興路46號8樓', '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu', '2026-01-27 19:30:00', 'img/site/H_avatar.svg', NULL, NULL, 1, 1),
(9, NULL, '小小R(測試停用)', '123@test.com', '0900000000', '桃園市中壢區復興路46號9樓', '$2y$10$e5pwotJLcuxX6kyFPJRfaO.bK0OqzpCI1065Yi/a3TY6nbpNM2BNu', '2026-01-27 20:00:00', NULL, NULL, NULL, 1, 0);

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `admin_account` (`admin_account`);

--
-- 資料表索引 `announcement`
--
ALTER TABLE `announcement`
  ADD PRIMARY KEY (`announcement_id`);

--
-- 資料表索引 `browsing_history`
--
ALTER TABLE `browsing_history`
  ADD PRIMARY KEY (`browsing_history_id`),
  ADD UNIQUE KEY `unique_user_recipe` (`user_id`,`recipe_id`),
  ADD KEY `fk_history_user_id` (`user_id`),
  ADD KEY `fk_history_recipe_id` (`recipe_id`);

--
-- 資料表索引 `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`carts_id`),
  ADD UNIQUE KEY `user_product_unique` (`user_id`,`product_id`),
  ADD KEY `fk_cart_user` (`user_id`),
  ADD KEY `fk_cart_product` (`product_id`);

--
-- 資料表索引 `cooking_logs`
--
ALTER TABLE `cooking_logs`
  ADD PRIMARY KEY (`cooking_log_id`),
  ADD KEY `fk_logs_recipe` (`recipe_id`),
  ADD KEY `fk_logs_user` (`user_id`);

--
-- 資料表索引 `faqs`
--
ALTER TABLE `faqs`
  ADD PRIMARY KEY (`faq_id`);

--
-- 資料表索引 `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`favorite_id`),
  ADD KEY `fk_favorites_user` (`user_id`),
  ADD KEY `fk_favorites_recipe` (`recipe_id`),
  ADD KEY `fk_favorites_folder` (`folder_id`);

--
-- 資料表索引 `favorites_folders`
--
ALTER TABLE `favorites_folders`
  ADD PRIMARY KEY (`favorites_folder_id`),
  ADD KEY `fk_favorites_folders_creator` (`creator_id`);

--
-- 資料表索引 `follows`
--
ALTER TABLE `follows`
  ADD PRIMARY KEY (`follow_id`),
  ADD UNIQUE KEY `unique_follow` (`follower_id`,`followed_id`),
  ADD KEY `idx_follower` (`follower_id`),
  ADD KEY `idx_followed` (`followed_id`);

--
-- 資料表索引 `ingredients`
--
ALTER TABLE `ingredients`
  ADD PRIMARY KEY (`ingredient_id`);

--
-- 資料表索引 `log_ingredients`
--
ALTER TABLE `log_ingredients`
  ADD PRIMARY KEY (`log_ingredient_id`),
  ADD KEY `fk_log_ingredients_log` (`cooking_log_id`),
  ADD KEY `fk_log_ingredients_ingredient` (`ingredient_id`);

--
-- 資料表索引 `log_step_note`
--
ALTER TABLE `log_step_note`
  ADD PRIMARY KEY (`log_step_note_id`),
  ADD KEY `fk_log_step_log` (`cooking_log_id`),
  ADD KEY `fk_log_step_step` (`step_id`);

--
-- 資料表索引 `meal_plans`
--
ALTER TABLE `meal_plans`
  ADD PRIMARY KEY (`plan_id`),
  ADD KEY `fk_plan_user` (`user_id`),
  ADD KEY `fk_plan_source` (`source_template_id`),
  ADD KEY `fk_plan_cover` (`cover_template_id`);

--
-- 資料表索引 `meal_plan_cover_template`
--
ALTER TABLE `meal_plan_cover_template`
  ADD PRIMARY KEY (`cover_template_id`);

--
-- 資料表索引 `meal_plan_daily_targets`
--
ALTER TABLE `meal_plan_daily_targets`
  ADD PRIMARY KEY (`daily_target_id`),
  ADD UNIQUE KEY `unique_plan_date` (`plan_id`,`target_date`),
  ADD KEY `fk_target_plan` (`plan_id`);

--
-- 資料表索引 `meal_plan_folders`
--
ALTER TABLE `meal_plan_folders`
  ADD PRIMARY KEY (`meal_plan_folder_id`),
  ADD KEY `fk_meal_plan_folders_creator_id` (`creator_id`);

--
-- 資料表索引 `meal_plan_items`
--
ALTER TABLE `meal_plan_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `fk_meal_plan_items_plan_id` (`plan_id`),
  ADD KEY `fk_meal_plan_items_recipe_id` (`recipe_id`);

--
-- 資料表索引 `meal_plan_templates`
--
ALTER TABLE `meal_plan_templates`
  ADD PRIMARY KEY (`template_id`),
  ADD KEY `fk_templates_cover_id` (`cover_template_id`);

--
-- 資料表索引 `meal_plan_template_items`
--
ALTER TABLE `meal_plan_template_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `fk_item_template` (`template_id`),
  ADD KEY `fk_item_recipe` (`recipe_id`);

--
-- 資料表索引 `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `fk_notifications_receiver` (`receiver_id`),
  ADD KEY `fk_notifications_sender` (`sender_id`);

--
-- 資料表索引 `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `fk_orders_user` (`user_id`);

--
-- 資料表索引 `order_products`
--
ALTER TABLE `order_products`
  ADD PRIMARY KEY (`order_product_id`),
  ADD KEY `fk_order` (`order_id`),
  ADD KEY `fk_product` (`product_id`);

--
-- 資料表索引 `personal_folders`
--
ALTER TABLE `personal_folders`
  ADD PRIMARY KEY (`personal_folder_id`),
  ADD KEY `fk_personal_folders_creator` (`creator_id`);

--
-- 資料表索引 `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- 資料表索引 `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`recipe_id`),
  ADD KEY `fk_recipes_author` (`author_id`),
  ADD KEY `fk_recipes_folder` (`personal_folder_id`),
  ADD KEY `fk_recipes_parent` (`parent_recipe_id`);

--
-- 資料表索引 `recipe_comments`
--
ALTER TABLE `recipe_comments`
  ADD PRIMARY KEY (`comment_id`),
  ADD KEY `fk_comments_recipe` (`recipe_id`),
  ADD KEY `fk_comments_user` (`user_id`);

--
-- 資料表索引 `recipe_gallery`
--
ALTER TABLE `recipe_gallery`
  ADD PRIMARY KEY (`gallery_id`),
  ADD KEY `fk_gallery_recipe` (`recipe_id`),
  ADD KEY `fk_gallery_user` (`user_id`);

--
-- 資料表索引 `recipe_ingredients`
--
ALTER TABLE `recipe_ingredients`
  ADD PRIMARY KEY (`recipe_ingredient_id`),
  ADD KEY `idx_recipe_id` (`recipe_id`),
  ADD KEY `idx_ingredient_id` (`ingredient_id`);

--
-- 資料表索引 `recipe_tag`
--
ALTER TABLE `recipe_tag`
  ADD PRIMARY KEY (`recipe_tag_id`),
  ADD KEY `fk_tag_id` (`tag_id`),
  ADD KEY `fk_recipe_id` (`recipe_id`);

--
-- 資料表索引 `remove_bg_ingredients`
--
ALTER TABLE `remove_bg_ingredients`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `reported_comments`
--
ALTER TABLE `reported_comments`
  ADD PRIMARY KEY (`reported_comment_id`),
  ADD KEY `fk_reports_comment` (`comment_id`),
  ADD KEY `fk_reports_reporter` (`reporter_id`),
  ADD KEY `fk_reports_handler` (`handler_id`);

--
-- 資料表索引 `reported_galleries`
--
ALTER TABLE `reported_galleries`
  ADD PRIMARY KEY (`reported_gallery_id`),
  ADD KEY `fk_reports_gallery` (`gallery_id`),
  ADD KEY `fk_reports_gal_reporter` (`reporter_id`),
  ADD KEY `fk_reports_gal_handler` (`handler_id`);

--
-- 資料表索引 `reported_recipes`
--
ALTER TABLE `reported_recipes`
  ADD PRIMARY KEY (`reported_recipe_id`),
  ADD KEY `fk_reports_recipe` (`recipe_id`),
  ADD KEY `fk_reports_rec_reporter` (`reporter_id`),
  ADD KEY `fk_reports_rec_handler` (`handler_id`);

--
-- 資料表索引 `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`,`review_comment`,`review_rating`);

--
-- 資料表索引 `steps`
--
ALTER TABLE `steps`
  ADD PRIMARY KEY (`step_id`),
  ADD KEY `fk_steps_recipe` (`recipe_id`);

--
-- 資料表索引 `step_ingredients`
--
ALTER TABLE `step_ingredients`
  ADD PRIMARY KEY (`step_ingredient_id`),
  ADD KEY `fk_si_step` (`step_id`),
  ADD KEY `fk_si_ingredient` (`ingredient_id`);

--
-- 資料表索引 `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `fk_tickets_user_id` (`user_id`);

--
-- 資料表索引 `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`tag_id`);

--
-- 資料表索引 `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `admins`
--
ALTER TABLE `admins`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `announcement`
--
ALTER TABLE `announcement`
  MODIFY `announcement_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `browsing_history`
--
ALTER TABLE `browsing_history`
  MODIFY `browsing_history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `carts`
--
ALTER TABLE `carts`
  MODIFY `carts_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `cooking_logs`
--
ALTER TABLE `cooking_logs`
  MODIFY `cooking_log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `faqs`
--
ALTER TABLE `faqs`
  MODIFY `faq_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `favorites`
--
ALTER TABLE `favorites`
  MODIFY `favorite_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `favorites_folders`
--
ALTER TABLE `favorites_folders`
  MODIFY `favorites_folder_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `follows`
--
ALTER TABLE `follows`
  MODIFY `follow_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `ingredients`
--
ALTER TABLE `ingredients`
  MODIFY `ingredient_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=527;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `log_ingredients`
--
ALTER TABLE `log_ingredients`
  MODIFY `log_ingredient_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=166;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `log_step_note`
--
ALTER TABLE `log_step_note`
  MODIFY `log_step_note_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plans`
--
ALTER TABLE `meal_plans`
  MODIFY `plan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plan_cover_template`
--
ALTER TABLE `meal_plan_cover_template`
  MODIFY `cover_template_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plan_daily_targets`
--
ALTER TABLE `meal_plan_daily_targets`
  MODIFY `daily_target_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plan_folders`
--
ALTER TABLE `meal_plan_folders`
  MODIFY `meal_plan_folder_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plan_items`
--
ALTER TABLE `meal_plan_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plan_templates`
--
ALTER TABLE `meal_plan_templates`
  MODIFY `template_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `meal_plan_template_items`
--
ALTER TABLE `meal_plan_template_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111020;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `order_products`
--
ALTER TABLE `order_products`
  MODIFY `order_product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `personal_folders`
--
ALTER TABLE `personal_folders`
  MODIFY `personal_folder_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `recipes`
--
ALTER TABLE `recipes`
  MODIFY `recipe_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `recipe_comments`
--
ALTER TABLE `recipe_comments`
  MODIFY `comment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `recipe_gallery`
--
ALTER TABLE `recipe_gallery`
  MODIFY `gallery_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `recipe_ingredients`
--
ALTER TABLE `recipe_ingredients`
  MODIFY `recipe_ingredient_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=677;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `recipe_tag`
--
ALTER TABLE `recipe_tag`
  MODIFY `recipe_tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=238;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `remove_bg_ingredients`
--
ALTER TABLE `remove_bg_ingredients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reported_comments`
--
ALTER TABLE `reported_comments`
  MODIFY `reported_comment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reported_galleries`
--
ALTER TABLE `reported_galleries`
  MODIFY `reported_gallery_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reported_recipes`
--
ALTER TABLE `reported_recipes`
  MODIFY `reported_recipe_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `steps`
--
ALTER TABLE `steps`
  MODIFY `step_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=465;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `step_ingredients`
--
ALTER TABLE `step_ingredients`
  MODIFY `step_ingredient_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=633;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `tags`
--
ALTER TABLE `tags`
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `browsing_history`
--
ALTER TABLE `browsing_history`
  ADD CONSTRAINT `fk_history_recipe_id` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_history_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `cooking_logs`
--
ALTER TABLE `cooking_logs`
  ADD CONSTRAINT `fk_logs_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `fk_favorites_folder` FOREIGN KEY (`folder_id`) REFERENCES `favorites_folders` (`favorites_folder_id`),
  ADD CONSTRAINT `fk_favorites_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_favorites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `favorites_folders`
--
ALTER TABLE `favorites_folders`
  ADD CONSTRAINT `fk_favorites_folders_creator` FOREIGN KEY (`creator_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `follows`
--
ALTER TABLE `follows`
  ADD CONSTRAINT `fk_followed` FOREIGN KEY (`followed_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- 資料表的限制式 `log_ingredients`
--
ALTER TABLE `log_ingredients`
  ADD CONSTRAINT `fk_log_ingredients_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`),
  ADD CONSTRAINT `fk_log_ingredients_log` FOREIGN KEY (`cooking_log_id`) REFERENCES `cooking_logs` (`cooking_log_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- 資料表的限制式 `log_step_note`
--
ALTER TABLE `log_step_note`
  ADD CONSTRAINT `fk_log_step_log` FOREIGN KEY (`cooking_log_id`) REFERENCES `cooking_logs` (`cooking_log_id`),
  ADD CONSTRAINT `fk_log_step_step` FOREIGN KEY (`step_id`) REFERENCES `steps` (`step_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- 資料表的限制式 `meal_plans`
--
ALTER TABLE `meal_plans`
  ADD CONSTRAINT `fk_plan_cover` FOREIGN KEY (`cover_template_id`) REFERENCES `meal_plan_cover_template` (`cover_template_id`),
  ADD CONSTRAINT `fk_plan_source` FOREIGN KEY (`source_template_id`) REFERENCES `meal_plan_templates` (`template_id`),
  ADD CONSTRAINT `fk_plan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `meal_plan_daily_targets`
--
ALTER TABLE `meal_plan_daily_targets`
  ADD CONSTRAINT `fk_target_plan` FOREIGN KEY (`plan_id`) REFERENCES `meal_plans` (`plan_id`) ON DELETE CASCADE;

--
-- 資料表的限制式 `meal_plan_folders`
--
ALTER TABLE `meal_plan_folders`
  ADD CONSTRAINT `fk_meal_plan_folders_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `meal_plan_items`
--
ALTER TABLE `meal_plan_items`
  ADD CONSTRAINT `fk_meal_plan_items_plan_id` FOREIGN KEY (`plan_id`) REFERENCES `meal_plans` (`plan_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_meal_plan_items_recipe_id` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE;

--
-- 資料表的限制式 `meal_plan_templates`
--
ALTER TABLE `meal_plan_templates`
  ADD CONSTRAINT `fk_templates_cover_id` FOREIGN KEY (`cover_template_id`) REFERENCES `meal_plan_cover_template` (`cover_template_id`);

--
-- 資料表的限制式 `meal_plan_template_items`
--
ALTER TABLE `meal_plan_template_items`
  ADD CONSTRAINT `fk_item_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`),
  ADD CONSTRAINT `fk_item_template` FOREIGN KEY (`template_id`) REFERENCES `meal_plan_templates` (`template_id`);

--
-- 資料表的限制式 `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_notifications_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- 資料表的限制式 `order_products`
--
ALTER TABLE `order_products`
  ADD CONSTRAINT `fk_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE;

--
-- 資料表的限制式 `personal_folders`
--
ALTER TABLE `personal_folders`
  ADD CONSTRAINT `fk_personal_folders_creator` FOREIGN KEY (`creator_id`) REFERENCES `users` (`user_id`);

--
-- 資料表的限制式 `recipes`
--
ALTER TABLE `recipes`
  ADD CONSTRAINT `fk_recipes_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_recipes_folder` FOREIGN KEY (`personal_folder_id`) REFERENCES `personal_folders` (`personal_folder_id`),
  ADD CONSTRAINT `fk_recipes_parent` FOREIGN KEY (`parent_recipe_id`) REFERENCES `recipes` (`recipe_id`);

--
-- 資料表的限制式 `recipe_comments`
--
ALTER TABLE `recipe_comments`
  ADD CONSTRAINT `fk_comments_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_comments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- 資料表的限制式 `recipe_gallery`
--
ALTER TABLE `recipe_gallery`
  ADD CONSTRAINT `fk_gallery_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_gallery_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- 資料表的限制式 `recipe_ingredients`
--
ALTER TABLE `recipe_ingredients`
  ADD CONSTRAINT `fk_recipe_ing_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_recipe_ing_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- 資料表的限制式 `recipe_tag`
--
ALTER TABLE `recipe_tag`
  ADD CONSTRAINT `fk_recipe_id` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tag_id` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`);

--
-- 資料表的限制式 `reported_comments`
--
ALTER TABLE `reported_comments`
  ADD CONSTRAINT `fk_reports_comment` FOREIGN KEY (`comment_id`) REFERENCES `recipe_comments` (`comment_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_handler` FOREIGN KEY (`handler_id`) REFERENCES `admins` (`admin_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- 資料表的限制式 `reported_galleries`
--
ALTER TABLE `reported_galleries`
  ADD CONSTRAINT `fk_reports_gal_handler` FOREIGN KEY (`handler_id`) REFERENCES `admins` (`admin_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_gal_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_gallery` FOREIGN KEY (`gallery_id`) REFERENCES `recipe_gallery` (`gallery_id`) ON UPDATE CASCADE;

--
-- 資料表的限制式 `reported_recipes`
--
ALTER TABLE `reported_recipes`
  ADD CONSTRAINT `fk_reports_rec_handler` FOREIGN KEY (`handler_id`) REFERENCES `admins` (`admin_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_rec_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- 資料表的限制式 `steps`
--
ALTER TABLE `steps`
  ADD CONSTRAINT `fk_steps_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- 資料表的限制式 `step_ingredients`
--
ALTER TABLE `step_ingredients`
  ADD CONSTRAINT `fk_si_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`),
  ADD CONSTRAINT `fk_si_step` FOREIGN KEY (`step_id`) REFERENCES `steps` (`step_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- 資料表的限制式 `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `fk_tickets_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
