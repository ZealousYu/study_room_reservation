/*
 Navicat Premium Dump SQL

 Source Server         : MySQL
 Source Server Type    : MySQL
 Source Server Version : 80045 (8.0.45)
 Source Host           : localhost:3306
 Source Schema         : study_room_reservation

 Target Server Type    : MySQL
 Target Server Version : 80045 (8.0.45)
 File Encoding         : 65001

 Date: 30/05/2026 22:02:19
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for foodorder
-- ----------------------------
DROP TABLE IF EXISTS `foodorder`;
CREATE TABLE `foodorder`  (
  `orderId` int NOT NULL AUTO_INCREMENT,
  `orderNo` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `userId` int NOT NULL,
  `revId` int NULL DEFAULT NULL,
  `totalAmount` int NOT NULL,
  `deliveryType` int NOT NULL COMMENT '1=配送至座位,2=吧台自取',
  `status` int NOT NULL DEFAULT 1 COMMENT '1=待支付,2=已支付,3=制作中,4=已完成,5=已取消',
  `createTime` datetime NOT NULL,
  `payTime` datetime NULL DEFAULT NULL,
  `cancelTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`orderId`) USING BTREE,
  UNIQUE INDEX `uk_orderNo`(`orderNo` ASC) USING BTREE,
  INDEX `idx_userId`(`userId` ASC) USING BTREE,
  INDEX `idx_status_created`(`status` ASC, `createTime` ASC) USING BTREE,
  INDEX `fk_foodorder_reservation`(`revId` ASC) USING BTREE,
  CONSTRAINT `fk_foodorder_reservation` FOREIGN KEY (`revId`) REFERENCES `reservation` (`revId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_foodorder_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of foodorder
-- ----------------------------
INSERT INTO `foodorder` VALUES (1, 'F202606041301010409', 10, 11, 12400, 1, 2, '2026-06-04 13:01:53', '2026-06-04 13:07:53', NULL);
INSERT INTO `foodorder` VALUES (2, 'F202606011212005084', 5, 12, 8000, 1, 2, '2026-06-01 12:12:54', '2026-06-01 12:26:54', NULL);
INSERT INTO `foodorder` VALUES (3, 'F202606011320003061', 3, 10, 5200, 1, 3, '2026-06-01 13:20:27', '2026-06-01 13:25:27', NULL);
INSERT INTO `foodorder` VALUES (4, 'F202606041249012474', 12, 9, 7900, 2, 3, '2026-06-04 12:49:05', '2026-06-04 13:03:05', NULL);
INSERT INTO `foodorder` VALUES (5, 'F202606032253010176', 10, 14, 800, 2, 1, '2026-06-03 22:53:34', NULL, NULL);
INSERT INTO `foodorder` VALUES (6, 'F202606041250012478', 12, 13, 11400, 1, 3, '2026-06-04 12:50:08', '2026-06-04 12:53:08', NULL);

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `nId` int NOT NULL AUTO_INCREMENT,
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `createTime` datetime NOT NULL,
  `state` int NOT NULL DEFAULT 1 COMMENT '1=发布,2=下架',
  `userId` int NOT NULL,
  PRIMARY KEY (`nId`) USING BTREE,
  INDEX `fk_notice_users`(`userId` ASC) USING BTREE,
  CONSTRAINT `fk_notice_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, '欢迎使用自习室预约系统', '亲爱的同学们，欢迎使用本自习室预约系统！系统支持座位预约、轻食点单、候补排队等功能。请遵守预约规则，按时打卡，共同维护良好的学习环境。如有疑问，请联系管理员。祝您学习愉快！', '2026-04-27 22:15:40', 1, 14);

-- ----------------------------
-- Table structure for orderdetail
-- ----------------------------
DROP TABLE IF EXISTS `orderdetail`;
CREATE TABLE `orderdetail`  (
  `ordId` int NOT NULL AUTO_INCREMENT,
  `orderId` int NOT NULL,
  `prodId` int NOT NULL,
  `quantity` int NOT NULL,
  `price` int NOT NULL,
  PRIMARY KEY (`ordId`) USING BTREE,
  INDEX `idx_orderId`(`orderId` ASC) USING BTREE,
  INDEX `fk_orderdetail_product`(`prodId` ASC) USING BTREE,
  CONSTRAINT `fk_orderdetail_order` FOREIGN KEY (`orderId`) REFERENCES `foodorder` (`orderId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orderdetail_product` FOREIGN KEY (`prodId`) REFERENCES `product` (`prodId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orderdetail
-- ----------------------------
INSERT INTO `orderdetail` VALUES (1, 1, 38, 3, 1800);
INSERT INTO `orderdetail` VALUES (2, 1, 73, 1, 1600);
INSERT INTO `orderdetail` VALUES (3, 1, 1, 3, 1300);
INSERT INTO `orderdetail` VALUES (4, 1, 48, 1, 1500);
INSERT INTO `orderdetail` VALUES (5, 2, 38, 2, 1800);
INSERT INTO `orderdetail` VALUES (6, 2, 20, 2, 800);
INSERT INTO `orderdetail` VALUES (7, 2, 47, 2, 1400);
INSERT INTO `orderdetail` VALUES (8, 3, 23, 2, 1300);
INSERT INTO `orderdetail` VALUES (9, 3, 58, 2, 1300);
INSERT INTO `orderdetail` VALUES (10, 4, 4, 1, 1300);
INSERT INTO `orderdetail` VALUES (11, 4, 50, 3, 1700);
INSERT INTO `orderdetail` VALUES (12, 4, 69, 3, 500);
INSERT INTO `orderdetail` VALUES (13, 5, 20, 1, 800);
INSERT INTO `orderdetail` VALUES (14, 6, 68, 2, 1000);
INSERT INTO `orderdetail` VALUES (15, 6, 53, 2, 1500);
INSERT INTO `orderdetail` VALUES (16, 6, 65, 2, 900);
INSERT INTO `orderdetail` VALUES (17, 6, 24, 2, 2300);

-- ----------------------------
-- Table structure for product
-- ----------------------------
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product`  (
  `prodId` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `category` int NOT NULL COMMENT '1=咖啡,2=茶饮,3=甜品,4=小吃',
  `price` int NOT NULL,
  `stock` int NOT NULL,
  `picture` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `state` int NOT NULL DEFAULT 1 COMMENT '1=上架,0=下架',
  PRIMARY KEY (`prodId`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product
-- ----------------------------
INSERT INTO `product` VALUES (1, '冰美式', 1, 1300, 47, '/images/product/冰美式.jpg', '经典冰美式，纯粹咖啡香，快速驱散困意，专注力满分。', 1);
INSERT INTO `product` VALUES (2, '气泡美式', 1, 1300, 39, '/images/product/气泡美式.jpg', '经典美式融合绵密气泡，清爽解腻，提神醒脑，夏季自习必备。', 1);
INSERT INTO `product` VALUES (3, '凤凰单枞美式', 1, 1300, 29, '/images/product/凤凰单枞美式.jpg', '凤凰单枞茶香与美式咖啡融合，甘醇回韵，别具一格。', 1);
INSERT INTO `product` VALUES (4, '龙井蜜瓜美式', 1, 1300, 30, '/images/product/龙井蜜瓜美式.jpg', '龙井茶香+蜜瓜清甜+美式咖啡，清新三重奏。', 1);
INSERT INTO `product` VALUES (5, '茉莉花茶美式', 1, 1300, 35, '/images/product/茉莉花茶美式.jpg', '茉莉花茶清香×浓缩咖啡，花香咖韵，淡雅悠长。', 1);
INSERT INTO `product` VALUES (6, '拿铁咖啡', 1, 1500, 60, '/images/product/拿铁咖啡.jpg', '经典拿铁，奶香与咖香平衡，自习室标配。', 1);
INSERT INTO `product` VALUES (7, '薄荷拿铁', 1, 1500, 59, '/images/product/薄荷拿铁.jpg', '清凉薄荷与醇厚拿铁交融，一口冰爽，困意一扫而空。', 1);
INSERT INTO `product` VALUES (8, '焦糖拿铁', 1, 1500, 59, '/images/product/焦糖拿铁.jpg', '焦糖香甜融入丝滑拿铁，温暖治愈，甜而不腻。', 1);
INSERT INTO `product` VALUES (9, '摩卡拿铁', 1, 1600, 60, '/images/product/摩卡拿铁.jpg', '巧克力与拿铁完美邂逅，甜蜜丝滑，能量补给站。', 1);
INSERT INTO `product` VALUES (10, '生椰拿铁', 1, 1500, 59, '/images/product/生椰拿铁.jpg', '生榨椰乳与浓缩咖啡完美融合，丝滑醇厚，椰香浓郁。', 1);
INSERT INTO `product` VALUES (11, '燕麦拿铁', 1, 1600, 60, '/images/product/燕麦拿铁.jpg', '燕麦奶与浓缩咖啡融合，植物清甜，乳糖不耐友好。', 1);
INSERT INTO `product` VALUES (12, '卡布奇诺', 1, 1600, 60, '/images/product/卡布奇诺.jpg', '绵密奶泡配浓缩咖啡，经典意式风味，优雅唤醒清晨。', 1);
INSERT INTO `product` VALUES (13, '栗子燕麦卡布奇诺', 1, 1800, 60, '/images/product/栗子燕麦卡布奇诺.jpg', '焦香咖啡遇上绵密栗泥，温润燕麦奶柔化苦感，一口暖到心底。', 1);
INSERT INTO `product` VALUES (14, '黑糖珍珠奶茶', 2, 1400, 45, '/images/product/黑糖珍珠奶茶.jpg', '现熬黑糖与醇厚奶茶融合，珍珠软糯，甜润顺滑，学习间隙的小确幸。', 1);
INSERT INTO `product` VALUES (16, '芒果椰椰', 2, 1400, 45, '/images/product/芒果椰椰.jpg', '香甜芒果遇上糯香椰乳，热带水果盛宴。', 1);
INSERT INTO `product` VALUES (17, '满杯橙鲜', 2, 1000, 45, '/images/product/满杯橙鲜.jpg', '鲜榨橙汁搭配清爽茶底，VC爆棚，活力满满。', 1);
INSERT INTO `product` VALUES (18, '西柚气泡水', 2, 1200, 44, '/images/product/西柚气泡水.jpg', '西柚酸甜+绵密气泡，酸甜激爽，低卡解暑。', 1);
INSERT INTO `product` VALUES (19, '泰绿柠檬茶', 2, 800, 45, '/images/product/泰绿柠檬茶.jpg', '泰式绿茶底加香水柠檬，酸甜爽口，仿佛置身泰国，地道泰式风味。', 1);
INSERT INTO `product` VALUES (20, '鸭屎香柠檬茶', 2, 800, 45, '/images/product/鸭屎香柠檬茶.jpg', '凤凰单枞鸭屎香茶底搭配柠檬，香气独特，回甘悠长。', 1);
INSERT INTO `product` VALUES (21, '波士玫瑰乌龙茶', 2, 1200, 45, '/images/product/波士玫瑰乌龙茶.jpg', '玫瑰花香与乌龙茶底融合，浪漫芬芳，舒缓学习压力。', 1);
INSERT INTO `product` VALUES (22, '话梅菠萝冰', 2, 1200, 45, '/images/product/话梅菠萝冰.jpg', '话梅咸甜搭配菠萝果肉，冰爽酸甜，夏日消暑神器。', 1);
INSERT INTO `product` VALUES (23, '青苹果奶绿', 2, 1300, 44, '/images/product/青苹果奶绿.jpg', '青苹果清新酸甜融入奶绿，口感清爽，沁人心脾。', 1);
INSERT INTO `product` VALUES (24, '燕窝蓝莓酸奶', 2, 2300, 45, '/images/product/燕窝蓝莓酸奶.jpg', '燕窝滋养+蓝莓果粒+浓稠酸奶，轻奢健康，自习能量饮。', 1);
INSERT INTO `product` VALUES (25, '杨枝甘露', 2, 1500, 45, '/images/product/杨枝甘露.jpg', '芒果西柚椰奶经典搭配，酸甜清香，港式甜品风味。', 1);
INSERT INTO `product` VALUES (26, '芝芝可可', 2, 1800, 45, '/images/product/芝芝可可.jpg', '芝士奶盖搭配浓郁可可，咸甜醇厚，为大脑充电。', 1);
INSERT INTO `product` VALUES (27, '可可牛乳', 2, 1800, 45, '/images/product/可可牛乳.jpg', '纯可可粉与鲜牛乳融合，丝滑浓郁，暖胃暖心。', 1);
INSERT INTO `product` VALUES (28, '经典抹茶奶茶', 2, 1600, 45, '/images/product/经典抹茶奶茶.jpg', '日式抹茶与香滑奶茶碰撞，微苦回甘，清新自然。', 1);
INSERT INTO `product` VALUES (29, '北海道海盐抹茶', 2, 1600, 45, '/images/product/北海道海盐抹茶.jpg', '浓醇抹茶遇上温润鲜奶，海盐轻提风味，一口沁凉解腻。', 1);
INSERT INTO `product` VALUES (30, '开心果抹茶', 2, 2200, 45, '/images/product/开心果抹茶.jpg', '浓醇抹茶搭配绵密开心果，温润奶底柔和茶苦，清新顺滑直抵心底。', 1);
INSERT INTO `product` VALUES (31, '茉莉抹茶', 2, 1600, 45, '/images/product/茉莉抹茶.jpg', '鲜灵茉莉衬出抹茶本味，冰感顺滑入喉，清爽解腻无负担。', 1);
INSERT INTO `product` VALUES (32, '抹茶西瓜啵啵', 2, 1600, 45, '/images/product/抹茶西瓜啵啵.jpg', '清爽西瓜汁打底，加入抹茶冻和脆啵啵，夏日果茶吸不停。', 1);
INSERT INTO `product` VALUES (33, '草莓抹茶鲜牛乳', 2, 1800, 45, '/images/product/草莓抹茶鲜牛乳.jpg', '饱满草莓果香打底，醇厚奶层过渡，清冽抹茶收尾，一口解锁双倍清新。', 1);
INSERT INTO `product` VALUES (34, '草莓奶昔', 2, 1400, 45, '/images/product/草莓奶昔.jpg', '鲜捣草莓果泥裹着醇厚鲜乳，果肉酸甜撞奶香，清爽软嫩甜而不腻。', 1);
INSERT INTO `product` VALUES (35, '蓝莓冰沙酸奶', 2, 800, 45, '/images/product/蓝莓冰沙酸奶.jpg', '整颗蓝莓与老酸奶打成冰沙，酸甜冰爽，清新解暑。', 1);
INSERT INTO `product` VALUES (36, '杨梅冰沙酸奶', 2, 800, 45, '/images/product/杨梅冰沙酸奶.jpg', '杨梅果肉搭配浓稠酸奶，冰沙质地，酸甜开胃，夏日消暑必备。', 1);
INSERT INTO `product` VALUES (37, '桑葚冰沙酸奶', 2, 800, 45, '/images/product/桑葚冰沙酸奶.jpg', '馥郁桑葚果香碰撞发酵酸奶，冰沙顺滑降温，酸甜平衡清爽不腻。', 1);
INSERT INTO `product` VALUES (38, '紫薯芋泥豆乳', 2, 1800, 45, '/images/product/紫薯芋泥豆乳.jpg', '粉糯芋泥混着绵柔紫薯底色，豆乳鲜醇干净，自带淡淡谷物回甘。', 1);
INSERT INTO `product` VALUES (39, '奶油南瓜豆乳', 2, 1800, 45, '/images/product/奶油南瓜豆乳.jpg', '细磨南瓜泥与温润豆乳相融，软滑细腻，暖感绵长舒服。', 1);
INSERT INTO `product` VALUES (40, '莓莓云朵可可芭菲', 3, 2400, 20, '/images/product/莓莓云朵可可芭菲.jpg', '粉嫩草莓裹着浓醇可可，搭配酥脆谷物与精巧马卡龙，视觉与味觉的双重浪漫暴击。', 1);
INSERT INTO `product` VALUES (41, '抹茶巧脆云朵芭菲', 3, 2400, 20, '/images/product/抹茶巧脆云朵芭菲.jpg', '抹茶糅合浓醇可可，脆谷增添层次，奶油轻顶绵柔，微苦中和甜腻，清爽治愈。', 1);
INSERT INTO `product` VALUES (42, '桃桃抹茶椰云芭菲', 3, 2400, 20, '/images/product/桃桃抹茶椰云芭菲.jpg', '清新抹茶底搭配软嫩水蜜桃果肉，点缀脆香饼干与绵密椰蓉，果香混着茶感，清甜爽口不腻。', 1);
INSERT INTO `product` VALUES (43, '特浓可可云朵芭菲', 3, 2400, 20, '/images/product/特浓可可云朵芭菲.jpg', '多层浓醇巧克力基底，夹满香脆坚果谷物，云顶奶油淋上可可酱，入口丝滑醇厚，浓甜不腻。', 1);
INSERT INTO `product` VALUES (44, '草莓抹茶瑞士卷', 3, 1600, 25, '/images/product/草莓抹茶瑞士卷.jpg', '戚风裹入草莓奶油，茶香清雅与酸甜果香交织，治愈系甜品。', 1);
INSERT INTO `product` VALUES (45, '原味巴斯克', 3, 1500, 18, '/images/product/原味巴斯克.jpg', '焦香外皮包裹绵密芝士芯，浓郁顺滑，芝士控的纯粹享受。', 1);
INSERT INTO `product` VALUES (46, '开心果芝士巴斯克', 3, 1700, 18, '/images/product/开心果芝士巴斯克.jpg', '开心果坚果香融入巴斯克，独特咸甜风味，一口沦陷。', 1);
INSERT INTO `product` VALUES (47, '青柠芝士蛋糕', 3, 1400, 18, '/images/product/青柠芝士蛋糕.jpg', '青柠清香化解芝士甜腻，轻盈爽口，自习间隙的小清新。', 1);
INSERT INTO `product` VALUES (48, '莓果芝士蛋糕', 3, 1500, 18, '/images/product/莓果芝士蛋糕.jpg', '混合莓果果酱搭配醇厚芝士，酸甜平衡，颜值与美味并存。', 1);
INSERT INTO `product` VALUES (49, '芒果芝士蛋糕', 3, 1500, 18, '/images/product/芒果芝士蛋糕.jpg', '热带芒果果泥与芝士融合，入口即化，夏日阳光滋味。', 1);
INSERT INTO `product` VALUES (50, '雪域牛乳芝士蛋糕', 3, 1700, 18, '/images/product/雪域牛乳芝士蛋糕.jpg', '北海道牛乳冰凉质感，奶香浓郁，如雪域般纯净。', 1);
INSERT INTO `product` VALUES (51, '蓝莓芝士蛋糕', 3, 1600, 18, '/images/product/蓝莓芝士蛋糕.jpg', '大粒蓝莓果粒与芝士层层叠叠，经典搭配，永不踩雷。', 1);
INSERT INTO `product` VALUES (52, '纽约芝士蛋糕', 3, 1500, 18, '/images/product/纽约芝士蛋糕.jpg', '浓郁酸奶油芝士，扎实绵密，纽约街角情怀。', 1);
INSERT INTO `product` VALUES (53, '美式芝士蛋糕', 3, 1500, 18, '/images/product/美式芝士蛋糕.jpg', '简朴醇厚，蛋香芝香完美平衡，美式经典风味。', 1);
INSERT INTO `product` VALUES (54, '半熟芝士', 3, 1600, 18, '/images/product/半熟芝士.jpg', '轻盈半熟质感，入口即化，如云朵般轻柔，低卡无负担。', 1);
INSERT INTO `product` VALUES (55, '原味提拉米苏', 3, 1800, 18, '/images/product/原味提拉米苏.jpg', '咖啡酒香与马斯卡彭缠绵，手指饼干湿润柔滑，意式浪漫。', 1);
INSERT INTO `product` VALUES (56, '蓝莓提拉米苏', 3, 1900, 18, '/images/product/蓝莓提拉米苏.jpg', '蓝莓果酱替换咖啡，果香版提拉米苏，甜而不腻。', 1);
INSERT INTO `product` VALUES (57, '乳酪包', 3, 2200, 18, '/images/product/乳酪包.jpg', '松软面包夹入浓郁乳酪馅，早餐或下午茶，能量满满。', 1);
INSERT INTO `product` VALUES (58, '西瓜芋圆西米露', 3, 1300, 18, '/images/product/西瓜芋圆西米露.jpg', '椰奶为底，加入大块清甜西瓜，搭配Q弹芋圆与爽滑西米，椰香果香交织，消暑又满足。', 1);
INSERT INTO `product` VALUES (60, '芒果桂花奶羹', 3, 1300, 18, '/images/product/芒果桂花奶羹.jpg', '芒果泥+桂花蜜+奶羹，花香果香奶香三重奏，冰爽丝滑。', 1);
INSERT INTO `product` VALUES (61, '芋泥椰奶大满贯', 3, 1800, 18, '/images/product/芋泥椰奶大满贯.jpg', '手捣芋泥挂壁，注入香浓椰奶，加入芋圆、红豆、西米、芒果、西瓜、葡萄干、南瓜子仁、薏米、花生，十种配料大满贯，一碗吃出幸福感。', 1);
INSERT INTO `product` VALUES (65, '红豆桂花小圆子', 3, 900, 50, '/images/product/红豆桂花小圆子.jpg', '绵密起沙的红豆汤底，裹住Q弹透亮白玉圆子，金桂点缀增香，清甜温润，一口暖到心底。', 1);
INSERT INTO `product` VALUES (66, '绿豆沙牛乳', 3, 800, 50, '/images/product/绿豆沙牛乳.jpg', '熬至开花的绵密绿豆，融入丝滑冷牛乳，清冽回甘，入口消解整日燥热。', 1);
INSERT INTO `product` VALUES (67, '芝士薯条', 4, 1000, 50, '/images/product/芝士薯条.jpg', '金黄粗薯条外脆内糯，覆上烘烤咸香芝士，焦香浓郁，回味悠长。', 1);
INSERT INTO `product` VALUES (68, '海苔薯条', 4, 1000, 50, '/images/product/海苔薯条.jpg', '现炸酥脆薯条，裹满鲜醇海苔风味粉，鲜咸提味，越嚼越有层次。', 1);
INSERT INTO `product` VALUES (69, '香葱肉松面包', 4, 500, 50, '/images/product/香葱肉松面包.jpg', '烘烤麦香卷体，裹满蓬松咸酥肉松，搭配葱香火腿芝麻，咸香适口，口感丰富。', 1);
INSERT INTO `product` VALUES (70, '鲜虾芝蛋三明治', 4, 900, 50, '/images/product/鲜虾芝蛋三明治.jpg', '香煎吐司叠上嫩滑蛋饼、醇厚芝士、Q弹鲜虾滑，搭配脆嫩生菜与酸甜茄酱，鲜爽开胃，元气拉满。', 1);
INSERT INTO `product` VALUES (71, '热狗培根芝士面包', 4, 800, 50, '/images/product/热狗培根芝士面包.jpg', '暄软麦香面包，夹上弹嫩肉肠和焦脆熏香培根，淋上融化的浓郁芝士，脂香与肉香层层迸发，口感醇厚扎实，咸香超上头！', 1);
INSERT INTO `product` VALUES (72, '蓝莓乳酪包', 4, 1800, 50, '/images/product/蓝莓乳酪包.jpg', '烘烤得外沿微焦的松软欧包，铺满绵密丝滑流心乳酪，搭配颗颗新鲜蓝莓，奶香清润不齁甜。', 1);
INSERT INTO `product` VALUES (73, '炙牛柳培根芝士面包', 4, 1600, 50, '/images/product/炙牛柳培根芝士面包.jpg', '烘烤出麦香韧劲的面包，铺上嫩弹炙烤牛柳、焦香培根，烟熏肉香混着厚焗芝士醇厚奶香，酸黄瓜脆爽提味，脆嫩咸香层层碰撞，一口鲜香不腻。', 1);
INSERT INTO `product` VALUES (74, '罗勒鲜蔬鸡腿芝士包', 4, 1200, 50, '/images/product/罗勒鲜蔬鸡腿芝士包.jpg', '嫩弹鸡腿肉搭配鲜甜双彩蔬，芝士焗烤醇厚拉丝，罗勒香草点睛增香，完全不腻口，一口吃到满满田园鲜香。', 1);
INSERT INTO `product` VALUES (75, '菠萝包', 4, 600, 80, '/images/product/菠萝包.jpg', '经典原味菠萝包，外皮酥掉渣、内里软绵，黄油香气直击舌尖，甜而不腻的永恒经典。', 1);
INSERT INTO `product` VALUES (76, '太阳蛋芝士可颂', 4, 700, 60, '/images/product/太阳蛋芝士可颂.jpg', '层层起酥的可颂烤至外皮焦脆掉渣，中间嵌入溏心太阳蛋，裹挟焦香芝士，咸香酥脆，每一口都是酥脆与软嫩的绝妙碰撞。', 1);
INSERT INTO `product` VALUES (77, '火腿滑蛋可颂', 4, 700, 60, '/images/product/火腿滑蛋可颂.jpg', '现烤可颂夹入蓬松软嫩的滑蛋，咸香火腿中和油脂香气，番茄与生菜锁住清甜脆感，一口酥、嫩、鲜三重口感层层迸发，好吃无负担。', 1);
INSERT INTO `product` VALUES (78, '芝士火腿全麦三明治', 4, 800, 60, '/images/product/芝士火腿全麦三明治.jpg', '麦香醇厚的全麦吐司，夹着大片原切芝士、薄切火腿，肉蔬搭配均衡，食材本味干净纯粹，轻食饱腹无负担。', 1);
INSERT INTO `product` VALUES (79, '开心果核桃马里奥', 4, 1200, 60, '/images/product/开心果核桃马里奥.jpg', '外壳坚果焦脆，开心果酱绵密柔润，奥利奥碎丰富咀嚼层次，风味醇厚又富有记忆点。', 1);
INSERT INTO `product` VALUES (80, '金枪鱼溏心蛋活力碗', 4, 1800, 60, '/images/product/金枪鱼溏心蛋活力碗.jpg', '鲜脆混合时蔬打底，搭配鲜香金枪鱼、软嫩溏心蛋，点缀圣女果与黑橄榄，裹上柔润美乃滋，口感清爽饱满。', 1);
INSERT INTO `product` VALUES (81, '蔬菜拼盘烤鸡', 4, 1800, 60, '/images/product/蔬菜拼盘烤鸡.jpg', '外皮焦香锁汁的烤鸡腿，搭配蜜糯南瓜、鲜烤彩蔬，迷迭香提味增香，肉香裹挟蔬果清甜，风味醇厚不腻。', 1);

-- ----------------------------
-- Table structure for reservation
-- ----------------------------
DROP TABLE IF EXISTS `reservation`;
CREATE TABLE `reservation`  (
  `revId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `resId` int NOT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  `status` int NOT NULL DEFAULT 1 COMMENT '1=预约成功,2=已取消,3=已违约,4=已完成',
  `createTime` datetime NOT NULL,
  `cancelTime` datetime NULL DEFAULT NULL,
  `checkinTime` datetime NULL DEFAULT NULL,
  `amount` int NOT NULL,
  PRIMARY KEY (`revId`) USING BTREE,
  INDEX `idx_userId`(`userId` ASC) USING BTREE,
  INDEX `idx_resId_start_end`(`resId` ASC, `startTime` ASC, `endTime` ASC) USING BTREE,
  INDEX `idx_status_start`(`status` ASC, `startTime` ASC) USING BTREE,
  CONSTRAINT `fk_reservation_resource` FOREIGN KEY (`resId`) REFERENCES `resource` (`resId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reservation_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 61 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of reservation
-- ----------------------------
INSERT INTO `reservation` VALUES (1, 1, 7, '2026-06-03 20:00:00', '2026-06-03 23:00:00', 0, '2026-06-01 22:08:49', NULL, NULL, 15);
INSERT INTO `reservation` VALUES (2, 10, 4, '2026-06-01 15:00:00', '2026-06-01 23:00:00', 0, '2026-05-28 21:48:18', NULL, NULL, 40);
INSERT INTO `reservation` VALUES (3, 3, 34, '2026-06-05 19:00:00', '2026-06-05 23:00:00', 3, '2026-05-30 23:48:03', '2026-05-30 11:15:56', NULL, 80);
INSERT INTO `reservation` VALUES (4, 12, 6, '2026-05-31 12:00:00', '2026-05-31 21:00:00', 0, '2026-05-28 08:37:02', NULL, NULL, 45);
INSERT INTO `reservation` VALUES (5, 5, 23, '2026-06-05 18:00:00', '2026-06-05 23:00:00', 0, '2026-06-01 20:37:34', NULL, NULL, 25);
INSERT INTO `reservation` VALUES (6, 1, 16, '2026-06-05 11:00:00', '2026-06-05 23:00:00', 0, '2026-06-02 03:37:42', NULL, NULL, 60);
INSERT INTO `reservation` VALUES (7, 10, 17, '2026-05-30 22:00:00', '2026-05-30 23:00:00', 1, '2026-05-23 22:59:04', NULL, NULL, 5);
INSERT INTO `reservation` VALUES (8, 6, 34, '2026-05-31 11:00:00', '2026-05-31 23:00:00', 1, '2026-05-26 12:43:00', NULL, NULL, 240);
INSERT INTO `reservation` VALUES (9, 12, 11, '2026-06-04 12:00:00', '2026-06-04 20:00:00', 1, '2026-05-28 06:35:11', NULL, NULL, 40);
INSERT INTO `reservation` VALUES (10, 3, 15, '2026-06-01 17:00:00', '2026-06-01 23:00:00', 3, '2026-05-26 15:58:55', '2026-05-30 11:18:24', NULL, 30);
INSERT INTO `reservation` VALUES (11, 10, 31, '2026-06-04 20:00:00', '2026-06-04 23:00:00', 1, '2026-05-31 19:45:20', NULL, NULL, 15);
INSERT INTO `reservation` VALUES (12, 5, 35, '2026-06-01 08:00:00', '2026-06-01 19:00:00', 1, '2026-05-27 05:17:45', NULL, NULL, 220);
INSERT INTO `reservation` VALUES (13, 12, 12, '2026-06-04 07:00:00', '2026-06-04 09:00:00', 1, '2026-06-02 18:08:25', NULL, NULL, 10);
INSERT INTO `reservation` VALUES (14, 10, 15, '2026-06-03 12:00:00', '2026-06-03 23:00:00', 1, '2026-05-31 00:53:20', NULL, NULL, 55);
INSERT INTO `reservation` VALUES (15, 1, 9, '2026-05-30 12:00:00', '2026-05-30 23:00:00', 3, '2026-05-23 08:50:10', NULL, NULL, 55);
INSERT INTO `reservation` VALUES (16, 5, 9, '2026-05-27 17:00:00', '2026-05-27 22:00:00', 2, '2026-05-27 22:13:22', NULL, '2026-05-27 17:05:00', 25);
INSERT INTO `reservation` VALUES (17, 10, 8, '2026-05-08 22:00:00', '2026-05-08 23:00:00', 2, '2026-05-08 17:30:23', NULL, '2026-05-08 22:13:00', 5);
INSERT INTO `reservation` VALUES (18, 2, 12, '2026-05-28 12:00:00', '2026-05-28 23:00:00', 2, '2026-05-25 14:22:03', NULL, '2026-05-28 12:03:00', 55);
INSERT INTO `reservation` VALUES (19, 6, 29, '2026-05-15 08:00:00', '2026-05-15 14:00:00', 2, '2026-05-14 03:00:39', NULL, '2026-05-15 08:06:00', 30);
INSERT INTO `reservation` VALUES (20, 2, 36, '2026-05-18 06:00:00', '2026-05-18 08:00:00', 2, '2026-05-17 22:59:10', NULL, '2026-05-18 06:26:00', 40);
INSERT INTO `reservation` VALUES (21, 11, 21, '2026-05-24 11:00:00', '2026-05-24 13:00:00', 2, '2026-05-22 21:12:21', NULL, '2026-05-24 11:05:00', 10);
INSERT INTO `reservation` VALUES (22, 11, 17, '2026-05-06 15:00:00', '2026-05-06 23:00:00', 3, '2026-05-01 05:12:24', '2026-05-05 17:46:41', NULL, 40);
INSERT INTO `reservation` VALUES (23, 2, 19, '2026-05-26 07:00:00', '2026-05-26 09:00:00', 3, '2026-05-25 14:34:01', '2026-05-25 17:50:04', NULL, 10);
INSERT INTO `reservation` VALUES (24, 11, 36, '2026-05-25 22:00:00', '2026-05-25 23:00:00', 3, '2026-05-24 03:49:40', '2026-05-24 17:40:32', NULL, 20);
INSERT INTO `reservation` VALUES (25, 9, 31, '2026-05-02 09:00:00', '2026-05-02 16:00:00', 3, '2026-05-02 10:57:26', '2026-05-01 17:11:02', NULL, 35);
INSERT INTO `reservation` VALUES (26, 9, 38, '2026-05-27 13:00:00', '2026-05-27 23:00:00', 3, '2026-05-26 14:09:00', '2026-05-26 17:54:48', NULL, 200);
INSERT INTO `reservation` VALUES (27, 4, 2, '2026-05-18 17:00:00', '2026-05-18 23:00:00', 3, '2026-05-15 06:24:13', '2026-05-17 17:40:46', NULL, 30);
INSERT INTO `reservation` VALUES (28, 12, 2, '2026-05-14 15:00:00', '2026-05-14 17:00:00', 3, '2026-05-09 11:30:05', '2026-05-13 17:16:40', NULL, 10);
INSERT INTO `reservation` VALUES (29, 7, 20, '2026-05-27 20:00:00', '2026-05-27 21:00:00', 3, '2026-05-24 04:51:48', '2026-05-26 17:51:55', NULL, 5);
INSERT INTO `reservation` VALUES (30, 1, 19, '2026-05-21 06:00:00', '2026-05-21 10:00:00', 3, '2026-05-16 02:44:22', '2026-05-20 17:12:01', NULL, 20);
INSERT INTO `reservation` VALUES (31, 7, 22, '2026-05-24 11:00:00', '2026-05-24 23:00:00', 4, '2026-05-20 00:47:55', NULL, NULL, 60);
INSERT INTO `reservation` VALUES (32, 3, 15, '2026-05-24 20:00:00', '2026-05-24 23:00:00', 4, '2026-05-24 20:20:03', NULL, NULL, 15);
INSERT INTO `reservation` VALUES (33, 5, 15, '2026-05-02 14:00:00', '2026-05-02 23:00:00', 4, '2026-04-30 21:09:04', NULL, NULL, 45);
INSERT INTO `reservation` VALUES (34, 12, 11, '2026-05-10 14:00:00', '2026-05-10 23:00:00', 4, '2026-05-10 16:14:13', NULL, NULL, 45);
INSERT INTO `reservation` VALUES (35, 5, 7, '2026-05-07 09:00:00', '2026-05-07 23:00:00', 4, '2026-05-03 21:25:22', NULL, NULL, 70);
INSERT INTO `reservation` VALUES (36, 8, 36, '2026-05-05 10:00:00', '2026-05-05 23:00:00', 4, '2026-05-03 07:33:48', NULL, NULL, 260);
INSERT INTO `reservation` VALUES (37, 5, 18, '2026-05-24 16:00:00', '2026-05-24 23:00:00', 5, '2026-05-24 04:47:23', NULL, '2026-05-24 16:17:00', 35);
INSERT INTO `reservation` VALUES (38, 10, 32, '2026-04-30 13:00:00', '2026-04-30 18:00:00', 5, '2026-04-30 20:29:56', NULL, '2026-04-30 13:06:00', 100);
INSERT INTO `reservation` VALUES (39, 3, 16, '2026-05-18 18:00:00', '2026-05-18 23:00:00', 5, '2026-05-14 03:18:05', NULL, '2026-05-18 18:16:00', 25);
INSERT INTO `reservation` VALUES (40, 7, 33, '2026-05-08 06:00:00', '2026-05-08 23:00:00', 5, '2026-05-04 03:12:41', NULL, '2026-05-08 06:24:00', 340);
INSERT INTO `reservation` VALUES (41, 13, 19, '2026-05-14 06:00:00', '2026-05-14 19:00:00', 5, '2026-05-11 16:42:29', NULL, '2026-05-14 06:08:00', 65);
INSERT INTO `reservation` VALUES (42, 13, 4, '2026-05-16 06:00:00', '2026-05-16 19:00:00', 5, '2026-05-13 01:23:42', NULL, '2026-05-16 06:11:00', 65);
INSERT INTO `reservation` VALUES (43, 11, 35, '2026-05-25 21:00:00', '2026-05-25 23:00:00', 5, '2026-05-23 14:33:02', NULL, '2026-05-25 21:14:00', 40);
INSERT INTO `reservation` VALUES (44, 5, 7, '2026-05-05 16:00:00', '2026-05-05 23:00:00', 5, '2026-05-02 00:08:41', NULL, '2026-05-05 16:01:00', 35);
INSERT INTO `reservation` VALUES (45, 3, 35, '2026-05-01 21:00:00', '2026-05-01 23:00:00', 5, '2026-04-30 15:32:47', NULL, '2026-05-01 21:10:00', 40);
INSERT INTO `reservation` VALUES (46, 6, 5, '2026-05-23 19:00:00', '2026-05-23 23:00:00', 5, '2026-05-21 06:49:19', NULL, '2026-05-23 19:05:00', 20);
INSERT INTO `reservation` VALUES (47, 13, 14, '2026-05-06 20:00:00', '2026-05-06 23:00:00', 5, '2026-05-06 23:23:59', NULL, '2026-05-06 20:24:00', 15);
INSERT INTO `reservation` VALUES (48, 2, 4, '2026-05-25 13:00:00', '2026-05-25 23:00:00', 5, '2026-05-25 14:49:21', NULL, '2026-05-25 13:08:00', 50);
INSERT INTO `reservation` VALUES (49, 6, 3, '2026-05-23 20:00:00', '2026-05-23 23:00:00', 5, '2026-05-19 16:14:08', NULL, '2026-05-23 20:00:00', 15);
INSERT INTO `reservation` VALUES (50, 9, 2, '2026-05-19 16:00:00', '2026-05-19 18:00:00', 5, '2026-05-16 19:06:08', NULL, '2026-05-19 16:11:00', 10);
INSERT INTO `reservation` VALUES (51, 7, 16, '2026-05-15 09:00:00', '2026-05-15 19:00:00', 5, '2026-05-14 04:28:45', NULL, '2026-05-15 09:12:00', 50);
INSERT INTO `reservation` VALUES (52, 10, 15, '2026-05-06 18:00:00', '2026-05-06 23:00:00', 5, '2026-05-01 04:09:17', NULL, '2026-05-06 18:29:00', 25);
INSERT INTO `reservation` VALUES (53, 1, 4, '2026-05-18 18:00:00', '2026-05-18 23:00:00', 5, '2026-05-17 02:30:13', NULL, '2026-05-18 18:19:00', 25);
INSERT INTO `reservation` VALUES (54, 7, 25, '2026-05-10 12:00:00', '2026-05-10 23:00:00', 5, '2026-05-10 17:28:12', NULL, '2026-05-10 12:19:00', 55);
INSERT INTO `reservation` VALUES (55, 8, 2, '2026-05-18 19:00:00', '2026-05-18 23:00:00', 5, '2026-05-13 22:56:54', NULL, '2026-05-18 19:20:00', 20);
INSERT INTO `reservation` VALUES (56, 10, 29, '2026-05-16 22:00:00', '2026-05-16 23:00:00', 5, '2026-05-13 17:36:52', NULL, '2026-05-16 22:17:00', 5);
INSERT INTO `reservation` VALUES (57, 4, 23, '2026-05-24 08:00:00', '2026-05-24 12:00:00', 5, '2026-05-21 11:28:55', NULL, '2026-05-24 08:07:00', 20);
INSERT INTO `reservation` VALUES (58, 6, 15, '2026-05-09 09:00:00', '2026-05-09 23:00:00', 5, '2026-05-09 08:43:31', NULL, '2026-05-09 09:13:00', 70);
INSERT INTO `reservation` VALUES (59, 10, 10, '2026-05-29 13:00:00', '2026-05-29 14:00:00', 5, '2026-05-25 22:20:51', NULL, '2026-05-29 13:07:00', 5);
INSERT INTO `reservation` VALUES (60, 10, 37, '2026-05-12 22:00:00', '2026-05-12 23:00:00', 5, '2026-05-11 09:16:14', NULL, '2026-05-12 22:10:00', 20);

-- ----------------------------
-- Table structure for resource
-- ----------------------------
DROP TABLE IF EXISTS `resource`;
CREATE TABLE `resource`  (
  `resId` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` int NOT NULL COMMENT '1=会议室,2=自习工位',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hasSocket` tinyint(1) NULL DEFAULT 0,
  `hasLamp` tinyint(1) NULL DEFAULT 0,
  `hasBaffle` tinyint(1) NULL DEFAULT 0,
  `byWindow` tinyint(1) NULL DEFAULT 0,
  `capacity` int NULL DEFAULT NULL,
  `state` int NOT NULL DEFAULT 1 COMMENT '1=可预约,2=维护中,0=禁用',
  PRIMARY KEY (`resId`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of resource
-- ----------------------------
INSERT INTO `resource` VALUES (1, 'A01', 1, '靠窗区', 1, 1, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (2, 'A02', 1, '靠窗区', 1, 1, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (3, 'A03', 1, '靠窗区', 0, 1, 0, 1, NULL, 2);
INSERT INTO `resource` VALUES (4, 'A04', 1, '靠窗区', 1, 0, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (5, 'A05', 1, '靠窗区', 1, 1, 1, 1, NULL, 1);
INSERT INTO `resource` VALUES (6, 'A06', 1, '靠窗区', 0, 0, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (7, 'A07', 1, '靠窗区', 1, 1, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (8, 'A08', 1, '靠窗区', 1, 1, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (9, 'A09', 1, '靠窗区', 0, 1, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (10, 'A10', 1, '靠窗区', 1, 0, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (11, 'A11', 1, '靠窗区', 1, 1, 0, 1, NULL, 1);
INSERT INTO `resource` VALUES (12, 'A12', 1, '靠窗区', 1, 1, 1, 1, NULL, 1);
INSERT INTO `resource` VALUES (13, 'B01', 1, '静音区', 1, 1, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (14, 'B02', 1, '静音区', 1, 0, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (15, 'B03', 1, '静音区', 0, 1, 1, 0, NULL, 2);
INSERT INTO `resource` VALUES (16, 'B04', 1, '静音区', 1, 1, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (17, 'B05', 1, '静音区', 1, 1, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (18, 'B06', 1, '静音区', 0, 0, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (19, 'B07', 1, '静音区', 1, 1, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (20, 'B08', 1, '静音区', 1, 1, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (21, 'B09', 1, '静音区', 0, 1, 1, 0, NULL, 1);
INSERT INTO `resource` VALUES (22, 'C01', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (23, 'C02', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (24, 'C03', 1, '吧台区', 0, 0, 0, 0, NULL, 2);
INSERT INTO `resource` VALUES (25, 'C04', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (26, 'C05', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (27, 'C06', 1, '吧台区', 0, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (28, 'C07', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (29, 'C08', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (30, 'C09', 1, '吧台区', 1, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (31, 'C10', 1, '吧台区', 0, 0, 0, 0, NULL, 1);
INSERT INTO `resource` VALUES (32, 'M01', 2, '主楼会议室', 1, 1, 0, 1, 6, 1);
INSERT INTO `resource` VALUES (33, 'M02', 2, '主楼会议室', 1, 1, 0, 0, 8, 1);
INSERT INTO `resource` VALUES (34, 'M03', 2, '东区研讨室', 1, 1, 1, 1, 4, 2);
INSERT INTO `resource` VALUES (35, 'M04', 2, '东区研讨室', 1, 0, 1, 0, 4, 1);
INSERT INTO `resource` VALUES (36, 'M05', 2, '西区会议室', 1, 1, 0, 1, 10, 1);
INSERT INTO `resource` VALUES (37, 'M06', 2, '西区会议室', 1, 1, 0, 0, 12, 1);
INSERT INTO `resource` VALUES (38, 'M07', 2, '北区研讨室', 1, 1, 1, 1, 6, 1);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `userId` int NOT NULL AUTO_INCREMENT,
  `account` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `realName` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `userType` int NOT NULL COMMENT '1=普通用户,2=管理员',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `state` int NOT NULL DEFAULT 1 COMMENT '1=正常,0=禁用',
  PRIMARY KEY (`userId`) USING BTREE,
  UNIQUE INDEX `uk_account`(`account` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'zjw111', '111111', '张吉惟', 1, '18843917510', 1);
INSERT INTO `users` VALUES (2, 'lgr222', '222222', '林国瑞', 1, '18155842438', 1);
INSERT INTO `users` VALUES (3, 'lyn333', '333333', '林雅南', 1, '13059227174', 1);
INSERT INTO `users` VALUES (4, 'lyy444', '444444', '江奕云', 1, '13250200789', 1);
INSERT INTO `users` VALUES (5, 'lbh555', '555555', '刘柏宏', 1, '15607535708', 1);
INSERT INTO `users` VALUES (6, 'lzf666', '666666', '林子帆', 1, '18789891667', 1);
INSERT INTO `users` VALUES (7, 'xzh777', '777777', '夏志豪', 1, '15707468066', 1);
INSERT INTO `users` VALUES (8, 'xyw888', '888888', '谢彦文', 1, '19808914548', 1);
INSERT INTO `users` VALUES (9, 'wbz999', '999999', '王宝珠', 1, '19808992549', 1);
INSERT INTO `users` VALUES (10, 'czy101', '101010', '陈祯月', 1, '15879493514', 1);
INSERT INTO `users` VALUES (11, 'cmy111', '110110', '曹敏侑', 1, '18613826664', 1);
INSERT INTO `users` VALUES (12, 'fzy121', '121212', '方兆玉', 1, '13357535368', 1);
INSERT INTO `users` VALUES (13, 'kqx131', '131313', '柯乔喜', 1, '15534416749', 1);
INSERT INTO `users` VALUES (14, 'gft141', '141414', '郭芳天', 2, '15289804753', 1);
INSERT INTO `users` VALUES (15, 'wyr151', '151515', '王亦柔', 2, '16668604671', 1);
INSERT INTO `users` VALUES (16, 'lws161', '161616', '林玟书', 2, '15321621910', 1);
INSERT INTO `users` VALUES (17, 'rja171', '171717', '阮建安', 2, '15389750656', 1);

-- ----------------------------
-- Table structure for violation
-- ----------------------------
DROP TABLE IF EXISTS `violation`;
CREATE TABLE `violation`  (
  `vioId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `revId` int NOT NULL,
  `violateTime` datetime NOT NULL,
  `reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `handleStatus` int NOT NULL DEFAULT 1 COMMENT '1=未处理,2=已处理',
  PRIMARY KEY (`vioId`) USING BTREE,
  UNIQUE INDEX `uk_revId`(`revId` ASC) USING BTREE,
  INDEX `idx_users_handle`(`userId` ASC, `handleStatus` ASC) USING BTREE,
  CONSTRAINT `fk_violation_reservation` FOREIGN KEY (`revId`) REFERENCES `reservation` (`revId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_violation_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 277 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of violation
-- ----------------------------
INSERT INTO `violation` VALUES (270, 7, 31, '2026-05-24 11:30:00', '预约开始后30分钟内未打卡', 1);
INSERT INTO `violation` VALUES (271, 3, 32, '2026-05-24 20:30:00', '预约开始后30分钟内未打卡', 1);
INSERT INTO `violation` VALUES (272, 5, 33, '2026-05-02 14:30:00', '预约开始后30分钟内未打卡', 1);
INSERT INTO `violation` VALUES (273, 12, 34, '2026-05-10 14:30:00', '预约开始后30分钟内未打卡', 1);
INSERT INTO `violation` VALUES (274, 5, 35, '2026-05-07 09:30:00', '预约开始后30分钟内未打卡', 1);
INSERT INTO `violation` VALUES (275, 8, 36, '2026-05-05 10:30:00', '预约开始后30分钟内未打卡', 1);
INSERT INTO `violation` VALUES (276, 1, 15, '2026-05-30 19:00:29', '预约开始后半小时内未打卡', 1);

-- ----------------------------
-- Table structure for waitlist
-- ----------------------------
DROP TABLE IF EXISTS `waitlist`;
CREATE TABLE `waitlist`  (
  `waitId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `resId` int NOT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  `createTime` datetime NOT NULL,
  `cancelTime` datetime NULL DEFAULT NULL,
  `status` int NOT NULL DEFAULT 1 COMMENT '1=等待中,2=已转正,3=已取消,4=未成功',
  `revId` int NULL DEFAULT NULL,
  PRIMARY KEY (`waitId`) USING BTREE,
  INDEX `idx_userId`(`userId` ASC) USING BTREE,
  INDEX `idx_res_start_status`(`resId` ASC, `startTime` ASC, `status` ASC) USING BTREE,
  INDEX `fk_waitlist_reservation`(`revId` ASC) USING BTREE,
  CONSTRAINT `fk_waitlist_reservation` FOREIGN KEY (`revId`) REFERENCES `reservation` (`revId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_waitlist_resource` FOREIGN KEY (`resId`) REFERENCES `resource` (`resId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_waitlist_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of waitlist
-- ----------------------------
INSERT INTO `waitlist` VALUES (1, 2, 13, '2026-06-02 09:00:00', '2026-06-02 21:00:00', '2026-05-06 22:22:01', NULL, 1, NULL);
INSERT INTO `waitlist` VALUES (2, 1, 35, '2026-06-03 16:00:00', '2026-06-03 18:00:00', '2026-05-16 06:45:04', NULL, 1, NULL);
INSERT INTO `waitlist` VALUES (3, 1, 1, '2026-06-05 20:00:00', '2026-06-05 23:00:00', '2026-05-02 20:22:18', NULL, 1, NULL);
INSERT INTO `waitlist` VALUES (4, 6, 11, '2026-05-30 18:00:00', '2026-05-30 23:00:00', '2026-05-12 00:12:59', NULL, 1, NULL);
INSERT INTO `waitlist` VALUES (5, 5, 27, '2026-06-02 17:00:00', '2026-06-02 23:00:00', '2026-05-21 13:56:56', NULL, 1, NULL);
INSERT INTO `waitlist` VALUES (6, 13, 31, '2026-05-31 22:00:00', '2026-05-31 23:00:00', '2026-05-28 10:53:10', '2026-05-30 17:32:03', 3, NULL);
INSERT INTO `waitlist` VALUES (7, 9, 1, '2026-05-31 06:00:00', '2026-05-31 13:00:00', '2026-05-30 19:58:30', '2026-05-30 17:22:10', 3, NULL);
INSERT INTO `waitlist` VALUES (8, 10, 6, '2026-06-02 06:00:00', '2026-06-02 19:00:00', '2026-05-12 18:04:02', NULL, 4, NULL);
INSERT INTO `waitlist` VALUES (9, 13, 29, '2026-06-05 12:00:00', '2026-06-05 14:00:00', '2026-05-22 03:49:44', NULL, 4, NULL);
INSERT INTO `waitlist` VALUES (10, 3, 29, '2026-05-31 21:00:00', '2026-05-31 23:00:00', '2026-05-18 14:45:00', '2026-05-30 11:16:48', 3, NULL);

-- ----------------------------
-- Function structure for amount_calculate
-- ----------------------------
DROP FUNCTION IF EXISTS `amount_calculate`;
delimiter ;;
CREATE FUNCTION `amount_calculate`(p_resId INT, p_start DATETIME, p_end DATETIME)
 RETURNS decimal(10,2)
  DETERMINISTIC
BEGIN
    DECLARE v_type INT;
    DECLARE v_hours INT;
    DECLARE v_price_per_hour DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    
    SELECT type INTO v_type FROM resource WHERE resId = p_resId;
    IF v_type = 1 THEN  #自习工位
        SET v_price_per_hour = 5;
    ELSE                #会议室
        SET v_price_per_hour = 20;
    END IF;
    
    #计算预约时长（小时）
    SET v_hours = TIMESTAMPDIFF(HOUR, p_start, p_end);
    SET v_total = v_hours * v_price_per_hour;
    
    RETURN v_total;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for cancel_unpaid_orders
-- ----------------------------
DROP PROCEDURE IF EXISTS `cancel_unpaid_orders`;
delimiter ;;
CREATE PROCEDURE `cancel_unpaid_orders`()
BEGIN
  UPDATE foodorder 
  SET status = 5, cancelTime = NOW()
  WHERE status = 1 
    AND createTime < DATE_SUB(NOW(), INTERVAL 15 MINUTE);
END
;;
delimiter ;

-- ----------------------------
-- Function structure for can_cancel_reservation
-- ----------------------------
DROP FUNCTION IF EXISTS `can_cancel_reservation`;
delimiter ;;
CREATE FUNCTION `can_cancel_reservation`(p_revId INT)
 RETURNS int
  DETERMINISTIC
BEGIN
    DECLARE v_startTime DATETIME;
    DECLARE v_cutoff DATETIME;
    SELECT startTime INTO v_startTime FROM reservation WHERE revId = p_revId;
    IF v_startTime IS NULL THEN
        RETURN 0;
    END IF;
    -- 截止时间为开始日期的前一天 18:00
    SET v_cutoff = DATE_SUB(DATE(v_startTime), INTERVAL 1 DAY) + INTERVAL 18 HOUR;
    RETURN IF(NOW() <= v_cutoff, 1, 0);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for complete_expired_reservations
-- ----------------------------
DROP PROCEDURE IF EXISTS `complete_expired_reservations`;
delimiter ;;
CREATE PROCEDURE `complete_expired_reservations`()
BEGIN
  UPDATE reservation 
  SET status = 4 
  WHERE status = 1 
    AND endTime < NOW() 
    AND checkinTime IS NOT NULL; #已打卡才正常完成，未打卡的已被违约处理
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for detect_violation
-- ----------------------------
DROP PROCEDURE IF EXISTS `detect_violation`;
delimiter ;;
CREATE PROCEDURE `detect_violation`()
BEGIN
  INSERT INTO violation (userId, revId, violateTime, reason, handleStatus)
  SELECT r.userId, r.revId, NOW(), '预约开始后半小时内未打卡', 1
  FROM reservation r
  WHERE r.status = 1 
    AND r.startTime <= NOW() 
    AND r.checkinTime IS NULL
    AND r.startTime < DATE_SUB(NOW(), INTERVAL 30 MINUTE)
    AND NOT EXISTS (
      SELECT 1 FROM violation v WHERE v.revId = r.revId
    );
  
#将对应预约状态改为“已违约”
  UPDATE reservation r
  SET r.status = 3
  WHERE r.status = 1 
    AND r.startTime <= NOW() 
    AND r.checkinTime IS NULL
    AND r.startTime < DATE_SUB(NOW(), INTERVAL 30 MINUTE);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for generate_foodorders_from_reservations
-- ----------------------------
DROP PROCEDURE IF EXISTS `generate_foodorders_from_reservations`;
delimiter ;;
CREATE PROCEDURE `generate_foodorders_from_reservations`(IN p_order_count INT,           -- 想要生成的订单数量
    IN p_start_date DATE,           -- 预约起始日期
    IN p_end_date DATE)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_revId INT;
    DECLARE v_userId INT;
    DECLARE v_order_date DATE;
    DECLARE v_startTime DATETIME;
    DECLARE v_endTime DATETIME;
    DECLARE v_createTime DATETIME;
    DECLARE v_payTime DATETIME;
    DECLARE v_cancelTime DATETIME;
    DECLARE v_status INT;
    DECLARE v_deliveryType INT;
    DECLARE v_orderNo VARCHAR(20);
    DECLARE v_totalAmount DECIMAL(10,2);
    DECLARE v_new_orderId INT;
    DECLARE v_detail_count INT;
    DECLARE v_prodId INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_hour INT;
    DECLARE v_minute INT;
    DECLARE v_second INT;
    DECLARE v_rand_val DECIMAL(5,4);

    -- 临时表：存储符合条件的预约记录（随机排序）
    DROP TEMPORARY TABLE IF EXISTS tmp_valid_reservations;
    CREATE TEMPORARY TABLE tmp_valid_reservations AS
    SELECT revId, userId, DATE(startTime) AS order_date, startTime, endTime
    FROM reservation
    WHERE DATE(startTime) BETWEEN p_start_date AND p_end_date
      AND status IN (1, 4)     -- 只选择“预约成功”或“已完成”的（已完成表示真实发生过）
    ORDER BY RAND();

    -- 如果预约数量不足，按实际数量生成
    IF (SELECT COUNT(*) FROM tmp_valid_reservations) < p_order_count THEN
        SET p_order_count = (SELECT COUNT(*) FROM tmp_valid_reservations);
    END IF;

    -- 循环生成订单
    WHILE i < p_order_count DO
        -- 从临时表中取一条预约记录（按随机顺序）
        SELECT revId, userId, order_date, startTime, endTime
        INTO v_revId, v_userId, v_order_date, v_startTime, v_endTime
        FROM tmp_valid_reservations
        LIMIT 1 OFFSET i;

        -- 随机配送方式（1=配送至座位，2=自取）
        SET v_deliveryType = IF(RAND() < 0.6, 1, 2);

        -- 订单状态分布（12% 取消，其余四种各22%）
        SET v_rand_val = RAND();
        IF v_rand_val < 0.12 THEN
            SET v_status = 5;      -- 已取消
        ELSEIF v_rand_val < 0.34 THEN
            SET v_status = 1;      -- 待支付
        ELSEIF v_rand_val < 0.56 THEN
            SET v_status = 2;      -- 已支付
        ELSEIF v_rand_val < 0.78 THEN
            SET v_status = 3;      -- 制作中
        ELSE
            SET v_status = 4;      -- 已完成
        END IF;

        -- 生成创建时间（在预约当天的 07:00~22:00 之间）
        SET v_hour = 7 + FLOOR(RAND() * 16);
        SET v_minute = FLOOR(RAND() * 60);
        SET v_second = FLOOR(RAND() * 60);
        SET v_createTime = TIMESTAMP(v_order_date, MAKETIME(v_hour, v_minute, v_second));

        -- 根据状态生成支付时间或取消时间
        SET v_payTime = NULL;
        SET v_cancelTime = NULL;

        IF v_status IN (2, 3, 4) THEN
            -- 支付时间在创建后 1~15 分钟之间，且不跨天
            SET v_payTime = DATE_ADD(v_createTime, INTERVAL 1 + FLOOR(RAND() * 14) MINUTE);
            IF DATE(v_payTime) > v_order_date THEN
                SET v_payTime = CONCAT(v_order_date, ' 23:59:59');
            END IF;
        ELSEIF v_status = 5 THEN
            -- 取消时间在创建后 1~120 分钟之间，且不跨天
            SET v_cancelTime = DATE_ADD(v_createTime, INTERVAL 1 + FLOOR(RAND() * 120) MINUTE);
            IF DATE(v_cancelTime) > v_order_date THEN
                SET v_cancelTime = CONCAT(v_order_date, ' 23:59:59');
            END IF;
        END IF;

        -- 生成唯一订单号（F + yyyyMMddHHmm + userId(3位) + 随机3位）
        SET v_orderNo = CONCAT(
            'F', DATE_FORMAT(v_createTime, '%Y%m%d%H%i'),
            LPAD(v_userId, 3, '0'),
            LPAD(FLOOR(RAND() * 1000), 3, '0')
        );

        -- 插入订单（总金额先为0，后面更新）
        INSERT INTO foodorder (
            orderNo, userId, revId, totalAmount, deliveryType,
            status, createTime, payTime, cancelTime
        ) VALUES (
            v_orderNo, v_userId, v_revId, 0.00, v_deliveryType,
            v_status, v_createTime, v_payTime, v_cancelTime
        );
        SET v_new_orderId = LAST_INSERT_ID();

        -- 生成订单明细（1~4种商品）
        SET v_detail_count = 1 + FLOOR(RAND() * 4);
        SET v_totalAmount = 0.00;

        START TRANSACTION;
        WHILE v_detail_count > 0 DO
            -- 随机选择一个上架商品
            SELECT prodId, price INTO v_prodId, v_price
            FROM product WHERE state = 1 ORDER BY RAND() LIMIT 1;
            SET v_quantity = 1 + FLOOR(RAND() * 3);
            INSERT INTO orderdetail (orderId, prodId, quantity, price)
            VALUES (v_new_orderId, v_prodId, v_quantity, v_price);
            SET v_totalAmount = v_totalAmount + (v_price * v_quantity);
            SET v_detail_count = v_detail_count - 1;
        END WHILE;

        -- 更新订单总金额
        UPDATE foodorder SET totalAmount = v_totalAmount WHERE orderId = v_new_orderId;
        COMMIT;

        SET i = i + 1;
    END WHILE;

    DROP TEMPORARY TABLE tmp_valid_reservations;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for generate_sample_foodorders
-- ----------------------------
DROP PROCEDURE IF EXISTS `generate_sample_foodorders`;
delimiter ;;
CREATE PROCEDURE `generate_sample_foodorders`(IN p_base_date DATE)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_target_date DATE;
    DECLARE v_userId INT;
    DECLARE v_revId INT DEFAULT NULL;
    DECLARE v_status INT;
    DECLARE v_createTime DATETIME;
    DECLARE v_payTime DATETIME;
    DECLARE v_cancelTime DATETIME;
    DECLARE v_orderNo VARCHAR(20);
    DECLARE v_totalAmount DECIMAL(10,2);
    DECLARE v_deliveryType INT;
    DECLARE v_new_orderId INT;
    DECLARE v_detail_count INT;
    DECLARE v_prodId INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_order_hour INT;
    DECLARE v_order_minute INT;
    DECLARE v_has_reservation INT DEFAULT 0;    -- 标记当天是否有预约

    IF p_base_date IS NULL THEN
        SET p_base_date = CURDATE();
    END IF;

    WHILE i <= 150 DO
        -- 1. 随机日期（过去30天内）
        SET v_target_date = DATE_SUB(p_base_date, INTERVAL FLOOR(RAND() * 30) DAY);

        -- 2. 随机普通用户（1~13）
        SET v_userId = ELT(1 + FLOOR(RAND() * 13), 1,2,3,4,5,6,7,8,9,10,11,12,13);

        -- 3. 查询该用户当天是否有预约（一天最多一个，取任意一个即可）
        SELECT revId INTO v_revId FROM reservation
        WHERE userId = v_userId AND DATE(startTime) = v_target_date
        LIMIT 1;
        SET v_has_reservation = (v_revId IS NOT NULL);

        -- 4. 随机决定配送方式（1=配送至座位，2=自取）
        --    如果没有预约，则配送方式强制为2（自取）
        IF v_has_reservation = 1 THEN
            SET v_deliveryType = 1 + FLOOR(RAND() * 2);   -- 1 或 2
        ELSE
            SET v_deliveryType = 2;   -- 无预约不能配送至座位
        END IF;

        -- 5. 订单状态分布（需求：已取消12%，其余88%平均分给1,2,3,4各22%）
        SET @rand_val = RAND();
        IF @rand_val < 0.12 THEN
            SET v_status = 5;   -- 已取消
        ELSEIF @rand_val < 0.34 THEN
            SET v_status = 1;   -- 待支付 (22%)
        ELSEIF @rand_val < 0.56 THEN
            SET v_status = 2;   -- 已支付 (22%)
        ELSEIF @rand_val < 0.78 THEN
            SET v_status = 3;   -- 制作中 (22%)
        ELSE
            SET v_status = 4;   -- 已完成 (22%)
        END IF;

        -- 6. 生成创建时间（07:00~22:00）
        SET v_order_hour = 7 + FLOOR(RAND() * 16);
        SET v_order_minute = FLOOR(RAND() * 60);
        SET v_createTime = CONCAT(v_target_date, ' ',
            LPAD(v_order_hour, 2, '0'), ':',
            LPAD(v_order_minute, 2, '0'), ':',
            LPAD(FLOOR(RAND()*60), 2, '0'));

        -- 7. 根据状态设置支付时间或取消时间
        SET v_payTime = NULL;
        SET v_cancelTime = NULL;

        IF v_status = 2 OR v_status = 3 OR v_status = 4 THEN
            -- 已支付/制作中/已完成：支付时间在创建后15分钟内
            SET v_payTime = DATE_ADD(v_createTime, INTERVAL 1 + FLOOR(RAND() * 14) MINUTE);
            IF DATE(v_payTime) > v_target_date THEN
                SET v_payTime = CONCAT(v_target_date, ' 23:59:59');
            END IF;
        ELSEIF v_status = 5 THEN
            -- 已取消：取消时间在创建后1~120分钟
            SET v_cancelTime = DATE_ADD(v_createTime, INTERVAL 1 + FLOOR(RAND() * 120) MINUTE);
            IF DATE(v_cancelTime) > v_target_date THEN
                SET v_cancelTime = CONCAT(v_target_date, ' 23:59:59');
            END IF;
        END IF;

        -- 8. 生成订单号（唯一）
        SET v_orderNo = CONCAT('F', DATE_FORMAT(v_createTime, '%Y%m%d%H%i'),
            LPAD(v_userId, 3, '0'), LPAD(FLOOR(RAND()*1000), 3, '0'));

        -- 9. 插入订单（注意：如果配送为1但无预约，因上面已强制改为2，所以revId可为NULL或不使用）
        INSERT INTO foodorder (
            orderNo, userId, revId, totalAmount, deliveryType,
            status, createTime, payTime, cancelTime
        ) VALUES (
            v_orderNo, v_userId, IF(v_deliveryType=1, v_revId, NULL), 0.00, v_deliveryType,
            v_status, v_createTime, v_payTime, v_cancelTime
        );
        SET v_new_orderId = LAST_INSERT_ID();

        -- 10. 生成订单明细（1~4种商品）
        SET v_detail_count = 1 + FLOOR(RAND() * 4);
        SET v_totalAmount = 0.00;
        WHILE v_detail_count > 0 DO
            SELECT prodId, price INTO v_prodId, v_price
            FROM product WHERE state = 1 ORDER BY RAND() LIMIT 1;
            SET v_quantity = 1 + FLOOR(RAND() * 3);
            INSERT INTO orderdetail (orderId, prodId, quantity, price)
            VALUES (v_new_orderId, v_prodId, v_quantity, v_price);
            SET v_totalAmount = v_totalAmount + (v_price * v_quantity);
            SET v_detail_count = v_detail_count - 1;
        END WHILE;

        -- 更新订单总金额
        UPDATE foodorder SET totalAmount = v_totalAmount WHERE orderId = v_new_orderId;

        -- 重要：重置变量，避免残留
        SET v_revId = NULL;
        SET v_has_reservation = 0;

        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for generate_sample_reservations
-- ----------------------------
DROP PROCEDURE IF EXISTS `generate_sample_reservations`;
delimiter ;;
CREATE PROCEDURE `generate_sample_reservations`(IN p_base_date DATE)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_userId INT;
    DECLARE v_resId INT;
    DECLARE v_startDate DATE;
    DECLARE v_startHour INT;
    DECLARE v_duration INT;
    DECLARE v_startTime DATETIME;
    DECLARE v_endTime DATETIME;
    DECLARE v_status INT;
    DECLARE v_createTime DATETIME;
    DECLARE v_cancelTime DATETIME;
    DECLARE v_checkinTime DATETIME;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_days_back INT;
    DECLARE v_new_revId INT;

    IF p_base_date IS NULL THEN
        SET p_base_date = CURDATE();
    END IF;

    WHILE i <= 60 DO
        -- 随机用户（普通用户 1~13）
        SET v_userId = ELT(1 + FLOOR(RAND() * 13), 1,2,3,4,5,6,7,8,9,10,11,12,13);
        -- 随机座位（1~38）
        SET v_resId = ELT(1 + FLOOR(RAND() * 38), 
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38);

        -- 状态分布（符合新定义）
        IF i <= 6 THEN                 -- 10% 待支付 (0)
            SET v_status = 0;
        ELSEIF i <= 15 THEN            -- 15% 预约成功 (1)
            SET v_status = 1;
        ELSEIF i <= 21 THEN            -- 10% 进行中 (2)
            SET v_status = 2;
        ELSEIF i <= 30 THEN            -- 15% 已取消 (3)
            SET v_status = 3;
        ELSEIF i <= 36 THEN            -- 10% 违约 (4)
            SET v_status = 4;
        ELSE                           -- 40% 已完成 (5)
            SET v_status = 5;
        END IF;

        -- 根据状态决定预约日期（未来/过去）
        IF v_status = 0 OR v_status = 1 THEN
            -- 待支付 和 预约成功 → 未来日期
            SET v_startDate = DATE_ADD(p_base_date, INTERVAL FLOOR(RAND() * 7) DAY);
            SET v_startHour = 6 + FLOOR(RAND() * 17);
            SET v_duration = 1 + FLOOR(RAND() * 17);
            IF v_startHour + v_duration > 23 THEN
                SET v_duration = 23 - v_startHour;
            END IF;
        ELSE
            -- 进行中 / 已取消 / 违约 / 已完成 → 过去日期
            SET v_days_back = 1 + FLOOR(RAND() * 30);
            SET v_startDate = DATE_SUB(p_base_date, INTERVAL v_days_back DAY);
            SET v_startHour = 6 + FLOOR(RAND() * 17);
            SET v_duration = 1 + FLOOR(RAND() * 17);
            IF v_startHour + v_duration > 23 THEN
                SET v_duration = 23 - v_startHour;
            END IF;
        END IF;

        SET v_startTime = CONCAT(v_startDate, ' ', LPAD(v_startHour, 2, '0'), ':00:00');
        SET v_endTime = DATE_ADD(v_startTime, INTERVAL v_duration HOUR);

        -- 创建时间（在开始时间之前若干天）
        IF v_status = 0 OR v_status = 1 THEN
            SET v_createTime = DATE_SUB(v_startTime, INTERVAL (1 + FLOOR(RAND() * 7)) DAY);
            IF v_createTime < DATE_SUB(p_base_date, INTERVAL 30 DAY) THEN
                SET v_createTime = DATE_SUB(p_base_date, INTERVAL 30 DAY);
                SET v_createTime = CONCAT(CAST(v_createTime AS DATE), ' 00:00:00');
            END IF;
        ELSE
            SET v_createTime = DATE_SUB(v_startTime, INTERVAL FLOOR(RAND() * 6) DAY);
            IF v_createTime < DATE_SUB(p_base_date, INTERVAL 30 DAY) THEN
                SET v_createTime = DATE_SUB(p_base_date, INTERVAL 30 DAY);
                SET v_createTime = CONCAT(CAST(v_createTime AS DATE), ' 00:00:00');
            END IF;
        END IF;

        -- 随机时间部分
        SET v_createTime = CONCAT(CAST(v_createTime AS DATE), ' ',
            LPAD(FLOOR(RAND() * 24), 2, '0'), ':',
            LPAD(FLOOR(RAND() * 60), 2, '0'), ':',
            LPAD(FLOOR(RAND() * 60), 2, '0'));

        -- 取消时间和打卡时间初始为 NULL
        SET v_cancelTime = NULL;
        SET v_checkinTime = NULL;

        -- 已取消的预约：设置取消时间（开始日期前一天 17:xx）
        IF v_status = 3 THEN
            SET v_cancelTime = DATE_SUB(DATE(v_startTime), INTERVAL 1 DAY);
            SET v_cancelTime = CONCAT(CAST(v_cancelTime AS DATE), ' ',
                LPAD(17 + FLOOR(RAND() * 1), 2, '0'), ':',
                LPAD(FLOOR(RAND() * 60), 2, '0'), ':',
                LPAD(FLOOR(RAND() * 60), 2, '0'));
        END IF;

        -- 进行中或已完成或违约：设置打卡时间（仅设置合适的类型）
        IF v_status = 2 THEN
            -- 进行中：打卡时间在开始时间后 0~29 分钟（但还没结束）
            SET v_checkinTime = DATE_ADD(v_startTime, INTERVAL FLOOR(RAND() * 30) MINUTE);
        ELSEIF v_status = 5 THEN
            -- 已完成：打卡时间在开始时间后 0~29 分钟
            SET v_checkinTime = DATE_ADD(v_startTime, INTERVAL FLOOR(RAND() * 30) MINUTE);
        ELSEIF v_status = 4 THEN
            -- 违约：不打卡，但插入违约记录
            SET v_checkinTime = NULL;
        END IF;

        -- 计算费用（元）
        SET v_amount = amount_calculate(v_resId, v_startTime, v_endTime);

        -- 插入预约
        INSERT INTO reservation (
            userId, resId, startTime, endTime, status,
            createTime, cancelTime, checkinTime, amount
        ) VALUES (
            v_userId, v_resId, v_startTime, v_endTime, v_status,
            v_createTime, v_cancelTime, v_checkinTime, v_amount
        );

        SET v_new_revId = LAST_INSERT_ID();

        -- 如果是违约状态（status=4），插入违约记录
        IF v_status = 4 THEN
            INSERT INTO violation (userId, revId, violateTime, reason, handleStatus)
            VALUES (v_userId, v_new_revId, DATE_ADD(v_startTime, INTERVAL 30 MINUTE), '预约开始后30分钟内未打卡', 1);
        END IF;

        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for generate_sample_waitlist
-- ----------------------------
DROP PROCEDURE IF EXISTS `generate_sample_waitlist`;
delimiter ;;
CREATE PROCEDURE `generate_sample_waitlist`(IN p_base_date DATE)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_userId INT;
    DECLARE v_resId INT;
    DECLARE v_startDate DATE;
    DECLARE v_startHour INT;
    DECLARE v_duration INT;
    DECLARE v_startTime DATETIME;
    DECLARE v_endTime DATETIME;
    DECLARE v_status INT;
    DECLARE v_createTime DATETIME;
    DECLARE v_cancelTime DATETIME;
    DECLARE v_createDate DATE;
    DECLARE v_createHour INT;
    DECLARE v_createMin INT;
    DECLARE v_createSec INT;
    DECLARE v_cancelDate DATE;

    IF p_base_date IS NULL THEN
        SET p_base_date = CURDATE();
    END IF;

    WHILE i <= 10 DO
        -- 随机用户（1~13）
        SET v_userId = ELT(1 + FLOOR(RAND() * 13), 1,2,3,4,5,6,7,8,9,10,11,12,13);
        -- 随机座位（1~37）
        SET v_resId = ELT(1 + FLOOR(RAND() * 37),
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38);

        -- 状态分配：等待中5条，已取消2条，未成功3条
        IF i <= 5 THEN
            SET v_status = 1;
        ELSEIF i <= 7 THEN
            SET v_status = 3;
        ELSE
            SET v_status = 4;
        END IF;

        -- 期望开始时间（未来一周内，整点）
        SET v_startDate = DATE_ADD(p_base_date, INTERVAL FLOOR(RAND() * 7) DAY);
        SET v_startHour = 6 + FLOOR(RAND() * 17);
        SET v_duration = 1 + FLOOR(RAND() * 17);
        IF v_startHour + v_duration > 23 THEN
            SET v_duration = 23 - v_startHour;
        END IF;

        SET v_startTime = CONCAT(CAST(v_startDate AS CHAR), ' ', LPAD(v_startHour, 2, '0'), ':00:00');
        SET v_endTime = DATE_ADD(v_startTime, INTERVAL v_duration HOUR);

        -- 创建时间（最近30天内，且不晚于期望开始时间）
        SET v_createDate = DATE_SUB(p_base_date, INTERVAL FLOOR(RAND() * 30) DAY);
        SET v_createHour = FLOOR(RAND() * 24);
        SET v_createMin = FLOOR(RAND() * 60);
        SET v_createSec = FLOOR(RAND() * 60);
        SET v_createTime = CONCAT(CAST(v_createDate AS CHAR), ' ',
            LPAD(v_createHour, 2, '0'), ':',
            LPAD(v_createMin, 2, '0'), ':',
            LPAD(v_createSec, 2, '0'));

        IF v_createTime > v_startTime THEN
            SET v_createDate = DATE_SUB(v_startDate, INTERVAL 1 DAY);
            SET v_createTime = CONCAT(CAST(v_createDate AS CHAR), ' ',
                LPAD(v_createHour, 2, '0'), ':',
                LPAD(v_createMin, 2, '0'), ':',
                LPAD(v_createSec, 2, '0'));
        END IF;

        -- 取消时间（仅已取消状态，为开始日期前一天 17:xx）
        SET v_cancelTime = NULL;
        IF v_status = 3 THEN
            SET v_cancelDate = DATE_SUB(v_startDate, INTERVAL 1 DAY);
            SET v_cancelTime = CONCAT(CAST(v_cancelDate AS CHAR), ' ',
                LPAD(17 + FLOOR(RAND() * 1), 2, '0'), ':',
                LPAD(FLOOR(RAND() * 60), 2, '0'), ':',
                LPAD(FLOOR(RAND() * 60), 2, '0'));
        END IF;

        -- 插入候补记录（不关联预约，revId = NULL）
        INSERT INTO waitlist (userId, resId, startTime, endTime, createTime, cancelTime, status, revId)
        VALUES (v_userId, v_resId, v_startTime, v_endTime, v_createTime, v_cancelTime, v_status, NULL);

        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for mark_failed_waitlist
-- ----------------------------
DROP PROCEDURE IF EXISTS `mark_failed_waitlist`;
delimiter ;;
CREATE PROCEDURE `mark_failed_waitlist`()
BEGIN
    -- 标记明天（CURDATE()+1）的候补中，仍存在冲突的记录为失败
    UPDATE waitlist w
    SET w.status = 4
    WHERE w.status = 1
      AND DATE(w.startTime) = CURDATE() + INTERVAL 1 DAY
      AND EXISTS (
          SELECT 1 FROM reservation r
          WHERE r.resId = w.resId
            AND r.status = 1   -- 有效的预约
            AND NOT (r.endTime <= w.startTime OR r.startTime >= w.endTime)
      );
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for promote_waitlist_for_seat
-- ----------------------------
DROP PROCEDURE IF EXISTS `promote_waitlist_for_seat`;
delimiter ;;
CREATE PROCEDURE `promote_waitlist_for_seat`(IN p_resId INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_waitId INT;
    DECLARE v_userId INT;
    DECLARE v_waitStart DATETIME;
    DECLARE v_waitEnd DATETIME;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_newRevId INT;
    
    DECLARE cur CURSOR FOR
        SELECT waitId, userId, startTime, endTime
        FROM waitlist
        WHERE resId = p_resId AND status = 1
        ORDER BY createTime ASC
        FOR UPDATE;  -- 锁定这些行，防止并发转正冲突
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_waitId, v_userId, v_waitStart, v_waitEnd;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- 检查是否有有效预约冲突（status=1的预约）
        IF NOT EXISTS (
            SELECT 1 FROM reservation
            WHERE resId = p_resId
              AND status = 1
              AND NOT (endTime <= v_waitStart OR startTime >= v_waitEnd)
        ) THEN
            -- 计算费用
            SET v_amount = amount_calculate(p_resId, v_waitStart, v_waitEnd);
            -- 插入预约
            INSERT INTO reservation (userId, resId, startTime, endTime, status, createTime, amount)
            VALUES (v_userId, p_resId, v_waitStart, v_waitEnd, 1, NOW(), v_amount);
            SET v_newRevId = LAST_INSERT_ID();
            -- 更新候补记录
            UPDATE waitlist SET status = 2, revId = v_newRevId WHERE waitId = v_waitId;
        END IF;
    END LOOP;
    CLOSE cur;
END
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_cancel_unpaid_orders
-- ----------------------------
DROP EVENT IF EXISTS `evt_cancel_unpaid_orders`;
delimiter ;;
CREATE EVENT `evt_cancel_unpaid_orders`
ON SCHEDULE
EVERY '5' MINUTE STARTS '2026-04-21 23:18:46'
DO CALL cancel_unpaid_orders()
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_complete_reservations
-- ----------------------------
DROP EVENT IF EXISTS `evt_complete_reservations`;
delimiter ;;
CREATE EVENT `evt_complete_reservations`
ON SCHEDULE
EVERY '15' MINUTE STARTS '2026-04-22 03:03:08'
DO CALL complete_expired_reservations()
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_detect_violation
-- ----------------------------
DROP EVENT IF EXISTS `evt_detect_violation`;
delimiter ;;
CREATE EVENT `evt_detect_violation`
ON SCHEDULE
EVERY '10' MINUTE STARTS '2026-04-22 03:00:29'
DO CALL detect_violation()
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_mark_failed_waitlist
-- ----------------------------
DROP EVENT IF EXISTS `evt_mark_failed_waitlist`;
delimiter ;;
CREATE EVENT `evt_mark_failed_waitlist`
ON SCHEDULE
EVERY '1' DAY STARTS '2026-04-25 18:30:00'
DO CALL mark_failed_waitlist()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table reservation
-- ----------------------------
DROP TRIGGER IF EXISTS `before_reservation_update`;
delimiter ;;
CREATE TRIGGER `before_reservation_update` BEFORE UPDATE ON `reservation` FOR EACH ROW BEGIN
    #如果状态从非取消变为取消，且当前时间已超过截止时间
    IF OLD.status != 2 AND NEW.status = 2 THEN
        IF can_cancel_reservation(OLD.revId) = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Cannot cancel: exceeded cancellation deadline (18:00 day before)';
        END IF;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table reservation
-- ----------------------------
DROP TRIGGER IF EXISTS `after_reservation_cancel`;
delimiter ;;
CREATE TRIGGER `after_reservation_cancel` AFTER UPDATE ON `reservation` FOR EACH ROW BEGIN
    IF OLD.status != 2 AND NEW.status = 2 THEN
        CALL promote_waitlist_for_seat(NEW.resId);
    END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
