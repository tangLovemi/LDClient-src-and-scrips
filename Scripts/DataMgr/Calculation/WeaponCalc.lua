module("WeaponCalc", package.seeall)

--用于计算某一武器的基础属性和额外属性



local m_proName = {
	"force", "quick", "endurance",
	"atk",	"def",	"hp",	"speed",	"bash",	"crit",	"catk",	"parry",	"dodge"
};

local TABLE_BASE_PRO 	= "weapon_base_proBase_Data";--基础属性基础表
local TABLE_BASE_GROW 	= "weapon_base_grow_Data"; --基础属性成长表
local TABLE_GROW_PRO 	= "weapon_second_proBase_Data";--额外属性基础表
local TABLE_GROW_GROW 	= "weapon_second_grow_Data";--额外属性成长表
local TABLE_PRO_LV 		= "weapon_star_Data"; --额外属性级别表

local MAX_STREN_LV  = 10; --最大强化等级
local MAX_STEP_LV	= 7; --成长性装备最大品阶

local MIN_STAR_LV = 1;

local MAX_WEAPON_COUNT = 19;

-- //		string	proId		额外属性id号	
-- //		string	proLV		额外属性星级
-- //		byte	atkPer		攻击力比率

function getMaxSteplv()
	return MAX_STEP_LV;
end

function getMaxStrenlv()
	return MAX_STREN_LV;
end

function getMinStarlv()
	return MIN_STAR_LV;
end

--判断是否可以继续升阶
function canUpStep( steplv )
	return (steplv > 0 and steplv < MAX_STEP_LV);
end

--判断达到最大强化等级
function canUpStren( strenlv )
	return (strenlv >= 0 and strenlv < MAX_STREN_LV);
end

function getMaxWeaponCount()
	return MAX_WEAPON_COUNT;
end


--计算某武器的某一品阶某一个等级的值
--返回：基础属性 额外属性值  d = {atk = , addition = {}}
function calcWeapon( data, steplv, strenlv )
	local atkper = data.atkPer;
	local base = DataTableManager.getValue(TABLE_BASE_PRO, "id_" .. steplv, "max");
	local baseGrow = DataTableManager.getValue(TABLE_BASE_GROW, "id_" .. steplv, "atk");
	local atk = math.floor(  (base + baseGrow*(strenlv - 1))*(atkper/100)  ); --攻击力

	local proids = Util.strToNumber(Util.Split(data.proId, ";"));
	local prolvs = Util.strToNumber(Util.Split(data.proLV, ";"));
	local add = DataTableManager.getItem(TABLE_GROW_PRO, "id_" .. steplv);
	local addGrow = DataTableManager.getItem(TABLE_GROW_GROW, "id_" .. steplv);

	local addiData = {};
	for i,v in ipairs(proids) do
		local proLv = DataTableManager.getValue(TABLE_PRO_LV, "id_" .. prolvs[i], "coefficient");
		local value = add[m_proName[v]] + addGrow[m_proName[v]]*(strenlv - 1);
		value = value*(proLv/100);
		value = math.floor(value);
		table.insert(addiData, value);
	end

	local d = {};

	d.atk = atk;
	d.addition = addiData;

	return d;
end

--武器升阶消耗
--返回：{{id = , count = }, {id = , count = }, ... }
function getUpstepUse( weaponData )
	local id = weaponData.id;
	local step = weaponData.step;
	local data = DataTableManager.getItem("weapon_upstep_use", "id_" .. id);
	if(data ~= nil) then
-- step1 = "170026:3;170027:4;170028:10",
-- step2 = "170026:3;170027:4;170028:11",
		local useStr = data["step" .. step];
		if(useStr ~= "") then
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
	return nil;
end

--计算某件武器被吞噬产出的武器经验
function getDevourProduce(weaponData)
	local weaponExp = 0;
	local step = weaponData.step;
	local star = weaponData.star;

	for i=1,step do
		local expstr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. i, "exp");
		exps = Util.strToNumber(Util.Split(expstr, ";"));
		local index = star - 1;
		if(i ~= step)then
			index = #exps;
		end
		for j=1,index do
			weaponExp = weaponExp + exps[j];
		end
	end

	weaponExp = weaponExp + weaponData.exp;
	return math.floor(weaponExp*0.7);
end


--经验是否满，足够可以升阶
function canWeaponUpstep( weaponData )
	if(canUpStep(weaponData.step)) then
		if(weaponData.star >= MAX_STREN_LV) then
			local exp = weaponData.exp;
		    local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. weaponData.step, "exp");
		    local expDatas = Util.strToNumber(Util.Split(expDataStr, ";"));
		    if(exp >= expDatas[weaponData.star]) then
		    	return true;
		    end
		end
	end
	return false;
end