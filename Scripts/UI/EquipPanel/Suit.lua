module("Suit", package.seeall)

local m_suitType = nil;
local m_list = nil;
local m_data = nil;

local m_suit  = nil;
local m_suit1 = nil;
local m_suit2 = nil;

local m_isCreate = false;

local function transData()
	m_data = {};
	local data = DataTableManager.getValue("equipSuitData", "id_" .. m_suitType, "pro");
	local d = Util.Split(data, "|");
	for i = 1,#d do
		local e = {};
		local es = Util.Split(d[i], ";");
		-- es[1] --同套装类型装备数量
		-- es[2] --激活属性id
		-- es[3] --激活属性值
		e.count = es[1];
		e.ids = Util.Split(es[2], ":");
		e.vals = Util.Split(es[3], ":");
		table.insert(m_data, e);
	end
end

local function showInfo()
	for i=1,#m_data do
		local panel = nil;
		local ids = m_data[i].ids;
		local vals = m_data[i].vals;
		local count = #ids;
		if(count == 1) then
			panel = m_suit1:clone();
		elseif(count == 2) then
			panel = m_suit2:clone();
		end
		local head_panel = tolua.cast(panel:getChildByName("head_panel"), "Layout");
		local countLabel = tolua.cast(head_panel:getChildByName("suitCount_label"), "Label");
		countLabel:setText(m_data[i].count);

		for j=1,#ids do
			local p = tolua.cast(panel:getChildByName("Panel_" .. j), "Layout");
			local nameLabel = tolua.cast(p:getChildByName("name_label"), "Label");
			local valLabel = tolua.cast(p:getChildByName("value_label"), "Label");
			nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[j], "name"));
			valLabel:setText(vals[j]);
		end
		m_list:pushBackCustomItem(panel);
	end
end


function add(suitType, listView)
	if(suitType) then
		m_suitType = suitType;
	end
	if(listView) then
		m_list = listView;
	end

	m_list:pushBackCustomItem(m_suit:clone());
	
	if(m_suitType and listView) then
		transData();
		showInfo();
	end
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_suit = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Suit.json");
		m_suit:retain();
		m_suit1 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Suit_1.json");
		m_suit1:retain();
		m_suit2 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "Suit_2.json");
		m_suit2:retain();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		m_suit1:release();
		m_suit2:release();
	end
end
