module("Guide", package.seeall)

local m_funCB = nil;
local STATUS_NORMAL = 0;
local STATUS_GUIDE  = 1;
local m_status = STATUS_NORMAL;

function showGuide(x, y, w, h, funCB)
    if(m_status == STATUS_NORMAL) then
        m_funCB = funCB;
        local guideLayer = MainCityLogic.getGuideLayer();
        MainCityLogic.unregisterTouchFunction();
        guideLayer:showGuide(x, y, w, h);
        getGameLayer(SCENE_GUIDE_LAYER):addChild(guideLayer);
        m_status = STATUS_GUIDE;
    end
end

function clearGuide()
    if(m_status == STATUS_GUIDE) then
        local guideLayer = MainCityLogic.getGuideLayer();
        MainCityLogic.registerTouchFunction();
        guideLayer:clearGuide();
        getGameLayer(SCENE_GUIDE_LAYER):removeChild(guideLayer, false);
        if(m_funCB) then
            m_funCB();
        end
        m_status = STATUS_NORMAL;
    end
end