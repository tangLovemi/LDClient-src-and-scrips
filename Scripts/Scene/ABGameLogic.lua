module("ABGameLogic", package.seeall)

----------------------------------------
--               AB答场景
----------------------------------------

--客户端发送：
--1、请求
--2、位置

--服务器发送：
--1、游戏状态
--2、玩家信息
--3、答题结果及奖励

local m_scheduler = nil;
local m_time_schedule = nil;
local m_rootLayer = nil;  --场景
local m_sceneActor = nil; --玩家自己
local m_timeActor = nil; --时间
local m_quesActor = nil; --问题
local m_answerActor_A = nil; --选项A
local m_answerActor_B = nil; --选项B

local m_status = -1;   --游戏状态
local m_gameCount = -1;--进行局数
local m_sec = 0;

local m_questions = {}; --所有问题、选项及答案

--游戏状态
local STATUS_WAIT  = 1; --等待开始
local STATUS_READY = 2; --准备开始
local STATUS_ON    = 3; --进行中
local STATUS_GAME_OVER = 4; --游戏结束

-------------常量-------------------
local ACTOR_NAME_TIME = "time";
local ACTOR_NAME_QUESTION = "question";
local ACTOR_NAME_ANSWER_A = "answer_A";
local ACTOR_NAME_ANSWER_B = "answer_B";

local GAME_MAX_COUNT = 5;
local TIME_ON = 10;
local TIME_READY = 5;

local TEXT_WAIT = "游戏将在每天12:30准时进行！！耐心等待";


local function formatTime()
	if(m_sec > 60) then
		return math.floor(m_sec/60) .. "分" .. m_sec%60 .. "秒";
	end
	return m_sec .. "秒";
end

local function refreshTime()
	m_timeActor:setDialogDisplay("剩余" .. formatTime());
end
--刷新题目和选项
local function refreshQuesAndAnswer()
	if(m_status == STATUS_ON) then
		m_quesActor:setDialogDisplay(m_questions[m_gameCount]["question"]);
		m_answerActor_A:setDialogDisplay(m_questions[m_gameCount]["answerA"]);
		m_answerActor_B:setDialogDisplay(m_questions[m_gameCount]["answerB"]);
	else
		m_quesActor:setDialogDisplay("题面");
		m_answerActor_A:setDialogDisplay("A");
		m_answerActor_B:setDialogDisplay("B");
	end
end

local function refreshDisplay()
	if(m_status == STATUS_GAME_OVER) then
		m_timeActor:setDialogDisplay("游戏结束");
	else
		refreshTime();
	end
	refreshQuesAndAnswer();
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
		Util.showOperateResultPrompt("进入新一轮游戏");

		m_sec = TIME_ON;
		m_status = STATUS_ON;
		m_gameCount = m_gameCount + 1;
		startUpdate();
	elseif(m_status == STATUS_ON) then
		if(m_gameCount >= GAME_MAX_COUNT) then
			gameOver();
		else
			print("******************** 进入游戏等待");
			Util.showOperateResultPrompt("进入游戏等待");

			m_sec = TIME_READY;
			m_status = STATUS_READY;
			startUpdate();
		end
		--发送自己位置信息
		sendPosition();
		sendRequest();--请求服务器发送答题结果
	end
	refreshDisplay();
end

--定时器更新时间
local function updateTime()
	m_sec = m_sec - 1;
    refreshTime();
    if (m_sec == 0) then 
 --    	--时间到，请求服务器
        stopUpdate();
        timeEnd();
    end
 --    if(m_status == STATUS_ON and m_sec == 5) then
 --    	test_npcPrompt();
    -- end
end

