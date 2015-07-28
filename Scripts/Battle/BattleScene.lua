module("BattleScene", package.seeall)

require (PATH_SCRIPT_BATTLE .. "BattleActor")
require (PATH_SCRIPT_BATTLE .. "BattleUI")



local BATTLE_TAG_SCENE  = 10001;
local BATTLE_TAG_UI     = 10002;
local BATTLE_TAG_PLAYER = 1;
local BATTLE_TAG_ENEMY  = 2;

local ATTACK_DISTANCE   = 50;
local COLOR_LAYER_Z     = 4;

local AMOUNT_FRAME_HAIR_FRONT   = 1;
local AMOUNT_FRAME_HAIR_BACK    = 1;
local AMOUNT_FRAME_FACE         = 1;
local AMOUNT_FRAME_EYEBROWS     = 1;
local AMOUNT_FRAME_EYES         = 1;
local AMOUNT_FRAME_MOUTH        = 1;

local SKILL_LABEL_OFFSET_Y = 300;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_schedulerShadow = nil;

local m_lockCameraScale = false;
local m_lockCameraPos = false;

local m_rootNode    = nil;
local m_sceneNode   = nil;
local m_colorNode   = nil;
local m_uiNode      = nil;
local m_playerNode  = nil;
local m_enemyNode   = nil;
local bg = nil;
local m_nearScene1  = nil;
local m_nearScene2  = nil;
local m_farScene1   = nil;
local m_farScene2   = nil;
local m_farScene3 = nil;
local m_farScene4 = nil;
local m_animList    = nil;
local m_animListCopy = nil;

--local m_bg1 = nil;
--local m_bg2 = nil;
--local m_bg3 = nil;
--local m_scene_width = nil;
local m_bg_width = nil;
local m_nearScene_width = nil;
local m_farScene_width = nil;
local m_farScene_width1 = nil;
local m_farScene_width2 = nil;

local m_playerData = nil;
local m_enemyData = nil;

local m_defaultDistance = 0;
local m_lastDistance    = 0;
local m_defaultHeight   = 0;

local m_scenePosY = 0;

local m_isloadModuleEnd = false;

local m_movieCallBack = nil;
local m_attackCallback = nil;

local m_isPlayAttackAnim = false;

local m_buffAnimData = nil;
local m_effectRemovePool = nil;

local m_scaleCount = 1;

local m_count = 0;

local m_sceneName = nil;
local m_actorCount = 0;
local m_sceneAniName = {};
local m_battleState = BATTLE_STATE_NONE;

local m_intervalCallFun = nil;
local m_intervalTicker = 0;
local m_displayStepPlayer = 0;--开场播放人物技能步骤
local m_displayStepEnemy = 0;
local m_playerDisArray = {};
local m_dataMap = {};
local m_winSize = nil;
local m_round = 0;

local m_atkBufRemList = nil;--人物清除buff使用
local m_defBufRemList = nil;
local m_attacker = 0;
local m_scaleTicker = -1;
local m_scaleAverage = 0;
local m_scaleDuration = 0;

local m_battleIsEnd = false;
local m_isAttackerDead = false;
local m_loadAniList = {};
local m_battleEnd = false;
local m_farHeight = 0;
local m_farHeight1 = 0;
local m_playerShadow = nil;
local m_enemyShadow = nil;
local m_loadActorAnimComplete = false;
local m_typeData = nil;
local m_debugMode = false;
local m_scaleLabel = nil;
local m_monsterSkinList = nil;
local m_effectReference = nil;

local m_rootLayer = nil;
local faceMap = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true};
local m_partCount = {
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1,
        weapon = 1, hair_other1 = 1, hair_other2 = 1, hair_other3 = 1, hair_other4 = 1, hair_other5 = 1, hair_other6 = 1, hair_other7 = 1, hair_other8 = 1, hair_other9 = 1, hair_other10 = 1}
};

function getPlayerPosX()
    return m_playerNode:getPositionX();
end

function getEnemyPosX()
    return m_enemyNode:getPositionX();
end

function getPlayerBonePosX()
    return m_playerNode:getBonePosX("face_0");
end

function getEnemyBonePosX()
    return m_enemyNode:getBonePosX("face_0");
end

function getHurtDistanceP()
    local distance = m_playerNode:getBonePosX("hand_back_1") - m_enemyNode:getBonePosX("body_0");
    return math.abs(distance);
end 

function getHurtDistanceE()
    local distance = m_enemyNode:getBonePosX("hand_back_1") - m_playerNode:getBonePosX("body_0");
    return math.abs(distance);
end    

function getWorldPosition(actor)
--  return m_rootNode:convertToWorldSpace(CCPoint(actor:getPositionX(), actor:getPositionY()));--by han
    return CCPoint(actor:getPositionX(),actor:getPositionY());--by han

end

function getWorldDistance()
    local distance = getWorldPosition(m_playerNode).x - getWorldPosition(m_enemyNode).x;
    return math.abs(distance);
end

function setLoadAniList(list)
    m_loadAniList = list;
end

local function getNodeDistance()
    local distance = m_playerNode:getPositionX() - m_enemyNode:getPositionX();
    return math.abs(distance);
end 

local function getWorldPositionByNodePosition(point)
    -- body
    -- return m_rootNode:convertToWorldSpace(ccp(point.x,point.y)); --by han
     return ccp(point.x,point.y); --by han
end 

--两个人在实际坐标下坐标
local function getWorldPositionByTwo()
    -- body
    local nodePosition = CCPointMake((m_playerNode:getPositionX() + m_enemyNode:getPositionX())/2,(m_playerNode:getPositionY() + m_enemyNode:getPositionY())/2);
    local n1 = m_playerNode:getPositionX();
    local n2 = m_enemyNode:getPositionX();
    local point = getWorldPositionByNodePosition(nodePosition);
    return point;
end 

local function getCenterWorldPosX()
    local posX = (getWorldPosition(m_playerNode).x + getWorldPosition(m_enemyNode).x) / 2;
    return posX;
end

--更新人物的位置
local function updateActorPos(actorNode, mov)
    actorNode:move(mov.vx, mov.vy);
    if (mov.vy < 0 and actorNode:getPositionY() < m_defaultHeight) then
        tolua.cast(actorNode, "CCNode"):setPositionY(m_defaultHeight);
    end
end
--更新人物速度
local function calcActorSpeed(mov)
    mov.vx = mov.vx + mov.ax;
    mov.vy = mov.vy + mov.ay;
end
local m_lastPos = 0;
--场景不断缩放
local function updateScale()
    if (m_lockCameraScale == true) then
        return;
    end

    local worldDistance = getWorldDistance();
    local nodeDistance = getNodeDistance();


    --m_defaultDistance 待改动
    if(m_scaleDuration > 0)then
        m_scaleDuration = m_scaleDuration - 1;
        if(m_scaleTicker > 0)then
            m_scaleTicker = m_scaleTicker - 1;
            m_scaleCount = m_scaleCount - m_scaleAverage;
        end 
    else
        -- if (m_lastDistance == nodeDistance) then
        --     return;
        -- end
        local scaleCount = 1;
        if (nodeDistance >= m_defaultDistance) then
            scaleCount = m_defaultDistance / nodeDistance;
        end
        m_scaleCount = scaleCount;
    end

    -- m_scaleCount = scaleCount;
--
    -- m_scaleLabel:setText(m_scaleCount .. "");
    m_sceneNode:setScale(m_scaleCount);
    m_lastDistance = nodeDistance;
end 

function modifyScale(scaleData)
    local scale = scaleData.scale;
    local ticker = scaleData.ticker;
    m_scaleAverage = (m_scaleCount - scale)/ticker;
    m_scaleTicker = ticker;
    m_scaleDuration = scaleData.duration;
end

--场景节点的不断移动
local function updatePosition()
    if (m_lockCameraPos == true) then
        return;
    end

    local worldPosition = getWorldPositionByTwo();
    local subtance = SCREEN_WIDTH_HALF - worldPosition.x * m_scaleCount;
    -- CCLuaLog("SCREEN_WIDTH_HALF:" .. SCREEN_WIDTH_HALF);
    -- CCLuaLog("m_sceneNode subtance" .. subtance);
    m_lastPos = m_sceneNode:getPositionX() - subtance;
    m_sceneNode:setPositionX(subtance);--by han
    -- m_sceneNode:setPositionX((SCREEN_WIDTH_HALF-worldPosition.x) * m_scaleCount);--by han
    -- local dis = SCREEN_WIDTH_HALF-worldPosition.x * m_scaleCount;
    -- m_lastPos = dis - subtance;
    local dis = (SCREEN_WIDTH_HALF-worldPosition.x) * m_scaleCount;
    m_lastPos = dis - subtance;--移动缩放距离和始终保持中间位置之间的偏移
    -- if(m_scaleCount ~= nil and m_playerNode ~= nil and m_enemyNode ~= nil and m_scaleCount ~)then
    --     tolua.cast(m_playerNode,"CCNode"):setPositionY(tolua.cast(m_playerNode,"CCNode"):getPositionY()*m_scaleCount);
    --     tolua.cast(m_enemyNode,"CCNode"):setPositionY(tolua.cast(m_enemyNode,"CCNode"):getPositionY()*m_scaleCount);
    -- end
  
end

