module("DataTableManager", package.seeall)

----------------------------------------
-- 读取不同json数值表
----------------------------------------

--各个文件名称

-------------------------------------------------------------------
local m_fileName = {
	"IdArea",  --物品id分区
	"IdHighArea", --物品大类id分区

	"PropertyName", --属性名称表

	-- --装备
	"equipment", --普通装备基础表
	"equipment_intensify", --普通装备强化表
	"growEquipment", --成长性装备基础表
	"growEquipment_intensify", --成长性装备强化表
	"equipSuit", --套装属性表
	"soulCharactorAdd", --灵魂品质加成

	--精灵武器表
	"weapon_base_grow", --基础属性成长表
	"weapon_base_proBase",--基础属性基础表
	"weapon_character",--性格表
	"weapon_name",--名称表
	"weapon_second_grow",--额外属性成长表
	"weapon_second_proBase",--额外属性基础表
	"weapon_star", --额外属性级别表
	"weapon_grow_exp", --经验表
	"weapon_upstep_use", --武器升阶消耗表

	-- --外套
	"coat_grow",
	"coat_name",
	"coat_pos",
	"coat_upstep_use",

	-- --碎片
	"equipPiece",
	"coatPiece",

	--技能
	"SkillInfo",
	"SkillPos",
	"SkillTypeName",

	--任务对话信息
	"MajorTaskDialog",--主线任务对话
	"Hunt",--赏金猎人BOSS介绍
	"RewardDialog",--赏金BOSS对话
	"MajorTaskInfo",--任务区域信息
	"majorTask",

	--点星
	"pointStarPro",   -- 点星属性表
	"pointStarCount", -- 数量表
	"pointStarLevel", -- 级别表

	-- --商店
	"generalShop",   --普通商店
	"mysteryShop",   --神秘商店
	"exchangeShop",  --兑换商店
	"shop_refresh_use",--手动刷新消耗
	"shop",

	--训练场
	"train_seat_count",
	"TrainBlessData",
	
	
	-------临时npc名称
	"npcName",
	"EveryDayTaskData",--日常任务
	"EveryDayTaskRewardData",--日常任务奖励

	--装备消耗（强化、灵魂炼化）
	"EquipSoulChemicalUse_BaseParam",
	"EquipSoulResetUse_BaseParam",
	"EquipSoulTransUse_BaseParam",
	"EquipSoulTransUse_LockParam",
	"EquipStrenUse_BaseParam",
	"EquipStrenUse_ColorParam",
	"EquipStrenUse_PartParam",
	"EquipStrenUse_WearLVParam",
	"EquipResetUse_BaseParam",
	"EquipResetUse_LockParam",
	"EquipUpstepUse",

	--吞噬表
	"DevoursOthers",
	"DevourStren",
	"DevourLevel",
	"DevourLevelMoney",
	"DevourLevelSoulYu",
	"DevourLevelUpstepStone",
	
	--物品基本信息
	"GoodsName",

	"arenaConstant",

	"exp",
	"NewGuider",

	"ArchOpenLevel", --建筑开放等级
	"BattleDialog", --战斗中对话
	"achievement",--成就数据
	"AncientMaterial",--远古材料,
	"npcWords",

	"NamesRandom",
	"firstBattle",
};

