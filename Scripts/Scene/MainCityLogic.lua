module("MainCityLogic", package.seeall)

require (PATH_SCRIPT_SCENE .. "MiniMap")
require (PATH_SCRIPT_SCENE .. "CityMap")
require (PATH_SCRIPT_SCENE .. "Guide")
require (PATH_SCRIPT_SCENE .. "Mission")
require (PATH_SCRIPT_SCENE .. "DialogTest")


local SCROLL_ANGLE_MAX = 90
local ROTATE_TO_ACTOR_SPEED = 0.2;
local ACTOR_RUN_SPEED       = 0.3;
local NEAR_LAYER_MOVE_SP = 0.22;
local DRAG_ANGLE = 15;
local m_rootLayer = nil;

local m_sceneID = 0;
local m_layerCount = 0;
local m_curLayer = 0;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_schedulerRun = nil;
local m_scheduleRunTo = nil;
local m_scheduleRunBy = nil;
local m_schedulerRunDrag = nil;
local m_angleMax = 0;
local m_rotateTime = 0;
local m_rotateSpeed = 0;
local m_moveY = 0;
local m_moveX = 0;
local m_selectedActor = nil;

local m_actorTriggers = nil;
local m_moveTriggers = nil;
local m_initTriggers = nil;
local m_startTriggers = nil;
local m_upGradeTriggers = nil;   --等级提升触发
local m_recvMisonTriggers = nil; --领取任务触发
local m_finshMisonTriggers = nil;--完成任务触发
local m_isRunToDoor = false;--是否正在向城门跑去 

local m_player = nil;
local m_bg = nil;

local m_loadingEndCB = nil;

--引导
local m_guideLayer = nil;
local m_status = nil;
local m_guideName = nil;
local m_guideEvent = nil;

local m_missionEvent = nil;

local m_playerRunEndCB = nil;
local m_switchInitAngle = 0;
local m_isPlayerRun = false;

local m_huntBossID = nil --点击的赏金BOSS的NPCid
local m_majorTaskNpcID = nil--点击的主线任务的NPC的ID

local m_isOpen = false;

local m_taskActor = nil
local m_isDrag = false;
local m_time = 0;
local m_curPoint = {};
local m_running = false;
local m_midLayer = nil;
local m_farLayer = nil;
local m_titleLayer = nil;
local m_curEvent = nil;
local m_touchOff_x = 0;
local m_touchOff_y = 0;
local m_runTimes = 0;
local m_runedTimes = 0;
local m_endX = 0;
function getCurSceneId()
    return m_sceneID;
end

local function returnFromUI()
    m_rootLayer:onEnter();
end

function openUI(uiType, pause)
    -- print("************* openUI uiType = " .. uiType);

    local canopen = false;
    --级别限制
    local item = DataTableManager.getItemByKey("ArchOpenLevel", "name", uiType);
    if(item) then
        local level = item.level;
        local roleLv = UserInfoManager.getRoleInfo("level");
        if(roleLv >= level) then
            canopen = true;
        else
            local text = item.desc .. level .. "级开放";
            Util.showOperateResultPrompt(text);
        end
    else
        canopen = true;
    end

    if(canopen) then
        UIManager.open(uiType);
        -- UIManager.setCloseCBFuc(returnFromUI);
        -- if (pause == true) then
        --     m_rootLayer:onExit();
        -- end
    end
end

function newUI(uiType)
    _G[uiType].open();
end

function enterShop( shopid )
    local shopType = {typeid = shopid};
    UIManager.open("Shop", shopType);
    UIManager.setCloseCBFuc(returnFromUI);
    if (pause == true) then
        m_rootLayer:onExit();
    end
end

local function playerStand()
    m_player:setAction("stand", 1);
    removeRunToScheduler();
    removeRunTimesScheduler();
    local function runEnd()
        m_isPlayerRun = false;
        if(UIManager.isOpen() == false) then
            registerTouchFunction();
        end

        if(m_playerRunEndCB) then
            m_playerRunEndCB();
            m_playerRunEndCB = nil;
        end
    end

    local actionArr = CCArray:create();
    actionArr:addObject(CCDelayTime:create(0.05));
    actionArr:addObject(CCCallFunc:create(runEnd));
    m_player:runAction(CCSequence:create(actionArr));
end

local function playerRun(angle, speed)
    --新手引导添加

    m_isPlayerRun = true;
    unregisterTouchFunction();
    local playerAngle = 5;
    -- if(angle )then

    -- end
    -- m_player:rotateInterval(angle, speed);
    m_player:setAction("run", 1);
    m_player:setFlipX(angle < 0);
    local actList = CCArray:create();
    local time = math.abs(angle / (speed * FPS));
    actList:addObject(CCDelayTime:create(time));
    actList:addObject(CCCallFunc:create(playerStand));
    m_runAction  = CCSequence:create(actList);
    m_player:runAction(m_runAction);
end

local function getNewGuideHideName(actor)
    local  nowActor = tolua.cast(actor, "SJActor");
    local newGuideNPC = {
                        ["castellan"] = true,
                        ["laopianzi"]= true,
                        ["beautyNPC"]= true,
                        ["blacksmithNPC"]= true,
                        }
    if newGuideNPC[nowActor:getKeyName()] then
        return false
    else
        return true
    end
end

