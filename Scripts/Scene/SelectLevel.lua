module("SelectLevel", package.seeall)
require "UI/SelectLevelUI"
SELECT_LEVEL_STATE_NULL = 1;
SELECT_LEVEL_STATE_UNLOCK = 2;
SELECT_LEVEL_STATE_NORMAL = 3;
SELECT_MODE_COMMON = 1;
SELECT_MODE_ELITE = 2;
local m_isRember = false;
local loadAmiArray = {"zhandouzhishi"};
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_schedulerLock = nil;
local m_schedulerArrow = mil;
local m_schedulermsg = nil;
local m_animList = nil;
local m_scene = nil;
local m_mapID = 0;
local m_levelInfo = {};
local m_loadEnd = false;
local m_loadActorAnimComplete = false;
local m_state = SELECT_LEVEL_STATE_NORMAL;
local m_loadAniNames = nil;
local m_touchArray = nil;
local m_aniArray = {};
local m_tmxNode = nil;
local m_curUnLockAni = nil;
local m_mode = 0;
local m_clearAniList = nil;
local m_curPoint = nil;
local m_lastOpenID = 1;
local m_isOpenHide = false;
local m_commonData = {};
local m_eliteData = {};
local m_dataSet = {};
local m_unLockAni = nil;
local ticker=0;
local m_open = false;
local m_missionLevels = nil;
local m_selectedLevel = nil;
local m_rootLayer = nil;
local m_selectedMode = 1;
local m_arrowAni = nil;
function removeCurrentSources()
    remove();
    WorldMap.remove();
end

function getSelectedLevel()
	return m_selectedLevel;
end

function setSelectedLevel(level)
	m_selectedLevel = level
end

function loadScene(sceneID)
	local name = m_mapID .. ".tmx";
	m_tmxNode = initTmxMap(name);
	m_rootLayer:addChild(m_tmxNode);
    local function ccTouchEnded(x, y)--注册触摸事件 
    	
    	for i,v in pairs(m_dataSet[m_mode]) do
    		if(v.rect:containsPoint(CCPointMake(x[1], x[2])) and m_curPoint ~= nil)then
    			-- if(x[1] == m_curPoint.x and x[2] == m_curPoint.y)then
    			if(WorldManager.isUnLock(v.id) or DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. v.id, "isHide") == 1)then
    				--进入战斗 临时代码 
    				local type = 1;
    				local level = v.id;
    				m_selectedLevel = v.id;
    				m_selectedMode = m_mode;
    				UIManager.open("SweepDetail");
    				break;
    			else
    				return;
    			end
    			-- end
    		end
    	end
    end
    local function ccTouchBegan(x,y)
    	for i,v in pairs(m_dataSet[m_mode]) do
    		if(v.rect:containsPoint(CCPointMake(x[1], x[2])))then
    			m_curPoint = {x=x[1],y=x[2]};
    		end
    	end
    	return true;
    end

    local function onTouch(eventType, x, y)
		if eventType == "began" then
			return ccTouchBegan(x,y);
    	-- elseif eventType == "moved" then
     --    	return self:ccTouchMoved(x,y);
    	elseif eventType == "ended" then
        	return ccTouchEnded(x, y);
    	end
    end

    m_rootLayer:setTouchEnabled(true)
    m_rootLayer:registerScriptTouchHandler(onTouch)
	m_loadEnd = true;
end

function isEnd()
	return m_loadEnd;
end

function isOpen()
	return m_open;
end

function create(mapID,isRember)
	m_open = true;
	if(isRember ~= nil)then
		m_isRember = isRember;
	end
	
	m_dataSet = {};
	m_commonData = {};
	m_eliteData = {};
	m_mapID = mapID;
	m_rootLayer = CCLayer:create();
	getGameLayer(SCENE_UI_LAYER):addChild(m_rootLayer);
	local loadScene = {resType = LOADING_DATA_MAP_DATA, resData = {loader = loadScene}};--加载地图信息
	local loadAnim = {resType = LOADING_DATA_MAP_AMATURE, resData = {loader = loadArmature, isEnd = isActorAnimComplete}}; --加载动画资源 
    
    local resList = {loadScene, loadAnim};
    Loading.create(resList, onLoadingEnd,true);
end


function onLoadingEnd()
	--加载完成之后进入状态机器
	m_schedulermsg = m_scheduler:scheduleScriptFunc(updateMessage, 0, false);--消息接收

	Loading.remove();
	rendeUI();
	if(not m_isRember)then
		m_mode = SELECT_MODE_COMMON;
		update(m_dataSet[1]);
		SelectLevelUI.selectMode(1);
	else
		local mode = m_mode;
		m_mode = 0;
		SelectLevelUI.selectMode(mode);
	end





	-- --新手引导
    if TaskManager.getNewState() then
    	if TaskManager.getLocalStepRecord()== 4 then
            UIManager.open("GuiderLayer")
    	end
    end


