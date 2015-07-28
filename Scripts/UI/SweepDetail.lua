module("SweepDetail", package.seeall)

local m_rootLayer = nil;
local m_touchList = nil;
local m_level = 0;
local m_timeLabel = nil;
local m_saoTimes = 0;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 620/2,WINSIZE.height/2 - 420/2);

local function removeCurrentSources()
	UIManager.close("SweepDetail");
	SelectLevel.remove();
    WorldMap.remove();
end

local function onTouch(eventType, x, y)--desc
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("SweepDetail");
    end
end

local function tiaozhanTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then 
		local type = 1;
		local level = SelectLevel.getSelectedLevel();
		if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. level, "isHide") == 1)then
			local  missionLevels = NpcInfoManager.getHuntSceneLevels();
			type = 3;
			for m,n in pairs(missionLevels)do
				if(n[2] == level)then
					level = n[1];
				end
			end
		end
		CCArmatureDataManager:purge();
    	BattleManager.enterBattle(1, type, level,removeCurrentSources);
	end
end 

local function saodangTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then 
		-- tolua.cast(sender,"Button"):setTouchEnabled(false);
		-- if(m_rootLayer ~= nil)then
		-- 	return;
		-- end
		m_saoTimes = sender:getTag();
		ClipTouchLayer.show();
		m_touchList = {};
		table.insert(m_touchList,sender);
		SaoDangManager.setCallBack(normal);
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_REQUEST_SAODAO, {SelectLevel.getSelectedLevel(),sender:getTag()});	
	end
end

function normal()
	for i,v in pairs(m_touchList)do
		tolua.cast(v,"Button"):setTouchEnabled(true);
	end
end

local function goodsOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_BEGIN then
		GoodsDetails.onTouchBegin(sender, sender:getTag());
	elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
		GoodsDetails.onTouchEnd();
	end
end


function setTimes()
	if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_level, "mode") == 2)then
		WorldManager.getInfo()[m_level].level = WorldManager.getInfo()[m_level].level + m_saoTimes;
		if(WorldManager.getInfo()[m_level].level > 3)then
			WorldManager.getInfo()[m_level].level = 3;
		end
	end
	m_timeLabel:setStringValue(tostring(WorldManager.getInfo()[m_level].level));
end

