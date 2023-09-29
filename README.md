1. Add the following items to your qb-core/shared/items.lua

['lithium'] = {['name'] = 'lithium', ['label'] = 'Lithium', ['weight'] = 100, ['type'] = 'item', ['image'] = 'lithium.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Chemicals!'},
['ammonia'] = {['name'] = 'ammonia', ['label'] = 'Ammonia', ['weight'] = 100, ['type'] = 'item', ['image'] = 'ammonia.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Chemicals!'},
['phosphorus'] = {['name'] = 'phosphorus', ['label'] = 'Phosphorus', ['weight'] = 100, ['type'] = 'item', ['image'] = 'phosphorus.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Chemicals!'},
['raw_meth'] = {['name'] = 'raw_meth', ['label'] = 'Raw Meth', ['weight'] = 100, ['type'] = 'item', ['image'] = 'raw_meth.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Get it in baggys and sell it!'},
['meth_baggy'] = {['name'] = 'meth_baggy', ['label'] = 'Meth Baggy', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'meth_baggy.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Ready for the streets.'},
['meth_lab_system'] = {['name'] = 'meth_lab_system', ['label'] = 'Meth Lab', ['weight'] = 10000, ['type'] = 'item', ['image'] = 'meth_lab_system.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Ready for the streets.'},

2. Copy the images from /images/ to qb-inventory/html/images

3. Execute the following MySQL query in your database

CREATE TABLE `rv_meth_labs` (
	`citizenid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`x` DOUBLE NULL DEFAULT NULL,
	`y` DOUBLE NULL DEFAULT NULL,
	`z` DOUBLE NULL DEFAULT NULL,
	`heading` DOUBLE NULL DEFAULT NULL
);