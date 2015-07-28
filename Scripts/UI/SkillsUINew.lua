module("SkillsUINew", package.seeall)

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate = false;
local m_isOpen = false;

local COUNT_PUBLIC_SKILL_CLASS = 31; --公用技能库中技能数量
local COUNT_PUBLIC_SKILL_SELF  = 5; --可装备公用技能数量

local TAG_COAT_SKILL	= 123;
local TAG_WEAPON_SKILL	= 124;
local TAG_PUBLIC_SKILL_BASE = 125;

local m_skillType = {
	TAG_CHOOSE_SKILL	 = 1,
	TAG_CLASS_SKILL 	 = 2,
};

local m_curTag = 0;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_countDown_schedule = nil; -- 倒计时定时器
local m_touchCount = 0;
local m_time = 0;
local DOUBLE_CLICK_SPACE = 0.3;

local m_result = {
	NOT_OPEN = 1,
	NOT_POS  = 2,
	HAVE_CHOOSE = 3,

	IS_COAT  = 4,
	IS_WEAPON = 5
};

local m_text = {
	NOT_OPEN = "没开启",
	NOT_POS  = "没位置",
	HAVE_CHOOSE = "已选择",
	IS_COAT  = "外套技能不可卸载",
	IS_WEAPON = "武器技能不可卸载"

};

local m_infoLayout = nil;
local m_item = nil;
local m_isItemOn = false;
local m_touchLayer = nil;

local m_skillsRect1 = {};
local m_skillsRect2 = {};
local m_itemSize1 = CCSizeMake(80, 80);
local m_itemSize2 = CCSizeMake(60, 60);
local m_skillsRectBig = CCRectMake(378, 53, 383, 71);--已选技能大范围

local m_chooseSkills = {};

-----------------------------------------------------------------
local m_haveNewSkill = false;
function setHaveNewSkill( have )
	m_haveNewSkill = have;
end

--上线检测提示
function checkNotification_login()
    if(m_haveNewSkill) then
    	m_haveNewSkill = false;
        return true;
    end
    return false;
end

function checkNotification_line()
    return checkNotification_login();
end

function checkNotification_close()
    return checkNotification_login();
end

------------------------------------------------------------------

local function bgOnClick( eventType,x,y )
	-- body
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		UIManager.close("SkillsUINew");
	end
end

local function getCoatSkillid()
	local roleCoatType = UserInfoManager.getRoleInfo("coat");
	if(roleCoatType.type > 0) then
		local roleCoatData = UserInfoManager.getBackPackInfo("coat")[roleCoatType.type];
		if(roleCoatData.id > 0) then
			--读外套表，得到技能id
			local id = DataTableManager.getValue("coat_grow_Data", "id_" .. roleCoatData.id, "skillid");
			if(id > 0) then
				return id;
			end
		end
	end
	return 0;
end

local function getWeaponSkillid()
	local roleWeaponData = UserInfoManager.getRoleInfo("weapon");
	if(roleWeaponData.id > 0) then
		if(roleWeaponData.skill > 0) then
			--读武器表,得到技能id
			local id = DataTableManager.getValue("weapon_name_Data", "id_" .. roleWeaponData.id, "skill");
			if(id > 0) then
				return id;
			end
		end
	end
	return 0;
end

--检测某位置是否安装技能
local function isHaveSkill( index )
	return (m_chooseSkills[index] > 0);
end

function changeChooseSkill( index, skillid )
	if(skillid > 0) then
		--装备技能
		local isHave = false;
		for i,v in ipairs(m_chooseSkills) do
			if(v == skillid) then
				isHave = true;
			end
		end
		if(not isHave)then
			m_chooseSkills[index] = skillid;
			Util.showOperateResultPrompt("装备成功");
		else
			Util.showOperateResultPrompt("此技能已装备");
		end
	else
		--卸下技能
		m_chooseSkills[index] = skillid;
	end
	Util.print_lua_table(m_chooseSkills);--------------------------
end

local function getChoosePulbicSkillByIndex( index )
	local id = m_chooseSkills[index];
	if(id > 0) then
		return id;
	end
	return 0;
end

