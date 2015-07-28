module("LoginManager", package.seeall)

local m_serverList = nil;
function registerMessage()

end

function onServerListBack(message)
	m_serverList = message;
end


function getServerList()
	return m_serverList;
end

function getInfoByID(id)
	for i,v in pairs(m_serverList)do
		if(v.id == id)then
			return v;
		end
	end
	return nil;
end

function getFireInfo()
	for i,v in pairs(m_serverList)do
		if(v.fire == 1)then
			return v;
		end
	end
	return nil;
end