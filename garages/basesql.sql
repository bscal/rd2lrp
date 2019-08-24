USE `fivem`;

CREATE TABLE IF NOT EXISTS `garages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `impound` TINYINT(1) NOT NULL,
  `x` decimal(10,2) NOT NULL,
  `y` decimal(10,2) NOT NULL,
  `z` decimal(10,2) NOT NULL,
  `price` int(11) NOT NULL,
  `blip_colour` int(255) NOT NULL,
  `blip_id` int(255) NOT NULL,
  `slot` int(255) NOT NULL,
  `available` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `garages` (`id`, `name`, `impound`, `x`, `y`, `z`, `price`, `blip_colour`, `blip_id`, `slot`, `available`) VALUES
(1, 'GreenWich 1', 0, '-1087.14', '-2232.71', '12.23', 120000, 3, 369, 10, 'on'),
(2, 'GreenWich 2', 0, '-1096.78', '-2222.89', '12.23', 120000, 3, 369, 10, 'on'),
(3, 'Exceptionalists 1', 0, '-666.51', '-2379.42', '12.89', 120000, 3, 369, 10, 'on'),
(4, 'Exceptionalists 2', 0, '-673.16', '-2391.26', '12.90', 120000, 3, 369, 10, 'on'),
(5, 'South Shambles', 0, '1027.35', '-2398.38', '28.87', 120000, 3, 369, 10, 'on'),
(6, 'Olympic Freeway 1', 0, '-221.11', '-1162.51', '22.02', 120000, 3, 369, 10, 'on'),
(7, 'Olympic Freeway 2', 0, '-41.88', '-1235.24', '28.38', 25000, 3, 369, 2, 'on'),
(8, 'Olympic Freeway 3', 0, '-41.79', '-1242.01', '28.34', 25000, 3, 369, 2, 'on'),
(9, 'Olympic Freeway 4', 0, '-42.16', '-1252.35', '28.27', 25000, 3, 369, 2, 'on'),
(10, 'Olympic Fury', 0, '841.65', '-1162.91', '24.27', 70000, 3, 369, 6, 'on'),
(11, 'Murrieta Heights 1', 0, '964.78', '-1031.05', '39.84', 150000, 3, 369, 10, 'on'),
(12, 'Murrieta Heights 2', 0, '964.77', '-1025.43', '39.85', 150000, 3, 369, 10, 'on'),
(13, 'Murrieta Heights 3', 0, '964.75', '-1019.79', '39.85', 150000, 3, 369, 10, 'on'),
(14, 'Murrieta Heights 4', 0, '964.70', '-1014.04', '39.85', 150000, 3, 369, 10, 'on'),
(15, 'Popular Street 1', 0, '815.13', '-923.22', '25.14', 200000, 3, 369, 15, 'on'),
(16, 'Popular Street 2', 0, '819.65', '-922.89', '25.12', 200000, 3, 369, 15, 'on'),
(17, 'Golden Garages', 0, '-791.74', '333.14', '84.70', 1500000, 3, 369, 99, 'off'),
(18, 'Joshua Road', 0, '190.31', '2787.02', '44.61', 60000, 3, 369, 6, 'on'),
(19, 'Route 68 1', 0, '639.22', '2773.21', '41.02', 30000, 3, 369, 2, 'on'),
(20, 'Route 68 2', 0, '644.25', '2791.79', '40.95', 30000, 3, 369, 2, 'on'),
(21, 'Paleto Blvd', 0, '-244.24', '6238.69', '30.49', 35000, 3, 369, 2, 'on'),
(22, 'Public Garage', 0, '214.12', '-791.38', '29.65', 0, 3, 357, 1, 'on');

CREATE TABLE IF NOT EXISTS `user_garage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `garage_id` int(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `user_vehicle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `garage_id` int(11) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `insurance` varchar(255) DEFAULT 'off',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
