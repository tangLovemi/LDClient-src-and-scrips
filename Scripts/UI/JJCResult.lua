module("JJCResult", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local ID_MONEY = 1001;
local ID_EXP = 1002;
local m_data = nil;
local m_diamond = 0;
local m_score = 0;
local TIME_MONEY = 60;
local m_diamondLabel = nil;
local m_scoreLabel = nil;
local m_diamondTicker = 0;
local m_scoreTicker = 0;
local m_diamondIncrease = 0;
local m_scoreIncrease = 0;
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerDiamond = nil;
local m_schedulerScore= nil;
local m_starTable = nil;
local function repeatBattle()
	close();
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleRepeat();
end


local function playVideo()--回放,本地回放
	close();
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleForRecord();
end

local function beginReward(text,node)

end

local function init()

end

function updateScore(dt)
	if(m_scoreTicker == TIME_MONEY)then
		m_scheduler:unscheduleScriptEntry(m_schedulerScore);
		m_scoreLabel:setStringValue(tostring(m_score));
		return;
	end
	m_scoreLabel:setStringValue(tostring(m_scoreIncrease*m_scoreTicker));
	m_scoreTicker = m_scoreTicker + 1;
end
function updateDiamond(dt)
	if(m_diamondTicker == TIME_MONEY)then
		m_scheduler:unscheduleScriptEntry(m_schedulerDiamond);
		m_diamondLabel:setStringValue(tostring(m_diamond));
		return;
	end
	m_diamondLabel:setStringValue(tostring(m_diamondIncrease*m_diamondTicker));
	m_diamondTicker = m_diamondTicker + 1;
end

function create()
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "jjcResult_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_uiLayer = uiLayer;
    -- m_rootLayer:addChild(uiLayer);

    m_data = BattleManager.getBattleData();
	local rewardItem = BattleManager.getPrizeItem();
	local rewardCommon = BattleManager.getPrizeCommon();
	-- local reward  = {{id=1,count=1000},{id=2,count=1000},{id=3,count=1000}};
	local winner = BattleManager.getWinner();
	local closeButton = tolua.cast(m_uiLayer:getWidgetByName("guanbi_btn"),"Button");
	closeButton:addTouchEventListener(goToSurface);

	local button1 = tolua.cast(m_uiLayer:getWidgetByName("huifang_btn"),"Button");
	local button2 = tolua.cast(m_uiLayer:getWidgetByName("queding_btn"),"Button");
	button1:addTouchEventListener(playVideo);
	button2:addTouchEventListener(goToSurface);

	m_diamondLabel = tolua.cast(m_uiLayer:getWidgetByName("zuanshi__labelNum"),"LabelAtlas");
	m_scoreLabel = tolua.cast(m_uiLayer:getWidgetByName("jifen__labelNum"),"LabelAtlas");

	m_diamond = rewardCommon.token;
	m_score = rewardCommon.score;
	m_diamondIncrease = math.ceil(rewardCommon.token/TIME_MONEY);
	m_scoreIncrease = math.ceil(rewardCommon.score/TIME_MONEY);
	if(m_diamond < 60)then
		m_diamondIncrease = 1;
	end
	if(m_score < 60)then
		m_scoreIncrease = 1;
	end
	m_schedulerDiamond = m_scheduler:scheduleScriptFunc(updateDiamond, 0, false);
	m_schedulerScore = m_scheduler:scheduleScriptFunc(updateScore, 0, false);
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
	UIManager.close("JJCResult");
	BattleScene.releaseBattleLayer();
	GameManager.enterMainCityOther(2);
	UIManager.open("JJCUI");
end
