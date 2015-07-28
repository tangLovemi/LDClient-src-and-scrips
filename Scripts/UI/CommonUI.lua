
module("CommonUI", package.seeall)--公用返回购买金币ui


local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerMessage = nil;
local function purchaseEnergy(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_energyImage:setScale(1);
		--打开购买体力或者使用体力丹

	elseif(eventType == TOUCH_EVENT_TYPE_BEGIN)then
		m_energyImage:setScale(1.2);
	end
end

local function purchaseMoney(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_moneyImage:setScale(1);
		--打开购买金币界面

	elseif(eventType == TOUCH_EVENT_TYPE_BEGIN)then
		m_moneyImage:setScale(1.2);
	end
end

local function purchaseDiamond(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_diamondImage:setScale(1);
		--进入购买钻石界面 

	elseif(eventType == TOUCH_EVENT_TYPE_BEGIN)then
		m_diamondImage:setScale(1.2);
	end
end

local function back(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- close();--跳转到世界地图界面 
		MessageManager.addMessage({GLOBAL_MESSAGE_BACK});
	end
end
function create()
	m_rootLayer = CCLayer:create();
	m_schedulerMessage = m_scheduler:scheduleScriptFunc(updateMessage, 0, false);
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "quyuui_tou.json");
	uiLayout:setPositionY(SCREEN_HEIGHT - uiLayout:getSize().height);
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    --m_rootLayer:retain();

    local energyBtn = uiLayer:getWidgetByName("tili_panel");
    energyBtn:addTouchEventListener(purchaseEnergy);

    local moneyBtn = uiLayer:getWidgetByName("Panel_34");
    moneyBtn:addTouchEventListener(purchaseMoney);

    local diamondBtn = uiLayer:getWidgetByName("Panel_33");
    diamondBtn:addTouchEventListener(purchaseDiamond);

    local backBtn = uiLayer:getWidgetByName("back_button");
    backBtn = tolua.cast(backBtn,"Button");
    backBtn:addTouchEventListener(back);
        m_moneyLabel = uiLayer:getWidgetByName("qian_label");
    m_moneyLabel = tolua.cast(m_moneyLabel,"Label");


    m_energyLabel = uiLayer:getWidgetByName("shuzi1_label");
    m_energyLabel = tolua.cast(m_energyLabel,"Label");

    m_diamondLabel = uiLayer:getWidgetByName("Label_37");
    m_diamondLabel = tolua.cast(m_diamondLabel,"Label");

    m_moneyImage = uiLayer:getWidgetByName("qian_di_img");
    m_moneyImage = tolua.cast(m_moneyImage,"ImageView");

    m_energyImage = uiLayer:getWidgetByName("tili_di_img");
    m_energyImage = tolua.cast(m_energyImage,"ImageView");

    m_diamondImage = uiLayer:getWidgetByName("yb_di_img");
    m_diamondImage = tolua.cast(m_diamondImage,"ImageView");

    local uplimit = uiLayer:getWidgetByName("box2shu3_label");
    uplimit = tolua.cast(m_diamondLabel,"Label");
    m_energyUpLimit = tonumber(uplimit:getStringValue());

    m_progressBar = uiLayer:getWidgetByName("ProgressBar_27");
    m_progressBar = tolua.cast(m_progressBar,"LoadingBar");
    local energy = UserInfoManager.getRoleInfo("physic");
    local rate = energy/m_energyUpLimit;
    m_progressBar:setPercent(rate);

    MessageManager.addMessage({GLOBAL_MESSAGE_MONEY});
    MessageManager.addMessage({GLOBAL_MESSAGE_ENERGY});
    MessageManager.addMessage({GLOBAL_MESSAGE_DIAMOND});
end

function open()
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end


function updateMessage(dt)
	local obj = MessageManager.front();
	if(obj)then
		local data = obj[1];
		if(data == GLOBAL_MESSAGE_MONEY)then
			m_moneyLabel:setText(tostring(UserInfoManager.getRoleInfo("gold")));
			MessageManager.pop();
		elseif(data == GLOBAL_MESSAGE_ENERGY)then
			m_energyLabel:setText(tostring(UserInfoManager.getRoleInfo("physic")));
			local energy =  UserInfoManager.getRoleInfo("physic");
			local rate = energy/m_energyUpLimit;
			m_progressBar:setPercent(50);
			MessageManager.pop();
		elseif(data == GLOBAL_MESSAGE_DIAMOND)then
			m_diamondLabel:setText(tostring(UserInfoManager.getRoleInfo("diamond")));
			MessageManager.pop();
		end
		
	end
end

function remove()
	m_scheduler:unscheduleScriptEntry(m_schedulerMessage);
	-- local uiLayer = getGameLayer(SCENE_UI_LAYER);
	-- uiLayer:removeChild(m_rootLayer,false);
	MessageManager.addMessage({GLOBAL_MESSAGE_BACK});
end