module("Register", package.seeall)


UUID                  = 313;  --设备ID

local m_rootLayer     = nil;
local m_nameTextField = nil;
local m_psdTextField  = nil;
local m_sureTextField = nil;
local m_checkBox 	  = nil;
local m_selectTag     = nil;

REGISTER_SUCCESS  = 1;

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("Register");
	end
end 

local function getRegisterBeSuccessfull()
	-- body
	if m_nameTextField:getStringValue() == "" or  
	   m_psdTextField:getStringValue()  == "" or 
	   m_sureTextField:getStringValue() == "" then

	   return false;
	end

	if m_psdTextField:getStringValue() ~= m_sureTextField:getStringValue() then
		return false;
	end

	if not m_checkBox:getSelectedState() then
		return false;
	end

	return true;
end 

local function sendMessageToServer()
	-- body
	local name = m_nameTextField:getStringValue();
	local password = m_psdTextField:getStringValue();
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_REGISTER, {name,password});
	CCLuaLog("发送成功！")

end

local function receiveDataFromServer(messageType, messageData)
	-- body
	CCLuaLog("接受成功!");
	print("messageType: " .. messageType);
    if messageData.sure == REGISTER_SUCCESS then
    	CCLuaLog("注册成功！");
    	close();

    	local name = m_nameTextField:getStringValue();
		local password = m_psdTextField:getStringValue();
		Login.open();
		Login.setUserNameAndPassWord(name,password);
		remove();
    else 
    	CCLuaLog("注册失败");
    end

end 

local function registerSuccess()
	-- body
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REGISTER, receiveDataFromServer);
	sendMessageToServer();
end 

local function registTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then 

		local isRegister = getRegisterBeSuccessfull();

		if isRegister then
			registerSuccess();
		else 
			CCLuaLog("注册内容有问题！");
		end

	end
end 

local function cancleTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		-- close();
		-- remove();
		-- Login.open();

		UIManager.backLastLayer();
	end
end 

local function initVariables()
	-- body
	m_rootLayer     = nil;
    m_nameTextField = nil;
    m_psdTextField  = nil;
    m_sureTextField = nil;
    m_checkBox 	    = nil;
end

function create()
	-- body

	m_rootLayer = CCLayer:create();

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "RegisterUI_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    -- m_rootLayer:retain();

    local nameLabel = tolua.cast(uiLayer:getWidgetByName("userName_editBox"),"TextField");
    local psdLabel  = tolua.cast(uiLayer:getWidgetByName("password_editBox"),"TextField");
    local sureLabel = tolua.cast(uiLayer:getWidgetByName("sure_editBox"),"TextField");
    local registerBtn  = uiLayer:getWidgetByName("register_btn");
    local cancleBtn    = uiLayer:getWidgetByName("cancle_btn"); 
    local exitBtn = uiLayer:getWidgetByName("exit_btn");

    m_nameTextField = nameLabel;
	m_psdTextField  = psdLabel;
	m_sureTextField = sureLabel;

	local checkBox = tolua.cast(uiLayer:getWidgetByName("checkBox"),"CheckBox");
	checkBox:setSelectedState(true);

	m_checkBox = checkBox;

	registerBtn:addTouchEventListener(registTouchEvent);
	cancleBtn:addTouchEventListener(cancleTouchEvent);
	exitBtn:addTouchEventListener(exitTouchEvent);

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

function remove()
	-- body
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_REGISTER, receiveDataFromServer);
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	initVariables();
end