--更新背景画面
local function updateScene()  
    -- if(m_scaleDuration > 0)then

    -- end
    -- scaleCount = m_defaultDistance / nodeDistance;
    local worldPosition = getWorldPositionByTwo();
    local posx = worldPosition.x;
    local i = math.ceil((worldPosition.x - SCREEN_WIDTH_HALF)/m_nearScene_width) - 1;
    m_nearScene1:setPositionX((i * m_nearScene_width - worldPosition.x)*m_scaleCount - m_lastPos);
    m_nearScene2:setPositionX(((i + 1) * m_nearScene_width - worldPosition.x)*m_scaleCount - m_lastPos);
    --     m_nearScene1:setPositionX((i * m_nearScene_width - worldPosition.x)*m_scaleCount);
    -- m_nearScene2:setPositionX(((i + 1) * m_nearScene_width - worldPosition.x)*m_scaleCount);
    local xdis = worldPosition.x;

    -- if(m_scaleDuration > 0)then
    --     local pos1 = m_nearScene1:getPositionX();
    --     local pos2 = m_nearScene2:getPositionX();

    -- end
    m_nearScene1:setScale(m_scaleCount);
    m_nearScene2:setScale(m_scaleCount);

    
    -- local farScale = 1-(1-m_scaleCount)*0.8;
    farScale = m_scaleCount;
    if(m_farScene1 ~= nil)then
        local i = math.ceil(((worldPosition.x*0.5) - SCREEN_WIDTH_HALF)/m_farScene_width) - 1;
        m_farScene1:setPositionX(((i * m_farScene_width - (worldPosition.x*0.5))*farScale - m_lastPos));
        m_farScene2:setPositionX((((i + 1) * m_farScene_width - (worldPosition.x*0.5))*farScale - m_lastPos));
        m_farScene1:setScale(farScale);
        m_farScene2:setScale(farScale);
    end
    if(m_farScene3 ~= nil and m_farScene4)then
        local i = math.ceil(((worldPosition.x*0.5) - SCREEN_WIDTH_HALF)/m_farScene_width2) - 1;
        m_farScene3:setPositionX(((i * m_farScene_width2 - (worldPosition.x*0.5))*farScale - m_lastPos));
        m_farScene4:setPositionX((((i + 1) * m_farScene_width2 - (worldPosition.x*0.5))*farScale - m_lastPos));
        m_farScene3:setScale(farScale);
        m_farScene4:setScale(farScale);
    end
    -- CCLuaLog("the near scene height is =" .. m_nearScene1:getContentSize().height*m_scaleCount);

end    

local function updateShadow()--刷新影子位置 
    m_playerShadow:setPositionY(m_defaultHeight - m_playerNode:getPositionY());
    m_enemyShadow:setPositionY(m_defaultHeight - m_enemyNode:getPositionY());
end

local function turnToGlide(actorNode, actorMov)
    actorMov.ax = 0;
    actorMov.ay = 0;
    actorMov.vy = 0;
    actorMov.t = 60;
    actorNode:setAction("glide");
    tolua.cast(actorNode, "CCNode"):setPositionY(m_defaultHeight);
end

local function turnToRebound(actorNode, actorMov)
    actorMov.ax = 0;
    actorMov.ay = 0;
    actorMov.vx = 0;
    actorMov.vy = 0;
    actorMov.t = 45;
    actorNode:setAction("rebound");
    tolua.cast(actorNode, "CCNode"):setPositionY(m_defaultHeight);
end

local function turnToGetUp(actorNode, actorMov,actorData)
    actorMov.ax = 0;
    actorMov.ay = 0;
    actorMov.vx = 0;
    actorMov.vy = 0;
    actorMov.t = 30;
    actorNode:setAction("get_up");
    actorData.nextMov = nil;
end

local function turnToLieDown(actorNode, actorMov,actorData)
    actorMov.ax = 0;
    actorMov.ay = 0;
    actorMov.vx = 0;
    actorMov.vy = 0;
    actorMov.t = 30;
    actorNode:setAction("lie_down");
    actorData.nextMov = "get_up";
end



local function turnToWeak(actorNode, actorMov, anim)
    actorMov.ax = 0;
    actorMov.ay = 0;
    actorMov.vx = 0;
    actorMov.vy = 0;
    actorMov.t = 30;
    actorNode:setAction(anim, true);
end

local function updateActor(actorNode, actorData)
    local actorMov = actorData.mov;
    updateActorPos(actorNode, actorMov);
    calcActorSpeed(actorMov);
    actorMov.t = actorMov.t - 1;
    if(actorData.willDead)then
        actorData.nextMov = nil;
    end
    if (actorMov.t <= 0) then--一段攻击结束
        local nextMov = actorData.nextMov;
            if(actorData.stop == SKILL_MOVE_NORMAL) then--如果是没有受伤要求防御方有移动走这里
                actorData.stop = SKILL_MOVE_DAMAGE;
                actorData.mov = nil;
                return;
            elseif(actorData.stop == SKILL_MOVE_BUFF)then--如果是final攻击无伤害走这里
                actorData.stop = SKILL_MOVE_DAMAGE;
                actorData.mov = nil;
            end
        if (nextMov) then
            if (nextMov == "get_up") then
                turnToGetUp(actorNode, actorMov,actorData);
                -- tolua.cast(actorNode, "CCNode"):setPositionY(m_defaultHeight);
                BattleActor.setTargetPosX(actorData, actorNode:getPositionX());
            elseif (nextMov == "weak") then
                turnToWeak(actorNode, actorMov, nextMov);
            elseif(nextMov == "lie_down")then
                turnToLieDown(actorNode, actorMov,actorData);
            end
        else
            -- local data = getDataByActor(actorNode);
            if(actorData.dead ~= true and actorData.willDead ~= true)then
                if(actorData.isVertiGo == true)then--如果是眩晕在玩家表现所有移动后眩晕
                    actorNode:setAction("weak",true);
                else
                    actorNode:setAction("stand",true);--被击方动作结束
                end
            else
                actorNode:setAction("die",false);
                actorData.willDead = false;
            end
            local distan = getWorldDistance();
            BattleActor.setTargetPosX(actorData, actorNode:getPositionX());
            actorData.isAnimEnd = true;
            actorData.knees = false;
            actorData.mov = nil;
            
        end
    end
end

function setClearBuffData(attacker, atkList, defList)
    m_attacker = attacker;
    m_atkBufRemList = atkList;
    m_defBufRemList = defList;
end
function removeBuff()
    local data = getDefData();
    if((m_atkBufRemList ~= nil or m_defBufRemList ~= nil))then
        local data  = getDefData(m_attacker);
        if(data.isAnimEnd)then
            clearBuffAni(m_attacker, m_atkBufRemList, m_defBufRemList);
            m_atkBufRemList = nil;
            m_defBufRemList = nil;
        end
    end
end
function createRoundLabel()
    local label = Label:create();
    label:setText(m_round .. "huihe");
    label:setPosition(ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2));
    label:setFontSize(35);
    label:setColor(ccc3(127, 255, 0));
    local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(label, CONFIRM_ZORDER);
    label:runAction(CCFadeOut:create(1));
end
function nextRound()
    m_round = m_round + 1;
end
local function updateAllActors()
                -- 我方位移
    if (m_playerData.mov) then
        updateActor(m_playerNode, m_playerData);
    end
        -- 敌方位移
    if (m_enemyData.mov) then
        updateActor(m_enemyNode, m_enemyData);
    end

end
function getDefData(index)
    if (index == 2) then
        return m_playerData;
    else
        return m_enemyData;
    end
end

function setAniEnd()--强制双方动画表演结束
    m_playerData.isAnimEnd = true;  
    m_enemyData.isAnimEnd = true;
end

