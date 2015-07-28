module("PlayerActor", package.seeall)

local m_sceneActor = nil;
local m_battleActor = nil;
local m_figureActor = nil;

local m_faceInfo = nil;
local m_isLoadRes = false;
--包括一个主城人物和一个UI中的人物

local m_name = ""; --动画编号(对应于角色的外套编号)
local m_jsonPath = ""; -- .ExportJson

COUNT_FACE = 17; --脸型数量
COUNT_HAIR = 15; --发型数量
COUNT_HAIR_COLOR = 10; --发色数量

--加载脸部所有资源
function initFace(endCB)
	if(not m_isLoadRes) then
		print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ initFace");
		m_isLoadRes = true;
		local sex = "Male";

	 	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache();
	 	local fullPath = PATH_RES_MODULE .. sex .. "/";
	 	-- frameCache:addSpriteFramesWithFile(fullPath .. hairFront .. ".plist");
	 	-- frameCache:addSpriteFramesWithFile(fullPath .. hairBack .. ".plist");
	 	-- frameCache:addSpriteFramesWithFile(fullPath .. face .. ".plist");
	 	-- frameCache:addSpriteFramesWithFile(fullPath .. eyebrows .. ".plist");
	 	-- frameCache:addSpriteFramesWithFile(fullPath .. eyes .. ".plist");
	 	-- frameCache:addSpriteFramesWithFile(fullPath .. mouth .. ".plist");

	 	--face
	 	for i=1,COUNT_FACE do
	 		-- face_faceid
	 		frameCache:addSpriteFramesWithFile(fullPath .. "face_" .. i .. ".plist");
	 	end

	 	-- hair
	 	for i=1,COUNT_HAIR do
	 		for j=1,COUNT_HAIR_COLOR do
	 			-- hair_front_hairid_colorid  前发
	 			local frontFileName = "hair_front_" .. i .. "_" .. j .. ".plist";
	 			frameCache:addSpriteFramesWithFile(fullPath .. frontFileName);
	 			-- hair_beishi_hairid_colorid 后脑勺
	 			local beishiFileName = "hair_beishi_" .. i .. "_" .. j .. ".plist";
	 			frameCache:addSpriteFramesWithFile(fullPath .. beishiFileName);
	 		end
	 	end

	 	-- 头发后辫
	 	for i=1,COUNT_HAIR do
	 		for j=1,COUNT_HAIR_COLOR do
	 			-- hair_other1_hairid_colorid
	 			local other1FileName = "hair_other1_" .. i .. "_" .. j .. ".plist";
	 			frameCache:addSpriteFramesWithFile(fullPath .. other1FileName);
	 		end
	 	end
	end

 	if(endCB) then
 		endCB();
 	end
 end