local function selectedOneActor(actor,angle)

    --新手引导判断
    if TaskManager.getNewState()  then
        if getNewGuideHideName(actor) then
            return 
        end
    end
    local index = actor:getTag();
    if(index < -10)then
        CCLuaLog("click players");
        local data = MainCityPlayers.getPlayersInfo()[math.abs(index) - 10];
        -- UIManager.open("FriendsMain")
        local uid = data.uid;
        -- FriendsMain.checkDetailForRole(data.uid);

        -- FriendsManager.applyAddFriendBySearch(data.name,1);

        -- UIManager.open("Mail");
        -- Mail.openWriteMailOutSide(data.name);
        SelectActorDialog.open(data,m_touchOff_x,m_touchOff_y);
        if(angle ~= nil)then
            removeRunTimesScheduler();
            m_runTimes = math.abs(angle/NEAR_LAYER_MOVE_SP);
            m_scheduleRunBy = m_scheduler:scheduleScriptFunc(updateRunTimes, 0, false);    
            unregisterTouchFunction();
        end
        return true;
    end


    --主角移动到点击npc位置
    m_rootLayer:unscheduleUpdate();
    m_selectedActor = tolua.cast(actor, "SJActor");

    -- local angle = m_selectedActor:getRotation();
    -- if (angle ~= 0) then
    --     if (angle > 0) then
    --         m_rotateSpeed = -ROTATE_TO_ACTOR_SPEED;
    --     else
    --         m_rotateSpeed = ROTATE_TO_ACTOR_SPEED;
    --     end
    --     m_rootLayer:scheduleUpdateWithPriorityLua(MainCityLogic.rotateSceneToActor, 1);
    -- end
    -- local playerAngle = m_player:getRotation();
    -- playerRun(angle - playerAngle, 0.3);

    --满足点击次数
    actor:setPointCount(actor:getPointCount() + 1);
    if(actor:getPointCount() >= actor:getPointTotalCount()) then
        -- event
        if (m_actorTriggers == nil) then
            return;
        end
        if (m_actorTriggers[m_selectedActor]) then
            local name = m_selectedActor:getKeyName();
            local triggers = m_actorTriggers[m_selectedActor][EVENT_TRIGGER_TAP_ACTOR];
            for i, trigger in ipairs(triggers) do
                EventManager.activeEvent(trigger);
            end
        end
        actor:setPointCount(0);
    end
    return true;
end

function updatePlayerRun(dt)
    m_isRunToDoor = true;
    local farspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "farspeed");
    local midspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "midspeed");
    if(m_rootLayer:getCurAngle() < 0)then--右半屏
        if(m_player:getRotation() > -2)then
            m_player:setRotation(m_player:getRotation() - 0.1);
        end

        m_rootLayer:rotateScene(-NEAR_LAYER_MOVE_SP);
        local dfd = m_rootLayer:getCurAngle();
        local kkkjk = m_rootLayer:getSceneLength();
        if(m_rootLayer:getCurAngle() ~= m_rootLayer:getSceneLength())then
            m_midLayer:rotateScene(-tonumber(midspeed));
            m_farLayer:rotateScene(-tonumber(farspeed));
        end
    else
        if(m_player:getRotation() < 2)then
            m_player:setRotation(m_player:getRotation() + 0.1);
        end
        m_rootLayer:rotateScene(NEAR_LAYER_MOVE_SP);
        if(m_rootLayer:getCurAngle() ~= -m_rootLayer:getSceneLength())then
            m_midLayer:rotateScene(tonumber(midspeed));
            m_farLayer:rotateScene(tonumber(farspeed));
        end
    end
end

function runing()
    if(m_player == nil)then
        return;
    end
    if(not m_running)then
        m_running = true;
        m_player:setAction("run", 1);
    end
    local farspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "farspeed");
    local midspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "midspeed");
    m_player:setFlipX(m_curPoint.x < SCREEN_WIDTH_HALF);
    if(m_curPoint.x > SCREEN_WIDTH_HALF)then--右半屏
        if(m_player:getRotation() > -2)then
            m_player:setRotation(m_player:getRotation() - 0.1);
        end

        m_rootLayer:rotateScene(-NEAR_LAYER_MOVE_SP);
        local dfd = m_rootLayer:getCurAngle();
        local kkkjk = m_rootLayer:getSceneLength();
        if(m_rootLayer:getCurAngle() ~= m_rootLayer:getSceneLength())then
            m_midLayer:rotateScene(-tonumber(midspeed));
            m_farLayer:rotateScene(-tonumber(farspeed));
        end
    else
        if(m_player:getRotation() < 2)then
            m_player:setRotation(m_player:getRotation() + 0.1);
        end
        m_rootLayer:rotateScene(NEAR_LAYER_MOVE_SP);
        if(m_rootLayer:getCurAngle() ~= -m_rootLayer:getSceneLength())then
            m_midLayer:rotateScene(tonumber(midspeed));
            m_farLayer:rotateScene(tonumber(farspeed));
        end
    end
end

function removeRunDragSchduler()
    if(m_schedulerRunDrag ~= nil)then
        m_scheduler:unscheduleScriptEntry(m_schedulerRunDrag);
        m_schedulerRunDrag = nil;
    end
end

function teachDrag(angle)
    m_runTimes = math.abs(angle/NEAR_LAYER_MOVE_SP);
    m_schedulerRunDrag = m_scheduler:scheduleScriptFunc(updateTeachDragRun, 0, false);
    unregisterTouchFunction();
    -- UIManager.open("GuiderLayer")
end

