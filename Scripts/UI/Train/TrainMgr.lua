module("TrainMgr", package.seeall)

local m_isOpen = false;

--操作id
local OPE_TYPE_REQUEST 		= 1; --请求数据
local OPE_TYPE_OPENTRIAN   	= 2; --打开或关闭个人训练场
local OPE_TYPE_STARTBLESS  	= 3; --开始祝福
local OPE_TYPE_BUY_ROBCOUNT	= 4; --购买抢夺次数
local OPE_TYPE_FIGHT		= 5; --抢夺
local OPE_TYPE_ROB_SEAT    	= 6; --占座


local m_resultCN = {
	-- ["1"] = "占座成功",   		--1
	["2"] = "",						--2
	["3"] = "购买抢夺座位次数成功",	--3
	["4"] = "购买抢夺座位次数失败",	--4
	["5"] = "开始祝福",				--5
	["6"] = "开始进行个人训练",		--6
	["7"] = "",			    		--7
	["8"] = "",						--8
	["9"] = "",						--9
	["10"] = "",     				--10
	["11"] = "不能抢夺自己",	    --11
	["12"] = "该角色正被其他角色挑战",--12
	["13"] = "",		--13
	["14"] = "挑战次数不够",		--14
	["15"] = "",		--15
	["16"] = "",		--16
	["17"] = "",		--17
	["18"] = "",		--18
	["19"] = "", 		--19
	["20"] = "", 		--20
	["21"] = "",		--21
};

local m_rootLayer = nil;
local m_index = 0;

local function refresh( operateId, resultId )
	if(operateId == OPE_TYPE_REQUEST) then
	--打开请求
		TrainUI.openReceiveDataEnd();
	elseif(operateId == OPE_TYPE_STARTBLESS) then
		TrainBless.close();
	else
		TrainUI.refreshInfo();
		if(operateId == OPE_TYPE_ROB_SEAT) then
			TrainUI.applySeatEnd(resultId, m_index);
		elseif(operateId == OPE_TYPE_FIGHT) then
			TrainUI.robSeat(m_index, resultId);
		elseif(operateId == OPE_TYPE_OPENTRIAN) then
			TrainUI.startStopTrainResponse(resultId);
		end
	end
end

local function receiveOperateResultMsg( messageType, messageData )
	-- operateId
	-- resultId
	
	Util.showOperateResultPrompt(m_resultCN[messageData.resultId .. ""]);
	close();
	refresh(messageData.operateId, messageData.resultId);
end

function open(index)
	if(m_isOpen == false) then
		m_isOpen = true;
	  	local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);

		if(index) then
			m_index = index;
		end
		ProgressRadial.open();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		m_rootLayer:removeFromParentAndCleanup(false);
		ProgressRadial.close();
	end
end

function create()
	m_rootLayer = CCLayer:create();
	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width, WINSIZE.height);
  	m_rootLayer:addChild(bgLayer, 0);
  	m_rootLayer:retain();

	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_OPERATIONRESPONS, receiveOperateResultMsg);
end

function remove()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_OPERATIONRESPONS, receiveOperateResultMsg);
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
end