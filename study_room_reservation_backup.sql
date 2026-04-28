-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: study_room_reservation
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `study_room_reservation`
--

/*!40000 DROP DATABASE IF EXISTS `study_room_reservation`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `study_room_reservation` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `study_room_reservation`;

--
-- Table structure for table `foodorder`
--

DROP TABLE IF EXISTS `foodorder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `foodorder` (
  `orderId` int NOT NULL AUTO_INCREMENT,
  `orderNo` varchar(20) NOT NULL,
  `userId` int NOT NULL,
  `revId` int DEFAULT NULL,
  `totalAmount` decimal(10,2) NOT NULL,
  `deliveryType` int NOT NULL COMMENT '1=配送至座位,2=吧台自取',
  `status` int NOT NULL DEFAULT '1' COMMENT '1=待支付,2=已支付,3=制作中,4=已完成,5=已取消',
  `createTime` datetime NOT NULL,
  `payTime` datetime DEFAULT NULL,
  `cancelTime` datetime DEFAULT NULL,
  PRIMARY KEY (`orderId`),
  UNIQUE KEY `uk_orderNo` (`orderNo`),
  KEY `idx_userId` (`userId`),
  KEY `idx_status_created` (`status`,`createTime`),
  KEY `fk_foodorder_reservation` (`revId`),
  CONSTRAINT `fk_foodorder_reservation` FOREIGN KEY (`revId`) REFERENCES `reservation` (`revId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_foodorder_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `foodorder`
--

LOCK TABLES `foodorder` WRITE;
/*!40000 ALTER TABLE `foodorder` DISABLE KEYS */;
INSERT INTO `foodorder` VALUES (1,'F202604252047010749',10,39,68.00,2,4,'2026-04-25 20:47:20','2026-04-25 20:53:20',NULL),(2,'F202604242046010948',10,32,16.00,1,2,'2026-04-24 20:46:18','2026-04-24 20:49:18',NULL),(3,'F202604271511008876',8,20,70.00,1,5,'2026-04-27 15:11:17',NULL,'2026-04-27 22:08:46'),(4,'F202604082025009096',9,51,60.00,1,5,'2026-04-08 20:25:40',NULL,'2026-04-27 22:08:46'),(5,'F202604300740001769',1,17,78.00,2,4,'2026-04-30 07:40:21','2026-04-30 07:51:21',NULL),(6,'F202604301751009644',9,5,60.00,2,1,'2026-04-30 17:51:14',NULL,NULL),(7,'F202604271313002295',2,6,36.00,1,4,'2026-04-27 13:13:53','2026-04-27 13:25:53',NULL),(8,'F202604191656011076',11,34,121.00,1,5,'2026-04-19 16:56:52',NULL,'2026-04-19 18:01:52'),(9,'F202604211230008539',8,35,74.00,2,3,'2026-04-21 12:30:27','2026-04-21 12:41:27',NULL),(10,'F202604291711002187',2,11,62.00,2,3,'2026-04-29 17:11:57','2026-04-29 17:14:57',NULL),(11,'F202604270738002498',2,16,143.00,2,4,'2026-04-27 07:38:05','2026-04-27 07:46:05',NULL),(12,'F202604081033001127',1,50,138.00,2,4,'2026-04-08 10:33:15','2026-04-08 10:42:15',NULL),(13,'F202604010702012092',12,30,132.00,2,2,'2026-04-01 07:02:04','2026-04-01 07:06:04',NULL),(14,'F202604020947010035',10,44,76.00,1,5,'2026-04-02 09:47:28',NULL,'2026-04-27 22:08:46'),(15,'F202604301347007414',7,23,62.00,1,5,'2026-04-30 13:47:46',NULL,'2026-04-30 14:54:46'),(16,'F202604101120003559',3,36,132.00,1,2,'2026-04-10 11:20:48','2026-04-10 11:34:48',NULL),(17,'F202604010851010918',10,52,142.00,1,2,'2026-04-01 08:51:02','2026-04-01 09:00:02',NULL),(18,'F202604081857004703',4,37,117.00,1,3,'2026-04-08 18:57:33','2026-04-08 19:10:33',NULL),(19,'F202604272257013697',13,26,100.00,1,3,'2026-04-27 22:57:49','2026-04-27 23:01:49',NULL),(20,'F202604290946004915',4,8,12.00,1,1,'2026-04-29 09:46:26',NULL,NULL),(21,'F202604290941002185',2,24,47.00,1,2,'2026-04-29 09:41:58','2026-04-29 09:53:58',NULL),(22,'F202604082246001882',1,41,57.00,1,3,'2026-04-08 22:46:55','2026-04-08 22:51:55',NULL),(23,'F202604030932009249',9,45,132.00,1,3,'2026-04-03 09:32:17','2026-04-03 09:44:17',NULL),(24,'F202604270904012491',12,27,52.00,1,4,'2026-04-27 09:04:58','2026-04-27 09:14:58',NULL),(25,'F202604291342002050',2,19,32.00,2,2,'2026-04-29 13:42:18','2026-04-29 13:48:18',NULL),(26,'F202604052226005548',5,43,146.00,1,4,'2026-04-05 22:26:16','2026-04-05 22:28:16',NULL),(27,'F202604231624005516',5,42,71.00,1,2,'2026-04-23 16:24:15','2026-04-23 16:25:15',NULL),(28,'F202604302208001193',1,10,103.00,1,2,'2026-04-30 22:08:49','2026-04-30 22:19:49',NULL),(29,'F202604111920005370',5,28,96.00,1,2,'2026-04-11 19:20:20','2026-04-11 19:30:20',NULL),(30,'F202604301017002749',2,2,98.00,2,1,'2026-04-30 10:17:55',NULL,NULL),(31,'F202604071559003427',3,31,78.00,1,5,'2026-04-07 15:59:16',NULL,'2026-04-27 22:08:46'),(32,'F202604151336003888',3,48,32.00,1,5,'2026-04-15 13:36:44',NULL,'2026-04-27 22:08:46'),(33,'F202604032226009909',9,38,70.00,1,2,'2026-04-03 22:26:23','2026-04-03 22:35:23',NULL),(34,'F202604161551002391',2,33,51.00,1,5,'2026-04-16 15:51:35',NULL,'2026-04-27 22:08:46'),(35,'F202604021135005490',5,47,48.00,1,4,'2026-04-02 11:35:06','2026-04-02 11:46:06',NULL),(36,'F202604011617008463',8,29,18.00,1,4,'2026-04-01 16:17:43','2026-04-01 16:28:43',NULL),(37,'F202604270757013879',13,13,44.00,1,2,'2026-04-27 07:57:38','2026-04-27 08:03:38',NULL),(38,'F202604291406013968',13,1,90.00,1,1,'2026-04-29 14:06:03',NULL,NULL),(39,'F202604271947012806',12,15,53.00,1,2,'2026-04-27 19:47:34','2026-04-27 19:55:34',NULL);
/*!40000 ALTER TABLE `foodorder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice`
--

DROP TABLE IF EXISTS `notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice` (
  `nId` int NOT NULL AUTO_INCREMENT,
  `title` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `createTime` datetime NOT NULL,
  `state` int NOT NULL DEFAULT '1' COMMENT '1=发布,2=下架',
  `userId` int NOT NULL,
  PRIMARY KEY (`nId`),
  KEY `fk_notice_users` (`userId`),
  CONSTRAINT `fk_notice_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice`
--

LOCK TABLES `notice` WRITE;
/*!40000 ALTER TABLE `notice` DISABLE KEYS */;
INSERT INTO `notice` VALUES (1,'欢迎使用自习室预约系统','亲爱的同学们，欢迎使用本自习室预约系统！系统支持座位预约、轻食点单、候补排队等功能。请遵守预约规则，按时打卡，共同维护良好的学习环境。如有疑问，请联系管理员。祝您学习愉快！','2026-04-27 22:15:40',1,14);
/*!40000 ALTER TABLE `notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderdetail`
--

DROP TABLE IF EXISTS `orderdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderdetail` (
  `ordId` int NOT NULL AUTO_INCREMENT,
  `orderId` int NOT NULL,
  `prodId` int NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL COMMENT '下单时快照单价',
  PRIMARY KEY (`ordId`),
  KEY `idx_orderId` (`orderId`),
  KEY `fk_orderdetail_product` (`prodId`),
  CONSTRAINT `fk_orderdetail_order` FOREIGN KEY (`orderId`) REFERENCES `foodorder` (`orderId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orderdetail_product` FOREIGN KEY (`prodId`) REFERENCES `product` (`prodId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderdetail`
--

LOCK TABLES `orderdetail` WRITE;
/*!40000 ALTER TABLE `orderdetail` DISABLE KEYS */;
INSERT INTO `orderdetail` VALUES (1,1,11,1,18.00),(2,1,57,1,24.00),(3,1,3,2,13.00),(4,2,36,2,8.00),(5,3,31,1,16.00),(6,3,19,3,8.00),(7,3,45,2,15.00),(8,4,25,3,15.00),(9,4,49,1,15.00),(10,5,42,1,24.00),(11,5,35,2,8.00),(12,5,56,2,19.00),(13,6,49,1,15.00),(14,6,53,3,15.00),(15,7,64,2,18.00),(16,8,63,1,16.00),(17,8,17,2,10.00),(18,8,56,3,19.00),(19,8,47,2,14.00),(20,9,13,1,20.00),(21,9,55,3,18.00),(22,10,2,2,13.00),(23,10,21,3,12.00),(24,11,24,1,23.00),(25,11,39,2,18.00),(26,11,31,3,16.00),(27,11,61,2,18.00),(28,12,21,2,12.00),(29,12,34,3,14.00),(30,12,26,1,18.00),(31,12,11,3,18.00),(32,13,34,3,14.00),(33,13,39,2,18.00),(34,13,39,3,18.00),(35,14,22,1,12.00),(36,14,46,3,17.00),(37,14,3,1,13.00),(38,15,38,3,18.00),(39,15,20,1,8.00),(40,16,19,3,8.00),(41,16,42,1,24.00),(42,16,10,3,18.00),(43,16,48,2,15.00),(44,17,20,1,8.00),(45,17,39,3,18.00),(46,17,36,1,8.00),(47,17,43,3,24.00),(48,18,24,2,23.00),(49,18,3,2,13.00),(50,18,45,2,15.00),(51,18,48,1,15.00),(52,19,62,3,12.00),(53,19,12,1,18.00),(54,19,46,2,17.00),(55,19,18,1,12.00),(56,20,62,1,12.00),(57,21,24,1,23.00),(58,21,19,3,8.00),(59,22,47,3,14.00),(60,22,49,1,15.00),(61,23,45,2,15.00),(62,23,34,3,14.00),(63,23,16,3,16.00),(64,23,18,1,12.00),(65,24,34,1,14.00),(66,24,56,2,19.00),(67,25,15,2,16.00),(68,26,58,2,13.00),(69,26,26,3,18.00),(70,26,30,3,22.00),(71,27,63,3,16.00),(72,27,24,1,23.00),(73,28,22,1,12.00),(74,28,59,3,13.00),(75,28,23,2,13.00),(76,28,58,2,13.00),(77,29,1,2,13.00),(78,29,54,1,16.00),(79,29,40,1,24.00),(80,29,52,2,15.00),(81,30,20,1,8.00),(82,30,25,2,15.00),(83,30,64,2,18.00),(84,30,62,2,12.00),(85,31,43,2,24.00),(86,31,53,2,15.00),(87,32,31,2,16.00),(88,33,37,2,8.00),(89,33,26,2,18.00),(90,33,6,1,18.00),(91,34,46,3,17.00),(92,35,14,3,16.00),(93,36,33,1,18.00),(94,37,59,2,13.00),(95,37,27,1,18.00),(96,38,51,2,16.00),(97,38,5,2,13.00),(98,38,32,2,16.00),(99,39,4,1,13.00),(100,39,20,2,8.00),(101,39,37,3,8.00);
/*!40000 ALTER TABLE `orderdetail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `prodId` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` int NOT NULL COMMENT '1=咖啡,2=茶饮,3=甜品,4=小吃',
  `price` decimal(10,2) NOT NULL,
  `stock` int NOT NULL,
  `picture` mediumtext,
  `description` varchar(200) DEFAULT NULL,
  `state` int NOT NULL DEFAULT '1' COMMENT '1=上架,0=下架',
  PRIMARY KEY (`prodId`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'冰美式',1,13.00,50,'/images/product/冰美式.jpg','经典冰美式，纯粹咖啡香，快速驱散困意，专注力满分。',1),(2,'气泡美式',1,13.00,40,'/images/product/气泡美式.jpg','经典美式融合绵密气泡，清爽解腻，提神醒脑，夏季自习必备。',1),(3,'凤凰单枞美式',1,13.00,30,'/images/product/凤凰单枞美式.jpg','凤凰单枞茶香与美式咖啡融合，甘醇回韵，别具一格。',1),(4,'龙井蜜瓜美式',1,13.00,30,'/images/product/龙井蜜瓜美式.jpg','龙井茶香+蜜瓜清甜+美式咖啡，清新三重奏。',1),(5,'茉莉花茶美式',1,13.00,35,'/images/product/茉莉花茶美式.jpg','茉莉花茶清香×浓缩咖啡，花香咖韵，淡雅悠长。',1),(6,'拿铁咖啡',1,18.00,60,'/images/product/拿铁咖啡.jpg','经典拿铁，奶香与咖香平衡，自习室标配。',1),(7,'薄荷拿铁',1,18.00,60,'/images/product/薄荷拿铁.jpg','清凉薄荷与醇厚拿铁交融，一口冰爽，困意一扫而空。',1),(8,'焦糖拿铁',1,18.00,60,'/images/product/焦糖拿铁.jpg','焦糖香甜融入丝滑拿铁，温暖治愈，甜而不腻。',1),(9,'摩卡拿铁',1,18.00,60,'/images/product/摩卡拿铁.jpg','巧克力与拿铁完美邂逅，甜蜜丝滑，能量补给站。',1),(10,'生椰拿铁',1,18.00,60,'/images/product/生椰拿铁.jpg','生榨椰乳与浓缩咖啡完美融合，丝滑醇厚，椰香浓郁。',1),(11,'燕麦拿铁',1,18.00,60,'/images/product/燕麦拿铁.jpg','燕麦奶与浓缩咖啡融合，植物清甜，乳糖不耐友好。',1),(12,'卡布奇诺',1,18.00,60,'/images/product/卡布奇诺.jpg','绵密奶泡配浓缩咖啡，经典意式风味，优雅唤醒清晨。',1),(13,'栗子燕麦卡布奇诺',1,20.00,60,'/images/product/栗子燕麦卡布奇诺.jpg','焦香咖啡遇上绵密栗泥，温润燕麦奶柔化苦感，一口暖到心底。',1),(14,'黑糖珍珠奶茶',2,16.00,45,'/images/product/黑糖珍珠奶茶.jpg','现熬黑糖与醇厚奶茶融合，珍珠软糯，甜润顺滑，学习间隙的小确幸。',1),(15,'芭乐椰椰',2,16.00,45,'/images/product/芭乐椰椰.jpg','芭乐果香融合清甜椰乳，热带风情满满，喝一口治愈自习疲惫。',1),(16,'芒果椰椰',2,16.00,45,'/images/product/芒果椰椰.jpg','香甜芒果遇上糯香椰乳，热带水果盛宴。',1),(17,'满杯橙鲜',2,10.00,45,'/images/product/满杯橙鲜.jpg','鲜榨橙汁搭配清爽茶底，VC爆棚，活力满满。',1),(18,'西柚气泡水',2,12.00,45,'/images/product/西柚气泡水.jpg','西柚酸甜+绵密气泡，酸甜激爽，低卡解暑。',1),(19,'泰绿柠檬茶',2,8.00,45,'/images/product/泰绿柠檬茶.jpg','泰式绿茶底加香水柠檬，酸甜爽口，仿佛置身泰国，地道泰式风味。',1),(20,'鸭屎香柠檬茶',2,8.00,45,'/images/product/鸭屎香柠檬茶.jpg','凤凰单枞鸭屎香茶底搭配柠檬，香气独特，回甘悠长。',1),(21,'波士玫瑰乌龙茶',2,12.00,45,'/images/product/波士玫瑰乌龙茶.jpg','玫瑰花香与乌龙茶底融合，浪漫芬芳，舒缓学习压力。',1),(22,'话梅菠萝冰',2,12.00,45,'/images/product/话梅菠萝冰.jpg','话梅咸甜搭配菠萝果肉，冰爽酸甜，夏日消暑神器。',1),(23,'青苹果奶绿',2,13.00,45,'/images/product/青苹果奶绿.jpg','青苹果清新酸甜融入奶绿，口感清爽，沁人心脾。',1),(24,'燕窝蓝莓酸奶',2,23.00,45,'/images/product/燕窝蓝莓酸奶.jpg','燕窝滋养+蓝莓果粒+浓稠酸奶，轻奢健康，自习能量饮。',1),(25,'杨枝甘露',2,15.00,45,'/images/product/杨枝甘露.jpg','芒果西柚椰奶经典搭配，酸甜清香，港式甜品风味。',1),(26,'芝芝可可',2,18.00,45,'/images/product/芝芝可可.jpg','芝士奶盖搭配浓郁可可，咸甜醇厚，为大脑充电。',1),(27,'可可牛乳',2,18.00,45,'/images/product/可可牛乳.jpg','纯可可粉与鲜牛乳融合，丝滑浓郁，暖胃暖心。',1),(28,'经典抹茶奶茶',2,16.00,45,'/images/product/经典抹茶奶茶.jpg','日式抹茶与香滑奶茶碰撞，微苦回甘，清新自然。',1),(29,'北海道海盐抹茶',2,16.00,45,'/images/product/北海道海盐抹茶.jpg','浓醇抹茶遇上温润鲜奶，海盐轻提风味，一口沁凉解腻。',1),(30,'开心果抹茶',2,22.00,45,'/images/product/开心果抹茶.jpg','浓醇抹茶搭配绵密开心果，温润奶底柔和茶苦，清新顺滑直抵心底。',1),(31,'茉莉抹茶',2,16.00,45,'/images/product/茉莉抹茶.jpg','鲜灵茉莉衬出抹茶本味，冰感顺滑入喉，清爽解腻无负担。',1),(32,'抹茶西瓜啵啵',2,16.00,45,'/images/product/抹茶西瓜啵啵.jpg','清爽西瓜汁打底，加入抹茶冻和脆啵啵，夏日果茶吸不停。',1),(33,'草莓抹茶鲜牛乳',2,18.00,45,'/images/product/草莓抹茶鲜牛乳.jpg','饱满草莓果香打底，醇厚奶层过渡，清冽抹茶收尾，一口解锁双倍清新。',1),(34,'草莓奶昔',2,14.00,45,'/images/product/草莓奶昔.jpg','鲜捣草莓果泥裹着醇厚鲜乳，果肉酸甜撞奶香，清爽软嫩甜而不腻。',1),(35,'蓝莓冰沙酸奶',2,8.00,45,'/images/product/蓝莓冰沙酸奶.jpg','整颗蓝莓与老酸奶打成冰沙，酸甜冰爽，清新解暑。',1),(36,'杨梅冰沙酸奶',2,8.00,45,'/images/product/杨梅冰沙酸奶.jpg','杨梅果肉搭配浓稠酸奶，冰沙质地，酸甜开胃，夏日消暑必备。',1),(37,'桑葚冰沙酸奶',2,8.00,45,'/images/product/桑葚冰沙酸奶.jpg','馥郁桑葚果香碰撞发酵酸奶，冰沙顺滑降温，酸甜平衡清爽不腻。',1),(38,'紫薯芋泥豆乳',2,18.00,45,'/images/product/紫薯芋泥豆乳.jpg','粉糯芋泥混着绵柔紫薯底色，豆乳鲜醇干净，自带淡淡谷物回甘。',1),(39,'奶油南瓜豆乳',2,18.00,45,'/images/product/奶油南瓜豆乳.jpg','细磨南瓜泥与温润豆乳相融，软滑细腻，暖感绵长舒服。',1),(40,'莓莓云朵可可芭菲',3,24.00,20,'/images/product/莓莓云朵可可芭菲.jpg','粉嫩草莓裹着浓醇可可，搭配酥脆谷物与精巧马卡龙，视觉与味觉的双重浪漫暴击。',1),(41,'抹茶巧脆云朵芭菲',3,24.00,20,'/images/product/抹茶巧脆云朵芭菲.jpg','抹茶糅合浓醇可可，脆谷增添层次，奶油轻顶绵柔，微苦中和甜腻，清爽治愈。',1),(42,'桃桃抹茶椰云芭菲',3,24.00,20,'/images/product/桃桃抹茶椰云芭菲.jpg','清新抹茶底搭配软嫩水蜜桃果肉，点缀脆香饼干与绵密椰蓉，果香混着茶感，清甜爽口不腻。',1),(43,'特浓可可云朵芭菲',3,24.00,20,'/images/product/特浓可可云朵芭菲.jpg','多层浓醇巧克力基底，夹满香脆坚果谷物，云顶奶油淋上可可酱，入口丝滑醇厚，浓甜不腻。',1),(44,'草莓抹茶瑞士卷',3,16.00,25,'/images/product/草莓抹茶瑞士卷.jpg','戚风裹入草莓奶油，茶香清雅与酸甜果香交织，治愈系甜品。',1),(45,'原味巴斯克',3,15.00,18,'/images/product/原味巴斯克.jpg','焦香外皮包裹绵密芝士芯，浓郁顺滑，芝士控的纯粹享受。',1),(46,'开心果芝士巴斯克',3,17.00,18,'/images/product/开心果芝士巴斯克.jpg','开心果坚果香融入巴斯克，独特咸甜风味，一口沦陷。',1),(47,'青柠芝士蛋糕',3,14.00,18,'/images/product/青柠芝士蛋糕.jpg','青柠清香化解芝士甜腻，轻盈爽口，自习间隙的小清新。',1),(48,'莓果芝士蛋糕',3,15.00,18,'/images/product/莓果芝士蛋糕.jpg','混合莓果果酱搭配醇厚芝士，酸甜平衡，颜值与美味并存。',1),(49,'芒果芝士蛋糕',3,15.00,18,'/images/product/芒果芝士蛋糕.jpg','热带芒果果泥与芝士融合，入口即化，夏日阳光滋味。',1),(50,'雪域牛乳芝士蛋糕',3,17.00,18,'/images/product/雪域牛乳芝士蛋糕.jpg','北海道牛乳冰凉质感，奶香浓郁，如雪域般纯净。',1),(51,'蓝莓芝士蛋糕',3,16.00,18,'/images/product/蓝莓芝士蛋糕.jpg','大粒蓝莓果粒与芝士层层叠叠，经典搭配，永不踩雷。',1),(52,'纽约芝士蛋糕',3,15.00,18,'/images/product/纽约芝士蛋糕.jpg','浓郁酸奶油芝士，扎实绵密，纽约街角情怀。',1),(53,'美式芝士蛋糕',3,15.00,18,'/images/product/美式芝士蛋糕.jpg','简朴醇厚，蛋香芝香完美平衡，美式经典风味。',1),(54,'半熟芝士',3,16.00,18,'/images/product/半熟芝士.jpg','轻盈半熟质感，入口即化，如云朵般轻柔，低卡无负担。',1),(55,'原味提拉米苏',3,18.00,18,'/images/product/原味提拉米苏.jpg','咖啡酒香与马斯卡彭缠绵，手指饼干湿润柔滑，意式浪漫。',1),(56,'蓝莓提拉米苏',3,19.00,18,'/images/product/蓝莓提拉米苏.jpg','蓝莓果酱替换咖啡，果香版提拉米苏，甜而不腻。',1),(57,'乳酪包',3,24.00,18,'/images/product/乳酪包.jpg','松软面包夹入浓郁乳酪馅，早餐或下午茶，能量满满。',1),(58,'西瓜芋圆西米露',3,13.00,18,'/images/product/西瓜芋圆西米露.jpg','椰奶为底，加入大块清甜西瓜，搭配Q弹芋圆与爽滑西米，椰香果香交织，消暑又满足。',1),(59,'芭乐芋圆西米露',3,13.00,18,'/images/product/芭乐芋圆西米露.jpg','芭乐果香与椰奶底碰撞，芋圆西米丰富口感，粉嫩讨喜。',1),(60,'芒果桂花奶羹',3,13.00,18,'/images/product/芒果桂花奶羹.jpg','芒果泥+桂花蜜+奶羹，花香果香奶香三重奏，冰爽丝滑。',1),(61,'芋泥椰奶大满贯',3,18.00,18,'/images/product/芋泥椰奶大满贯.jpg','手捣芋泥挂壁，注入香浓椰奶，加入芋圆、红豆、西米、芒果、西瓜、葡萄干、南瓜子仁、薏米、花生，十种配料大满贯，一碗吃出幸福感。',1),(62,'炸薯条',4,12.00,80,'/images/product/fries.jpg','金黄酥脆，配番茄酱',1),(63,'鸡米花',4,16.00,60,'/images/product/chicken_popcorn.jpg','外酥里嫩，小食首选',1),(64,'蔬菜沙拉',4,18.00,30,'/images/product/vege_salad.jpg','新鲜时蔬，低脂健康',1);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `revId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `resId` int NOT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  `status` int NOT NULL DEFAULT '1' COMMENT '1=预约成功,2=已取消,3=已违约,4=已完成',
  `createTime` datetime NOT NULL,
  `cancelTime` datetime DEFAULT NULL,
  `checkinTime` datetime DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`revId`),
  KEY `idx_userId` (`userId`),
  KEY `idx_resId_start_end` (`resId`,`startTime`,`endTime`),
  KEY `idx_status_start` (`status`,`startTime`),
  CONSTRAINT `fk_reservation_resource` FOREIGN KEY (`resId`) REFERENCES `resource` (`resId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reservation_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservation`
--

LOCK TABLES `reservation` WRITE;
/*!40000 ALTER TABLE `reservation` DISABLE KEYS */;
INSERT INTO `reservation` VALUES (1,13,10,'2026-04-29 10:00:00','2026-04-29 11:00:00',1,'2026-04-26 11:34:22',NULL,NULL,5.00),(2,2,23,'2026-04-30 22:00:00','2026-04-30 23:00:00',1,'2026-04-28 15:20:48',NULL,NULL,5.00),(3,13,22,'2026-05-03 16:00:00','2026-05-03 23:00:00',1,'2026-05-01 03:48:41',NULL,NULL,35.00),(4,1,37,'2026-05-02 11:00:00','2026-05-02 12:00:00',1,'2026-05-01 09:48:48',NULL,NULL,20.00),(5,9,25,'2026-04-30 10:00:00','2026-04-30 11:00:00',1,'2026-04-28 04:16:47',NULL,NULL,5.00),(6,2,3,'2026-04-27 09:00:00','2026-04-27 23:00:00',3,'2026-04-21 11:52:54',NULL,NULL,70.00),(7,13,36,'2026-05-03 19:00:00','2026-05-03 23:00:00',1,'2026-04-27 22:27:31',NULL,NULL,80.00),(8,4,24,'2026-04-29 09:00:00','2026-04-29 23:00:00',1,'2026-04-26 13:35:18',NULL,NULL,70.00),(9,10,30,'2026-05-01 09:00:00','2026-05-01 23:00:00',1,'2026-04-26 14:11:07',NULL,NULL,70.00),(10,1,35,'2026-04-30 18:00:00','2026-04-30 19:00:00',1,'2026-04-29 08:31:32',NULL,NULL,20.00),(11,2,35,'2026-04-29 06:00:00','2026-04-29 23:00:00',1,'2026-04-23 02:08:24',NULL,NULL,340.00),(12,8,27,'2026-05-02 22:00:00','2026-05-02 23:00:00',1,'2026-04-25 09:12:54',NULL,NULL,5.00),(13,13,37,'2026-04-27 16:00:00','2026-04-27 23:00:00',3,'2026-04-26 19:52:00',NULL,NULL,140.00),(14,6,1,'2026-05-03 11:00:00','2026-05-03 23:00:00',1,'2026-04-26 10:40:58',NULL,NULL,60.00),(15,12,13,'2026-04-27 13:00:00','2026-04-27 15:00:00',3,'2026-04-20 17:38:00',NULL,NULL,10.00),(16,2,26,'2026-04-27 07:00:00','2026-04-27 12:00:00',3,'2026-04-26 12:30:54',NULL,NULL,25.00),(17,1,21,'2026-04-30 08:00:00','2026-04-30 23:00:00',1,'2026-04-27 06:02:22',NULL,NULL,75.00),(18,11,33,'2026-05-03 06:00:00','2026-05-03 12:00:00',1,'2026-04-29 14:33:57',NULL,NULL,120.00),(19,2,28,'2026-04-29 15:00:00','2026-04-29 23:00:00',1,'2026-04-22 08:08:36',NULL,NULL,40.00),(20,8,7,'2026-04-27 20:00:00','2026-04-27 23:00:00',3,'2026-04-26 03:22:25',NULL,NULL,15.00),(21,1,28,'2026-05-01 07:00:00','2026-05-01 17:00:00',1,'2026-04-27 12:18:56',NULL,NULL,50.00),(22,11,8,'2026-05-01 13:00:00','2026-05-01 20:00:00',1,'2026-04-26 06:18:41',NULL,NULL,35.00),(23,7,23,'2026-04-30 11:00:00','2026-04-30 17:00:00',1,'2026-04-25 13:36:23',NULL,NULL,30.00),(24,2,22,'2026-04-29 10:00:00','2026-04-29 15:00:00',1,'2026-04-26 04:45:15',NULL,NULL,25.00),(25,13,5,'2026-05-01 20:00:00','2026-05-01 23:00:00',1,'2026-04-27 04:29:53',NULL,NULL,15.00),(26,13,8,'2026-04-27 17:00:00','2026-04-27 20:00:00',3,'2026-04-22 02:22:36',NULL,NULL,15.00),(27,12,28,'2026-04-27 19:00:00','2026-04-27 23:00:00',3,'2026-04-24 18:57:27',NULL,NULL,20.00),(28,5,20,'2026-04-11 22:00:00','2026-04-11 23:00:00',4,'2026-04-09 02:21:29',NULL,'2026-04-11 22:12:00',5.00),(29,8,28,'2026-04-01 08:00:00','2026-04-01 10:00:00',4,'2026-04-01 00:56:38',NULL,'2026-04-01 08:10:00',10.00),(30,12,11,'2026-04-01 11:00:00','2026-04-01 15:00:00',4,'2026-04-01 14:53:37',NULL,'2026-04-01 11:12:00',20.00),(31,3,32,'2026-04-07 16:00:00','2026-04-07 17:00:00',4,'2026-04-05 06:50:25',NULL,'2026-04-07 16:18:00',20.00),(32,10,32,'2026-04-24 20:00:00','2026-04-24 23:00:00',4,'2026-04-24 11:11:35',NULL,'2026-04-24 20:11:00',60.00),(33,2,12,'2026-04-16 18:00:00','2026-04-16 23:00:00',4,'2026-04-15 07:43:39',NULL,'2026-04-16 18:04:00',25.00),(34,11,20,'2026-04-19 17:00:00','2026-04-19 23:00:00',4,'2026-04-14 00:07:39',NULL,'2026-04-19 17:27:00',30.00),(35,8,8,'2026-04-21 13:00:00','2026-04-21 22:00:00',4,'2026-04-20 10:39:57',NULL,'2026-04-21 13:24:00',45.00),(36,3,16,'2026-04-10 15:00:00','2026-04-10 16:00:00',4,'2026-04-08 00:58:46',NULL,'2026-04-10 15:27:00',5.00),(37,4,26,'2026-04-08 06:00:00','2026-04-08 09:00:00',4,'2026-04-04 05:55:59',NULL,'2026-04-08 06:03:00',15.00),(38,9,36,'2026-04-03 22:00:00','2026-04-03 23:00:00',4,'2026-04-02 15:13:14',NULL,'2026-04-03 22:14:00',20.00),(39,10,10,'2026-04-25 13:00:00','2026-04-25 14:00:00',4,'2026-04-21 00:43:29',NULL,'2026-04-25 13:08:00',5.00),(40,13,36,'2026-03-31 15:00:00','2026-03-31 19:00:00',4,'2026-03-30 18:03:56',NULL,'2026-03-31 15:17:00',80.00),(41,1,21,'2026-04-08 12:00:00','2026-04-08 16:00:00',4,'2026-04-04 01:05:18',NULL,'2026-04-08 12:07:00',20.00),(42,5,30,'2026-04-23 08:00:00','2026-04-23 17:00:00',4,'2026-04-18 00:30:27',NULL,'2026-04-23 08:22:00',45.00),(43,5,21,'2026-04-05 20:00:00','2026-04-05 23:00:00',4,'2026-04-02 04:09:13',NULL,'2026-04-05 20:20:00',15.00),(44,10,23,'2026-04-02 10:00:00','2026-04-02 23:00:00',4,'2026-03-31 12:22:19',NULL,'2026-04-02 10:16:00',65.00),(45,9,29,'2026-04-03 17:00:00','2026-04-03 19:00:00',4,'2026-04-01 17:29:12',NULL,'2026-04-03 17:18:00',10.00),(46,6,10,'2026-03-28 09:00:00','2026-03-28 10:00:00',4,'2026-03-28 14:21:02',NULL,'2026-03-28 09:02:00',5.00),(47,5,14,'2026-04-02 06:00:00','2026-04-02 19:00:00',4,'2026-03-31 01:58:43',NULL,'2026-04-02 06:20:00',65.00),(48,3,37,'2026-04-15 20:00:00','2026-04-15 23:00:00',4,'2026-04-12 08:50:11',NULL,'2026-04-15 20:12:00',60.00),(49,7,11,'2026-03-29 19:00:00','2026-03-29 23:00:00',4,'2026-03-28 21:15:37',NULL,'2026-03-29 19:11:00',20.00),(50,1,35,'2026-04-08 10:00:00','2026-04-08 20:00:00',4,'2026-04-08 12:27:42',NULL,'2026-04-08 10:04:00',200.00),(51,9,35,'2026-04-08 09:00:00','2026-04-08 15:00:00',4,'2026-04-04 04:30:58',NULL,'2026-04-08 09:09:00',120.00),(52,10,23,'2026-04-01 13:00:00','2026-04-01 23:00:00',4,'2026-03-29 06:50:22',NULL,'2026-04-01 13:10:00',50.00),(53,9,4,'2026-04-08 18:00:00','2026-04-08 23:00:00',3,'2026-04-08 15:08:44',NULL,NULL,25.00),(54,4,5,'2026-04-02 17:00:00','2026-04-02 19:00:00',3,'2026-04-01 01:27:10',NULL,NULL,10.00),(55,7,34,'2026-04-26 12:00:00','2026-04-26 23:00:00',3,'2026-04-23 04:07:04',NULL,NULL,220.00),(56,13,21,'2026-03-30 22:00:00','2026-03-30 23:00:00',3,'2026-03-28 21:17:41',NULL,NULL,5.00),(57,8,37,'2026-04-25 11:00:00','2026-04-25 20:00:00',3,'2026-04-23 16:04:23',NULL,NULL,180.00),(58,10,13,'2026-04-07 08:00:00','2026-04-07 22:00:00',2,'2026-04-05 00:40:17','2026-04-06 17:28:58',NULL,70.00),(59,6,12,'2026-04-20 09:00:00','2026-04-20 16:00:00',2,'2026-04-19 22:05:36','2026-04-19 17:10:26',NULL,35.00),(60,9,3,'2026-04-18 10:00:00','2026-04-18 18:00:00',2,'2026-04-17 08:53:19','2026-04-17 17:46:00',NULL,40.00);
/*!40000 ALTER TABLE `reservation` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_reservation_update` BEFORE UPDATE ON `reservation` FOR EACH ROW BEGIN
    #如果状态从非取消变为取消，且当前时间已超过截止时间
    IF OLD.status != 2 AND NEW.status = 2 THEN
        IF can_cancel_reservation(OLD.revId) = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Cannot cancel: exceeded cancellation deadline (18:00 day before)';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_reservation_cancel` AFTER UPDATE ON `reservation` FOR EACH ROW BEGIN
    IF OLD.status != 2 AND NEW.status = 2 THEN
        CALL promote_waitlist_for_seat(NEW.resId);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `resource`
--

DROP TABLE IF EXISTS `resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resource` (
  `resId` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` int NOT NULL COMMENT '1=会议室,2=自习工位',
  `location` varchar(100) DEFAULT NULL,
  `hasSocket` tinyint(1) DEFAULT '0',
  `hasLamp` tinyint(1) DEFAULT '0',
  `hasBaffle` tinyint(1) DEFAULT '0',
  `byWindow` tinyint(1) DEFAULT '0',
  `capacity` int DEFAULT NULL,
  `state` int NOT NULL DEFAULT '1' COMMENT '1=可预约,2=维护中,0=禁用',
  PRIMARY KEY (`resId`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource`
--

LOCK TABLES `resource` WRITE;
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
INSERT INTO `resource` VALUES (1,'A01',1,'靠窗区',1,1,0,1,NULL,1),(2,'A02',1,'靠窗区',1,1,0,1,NULL,1),(3,'A03',1,'靠窗区',0,1,0,1,NULL,2),(4,'A04',1,'靠窗区',1,0,0,1,NULL,1),(5,'A05',1,'靠窗区',1,1,1,1,NULL,1),(6,'A06',1,'靠窗区',0,0,0,1,NULL,1),(7,'A07',1,'靠窗区',1,1,0,1,NULL,1),(8,'A08',1,'靠窗区',1,1,0,1,NULL,1),(9,'A09',1,'靠窗区',0,1,0,1,NULL,1),(10,'A10',1,'靠窗区',1,0,0,1,NULL,1),(11,'A11',1,'靠窗区',1,1,0,1,NULL,1),(12,'A12',1,'靠窗区',1,1,1,1,NULL,1),(13,'B01',1,'静音区',1,1,1,0,NULL,1),(14,'B02',1,'静音区',1,0,1,0,NULL,1),(15,'B03',1,'静音区',0,1,1,0,NULL,2),(16,'B04',1,'静音区',1,1,1,0,NULL,1),(17,'B05',1,'静音区',1,1,0,0,NULL,1),(18,'B06',1,'静音区',0,0,1,0,NULL,1),(19,'B07',1,'静音区',1,1,1,0,NULL,1),(20,'B08',1,'静音区',1,1,1,0,NULL,1),(21,'B09',1,'静音区',0,1,1,0,NULL,1),(22,'C01',1,'吧台区',1,0,0,0,NULL,1),(23,'C02',1,'吧台区',1,0,0,0,NULL,1),(24,'C03',1,'吧台区',0,0,0,0,NULL,2),(25,'C04',1,'吧台区',1,0,0,0,NULL,1),(26,'C05',1,'吧台区',1,0,0,0,NULL,1),(27,'C06',1,'吧台区',0,0,0,0,NULL,1),(28,'C07',1,'吧台区',1,0,0,0,NULL,1),(29,'C08',1,'吧台区',1,0,0,0,NULL,1),(30,'C09',1,'吧台区',1,0,0,0,NULL,1),(31,'C10',1,'吧台区',0,0,0,0,NULL,1),(32,'M01',2,'主楼会议室',1,1,0,1,6,1),(33,'M02',2,'主楼会议室',1,1,0,0,8,1),(34,'M03',2,'东区研讨室',1,1,1,1,4,2),(35,'M04',2,'东区研讨室',1,0,1,0,4,1),(36,'M05',2,'西区会议室',1,1,0,1,10,1),(37,'M06',2,'西区会议室',1,1,0,0,12,1),(38,'M07',2,'北区研讨室',1,1,1,1,6,1);
/*!40000 ALTER TABLE `resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `account` varchar(20) NOT NULL,
  `password` varchar(20) NOT NULL,
  `realName` varchar(20) NOT NULL,
  `userType` int NOT NULL COMMENT '1=普通用户,2=管理员',
  `phone` varchar(11) NOT NULL,
  `state` int NOT NULL DEFAULT '1' COMMENT '1=正常,0=禁用',
  PRIMARY KEY (`userId`),
  UNIQUE KEY `uk_account` (`account`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'zjw111','111111','张吉惟',1,'18843917510',1),(2,'lgr222','222222','林国瑞',1,'18155842438',1),(3,'lyn333','333333','林雅南',1,'13059227174',1),(4,'lyy444','444444','江奕云',1,'13250200789',1),(5,'lbh555','555555','刘柏宏',1,'15607535708',1),(6,'lzf666','666666','林子帆',1,'18789891667',1),(7,'xzh777','777777','夏志豪',1,'15707468066',1),(8,'xyw888','888888','谢彦文',1,'19808914548',1),(9,'wbz999','999999','王宝珠',1,'19808992549',1),(10,'czy101','101010','陈祯月',1,'15879493514',1),(11,'cmy111','110110','曹敏侑',1,'18613826664',1),(12,'fzy121','121212','方兆玉',1,'13357535368',1),(13,'kqx131','131313','柯乔喜',1,'15534416749',1),(14,'gft141','141414','郭芳天',2,'15289804753',1),(15,'wyr151','151515','王亦柔',2,'16668604671',1),(16,'lws161','161616','林玟书',2,'15321621910',1),(17,'rja171','171717','阮建安',2,'15389750656',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `violation`
--

DROP TABLE IF EXISTS `violation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `violation` (
  `vioId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `revId` int NOT NULL,
  `violateTime` datetime NOT NULL,
  `reason` varchar(200) NOT NULL,
  `handleStatus` int NOT NULL DEFAULT '1' COMMENT '1=未处理,2=已处理',
  PRIMARY KEY (`vioId`),
  UNIQUE KEY `uk_revId` (`revId`),
  KEY `idx_users_handle` (`userId`,`handleStatus`),
  CONSTRAINT `fk_violation_reservation` FOREIGN KEY (`revId`) REFERENCES `reservation` (`revId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_violation_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `violation`
--

LOCK TABLES `violation` WRITE;
/*!40000 ALTER TABLE `violation` DISABLE KEYS */;
INSERT INTO `violation` VALUES (98,9,53,'2026-04-08 18:30:00','预约开始后30分钟内未打卡',1),(99,4,54,'2026-04-02 17:30:00','预约开始后30分钟内未打卡',1),(100,7,55,'2026-04-26 12:30:00','预约开始后30分钟内未打卡',1),(101,13,56,'2026-03-30 22:30:00','预约开始后30分钟内未打卡',1),(102,8,57,'2026-04-25 11:30:00','预约开始后30分钟内未打卡',1),(103,2,16,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1),(104,2,6,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1),(105,12,15,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1),(106,13,13,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1),(107,13,26,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1),(108,12,27,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1),(109,8,20,'2026-04-27 22:10:29','预约开始后半小时内未打卡',1);
/*!40000 ALTER TABLE `violation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitlist`
--

DROP TABLE IF EXISTS `waitlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitlist` (
  `waitId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `resId` int NOT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  `createTime` datetime NOT NULL,
  `cancelTime` datetime DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1' COMMENT '1=等待中,2=已转正,3=已取消,4=未成功',
  `revId` int DEFAULT NULL,
  PRIMARY KEY (`waitId`),
  KEY `idx_userId` (`userId`),
  KEY `idx_res_start_status` (`resId`,`startTime`,`status`),
  KEY `fk_waitlist_reservation` (`revId`),
  CONSTRAINT `fk_waitlist_reservation` FOREIGN KEY (`revId`) REFERENCES `reservation` (`revId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_waitlist_resource` FOREIGN KEY (`resId`) REFERENCES `resource` (`resId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_waitlist_users` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitlist`
--

LOCK TABLES `waitlist` WRITE;
/*!40000 ALTER TABLE `waitlist` DISABLE KEYS */;
INSERT INTO `waitlist` VALUES (1,10,23,'2026-05-02 10:00:00','2026-05-02 23:00:00','2026-04-07 17:39:04',NULL,1,NULL),(2,6,29,'2026-05-01 18:00:00','2026-05-01 23:00:00','2026-04-07 02:24:45',NULL,1,NULL),(3,8,21,'2026-04-27 21:00:00','2026-04-27 23:00:00','2026-03-30 07:46:54',NULL,1,NULL),(4,4,21,'2026-05-03 07:00:00','2026-05-03 20:00:00','2026-04-20 01:34:41',NULL,1,NULL),(5,10,25,'2026-04-27 15:00:00','2026-04-27 23:00:00','2026-04-08 19:10:24',NULL,1,NULL),(6,7,10,'2026-05-02 09:00:00','2026-05-02 23:00:00','2026-04-23 10:40:06','2026-05-01 17:13:36',3,NULL),(7,5,35,'2026-05-01 07:00:00','2026-05-01 20:00:00','2026-04-13 04:32:04','2026-04-30 17:43:13',3,NULL),(8,13,7,'2026-05-03 11:00:00','2026-05-03 23:00:00','2026-04-01 00:25:06',NULL,4,NULL),(9,4,4,'2026-05-01 16:00:00','2026-05-01 23:00:00','2026-04-16 12:25:36',NULL,4,NULL),(10,10,31,'2026-05-03 13:00:00','2026-05-03 16:00:00','2026-04-14 18:31:17',NULL,4,NULL);
/*!40000 ALTER TABLE `waitlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'study_room_reservation'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `evt_cancel_unpaid_orders` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `evt_cancel_unpaid_orders` ON SCHEDULE EVERY 5 MINUTE STARTS '2026-04-21 23:18:46' ON COMPLETION NOT PRESERVE ENABLE DO CALL cancel_unpaid_orders() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `evt_complete_reservations` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `evt_complete_reservations` ON SCHEDULE EVERY 15 MINUTE STARTS '2026-04-22 03:03:08' ON COMPLETION NOT PRESERVE ENABLE DO CALL complete_expired_reservations() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `evt_detect_violation` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `evt_detect_violation` ON SCHEDULE EVERY 10 MINUTE STARTS '2026-04-22 03:00:29' ON COMPLETION NOT PRESERVE ENABLE DO CALL detect_violation() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `evt_mark_failed_waitlist` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `evt_mark_failed_waitlist` ON SCHEDULE EVERY 1 DAY STARTS '2026-04-25 18:30:00' ON COMPLETION NOT PRESERVE ENABLE DO CALL mark_failed_waitlist() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'study_room_reservation'
--
/*!50003 DROP FUNCTION IF EXISTS `amount_calculate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `amount_calculate`(p_resId INT, p_start DATETIME, p_end DATETIME) RETURNS decimal(10,2)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `can_cancel_reservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `can_cancel_reservation`(p_revId INT) RETURNS int
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_unpaid_orders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_unpaid_orders`()
BEGIN
  UPDATE foodorder 
  SET status = 5, cancelTime = NOW()
  WHERE status = 1 
    AND createTime < DATE_SUB(NOW(), INTERVAL 15 MINUTE);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `complete_expired_reservations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `complete_expired_reservations`()
BEGIN
  UPDATE reservation 
  SET status = 4 
  WHERE status = 1 
    AND endTime < NOW() 
    AND checkinTime IS NOT NULL; #已打卡才正常完成，未打卡的已被违约处理
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `detect_violation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `detect_violation`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_foodorders_from_reservations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_foodorders_from_reservations`(
    IN p_order_count INT,           -- 想要生成的订单数量
    IN p_start_date DATE,           -- 预约起始日期
    IN p_end_date DATE              -- 预约结束日期
)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_sample_foodorders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_sample_foodorders`(IN p_base_date DATE)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_sample_reservations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_sample_reservations`(IN p_base_date DATE)
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
        -- 随机座位（1~37）
        SET v_resId = ELT(1 + FLOOR(RAND() * 37), 
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38);

        -- 状态分布
        IF i <= 27 THEN
            SET v_status = 1;      -- 预约成功（未来）
        ELSEIF i <= 52 THEN
            SET v_status = 4;      -- 已完成（过去）
        ELSEIF i <= 57 THEN
            SET v_status = 3;      -- 违约（过去）
        ELSE
            SET v_status = 2;      -- 取消（过去或未来均可）
        END IF;

        -- 生成开始时间和结束时间（整点）
        IF v_status = 1 THEN
            SET v_startDate = DATE_ADD(p_base_date, INTERVAL FLOOR(RAND() * 7) DAY);
            SET v_startHour = 6 + FLOOR(RAND() * 17);
            SET v_duration = 1 + FLOOR(RAND() * 17);
            IF v_startHour + v_duration > 23 THEN
                SET v_duration = 23 - v_startHour;
            END IF;
        ELSE
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

        -- ===================== 修正 createTime 逻辑 =====================
        IF v_status = 1 THEN
            -- 预约成功（未来）：创建时间在 startTime 之前的 1~7 天内，且不早于 p_base_date 之前30天
            SET v_createTime = DATE_SUB(v_startTime, INTERVAL (1 + FLOOR(RAND() * 7)) DAY);
            -- 确保创建时间不早于基准日期前30天（以防万一，但一般不会）
            IF v_createTime < DATE_SUB(p_base_date, INTERVAL 30 DAY) THEN
                SET v_createTime = DATE_SUB(p_base_date, INTERVAL 30 DAY);
                SET v_createTime = CONCAT(CAST(v_createTime AS DATE), ' 00:00:00');
            END IF;
        ELSE
            -- 过去记录（已完成/违约/取消）：创建时间在 startTime 之前的 0~5 天内
            SET v_createTime = DATE_SUB(v_startTime, INTERVAL FLOOR(RAND() * 6) DAY);
            -- 同时不能早于基准日期前30天
            IF v_createTime < DATE_SUB(p_base_date, INTERVAL 30 DAY) THEN
                SET v_createTime = DATE_SUB(p_base_date, INTERVAL 30 DAY);
                SET v_createTime = CONCAT(CAST(v_createTime AS DATE), ' 00:00:00');
            END IF;
        END IF;

        -- 随机添加时间部分（时分秒）
        SET v_createTime = CONCAT(CAST(v_createTime AS DATE), ' ',
            LPAD(FLOOR(RAND() * 24), 2, '0'), ':',
            LPAD(FLOOR(RAND() * 60), 2, '0'), ':',
            LPAD(FLOOR(RAND() * 60), 2, '0'));

        -- 取消时间和打卡时间
        SET v_cancelTime = NULL;
        SET v_checkinTime = NULL;

        IF v_status = 2 THEN
            -- 已取消：取消时间为开始日期前一天 17:xx
            SET v_cancelTime = DATE_SUB(DATE(v_startTime), INTERVAL 1 DAY);
            SET v_cancelTime = CONCAT(CAST(v_cancelTime AS DATE), ' ',
                LPAD(17 + FLOOR(RAND() * 1), 2, '0'), ':',
                LPAD(FLOOR(RAND() * 60), 2, '0'), ':',
                LPAD(FLOOR(RAND() * 60), 2, '0'));
        END IF;

        IF v_status = 4 THEN
            -- 已完成：打卡时间为开始时间后 0~29 分钟
            SET v_checkinTime = DATE_ADD(v_startTime, INTERVAL FLOOR(RAND() * 30) MINUTE);
        END IF;

        -- 计算费用
        SET v_amount = amount_calculate(v_resId, v_startTime, v_endTime);

        -- 插入预约记录
        INSERT INTO reservation (
            userId, resId, startTime, endTime, status,
            createTime, cancelTime, checkinTime, amount
        ) VALUES (
            v_userId, v_resId, v_startTime, v_endTime, v_status,
            v_createTime, v_cancelTime, v_checkinTime, v_amount
        );

        SET v_new_revId = LAST_INSERT_ID();

        -- 如果状态是违约，插入违约记录
        IF v_status = 3 THEN
            INSERT INTO violation (userId, revId, violateTime, reason, handleStatus)
            VALUES (v_userId, v_new_revId, DATE_ADD(v_startTime, INTERVAL 30 MINUTE), '预约开始后30分钟内未打卡', 1);
        END IF;

        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_sample_waitlist` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_sample_waitlist`(IN p_base_date DATE)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mark_failed_waitlist` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mark_failed_waitlist`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `promote_waitlist_for_seat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `promote_waitlist_for_seat`(IN p_resId INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-27 22:37:37
