module("SingleChoicePanel", package.seeall)

function create(list,listener)--是否是多选
	local self = {};
	local m_list = list;
	local m_listener = listener;
	local m_lastClick = nil;
	local function onTouchEvent(sender,eventType)
		if eventType == TOUCH_EVENT_TYPE_END then
			local button = tolua.cast(sender,"Button");
			if(button:isBright() == false)then
				return;
			end
			m_listener(sender,eventType);
			if(m_lastClick ~= nil)then
				tolua.cast(m_lastClick,"Button"):setBright(true);
			end
			button:setBright(false);
			m_lastClick = sender;
		end
	end

	for i,v in pairs(list) do
		local button = tolua.cast(v,"Button");
		button:addTouchEventListener(onTouchEvent);
	end
	self.selectIndex = function (index)
		tolua.cast(m_list[index],"Button"):setBright(false);
		m_lastClick = m_list[index];
		m_listener(m_list[index],2);
	end
	return self;
end