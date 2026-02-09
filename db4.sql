CREATE DATABASE  IF NOT EXISTS `crm` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `crm`;
-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: crm
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointment_categorized_reports`
--

DROP TABLE IF EXISTS `appointment_categorized_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_categorized_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `report_type` enum('pathology','cardiology','sonography','mer','mtrf','radiology','other') NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_appointment_report` (`appointment_id`,`report_type`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `appointment_categorized_reports_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_categorized_reports_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_categorized_reports`
--

LOCK TABLES `appointment_categorized_reports` WRITE;
/*!40000 ALTER TABLE `appointment_categorized_reports` DISABLE KEYS */;
INSERT INTO `appointment_categorized_reports` VALUES (1,1,'pathology','uploads/appointment_reports/1769670923392-403261554.png','qrcode_lh3.googleusercontent.com.png',8218,21,'2026-01-29 07:15:23',1),(2,1,'pathology','uploads/appointment_reports/1769748294177-692951508.pdf','post_wise_report (5).pdf',75540,21,'2026-01-30 04:44:54',0);
/*!40000 ALTER TABLE `appointment_categorized_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_customer_images`
--

DROP TABLE IF EXISTS `appointment_customer_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_customer_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `image_label` varchar(100) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `uploaded_by` int NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_appointment_image` (`appointment_id`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `appointment_customer_images_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_customer_images_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_customer_images`
--

LOCK TABLES `appointment_customer_images` WRITE;
/*!40000 ALTER TABLE `appointment_customer_images` DISABLE KEYS */;
INSERT INTO `appointment_customer_images` VALUES (1,1,'Standing Photo','uploads/appointment_customer_images/1768992156611-244182249.jpg','scaled_Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-21 10:42:36',0),(2,4,'Standing Photo','uploads/appointment_customer_images/1768993750335-5872728.jpg','scaled_Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-21 11:09:10',0),(3,2,'Standing Photo','uploads/appointment_customer_images/1768993970619-828629059.jpg','scaled_Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-21 11:12:50',0),(4,5,'Weight Photo','uploads/appointment_customer_images/1769580961832-648690103.jpg','scaled_56c9c74f-b5fd-433f-914e-771404218fae1704755817678020357.jpg',9,'2026-01-28 06:16:01',0),(5,6,'Standing Photo','uploads/appointment_customer_images/appointment_6/user_17/1769664527878-467731864.png','qrcode_lh3.googleusercontent.com.png',17,'2026-01-29 05:28:47',0);
/*!40000 ALTER TABLE `appointment_customer_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_documents`
--

DROP TABLE IF EXISTS `appointment_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `doc_type` varchar(55) NOT NULL,
  `doc_number` varchar(50) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `uploaded_by` int NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_appointment_doc` (`appointment_id`,`doc_type`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `appointment_documents_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_documents`
--

LOCK TABLES `appointment_documents` WRITE;
/*!40000 ALTER TABLE `appointment_documents` DISABLE KEYS */;
INSERT INTO `appointment_documents` VALUES (1,1,'aadhaar','12345678','uploads/appointment_documents/1768992156593-942984461.jpg','Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-21 10:42:36',0),(2,4,'aadhaar','1234567890','uploads/appointment_documents/1768993750321-234555000.jpg','Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-21 11:09:10',0),(3,2,'aadhaar','hshsh','uploads/appointment_documents/1768993970614-559967720.jpg','Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-21 11:12:50',0),(4,5,'aadhaar','1234567890','uploads/appointment_documents/1769580961821-235963170.jpg','Screenshot_2025-08-08-18-16-29-831_com.miui.home.jpg',9,'2026-01-28 06:16:01',0),(5,6,'aadhaar','1234567890','uploads/appointment_documents/appointment_6/user_17/1769664527335-854232790.png','qrcode_lh3.googleusercontent.com.png',17,'2026-01-29 05:28:47',0);
/*!40000 ALTER TABLE `appointment_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_medical_files`
--

DROP TABLE IF EXISTS `appointment_medical_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_medical_files` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_medical_files_appointment` (`appointment_id`),
  CONSTRAINT `fk_medical_files_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_medical_files`
--

