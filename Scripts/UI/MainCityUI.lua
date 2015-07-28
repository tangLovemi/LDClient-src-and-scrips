module("MainCityUI", package.seeall)

require "UI/CoolingTime"

local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry  = nil;   --定时器
local m_rootLayer       = nil;
local m_uiLayer	        = nil;
local m_coolingPanel    = nil;
local m_openCoolingTime = false;
local m_cltimeVisible   = false;
local m_coolingTime     = 0;

local m_disTime         = 3;
local m_chatListView    = nil;


OPENARER_POSITION_OPEN  = ccp(0,328);
OPENARER_POSITION_CLOSE = ccp(-95,328);

CHANNEL_SYSTEM   = 1;
CHANNEL_WORLD    = 2;
CHANNEL_PERSOANL = 3;
CHANNEL_FACTION  = 4;

local m_isCreate = false;
local m_isOpen = false;
local m_funcBtns_h = {};
local m_funcBtns_s = {};
local m_funcBtns_pos_h = {};
local m_funcBtns_pos_s = {};
local m_checkBoxPos = nil;
local MOVE_TIME = 0.2;
local m_switchBox = nil;


local m_notificationList = {}
local function openClTimeLabel()
	-- body
	if m_cltimeVisible == false then
		local moveTo = CCMoveTo:create(2,OPENARER_POSITION_OPEN);
		local easeExponentialOut = CCEaseExponentialOut:create(moveTo);
		m_coolingPanel:runAction(easeExponentialOut);
		m_cltimeVisible = true;
	end
end

local function closeClTimeLabel()
	-- body
	if m_cltimeVisible == true then
		local moveTo = CCMoveTo:create(2,OPENARER_POSITION_CLOSE);
		local easeExponentialOut = CCEaseExponentialOut:create(moveTo);
		m_coolingPanel:runAction(easeExponentialOut);
		m_cltimeVisible = false;
	end
end 

local function updateCoolingLable(time)
	-- body
	local str = CoolingTime.timeChangeString(time);
	local coolingLabel = tolua.cast(m_coolingPanel:getChildByName("coolingTime_label"),"Label");
    coolingLabel:setText(str);
end

local function updateLabelTime(dt)
	-- body
	if m_openCoolingTime == true then

		if m_coolingTime <= 0 then
			m_disTime = m_disTime - 1;
			if m_disTime < 0 then
				m_openCoolingTime = false;
			end
			return;				
		end

		m_coolingTime = m_coolingTime - 1;
		updateCoolingLable(m_coolingTime);
	else 
		closeClTimeLabel();
	end
end 

local function initVariables()
	-- body	
	m_schedulerEntry     = nil;   
	m_rootLayer          = nil;
	m_uiLayer			 = nil;
	m_coolingPanel       = nil;
	m_openCoolingTime    = false;
	m_cltimeVisible      = false;
	m_coolingTime        = 0;
	m_chatListView       = nil;
end 


local function openTheFunc(str)
	-- body
	UIManager.open(str);
end

local function payTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end

local function settingTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		openTheFunc("SettingUI");
	end
end

local function helperTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end 

local function exploreTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		openTheFunc("ExploreUI");
	end
end 

local function chatTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		openTheFunc("Chat");
	end
end

local function chestTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
	end
end

local function rankingTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end 

local function friendTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("FriendsMain");

	end
end 

local function activityTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end

local function taskTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end 

local function backpackTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		openTheFunc("Backpack");
	end
end

local function skillTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end 

local function coolingPanelTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		closeClTimeLabel();
	end
end 

local function coolingBtnTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end 

local function setChatItemContent(item,chatContent)
	-- body
	local channelLabel = tolua.cast(item:getChildByName("channel_label"),"Label");
	local nameLabel    = tolua.cast(item:getChildByName("name_label"),"Label");
	local contentLabel = tolua.cast(item:getChildByName("contentLabel"),"Label");

	local channel    = chatContent[1];
	local channelStr = nil;
	if     channel == CHANNEL_WORLD then
		channelStr = "世界";
	elseif channel == CHANNEL_SYSTEM then
		channelStr = "系统";
	elseif channel == CHANNEL_PERSOANL then
		channelStr = "私聊";
	elseif channel == CHANNEL_FACTION then
		channelStr = "帮派";
	end

	local nameStr    = chatContent[2];
	local contentStr = chatContent[3];

	channelLabel:setText(channelStr);
	nameLabel:setText(nameStr);
	contentLabel:setText(contentStr);