local m_names = {

	TrainSeatCount = "train_seat_count",   --训练场中各个组别的座位数量
	TrainBlessData	   = "TrainBlessData", -- 训练场祝福

	IdAreaData = "IdArea",  --物品id分区
	IdHighAreaData = "IdHighArea", --物品大类id分区

	PropertyNameData = "PropertyName", --属性名称表

	-- --装备
	normalEquipmentData = "equipment", --普通装备基础表
	normalEquipment_intensifyData = "equipment_intensifyNew", --普通装备强化表
	growEquipmentData = "growEquipment", --成长性装备基础表
	growEquipment_intensifyData = "growEquipment_intensifyNew", --成长性装备强化表
	equipSuitData = "equipSuit", --套装属性表
	normalEquipment_intensifyDataOld = "equipment_intensify",
	growEquipment_intensifyDataOld = "growEquipment_intensify",
	soulCharactorAdd = "soulCharactorAdd",

	--精灵武器表
	weapon_base_grow_Data = "weapon_base_grow", --基础属性成长表
	weapon_base_proBase_Data = "weapon_base_proBase",--基础属性基础表
	weapon_character_Data = "weapon_character",--性格表
	weapon_name_Data = "weapon_name",--名称表
	weapon_second_grow_Data = "weapon_second_grow",--额外属性成长表
	weapon_second_proBase_Data = "weapon_second_proBase",--额外属性基础表
	weapon_star_Data = "weapon_star", --额外属性级别表
	weapon_grow_exp_Data = "weapon_grow_exp", --经验表
	weapon_upstep_use = "weapon_upstep_use", --武器升阶消耗表

	-- --外套
	coat_grow_Data = "coat_grow",
	coat_name = "coat_name",
	coat_pos = "coat_pos",
	coat_grow = "coat_grow",
	coat_upstep_use = "coat_upstep_use",

	-- --碎片
	equipPieceData = "equipPiece",
	coatPieceData = "coatPiece",

	--技能
	SkillInfoData = "SkillInfo",
	SkillPosData = "SkillPos",
	SkillTypeNameData = "SkillTypeName",
	--任务对话
	MajorTaskDialog = "MajorTaskDialog",
	Hunt ="Hunt",
	RewardDialog ="RewardDialog",
	--点星
	pointStarPro   = "pointStarPro",   -- 点星属性表
	pointStarCount = "pointStarCount", -- 数量表
	pointStarLevel = "pointStarLevel", -- 级别表

	-- --商店
	shop = "shop",
	generalShop = "generalShop",   --普通商店
	mysteryShop = "mysteryShop",   --神秘商店
	exchangeShop = "exchangeShop", --兑换商店

	shop_refresh_use = "shop_refresh_use", --手动刷新消耗
	MajorTaskInfo = "MajorTaskInfo", --任务区域信息

	npcName = "npcName", ---------临时
	EveryDayTaskData = "EveryDayTaskData",--日常任务
	EveryDayTaskRewardData = "EveryDayTaskRewardData", --日常任务奖励

	--装备消耗
	EquipResetUse_BaseParam = "EquipResetUse_BaseParam",
	EquipResetUse_LockParam = "EquipResetUse_LockParam",
	EquipSoulChemicalUse_BaseParam = "EquipSoulChemicalUse_BaseParam",
	EquipSoulResetUse_BaseParam = "EquipSoulResetUse_BaseParam",
	EquipSoulTransUse_BaseParam = "EquipSoulTransUse_BaseParam",
	EquipSoulTransUse_LockParam = "EquipSoulTransUse_LockParam",
	EquipStrenUse_BaseParam = "EquipStrenUse_BaseParam",
	EquipStrenUse_ColorParam = "EquipStrenUse_ColorParam",
	EquipStrenUse_PartParam = "EquipStrenUse_PartParam",
	EquipStrenUse_WearLVParam = "EquipStrenUse_WearLVParam",
	EquipUpstepUse = "EquipUpstepUse",

	--吞噬表
	DevourStren = "DevourStren", --强化系数
	DevourLevel = "DevourLevel", --等级配置表
	DevourLevelMoney = "DevourLevelMoney", --金币产出配置
	DevourLevelSoulYu = "DevourLevelSoulYu",--魂玉产出配置
	DevourLevelUpstepStone = "DevourLevelUpstepStone",--升阶石产出
	DevoursOthers = "DevoursOthers", --其它物品吞噬

	GoodsName = "GoodsName",
	arenaConstant = "arenaConstant",--竞技场常量

	expData = "exp", --级别经验表
	NewGuider = "NewGuider", --新手引导

	ArchOpenLevel = "ArchOpenLevel", --建筑开放等级
	BattleDialog = "BattleDialog",--战斗中对话
	achievement = "achievement",
	AncientMaterial= "AncientMaterial",
	npcWords = "npcWords",

	NamesRandom = "NamesRandom",--随机名称
	firstBattle = "firstBattle",
};

function loadData()
	for i = 1, #m_fileName do
		require("DataMgr/ConfigureData/" .. m_fileName[i]);--load lua file
		if(m_fileName[i] == "equipment_intensify") then
			require("DataMgr/ConfigureData/equipment_intensifyNew");
			EquipmentCalc.reloadNormalEquipData();
		elseif(m_fileName[i] == "growEquipment_intensify") then
			require("DataMgr/ConfigureData/growEquipment_intensifyNew");
			EquipmentCalc.reloadGrowEquipData();
		end

		if(m_fileName[i] == "shop") then
			require("DataMgr/Calculation/ShopReload");
			ShopReload.reloadShopData();
		end
	end
end

--得到某一属性数据
function getValue(dataName, index, key)
	local name = m_names[dataName];
	return _G[name][index][key];
end
--得到某一项数据
function getItem( dataName, index )
	local name = m_names[dataName];
	return _G[name][index];
end
--得到json文件的全部数据
function getTableByName(dataName)
	local name = m_names[dataName];
	return _G[name]
end

--得到满足某一项中某一值的项
function getItemByKey( dataName, key, value )
	local items = getTableByName(dataName);
	for k,v in pairs(items) do
		if(v[key] == value) then
			return v;
		end
	end
	return nil;
end

function getItemsByKey( dataName, key, value )
	local items = {};
	local data = getTableByName(dataName);
	for k,v in pairs(data) do
		if(v[key] == value) then
			table.insert(items, v);
		end
	end
	return items;
end

function getCount( dataName )
	local datas = getTableByName(dataName);
	local n = 0;
	for k,v in pairs(datas) do
		n = n + 1;
	end
	return n;
end