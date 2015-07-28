module("EventManager", package.seeall)

require "Event/EventEntity"

local m_scene = nil;

local m_events = nil;
local m_eventEnities = nil;

local m_variables = nil;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;

local m_activedEvents = nil;

function init()
    m_variables = {};
    m_activedEvents = {};
end

function free()
    m_activedEvents = {};
end

function loadEventFile(fileName)
    local text = SJTxtFile:openFile(PATH_RES_EVENT .. fileName);
    m_events = json.decode(text).Events;
end

function parseEvent(text)
    m_events = json.decode(text).Events;
end

function convertEvent(sceneName)
    m_eventEnities = {};
    m_scene = _G[sceneName];

    for i, event in ipairs(m_events) do
        local eventData = m_events[i];
        local eventEntity = EventEntity.createEvent(eventData);
        if ((#eventEntity.trigger > 0) or (#eventEntity.condition > 0) or (#eventEntity.action > 0)) then
            m_eventEnities[eventData.name] = eventEntity;
            registerTriggers(eventEntity.trigger);
        end
    end
end

function setVariableValue(key, value)
    m_variables[key] = value;
end

local function getVariable(key)
    if (type(key) == "string") then
        return m_variables[key];
    else
        return key;
    end
end

local function getWord(text)
    local index = tonumber(text) + 1;
    return WordManager.getWord(index);
end

local function actionUpdate( dt )
    local temp = {};

    for i, event in ipairs(m_activedEvents) do
        if (event.wait > 0) then
            event.wait = math.max(event.wait - dt, 0);
            table.insert(temp, event);
        elseif (event.wait == 0) then
            if (event.progress == #event.action) then
                event.progress = 0;
                break;
            end
            while (event.progress < #event.action) do
                event.progress = event.progress + 1;
                local action = event.action[event.progress];
                if (action.func) then
                    action.func(event, action.data);
                end
                if (event.wait ~= 0) then
                    break;
                end
            end
            table.insert(temp, event);
        else
            table.insert(temp, event);
        end
    end
    
    m_activedEvents = temp;
    if (#m_activedEvents == 0) then
        m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
    end
end

function activeEvent(trigger)
    local event = trigger.event;
    local conditions = event.condition;

    if (event.isRun == false or event.progress > 0) then
        return;
    end

    local isAccord = true;
    for i, condition in ipairs(conditions) do
        if(condition.func) then
            isAccord = condition.func(event, condition.data);
        end
        if (isAccord == false) then
            return;
        end
    end

    if (#m_activedEvents == 0) then
        m_schedulerEntry = m_scheduler:scheduleScriptFunc(actionUpdate, 0, false);
    end
    -- event.progress = 0;
    table.insert(m_activedEvents, event);
end

local function equalValues(event, data)
    local valueLeft = getVariable(data[1]);
    local valueRight = getVariable(data[3]);
    local equalType = data[2];
    local res = true;
    if (valueLeft == nil or valueRight == nil) then
        return false;
    end
    if (equalType == "same") then
        res = (valueLeft == valueRight);
    elseif (equalType == "more") then
        res = (valueLeft > valueRight);
    elseif (equalType == "less") then
        res = (valueLeft < valueRight);
    elseif (equalType == "not_less") then
        res = (valueLeft >= valueRight);
    elseif (equalType == "not_more") then
        res = (valueLeft <= valueRight);
    elseif (equalType == "not_same") then
        res = (valueLeft ~= valueRight);
    end
    return res;
end

local function stringEqualValues(event, data)
    local valueLeft = getVariable(data[1]);
    local valueRight = data[3];
    local equalType = data[2];
    local res = true;
    if (valueLeft == nil or valueRight == nil) then
        return false;
    end
    if (equalType == "same") then
        res = (valueLeft == valueRight);
    elseif (equalType == "more") then
        res = (valueLeft > valueRight);
    elseif (equalType == "less") then
        res = (valueLeft < valueRight);
    elseif (equalType == "not_less") then
        res = (valueLeft >= valueRight);
    elseif (equalType == "not_more") then
        res = (valueLeft <= valueRight);
    end
    return res;
end

local function moveActor(event, data)
    if (m_scene.moveActor) then
        local actorName = data[1];
        local angle = data[2];
        local speed = data[3];
        local isWaitFinish = data[4];
        m_scene.moveActor(actorName, angle, speed, isWaitFinish, event);
    end
    -- event.wait = 0;
end

local function closeEvent(event, data)
    local eventName = data[1];
    if (eventName == "self") then
        event.isRun = false;
    else
        m_eventEnities[eventName].isRun = false;
    end
    event.wait = 0;
end

local function openEvent(event, data)
    local eventName = data[1];
    if (eventName == "self") then
        event.isRun = true;
    else
        m_eventEnities[eventName].isRun = true;
    end
    event.wait = 0;
end

local function switchLayer(event, data)
    if (m_scene.switchLayer) then
        m_scene.switchLayer(data[1], data[2], true);
    end
    event.wait = -1;
end

function actionEnterWorldMap( event, data )
    if (m_scene.enterWorldMap) then
        m_scene.enterWorldMap(data[1], data[2]);
    end
    event.wait = -1;
end

function actionEnterShop( event, data )
    if(m_scene.enterShop) then
        m_scene.enterShop(data[1]);
    end
    event.wait = 0;
end

local function openUI(event, data)
    local uiName = data[1];
    local pauseGame = data[2];
    if (m_scene.openUI) then
        m_scene.openUI(uiName, pauseGame);
    end
    event.wait = 0;
end

local function newUI(event, data)
    local uiName = data[1];
    if (m_scene.newUI) then
        m_scene.newUI(uiName);
    end
    event.wait = 0;
end

local function setVariable(event, data)
    local key = data[1];
    local strValue = data[2];
    local numValue = data[3];
    if (strValue and strValue ~= "") then
        m_variables[key] = strValue;
    else
        if (type(numValue) == "string") then
            numValue = m_variables[numValue];
        end
        m_variables[key] = numValue;
    end
    event.wait = 0;
end

local function actionIfBetween(event, data)
    local centerV = getVariable(data[1]);
    local lowV = getVariable(data[2]);
    local upV = getVariable(data[3]);
    if (centerV < lowV or centerV > upV) then
        event.progress = event.progress + data.jump;
    end
    event.wait = 0;
end

local function actionIf(event, data)
    local res = equalValues(event, data);
    if (res == false) then
        event.progress = event.progress + data.jump;
    end
    event.wait = 0;
end

local function actionElse(event, data)
    event.progress = event.progress + data.jump;
    event.wait = 0;
end

local function actionEnd(event, data)
    event.wait = 0;
end

local function actionWait(event, data)
    local time = data[1];
    if (time ~= 0) then
        event.wait = time;
    end
end

local function actionGuide( event, data )
    local x = data[1];
    local y = data[2];
    local w = data[3];
    local h = data[4];
    m_scene.exeGuide(x, y, w, h, event);
end

local function actionSetMission( event, data)
    local npcName = data[1];
    local missionId = data[2];
    local missionType = data[3];
    m_scene.setMission(npcName, missionId, missionType);
end

local function actionShowMission( event, data )
    local npcName = data[1];
    m_scene.showMission(npcName, event);
end

local function actionUpGrade( event, data )
    --查表或公式，根据经验值，判断是否可以进行等级提升
    if(true) then
        --进行提升，播放动画
        --触发等级提升
        m_scene.activeUpGradeEvent();
    end
end

local function actionEnterBattle( event, data )
    print("*******************actionEnterBattle***********************");
    event.wait = 0;
    MainCityLogic.enterBattle(1, 1);
end

local function actionSendNpcId( event, data )
    MainCityLogic.sendNPCID(data)
end

function registerTriggers(triggers)
    for i, trigger in ipairs(triggers) do
        if (trigger.type == EVENT_TRIGGER_TAP_ACTOR) then
            m_scene.registerTriggerOnActor(trigger);
        elseif (trigger.type == EVENT_TRIGGER_ENTER_RANGE) then
            m_scene.registerTriggerOnActor(trigger);
        elseif (trigger.type == EVENT_TRIGGER_MOVE_VERT) then
            m_scene.registerTriggerOnMove(trigger);
        elseif (trigger.type == EVENT_TRIGGER_INITIAL) then
            m_scene.registerTriggerOnInit(trigger);
        elseif (trigger.type == EVENT_TRIGGER_START) then
            m_scene.registerTriggerOnStart(trigger);
        elseif (trigger.type == EVENT_TRIGGER_UPGRADE) then
            m_scene.registerTriggerOnGradeUp(trigger);
        elseif (trigger.type == EVENT_TRIGGER_RECV_MISSION) then
            m_scene.registerTriggerOnMissionReceive(trigger);
        elseif (trigger.type == EVENT_TRIGGER_FNIS_MITTION) then
            m_scene.registerTriggerOnMissionFinished(trigger);
        end
    end
end

function getConditionFunc(condittionType)
    if (condittionType == EVENT_CONDITION_EQUAL) then
        return equalValues;
    elseif(condittionType == EVENT_CONDITION_STRING_EQUAL) then
        return stringEqualValues;
    end
end

function getActionFunc(actionType)
    if (actionType == EVENT_ACTION_MOVE_ACTOR) then
        return moveActor;
    elseif (actionType == EVENT_ACTION_CLOSE_EVENT) then
        return closeEvent;
    elseif (actionType == EVENT_ACTION_OPEN_EVENT) then
        return openEvent;
    elseif (actionType == EVENT_ACTION_SWITCH_LAYER) then
        return switchLayer;
    elseif (actionType == EVENT_ACTION_OPEN_UI) then
        return openUI;
    elseif (actionType == EVENT_ACTION_NEW_UI) then
        return newUI;
    elseif (actionType == EVENT_ACTION_SET_VARIABLE) then
        return setVariable;
    elseif (actionType == EVENT_ACTION_IF) then
        return actionIf;
    elseif (actionType == EVENT_ACTION_ELSE) then
        return actionElse;
    elseif (actionType == EVENT_ACTION_END) then
        return actionEnd;
    elseif(actionType == EVENT_ACTION_GUIDE) then
        return actionGuide;
    elseif(actionType == EVENT_ACTION_WAIT) then
        return actionWait;
    elseif(actionType == EVENT_ACTION_SET_MISSION) then
        return actionSetMission;
    elseif(actionType == EVENT_ACTION_SHOW_MISSION) then
        return actionShowMission;
    elseif(actionType == EVENT_ACTION_UP_GRADE) then
        return actionUpGrade;
    elseif (actionType == EVENT_ACTION_IFBETWEEN) then
        return actionIfBetween;
    elseif (actionType == EVENT_ACTION_ENTER_BATTLE) then
        return actionEnterBattle;
    elseif (actionType == EVENT_ACTION_SEND_NPCID) then
        return actionSendNpcId;
    elseif (actionType == EVENT_ACTION_ENTER_WORLD_MAP) then
        return actionEnterWorldMap;
    elseif (actionType == EVENT_ACTION_ENTER_SHOP) then
        return actionEnterShop;
    end
end