end

local function updateChatListView(contents)
	-- body
	for i=1,2 do
		local item = m_chatListView:getItem(i-1);
		setChatItemContent(item,contents[i]);
	end

end

function openTheCoolingTime(time)
	-- body
	m_coolingTime = time;
	m_openCoolingTime = true;
	openClTimeLabel();
end


--背包
local function panel_h_1_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("BackpackNew");
	end
end

--衣柜
local function panel_h_2_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("Wardrobe");
	end
end

--技能
local function panel_h_3_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("SkillsUINew");
	end
end

--点金
local function panel_h_4_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        -- UIManager.open("TrainUI");
		-- UIManager.open("Bank");
		-- UIManager.open("FaceMakerNew", FACEMAKER_STATUS_CHANGE);
		-- UIManager.open("JJCUI");
		-- UIManager.open("PointStar");
		-- local shopType = {typeid = SHOP_NORMAL_BEGIN}--此处普通商店id号要写对应据点普通商店的id号
		-- UIManager.open("Shop", shopType);
		-- local shopType = {typeid = SHOP_EXCHANGE}--此处普通商店id号要写对应据点普通商店的id号
		-- UIManager.open("Shop", shopType);
		-- local shopType = {typeid = SHOP_MYSTERY}--此处普通商店id号要写对应据点普通商店的id号
		-- UIManager.open("Shop", shopType);
		-- UIManager.open("Mail");
		-- UIManager.open("Transform");
        -- UIManager.open("SoulChemical");
        -- UIManager.open("WeaponUI");
        -- UIManager.open("ActivityType");
        -- UIManager.open("Upgrade");
        -- UIManager.open("BeatDownUI");
        -- UIManager.open("Chat");
        -- UIManager.open("AncientMain");
        UIManager.open("PurchaseGold");
	end
end

--好友
local function panel_h_5_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.open("FriendsMain");
	end
end

--主线任务
local function panel_h_6_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("TaskInfoUI")
	end
end

--每日任务
local function panel_h_7_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("DailyTaskUI")
	end
end

--武器
local function panel_h_8_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("WeaponUI")
	end
end
--许愿
local function panel_h_9_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("WishMain")
		-- UIManager.open("SwitchLayer");
	end
end

--竖行
--设置
local function panel_s_1_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end

--邮箱
local function panel_s_2_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("Mail")
	end
end

--签到
local function panel_s_3_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("SignUI");
	end
end

--排行
local function panel_s_4_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		
		UIManager.open("GuiderLayer")
	end
end

--礼包
local function panel_s_5_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("HuntUI")

	end
end
--远古材料
local function panel_s_6_OnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("AncientMain");

	end
end
--聊天
local function chatBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("Chat");
	end
end


--进入世界地图
local function goToMapOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
	    local function openSelect()
			-- local pointid = 1;
	  --      	SelectLevel.openAppointLevel(pointid);
	    end
	    MainCityLogic.removeMainCity();
	    WorldMap.create(openSelect);
	end
end


function isExists()
	return (MainCityUI~= nil and m_isCreate and m_isOpen);
end


local m_faceInfo = {
	face = 0, hair = 0, hairColor = 0, coat = 0
};
local m_headW = 91;
local m_headH = 91;
local m_headPos = ccp(m_headW/2, m_headH/2);

