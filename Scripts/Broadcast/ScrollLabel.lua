module("ScrollLabel", package.seeall)

local m_speed = 200;
function create(message)
	local selfObj = {};
	local label1 = CCNode:create();
    label1:retain();
    label1:setAnchorPoint(CCPoint(0,0));

    -- local width = label:getContentSize().width;

    local posx = 0;
    for i,v in pairs(message)do
        local temp = Label:create();
        temp:setText(v.content);
        temp:setFontSize(25);
        temp:setAnchorPoint(CCPoint(0,0));
        temp:setTextHorizontalAlignment(kCCTextAlignmentLeft);
        temp:setColor(v.color);
        temp:setPositionX(posx);
        label1:addChild(temp);
        posx = posx + temp:getContentSize().width + 5;
    end
    selfObj.label = label1;
    selfObj.update = function ()
        local disX = posx + 400;
        local move = CCMoveBy:create(math.abs(disX / m_speed), CCPoint(-disX, 0));
        local callback = CCCallFuncN:create(BroadcastLayer.update);
        local actList = CCArray:create();
        actList:addObject(move);
        actList:addObject(callback);
        local action = CCSequence:create(actList);
        tolua.cast(label1, "CCNode"):runAction(action);
	end

	selfObj.remove = function ()
		label1:removeFromParentAndCleanup(true);
		selfObj = nil;
	end
    return selfObj;
end

