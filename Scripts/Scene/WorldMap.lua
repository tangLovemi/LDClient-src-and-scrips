module("WorldMap", package.seeall)





local SCROLL_ANGLE_MAX = 10;
local m_rootLayer = nil;
local m_layer = nil;
local m_angleMax = nil;
local m_sceneID = 5;
local m_rotateSpeed = 0;
local m_moveY = 0;
local m_moveX = 0;
local m_rotateSpeed = 0;
local m_isRegister = false;
local m_actorTriggers = {};
local m_curPoint = {};
local m_open = false;
local m_drag = false;
local m_callBack = nil;
local function initTriggers()
    m_actorTriggers = {};
    local allNames = m_rootLayer:getAllActorNames();
    if (allNames) then
        local count = allNames:count();
        for i = 1, count do
            local name = tolua.cast(allNames:objectAtIndex(i - 1), "CCString"):getCString();
            local actor = m_rootLayer:getActorByName(name);
            m_actorTriggers[actor] = {};
            for j = 1, EVENT_TRIGGER_TOTAL do
                m_actorTriggers[actor][j] = {};
            end
        end
    end
end

function newUnLock()
    local actor = m_rootLayer:getActorByName("daditu");
    actor:setAction("stand" .. WorldManager.getCUrOpenMap());
end

local function onLoadingEnd()
    AudioEngine.setMusicVolume(1);
    AudioEngine.playMusic(PATH_RES_AUDIO .. "music_shijie.mp3", true);
    Loading.remove();
    renderMap();
    TouchDispatcher.init();
    registerTouchFunction();
    ShopListPanel.open();
    if(m_callBack)then
        m_callBack();
    end
    local actor = m_rootLayer:getActorByName("daditu");
    actor:setAction("stand" .. WorldManager.getCUrOpenMap());
    if(WorldManager.getUnLockID() ~= 0)then
        UIManager.open("UnLockLevel");
    end
    

    UIManager.open("WorldMapUI");
    m_rootLayer:rotateScene(-DataBaseManager.getValue("WorldMapArea", DATABASE_HEAD .. WorldManager.getCurBattleMap(), "angle"));
    if(WorldManager.getNeedOpenSelectLevel())then
        --添加任务调转判断
        if WorldManager.getTaskMapId() == nil then
            SelectLevel.create(WorldManager.getCurBattleMap());
        else           
            SelectLevel.create(WorldManager.getTaskMapId());
            WorldManager.setTaskMapId(nil)
        end
        WorldManager.setNeedOpenSelectLevel(false);
    end

    if TaskManager.getNewState() then
        if TaskManager.getLocalStepRecord()== 3 then
            UIManager.open("GuiderLayer")
        end
    end
end

local function isLoadingComplete()
    return m_rootLayer:isLoadingComplete();
end

local function loadScene(sceneID)
    CCLuaLog("begin load scene");
    m_sceneID = sceneID;
    if (m_rootLayer == nil) then
        m_rootLayer = SJArcScene:create();
        -- m_rootLayer:rotateScene(-20);
        local bg = CCSprite:create(PATH_RES_MAP .. "sky.png");
        bg:setPosition(ccp(SCREEN_WIDTH/2,SCREEN_HEIGHT/2));
        getGameLayer(SCENE_MAIN_LAYER):addChild(bg);
        getGameLayer(SCENE_MAIN_LAYER):addChild(m_rootLayer);
    end

    m_rootLayer:loadData(PATH_RES_SCENE .. "scene_" .. sceneID .. ".json");
    m_angleMax = m_rootLayer:getSceneLength();
end

local function loadEvent(sceneID)
    CCLuaLog("begin load event");
    initTriggers();
    EventManager.loadEventFile("event_" .. sceneID .. ".json");
    EventManager.convertEvent("WorldMap");
end

function create(callBack)
    CCLuaLog("begin create ui");
    m_callBack = callBack;
    -- WorldManager.registMessage();
    TouchDispatcher.init();
    m_sceneID = 0;
    local resList;
    local loadScene = {resType = LOADING_TYPE_SCENE, resData = {sceneID = m_sceneID, loader = loadScene, isEnd = isLoadingComplete}};
    local loadEvent = {resType = LOADING_TYPE_EVENT, resData = {eventID = m_sceneID, loader = loadEvent}};
    if(WorldManager.hasReceived() ~= true)then--已经有数据不用在请求了
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_STAGES_INFO_REQ,{});
        local loadData = {resType = LOADING_DATA_FROM_SERVER, resData = {isEnd = WorldManager.hasReceived}};
        resList = {loadData, loadScene, loadEvent};
    else
        resList = {loadScene, loadEvent};
    end
    -- resList = {loadScene, loadEvent};
    Loading.create(resList, onLoadingEnd);
end

local function touchBegan(x, y)
    m_curPoint.x = x;
    m_curPoint.y = y;
    m_rotateSpeed = 0;
    m_moveY = 0;
    m_moveX = 0;
    -- m_rootLayer:unscheduleUpdate();
