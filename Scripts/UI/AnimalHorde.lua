module("AnimalHorde", package.seeall)

require "UI/CoolingTime"

local m_rootLayer = nil;

local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器

local m_scorePanel = nil;
local m_willOpen = true;
local m_scoreList = nil;
local m_countPerLabel = nil;
local m_loadingBar = nil;
local m_oddPer = nil;
local m_coolingTimeLabel = nil;
local m_coolingTime = nil;
local m_startBtn = nil;
local m_timeTile = nil;
local m_startTime = nil;
local m_endTime = nil;

OPENARER_POSITION_OPEN = ccp(0,50);
OPENARER_POSITION_CLOSE = ccp(-240,50);

COOLINGTIME  =  1 * 60 ;

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("AnimalHorde");
	end
end

local function startGameTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end

end

local function openScoreTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_willOpen == true then
			local moveTo = CCMoveTo:create(1,OPENARER_POSITION_OPEN);
			local easeExponentialOut = CCEaseExponentialOut:create(moveTo);
			m_scorePanel:runAction(easeExponentialOut);
			m_willOpen = false;
		else
			local moveTo = CCMoveTo:create(1,OPENARER_POSITION_CLOSE);
			local easeExponentialOut = CCEaseExponentialOut:create(moveTo);
			m_scorePanel:runAction(easeExponentialOut);
			m_willOpen = true;
		end
	end
end

local function setListItem(items)
	-- body
	for i=1,11 do
		local item = items[i];
		local str = item[1];
		local ranking = item[2];

		local layout = m_scoreList:getItem(i-1);
		local nameLabel =  tolua.cast(layout:getChildByName("name_label"),"Label");
		local rankingLabel = tolua.cast(layout:getChildByName("ranking_label"),"Label");
		nameLabel:setText(str);
		rankingLabel:setText(ranking);
	end
end

local function initList()
	-- body
	for i=1,11 do
		local scoreItem = tolua.cast(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "AH_scoreItemUI_1.json"),"Layout");
		m_scoreList:pushBackCustomItem(scoreItem);
	end
end

local function loadingBarChange(oddPer)
	-- body
	m_loadingBar:setPercent(oddPer);
	local str = oddPer .."%";
	m_countPerLabel:setText(str);
end

local function subCoolingTime(time)
	-- body
    local str = CoolingTime.timeChangeString(time);
    m_coolingTimeLabel:setText(str);
end 

local function updateLabelTime(dt)
	-- body
	m_oddPer = m_oddPer - 1;
	if m_oddPer <= 0 then
		m_oddPer = 0;
	end
	loadingBarChange(m_oddPer);

	m_startTime = m_startTime - 1;
	if m_startTime < 0 then
		m_endTime = m_endTime - 1;
		
		m_timeTile:setText("剩余时间:");
		m_startBtn:setTitleText("开始战斗");
		if m_endTime < 0 then
			m_endTime = 0; 
			m_startBtn:setTitleText("战斗结束");
			return;
		end
		m_coolingTime = m_endTime;
	else
		m_coolingTime = m_startTime;
	end
	subCoolingTime(m_coolingTime);


end

local function recieveDataFromSv(messageType,messageData)
	-- body
end

local function initVariables()
	-- body
	m_willOpen = true;
	m_oddPer   = nil;
	m_coolingTime = nil;
	m_startTime = nil;
	m_endTime = nil;
end

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "AnimalHordeUI_1.json");
	local uiLayer = TouchGroup:create();
	uiLayer:addWidget(uiLayout);
	m_rootLayer:addChild(uiLayer);
	-- m_rootLayer:retain();

	local exitBtn = uiLayer:getWidgetByName("exit_btn");
	exitBtn:addTouchEventListener(exitTouchEvent);

	local startGameBtn = tolua.cast(uiLayer:getWidgetByName("start_btn"),"Button");
	startGameBtn:addTouchEventListener(startGameTouchEvent);
	m_startBtn = startGameBtn;

	local openScoreBtn = uiLayer:getWidgetByName("openScore_btn");
	openScoreBtn:addTouchEventListener(openScoreTouchEvent);

	local scorePanel = uiLayer:getWidgetByName("score_panel");
	m_scorePanel = scorePanel;

	local scoreList = tolua.cast(uiLayer:getWidgetByName("score_listView"),"ListView");
	m_scoreList = scoreList;

	local countPerLabel = tolua.cast(uiLayer:getWidgetByName("countPer_label"),"Label");
	m_countPerLabel = countPerLabel;

	local loadingBar = tolua.cast(uiLayer:getWidgetByName("count_loadingBar"),"LoadingBar");
	m_loadingBar = loadingBar;

	local coolingTimeLabel = tolua.cast(uiLayer:getWidgetByName("time_label"),"Label");
	m_coolingTimeLabel = coolingTimeLabel;

	local timeTitle = tolua.cast(uiLayer:getWidgetByName("time_title"),"Label");
	m_timeTile = timeTitle;

	initList();
end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	m_startBtn:setTitleText("战斗未开始");
	m_timeTile:setText("开始倒计时:");

	m_oddPer = 100;
	m_coolingTime = COOLINGTIME;
	m_startTime = 1* 60;
	m_endTime = COOLINGTIME;

	local scoreItems = {};
	for i=1,11 do
		local scoreItem = {};
		local str = i .. ".caoXiaoBin";
		local ranking = 923;
		scoreItem[1] = str;
		scoreItem[2] = ranking;
		table.insert(scoreItems,scoreItem);
	end
	setListItem(scoreItems);

	m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, 1, false);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	scheduler:unscheduleScriptEntry(m_schedulerEntry);
	initVariables();

end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	m_scorePanel = nil;
	m_scoreList = nil;
	m_countPerLabel = nil;
	m_loadingBar = nil;
	m_coolingTimeLabel = nil;
	m_startBtn = nil;
	m_timeTile = nil;
end