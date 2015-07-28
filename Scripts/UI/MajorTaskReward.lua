
module("MajorTaskReward", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_taskName= nil
local m_expLable = nil
local m_moneyLabel = nil
local m_submittBtn = nil
local m_cancelBtn = nil
local m_npcId = nil


local function initRewardInfo(messageData)
	--待初始化
	m_npcId = 100000
	m_taskName:setText("m_taskName")
	m_expLable:setText("rewardExp")
	m_moneyLabel:setText("rewardMoney")
	m_amountLabel:setText("25")

end
local function onRecieveSubmit(messageType,messageData)
	if(messageData["bScucess"]==1) then
		UIManager.close("MajorTaskReward")
		print("submit this task ok")
	end
end
local function doSubmit(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then		
		NetMessageManager.sendMessage(NETWORK_MESSAGE_RECEIVE_MAJORTASKSTATUS_CHANGE, {m_npcId});	
	end
end
local function doCancel(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("MajorTaskReward")
		UIManager.open("AlertView",{"messenge"})
	end
end
function create()
	m_rootLayer = CCLayer:create();
	-- m_rootLayer:retain()  
	local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "missionokui_1.json");
    m_UILayout = TouchGroup:create();
    m_UILayout:addWidget(UISource);
    m_rootLayer:addChild(m_UILayout);
    local panel = tolua.cast(m_UILayout:getWidgetByName("Panel_1"), "Layout")
    -- panel:addTouchEventListener(touchEvent);
    m_taskName = tolua.cast(m_UILayout:getWidgetByName("name_label"), "Label");
    m_expLable = tolua.cast(m_UILayout:getWidgetByName("exp_label"), "Label");
    m_moneyLabel = tolua.cast(m_UILayout:getWidgetByName("money_label"), "Label");
    m_amountLabel = tolua.cast(m_UILayout:getWidgetByName("shu_label"), "Label");
    m_submittBtn = tolua.cast(m_UILayout:getWidgetByName("ok_btn"), "Button");
    m_submittBtn:addTouchEventListener(doSubmit)
    m_cancelBtn = tolua.cast(m_UILayout:getWidgetByName("no_btn"), "Button");
    m_cancelBtn:addTouchEventListener(doCancel)
end

function open(messageData)
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer)
	if(messageData~=nil) then
		initRewardInfo()
	end
	initRewardInfo()

end
function close()
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end

function remove()
	m_rootLayer:removeAllChildrenWithCleanup(true);	
	m_rootLayer:release();
	m_rootLayer= nil
end
