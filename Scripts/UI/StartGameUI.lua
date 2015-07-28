module("StartGameUI", package.seeall)
require "UI/MainMenu"
require "LoginMgr"
local m_isCreate		= false;
local m_isOpen 			= false;
local m_rootLayer  		= nil;
local m_serverListPanel	= nil;
local m_enterPanel 		= nil;
local m_waitingUI 		= nil;

local m_sm_listPanel	= nil;
local m_sm_headPanel 	= nil;
local m_sm_serversPanel = nil;

local m_lastSelectAare 	= nil;
local m_maxIndex        = 0;
local m_selectIndex_Start = nil;

local m_accountId       = nil;

FONTZISE  = 20;
FONTCOLOR = ccc3(237,177,62);
ITEMSIZE  = CCSizeMake(160,50);
LABEL_POSITION = ccp(80,25);

NEW_COLOR   = ccc3(250,184,11);
RELAX_COLOR = ccc3(47,181,39);
FULL_COLOR  = ccc3(250,0,4);

SELECTITEM_COLOR = ccc3(0,255,99);
DISSELECTITEM_COLOR = ccc3(0,0,0);

local Server_State = {
	NEW   = 1,
	RELAX = 2,
	FULL  = 3,
}

local m_serversTable = {"飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","哈龙在天","飞龙在天",
						"飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","吗龙在天","飞龙在天",
						"飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","几龙在天","飞龙在天",
						"飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","漂龙在天","飞龙在天",
						"飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","飞龙在天","写龙在天"}

local function recieveRoleInfo(messageData)
	-- body
	local name = messageData.name;
	local mapId = messageData.map;
	local uid = messageData.uid;
	UserInfoManager.setRoleInfo("uid",uid);
	CCLuaLog("玩家："..name);
	CCLuaLog("所在地图:"..mapId);
end

local function loadBeforeCreateDataEnd()
	StartGameUI.close();
	UIManager.open("FaceMakerNew", FACEMAKER_STATUS_CREATE);
end

local function recieveDataForEnterGame(messageType,messageData)
	-- body
	CCLuaLog("xxx");
	if messageData.sure == 1 then
		CCLuaLog("有角色");
		recieveRoleInfo(messageData);
		UIManager.close("StartGameUI");
		UIManager.close("newRegisterUI");
		UIManager.close("newLoginUI");
		----------------新登陆按钮设置-----------
		-- local button = MainMenu.startGameBtnSet();
		-- CCLuaLog("设置成功")
		-- button:setTouchEnabled(false);

		--等待服务器加载数据
		-- GameManager.loadDataFromServer();
		if(LoginMgr.isFirst()) then
			ProgressRadial.close();
			UIManager.close("FaceMakerNew");
		end
		LoginMgr.loadLoginData();
	end

	if messageData.sure == 0 then
		CCLuaLog("无角色");
		LoginMgr.setIsFirst(true);

		LoginMgr.loadBeforeCreateData(loadBeforeCreateDataEnd);
	end
end


local function enterGameTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		CCLuaLog(m_accountId);
		
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ENTERGAME, {m_accountId});
	end
end

local function getServerTable(index)
	-- body
	local max = index + 9
	if index + 9 > m_maxIndex then
		max = m_maxIndex;
	end

	local servers = {};
	for i=index,max do
		local str = m_serversTable[i];
		table.insert(servers,str);
	end
	return servers;
end 

local function setServersTable()
	-- body
end

local function setSelectServer(serverText)
	-- body
	local serverLabel = tolua.cast(m_enterPanel:getChildByName("select_panel"):getChildByName("serverA_label"),"Label");
	serverLabel:setText(serverText);

	m_serverListPanel:setEnabled(false);
end

