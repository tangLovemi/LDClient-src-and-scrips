module("FunBtnCount3", package.seeall)

-------------------------------------
-- 功能按钮3个
-------------------------------------
local m_panel = nil;
local m_layouts = {};
local m_isCreate = false;
local DelName = {
	BP = "Backpack",
	Bank = "Bank",
	Figure = "Figure",

};

function getDelName()
	return DelName;
end

local function setShowName(layout, labels)
	for i = 1,3 do
		local v = labels[i];
		if(v ~= nil) then
			local btnNameImg = tolua.cast(layout:getWidgetByName("name_img_" .. i), "ImageView");
			btnNameImg:loadTexture(v);
		else
			local btnPanel = tolua.cast(layout:getWidgetByName("btn_panel_" .. i), "Layout");
			btnPanel:setEnabled(false);
		end
	end
end

-------------为按钮绑定监听--------------
local function boundListener(layout, cbs)
	for k,v in pairs(cbs) do
		if(v) then
			local btnPanel = tolua.cast(layout:getWidgetByName("btn_panel_" .. k), "Layout");
			btnPanel:addTouchEventListener(v);
		end
	end
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "FunctionBtn_count3.json");
		m_panel:retain();
	end
end


function open(name, cbs, labels, pos)
	if(name and cbs and pos and labels) then
		create();
		local layout = TouchGroup:create();
		-- layout:retain();
		local panel = m_panel:clone();
		layout:addWidget(panel);
		m_layouts[name] = layout;

		layout:setPosition(pos);
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(layout, FIVE_ZORDER);

		setShowName(layout, labels);

		boundListener(layout, cbs);
	end
end

function close()
	for k,v in pairs(DelName) do
		if(m_layouts[v]) then
			m_layouts[v]:removeFromParentAndCleanup(true);
			m_layouts[v] = nil;
		end
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		m_panel:release();
		m_panel = nil;
	end
end
