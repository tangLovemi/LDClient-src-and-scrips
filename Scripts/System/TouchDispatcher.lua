module("TouchDispatcher", package.seeall)

local m_touchEvents = nil;

local function touchReceiver(touchType, x, y)
	touchType = touchType + 1;
	for i, func in ipairs(m_touchEvents[touchType]) do
		func(x, y);
	end
end

function init()
	m_touchEvents = {};
	for i = 1, TOUCH_EVENT_TYPE_COUNT do
		m_touchEvents[i] = {};
	end
end

function create()
	local touchLayer = TouchGesture:create(touchReceiver);
	addGameLayer(touchLayer, 5, SCENE_TOUCH_LAYER);
	init();
end

function registerTouchFunction(touchType, func)
	table.insert(m_touchEvents[touchType + 1], func);
end

function unregisterTouchFunction(touchType, func)
	touchType = touchType + 1;
	for i, aFunc in ipairs(m_touchEvents[touchType]) do
		if (aFunc == func) then
			table.remove(m_touchEvents[touchType], i)
		end
	end
end