local function setStateStrAndColor(serverState,stateTag)
	-- body
	local stateLabel = nil;
	if stateTag == Server_State.FULL then
		stateLabel = "爆满";
		serverState:setColor(FULL_COLOR);
	elseif stateTag == Server_State.RELAX then
		stateLabel = "放松";
		serverState:setColor(RELAX_COLOR);
	elseif stateTag == Server_State.NEW then
		stateLabel = "新开";
		serverState:setColor(NEW_COLOR);
	end

	serverState:setText(stateLabel);
end

local function listViewTouchEvent(sender,eventType)
		-- body
	if eventType == LISTVIEW_ONSELECTEDITEM_END then
		local tag = sender:getTag();
		local curIndex = sender:getCurSelectedIndex() + 1;
		CCLuaLog(curIndex);

		if m_selectIndex_Start == nil then
			m_selectIndex_Start = 1;
		end

		if tag == 1 then
			curIndex = m_selectIndex_Start + curIndex - 1;
		else
			curIndex = m_selectIndex_Start + curIndex + 5 - 1;
		end
		local serStr = m_serversTable[curIndex];		
		local text = string.format("%03d区",curIndex);
		serStr = text .. "(".. serStr.. ")";

		setSelectServer(serStr);
	end
end 

local function getSererList(tag)
	-- body
	local listStr = "serverList_"..tag;
	local listView = tolua.cast(m_sm_serversPanel:getChildByName(listStr),"ListView");

	listView:setTag(tag);
	listView:addEventListenerListView(listViewTouchEvent);

	return listView;
end


local function selectPanelTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then 
		m_serverListPanel:setEnabled(true);
		m_serverListPanel:setVisible(true);
	end
end

local function setServerItem(serverItem,str,stateTag)
	-- body
	local indexLabel = tolua.cast(serverItem:getChildByName("index_label"),"Label");
	local stateLabel = tolua.cast(serverItem:getChildByName("state_label"),"Label");

	indexLabel:setText(str);
	setStateStrAndColor(stateLabel,stateTag);
end

local function setHeadPanel()
	-- body
	-- 登录前获得
end