function updateState()  

    if(getBattleState() == BATTLE_STATE_NONE) then 

    elseif(getBattleState() == BATTLE_STATE_PAUSE_ROLL)then
        local id = BattleMovie.getDefIndex();
        local defData = getDefData(id);
        if(m_playerData.mov == nil and m_enemyData.mov == nil and defData.isAnimEnd)then
            m_isPlayAttackAnim = false;
            m_playerData.isAnimEnd = false;  
            m_enemyData.isAnimEnd = false;
            setBattleState(BATTLE_STATE_ATTACK);
        end
    elseif(getBattleState() == BATTLE_STATE_PREPARE_RELIVE)then
        local id = BattleMovie.getDefIndex();
        local defData = getDefData(id);
        if(m_playerData.mov == nil and m_enemyData.mov == nil and defData.isAnimEnd)then
            m_isPlayAttackAnim = false;
            m_playerData.isAnimEnd = false;  
            m_enemyData.isAnimEnd = false;
            local actList = CCArray:create();
            local delay = CCDelayTime:create(2);
            local callback = CCCallFunc:create(m_attackCallback);
            actList:addObject(delay);
            actList:addObject(callback);
            m_rootNode:runAction(CCSequence:create(actList));
            setBattleState(BATTLE_STATE_NONE);
        end
    elseif(getBattleState() == BATTLE_STATE_RELIVE)then
            m_isPlayAttackAnim = false;
            m_playerData.isAnimEnd = false;  
            m_enemyData.isAnimEnd = false;
            BattleUI.setState(UI_STATE_CONTINUE);
            setBattleState(BATTLE_STATE_NONE);
    elseif(getBattleState() == BATTLE_STATE_BEGIN)then
        BattleUI.setState(UI_STATE_CONTINUE);
        setBattleState(BATTLE_STATE_NONE);
    elseif(getBattleState() == BATTLE_STATE_ATTACK) then
        m_isPlayAttackAnim = false;
        m_playerData.isAnimEnd = false;  
        m_enemyData.isAnimEnd = false;
        m_attackCallback();
        setBattleState(BATTLE_STATE_NONE);
    elseif(getBattleState() == BATTLE_STATE_WAIT) then
        local id = BattleMovie.getDefIndex();
        local defData = getDefData(id);
        if(m_playerData.mov == nil and m_enemyData.mov == nil and defData.isAnimEnd)then
            m_isPlayAttackAnim = false;
            m_playerData.isAnimEnd = false;  
            m_enemyData.isAnimEnd = false;
            m_playerData.hasAttacked = false;
            m_enemyData.hasAttacked = false;
            if(m_battleEnd)then--战斗结束 
                m_attackCallback();
            else
                BattleUI.setState(UI_STATE_CONTINUE);
            end
            setBattleState(BATTLE_STATE_NONE);
        end
    elseif(getBattleState() == BATTLE_STATE_COUNTER)then--反击状态
        local id = BattleMovie.getDefIndex();
        local defData = getDefData(id);
        --敌人落地之后开始反击
        if(m_playerData.mov == nil and m_enemyData.mov == nil and defData.isAnimEnd)then
            -- local actList = CCArray:create();
            -- local delay = CCDelayTime:create(0.01);
            -- local callback = CCCallFunc:create(function() setBattleState(BATTLE_STATE_ATTACK); end);
            -- actList:addObject(delay);
            -- actList:addObject(callback);
            -- m_rootNode:runAction(CCSequence:create(actList));
            -- setBattleState(BATTLE_STATE_NONE);
            setBattleState(BATTLE_STATE_ATTACK);
        end
    elseif(getBattleState() == BATTLE_STATE_NEXT)then--下一回合
        local id = BattleMovie.getDefIndex();
        local defData = getDefData(id);
        if(m_playerData.mov == nil and m_enemyData.mov == nil and defData.isAnimEnd)then
            m_isPlayAttackAnim = false;
            m_playerData.isAnimEnd = false;  
            m_enemyData.isAnimEnd = false;
            m_playerData.hasAttacked = false;
            m_enemyData.hasAttacked = false;
            BattleUI.setState(UI_STATE_INTERVAL);
            setBattleState(BATTLE_STATE_NONE);
        end
    end
end
local function lockCamera()
    m_lockCameraScale = true;
    m_lockCameraPos = true;
end

local function unlockCamera()
    m_lockCameraScale = false;
    m_lockCameraPos = false;
end

local function removeEffects()
    for i, effect in ipairs(m_effectRemovePool) do
        effect:removeFromParentAndCleanup(true);
    end
    m_effectRemovePool = {};
end

--更新缩放，更新位置，更新人物，移除光效
local function update(dt)
    updateScale();--by han
    updatePosition();--by han
    updateAllActors();
    removeEffects();
    updateScene();
    removeBuff();
    updateState();--更新回合
    updateShadow();
end

function startBattle()
    unlockCamera();
    m_schedulerEntry = m_scheduler:scheduleScriptFunc(update, 0, false);
end

function stopBattle()
    if (m_schedulerEntry ~= nil)    then
        m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
    end
end

local function isLoadModuleEnd()
    return m_isloadModuleEnd;
end

local function makeActorInfo(skin)
    local faceInfo = CCDictionary:create();
    if(faceMap[skin.cloth])then--特殊人物特殊换脸 
        faceInfo:setObject(CCString:create("hair_front_" .. skin.hairFront .. "_" .. skin.color .. "_1" .. ".png"), MODULE_KEY_HAIR_FRONT);
        faceInfo:setObject(CCString:create("hair_beishi_".. skin.hairFront .. "_" ..skin.color .. "_1" .. ".png"), MODULE_KEY_HAIR_BACK);
        faceInfo:setObject(CCString:create("face_" .. skin.face .. "_1" .. ".png"), MODULE_KEY_FACE);
        faceInfo:setObject(CCString:create("hair_other" .. 1 .. "_" .. skin.hairFront .. "_" .. skin.color .. ".png"), "hair_other" .. 1);
    else
        faceInfo:setObject(CCString:create("hair_front_" .. skin.hairFront .. "_" .. skin.color .. ".png"), MODULE_KEY_HAIR_FRONT);
        faceInfo:setObject(CCString:create("hair_beishi_".. skin.hairFront .. "_" ..skin.color .. ".png"), MODULE_KEY_HAIR_BACK);
        faceInfo:setObject(CCString:create("face_" .. skin.face .. ".png"), MODULE_KEY_FACE);
        faceInfo:setObject(CCString:create("hair_other" .. 1 .. "_" .. skin.hairFront .."_" .. skin.color .. ".png"), "hair_other" .. 1);
    end
    -- for i = 1, 10 do
    --     faceInfo:setObject(CCString:create("battle_hair_other" .. i .. "_%d_" .. skin.hairBack .. ".png"), "hair_other" .. i);
    -- end
     --   faceInfo:setObject(CCString:create("battle_eyebrows_%d_" .. skin.eyebrows .. ".png"), MODULE_KEY_EYEBROWS);
 --   faceInfo:setObject(CCString:create("battle_eyes_%d_" .. skin.eyes .. ".png"), MODULE_KEY_EYES);
 --   faceInfo:setObject(CCString:create("battle_mouth_%d_" .. skin.mouth .. ".png"), MODULE_KEY_MOUTH);
    return faceInfo;
end

local function loadModuleComplete()
    m_isloadModuleEnd = true;
end

--加载场景********需要改动
local function loadScene(resData)
    -- local sceneName = resData.sceneName .. ".json";
    --test
    
    if(m_debugMode)then
        m_scaleLabel = Label:create();
        m_scaleLabel:setText("");
        m_scaleLabel:setPosition(ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2));
        m_scaleLabel:setFontSize(50);
        m_scaleLabel:setColor(ccc3(255, 0, 0));
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_scaleLabel);
    end
    --
    --读取配置文件加载场景，场景ID根据加载机制待完成
    local sceneID = 101;
    if(m_typeData[2] == BATTLE_SUBTYPE_LEVEL)then
       sceneID = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_typeData[3], "mapID");
    elseif(m_typeData[2] == BATTLE_SUBTYPE_LEVEL)then 
       sceneID = DataBaseManager.getValue(DATA_BASE_ACTIVITY_LEVEL, DATABASE_HEAD .. m_typeData[3], "mapID");
    else
        sceneID = math.random(3) + 100;
    end
    
    m_sceneName = "id_" .. sceneID;
    local dataName = SCENE_DATA_NAME;
    local bgName = DataBaseManager.getValue(dataName, m_sceneName, "bg");
    local nearName = DataBaseManager.getValue(dataName, m_sceneName, "near");
    local farName = DataBaseManager.getValue(dataName, m_sceneName, "far1");
    local farName1 = DataBaseManager.getValue(dataName, m_sceneName, "far2");
    local posy1 = 0;
    if(farName ~= "")then
        m_farHeight = DataBaseManager.getValue(dataName, m_sceneName, "far1_posy");
    end
    if(farName1 ~= "")then
         m_farHeight1 = DataBaseManager.getValue(dataName, m_sceneName, "far2_posy");
    end
    
    local length = 0;
    -- for k,v in pairs(item) do
    --     length = length+1;
    --     if(string.find(k,"name") == 1) then
    --         local isNew = true;
    --         local count = table.getn(m_sceneAniName);
    --         for i,count in ipairs(m_sceneAniName) do
    --             if(m_sceneAniName[i] == v) then
    --                 isNew = false;
    --                 break;
    --             end
    --         end
    --         if(isNew and v ~= "") then
    --             table.insert(m_sceneAniName,v);
    --         end
    --     end
    -- end

    --场景包含动画数量等于一条数据的总数量减去固定五列数据
    m_actorCount = (length - 5)/3;
    m_rootLayer = CCLayer:create();
    m_bg = CCSprite:create(PATH_RES_BATTLE .. bgName);
    m_bg_width = m_bg:getContentSize().width; 
    m_bg:setPosition(ccp(0,0));
    m_bg:setAnchorPoint(CCPoint(0,0));
    m_bg:setColor(ccc3(255,255,255));
    getGameLayer(SCENE_BATTLE_LAYER):addChild(m_bg);
    getGameLayer(SCENE_BATTLE_LAYER):addChild(m_rootLayer);
    local far3 = nil;
    local far4 = nil;
    if(farName1 ~= "")then
        far3 = CCSprite:create(PATH_RES_BATTLE .. farName1);
        far4 = CCSprite:create(PATH_RES_BATTLE .. farName1);
    end

    
    if(far3 ~= nil)then
        m_farScene3 = CCLayer:create();
        m_farScene4 = CCLayer:create();
        far3:setPosition(ccp(0,m_farHeight1));
        far4:setPosition(ccp(0,m_farHeight1));
        far3:setAnchorPoint(CCPoint(0,0));
        far4:setAnchorPoint(CCPoint(0,0));
        m_farScene_width2 = far3:getContentSize().width;
        m_farScene3:setPosition(ccp(0,0));
        m_farScene3:setAnchorPoint(CCPoint(0,0));
        m_farScene3:addChild(far3);
        m_rootLayer:addChild(m_farScene3);

        m_farScene4 = CCSprite:create(PATH_RES_BATTLE .. farName1);
        m_farScene4:setPosition(ccp(m_farScene_width2,0));
        m_farScene4:setAnchorPoint(CCPoint(0,0));
        m_farScene4:addChild(far4);
        m_rootLayer:addChild(m_farScene4);
    end

    local far1 = CCSprite:create(PATH_RES_BATTLE .. farName);
    local far2 = CCSprite:create(PATH_RES_BATTLE .. farName);
    far1:setAnchorPoint(CCPoint(0,0));
    far2:setAnchorPoint(CCPoint(0,0));
    far1:setPosition(ccp(0,m_farHeight));
    far2:setPosition(ccp(0,m_farHeight));
    m_farScene1 = CCLayer:create();
    m_farScene1:setAnchorPoint(ccp(0,0));
    -- m_farScene1:setPosition(ccp(0,));
    m_farScene_width = far1:getContentSize().width;
    m_farScene1:addChild(far1);
    m_rootLayer:addChild(m_farScene1);

    m_farScene2 = CCLayer:create();
    m_farScene2:setPosition(ccp(m_farScene_width,0));
    m_farScene2:setAnchorPoint(CCPoint(0,0));
    m_farScene2:addChild(far2);
    m_rootLayer:addChild(m_farScene2);


    m_winSize = CCDirector:sharedDirector():getWinSize();

    m_nearScene1 = CCSprite:create(PATH_RES_BATTLE .. nearName);
    m_nearScene_width = m_nearScene1:getContentSize().width;
    m_nearScene1:setPosition(ccp(0,0));
    -- m_nearScene1:setVisible(false);
    m_nearScene1:setAnchorPoint(CCPoint(0,0));
    m_rootLayer:addChild(m_nearScene1);

    m_nearScene2 = CCSprite:create(PATH_RES_BATTLE .. nearName);
    m_nearScene2:setPosition(ccp(m_nearScene_width,0));
    -- m_nearScene2:setVisible(false);
    m_nearScene2:setAnchorPoint(CCPoint(0,0));
    m_rootLayer:addChild(m_nearScene2);


    m_rootNode = CCNode:create();

    m_rootNode:setAnchorPoint(CCPoint(0,0));
    m_rootNode:setPosition(ccp(0,0));
    m_rootLayer:addChild(m_rootNode,2);

    m_sceneNode = m_rootNode;

    m_scenePosY = m_sceneNode:getPositionY();

    m_colorNode = CCLayerColor:create(ccc4(0, 0, 0, 0));
    m_colorNode:setContentSize(CCSize(SCREEN_WIDTH+200,SCREEN_HEIGHT+200));
    m_colorNode:setPositionX(-100);
    m_colorNode:setPositionY(-100);
    m_rootLayer:addChild(m_colorNode,1);
    -- m_sceneNode:addChild(m_colorNode, COLOR_LAYER_Z);
