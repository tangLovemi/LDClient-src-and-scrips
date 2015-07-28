module("BiWuResult", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;

local function repeatBattle()
	UIManager.close("BiWuResult");
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleRepeat();
end


local function playVideo()--回放,本地回放
	UIManager.close("BiWuResult");
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleForRecord();
end

function create()
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "biwuResult_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_uiLayer = uiLayer;
    -- m_rootLayer:addChild(uiLayer);

	local closeButton = tolua.cast(m_uiLayer:getWidgetByName("guanbi_btn"),"Button");
	closeButton:addTouchEventListener(goToSurface);

	local button1 = tolua.cast(m_uiLayer:getWidgetByName("huifang_btn"),"Button");
	local button2 = tolua.cast(m_uiLayer:getWidgetByName("queding_btn"),"Button");
	button1:addTouchEventListener(playVideo);
	button2:addTouchEventListener(goToSurface);
	m_rootLayer:addChild(UIManager.bounceOut(m_uiLayer));
end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	if(m_schedulerDiamond ~= nil)then
		m_scheduler:unscheduleScriptEntry(m_schedulerDiamond);
	end
	if(m_schedulerScore ~= nil)then
		m_scheduler:unscheduleScriptEntry(m_schedulerScore);
	end
	m_diamond = 0;
	m_diamondIncrease = 0;
	m_diamondLabel = nil;
	m_diamondTicker = 0;
	m_scoreLabel = nil;
	m_scoreTicker = 0;
	m_scoreIncrease = 0;
	m_schedulerDiamond = nil;
	m_schedulerScore = nil;
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer, true);
	m_rootLayer = nil;
end

function remove()

end

function goToSurface()--根据类型转到相应界面 
	UIManager.close("BiWuResult");
	BattleScene.releaseBattleLayer();
	GameManager.enterMainCityOther(2);
	if(m_data[2] == BATTLE_SUBTYPE_JJC)then

	end
end
