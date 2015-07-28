module("ClipTouchLayer", package.seeall)
local m_layer = nil;
function show()
	if(m_layer == nil)then
		local function onTouch(eventType, x, y)
			if eventType == "began" then
				return true;
    		elseif eventType == "ended" then
        		return true;
    		end
    	end
    	m_layer = CCLayer:create();
    	getGameLayer(SCENE_TOP_LAYER):addChild(m_layer);
    	m_layer:setTouchEnabled(true);
    	m_layer:setTouchPriority(-10);
    	m_layer:registerScriptTouchHandler(onTouch,false,-1,true)
	end
end


function clear()
	if(m_layer ~= nil)then
		getGameLayer(SCENE_TOP_LAYER):removeChild(m_layer,true);
		m_layer = nil;
	end
end