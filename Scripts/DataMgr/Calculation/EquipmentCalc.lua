module("EquipmentCalc", package.seeall)

--用于计算某一装备的基础属性

--分为普通装备 和 成长性装备

-- 1	力量	"force_b"
-- 2	敏捷    "quick_b"
-- 3	耐力    "endurance_b"
-- 4	攻击    "atk_b"
-- 5	防御    "def_b"
-- 6	生命    "hp_b"
-- 7	速度    "speed_b"
-- 8	重击    "bash_b"
-- 9	暴击    "crit_b"
-- 10	反击    "counter_b"
-- 11	格挡    "parry_b"
-- 12	闪避    "dodge_b"

local m_proName = {
	"force_b", "quick_b", "endurance_b",
	"atk_b", "def_b", "hp_b", "speed_b",
	"bash_b", "crit_b", "counter_b", "parry_b", "dodge_b"
};

local Table_normalBase 		= "normalEquipmentData";--普通装备基础表
local Table_normalIntensify = "normalEquipment_intensifyData"; --普通装备强化表
local Table_growBase 		= "growEquipmentData"; --成长性装备基础表
local Table_growIntensify 	= "growEquipment_intensifyData"; --成长性装备强化表




local MAX_STREN_LV  = 13; --最大强化等级
local MAX_STEP_LV	= 6; --成长性装备最大品阶

local MIN_STREN_LV = 0;
local MIN_STEP_LV  = 1;


--判断成长性装备是否可以继续升阶
function canUpStep( steplv )
	return (steplv > 0 and steplv < MAX_STEP_LV);
end

--判断装备是否达到最大强化等级
function canUpStren( strenlv )
	return (strenlv >= 0 and strenlv < MAX_STREN_LV);
end

function isMaxStrenLv(strenlv)
	return (strenlv == MAX_STREN_LV);
end

function getMinLV()
	return MIN_STREN_LV;
end

function getMinStepLV(id)
	--需要读表查询
	if(id) then
		local baseData = DataTableManager.getItem(Table_growBase, "id_" .. id);
		if(baseData.step) then
			return baseData.step;
		end
	end
	return MIN_STEP_LV;
end

function isMaxUpstepLv( upsteplv )
	return upsteplv >= MAX_STEP_LV;
end

function getMaxUpstepLV()
	return MAX_STEP_LV;
end

--计算普通装备某一强化等级的基础属性值
--返回：属性id集合，属性值集合
function calcNormalEquip( id, strenlv )
	if(id and strenlv) then
		local ids = {};
		local vals = {};

		local baseData = DataTableManager.getItem(Table_normalBase, "id_" .. id);
		local growData = DataTableManager.getItem(Table_normalIntensify, "id_" .. id);
		local proid_1 = growData["pro_1_id"];
		local proid_2 = growData["pro_2_id"];

		table.insert(ids, proid_1);
		table.insert(ids, proid_2);

		for i,v in ipairs(ids) do
			local val = baseData[m_proName[v]];
			if(strenlv > MIN_STREN_LV and strenlv <= MAX_STREN_LV) then
				val = val + Util.strToNumber(Util.Split(growData["pro_valueDiff" .. i], ";"))[strenlv];
			end
			table.insert(vals, val);
		end

		local data = {};
		data.ids = ids;
		data.vals = vals;
		data.level = baseData.level;
		return data;
	else
		print("计算普通参数错误");
	end
end