local function refreshFace()
	local userfaceInfo = UserInfoManager.getAllFaceInfo();
	local nowFace = {};
    nowFace.face = userfaceInfo.face;
    nowFace.hair = userfaceInfo.hair;
    nowFace.hairColor = userfaceInfo.hair_color.r;
    nowFace.coat = UserInfoManager.getRoleInfo("coat").type;

    if(nowFace.face ~= m_faceInfo.face or nowFace.hair ~= m_faceInfo.hair or nowFace.hairColor ~= m_faceInfo.hairColor or nowFace.coat ~= m_faceInfo.coat) then
    	m_faceInfo.face = nowFace.face;
    	m_faceInfo.hair = nowFace.hair;
    	m_faceInfo.hairColor = nowFace.hairColor;
    	m_faceInfo.coat = nowFace.coat;
    	--更改头像
    	local headW, headH = Util.getHeadSize();
    	local scaleX = m_headW/headW;
    	local scaleY = m_headH/headH;
    	local headPanel = tolua.cast(m_uiLayer:getWidgetByName("head_panel"), "Layout");
    	headPanel:removeAllNodes();

		local face = Util.createHeadNode(m_faceInfo.hair, m_faceInfo.hairColor, m_faceInfo.face, m_faceInfo.coat);
		face:setScaleX(scaleX);
		face:setScaleY(scaleY);
		face:setPosition(m_headPos);
		headPanel:addNode(face);
    end
end

function refreshDisplay()
	if(MainCityUI~= nil and m_isCreate and m_isOpen) then
		refreshFace();
		--角色名称
		local selfName = UserInfoManager.getRoleInfo("name");
		tolua.cast(m_uiLayer:getWidgetByName("name_label"), "Label"):setText(selfName);
		--级别
		local selfLv = UserInfoManager.getRoleInfo("level");
		tolua.cast(m_uiLayer:getWidgetByName("level_labelNum"), "LabelAtlas"):setStringValue(selfLv);
		ShopListPanel.refreshDisplay();
	end
end

local function resetFaceInfo()
	m_faceInfo.face = 0;
	m_faceInfo.hair = 0;
	m_faceInfo.hairColor = 0;
	m_faceInfo.coat = 0;
end

local function showBtns(isShow)

	local function actionEnd()
		m_switchBox:setTouchEnabled(true);
		for i,v in ipairs(m_funcBtns_h) do
			if(isShow == false) then
				v:setEnabled(false);
			else
				v:setTouchEnabled(true);
			end
		end
		for i,v in ipairs(m_funcBtns_s) do
			if(isShow == false) then
				v:setEnabled(false);
			else
				v:setTouchEnabled(true);
			end
		end
	end

	m_switchBox:setTouchEnabled(false);
	local function createMoveAction( pos )
		local actList = CCArray:create();
	    actList:addObject(CCMoveTo:create(MOVE_TIME, pos));
	    actList:addObject(CCCallFunc:create(actionEnd));
	    return CCSequence:create(actList);
	end

	--横向
	for i,v in ipairs(m_funcBtns_h) do
		v:setEnabled(true);
		v:setTouchEnabled(false);
	    local pos = m_funcBtns_pos_h[i];
	    if(isShow == false) then
	    	pos = m_checkBoxPos;
	    end
	    v:runAction(createMoveAction(pos));
	end
	print()
	--纵向
	for i,v in ipairs(m_funcBtns_s) do
		v:setEnabled(true);
		v:setTouchEnabled(false);
		local pos = m_funcBtns_pos_s[i];
	    if(isShow == false) then
	    	pos = m_checkBoxPos;
	    end
	    v:runAction(createMoveAction(pos));
	end
end

local function switchBoxOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		local is = m_switchBox:getSelectedState();
		showBtns(is);
	end
end

