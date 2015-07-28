--
-- Author: Your Name
-- Date: 2015-06-05 15:01:18
--
module("WishManager", package.seeall)
local m_wishBaseData = nil
local m_baseInfoHandler = nil
local m_getItemHandler = nil
local m_selectType = nil
function onRecievBaseInfo(messageType,messageData)
	m_wishBaseData = messageData
	if m_baseInfoHandler ~= nil then
		m_baseInfoHandler(messageData)
		m_baseInfoHandler = nil
	end
	NotificationManager.onLineCheck("WishManager")
end
function setBaseInfoCallback( calback)
	m_baseInfoHandler= calback
end
function getWishBaseDataLocal()
	return m_wishBaseData
end
function onRecieveResultInfo(messageType,messageData)
	if m_getItemHandler~= nil then
		m_getItemHandler(messageData)
	end
end
function getSelecttype()
	return m_selectType
end
function chouchaWork(type,num,callback)
	m_getItemHandler = callback
	m_selectType = type
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_WISH_SYSTEM_CHOUKA, {type,num});
end
function getWishBaseData(initBaseInfo)
	m_baseInfoHandler = initBaseInfo
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_WISH_SYSTEM_INFO, {0});
end
-- function registerMessage()
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_WISH_SYSTEM_INFO_RESP, onRecievBaseInfo);--请求许愿系统信息
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_WISH_SYSTEM_ITEM_GET, onRecieveResultInfo);--接收许愿结果
-- end

function unRegisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_WISH_SYSTEM_INFO_RESP, onRecievBaseInfo);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_WISH_SYSTEM_ITEM_GET, onRecieveResultInfo);
end
function checkNotification()
	-- print(m_wishBaseData.diamond_countdown.."......................................"..m_wishBaseData.gold_countdown)

	GameManager.updateCountDown(m_wishBaseData.gold_countdown,m_wishBaseData.diamond_countdown)
	if m_wishBaseData.gold_time~= 0 then
		if m_wishBaseData.gold_countdown ==0 then
			return true
		end
	end
	if m_wishBaseData.diamond_countdown ==0 then
		return true
	end

    return false
end

function checkNotification_login()
    return checkNotification()
end
function checkNotification_line()
    return checkNotification()
end
function checkNotification_close()
    return checkNotification()
end
