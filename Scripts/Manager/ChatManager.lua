module("ChatManager", package.seeall)
local m_max = 80;
local m_message = {};
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_ticker = 1;
local function update(dt)
	Response(0,{type=1,name="系统",viplevel=3,id="1122222222",content="拮抗剂卢卡雷利理论逻辑"});
end

function registerMessage()
	-- m_schedulerEntry = m_scheduler:scheduleScriptFunc(update, 1, false);
	m_message[CHAT_TYPE_ALL] = {};
	m_message[CHAT_TYPE_WORLD] = {};
	m_message[CHAT_TYPE_TEAM] = {};
	m_message[CHAT_TYPE_SYSTEM] = {};
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_CHAT, Response);
end

local function setDataType(type,data)
	local temp = {};
	temp.type = data.type;
	temp.id = data.id;
	temp.name = data.name;
	temp.viplevel = data.viplevel;
	temp.content = data.content;

	temp.ticker = m_ticker;
	m_ticker = m_ticker + 1;
	
	table.insert(m_message[type],temp);
	Chat.addNewMessage(type,temp);
	MainCityUI.showChatInfo(data)
end

function getData() 
	return m_message;
end

function Response(messageType, messageData)
	local all = {};
	local world = {};
	local system = {};
	local team = {};

	setDataType(CHAT_TYPE_ALL,messageData)
	if(messageData.type == 0)then
		setDataType(CHAT_TYPE_SYSTEM,messageData)
	elseif(messageData.type == 1)then
		setDataType(CHAT_TYPE_WORLD,messageData)
	-- elseif(messageData.type == 2)then
	-- 	setDataType(CHAT_TYPE_TEAM,data)
	end
	-- Chat.removeMessage(CHAT_TYPE_ALL);
	if(#m_message[CHAT_TYPE_ALL] > m_max)then
		table.remove(m_message[CHAT_TYPE_ALL],1);
		Chat.removeMessage(CHAT_TYPE_ALL);
	end
	if(#m_message[CHAT_TYPE_WORLD] > m_max)then
		table.remove(m_message[CHAT_TYPE_WORLD],1);
		Chat.removeMessage(CHAT_TYPE_WORLD);
	end
	if(#m_message[CHAT_TYPE_TEAM] > m_max)then
		table.remove(m_message[CHAT_TYPE_TEAM],1);
		Chat.removeMessage(CHAT_TYPE_TEAM);
	end
	if(#m_message[CHAT_TYPE_SYSTEM] > m_max)then
		table.remove(m_message[CHAT_TYPE_SYSTEM],1);
		Chat.removeMessage(CHAT_TYPE_SYSTEM);
	end
end

function sendMessage()
	
end