local function getPulbicSkillByIndex( index )
	local id = DataTableManager.getValue("SkillPosData", "id_" .. index, "skillid");
	if(id > 0) then
		return id;
	end
	return 0;
end

local function getSkillidAndTypeByTag(tag)
	local skillid = 0;
	local type = 0;
	if(tag > 0) then
		if(tag == TAG_COAT_SKILL) then
			--外套技能
			skillid = getCoatSkillid();
			type = m_skillType.TAG_CLASS_SKILL;
		elseif(tag == TAG_WEAPON_SKILL) then
			--武器技能
			skillid = getWeaponSkillid();
			type = m_skillType.TAG_CLASS_SKILL;
		elseif(tag > TAG_PUBLIC_SKILL_BASE) then
			--已装备的公用技能
			local index = tag - TAG_PUBLIC_SKILL_BASE;
			skillid = getChoosePulbicSkillByIndex(index);
			type = m_skillType.TAG_CLASS_SKILL;
		else
			--公用技能库
			skillid = getPulbicSkillByIndex(tag);
			type = m_skillType.TAG_CHOOSE_SKILL;
		end
	end
	return skillid, type;
end

--技能是否开启
local function isSkillOpen(skillid)
	local skillsClass = UserInfoManager.getRoleInfo("skills").skillsClass; --已开启的技能
	if(skillsClass and #skillsClass > 0) then
		for i=1,#skillsClass do
			local id = skillsClass[i].skill;
			if(id == skillid) then
				return true;
			end
		end
	end
	return false;
end


function closeInfoPanel()
	m_infoLayout:removeFromParentAndCleanup(false);
end


--技能详细信息
local function showSkillInfo( skillid )
	if(skillid ~= nil and skillid > 0) then
    	m_rootLayer:addChild(m_infoLayout, 10);
    	local nameLabel = tolua.cast(m_infoLayout:getWidgetByName("name_Label"), "Label");
		local typeLable = tolua.cast(m_infoLayout:getWidgetByName("type_Label"), "Label");
		local perLable  = tolua.cast(m_infoLayout:getWidgetByName("per_Label"), "Label");
		local descLabel = tolua.cast(m_infoLayout:getWidgetByName("desc_Label"), "Label");
		local iconImg = tolua.cast(m_infoLayout:getWidgetByName("icon_img"), "ImageView");
		-- print("************ skillid = " .. skillid);
		local data = DataTableManager.getItem("SkillInfoData", "id_" .. skillid);
		nameLabel:setText(data.name);
		typeLable:setText(DataTableManager.getValue("SkillTypeNameData", "id_" .. data.type, "name"));
		perLable:setText(data.per);
		descLabel:setText(data.desc);
		iconImg:loadTexture(Util.getSkillIconPath(skillid, true));
	end
end

--单击
local function touchIcon()
	if(m_curTag > 0) then
		local skillid = getSkillidAndTypeByTag(m_curTag);
		if(skillid > 0) then
			showSkillInfo(skillid);
		else
			showSkillInfo();
		end
	end
end

--判断是否可以拖动
local function canMoveIcon(tag)
	if(m_curTag > TAG_PUBLIC_SKILL_BASE) then
		--卸下技能
		return isHaveSkill(tag - TAG_PUBLIC_SKILL_BASE);
	else
		--装上技能
		local skillid = getSkillidAndTypeByTag(tag);
		return isSkillOpen(skillid);
	end
end

--检测装上或者卸下
local function checkOperate(x, y)
	local itemRect = CCRectMake(x - m_itemSize2.width/2, y - m_itemSize2.height/2, m_itemSize2.width, m_itemSize2.height);
	if(m_curTag > TAG_PUBLIC_SKILL_BASE) then
		--检测卸下
		local index = m_curTag - TAG_PUBLIC_SKILL_BASE;
		-- if(itemRect:intersectsRect(m_skillsRect2[index]) == false) then
		-- 	changeChooseSkill(index, 0);
		-- 	refreshChoolsePublicSkills();
		-- end

		if(itemRect:intersectsRect(m_skillsRectBig) == false) then
			changeChooseSkill(index, 0);
			refreshChoolsePublicSkills();
		end
	else
		--检测装上
		if(itemRect:intersectsRect(m_skillsRectBig)) then
			for i=1,5 do
				if(m_skillsRect1[i]:containsPoint(ccp(x, y))) then
					changeChooseSkill(i, getSkillidAndTypeByTag(m_curTag));
					refreshChoolsePublicSkills();
				end
			end
		end
	end
end

local m_touchOff_x = 0;
local m_touchOff_y = 0;
local DIS = -35;
local function touchBegan( x, y )
    m_touchOff_x = x;
    m_touchOff_y = y;
    return true;
end
local function touchMoved( x, y )
	if(m_isItemOn) then
		m_item:setPosition(ccp(x + DIS, y + DIS));
	end
end
local function touchEnded( x, y )
	if(m_isItemOn) then
		m_isItemOn = false;
		m_item:removeFromParentAndCleanup(false);
		checkOperate(x, y);
	end
end

local function onTouch(eventType, x, y)
    if (eventType == "began") then
        return touchBegan(x, y);
    elseif (eventType == "moved") then
        touchMoved(x, y);
    elseif (eventType == "ended") then
    	touchEnded(x, y);
    end
end

-------------------------------------------------------------------------------
--点击某个技能
function iconOnClick( sender,eventType )
	m_curTag = sender:getTag();
	if(eventType == TOUCH_EVENT_TYPE_BEGIN) then
		
	elseif(eventType == TOUCH_EVENT_TYPE_MOVE) then
		if(not m_isItemOn) then
			if(canMoveIcon(m_curTag)) then
				m_isItemOn = true;
				local iconPanel = nil;
				if(m_curTag > TAG_PUBLIC_SKILL_BASE) then
					--卸下技能
					iconPanel = tolua.cast(m_rootLayout:getWidgetByName("gongyong_panel_" .. (m_curTag - TAG_PUBLIC_SKILL_BASE)), "Layout");
				else
					--装上技能
					iconPanel = tolua.cast(m_rootLayout:getWidgetByName("jineng_panel_" .. m_curTag), "Layout");
				end
				if(iconPanel ~= nil) then
					local skillid = getSkillidAndTypeByTag(m_curTag);
					local point = iconPanel:getParent():convertToWorldSpaceAR(ccp(iconPanel:getPositionX(), iconPanel:getPositionY()));  
					local icon = tolua.cast(m_item:getChildByName("icon_img"), "ImageView");
					local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. skillid .. ".png";
					icon:loadTexture(iconPath);
					m_item:setPosition(ccp(m_touchOff_x + DIS, m_touchOff_y + DIS));
					getGameLayer(SCENE_UI_LAYER):addChild(m_item, TEN_ZORDER);
				end
			end
		end
	elseif eventType == TOUCH_EVENT_TYPE_END then
		--区分是外套技能、武器技能、已选择公用技能 还是 技能库里的技能
		touchIcon();
	end
end

--通过技能id获得此技能在公用技能库中的位置
local function getPublicSkillPosById( skillid )
	local posDatas = DataTableManager.getTableByName("SkillPosData");
	for i=1,COUNT_PUBLIC_SKILL_CLASS do
		if(skillid == posDatas["id_" .. i]["skillid"]) then
			return i;
		end
	end
	return 0;
end

--刷新公用技能库
local function refresh_public_skills()
	--设置图标
	-- 先设置为灰图
	local posDatas = DataTableManager.getTableByName("SkillPosData");
	for i=1,COUNT_PUBLIC_SKILL_CLASS do
		local iconPanel = tolua.cast(m_rootLayout:getWidgetByName("jineng_panel_" .. i), "Layout");
		local iconImg = tolua.cast(iconPanel:getChildByName("jineng_img"), "ImageView");
		local disIconPath = PATH_RES_IMAGE_SKILLS_DISABLE .. "skill_" .. posDatas["id_" .. i]["skillid"] .. ".png";
		iconImg:loadTexture(disIconPath);
	end
	--再设置已开启技能
	local skillsClass = UserInfoManager.getRoleInfo("skills").skillsClass; --已开启的技能
	if(skillsClass and #skillsClass > 0) then
		for i=1,#skillsClass do
			local skillid = skillsClass[i].skill;
			local pos = getPublicSkillPosById(skillid);
			if(pos ~= 0) then
				local iconPanel = tolua.cast(m_rootLayout:getWidgetByName("jineng_panel_" .. pos), "Layout");
				local iconImg = tolua.cast(iconPanel:getChildByName("jineng_img"), "ImageView");
				local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. skillid .. ".png";
				iconImg:loadTexture(iconPath);
				--新开启的技能
				if(skillsClass[i].isNew ~= nil and skillsClass[i].isNew == true) then
					skillsClass[i].isNew = false;
					print("****** 提示 new Skill    pos = " .. pos .. "   skillid = " .. skillid);
				end
			end
		end
	end
end

local function refreshCoatSkill()
	local roleCoatType = UserInfoManager.getRoleInfo("coat");
	local coatPanel = tolua.cast(m_rootLayout:getWidgetByName("waitao_panel"), "Layout");
	local coatIconImg = tolua.cast(coatPanel:getChildByName("jineng_img"), "ImageView");
	local coatSkillid = getCoatSkillid();
	if(coatSkillid > 0) then
		coatIconImg:setEnabled(true);
		local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. coatSkillid .. ".png";
		coatIconImg:loadTexture(iconPath);
	else
		coatIconImg:setEnabled(false);
	end
end

local function refreshWeaponSkill()
	local weaponPanel = tolua.cast(m_rootLayout:getWidgetByName("wuqi_panel"), "Layout");
	local weaponIconImg = tolua.cast(weaponPanel:getChildByName("jineng_img"), "ImageView");
	local weaponSkillid = getWeaponSkillid();
	if(weaponSkillid > 0) then
		weaponIconImg:setEnabled(true);
		local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. weaponSkillid .. ".png";
		weaponIconImg:loadTexture(iconPath);
	else
		weaponIconImg:setEnabled(false);
	end
end

function refreshChoolsePublicSkills()
	for i=1,COUNT_PUBLIC_SKILL_SELF do
		local iconPanel = tolua.cast(m_rootLayout:getWidgetByName("gongyong_panel_" .. i), "Layout");
		local iconImg = tolua.cast(iconPanel:getChildByName("jineng_img"), "ImageView");
		local skillid = getChoosePulbicSkillByIndex(i);
		if(skillid > 0) then
			iconImg:setEnabled(true);
			local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. skillid .. ".png";
			iconImg:loadTexture(iconPath);
		else
			iconImg:setEnabled(false);
		end
	end
end

--已选技能库
local function refresh_choose_skills()
	--先装备外套和武器的技能，再装备公用技能
	--外套
	refreshCoatSkill();

	--武器
	refreshWeaponSkill();

	--公用技能
	refreshChoolsePublicSkills();
end

local function initChoosedSkills()
	m_chooseSkills = {};
	m_chooseSkills = UserInfoManager.getRoleInfo("skills").chooseSkills;
end


--界面打开初始化
local function init()
	m_touchCount = 0;
	m_time = 0;

	m_curTag = 0;
	initChoosedSkills();
	refresh_public_skills();
	refresh_choose_skills();
end

--为每个技能绑定监听
local function boundListener()
	--公用技能库
	for i=1,COUNT_PUBLIC_SKILL_CLASS do
		local iconPanel = tolua.cast(m_rootLayout:getWidgetByName("jineng_panel_" .. i), "Layout");
		iconPanel:setTag(i);
		-- iconPanel:addDoubleTouchEventListener(iconOnDoubleClick);
		iconPanel:addTouchEventListener(iconOnClick);
	end

	--装备技能
	for i=1,COUNT_PUBLIC_SKILL_SELF do
		local iconPanel = tolua.cast(m_rootLayout:getWidgetByName("gongyong_panel_" .. i), "Layout");
		iconPanel:setTag(TAG_PUBLIC_SKILL_BASE + i);
		iconPanel:addTouchEventListener(iconOnClick);
		-- iconPanel:addDoubleTouchEventListener(iconOnDoubleClick);
	end
	--外套技能
	local coatPanel = tolua.cast(m_rootLayout:getWidgetByName("waitao_panel"), "Layout");
	coatPanel:setTag(TAG_COAT_SKILL);
	coatPanel:addTouchEventListener(iconOnClick);
	-- coatPanel:addDoubleTouchEventListener(iconOnDoubleClick);
	--武器技能
	local weaponPanel = tolua.cast(m_rootLayout:getWidgetByName("wuqi_panel"), "Layout");
	weaponPanel:setTag(TAG_WEAPON_SKILL);
	weaponPanel:addTouchEventListener(iconOnClick);
	-- weaponPanel:addDoubleTouchEventListener(iconOnDoubleClick);
end

local function initChooseSkillsPos()
	m_skillsRect1 = {};
	m_skillsRect2 = {};
	for i=1,5 do 
		local iconPanel = tolua.cast(m_rootLayout:getWidgetByName("gongyong_panel_" .. i), "Layout");
		local icon = tolua.cast(iconPanel:getChildByName("jineng_img"), "ImageView");
		local point1 = iconPanel:getParent():convertToWorldSpaceAR(ccp(iconPanel:getPositionX(), iconPanel:getPositionY()));
		local point2 = icon:getParent():convertToWorldSpaceAR(ccp(icon:getPositionX(), icon:getPositionY()));
		m_skillsRect1[i] = CCRectMake(point1.x, point1.y, m_itemSize1.width, m_itemSize1.height);
		m_skillsRect2[i] = CCRectMake(point2.x, point2.y, m_itemSize2.width, m_itemSize2.height);
	end
end

--保存已选择的技能
local function saveChoosedSkills()
	local str = Util.tableToStrBySeparator(m_chooseSkills, ";");
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CHANGESKILL, {str});
end

local function testData()
	local skillOpenStr = "21001;21002;21003;21004;21005;21006;21007;21008;21009;21010;21012;21013;21014;21015;21016;21026;21027;21017;21018;21019;21020;21021;21022;21023;21024;21025;21032;21028;21029;21030;21031";
	local skillOpenData = {skillsStr = skillOpenStr};
	UserInfoManager.receiveDataForRoleSkills(NETWORK_MESSAGE_RECEIVE_ROLE_SKILL_CLAS, skillOpenData);

	-- local skillChooseStr = "0;0;0;0;0";
	-- local skillChooseStr = "21001;21002;0;21004;0"
	-- local skillChooseData = {skillsStr = skillChooseStr};
	-- UserInfoManager.receiveDataForRoleSkills(NETWORK_MESSAGE_RECEIVE_ROLE_SKILL_CHOOSE, skillChooseData);
end

function create()
	-----------------------------------------------测试
    				-- testData();
    -----------------------------------------------测试
    if(not m_isCreate) then
    	m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		m_rootLayer:addChild(bgLayer, 0);
		bgLayer:registerScriptTouchHandler(bgOnClick);
		
	    m_rootLayout = TouchGroup:create();
	    m_rootLayer:addChild(m_rootLayout);
	    m_rootLayout:retain();

		local rootPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SkillUI.json");
	    m_rootLayout:addWidget(rootPanel);


	    boundListener();

	    --详细信息面板
	    m_infoLayout = TouchGroup:create();
	    local infoPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Skill_DatailsUI.json");
	    infoPanel:addTouchEventListener(closeInfoPanel);
	    m_infoLayout:addWidget(infoPanel);
	    m_infoLayout:retain();

	    m_item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Skill_ItemUI.json");
	    m_item:retain();

	    m_touchLayer = CCLayer:create();
	    m_touchLayer:retain();
	    m_touchLayer:setTouchEnabled(true)
    	m_touchLayer:registerScriptTouchHandler(onTouch)

    	initChooseSkillsPos();
    end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;

        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);
        uiLayer:addChild(m_touchLayer, THREE_ZORDER);
        init();
	end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        uiLayer:removeChild(m_touchLayer, false);
        ProgressRadial.close();
        saveChoosedSkills();
        NotificationManager.onCloseCheck("SkillsUINew");
    end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
	    if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    	m_infoLayout:release();
	    	m_infoLayout = nil;
	    	m_item:release();
	    	m_item = nil;
	   	 	m_touchLayer:release();
	    	m_touchLayer = nil;
	    end
	    m_rootLayer = nil;
	    m_rootLayout:release();
	   	m_rootLayout = nil;
	end
end