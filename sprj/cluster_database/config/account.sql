/*
Navicat MySQL Data Transfer

Source Server         : ubuntu
Source Server Version : 50631
Source Host           : 192.168.80.13:3306
Source Database       : sprj

Target Server Type    : MYSQL
Target Server Version : 50631
File Encoding         : 65001

Date: 2016-12-07 10:45:19
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for account
-- ----------------------------
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `uid` int(4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_id` (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of account
-- ----------------------------
INSERT INTO `account` VALUES ('1', '10001');
INSERT INTO `account` VALUES ('2', '10002');
