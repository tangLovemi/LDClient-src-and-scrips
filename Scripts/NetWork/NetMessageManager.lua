
module("NetMessageManager", package.seeall)

local m_cbFunctions = {};

function sendMessage(messageType, messageData)
	-- ClipTouchLayer.show();
	NetWorkManager:sharedInstance():sendMessage(messageType, messageData);
end

local function receiveMessage(messageType, messageData)
	-- ClipTouchLayer.clear();
	if(messageType == 2501)then
		if(messageData.isOk ~= 1)then
			ClipTouchLayer.clear();
		end
	end
	local functions = m_cbFunctions[messageType];
	if (functions == nil) then
		return;
	end
	for i, func in ipairs(functions) do
		func(messageType, messageData);
	end
end

function registerReceiveFunc()
	NetWorkManager:sharedInstance():setScriptHandler(receiveMessage);
end

function registerMessage(messageType, callbackFunc)
	if (m_cbFunctions[messageType] == nil) then
		m_cbFunctions[messageType] = {};
	end
	table.insert(m_cbFunctions[messageType], callbackFunc);
end

function unregisterMessage(messageType, callbackFunc)
	local functions = m_cbFunctions[messageType];
	if (functions == nil) then
		return;
	end
	for i, func in ipairs(functions) do
		if (func == callbackFunc) then
			table.remove(functions, i);
		end
	end
end