local function setSmallListPanel(index)
	-- body
	local servers = getServerTable(index);


	local headLabel = tolua.cast(m_sm_serversPanel:getChildByName("section_label"),"Label");
	local max = index + 9
	if index + 9 > m_maxIndex then
		max = m_maxIndex;
	end

	local headStr = string.format("服务器   %03d-%03d", index,max);

	headLabel:setText(headStr); 

	local listView_1 = getSererList(1);
	local listView_2 = getSererList(2);


	for i=1,5 do
		local item = listView_1:getItem(i-1);
		local str  = servers[i]
		local text = string.format("%03d区",index + i -1);
		str = text .. "    " .. str;
		local tag  = 2;
		setServerItem(item,str,tag);
	end

	if #servers > 5 then
		for i=1,(#servers - 5) do
			local item = listView_2:getItem(i-1);
			local str  = servers[i+5]
			local text = string.format("%03d区",index + i-1 + 5);
			str = text .. "    " .. str;
			local tag  = 2;
			setServerItem(item,str,tag);
		end
	end
end


local function changeItemColor(tag,color)
	-- body
	local listView = tolua.cast(m_sm_listPanel:getChildByName("allServer_listView"),"ListView");
	local item = listView:getItem(tag);
	item:setBackGroundColorOpacity(200);
	item:setBackGroundColor(color);
	item:setBackGroundColorType(1);
end 

local function selectServerAreaTouchEvent(sender,eventType)
	-- body
	if eventType == LISTVIEW_ONSELECTEDITEM_END then
		local tag = sender:getCurSelectedIndex();
		changeItemColor(tag,SELECTITEM_COLOR);

		local index = 1 + 10 * (tag); 
		setSmallListPanel(index);
		m_selectIndex_Start = index;

		if m_lastSelectAare ~= nil then
			changeItemColor(m_lastSelectAare,DISSELECTITEM_COLOR);
		end
		m_lastSelectAare = tag;
	end
end

local function setListPanel(index)
	-- body
	local listView = tolua.cast(m_sm_listPanel:getChildByName("allServer_listView"),"ListView");

	local count = math.ceil(index/10);

	local sum = 1;
	for i=1,count do
		local contentLabel = Label:create();
		local containLayer = Layout:create();
		containLayer:setSize(ITEMSIZE)
		containLayer:addChild(contentLabel);
		containLayer:setTouchEnabled(true);

		local text = nil;
		if i == count then
			text = string.format("%03d -- %03d区", sum,index);
		else
			text = string.format("%03d -- %03d区", sum,(sum+9));
		end
		contentLabel:setText(text);
		contentLabel:setColor(FONTCOLOR);
		contentLabel:setFontSize(FONTZISE);
		contentLabel:setPosition(LABEL_POSITION);
		listView:pushBackCustomItem(containLayer);
		sum = sum + 10;
	end

	listView:addEventListenerListView(selectServerAreaTouchEvent);
end

local function initEnterPanel()
	-- body
	local selectPanel = tolua.cast(m_enterPanel:getChildByName("select_panel"),"Layout");
	local enterGameBtn = m_enterPanel:getChildByName("enterGame_btn");

	selectPanel:addTouchEventListener(selectPanelTouchEvent);
	enterGameBtn:addTouchEventListener(enterGameTouchEvent);
end

local function initServerPanel()
	-- body
	local listPanel       = tolua.cast(m_serverListPanel:getChildByName("server_panel"),"Layout");
	local headPanel       = tolua.cast(m_serverListPanel:getChildByName("head_panel"),"Layout");
	local serversPanel    = tolua.cast(m_serverListPanel:getChildByName("smallList_panel"),"Layout");

	m_sm_listPanel    = listPanel;
	m_sm_headPanel 	  = headPanel;
	m_sm_serversPanel = serversPanel;

	local listView_1 = getSererList(1);
	for i=1,5 do
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI.."ServerListItemUI_1.json"); 
		listView_1:pushBackCustomItem(panel);
	end
	local listView_2 = getSererList(2);
	for i=1,5 do
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI.."ServerListItemUI_1.json"); 
		listView_2:pushBackCustomItem(panel);
	end
end 

local function initVariables()
	-- body
	m_serverListPanel	= nil;
	m_enterPanel 		= nil;
	m_waitingUI 		= nil;
	m_sm_listPanel		= nil;
	m_sm_headPanel	 	= nil;
	m_sm_serversPanel   = nil;
	m_maxIndex          = 0;
	m_selectIndex_Start = nil;
end

function openTheEnterLayer()
	-- body
	m_enterPanel:setEnabled(true);
end

function setAccountId(accountId)
	-- body
	m_accountId = accountId;
end

function create()
	-- body
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Login_StartUI_1.json");
		uiLayer = TouchGroup:create();
		uiLayer:addWidget(hotelLayer);
		m_rootLayer:addChild(uiLayer);

		m_rootLayer:retain();

		local enterPanel = tolua.cast(uiLayer:getWidgetByName("enter_panel"),"Layout");
		m_enterPanel = enterPanel;

		local serverListPanel = tolua.cast(uiLayer:getWidgetByName("serverList_panel"),"Layout");
		m_serverListPanel = serverListPanel;
		m_serverListPanel:setEnabled(false);

		initServerPanel();
		initEnterPanel();
		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ENTERGAME, recieveDataForEnterGame);

		return m_rootLayer;
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);

		m_maxIndex = #m_serversTable;
		setListPanel(m_maxIndex);
		setSelectServer("2区(世界之乱)");
		setServerItem(m_sm_headPanel,"2区 世界之乱",2);

		-- UIManager.open("newLoginUI");
		newLoginUI.open();
	end
end

function close()
	-- body
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,true);
	end
end

function remove()
	-- body
	if(m_isCreate) then
		m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		initVariables();
		NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_ENTERGAME, recieveDataForEnterGame);
	end
end