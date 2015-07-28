module("Addition", package.seeall)

local m_data = nil; --额外属性
local m_list = nil;
local m_isCreate = false;
local m_panel = nil;

local panel0 = nil;
local panel2 = nil;
local panel4 = nil;
local panel5 = nil;

local function transData()
	local idvals = Util.Split(m_data.additionProval, "|");
	local id = Util.strToNumber(Util.Split(idvals[1], ";"));
	local val = Util.strToNumber(Util.Split(idvals[2], ";"));
	return id, val;
end

local function attachPanel()
	local count = EquipmentCalc.getAddtionProCount(m_data.id);
	if(count == 0) then
		m_panel = panel0:clone();
	elseif(count == 2) then
		m_panel = panel2:clone();
	elseif(count == 4) then
		m_panel = panel4:clone();
	elseif(count == 5) then
		m_panel = panel5:clone();
	end
	m_list:pushBackCustomItem(m_panel);
end

local function showInfo()
	local ids, vals = transData();
	for i=1,#ids do
		local panel = tolua.cast(m_panel:getChildByName("Panel_" .. i), "Layout");
		local nameLabel = tolua.cast(panel:getChildByName("name_label"), "Label");
		local valueLabel = tolua.cast(panel:getChildByName("value_label"), "Label");
		if(ids[i] > 0) then
			nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[i], "name") .. ":");
			valueLabel:setColor(EquipmentCalc.getAddtionProColor(m_data.id, ids[i], vals[i], m_data.upstepLV));
			valueLabel:setText(vals[i]);
		end
	end
end

function add(data, listView)
	if(data) then
		m_data = data;
	end
	if(listView) then
		m_list = listView;
	end

	if(m_data and m_list) then
		attachPanel();
		if(m_data.color > COLOR_WHITE) then
			showInfo();
		end
	end
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		panel0 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Addition_0.json");
		panel0:retain();
		panel2 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Addition_2.json");
		panel2:retain();
		panel4 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Addition_4.json");
		panel4:retain();
		panel5 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Addition_5.json");
		panel5:retain();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		panel0:release();
		panel2:release();
		panel4:release();
		panel5:release();
	end
end