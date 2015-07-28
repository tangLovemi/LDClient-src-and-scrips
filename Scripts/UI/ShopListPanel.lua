module("ShopListPanel", package.seeall)
local m_rootLayer = nil;
local m_uiLayer = nil;


local function PurchaseMoneyEvent(obj,event)
    if event == TOUCH_EVENT_TYPE_END then

    end
end

local function PurchaseEnergyEvent(obj,event)
    if event == TOUCH_EVENT_TYPE_END then

    end
end

local function PurchaseDiamondEvent(obj,event)
    if event == TOUCH_EVENT_TYPE_END then

    end
end

function create()
	m_rootLayer = CCLayer:create();
    m_uiLayer = TouchGroup:create();
    m_uiLayer:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ShopListPanel_1.json"));
    m_rootLayer:addChild(m_uiLayer);

    local moneyBtn = tolua.cast(m_uiLayer:getWidgetByName("jb_bin"), "Button");
    local energyBtn = tolua.cast(m_uiLayer:getWidgetByName("tili_btn"), "Button");
    local diamondBtn = tolua.cast(m_uiLayer:getWidgetByName("zs_btn"), "Button");

    moneyBtn:addTouchEventListener(PurchaseMoneyEvent);
    energyBtn:addTouchEventListener(PurchaseEnergyEvent);
    diamondBtn:addTouchEventListener(PurchaseDiamondEvent);
    refreshDisplay();
end

function displayUpgrade(text, effNode)
    m_layout:setVisible(true);
    m_armature:unregisterAnimEvent(1);
end


function refreshDisplay()
	if(m_rootLayer~= nil) then
		--体力
		tolua.cast(m_uiLayer:getWidgetByName("tili_label"), "Label"):setText(UserInfoManager.getRoleInfo("physic").."/120");
		--金币
		tolua.cast(m_uiLayer:getWidgetByName("jb_label"), "Label"):setText(UserInfoManager.getRoleInfo("gold"));
		--钻石
		tolua.cast(m_uiLayer:getWidgetByName("zs_label"), "Label"):setText(UserInfoManager.getRoleInfo("diamond"));
	end
end

function open()
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(m_rootLayer);
end


function close()
    	local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, true);
    	m_rootLayer = nil;

end

function remove()

end