--释放脸部所有资源
function freeModules()
	if(m_isLoadRes) then
		m_isLoadRes = false;
		print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ freeModules");
	 -- local hairFront = m_faceInfo:valueForKey("hair_front"):getCString();
		-- local hairBack = m_faceInfo:valueForKey("hair_back"):getCString();
		-- local face = m_faceInfo:valueForKey("face"):getCString();
		-- local eyebrows = m_faceInfo:valueForKey("eyebrows"):getCString();
		-- local eyes = m_faceInfo:valueForKey("eyes"):getCString();
		-- local mouth = m_faceInfo:valueForKey("mouth"):getCString();
		-- local goatee = m_faceInfo:valueForKey("goatee"):getCString();
		local sex = "Male";

		local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache();
	 	local fullPath = PATH_RES_MODULE .. sex .. "/";
		-- frameCache:removeSpriteFramesFromFile(fullPath .. hairFront .. ".plist");
		-- frameCache:removeSpriteFramesFromFile(fullPath .. hairBack .. ".plist");
		-- frameCache:removeSpriteFramesFromFile(fullPath .. face .. ".plist");
		-- frameCache:removeSpriteFramesFromFile(fullPath .. eyebrows .. ".plist");
		-- frameCache:removeSpriteFramesFromFile(fullPath .. eyes .. ".plist");
		-- frameCache:removeSpriteFramesFromFile(fullPath .. mouth .. ".plist");
		-- frameCache:removeSpriteFramesFromFile(fullPath .. goatee .. ".plist");

		local textureCache = CCTextureCache:sharedTextureCache();
		-- textureCache:removeTextureForKey(hairFront .. ".png");
		-- textureCache:removeTextureForKey(hairBack .. ".png");
		-- textureCache:removeTextureForKey(face .. ".png");
		-- textureCache:removeTextureForKey(eyebrows .. ".png");
		-- textureCache:removeTextureForKey(eyes .. ".png");
		-- textureCache:removeTextureForKey(mouth .. ".png");
		-- textureCache:removeTextureForKey(goatee .. ".png");

		--face
	 	for i=1,COUNT_FACE do
	 		frameCache:removeSpriteFramesFromFile(fullPath .. "face_" .. i .. ".plist");
 			textureCache:removeTextureForKey("face_" .. i .. ".png");
	 	end

	 	-- hair
	 	for i=1,COUNT_HAIR do
	 		for j=1,COUNT_HAIR_COLOR do
	 			-- hair_front  前发
	 			local frontFileName = "hair_front_" .. i .. "_" .. j;
	 			frameCache:removeSpriteFramesFromFile(fullPath .. frontFileName .. ".plist");
	 			textureCache:removeTextureForKey(frontFileName .. ".png");
	 			-- hair_beishi 后脑勺
	 			local beishiFileName = "hair_beishi_" .. i .. "_" .. j;
	 			frameCache:removeSpriteFramesFromFile(fullPath .. beishiFileName .. ".plist");
	 			textureCache:removeTextureForKey(beishiFileName .. ".png");
	 		end
	 	end

	 	-- 头发后辫
	 	for i=1,COUNT_HAIR do
	 		for j=1,COUNT_HAIR_COLOR do
	 			-- hair_other1
	 			local other1FileName = "hair_other1_" .. i .. "_" .. j .. ".plist";
	 			frameCache:removeSpriteFramesFromFile(fullPath .. other1FileName);
	 			textureCache:removeTextureForKey(other1FileName .. ".png");
	 		end
	 	end
	end
end






-------------------主城动画-----------------------

local function cleanActorRes()
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(m_jsonPath);
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(PATH_RES_PLAYER .. m_name .. "0.plist");
	CCTextureCache:sharedTextureCache():removeTextureForKey(PATH_RES_PLAYER .. m_name .. "0.png");
end

local function createSceneActor()
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_jsonPath);
	m_sceneActor = SJCustomActor:createActor(m_name, -120, 1);
	if(m_faceInfo) then
		m_sceneActor:setActorFace(m_faceInfo);
	end
	m_sceneActor:retain();
	CCArmatureDataManager:purge();
end

local function removeSceneActor()
	m_sceneActor:cleanup();
	m_sceneActor:release();
	m_sceneActor = nil;

	cleanActorRes();
end



-------------------人物动画-----------------------
local function createFigureActor()
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_jsonPath);
	m_figureActor = SJCustomActor:createActor(m_name, -120, 1);

	if(m_faceInfo) then
		m_figureActor:setActorFace(m_faceInfo);
	end
	m_figureActor:retain();
    m_figureActor:setAction("stand", -1);

	CCArmatureDataManager:purge();
end

local function removeFigureActor()
	m_figureActor:cleanup();
	m_figureActor:release();
	m_figureActor = nil;
end


-- 主城、UI中两个角色动画的创建和销毁是同步的
local function createPlayerActor()
	createSceneActor();
	createFigureActor();
end

local m_coatid = 0;
local m_faceInfoData = {};

