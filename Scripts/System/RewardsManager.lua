module("RewardsManager", package.seeall)



local m_datas = {};
local m_count = 0;
local m_index = 0;
local m_node = nil;
local m_isShow = false;
local SPACE_TIME = 0.5;

local function createAction()
	local arr = CCArray:create();
	arr:addObject(CCDelayTime:create(SPACE_TIME));
	arr:addObject(CCCallFunc:create(function() RewardsManager.actionEnd() end));
	action = CCSequence:create(arr);
	return action;
end

function actionEnd()
	m_index = m_index + 1;
	m_node:stopAllActions();
	if(m_index > m_count) then
		m_index = 0;
		m_count = 0;
		m_datas = nil;
		m_isShow = false;
	else
		local v = m_datas[m_index];
		if(v.count > 0) then
			local desc = GoodsManager.getNameById(v.id) .. "  ×" .. v.count;
			Util.showOperateResultPrompt(desc);
			m_node:runAction(createAction());
		end
	end
end


function onReceiveRewards( messageType, messageData )
	if(not m_isShow) then
		m_isShow = true;
		m_datas = messageData;
		m_count = #messageData;
		m_index = 0;
		actionEnd();
	end
end


function create()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REWARDSLIST, onReceiveRewards);
	m_node = CCNode:create();
	m_node:retain();
    getGameLayer(SCENE_UI_LAYER):addChild(m_node, CONFIRM_ZORDER);
end