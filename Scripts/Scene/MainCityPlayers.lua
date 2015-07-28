module("MainCityPlayers", package.seeall)

local m_playerInfo = nil;
local m_actors = nil;
local m_jsonFiles = nil;

local m_rootNode = nil;

local m_partCount = {
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1},
        {hair_front = 1, hair_back = 1, face = 1, eyebrows = 1, eyes = 1, mouth = 1, goatee = 1, chest = 1, belly = 1, cross = 1, boom_front = 1, forearm_front = 1, hand_front = 1, boom_back = 1, 
        foream_back = 1, hand_back = 1, thigh_front = 1, calf_front = 1, foot_front = 1, thigh_back = 1, calf_back = 1, foot_back = 1, decoration_back = 1, decoration_front1 = 1, decoration_front2 = 1, weapon = 1}
};

local function addActor( actor, jsonPath )
    table.insert(m_actors, actor);
    table.insert(m_jsonFiles, jsonPath);
end

local function createPlayerActor(playerinfo, index)
    -- name = "Player_" .. 11;
    name = "Player_" .. playerinfo.cloth;
    jsonPath = PATH_RES_PLAYER .. name .. ".ExportJson";
    plistPath = PATH_RES_PLAYER .. name .. "0.plist";
    if(playerinfo.cloth <= 0) then
        name = "Player_12";
        jsonPath = PATH_RES_PLAYER .. "Player_12.ExportJson";
        plistPath = PATH_RES_PLAYER .. "Player_120.plist";
    end
    print("***** cloth = " .. playerinfo.cloth);
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(jsonPath);


    -- P_z_cultivation_3

    local angleMax = m_rootNode:getSceneLength();
    math.randomseed(tostring(os.time()):reverse():sub(1, 10));

    local faceid = playerinfo.face;
    local hairid = playerinfo.hair;
    local hairColorid = playerinfo.color;

    if(faceid == 0) then
        faceid = math.random(FaceMakerNew.getFaceCount());
    end
    if(hairid == 0) then
        hairid = math.random(FaceMakerNew.getHairCount());
    end
    if(hairColorid == 0) then
        hairColorid = math.random(FaceMakerNew.getColorCount());
    end
    
    local hairFront = "hair_front_" .. hairid .. "_" .. hairColorid;
    local face = "face_" .. faceid;
    local hairOther1 = "hair_other1_" .. hairid .. "_" .. hairColorid;

    local faceInfo = CCDictionary:create();
    faceInfo:retain();
    faceInfo:setObject(CCString:create(hairFront .. ".png"), "hair_front");
    faceInfo:setObject(CCString:create(face .. ".png"), "face");
    faceInfo:setObject(CCString:create(hairOther1 .. ".png"), "hair_other1");

    local actor = SJCustomActor:createActor(name, -120, 1);
    actor:setActorFace(faceInfo);
    actor:retain();

    m_rootNode:addActor(actor, 9, -10 - index);--加入场景
    actor:setRotation(math.random(angleMax * 2) - angleMax);
    MainCityActorAI.addActor(actor, 5, 10, 0);
    addActor(actor, jsonPath);
    
    -- m_playerInfo = nil;
    CCArmatureDataManager:purge();
end

function requestPlayerInfo(secneID, rootNode)
    m_rootNode = rootNode;
    m_actors = {};
    m_jsonFiles = {};
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CITY_PLAYERS_LIST, {});
end

local function addAPartFramesToList(fileList, fullName, id, count)
    if (id <= 0) then
        for i = 1, count do
            fileList:addObject(CCString:create(fullName .. (i - 1) .. "_" .. id));
        end
    end
end

function receivePlayerInfo(messageType, messageData)
    local fileList = CCArray:create();
    m_playerInfo = messageData;
    for i,v in ipairs(m_playerInfo) do
        createPlayerActor(v, i);
    end
    -- m_playerInfo = nil;
end

function registerMessageFunction()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_CITY_PLAYERS_LIST, receivePlayerInfo);
end

function unregisterMessageFunction()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_CITY_PLAYERS_LIST, receivePlayerInfo);
end

function runAI()
    -- body
end

function setActorsVisible( visible )
    --1. 显示否
    --2. 接收触摸否
    for i, actor in ipairs(m_actors) do
        actor:setVisible(visible);
        actor:setTouchEnabled(visible);
    end
end

function removePlayers()
    if(m_actors) then
        for i,v in ipairs(m_actors) do
            v:cleanup();
        end
    end
    if(m_jsonFiles) then
        for i,v in ipairs(m_jsonFiles) do
            CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(v);
        end
    end
    m_actors = nil;
    m_jsonFiles = nil;
end

function getPlayersInfo()
    return m_playerInfo;
end