end

function frameEventBuffInVisible(text,node)
    -- CCLuaLog("enquire event");
    local data = m_dataMap[node];
    for i,v in pairs(data.buff) do
        if(v[1] ~= nil)then
            v[1]:setVisible(false);
        end
    end
end

function frameEventBuffVisible(text,node)
    local data = m_dataMap[node];
    for i,v in pairs(data.buff) do
        if(v[1] ~= nil)then
            v[1]:setVisible(true);
        end
    end
end

local function createBattlerAni()

end
--从场景文件加入两个角色节点
--主要是得到双方玩家的位置*********需要改动
local function createBattler(resData)

    stopBattle();
    BattleMovie.stopMovie();
	removeActor();
    local playerNode = nil;
    local enemyNode = nil;
    --temp modify
    local playerPos = 200;
    local enemyPos = SCREEN_WIDTH-200;
    local playerHeight = 160;
    local enemyHeight = 160;

    -- m_playerData = BattleActor.creteActorData(BATTLE_ACTOR_TYPE_PLAYER);
    -- m_enemyData = BattleActor.creteActorData(BATTLE_ACTOR_TYPE_ENEMY);
    -- m_monsterSkinList = {};
    -- for i,v in pairs(resData.skin)do
    --     if(v.isAattacker == 1)then
    --         BattleActor.setEnemySkin(m_playerData, v);
    --     else
    --         table.insert(m_monsterSkinList,v);
    --     end
    -- end
    -- if(m_playerData.skin == nil)then
    --     BattleActor.setPlayerSkin(m_playerData);
    -- end
    -- BattleActor.setEnemySkin(m_enemyData, m_monsterSkinList[1]);
    local playerSkin = BattleActor.getSkin(m_playerData);
    local enemySkin = BattleActor.getSkin(m_enemyData);
    m_playerNode= BattleActor.create("Actor_" .. playerSkin.cloth, playerPos, playerHeight, BATTLE_ACTOR_TYPE_PLAYER);
    m_enemyNode = BattleActor.create("Actor_" .. enemySkin.cloth, enemyPos, enemyHeight, BATTLE_ACTOR_TYPE_ENEMY);

    m_playerNode:registerFrameEvent("disappear",frameEventBuffInVisible);
    m_playerNode:registerFrameEvent("appear",frameEventBuffVisible);
    m_enemyNode:registerFrameEvent("disappear",frameEventBuffInVisible);
    m_enemyNode:registerFrameEvent("appear",frameEventBuffVisible);
    m_playerShadow = CCSprite:create(PATH_RES_BATTLE .. "shadow.png");
    local playerWidth = tolua.cast(m_playerNode,"CCArmature"):boundingBox():getMaxX();
    tolua.cast(m_playerNode,"CCNode"):addChild(m_playerShadow);
    m_enemyShadow = CCSprite:create(PATH_RES_BATTLE .. "shadow.png");
    local enemyWidth = tolua.cast(m_enemyNode,"CCArmature"):boundingBox():getMaxX();
    tolua.cast(m_enemyNode,"CCNode"):addChild(m_enemyShadow);
    m_dataMap[m_playerNode] = m_playerData;
    m_dataMap[m_enemyNode] = m_enemyData;
    --给场景创建动画
    local dataName = SCENE_DATA_NAME;

    -- for i = 1, m_actorCount do--场景中加入动画代码，暂时配置不正确注掉
    --     local resName = DataTableManager.getValue(dataName, m_sceneName, "name_" .. i);

    --     if(resName ~= "") then--如果有存在的animation
    --         local posX = DataTableManager.getValue(dataName, m_sceneName, "posx_" .. i);
    --         local posY = DataTableManager.getValue(dataName, m_sceneName, "posy_" .. i);
    --         local actor = SJBattleActor:create(resName);
    --         local actor1 = SJBattleActor:create(resName);
    --         tolua.cast(actor, "CCNode"):setPosition(CCPoint(posX, posY));
    --         tolua.cast(actor1, "CCNode"):setPosition(CCPoint(posX, posY));
    --         actor:setAction("run", true);
    --         actor1:setAction("run", true);
    --         m_nearScene1:addChild(tolua.cast(actor, "CCNode"));
    --         m_nearScene2:addChild(tolua.cast(actor1, "CCNode"));
    --     else
    --         break;
    --     end
    -- end

    BattleActor.setTargetPos(m_playerData, playerPos, playerHeight);
    BattleActor.setTargetPos(m_enemyData, enemyPos, enemyHeight);

    m_defaultDistance = math.abs(playerPos - enemyPos);
    m_lastDistance = m_defaultDistance;
    m_defaultHeight = (playerHeight + enemyHeight) / 2;

    m_enemyNode:setFlipX(true);
    m_playerNode:setAction("stand", true);
    m_enemyNode:setAction("stand", true);

    m_sceneNode:addChild(tolua.cast(m_playerNode, "CCNode"),BATTLE_TAG_PLAYER);
    m_sceneNode:addChild(tolua.cast(m_enemyNode, "CCNode"), BATTLE_TAG_ENEMY);


end

function removeActor()
	if(m_playerNode~=nil) then
		m_playerNode:removeFromParentAndCleanup(true);
		m_playerNode = nil;
	end
	if(m_enemyNode~=nil) then
		m_enemyNode:removeFromParentAndCleanup(true);
		m_enemyNode = nil;
	end
end


