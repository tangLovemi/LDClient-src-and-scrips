module("newRegisterUI", package.seeall)

require "newLoginUI"

local m_rootLayer  = nil;

local m_psdTextField = nil;
local m_accountTextField = nil;
local m_confirmTextField = nil;

WINSIZE = CCDirector:sharedDirector():getWinSize();
LAYERPOSITION = ccp( WINSIZE.width/2 - 300 , WINSIZE.height/2 - 175);

REGISTER_SUCCESS  = 1;

local m_isCreate = false;
local m_isOpen = false;
-- local 
--判断注册是否为空
local function getRegisterBeSuccessfull()
	-- body
	if m_accountTextField:getStringValue() == "" or  
	   m_psdTextField:getStringValue()  == "" or 
	   m_confirmTextField:getStringValue() == "" then

	   return false;
	end

	if m_psdTextField:getStringValue() ~= m_confirmTextField:getStringValue() then
		return false;
	end

	return true;
end 


--清空textfield内容
local function setTextFieldNull()
	-- body
	m_psdTextField:setText("");
	m_accountTextField:setText("");
	m_confirmTextField:setText("");
end

--返回登陆界面
local function backLoginLayer()
	-- body
	UIManager.close("newRegisterUI");
	UIManager.open("Login");
	-- if m_accountTextField:getStringValue() ~= "" and m_psdTextField:getStringValue() ~= "" then
	-- 	local account = m_accountTextField:getStringValue();
	-- 	local password = m_psdTextField:getStringValue();
	-- 	newLoginUI.setAccountAndPsd(account,password);
	-- end

	-- setTextFieldNull();
end

local function isContainChinese(str)
	local len = #str;
	for i=1,len do
		local data = string.byte(str,i);
		if(data > 127)then
			return true;
		end
	end
	return false;
end

local function registerTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- backLoginLayer();
		if(m_confirmTextField:getStringValue() == "" or m_psdTextField:getStringValue() == "" or m_accountTextField:getStringValue() == "")then
			Util.showOperateResultPrompt("用户名或密码不能为空");
			return;
		end
		if(m_psdTextField:getStringValue() ~= m_confirmTextField:getStringValue())then
			Util.showOperateResultPrompt("两次输入密码不一致");
			return;
		end
		if(isContainChinese(m_psdTextField:getStringValue()) or isContainChinese(m_accountTextField:getStringValue()))then
			Util.showOperateResultPrompt("用户名或密码不能包含中文");
			return;
		end

		ClientConnect:shareInstance():RegisterRequest(m_accountTextField:getStringValue(),m_psdTextField:getStringValue());
	end
end

local function backTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		backLoginLayer();
	end
end

local function initVariables()
	-- body
	m_psdTextField = nil;
	m_accountTextField = nil;
	m_confirmTextField = nil;
end

function RegisterCallBack(message)
	if(message.isOk == 1)then
		CCUserDefault:sharedUserDefault():setStringForKey("defaultaccount",m_accountTextField:getStringValue());
		CCUserDefault:sharedUserDefault():setStringForKey("defaultpwd",m_psdTextField:getStringValue());
		UIManager.close("newRegisterUI");
		UIManager.open("Login");
	else
		NetMessageResultManager.displayMessage({id=message.isOk});
		setTextFieldNull();
	end
end

function create()
	if(m_isCreate == false) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		local bg = ImageView:create();
		bg:setAnchorPoint(CCPoint(0,0));
    	bg:loadTexture(PATH_CCS_RES .. "denglu_bg_1.png");
    	m_rootLayer:addChild(bg);
		local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "newRegisterUI_1.json");
		uiLayer = TouchGroup:create();
		uiLayer:addWidget(hotelLayer);
		m_rootLayer:addChild(uiLayer);

		hotelLayer:setPosition(LAYERPOSITION);

		local registerBtn = uiLayer:getWidgetByName("register_btn");
		local backBtn = uiLayer:getWidgetByName("back_btn");
		registerBtn:addTouchEventListener(registerTouchEvent);
		backBtn:addTouchEventListener(backTouchEvent);

		local accountTextField = tolua.cast(uiLayer:getWidgetByName("name_textfield"),"TextField");
		local psdTextField = tolua.cast(uiLayer:getWidgetByName("password_textfield"),"TextField");
		local confirmTextField = tolua.cast(uiLayer:getWidgetByName("confirm_textfield"),"TextField");

		m_accountTextField = accountTextField;
		m_psdTextField = psdTextField;
		m_confirmTextField = confirmTextField;
	end
end	

function open()
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,true);
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		m_rootLayer = nil;
		initVariables();
	end
end