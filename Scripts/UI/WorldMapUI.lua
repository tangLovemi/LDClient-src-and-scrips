module("WorldMapUI", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;

local m_flagList = nil;

function isOpen()
	return m_isOpen;
end

--背包
local function panel_h_1_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.open("BackpackNew");
	end
end
--技能
local function panel_h_3_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.open("SkillsUINew");
	end
end
--任务
local function panel_h_6_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.open("TaskInfoUI");
	end
end
--活跃
local function panel_h_7_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.open("DailyTaskUI");
	end
end

--进入主城
local function gotoMainCityOnClick( sender,eventType )
	WorldMap.remove();
	GameManager.enterMainCityOther(1, nil);
end

local m_faceInfo = {
	face = 0, hair = 0, hairColor = 0, coat = 0
};
local m_headW = 91;
local m_headH = 91;
local m_headPos = ccp(m_headW/2, m_headH/2);

local function refreshFace()
	local userfaceInfo = UserInfoManager.getAllFaceInfo();
	local nowFace = {};
    nowFace.face = userfaceInfo.face;
    nowFace.hair = userfaceInfo.hair;
    nowFace.hairColor = userfaceInfo.hair_color.r;
    nowFace.coat = UserInfoManager.getRoleInfo("coat").type;

    if(nowFace.face ~= m_faceInfo.face or nowFace.hair ~= m_faceInfo.hair or nowFace.hairColor ~= m_faceInfo.hairColor or nowFace.coat ~= m_faceInfo.coat) then
    	m_faceInfo.face = nowFace.face;
    	m_faceInfo.hair = nowFace.hair;
    	m_faceInfo.hairColor = nowFace.hairColor;
    	m_faceInfo.coat = nowFace.coat;
    	--更改头像
    	local headW, headH = Util.getHeadSize();
    	local scaleX = m_headW/headW;
    	local scaleY = m_headH/headH;
    	local headPanel = tolua.cast(m_uiLayer:getWidgetByName("head_panel"), "Layout");
    	headPanel:removeAllNodes();

		local face = Util.createHeadNode(m_faceInfo.hair, m_faceInfo.hairColor, m_faceInfo.face, m_faceInfo.coat);
		face:setScaleX(scaleX);
		face:setScaleY(scaleY);
		face:setPosition(m_headPos);
		headPanel:addNode(face);
    end
end

local function resetFaceInfo()
	m_faceInfo.face = 0;
	m_faceInfo.hair = 0;
	m_faceInfo.hairColor = 0;
	m_faceInfo.coat = 0;
end

function refreshDisplay()
	if(m_isCreate and m_isOpen) then
		refreshFace();
		--角色名称
		local selfName = UserInfoManager.getRoleInfo("name");
		tolua.cast(m_uiLayer:getWidgetByName("name_label"), "Label"):setText(selfName);
		--级别
		local selfLv = UserInfoManager.getRoleInfo("level");
		tolua.cast(m_uiLayer:getWidgetByName("level_labelNum"), "LabelAtlas"):setStringValue(selfLv);
		ShopListPanel.refreshDisplay();
	end
end



function getNotificationImages()
	return m_flagList;
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		m_uiLayer = TouchGroup:create();
		m_rootLayer:addChild(m_uiLayer);
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "LargemapUI.json");
		m_uiLayer:addWidget(panel);
	--新手引导
		    if TaskManager.getNewState() then
		    	panel:setTouchEnabled(false)
		    	-- return
		    end
		--背包
		local panel_h_1 = tolua.cast(m_uiLayer:getWidgetByName("h_1_panel"), "Layout");
		panel_h_1:addTouchEventListener(panel_h_1_OnClick);

		--技能
		local panel_h_3 = tolua.cast(m_uiLayer:getWidgetByName("h_3_panel"), "Layout");
		panel_h_3:addTouchEventListener(panel_h_3_OnClick);

	    --任务
		local panel_h_6 = tolua.cast(m_uiLayer:getWidgetByName("h_6_panel"), "Layout");
		panel_h_6:addTouchEventListener(panel_h_6_OnClick);

		--活跃
		local panel_h_7 = tolua.cast(m_uiLayer:getWidgetByName("h_7_panel"), "Layout");
		panel_h_7:addTouchEventListener(panel_h_7_OnClick);

		m_flagList = {};
		m_flagList["h_1_img"] = tolua.cast(m_uiLayer:getWidgetByName("h_1_img"), "ImageView");
		m_flagList["h_3_img"] = tolua.cast(m_uiLayer:getWidgetByName("h_3_img"), "ImageView");
		m_flagList["h_6_img"] = tolua.cast(m_uiLayer:getWidgetByName("h_6_img"), "ImageView");
		m_flagList["h_7_img"] = tolua.cast(m_uiLayer:getWidgetByName("h_7_img"), "ImageView");

		m_uiLayer:getWidgetByName("zhucheng_panel"):addTouchEventListener(gotoMainCityOnClick);
	end
end

function open()

	if(not m_isOpen) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);

		refreshDisplay();
		NotificationManager.onLoginCheckAll();
	end
end


function close()
	if(m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
        m_rootLayer:removeAllChildrenWithCleanup(true);
        m_rootLayer:release();
        m_rootLayer = nil;
        m_uiLayer = nil;
        m_flagList = nil;
        resetFaceInfo();
	end
end