local function onLoadSceneEnd()
	m_rootLayer = MainCityLogic.getRootLayer();
	m_sceneActor = PlayerActor.getSceneActor();
	m_timeActor = m_rootLayer:getActorByName(ACTOR_NAME_TIME);
	m_quesActor = m_rootLayer:getActorByName(ACTOR_NAME_QUESTION);
	m_answerActor_A = m_rootLayer:getActorByName(ACTOR_NAME_ANSWER_A);
	m_answerActor_B = m_rootLayer:getActorByName(ACTOR_NAME_ANSWER_B);
	if(m_timeActor) then
		m_timeActor:setDialog("剩余" .. formatTime());
		m_quesActor:setDialog("题面");
		m_answerActor_A:setDialog("A");
		m_answerActor_B:setDialog("B");
	end
	startUpdate();
	test_sendPlayers();
end
-----------------------处理服务器返回消息--------------------------

local function onReceiveGameStatus( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS) then
		if(messageData.statusId == STATUS_WAIT or messageData.statusId == STATUS_GAME_OVER) then
			unRegisterReceiveMsg();
			Util.showOperateResultPrompt(TEXT_WAIT);
		else
			ABGameLogic.create();
			m_status = messageData.statusId;
			m_sec = messageData.sec;
			m_gameCount = messageData.gameCount;
			--加载场景
			Loading.remove();
			PlayerActor.initPlayerActor();
			MainCityLogic.create();
			MainCityLogic.EnterCity(2, onLoadSceneEnd);
		end
	end
end

local function onReceivePalyersInfo( messageType, messageData )
	
end

local function onReceiveGameResult( messageType, messageData )
	
end

local function onReceiveQuestions( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_ABGAMEQUESTIONS) then
		m_questions = messageData;
	end
end

-------------------------客户端发送请求-------------------------
--发送请求
--发送时机：1、进入游戏时（请求：游戏状态，倒计时时间；15道题目及答案） 2、游戏答题结束时（请求答题结果）
function sendRequest()
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ABGAMEREQUEST, {m_status, m_gameCount});
end

--发送位置信息
--发送时机：每一局结束
function sendPosition()
	--得到当前玩家位置,设置位置编号(1表示左边；2表示右边；3表示中间)
	-- NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ABGAMEPLAYERPOS, );
end

function test_sendRequest()
	local data = {};
	data.statusId = STATUS_READY;
	data.sec = 5;
	data.gameCount = 0;
	onReceiveGameStatus(NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS, data);
end

function test_sendQuestions()
	local data = {};
	for i = 1,GAME_MAX_COUNT do
		local a = {};
		a.question = "题目_" .. i;
		a.answerA = "选项A_" .. i;
		a.answerB = "选项B_" .. i;
		table.insert(data, a);
	end
	onReceiveQuestions(NETWORK_MESSAGE_RECEIVE_ABGAMEQUESTIONS, data);
end

function test_sendPlayers()
	local data = {};
	for i = 1,30 do
		local a = {};
		a.hair = 1;
		a.face = 1;
		a.eyebrows = 1;
		a.eyes = 1;
		a.mouth = 1;
		a.goatee = 1;
		a.cloth = 1;
		a.weapon = 1;
		table.insert(data, a);
	end
	MainCityPlayers.receivePlayerInfo(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, data);
end

--启动定时器
function startUpdate()
	m_time_schedule = m_scheduler:scheduleScriptFunc(updateTime, 1, false);
end

--停止定时器
function stopUpdate()
    if (m_time_schedule ~= nil) then  
        m_scheduler:unscheduleScriptEntry(m_time_schedule)
        m_time_schedule = nil;
    end 
end

function registerReceiveMsg()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS, onReceiveGameStatus);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, onReceivePalyersInfo);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMERESULT, onReceiveGameResult);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ABGAMEQUESTIONS, onReceiveQuestions);
end

local function unRegisterReceiveMsg()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMESTATUS, onReceiveGameStatus);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, onReceivePalyersInfo);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SMALLGAMERESULT, onReceiveGameResult);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_ABGAMEQUESTIONS, onReceiveQuestions);
end

function create()
	m_scheduler = CCDirector:sharedDirector():getScheduler();
	registerReceiveMsg();
end

function remove()
	stopUpdate();
	unRegisterReceiveMsg();
end
