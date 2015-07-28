module("ExploreUI", package.seeall)


require "Tools/SJDropList"

local m_rootLayer = nil;
local m_explorePanel = nil;

local m_areDropLayer = nil;
local m_priordropLayer = nil;
local m_selectIndex = nil;

local m_panel = nil;


DROPLISTIMAGEPATH = PATH_CCS_RES .. "bg_1.png";

AREDROPLIST_POSITION = ccp(96,275);
PRIORTOLIST_POSITION = ccp(96,120);


local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("ExploreUI");
	end
end

local function startExploreTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		local priorstr = nil;
		local checkStr = nil;
		if m_priordropLayer.selectedIndex == 1 then
			priorstr = "经验优先";
		else
			priorstr = "金钱优先";
		end

		if m_selectIndex == 1 then
			checkStr = "清理仇人";
		elseif m_selectIndex == 2 then
			checkStr = "只杀仇人";
		else
			checkStr = "和平模式";
		end
		CCLuaLog("你选择了区域 "..m_areDropLayer.selectedIndex..",同时你选择了"..priorstr..",并且"..checkStr);
		UIManager.close("ExploreUI");
	end
end 

local function setDropLabel()
	-- body
	for i=1,8 do
		local str = "区域" .. i;
		m_areDropLayer:addLabel(str);
	end

	m_priordropLayer:addLabel("经验优先");
	m_priordropLayer:addLabel("金钱优先");
end

local function checkBoxTouchEvent(sender,eventType)
	-- body
	if CHECKBOX_STATE_EVENT_SELECTED then
		local index = sender:getTag();
		if sender:getSelectedState() == true then
			m_selectIndex = index;
			for i=1,3 do
				if i ~= index then
					checkBox = m_explorePanel:getChildByTag(i);
					checkBox:setSelectedState(false);
				end
			end
		else
			if m_selectIndex == index then
				m_selectIndex = nil;
			end
		end
		CCLuaLog(m_selectIndex);
	end
end 

local function initVariables()
	-- body
	m_areDropLayer:clean();
	m_priordropLayer:clean();
end

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ExploreUI_1.json");
	local uiLayer = TouchGroup:create();
	uiLayer:addWidget(uiLayout);
	m_rootLayer:addChild(uiLayer);
	-- m_rootLayer:retain();

	local explorePanel = tolua.cast(uiLayer:getWidgetByName("explore_panel"),"Layout");
	m_explorePanel = explorePanel;

	local area_topLabel = "选择探索区域";
	local area_dropLayer =  SJDropList.SJDropListClass:create(area_topLabel,DROPLISTIMAGEPATH);

	local area_dropLayout = area_dropLayer.DropLayer;
	area_dropLayout:setPosition(AREDROPLIST_POSITION);
	m_explorePanel:addChild(area_dropLayout);

	
	local priorTo_topLabel = "优先探索";
	local priorTo_dropLayer =  SJDropList.SJDropListClass:create(priorTo_topLabel,DROPLISTIMAGEPATH);
	local priorTo_dropLayout = priorTo_dropLayer.DropLayer;

	priorTo_dropLayout:setPosition(PRIORTOLIST_POSITION);
	m_explorePanel:addChild(priorTo_dropLayout);

	local exitBtn = uiLayer:getWidgetByName("exit_btn");
	exitBtn:addTouchEventListener(exitTouchEvent);

	local startBtn = uiLayer:getWidgetByName("sure_btn");
	startBtn:addTouchEventListener(startExploreTouchEvent); 

	for i=1,3 do
		local str = "select_checkBox_" .. i;
		local checkBox = tolua.cast(uiLayer:getWidgetByName(str),"CheckBox");
		checkBox:addEventListenerCheckBox(checkBoxTouchEvent);
		checkBox:setTag(i);
	end

	m_areDropLayer = area_dropLayer;
	m_priordropLayer = priorTo_dropLayer;
end


function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	setDropLabel();
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	initVariables();
end
function remove()
	-- body
	
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	m_explorePanel = nil;
end