function updateTeachDragRun()
    if(not m_running)then
        m_running = true;
        m_player:setAction("run", 1);
    end
    m_runedTimes = m_runedTimes + 1;
    local farspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "farspeed");
    local midspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "midspeed");
    m_player:setFlipX(true);
    if(m_player:getRotation() < 2)then
        m_player:setRotation(m_player:getRotation() + 0.1);
    end
    m_rootLayer:rotateScene(NEAR_LAYER_MOVE_SP);
    if(m_rootLayer:getCurAngle() ~= -m_rootLayer:getSceneLength())then
        m_midLayer:rotateScene(tonumber(midspeed));
        m_farLayer:rotateScene(tonumber(farspeed));
    end
    if(m_runedTimes >= m_runTimes)then
        m_scheduler:unscheduleScriptEntry(m_schedulerRunDrag);
        m_schedulerRunDrag = nil;
        m_runedTimes = 0;
        m_runTimes = 0;
        m_running = false;
        m_player:setAction("stand", 1);
        m_player:setRotation(0);
        registerTouchFunction();
        UIManager.open("GuiderLayer")
    end
end

function updateDragRun(dt)
    if(m_player == nil)then
        return;
    end
    if(not m_running)then
        m_running = true;
        m_player:setAction("run", 1);
    end
    m_runedTimes = m_runedTimes + 1;
    local farspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "farspeed");
    local midspeed = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "midspeed");

    m_player:setFlipX(m_endX - m_touchOff_x > 0);

    if(m_endX - m_touchOff_x < 0)then--右半屏
        if(m_player:getRotation() > -2)then
            m_player:setRotation(m_player:getRotation() - 0.1);
        end

        m_rootLayer:rotateScene(-NEAR_LAYER_MOVE_SP);
        local dfd = m_rootLayer:getCurAngle();
        local kkkjk = m_rootLayer:getSceneLength();
        if(m_rootLayer:getCurAngle() ~= m_rootLayer:getSceneLength())then
            m_midLayer:rotateScene(-tonumber(midspeed));
            m_farLayer:rotateScene(-tonumber(farspeed));
        end
    else
        if(m_player:getRotation() < 2)then
            m_player:setRotation(m_player:getRotation() + 0.1);
        end
        m_rootLayer:rotateScene(NEAR_LAYER_MOVE_SP);
        if(m_rootLayer:getCurAngle() ~= -m_rootLayer:getSceneLength())then
            m_midLayer:rotateScene(tonumber(midspeed));
            m_farLayer:rotateScene(tonumber(farspeed));
        end
    end
    if(m_runedTimes >= m_runTimes)then
        m_scheduler:unscheduleScriptEntry(m_schedulerRunDrag);
        m_runedTimes = 0;
        m_runTimes = 0;
        m_running = false;
        m_player:setAction("stand", 1);
        m_player:setRotation(0);
        registerTouchFunction();
    end
end


function updateCityRun(dt)
    if(GetCurSystemTime() - m_time < 300)then
        return;
    end
    runing();
end

function updateRunTimes(dt)
    m_runedTimes = m_runedTimes + 1;
    runing();
    if(m_runedTimes >= m_runTimes)then
         m_scheduler:unscheduleScriptEntry(m_scheduleRunBy);
         m_runedTimes = 0;
         m_runTimes = 0;
         m_running = false;
         m_player:setAction("stand", 1);
         m_player:setRotation(0);
         registerTouchFunction();
    end
end

function touchBegan(x, y)
    if m_rootLayer ~= nil then
        -- if(m_isRunToDoor)then
        --     removeRunToScheduler();
        --     m_playerRunEndCB = nil;
        --     m_curEvent.progress = #m_curEvent.action;
        --     m_curEvent.wait = 0;
        --     return;
        -- end
        removeRunScheduler();
        m_rotateSpeed = 0;
        m_moveY = 0;
        m_moveX = 0;
        m_touchOff_x = x;
        m_touchOff_y = y;
        m_curPoint = {x=x,y=y};
        m_time = GetCurSystemTime();
        m_schedulerRun = m_scheduler:scheduleScriptFunc(updateCityRun, 0, false);
        m_rootLayer:unscheduleUpdate();
        CCLuaLog("touchbegan");
    end
end

function touchMoved(x, y)
    if m_rootLayer ~= nil then
        
        m_curPoint.x = m_curPoint.x + x*SCREEN_WIDTH;
        -- m_player:setFlipX(x > 0);
        -- m_rootLayer:rotateScene(SCROLL_ANGLE_MAX * x);
        -- CCLuaLog("touchmoved");
        -- m_rotateSpeed = x;
        -- m_rotateTime = os.clock();
        m_moveY = m_moveY + y;
        m_moveX = m_moveX + x;
        -- event
        if (m_actorTriggers == nil or m_running) then
            return;
        end
        local curAngle = m_rootLayer:getCurAngle();
        EventManager.setVariableValue("cur_angle", curAngle);
        if (m_moveY > 0.05 or m_moveY < -0.05) then
            EventManager.setVariableValue("move_distance", m_moveY);
            -- print("***** m_moveY = " .. m_moveY);
            for i, trigger in ipairs(m_moveTriggers) do
                EventManager.activeEvent(trigger);
            end
        end
        if (m_moveX > 0.05) then
            EventManager.setVariableValue("move_distance", m_moveX);
            if (m_actorTriggers[m_player]) then
                local horMoveTriggers = m_actorTriggers[m_player][EVENT_TRIGGER_ENTER_RANGE];
                for i, trigger in ipairs(horMoveTriggers) do
                    EventManager.activeEvent(trigger);
                end
            end
        end
    end
end

