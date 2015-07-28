module("newLoginUI", package.seeall)

require "StartGameUI"

local m_rootLayer  = nil;
local m_uiLayer    = nil;
local m_ipTextField = nil;
local m_accountTextField = nil;
local m_psdTextField 	 = nil;
local m_accountId  = nil;
local m_touristId  = nil;

local m_isCreate = false;
local m_isOpen = false;

WINSIZE = CCDirector:sharedDirector():getWinSize();
LAYERPOSITION = ccp( WINSIZE.width/2 - 200 , WINSIZE.height/2 - 150);

LOGIN_SUCCESS           = 1;
LOGIN_ACCOUNT_NULL      = 2;
LOGIN_ACCOUNT_PSW_ERROR = 3;

--返回上一菜单
local function backToEnterLayer()
	-- body
	-- UIManager.close("newLoginUI");
	newLoginUI.close();
    StartGameUI.openTheEnterLayer();
end

--进入游戏
local function enterTheGame()
	StartGameUI.setAccountId(m_accountId);
	StartGameUI.openTheEnterLayer();
	-- UIManager.close("newLoginUI");
	newLoginUI.close();
end

--收到数据，进入登陆界面
local function receiveDataForTouristLogin(messageType,messageData)
	-- body
	local accountId = messageData.accountId;
	m_accountId = accountId;
	enterTheGame();
end

--登入数据，判断是否登陆成功
local function receiveDataForLogin(messageType, messageData)
	-- body
	CCLuaLog("接受成功!");
	print("messageType: " .. messageType);
	CCLuaLog(messageData.sure);
    if messageData.sure == LOGIN_SUCCESS then
    	CCLuaLog("登录成功！");
    	enterTheGame();
    	-- BattleManager.enterBattle(1, 1);
    else
    	CCLuaLog("登录失败，输入的用户名或者密码有误！");
    end

end

local function recordAccountMessage()
	-- body

end

--清空textField
local function setTextFieldNull()
	-- body
	local ip = NetWorkConnect.getConnectIP();
	m_ipTextField:setText(ip);
	m_psdTextField:setText("");
	m_accountTextField:setText("");
end

--发送消息到服务器中
local function sendMsgToSv()
	-- body
	local ip = NetWorkConnect.getConnectIP();
	local gameScene = GameManager.getGameScene();
	NetWorkConnect.create(gameScene, ip);

	local name = m_accountTextField:getStringValue();
	local psd  = m_psdTextField:getStringValue();
	m_accountId = name;

	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_LOGIN, {name,psd});
end


local function getEnableLogin()
	-- body
	if m_accountTextField:getStringValue() == ""
	or m_psdTextField:getStringValue()     == "" then

		return false;

	end

	return true;
end 

local function changeIp()
	local ip = m_ipTextField:getStringValue();
	if(ip ~= nil and ip ~= "") then
		NetWorkConnect.setConnectIP(ip);
	end
end

--登陆
local function loginTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		local enableLogin = getEnableLogin();

		changeIp();
		

		if enableLogin == true then
			sendMsgToSv();
		else
			CCLuaLog("输入不能为空!");
		end
	end
end

local function registerTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		changeIp();

		-- UIManager.close("newLoginUI");
		-- UIManager.open("newRegisterUI");
		newLoginUI.close();
		newRegisterUI.open();
	end
end


local function touristTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURISTLOGIN, {1});
	end
end 

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		backToEnterLayer();
	end
end

local function initVariables()
	-- body
	m_uiLayer = nil;
	m_accountTextField = nil;
	m_psdTextField 	   = nil;
end


--设置账号和密码
function setAccountAndPsd(account,psd)
	-- body
	m_accountTextField:setText(account);
	m_psdTextField:setText(psd);
end

function create()
	if(m_isCreate == false) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "newLoginUI_1.json");
		uiLayer = TouchGroup:create();
		uiLayer:addWidget(hotelLayer);
		m_rootLayer:addChild(uiLayer);
	 
		hotelLayer:setPosition(LAYERPOSITION);
		m_rootLayer:retain();

		local loginBtn    = uiLayer:getWidgetByName("login_btn");
		local registerBtn = uiLayer:getWidgetByName("register_btn");
		local exitBtn     = uiLayer:getWidgetByName("exit_btn");
		loginBtn:addTouchEventListener(loginTouchEvent);
		registerBtn:addTouchEventListener(registerTouchEvent);
		exitBtn:addTouchEventListener(exitTouchEvent);

	--	local touristBtn = uiLayer:getWidgetByName("tourist_btn");
	--	touristBtn:addTouchEventListener(touristTouchEvent)

		local ipTextField = tolua.cast(uiLayer:getWidgetByName("ip_textfield"),"TextField");
		m_ipTextField = ipTextField;

		local accountTextField = tolua.cast(uiLayer:getWidgetByName("account_textfield"),"TextField");
		m_accountTextField = accountTextField;

		local psdTextField = tolua.cast(uiLayer:getWidgetByName("password_textfield"),"TextField");
		m_psdTextField = psdTextField;

		local checkBox = tolua.cast(uiLayer:getWidgetByName("record_checkBox"),"CheckBox");
		checkBox:setSelectedState(true);

		m_uiLayer = uiLayer;
		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_LOGIN, receiveDataForLogin);
	end
end

function open()
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
		setTextFieldNull();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,true);
		setTextFieldNull();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_LOGIN, receiveDataForLogin);
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		initVariables();
		m_isCreate = false;
	end
end