local function openInit()
	m_disTime = 3;

	showBtns(true);
	refreshDisplay();
	m_switchBox:setSelectedState(false);
	if(WorldMapUI.isOpen()) then
		UIManager.close("WorldMapUI");
	end
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MainCityUI_1.json");
		uiLayer = TouchGroup:create();
		uiLayer:addWidget(hotelLayer);
		m_rootLayer:addChild(uiLayer);

		m_rootLayer:retain();
		m_uiLayer = uiLayer;


		-- local coolingPanel = tolua.cast(uiLayer:getWidgetByName("coolingTime_panel"),"Layout");
		-- m_coolingPanel = coolingPanel;
		-- m_coolingPanel:addTouchEventListener(coolingPanelTouchEvent);

		-- local coolingBtn = uiLayer:getWidgetByName("coolingTime_btn");
		-- coolingBtn:addTouchEventListener(coolingBtnTouchEvent);
		-- coolingBtn:setEnabled(false);

		-- local chatListView = tolua.cast(uiLayer:getWidgetByName("chat_listView"),"ListView");
		-- m_chatListView = chatListView;

		-- initChatListView();
		-- initFuncButton();


		m_uiLayer:getWidgetByName("chat_btn"):addTouchEventListener(chatBtnOnClick);

		--背包
		local panel_h_1 = tolua.cast(m_uiLayer:getWidgetByName("h_1_panel"), "Layout");
		panel_h_1:addTouchEventListener(panel_h_1_OnClick);

		--仓库
		local panel_h_2 = tolua.cast(m_uiLayer:getWidgetByName("h_2_panel"), "Layout");
		panel_h_2:addTouchEventListener(panel_h_2_OnClick);

		--铁匠铺
		local panel_h_3 = tolua.cast(m_uiLayer:getWidgetByName("h_3_panel"), "Layout");
		panel_h_3:addTouchEventListener(panel_h_3_OnClick);

		--灵魂炼化
		local panel_h_4 = tolua.cast(m_uiLayer:getWidgetByName("h_4_panel"), "Layout");
		panel_h_4:addTouchEventListener(panel_h_4_OnClick);

	    --衣柜
		local panel_h_5 = tolua.cast(m_uiLayer:getWidgetByName("h_5_panel"), "Layout");
		panel_h_5:addTouchEventListener(panel_h_5_OnClick);

	    --熔炼房
		local panel_h_6 = tolua.cast(m_uiLayer:getWidgetByName("h_6_panel"), "Layout");
		panel_h_6:addTouchEventListener(panel_h_6_OnClick);

		local panel_h_7 = tolua.cast(m_uiLayer:getWidgetByName("h_7_panel"), "Layout");
		panel_h_7:addTouchEventListener(panel_h_7_OnClick);

		local panel_h_8 = tolua.cast(m_uiLayer:getWidgetByName("h_8_panel"), "Layout");
		panel_h_8:addTouchEventListener(panel_h_8_OnClick);

		local panel_h_9 = tolua.cast(m_uiLayer:getWidgetByName("h_9_panel"), "Layout");
		panel_h_9:addTouchEventListener(panel_h_9_OnClick);
		m_funcBtns_h = {};


		table.insert(m_funcBtns_h, panel_h_1);
		table.insert(m_funcBtns_h, panel_h_2);
		table.insert(m_funcBtns_h, panel_h_3);
		table.insert(m_funcBtns_h, panel_h_4);
		table.insert(m_funcBtns_h, panel_h_5);
		table.insert(m_funcBtns_h, panel_h_6);
		table.insert(m_funcBtns_h, panel_h_7);
		table.insert(m_funcBtns_h, panel_h_8);
		table.insert(m_funcBtns_h, panel_h_9);

		for i,v in ipairs(m_funcBtns_h) do
			table.insert(m_funcBtns_pos_h, ccp(v:getPositionX(), v:getPositionY()));
		end


		--衣柜
		local panel_s_1 = tolua.cast(m_uiLayer:getWidgetByName("s_1_panel"), "Layout");
		panel_s_1:addTouchEventListener(panel_s_1_OnClick);

		local panel_s_2 = tolua.cast(m_uiLayer:getWidgetByName("s_2_panel"), "Layout");
		panel_s_2:addTouchEventListener(panel_s_2_OnClick);

		local panel_s_3 = tolua.cast(m_uiLayer:getWidgetByName("s_3_panel"), "Layout");
		panel_s_3:addTouchEventListener(panel_s_3_OnClick);

		local panel_s_4 = tolua.cast(m_uiLayer:getWidgetByName("s_4_panel"), "Layout");
		panel_s_4:addTouchEventListener(panel_s_4_OnClick);

		local panel_s_5 = tolua.cast(m_uiLayer:getWidgetByName("s_5_panel"), "Layout");
		panel_s_5:addTouchEventListener(panel_s_5_OnClick);

		local panel_s_6 = tolua.cast(m_uiLayer:getWidgetByName("s_6_panel"), "Layout");
		panel_s_6:addTouchEventListener(panel_s_6_OnClick);

		m_funcBtns_s = {};
		table.insert(m_funcBtns_s, panel_s_1);
		table.insert(m_funcBtns_s, panel_s_2);
		table.insert(m_funcBtns_s, panel_s_3);
		table.insert(m_funcBtns_s, panel_s_4);
		table.insert(m_funcBtns_s, panel_s_5);
		table.insert(m_funcBtns_s, panel_s_6);
		for i,v in ipairs(m_funcBtns_s) do
			table.insert(m_funcBtns_pos_s, ccp(v:getPositionX(), v:getPositionY()));
		end

		m_switchBox = tolua.cast(m_uiLayer:getWidgetByName("switch_checkBox"), "CheckBox");
		m_switchBox:addTouchEventListener(switchBoxOnClick);
		local boxPanel = tolua.cast(m_uiLayer:getWidgetByName("checkBox_panel"), "Layout");
		m_checkBoxPos = ccp(boxPanel:getPositionX(), boxPanel:getPositionY());

		for i=1,9 do
			local temImg = tolua.cast(m_uiLayer:getWidgetByName("h_"..i.."_img"), "ImageView");
			m_notificationList["h_"..i.."_img"] = temImg
		end

		for i=1,6 do
			local temImg = tolua.cast(m_uiLayer:getWidgetByName("s_"..i.."_img"), "ImageView");
			m_notificationList["s_"..i.."_img"] = temImg
		end


		m_uiLayer:getWidgetByName("maoxian_panel"):addTouchEventListener(goToMapOnClick);
	end