end

local function touchMoved(x, y)
    if(SelectLevel.isOpen())then
        return;
    end
    m_drag = true;
    m_rootLayer:rotateScene(SCROLL_ANGLE_MAX * x);
    m_rotateSpeed = x;
    m_rotateTime = os.clock();
    m_moveY = m_moveY + y;
    m_moveX = m_moveX + x;
end

function touchEnded(x, y)
    -- if( m_curPoint.x ~= x or m_curPoint.y ~= y)then
    --     return;
    -- end
    m_rootLayer:onClick(x, y);
    if(SelectLevel.isOpen())then
        return;
    end
    if(m_drag)then
        m_drag = false;
        return;
    end
    local actorList = m_rootLayer:getSelectedActors();
    local cc = actorList:count();
    if(cc == 0)then
        return;
    end
        if(m_actorTriggers[actorList:objectAtIndex(0)] == nil)then
            return;
        end
       local data = m_actorTriggers[actorList:objectAtIndex(0)][EVENT_TRIGGER_TAP_ACTOR];
       if(data == nil or #data == 0)then
            return;
       end
       local temp = data[1].data;
       -- remove();
        local levelStr = Util.Split(temp[1],'_');
        local level = 1;
        if(levelStr[1] == "jvdian")then
            local index = tonumber(levelStr[2]);--据点编号
            if(index <= WorldManager.getCurJuDdianID() and WorldManager.getCurJuDdianID() > 0)then
                remove();
                GameManager.enterMainCityOther(4+index);
            end
        elseif(levelStr[1] == "zhucheng")then--去主城
            remove();
            GameManager.enterMainCityOther(3);
        elseif(levelStr[1] == "touch")then
            level = tonumber(levelStr[3]);--获取区域
            if(level > 10)then
                Util.showOperateResultPrompt("正在开发中...");
            else
                if(level <= WorldManager.getCUrOpenMap())then
                    WorldManager.setCurBattleMap(level);
                    SelectLevel.create(level);
                else
                    Util.showOperateResultPrompt("此区域未开启");
                end
            end
        end
end

function registerTouchFunction()
    if(not m_isRegister) then
        m_isRegister = true;
        TouchDispatcher.registerTouchFunction(TOUCH_EVENT_TYPE_BEGIN, touchBegan);
        TouchDispatcher.registerTouchFunction(TOUCH_EVENT_TYPE_MOVE, touchMoved);
        TouchDispatcher.registerTouchFunction(TOUCH_EVENT_TYPE_END, touchEnded);
    end
end

function unregisterTouchFunction()
    EventManager.free();
    if(m_isRegister) then
        m_isRegister = false;
        TouchDispatcher.unregisterTouchFunction(TOUCH_EVENT_TYPE_BEGIN, touchBegan);
        TouchDispatcher.unregisterTouchFunction(TOUCH_EVENT_TYPE_MOVE, touchMoved);
        TouchDispatcher.unregisterTouchFunction(TOUCH_EVENT_TYPE_END, touchEnded);
    end
end

function registerTriggerOnActor(trigger)
    local triggerType = trigger.type;
    local actorName = nil;
    local actor = nil;
    if (triggerType == EVENT_TRIGGER_TAP_ACTOR) then
        actorName = trigger.data[1];
        local pointTotalCount = trigger.data[2];
        actor = m_rootLayer:getActorByName(actorName);
        -- actor:setPointTotalCount(pointTotalCount);
        -- actor:setPointCount(0);
    else
        return;
    end
    
    if (actor) then
        table.insert(m_actorTriggers[actor][EVENT_TRIGGER_TAP_ACTOR], trigger);
    end
end
function open()

end

function remove()
    AudioEngine.stopMusic(true);
    m_drag = false;
    m_rootLayer:cleanup();
    m_rootLayer:removeAllChildrenWithCleanup(true);
    m_rootLayer:removeFromParentAndCleanup(true);
    m_rootLayer = nil;
    getGameLayer(SCENE_MAIN_LAYER):removeAllChildrenWithCleanup(true);
    unregisterTouchFunction();
    CCArmatureDataManager:purge();
    UIManager.close("WorldMapUI");
    ShopListPanel.close();
end


function renderMap()--根据当前开启进度刷新世界地图
    --所有区域块 
    local allNames = m_rootLayer:getAllActorNames();

    if (allNames) then
        local count = allNames:count();
        for i = 1, count do
            local name = tolua.cast(allNames:objectAtIndex(i - 1), "CCString"):getCString();
            local actor = m_rootLayer:getActorByName(name);
            local source = Util.Split(name,'_');
            if(source[1] == "judianname")then
                if(tonumber(source[2]) > WorldManager.getCurJuDdianID())then
                    actor:setVisible(false);
                end
            elseif(source[1] == "quyuname")then 
                if(tonumber(source[2]) > WorldManager.getCUrOpenMap())then
                    actor:setVisible(false);
                end
            end
        end
    --所有据点块
    end
end