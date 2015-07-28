module("Login", package.seeall)

-- require "System/UserInfoManager"

UID               = 313; 
local m_rootLayer = nil;

local m_nameTextField = nil;
local m_psdTextField  = nil;
local m_loginPanel = nil;
local m_enterPanel = nil;
local m_nameLabel = nil;
local m_selectServerBtn = nil;
local m_serverNameLabel = nil;
local m_isNewServerLabel = nil;
local m_defaultAccount = "";
local m_defaultPwd = "";
local m_loginAllPanel = nil;
local m_curServerID = nil;
local m_enterDirectlyBtn = nil;
local m_registerBtn = nil;
local m_logoutBtn = nil;
-- 

LOGIN_SUCCESS           = 1;
LOGIN_ACCOUNT_NULL      = 2;
LOGIN_ACCOUNT_PSW_ERROR = 3;

local function exitTouchEvent(sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("Login");
	end
end 


local function relateAccountEvent(sender, eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- UIManager.close("Login");
	end
end

local function searchPsdEvent(sender, eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- UIManager.close("Login");
	end
end

local function selectServerEvent(sender, eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("ServerListUI");
		UIManager.close("Login");
	end
end

local function enterDirectlyEvent(sender, eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		ClipTouchLayer.show();
		-- UIManager.close("Login");
		createTcpConnect();
	end
end

local function enterQuicklyEvent(sender, eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- UIManager.close("Login");
	end
end

local function loginTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_nameTextField:getStringValue() == "")then
			Util.showOperateResultPrompt("未填写用户名");
			return;
		end
		if(m_psdTextField:getStringValue()  == "")then
			Util.showOperateResultPrompt("未填写密码");
			return;
		end

		ClipTouchLayer.show();
		m_defaultAccount = m_nameTextField:getStringValue();
		m_defaultPwd = m_psdTextField:getStringValue();
		createTcpConnect();
	end
end 

local function logoutTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- UIManager.open("newRegisterUI");
		CCUserDefault:sharedUserDefault():setStringForKey("defaultaccount","");
		CCUserDefault:sharedUserDefault():setStringForKey("defaultpwd","");
		m_defaultAccount = "";
		m_defaultPwd = "";
		setLoginUI();
		setUserNameAndPassWord("","");
	end
end

local function registerTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("newRegisterUI");
		UIManager.close("Login");
	end
end
-----------------------------------------------------

function isEnterCorrect()
	-- body
	if m_nameTextField:getStringValue() == "" or
	   m_psdTextField:getStringValue()  == "" then
	   return false;
	end
	return true;
end

local function initVariables()
	-- body
	m_rootLayer = nil;
    m_nameTextField = nil;
    m_psdTextField  = nil;
end

function setUserNameAndPassWord(name,password)
	-- body
	m_nameTextField:setText(name);
	m_psdTextField:setText(password);

end

local function setServerName(message)
	m_serverNameLabel:setText(message.serverName);
	if(message.serverName == 1)then
		m_isNewServerLabel:setText("新服");
	else
		m_isNewServerLabel:setText("火爆");
	end
end

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
	UIManager.close("Login");
	ClipTouchLayer.clear();
	UIManager.open("FaceMakerNew", FACEMAKER_STATUS_CREATE);
end

local function enterGame()
	-- UIManager.close("Login");

	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ENTERGAME, {m_defaultAccount});
end

local function recieveDataForEnterGame(messageType,messageData)
	-- body
	CCLuaLog("xxx");

	if messageData.sure == 1 then
		CCLuaLog("有角色");
		UIManager.close("Login");
		recieveRoleInfo(messageData);
		--等待服务器加载数据
		-- GameManager.loadDataFromServer();
		if(LoginMgr.isFirst()) then
			ProgressRadial.close();
			UIManager.close("FaceMakerNew");
		end
		ClipTouchLayer.clear();
		LoginMgr.loadLoginData();
	end

	if messageData.sure == 0 then
		CCLuaLog("无角色");
		LoginMgr.setIsFirst(true);

		LoginMgr.loadBeforeCreateData(loadBeforeCreateDataEnd);
	end
end

local function receiveDataForLogin(messageType, messageData)
    if messageData.sure == LOGIN_SUCCESS then
    	CCLuaLog("登录成功！");
    	-- if(BattleManager.isDebugMode)then--播放一场假战斗
    	-- 	UIManager.close("Login");
    	-- 	BattleManager.enterDebugBattle(enterGame);
    	-- else
    		enterGame();
    	-- end
    	
    	CCUserDefault:sharedUserDefault():setStringForKey("defaultaccount",m_defaultAccount);
		CCUserDefault:sharedUserDefault():setStringForKey("defaultpwd",m_defaultPwd);
    else
    	CCLuaLog("登录失败，输入的用户名或者密码有误！");
    end
end


function registerMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_LOGIN, receiveDataForLogin);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ENTERGAME, recieveDataForEnterGame);
end

function createTcpConnect()
	if(m_defaultAccount == "" or m_defaultPwd == "")then
		return;
	end
	local ip = LoginManager.getInfoByID(getCurServerID()).serverIP;
	NetWorkConnect.setConnectIP(ip);
	local gameScene = GameManager.getGameScene();
	NetWorkConnect.create(gameScene, ip);

	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_LOGIN, {m_defaultAccount,m_defaultPwd});
end


function setCurServerID(id)
	m_curServerID = id;
end

function getCurServerID()
	return m_curServerID;
end

function setLoginUI()
 	m_defaultAccount = "";
	m_defaultPwd = "";
 	m_logoutBtn:setVisible(false);
 	m_logoutBtn:setTouchEnabled(false);
 	m_registerBtn:setVisible(true);
 	m_registerBtn:setTouchEnabled(true);

 	m_enterPanel:setVisible(false);
 	m_loginPanel:setVisible(true);
 	m_enterDirectlyBtn:setVisible(false);
 	m_enterDirectlyBtn:setTouchEnabled(false);
 	m_nameLabel:setText("");
end

function setDirectLoginUI()

 	m_defaultAccount = CCUserDefault:sharedUserDefault():getStringForKey("defaultaccount");
 	m_defaultPwd = CCUserDefault:sharedUserDefault():getStringForKey("defaultpwd");
 		-- setUserNameAndPassWord(m_defaultAccount, m_defaultPwd);
 	m_enterPanel:setVisible(true);
 	m_loginPanel:setVisible(false);
 	m_nameLabel:setText(m_defaultAccount);
 	m_enterDirectlyBtn:setVisible(true);
 	m_enterDirectlyBtn:setTouchEnabled(true);
	m_logoutBtn:setTouchEnabled(true);
	m_logoutBtn:setVisible(true);
	m_registerBtn:setTouchEnabled(false);
	m_registerBtn:setVisible(false);
end

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "newLoginUI_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    
    local loginBtn = uiLayer:getWidgetByName("login_btn");
    loginBtn:addTouchEventListener(loginTouchEvent);

    m_registerBtn = uiLayer:getWidgetByName("register_btn");
    m_registerBtn:addTouchEventListener(registerTouchEvent);

    m_logoutBtn = uiLayer:getWidgetByName("zhuxiao_btn");
    m_logoutBtn:addTouchEventListener(logoutTouchEvent);

    local nameLabel = uiLayer:getWidgetByName("account_textfield");
    m_nameTextField = tolua.cast(nameLabel,"TextField");

    local psdLabel = uiLayer:getWidgetByName("password_textfield");
    m_psdTextField = tolua.cast(psdLabel,"TextField");

    local nameLabel1 = uiLayer:getWidgetByName("name_Label");
    m_nameLabel = tolua.cast(nameLabel1,"Label");

    local loginPanel = uiLayer:getWidgetByName("Panel_18");
    m_loginPanel = tolua.cast(loginPanel,"Layout");

    local enterPanel = uiLayer:getWidgetByName("Panel_19");
    m_enterPanel = tolua.cast(enterPanel,"Layout");

    local loginAllPanel = uiLayer:getWidgetByName("Panel_3");
    m_loginAllPanel = tolua.cast(loginAllPanel,"Layout");

    local searchPsd = uiLayer:getWidgetByName("zhaohuimima_btn");
    searchPsd = tolua.cast(searchPsd,"Button");
    searchPsd:addTouchEventListener(searchPsdEvent);

    local relateAccount = uiLayer:getWidgetByName("zhanghaobaohu_btn");
    relateAccount = tolua.cast(relateAccount,"Button");
 	relateAccount:addTouchEventListener(relateAccountEvent);

 	local selectServerBtn = uiLayer:getWidgetByName("fuwuqi_img");
 	m_selectServerBtn = tolua.cast(selectServerBtn,"Layout");
 	m_selectServerBtn:addTouchEventListener(selectServerEvent);

 	local serverNameLabel = uiLayer:getWidgetByName("fuwuqi_text");
    m_serverNameLabel = tolua.cast(serverNameLabel,"Label");
 	
 	local isNewServerLabel = uiLayer:getWidgetByName("fuwuqi_type_text");
    m_isNewServerLabel = tolua.cast(isNewServerLabel,"Label");

    local enterDirectlyBtn = uiLayer:getWidgetByName("Button_20");
 	m_enterDirectlyBtn = tolua.cast(enterDirectlyBtn,"Button");
 	m_enterDirectlyBtn:addTouchEventListener(enterDirectlyEvent);

    local enterQuicklyBtn = uiLayer:getWidgetByName("quickly_btn");
 	enterQuicklyBtn = tolua.cast(enterQuicklyBtn,"Button");
 	enterQuicklyBtn:addTouchEventListener(enterQuicklyEvent);

	if(getCurServerID() == nil)then--首次开启游戏 
		if(CCUserDefault:sharedUserDefault():getStringForKey("defaultid") ~= "")then
			setCurServerID(tonumber(CCUserDefault:sharedUserDefault():getStringForKey("defaultid")));
		else
			for i,v in pairs(LoginManager.getServerList())do
				if(v.fire == 1)then
					setCurServerID(tonumber(v.id));
				end
			end
		end
	end
	setServerName(LoginManager.getInfoByID(getCurServerID()));

 	if(CCUserDefault:sharedUserDefault():getStringForKey("defaultaccount") ~= ""
 		and CCUserDefault:sharedUserDefault():getStringForKey("defaultpwd") ~= "")then--本地已经有账号缓存信息
 		setDirectLoginUI();
 	else--没有默认账号
 		setLoginUI();
 	end
end

function open()
	-- body
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
	m_rootLayer = nil;
	m_loginPanel = nil;
	m_enterPanel = nil;
	m_nameLabel = nil;
end

function remove()
	initVariables();
end
