module("Loading", package.seeall)

local LOADING_STATE_STOP = 0
local LOADING_STATE_UPDATE = 1
local LOADING_STATE_WAIT = 2

local m_loadingState = LOADING_STATE_STOP;

local m_curStep = 1;
local m_stepMax = 1;
local m_resList = nil;

local m_callbackFun = nil;
local m_conditionFun = nil;

local BG_PATH = PATH_RES_IMAGE .. "loading_bg.png"
local m_animationLodingPath = PATH_RES_ACTORS .."Loading_actor_17.ExportJson"
local m_armature = nil;
local m_rootLayer = nil;
local m_isAdd = false;

local function free()
    if(m_isAdd) then
        m_isAdd = false;
        m_armature:getAnimation():pause();
        m_rootLayer:removeFromParentAndCleanup(false);
    end
end

local function loadScene(resData)
    local sceneID = resData.sceneID;
    local loader = resData.loader;
    m_conditionFun = resData.isEnd;
    m_loadingState = LOADING_STATE_WAIT;
    loader(sceneID);
end

local function loadEvent(resData)
    local eventID = resData.eventID;
    local loader = resData.loader;
    loader(eventID);
end

local function eventInitial(resData)
    local loader = resData.loader;
    loader();
end

local function loadModule(resData)
    local loader = resData.loader;
    loader();
end

local function loadPlayers(resData)
    local loader = resData.loader;
    m_conditionFun = resData.isEnd;
    loader();
end

local function loadBattle(resData)
    local loader = resData.loader;
    loader(resData);
end

local function loadBattleAsync(resData)
    local loader = resData.loader;
    loader(resData);
    m_conditionFun = resData.isEnd;
    m_loadingState = LOADING_STATE_WAIT;
end

local function onlyWait(resData)
    m_conditionFun = resData.isEnd;
    m_loadingState = LOADING_STATE_WAIT;
end

local function loadMapAmature(resData)
    local loader = resData.loader;
    loader(resData);
    m_conditionFun = resData.isEnd;
    m_loadingState = LOADING_STATE_WAIT;
end

local function loadMapScene(resData)
    local loader = resData.loader;
    loader(resData);
end

local function update()
    if (m_loadingState == LOADING_STATE_UPDATE) then
        if (m_curStep > m_stepMax) then
            Loading.stop();
            m_callbackFun();
            return;
        end
        
        local resType = m_resList[m_curStep].resType;
        local resData = m_resList[m_curStep].resData;

        if (resType == LOADING_TYPE_SCENE) then
            loadScene(resData);
        elseif (resType == LOADING_TYPE_EVENT) then
            loadEvent(resData);
        elseif (resType == LOADING_TYPE_INIT_EVENT) then
            eventInitial(resData);
        elseif (resType == LOADING_TYPE_MODULE) then
            loadModule(resData);
        elseif (resType == LOADING_TYPE_PLAYERS) then
            loadPlayers(resData);
        elseif(resType == LOADING_TYPE_BATTLE) then
            loadBattle(resData);
        elseif(resType == LOADING_TYPE_BATTLE_ASYNC) then
            loadBattleAsync(resData);
        elseif(resType == LOADING_DATA_FROM_SERVER) then
            onlyWait(resData);
        elseif(resType == LOADING_DATA_MAP_AMATURE)then
            loadMapAmature(resData);
        elseif(resType == LOADING_DATA_MAP_DATA)then
            loadMapScene(resData);
        end

        m_curStep = m_curStep + 1;
    else
        if (m_conditionFun() == true) then
            m_conditionFun = nil;
            m_loadingState = LOADING_STATE_UPDATE;
        end
    end
end

function start()
    m_loadingState = LOADING_STATE_UPDATE;
    local layer = getGameLayer(SCENE_LOADING_LAYER);
    layer:scheduleUpdateWithPriorityLua(update, 1);
end

function stop()
    m_loadingState = LOADING_STATE_STOP;
    local layer = getGameLayer(SCENE_LOADING_LAYER);
    layer:unscheduleUpdate();
    m_resList = nil;
end

local function createBackground()
    -- local bg = CCSprite:create(BG_PATH);
    -- bg:setAnchorPoint(CCPoint(0, 0));
    -- bg:setPosition(ccp(0,0));
    -- getGameLayer(SCENE_LOADING_LAYER):addChild(bg);

    -- local label = Label:create();
    -- label:setText("Loading····");
    -- label:setFontSize(30);
    -- label:setColor(ccc3(224, 199, 45));
    -- label:setPosition(ccp(SCREEN_WIDTH_HALF, 120));
    -- getGameLayer(SCENE_LOADING_LAYER):addChild(label);
    if(not m_isAdd) then
        m_isAdd = true;
        getGameLayer(SCENE_LOADING_LAYER):addChild(m_rootLayer);
        m_armature:getAnimation():resume();
    end
end

--创建动画，长驻内存
function init()
    m_rootLayer = CCLayerColor:create(ccc4(0,0,0,255));
    m_rootLayer:retain();

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationLodingPath);
    m_armature = CCArmature:create("Loading_actor_17");
    m_armature:setScale(0.8)
    m_armature:getAnimation():playWithIndex(0);
    m_armature:setPosition(ccp(578,250));
    -- m_armature:getAnimation():setAnimationScale(2)
    m_armature:retain();
    m_armature:getAnimation():pause();
    CCArmatureDataManager:purge();

    m_rootLayer:addChild(m_armature);
end

function create(resList, cbFun,isDisplay)
    m_stepMax = #resList;
    m_resList = resList;
    m_curStep = 1;
    m_callbackFun = cbFun;
    if(isDisplay ~= true)then
        createBackground();
    end
    
    start();
end

function remove()
    m_curStep = 1;
    m_stepMax = 1;
    m_resList = nil;
    m_callbackFun = nil;
    free();
end