--皮肤管理
local function addFramesToList(fileList, skin)
    local fullPath = PATH_RES_MDL_MALE;
    if(faceMap[skin.cloth])then--特殊人物换肤加载资源特殊 
        -- for i = 1, m_partCount[skin.cloth].hair_front do
            local fullName1 = fullPath .. "hair_front_" .. (i - 1) .. "_" .. skin.hairFront .. "_1";
            fileList:addObject(CCString:create(fullName1));
        -- end
        -- for i = 1, m_partCount[skin.cloth].hair_back do
            local fullName2 = fullPath .. "hair_back_" .. (i - 1) .. "_" .. skin.hairBack .. "_1";
            fileList:addObject(CCString:create(fullName2));
        -- end
        -- for i = 1, m_partCount[skin.cloth].face do
            local fullName3 = fullPath .. "face_" .. skin.face .. "_1";
            fileList:addObject(CCString:create(fullName3));
        -- end
            local fullName4 = fullPath .. "hair_other" .. 1 .. "_" .. skin.hairFront .. "_" .. skin.colork;
            fileList:addObject(CCString:create(fullName4));
    else
        -- for i = 1, m_partCount[skin.cloth].hair_front do
            local fullName1 = fullPath .. "hair_front_" .. skin.hairFront .. "_" .. skin.color;
            fileList:addObject(CCString:create(fullName1));
        -- end
        -- for i = 1, m_partCount[skin.cloth].hair_back do
            local fullName2 = fullPath .. "hair_beishi_".. skin.hairBack .. "_" .. skin.color;
            fileList:addObject(CCString:create(fullName2));
        -- end
        -- for i = 1, m_partCount[skin.cloth].face do
            local fullName3 = fullPath .. "face_" .. skin.face;
            fileList:addObject(CCString:create(fullName3));
        -- end
            local fullName4 = fullPath .. "hair_other" .. 1 .. "_" .. skin.hairFront .. "_" .. skin.color;
            fileList:addObject(CCString:create(fullName4));
    end

    -- for j = 1, 10 do
    --     local count = m_partCount[skin.cloth]["hair_other" .. j];
    --     for i = 1, count do
    --         local fullName = fullPath .. "battle_hair_other" .. j .. "_" .. (i - 1) .. "_" .. skin.hairBack;
    --         fileList:addObject(CCString:create(fullName));
    --     end
    -- end
end

--加载双方皮肤资源
local function loadActorModule()
    local playerSkin = BattleActor.getSkin(m_playerData);
    local enemySkin = BattleActor.getSkin(m_enemyData);

    local fileList = CCArray:create();
    addFramesToList(fileList, playerSkin);
    if(enemySkin.cloth < 10000)then
        addFramesToList(fileList, enemySkin);
    end
    

    SJFrameLoader:sharedInstance():addFramesWithFileListAsync(fileList, loadModuleComplete);
end


local function loadResultData(resData)
    local resultData = resData.data;
    m_playerData.name = resultData.name_1;
    m_playerData.hp = resultData.hp_1;
    m_playerData.hpMax = resultData.maxHp_1;
    m_enemyData.name = resultData.name_2;
    m_enemyData.hp = resultData.hp_2;
    m_enemyData.hpMax = resultData.maxHp_2;
    m_enemyData.hpMax = resultData.maxHp_2;
    m_playerData.cycle = resultData.cycle1;
    m_enemyData.cycle = resultData.cycle2;
    if(m_playerData.hp > m_playerData.hpMax)then
        m_playerData.hp = m_playerData.hpMax;
    end
    if(m_enemyData.hp > m_enemyData.hpMax)then
        m_enemyData.hp = m_enemyData.hpMax;
    end
    -- 替换资源
    local playerSkin = BattleActor.getSkin(m_playerData);
    local enemySkin = BattleActor.getSkin(m_enemyData);
    local playerFace = makeActorInfo(playerSkin);
    local enemyFace = makeActorInfo(enemySkin);

    m_playerNode:setActorFace(playerFace);
    if(enemySkin.cloth < 10000)then
        m_enemyNode:setActorFace(enemyFace);
    end
    

    BattleUI.setData(m_playerData, m_enemyData);--先放这里，如果改动加载流程再换地方
    local battleui = BattleUI.create();
    -- battleui:setPositionY(-250);
    m_rootLayer:addChild(battleui,100);
end

local function loadActorAnimComplete()
    m_loadActorAnimComplete = true;
end

local function clearCurEffectReference()
    for i,v in pairs(m_effectReference)do
        local obj = tolua.cast(v,"CCNode");
        obj:removeFromParentAndCleanup(true);
    end
    m_effectReference = {};
end

local function clearEffectReference()
    clearCurEffectReference();
    m_effectReference = nil;
end
--加载角色动画资源
local function loadArmature(resData)

    if(m_animList ~= nil ) then
        if(m_animList:count() ~= 0) then
            clearAnimList();
	    end	
    end	
	if(m_effectReference ~= nil)then
        clearEffectReference();
    end
    m_effectReference = {};
    m_animList = CCArray:create();
    m_animList:retain();
    local hasPlayer = false;
    local clothTable = {};

    for i,v in pairs(resData.cloth)do 
        if(clothTable[v.cloth] == nil)then
            clothTable[v.cloth] = v.cloth;
            m_animList:addObject(CCString:create(PATH_RES_BAT_ACTOR .. "Actor_" .. v.cloth .. ".ExportJson"));
        end
        if(v.isAattacker == 1)then
            hasPlayer = true;
        end
    end

    for i = 1,#m_sceneAniName do
        m_animList:addObject(CCString:create(PATH_RES_ACTORS .. m_sceneAniName[i] .. ".ExportJson"));
    end


    m_animList:addObject(CCString:create(PATH_RES_OTHER .. "zhandoushengli.ExportJson"));
    m_animList:addObject(CCString:create(PATH_RES_OTHER .. "xiaoxingxing.ExportJson"));
    m_animList:addObject(CCString:create(PATH_RES_EFFECT .. "kongbuff" .. ".ExportJson"));
    
    --/////
    m_playerData = BattleActor.creteActorData(BATTLE_ACTOR_TYPE_PLAYER);
    m_enemyData = BattleActor.creteActorData(BATTLE_ACTOR_TYPE_ENEMY);
    m_monsterSkinList = {};
    for i,v in pairs(resData.cloth)do
        if(v.isAattacker == 1)then
            BattleActor.setEnemySkin(m_playerData, v);
        else
            table.insert(m_monsterSkinList,v);
        end
    end
    if(m_playerData.skin == nil)then
        BattleActor.setPlayerSkin(m_playerData);
    end

    BattleActor.setEnemySkin(m_enemyData, m_monsterSkinList[1]);
    local playerSkin = BattleActor.getSkin(m_playerData);
    local enemySkin = BattleActor.getSkin(m_enemyData);
    BattleMovie.setSkinID(1,playerSkin.cloth);
    BattleMovie.setSkinID(2,enemySkin.cloth);
    BattleManager.setBattleData();
    for i,v in pairs(m_loadAniList)do
        m_animList:addObject(CCString:create(PATH_RES_EFFECT .. v .. ".ExportJson"));
    end
    CCLuaLog("convert lua data end------------------------");
    
    local playerCloth = UserInfoManager.getRoleInfo("coat").type;
    if(hasPlayer == false and clothTable[playerCloth] == nil)then
        m_animList:addObject(CCString:create(PATH_RES_BAT_ACTOR .. "Actor_" .. playerCloth .. ".ExportJson"));
    end
--/////



    SJArmatureLoader:sharedInstance():addArmatureWithFileListAsync(m_animList, loadActorAnimComplete);

end

function clearAnimList()
   
 -- CCLuaLog("array count:"..m_animListCopy:objectAtIndex(0));
    SJArmatureLoader:sharedInstance():removeArmatureFileInfo(m_animList);
    m_animList:removeAllObjects();
    m_animList:release();
    m_animList = nil;
end    

local function isActorAnimComplete()
    return m_loadActorAnimComplete;
end


function loadBattler(skinData, resultData, callbackFunc)
    local loadAnim = {resType = LOADING_TYPE_BATTLE_ASYNC, resData = {loader = loadArmature, isEnd = isActorAnimComplete, cloth = skinData}};
    local loadActor = {resType = LOADING_TYPE_BATTLE, resData = {loader = createBattler, skin = skinData}};
    local loadModule = {resType = LOADING_TYPE_BATTLE_ASYNC, resData = {loader = loadActorModule, isEnd = isLoadModuleEnd}};
    -- local loadResult = {resType = LOADING_TYPE_BATTLE, resData = {loader = loadEffectArmature, isEnd = resultData}};
    local loadResult = {resType = LOADING_TYPE_BATTLE, resData = {loader = loadResultData, data = resultData}};
    local resList = {loadAnim, loadActor, loadModule, loadResult};
    Loading.create(resList, callbackFunc);
end

--根据场景名称加载场景文件
function create(sceneName, typeData, callbackFunc)
    
    Loading.remove();
    m_isloadModuleEnd = false;
    m_buffAnimData = {};
    m_effectRemovePool = {};
    m_typeData = typeData;
    local loadField = {resType = LOADING_TYPE_BATTLE, resData = {sceneName = sceneName, loader = loadScene}};
    local resList = {loadField};
    Loading.create(resList, callbackFunc);
end

function playBegin(cbFunc)
    CCLuaLog("Play Begin!");
    AudioEngine.setMusicVolume(0.2);
    math.randomseed(tostring(os.time()):reverse():sub(1, 6));
    local num = math.random(3);
    AudioEngine.playMusic(PATH_RES_AUDIO .. "music_zhandou" .. num .. ".mp3", true);
    m_movieCallBack = cbFunc;
    --new 播放准备动画以及永久技能
    m_playerNode:registerAnimEvent(1, nextDisplayStep);
    m_enemyNode:registerAnimEvent(1, nextDisplayStep);
    m_playerNode:setAction("ready",false);
    m_enemyNode:setAction("ready",false);
end

