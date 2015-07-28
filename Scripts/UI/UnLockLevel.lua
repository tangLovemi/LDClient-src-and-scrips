module("UnLockLevel", package.seeall)

local m_rootLayer = nil;
local m_lockID = 0;
local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("UnLockLevel");
    end
end

local function displayUnLock(text, effNode)

    effNode:unregisterAnimEvent(1);
    CCArmatureDataManager:purge();
    local nameImg = ImageView:create();
    nameImg:loadTexture(PATH_CCS_RES .. "guanka_" .. m_lockID .. ".png");
    nameImg:setPosition(ccp(WINSIZE.width/2,WINSIZE.height/2));
    effNode:getAnimation():play("cycle", 0, 0, 1, 0);
    m_rootLayer:addChild(nameImg);
end

function create()
	m_lockID = WorldManager.getUnLockID();
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_UNLOCK_REQUEST,{WorldManager.getCUrOpenMap()});
	m_rootLayer = CCLayer:create();
	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
    m_rootLayer:addChild(bgLayer);
    local jsonPath = PATH_RES_OTHER .. "xinquyukaiqi.ExportJson";
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(jsonPath);
    local armature = SJArmature:create("xinquyukaiqi");
   	armature:registerAnimEvent(1, displayUnLock);
    m_rootLayer:addChild(armature);
	armature:setPositionX(WINSIZE.width/2);
	armature:setPositionY(WINSIZE.height/2);
    armature:getAnimation():play("start", 0, 0, 0, 0);
    -- CCArmatureDataManager:purge();

end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer,1);
	ClipTouchLayer.clear();
end

function close()
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer, true);
	m_rootLayer = nil;
end

function remove()

end