--计算成长性装备在某一品阶、某一等级下的属性
--返回：装备等级，套装属性，属性id集合，属性值集合
function calcGrowEquip( id, steplv, strenlv )
	if(id and steplv and strenlv) then
		local baseData = DataTableManager.getItem(Table_growBase, "id_" .. id);
		local growData = DataTableManager.getItem(Table_growIntensify, "id_" .. id);

		local levels = Util.strToNumber(Util.Split(baseData["level"], ";"));
		local level = levels[steplv];

		local suitTypes = Util.strToNumber(Util.Split(baseData["suitType"], ";"));
		local suitType = suitTypes[steplv];

		local ids = {};
		local vals = {};

		local proid_1 = growData["id_step" .. steplv .. "_pro1"];
		local proid_2 = growData["id_step" .. steplv .. "_pro2"];
		table.insert(ids, proid_1);
		table.insert(ids, proid_2);

		for i,v in ipairs(ids) do
			local val = Util.strToNumber(Util.Split(baseData[m_proName[v]], ";"))[steplv];
			if(strenlv > MIN_STREN_LV and strenlv <= MAX_STREN_LV) then
				val = val + Util.strToNumber(Util.Split(growData["value_step" .. steplv .. "_pro" .. i], ";"))[strenlv];
			end

			table.insert(vals, val);
		end

		local data = {};
		data.level = level;
		data.suitType = suitType;
		data.ids = ids;
		data.vals = vals;
		return data;
	else
		print("计算成长性装备参数错误");
	end
end











--重新load数据

local function loadData( dataName, itemKey, key, value )
	if(_G[dataName][itemKey] == nil) then
		_G[dataName][itemKey] = {};
	end
	_G[dataName][itemKey][key] = value;
end


-- 提取出六阶中的两组有效属性值 和 属性类型
function reloadGrowEquipData()
	local datas = DataTableManager.getTableByName("growEquipment_intensifyDataOld");
	for k,v in pairs(datas) do
		local id = v.id;
		local dStr = v.value;
		local steps = Util.Split(dStr, ":");
		--提前每阶属性
		for i,stepV in ipairs(steps) do
			local stepid = i;
			--12个属性
			local pros = Util.Split(stepV, "|");
			local nullStr = "0;0;0;0;0;0;0;0;0;0;0;0;0";
			local n = 0;
			local proid1 = 0;
			local proid2 = 0;
			local provalue1 = "";
			local provalue2 = "";

			for j,proV in ipairs(pros) do
				if(nullStr ~= proV) then
					n = n + 1;
					if(n == 1) then
						proid1 = j;
						provalue1 = proV;
					elseif(n == 2)then
						proid2 = j;
						provalue2 = proV;
					end
				end
			end
			loadData( "growEquipment_intensifyNew", "id_" .. id, "id_step" .. stepid .. "_pro1", proid1 );
			loadData( "growEquipment_intensifyNew", "id_" .. id, "id_step" .. stepid .. "_pro2", proid2 );
			loadData( "growEquipment_intensifyNew", "id_" .. id, "value_step" .. stepid .. "_pro1", provalue1 );
			loadData( "growEquipment_intensifyNew", "id_" .. id, "value_step" .. stepid .. "_pro2", provalue2 );
		end
		loadData( "growEquipment_intensifyNew", "id_" .. id, "id", id );
	end
end


function reloadNormalEquipData()
	local datas = DataTableManager.getTableByName("normalEquipment_intensifyDataOld");
	for k,v in pairs(datas) do
		local id = v.id;
		local dStr = v.value;
		--12个属性
		local pros = Util.Split(dStr, "|");
		local nullStr = "0;0;0;0;0;0;0;0;0;0;0;0;0";
		local n = 0;
		local proid1 = 0;
		local proid2 = 0;
		local provalue1 = "";
		local provalue2 = "";

		for j,proV in ipairs(pros) do
			if(nullStr ~= proV) then
				n = n + 1;
				if(n == 1) then
					proid1 = j;
					provalue1 = proV;
				elseif(n == 2)then
					proid2 = j;
					provalue2 = proV;
				end
			end
		end
		loadData( "equipment_intensifyNew", "id_" .. id, "id", id );
		loadData( "equipment_intensifyNew", "id_" .. id, "pro_1_id", proid1 );
		loadData( "equipment_intensifyNew", "id_" .. id, "pro_2_id", proid2 );
		loadData( "equipment_intensifyNew", "id_" .. id, "pro_valueDiff1", provalue1 );
		loadData( "equipment_intensifyNew", "id_" .. id, "pro_valueDiff2", provalue2 );
	end
end


