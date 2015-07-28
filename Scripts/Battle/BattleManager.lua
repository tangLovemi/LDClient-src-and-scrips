module("BattleManager", package.seeall)

require (PATH_SCRIPT_BATTLE .. "BattleBuff")
require (PATH_SCRIPT_BATTLE .. "BattleScene")
require (PATH_SCRIPT_BATTLE .. "BattleMovie")

local DEBUG_MODE = true;
local m_type = nil;
local m_subType = nil;
local m_sceneData = nil;
local m_battleID = nil;
local m_skinData = nil;
local m_resultData = nil;
local m_processData = nil;
local m_id = 0;
local m_winner = nil;
local m_isPlayVedio = false;
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_processDataLast = nil;
local m_skinDataLast = nil;
local m_resultDataLast = nil;
local m_prizeCommon = nil;
local m_prizeItem = nil;
local m_pauseBegin = false;
local m_pauseEnd = false;
local m_debugMode = false;
local m_debugCallBack = nil;
local function receiveBattleResult(messageType, messageData)
    m_winner = messageData.winner;
    -- m_winner = 2;
    m_resultData = messageData;
    m_resultDataLast = messageData;
end

local function receiveBattleProcess(messageType, messageData)
    m_processData = messageData;
    m_processDataLast = messageData;
    -- for i,msg in ipairs(messageData) do
    --     CCLuaLog("step:" .. i);
    --     CCLuaLog("attacker:" .. msg.attacker);
    --     CCLuaLog("skillNum1:" .. msg.skillNum1);
    --     CCLuaLog("skillNum2:" .. msg.skillNum2);
    --     CCLuaLog("flag:" .. msg.flag);
    --     for i=1,#msg.atkBuff do
    --          CCLuaLog("atkBuff:".. msg.atkBuff[i]);
    --     end 
    --     for i=1,#msg.defBuff do
    --         CCLuaLog("defBuff:".. msg.defBuff[i]);
    --     end

    --     CCLuaLog("*****************");
    -- end
end

local function receiveCommon(messageType, messageData)
    m_prizeCommon = messageData;
    if(m_type == BATTLE_MAIN_TYPE_PVE and m_subType == BATTLE_SUBTYPE_LEVEL)then
        local data = WorldManager.getInfo();
        for i,v in pairs(data)do
            if(v.id == m_id)then
                v.level = messageData.star;
            end
        end
    end
end


local function receiveItem(messageType, messageData)
    m_prizeItem = messageData;
end
--½ÓÊÕµÐÈËµÄÍâ¹ÛÊý¾Ý£º1001
local function receiveActorSkin(messageType, messageData)
    m_skinData = messageData;
    m_skinDataLast = messageData;
end

local function fightEnd()
    print("fightEnd: " .. m_winner);
    --战斗后对话
    if m_subType ==1 then--关卡
        local currentTaskData = NpcInfoManager.getMajorTaskData()
        local currentTaskId = currentTaskData["task_id"]
        local current_Task_Status = currentTaskData["status"]
        local beforBattleDialog =  DataTableManager.getItem("BattleDialog",tostring(currentTaskId).."_2_index")
        if beforBattleDialog ~= nil then
            if current_Task_Status == 4 then 
                setEndPause()
                require("UI/BattleDialogUI")
                BattleDialogUI.create()
                local function continueBattle()
                    BattleDialogUI.close()
                    BattleDialogUI.remove()
                    setEndContinue()
                end
                BattleDialogUI.open(beforBattleDialog["DialogContent"],continueBattle)
            end
        end
    end
    --战斗展示中暂停
    if TaskManager.checkFirstShowBattle() then
        setEndPause()
        require("UI/Guide/FirstBattle")
        FirstBattle.create()
        FirstBattle.open("end")
        local callback = function()
            FirstBattle.close()
            setDebugMode(false);
            BattleScene.releaseBattleLayer();
            m_debugCallBack();
        end
        FirstBattle.setCallBack(callback)
        m_pauseEnd = false;
    end

    BattleScene.stopBattle();
    if(not m_pauseEnd)then
        if(isDebugMode())then
            -- cclog("isDebugMode")
            -- setDebugMode(false);
            -- BattleScene.releaseBattleLayer();
            -- m_debugCallBack();
        else
            BattleScene.playResult(m_winner);
        end
    else
        BattleScene.playResult(m_winner);
    end
