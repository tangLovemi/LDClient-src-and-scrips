module("JJCGroup", package.seeall)

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate  = false;
local m_isOpen = false;
local m_scoreDatas = nil;

function setPosition( pos )
	if(pos) then
		m_rootLayer:setPosition(pos);
	end
end

function getMinScoreOfGroup( index )
	return m_scoreDatas[index].score;
end

local function refreshInfo()
	if(m_scoreDatas) then
		local count = JJCUI.getGroupCount();
		for i=1, count do
			local scoreLabel = tolua.cast(m_rootLayout:getWidgetByName("fenshuAtlasLabel_" .. i), "LabelAtlas");
			scoreLabel:setStringValue(m_scoreDatas[i].score);
		end
	end
end

local function gotoPersonal( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		JJCGroup.close();
		JJCPersonal.open();
		JJCUI.refreshOpps();
		JJCUI.setTimePanelVisiable(true);
	end
end

local function groupOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		local index = sender:getTag();
		JJCUI.requestHeadPlayers(index - 1);
	end
end

function onReceiveGroupScores( messageType, messageData )
    if(messageData) then
    	m_scoreDatas = messageData;
    	refreshInfo();
    end
end

local function openInit()
    -- local jjcData = UserInfoManager.getRoleInfo("jjcData");
    -- local groupid = jjcData.groupId;--  0-6
    -- local groupCount = JJCUI.getGroupCount();
	-- tolua.cast(m_rootLayout:getWidgetByName("group_slv"), "ScrollView"):scrollToPercentVertical((100/groupCount)*groupid, 0.5, false);
	JJCUI.requestHeadPlayers(0);
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;

		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

		m_rootLayout = TouchGroup:create();
		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "JJC_paihang_1.json");
		m_rootLayout:addWidget(uiLayout);
		m_rootLayer:addChild(m_rootLayout, 1);

   	 	local gotoPersonal_btn = m_rootLayout:getWidgetByName("gotoPersonal_btn");
   	 	gotoPersonal_btn:addTouchEventListener(gotoPersonal);

   	 	for i=1,JJCUI.getGroupCount() do
   	 		local groupBtn = m_rootLayout:getWidgetByName("zuImg_".. i);
   	 		groupBtn:setTag(i);
   	 		groupBtn:addTouchEventListener(groupOnClick);
   	 	end
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;

		local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);

        openInit();
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
		if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    end
		m_rootLayer = nil;
		m_rootLayout = nil;
	end
end