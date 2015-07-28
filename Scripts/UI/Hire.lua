module("Hire", package.seeall)


-- require (PATH_SCRIPT_TEST .. "FriendData")
-- require (PATH_SCRIPT_TEST .. "FrendPersonData")


SELECTED_COLOR   = ccc3(255,0,0)
DISSELCTED_COLOR = ccc3(255,255,255)

NAMEINDEX        = 1
ATKINDEX         = 2
DEFINDEX         = 3
SPDINDEX         = 4

local m_rootLayer       = nil;
local m_friendList      = nil;
local m_lastSelectIndex = 0;
local m_messagePanel    = nil;

local function getFriendDataTable()
	-- body
	local friendDataTable = FriendData.getFriendDataTable();


	return friendDataTable;
end 


local function hireTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		local index = m_lastSelectIndex + 1;
		local friendDataTable = getFriendDataTable();
		local friendData = friendDataTable[index];
		local freStr = friendData[NAMEINDEX];
		freStr = freStr .. "被你雇佣了";
		CCLuaLog(freStr);


		UIManager.close("Hire");
		UIManager.open("Treasure");
	end

end

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
	  	UIManager.close("Hire");
	end;
end 

local function changeLabelColor(sender,index)
	-- body
	CCLuaLog(m_lastSelectIndex);
	local curItem = sender:getItem(index);
	local labelPanel = curItem:getChildByName("Panel_24");
	local name = labelPanel:getChildByName("nameLabel");
	name:setColor(SELECTED_COLOR);

	local curItemLast = sender:getItem(m_lastSelectIndex);
	local labelPanelLast = curItemLast:getChildByName("Panel_24");
	local nameLast = labelPanelLast:getChildByName("nameLabel");
	nameLast:setColor(DISSELCTED_COLOR);
end 

local function changeRoleMessage(index)
	-- body
	local friendDataTable = getFriendDataTable();
	local friendData = friendDataTable[index];


	local messagePanel = m_messagePanel;
	local nameLabel = messagePanel:getChildByName("nameDataLabel");
	nameLabel = tolua.cast(nameLabel,"Label");

	local atkLabel = messagePanel:getChildByName("atkDataLabel");
	atkLabel = tolua.cast(atkLabel,"Label");

	local defLabel = messagePanel:getChildByName("defDataLabel");
	defLabel = tolua.cast(defLabel,"Label");

	local spdLabel = messagePanel:getChildByName("spdDataLabel");
	spdLabel = tolua.cast(spdLabel,"Label");

	local nameStr = friendData[NAMEINDEX];
	nameLabel:setText(nameStr);

	local atkStr = friendData[ATKINDEX];
	atkLabel:setText(atkStr);

	local defStr = friendData[DEFINDEX];
	defLabel:setText(defStr);

	local spdStr = friendData[SPDINDEX];
	spdLabel:setText(spdStr);
end 

local function listViewTouchEvent(sender,eventType)
	-- body
	local index = sender:getCurSelectedIndex();
	if eventType == LISTVIEW_ONSELECTEDITEM_START then
	   if index ~= m_lastSelectIndex then
	   	changeLabelColor(sender,index);
	   	changeRoleMessage(index+1);
	   end
    elseif eventType == LISTVIEW_ONSELECTEDITEM_END then
        CCLuaLog("You select friend is"..index);
    end

    m_lastSelectIndex = index;
end 

local function initFriendListView()
	-- body
	local friendTable = getFriendDataTable();

	for i=1,#friendTable do
		local friendData = friendTable[i];


        local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "FriendListItem.json");
        local labelPanel = item:getChildByName("Panel_24");
        local name = tolua.cast(labelPanel:getChildByName("nameLabel"), "Label");
        local nameStr = friendData[NAMEINDEX];
        name:setText(nameStr);

        if i == 1 then
        	name:setColor(SELECTED_COLOR);
        end
        m_friendList:pushBackCustomItem(item);
	end

	m_friendList:addEventListenerListView(listViewTouchEvent);
end


function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);

end

function create()
	-- body
	m_rootLayer = CCLayer:create();
    
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Hire.json");
	local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    -- m_rootLayer:retain();

    local messagePanel = uiLayer:getWidgetByName("messagePanel");
    m_messagePanel = messagePanel;


    local exitBtn = uiLayer:getWidgetByName("exit_btn");
    exitBtn:addTouchEventListener(exitTouchEvent);

    local hireBtn = uiLayer:getWidgetByName("hire_btn");
    hireBtn:addTouchEventListener(hireTouchEvent);

    local friendList = uiLayer:getWidgetByName("friendList");
    friendList = tolua.cast(friendList,"ListView");
    m_friendList = friendList;

    initFriendListView();

end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);	
	m_rootLayer:release();
	m_rootLayer       = nil;
	m_friendList      = nil;
	m_lastSelectIndex = 0;
	m_messagePanel    = nil;
end

