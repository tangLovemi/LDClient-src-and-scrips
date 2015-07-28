module("Soul", package.seeall)

local m_data = nil;
local m_list = nil;
local m_isCreate = false;
local m_panel = nil;





function add(equipData, listView)
	if(equipData) then
		m_data = equipData;
	end

	if(listView) then
		m_list = listView;
	end

	if(m_data and m_list) then

		local panel = m_panel:clone();

		local contentPanel = tolua.cast(panel:getChildByName("content_panel"), "Layout");

		local panel1 = tolua.cast(contentPanel:getChildByName("Panel_1"), "Layout");
		local wuxing_label = tolua.cast(panel1:getChildByName("wuxing_label"), "Label");

		local panel2 = tolua.cast(contentPanel:getChildByName("Panel_2"), "Layout");
		local soulLv_label = tolua.cast(panel2:getChildByName("soulLv_label"), "Label");

		local panel3 = tolua.cast(contentPanel:getChildByName("Panel_3"), "Layout");
		local soulPro_label = tolua.cast(panel3:getChildByName("soulPro_label"), "Label");

		local panel4 = tolua.cast(contentPanel:getChildByName("Panel_4"), "Layout");
		local soulCharactor_label = tolua.cast(panel4:getChildByName("soulCharactor_label"), "Label");

		wuxing_label:setText(GoodsManager.getWuxingName(m_data.wuxingPro));
		soulLv_label:setText(m_data.soulLV);
		soulPro_label:setText(DataTableManager.getValue("PropertyNameData", "id_" .. m_data.soulPro, "name"));
		soulCharactor_label:setText(GoodsManager.getColorName(m_data.soulCharacter))
		
		m_list:pushBackCustomItem(panel);
	end
end

function create()
	if(m_isCreate == false) then
		m_isCreate = true;
		m_panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI_EQUIPANEL .. "SoulProperty.json");
		m_panel:retain();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		m_panel:release();
	end
end