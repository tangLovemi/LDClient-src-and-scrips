module("BroadcastManager", package.seeall)


function registerMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SYSTEM_BRODCAST_NOTIFY, on_messageBack);
end


function on_messageBack(type,message)
	BroadcastLayer.addMessage(message.content);
end