function nextDisplayStep(text,node) 
    local actorData = getDataByActor(node);
    actorData.skillDisEnd = true;
    node:setAction("stand",true);
    node:unregisterAnimEvent(1);
    if(m_playerData.skillDisEnd == true and m_enemyData.skillDisEnd == true) then--播放完毕
        m_movieCallBack();
    end
end
local function playEnd(movieData, cbFunc)
    CCLuaLog("Play End!");
    m_movieCallBack = cbFunc;
end

function setAttackCallbackFunc(cbFunc)
    m_attackCallback = cbFunc;
end

function setPlayAttackAnim(isPlay)
    m_isPlayAttackAnim = isPlay;
end

local function getAttacker(index)
    if (index == 1) then
        return m_playerNode;
    else
        return m_enemyNode;
    end
end

local function getDefenser(index)
    if (index == 2) then
        return m_playerNode;
    else
        return m_enemyNode;
    end
end

local function getAtkData(index)
    if (index == 1) then
        return m_playerData;
    else
        return m_enemyData;
    end
end



local function setBuffColor(actorNode, actorData, red, green, blue, part)
    local count = m_partCount[BattleActor.getSkin(actorData).cloth][part];
    actorNode:setAPartColor(part .. "_%d", ccc3(red, green, blue), count);
end

local function clearAnimEffect(text, effNode)
    local actorNode = m_buffAnimData[effNode];
    m_buffAnimData[effNode] = nil;
    effNode:removeFromParentAndCleanup(true);
    effNode = nil;
    -- actorNode:delEffect(effNode);
    -- table.insert(m_effectRemovePool, effNode);
end

local function removeBuffEffect(actorNode, actorData, buff)
    local effCount = BattleBuff.getEffectCount(buff);
    for i = 1, effCount do
        local effType = BattleBuff.getEffectType(buff, i);
        local effData = BattleActor.getEffectData(actorData, buff, i);
        if(effData == nil)then
            CCLuaLog("buff " .. buff .. " is null,please check file of bufflist or check server info");
            return;
        end
        if (effType == BATTLE_BUFF_TYPE_ANIMATION) then
            -- CCLuaLog("the effect data remove is" .. i);
            local attacker = 1;
            if(actorNode == m_enemyNode)then
                attacker = 2;
            end
            BattleUI.removeBuffIcon(attacker,buff);
            actorData.buff[buff][i] = nil;
            effData:getAnimation():play("stop", -1, -1, 0, -1);
            effData:registerAnimEvent(1, clearAnimEffect);
        end
    end
end

function clearBuffAni(attacker, atkList, defList)
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    for i,buff in ipairs(atkList) do
        if(buff < 0)then
            removeBuffEffect(atkNode,atkData, -buff);
        end
    end
    for i,buff in ipairs(defList) do
        if(buff < 0)then
            removeBuffEffect(defNode,defData, -buff);
        end
    end

end 

local function createBuffAnim(actorNode, name, block, offset)
    CCLuaLog("buff name is " .. name);
    local effNode = SJArmature:create(name);
    local baseNode = tolua.cast(actorNode, "CCNode");
    local animList = CCArray:create();
    local actorZ = baseNode:getZOrder();
    if (block == false) then
        actorZ = actorZ - 1;
    else
        actorZ = actorZ + 100;
    end
    animList:addObject(CCString:create("start"));
    animList:addObject(CCString:create("cycle"));
    -- effNode:setFlipX(actorNode:getFlipX());

    effNode:setPositionX(0);
    effNode:setPositionY(offset);
    effNode:getAnimation():playWithArray(animList, -1, false);
    tolua.cast(actorNode, "CCNode"):addChild(effNode, actorZ);
    m_buffAnimData[effNode] = actorNode;
    return effNode;
end

function addArmature(node)
    m_rootLayer:addChild(node,10);
end

--移动中BUFF的机制两种机制，一种跟随人物移动，一种是直接添加到人物上不用管理。最后再根据需求调整
local function doMoveAction(actorNode, speed, disX, cbFunc)
    print("BattleScene doMoveAction-->disX = " .. disX);
    local disY = m_defaultHeight - tolua.cast(actorNode, "CCNode"):getPositionY();
    local actList = CCArray:create();
    local actMove = CCMoveBy:create(math.abs(disX / speed), CCPoint(disX, disY));

    local callback = CCCallFunc:create(cbFunc);
    actList:addObject(actMove);
    actList:addObject(callback);
    local action = CCSequence:create(actList);
    local action = tolua.cast(actorNode, "CCNode"):runAction(action);
end

function moveAttacker(attacker, moveType, offset, offsetY, duration)
    local atkNode = getAttacker(attacker);
    local defNode = getDefenser(attacker);
    if (atkNode:getFlipX() == true) then
        offset = -offset;
    end
    atkNode = tolua.cast(atkNode, "CCNode");
    defNode = tolua.cast(defNode, "CCNode");
    if (moveType == BATTLE_ACTOR_MOVE_TO) then
        local targetX = defNode:getPositionX() - offset;
            atkNode:runAction(CCMoveTo:create(duration, CCPoint(targetX, atkNode:getPositionY() + offsetY)));
    elseif (moveType == BATTLE_ACTOR_MOVE_BY) then
        atkNode:runAction(CCMoveBy:create(duration, CCPoint(offset, offsetY)));
    end
end

function turnDefenserColor(attacker, duration, color)
    local actorNode = tolua.cast(getDefenser(attacker), "CCNode");
    local turn = CCArray:create();
    turn:addObject(CCTintTo:create(duration, color.r, color.g, color.b));
    turn:addObject(CCFadeTo:create(duration, color.a));
    actorNode:runAction(CCSpawn:create(turn));
end

function turnScreenColor(duration, color)
    local turn = CCArray:create();
    turn:addObject(CCTintTo:create(duration/FPS, color.r, color.g, color.b));
    turn:addObject(CCFadeTo:create(duration/FPS, color.a));
    m_colorNode:runAction(CCSpawn:create(turn));
end

function resetColorLayer()
    m_colorNode:setColor(ccc3(0,0,0));
    m_colorNode:setOpacity(0);
end

function shockScreen(times)
    --重复震屏次数
    local posx = m_rootLayer:getPositionX();
    local move1 = CCMoveTo:create(0.05, CCPoint(20, -20));
    local move2 = CCMoveTo:create(0.05, CCPoint(10, -15));
    local move3 = CCMoveTo:create(0.05, CCPoint(0, 0));
    -- local move2 = move1:reverse();
    local moveList = CCArray:create();
    moveList:addObject(move1);
    moveList:addObject(move2);
    moveList:addObject(move3);
    -- moveList:addObject(CCCallFunc:create(resetPos));
    local moveAction = CCSequence:create(moveList);
    m_rootLayer:runAction(CCRepeat:create(moveAction, times));
    -- return m_sceneNode:runAction(CCRepeat:create(moveAction, times));
end

function resetPos()
    local posx = getGameLayer(SCENE_BATTLE_LAYER):getPositionX();
    local posy = getGameLayer(SCENE_BATTLE_LAYER):getPositionY();
    m_rootLayer:setPosition(ccp(0,0));
end

local function getHurtAnim(defNode, defData, damage, superAttack)
    local rate = damage / defData.hpMax;
    if (rate > 0.2) then
        return "hurt_h";
    else
        if (superAttack == true) then
            return "knees";
        else
            return "hurt";
        end
    end
end

--hurt，只要skiildata中有MOV就不会走。类似有特殊情况走特殊情况，没有就走这里普遍情况
local function getHurtMov(defNode, defData, damage)
    local rate = damage / defData.hpMax;
    local mov = {};
        mov.ax = 0;
        mov.ay = 0;
        mov.vx = 0;
        mov.vy = 0;
        mov.t = 20;
    return mov;
end

function attackerRun(attacker, offsetX, cbFunc)
    local actorNode = getAttacker(attacker);
    local defData = getDefData(attacker);
    local defNode = getDefenser(attacker);
    -- local disX = BattleActor.getTargetPosX(defData) - actorNode:getPositionX();
    local disX = defNode:getPositionX() - actorNode:getPositionX();
    if (disX > 0) then
        disX = disX - offsetX;
    else
        disX = disX + offsetX;
    end
    actorNode:setAction("run", true);
    doMoveAction(actorNode, 1000, disX, cbFunc);
end

function attackerFlashBack(attacker, offsetX, cbFunc)
    local actorNode = getAttacker(attacker);
    local defData = getDefData(attacker);
    local disX = BattleActor.getTargetPosX(defData) - actorNode:getPositionX();
    if (disX > 0) then
        disX = disX + offsetX;
    else
        disX = disX - offsetX;
    end
    actorNode:setAction("run", true);
    doMoveAction(actorNode, 1050, disX, cbFunc);
end

function flipAttacker(attacker)
    local actorNode = getAttacker(attacker);
    actorNode:setFlipX(not actorNode:getFlipX());
end

function flipDefenser(attacker)
    local actorNode = getDefenser(attacker);
    actorNode:setFlipX(not actorNode:getFlipX());
end