--根据装备id、强化等级、品阶获得基本信息（名称、颜色、装备等级、部位）
function getBaseInfo( id, steplv )
	local data = {};
	local isGrow = GoodsManager.isGrowEquip(id);
	local name = "";
	local color = 0;
	local level = 0;
	local part  = 0;
	if(isGrow ~= -1) then
		if(isGrow) then
			local baseData = DataTableManager.getItem(Table_growBase, "id_" .. id);
			name = baseData["name"];
			color = baseData["color"];
			local levels = Util.strToNumber(Util.Split(baseData["level"], ";"));
			level = levels[steplv];
			part = baseData["part"];
		else
			local baseData = DataTableManager.getItem(Table_normalBase, "id_" .. id);
			name = baseData["name"];
			color = baseData["color"];
			level = baseData["level"];
			part = baseData["part"];
		end
		data.name = name;
		data.color = color;
		data.level = level;
		data.part = part;
		return data;
	end
	return nil;
end



--计算装备强化消耗
--参数：id、强化等级、品阶
--返回：金币数量
function calcStrenUse( id, strenLv, stepLv )
	-- 装备强化金额 = 	强化等级基数 * 装备颜色系数 * 装备等级系数 * 装备部位系数
	-- 强化等级基数= 强化等级^2.5(向下取整)
	local money = 0;
	local strenBaseParam = DataTableManager.getValue("EquipStrenUse_BaseParam", "id_1", "count");
	local baseParam = 0;
	local colorPram = 0;
	local levelParam = 0;
	local partParam = 0;

	local baseInfo = getBaseInfo(id, stepLv);
	local color = baseInfo.color;
	local level = baseInfo.level;
	local part  = baseInfo.part;

	baseParam = math.max(1, math.floor(math.pow(strenLv + 1, tonumber(strenBaseParam))));
	local isGrow = GoodsManager.isGrowEquip(id);
	if(isGrow ~= -1) then
		if(isGrow == true) then
			colorPram = tonumber(DataTableManager.getItemByKey("EquipStrenUse_ColorParam", "color", 5)["num"]);
		else
			colorPram = tonumber(DataTableManager.getItemByKey("EquipStrenUse_ColorParam", "color", color)["num"]);
		end
	else
		colorPram = 1;
	end
	local wearLvDatas = DataTableManager.getTableByName("EquipStrenUse_WearLVParam");
	local lastNum = 0;
	local count = 0;
	for k,v in pairs(wearLvDatas) do
		count = count + 1;
	end
	for i=1,count do
		local v = wearLvDatas["id_" .. i];
		if(level < v.level) then
			break;
		end
		lastNum = tonumber(v.num);
	end
	levelParam = lastNum;

	partParam = tonumber(DataTableManager.getItemByKey("EquipStrenUse_PartParam", "part", part)["num"]);

	return math.ceil(baseParam*colorPram*levelParam*partParam);
end

--计算装备重置消耗
--参数：id、品阶、锁定数量
--返回：金币数量, 元宝数量
function calcResetMoneyUse( id, upstepLv )
	local isGrow = GoodsManager.isGrowEquip(id);
	local money = 0;
	
	if(isGrow ~= -1) then
		local baseInfo = getBaseInfo(id, upstepLv);
		local level = baseInfo.level;
		local moneyData = DataTableManager.getItemByKey("EquipResetUse_BaseParam", "level", level);
		if(isGrow) then
			money = moneyData.suit;
		else
			local color = baseInfo.color;
			if(color == COLOR_GREEN) then
				money = moneyData.green;
			elseif(color == COLOR_BLUE) then
				money = moneyData.blue;
			elseif(color == COLOR_PURPLE) then
				money = moneyData.purple;
			end
		end
		return math.ceil(money);
	end
	return nil;
end

function calcResetTokenyUse( lockCount )
	if(lockCount > 0) then
		return DataTableManager.getItemByKey("EquipResetUse_LockParam", "count", lockCount)["num"];
	end
	return 0;
end

--计算装备升阶消耗
--金币消耗
function calcUpstepMoneyUse( upstepLv )
	local data = DataTableManager.getItemByKey("EquipUpstepUse", "id", upstepLv);
	if(data ~= nil) then
		return data.money;
	end
	return 0;
