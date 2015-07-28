
function OpenSelectServerList(message)
	CCLuaLog("get serverlist message open selectserver");
	LoginManager.onServerListBack(message);
	UIManager.open("Login");
end

function RegisterCallBack(message)
	newRegisterUI.RegisterCallBack(message);
end

function ConnectErrorBack()
	Util.showOperateResultPrompt("连接失败");
	CCLuaLog("");
end