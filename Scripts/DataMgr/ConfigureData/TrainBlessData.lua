module("TrainBlessData", package.seeall)

local moduleName = "TrainBlessData";
local m_database = {};
_G[moduleName] = m_database;

m_database["id_1"] = {
id = 1,
desc = "日卡",
price = 10,
time = 24,
}
m_database["id_2"] = {
id = 2,
desc = "周卡",
price = 60,
time = 168,
}
m_database["id_3"] = {
id = 3,
desc = "月卡",
price = 2500,
time = 720,
}

