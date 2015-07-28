module("Upgrade", package.seeall)
local m_rootLayer = nil;
local m_layout = nil;
local m_victoryAnimation = nil;
local m_armature = nil;
local m_isOpen = false
local m_moveDown = 100
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 550/2,WINSIZE.height/2 - 370/2);



local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("Upgrade");
    end
end



function getCount(prelevel,level,key)
	local value = level-prelevel;
	local count = 0;
	for i=prelevel+1,level do
		count = count + DataBaseManager.getValue("exp", DATABASE_HEAD .. i, key);
	end
	return count;
end

function getSkills(prelevel,level)
	local value = level-prelevel;
	local skills = {};
	for i=prelevel+1,level do
		local str = DataBaseManager.getValue("exp", DATABASE_HEAD .. i, "skillopen");
		if(str ~= "")then
			local skills1 = Util.Split(str,";");
			for j,v in pairs(skills1)do
				table.insert(skills,v);
			end
		end
	end
	return skills;
end

function create()
    MainCityLogic.unregisterTouchFunction();
	m_rootLayer = CCLayer:create();
    local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch,false,-99,true);
    m_rootLayer:addChild(bgLayer);
    m_layout = TouchGroup:create();
    m_layout:setVisible(false);
    m_layout:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "upgradeUi_1.json"));
    m_layout:setPosition(SETTING_POSITION);
    m_rootLayer:addChild(m_layout,11);
    if(m_armature == nil)then
    	local upgradePath = PATH_RES_ACTORS .."shengjila.ExportJson";
    	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(upgradePath);
    	m_armature = SJArmature:create("shengjila");
    	m_armature:retain();
    	CCArmatureDataManager:purge();
    end
    local preLevel = UserInfoManager.getRoleInfo("preLevel");
    local curLevel = UserInfoManager.getRoleInfo("level");
    local level_labelNum = tolua.cast(m_layout:getWidgetByName("level_labelNum"),"LabelAtlas");
    local level1_labelNum = tolua.cast(m_layout:getWidgetByName("level1_labelNum"),"LabelAtlas");
    level_labelNum:setStringValue(tostring(preLevel));
    level1_labelNum:setStringValue(tostring(curLevel));




    local tili_labelNum = tolua.cast(m_layout:getWidgetByName("tili_labelNum"),"LabelAtlas");
    local tili1_labelNum = tolua.cast(m_layout:getWidgetByName("tili1_labelNum"),"LabelAtlas");
    tili_labelNum:setStringValue(tostring(UserInfoManager.getRoleInfo("physic")-(UserInfoManager.getRoleInfo("level")-1)));
    tili1_labelNum:setStringValue(tostring(UserInfoManager.getRoleInfo("physic")));

    local jinbi_labelNum = tolua.cast(m_layout:getWidgetByName("jinbi_labelNum"),"LabelAtlas");
    local zuanshi_labelNum = tolua.cast(m_layout:getWidgetByName("zuanshi_labelNum"),"LabelAtlas");
    jinbi_labelNum:setStringValue(tostring(getCount(preLevel,curLevel,"money")));
    zuanshi_labelNum:setStringValue(tostring(getCount(preLevel,curLevel,"token")));

	local ListView_skills = tolua.cast(m_layout:getWidgetByName("ListView_skills"),"ListView");
	local skills = getSkills(preLevel,curLevel);
    for i,v in pairs(skills)do
    	local icon = Util.getSkillIconByID(v, true);
    	ListView_skills:pushBackCustomItem(icon);
    end
    UserInfoManager.setRoleInfo("preLevel",curLevel);
end

function displayUpgrade(text, effNode)
    m_layout:setVisible(true);
    m_armature:unregisterAnimEvent(1);
    m_armature:getAnimation():play("cycle", 0, 0, 1, 0);
end

function open()
    m_isOpen = true 
    m_armature:registerAnimEvent(1, displayUpgrade);
    m_rootLayer:addChild(m_armature);
	m_armature:setPositionX(WINSIZE.width/2-100);
	m_armature:setPositionY(WINSIZE.height/2-100+30);
    m_armature:getAnimation():play("start", 0, 0, 0, 0);
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(m_rootLayer, 10);
    AudioEngine.playEffect(PATH_RES_AUDIO.."renwushengji.mp3")
end


function close()
    if(m_isOpen) then
        MainCityLogic.registerTouchFunction();
        m_isOpen = false
    	local uiLayer = getGameLayer(SCENE_UI_LAYER,100);
    	m_rootLayer:unregisterScriptTouchHandler();
        uiLayer:removeChild(m_rootLayer, true);
        m_layout = nil;
    	m_rootLayer = nil;
    end

end

function remove()

end

function getOpenState( )
    return m_isOpen
end