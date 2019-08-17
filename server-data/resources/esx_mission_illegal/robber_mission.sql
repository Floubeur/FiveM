
DROP TABLE IF EXISTS `robber_mission`;
CREATE TABLE IF NOT EXISTS `robber_mission` (
  `identifier` varchar(255) NOT NULL,
  `experience` varchar(255) DEFAULT '0',
  `lvl_robber` int(2) DEFAULT '0',
  `nub_mission` varchar(255) DEFAULT '0',
  `kill_npc` varchar(50) DEFAULT NULL,
  `kill_player` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
