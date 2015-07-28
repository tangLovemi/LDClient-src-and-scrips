﻿module("exp", package.seeall)

local moduleName = "exp";
local m_database = {};
_G[moduleName] = m_database;

m_database["id_1"] = {
id = 1,
expmin = 0,
expmax = 301,
expadd = 2,
expadd2 = 4,
token = 0,
money = 0,
sp = 0,
skillopen = "",
}
m_database["id_2"] = {
id = 2,
expmin = 302,
expmax = 607,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 2,
skillopen = "21002;21025",
}
m_database["id_3"] = {
id = 3,
expmin = 608,
expmax = 923,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 3,
skillopen = "21003;21030",
}
m_database["id_4"] = {
id = 4,
expmin = 924,
expmax = 1255,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 4,
skillopen = "21004;21031",
}
m_database["id_5"] = {
id = 5,
expmin = 1256,
expmax = 1611,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 5,
skillopen = "21007;21014",
}
m_database["id_6"] = {
id = 6,
expmin = 1612,
expmax = 2000,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 6,
skillopen = "21006;21027",
}
m_database["id_7"] = {
id = 7,
expmin = 2001,
expmax = 2430,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 7,
skillopen = "21009;21024",
}
m_database["id_8"] = {
id = 8,
expmin = 2431,
expmax = 2912,
expadd = 2,
expadd2 = 4,
token = 20,
money = 5000,
sp = 8,
skillopen = "21010;21019",
}
m_database["id_9"] = {
id = 9,
expmin = 2913,
expmax = 3455,
expadd = 3,
expadd2 = 6,
token = 20,
money = 5000,
sp = 9,
skillopen = "21008;21012",
}
m_database["id_10"] = {
id = 10,
expmin = 3456,
expmax = 4072,
expadd = 3,
expadd2 = 6,
token = 20,
money = 5000,
sp = 10,
skillopen = "21032;21001;21029",
}
m_database["id_11"] = {
id = 11,
expmin = 4073,
expmax = 4925,
expadd = 3,
expadd2 = 6,
token = 20,
money = 5000,
sp = 11,
skillopen = 21005,
}
m_database["id_12"] = {
id = 12,
expmin = 4926,
expmax = 5895,
expadd = 4,
expadd2 = 8,
token = 20,
money = 5000,
sp = 12,
skillopen = "",
}
m_database["id_13"] = {
id = 13,
expmin = 5896,
expmax = 6996,
expadd = 4,
expadd2 = 8,
token = 20,
money = 5000,
sp = 13,
skillopen = 21013,
}
m_database["id_14"] = {
id = 14,
expmin = 6997,
expmax = 8242,
expadd = 5,
expadd2 = 10,
token = 20,
money = 5000,
sp = 14,
skillopen = "",
}
m_database["id_15"] = {
id = 15,
expmin = 8243,
expmax = 9648,
expadd = 5,
expadd2 = 10,
token = 20,
money = 5000,
sp = 15,
skillopen = 21026,
}
m_database["id_16"] = {
id = 16,
expmin = 9649,
expmax = 11230,
expadd = 5,
expadd2 = 10,
token = 20,
money = 5000,
sp = 16,
skillopen = "",
}
m_database["id_17"] = {
id = 17,
expmin = 11231,
expmax = 13003,
expadd = 6,
expadd2 = 12,
token = 20,
money = 5000,
sp = 17,
skillopen = 21018,
}
m_database["id_18"] = {
id = 18,
expmin = 13004,
expmax = 14983,
expadd = 7,
expadd2 = 14,
token = 20,
money = 5000,
sp = 18,
skillopen = "",
}
m_database["id_19"] = {
id = 19,
expmin = 14984,
expmax = 17186,
expadd = 7,
expadd2 = 14,
token = 20,
money = 5000,
sp = 19,
skillopen = 21023,
}
m_database["id_20"] = {
id = 20,
expmin = 17187,
expmax = 19630,
expadd = 8,
expadd2 = 16,
token = 20,
money = 5000,
sp = 20,
skillopen = "",
}
m_database["id_21"] = {
id = 21,
expmin = 19631,
expmax = 22752,
expadd = 8,
expadd2 = 16,
token = 20,
money = 5000,
sp = 21,
skillopen = 21017,
}
m_database["id_22"] = {
id = 22,
expmin = 22753,
expmax = 26177,
expadd = 9,
expadd2 = 18,
token = 20,
money = 5000,
sp = 22,
skillopen = "",
}
m_database["id_23"] = {
id = 23,
expmin = 26178,
expmax = 29924,
expadd = 10,
expadd2 = 20,
token = 20,
money = 5000,
sp = 23,
skillopen = 21020,
}
m_database["id_24"] = {
id = 24,
expmin = 29925,
expmax = 34012,
expadd = 10,
expadd2 = 20,
token = 20,
money = 5000,
sp = 24,
skillopen = "",
}
m_database["id_25"] = {
id = 25,
expmin = 34013,
expmax = 38461,
expadd = 11,
expadd2 = 22,
token = 20,
money = 5000,
sp = 25,
skillopen = 21015,
}
m_database["id_26"] = {
id = 26,
expmin = 38462,
expmax = 43290,
expadd = 12,
expadd2 = 24,
token = 20,
money = 5000,
sp = 26,
skillopen = "",
}
m_database["id_27"] = {
id = 27,
expmin = 43291,
expmax = 48520,
expadd = 13,
expadd2 = 26,
token = 20,
money = 5000,
sp = 27,
skillopen = 21016,
}
m_database["id_28"] = {
id = 28,
expmin = 48521,
expmax = 54171,
expadd = 14,
expadd2 = 28,
token = 20,
money = 5000,
sp = 28,
skillopen = "",
}
m_database["id_29"] = {
id = 29,
expmin = 54172,
expmax = 60264,
expadd = 15,
expadd2 = 30,
token = 20,
money = 5000,
sp = 29,
skillopen = 21028,
}
m_database["id_30"] = {
id = 30,
expmin = 60265,
expmax = 66820,
expadd = 15,
expadd2 = 30,
token = 20,
money = 5000,
sp = 30,
skillopen = "",
}
m_database["id_31"] = {
id = 31,
expmin = 66821,
expmax = 74629,
expadd = 16,
expadd2 = 32,
token = 20,
money = 5000,
sp = 31,
skillopen = 21022,
}
m_database["id_32"] = {
id = 32,
expmin = 74630,
expmax = 82978,
expadd = 17,
expadd2 = 34,
token = 20,
money = 5000,
sp = 32,
skillopen = "",
}
m_database["id_33"] = {
id = 33,
expmin = 82979,
expmax = 91890,
expadd = 18,
expadd2 = 36,
token = 20,
money = 5000,
sp = 33,
skillopen = 21021,
}
m_database["id_34"] = {
id = 34,
expmin = 91891,
expmax = 101388,
expadd = 19,
expadd2 = 38,
token = 20,
money = 5000,
sp = 34,
skillopen = "",
}
m_database["id_35"] = {
id = 35,
expmin = 101389,
expmax = 111495,
expadd = 20,
expadd2 = 40,
token = 20,
money = 5000,
sp = 35,
skillopen = "",
}
m_database["id_36"] = {
id = 36,
expmin = 111496,
expmax = 122234,
expadd = 22,
expadd2 = 44,
token = 20,
money = 5000,
sp = 36,
skillopen = "",
}
m_database["id_37"] = {
id = 37,
expmin = 122235,
expmax = 133629,
expadd = 23,
expadd2 = 46,
token = 20,
money = 5000,
sp = 37,
skillopen = "",
}
m_database["id_38"] = {
id = 38,
expmin = 133630,
expmax = 145705,
expadd = 24,
expadd2 = 48,
token = 20,
money = 5000,
sp = 38,
skillopen = "",
}
m_database["id_39"] = {
id = 39,
expmin = 145706,
expmax = 158486,
expadd = 25,
expadd2 = 50,
token = 20,
money = 5000,
sp = 39,
skillopen = "",
}
m_database["id_40"] = {
id = 40,
expmin = 158487,
expmax = 171996,
expadd = 26,
expadd2 = 52,
token = 20,
money = 5000,
sp = 40,
skillopen = "",
}
m_database["id_41"] = {
id = 41,
expmin = 171997,
expmax = 187441,
expadd = 28,
expadd2 = 56,
token = 20,
money = 5000,
sp = 41,
skillopen = "",
}
m_database["id_42"] = {
id = 42,
expmin = 187442,
expmax = 203704,
expadd = 29,
expadd2 = 58,
token = 20,
money = 5000,
sp = 42,
skillopen = "",
}
m_database["id_43"] = {
id = 43,
expmin = 203705,
expmax = 220811,
expadd = 30,
expadd2 = 60,
token = 20,
money = 5000,
sp = 43,
skillopen = "",
}
m_database["id_44"] = {
id = 44,
expmin = 220812,
expmax = 238789,
expadd = 32,
expadd2 = 64,
token = 20,
money = 5000,
sp = 44,
skillopen = "",
}
m_database["id_45"] = {
id = 45,
expmin = 238790,
expmax = 257664,
expadd = 33,
expadd2 = 66,
token = 20,
money = 5000,
sp = 45,
skillopen = "",
}
m_database["id_46"] = {
id = 46,
expmin = 257665,
expmax = 277463,
expadd = 34,
expadd2 = 68,
token = 20,
money = 5000,
sp = 46,
skillopen = "",
}
m_database["id_47"] = {
id = 47,
expmin = 277464,
expmax = 298213,
expadd = 36,
expadd2 = 72,
token = 20,
money = 5000,
sp = 47,
skillopen = "",
}
m_database["id_48"] = {
id = 48,
expmin = 298214,
expmax = 319942,
expadd = 37,
expadd2 = 74,
token = 20,
money = 5000,
sp = 48,
skillopen = "",
}
m_database["id_49"] = {
id = 49,
expmin = 319943,
expmax = 342677,
expadd = 39,
expadd2 = 78,
token = 20,
money = 5000,
sp = 49,
skillopen = "",
}
m_database["id_50"] = {
id = 50,
expmin = 342678,
expmax = 366445,
expadd = 40,
expadd2 = 80,
token = 20,
money = 5000,
sp = 50,
skillopen = "",
}
m_database["id_51"] = {
id = 51,
expmin = 366446,
expmax = 392921,
expadd = 42,
expadd2 = 84,
token = 20,
money = 5000,
sp = 51,
skillopen = "",
}
m_database["id_52"] = {
id = 52,
expmin = 392922,
expmax = 420530,
expadd = 43,
expadd2 = 86,
token = 20,
money = 5000,
sp = 52,
skillopen = "",
}
m_database["id_53"] = {
id = 53,
expmin = 420531,
expmax = 449301,
expadd = 45,
expadd2 = 90,
token = 20,
money = 5000,
sp = 53,
skillopen = "",
}
m_database["id_54"] = {
id = 54,
expmin = 449302,
expmax = 479263,
expadd = 47,
expadd2 = 94,
token = 20,
money = 5000,
sp = 54,
skillopen = "",
}
m_database["id_55"] = {
id = 55,
expmin = 479264,
expmax = 510445,
expadd = 48,
expadd2 = 96,
token = 20,
money = 5000,
sp = 55,
skillopen = "",
}
m_database["id_56"] = {
id = 56,
expmin = 510446,
expmax = 542877,
expadd = 50,
expadd2 = 100,
token = 20,
money = 5000,
sp = 56,
skillopen = "",
}
m_database["id_57"] = {
id = 57,
expmin = 542878,
expmax = 576589,
expadd = 52,
expadd2 = 104,
token = 20,
money = 5000,
sp = 57,
skillopen = "",
}
m_database["id_58"] = {
id = 58,
expmin = 576590,
expmax = 611611,
expadd = 54,
expadd2 = 108,
token = 20,
money = 5000,
sp = 58,
skillopen = "",
}
m_database["id_59"] = {
id = 59,
expmin = 611612,
expmax = 647974,
expadd = 55,
expadd2 = 110,
token = 20,
money = 5000,
sp = 59,
skillopen = "",
}
m_database["id_60"] = {
id = 60,
expmin = 647975,
expmax = 685708,
expadd = 57,
expadd2 = 114,
token = 20,
money = 5000,
sp = 60,
skillopen = "",
}
m_database["id_61"] = {
id = 61,
expmin = 685709,
expmax = 727005,
expadd = 59,
expadd2 = 118,
token = 20,
money = 5000,
sp = 61,
skillopen = "",
}
m_database["id_62"] = {
id = 62,
expmin = 727006,
expmax = 769782,
expadd = 61,
expadd2 = 122,
token = 20,
money = 5000,
sp = 62,
skillopen = "",
}
m_database["id_63"] = {
id = 63,
expmin = 769783,
expmax = 814070,
expadd = 63,
expadd2 = 126,
token = 20,
money = 5000,
sp = 63,
skillopen = "",
}
m_database["id_64"] = {
id = 64,
expmin = 814071,
expmax = 859901,
expadd = 65,
expadd2 = 130,
token = 20,
money = 5000,
sp = 64,
skillopen = "",
}
m_database["id_65"] = {
id = 65,
expmin = 859902,
expmax = 907308,
expadd = 67,
expadd2 = 134,
token = 20,
money = 5000,
sp = 65,
skillopen = "",
}
m_database["id_66"] = {
id = 66,
expmin = 907309,
expmax = 956322,
expadd = 69,
expadd2 = 138,
token = 20,
money = 5000,
sp = 66,
skillopen = "",
}
m_database["id_67"] = {
id = 67,
expmin = 956323,
expmax = 1006977,
expadd = 71,
expadd2 = 142,
token = 20,
money = 5000,
sp = 67,
skillopen = "",
}
m_database["id_68"] = {
id = 68,
expmin = 1006978,
expmax = 1059304,
expadd = 73,
expadd2 = 146,
token = 20,
money = 5000,
sp = 68,
skillopen = "",
}
m_database["id_69"] = {
id = 69,
expmin = 1059305,
expmax = 1113337,
expadd = 75,
expadd2 = 150,
token = 20,
money = 5000,
sp = 69,
skillopen = "",
}
m_database["id_70"] = {
id = 70,
expmin = 1113338,
expmax = 1167370,
expadd = 75,
expadd2 = 0,
token = 20,
money = 5000,
sp = 70,
skillopen = "",
}

