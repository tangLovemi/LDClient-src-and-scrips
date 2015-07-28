module("BroadcastLayer", package.seeall)

local m_parent = nil;
local m_clipNode = nil;
local m_list = {};
local m_viewWidth = 400;
function open()
	local layer = getGameLayer(SCENE_BROADCAST_LAYER);
	m_parent = CCNode:create();
	local bg = CCSprite:create(PATH_RES_IMAGE .. "broadcast_bg.png");
	bg:setPositionX(m_viewWidth/2);
	bg:setPositionY(bg:getContentSize().height/2);
	m_parent:addChild(bg);
	m_parent:setAnchorPoint(CCPoint(0,0));
	m_parent:setVisible(false);
	m_clipNode = tolua.cast(ClippingNodeCustom:create(m_viewWidth,80),"CCNode");
	m_parent:addChild(m_clipNode);
	local bg = CCSprite:create(PATH_RES_IMAGE .. "broadcast_bg.png");
	m_parent:setPosition(ccp(SCREEN_WIDTH/2-m_viewWidth/2,520));
	layer:addChild(m_parent);
end


function appearBroadcast()
	m_parent:setVisible(true);
	if(#m_list ~= 0)then
		for i,v in pairs(m_list)do
			local ooo = tolua.cast(m_list[i].label,"CCNode");
			local kkk = 2;
		end
		tolua.cast(m_list[1].label,"CCNode"):setPositionX(m_viewWidth);
		tolua.cast(m_clipNode,"ClippingNodeCustom"):addContent(tolua.cast(m_list[1].label,"CCNode"));
		m_list[1].update();
	end
end

function disappearBroadcast()
	m_parent:setVisible(false);
end

function analyMessage(list,message)
	local begin,last = string.find(message,"&");
	local data = {};
	table.insert(list,data);
	local colorIndex = 0;
	if(begin == nil)then
		data.color = BROADCAST_COLOR_WHITE;
		data.content = message;
	else
		local temp = string.sub(message,begin+1,begin+2);
		colorIndex = tonumber(string.sub(message,begin+1,begin+2));
		local substr = string.sub(message,begin+3,string.len(message));
		local begin1,last1 = string.find(substr,"&");
		if(begin1 ~= nil)then
			data.content = string.sub(substr,1,begin1-1);
			local nextStr = string.sub(substr,begin1,string.len(substr));
			analyMessage(list,nextStr);
		else
			data.content = string.sub(substr,1,string.len(substr));
		end
	end
	if(colorIndex == 1)then
			data.color = BROADCAST_COLOR_WHITE;
	elseif(colorIndex == 2)then
			data.color = BROADCAST_COLOR_GREEN;
	elseif(colorIndex == 3)then
			data.color = BROADCAST_COLOR_BLUE;
	elseif(colorIndex == 4)then
			data.color = BROADCAST_COLOR_PURPLE;
	elseif(colorIndex == 5)then
			data.color = BROADCAST_COLOR_ORANGE;
	elseif(colorIndex == 6)then
			data.color = BROADCAST_COLOR_GOLD;
	end
end

local function isAppear()
	return m_parent:isVisible();
end

function addMessage(message)
	local list = {};
	analyMessage(list,message);
	local obj = ScrollLabel.create(list);
	table.insert(m_list,obj);
	if(not isAppear())then
		appearBroadcast();
	end
end


function update(object)
	local index = 0;
	local obj = tolua.cast(object,"CCNode");
	for i,v in pairs(m_list)do
		if(v.label == obj)then
			v.remove();
			index = i;
		end
	end
	table.remove(m_list,index);
	if(#m_list == 0)then
		disappearBroadcast();
	else
		appearBroadcast();
	end
end

function createLabel()
    local ta = {};
    local temp = Label:create();
    ta.label = temp;
    return ta;
end

