module("BattleActivity", package.seeall)

local m_bgPanel = nil;
local m_uiPanel = nil;--返回购买金币等物品panel
local m_bigPanel = nil;--外层选择活动panel
local m_smallPanel = nil;--内部选择活动panel
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerMessage = nil;
local m_type = 0;
local m_isOpen = false;
local m_info = {{["isOpen"]=true,["times"]=5},{["isOpen"]=true,["times"]=5},{["isOpen"]=false,["times"]=5}};
function open()--请求信息
    CommonUI.open();--通用ui
    ActivityType.open(m_info);
end

function close()
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeAllChildrenWithCleanup(true);
        GameManager.enterMainCity();
end

