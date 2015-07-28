module("MutipleButtonList", package.seeall)



local m_isMutiple = false;
local m_listener = nil;
local m_list = nil;
local m_lastClick = nil;

local function onTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then

		local button = tolua.cast(sender,"Button");
		m_listener(sender,eventType);
		if(m_isMutiple)then

		else
			if(m_lastClick ~= nil)then
				tolua.cast(m_lastClick,"Button"):setBright(true);
				-- tolua.cast(m_lastClick,"Button"):setBrightStyle(1);
			end
			if(m_lastClick == sender)then
				return;
			else
				-- button:setBrightStyle(1);
				button:setBright(false);
			end
		end
		m_listener(sender,eventType);
		m_lastClick = sender;
	end
end

function create(list,isMutiple,listener)--是否是多选
	m_isMutiple = false;
	m_listener = nil;
	m_list = nil;
	m_lastClick = nil;
	m_list = list;
	m_listener = listener;
	m_isMutiple = isMutiple;
	for i,v in pairs(list) do
		local button = tolua.cast(v,"Button");
		button:addTouchEventListener(onTouchEvent);
		-- button:setBright(true);
		-- button:setBrightStyle(1);
	end
end