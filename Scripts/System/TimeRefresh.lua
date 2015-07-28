module("TimeRefresh", package.seeall)

require "UI/Shop/ShopTimeRefresh"

--接收服务器发送的有关时间
--messageData = {hor = ?, min = ?, sec = ?}


local function onReceiveTimeRefresh( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_REMAINTIME) then
		if(messageData.id == SHOP_MYS_TIME) then
			ShopTimeRefresh.receiveTimeFromServer(messageData);
		elseif(messageData.id == SHOP_EXC_TIME) then
			ShopTimeRefresh.receiveTimeFromServer(messageData);
		elseif(messageData.id == JJC_TIME) then
			JJCUI.receiveTimeFromServer(messageData);
		end
	end
end


function registerTimeRefresh()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REMAINTIME, onReceiveTimeRefresh);
end


function unRegisterTimeRefresh(messageType)
	if(messageType == NETWORK_MESSAGE_RECEIVE_REMAINTIME) then
		NetMessageManager.unregisterMessage(messageType, onReceiveTimeRefresh);
	end
end

--格式化时间
function timeFormat(hour, minute, second)
    hour = hour .. "";
    minute = minute .. "";
    second = second .. "";
    if(string.len(hour) == 1) then
        hour = "0" .. hour;
    end
    if(string.len(minute) == 1) then
        minute = "0" .. minute;
    end
    if(string.len(second) == 1) then
        second = "0" .. second;
    end
    return hour .. ":" .. minute .. ":" .. second;
end