end

--¿ªÊ¼²¥·ÅÕ½¶·
local function gone()
    BattleMovie.playMovie(BATTLE_MOVIE_ATTACK, m_processData, fightEnd);
    m_processData = nil;
end


function isWinner()
    if(m_winner == 1)then
        return true;
    end
    return false;
end

function setBeginPause()
    m_pauseBegin = true;
end

function setEndPause()
    m_pauseEnd = true;
end

function setBeginContinue()
    m_pauseBegin = false;
    BattleScene.startBattle();
    BattleMovie.playMovie(BATTLE_MOVIE_BENGIN, nil, gone);
end

function setEndContinue()
    m_pauseEnd = false;
    BattleScene.playResult(m_winner);
end

--ÑÓ³Ù2s×¼±¸¿ªÊ¼
local function battlerOnReady()
    Loading.remove();
    --战斗前对话
    if m_subType ==1 then--关卡
        local currentTaskData = NpcInfoManager.getMajorTaskData()
        local currentTaskId = currentTaskData["task_id"]
        local current_Task_Status = currentTaskData["status"]
        local beforeBattleDialog =  DataTableManager.getItem("BattleDialog",tostring(currentTaskId).."_1_index")
        if beforeBattleDialog~= nil then
            if current_Task_Status == 3 or current_Task_Status == 4 then 
                setBeginPause()
                require("UI/BattleDialogUI")
                BattleDialogUI.create()
                local function continueBattle()
                    BattleDialogUI.close()
                    BattleDialogUI.remove()
                    setBeginContinue()
                end
                BattleDialogUI.open(beforeBattleDialog["DialogContent"],continueBattle)
                -- --更新任务信息
                NpcInfoManager.getMajorTaskInfo(1,nil)
            end
        end
    end
    --战斗展示中暂停
    if TaskManager.checkFirstShowBattle() then
        setBeginPause()
        require("UI/Guide/FirstBattle")
        FirstBattle.create()
        FirstBattle.open("begin")
        local function callback()
            setBeginContinue()
            FirstBattle.close()
        end
        FirstBattle.setCallBack(callback)
    end





    if(not m_pauseBegin)then
        BattleScene.startBattle();
        BattleMovie.playMovie(BATTLE_MOVIE_BENGIN, nil, gone);
    end
    
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, receiveActorSkin);
    m_skinData = nil;
    m_resultData = nil;
    m_isPlayVedio = false;
end

local function waitMessage()
    if (m_resultData and m_processData and m_skinData) then
        if(MainCityLogic.isOpen() == true)then
            MainCityLogic.removeMainCity();
        end
        m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
        local playerName = UserInfoManager.getRoleInfo("name");
        BattleMovie.setBattlerCamp(m_resultData.name_1 == playerName);
        
        BattleScene.loadBattler(m_skinData, m_resultData, battlerOnReady); --¼ÓÔØ×ÊÔ´
    end
end

local function battlefieldOnReady()
    local uid = UserInfoManager.getRoleInfo("uid");
    if (m_resultData and m_processData and m_skinData) then
        if(MainCityLogic.isOpen() == true)then
            MainCityLogic.removeMainCity();
        end
        local playerName = UserInfoManager.getRoleInfo("name");
        BattleMovie.setBattlerCamp(m_resultData.name_1 == playerName);
        -- setBattleData();
        BattleScene.loadBattler(m_skinData, m_resultData, battlerOnReady);
    else
        m_schedulerEntry = m_scheduler:scheduleScriptFunc(waitMessage, 0, false);
    end
end

local function freeResources()
    SJBattleActor:purgeAnimRes();
    CCArmatureDataManager:purge();
end

function setBattleData()
    m_processData = BattleMovie.convert(m_processData);
end

function enterBattle(battleType, subType, id, fun)
    WorldManager.setCurData({type=battleType,subType=subType,id=id});
    m_type = battleType;
    m_subType = subType;
    m_skinData = nil;
    m_resultData = nil;
    m_processData = nil;
    m_id = id;
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, receiveActorSkin);
    MainCityPlayers.unregisterMessageFunction();
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_BATTLE, {battleType, subType,id});

    -- BattleScene.create("battle1", {m_type, m_subType}, battlefieldOnReady);
    local function beginBattle()
        fun();
        BattleScene.create("battle1", {m_type, m_subType,m_id}, battlefieldOnReady);
    end
    NetMessageResultManager.setCallBackFun(beginBattle);


