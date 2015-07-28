module("FailResult", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_data = nil;
local m_weaponBtn = nil;
local m_coatBtn = nil;
local m_equipBtn = nil;
local m_skillBtn = nil;

local function repeatBattle()
	UIManager.close("FailResult");
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleRepeat();
end

local function playVideo()--回放,本地回放
	UIManager.close("FailResult");
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleForRecord();
end

function create()
	m_data = BattleManager.getBattleData();
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "failResult_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_uiLayer = uiLayer;
    -- m_rootLayer:addChild(uiLayer);
    local closeButton = tolua.cast(m_uiLayer:getWidgetByName("Button_5"),"Button");
	closeButton:addTouchEventListener(goToSurface);
    local button1 = tolua.cast(m_uiLayer:getWidgetByName("queding_btn"),"Button");
	local button2 = tolua.cast(m_uiLayer:getWidgetByName("huifang_btn"),"Button");
	button1:addTouchEventListener(goToSurface);
	button2:addTouchEventListener(playVideo);
	m_weaponBtn = tolua.cast(m_uiLayer:getWidgetByName("wuqi_img"),"ImageView");
	m_weaponBtn:addTouchEventListener(revertEvent);
	m_coatBtn = tolua.cast(m_uiLayer:getWidgetByName("wuqi_img"),"ImageView");
	m_coatBtn:addTouchEventListener(revertEvent);
	m_equipBtn = tolua.cast(m_uiLayer:getWidgetByName("wuqi_img"),"ImageView");
	m_equipBtn:addTouchEventListener(revertEvent);
	m_skillBtn = tolua.cast(m_uiLayer:getWidgetByName("wuqi_img"),"ImageView");
	m_skillBtn:addTouchEventListener(revertEvent);
	m_rootLayer:addChild(UIManager.bounceOut(m_uiLayer));
end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer, true);
	m_rootLayer = nil;
end

function revertEvent(object,event)
	UIManager.close("FailResult");
	BattleScene.releaseBattleLayer();
	GameManager.enterMainCity();
	if(object == m_weaponBtn)then

	elseif(object == m_coatBtn)then
		
	elseif(object == m_equipBtn)then
	
	elseif(object == m_skillBtn)then
	
	end
end



function goToSurface()--根据类型转到相应界面 
	UIManager.close("FailResult");
	BattleScene.releaseBattleLayer();
	GameManager.enterMainCityOther(2);
	if(m_data[2] == BATTLE_SUBTYPE_JJC)then
		UIManager.open("JJCUI");
	elseif(m_data[2] == BATTLE_SUBTYPE_TRAIN)then
		UIManager.open("TrainUI");
	end
end

function remove()

end
