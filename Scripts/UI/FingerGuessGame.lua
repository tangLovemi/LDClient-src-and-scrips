module("FingerGuessGame", package.seeall)

require "NetWork/NetMessageManager"

---------------------------------------------------------
--                    猜拳小游戏界面
---------------------------------------------------------
local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isOpen = false;
local m_isCreate = false;

--每日12：00开启
--每天猜拳活动将有15局游戏。15局结束后，活动结束。
--每局游戏为1分钟，每局游戏之间间隔10秒钟。

--客户端发送：
--1、猜拳请求
--2、所选猜拳

--服务器发送：
--1、游戏状态，时间，局数
--2、公告内容
--3、排名榜列表/输赢结果

local SCISSOR_ID 	= 1; --剪刀
local STONE_ID 		= 2; --石头
local PAPER_ID 		= 3; --布
local m_choiceName = {"剪刀", "石头", "布"};
--游戏状态
local STATUS_WAIT  = 1; --等待开始
local STATUS_READY = 2; --准备开始
local STATUS_ON    = 3; --进行中
local STATUS_GAME_OVER = 4; --游戏结束

local TIME_READY = 5; --准备时长
local TIME_ON = 10;   --进行时长
local GAME_MAX_COUNT = 5; --一天游戏进行局数
local MAX_CONTACT_COUNT = 20; --左边对话列表最多显示的项数

local m_resultText = {"本局你赢了", "本局你输了", "本局你战平了"};
local RESULT_WIN = 1;
local RESULT_LOSE = 2;
local RESULT_DRAW = 3;

local m_gameCount = -1; -- 标志系统已经进行几局
local m_sec = 0;
local m_status = -1; --游戏状态

local m_time = nil; --显示时间
local m_scheduler = nil;
local m_time_schedule = nil;

local m_contactDesc = {"更换成", "选择了"};

local m_contactLv = nil;
local m_rankingLv = nil;

local m_testName = "Nancy";

local  m_promptText = {
	"难得你们竟然这么齐心，不过蝼蚁始终是蝼蚁，这一轮本尊将带走所有人的胜利！",
	"选择最多的那个手势，这一轮必输！",
	"本轮游戏,，选择最多的手势，将胜利。",
	"本轮游戏,，选择最少的手势，将胜利。",
	"本轮游戏,，选择不是最多也不是最少的手势，将胜利。",
	"本轮游戏,，选择最多的手势，将失败。",
	"本轮游戏,，选择最少的手势，将失败。",
	"本轮游戏,，选择不是最多也不是最少的手势，将失败。",
};

local TEXT_WAIT = "游戏还未开始，每天12点开始游戏！！";
local TEXT_READY = "新一轮游戏即将开始，继续努力！";
local TEXT_ON = "猜猜看，我要出什么呢??";
local TEXT_GAME_OVER = "游戏结束，咱们下次在玩吧，哈哈";

--改变按钮状态
local function setFingerGuessBtnEnabled( enable )
	local btn1 = tolua.cast(m_rootLayout:getWidgetByName("scissor_btn"), "Button");
	local btn2 = tolua.cast(m_rootLayout:getWidgetByName("stone_btn"), "Button");
	local btn3 = tolua.cast(m_rootLayout:getWidgetByName("paper_btn"), "Button");
	btn1:setTouchEnabled(enable);
	btn2:setTouchEnabled(enable);
	btn3:setTouchEnabled(enable);
end
--刷新倒计时时间
local function refreshTime()
	tolua.cast(m_rootLayout:getWidgetByName("time_label"), "Label"):setText(m_sec .. "秒");
end
local function setNpcSay( text )
	local sayLabel = tolua.cast(m_rootLayout:getWidgetByName("say_label"), "Label");
	sayLabel:setText(text);
end
--刷新npc对话
local function refreshNpcSay()
	
	if(m_status == STATUS_READY) then
		setNpcSay( TEXT_READY );
	elseif(m_status == STATUS_ON) then
		setNpcSay( TEXT_ON );
	elseif(m_status ==  STATUS_GAME_OVER) then
		setNpcSay( TEXT_GAME_OVER );
	end
end
--刷新按钮状态
local function refreshGuessBtns()
	if(m_status == STATUS_READY or m_status == STATUS_GAME_OVER) then
		setFingerGuessBtnEnabled(false);
	else
		setFingerGuessBtnEnabled(true);
	end
end
--刷新已经进行的局数
local function refreshGameCount()
	local goodsCountLabel = tolua.cast(m_rootLayout:getWidgetByName("gameCount_label"), "Label");
	goodsCountLabel:setText(m_gameCount);
end

--刷新显示
local function refreshDisplay()
	refreshTime();
	refreshGuessBtns();
	refreshNpcSay();
	refreshGameCount();
end

local function gameOver()
	print("******************** 游戏结束");
	m_status = STATUS_GAME_OVER;
end