end

local function isObtain(name)
	if(name == "")then
		return false;
	end
	for i,v in pairs(loadAmiArray)do
		if(v == name)then
			return true;
		end
	end
	table.insert(loadAmiArray,name);
	return false;
end

function initTmxMap(mapName)
	m_missionLevels = NpcInfoManager.getHuntSceneLevels();
	m_clearAniList = CCArray:create();
	local map = CCTMXTiledMap:create(PATH_RES_MAP .. mapName);
	local group = map:objectGroupNamed("obj2");
	local array = group:getObjects();
	local count = array:count();
	for i = 1,count do--关卡层
		local data = {};
		local data1 = {};
		local dic = tolua.cast(array:objectAtIndex(i-1),"CCDictionary");
		local key = "x";
		data.x = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data1.x = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "y";--未开启关卡两种类型统一资源 
		data.y = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data1.y = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "icon";--开启关卡之后的图标动画 
		data.icon = tolua.cast(dic:objectForKey(key),"CCString"):getCString();
		data1.icon = tolua.cast(dic:objectForKey(key),"CCString"):getCString();

		key = "lock";--开启关卡之后的图标动画 
		data.lock = tolua.cast(dic:objectForKey(key),"CCString"):getCString();
		data1.lock = tolua.cast(dic:objectForKey(key),"CCString"):getCString();

		key = "id";
		data.id = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data1.id = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. data.id, "map");
		if(data1.id == 0)then
			data1.id = data.id;
		end
		key = "type";
		data.type = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data1.type = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "levelx";
		data.levelx = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data1.levelx = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "levely";
		data.levely = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data1.levely = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		-- local btn = CCSprite:create(PATH_RES_MAP .. data.res);
		if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. data.id, "isHide") == 1)then
			if(m_missionLevels ~= nil)then
				for i,v in pairs(m_missionLevels)do
					if(v[2] == data.id)then
						table.insert(m_commonData,data);
						break;
					end
				end
			end
		else
			table.insert(m_commonData,data);
			table.insert(m_eliteData,data1);
		end
	end

	local group1 = map:objectGroupNamed("obj3");--触摸区域层 
	local array1 = group1:getObjects();
	local count1 = array1:count();
	for i=1,count1 do
		local dic = tolua.cast(array1:objectAtIndex(i-1),"CCDictionary");
		local data = {};
		local data1 = {};
		local key = "x";
		local x = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "y";
		local y = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "width";
		local width = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "height";
		local height = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		key = "id";
		local id = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
		data.id = id;
		data1.id = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. data.id, "map");
		if(data1.id ==0)then
			data1.id = id;
		end
		local rect = CCRectMake(x, y, width, height);
		data.rect = rect;
	end
	m_dataSet[1] = m_commonData;
	m_dataSet[2] = m_eliteData;
	local group2 = map:objectGroupNamed("obj4");--屏幕动画层
	if(group2)then
		local array2 = group2:getObjects();
		local count2 = array2:count();
		for i=1,count2 do
			local dic = tolua.cast(array2:objectAtIndex(i-1),"CCDictionary");
			local data = {};
			local key = "x";
			data.x = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
			key = "y";
			data.y = tonumber(tolua.cast(dic:objectForKey(key),"CCString"):getCString());
			key = "res";
			data.res = tolua.cast(dic:objectForKey(key),"CCString"):getCString();
			isObtain(data.res);--添加到加载资源列表 
			table.insert(m_aniArray,data);
		end
	end

	return map;
end

function removeData(data)
	for i,v in pairs(data)do 
		if(v.data)then
			v.data.aniIcon:removeFromParentAndCleanup(true);
			v.data.aniIcon = nil;
			if(v.data.anilevel)then
				
				v.data.anilevel:removeFromParentAndCleanup(true);
				v.data.anilevel = nil;
			end
			-- tolua.cast(v.data,"CCNode"):removeFromParentAndCleanup(true);
			v.data = nil;
		end
	end
end