function touchEnded(x, y)
    if m_rootLayer ~= nil then
        m_running = false;
        m_player:setAction("stand", 1);
        removeRunScheduler();
         m_player:setRotation(0);
        local time = GetCurSystemTime() - m_time;
        CCLuaLog("click time = " .. time);
        m_endX = x;
        if(time < 300)then
            local dis = (m_touchOff_x - x)*(m_touchOff_x - x) + (m_touchOff_y - y)*(m_touchOff_y - y);
            if(dis < 20*20) then 
                local angle =  m_rootLayer:onClick(x, y);
                local actorList = m_rootLayer:getSelectedActors();
                local count = actorList:count();
                if(count > 0) then
                    for i=1, count do
                        local isBreak = selectedOneActor(actorList:objectAtIndex(i - 1),angle);
                        if(isBreak)then
                            break;
                        end
                    end
                else
                    removeRunTimesScheduler();
                    m_runTimes = math.abs(angle/NEAR_LAYER_MOVE_SP);
                    m_scheduleRunBy = m_scheduler:scheduleScriptFunc(updateRunTimes, 0, false);    
                    unregisterTouchFunction();
                end
            else--滑动
                m_runTimes = math.abs(DRAG_ANGLE/NEAR_LAYER_MOVE_SP);
                m_schedulerRunDrag = m_scheduler:scheduleScriptFunc(updateDragRun, 0, false);
                unregisterTouchFunction();
            end

        end
    end
end

local function updateLogic(dt)
    if (m_rootLayer and m_player) then
        local angle = m_rootLayer:getCurAngle() + m_player:getRotation();
        -- MiniMap.setPosition(angle / (m_angleMax * 2));
        CityMap.setPositionX(angle / (m_angleMax * 2));
    end
end

local m_isRegister = false;

function registerTouchFunction()
        --print("********** 1 **********");
    
    if TaskManager.getNewState() then
        return 
    end


    if(not m_isRegister) then
        m_isRegister = true;
        TouchDispatcher.registerTouchFunction(TOUCH_EVENT_TYPE_BEGIN, touchBegan);
        TouchDispatcher.registerTouchFunction(TOUCH_EVENT_TYPE_MOVE, touchMoved);
        TouchDispatcher.registerTouchFunction(TOUCH_EVENT_TYPE_END, touchEnded);
    end
end

function unregisterTouchFunction()
       -- print("********** 0 **********");
    if(m_isRegister) then
        m_isRegister = false;
        TouchDispatcher.unregisterTouchFunction(TOUCH_EVENT_TYPE_BEGIN, touchBegan);
        TouchDispatcher.unregisterTouchFunction(TOUCH_EVENT_TYPE_MOVE, touchMoved);
        TouchDispatcher.unregisterTouchFunction(TOUCH_EVENT_TYPE_END, touchEnded);
    end
end

local function init()
    m_rotateTime = 0;
    m_rotateSpeed = 0;
    m_moveY = 0;
    m_moveX = 0;
    m_selectedActor = nil;
end

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
    m_actorTriggers[m_player] = {};
    for i = 1, EVENT_TRIGGER_TOTAL do
        m_actorTriggers[m_player][i] = {};
    end
    m_moveTriggers = {};
    m_initTriggers = {};
    m_startTriggers = {};
    m_upGradeTriggers = {};
    m_recvMisonTriggers = {};
    m_finshMisonTriggers = {};
end

local function loadScene(sceneID)
    m_sceneID = sceneID;
    if (m_rootLayer == nil) then
        m_rootLayer = SJArcScene:create();
        m_rootLayer:rotateScene(-20);
        getGameLayer(SCENE_MAIN_LAYER):addChild(m_rootLayer,1000);
    end
    if (m_player:getParent() == nil) then
        m_rootLayer:addActor(m_player, 10, -2);
        m_player:setRotation(0);
        m_player:setOrigAngle(0);
    end
    
    -- CCArmatureDataManager:purge();
    m_rootLayer:loadData(PATH_RES_SCENE .. "scene_" .. sceneID .. ".json");
    m_angleMax = m_rootLayer:getSceneLength();
end

local function loadMidScene(sceneID)
    if (m_midLayer == nil) then
        m_midLayer = SJArcScene:create();
        m_midLayer:rotateScene(-20);
        getGameLayer(SCENE_MAIN_LAYER):addChild(m_midLayer,2);
    end
    
    -- CCArmatureDataManager:purge();
    m_midLayer:loadData(PATH_RES_SCENE .. "scene_" .. sceneID .. ".json");
end

local function loadFarScene(sceneID)
    if (m_farLayer == nil) then
        m_farLayer = SJArcScene:create();
        m_farLayer:rotateScene(-20);
        getGameLayer(SCENE_MAIN_LAYER):addChild(m_farLayer,1);
    end
    
    -- CCArmatureDataManager:purge();
    m_farLayer:loadData(PATH_RES_SCENE .. "scene_" .. sceneID .. ".json");
end

local function loadEvent(sceneID)
    initTriggers();
    EventManager.loadEventFile("event_" .. sceneID .. ".json");
    EventManager.convertEvent("MainCityLogic");
end

local function loadPlayers(sceneID)
    MainCityPlayers.requestPlayerInfo(sceneID, m_rootLayer);
end

local function activeInitEvent()
    for i, trigger in ipairs(m_initTriggers) do
        EventManager.activeEvent(trigger);
    end
end

local function activeStartEvent()
    for i, trigger in ipairs(m_startTriggers) do
        EventManager.activeEvent(trigger);
    end
end

function activeUpGradeEvent()
    for i, trigger in ipairs(m_upGradeTriggers) do
        EventManager.activeEvent(trigger);
    end
end

function activeMissionRevEvent()
    for i, trigger in ipairs(m_recvMisonTriggers) do
        EventManager.activeEvent(trigger);
    end
end

function activeMissionFisEvent()
    for i, trigger in ipairs(m_finshMisonTriggers) do
        EventManager.activeEvent(trigger);
    end
