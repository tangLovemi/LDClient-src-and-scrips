module("CoatCalc", package.seeall)


--用于计算某一外套的属性加成

-- force_atk	
-- force_def	
-- force_hp	
-- force_speed	
-- force_bash  	
-- force_crit	
-- force_catk	
-- force_parry	
-- force_dodge	

-- agility_atk	
-- agility_def	
-- agility_hp	
-- agility_speed	
-- agility_bash  	
-- agility_crit	
-- agility_catk	
-- agility_parry	
-- agility_dodge	

-- endurance_atk	
-- endurance_def	
-- endurance_hp	
-- endurance_speed	
-- endurance_bash  	
-- endurance_crit	
-- endurance_catk	
-- endurance_parry	
-- endurance_dodge	

-- skillid	
-- nextStepId

local m_proName = {
	"atk",	"def",	"hp",	"speed",	"bash",	"crit",	"catk",	"parry",	"dodge"
};

local ColorType = {
	WRITE	= 1,
	GREEN	= 2,
	BLUE	= 3,
	PURPLE	= 4,
	ORANGE	= 5
};

function getMaxLv( color )
	if(color == ColorType.WRITE) then
		return 1;
	elseif(color == ColorType.GREEN) then
		return 2;
	elseif(color == ColorType.BLUE) then
		return 3;
	elseif(color == ColorType.PURPLE) then
		return 4;
	elseif(color == ColorType.ORANGE) then
		return 5;
	end
end

function canStren(data)
	local maxLv = getMaxLv(data.color);
	return (data.lv < maxLv);
end

function canUpStep( data )
	local curItem = DataTableManager.getItem("coat_grow_Data", "id_" .. data.id);
	local nextStepId = curItem.nextStepId;
	return (nextStepId > 0);
end

-- //		int		id			外套ID	
-- //		byte	color		颜色	
-- //		string	name		名称	
-- //		byte	lv			等级	
-- //		string	strenPro	力量转化	
-- //		string	agilityPro	敏捷转化	
-- //		string	endurPro	耐力转化


function calcCoat( id, lv )
	local item = DataTableManager.getItem("coat_grow_Data", "id_" .. id);

	local data = {strenPro = {}, agilityPro = {}, endurPro = {}, addition = {}};
	local name = {"strenPro", "agilityPro", "endurPro"};
	local key = {"force", "agility", "endurance"};
	for i=1,#name do
		local n = 0;
		for j=1,#m_proName do
			local ds = item[key[i] .. "_" .. m_proName[j]];
			local d = Util.strToNumber(Util.Split(ds, ";"));
			local isEffect = false;
			for k,v in ipairs(d) do
				if(v > 0) then
					isEffect = true;
					break;
				end
			end
			if(isEffect) then
				n = n + 1;
				local d = Util.strToNumber(Util.Split(ds, ";"));
				data[name[i]][n] = {proid = j + 3, proval = d[lv]};
			end
		end
		data.addition[name[i]] = {proid = item[key[i] .. "_addition_id"], proval = tonumber(item[key[i] .. "_addition_value"])};
	end
	return data;
end


--计算外套下一强化等级数据
--返回 data = {strenPro = {}, agilityPro = {}, endurPro = {}}
function calcCoat_nextStrenlv( data )
	local d = calcCoat(data.id, data.lv + 1);
	return d;
end

--计算外套下一品阶数据
--返回 data = {id, color, name, lv, strenPro = {}, agilityPro = {}, endurPro = {]}}
function calcCoat_nextSteplv( data )
	local curItem = DataTableManager.getItem("coat_grow_Data", "id_" .. data.id);
	local nextStepId = curItem.nextStepId;
	local nextItem = DataTableManager.getItem("coat_grow_Data", "id_" .. nextStepId);
	local d = {};
	d.id = nextItem.id;
	d.color = nextItem.color;
	d.name = nextItem.name;
	d.lv = 1;
	local pro = calcCoat(d.id, d.lv);
	d.strenPro = pro.strenPro;
	d.agilityPro = pro.agilityPro;
	d.endurPro = pro.endurPro;
	d.addition = pro.addition;

	return d;
end

function getCoatData( id,  lv)
	local data = DataTableManager.getItem("coat_grow_Data", "id_" .. id);
	local d = {};
	d.id = data.id;
	d.color = data.color;
	d.name = data.name;
	d.lv = lv;
	local pro = calcCoat(d.id, d.lv);
	d.strenPro = pro.strenPro;
	d.agilityPro = pro.agilityPro;
	d.endurPro = pro.endurPro;
	return d;
end


--武器升阶消耗
--返回：{{id = , count = }, {id = , count = }, ... }
function getUpstepUse( coatdata )
	if(canStren(coatdata) or canUpStep(coatdata)) then
		local lv = coatdata.lv;
		local useItem = DataTableManager.getItem("coat_upstep_use", "id_" .. coatdata.id);
		if(useItem ~= nil) then
			local useStr = useItem["step" .. lv];
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