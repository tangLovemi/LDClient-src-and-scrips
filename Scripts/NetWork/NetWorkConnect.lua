module("NetWorkConnect", package.seeall)

local DEFAULT_IP = "192.168.1.123"

local m_connectIP = DEFAULT_IP;

function create(scene)
	NetWorkManager:sharedInstance():createSocket(scene, m_connectIP);
end

function create(scene,connectIP)
	NetWorkManager:sharedInstance():createSocket(scene, connectIP);
end

function remove(scene)
	NetWorkManager:sharedInstance():removeSocket(scene);
end

function setConnectIP(ip)
	m_connectIP = ip;
end

function setDefaultIP()
	m_connectIP = DEFAULT_IP;
end


function getConnectIP()
	return m_connectIP;
end	