LOCK TABLES `appointment_medical_files` WRITE;
/*!40000 ALTER TABLE `appointment_medical_files` DISABLE KEYS */;
INSERT INTO `appointment_medical_files` VALUES (1,1,'uploads/appointment_medical/1769066144208-790277223.jpg','1769066144208-790277223.jpg',NULL,9,'2026-01-22 07:15:44',0),(2,1,'uploads/appointment_medical/1769067252821-553172985.jpg','1769067252821-553172985.jpg',NULL,9,'2026-01-22 07:34:12',0),(3,5,'uploads/appointment_medical/1769581007092-496933805.jpg','1769581007092-496933805.jpg',NULL,9,'2026-01-28 06:16:47',0);
/*!40000 ALTER TABLE `appointment_medical_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_pushback_history`
--

DROP TABLE IF EXISTS `appointment_pushback_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_pushback_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `pushed_back_by` int NOT NULL,
  `remarks` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `pushed_back_by` (`pushed_back_by`),
  CONSTRAINT `appointment_pushback_history_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `appointment_pushback_history_ibfk_2` FOREIGN KEY (`pushed_back_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_pushback_history`
--

LOCK TABLES `appointment_pushback_history` WRITE;
/*!40000 ALTER TABLE `appointment_pushback_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `appointment_pushback_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_qc`
--

DROP TABLE IF EXISTS `appointment_qc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_qc` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `qc_status` enum('Pending','In_Progress','Completed','Partial') DEFAULT 'Pending',
  `all_tests_available` tinyint(1) DEFAULT '0',
  `missing_tests` text,
  `qc_completed_by` int DEFAULT NULL,
  `qc_completed_at` timestamp NULL DEFAULT NULL,
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_qc`
--

LOCK TABLES `appointment_qc` WRITE;
/*!40000 ALTER TABLE `appointment_qc` DISABLE KEYS */;
/*!40000 ALTER TABLE `appointment_qc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_qc_history`
--

DROP TABLE IF EXISTS `appointment_qc_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_qc_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `action` enum('verified','pushed_back','completed','partial_save','submitted_for_qc','report_uploaded','report_deleted') DEFAULT NULL,
  `pathology_checked` tinyint(1) DEFAULT '0',
  `cardiology_checked` tinyint(1) DEFAULT '0',
  `sonography_checked` tinyint(1) DEFAULT '0',
  `mer_checked` tinyint(1) DEFAULT '0',
  `mtrf_checked` tinyint(1) DEFAULT '0',
  `radiology_checked` tinyint(1) DEFAULT '0',
  `other_checked` tinyint(1) DEFAULT '0',
  `remarks` text,
  `qc_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_appointment_qc` (`appointment_id`),
  KEY `qc_by` (`qc_by`),
  CONSTRAINT `appointment_qc_history_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_qc_history_ibfk_2` FOREIGN KEY (`qc_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_qc_history`
--

LOCK TABLES `appointment_qc_history` WRITE;
/*!40000 ALTER TABLE `appointment_qc_history` DISABLE KEYS */;
INSERT INTO `appointment_qc_history` VALUES (1,1,'submitted_for_qc',0,0,0,0,0,0,0,'Reports submitted for QC',21,'2026-01-29 07:15:28'),(2,1,'submitted_for_qc',0,0,0,0,0,0,0,'Reports submitted for QC',21,'2026-01-30 04:45:16'),(3,1,'submitted_for_qc',0,0,0,0,0,0,0,'Reports submitted for QC',21,'2026-01-30 04:45:35'),(4,1,'submitted_for_qc',0,0,0,0,0,0,0,'Reports submitted for QC',21,'2026-01-30 04:49:51'),(5,1,'submitted_for_qc',0,0,0,0,0,0,0,'Reports submitted for QC',21,'2026-01-30 04:58:13'),(6,1,'partial_save',1,0,0,1,0,0,0,NULL,17,'2026-01-30 04:59:02'),(7,1,'partial_save',1,0,0,1,0,1,0,NULL,21,'2026-01-30 04:59:29'),(8,1,'completed',1,1,0,1,1,1,1,NULL,21,'2026-01-30 05:00:53');
/*!40000 ALTER TABLE `appointment_qc_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_reports`
--

DROP TABLE IF EXISTS `appointment_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `appointment_reports_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_reports_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_reports`
--

LOCK TABLES `appointment_reports` WRITE;
/*!40000 ALTER TABLE `appointment_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `appointment_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_status_history`
--

DROP TABLE IF EXISTS `appointment_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `old_status` varchar(45) DEFAULT NULL,
  `new_status` varchar(45) DEFAULT NULL,
  `old_medical_status` varchar(45) DEFAULT NULL,
  `new_medical_status` varchar(45) DEFAULT NULL,
  `changed_by` int NOT NULL,
  `change_type` varchar(50) DEFAULT NULL,
  `remarks` text,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `changed_by` (`changed_by`),
  KEY `idx_appointment` (`appointment_id`),
  KEY `idx_change_type` (`change_type`),
  KEY `idx_status_history_appointment` (`appointment_id`,`id` DESC),
  CONSTRAINT `appointment_status_history_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `appointment_status_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_status_history`
--

LOCK TABLES `appointment_status_history` WRITE;
/*!40000 ALTER TABLE `appointment_status_history` DISABLE KEYS */;
INSERT INTO `appointment_status_history` VALUES (1,1,NULL,NULL,NULL,'scheduled',21,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-23\", \"confirmed_time\": \"09:00:00\"}','2026-01-21 10:38:06'),(2,1,'pending','checked_in','scheduled','arrived',9,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-21 10:42:36'),(3,1,'checked_in','medical_in_process','arrived','in_process',9,'medical_status_update',NULL,'{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": null, \"pending_report_types\": null}','2026-01-21 10:42:53'),(4,1,'medical_in_process','medical_partially_completed','in_process','partially_completed',9,'medical_status_update','chrck','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"chrck\", \"pending_report_types\": \"pathology,cardiology\"}','2026-01-21 10:59:07'),(5,1,'medical_partially_completed','medical_partially_completed','partially_completed','partially_completed',9,'medical_status_update','chrck','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"chrck\", \"pending_report_types\": \"pathology,cardiology\"}','2026-01-21 10:59:12'),(6,1,'medical_partially_completed','medical_partially_completed','partially_completed','partially_completed',9,'medical_status_update','chrck','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"chrck\", \"pending_report_types\": \"pathology,cardiology\"}','2026-01-21 10:59:13'),(7,2,NULL,NULL,NULL,'scheduled',21,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-22\", \"confirmed_time\": \"00:00:00\"}','2026-01-21 11:07:10'),(8,3,NULL,NULL,NULL,'scheduled',21,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-21\", \"confirmed_time\": \"08:00:00\"}','2026-01-21 11:07:17'),(9,4,NULL,NULL,NULL,'scheduled',21,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-24\", \"confirmed_time\": \"06:00:00\"}','2026-01-21 11:07:26'),(10,4,'pending','checked_in','scheduled','arrived',9,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-21 11:09:10'),(11,4,'checked_in','medical_in_process','arrived','in_process',9,'medical_status_update',NULL,'{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": null, \"pending_report_types\": null}','2026-01-21 11:09:16'),(12,4,'medical_in_process','medical_partially_completed','in_process','partially_completed',9,'medical_status_update','ok','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"ok\", \"pending_report_types\": \"pathology,mer\"}','2026-01-21 11:09:29'),(13,2,'pending','checked_in','scheduled','arrived',9,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-21 11:12:50'),(14,2,'checked_in','medical_in_process','arrived','in_process',9,'medical_status_update',NULL,'{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": null, \"pending_report_types\": null}','2026-01-21 11:12:55'),(15,2,'medical_in_process','medical_partially_completed','in_process','partially_completed',9,'medical_status_update','ok','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"ok\", \"pending_report_types\": \"pathology,cardiology\"}','2026-01-21 11:14:01'),(16,4,'medical_partially_completed','medical_completed','partially_completed','completed',9,'medical_status_update','ok','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"ok\", \"pending_report_types\": null}','2026-01-22 05:11:50'),(17,3,NULL,NULL,'scheduled','rescheduled',17,'schedule_reschedule','Appointment rescheduled','{\"new_confirmed_date\": \"2026-01-22\", \"new_confirmed_time\": \"16:00:00\", \"previous_confirmed_date\": \"2026-01-20T18:30:00.000Z\", \"previous_confirmed_time\": \"08:00:00\"}','2026-01-22 06:59:38'),(18,4,'medical_completed','medical_completed','completed','rescheduled',17,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-22 11:56:59'),(19,1,'medical_partially_completed','medical_completed','partially_completed','completed',17,'medical_status_update','test check','{\"medical_remarks\": \"test check\", \"pending_report_types\": null}','2026-01-22 11:56:59'),(20,3,NULL,NULL,'rescheduled','rescheduled',17,'schedule_reschedule','Appointment rescheduled','{\"new_confirmed_date\": \"2026-01-27\", \"new_confirmed_time\": \"11:00:00\", \"previous_confirmed_date\": \"2026-01-21T18:30:00.000Z\", \"previous_confirmed_time\": \"16:00:00\"}','2026-01-27 07:06:08'),(21,5,NULL,NULL,NULL,'scheduled',17,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-29\", \"confirmed_time\": \"09:00:00\"}','2026-01-27 12:57:22'),(22,6,NULL,NULL,NULL,NULL,21,'schedule_confirm','Center side confirmed','{\"side\": \"center\", \"confirmed_date\": \"2026-01-29\", \"confirmed_time\": \"09:00:00\"}','2026-01-27 12:59:55'),(23,6,NULL,NULL,NULL,NULL,14,'schedule_confirm','Home side confirmed','{\"side\": \"technician\", \"confirmed_date\": \"2026-01-29\", \"confirmed_time\": \"09:00:00\"}','2026-01-27 13:00:24'),(24,5,'pending','checked_in','scheduled','arrived',9,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-28 06:16:02'),(25,5,'checked_in','medical_in_process','arrived','in_process',9,'medical_status_update',NULL,'{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": null, \"pending_report_types\": null}','2026-01-28 06:16:08'),(26,5,'medical_in_process','medical_partially_completed','in_process','partially_completed',9,'medical_status_update','ok','{\"pan_number\": null, \"aadhaar_number\": null, \"medical_remarks\": \"ok\", \"pending_report_types\": \"pathology\"}','2026-01-28 06:16:24'),(27,5,'medical_partially_completed','medical_completed','partially_completed','completed',17,'medical_status_update','complete','{\"medical_remarks\": \"complete\", \"pending_report_types\": null}','2026-01-28 06:17:06'),(28,10,NULL,NULL,NULL,'scheduled',17,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-29\", \"confirmed_time\": \"12:00:00\"}','2026-01-29 05:27:09'),(29,6,'pending','checked_in','scheduled','arrived',17,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-29 05:28:47'),(30,6,'checked_in','medical_in_process','checked_in','in_process',21,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-29 07:14:12'),(31,6,'medical_in_process','medical_partially_completed','medical_in_process','completed',17,'medical_status_update','ok','{\"medical_remarks\": \"ok\", \"pending_report_types\": null}','2026-01-29 07:14:48'),(32,1,'medical_completed','qc_pending','completed','completed',21,'qc_submit','Reports submitted for QC','{\"qc_status\": \"pending\", \"preserved_checkboxes\": {\"mer\": 0, \"mtrf\": 0, \"other\": 0, \"pathology\": 0, \"radiology\": 0, \"cardiology\": 0}}','2026-01-29 07:15:28'),(33,1,'qc_pending','qc_pending','completed','completed',21,'qc_submit','Reports submitted for QC','{\"qc_status\": \"pending\", \"preserved_checkboxes\": {\"mer\": 0, \"mtrf\": 0, \"other\": 0, \"pathology\": 0, \"radiology\": 0, \"cardiology\": 0}}','2026-01-30 04:45:16'),(34,1,'qc_pending','qc_pending','completed','completed',21,'qc_submit','Reports submitted for QC','{\"qc_status\": \"pending\", \"preserved_checkboxes\": {\"mer\": 0, \"mtrf\": 0, \"other\": 0, \"pathology\": 0, \"radiology\": 0, \"cardiology\": 0}}','2026-01-30 04:45:35'),(35,1,'qc_pending','qc_pending','completed','completed',21,'qc_submit','Reports submitted for QC','{\"qc_status\": \"pending\", \"preserved_checkboxes\": {\"mer\": 0, \"mtrf\": 0, \"other\": 0, \"pathology\": 0, \"radiology\": 0, \"cardiology\": 0}}','2026-01-30 04:49:51'),(36,1,'qc_pending','qc_pending','completed','completed',21,'qc_submit','Reports submitted for QC','{\"qc_status\": \"pending\", \"preserved_checkboxes\": {\"mer\": 0, \"mtrf\": 0, \"other\": 0, \"pathology\": 0, \"radiology\": 0, \"cardiology\": 0}}','2026-01-30 04:58:13'),(37,1,'qc_pending','qc_pending','completed','completed',17,'qc_partial_save',NULL,'{\"qc_status\": \"in_process\", \"checkboxes\": {\"mer\": true, \"mtrf\": false, \"other\": false, \"pathology\": true, \"radiology\": false, \"cardiology\": false}}','2026-01-30 04:59:02'),(38,1,'qc_pending','qc_pending','completed','completed',21,'qc_partial_save',NULL,'{\"qc_status\": \"in_process\", \"checkboxes\": {\"mer\": true, \"mtrf\": false, \"other\": false, \"pathology\": true, \"radiology\": true, \"cardiology\": false}}','2026-01-30 04:59:29'),(39,1,'qc_pending','completed','completed','completed',21,'qc_complete',NULL,'{\"qc_status\": \"completed\", \"checkboxes\": {\"mer\": true, \"mtrf\": true, \"other\": true, \"pathology\": true, \"radiology\": true, \"cardiology\": true}}','2026-01-30 05:00:53'),(40,7,NULL,NULL,NULL,NULL,14,'schedule_confirm','Center side confirmed','{\"side\": \"center\", \"confirmed_date\": \"2026-01-31\", \"confirmed_time\": \"10:00:00\"}','2026-01-30 07:36:22'),(41,9,NULL,NULL,NULL,'scheduled',21,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-31\", \"confirmed_time\": \"09:00:00\"}','2026-01-30 07:38:28'),(42,8,NULL,NULL,NULL,'scheduled',21,'schedule_confirm','Appointment schedule confirmed','{\"side\": null, \"confirmed_date\": \"2026-01-31\", \"confirmed_time\": \"09:00:00\"}','2026-01-30 07:38:39'),(43,11,NULL,NULL,NULL,NULL,21,'schedule_confirm','Center side confirmed','{\"side\": \"center\", \"confirmed_date\": \"2026-01-31\", \"confirmed_time\": \"07:00:00\"}','2026-01-30 09:31:03'),(44,11,NULL,NULL,NULL,NULL,21,'schedule_confirm','Home side confirmed','{\"side\": \"technician\", \"confirmed_date\": \"2026-01-30\", \"confirmed_time\": \"16:00:00\"}','2026-01-30 09:32:12'),(45,11,'pending','checked_in','scheduled','arrived',14,'medical_status_update',NULL,'{\"pending_report_types\": null}','2026-01-30 09:34:09'),(46,8,NULL,NULL,'scheduled','rescheduled',17,'schedule_reschedule','Appointment rescheduled','{\"new_confirmed_date\": \"2026-02-05\", \"new_confirmed_time\": \"00:00:00\", \"previous_confirmed_date\": \"2026-01-30T18:30:00.000Z\", \"previous_confirmed_time\": \"09:00:00\"}','2026-02-04 10:41:52');
/*!40000 ALTER TABLE `appointment_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_tests`
--

DROP TABLE IF EXISTS `appointment_tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_tests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int DEFAULT NULL,
  `test_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `rate` decimal(10,2) DEFAULT NULL,
  `assigned_center_id` int DEFAULT NULL,
  `assigned_technician_id` int DEFAULT NULL,
  `visit_subtype` enum('center','home','both') DEFAULT 'center',
  `status` varchar(50) DEFAULT 'Pending',
  `invoice_upload` text,
  `updated_by` int DEFAULT NULL,
  `is_completed` tinyint(1) DEFAULT '0',
  `completion_remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `rate_type` enum('test','category') DEFAULT 'test',
  `item_name` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `test_id` (`test_id`),
  KEY `fk_appointment_tests_category` (`category_id`),
  KEY `idx_appointment_tests_type` (`rate_type`),
  KEY `idx_appointment_tests_tech_appt` (`assigned_technician_id`,`appointment_id`,`is_completed`),
  KEY `idx_appointment_tests_center_appt` (`assigned_center_id`,`appointment_id`,`visit_subtype`),
  KEY `idx_appointment_tests_completion` (`appointment_id`,`is_completed`,`status`),
  CONSTRAINT `appointment_tests_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointment_tests_ibfk_2` FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`),
  CONSTRAINT `fk_appointment_tests_category` FOREIGN KEY (`category_id`) REFERENCES `test_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_tests`
--

LOCK TABLES `appointment_tests` WRITE;
/*!40000 ALTER TABLE `appointment_tests` DISABLE KEYS */;
INSERT INTO `appointment_tests` VALUES (14,1,62,NULL,450.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','ANTI HCV','2026-01-21 10:42:36'),(15,1,32,NULL,322500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','CBC & ESR','2026-01-21 10:42:36'),(16,1,72,NULL,1111.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','Complete Blood Count','2026-01-21 10:42:36'),(17,1,35,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','FBS','2026-01-21 10:42:36'),(18,1,36,NULL,353500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','HBA1C','2026-01-21 10:42:36'),(19,1,63,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','HBEAG','2026-01-21 10:42:36'),(20,1,64,NULL,1100.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','HBsAg','2026-01-21 10:42:36'),(21,1,40,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','LFT','2026-01-21 10:42:36'),(22,1,69,NULL,11.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','test','RUA','2026-01-21 10:42:36'),(23,1,NULL,16,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','category','BSL-11','2026-01-21 10:42:36'),(24,1,NULL,15,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','category','BSL-8','2026-01-21 10:42:36'),(25,1,NULL,22,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','category','catru Adit','2026-01-21 10:42:36'),(26,1,NULL,26,1000.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 10:38:32','category','combo2','2026-01-21 10:42:36'),(66,4,62,NULL,450.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','ANTI HCV','2026-01-21 11:09:10'),(67,4,32,NULL,322500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','CBC & ESR','2026-01-21 11:09:10'),(68,4,72,NULL,1111.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','Complete Blood Count','2026-01-21 11:09:10'),(69,4,35,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','FBS','2026-01-21 11:09:10'),(70,4,36,NULL,353500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','HBA1C','2026-01-21 11:09:10'),(71,4,63,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','HBEAG','2026-01-21 11:09:10'),(72,4,64,NULL,1100.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','HBsAg','2026-01-21 11:09:10'),(73,4,40,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','LFT','2026-01-21 11:09:10'),(74,4,69,NULL,11.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','RUA','2026-01-21 11:09:10'),(75,4,NULL,16,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','BSL-11','2026-01-21 11:09:10'),(76,4,NULL,15,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','BSL-8','2026-01-21 11:09:10'),(77,4,NULL,22,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','catru Adit','2026-01-21 11:09:10'),(78,4,NULL,26,1000.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','combo2','2026-01-21 11:09:10'),(79,3,62,NULL,450.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','ANTI HCV','2026-01-22 07:16:20'),(80,3,32,NULL,322500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','CBC & ESR','2026-01-22 07:16:20'),(81,3,72,NULL,1111.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','Complete Blood Count','2026-01-22 07:16:20'),(82,3,35,NULL,3500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','FBS','2026-01-22 07:16:20'),(83,3,36,NULL,353500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','HBA1C','2026-01-22 07:16:20'),(84,3,63,NULL,3500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','HBEAG','2026-01-22 07:16:20'),(85,3,64,NULL,1100.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','HBsAg','2026-01-22 07:16:20'),(86,3,40,NULL,3500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','LFT','2026-01-22 07:16:20'),(87,3,69,NULL,11.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','test','RUA','2026-01-22 07:16:20'),(88,3,NULL,16,3500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','category','BSL-11','2026-01-22 07:16:20'),(89,3,NULL,15,3500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','category','BSL-8','2026-01-22 07:16:20'),(90,3,NULL,22,3500.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','category','catru Adit','2026-01-22 07:16:20'),(91,3,NULL,26,1000.00,20,2,'home','Pending',NULL,17,0,NULL,'2026-01-21 11:06:15','category','combo2','2026-01-22 07:16:20'),(92,2,62,NULL,450.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','ANTI HCV','2026-01-21 11:12:50'),(93,2,32,NULL,322500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','CBC & ESR','2026-01-21 11:12:50'),(94,2,72,NULL,1111.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','Complete Blood Count','2026-01-21 11:12:50'),(95,2,35,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','FBS','2026-01-21 11:12:50'),(96,2,36,NULL,353500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','HBA1C','2026-01-21 11:12:50'),(97,2,63,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','HBEAG','2026-01-21 11:12:50'),(98,2,64,NULL,1100.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','HBsAg','2026-01-21 11:12:50'),(99,2,40,NULL,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','LFT','2026-01-21 11:12:50'),(100,2,69,NULL,11.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','test','RUA','2026-01-21 11:12:50'),(101,2,NULL,16,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','BSL-11','2026-01-21 11:12:50'),(102,2,NULL,15,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','BSL-8','2026-01-21 11:12:50'),(103,2,NULL,22,3500.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','catru Adit','2026-01-21 11:12:50'),(104,2,NULL,26,1000.00,20,2,'home','Ready',NULL,9,0,NULL,'2026-01-21 11:06:15','category','combo2','2026-01-21 11:12:50'),(105,6,62,NULL,450.00,20,NULL,'center','Completed',NULL,17,1,NULL,'2026-01-27 12:59:34','test','ANTI HCV','2026-01-29 07:14:48'),(106,6,72,NULL,1111.00,20,NULL,'center','Completed',NULL,17,1,NULL,'2026-01-27 12:59:34','test','Complete Blood Count','2026-01-29 07:14:48'),(109,6,NULL,16,3500.00,12,2,'home','Pending',NULL,14,0,NULL,'2026-01-27 13:01:06','category','BSL-11','2026-01-27 13:01:06'),(110,6,NULL,15,3500.00,12,2,'home','Pending',NULL,14,0,NULL,'2026-01-27 13:01:06','category','BSL-8','2026-01-27 13:01:06'),(115,5,62,NULL,450.00,12,2,'home','Ready',NULL,9,0,NULL,'2026-01-28 04:50:01','test','ANTI HCV','2026-01-28 06:16:02'),(116,5,35,NULL,3500.00,12,2,'home','Ready',NULL,9,0,NULL,'2026-01-28 04:50:01','test','FBS','2026-01-28 06:16:02'),(117,5,NULL,16,3500.00,12,2,'home','Ready',NULL,9,0,NULL,'2026-01-28 04:50:01','category','BSL-11','2026-01-28 06:16:02'),(118,5,69,NULL,11.00,12,2,'home','Ready',NULL,9,0,NULL,'2026-01-28 04:50:01','test','RUA','2026-01-28 06:16:02'),(128,7,62,NULL,450.00,20,NULL,'home','pending',NULL,17,0,NULL,'2026-01-30 07:36:04','test','ANTI HCV','2026-01-30 07:36:04'),(129,7,72,NULL,1111.00,12,NULL,'center','pending',NULL,17,0,NULL,'2026-01-30 07:36:04','test','Complete Blood Count','2026-01-30 07:36:04'),(130,7,NULL,16,3500.00,12,NULL,'center','pending',NULL,17,0,NULL,'2026-01-30 07:36:04','category','BSL-11','2026-01-30 07:36:04'),(131,7,NULL,15,3500.00,20,NULL,'home','pending',NULL,17,0,NULL,'2026-01-30 07:36:04','category','BSL-8','2026-01-30 07:36:04'),(132,8,62,NULL,450.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','test','ANTI HCV','2026-01-30 07:38:53'),(133,8,72,NULL,1111.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','test','Complete Blood Count','2026-01-30 07:38:53'),(134,8,NULL,15,3500.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','category','BSL-8','2026-01-30 07:38:53'),(135,8,NULL,16,3500.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','category','BSL-11','2026-01-30 07:38:53'),(136,9,62,NULL,450.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','test','ANTI HCV','2026-01-30 07:38:53'),(137,9,72,NULL,1111.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','test','Complete Blood Count','2026-01-30 07:38:53'),(138,9,35,NULL,3500.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','test','FBS','2026-01-30 07:38:53'),(139,9,NULL,16,3500.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','category','BSL-11','2026-01-30 07:38:53'),(140,9,NULL,15,3500.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 07:38:53','category','BSL-8','2026-01-30 07:38:53'),(142,11,72,NULL,1111.00,12,NULL,'center','Ready',NULL,14,0,NULL,'2026-01-30 09:30:27','test','Complete Blood Count','2026-01-30 09:34:09'),(143,11,NULL,15,3500.00,12,NULL,'center','Ready',NULL,14,0,NULL,'2026-01-30 09:30:27','category','BSL-8','2026-01-30 09:34:09'),(145,11,62,NULL,450.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 09:34:25','test','ANTI HCV','2026-01-30 09:34:25'),(146,11,NULL,16,3500.00,20,2,'home','Pending',NULL,21,0,NULL,'2026-01-30 09:34:25','category','BSL-11','2026-01-30 09:34:25'),(149,27,62,NULL,450.00,20,NULL,'home','Pending',NULL,21,0,NULL,'2026-02-03 06:27:57','test','ANTI HCV','2026-02-03 06:27:57'),(150,27,32,NULL,322500.00,20,NULL,'center','Pending',NULL,21,0,NULL,'2026-02-03 06:27:57','test','CBC & ESR','2026-02-03 06:27:57');
/*!40000 ALTER TABLE `appointment_tests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_number` varchar(100) NOT NULL,
  `application_number` varchar(100) DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `center_id` int DEFAULT NULL,
  `other_center_id` int DEFAULT NULL,
  `insurer_id` int DEFAULT NULL,
  `customer_first_name` varchar(155) DEFAULT NULL,
  `customer_last_name` varchar(155) DEFAULT NULL,
  `gender` varchar(45) DEFAULT NULL,
  `customer_mobile` varchar(20) DEFAULT NULL,
  `customer_alt_mobile` varchar(45) DEFAULT NULL,
  `customer_service_no` varchar(20) DEFAULT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `customer_address` text,
  `state` varchar(45) DEFAULT NULL,
  `city` varchar(45) DEFAULT NULL,
  `pincode` varchar(45) DEFAULT NULL,
  `country` varchar(45) DEFAULT NULL,
  `customer_gps_latitude` decimal(10,8) DEFAULT NULL,
  `customer_gps_longitude` decimal(11,8) DEFAULT NULL,
  `customer_landmark` varchar(255) DEFAULT NULL,
  `visit_type` varchar(80) DEFAULT NULL,
  `customer_category` varchar(80) DEFAULT NULL,
  `appointment_date` date DEFAULT NULL,
  `confirmed_date` date DEFAULT NULL,
  `appointment_time` time DEFAULT NULL,
  `confirmed_time` time DEFAULT NULL,
  `status` varchar(100) NOT NULL DEFAULT 'pending',
  `assigned_technician_id` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `customer_arrived_at` timestamp NULL DEFAULT NULL,
  `medical_started_at` timestamp NULL DEFAULT NULL,
  `medical_completed_at` timestamp NULL DEFAULT NULL,
  `remarks` text,
  `cancellation_reason` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `test_name` varchar(45) DEFAULT NULL,
  `cost_type` varchar(85) DEFAULT NULL,
  `amount` decimal(8,2) DEFAULT NULL,
  `amount_upload` text,
  `case_severity` tinyint NOT NULL DEFAULT '0',
  `updated_by` int DEFAULT NULL,
  `is_active` tinyint NOT NULL DEFAULT '1',
  `split_type` enum('none','center_only','technician_only','split') DEFAULT 'none',
  `medical_status` varchar(45) DEFAULT NULL,
  `qc_status` varchar(55) DEFAULT NULL,
  `medical_remarks` text,
  `pending_report_types` varchar(255) DEFAULT NULL,
  `aadhaar_number` varchar(20) DEFAULT NULL,
  `pan_number` varchar(20) DEFAULT NULL,
  `arrival_time` datetime DEFAULT NULL,
  `medical_start_time` datetime DEFAULT NULL,
  `medical_end_time` datetime DEFAULT NULL,
  `pushed_back` tinyint NOT NULL DEFAULT '0',
  `pushback_remarks` text,
  `pushed_back_by` int DEFAULT NULL,
  `pushed_back_at` datetime DEFAULT NULL,
  `center_confirmed_at` datetime DEFAULT NULL COMMENT 'When center confirmed their part',
  `home_confirmed_at` datetime DEFAULT NULL COMMENT 'When home/technician confirmed their part',
  `center_arrived_at` datetime DEFAULT NULL COMMENT 'When customer arrived at center',
  `home_arrived_at` datetime DEFAULT NULL COMMENT 'When technician arrived at home',
  `center_medical_status` varchar(45) DEFAULT NULL COMMENT 'Center side medical status: scheduled, arrived, in_process, partially_completed, completed',
  `home_medical_status` varchar(45) DEFAULT NULL COMMENT 'Home side medical status: scheduled, arrived, in_process, partially_completed, completed',
  `center_completed_at` datetime DEFAULT NULL COMMENT 'When center tests completed',
  `home_completed_at` datetime DEFAULT NULL COMMENT 'When home tests completed',
  `center_pushed_back` tinyint(1) DEFAULT '0' COMMENT 'Center side pushed back',
  `home_pushed_back` tinyint(1) DEFAULT '0' COMMENT 'Home side pushed back',
  `center_pushback_remarks` text COMMENT 'Center pushback reason',
  `home_pushback_remarks` text COMMENT 'Home pushback reason',
  `center_reschedule_remark` text COMMENT 'Center reschedule reason',
  `home_reschedule_remark` text COMMENT 'Home reschedule reason',
  `last_call_attempt_at` datetime DEFAULT NULL COMMENT 'Last time a call was attempted',
  `total_call_attempts` int DEFAULT '0' COMMENT 'Total number of call attempts made',
  PRIMARY KEY (`id`),
  KEY `insurer_id` (`insurer_id`),
  KEY `assigned_technician_id` (`assigned_technician_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `created_by` (`created_by`),
  KEY `idx_appointment_date` (`appointment_date`),
  KEY `idx_status` (`status`),
  KEY `idx_customer_mobile` (`customer_mobile`),
  KEY `appointments_ibfk_1` (`client_id`),
  KEY `appointments_ibfk_2` (`center_id`),
  KEY `appointments_ibfk_7_idx` (`other_center_id`),
  KEY `appointments_ibfk_8_idx` (`updated_by`),
  KEY `fk_pushed_back_by` (`pushed_back_by`),
  KEY `idx_appointments_status_date` (`status`,`appointment_date`,`center_id`),
  KEY `idx_appointments_center_tech` (`center_id`,`assigned_technician_id`,`status`),
  KEY `idx_appointments_search` (`status`,`appointment_date`,`center_id`,`assigned_technician_id`),
  KEY `idx_appointments_center_status` (`center_medical_status`,`center_id`),
  KEY `idx_appointments_home_status` (`home_medical_status`,`other_center_id`),
  KEY `idx_appointments_center_pushback` (`center_pushed_back`),
  KEY `idx_appointments_home_pushback` (`home_pushed_back`),
  KEY `idx_last_call_attempt` (`last_call_attempt_at`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`center_id`) REFERENCES `diagnostic_centers` (`id`),
  CONSTRAINT `appointments_ibfk_3` FOREIGN KEY (`insurer_id`) REFERENCES `insurers` (`id`),
  CONSTRAINT `appointments_ibfk_4` FOREIGN KEY (`assigned_technician_id`) REFERENCES `technicians` (`id`),
  CONSTRAINT `appointments_ibfk_5` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  CONSTRAINT `appointments_ibfk_6` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `appointments_ibfk_7` FOREIGN KEY (`other_center_id`) REFERENCES `diagnostic_centers` (`id`),
  CONSTRAINT `fk_pushed_back_by` FOREIGN KEY (`pushed_back_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,'CASE/01/0001','APP-001s',38,20,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','123 Main Street, XYZ Building','Delhi','New Delhi','110001','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-15','2026-01-23','09:00:00','09:00:00','completed',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-30 05:00:53',0,0,NULL,NULL,NULL,NULL,0,21,1,'none','completed','completed','test check',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(2,'CASE/01/0002','APP-002s',38,20,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','124 Main Street, XYZ Building','Delhi','New Delhi','110002','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-16','2026-01-22','09:00:00','00:00:00','medical_partially_completed',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-21 11:14:01',0,0,NULL,NULL,NULL,NULL,0,9,1,'none','partially_completed',NULL,'ok','pathology,cardiology',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(3,'CASE/01/0003','APP-003s',38,20,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','125 Main Street, XYZ Building','Delhi','New Delhi','110003','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-17','2026-01-27','09:00:00','11:00:00','pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-27 07:06:08',0,0,NULL,NULL,NULL,NULL,0,17,1,'none','rescheduled',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(4,'CASE/01/0004','APP-004s',38,20,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','126 Main Street, XYZ Building','Delhi','New Delhi','110004','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-18','2026-01-24','09:00:00','06:00:00','medical_completed',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-22 11:56:59',0,0,NULL,NULL,NULL,NULL,0,17,1,'none','rescheduled',NULL,'ok',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(5,'CASE/01/0005','APP-005s',38,12,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','127 Main Street, XYZ Building','Delhi','New Delhi','110005','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-19','2026-01-29','09:00:00','09:00:00','medical_completed',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-28 06:17:06',0,0,NULL,NULL,NULL,NULL,0,17,1,'none','completed',NULL,'complete',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(6,'CASE/01/0006','APP-006s',38,20,12,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','128 Main Street, XYZ Building','Delhi','New Delhi','110006','IN',NULL,NULL,'Near Mall Road','Both','Non_HNI','2024-01-20',NULL,'09:00:00',NULL,'medical_partially_completed',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-29 07:14:48',0,0,NULL,NULL,NULL,NULL,0,17,1,'none','medical_partially_completed',NULL,'ok',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'2026-01-29 09:00:00','2026-01-29 09:00:00','2026-01-29 10:58:47',NULL,'completed','scheduled','2026-01-29 12:44:48',NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(7,'CASE/01/0007','APP-007s',38,20,12,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','129 Main Street, XYZ Building','Delhi','New Delhi','110007','IN',NULL,NULL,'Near Mall Road','Both','Non_HNI','2024-01-21',NULL,'09:00:00',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-30 07:36:22',0,0,NULL,NULL,NULL,NULL,0,14,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'2026-01-31 10:00:00',NULL,NULL,NULL,'scheduled',NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(8,'CASE/01/0008','yAPP-008s',38,20,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','130 Main Street, XYZ Building','Delhi','New Delhi','110008','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-22','2026-02-05','09:00:00','00:00:00','pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-02-04 11:08:09',0,0,NULL,NULL,NULL,NULL,0,17,1,'none','rescheduled',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2026-02-04 16:38:09',1),(9,'CASE/01/0009','yAPP-009s',38,20,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','131 Main Street, XYZ Building','Delhi','New Delhi','110009','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-23','2026-01-31','09:00:00','09:00:00','pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-30 07:38:53',0,0,NULL,NULL,NULL,NULL,0,21,1,'none','scheduled',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(10,'CASE/01/0010','APP-s',24,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','132 Main Street, XYZ Building','Delhi','New Delhi','110010','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-24','2026-01-29','09:00:09','12:00:00','pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-21 10:37:13','2026-01-29 05:27:09',0,0,NULL,NULL,NULL,NULL,0,17,1,'none','scheduled',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(11,'CASE/01/0011','rrAPP-001',38,12,20,5,'gfdgdf','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','123 Main Street, XYZ Building','Delhi','New Delhi','110001','IN',NULL,NULL,'Near Mall Road','Both','Non_HNI','2024-01-15',NULL,'09:00:00',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 09:29:25','2026-01-30 09:34:25',0,0,NULL,'Advance NEFT',4545.00,NULL,0,21,1,'none','checked_in',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'2026-01-31 07:00:00','2026-01-30 16:00:00','2026-01-30 15:04:09',NULL,'arrived','scheduled',NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(12,'CASE/01/0012','rrAPP-0013',38,NULL,NULL,5,'gfdgdf','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','123 Main Street, XYZ Building','Delhi','New Delhi','110001','IN',NULL,NULL,'Near Mall Road','Both','Non_HNI','2024-01-15',NULL,'09:00:00',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:04:03','2026-01-30 10:04:03',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(13,'CASE/01/0013','APPttt-001',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','123 Main Street, XYZ Building','Delhi','New Delhi','110001','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-15',NULL,'09:00:00',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(14,'CASE/01/0014','APPttt-002',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','124 Main Street, XYZ Building','Delhi','New Delhi','110002','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-16',NULL,'09:00:01',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(15,'CASE/01/0015','APPttt-003',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','125 Main Street, XYZ Building','Delhi','New Delhi','110003','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-17',NULL,'09:00:02',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(16,'CASE/01/0016','APPttt-004',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','126 Main Street, XYZ Building','Delhi','New Delhi','110004','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-18',NULL,'09:00:03',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(17,'CASE/01/0017','APPttt-005',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','127 Main Street, XYZ Building','Delhi','New Delhi','110005','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-19',NULL,'09:00:04',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(18,'CASE/01/0018','APPttt-006',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','128 Main Street, XYZ Building','Delhi','New Delhi','110006','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-20',NULL,'09:00:05',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(19,'CASE/01/0019','APPttt-007',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','129 Main Street, XYZ Building','Delhi','New Delhi','110007','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-21',NULL,'09:00:06',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(20,'CASE/01/0020','APPttt-008',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','130 Main Street, XYZ Building','Delhi','New Delhi','110008','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-22',NULL,'09:00:07',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(21,'CASE/01/0021','APPttt-009',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','131 Main Street, XYZ Building','Delhi','New Delhi','110009','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-23',NULL,'09:00:08',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(22,'CASE/01/0022','APPttt-010',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','132 Main Street, XYZ Building','Delhi','New Delhi','110010','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-24',NULL,'09:00:09',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(23,'CASE/01/0023','APPttt-011',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','133 Main Street, XYZ Building','Delhi','New Delhi','110011','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-25',NULL,'09:00:10',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(24,'CASE/01/0024','APPttt-012',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','134 Main Street, XYZ Building','Delhi','New Delhi','110012','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-26',NULL,'09:00:11',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(25,'CASE/01/0025','APPttt-013',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','135 Main Street, XYZ Building','Delhi','New Delhi','110013','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-27',NULL,'09:00:12',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(26,'CASE/01/0026','APPttt-014',38,NULL,NULL,5,'John','Doe','Male','9876543210',NULL,NULL,'john.doe@email.com','136 Main Street, XYZ Building','Delhi','New Delhi','110014','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-28',NULL,'09:00:13',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'Initial appointment',NULL,NULL,'2026-01-30 10:33:13','2026-01-30 10:33:13',0,0,NULL,NULL,NULL,NULL,0,NULL,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0),(27,'CASE/01/0027','APPttt-015',38,20,NULL,5,'John','Doe','Male','9226716071','9226716071','9226716071','john.doe@email.com','137 Main Street, XYZ Building','Delhi','New Delhi','110015','IN',NULL,NULL,'Near Mall Road','Home_Visit','Non_HNI','2024-01-29',NULL,'09:00:00',NULL,'pending',NULL,NULL,NULL,NULL,NULL,NULL,' hiiiiiiiii',NULL,NULL,'2026-01-30 10:33:13','2026-02-09 09:25:40',0,0,NULL,'Credit',NULL,NULL,0,21,1,'none',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2026-02-09 14:55:40',40);
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `approval_queue`
--

DROP TABLE IF EXISTS `approval_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `approval_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `entity_type` enum('client','center','doctor','insurer','appointment','appointment_import','test','test_category','test_rate','bulk_test_rate','test_rate_import','technician','user') NOT NULL,
  `entity_id` int DEFAULT NULL,
  `action_type` enum('create','update','delete','bulk_update','bulk_create','bulk_delete') NOT NULL,
  `old_data` json DEFAULT NULL COMMENT 'Original data before change (for updates/deletes)',
  `new_data` json NOT NULL COMMENT 'New/proposed data',
  `changes_summary` text COMMENT 'Human-readable summary of changes',
  `requested_by` int NOT NULL,
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `reviewed_by` int DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text,
  `notes` text COMMENT 'Additional notes from requester',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_status` (`status`),
  KEY `idx_requested_by` (`requested_by`),
  KEY `idx_reviewed_by` (`reviewed_by`),
  KEY `idx_requested_at` (`requested_at`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_approvals_entity_status` (`entity_type`,`entity_id`,`status`,`created_at`),
  CONSTRAINT `fk_approval_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_approval_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `approval_queue`
--

LOCK TABLES `approval_queue` WRITE;
/*!40000 ALTER TABLE `approval_queue` DISABLE KEYS */;
INSERT INTO `approval_queue` VALUES (1,'appointment',3,'update','{\"id\": 3, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 6, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T07:22:56.000Z\", \"updated_by\": 7, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0003\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": 5, \"appointment_date\": \"2024-01-16T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"home_pushed_back\": 1, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": \"2026-01-23T18:30:00.000Z\", \"application_number\": \"APP-003s\", \"center_pushed_back\": 1, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": \"2026-01-24T04:30:00.000Z\", \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": \"scheduled\", \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": \"scheduled\", \"customer_gps_latitude\": null, \"home_pushback_remarks\": \"nnnnnnnnnnnnnnnnnnn\", \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": \"bbbbbbbbbbbbbbbb\", \"center_reschedule_remark\": null}','{\"_actorContext\": null, \"confirmed_date\": \"2026-01-21\", \"confirmed_time\": \"16:02:00\", \"medical_status\": \"rescheduled\"}','confirmed_date: \"empty\" → \"2026-01-21\", confirmed_time: \"empty\" → \"16:02:00\", medical_status: \"scheduled\" → \"rescheduled\"',10,'2026-01-21 07:24:59','approved',17,'2026-01-21 07:38:48',NULL,'','medium','2026-01-21 07:24:59','2026-01-21 07:38:48'),(2,'appointment',3,'update','{\"id\": 3, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"scheduled\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 6, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T07:38:48.000Z\", \"updated_by\": 17, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0003\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": 5, \"appointment_date\": \"2024-01-16T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"home_pushed_back\": 1, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": \"2026-01-23T18:30:00.000Z\", \"application_number\": \"APP-003s\", \"center_pushed_back\": 1, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": \"2026-01-24T04:30:00.000Z\", \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": \"scheduled\", \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": \"rescheduled\", \"customer_gps_latitude\": null, \"home_pushback_remarks\": \"nnnnnnnnnnnnnnnnnnn\", \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": \"bbbbbbbbbbbbbbbb\", \"center_reschedule_remark\": null}','{\"_actorContext\": {\"type\": \"center\", \"centerId\": 6}, \"confirmed_date\": \"2026-01-22\", \"confirmed_time\": \"08:00:00\", \"medical_status\": \"rescheduled\"}','confirmed_date: \"empty\" → \"2026-01-22\", confirmed_time: \"empty\" → \"08:00:00\", medical_status: \"scheduled\" → \"rescheduled\", _actorContext: \"empty\" → \"[object Object]\"',10,'2026-01-21 07:39:56','approved',17,'2026-01-21 07:41:01',NULL,'Reschedule by center (ID: 6): No reason','medium','2026-01-21 07:39:56','2026-01-21 07:41:01'),(3,'appointment',3,'update','{\"id\": 3, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"scheduled\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 6, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T07:41:01.000Z\", \"updated_by\": 17, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0003\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": 5, \"appointment_date\": \"2024-01-16T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"home_pushed_back\": 1, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": \"2026-01-23T18:30:00.000Z\", \"application_number\": \"APP-003s\", \"center_pushed_back\": 1, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": \"2026-01-24T04:30:00.000Z\", \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": \"scheduled\", \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": \"rescheduled\", \"customer_gps_latitude\": null, \"home_pushback_remarks\": \"nnnnnnnnnnnnnnnnnnn\", \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": \"bbbbbbbbbbbbbbbb\", \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"scheduled\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 6, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 7, \"visit_type\": \"Both\", \"case_number\": \"CASE/01/0003\", \"total_amount\": 3511, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 5, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 5, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"other_center_id\": 5, \"appointment_date\": \"2024-01-17\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-003s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Wed Jan 17 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-17\", selected_items: \"0 test(s)\" → \"2 test(s)\", total_amount: \"empty\" → \"3511\"',7,'2026-01-21 07:55:09','approved',17,'2026-01-21 07:55:15',NULL,'','medium','2026-01-21 07:55:09','2026-01-21 07:55:15'),(4,'appointment',3,'update','{\"id\": 3, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_partially_completed\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 6, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T09:48:04.000Z\", \"updated_by\": 10, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0003\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"medical_partially_completed\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": \"2026-01-21T07:55:20.000Z\", \"medical_remarks\": \"nnnnnnnn\", \"other_center_id\": 5, \"appointment_date\": \"2024-01-16T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"home_pushed_back\": 1, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": \"2026-01-21T09:47:47.000Z\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": \"2026-01-21T09:40:06.000Z\", \"home_confirmed_at\": \"2026-01-23T18:30:00.000Z\", \"application_number\": \"APP-003s\", \"center_pushed_back\": 1, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": \"2026-01-24T04:30:00.000Z\", \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": \"completed\", \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": \"partially_completed\", \"customer_gps_latitude\": null, \"home_pushback_remarks\": \"nnnnnnnnnnnnnnnnnnn\", \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": \"bbbbbbbbbbbbbbbb\", \"center_reschedule_remark\": null}','{\"updated_by\": 10, \"_actorContext\": null, \"medical_status\": \"completed\", \"medical_remarks\": \"bbbbbbbbb\"}','medical_status: \"medical_partially_completed\" → \"completed\", medical_remarks: \"nnnnnnnn\" → \"bbbbbbbbb\"',10,'2026-01-21 09:48:13','approved',17,'2026-01-21 09:48:26',NULL,'Medical completion requested with remarks and file upload','high','2026-01-21 09:48:13','2026-01-21 09:48:26'),(5,'appointment',5,'update','{\"id\": 5, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110005\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T10:20:31.000Z\", \"updated_by\": 14, \"visit_type\": \"Center_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0005\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-21T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-18T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"127 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-005s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"_actorContext\": null, \"confirmed_date\": \"2026-01-24\", \"confirmed_time\": \"11:00:00\", \"medical_status\": \"rescheduled\"}','confirmed_date: \"Thu Jan 22 2026 00:00:00 GMT+0530 (India Standard Time)\" → \"2026-01-24\", confirmed_time: \"09:00:00\" → \"11:00:00\", medical_status: \"scheduled\" → \"rescheduled\"',14,'2026-01-21 10:20:42','approved',17,'2026-01-21 10:20:56',NULL,'','medium','2026-01-21 10:20:42','2026-01-21 10:20:56'),(6,'appointment',5,'update','{\"id\": 5, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_partially_completed\", \"country\": \"IN\", \"pincode\": \"110005\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T10:24:02.000Z\", \"updated_by\": 14, \"visit_type\": \"Center_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0005\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-21T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"partially_completed\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": \"nnnnnnnnnnnnnnnn\", \"other_center_id\": null, \"appointment_date\": \"2024-01-18T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"127 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-005s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": \"pathology,cardiology\", \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"updated_by\": 14, \"_actorContext\": null, \"medical_status\": \"completed\", \"medical_remarks\": \"vvvvvvvvvvvvvvvvvvvv\"}','medical_status: \"partially_completed\" → \"completed\", medical_remarks: \"nnnnnnnnnnnnnnnn\" → \"vvvvvvvvvvvvvvvvvvvv\"',14,'2026-01-21 10:24:12','approved',17,'2026-01-21 10:24:18',NULL,'Medical completion requested with remarks and file upload','high','2026-01-21 10:24:12','2026-01-21 10:24:18'),(7,'appointment',4,'update','{\"id\": 4, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pushed_back\", \"country\": \"IN\", \"pincode\": \"110004\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T06:17:23.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T10:25:39.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0004\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-17T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"126 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-004s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pushed_back\", \"country\": \"IN\", \"pincode\": \"110004\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0004\", \"total_amount\": 700672, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 32, \"name\": \"CBC & ESR\", \"rate\": 322500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 36, \"name\": \"HBA1C\", \"rate\": 353500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 63, \"name\": \"HBEAG\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 64, \"name\": \"HBsAg\", \"rate\": 1100, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 40, \"name\": \"LFT\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 22, \"name\": \"catru Adit\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 26, \"name\": \"combo2\", \"rate\": 1000, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-18\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"126 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-004s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Thu Jan 18 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-18\", selected_items: \"0 test(s)\" → \"13 test(s)\", total_amount: \"empty\" → \"700672\"',21,'2026-01-21 10:26:09','approved',17,'2026-01-21 10:26:13',NULL,'','medium','2026-01-21 10:26:09','2026-01-21 10:26:13'),(8,'appointment',1,'update','{\"id\": 1, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110001\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T10:38:06.000Z\", \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0001\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-22T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-14T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"123 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-001s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110001\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0001\", \"total_amount\": 700672, \"amount_upload\": null, \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 32, \"name\": \"CBC & ESR\", \"rate\": 322500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 36, \"name\": \"HBA1C\", \"rate\": 353500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 63, \"name\": \"HBEAG\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 64, \"name\": \"HBsAg\", \"rate\": 1100, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 40, \"name\": \"LFT\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 22, \"name\": \"catru Adit\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 26, \"name\": \"combo2\", \"rate\": 1000, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-15\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"123 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-001s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Mon Jan 15 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-15\", selected_items: \"0 test(s)\" → \"13 test(s)\", total_amount: \"empty\" → \"700672\"',21,'2026-01-21 10:38:26','approved',17,'2026-01-21 10:38:32',NULL,'','medium','2026-01-21 10:38:26','2026-01-21 10:38:32'),(9,'appointment',2,'update','{\"id\": 2, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110002\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T11:05:01.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0002\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-15T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"124 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-002s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110002\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0002\", \"total_amount\": 700672, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 32, \"name\": \"CBC & ESR\", \"rate\": 322500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 36, \"name\": \"HBA1C\", \"rate\": 353500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 63, \"name\": \"HBEAG\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 64, \"name\": \"HBsAg\", \"rate\": 1100, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 40, \"name\": \"LFT\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 22, \"name\": \"catru Adit\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 26, \"name\": \"combo2\", \"rate\": 1000, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-16\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"124 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-002s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Tue Jan 16 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-16\", selected_items: \"0 test(s)\" → \"13 test(s)\", total_amount: \"empty\" → \"700672\"',21,'2026-01-21 11:05:54','approved',17,'2026-01-21 11:06:15',NULL,'','medium','2026-01-21 11:05:54','2026-01-21 11:06:15'),(10,'appointment',3,'update','{\"id\": 3, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T11:05:18.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0003\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-16T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-003s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110003\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0003\", \"total_amount\": 700672, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 32, \"name\": \"CBC & ESR\", \"rate\": 322500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 36, \"name\": \"HBA1C\", \"rate\": 353500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 63, \"name\": \"HBEAG\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 64, \"name\": \"HBsAg\", \"rate\": 1100, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 40, \"name\": \"LFT\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 22, \"name\": \"catru Adit\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 26, \"name\": \"combo2\", \"rate\": 1000, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-17\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"125 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-003s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Wed Jan 17 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-17\", selected_items: \"0 test(s)\" → \"13 test(s)\", total_amount: \"empty\" → \"700672\"',21,'2026-01-21 11:06:02','approved',17,'2026-01-21 11:06:15',NULL,'','medium','2026-01-21 11:06:02','2026-01-21 11:06:15'),(11,'appointment',4,'update','{\"id\": 4, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110004\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T11:05:40.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0004\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-17T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"126 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-004s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110004\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0004\", \"total_amount\": 700672, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 32, \"name\": \"CBC & ESR\", \"rate\": 322500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 36, \"name\": \"HBA1C\", \"rate\": 353500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 63, \"name\": \"HBEAG\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 64, \"name\": \"HBsAg\", \"rate\": 1100, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 40, \"name\": \"LFT\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 22, \"name\": \"catru Adit\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 26, \"name\": \"combo2\", \"rate\": 1000, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-18\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"126 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-004s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Thu Jan 18 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-18\", selected_items: \"0 test(s)\" → \"13 test(s)\", total_amount: \"empty\" → \"700672\"',21,'2026-01-21 11:06:09','approved',17,'2026-01-21 11:06:15',NULL,'','medium','2026-01-21 11:06:09','2026-01-21 11:06:15'),(12,'appointment',1,'update','{\"id\": 1, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_partially_completed\", \"country\": \"IN\", \"pincode\": \"110001\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-21T10:59:13.000Z\", \"updated_by\": 9, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0001\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-22T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"partially_completed\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": \"chrck\", \"other_center_id\": null, \"appointment_date\": \"2024-01-14T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"123 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-001s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": \"pathology,cardiology\", \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"pan_number\": null, \"updated_by\": 9, \"_actorContext\": {\"type\": \"technician\", \"centerId\": null, \"technicianId\": 2}, \"aadhaar_number\": null, \"medical_status\": \"completed\", \"medical_remarks\": \"case 001\", \"pending_report_types\": []}','medical_status: \"partially_completed\" → \"completed\", medical_remarks: \"chrck\" → \"case 001\", pending_report_types: \"pathology,cardiology\" → \"empty\", _actorContext: \"empty\" → \"[object Object]\"',9,'2026-01-22 07:15:44','rejected',17,'2026-01-22 11:56:59','Superseded by newer approval','Medical completion requested by technician (ID: 2)','high','2026-01-22 07:15:44','2026-01-22 11:56:59'),(13,'appointment',1,'update','{\"id\": 1, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_partially_completed\", \"country\": \"IN\", \"pincode\": \"110001\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-22T07:15:44.000Z\", \"updated_by\": 9, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0001\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-22T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"partially_completed\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": \"chrck\", \"other_center_id\": null, \"appointment_date\": \"2024-01-14T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"123 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-001s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 1, \"medical_completed_at\": null, \"pending_report_types\": \"pathology,cardiology\", \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"pan_number\": null, \"updated_by\": 9, \"_actorContext\": {\"type\": \"technician\", \"centerId\": null, \"technicianId\": 2}, \"aadhaar_number\": null, \"medical_status\": \"completed\", \"medical_remarks\": \"test check\", \"pending_report_types\": []}','medical_status: \"partially_completed\" → \"completed\", medical_remarks: \"chrck\" → \"test check\", pending_report_types: \"pathology,cardiology\" → \"empty\", _actorContext: \"empty\" → \"[object Object]\"',9,'2026-01-22 07:34:12','approved',17,'2026-01-22 11:56:59',NULL,'Medical completion requested by technician (ID: 2)','high','2026-01-22 07:34:12','2026-01-22 11:56:59'),(14,'appointment',4,'update','{\"id\": 4, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_completed\", \"country\": \"IN\", \"pincode\": \"110004\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-22T05:11:50.000Z\", \"updated_by\": 9, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0004\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-23T18:30:00.000Z\", \"confirmed_time\": \"06:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"completed\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": \"ok\", \"other_center_id\": null, \"appointment_date\": \"2024-01-17T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"126 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-004s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"confirmed_date\": \"2026-01-22\", \"confirmed_time\": \"1:04 PM\", \"medical_status\": \"rescheduled\"}','confirmed_date: \"Sat Jan 24 2026 00:00:00 GMT+0530 (India Standard Time)\" → \"2026-01-22\", confirmed_time: \"06:00:00\" → \"1:04 PM\", medical_status: \"completed\" → \"rescheduled\"',9,'2026-01-22 07:34:58','approved',17,'2026-01-22 11:56:59',NULL,'Reschedule reason: check after status completed','medium','2026-01-22 07:34:58','2026-01-22 11:56:59'),(15,'appointment',6,'update','{\"id\": 6, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110006\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-27T13:00:24.000Z\", \"updated_by\": 14, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0006\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": 12, \"appointment_date\": \"2024-01-19T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"128 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": \"2026-01-29T03:30:00.000Z\", \"application_number\": \"APP-006s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": \"2026-01-29T03:30:00.000Z\", \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": \"scheduled\", \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": \"scheduled\", \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110006\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 14, \"visit_type\": \"Both\", \"case_number\": \"CASE/01/0006\", \"total_amount\": 7000, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 12, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 12, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"other_center_id\": 12, \"appointment_date\": \"2024-01-20\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"128 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-006s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Sat Jan 20 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-20\", selected_items: \"0 test(s)\" → \"2 test(s)\", total_amount: \"empty\" → \"7000\"',14,'2026-01-27 13:00:36','approved',17,'2026-01-27 13:01:06',NULL,'','medium','2026-01-27 13:00:36','2026-01-27 13:01:06'),(16,'appointment',5,'update','{\"id\": 5, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110005\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-28T04:49:28.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0005\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-28T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"scheduled\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-18T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"127 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-005s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110005\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 14, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0005\", \"total_amount\": 7461, \"amount_upload\": null, \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 12, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 12, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 12, \"assigned_technician_id\": 2}, {\"id\": 69, \"name\": \"RUA\", \"rate\": 11, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 12, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-19\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"127 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APP-005s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Fri Jan 19 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-19\", selected_items: \"0 test(s)\" → \"4 test(s)\", total_amount: \"empty\" → \"7461\"',14,'2026-01-28 04:49:48','approved',17,'2026-01-28 04:50:01',NULL,'','medium','2026-01-28 04:49:48','2026-01-28 04:50:01'),(17,'appointment',5,'update','{\"id\": 5, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_partially_completed\", \"country\": \"IN\", \"pincode\": \"110005\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-28T06:16:24.000Z\", \"updated_by\": 9, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0005\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": \"2026-01-28T18:30:00.000Z\", \"confirmed_time\": \"09:00:00\", \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"partially_completed\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": \"ok\", \"other_center_id\": null, \"appointment_date\": \"2024-01-18T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"127 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APP-005s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": \"pathology\", \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"pan_number\": null, \"updated_by\": 9, \"_actorContext\": {\"type\": \"technician\", \"centerId\": null, \"technicianId\": 2}, \"aadhaar_number\": null, \"medical_status\": \"completed\", \"medical_remarks\": \"complete\", \"pending_report_types\": []}','medical_status: \"partially_completed\" → \"completed\", medical_remarks: \"ok\" → \"complete\", pending_report_types: \"pathology\" → \"empty\", _actorContext: \"empty\" → \"[object Object]\"',9,'2026-01-28 06:16:47','approved',17,'2026-01-28 06:17:06',NULL,'Medical completion requested by technician (ID: 2)','high','2026-01-28 06:16:47','2026-01-28 06:17:06'),(18,'appointment',6,'update','{\"id\": 6, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"medical_in_process\", \"country\": \"IN\", \"pincode\": \"110006\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-29T07:14:12.000Z\", \"updated_by\": 21, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0006\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": \"medical_in_process\", \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": 12, \"appointment_date\": \"2024-01-19T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"128 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": \"2026-01-29T05:28:47.000Z\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": \"2026-01-29T03:30:00.000Z\", \"application_number\": \"APP-006s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": \"2026-01-29T03:30:00.000Z\", \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": \"scheduled\", \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": \"in_process\", \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"updated_by\": 21, \"_actorContext\": null, \"medical_status\": \"completed\", \"medical_remarks\": \"ok\"}','medical_status: \"medical_in_process\" → \"completed\", medical_remarks: \"empty\" → \"ok\"',21,'2026-01-29 07:14:29','approved',17,'2026-01-29 07:14:48',NULL,'Medical completion requested with remarks and file upload','high','2026-01-29 07:14:29','2026-01-29 07:14:48'),(19,'appointment',8,'update','{\"id\": 8, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110008\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-30T07:35:23.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0008\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-21T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"130 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"yAPP-008s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110008\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0008\", \"total_amount\": 8561, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-22\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"130 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"yAPP-008s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Mon Jan 22 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-22\", selected_items: \"0 test(s)\" → \"4 test(s)\", total_amount: \"empty\" → \"8561\"',21,'2026-01-30 07:37:53','rejected',17,'2026-01-30 07:38:53','Superseded by newer approval','','medium','2026-01-30 07:37:53','2026-01-30 07:38:53'),(20,'appointment',9,'update','{\"id\": 9, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110009\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-30T07:34:49.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0009\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-22T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"131 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"yAPP-009s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110009\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0009\", \"total_amount\": 12061, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 35, \"name\": \"FBS\", \"rate\": 3500, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-23\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"131 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"yAPP-009s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Tue Jan 23 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-23\", selected_items: \"0 test(s)\" → \"5 test(s)\", total_amount: \"empty\" → \"12061\"',21,'2026-01-30 07:38:08','approved',17,'2026-01-30 07:38:53',NULL,'','medium','2026-01-30 07:38:08','2026-01-30 07:38:53'),(21,'appointment',8,'update','{\"id\": 8, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110008\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": null, \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-21T10:37:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-30T07:37:53.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0008\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-21T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"130 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"yAPP-008s\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 1, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110008\", \"remarks\": \"Initial appointment\", \"center_id\": 20, \"client_id\": 38, \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0008\", \"total_amount\": 8561, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 72, \"name\": \"Complete Blood Count\", \"rate\": 1111, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 15, \"name\": \"BSL-8\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"appointment_date\": \"2024-01-22\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"130 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"yAPP-008s\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','appointment_date: \"Mon Jan 22 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-22\", selected_items: \"0 test(s)\" → \"4 test(s)\", total_amount: \"empty\" → \"8561\"',21,'2026-01-30 07:38:19','approved',17,'2026-01-30 07:38:53',NULL,'','medium','2026-01-30 07:38:19','2026-01-30 07:38:53'),(22,'appointment',11,'update','{\"id\": 11, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": \"4545.00\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110001\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"cost_type\": \"Advance NEFT\", \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-30T09:29:25.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-30T09:30:27.000Z\", \"updated_by\": 17, \"visit_type\": \"Both\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0011\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": 20, \"appointment_date\": \"2024-01-14T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"123 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"rrAPP-001\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"gfdgdf\", \"customer_service_no\": null, \"home_medical_status\": null, \"has_pending_approval\": 0, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": 4545, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110001\", \"remarks\": \"Initial appointment\", \"center_id\": 12, \"client_id\": 38, \"cost_type\": \"Advance NEFT\", \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Both\", \"case_number\": \"CASE/01/0011\", \"total_amount\": 3950, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}, {\"id\": 16, \"name\": \"BSL-11\", \"rate\": 3500, \"type\": \"category\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": 2}], \"customer_mobile\": \"9876543210\", \"other_center_id\": 20, \"appointment_date\": \"2024-01-15\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"123 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"rrAPP-001\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"gfdgdf\"}','appointment_date: \"Mon Jan 15 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-15\", selected_items: \"0 test(s)\" → \"2 test(s)\", total_amount: \"empty\" → \"3950\"',21,'2026-01-30 09:30:54','approved',17,'2026-01-30 09:34:25',NULL,'','medium','2026-01-30 09:30:54','2026-01-30 09:34:25'),(23,'appointment',27,'update','{\"id\": 27, \"city\": \"New Delhi\", \"state\": \"Delhi\", \"amount\": null, \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110015\", \"remarks\": \" hiiiiiiiii\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": \"Credit\", \"is_active\": 1, \"qc_status\": null, \"test_name\": null, \"created_at\": \"2026-01-30T10:33:13.000Z\", \"created_by\": null, \"insurer_id\": 5, \"is_deleted\": 0, \"pan_number\": null, \"split_type\": \"none\", \"updated_at\": \"2026-01-30T10:51:55.000Z\", \"updated_by\": 17, \"visit_type\": \"Home_Visit\", \"assigned_at\": null, \"assigned_by\": null, \"case_number\": \"CASE/01/0027\", \"pushed_back\": 0, \"arrival_time\": null, \"amount_upload\": null, \"case_severity\": 0, \"aadhaar_number\": null, \"confirmed_date\": null, \"confirmed_time\": null, \"customer_email\": \"john.doe@email.com\", \"medical_status\": null, \"pushed_back_at\": null, \"pushed_back_by\": null, \"customer_mobile\": \"9876543210\", \"home_arrived_at\": null, \"medical_remarks\": null, \"other_center_id\": null, \"appointment_date\": \"2024-01-28T18:30:00.000Z\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"137 Main Street, XYZ Building\", \"home_pushed_back\": 0, \"medical_end_time\": null, \"pushback_remarks\": null, \"center_arrived_at\": null, \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"home_completed_at\": null, \"home_confirmed_at\": null, \"application_number\": \"APPttt-015\", \"center_pushed_back\": 0, \"customer_last_name\": \"Doe\", \"medical_start_time\": null, \"medical_started_at\": null, \"cancellation_reason\": null, \"center_completed_at\": null, \"center_confirmed_at\": null, \"customer_alt_mobile\": null, \"customer_arrived_at\": null, \"customer_first_name\": \"John\", \"customer_service_no\": null, \"home_medical_status\": null, \"total_call_attempts\": 0, \"has_pending_approval\": 0, \"last_call_attempt_at\": null, \"medical_completed_at\": null, \"pending_report_types\": null, \"center_medical_status\": null, \"customer_gps_latitude\": null, \"home_pushback_remarks\": null, \"assigned_technician_id\": null, \"customer_gps_longitude\": null, \"home_reschedule_remark\": null, \"center_pushback_remarks\": null, \"center_reschedule_remark\": null}','{\"city\": \"New Delhi\", \"state\": \"Delhi\", \"gender\": \"Male\", \"status\": \"pending\", \"country\": \"IN\", \"pincode\": \"110015\", \"remarks\": \" hiiiiiiiii\", \"center_id\": 20, \"client_id\": 38, \"cost_type\": \"Credit\", \"insurer_id\": 5, \"updated_by\": 21, \"visit_type\": \"Home_Visit\", \"case_number\": \"CASE/01/0027\", \"total_amount\": 322950, \"amount_upload\": null, \"customer_email\": \"john.doe@email.com\", \"selected_items\": [{\"id\": 62, \"name\": \"ANTI HCV\", \"rate\": 450, \"type\": \"test\", \"visit_subtype\": \"home\", \"assigned_center_id\": 20, \"assigned_technician_id\": null}, {\"id\": 32, \"name\": \"CBC & ESR\", \"rate\": 322500, \"type\": \"test\", \"visit_subtype\": \"center\", \"assigned_center_id\": 20, \"assigned_technician_id\": null}], \"customer_mobile\": \"9226716071\", \"appointment_date\": \"2024-01-29\", \"appointment_time\": \"09:00:00\", \"customer_address\": \"137 Main Street, XYZ Building\", \"customer_category\": \"Non_HNI\", \"customer_landmark\": \"Near Mall Road\", \"application_number\": \"APPttt-015\", \"customer_last_name\": \"Doe\", \"customer_first_name\": \"John\"}','customer_mobile: \"9876543210\" → \"9226716071\", appointment_date: \"Mon Jan 29 2024 00:00:00 GMT+0530 (India Standard Time)\" → \"2024-01-29\", selected_items: \"0 test(s)\" → \"2 test(s)\", total_amount: \"empty\" → \"322950\"',21,'2026-02-03 06:27:46','approved',17,'2026-02-03 06:27:57',NULL,'','medium','2026-02-03 06:27:46','2026-02-03 06:27:57');
/*!40000 ALTER TABLE `approval_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bulk_test_rates`
--

DROP TABLE IF EXISTS `bulk_test_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bulk_test_rates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `insurer_id` int NOT NULL,
  `item_type` enum('test','category') NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `item_code` varchar(150) DEFAULT NULL,
  `description` text,
  `rate` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `test_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rate_unique` (`client_id`,`insurer_id`,`item_type`,`test_id`,`category_id`),
  KEY `idx_lookup` (`client_id`,`insurer_id`,`item_type`),
  KEY `idx_item_name` (`item_type`,`item_name`(100)),
  KEY `idx_test` (`test_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_bulk_rates_client_insurer` (`client_id`,`insurer_id`,`test_id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bulk_test_rates`
--

LOCK TABLES `bulk_test_rates` WRITE;
/*!40000 ALTER TABLE `bulk_test_rates` DISABLE KEYS */;
INSERT INTO `bulk_test_rates` VALUES (1,38,5,'test','FBS','',NULL,3500.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:48',35,NULL,0,0,NULL),(2,38,5,'test','HBA1C','','Full package',353500.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:49',36,NULL,0,0,NULL),(3,38,5,'test','HBEAG','',NULL,3500.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:48',63,NULL,0,0,NULL),(4,38,5,'test','HBsAg','',NULL,1100.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:49',64,NULL,0,0,NULL),(5,38,5,'test','Complete Blood Count','',NULL,1111.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:48',72,NULL,0,0,NULL),(6,38,5,'test','CBC & ESR','',NULL,322500.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:48',32,NULL,0,0,NULL),(7,38,5,'test','ANTI HCV','','Complete Blood Count',450.00,1,3,'2025-10-30 12:59:56','2025-11-08 09:24:35',62,NULL,0,0,2),(8,38,5,'test','LFT','',NULL,3500.00,1,3,'2025-10-30 12:59:56','2025-11-02 12:18:49',40,NULL,0,0,NULL),(9,38,5,'category','BSL-11',NULL,NULL,3500.00,1,3,'2025-10-30 12:59:56','2025-10-30 12:59:56',NULL,16,0,0,NULL),(10,38,5,'category','BSL-8',NULL,NULL,3500.00,1,3,'2025-10-30 12:59:56','2025-10-30 12:59:56',NULL,15,0,0,NULL),(11,42,20,'category','new categoryy333','CAT_21','dcccccc',3535353.00,1,2,'2025-10-31 04:56:23','2025-12-01 07:28:55',NULL,21,0,0,NULL),(12,38,5,'test','RUA',NULL,NULL,11.00,1,2,'2025-10-31 05:30:03','2025-10-31 05:35:44',69,NULL,1,0,NULL),(13,38,20,'test','RUA',NULL,'Blood test',450.00,1,2,'2025-11-02 12:18:49','2025-11-02 13:10:49',69,NULL,0,0,NULL),(14,38,5,'category','catru Adit',NULL,'adity descrip',3500.00,1,2,'2025-11-02 12:19:29','2025-12-01 07:56:25',NULL,22,0,0,NULL),(15,38,5,'test','RUA',NULL,NULL,444.00,1,2,'2025-11-05 12:02:02','2025-11-05 12:02:02',69,NULL,0,0,NULL),(16,44,63,'test','Complete Blood Count',NULL,NULL,232.00,1,2,'2025-11-05 12:29:39','2025-11-05 12:29:39',72,NULL,0,0,NULL),(17,44,63,'test','PFT','',NULL,0.00,1,2,'2025-11-05 12:29:39','2025-11-05 13:03:42',67,NULL,1,0,NULL),(18,44,63,'test','Complete Blood Count',NULL,NULL,232.00,1,2,'2025-11-05 12:30:43','2025-11-05 12:30:43',72,NULL,0,0,NULL),(19,44,63,'test','PFT',NULL,NULL,333.00,1,2,'2025-11-05 12:30:43','2025-11-05 12:55:28',67,NULL,1,0,NULL),(20,44,63,'test','Complete Blood Count','',NULL,232.00,1,2,'2025-11-05 12:33:06','2025-11-05 12:55:22',72,NULL,0,0,NULL),(21,44,63,'test','PFT','',NULL,333.00,0,2,'2025-11-05 12:33:06','2025-11-05 12:52:38',67,NULL,1,0,NULL),(22,44,63,'test','RUA','',NULL,44.55,1,2,'2025-11-05 12:40:55','2025-11-05 12:46:30',69,NULL,1,0,NULL),(24,43,63,'category','dsfdsf',NULL,'dsfdsf',23.00,1,NULL,'2025-11-06 10:05:04','2025-11-06 10:05:04',NULL,23,0,0,NULL),(25,43,65,'category','dsfds',NULL,'fsdfdsf',3434.22,1,NULL,'2025-11-06 10:09:08','2025-11-06 10:22:51',NULL,24,0,0,NULL),(26,43,58,'test','Complete Blood Count',NULL,NULL,34.00,1,2,'2025-11-06 10:30:17','2025-11-06 10:31:32',72,NULL,1,0,NULL),(32,42,20,'test','ANTI HCV','','Blood test',45.00,1,2,'2025-11-06 11:25:24','2025-11-08 10:31:24',62,NULL,0,0,NULL),(33,42,20,'category','new categoryy333',NULL,'Full package',3535353.00,1,2,'2025-11-06 11:25:24','2025-11-06 11:27:04',NULL,21,0,0,NULL),(34,47,70,'category','Combo1',NULL,'Combinations',500.00,1,NULL,'2025-11-10 05:15:25','2025-11-10 05:17:08',NULL,25,0,0,NULL),(35,38,5,'category','combo2',NULL,'fsdfdsf',1000.00,1,NULL,'2025-11-10 05:18:03','2025-12-05 12:03:12',NULL,26,0,0,NULL),(39,47,70,'category','new',NULL,'edhc',34.00,1,NULL,'2025-11-10 11:37:50','2025-11-10 11:37:50',NULL,27,0,0,NULL),(40,47,56,'test','Complete Blood Count (CBC)','',NULL,32.67,1,2,'2025-11-12 09:47:39','2025-11-13 05:37:14',86,NULL,0,0,NULL),(41,47,70,'category','er',NULL,'er',34.00,1,NULL,'2025-11-17 08:03:42','2025-11-17 08:03:42',NULL,28,0,0,NULL),(43,46,65,'test','Complete Blood Count (CBC)',NULL,'',42.12,1,17,'2025-11-19 12:39:02','2025-11-19 12:46:11',86,NULL,0,0,2),(44,46,69,'test','ANTI HCV',NULL,'',13.78,1,2,'2025-11-20 04:39:32','2025-11-20 04:50:20',62,NULL,0,0,2),(45,46,69,'test','cc',NULL,'',33.00,1,2,'2025-11-20 04:39:32','2025-11-20 04:50:20',82,NULL,0,1,2),(46,47,70,'category','fdsfds',NULL,'sdfds',343.00,1,NULL,'2025-11-20 07:24:52','2025-11-20 07:31:20',NULL,29,0,0,NULL),(47,38,65,'test','ANTI HCV',NULL,'',11.00,1,17,'2026-01-14 09:42:54','2026-01-14 09:42:54',62,NULL,0,0,NULL),(48,46,69,'test','dff',NULL,'',1111.00,1,17,'2026-01-14 09:46:40','2026-01-14 09:47:28',85,NULL,0,0,17),(49,44,69,'category','bbbbbbbbbfff',NULL,'bbbbbbbb',45.99,1,NULL,'2026-01-16 07:56:00','2026-02-05 06:21:08',NULL,30,0,0,NULL),(50,42,69,'category','qqqqq',NULL,'qqqqqq',22.88,1,NULL,'2026-01-16 08:00:37','2026-01-16 08:00:37',NULL,31,0,0,NULL),(51,46,63,'test','cc',NULL,NULL,11.00,1,17,'2026-01-16 10:12:13','2026-01-16 10:12:13',82,NULL,0,0,NULL),(52,46,63,'test','Complete Blood Count (CBC)',NULL,NULL,23.00,1,17,'2026-01-16 10:12:23','2026-01-16 10:12:23',86,NULL,0,0,NULL),(53,46,63,'test','ANTI HCV',NULL,NULL,45.55,1,17,'2026-01-16 10:12:29','2026-01-16 10:12:29',62,NULL,0,0,NULL),(54,46,69,'category','test',NULL,'test',11.00,1,NULL,'2026-02-05 06:21:27','2026-02-05 06:21:27',NULL,32,0,0,NULL),(55,47,69,'category','rgdfgfdgdfgdf',NULL,'gfdgfdgfd',454.00,1,NULL,'2026-02-09 05:38:10','2026-02-09 05:38:40',NULL,33,0,0,NULL);
/*!40000 ALTER TABLE `bulk_test_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bulk_upload_logs`
--

DROP TABLE IF EXISTS `bulk_upload_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bulk_upload_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_by` int NOT NULL,
  `upload_type` varchar(50) NOT NULL DEFAULT 'rates',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('success','partial','failed') DEFAULT 'success',
  `summary` json NOT NULL,
  `errors` json DEFAULT NULL,
  `file_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `processed_rows` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bulk_upload_logs`
--

LOCK TABLES `bulk_upload_logs` WRITE;
/*!40000 ALTER TABLE `bulk_upload_logs` DISABLE KEYS */;
INSERT INTO `bulk_upload_logs` VALUES (1,3,'rates','2025-10-30 12:59:56','partial','{\"total\": 12, \"errors\": 2, \"updated\": 0, \"inserted\": 10}','[{\"row\": 2, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}, {\"row\": 3, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}]','D:\\CRM\\back\\uploads\\logs\\2025-10-30T12-59-56-613Z_rates-upload-template__10_.xlsx','rates-upload-template (10).xlsx',12),(2,3,'rates','2025-10-31 05:50:04','failed','{\"total\": 1, \"errors\": 1, \"updated\": 0, \"inserted\": 0}','[{\"row\": 3, \"error\": \"Missing required fields\"}]','D:\\CRM\\back\\uploads\\logs\\2025-10-31T05-50-04-908Z_rates-upload-template__11_.xlsx','rates-upload-template (11).xlsx',1),(3,3,'rates','2025-10-31 05:50:23','success','{\"total\": 1, \"errors\": 0, \"updated\": 1, \"inserted\": 0}','[]','D:\\CRM\\back\\uploads\\logs\\2025-10-31T05-50-23-256Z_rates-upload-template__11_.xlsx','rates-upload-template (11).xlsx',1),(4,2,'rates','2025-10-31 11:02:56','failed','{\"total\": 2, \"errors\": 2, \"updated\": 0, \"inserted\": 0}','[{\"row\": 2, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}, {\"row\": 3, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}]','D:\\CRM\\back\\uploads\\logs\\2025-10-31T11-02-56-707Z_rates-upload-template__13_.xlsx','rates-upload-template (13).xlsx',2),(5,2,'rates','2025-10-31 11:03:43','failed','{\"total\": 2, \"errors\": 2, \"updated\": 0, \"inserted\": 0}','[{\"row\": 2, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}, {\"row\": 3, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}]','D:\\CRM\\back\\uploads\\logs\\2025-10-31T11-03-43-424Z_rates-upload-template__13_.xlsx','rates-upload-template (13).xlsx',2),(6,2,'rates','2025-10-31 11:16:18','failed','{\"total\": 2, \"errors\": 2, \"updated\": 0, \"inserted\": 0}','[{\"row\": 2, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}, {\"row\": 3, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}]','D:\\CRM\\back\\uploads\\logs\\2025-10-31T11-16-18-366Z_rates-upload-template__14_.xlsx','rates-upload-template (14).xlsx',2),(7,2,'rates','2025-11-02 13:07:20','failed','{\"total\": 2, \"errors\": 2, \"updated\": 0, \"inserted\": 0}','[{\"row\": 2, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}, {\"row\": 3, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}]','C:\\Users\\yashn\\OneDrive\\Desktop\\b\\uploads\\logs\\2025-11-02T13-07-20-766Z_rates-upload-template__15_.xlsx','rates-upload-template (15).xlsx',2),(8,2,'rates','2025-11-02 13:10:49','success','{\"total\": 2, \"errors\": 0, \"updated\": 2, \"inserted\": 0}','[]','C:\\Users\\yashn\\OneDrive\\Desktop\\b\\uploads\\logs\\2025-11-02T13-10-49-278Z_rates-upload-template__15_.xlsx','rates-upload-template (15).xlsx',2),(9,2,'rates','2025-11-05 13:04:29','failed','{\"total\": 2, \"errors\": 2, \"updated\": 0, \"inserted\": 0}','[{\"row\": 2, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}, {\"row\": 3, \"error\": \"Invalid Insurer Short Code: HDFC ERGO\"}]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-05T13-04-29-051Z_rates-upload-template__15_.xlsx','rates-upload-template (15).xlsx',2),(10,2,'rates','2025-11-06 10:39:07','success','{\"total\": 2, \"errors\": 0, \"updated\": 0, \"inserted\": 2}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T10-39-07-660Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(11,2,'rates','2025-11-06 10:40:15','success','{\"total\": 2, \"errors\": 0, \"updated\": 2, \"inserted\": 0}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T10-40-15-225Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(12,2,'rates','2025-11-06 10:56:54','success','{\"total\": 2, \"errors\": 0, \"updated\": 1, \"inserted\": 1}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T10-56-54-600Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(13,2,'rates','2025-11-06 10:57:14','success','{\"total\": 2, \"errors\": 0, \"updated\": 2, \"inserted\": 0}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T10-57-14-606Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(14,2,'rates','2025-11-06 11:05:40','success','{\"total\": 2, \"errors\": 0, \"updated\": 1, \"inserted\": 1}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T11-05-40-676Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(15,2,'rates','2025-11-06 11:07:08','success','{\"total\": 2, \"errors\": 0, \"updated\": 0, \"inserted\": 2}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T11-07-08-004Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(16,2,'rates','2025-11-06 11:13:46','success','{\"total\": 2, \"errors\": 0, \"updated\": 2, \"inserted\": 0}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T11-13-46-687Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(17,2,'rates','2025-11-06 11:25:24','success','{\"total\": 2, \"errors\": 0, \"updated\": 0, \"inserted\": 2}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-06T11-25-24-765Z_rates-upload-template__19_.xlsx','rates-upload-template (19).xlsx',2),(18,2,'rates','2025-11-08 09:23:15','success','{\"total\": 1, \"errors\": 0, \"updated\": 1, \"inserted\": 0}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\2025-11-08T09-23-15-961Z_rates-upload-template__22_.xlsx','rates-upload-template (22).xlsx',1),(19,2,'rates','2025-11-17 11:11:45','partial','{\"total_rows\": 1, \"new_records\": 0, \"processed_rows\": 1, \"updated_records\": 0, \"requires_approval\": true}','[]','uploads\\1763377905434-240881816-rates-upload-template (28).xlsx','rates-upload-template (28).xlsx',1),(20,2,'rates','2025-11-19 12:34:05','partial','{\"total_rows\": 1, \"new_records\": 0, \"processed_rows\": 1, \"updated_records\": 0, \"requires_approval\": true}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763555645144-699471444_rates-upload-template__29_.xlsx','rates-upload-template (29).xlsx',1),(21,2,'rates','2025-11-19 12:35:08','partial','{\"total_rows\": 1, \"new_records\": 0, \"processed_rows\": 1, \"updated_records\": 0, \"requires_approval\": true}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763555708832-399771610_rates-upload-template__29_.xlsx','rates-upload-template (29).xlsx',1),(23,17,'rates','2025-11-19 12:39:02','success','{\"total_rows\": 1, \"new_records\": 1, \"processed_rows\": 1, \"updated_records\": 0, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763555942090-902153050_rates-upload-template__29_.xlsx','rates-upload-template (29).xlsx',1),(24,17,'rates','2025-11-19 12:39:27','success','{\"total_rows\": 1, \"new_records\": 0, \"processed_rows\": 1, \"updated_records\": 1, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763555967879-154750143_rates-upload-template__29_.xlsx','rates-upload-template (29).xlsx',1),(25,2,'rates','2025-11-19 12:44:33','success','{\"total_rows\": 1, \"new_records\": 0, \"processed_rows\": 1, \"updated_records\": 1, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763556273836-558825493_rates-upload-template__29_.xlsx','rates-upload-template (29).xlsx',1),(26,2,'rates','2025-11-19 12:46:11','success','{\"total_rows\": 2, \"new_records\": 0, \"processed_rows\": 2, \"updated_records\": 1, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763556371273-808166051_rates-upload-template__29_.xlsx','rates-upload-template (29).xlsx',2),(27,2,'rates','2025-11-20 04:39:32','partial','{\"total_rows\": 2, \"new_records\": 2, \"processed_rows\": 2, \"updated_records\": 0, \"requires_approval\": true}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763613572137-545450836_rates-upload-template__30_.xlsx','rates-upload-template (30).xlsx',2),(28,2,'rates','2025-11-20 04:47:06','success','{\"total_rows\": 2, \"new_records\": 0, \"processed_rows\": 2, \"updated_records\": 2, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763614026633-83726148_rates-upload-template__30_.xlsx','rates-upload-template (30).xlsx',2),(29,2,'rates','2025-11-20 04:48:43','success','{\"total_rows\": 2, \"new_records\": 0, \"processed_rows\": 2, \"updated_records\": 2, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763614123709-616077926_rates-upload-template__30_.xlsx','rates-upload-template (30).xlsx',2),(30,2,'rates','2025-11-20 04:50:00','success','{\"total_rows\": 2, \"new_records\": 0, \"processed_rows\": 2, \"updated_records\": 2, \"requires_approval\": false}','[]','D:\\CRM\\main project\\b\\uploads\\logs\\1763614200671-463471156_rates-upload-template__30_.xlsx','rates-upload-template (30).xlsx',2),(31,17,'rates','2026-01-14 09:42:54','success','{\"total_rows\": 1, \"new_records\": 1, \"processed_rows\": 1, \"updated_records\": 0, \"requires_approval\": false}','[]','D:\\GITHUB\\CRM\\crm-backend\\uploads\\logs\\1768383774798-563455344_rates-upload-template__31_.xlsx','rates-upload-template (31).xlsx',1),(32,17,'rates','2026-01-14 09:46:40','success','{\"total_rows\": 1, \"new_records\": 1, \"processed_rows\": 1, \"updated_records\": 0, \"requires_approval\": false}','[]','D:\\GITHUB\\CRM\\crm-backend\\uploads\\logs\\1768384000248-164325718_rates-upload-template__31_.xlsx','rates-upload-template (31).xlsx',1),(33,17,'rates','2026-01-14 09:47:28','success','{\"total_rows\": 1, \"new_records\": 0, \"processed_rows\": 1, \"updated_records\": 1, \"requires_approval\": false}','[]','D:\\GITHUB\\CRM\\crm-backend\\uploads\\logs\\1768384048174-959330119_rates-upload-template__31_.xlsx','rates-upload-template (31).xlsx',1);
/*!40000 ALTER TABLE `bulk_upload_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `call_attempts`
--

DROP TABLE IF EXISTS `call_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `call_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `center_id` int NOT NULL COMMENT 'Center making the call attempt',
  `customer_number` varchar(20) NOT NULL,
  `attempt_type` enum('manual','scheduled','auto_retry') DEFAULT 'manual',
  `attempt_status` enum('initiated','in_progress','completed','failed') DEFAULT 'initiated',
  `call_log_id` int DEFAULT NULL COMMENT 'Reference to actual call log once call is made',
  `scheduled_at` datetime DEFAULT NULL COMMENT 'When call is scheduled for',
  `attempted_at` datetime DEFAULT NULL COMMENT 'When call attempt was made',
  `attempted_by` int DEFAULT NULL COMMENT 'User who initiated the call',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_appointment_id` (`appointment_id`),
  KEY `idx_center_id` (`center_id`),
  KEY `idx_attempt_status` (`attempt_status`),
  KEY `idx_scheduled_at` (`scheduled_at`),
  KEY `idx_attempted_by` (`attempted_by`),
  KEY `idx_call_log_id` (`call_log_id`),
  CONSTRAINT `fk_call_attempts_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_call_attempts_call_log` FOREIGN KEY (`call_log_id`) REFERENCES `call_logs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_call_attempts_center` FOREIGN KEY (`center_id`) REFERENCES `diagnostic_centers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_call_attempts_user` FOREIGN KEY (`attempted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Track call attempts for appointments';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `call_attempts`
--

LOCK TABLES `call_attempts` WRITE;
/*!40000 ALTER TABLE `call_attempts` DISABLE KEYS */;
INSERT INTO `call_attempts` VALUES (1,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 12:40:31',21,NULL,'2026-02-03 07:10:31','2026-02-03 07:10:32'),(2,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 12:41:31',21,NULL,'2026-02-03 07:11:31','2026-02-03 07:11:31'),(3,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 12:43:15',21,NULL,'2026-02-03 07:13:15','2026-02-03 07:13:15'),(4,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 12:55:48',21,NULL,'2026-02-03 07:25:48','2026-02-03 07:25:49'),(5,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 13:12:18',21,NULL,'2026-02-03 07:42:18','2026-02-03 07:42:19'),(6,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 14:38:41',21,NULL,'2026-02-03 09:08:41','2026-02-03 09:08:42'),(7,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 14:39:44',21,NULL,'2026-02-03 09:09:44','2026-02-03 09:09:44'),(8,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:11:57',21,NULL,'2026-02-03 09:41:57','2026-02-03 09:41:58'),(9,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:27:22',21,NULL,'2026-02-03 09:57:22','2026-02-03 09:57:22'),(10,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:29:53',21,NULL,'2026-02-03 09:59:53','2026-02-03 09:59:53'),(11,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:35:11',21,NULL,'2026-02-03 10:05:11','2026-02-03 10:05:12'),(12,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:35:40',21,NULL,'2026-02-03 10:05:40','2026-02-03 10:05:40'),(13,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:36:23',21,NULL,'2026-02-03 10:06:23','2026-02-03 10:06:23'),(14,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:43:26',21,NULL,'2026-02-03 10:13:26','2026-02-03 10:13:26'),(15,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:46:01',21,NULL,'2026-02-03 10:16:01','2026-02-03 10:16:01'),(16,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:50:23',21,NULL,'2026-02-03 10:20:23','2026-02-03 10:20:23'),(17,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 15:51:02',21,NULL,'2026-02-03 10:21:02','2026-02-03 10:21:02'),(18,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:01:32',21,NULL,'2026-02-03 10:31:32','2026-02-03 10:31:32'),(19,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:02:59',21,NULL,'2026-02-03 10:32:59','2026-02-03 10:32:59'),(20,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:05:20',21,NULL,'2026-02-03 10:35:20','2026-02-03 10:35:21'),(21,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:15:44',21,NULL,'2026-02-03 10:45:44','2026-02-03 10:45:47'),(22,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:16:16',21,NULL,'2026-02-03 10:46:16','2026-02-03 10:46:16'),(23,27,20,'9226716071','manual','initiated',NULL,NULL,'2026-02-03 16:17:26',21,NULL,'2026-02-03 10:47:26','2026-02-03 10:47:26'),(24,27,20,'9226716071','manual','initiated',NULL,NULL,'2026-02-03 16:17:45',21,NULL,'2026-02-03 10:47:45','2026-02-03 10:47:45'),(25,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:27:19',21,NULL,'2026-02-03 10:57:19','2026-02-03 10:57:19'),(26,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:35:59',21,NULL,'2026-02-03 11:05:59','2026-02-03 11:05:59'),(27,27,20,'919226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:36:18',21,NULL,'2026-02-03 11:06:18','2026-02-03 11:06:18'),(28,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 16:40:12',21,NULL,'2026-02-03 11:10:12','2026-02-03 11:10:13'),(29,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 17:26:19',17,NULL,'2026-02-03 11:56:19','2026-02-03 11:56:21'),(30,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 17:29:47',21,NULL,'2026-02-03 11:59:47','2026-02-03 11:59:47'),(31,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 17:41:29',21,NULL,'2026-02-03 12:11:29','2026-02-03 12:11:30'),(32,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 17:42:36',21,NULL,'2026-02-03 12:12:36','2026-02-03 12:12:38'),(33,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 17:44:29',21,NULL,'2026-02-03 12:14:29','2026-02-03 12:14:29'),(34,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 17:45:52',21,NULL,'2026-02-03 12:15:52','2026-02-03 12:15:52'),(35,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 18:00:51',21,NULL,'2026-02-03 12:30:51','2026-02-03 12:30:52'),(36,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 18:03:00',21,NULL,'2026-02-03 12:33:00','2026-02-03 12:33:00'),(37,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 18:06:13',21,NULL,'2026-02-03 12:36:13','2026-02-03 12:36:13'),(38,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 18:09:12',21,NULL,'2026-02-03 12:39:12','2026-02-03 12:39:13'),(39,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 18:10:34',21,NULL,'2026-02-03 12:40:34','2026-02-03 12:40:34'),(40,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-03 18:11:49',21,NULL,'2026-02-03 12:41:49','2026-02-03 12:41:49'),(41,8,20,'919876543210','manual','in_progress',NULL,NULL,'2026-02-04 16:38:08',17,NULL,'2026-02-04 11:08:08','2026-02-04 11:08:09'),(42,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-09 14:54:36',21,NULL,'2026-02-09 09:24:36','2026-02-09 09:24:36'),(43,27,20,'9226716071','manual','in_progress',NULL,NULL,'2026-02-09 14:55:40',21,NULL,'2026-02-09 09:25:40','2026-02-09 09:25:40');
/*!40000 ALTER TABLE `call_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `call_logs`
--

DROP TABLE IF EXISTS `call_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `call_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `call_id` varchar(100) NOT NULL COMMENT 'Unique call identifier from telephony system',
  `appointment_id` int DEFAULT NULL COMMENT 'Related appointment if applicable',
  `center_id` int DEFAULT NULL COMMENT 'Diagnostic center that made/received the call',
  `call_type` enum('incoming','outgoing') NOT NULL COMMENT 'Direction of call',
  `disposition` enum('answered','missed','busy','failed','no_answer') NOT NULL COMMENT 'Call outcome',
  `call_duration` int DEFAULT '0' COMMENT 'Duration in seconds',
  `agent_number` varchar(20) DEFAULT NULL COMMENT 'Phone number of agent/center',
  `customer_number` varchar(20) NOT NULL COMMENT 'Customer phone number',
  `virtual_number` varchar(20) DEFAULT NULL COMMENT 'DID/Virtual number used',
  `recording_url` text COMMENT 'URL to call recording if available',
  `start_time` datetime DEFAULT NULL COMMENT 'Call start timestamp',
  `end_time` datetime DEFAULT NULL COMMENT 'Call end timestamp',
  `received_by` varchar(100) DEFAULT NULL COMMENT 'Agent name who received call',
  `transferred_to` varchar(255) DEFAULT NULL COMMENT 'Agents call was transferred to',
  `handle_time` int DEFAULT NULL COMMENT 'Total handle time in milliseconds',
  `hold_time` int DEFAULT NULL COMMENT 'Total hold time in milliseconds',
  `hangup_by` enum('customer','agent','system') DEFAULT NULL COMMENT 'Who ended the call',
  `service_id` varchar(50) DEFAULT NULL COMMENT 'Telephony service identifier',
  `skill_id` varchar(50) DEFAULT NULL COMMENT 'Queue/Skill identifier',
  `ivr_inputs` text COMMENT 'IVR inputs collected',
  `custom_param` varchar(255) DEFAULT NULL COMMENT 'Custom parameter (param1)',
  `metadata` json DEFAULT NULL COMMENT 'Additional call metadata',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_call_id` (`call_id`),
  KEY `idx_appointment_id` (`appointment_id`),
  KEY `idx_center_id` (`center_id`),
  KEY `idx_customer_number` (`customer_number`),
  KEY `idx_call_type_disposition` (`call_type`,`disposition`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_call_logs_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_call_logs_center` FOREIGN KEY (`center_id`) REFERENCES `diagnostic_centers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Call logs from telephony system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `call_logs`
--

LOCK TABLES `call_logs` WRITE;
/*!40000 ALTER TABLE `call_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `call_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_test_mapping`
--

DROP TABLE IF EXISTS `category_test_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category_test_mapping` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_test_id` int NOT NULL,
  `single_test_id` int NOT NULL,
  `is_mandatory` tinyint(1) DEFAULT '1',
  `display_order` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_category_test` (`category_test_id`,`single_test_id`),
  KEY `single_test_id` (`single_test_id`),
  CONSTRAINT `category_test_mapping_ibfk_2` FOREIGN KEY (`single_test_id`) REFERENCES `tests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_category_test_mapping_category` FOREIGN KEY (`category_test_id`) REFERENCES `test_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_test_mapping`
--

LOCK TABLES `category_test_mapping` WRITE;
/*!40000 ALTER TABLE `category_test_mapping` DISABLE KEYS */;
INSERT INTO `category_test_mapping` VALUES (75,23,69,1,0),(76,23,68,1,0),(79,24,68,1,0),(80,24,69,1,0),(84,25,86,1,0),(85,25,83,1,0),(86,25,68,1,0),(94,21,67,1,0),(95,21,68,1,0),(96,21,69,1,0),(105,22,68,1,0),(106,22,69,1,0),(131,26,83,1,0),(132,26,85,1,0),(133,26,86,1,0);
/*!40000 ALTER TABLE `category_test_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_insurers`
--

DROP TABLE IF EXISTS `client_insurers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_insurers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `insurer_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `insurer_id` (`insurer_id`),
  CONSTRAINT `client_insurers_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `client_insurers_ibfk_2` FOREIGN KEY (`insurer_id`) REFERENCES `insurers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=184 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_insurers`
--

LOCK TABLES `client_insurers` WRITE;
/*!40000 ALTER TABLE `client_insurers` DISABLE KEYS */;
INSERT INTO `client_insurers` VALUES (16,22,20,'2025-10-14 07:47:14','2025-10-14 07:47:14'),(17,22,43,'2025-10-14 07:47:14','2025-10-14 07:47:14'),(18,22,39,'2025-10-14 07:47:14','2025-10-14 07:47:14'),(20,23,7,'2025-10-14 10:21:10','2025-10-14 10:21:10'),(21,5,5,'2025-10-15 09:34:14','2025-10-15 09:34:14'),(22,5,6,'2025-10-15 09:35:01','2025-10-15 09:35:01'),(23,5,7,'2025-10-15 10:07:32','2025-10-15 10:07:32'),(24,23,6,'2025-10-15 10:32:49','2025-10-15 10:32:49'),(25,23,5,'2025-10-15 10:32:49','2025-10-15 10:32:49'),(27,23,8,'2025-10-15 10:42:31','2025-10-15 10:42:31'),(28,23,9,'2025-10-15 10:42:31','2025-10-15 10:42:31'),(29,23,10,'2025-10-15 10:43:07','2025-10-15 10:43:07'),(30,23,11,'2025-10-15 10:43:07','2025-10-15 10:43:07'),(31,23,12,'2025-10-15 10:43:07','2025-10-15 10:43:07'),(61,41,63,'2025-10-16 10:39:19','2025-10-16 10:39:19'),(94,43,63,'2025-11-03 06:00:07','2025-11-03 06:00:07'),(95,43,58,'2025-11-03 06:00:07','2025-11-03 06:00:07'),(96,44,63,'2025-11-03 06:01:32','2025-11-03 06:01:32'),(106,38,67,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(107,38,66,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(108,38,65,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(109,38,63,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(110,38,58,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(111,38,57,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(112,38,56,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(113,38,55,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(114,38,54,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(115,38,53,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(116,38,52,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(117,38,51,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(118,38,50,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(119,38,22,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(120,38,20,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(121,38,17,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(122,38,16,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(123,38,5,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(124,38,49,'2025-11-04 11:30:32','2025-11-04 11:30:32'),(131,45,63,'2025-11-06 07:18:20','2025-11-06 07:18:20'),(134,42,57,'2025-11-06 10:38:51','2025-11-06 10:38:51'),(135,42,56,'2025-11-06 10:38:51','2025-11-06 10:38:51'),(136,42,20,'2025-11-06 10:38:51','2025-11-06 10:38:51'),(159,47,65,'2025-11-10 05:05:09','2025-11-10 05:05:09'),(160,47,58,'2025-11-10 05:05:09','2025-11-10 05:05:09'),(161,47,56,'2025-11-10 05:05:09','2025-11-10 05:05:09'),(169,46,65,'2025-11-19 12:45:13','2025-11-19 12:45:13'),(170,46,63,'2025-11-19 12:45:13','2025-11-19 12:45:13'),(171,46,69,'2025-11-19 12:45:13','2025-11-19 12:45:13'),(172,48,70,'2025-11-20 06:31:29','2025-11-20 06:31:29'),(173,48,69,'2025-11-20 06:31:29','2025-11-20 06:31:29'),(174,48,65,'2025-11-20 06:31:29','2025-11-20 06:31:29'),(175,48,63,'2025-11-20 06:31:29','2025-11-20 06:31:29'),(176,56,70,'2025-11-20 06:44:21','2025-11-20 06:44:21'),(177,56,69,'2025-11-20 06:44:21','2025-11-20 06:44:21'),(178,56,65,'2025-11-20 06:44:21','2025-11-20 06:44:21'),(179,56,63,'2025-11-20 06:44:21','2025-11-20 06:44:21'),(180,57,70,'2025-11-20 06:52:34','2025-11-20 06:52:34'),(181,57,69,'2025-11-20 06:52:34','2025-11-20 06:52:34'),(182,57,65,'2025-11-20 06:52:34','2025-11-20 06:52:34'),(183,57,63,'2025-11-20 06:52:34','2025-11-20 06:52:34');
/*!40000 ALTER TABLE `client_insurers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_code` varchar(50) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `client_type` varchar(100) DEFAULT NULL,
  `registered_address` text,
  `gst_number` varchar(20) DEFAULT NULL,
  `pan_number` varchar(10) DEFAULT NULL,
  `mode_of_payment` varchar(55) DEFAULT NULL,
  `payment_frequency` varchar(55) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `state` varchar(45) DEFAULT NULL,
  `city` varchar(45) DEFAULT NULL,
  `pincode` varchar(45) DEFAULT NULL,
  `country` varchar(45) DEFAULT NULL,
  `email_id` varchar(45) DEFAULT NULL,
  `email_id_2` varchar(45) DEFAULT NULL,
  `email_id_3` varchar(45) DEFAULT NULL,
  `contact_person_name` varchar(45) DEFAULT NULL,
  `contact_person_no` varchar(45) DEFAULT NULL,
  `contact_person_address` varchar(455) DEFAULT NULL,
  `onboarding_date` datetime DEFAULT NULL,
  `agreement_id` varchar(45) DEFAULT NULL,
  `validity_period_start` date DEFAULT NULL,
  `validity_period_end` date DEFAULT NULL,
  `invoice_format_upload` longtext,
  `mou` varchar(45) DEFAULT NULL,
  `IRDAI_no` varchar(45) DEFAULT NULL,
  `short_code` varchar(45) DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `clients_ibfk_2_idx` (`created_by`),
  KEY `clients_ibfk_3_idx` (`updated_by`),
  CONSTRAINT `clients_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `clients_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `clients_ibfk_3` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (24,'TPA/10/0001','1 MG',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(25,'TPA/10/0002','Anmol TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(26,'TPA/10/0003','Call Health TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(27,'TPA/10/0004','Call Medilife TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(28,'TPA/10/0005','E Cure',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(29,'TPA/10/0006','Ericsson TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(30,'TPA/10/0007','Get Visit',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(31,'TPA/10/0008','GOWELNEXT Solutions Pvt Ltd',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(32,'INS/08/0009','Health Assure TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:07:46',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(33,'TPA/10/0010','Health India TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(34,'TPA/10/0011','MD India TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(35,'TPA/10/0012','Medibuddy TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(36,'TPA/10/0013','Medpiper TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(37,'TPA/10/0014','Volo Health Insurance TPA',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2025-10-16 05:05:53','2025-10-16 05:25:06',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(38,'TPA/10/0015','Test TPA','Corporate','customers address','GST1234567RT123','PAN1234567','Credit','90',1,2,'2025-10-16 05:19:04','2025-11-04 11:30:32',0,0,'Chhattisgarh','Kolkata','455678','IN','p@gmail.com','s@gmail.com','t@gmail.com','udit','5656565656','adress of contact ppersone','2025-10-16 00:00:00','ATEST1','2025-10-01','2025-10-30','uploads\\1760591943988-977419594-Minutes of Meeting-10 OCT.pdf','MOUTEST123','IRDAI TEST1122','TPA',2),(40,'TPA/10/0016','cv','TPA','',NULL,NULL,'Advance','30',1,2,'2025-10-16 10:36:26','2025-10-16 10:36:59',1,0,NULL,NULL,NULL,'IN',NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-17 05:30:00',NULL,'2025-10-18','2025-10-17',NULL,NULL,NULL,NULL,NULL),(41,'TPA/10/0016','wewewefdsf','Corporate','dfdsfdfdsfdsfsdfsdfd dfdsfsd','dddddddddd33333','dddddddddd','Advance','60',1,2,'2025-10-16 10:38:32','2025-10-16 10:39:26',1,0,'Goa','dsdsdsdsdsd','222222','IN','r@gmail.com','r@gmail.com','r@gmail.com','gghh','3333333333','fdsfdsf dfds fds fdsfsd','2025-10-17 05:30:00','ewew232dsf','2025-10-03','2025-10-22','uploads\\1760611112725-796179227-Motogp24 Screenshot 2024.11.07 - 23.19.35.24.png','sdd2323fsd','sde23',NULL,NULL),(42,'TPA/10/0016','tesst','Corporate','',NULL,NULL,'Advance','30',1,2,'2025-10-21 07:45:16','2025-11-06 10:38:51',0,0,NULL,NULL,NULL,'IN',NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-23 00:00:00',NULL,'2025-10-22','2025-10-30',NULL,NULL,NULL,'ADTV',2),(43,'TPA/11/0001','newttppaa','Aggregator','full address','GST1234567RT123','PAN1234567','Advance','30',1,15,'2025-11-03 05:58:26','2025-11-03 06:00:07',0,0,'Assam','uaaa','110001','IN','p@gmail.com','s@gmail.com','t@gmail.com','udit','5656565656','adress of contact ppersone','2025-11-04 05:30:00','ATEST1','2025-11-04','2025-11-06',NULL,'MOUTEST123','IRDAI TEST1122',NULL,15),(44,'TPA/11/0002','acc holde rname','Corporate','full address','111111111111111',NULL,'Advance','30',1,15,'2025-11-03 06:01:32','2025-11-03 06:01:32',0,0,NULL,'uaaa','110001','IN',NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-13 05:30:00',NULL,'2025-11-13','2025-11-20',NULL,NULL,NULL,NULL,NULL),(45,'TPA/11/0003','acc holde rnamevvv','Corporate','dsfsdf',NULL,NULL,'Advance','30',1,15,'2025-11-03 06:12:16','2025-11-06 09:57:42',1,0,'Arunachal Pradesh','uaaa','110001','IN',NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-13 00:00:00',NULL,'2025-11-13','2025-11-20','uploads/clients/1762413491742-832364944.png',NULL,NULL,'AVDDD',2),(46,'TPA/11/0003','neww','Corporate','jj',NULL,NULL,'Advance','30',1,20,'2025-11-07 04:40:50','2025-11-19 12:45:13',0,0,'Arunachal Pradesh','sdfds','333333','IN','jo@gmail.com','jo@gmail.com','jo@gmail.com','joe','joe','jj','2025-11-22 00:00:00',NULL,'2025-11-23','2025-11-24','uploads/clients/1762768530083-689883907.jpg',NULL,NULL,'new',2),(47,'TPA/11/0004','JW','TPA','megacenter 411028','27AAAAA1111A5ZK','AAAAA1111A','Advance','30',1,2,'2025-11-10 05:05:08','2025-11-10 05:06:15',0,0,'Maharashtra','pune','411028','IN','jw1@gmail.com','jw2@gmail.com','jw3@gmail.com','Johny Depp','9764493399','Pune 411028','2025-11-11 00:00:00','Q-101','2025-11-11','2026-11-10','uploads/clients/1762751108986-666331474.pdf',NULL,'A1234','Johny walker ',NULL),(48,'CLI/11/0001','ytpa','Corporate',NULL,'324324342343244','DSFSDFDSFS','Advance','30',1,2,'2025-11-20 06:31:29','2025-11-20 06:36:54',1,0,'Assam','unmaaa','435345','IN',NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-21 00:00:00',NULL,'2025-11-21','2025-11-22','uploads/clients/1763620289898-762157070.pdf','DSFSDF','DSFDS43','YTPA',NULL),(56,'CLI/11/0001','ytpa','Corporate','cvxvcxv','543543543543543','DSFSDFDSFS','Advance','30',1,2,'2025-11-20 06:44:21','2025-11-20 06:52:06',1,0,'Arunachal Pradesh','unmaaa','435345','IN','er@gmail.com','er@gmail.com','er@gmail.com','test name tet ;last name','4353453453','full address','2025-11-21 00:00:00',NULL,'2025-11-22','2025-11-23','uploads/clients/1763621061724-175096169.png','DSFSDF','DSFDS43','YTPA',NULL),(57,'TPA/11/0005','ytpa','Corporate','gfhgfhgfh','543543543543543','DSFSDFDSFS','Advance','30',1,2,'2025-11-20 06:52:34','2025-11-20 06:53:15',1,0,'Arunachal Pradesh','unmaaa','435345','IN','er@gmail.com','er@gmail.com','er@gmail.com','test name tet ;last name','4353453453','full address','2025-11-22 00:00:00','dfsdfsdf','2025-11-22','2025-11-22',NULL,'DSFSDF','DSFDS43','YTPA',NULL);
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diagnostic_centers`
--

DROP TABLE IF EXISTS `diagnostic_centers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnostic_centers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `center_code` varchar(50) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `center_name` varchar(255) NOT NULL,
  `center_type` varchar(55) DEFAULT NULL,
  `address` text,
  `owner_name` varchar(45) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `city_type` varchar(45) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `pincode` longtext,
  `country` varchar(45) DEFAULT NULL,
  `dc_photos` longtext,
  `gps_latitude` decimal(10,8) DEFAULT NULL,
  `gps_longitude` decimal(11,8) DEFAULT NULL,
  `letterhead_path` longtext,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `associate_doctor_1_details` json DEFAULT NULL,
  `associate_doctor_2_details` json DEFAULT NULL,
  `associate_doctor_3_details` json DEFAULT NULL,
  `associate_doctor_4_details` json DEFAULT NULL,
  `acc_name` varchar(105) DEFAULT NULL,
  `acc_no` varchar(105) DEFAULT NULL,
  `ifsc_code` varchar(105) DEFAULT NULL,
  `receivers_name` varchar(105) DEFAULT NULL,
  `branch_name` varchar(45) DEFAULT NULL,
  `accredation` varchar(105) DEFAULT NULL,
  `associate_doctor_1_id` int DEFAULT NULL,
  `associate_doctor_2_id` int DEFAULT NULL,
  `associate_doctor_3_id` int DEFAULT NULL,
  `associate_doctor_4_id` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `telephony_enabled` tinyint(1) DEFAULT '0' COMMENT 'Whether telephony is enabled for this center',
  `telephony_agent_number` varchar(20) DEFAULT NULL COMMENT 'Primary phone number for outbound calls',
  `telephony_service_id` varchar(50) DEFAULT NULL COMMENT 'SparkTG service ID for this center',
  `telephony_config` json DEFAULT NULL COMMENT 'Additional telephony configuration',
  PRIMARY KEY (`id`),
  KEY `fk_user_id` (`user_id`),
  KEY `associate_doctor_1_id` (`associate_doctor_1_id`),
  KEY `associate_doctor_2_id` (`associate_doctor_2_id`),
  KEY `associate_doctor_3_id` (`associate_doctor_3_id`),
  KEY `associate_doctor_4_id` (`associate_doctor_4_id`),
  KEY `diagnostic_centers_ibfk_5_idx` (`updated_by`),
  KEY `diagnostic_centers_ibfk_6_idx` (`created_by`),
  KEY `idx_telephony_enabled` (`telephony_enabled`),
  CONSTRAINT `diagnostic_centers_ibfk_1` FOREIGN KEY (`associate_doctor_1_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `diagnostic_centers_ibfk_2` FOREIGN KEY (`associate_doctor_2_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `diagnostic_centers_ibfk_3` FOREIGN KEY (`associate_doctor_3_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `diagnostic_centers_ibfk_4` FOREIGN KEY (`associate_doctor_4_id`) REFERENCES `doctors` (`id`),
  CONSTRAINT `diagnostic_centers_ibfk_5` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `diagnostic_centers_ibfk_6` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diagnostic_centers`
--

LOCK TABLES `diagnostic_centers` WRITE;
/*!40000 ALTER TABLE `diagnostic_centers` DISABLE KEYS */;
INSERT INTO `diagnostic_centers` VALUES (5,'DC0001',7,'Kumar Diagnostic Center','Third_Party','Nariman Point, Mumbai',NULL,'9999999999','reliance@elec.com','Mumbai',NULL,'Maharashtra','400021',NULL,NULL,NULL,NULL,NULL,1,2,'2025-10-09 06:28:06','2025-10-09 06:43:32',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL),(6,'DC002',10,'Shelll Diagnostic center','Own','ffff',NULL,'9999999999','ee@gmail.com','pune',NULL,'mh','411028',NULL,NULL,NULL,NULL,NULL,1,2,'2025-10-09 08:07:44','2025-10-09 09:20:42',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL),(10,'DC/10/0001',NULL,'newdcgg','Non Premium','fgfgfgfgfgf g fg f gfg f44t4 tt4',NULL,'7777777777','ee@gmail.com','Kolkata',NULL,'Arunachal Pradesh','411111','IN','[\"uploads\\\\1760440162483-106476657-Motogp24 Screenshot 2024.11.07 - 23.32.35.15.png\",\"uploads\\\\1760440162526-134738305-Motogp24 Screenshot 2024.12.05 - 22.21.17.90.png\",\"uploads\\\\1760440162552-413053908-Motogp24 Screenshot 2024.12.05 - 22.49.46.64.png\"]',NULL,NULL,NULL,1,2,'2025-10-14 11:09:22','2025-10-16 06:59:41',1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL),(11,'DC/10/0002',NULL,'rtttr','Premium','dfdf df d fd f df 3 44 34 ',NULL,'6666666666','A@gmail.com','wewew',NULL,'Assam','333333','IN','[\"uploads\\\\1760442936051-72217570-Motogp24 Screenshot 2024.11.07 - 23.19.35.24.png\",\"uploads\\\\1760442936071-387098205-Motogp24 Screenshot 2024.11.07 - 23.27.08.99.png\",\"uploads\\\\1760442936121-949943484-Motogp24 Screenshot 2024.11.07 - 23.30.46.54.png\",\"uploads\\\\1760442936162-715357322-Motogp24 Screenshot 2024.11.07 - 23.15.12.88.png\",\"uploads\\\\1760442936201-951509084-Motogp24 Screenshot 2024.11.07 - 23.15.33.77.png\",\"uploads\\\\1760442936234-110895913-Motogp24 Screenshot 2024.11.07 - 23.31.11.20.png\",\"uploads\\\\1760442936265-644606387-Motogp24 Screenshot 2024.11.07 - 23.32.35.15.png\"]',NULL,NULL,'uploads\\1760442936290-372543323-.trashed-1736252251-Mount & Blade II  Bannerlord Screenshot 2024.11.26 - 00.16.39.18.png',1,2,'2025-10-14 11:51:37','2025-10-16 06:59:41',1,0,NULL,'{\"address\": \"fdfd\", \"email_id\": \"rdfdfdfff@gmail.com\", \"mobile_no\": \"3333333363\", \"doctor_name\": \"ytytytfdfdfdfdfd\", \"registration_no\": \"fdf43\"}',NULL,NULL,'acnamefff','acc1','fscsc23','receiver nameee',NULL,'2323ddsdsdsd',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL),(12,'DC/10/0003',14,'TEST DC','Premium','full address of customer','owners name','4444444444','test@gmail.com','pune','Tier 2','Punjab','4444444','IN','[\"uploads\\\\1760592515083-168272117-Motogp24 Screenshot 2024.12.05 - 22.49.25.00.png\",\"uploads\\\\1760592515123-265749623-Motogp24 Screenshot 2024.12.05 - 22.49.46.64.png\",\"uploads\\\\1760592515155-340670135-Motogp24 Screenshot 2024.12.05 - 22.57.44.33.png\",\"uploads\\\\1760592515196-691217737-Motogp24 Screenshot 2024.12.05 - 22.58.30.97.png\"]',NULL,NULL,'uploads/centers/1762771526397-394783556.png',1,2,'2025-10-16 05:28:35','2025-11-10 10:45:52',0,0,'{\"address\": \"address of doctor\", \"email_id\": \"testdoc@gmail.com\", \"mobile_no\": \"4444444444\", \"doctor_name\": \"doc name test\", \"registration_no\": \"reg23456test\"}',NULL,NULL,NULL,'acc holde rname','acc no245677','isfc3456','rohit',NULL,'3434',NULL,NULL,NULL,NULL,2,0,NULL,NULL,NULL),(13,'DC/10/0004',NULL,'T2','Non Premium','fdfd fdf dfdf d',NULL,'6666666666','a@gmail.com','ffffff',NULL,'Arunachal Pradesh','211111','IN','[\"uploads\\\\1760607296851-692728025-.trashed-1736252251-Mount & Blade II  Bannerlord Screenshot 2024.11.26 - 00.16.39.18.png\",\"uploads\\\\1760607296868-766694748-Motogp24 Screenshot 2024.11.07 - 22.36.30.99.png\"]',NULL,NULL,'uploads\\1760607296892-98556927-Minutes of Meeting-10 OCT.pdf',1,2,'2025-10-16 09:34:36','2025-10-16 10:32:55',1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL),(17,'DC/10/0004',NULL,'TEST DC','Premium','customers address','owners name','4444444444','john.doe@email.com','Kolkata','Tier 3','Arunachal Pradesh','455678','IN','[\"uploads\\\\1760611271970-269778425-Motogp24 Screenshot 2024.11.07 - 23.19.35.24.png\",\"uploads\\\\1760611272008-454954026-Motogp24 Screenshot 2024.11.07 - 23.27.08.99.png\",\"uploads\\\\1760611272037-888906100-Motogp24 Screenshot 2024.11.07 - 23.30.46.54.png\"]',NULL,NULL,'uploads\\1760611272067-75937333-Motogp24 Screenshot 2024.11.07 - 23.27.08.99.png',1,2,'2025-10-16 10:35:00','2025-10-16 10:41:24',1,0,NULL,NULL,NULL,NULL,'acc holde rname','acc no245677','isfc3456','rohit',NULL,'acc2344tt',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL),(18,'DC/10/0004',NULL,'UTC DC','Premium','full address of customer','UTC name','4444444444','test@gmail.com','pune','Tier 2','Arunachal Pradesh','444443','IN',NULL,NULL,NULL,'uploads/centers/1762773487215-407913873.pdf',1,2,'2025-10-29 07:01:59','2025-11-17 12:13:11',0,0,NULL,NULL,NULL,NULL,'acc holde rname','acc no245677','isfc3456','rohit','pune','3434',2,NULL,NULL,NULL,2,0,NULL,NULL,NULL),(19,'DC/11/0001',15,'new test dc','Non Premium','dsfdsfsdfdsfds','dcdc','4444444444','w@gmail.com','hhhooo','Tier 2','Assam','555555','IN','[\"uploads/centers/1762410953926-66946120.jpg\",\"uploads/centers/1762410953941-261825878.png\"]',NULL,NULL,NULL,1,15,'2025-11-03 05:53:32','2025-11-06 09:56:32',1,0,NULL,NULL,NULL,NULL,'acc holde rname','acc no245677','isfc3456','rohit','pune','3434',2,1,NULL,NULL,2,0,NULL,NULL,NULL),(20,'DC/11/0001',21,'Iconic ','Premium','B-509/megacenter, near nobel hospital,411028','Nikhil Pawar','9403099089','nikhilpawarsitsolutions@gmail.com','pune','Tier 1','Maharashtra','411028','IN','[]',NULL,NULL,'uploads/centers/1766574904445-844943333.jpg',1,2,'2025-11-10 04:30:19','2026-02-04 11:49:22',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'abc',NULL,NULL,NULL,NULL,NULL,1,'9403099089',NULL,NULL),(21,'DC/11/0002',NULL,'yDC','Premium','full address','ydc','3333333333','er@gmail.com','unmaaa','Tier 2','Maharashtra','333333','IN','[{\"originalname\":\"440.jpg\",\"size\":2268156},{\"originalname\":\"dc2.jpg\",\"size\":435693}]',NULL,NULL,NULL,1,2,'2025-11-20 06:02:22','2025-11-20 06:21:25',1,0,NULL,NULL,NULL,NULL,'neww','4354','27AAAAA1111','test name tet ;last name','Doe','dfgd45345',3,2,NULL,NULL,NULL,0,NULL,NULL,NULL),(22,'DC/11/0002',NULL,'yDC','Non Premium','ccvcxvcxvxcv','ydc','3333333333','er@gmail.com','unmaaa','Tier 1','Bihar','333333','IN','[\"uploads/centers/1770615899428-892554326.png\",\"uploads/centers/1770616324242-31138045.png\",\"uploads/centers/1770616337860-733558836.jpg\"]',NULL,NULL,'uploads/centers/1763619922498-844720075.png',1,2,'2025-11-20 06:24:26','2026-02-09 05:52:17',0,0,NULL,NULL,NULL,NULL,'neww','4354','27AAAAA1111','test name tet ;last name','Doe','dfgd45345',2,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `diagnostic_centers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `doctor_name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `registration_number` varchar(100) NOT NULL,
  `qualification` varchar(255) DEFAULT NULL,
  `specialization` varchar(255) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `aadhar_number` varchar(20) DEFAULT NULL,
  `aadhar_doc_path` longtext,
  `pan_number` varchar(20) DEFAULT NULL,
  `pan_doc_path` longtext,
  `profile_photo_path` longtext,
  `address` text,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `pincode` varchar(15) DEFAULT NULL,
  `country` varchar(100) DEFAULT 'IN',
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `acc_name` varchar(105) DEFAULT NULL,
  `acc_no` varchar(105) DEFAULT NULL,
  `ifsc_code` varchar(105) DEFAULT NULL,
  `receivers_name` varchar(105) DEFAULT NULL,
  `branch_name` varchar(105) DEFAULT NULL,
  `educational_certificates` json DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `doctors_ibfk_2_idx` (`created_by`),
  KEY `doctors_ibfk_3_idx` (`updated_by`),
  CONSTRAINT `doctors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `doctors_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `doctors_ibfk_3` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (1,NULL,'Amit Kumar','ak@gmail.com','9898989898','Male','2025-09-30','ADC66677789G','MBBS','NA',9,'123456789101','uploads/doctors/1762773576019-401331774.jpg','PAN1234567',NULL,'uploads/doctors/1762773576776-349253822.png','customers address','Kolkata','Arunachal Pradesh','455678','IN',1,2,'2025-10-29 05:15:16','2025-11-18 11:47:22',0,0,'NAME2345','ERTYFVB4567','DFG567','Amit','Pune','[\"uploads/doctors/1762773576914-432057552.jpg\", \"uploads/doctors/1762773577744-935983936.jpg\", \"uploads/doctors/1762773577758-485936198.png\"]',17),(2,NULL,'Rajesh Dev','dr@gmail.com','3333333333','Male','2025-09-19','EDR56789YU','MBBS','NA',8,'123456789101','uploads/doctors/1762410545896-874223665.pdf','123456789011','uploads/doctors/1762410545899-743205694.png','uploads/doctors/1763378587464-285102927.png','address of doc','Pune','Arunachal Pradesh','433231','IN',1,2,'2025-10-29 06:30:07','2025-11-17 11:23:14',0,0,'NAME2345','ASD3456','cgh34567','DEV','Punec','[\"uploads/doctors/1762410546172-126245381.jpg\", \"uploads/doctors/1762410547098-877877442.png\"]',2),(3,20,'Gaurav Shinde','gs@gmail.com','0099008899','Male','2000-11-30','MBBS-0001','MBBS','Hart',5,'1122 2222 2222',NULL,'AAAAA2222A',NULL,NULL,'Nobel Hospital','Pune','Maharashtra','411028','IN',1,2,'2025-11-10 06:11:17','2025-11-18 11:14:29',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,4,'Rajesh Dev','ak@gmail.com','2342343243','Male','1983-11-10','SDSF324324/3423','MD','MA',5,'3432 4234 2342','uploads/doctors/1763463758352-232639597.pdf','CXVDF3333F','uploads/doctors/1763463758357-194537441.jpg','uploads/doctors/1763463759132-799070928.png','full address of customer sr2 fdsf ,dfsdf,fdssf','Kolkata','Andhra Pradesh','354354','IN',1,NULL,'2025-11-18 11:02:40','2025-11-18 11:15:33',1,0,'Rajesh Dev','242343242342342343','DFDF8888888','DEV','Pune','[\"uploads/doctors/1763463759277-860116497.png\", \"uploads/doctors/1763463759990-135538363.jpg\", \"uploads/doctors/1763463760002-969851139.png\"]',NULL),(5,NULL,'trest ddc ','er@gmail.com','3333333333','Female','2025-10-02','4354','gfg','dfsdf',1,'2343 2423 4324','uploads/doctors/1763622999309-609035839.pdf','DSFSDFDSFS','uploads/doctors/1763622999315-192975362.jpg','uploads/doctors/1763622999545-922776017.png','full address','unmaaa','Andhra Pradesh','333333','IN',1,NULL,'2025-11-20 07:16:40','2025-11-20 07:18:18',1,0,'neww','4354','27AAAAA1111','test name tet ;last name','Doe','[\"uploads/doctors/1763622999687-992261545.jpg\", \"uploads/doctors/1763623000427-66735865.jpg\", \"uploads/doctors/1763623000622-362852061.jpg\"]',2);
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurers`
--

DROP TABLE IF EXISTS `insurers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `insurer_code` varchar(50) DEFAULT NULL,
  `insurer_name` varchar(255) DEFAULT NULL,
  `insurer_type` varchar(100) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `short_code` varchar(45) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_insurer_shortcode` (`short_code`),
  KEY `insurers_ibfk_1_idx` (`created_by`),
  KEY `insurers_ibfk_2_idx` (`updated_by`),
  CONSTRAINT `insurers_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `insurers_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurers`
--

LOCK TABLES `insurers` WRITE;
/*!40000 ALTER TABLE `insurers` DISABLE KEYS */;
INSERT INTO `insurers` VALUES (5,'INS/10/0001','Aditya Birla Sun Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:28:17',0,0,'ABSLI',NULL,NULL),(6,'INS/10/0002','Ageas Federal Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:29:13',0,0,'AGEASF',NULL,NULL),(7,'INS/10/0003','Ageas Fede','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(8,'INS/10/0004','Aviva Life Insurance ','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(9,'INS/10/0005','Axis Max Life Insurance Limited','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(10,'INS/10/0006','Bajaj Allianz Life Insurance Company Ltd.','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:29:55',0,0,'BALIC',NULL,NULL),(11,'INS/10/0007','Bandhan Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:29:13',0,0,'BANDHAN',NULL,NULL),(12,'INS/10/0008','Bharti Axa Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:30:11',0,0,'BAX',NULL,NULL),(13,'INS/10/0009','Canara HSBC Life Insurance company Ltd','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:33:15',0,0,'HSBC',NULL,NULL),(14,'INS/10/0010','Edelweiss Life Insurance Co. Ltd.','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:32:20',0,0,'EDT',NULL,NULL),(15,'INS/10/0011','Generali Central Life Insurance Company Limited','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(16,'INS/10/0012','HDFC Life','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(17,'INS/10/0013','ICICI Prudential Life Insurance Co. Ltd','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:34:02',0,0,'ICICI',NULL,NULL),(18,'INS/10/0014','India First Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:34:20',0,0,'IFL',NULL,NULL),(19,'INS/10/0015','Kotak Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(20,'INS/10/0016','LIC','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:34:33',0,0,'LIC',NULL,NULL),(21,'INS/10/0017','PNB Metlife','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(22,'INS/10/0018','Pramerica Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:35:29',0,0,'PLIC',NULL,NULL),(23,'INS/10/0019','Reliance Nippon Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(24,'INS/10/0020','SBI Life','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:37:03',0,0,'SBI',NULL,NULL),(25,'INS/10/0021','Shriram Life Insurance','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:37:35',0,0,'SRL',NULL,NULL),(26,'INS/10/0022','Star Union Dai-ichi Life Insurance Co. Ltd.','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(27,'INS/10/0023','TATA AIA Life','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(28,'INS/10/0024','Acko Life','Life',NULL,NULL,1,'2025-10-09 12:37:20','2025-10-30 05:31:01',0,0,'ACKO LIFE',NULL,NULL),(29,'INS/10/0025','Aditya Birla Health Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:44:40','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(30,'INS/10/0026','Care Health Insurance Ltd. (formerly Religare)','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:30:28',0,0,'CHIL',NULL,NULL),(31,'INS/10/0027','Galaxy Health Insurance Company Limited','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(32,'INS/10/0028','Manipal Cigna Health Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:30:51',0,0,'CIGNA',NULL,NULL),(33,'INS/10/0029','Niva Bupa Health Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(34,'INS/10/0030','Star Health & Allied Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(35,'INS/10/0031','Acko General Insurance Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:28:17',0,0,'ACKO',NULL,NULL),(36,'INS/10/0032','Bajaj Allianz General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:29:55',0,0,'BAGICPPC',NULL,NULL),(37,'INS/10/0033','Bharti AXA General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(38,'INS/10/0034','Cholamandalam MS General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(39,'INS/10/0035','Zuno (Edelweiss) General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(40,'INS/10/0036','Future Generali India Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:32:20',0,0,'',NULL,NULL),(41,'INS/10/0037','Go Digit General Insurance Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(42,'INS/10/0038','HDFC ERGO General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:32:51',0,0,' HDFC ERGO',NULL,NULL),(43,'INS/10/0039','ICICI Lombard General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:34:02',0,0,'ICICILOM',NULL,NULL),(44,'INS/10/0040','Liberty General Insurance Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(45,'INS/10/0041','Magma General Insurance Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(46,'INS/10/0042','National Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(47,'INS/10/0043','Navi General Insurance Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(48,'INS/10/0044','Raheja QBE General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:47:55','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(49,'INS/10/0045','Reliance General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(50,'INS/10/0046','Royal Sundaram General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:36:35',0,0,'RS',NULL,NULL),(51,'INS/10/0047','SBI General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:37:17',0,0,'SBIG',NULL,NULL),(52,'INS/10/0048','Shriram General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(53,'INS/10/0049','Tata AIG General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(54,'INS/10/0050','The New India Assurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:25:49',0,0,NULL,NULL,NULL),(55,'INS/10/0051','The Oriental Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:26:11',0,0,NULL,NULL,NULL),(56,'INS/10/0052','United India Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:26:11',0,0,NULL,NULL,NULL),(57,'INS/10/0053','Universal Sompo General Insurance Co. Ltd.','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:26:11',0,0,NULL,NULL,NULL),(58,'INS/10/0054','Acko Health','Health',NULL,NULL,1,'2025-10-09 12:49:28','2025-10-28 07:26:11',0,0,NULL,NULL,NULL),(63,'INS/10/0055','TEST Insurer','Life','4444444444','e@gmail.com',1,'2025-10-16 05:21:16','2025-10-28 09:52:09',0,0,NULL,NULL,NULL),(65,'INS/11/0001','testingggg','Life','3333333333','rty@gmail.com',1,'2025-11-03 09:51:44','2025-11-17 10:21:14',0,0,'TESTINGG',2,2),(66,'INS/11/0002','testingg newwt','Health','3333333333','rty@gmail.com',1,'2025-11-03 11:11:46','2025-11-06 09:57:14',1,0,NULL,2,2),(67,'INS/11/0003','testingg ggg','Health','3333333333','rty@gmail.com',1,'2025-11-03 11:43:57','2025-11-06 09:57:16',1,0,'TG',17,2),(68,'INS/11/0004','ggggggggg','Health',NULL,'4@gmail.com',1,'2025-11-03 11:45:36','2025-11-03 11:51:54',1,0,NULL,2,NULL),(69,'INS/11/0002','new','Health','9999999999','jo@gmail.com',1,'2025-11-07 04:40:04','2025-11-07 04:41:12',0,0,'new',20,NULL),(70,'INS/11/0003','Sta Health','Health','0088885954','sh@gmail.com',1,'2025-11-10 05:08:48','2025-11-10 05:09:11',0,0,'SH',2,NULL),(72,'INS/11/0004','ynccfff','Health','3333333333','er@gmail.com',1,'2025-11-20 06:56:18','2025-11-20 06:58:11',1,0,'YNCC',2,2);
/*!40000 ALTER TABLE `insurers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ongoing_calls`
--

DROP TABLE IF EXISTS `ongoing_calls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ongoing_calls` (
  `call_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Call ID from SparkTG',
  `appointment_id` int NOT NULL COMMENT 'Related appointment ID',
  `center_id` int NOT NULL COMMENT 'Diagnostic center ID',
  `agent_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Agent mobile number (for mobile calls)',
  `customer_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Customer phone number',
  `call_type` enum('incoming','outgoing') COLLATE utf8mb4_unicode_ci DEFAULT 'outgoing' COMMENT 'Call direction',
  `created_by` int NOT NULL COMMENT 'User who initiated the call',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When call was initiated',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update time',
  PRIMARY KEY (`call_id`),
  KEY `idx_appointment` (`appointment_id`),
  KEY `idx_center` (`center_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `ongoing_calls_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ongoing_calls_ibfk_2` FOREIGN KEY (`center_id`) REFERENCES `diagnostic_centers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ongoing_calls_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks ongoing calls for Spy/Whisper functionality';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ongoing_calls`
--

LOCK TABLES `ongoing_calls` WRITE;
/*!40000 ALTER TABLE `ongoing_calls` DISABLE KEYS */;
INSERT INTO `ongoing_calls` VALUES ('0fb89042-401d-4d90-9d55-a9075a60acbb',27,20,NULL,'9226716071','outgoing',21,'2026-02-09 09:24:36','2026-02-09 09:24:36'),('56d9ab5b-abd3-4e8e-844d-2bf511b5fb81',27,20,NULL,'9226716071','outgoing',21,'2026-02-09 09:25:40','2026-02-09 09:25:40'),('6841d1f4-b704-41b9-9d6a-d52fa51b0cc1',8,20,'+919403099089','9876543210','outgoing',17,'2026-02-04 11:08:09','2026-02-04 11:08:09'),('78b2228d-aaa8-4daa-b975-c4867fb0f7c1',27,20,NULL,'9226716071','outgoing',21,'2026-02-03 12:41:49','2026-02-03 12:41:49');
/*!40000 ALTER TABLE `ongoing_calls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'users.view','View user list/details','2025-12-22 10:43:30','2025-12-22 10:43:30'),(2,'users.create','Create users','2025-12-22 10:43:30','2025-12-22 10:43:30'),(3,'users.update','Update users','2025-12-22 10:43:30','2025-12-22 10:43:30'),(4,'users.delete','Delete users','2025-12-22 10:43:30','2025-12-22 10:43:30'),(5,'users.manage_roles','Assign roles / permissions to users','2025-12-22 10:43:30','2025-12-22 10:43:30'),(6,'roles.view','View roles','2025-12-22 10:43:30','2025-12-22 10:43:30'),(7,'roles.create','Create roles','2025-12-22 10:43:30','2025-12-22 10:43:30'),(8,'roles.update','Update roles','2025-12-22 10:43:30','2025-12-22 10:43:30'),(9,'roles.delete','Delete roles','2025-12-22 10:43:30','2025-12-22 10:43:30'),(10,'permissions.manage','Manage permission catalog and mappings','2025-12-22 10:43:30','2025-12-22 10:43:30'),(11,'clients.view','View clients','2025-12-22 10:43:30','2025-12-22 10:43:30'),(12,'clients.create','Create clients','2025-12-22 10:43:30','2025-12-22 10:43:30'),(13,'clients.update','Update clients','2025-12-22 10:43:30','2025-12-22 10:43:30'),(14,'clients.delete','Delete clients','2025-12-22 10:43:30','2025-12-22 10:43:30'),(15,'insurers.view','View insurers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(16,'insurers.create','Create insurers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(17,'insurers.update','Update insurers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(18,'insurers.delete','Delete insurers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(19,'centers.view','View diagnostic centers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(20,'centers.create','Create diagnostic centers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(21,'centers.update','Update diagnostic centers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(22,'centers.delete','Delete diagnostic centers','2025-12-22 10:43:30','2025-12-22 10:43:30'),(23,'technicians.view','View technicians','2025-12-22 10:43:30','2025-12-22 10:43:30'),(24,'technicians.create','Create technicians','2025-12-22 10:43:30','2025-12-22 10:43:30'),(25,'technicians.update','Update technicians','2025-12-22 10:43:30','2025-12-22 10:43:30'),(26,'technicians.delete','Delete technicians','2025-12-22 10:43:30','2025-12-22 10:43:30'),(27,'appointments.view','View appointments','2025-12-22 10:43:30','2025-12-22 10:43:30'),(28,'appointments.create','Create appointments','2025-12-22 10:43:30','2025-12-22 10:43:30'),(29,'appointments.update','Update appointments','2025-12-22 10:43:30','2025-12-22 10:43:30'),(30,'appointments.delete','Delete/restore appointments','2025-12-22 10:43:30','2025-12-22 10:43:30'),(31,'appointments.assign_center','Assign diagnostic center or technician','2025-12-22 10:43:30','2025-12-22 10:43:30'),(32,'appointments.upload_docs','Upload documents/images','2025-12-22 10:43:30','2025-12-22 10:43:30'),(33,'appointments.qc','Perform QC actions','2025-12-22 10:43:30','2025-12-22 10:43:30'),(34,'appointments.reports','Upload/download reports','2025-12-22 10:43:30','2025-12-22 10:43:30'),(35,'approvals.view','View approval queue','2025-12-22 10:43:30','2025-12-22 10:43:30'),(36,'approvals.process','Approve/reject requests','2025-12-22 10:43:30','2025-12-22 10:43:30'),(37,'tests.view','View tests','2025-12-22 10:43:30','2025-12-22 10:43:30'),(38,'tests.create','Create tests','2025-12-22 10:43:30','2025-12-22 10:43:30'),(39,'tests.update','Update tests','2025-12-22 10:43:30','2025-12-22 10:43:30'),(40,'tests.delete','Delete tests','2025-12-22 10:43:30','2025-12-22 10:43:30'),(41,'test_rates.view','View test rates','2025-12-22 10:43:30','2025-12-22 10:43:30'),(42,'test_rates.create','Create test rates','2025-12-22 10:43:30','2025-12-22 10:43:30'),(43,'test_rates.update','Update test rates','2025-12-22 10:43:30','2025-12-22 10:43:30'),(44,'test_rates.delete','Delete test rates','2025-12-22 10:43:30','2025-12-22 10:43:30'),(45,'categories.view','View test categories','2025-12-22 10:43:30','2025-12-22 10:43:30'),(46,'categories.create','Create test categories','2025-12-22 10:43:30','2025-12-22 10:43:30'),(47,'categories.update','Update test categories','2025-12-22 10:43:30','2025-12-22 10:43:30'),(48,'categories.delete','Delete test categories','2025-12-22 10:43:30','2025-12-22 10:43:30'),(49,'dashboard.view','View dashboard metrics','2025-12-22 10:43:30','2025-12-22 10:43:30'),(50,'*','Grants all permissions across the system','2025-12-22 18:42:55','2025-12-22 18:42:55'),(51,'doctors.view','View doctors','2025-12-26 04:38:36','2025-12-26 04:38:36'),(52,'doctors.create','Create doctors','2025-12-26 04:38:36','2025-12-26 04:38:36'),(53,'doctors.update','Update doctors','2025-12-26 04:38:36','2025-12-26 04:38:36'),(54,'doctors.delete','Delete doctors','2025-12-26 04:38:36','2025-12-26 04:38:36'),(55,'appointments.import','Import appointments from Excel file','2026-01-03 19:06:40','2026-01-03 19:06:40'),(56,'appointments.export','Export appointments list to Excel','2026-01-03 19:06:40','2026-01-03 19:06:40'),(57,'appointments.pushback','Push back appointments to Admin/Reports stage','2026-01-03 19:06:40','2026-01-03 19:06:40'),(58,'appointments.restore','Restore pushed-back appointments to active state','2026-01-03 19:06:40','2026-01-03 19:06:40'),(59,'appointments.reschedule','Reschedule appointment date and time','2026-01-03 19:06:40','2026-01-03 19:06:40'),(60,'appointments.medical_update','Update medical workflow status (Mark Arrived, Start Medical, Partial Complete)','2026-01-03 19:06:40','2026-01-03 19:06:40'),(61,'appointments.complete','Mark appointment as completed (final confirmation)','2026-01-03 19:06:40','2026-01-03 19:06:40'),(62,'appointments.proforma','Download proforma invoice PDF','2026-01-03 19:06:40','2026-01-03 19:06:40'),(63,'appointments.test_assignments','Update test assignments for appointments','2026-01-03 19:06:40','2026-01-03 19:06:40'),(64,'appointments.qc_history','View QC audit trail and history','2026-01-03 19:06:40','2026-01-03 19:06:40'),(65,'appointments.assign_tests','Assign or split tests to different centers/technicians','2026-01-03 19:06:40','2026-01-03 19:06:40'),(66,'appointments.submit_qc','Submit reports for QC verification','2026-01-03 19:06:40','2026-01-03 19:06:40'),(67,'appointments.qc_verify','Verify and approve QC reports','2026-01-03 19:06:40','2026-01-03 19:06:40'),(68,'appointments.qc_pushback','Push back reports from QC to center for corrections','2026-01-03 19:06:40','2026-01-03 19:06:40'),(69,'appointments.view_history','View appointment audit trail and status history','2026-01-03 19:06:40','2026-01-03 19:06:40'),(70,'appointments.bulk_operations','Perform bulk updates on multiple appointments','2026-01-03 19:06:40','2026-01-03 19:06:40'),(71,'test_rates.import','Bulk import test rates from Excel','2026-01-03 19:06:47','2026-01-03 19:06:47'),(72,'test_rates.export','Export test rates to Excel','2026-01-03 19:06:47','2026-01-03 19:06:47'),(73,'test_rates.logs','View history and audit logs of rate changes','2026-01-03 19:06:47','2026-01-03 19:06:47'),(74,'approvals.approve','Approve pending requests','2026-01-03 19:06:50','2026-01-03 19:06:50'),(75,'approvals.reject','Reject pending requests','2026-01-03 19:06:50','2026-01-03 19:06:50'),(76,'dashboard.reports','Access detailed reports and statistics','2026-01-03 19:06:55','2026-01-03 19:06:55'),(77,'dashboard.export','Export dashboard data and reports','2026-01-03 19:06:55','2026-01-03 19:06:55'),(78,'roles.assign_permissions','Assign or modify permissions for roles','2026-01-03 19:06:58','2026-01-03 19:06:58'),(79,'roles.manage_users','Assign roles to users','2026-01-03 19:06:58','2026-01-03 19:06:58'),(80,'system.config','Access system configuration and settings','2026-01-03 19:06:58','2026-01-03 19:06:58'),(81,'clients.import','Bulk import clients from Excel','2026-01-03 19:07:03','2026-01-03 19:07:03'),(82,'clients.export','Export clients list to Excel','2026-01-03 19:07:03','2026-01-03 19:07:03'),(83,'insurers.import','Bulk import insurers from Excel','2026-01-03 19:07:06','2026-01-03 19:07:06'),(84,'insurers.export','Export insurers list to Excel','2026-01-03 19:07:06','2026-01-03 19:07:06'),(85,'centers.import','Bulk import diagnostic centers from Excel','2026-01-03 19:07:10','2026-01-03 19:07:10'),(86,'centers.export','Export diagnostic centers list to Excel','2026-01-03 19:07:10','2026-01-03 19:07:10'),(87,'technicians.import','Bulk import technicians from Excel','2026-01-03 19:07:13','2026-01-03 19:07:13'),(88,'technicians.export','Export technicians list to Excel','2026-01-03 19:07:13','2026-01-03 19:07:13'),(89,'tests.import','Bulk import tests from Excel','2026-01-03 19:07:16','2026-01-03 19:07:16'),(90,'tests.export','Export tests list to Excel','2026-01-03 19:07:16','2026-01-03 19:07:16'),(91,'test_categories.import','Bulk import test categories from Excel','2026-01-03 19:07:21','2026-01-03 19:07:21'),(92,'test_categories.export','Export test categories list to Excel','2026-01-03 19:07:21','2026-01-03 19:07:21'),(93,'users.import','Bulk import users from Excel','2026-01-03 19:07:25','2026-01-03 19:07:25'),(94,'users.export','Export users list to Excel','2026-01-03 19:07:25','2026-01-03 19:07:25'),(95,'telephony.make_call','Make outbound calls to customers','2026-02-03 05:07:39','2026-02-03 05:07:39'),(96,'telephony.view_call_logs','View call history and logs','2026-02-03 05:07:39','2026-02-03 05:07:39'),(97,'telephony.listen_recording','Listen to call recordings','2026-02-03 05:07:39','2026-02-03 05:07:39'),(98,'telephony.manage_config','Manage telephony configuration','2026-02-03 05:07:39','2026-02-03 05:07:39'),(99,'telephony.spy_call','Spy on ongoing calls','2026-02-03 11:28:22','2026-02-03 11:28:22'),(100,'telephony.whisper_call','Whisper during ongoing calls','2026-02-03 11:28:22','2026-02-03 11:28:22');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `fk_role_permissions_permission` (`permission_id`),
  CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,1,'2025-12-26 04:40:21'),(1,2,'2025-12-26 04:40:21'),(1,3,'2025-12-26 04:40:21'),(1,4,'2025-12-26 04:40:21'),(1,5,'2026-01-05 06:44:29'),(1,6,'2026-01-05 06:44:29'),(1,7,'2026-01-05 06:44:29'),(1,8,'2026-01-05 06:44:29'),(1,9,'2026-01-05 06:44:29'),(1,10,'2026-01-05 06:44:29'),(1,11,'2025-12-26 04:40:21'),(1,12,'2025-12-26 04:40:21'),(1,13,'2025-12-26 04:40:21'),(1,14,'2025-12-26 04:40:21'),(1,15,'2025-12-26 04:40:21'),(1,16,'2025-12-26 04:40:21'),(1,17,'2025-12-26 04:40:21'),(1,18,'2025-12-26 04:40:21'),(1,19,'2025-12-26 04:40:21'),(1,20,'2026-01-05 06:44:29'),(1,21,'2025-12-26 04:40:21'),(1,22,'2026-01-05 06:44:29'),(1,23,'2025-12-26 04:40:21'),(1,24,'2025-12-26 04:40:21'),(1,25,'2025-12-26 04:40:21'),(1,26,'2025-12-26 04:40:21'),(1,27,'2025-12-26 04:40:21'),(1,28,'2025-12-26 04:40:21'),(1,29,'2025-12-26 04:40:21'),(1,30,'2026-01-05 06:44:29'),(1,31,'2026-01-05 06:44:29'),(1,32,'2026-01-05 06:44:29'),(1,33,'2026-01-05 06:44:29'),(1,34,'2026-01-05 06:44:29'),(1,35,'2026-01-05 06:54:52'),(1,36,'2026-01-05 06:59:53'),(1,37,'2025-12-26 04:40:21'),(1,38,'2025-12-26 04:40:21'),(1,39,'2025-12-26 04:40:21'),(1,40,'2025-12-26 04:40:21'),(1,41,'2025-12-26 04:40:21'),(1,42,'2025-12-26 04:40:21'),(1,43,'2025-12-26 04:40:21'),(1,44,'2025-12-26 04:40:21'),(1,45,'2025-12-26 04:40:21'),(1,46,'2025-12-26 04:40:21'),(1,47,'2025-12-26 04:40:21'),(1,48,'2025-12-26 04:40:21'),(1,49,'2026-01-05 06:44:29'),(1,51,'2025-12-26 04:40:21'),(1,52,'2025-12-26 04:40:21'),(1,53,'2025-12-26 04:40:21'),(1,54,'2025-12-26 04:40:21'),(1,55,'2026-01-05 06:44:29'),(1,56,'2026-01-05 06:44:29'),(1,57,'2026-01-05 06:44:29'),(1,58,'2026-01-05 06:44:29'),(1,59,'2026-01-05 06:44:29'),(1,60,'2026-01-05 06:44:29'),(1,61,'2026-01-05 06:44:29'),(1,62,'2026-01-05 06:44:29'),(1,63,'2026-01-05 06:44:29'),(1,64,'2026-01-05 06:44:29'),(1,65,'2026-01-05 06:44:29'),(1,66,'2026-01-05 06:44:29'),(1,67,'2026-01-05 06:44:29'),(1,68,'2026-01-05 06:44:29'),(1,69,'2026-01-05 06:44:29'),(1,70,'2026-01-05 06:44:29'),(1,71,'2026-01-05 06:44:29'),(1,72,'2026-01-05 06:44:29'),(1,73,'2026-01-05 06:44:29'),(1,76,'2026-01-05 06:44:29'),(1,77,'2026-01-05 06:44:29'),(1,78,'2026-01-05 06:44:29'),(1,79,'2026-01-05 06:44:29'),(1,80,'2026-01-05 06:44:29'),(1,81,'2026-01-05 06:44:29'),(1,82,'2026-01-05 06:44:29'),(1,83,'2026-01-05 06:44:29'),(1,84,'2026-01-05 06:44:29'),(1,85,'2026-01-05 05:13:52'),(1,86,'2026-01-05 05:13:52'),(1,87,'2026-01-05 06:44:29'),(1,88,'2026-01-05 06:44:29'),(1,89,'2026-01-05 06:44:29'),(1,90,'2026-01-05 06:44:29'),(1,91,'2026-01-05 06:44:29'),(1,92,'2026-01-05 06:44:29'),(1,93,'2026-01-05 06:44:29'),(1,94,'2026-01-05 06:44:29'),(2,37,'2026-01-14 10:28:19'),(2,38,'2026-01-14 10:28:19'),(2,39,'2026-01-14 10:28:19'),(2,40,'2026-01-14 10:28:19'),(2,41,'2026-01-14 10:28:19'),(2,42,'2026-01-14 10:28:19'),(2,43,'2026-01-14 10:28:19'),(2,44,'2026-01-14 10:28:19'),(2,71,'2026-01-14 10:28:19'),(2,72,'2026-01-14 10:28:19'),(2,73,'2026-01-14 10:28:19'),(2,89,'2026-01-14 10:28:19'),(2,90,'2026-01-14 10:28:19'),(2,91,'2026-01-14 10:28:19'),(2,92,'2026-01-14 10:28:19'),(3,1,'2026-01-06 09:28:31'),(3,2,'2026-01-06 09:28:31'),(3,3,'2026-01-06 09:28:31'),(3,4,'2026-01-06 09:28:31'),(3,5,'2026-01-06 09:28:31'),(3,11,'2026-01-14 10:31:18'),(3,12,'2026-01-14 10:31:18'),(3,13,'2026-01-14 10:31:18'),(3,14,'2026-01-14 10:31:18'),(3,15,'2026-01-14 10:31:18'),(3,16,'2026-01-14 10:31:18'),(3,17,'2026-01-14 10:31:18'),(3,18,'2026-01-14 10:31:18'),(3,19,'2026-01-14 10:31:18'),(3,20,'2026-01-14 10:31:18'),(3,21,'2026-01-14 10:31:18'),(3,22,'2026-01-14 10:31:18'),(3,23,'2026-01-14 10:31:18'),(3,24,'2026-01-14 10:31:18'),(3,25,'2026-01-14 10:31:18'),(3,26,'2026-01-14 10:31:18'),(3,27,'2026-01-06 11:16:14'),(3,28,'2026-01-06 09:28:13'),(3,29,'2026-01-06 09:28:13'),(3,30,'2026-01-06 09:28:13'),(3,31,'2026-01-06 09:28:13'),(3,35,'2026-01-14 10:32:09'),(3,37,'2026-01-14 10:31:18'),(3,38,'2026-01-14 10:31:18'),(3,39,'2026-01-14 10:31:18'),(3,40,'2026-01-14 10:31:18'),(3,41,'2026-01-14 10:31:18'),(3,42,'2026-01-14 10:31:18'),(3,43,'2026-01-14 10:31:18'),(3,44,'2026-01-14 10:31:18'),(3,45,'2026-01-14 10:31:18'),(3,46,'2026-01-14 10:31:18'),(3,47,'2026-01-14 10:31:18'),(3,48,'2026-01-14 10:31:18'),(3,49,'2026-01-14 10:07:22'),(3,51,'2026-01-14 10:31:18'),(3,52,'2026-01-14 10:31:18'),(3,53,'2026-01-14 10:31:18'),(3,54,'2026-01-14 10:31:18'),(3,55,'2026-01-06 09:28:13'),(3,56,'2026-01-06 09:28:13'),(3,57,'2026-01-06 09:28:13'),(3,59,'2026-01-06 09:28:13'),(3,60,'2026-01-06 09:28:13'),(3,61,'2026-01-30 05:41:28'),(3,62,'2026-01-06 09:28:13'),(3,63,'2026-01-06 09:28:13'),(3,65,'2026-01-06 09:28:13'),(3,69,'2026-01-06 09:28:13'),(3,70,'2026-01-06 09:28:13'),(3,71,'2026-01-14 10:31:18'),(3,72,'2026-01-14 10:31:18'),(3,73,'2026-01-14 10:31:18'),(3,81,'2026-01-14 10:31:18'),(3,82,'2026-01-14 10:31:18'),(3,83,'2026-01-14 10:31:18'),(3,84,'2026-01-14 10:31:18'),(3,85,'2026-01-14 10:31:18'),(3,86,'2026-01-14 10:31:18'),(3,87,'2026-01-14 10:31:18'),(3,88,'2026-01-14 10:31:18'),(3,89,'2026-01-14 10:31:18'),(3,90,'2026-01-14 10:31:18'),(3,91,'2026-01-14 10:31:18'),(3,92,'2026-01-14 10:31:18'),(3,93,'2026-01-06 09:28:31'),(3,94,'2026-01-06 09:28:31'),(3,95,'2026-02-03 06:04:55'),(3,96,'2026-02-03 06:04:55'),(3,97,'2026-02-03 06:04:55'),(3,98,'2026-02-03 06:04:55'),(5,1,'2025-12-25 09:36:54'),(5,2,'2025-12-25 09:36:54'),(5,3,'2025-12-25 09:36:54'),(5,4,'2025-12-25 09:36:54'),(5,5,'2025-12-25 09:36:54'),(5,6,'2025-12-25 09:36:54'),(5,7,'2025-12-25 09:36:54'),(5,8,'2025-12-25 09:36:54'),(5,9,'2025-12-25 09:36:54'),(5,10,'2025-12-25 09:36:54'),(5,11,'2026-01-14 10:19:10'),(5,12,'2026-01-14 10:18:46'),(5,13,'2026-01-14 10:19:10'),(5,14,'2026-01-14 10:19:10'),(5,15,'2025-12-25 09:36:54'),(5,16,'2025-12-25 09:36:54'),(5,17,'2025-12-25 09:36:54'),(5,18,'2025-12-25 09:36:54'),(5,19,'2025-12-25 09:36:54'),(5,20,'2025-12-25 09:36:54'),(5,21,'2025-12-25 09:36:54'),(5,22,'2025-12-25 09:36:54'),(5,23,'2025-12-25 09:36:54'),(5,24,'2025-12-25 09:36:54'),(5,25,'2025-12-25 09:36:54'),(5,26,'2025-12-25 09:36:54'),(5,27,'2025-12-25 09:36:54'),(5,28,'2025-12-25 09:36:54'),(5,29,'2025-12-25 09:36:54'),(5,30,'2025-12-25 09:36:54'),(5,31,'2025-12-25 09:36:54'),(5,32,'2025-12-25 09:36:54'),(5,33,'2025-12-25 09:36:54'),(5,34,'2025-12-25 09:36:54'),(5,35,'2025-12-25 09:36:54'),(5,36,'2025-12-25 09:36:54'),(5,37,'2025-12-25 09:36:54'),(5,38,'2025-12-25 09:36:54'),(5,39,'2025-12-25 09:36:54'),(5,40,'2025-12-25 09:36:54'),(5,41,'2025-12-25 09:36:54'),(5,42,'2025-12-25 09:36:54'),(5,43,'2025-12-25 09:36:54'),(5,44,'2025-12-25 09:36:54'),(5,45,'2025-12-25 09:36:54'),(5,46,'2025-12-25 09:36:54'),(5,47,'2025-12-25 09:36:54'),(5,48,'2026-01-06 09:42:55'),(5,49,'2025-12-25 09:36:54'),(5,50,'2026-01-14 10:19:10'),(5,51,'2026-01-05 04:58:39'),(5,52,'2026-01-05 04:58:39'),(5,53,'2026-01-05 04:58:39'),(5,54,'2026-01-05 04:58:39'),(5,55,'2026-01-05 04:58:39'),(5,56,'2026-01-05 04:58:39'),(5,57,'2026-01-05 04:58:39'),(5,58,'2026-01-05 04:58:39'),(5,59,'2026-01-05 04:58:39'),(5,60,'2026-01-05 04:58:39'),(5,61,'2026-01-05 04:58:39'),(5,62,'2026-01-05 04:58:39'),(5,63,'2026-01-05 04:58:39'),(5,64,'2026-01-05 04:58:39'),(5,65,'2026-01-05 04:58:39'),(5,66,'2026-01-05 04:58:39'),(5,67,'2026-01-05 04:58:39'),(5,68,'2026-01-05 04:58:39'),(5,69,'2026-01-05 04:58:39'),(5,70,'2026-01-05 04:58:39'),(5,71,'2026-01-05 04:58:39'),(5,72,'2026-01-05 04:58:39'),(5,73,'2026-01-05 04:58:39'),(5,74,'2026-01-05 04:58:39'),(5,75,'2026-01-05 04:58:39'),(5,76,'2026-01-05 04:58:39'),(5,77,'2026-01-05 04:58:39'),(5,78,'2026-01-05 04:58:39'),(5,79,'2026-01-05 04:58:39'),(5,80,'2026-01-05 04:58:39'),(5,81,'2026-01-14 10:19:10'),(5,82,'2026-01-14 10:19:10'),(5,83,'2026-01-05 04:58:39'),(5,84,'2026-01-05 04:58:39'),(5,85,'2026-01-05 04:58:39'),(5,86,'2026-01-05 04:58:39'),(5,87,'2026-01-05 04:58:39'),(5,88,'2026-01-05 04:58:39'),(5,89,'2026-01-05 04:58:39'),(5,90,'2026-01-05 04:58:39'),(5,91,'2026-01-05 04:58:39'),(5,92,'2026-01-05 04:58:39'),(5,93,'2026-01-05 04:58:39'),(5,94,'2026-01-05 04:58:39'),(5,95,'2026-02-03 06:04:42'),(5,96,'2026-02-03 06:04:42'),(5,97,'2026-02-03 06:04:42'),(5,98,'2026-02-03 06:04:42'),(5,99,'2026-02-03 11:29:39'),(5,100,'2026-02-03 11:29:39'),(6,1,'2026-01-03 15:42:11'),(6,2,'2026-01-03 15:42:11'),(6,3,'2026-01-03 15:42:11'),(6,4,'2026-01-03 15:42:11'),(6,5,'2026-01-03 15:42:11'),(6,6,'2026-01-03 15:42:11'),(6,7,'2026-01-03 15:42:11'),(6,8,'2026-01-03 15:42:11'),(6,9,'2026-01-03 15:42:11'),(6,10,'2026-01-03 15:42:11'),(6,11,'2026-01-03 15:42:11'),(6,12,'2026-01-03 15:42:11'),(6,13,'2026-01-03 15:42:11'),(6,14,'2026-01-03 15:42:11'),(6,15,'2026-01-03 15:42:11'),(6,16,'2026-01-03 22:49:46'),(6,17,'2026-01-03 15:42:11'),(6,18,'2026-01-03 15:42:11'),(6,19,'2026-01-03 15:42:11'),(6,20,'2026-01-03 15:42:11'),(6,21,'2026-01-03 15:42:11'),(6,22,'2026-01-03 15:42:11'),(6,23,'2026-01-03 15:42:11'),(6,24,'2026-01-03 15:42:11'),(6,25,'2026-01-03 15:42:11'),(6,26,'2026-01-03 15:42:11'),(6,27,'2026-01-03 20:12:43'),(6,28,'2026-01-03 20:13:44'),(6,29,'2026-01-03 20:13:44'),(6,30,'2026-01-03 20:12:14'),(6,31,'2026-01-03 20:12:14'),(6,32,'2026-01-03 20:13:44'),(6,33,'2026-01-03 20:12:14'),(6,34,'2026-01-03 20:13:44'),(6,37,'2026-01-02 04:35:12'),(6,38,'2026-01-02 04:35:12'),(6,39,'2026-01-02 04:35:12'),(6,40,'2026-01-02 04:35:12'),(6,41,'2026-01-02 04:35:12'),(6,42,'2026-01-02 04:35:12'),(6,43,'2026-01-02 04:35:12'),(6,44,'2026-01-02 04:35:12'),(6,45,'2026-01-02 04:35:12'),(6,46,'2026-01-02 04:35:12'),(6,47,'2026-01-02 04:35:12'),(6,48,'2026-01-02 04:35:12'),(6,51,'2026-01-03 15:42:11'),(6,52,'2026-01-03 15:42:11'),(6,53,'2026-01-03 15:42:11'),(6,54,'2026-01-03 22:49:46'),(6,55,'2026-01-03 22:49:46'),(6,56,'2026-01-03 22:49:46'),(6,57,'2026-01-03 20:13:44'),(6,58,'2026-01-03 20:13:44'),(6,59,'2026-01-03 20:13:44'),(6,60,'2026-01-03 20:13:44'),(6,61,'2026-01-03 23:02:37'),(6,62,'2026-01-03 22:49:00'),(6,63,'2026-01-03 20:13:44'),(6,64,'2026-01-03 20:13:44'),(6,65,'2026-01-03 22:37:18'),(6,66,'2026-01-03 22:37:18'),(6,67,'2026-01-03 22:37:18'),(6,68,'2026-01-03 22:37:18'),(6,69,'2026-01-03 22:37:18'),(6,70,'2026-01-03 22:37:18'),(6,71,'2026-01-03 19:08:31'),(6,72,'2026-01-03 19:08:31'),(6,73,'2026-01-03 19:08:31'),(6,78,'2026-01-03 19:08:31'),(6,79,'2026-01-03 19:08:31'),(6,81,'2026-01-03 19:08:31'),(6,82,'2026-01-03 19:08:31'),(6,83,'2026-01-03 19:08:31'),(6,84,'2026-01-03 19:08:31'),(6,85,'2026-01-03 19:08:31'),(6,86,'2026-01-03 19:08:31'),(6,87,'2026-01-03 19:08:31'),(6,88,'2026-01-03 19:08:31'),(6,89,'2026-01-03 19:08:31'),(6,90,'2026-01-03 19:08:31'),(6,91,'2026-01-03 19:08:31'),(6,92,'2026-01-03 19:08:31'),(6,93,'2026-01-03 19:08:31'),(6,94,'2026-01-03 19:08:31');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Admin','admin permissions','2025-10-06 07:01:14','2026-01-05 06:59:53',0),(2,'TPA','tpa permisison','2025-10-06 09:23:27','2026-01-14 10:28:19',0),(3,'Diagnostic Center','center permissions','2025-10-06 09:23:27','2026-02-03 06:04:55',0),(4,'Technician','{\"insurers\":[],\"clients\":[\"read\"],\"centers\":[],\"technicians\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"users\":[],\"appointments\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"]}','2025-10-06 11:22:03','2025-11-13 07:28:47',0),(5,'Super Admin','super admin rp','2025-10-31 06:51:56','2026-02-03 11:29:39',0),(6,'new','{\"insurers\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"clients\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"centers\":[\"read\",\"add\",\"edit\",\"import\",\"export\",\"delete\"],\"doctors\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"technicians\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"users\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"appointments\":[],\"test\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"testRates\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"],\"category\":[\"read\",\"add\",\"edit\",\"delete\",\"import\",\"export\"]}','2025-12-22 19:08:55','2026-01-03 23:07:40',0);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `technician_documents`
--

DROP TABLE IF EXISTS `technician_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `technician_id` int NOT NULL,
  `document_type` varchar(100) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `technician_id` (`technician_id`),
  CONSTRAINT `technician_documents_ibfk_1` FOREIGN KEY (`technician_id`) REFERENCES `technicians` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `technician_documents`
--

LOCK TABLES `technician_documents` WRITE;
/*!40000 ALTER TABLE `technician_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `technician_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `technicians`
--

DROP TABLE IF EXISTS `technicians`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technicians` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `center_id` int NOT NULL,
  `technician_code` varchar(50) NOT NULL,
  `technician_type` enum('On-Roll','In-House') DEFAULT 'In-House',
  `rate_per_appointment` decimal(10,2) DEFAULT '0.00',
  `profile_pic` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `home_gps_latitude` decimal(10,8) DEFAULT NULL,
  `home_gps_longitude` decimal(11,8) DEFAULT NULL,
  `home_address` text,
  `qualification` varchar(255) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  PRIMARY KEY (`id`),
  UNIQUE KEY `technician_code` (`technician_code`),
  KEY `center_id` (`center_id`),
  KEY `technicians_ibfk_1` (`user_id`),
  CONSTRAINT `technicians_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `technicians_ibfk_2` FOREIGN KEY (`center_id`) REFERENCES `diagnostic_centers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `technicians`
--

LOCK TABLES `technicians` WRITE;
/*!40000 ALTER TABLE `technicians` DISABLE KEYS */;
INSERT INTO `technicians` VALUES (2,9,5,'TEC001','On-Roll',30.10,'uploads/technicians/1770015222591-116260179.jpg','Kumar Technician','9999999999','af@gmail.com',NULL,NULL,'naaa','ME',0,1,'2025-10-09 06:48:50','2026-02-02 06:53:42',0,0),(3,11,6,'Tec002','In-House',0.00,NULL,'shell technician','9999999999','er@gmail.com',NULL,NULL,'ff','be',3,1,'2025-10-09 09:55:23','2026-02-02 06:47:03',1,0),(8,11,6,'SHTEC1','On-Roll',330.12,'uploads/technicians/1770014916066-428897548.jpg','shelltec','9999999999','test@gmail.com',NULL,NULL,'full address of customer','ME',1,1,'2026-02-02 06:26:31','2026-02-02 06:48:36',0,0);
/*!40000 ALTER TABLE `technicians` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_categories`
--

DROP TABLE IF EXISTS `test_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(255) NOT NULL,
  `description` text,
  `report_type` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `test_categories_ibfk_3_idx` (`created_by`),
  KEY `test_categories_ibfk_2_idx` (`updated_by`),
  CONSTRAINT `test_categories_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `test_categories_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_categories`
--

LOCK TABLES `test_categories` WRITE;
/*!40000 ALTER TABLE `test_categories` DISABLE KEYS */;
INSERT INTO `test_categories` VALUES (7,'FMR,BSL13,CBC,HBA1C ,TMT','Alkaline_Phosp, BUN, CBC & ESR(Hb, WBC, RBC, MCV, PCV MCH MCHC, RDW, Platelets Differential count, ESR), Cholesterol, Creatinine, FBS, FMR, GGT / GGTP, Hba1c, HbsAg, HIV 1 & 2(HIV 1 & 2 - Elisa), LDL_Chol, RUA, SGOT, SGPT, TMT, Total Bilirubin, Total Proteins, Triglycerides, VLDL',NULL,1,'2025-10-29 07:35:39',0,0,'2025-10-29 07:35:39',NULL,NULL),(15,'BSL-8','Cholesterol, Creatinine, FBS, GGT / GGTP, HbsAg, HIV 1 & 2(HIV 1 & 2 - Elisa), SGOT, SGPT',NULL,1,'2025-10-30 06:36:01',0,0,'2025-10-30 06:36:01',NULL,NULL),(16,'BSL-11','Cholesterol, Creatinine, FBS, GGT / GGTP, HbsAg, HIV 1 & 2(HIV 1 & 2 - Elisa), SGOT, SGPT, Total Bilirubin, Total\nProteins, Triglycerides',NULL,1,'2025-10-30 06:50:09',0,0,'2025-10-30 06:50:09',NULL,NULL),(17,'BSL-13','Alkaline_Phosp, BUN, Cholesterol, Creatinine, FBS, GGT / GGTP, HbsAg, HIV 1 & 2(HIV 1 & 2 - Elisa), LDL_Chol,\nSGOT, SGPT, Total Bilirubin, Total Proteins, Triglycerides, VLDL',NULL,1,'2025-10-30 06:50:09',0,0,'2025-10-30 06:50:09',NULL,NULL),(19,'Basic Health Package','Complete health checkup package',NULL,1,'2025-10-30 07:16:26',0,0,'2025-10-30 07:16:26',NULL,NULL),(21,'new categoryy333','dcccccc',NULL,1,'2025-10-31 04:56:23',0,0,'2025-12-01 07:28:55',NULL,NULL),(22,'catru Adit','adity descrip',NULL,1,'2025-11-02 12:19:29',0,0,'2025-12-05 11:17:00',NULL,NULL),(23,'dsfdsf','dsfdsf',NULL,0,'2025-11-06 10:05:04',1,0,'2025-11-06 10:08:47',NULL,NULL),(24,'dsfds','fsdfdsf',NULL,1,'2025-11-06 10:09:08',1,0,'2025-11-06 10:23:04',NULL,2),(25,'Combo1','Combinations',NULL,1,'2025-11-10 05:15:25',0,0,'2025-11-10 05:17:08',NULL,2),(26,'combo2','fsdfdsf','[\"pathology\", \"cardiology\", \"radiology\", \"mer\", \"mtrf\", \"other\"]',1,'2025-11-10 05:18:03',0,0,'2025-12-05 12:03:12',NULL,NULL),(28,'er','er',NULL,1,'2025-11-17 08:03:42',1,0,'2025-11-17 08:04:29',NULL,NULL),(29,'fdsfdsdsfds','sdfdsvbcbcv',NULL,1,'2025-11-20 07:24:52',1,0,'2025-11-20 07:31:57',NULL,2),(30,'bbbbbbbbbfff','bbbbbbbb','[\"cardiology\", \"mer\", \"other\"]',1,'2026-01-16 07:56:00',0,0,'2026-02-05 06:21:08',NULL,NULL),(32,'test','test','[\"cardiology\", \"radiology\"]',1,'2026-02-05 06:21:27',0,0,'2026-02-05 06:21:27',NULL,NULL),(33,'rgdfgfdgdfgdf','gfdgfdgfd','[\"pathology\", \"cardiology\"]',1,'2026-02-09 05:38:10',1,0,'2026-02-09 05:38:45',NULL,17);
/*!40000 ALTER TABLE `test_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_rates`
--

DROP TABLE IF EXISTS `test_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_rates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `center_id` int DEFAULT NULL,
  `insurer_id` int DEFAULT NULL,
  `test_id` int DEFAULT NULL,
  `rate` decimal(10,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `rate_type` enum('test','category') DEFAULT 'test',
  `category_id` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `test_rates_ibfk_2` (`center_id`),
  KEY `test_rates_ibfk_1` (`client_id`),
  KEY `test_rates_ibfk_3` (`insurer_id`),
  KEY `test_rates_ibfk_4` (`test_id`),
  KEY `test_rates_ibfk_6_idx` (`updated_by`),
  CONSTRAINT `test_rates_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `test_rates_ibfk_2` FOREIGN KEY (`center_id`) REFERENCES `diagnostic_centers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `test_rates_ibfk_3` FOREIGN KEY (`insurer_id`) REFERENCES `insurers` (`id`),
  CONSTRAINT `test_rates_ibfk_4` FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `test_rates_ibfk_5` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `test_rates_ibfk_6` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_test_rates_exclusive` CHECK ((((`rate_type` = _utf8mb4'test') and (`test_id` is not null) and (`category_id` is null)) or ((`rate_type` = _utf8mb4'category') and (`category_id` is not null) and (`test_id` is null))))
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_rates`
--

LOCK TABLES `test_rates` WRITE;
/*!40000 ALTER TABLE `test_rates` DISABLE KEYS */;
INSERT INTO `test_rates` VALUES (49,42,NULL,56,NULL,44.00,1,2,'2025-10-21 09:35:57','2025-10-27 07:50:52',1,'category',2,NULL),(50,42,NULL,57,NULL,56.89,1,2,'2025-10-21 09:35:57','2025-10-27 07:49:16',1,'category',2,NULL),(51,42,NULL,56,NULL,11200.00,1,2,'2025-10-21 10:31:20','2025-10-28 08:24:35',0,'category',1,NULL),(52,42,NULL,57,NULL,60000.00,1,2,'2025-10-21 10:33:40','2025-10-28 08:24:35',0,'category',1,NULL),(53,42,NULL,56,NULL,67.00,1,2,'2025-10-27 06:38:25','2025-10-27 07:50:22',1,'category',2,NULL),(54,42,NULL,57,NULL,77.92,1,2,'2025-10-27 06:38:25','2025-10-28 08:24:35',0,'category',2,NULL),(55,42,NULL,56,NULL,55.66,1,2,'2025-10-27 06:39:05','2025-10-28 08:24:35',0,'category',2,NULL),(68,38,NULL,22,NULL,160.00,1,2,'2025-10-28 07:45:51','2025-10-29 07:53:34',0,'category',3,NULL),(91,38,NULL,5,NULL,480.00,1,2,'2025-10-29 07:49:38','2025-10-29 07:53:34',0,'category',4,NULL),(92,38,NULL,5,NULL,600.00,1,2,'2025-10-29 07:50:01','2025-10-29 07:53:34',0,'category',5,NULL),(93,38,NULL,5,NULL,740.00,1,2,'2025-10-29 07:50:28','2025-10-29 07:53:34',0,'category',6,NULL),(94,38,NULL,5,NULL,100.00,1,2,'2025-10-29 07:51:45','2025-10-29 07:53:34',0,'category',8,NULL),(95,38,NULL,5,NULL,1628.00,1,2,'2025-10-29 07:51:45','2025-10-29 07:53:34',0,'category',7,NULL),(96,38,NULL,5,NULL,1172.00,1,2,'2025-10-29 07:52:38','2025-10-29 07:53:34',0,'category',9,NULL),(97,38,NULL,5,NULL,1388.00,1,2,'2025-10-29 07:52:38','2025-10-29 07:53:34',0,'category',10,NULL),(98,38,NULL,5,NULL,1148.00,1,2,'2025-10-29 07:53:03','2025-10-29 07:53:34',0,'category',11,NULL),(99,38,NULL,5,NULL,2108.00,1,2,'2025-10-29 07:53:34','2025-10-29 07:53:34',0,'category',12,NULL);
/*!40000 ALTER TABLE `test_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tests`
--

DROP TABLE IF EXISTS `tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `test_code` varchar(150) DEFAULT NULL,
  `test_name` varchar(255) DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `description` text,
  `report_type` varchar(45) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint(1) DEFAULT '0' COMMENT 'Quick flag for pending approval',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `tests_ibfk_2_idx` (`created_by`),
  KEY `tests_ibfk_3_idx` (`updated_by`),
  CONSTRAINT `tests_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `test_categories` (`id`),
  CONSTRAINT `tests_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `tests_ibfk_3` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tests`
--

LOCK TABLES `tests` WRITE;
/*!40000 ALTER TABLE `tests` DISABLE KEYS */;
INSERT INTO `tests` VALUES (32,NULL,'CBC & ESR',NULL,'CBC & ESR(Hb, WBC, RBC, MCV, PCV MCH MCHC, RDW, Platelets Differential count, ESR)',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(33,NULL,'Complete Renal Profile',NULL,'RFT',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(34,NULL,'ECG',NULL,'ECG',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(35,NULL,'FBS',NULL,'FBS',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(36,NULL,'HBA1C',NULL,'Hba1c',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(39,NULL,'HIV 1 & 2 WITH ELISA METHOD',NULL,'HIV 1 & 2(HIV 1 & 2 - Elisa)',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(40,NULL,'LFT',NULL,'LFT(Total Bilirubin, SGOT / AST , SGPT /ALT, GGT / GGTP, Alkaline_Phosp, Total Proteins, ALBUMIN GLOUBIN AG\nRATIO)',NULL,1,'2025-10-30 06:35:00','2025-10-30 06:35:00',0,0,NULL,NULL),(61,NULL,'2 D ECHO(PLAIN)',NULL,'2D ECHO',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(62,NULL,'ANTI HCV',NULL,'Anti HCV','pathology',1,'2025-10-30 06:50:09','2025-12-03 09:53:28',0,0,NULL,17),(63,NULL,'HBEAG',NULL,'HbeAg',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(64,NULL,'HBsAg',NULL,'HbsAg',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(65,NULL,'Lipid Profile',NULL,'LIP(HDL /LDL RATIO, VLDL, HDL_Chol, LDL_Chol, Cholesterol, Triglycerides, Total Chol/HDL ratio, LDL/HDL RATIO)',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(66,NULL,'MICROALBUMIN',NULL,'Urine Microalbumin',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(67,NULL,'PFT',NULL,'PFT',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(68,NULL,'PSA',NULL,'PSA',NULL,1,'2025-10-30 06:50:09','2025-10-30 06:50:09',0,0,NULL,NULL),(69,NULL,'RUA',NULL,'RUA','radiology',1,'2025-10-30 06:50:09','2025-12-05 12:06:46',0,0,NULL,17),(72,NULL,'Complete Blood Count',NULL,'Blood test for RBC, WBC, Hemoglobin','mer',1,'2025-10-30 07:16:26','2025-12-03 09:33:44',0,0,NULL,17),(75,NULL,'test name 1',NULL,'dscdsjhcvsm',NULL,1,'2025-11-03 06:35:22','2025-11-04 12:51:53',1,0,15,NULL),(76,NULL,'new',NULL,'new',NULL,1,'2025-11-04 06:35:49','2025-11-04 06:45:48',1,0,2,NULL),(77,NULL,'neww',NULL,'new',NULL,1,'2025-11-04 06:46:06','2025-11-04 09:40:05',1,0,2,2),(78,NULL,'testnew tttttt',NULL,'testnew',NULL,0,'2025-11-04 09:40:33','2025-11-04 09:41:40',1,0,2,2),(79,NULL,'testt',NULL,'dsfdsfsdfsdfdsf',NULL,0,'2025-11-06 09:58:07','2025-11-06 09:58:53',1,0,2,2),(81,NULL,'tttdssnnew name',NULL,'sdsd',NULL,1,'2025-11-06 12:27:42','2025-11-06 12:28:52',1,0,2,2),(82,NULL,'cc',NULL,'cc','mer',1,'2025-11-06 12:29:04','2025-12-01 07:15:37',0,0,2,NULL),(83,NULL,'test new',NULL,'test newdfdsfds','mer',1,'2025-11-07 06:40:15','2025-12-01 07:15:37',0,0,2,2),(85,NULL,'dff',NULL,'fff','pathology',1,'2025-11-08 12:33:10','2025-12-01 07:15:37',0,0,2,NULL),(86,NULL,'Complete Blood Count (CBC)',NULL,'which checks for red and white blood cells and platelets','mer',1,'2025-11-10 05:13:05','2025-12-17 07:30:58',0,0,2,NULL),(87,NULL,'d',NULL,'d',NULL,0,'2025-11-17 07:21:26','2025-11-17 07:22:35',1,0,2,NULL),(89,'TST/11/0001','dffccsdfdsfsdf',NULL,'dfsdsf',NULL,1,'2025-11-20 07:11:39','2025-11-20 07:12:18',1,0,2,NULL),(90,'TST/01/0001','vvvvvvvv',NULL,'vvvvvvvvvvv','radiology',1,'2026-01-16 07:59:49','2026-01-16 07:59:49',0,0,17,NULL);
/*!40000 ALTER TABLE `tests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_otps`
--

DROP TABLE IF EXISTS `user_otps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_otps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `otp_code` varchar(10) NOT NULL,
  `purpose` varchar(50) DEFAULT 'password_reset',
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_purpose` (`user_id`,`purpose`),
  CONSTRAINT `fk_user_otps_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_otps`
--

LOCK TABLES `user_otps` WRITE;
/*!40000 ALTER TABLE `user_otps` DISABLE KEYS */;
INSERT INTO `user_otps` VALUES (1,9,'318132','password_reset','2025-12-22 15:39:39',NULL,'2025-12-22 15:29:39'),(2,9,'400283','password_reset','2025-12-22 15:41:51','2025-12-22 15:35:19','2025-12-22 15:31:51'),(3,9,'819083','password_reset','2025-12-22 18:21:30',NULL,'2025-12-22 18:11:30'),(4,9,'240762','password_reset','2025-12-22 18:29:30',NULL,'2025-12-22 18:19:30'),(5,9,'925505','password_reset','2025-12-22 18:29:32',NULL,'2025-12-22 18:19:32'),(6,9,'471887','password_reset','2025-12-22 18:47:19','2025-12-22 18:39:05','2025-12-22 18:37:19'),(7,9,'628386','password_reset','2025-12-23 12:23:42','2025-12-23 12:14:04','2025-12-23 12:13:42'),(8,9,'441687','password_reset','2026-01-05 16:16:19',NULL,'2026-01-05 16:06:19'),(9,9,'743824','password_reset','2026-01-05 18:11:21','2026-01-05 18:02:06','2026-01-05 18:01:21');
/*!40000 ALTER TABLE `user_otps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_permissions` (
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `assignment_type` enum('grant','revoke') NOT NULL DEFAULT 'grant',
  PRIMARY KEY (`user_id`,`permission_id`,`assignment_type`),
  KEY `fk_user_permissions_permission` (`permission_id`),
  CONSTRAINT `fk_user_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_permissions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` varchar(500) NOT NULL,
  `device_info` text,
  `ip_address` varchar(50) DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role_id` int DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `has_pending_approval` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `users_ibfk_1` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'Admin','admin1@gmail.com','$2a$10$DXXZiHE8z2fvz.P01BLZGeaXGLImd1LIuw9uD5QjKSBq1FFCmVucO',1,'Admin\'s Full Name','2222888882',1,'2025-11-05 09:38:24','2025-10-06 07:01:55','2026-01-19 06:15:33',0,0),(4,'Center1','center1@gmail.com','$2a$10$ftdqjsW2RghXB1rUrGsZXO9oedGUj76irc9GI9gC1GTWJfj4oo33S',3,'Center1','9999999999',1,NULL,'2025-10-06 09:23:37','2025-10-09 11:31:27',0,0),(5,'Tec1','tec1@gmail.com','$2a$10$l4CmZznq6J8/iAdRtYWaf.UHaPG/l9QAd.vdPWYct8T.Rfp7i81lC',4,'Tec1','9999999999',1,NULL,'2025-10-06 11:23:03','2025-10-06 11:23:03',0,0),(6,'new','new@gmail.com','$2a$10$74qxzS4kBbDP5cOoDsiMJ.4AyFYYtWGqwD/BSa2pwrGC.lJCyF2Pq',6,'new','9999999999',1,NULL,'2025-10-08 11:06:13','2026-01-02 04:35:35',0,0),(7,'KumarDC','a@gmail.com','$2a$10$g0D5Mhly56K5IuLv0iD2RuRB0DRcAmD4HQN392ruIzfXQwbsB8ndi',3,'Kumar Diagnostic Center','9999999999',1,NULL,'2025-10-09 06:22:43','2025-10-09 06:22:43',0,0),(9,'kumarTec','alanwalkerdj27@gmail.com','$2a$10$dDPW/m8uJ40OBTpeO6nY4eXnOzu5RlZF4XZVx24ToNRuMPOQeEiRe',4,'Kumar Technician','9999999999',1,'2026-02-04 12:16:33','2025-10-09 06:45:13','2026-02-04 12:16:33',0,0),(10,'shelldc','d@gmail.com','$2a$10$KqY6/XWy9Jt.HpQydRWyXOwz/4ExBNO3mi9gW5St8bzQM7xyf6IBC',3,'shell diagnostic center','9999999999',1,NULL,'2025-10-09 08:06:55','2025-10-09 08:06:55',0,0),(11,'shelltec','h@gmail.com','$2a$10$1nKrywUpgjG56WMuMspLeublpBSV8ABIz.phL/evI13xHa.55k2/6',4,'shell technician','9999999999',1,'2026-02-02 06:48:48','2025-10-09 09:53:43','2026-02-02 06:48:48',0,0),(14,'testdc','t@gmail.com','$2a$10$C0S0gESTpHfdXvkbjzddD.hSFLzrRI2h0UKmu07EF9G8.1lL85O62',3,'testdc','3333333333',1,NULL,'2025-10-16 05:29:15','2025-10-16 05:29:15',0,0),(15,'ioi','ioi@gmail.com','$2a$10$UR/mlX93TzfgjnoSUk/hTeGa4b0VHHx3jtPpCun1NuUdIeW0Cm/Eq',6,'ioi name','3434343456',1,NULL,'2025-10-20 09:01:25','2025-12-22 19:12:07',0,0),(17,'Super Admin','sa@gmail.com','$2a$10$U0L.gwxob6zG/KQjPv1P/.N39atOcSijSD5dO/BA3O7PrRNq9aV9K',5,'Super Admin Name','9999999999',1,NULL,'2025-11-03 09:32:43','2026-02-03 12:43:25',0,0),(18,'doc','docc@gmail.com','$2a$10$w1tO9mSRrac5dU8rF4Aru.2sOLjKGrywNAgxvzlvI16BvAong1gfW',2,'docggg','1111111111',1,NULL,'2025-11-06 10:15:23','2025-11-06 10:34:33',1,0),(19,'docx','dofcc@gmail.com','$2a$10$L1g.rJTFVf.6KSLDGicb.OjgF6PwdhVKhiD3b9Yp7uDINfPspXe96',1,'doc','1111111111',1,NULL,'2025-11-06 10:35:10','2025-11-06 10:35:50',1,0),(20,'Admin2','aaa@gmail.com','$2a$10$Aq0CVvJ3.dyM1TylSLV/yeHJO3m.gNrKdyy6PIzC70ziqK2.PVg62',1,'Admin22','1111111111',1,NULL,'2025-11-07 04:28:45','2025-11-07 04:30:41',0,0),(21,'Iconic','ee333r@gmail.com','$2a$10$CDAvdZGw3BEqZ9059m94DOay.aE/TRm0flYBnIrj6GmSQ6PVwIFOm',3,'iconic name','2222222222',1,NULL,'2025-11-10 07:33:46','2025-12-25 08:17:13',0,0),(22,'tpa1','tpa1@gmail.com','$2a$10$EXoAw7wtpQ47f5CruY577O934IEW.CmiCEacnzETnQOqfpURCHTam',2,'tpa1','7777777777',1,NULL,'2026-01-14 10:28:47','2026-01-14 10:28:47',0,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-09 15:21:41
