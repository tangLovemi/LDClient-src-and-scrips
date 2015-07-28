--
-- Author: Gao Jiefeng
-- Date: 2015-03-25 13:41:45
--
module("MailManager", package.seeall)
local m_MailDatas = {}
local m_mailOperateHandler= nil
local m_sendMailHandler = nil

function getAllMail() --收取所有邮件
	return m_MailDatas
end
function getMailContentById(mailId)
	for k,v in pairs(m_MailDatas) do
		if v["mailId"] ==  mailId then
			return v
		end
	end

end
function getMailIndexById(mailId)
	for k,v in pairs(m_MailDatas) do
		if v["mailId"] ==  mailId then
			return k
		end
	end

end

function sendNewMail(sender_name,title, mailContent,handler)
	m_sendMailHandler = handler
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_WRITEMAIL, {sender_name,title, mailContent});	
end

function mailOperate(mailId, state,handler)
	m_mailOperateHandler = handler 
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MAILOPERATE, {mailId,state});

end
function onRecieveAllMail(messageType, messageData)--请求所有邮件返回
	m_MailDatas = messageData
end
function onRecieveMailOperate(messageType, messageData)--邮件操作返回
	local mailIndex= getMailIndexById(messageData["mailId"])
	m_MailDatas[mailIndex]["state"] =messageData["state"] 
	m_mailOperateHandler(messageData["mailId"],messageData["state"])
	m_mailOperateHandler = nil
	if messageData["state"] ==3 or messageData["state"] ==4 then
		m_MailDatas[mailIndex] = nil
        -- table.remove(m_MailDatas,mailIndex)
	end
end
function onRecieveMailSendResp(messageType, messageData)--发送邮件返回
	if messageData["isOk"] == 1 then
		m_sendMailHandler()
    elseif messageData["isOk"] == 0 then
        Util.showOperateResultPrompt("玩家不存在")
	end
end

function onRecieveNewMail(messageType, messageData)--收到新邮件
	m_MailDatas[messageData["mailId"]] = messageData
	if Mail.getOpenState() == true then 
		Mail.getNewMail(messageData)
		NotificationManager.onLineCheck("MailManager")
	end
end
function getMailTimeDiffStrings(mailId)
	local mailData = m_MailDatas[getMailIndexById(mailId)] 
    local mailTime = math.floor(tonumber(mailData.date)/1000)
    local timeNow = os.time()
    local differTime = os.difftime(timeNow, mailTime)
    local formateTimeString = string.format("%.2d:%.2d:%.2d:%.2d:%.2d:%.2d",differTime/(60*60*60*60*60)%60,differTime/(60*60*60*60)%60,differTime/(60*60*60)%60,differTime/(60*60)%60, (differTime/60)%60, differTime%60)
    local timeArray =  Util.Split(formateTimeString,":")
    local year = tonumber(timeArray[1])
    local month = tonumber(timeArray[2])
    local day = tonumber(timeArray[3])
    local hour = tonumber(timeArray[4])
    local minute = tonumber(timeArray[5])
    local secound = tonumber(timeArray[6])
    local time = ""
    local timeDesc = ""

    if year>0 then
        time =""
        timeDesc = "刚才"
    else
        if month>0 then
            time =month
            timeDesc = "月前"
        else
            if day>0 then
                time =day
                timeDesc = "天前"
            else
                if hour>0 then
                    time =hour
                    timeDesc = "小时前"
                else
                    if minute>0 then
                        time =minute
                        timeDesc = "分钟"
                    else
                        time =""
                        timeDesc = "刚才"                     
                    end
                end
            end
        end
    end

    return time,timeDesc
end

function checkNotification()
    for k,v in pairs(m_MailDatas) do
        if v["state"] ==0 then
            return true
        end

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
--注册接收协议
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAILCONTENT, onRecieveAllMail);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAILOPERRESULT, onRecieveMailOperate);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAILSENDRESP, onRecieveMailSendResp);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAILCONTENTDOWN, onRecieveNewMail);



-- --邮件系统
-- --发送
-- NETWORK_MESSAGE_SEND_MAILOPERATE = 600 --对邮件进行操作{mailID , type(1:读取，2：附件内容领取，3：邮件删除，4领取并删除)}
-- NETWORK_MESSAGE_SEND_MAILREQUEST = 602 --请求所有邮件信息{可为任何值}
-- NETWORK_MESSAGE_SEND_WRITEMAIL = 604 --写邮件  {收件人，主题，内容}
-- --接收
-- NETWORK_MESSAGE_RECEIVE_MAILCONTENT = 601 --602回复 邮件内容{sender_name发件人姓名	date:发送日期,title:主题,content:邮件内容,attach:附件,state:邮件状态,mailID	:邮件ID	}
-- NETWORK_MESSAGE_RECEIVE_MAILDELRESULT = 603--600回复 对邮件操作结果返回{mailID,state:当前状态(1:读取，2：附件内容领取，3：邮件删除)}
-- NETWORK_MESSAGE_RECEIVE_SENDMAILRESP = 607 --604返回值，发邮件返回信息{isOk(0：失败，1：成功)}
-- NETWORK_MESSAGE_RECEIVE_MAILCONTENDOWN =609 --服务器下发新邮件 邮件内容{sender_name发件人姓名	date:发送日期,title:主题,content:邮件内容,attach:附件,state:邮件状态,mailID	:邮件ID	}