function update(data)
		if(m_arrowAni ~= nil)then
			m_arrowAni:removeFromParentAndCleanup(true);
			m_arrowAni = nil;
		end
		local levelData = WorldManager.getInfo();
		for i,v in pairs(data)do
			local data = {};
			local aniIcon = nil;--关卡动画
			local anilevel = nil;
			if(WorldManager.isUnLock(v.id)) then
				if(v.type == 1)then--小关解锁的 
					aniIcon = ImageView:create();
					aniIcon:loadTexture(PATH_RES_MAP_ICON .. "xianguanka_k.png");
				else
					aniIcon = ImageView:create();
					aniIcon:loadTexture(PATH_RES_MAP_ICON .. v.icon .. ".png");
				end
			else
				if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. v.id, "isHide") == 1)then--隐藏关卡直接出现
					aniIcon = SJArmature:create(v.icon);
				else
					if(v.type == 1)then
						aniIcon = ImageView:create();
						aniIcon:loadTexture(PATH_RES_MAP_ICON .. "xianguanka_g.png");
					else
						aniIcon = ImageView:create();
						aniIcon:loadTexture(PATH_RES_MAP_ICON .. v.lock .. ".png");
					end
				end

			end
			-- aniIcon:setAnchorPoint(ccp(0,1));
			data.aniIcon = aniIcon;
			aniIcon:setPositionX(v.x);
			aniIcon:setPositionY(v.y);
			if(anilevel)then 
				anilevel:setPositionX(aniIcon:getPositionX());
				anilevel:setPositionY(aniIcon:getPositionY() + aniIcon:getContentSize().height/2 + 20);
				m_tmxNode:addChild(anilevel);
			end
			v.data = data;
			m_tmxNode:addChild(aniIcon);
			local rect = CCRectMake(v.x - aniIcon:getContentSize().width/2, v.y - aniIcon:getContentSize().height/2, aniIcon:getContentSize().width, aniIcon:getContentSize().height);
			v.rect = rect;
			if(levelData[v.id].lock == 0)then--当前开启没打的关卡
				m_arrowAni = SJArmature:create("zhandouzhishi");
				m_arrowAni:setPositionX(v.x);
				m_arrowAni:setPositionY(v.y);
				m_arrowAni:setAnchorPoint(ccp(0.5,0.5));
				m_arrowAni:getAnimation():play("stand", 0, 0, 1, 0);
				m_tmxNode:addChild(m_arrowAni);
			end
		end
end

function getDataByIndex(index)
	for i,v in pairs(m_dataSet)do
		for k,m in pairs(v)do
			if(m.id == index)then
				return m;
			end
		end
	end
	return nil;
end

function convertMode(mode)
	if(m_mode == mode)then
		return;
	end
	removeData(m_dataSet[mode]);
	update(m_dataSet[mode]);
	m_mode = mode;
end

function updateMessage(dt)
	local obj = MessageManager.front();
	if(obj)then
		local data = obj[1];
		if(data == GLOBAL_MESSAGE_COMMON)then
			if(m_mode ~= SELECT_MODE_COMMON)then--切换普通模式 
				convertMode(SELECT_MODE_COMMON);
			end
			MessageManager.pop();
		elseif(data == GLOBAL_MESSAGE_ELITE)then--切换精英模式 
			if(m_mode ~= SELECT_MODE_ELITE)then
				convertMode(SELECT_MODE_ELITE);
			end
			MessageManager.pop();
		end
	end

end

function rendeUI()--绘制界面另一ui层 
	SelectLevelUI.open();
end


function remove()--删除界面所有信息
	m_open = false;
	m_isRember = false;
	m_rootLayer:unregisterScriptTouchHandler();
	clearAnimList();
	m_scheduler:unscheduleScriptEntry(m_schedulermsg);
	local layer = getGameLayer(SCENE_UI_LAYER);
	SelectLevelUI.removeFromParent();
	m_levelInfo = nil;
	m_dataSet = nil;
	m_commonData = nil;
	m_eliteData = nil;
	m_rootLayer:removeChild(m_tmxNode,true);
	m_arrowAni = nil;
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer,true);
	m_rootLayer = nil;
	CCTextureCache:sharedTextureCache():removeUnusedTextures();
    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames();
end

function loadArmature(resData)

    if(m_animList ~= nil ) then
        if(m_animList:count() ~= 0) then
            clearAnimList();
	    end	
    end	
	
    m_animList = CCArray:create();
	m_animList:retain();
    for i,v in pairs(loadAmiArray)do
    	m_animList:addObject(CCString:create(PATH_RES_ACTORS .. v .. ".ExportJson"));
    end
    SJArmatureLoader:sharedInstance():addArmatureWithFileListAsync(m_animList, loadAnimComplete);

end

function clearAnimList()
    SJArmatureLoader:sharedInstance():removeArmatureFileInfo(m_animList);
    m_animList:removeAllObjects();
    m_animList:release();
    m_animList = nil;
    m_loadActorAnimComplete = false;
    CCArmatureDataManager:purge();
end   

function loadAnimComplete()
    m_loadActorAnimComplete = true;
end

function isActorAnimComplete()
	return m_loadActorAnimComplete;
end

function convertGLCoordinate(y)
	return SCREEN_HEIGHT - y;
end

function getCurMode()
	return m_mode;
end

function getMapID()
	return m_mapID;
end

function openAppointLevel(id,isRember)
	local mapid = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. id, "belong");
	SelectLevel.create(mapid,isRember);
	m_selectedLevel = id;
    UIManager.open("SweepDetail");
end