end
--绑定升阶元宝消耗
function calcUpstepTokenUse( upstepLv )
	local data = DataTableManager.getItemByKey("EquipUpstepUse", "id", upstepLv);
	if(data ~= nil) then
		return data.token;
	end
	return 0;
end



--计算装备灵魂炼化消耗
--参数：炼化之后的灵魂等级
--返回：金币数量
function calcSoulChemialUse( soulLv )
	if(soulLv) then
		return DataTableManager.getItemByKey("EquipSoulChemicalUse_BaseParam", "level", soulLv)["num"];
	end
	return nil;
end

--计算装备灵魂重置消耗
function calcSoulResetUse()
	return DataTableManager.getValue("EquipSoulResetUse_BaseParam", "id_1", "price");
end

--计算装备灵魂转换消耗
--参数：绑定条数
--返回：金币数量、元宝数量

function calcSoulTranMoneyUse()
	return DataTableManager.getValue("EquipSoulTransUse_BaseParam", "id_1", "price");
end

function calcSoulTransTokenUse( lockCount )
	local token = 0;
	if(lockCount > 0) then
		token = DataTableManager.getItemByKey("EquipSoulTransUse_LockParam", "count", lockCount)["num"];
	end
	return token;
end


local m_AdditionProName = {
	"force_a",	"quick_a",	"endurance_a",	
	"atk_a",	"def_a",	"hp_a",	"speed_a",	"bash_a",	
	"crit_a",	"counter_a",	"parry_a",	"dodge_a",
};


--额外属性最大值
function getAddtionProMaxValue( id, proid, steplv )
	local isGrow = GoodsManager.isGrowEquip(id);
	if(isGrow ~= -1) then
		if(isGrow) then
			local baseData = DataTableManager.getItem(Table_growBase, "id_" .. id);
			local addPros = Util.strToNumber(Util.Split(baseData[m_AdditionProName[proid]], ";"));
			return addPros[steplv];
		else
			local baseData = DataTableManager.getItem(Table_normalBase, "id_" .. id);
			return baseData[m_AdditionProName[proid]];
		end
	end
	return 0;
end

function getAddtionProColor(id, proid, value, steplv)
	if(proid > 0) then
		local max = getAddtionProMaxValue(id, proid, steplv);
		local per = value/max;

		if(per > 0.8) then
			return COLOR_VALUE[COLOR_ORANGE];
		elseif(per > 0.6) then
			return COLOR_VALUE[COLOR_PURPLE];
		elseif(per > 0.4) then
			return COLOR_VALUE[COLOR_BLUE];
		elseif(per > 0.2) then
			return COLOR_VALUE[COLOR_GREEN];
		else
			return COLOR_VALUE[COLOR_WHITE];
		end
	end
	return COLOR_VALUE[COLOR_WHITE];
end

function getAddtionProCount( id )
	local color = GoodsManager.getColorById(id);
	if(color == COLOR_WHITE) then
		return 0;
	elseif(color == COLOR_GREEN) then
		return 2;
	elseif(color == COLOR_BLUE) then
		return 4;
	elseif(color == COLOR_PURPLE or color == COLOR_ORANGE) then
		return 5;
	end
		
	return 0;		
end


---------------------------------------吞噬产出----------------------------------------------

local Table_DevourStren = "DevourStren";
local Table_DevourLevel = "DevourLevel";
local Table_DevourLevelMoney  = "DevourLevelMoney";
local Table_DevourLevelSoulYu = "DevourLevelSoulYu";
local Table_DevourLevelUpstepStone = "DevourLevelUpstepStone";

