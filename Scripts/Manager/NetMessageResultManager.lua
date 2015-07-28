module("NetMessageResultManager", package.seeall)

local m_callBackFun = nil;
function registerMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ERROR_INFO_ID, on_back);
end

function on_back(messageType,message)
	displayMessage(message);
end

function displayMessage(message)
	local str = DataBaseManager.getValue("FailMsg", DATABASE_HEAD .. message.id, "msg");
	if(message.id == 4)then--钻石不足 
		UIManager.open("ErrorDialog");
		local funs = {};
		table.insert(funs,function () UIManager.close("ErrorDialog");end);
		table.insert(funs,function () UIManager.close("ErrorDialog");end);
		ErrorDialog.setPanelStyle(str,funs);
	elseif(message.id == 1)then--成功 
		if(m_callBackFun ~= nil)then
			m_callBackFun();--继续执行进入相应界面
		end
	else
		Util.showOperateResultPrompt(str);
	end
	m_callBackFun = nil;
end


function setCallBackFun(fun)
	m_callBackFun = fun;
end