end

local function isLoadingComplete()
    return m_rootLayer:isLoadingComplete();
end

local function midIsLoadingComplete()
    return m_midLayer:isLoadingComplete();
end

local function farIsLoadingComplete()
    return m_farLayer:isLoadingComplete();
end

local function clearCityName(object)
    tolua.cast(object, "CCSprite"):removeFromParentAndCleanup(true);
end

local function onLoadingEnd()
    Loading.remove();
    AudioEngine.setMusicVolume(1);
    if( not AudioEngine.isMusicPlaying())then
        AudioEngine.playMusic(PATH_RES_AUDIO .. DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. m_sceneID, "music") .. ".mp3", true);
    end
    
    registerTouchFunction();
    Mission.registerMissionMsg();
    MainCityActorAI.init();
    init();
    loadPlayers(m_sceneID);
    MainCityActorAI.runAI();
    if(m_loadingEndCB) then
        m_loadingEndCB();
    end
    CityMap.setPositionY(m_curLayer / (m_layerCount + 1));

    --初始角度
    m_rootLayer:rotateScene(-m_switchInitAngle);
    m_player:setRotation(m_switchInitAngle/100);
    m_switchInitAngle = 0;
    -- event
    activeStartEvent();
    if(m_titleLayer == nil)then
        m_titleLayer = CCLayer:create();
        getGameLayer(SCENE_MAIN_LAYER):addChild(m_titleLayer,10000);
    end
    local titlebg = CCSprite:create(PATH_RES_IMAGE .. "zhucheng_qieceng_kuang.png");
    local titlename = CCSprite:create(PATH_RES_IMAGE .. "zhucheng_qieceng_" .. m_sceneID .. ".png");
    if(titlename ~= nil)then
        titlebg:setPositionY(SCREEN_HEIGHT_HALF+200);
        titlebg:setPositionX(SCREEN_WIDTH_HALF);
        titlename:setPosition(ccp(titlebg:getContentSize().width/2,titlebg:getContentSize().height/2-20));
        titlebg:addChild(titlename);
        m_titleLayer:addChild(titlebg,1000);
        local actList = CCArray:create();
        actList:addObject(CCDelayTime:create(3));
        actList:addObject(CCFadeOut:create(2));
        actList:addObject(CCCallFuncN:create(clearCityName));

        local actList1 = CCArray:create();
        actList1:addObject(CCDelayTime:create(3));
        actList1:addObject(CCFadeOut:create(2));
        titlebg:runAction(CCSequence:create(actList));
        titlename:runAction(CCSequence:create(actList1));
    end
    -- 临时给npc加名字
   --  local npcNameDatas = DataTableManager.getItemsByKey("npcName", "sceneid", m_sceneID);
   -- for i,v in ipairs(npcNameDatas) do
   --      local npcActor = m_rootLayer:getActorByName(v.npc);
   --      if(npcActor) then
   --          npcActor:setDialog(v.name);
   --      end
   -- end
   m_taskActor = nil
   setMajorTaskStatus()
end

function switchLayer(sceneID, initAngle, removeOld, endCB)
print("switchLayer(sceneID, initAngle, removeOld, endCB)"..sceneID)
-- AudioEngine.playEffect(PATH_RES_ROOT .. "music.mp3", true);
    if(m_player ~= nil)then
        m_player:setAction("stand", 1);
    end
    -----


    ------
    m_time = 0;
    m_switchInitAngle = 0;
    if(initAngle) then
        m_switchInitAngle = initAngle;
    end
    m_isOpen  = true;
    MainCityActorAI.stopAI();
    if (removeOld == true) then
        if(m_titleLayer ~= nil)then
            m_titleLayer:removeAllChildrenWithCleanup(true);
        end
        removeRunScheduler();
        removeRunToScheduler();
        removeRunDragSchduler();
        m_rootLayer:cleanup();
        m_player:removeFromParentAndCleanup(false);
        m_rootLayer:removeAllChildrenWithCleanup(true);
        CCArmatureDataManager:purge();
        m_rootLayer:removeFromParentAndCleanup(true);
        m_midLayer:removeAllChildrenWithCleanup(true);
        m_farLayer:removeAllChildrenWithCleanup(true);
        m_farLayer:removeFromParentAndCleanup(true);
        m_midLayer:removeFromParentAndCleanup(true);
        m_rootLayer = nil;
        m_farLayer = nil;
        m_midLayer = nil;
        MainCityPlayers.removePlayers();
    end
    m_loadingEndCB = nil;
    if(endCB) then
        m_loadingEndCB = endCB;
    end
    unregisterTouchFunction();
    EventManager.free();
    MainCityActorAI.free();

    -- MiniMap.setMapImage(sceneID);
    -- MiniMap.setPosition(0.5, true);
    m_curLayer = 1;
    -- sceneID = 3;
    local farID = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. sceneID, "farid");
    local midID = DataBaseManager.getValue("MainCityScene", DATABASE_HEAD .. sceneID, "midid");
    local loadSceneFar = {resType = LOADING_TYPE_SCENE, resData = {sceneID = farID, loader = loadFarScene, isEnd = farIsLoadingComplete}};
    local loadSceneMid = {resType = LOADING_TYPE_SCENE, resData = {sceneID = midID, loader = loadMidScene, isEnd = midIsLoadingComplete}};

    local loadScene = {resType = LOADING_TYPE_SCENE, resData = {sceneID = sceneID, loader = loadScene, isEnd = isLoadingComplete}};
    local loadEvent = {resType = LOADING_TYPE_EVENT, resData = {eventID = sceneID, loader = loadEvent}};
    -- local loadPlayers = {resType = LOADING_TYPE_PLAYERS, resData = {sceneID = sceneID, loader = loadPlayers, isEnd = MainCityPlayers.isComplete}};
    local initEvent = {resType = LOADING_TYPE_INIT_EVENT, resData = {loader = activeInitEvent}};
    local resList = {loadSceneFar,loadSceneMid,loadScene, loadEvent, initEvent};
    Loading.create(resList, onLoadingEnd);

