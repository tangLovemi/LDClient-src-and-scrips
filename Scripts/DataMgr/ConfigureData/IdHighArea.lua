module("IdHighArea", package.seeall)

local moduleName = "IdHighArea";
local m_database = {};
_G[moduleName] = m_database;

m_database["id_1"] = {
id = 1,
desc = "普通装备",
minId = 120000,
maxId = 126999,
type = "equip_normal",
name = "equip",
hasPart = 1,
}
m_database["id_2"] = {
id = 2,
desc = "成长性装备",
minId = 127000,
maxId = 127999,
type = "equip_grow",
name = "equip",
hasPart = 1,
}
m_database["id_3"] = {
id = 3,
desc = "装备碎片",
minId = 128000,
maxId = 128999,
type = "piece_equip",
name = "piece",
hasPart = 0,
}
m_database["id_4"] = {
id = 4,
desc = "外套",
minId = 140000,
maxId = 149999,
type = "coat",
name = "coat",
hasPart = 0,
}
m_database["id_5"] = {
id = 5,
desc = "武器",
minId = 150000,
maxId = 159999,
type = "weapon",
name = "weapon",
hasPart = 0,
}
m_database["id_6"] = {
id = 6,
desc = "外套碎片",
minId = 160000,
maxId = 165000,
type = "piece_coat",
name = "piece",
hasPart = 0,
}
m_database["id_7"] = {
id = 7,
desc = "其它物品",
minId = 165001,
maxId = 170025,
type = "other",
name = "other",
hasPart = 1,
}
m_database["id_8"] = {
id = 8,
desc = "角色自带(例如：金币、经验)",
minId = 180000,
maxId = 189999,
type = "self",
name = "self",
hasPart = 1,
}
m_database["id_9"] = {
id = 9,
desc = "升阶材料",
minId = 170026,
maxId = 175000,
type = "ancient_nornal",
name = "ancient_nornal",
hasPart = 0,
}