--计算某件装备被吞噬产出的物品
--产出包括：武器经验、金币、魂玉、升阶石   exp, money, soulYu, upstepStone
function getDevourProduce(equipData, weaponData)
	local strenLv = equipData.strenLV;
	local level = equipData.level;
	local strenPer = DataTableManager.getValue(Table_DevourStren, "id_" .. strenLv, "add");
	local weaponLv = (weaponData.step - 1) * WeaponCalc.getMaxStrenlv() + weaponData.star;
	local lvCoef = math.max(0.05, 1.0 - (weaponLv - level) * 0.05);

	local exp = 0;
	local money = 0;
	local soulYu = 0;
	local upstepStone = 0;
	if(GoodsManager.isGrowEquip(equipData.id)) then
		exp = DataTableManager.getValue(Table_DevourLevel, "id_" .. level, "suit");
		money = DataTableManager.getValue(Table_DevourLevelMoney, "id_" .. level, "suit");
		soulYu = DataTableManager.getValue(Table_DevourLevelSoulYu, "id_" .. level, "suit");
		upstepStone = DataTableManager.getValue(Table_DevourLevelUpstepStone, "id_" .. level, "suit");
	else
		local color = GoodsManager.getColorById(equipData.id);
		if(color == COLOR_WHITE) then
			exp = DataTableManager.getValue(Table_DevourLevel, "id_" .. level, "white");
			money = DataTableManager.getValue(Table_DevourLevelMoney, "id_" .. level, "white");
			soulYu = DataTableManager.getValue(Table_DevourLevelSoulYu, "id_" .. level, "white");
			upstepStone = DataTableManager.getValue(Table_DevourLevelUpstepStone, "id_" .. level, "white");
		elseif(color == COLOR_GREEN) then
			exp = DataTableManager.getValue(Table_DevourLevel, "id_" .. level, "green");
			money = DataTableManager.getValue(Table_DevourLevelMoney, "id_" .. level, "green");
			soulYu = DataTableManager.getValue(Table_DevourLevelSoulYu, "id_" .. level, "green");
			upstepStone = DataTableManager.getValue(Table_DevourLevelUpstepStone, "id_" .. level, "green");
		elseif(color == COLOR_BLUE) then
			exp = DataTableManager.getValue(Table_DevourLevel, "id_" .. level, "blue");
			money = DataTableManager.getValue(Table_DevourLevelMoney, "id_" .. level, "blue");
			soulYu = DataTableManager.getValue(Table_DevourLevelSoulYu, "id_" .. level, "blue");
			upstepStone = DataTableManager.getValue(Table_DevourLevelUpstepStone, "id_" .. level, "blue");
		elseif(color == COLOR_PURPLE) then
			exp = DataTableManager.getValue(Table_DevourLevel, "id_" .. level, "purple");
			money = DataTableManager.getValue(Table_DevourLevelMoney, "id_" .. level, "purple");
			soulYu = DataTableManager.getValue(Table_DevourLevelSoulYu, "id_" .. level, "purple");
			upstepStone = DataTableManager.getValue(Table_DevourLevelUpstepStone, "id_" .. level, "purple");
		end
	end
	exp = math.floor(math.max(1, (exp * lvCoef * strenPer)));
	money = math.floor(math.max(1, (money * lvCoef * strenPer)));
	soulYu = math.floor(math.max(1, (soulYu * lvCoef * strenPer)));
	upstepStone = math.floor(math.max(1, (upstepStone * lvCoef * strenPer)));

	local produce = {};
	produce.exp = exp;
	produce.money = money;
	produce.soulYu = soulYu;
	produce.upstepStone = upstepStone;
	return produce;
end




--装备升阶消耗
--返回：{{id = , count = }, {id = , count = }, ... }
function getUpstepUse( equipData )
	local id = equipData.id;
	local step = equipData.upstepLV;
	if(step > 0) then
		local data = DataTableManager.getItem(Table_growBase, "id_" .. id);
		if(data ~= nil) then
			-- step1 = "170026:3;170027:4;170028:10",
			-- step2 = "170026:3;170027:4;170028:11",
			local useStr = data["step" .. step];
			if(useStr and useStr ~= "") then
				local uses = Util.Split(useStr, ";");
				local useData = {};
				for i=1,#uses do
					local d = Util.strToNumber(Util.Split(uses[i], ":"));
					local dd = {};
					if(d[1] > d[2]) then
						dd.id = d[1];
						dd.count = d[2];
					else
						dd.id = d[2];
						dd.count = d[1];
					end
					table.insert(useData, dd);
				end
				return useData;
			end
		end
	end
	return nil;
end