end

function enterWorldMap( sceneID, initAngle )
    removeMainCity();
    WorldMap.create();
end

function create()
    local mainLayer = getGameLayer(SCENE_MAIN_LAYER);
    m_rootLayer = SJArcScene:create();
    mainLayer:addChild(m_rootLayer,3);

    -- m_guideLayer = GuideLayer:create("G_Bulletin", 30);
    -- m_guideLayer:retain();

    m_angleMax = 0;
    m_layerCount = 1;
    m_player = PlayerActor.getSceneActor();
    m_player:setRotation(0);

    -- local map = MiniMap.create();
    -- mainLayer:addChild(map, 100);
    -- map:setPosition(CCPoint(SCREEN_WIDTH, SCREEN_HEIGHT));

    local mapBig = CityMap.create();
    mainLayer:addChild(mapBig, 101);
    mapBig:setPosition(CCPoint(SCREEN_WIDTH_HALF, SCREEN_HEIGHT_HALF));
    CityMap.close();

    registerTouchFunction();

    init();


end

function removeRunToScheduler()
    if(m_scheduleRunTo ~= nil)then
        m_scheduler:unscheduleScriptEntry(m_scheduleRunTo);
        m_scheduleRunTo = nil;
        m_isRunToDoor = false;
        -- m_curEvent.progress = #m_curEvent.action;
    end
end

function removeRunScheduler()
    if(m_schedulerRun ~= nil)then
        m_scheduler:unscheduleScriptEntry(m_schedulerRun);
        m_schedulerRun = nil;
    end
end

function removeRunTimesScheduler()
    if(m_scheduleRunBy ~= nil)then
        m_scheduler:unscheduleScriptEntry(m_scheduleRunBy);
        m_scheduleRunBy = nil;
    end
end

function remove()
    if (m_player) then
        m_player:removeFromParentAndCleanup(true);
        m_player = nil;
    end
    if (m_bg) then
        m_bg:removeFromParentAndCleanup(true);
        m_bg = nil;
    end
    m_rootLayer:cleanup();
    m_rootLayer:removeAllChildrenWithCleanup(true);
    m_rootLayer:removeFromParentAndCleanup(true);
    unregisterTouchFunction();
    Mission.unregisterMissionMsg();
    CCArmatureDataManager:purge();
    m_loadingEndCB = nil;
end

function EnterCity(sceneID, loadingEndCB, initAngle)
    m_bg = CCSprite:create(PATH_RES_IMAGE .. "sky.png");
    m_bg:setAnchorPoint(CCPoint(0, 0));
    m_status = MAINCITY_NORMAL;
    getGameLayer(SCENE_MAIN_LAYER):addChild(m_bg, -1);
    -- MainCityPlayers.registerMessageFunction();
    switchLayer(sceneID, initAngle);
    m_loadingEndCB = loadingEndCB;
    if (m_player) then
        m_rootLayer:addActor(m_player, 100, -2);
    end
    m_schedulerEntry = m_scheduler:scheduleScriptFunc(updateLogic, 0, false);
end

function ExitCity()
    m_rootLayer:removeActor(-2);
    -- MainCityPlayers.unregisterMessageFunction();
    m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
end

function updateSpeed(time)
    if (m_rotateSpeed > 0) then
        m_rotateSpeed = math.max(m_rotateSpeed - 0.0025);
        m_rootLayer:rotateScene(SCROLL_ANGLE_MAX * m_rotateSpeed);
    elseif (m_rotateSpeed < 0) then
        m_rotateSpeed = math.min(m_rotateSpeed + 0.0025, 0);
        m_rootLayer:rotateScene(SCROLL_ANGLE_MAX * m_rotateSpeed);
    else
        m_rootLayer:unscheduleUpdate();
    end
end

function rotateSceneToActor(time)
    local angle = m_selectedActor:getRotation();
    if (((m_rotateSpeed > 0) and (angle + m_rotateSpeed >= 0)) or ((m_rotateSpeed < 0) and (angle + m_rotateSpeed <= 0))) then
        m_rotateSpeed = -angle;
        m_rootLayer:unscheduleUpdate();
    end
    m_rootLayer:rotateScene(m_rotateSpeed);
end

function reloadEnd()
    m_player = PlayerActor.getSceneActor();
    m_player:setRotation(0);
    m_player:setRotation(m_switchInitAngle/100);
    if (m_player) then
        m_rootLayer:addActor(m_player, 100, -2);
    end
end

function reloadPlayer()
    local nowCoat = UserInfoManager.getRoleInfo("coat").type;
    if(nowCoat and nowCoat > 0) then
        if (m_player) then
            m_player:removeFromParentAndCleanup(true);
            m_player = nil;
        end
        PlayerActor.removePlayerActor();
        PlayerActor.initPlayerActor(reloadEnd);
    end
end