function setAttackerAction(attacker, action)
    local actorNode = getAttacker(attacker);
    local actorData = getAtkData(attacker);

    --to do lichong
    local attNode = tolua.cast(actorNode, "CCNode");
    local defNode =  tolua.cast(getDefenser(attacker), "CCNode");
    local attackerZ = attNode:getZOrder();
    local defenderZ = defNode:getZOrder();
    if(attackerZ < defenderZ) then
        attNode:setZOrder(defenderZ);
        defNode:setZOrder(attackerZ);
    end
    --lichong
    actorNode:setAction(action);
    BattleActor.setTargetPosX(actorData, actorNode:getPositionX());
    -- actorData.isAnimEnd = true;
end

function setDefenserAction(attacker, action)
    if (action ~= "null" and action ~= nil) then
        local actorNode = getDefenser(attacker);
        actorNode:setAction(action);
    end
end

--显示buff光效
local function showBuffEffect(actorNode, actorData, buff)
    local effCount = BattleBuff.getEffectCount(buff);
    local buffData = {buff, {}};
    -- for i = 1, effCount do
        local effType = BattleBuff.getEffectType(buff, 1);
        local effValues = BattleBuff.getEffectValues(buff, 1);
        if (effType == BATTLE_BUFF_TYPE_ANIMATION) then
            local anim = createBuffAnim(actorNode, effValues[1], effValues[2], effValues[3]);
            if(effValues[5] ~= "")then
                local attacker = 1;
                if(actorNode == m_enemyNode)then
                    attacker = 2;
                end
                BattleUI.addBuffIcon(attacker,buff,effValues[5]);
            end

            BattleActor.setEffectData(actorData, buff, 1, anim);
        end
    -- end
end

function defenserHurt(attacker, damage, anim, mov, superAttack, interrupt, attackType, isVertigo,isFinal, heatType)
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    defData.hp = math.max(defData.hp - damage, 0);
    BattleUI.updateBlood();

    defNode:setFlipX(not atkNode:getFlipX());
    -- if (anim == "") then
    --     anim = getHurtAnim(defNode, defData, damage, superAttack);
    -- end
    if(attackType == FINAL_ATTACK_TYPE_BACK)then
        anim = "hurt_back"
    end

    if(anim == "hurt_fly_arc")then
        defData.nextMov = "get_up";
    end
    if(anim ~= "")then
        defNode:setAction(anim);
    end

    if(damage ~= 0)then
        local numLabel = defNode:createNumber("-" .. math.floor(damage), 0, 100, 2,heatType);
        m_sceneNode:addChild(numLabel, 100);
    end
    
    if (mov == nil) then
        mov = getHurtMov(defNode, defData, damage);
    end
    defData.knees = superAttack;
    defData.mov = mov;
    if(isFinal)then--战斗结束
        defData.dead = true;
        m_battleEnd = true;
    end
    defData.isVertiGo = isVertigo;
end

function fetchHpAttacker(id,damage)--吸血 
    local atkNode = getRoleNode(id);
    local data = getRoleData(id);
    local numLabel = atkNode:createNumber("" .. math.floor(damage), 0, 100, 2,8);
    data.hp = data.hp + damage;
    data.hp = math.min(data.hp, data.hpMax);
    BattleUI.updateBlood();
    m_sceneNode:addChild(numLabel, 100);
end

function onceDamage(id,damage)
    local node = getRoleNode(id);
    local data = getRoleData(id);
    local numLabel;
    local type = 7;
    if(damage > 0)then
        type = 8;
    end
    numLabel = node:createNumber("" .. math.floor(damage), 0, 100, 2,type);
    data.hp = math.max(data.hp + damage, 0);
    data.hp = math.min(data.hp, data.hpMax);
    BattleUI.updateBlood();
    m_sceneNode:addChild(numLabel, 100);
end

function buffDead(id)
    local node = getRoleNode(id);
    local data = getRoleData(id);
    stopBattle();
    node:setAction("die");
    data.isAnimEnd = false;
    BattleMovie.stopBattle();
end

function buffFalseDead(id)--濒死状态
    local node = getRoleNode(id);
    local data = getRoleData(id);
    node:setAction("die");
    data.isAnimEnd = false;
end

function buffHurt(id,damage)
    if(damage == nil)then
        return;
    end
    if(damage == 0)then
        return;
    end
    local type = 7;
    if(damage > 0)then
        type = 8;
    end
    local node = getRoleNode(id);
    local data = getRoleData(id);
    local numLabel;
    numLabel = node:createNumber("" .. math.floor(damage), 0, 100, 2,type);
    data.hp = math.max(data.hp + damage, 0);
    data.hp = math.min(data.hp, data.hpMax);
    BattleUI.updateBlood();
    m_sceneNode:addChild(numLabel, 100);
end

function getRoleNode(id)
    if(id == 1)then
        return m_playerNode;
    else
        return m_enemyNode;
    end
end

function getRoleData(id)
    if(id == 1)then
        return m_playerData;
    else
        return m_enemyData;
    end
end

function setDefenserMov(attacker, mov, type)
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    defData.stop = type;
    defData.mov = mov;
end

function setDefenserAni(attacker,anim)
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    defNode:setAction(anim,false);
end

function attackerHurt(attacker, damage, ko)
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);
    atkData.hp = math.max(atkData.hp - damage, 0);
    atkData.hp = math.min(atkData.hp, atkData.hpMax);
    BattleUI.updateBlood();
    local numLabel = atkNode:createNumber("-" .. math.floor(damage), 0, 100, 2,9);
    m_sceneNode:addChild(numLabel, 100);
end

function finalFeedBack(attacker)--反击被反死
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);--回位，挂掉
    tolua.cast(atkNode,"CCNode"):setPositionY(m_defaultHeight);
    anim = "die";
    m_isAttackerDead = true;
    atkNode:setAction(anim,false);
end

function attackerWillDead(attacker)
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);--回位，挂掉
    tolua.cast(atkNode,"CCNode"):setPositionY(m_defaultHeight);
    anim = "die";
    mov = {vx = 0, ax = 0, vy = 0, ay = 0, t = 120};
    m_isAttackerDead = true;
    atkNode:setAction(anim,false);
end

function defenserWillDead(attacker)--被攻击者濒死
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    defData.willDead = true;
end


function finalHurt(attacker, damage, sumDamage)
    local atkNode = getAttacker(attacker);
    local defNode = getDefenser(attacker);
    local atkData = getAtkData(attacker);
    local defData = getDefData(attacker);
 --   local rate = sumDamage / defData.hpMax;
    local rate = damage / defData.hpMax;
    local anim, mov = nil, nil;
    defData.hp = math.max(defData.hp - damage, 0);--减少血量
    defData.hp = math.min(defData.hp, defData.hpMax);
    defNode:setFlipX(not atkNode:getFlipX());
	--伤害值大于总血量20%则被击飞，否则被击倒
    if (rate > 0.1) then
        anim = "die_fly";
        mov = {vx = 24, ax = -0.2, vy = 4.8, ay = -0.08, t = 120};
    -- else
    --     anim = "lie_down";
    --     mov = {vx = 0, ax = 0, vy = 0, ay = 0, t = 60};
        defNode:setAction(anim);
    end
    -- defNode:setAction(anim);
    local numLabel = defNode:createNumber("" .. math.floor(damage), 0, 100, 2,0);
    m_sceneNode:addChild(numLabel, 100);
    defData.dead = true;--死亡
    m_battleEnd = true;
    lockCamera();
    atkData.hasAttacked = true;
end

function getSelfBuffLast(list)
    local buffList = {};
    for i, buff in ipairs(list) do
        if (buff > 0) then
            local effValues = BattleBuff.getEffectValues(buff, 1);
            if(effValues[4] == 1)then--增益buff且不是在技能中的
                table.insert(buffList,buff);
            end
        end
    end
    return buffList;
end

function getOtherBuffLast(list)
    local buffList = {};
    for i, buff in ipairs(list) do
        if (buff > 0) then
            local effValues = BattleBuff.getEffectValues(buff, 1);
            if(effValues[4] == 0)then--增益buff且不是在技能中的
                table.insert(buffList,buff);
            end
        end
    end
    return buffList;
end

function getSelfBuffInner(list)
    local buffList = {};
    for i, buff in ipairs(list) do
        if (buff > 0) then
            local effValues = BattleBuff.getEffectValues(buff, 1);
            if(effValues[4] == 1 and effValues[6] == true)then--增益buff且不是在技能中的
                table.insert(buffList,buff);
            end
        end
    end
    return buffList;
end

function getOhterBuffInner(list)
    local buffList = {};
    for i, buff in ipairs(list) do
        if (buff > 0) then
            local effValues = BattleBuff.getEffectValues(buff, 1);
            if(effValues[4] == 0 and effValues[6] == true)then--增益buff且不是在技能中的
                table.insert(buffList,buff);
            end
        end
    end
    return buffList;
end
function updateAtkBuff(attacker, atkBuff)
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);
    -- 给自己用的buf
    for i, buff in ipairs(atkBuff) do
        if (buff > 0) then
            showBuffEffect(atkNode, atkData, buff);
        end
    end
    -- 防御方buff
    
end

function updateDefBuff(attacker,defBuff)
    -- body
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    for i, buff in ipairs(defBuff) do
        if (buff > 0) then
            showBuffEffect(defNode, defData, buff);
        end
    end
end

