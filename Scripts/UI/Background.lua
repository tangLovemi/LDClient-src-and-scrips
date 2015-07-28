module("Background", package.seeall)

local m_rootLayer = nil;
local m_bgPanel = nil;
local m_closeCB = nil;
local m_isOpen = false;
local m_type = nil;

local Width = 945/2;
local Height = 585/2;
local m_defPos = ccp(SCREEN_WIDTH_HALF - Width, SCREEN_HEIGHT_HALF - Height);

local function closeBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
        -- m_closeCB();
        UIManager.close(m_closeCB);

        if(MainCityLogic.getRootLayer() ~= nil) then
            MainCityLogic.registerTouchFunction();
        end

        UIManager.setOpen(false);
    end
end

local function closeOnClick( eventType,x,y )
    -- body
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        if(m_type ~= nil) then
            if(m_closeCB) then
                m_closeCB();
            end
        else
            if(m_closeCB) then
                UIManager.close(m_closeCB);
            end
        end

        if(MainCityLogic.getRootLayer() ~= nil) then
            MainCityLogic.registerTouchFunction();
        end

        UIManager.setOpen(false);
    end
end

function setFullScreen()
    m_bgPanel:setScaleX(1.14747);
    m_bgPanel:setScaleY(1.16363);
end

function restoreScale()
    m_rootLayer:setScale(1);
end

function setPosition( pos )
	m_rootLayer:setPosition(pos);
end

function create(closeCB, type)
	m_rootLayer = CCLayer:create();
    m_rootLayer:retain();
    m_closeCB = closeCB;
    if(type) then
        m_type = type;
    end
    local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
    m_rootLayer:addChild(bgLayer, 1);
    bgLayer:registerScriptTouchHandler(closeOnClick);
    return m_rootLayer
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, TWO_ZORDER);
	end
end

function close()
	if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        m_type = nil;
        m_closeCB = nil;
    end
end

function remove()
	if(m_rootLayer) then
        m_rootLayer:removeAllChildrenWithCleanup(true);
        m_rootLayer:release();
        m_rootLayer = nil;
    end
    m_closeCB = nil;
    m_bgPanel = nil;
    m_type = nil;
end