function moveActor(actorName, angle, speed, isWaitFinish, event)
    -- return;
    local curAngle = m_rootLayer:getCurAngle();
    angle = angle - curAngle;

    local function moveEnd()
        if(event) then
            event.wait = 0;
        end
    end

    local actor = nil;
    if(actorName == "self") then
        actor = m_player;
    else
        actor = m_rootLayer:getActorByName(actorName);
    end
    if (actor) then
        if (angle ~= 0) then
            if(m_schedulerRun ~= nil)then
                m_scheduler:unscheduleScriptEntry(m_schedulerRun);
                m_schedulerRun = nil;
            end
            actor:setFlipX(angle < 0);
            if(actorName == "self") then
                m_playerRunEndCB = moveEnd;
                playerRun(angle, NEAR_LAYER_MOVE_SP);
            else
                actor:rotateInterval(angle, ROTATE_TO_ACTOR_SPEED);
            end
            --旋转场景
            -- m_rootLayer:rotateSceneInterval(-angle, ROTATE_TO_ACTOR_SPEED);
            removeRunScheduler();
            m_curEvent = event;
            m_scheduleRunTo = m_scheduler:scheduleScriptFunc(updatePlayerRun, 0, false);
        end
    end
    if(event) then
        if(isWaitFinish == 1) then
            event.wait = -1;
        else
            event.wait = 0;
        end
    end
end


--新手引导移动player
function moveActorByNewGuide(actorName, angle, speed, callBack)
    if callBack == nil then 
        callBack = function () end
    end
                
    local curAngle = m_rootLayer:getCurAngle();
    angle = angle - curAngle;

    local actor = nil;
    if(actorName == "self") then
        actor = m_player;
    else
        actor = m_rootLayer:getActorByName(actorName);
    end
    if (actor) then
        if (angle ~= 0) then
            actor:setFlipX(angle < 0);
            if(actorName == "self") then
                m_playerRunEndCB = callBack;
                playerRun(angle, ROTATE_TO_ACTOR_SPEED);
            else
                actor:rotateInterval(angle, ROTATE_TO_ACTOR_SPEED);
            end
            --旋转场景
            m_rootLayer:rotateSceneInterval(-angle, ROTATE_TO_ACTOR_SPEED);
        end
    end

end
-- 协议函数，所有用到事件的模块都要实现

function registerTriggerOnActor(trigger)
    local triggerType = trigger.type;
    local actorName = nil;
    local actor = nil;
    if (triggerType == EVENT_TRIGGER_TAP_ACTOR) then
        actorName = trigger.data[1];
        local pointTotalCount = trigger.data[2];
        if(actorName == "self") then
            actor = m_player;
        else
            actor = m_rootLayer:getActorByName(actorName);
        end
        CCLuaLog(actorName);
        actor:setPointTotalCount(pointTotalCount);
        actor:setPointCount(0);
    elseif (triggerType == EVENT_TRIGGER_ENTER_RANGE) then
        actor = m_player;
    else
        return;
    end
    
    if (actor) then
        table.insert(m_actorTriggers[actor][triggerType], trigger);
    end
end

function registerTriggerOnMove(trigger)
    table.insert(m_moveTriggers, trigger);
end

function registerTriggerOnInit(trigger)
    table.insert(m_initTriggers, trigger);
end

function registerTriggerOnStart(trigger)
    table.insert(m_startTriggers, trigger);
end

function registerTriggerOnGradeUp( trigger )
    table.insert(m_upGradeTriggers, trigger);
end

function registerTriggerOnMissionReceive( trigger )
    table.insert(m_recvMisonTriggers, trigger);
end

function registerTriggerOnMissionFinished( trigger )
    table.insert(m_finshMisonTriggers, trigger);
end

function getRootLayer()
    return m_rootLayer;
end

local function removeUI()
    getGameLayer(SCENE_UI_LAYER):removeAllChildrenWithCleanup(true);
    getGameLayer(SCENE_MAIN_LAYER):removeAllChildrenWithCleanup(true);
end

function removeMainCity()
    -- AudioEngine.stopMusic(true);
    UIManager.close("MainCityUI");
    UIManager.setOpen(false);
    MainCityLogic.ExitCity();
    PlayerActor.freeModules();
    EventManager.free();
    if (m_bg) then
        m_bg:removeFromParentAndCleanup(true);
        m_bg = nil;
    end
    MainCityActorAI.stopAI();
    m_isOpen = false;
    removeRunScheduler();
    removeRunToScheduler();
    removeRunTimesScheduler();
    removeRunDragSchduler();
    m_titleLayer:removeAllChildrenWithCleanup(true);
    m_titleLayer:removeFromParentAndCleanup(true);
    m_titleLayer = nil;
    m_rootLayer:cleanup();
    m_player:removeFromParentAndCleanup(false);
    m_rootLayer:removeAllChildrenWithCleanup(true);
    CCArmatureDataManager:purge();
    m_rootLayer:removeFromParentAndCleanup(true);
    m_midLayer:removeAllChildrenWithCleanup(true);
    m_farLayer:removeAllChildrenWithCleanup(true);
    m_farLayer:removeFromParentAndCleanup(true);
    m_midLayer:removeFromParentAndCleanup(true);
    m_rootLayer = nil;
    m_farLayer = nil;
    m_midLayer = nil;
    MainCityPlayers.removePlayers();
    -- MainCityActorAI.free();
    CCTextureCache:sharedTextureCache():removeUnusedTextures();
    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames();
end

function enterBattle(battleType, subType, id)
    -- removeMainCity();
    
    -- BattleManager.init();
    BattleManager.enterBattle(battleType, subType, id,removeMainCity);
end

function enterBattleRecord(battType,battleSubType,battID)
    -- removeMainCity();
    BattleManager.enterBattleRecord(battType,battleSubType,battID);
end

--引导
function clearGuide()
    m_guideEvent.wait = 0;
    m_guideEvent = nil;
end