--倒计时结束
local function timeEnd()
 --判断当前状态-->ready: 时间重置为60s；状态改为on；局数+1
			   -->on: 发送本轮游戏结束消息；判断局数是否到达15局-->是：游戏结束
			  												   -->否：时间重置为10s; 状态改为ready
	if(m_status == STATUS_READY) then
		print("************************ 进入新一轮游戏");
		m_sec = TIME_ON;
		m_status = STATUS_ON;
		m_gameCount = m_gameCount + 1;
		refreshDisplay();
		startUpdate();
	elseif(m_status == STATUS_ON) then
		if(m_gameCount >= GAME_MAX_COUNT) then
			gameOver();
		else
			print("******************** 进入游戏等待");
			m_sec = TIME_READY;
			m_status = STATUS_READY;
			startUpdate();
		end
		sendRequest();--请求服务器发送输赢信息
		refreshDisplay();

		--测试排行榜
		test_ranking();
		test_result();
	end
end

--倒计时更新时间
local function timeUpdate()
    m_sec = m_sec - 1;
    if (m_sec == 0) then 
    	--时间到，请求服务器
        stopUpdate();
        timeEnd();
    end
    refreshTime();
    if(m_status == STATUS_ON and m_sec == 5) then
    	test_npcPrompt();
    end
end

local function haveSelfInRanking(messageData)
	for i = 1,#messageData - 1 do
		if(messageData[#messageData].name == messageData[i].name) then
			return i;
		end
	end
	return -1;
end

-----------------------处理服务器返回消息--------------------------

local function onReceiveMonsterPrompt( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_FINGERGUESSMOSTERPROMPT) then
		setNpcSay(m_promptText[messageData.promptId]);
	end
end

--排名榜
local function onReceiveGuessRanking( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_FINGERGUESSRANK) then
		if(m_rankingLv:getChildrenCount() > 0) then
			m_rankingLv:removeAllItems();
		end
		local index = haveSelfInRanking(messageData);

		for i = 1,#messageData do
			--如果玩家自己在排行中，则略过最后一个
			if(index ~= -1 and i == #messageData) then
				break;
			end
			local per = messageData[i];
			local name = per.name;
			local ranking = per.ranking;
			local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "FingerGuessRankingItem.json");
			local nameLabel = tolua.cast(item:getChildByName("name_label"), "Label"); 
			local rankingLabel = tolua.cast(item:getChildByName("ranking_label"), "Label");
			if((index ~= -1 and i == index) or (i == #messageData)) then
				nameLabel:setColor(ccc3(255, 154, 123));
				rankingLabel:setColor(ccc3(255, 154, 123));
			end
			nameLabel:setText(name);
			rankingLabel:setText(ranking);
			m_rankingLv:pushBackCustomItem(item);
		end
	end
end

--输赢结果
local function onReceiveGuessResult( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_SMALLGAMERESULT) then
		Util.showOperateResultPrompt(m_resultText[messageData.id]);
	end
end

--其他玩家猜拳选择
local function onReceiveContactContent( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_FINGERGUESSCONTACT)then
		--加入新对话
		local name = messageData.name;
		local contactItem = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "FingerGuessContactItem.json");
		local nameLabel = tolua.cast(contactItem:getChildByName("name_label"), "Label");
		local descLabel = tolua.cast(contactItem:getChildByName("desc_label"), "Label");
		local choiceLabel = tolua.cast(contactItem:getChildByName("choice_label"), "Label");
		nameLabel:setText(name);
		descLabel:setText(m_contactDesc[messageData.isFirst + 1]);
		choiceLabel:setText(m_choiceName[messageData.choiceId]);
		m_contactLv:pushBackCustomItem(contactItem);
		--处理新消息显示在最下边
		local item0 = m_contactLv:getItem(0);
		local parent = item0:getParent();
		local contentHeight = parent:getContentSize().height;
		if contentHeight > 400 then
			parent:setPositionY(400 + 150);		
		end
		--增加到最多时移除
		if(m_contactLv:getChildrenCount() > MAX_CONTACT_COUNT) then
			m_contactLv:removeAllItems();
		end
	end
end

--游戏状态
local function onReceiveGameStatus( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS)then
		-- ProgressRadial.close();
		if(messageData.statusId == STATUS_WAIT) then
			Util.showOperateResultPrompt(TEXT_WAIT);
		else
			m_status = messageData.statusId;
			m_sec = messageData.sec;
			m_gameCount = messageData.gameCount;
			refreshDisplay();
			startUpdate();
			open();
		end
	end
end

-------------------------客户端发送请求-------------------------
--发送选择（剪刀、石头、布）
local function sendChoice( choiceId )
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FINGERGUESSCHOICE, {choiceId});
	test_sendContact(choiceId);
end

--发送请求（调用时机：1、打开游戏界面；2、每一次倒计时结束   发送内容：1、当前状态； 2、游戏局数）
function sendRequest()
	local data = {m_status, m_gameCount};
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FINGERGUESSREQUEST, data);
	-- ProgressRadial.open();
end

local function registerReceiveMsg()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FINGERGUESSMOSTERPROMPT, onReceiveMonsterPrompt);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS, onReceiveGameStatus);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FINGERGUESSCONTACT, onReceiveContactContent);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMERESULT, onReceiveGuessResult);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FINGERGUESSRANK, onReceiveGuessRanking);
end

