module("OtherPlayer", package.seeall)

--用于创建其他玩家的动画(竞技场、好友)
local m_resNames = {};
local m_actors = {};

function removeAnimation()
    for i,v in ipairs(m_actors) do
        v:release();
        v = nil;
    end
    local roleCoatid = UserInfoManager.getRoleInfo("coat").type;

    for i,v in ipairs(m_resNames) do
        if(v ~= ("Player_" .. roleCoatid)) then
            local armature = PATH_RES_PLAYER .. v .. ".ExportJson";
            local texture = PATH_RES_PLAYER .. v .. "0.png";
            CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(armature);
            CCTextureCache:sharedTextureCache():removeTextureForKey(texture);
        end
    end
    m_resNames = {};
    m_actors = {};
end


local function addActor( actor, resName )
    table.insert(m_actors, actor);
    table.insert(m_resNames, resName);
end


function createAnimation( coatid, faceid, hairid, hairColorid )
    name = "Player_" .. coatid;
    jsonPath = PATH_RES_PLAYER .. name .. ".ExportJson";
    if(coatid <= 0) then
        name = "timo";
        jsonPath = PATH_RES_PLAYER .. "timo.ExportJson";
    end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(jsonPath);
    
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
    CCArmatureDataManager:purge();

    addActor(actor, name);

    return actor;
end