function exeGuide( x, y, w, h, event )
    Guide.showGuide(x, y, w, h, clearGuide);

    event.wait = -1;
    m_guideEvent = event;
end

function getGuideLayer()
    return m_guideLayer;
end

function setGuideLayer(layer)
    m_guideLayer = layer;
end


--任务
function setMission(npcName, missionId, missionType)
    --为某个npc绑定一个任务，发送到服务器
    -- NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_SETMISSION, {m_sceneID, npcName, missionId, missionType});
end

function clearMission()
    m_missionEvent.wait = 0;
    m_missionEvent = nil;
end

function showMission(npcName, event)
    --根据npc名字请求服务器得到绑定的任务id和任务类型，进行显示
    Mission.showMission(npcName, clearMission);
    event.wait = -1;
    m_missionEvent = event;
end

function missionDialog( data )
        --任务对话框
    -- DialogTest.create(data)
    -- DialogTest.open()
end
function recieveDataOnHunter(messageData)
    -- --1,不可接取，2，可以接但未接，3，接任务未完成，4，接任务已完成未领奖励，5接任务已完成领取奖励
    local current_Task = tonumber(messageData["task_id"])
    local current_Task_Status = messageData["status"]
    local current_Task_Num = messageData["num"]

    local bossId = DataTableManager.getValue("RewardDialog", current_Task.."_index", "bossid")
    if(bossId==m_huntBossID) then        
        if(current_Task_Status==3) then
            messageData["npcID"] = m_huntBossID
            UIManager.open("DialogView",messageData)
            m_huntBossID = nil
        end
    end
end

function onMajorTaskHandler(messageData)
    -- --1,不可接取，2，可以接但未接，3，接任务未完成，4，接任务已完成未领奖励，5接任务已完成领取奖励
    local current_Task = tonumber(messageData["task_id"])
    local current_Task_Status = messageData["status"]
    local current_Task_Num = messageData["num"]

    local npcID = DataTableManager.getValue("MajorTaskDialog", current_Task.."_index", "NpcID")
    if 4 == current_Task_Status then
        current_Task = current_Task+1
        npcID = DataTableManager.getValue("MajorTaskDialog", current_Task.."_index", "NpcID")
        messageData["task_id"]= current_Task
    end
    
    if(npcID==m_majorTaskNpcID) then        
        if(current_Task_Status==2 or current_Task_Status==4) then
            messageData["npcID"] = m_majorTaskNpcID
            UIManager.open("DialogView",messageData)
            m_majorTaskNpcID = nil
        end
    else
      
    end
end
function sendNPCID(dataWithNPC)
    local npcID     = dataWithNPC[1];
    local UIname    = dataWithNPC[2];
    local bPassGame = dataWithNPC[3];
    --赏金猎人
    if(npcID ==710001) then
        UIManager.open("HuntUI")   
    elseif(math.modf(npcID/1000) == 327) then
        m_huntBossID = npcID
        NpcInfoManager.getHuntTaskInfo(710001,recieveDataOnHunter)
    elseif(math.modf(npcID/1000) == 320) then

        local taskNpcid = NpcInfoManager.getMajorTaskNpcID()
        if taskNpcid~= npcID then 
            UIManager.open("NpcWordsUI",npcID)
        else
            m_majorTaskNpcID = npcID
            NpcInfoManager.getMajorTaskInfo(m_majorTaskNpcID,onMajorTaskHandler)            
        end
    end
end

function checkLayerStatus()
    if m_rootlayer ~= nil then
        return true
    else
        return false
    end
end
function isOpen()
    return m_isOpen;
end
function setNpcId(npcID)
    m_majorTaskNpcID = npcID
end

--设置任务状态信息
function setMajorTaskStatus()
    if m_isOpen== false then 
        return 
    end
    if m_taskActor ~= nil then
        m_taskActor:setEmotion("",1)
        m_taskActor = nil 
    end  
        --任务动画
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_ACTORS.."tanhao.ExportJson");
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_ACTORS.."wenhao.ExportJson");
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_ACTORS.."wenhao2.ExportJson");
    --获取任务信息
    local taskData = NpcInfoManager.getMajorTaskData()
    local current_Task = tonumber(taskData["task_id"])
    local current_Task_Status = taskData["status"]
    local npcID
    if current_Task_Status == 2 then
        npcID = DataTableManager.getValue("MajorTaskDialog", current_Task.."_index", "NpcID")
    elseif current_Task_Status == 3   then 
        npcID = DataTableManager.getValue("MajorTaskDialog", (current_Task+1).."_index", "NpcID")
    elseif current_Task_Status == 4  then 
        npcID = DataTableManager.getValue("MajorTaskDialog", (current_Task+1).."_index", "NpcID")
    end

    local npcDatas = DataTableManager.getItemsByKey("npcName", "sceneid", m_sceneID);
    
    for k,npcItem in pairs(npcDatas) do
        if npcID == npcItem.npcId then  
            m_taskActor = m_rootLayer:getActorByName(npcItem.npc);
        else
        end
    end
    if m_taskActor ~= nil then
        if current_Task_Status == 2 then
            m_taskActor:setEmotion("tanhao",1)
        elseif current_Task_Status == 3   then
            local taskType = DataTableManager.getValue("MajorTaskDialog", current_Task.."_index", "type")
            if taskType ~= 1 then 
                m_taskActor:setEmotion("wenhao2",1)
            else
                m_taskActor:setEmotion("wenhao",1)
            end
        elseif current_Task_Status == 4  then 
            m_taskActor:setEmotion("wenhao",1)
        end
    end

end

function getSceneID()
    return m_sceneID
end