end

function open()
	-- body
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
		
		openInit();
		ShopListPanel.open();
		-- openTheCoolingTime(30);

		-- m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, 1, false);

	end
end

function close()
	-- body
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		-- scheduler:unscheduleScriptEntry(m_schedulerEntry);
		ShopListPanel.close();
	end
end

function remove()
	-- body
	if(m_isCreate) then
		m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		resetFaceInfo();
		initVariables();
	end
end
function getNotificationImages()
	if(m_isOpen == false) then
		return nil
	end
	return m_notificationList
end

function showChatInfo(data)
	if m_isOpen then
		local chatBtn = m_uiLayer:getWidgetByName("chat_btn")
		
		chatBtn:removeAllChildren()
		local richText = RichText:create()
		local element = RichElementText:create(102, ccc3(0,255,0), 255 ,data.name..":", "Arial",25);
		
		local element2 = RichElementText:create(103, ccc3(0,255,255), 255 ," "..data.content, "Arial",25);
		
		-- richText:setAnchorPoint(ccp(0,0.5))
		-- richText:setPosition(ccp(35,0.5))

		if data.viplevel ~= 0 then
			local vipImag = RichElementImage:create(101, ccc3(0,255,255), 255, PATH_CCS_RES.."vip_"..data.viplevel..".png")
			richText:pushBackElement(vipImag)
		end
		richText:pushBackElement(element)
		richText:pushBackElement(element2)
		-- -- local contentBg = CCScale9Sprite:create()
		-- local aaaaaaaaa = richText:getContentSize()
		-- print(richText:getContentSize().width.."...................."..richText:getContentSize().height)
		local fontSize = 25
		local newSizeX = fontSize*(string.len(data.name..data.content))/2+fontSize
		local  fullRect = CCRectMake(0,0, newSizeX+50, 58);
        local insetRect = CCRectMake(3,3,newSizeX, 58);
		-- contentBg:setContentSize(CCSizeMake(richText:getContentSize().width+50,richText:getContentSize().height))
		local contentBg = CCScale9Sprite:create(PATH_CCS_RES.."zhucheng_xiaoduihuakuang.png",fullRect,insetRect)
		
		contentBg:setAnchorPoint(ccp(0,0.5))
		contentBg:setPosition(ccp(richText:getContentSize().width/2+35,0.5))
		richText:setPosition(ccp(richText:getContentSize().width/2+10,30))
		richText:setAnchorPoint(ccp(0,0.5))
		chatBtn:addNode(contentBg)
		contentBg:addChild(richText)
		require("extern")
		local function callback()
			-- richText:runAction(CCFadeOut:create(3));
			-- chatBtn:removeAllChildren()
			contentBg:removeFromParentAndCleanup(true)
		end
		performWithDelay(chatBtn,callback, 3)
	end
end