local function unRegisterReceiveMsg()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_FINGERGUESSMOSTERPROMPT, onReceiveMonsterPrompt);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS, onReceiveGameStatus);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_FINGERGUESSCONTACT, onReceiveContactContent);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMERESULT, onReceiveGuessResult);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_FINGERGUESSRANK, onReceiveGuessRanking);
end

local function closeOnTouch( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		UIManager.close("FingerGuessGame");
	end
end

local function init()
	m_time = "";
end

--------------------模拟服务器发送测试----------------------
function test_sendStatus()
	-- 1.未到12点未开启；  2.开启中，等待游戏；  3.开启中，游戏进行中;
	local messageData = {};
	messageData.statusId = STATUS_READY;
	messageData.sec = 5;
	messageData.gameCount = 0;
	onReceiveGameStatus( NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS, messageData );
end

local test_names = {"Tom", "Jenny", "Obama", "Catherine", "Estelle", "Aliver", "Becky", "Carry", "Cluse", "Koulker", "Sheild", "Rose", "Jack", "Json", "Charlse", "Rwike", "ShiledGan"};
function test_sendContact(choiceId)
	local data = {};
	data.name = test_names[math.random(#test_names)];
	data.choiceId = math.random(3);
	data.isFirst = 1;
	onReceiveContactContent(NETWORK_MESSAGE_RECEIVE_FINGERGUESSCONTACT, data);
end

function test_ranking()
	local data = {};
	local nameTest = math.random(10);
	for i = 1,10 do
		local a = {};
		-- if(i == nameTest) then
		-- 	a.name = m_testName;
		-- else
		-- 	a.name = test_names[math.random(#test_names)];
		-- end
		a.name = test_names[math.random(#test_names)];
		a.ranking = i;
		table.insert(data, a);
	end

	--玩家自己
	local self = {};
	self.name = m_testName;
	self.ranking = 11;
	table.insert(data, self);

	onReceiveGuessRanking(NETWORK_MESSAGE_RECEIVE_FINGERGUESSRANK, data);
end

function test_npcPrompt()
	local data = {};
	data.promptId = math.random(#m_promptText);	
	onReceiveMonsterPrompt(NETWORK_MESSAGE_RECEIVE_FINGERGUESSMOSTERPROMPT, data);
end

function test_result()
	local data = {};
	data.id = math.random(3);
	onReceiveGuessResult(NETWORK_MESSAGE_RECEIVE_SMALLGAMERESULT, data);
end

--启动定时器
function startUpdate()
	m_time_schedule = m_scheduler:scheduleScriptFunc(timeUpdate, 1, false);
end

--停止定时器
function stopUpdate()
    if (m_time_schedule ~= nil) then  
        m_scheduler:unscheduleScriptEntry(m_time_schedule)  
        m_time_schedule = nil;
    end 
end

local function restoreData()
	local m_gameCount = -1; -- 标志系统已经进行几局
	local m_sec = 0;
	local m_status = -1; --游戏状态
end

local function choiceBtnOnTouch( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local tag = sender:getTag();
		sendChoice(tag);
	end
end

local function boundBtnsListener()
	local scissor_btn = tolua.cast(m_rootLayout:getWidgetByName("scissor_btn"), "Button");
	local stone_btn = tolua.cast(m_rootLayout:getWidgetByName("stone_btn"), "Button");
	local paper_btn = tolua.cast(m_rootLayout:getWidgetByName("paper_btn"), "Button");
	scissor_btn:setTag(SCISSOR_ID);
	stone_btn:setTag(STONE_ID);
	paper_btn:setTag(PAPER_ID);
	scissor_btn:addTouchEventListener(choiceBtnOnTouch);
	stone_btn:addTouchEventListener(choiceBtnOnTouch);
	paper_btn:addTouchEventListener(choiceBtnOnTouch);
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

		m_rootLayout = TouchGroup:create();
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Game_FingerGuess.json");
		m_rootLayout:addWidget(panel);

		local closeBtn = tolua.cast(m_rootLayout:getWidgetByName("close_btn"), "Button");
		closeBtn:addTouchEventListener(closeOnTouch);

		m_rootLayer:addChild(m_rootLayout, 1);

		registerReceiveMsg();
		boundBtnsListener();
	    m_scheduler = CCDirector:sharedDirector():getScheduler();
	    m_contactLv = tolua.cast(m_rootLayout:getWidgetByName("choiceSLV"), "ListView");
	    m_rankingLv = tolua.cast(m_rootLayout:getWidgetByName("ranking_slv"), "ListView");
	end
end

function open()
	if (not m_isOpen) then
		create();
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        init();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

        stopUpdate();
        restoreData();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    end
	    unRegisterReceiveMsg();
	    m_rootLayer = nil;
	    m_rootLayout = nil;
	    m_isOpen = false;
	end
end