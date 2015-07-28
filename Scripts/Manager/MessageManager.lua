module("MessageManager", package.seeall)
--管理全局消息队列
local m_messageQueue = {};
function addMessage(type)
	table.insert(m_messageQueue,type);
end

function pop()
	if(#m_messageQueue > 0)then
		table.remove(m_messageQueue,1);
	end
end

function front()
	if(#m_messageQueue > 0)then
		return m_messageQueue[1];
	end
	return nil;
end