function create()
	m_rootLayer = CCLayer:create();
	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
    m_rootLayer:addChild(bgLayer);
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "guankatankuang_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    uiLayer:setPosition(SETTING_POSITION);
    local curLevel = SelectLevel.getSelectedLevel();
    m_level = SelectLevel.getSelectedLevel();
    local tiaozhanBtn = tolua.cast(uiLayer:getWidgetByName("Button_25"),"Button");
	tiaozhanBtn:addTouchEventListener(tiaozhanTouchEvent);
	local descLabel = tolua.cast(uiLayer:getWidgetByName("Label_30"),"Label");
	descLabel:setText(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. curLevel, "desc"));
	local starPanel = tolua.cast(uiLayer:getWidgetByName("Panel_star"),"Layout");
	local threeBtn = tolua.cast(uiLayer:getWidgetByName("Button_26"),"Button");
	local tenBtn = tolua.cast(uiLayer:getWidgetByName("Button_24"),"Button");
	local oneBtn = tolua.cast(uiLayer:getWidgetByName("Button_23"),"Button");
	local energyLabel = tolua.cast(uiLayer:getWidgetByName("tili_labelNum"),"LabelAtlas");
	local timePanel = tolua.cast(uiLayer:getWidgetByName("Panel_28"),"Layout");
	m_timeLabel = tolua.cast(uiLayer:getWidgetByName("xiaohaocishu_labelNum"),"LabelAtlas");
	local numberLabel = tolua.cast(uiLayer:getWidgetByName("stage_abelNum"),"LabelAtlas");
	numberLabel:setStringValue(tostring(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. SelectLevel.getSelectedLevel(), "subType")));
	local areaNameImg = tolua.cast(uiLayer:getWidgetByName("stagename_img"),"ImageView");
	local areaName = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. SelectLevel.getSelectedLevel(), "mapname");
	if(areaName ~= "")then
		areaNameImg:loadTexture(PATH_CCS_RES .. areaName .. ".png");
	end
	local rewardIDList = {};
	local list = tolua.cast(uiLayer:getWidgetByName("ListView_21"),"ListView");
	local group =  DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. SelectLevel.getSelectedLevel(), "dropGroup");
	for i=5,1,-1 do
		local name = "itemid" .. i;
		local id = DataBaseManager.getValue("drop", DATABASE_HEAD .. group, name);
		if(id ~= 0)then
			table.insert(rewardIDList,id);
		end
	end
	local anchientString = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. SelectLevel.getSelectedLevel(), "fardrop");
	if(anchientString ~= "")then
		local farList = Util.Split(anchientString,";");
		for i,v in pairs(farList)do
			table.insert(rewardIDList,tonumber(v));
		end
	end

	for i,v in pairs(rewardIDList)do
		local res = GoodsManager.getIconPathById(v);
		if(res ~= "")then
			local image = ImageView:create();
			local layout = Layout:create();
			layout:setTouchEnabled(true);

			image:loadTexture(res,0);
			local frame = ImageView:create();
			frame:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(v)),0);
			layout:setSize(frame:getContentSize());
			image:setPosition(ccp(frame:getContentSize().width/2,frame:getContentSize().height/2));
			frame:setPosition(ccp(frame:getContentSize().width/2,frame:getContentSize().height/2));
			layout:addChild(image);
			layout:addChild(frame);
			layout:setTag(v);
			layout:addTouchEventListener(goodsOnClick);
			list:pushBackCustomItem(layout);
		end
	end
	oneBtn:setTag(1);
	tenBtn:setTag(10);
	threeBtn:setTag(3);
	local saodangPanel = tolua.cast(uiLayer:getWidgetByName("Panel_22"),"Layout");--saodangTouchEvent

	-- oneBtn:addTouchEventListener(tiaozhanTouchEvent);
	if(SelectLevel.getCurMode() == 1)then--common mode
		timePanel:setVisible(false);
		energyLabel:setStringValue(tostring(10));
		if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. SelectLevel.getSelectedLevel(), "isHide") == 1)then
			saodangPanel:setVisible(false);
			starPanel:setVisible(false);
			threeBtn:setTouchEnabled(false);
			oneBtn:setTouchEnabled(false);
			tenBtn:setTouchEnabled(false);
			return;
		end
		local type = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. SelectLevel.getSelectedLevel(), "type");
		if(type == 2)then--big
			local starLevel = WorldManager.getInfoByID(SelectLevel.getSelectedLevel()).level;
			if(starLevel == 0)then--first
				saodangPanel:setVisible(false);
				starPanel:setVisible(false);
				threeBtn:setTouchEnabled(false);
				oneBtn:setTouchEnabled(false);
				tenBtn:setTouchEnabled(false);
			else
				for i=1,starLevel do
					local name = "xingxing" .. (3+i) .. "_img";
					local star = tolua.cast(uiLayer:getWidgetByName(name),"ImageView");
					star:setVisible(true);
				end
				tenBtn:setVisible(true);
				threeBtn:setVisible(false);
				threeBtn:setTouchEnabled(false);
				oneBtn:addTouchEventListener(saodangTouchEvent);
				tenBtn:addTouchEventListener(saodangTouchEvent);
			end
		else
			starPanel:setVisible(false);
			saodangPanel:setVisible(false);
			threeBtn:setTouchEnabled(false);
			oneBtn:setTouchEnabled(false);
			tenBtn:setTouchEnabled(false);
		end
	else
		if(not WorldManager.isAcross(SelectLevel.getSelectedLevel()))then--未打过 
			saodangPanel:setVisible(false);
			threeBtn:setTouchEnabled(false);
			oneBtn:setTouchEnabled(false);
			tenBtn:setTouchEnabled(false);
		else
			tenBtn:setVisible(false);
			tenBtn:setTouchEnabled(false);
			threeBtn:setVisible(true);
			threeBtn:setTouchEnabled(true);
			oneBtn:addTouchEventListener(saodangTouchEvent);
			threeBtn:addTouchEventListener(saodangTouchEvent);
		end
		energyLabel:setStringValue(tostring(20));
		m_timeLabel:setStringValue(tostring(WorldManager.getInfoByID(SelectLevel.getSelectedLevel()).level));
		starPanel:setVisible(false);

	end
end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer,1);
end

function close()
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer, true);
	m_rootLayer = nil;
end

function remove()

end