function avoidHurt(attacker, counter)
    local atkNode = getAttacker(attacker);
    local atkData = getAtkData(attacker);
    local defNode = getDefenser(attacker);
    local defData = getDefData(attacker);
    defNode:setAction("avoid");
    defData.mov = {vx = 22.7, ax = -0.1, vy = 0, ay = 0, t = 35};
    showAvoidLabel(defNode,"shanbi");
    atkNode:setAction("stand",true);
    tolua.cast(atkNode,"CCNode"):setPositionY(m_defaultHeight);
    clearCurEffectReference();
    m_colorNode:setOpacity(0);
    defData.isAnimEnd = false;
    atkData.hasAttacked = true;
end

function setAttackEnd(attacker)
    local atkData = getAtkData(attacker);
    local defData = getDefData(attacker);
    -- if (atkData.hasAttacked ~= true) then
        defData.isAnimEnd = true;
    -- end
    atkData.isAnimEnd = true;
end

function clearEffect(text, effNode)
    for i,v in pairs(m_effectReference)do
        if(effNode == v)then
            table.remove(m_effectReference,i);
            break;
        end
    end
    effNode:removeFromParentAndCleanup(true);

end

function playAttackerEffect(attacker, effect, effFollow, moveTime, effPos)
    if (effect) then
        local actorNode = getAttacker(attacker);
        local effNode = SJArmature:create(effect);
        local isFlip = actorNode:getFlipX();
        -- effNode:setFlipX(isFlip);
        -- if (isFlip == true) then
        --     effNode:setPositionX(-effPos.x);
        -- else
            effNode:setPositionX(effPos.x);
        -- end
        effNode:setPositionY(effPos.y);
        effNode:registerAnimEvent(1, clearEffect);
        
        table.insert(m_effectReference,effNode);
        local posx = effNode:getPositionX();
        local posy = effNode:getPositionY();
        effNode:getAnimation():play("stand", 0, 0, 0, 0);
        -- tolua.cast(actorNode, "CCNode"):addChild(effNode,100);
        -- m_sceneNode:addChild(effNode, 50);
        if (effFollow == BATTLE_EFFECT_MOVE_INTERVAL) then
            local defNode = getDefenser(attacker);
            local defData = getDefData(attacker);
            local targetPosX, targetPosY = defNode:getPositionX(), defNode:getPositionY();
            local mov = defData.mov;
            if (moveTime == nil) then
                moveTime = 0;
            end

            if (mov) then
                targetPosX = targetPosX + mov.vx * moveTime + mov.ax * moveTime * moveTime / 2;
                targetPosY = targetPosY + mov.vy * moveTime + mov.ay * moveTime * moveTime / 2;
            end
            local action = CCMoveTo:create(moveTime / FPS, CCPoint(targetPosX, targetPosY));
            if (isFlip == true) then
                effNode:setPositionX(actorNode:getPositionX() - effPos.x);
            else
                effNode:setPositionX(actorNode:getPositionX() + effPos.x);
            end
            effNode:setPositionY(actorNode:getPositionY() + effPos.y);
            effNode:runAction(action);
            m_sceneNode:addChild(effNode, 50);
        elseif (effFollow == BATTLE_EFFECT_MOVE_INSTANT) then
            local defNode = getDefenser(attacker);
            -- local defPosX = tolua.cast(defNode, "CCNode"):getPositionX();
            -- local defPosY = tolua.cast(defNode, "CCNode"):getPositionY();
            -- effNode:setPositionX(defPosX);
            -- effNode:setPositionY(defPosY);
            -- if (defNode:getFlipX() == true) then
            --     effNode:setPositionX(- effPos.x);
            -- else
                effNode:setPositionX(effPos.x);
            -- end
            effNode:setPositionY(effPos.y);
            tolua.cast(defNode, "CCNode"):addChild(effNode,100);
        else
            tolua.cast(actorNode, "CCNode"):addChild(effNode,100);
        end
    end
end

function playDefenserEffect(attacker, effect, effPos)
    if (effect) then
        local actorNode = getDefenser(attacker);
        CCLuaLog("defenser effect name = ".. effect);
        local effNode = SJArmature:create(effect);
        if(effNode == nil)then
            CCLuaLog("effect " .. effect .. " is null");
        end
        local isFlip = actorNode:getFlipX();
        -- effNode:setFlipX(isFlip);
        if(effPos ~= nil)then
            if (isFlip == true) then
                effNode:setPositionX(-effPos.x);
            else
                effNode:setPositionX(effPos.x);
            end

            effNode:setPositionY(effPos.y);
        end
        effNode:registerAnimEvent(1, clearEffect);
        effNode:getAnimation():play("stand", 0, 0, 0, 0);
     --   m_sceneNode:addChild(effNode, 50);--by han
        tolua.cast(actorNode, "CCNode"):addChild(effNode,100);
    end
end

-- function playBattleVideo()--回放,本地回放,重设所有状态
-- m_sceneNode:setPositionX(0);
-- m_nearScene1:setPositionX(0);
-- m_playerNode:setAction("stand");
-- m_enemyNode:setAction("stand");

-- end

function releaseBattleLayer()
    AudioEngine.stopMusic(true);

    m_monsterSkinList = nil;
    m_battleEnd = false;
    m_typeData = nil;
    m_loadActorAnimComplete = false;
    removeActor();
    clearAnimList();
    stopBattle();
    BattleMovie.stopMovie();
    BattleUI.close();
    clearEffectReference();
    getGameLayer(SCENE_BATTLE_LAYER):removeAllChildrenWithCleanup(true);
    getGameLayer(SCENE_UI_LAYER):removeAllChildrenWithCleanup(true);
    -- CCTextureCache:sharedTextureCache():removeUnusedTextures();
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames();
    m_rootLayer = nil;
end

function playResult(winner)
    if (winner == 1) then
        m_playerNode:setAction("victory", false);
    else
        m_enemyNode:setAction("victory", false);
    end
    AudioEngine.stopMusic(true);
    local data = BattleManager.getBattleData();
    if(data[1] == BATTLE_MAIN_TYPE_PVP)then--pvp
        if(winner == 1)then
            AudioEngine.playEffect(PATH_RES_AUDIO.."laohuji.mp3")
            if(data[2] == BATTLE_SUBTYPE_JJC)then
                UIManager.open("JJCResult");
            elseif(data[2] == BATTLE_SUBTYPE_TRAIN)then
                UIManager.open("TrainResult");
            elseif(data[2] == BATTLE_SUBTYPE_TOURNAMENT)then
                UIManager.open("BiWuResult");
            end
        else
            UIManager.open("FailResult");
        end

    else
        BattleResult.create();
        BattleResult.open(m_typeData);--本次战斗数据 
    end


    local newMaterialData = UserInfoManager.isNewMaterial()
    if newMaterialData.isNew then
        AncientMaterialItem.playGetAncientEffect(newMaterialData["id"])
    end
end

local function clearSkillLabel(object)
    tolua.cast(object, "CCSprite"):removeFromParentAndCleanup(true);
end

function showSkillLabel(attacker, skillID)
    -- local actorNode = getAttacker(attacker);
    -- local text = SkillData.getProperties(skillID).name;
    -- local label = CCSprite:create(PATH_RES_LABEL .. text .. ".png");
    -- if(label == nil) then
    --     return;
    -- end
    -- label:setAnchorPoint(ccp(0.5,0));
    -- label:setPositionY(tolua.cast(actorNode,"CCNode"):getContentSize().height/2);
    -- label:setFlipX(actorNode:getFlipX());
    -- tolua.cast(actorNode, "CCNode"):addChild(label,2);
    -- local actList = CCArray:create();
    -- actList:addObject(CCDelayTime:create(2));
    -- actList:addObject(CCCallFuncN:create(clearSkillLabel));
    -- label:runAction(CCSequence:create(actList));
end

function showAvoidLabel(actorNode,imgName)
    local text = imgName;
    local label = CCSprite:create(PATH_RES_LABEL .. text .. ".png");
    label:setAnchorPoint(ccp(0.5,0));
    label:setPositionX(0);
    label:setPositionY(tolua.cast(actorNode,"CCNode"):getContentSize().height/2+50);
    label:setFlipX(actorNode:getFlipX());
     tolua.cast(actorNode, "CCNode"):addChild(label,2);
    local actList = CCArray:create();
    actList:addObject(CCDelayTime:create(2));
    actList:addObject(CCCallFuncN:create(clearSkillLabel));
    label:runAction(CCSequence:create(actList));
end

function setBattleState(state)
    m_battleState = state;
end

function battleInterval(callFun) 
    m_intervalCallFun = callFun;
    BattleUI.setCallFun(callFun);
    BattleUI.setState(UI_STATE_CONTINUE);
end
function getBattleState()
    return m_battleState;
end
function setAttackerDead(isDead)
    m_isAttackerDead = isDead;
end

function setDefaultAniActor(attacker,isAttacker)
    local atkNode = getAttacker(attacker);
    local defNode = getDefenser(attacker);
    if(isAttacker) then
        if(m_isAttackerDead)then
            m_isAttackerDead = false;
            return;
        else
            atkNode:setAction("stand",true);
        end 
    else
    defNode:setAction("stand",true);
    end
end

function getDataByActor(actorNode) 
    for k,v in pairs(m_dataMap) do
        if(actorNode == k) then
            return v;
        end
    end
end

function getDefenserIndex(attacker)
    if(attacker == 1)then
        return 2;
    else
        return 1;
    end
end

