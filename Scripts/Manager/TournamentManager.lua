module("TournamentManager", package.seeall)

local m_state = nil;
local m_matchData = nil;
local m_myBetData = nil;
local m_myGameData = nil;
local function onTournament_back(messageType, messageData)
	m_matchData = messageData;
	m_matchData = {};
	for i,v in pairs(messageData)do
		m_matchData[v.id] = v;
	end

	LastLiveUI.reflushUI();
end



local function onMyGame_back(messageType, messageData)
	m_myGameData = messageData;
	BD_MyGameUI.initListView();
end

local function onMyBet_back(messageType, messageData)
	if(#messageData == 0)then--没有押注 

	else
		m_myBetData = messageData;
		MyBetUI.reflushUI();
	end
end

local function onState_back(messageType, messageData)
	m_state = messageData;
	BeatDownUI.reflushUI();
end

local function onRegisConfirm_back(messageType, messageData)
	if(messageData.sure == 1)then
		Util.showOperateResultPrompt("报名成功");
	else
		Util.showOperateResultPrompt("报名失败");
	end
end

local function onBetConfirm_back(messageType, messageData)
	if(messageData.sure == 1)then
		m_matchData[LastLiveUI.getCurBet()].isBet = 1;
		UIManager.close("BetUI");
		Util.showOperateResultPrompt("押注成功");
	else
		Util.showOperateResultPrompt("押注失败");
	end
end

function registerMessage()
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TOURNAMENT_LIVE, onTournament_back);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TOURNAMENT_BETINFO, onState_back);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TOURNAMENT_BETTLE, onMyGame_back);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TOURNAMENT_MYBET, onMyBet_back);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TOURNAMENT_APPLY, onRegisConfirm_back);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TOURNAMENT_BETSURE, onBetConfirm_back);
end

function release()
	m_state = nil;
	m_matchData = nil;
	m_myBetData = nil;
	messageData = nil;
end

function getMyGameData()
	return m_myGameData;
end

function getState()
	return m_state;
end

function getMatchData()
	return m_matchData;
end

function getMyBetData()
	return m_myBetData;
end