end                                                                                 

function enterDebugBattle(callFun)
    m_winner = 1;
    m_debugCallBack = callFun;
    m_resultData = {winner = 1, hp_1 = 20000, hp_2 = 50000, maxHp_1 = 20000, maxHp_2 = 50000, name_1 = "jjk", name_2 = "nihao", cycle1 = 10, cycle2 = 20};
    m_skinData = {{hair = 106, face = 106, cloth = 6, color = 1, isAattacker = 0,  uid = "222333", name = "jll"}};
    m_processData = {};
    BattleScene.create("battle1", {1, 1,1}, battlefieldOnReady);
end

function enterBattleRecord(battType,battleSubType,battID,fun)
    WorldManager.setCurData({type=battType,subType=battleSubType,id=battID});
    m_type = battType;
    m_subType = battleSubType;
    m_id = battID;
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, receiveActorSkin);
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_COMBATRECORD, {battID});
    local function beginBattle()
        fun();
        BattleScene.create("battle1", {m_type, m_subType,m_id}, battlefieldOnReady);
    end
    NetMessageResultManager.setCallBackFun(beginBattle);
end

function enterBattleRepeat(fun)
    m_processData = nil;
    m_skinData = nil;
    m_resultData = nil;
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, receiveActorSkin);
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_BATTLE, {m_type, m_subType,m_id});
    local function beginBattle()
        fun();
        BattleScene.create("battle1", {m_type, m_subType,m_id}, battlefieldOnReady);
    end
    NetMessageResultManager.setCallBackFun(beginBattle);
end

function enterBattleForRecord(battleType, subType,battleId)
    -- NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, receiveActorSkin);
    m_isPlayVedio = true;
    m_processData = m_processDataLast;
    m_skinData = m_skinDataLast;
    m_resultData = m_resultDataLast;
    BattleScene.create("battle1", {m_type, m_subType,battleId}, battlefieldOnReady);
end

function gmEnterBattle(battleType, subType)

    CCLuaLog("gmEnterBattle");

    m_type = battleType;
    m_subType = subType;
    m_skinData = nil;
    m_resultData = nil;
    m_processData = nil;

    BattleScene.create("battle1", {battleType, subType}, battlefieldOnReady);
end   
    

function exitBattle(callbackFunc)
    local unloadField = {resType = LOADING_TYPE_BATTLE, resData = {loader = freeResources}};
    local resList = {unloadField};
    Loading.create(resList, callbackFunc);
end

function getWinner()
    return m_winner;
end

function getResult()
    return m_resultData;
end

function getMoney()
    if(DEBUG_MODE)then
        return 1000;
    else
        return m_resultData.money;
    end
end

function getExp()
    if(DEBUG_MODE)then
        return 10000;
    else
        return m_resultData.exp;
    end
end

function init()
    m_sceneData = {{"battle_1", "battle_1"}, {"battle_1", "battle_1"}};
    BattleBuff.loadBuffFile(PATH_RES_DATA .. "BattleBuff.json");
    
    -- local dataManager = CCArmatureDataManager:sharedArmatureDataManager();
end

function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_COMBAT_RESULT, receiveBattleResult);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_COMBAT_PROCESS, receiveBattleProcess);
    -- NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SCENE_PLAYERS, receiveActorSkin);

    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_BATTLE_PVE_RECORD_GE_RESPONS, receiveCommon);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_BATTLE_PVE_RECORD_IT_RESPONS, receiveItem);
end

function getPrizeCommon()
    return m_prizeCommon;
    -- return {exp=2510,money=2560,star=3}
end

function getPrizeItem()
    return m_prizeItem;
    -- return {exp=2510,money=2560}
end

function getBattleData()
    return {m_type,m_subType,m_id};
end

function setDebugMode(isDebug)
    m_debugMode = isDebug;
end

function isDebugMode()
    return m_debugMode;
end

function setDebugSkinData(data)
    if(m_skinData == nil)then
        m_skinData  = {};
    end
    table.insert(m_skinData, data);
 end