--角色动画资源
local function initAnimData()
	m_coatid = UserInfoManager.getRoleInfo("coat").type;
	-- local coatid = 12;
	m_name = "Player_" .. m_coatid;
	m_jsonPath = PATH_RES_PLAYER .. m_name .. ".ExportJson";
	if(m_coatid <= 0) then
		m_name = "timo";
		m_jsonPath = PATH_RES_PLAYER .. "timo.ExportJson";
	end
end

local function initFaceData()
	--角色脸部资源
	local faceinfoData = UserInfoManager.getAllFaceInfo();
	m_faceInfoData.face = faceinfoData.face;
	m_faceInfoData.hair = faceinfoData.hair;
	m_faceInfoData.hairColor = faceinfoData.hair_color.r;
    local faceid = m_faceInfoData.face;
    local hairid = m_faceInfoData.hair;
    local hairColorid = m_faceInfoData.hairColor;
    if(faceid > 0 and hairid > 0 and hairColorid > 0) then
		local hairFront = "hair_front_" .. hairid .. "_" .. hairColorid;
		local face = "face_" .. faceid;
		local hairOther1 = "hair_other1_" .. hairid .. "_" .. hairColorid;

	 	m_faceInfo = CCDictionary:create();
	 	m_faceInfo:retain();
	 	m_faceInfo:setObject(CCString:create(hairFront .. ".png"), "hair_front");
	 	m_faceInfo:setObject(CCString:create(face .. ".png"), "face");
	 	m_faceInfo:setObject(CCString:create(hairOther1 .. ".png"), "hair_other1");
    end
end

local function initPlayerData()
	initAnimData();
	initFaceData();
end

-------------------对外接口-----------------------

function removePlayerActor()
	removeSceneActor();
	removeFigureActor();
end

--登录初始化角色动画
function initPlayerActor(endCB)
	m_faceInfo = nil;
	initPlayerData();
	createPlayerActor();
	if(endCB) then
		endCB();
	end
end

--更改角色动画 (更换外套时)
function changePlayerActor()
	initPlayerData();
	removePlayerActor();
	createPlayerActor();
end

--更改角色脸部动画 (捏脸)
function changeFace(faceInfo)
	if(faceInfo) then
		m_faceInfoData = faceInfo;
	    local faceid = m_faceInfoData.face;
	    local hairid = m_faceInfoData.hair;
	    local hairColorid = m_faceInfoData.hairColor;
	    if(faceid > 0 and hairid > 0 and hairColorid > 0) then
			local hairFront = "hair_front_" .. hairid .. "_" .. hairColorid;
			local face = "face_" .. faceid;
			local hairOther1 = "hair_other1_" .. hairid .. "_" .. hairColorid;

		 	faceInfo_di = CCDictionary:create();
		 	faceInfo_di:retain();
		 	faceInfo_di:setObject(CCString:create(hairFront .. ".png"), "hair_front");
		 	faceInfo_di:setObject(CCString:create(face .. ".png"), "face");
	 		faceInfo_di:setObject(CCString:create(hairOther1 .. ".png"), "hair_other1");
			m_sceneActor:setActorFace(faceInfo_di);
			m_figureActor:setActorFace(faceInfo_di);
	    end
	else
		initPlayerData();
		m_sceneActor:setActorFace(m_faceInfo);
		m_figureActor:setActorFace(m_faceInfo);
	end
end


function getFigureActor()
	return m_figureActor;
end


function getSceneActor()
	return m_sceneActor;
end


function getCurCoatid()
	return m_coatid;
end

function isChange()
    local coat = UserInfoManager.getRoleInfo("coat").type;
	local faceinfoData = UserInfoManager.getAllFaceInfo();
	local face = faceinfoData.face;
	local hair = faceinfoData.hair;
	local hairColor = faceinfoData.hair_color.r;
	if(coat ~= m_coatid or face ~= m_faceInfoData.face or hair ~= m_faceInfoData.hair or hairColor ~= m_faceInfoData.hairColor) then
		return true;
	end
	return false;
end