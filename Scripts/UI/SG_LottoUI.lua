module("SG_LottoUI", package.seeall)

local m_rootLayer  = nil;

local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器
local m_countLabel = nil;
local m_count = 0;
local m_time = 0;
local m_headIndex = nil;
local m_isHeadApear = false;
local m_selectedIndex = {};
local m_awardListView  = nil;
local m_peopleListView = nil;
local m_awardIndex = nil;
local m_isPreExpain = false;

LITTO_TAG = 1;

FONTZISE = 20
LABEL_POSITION = ccp(125,20); 
ITEMSIZE_PEOPLE = CCSizeMake(250, 40);
BLACKCOLOR = ccc3(0,0,0);

IMG_POSITON = ccp(100,20);
ITEMSIZE_AWARD = CCSizeMake(250, 40);

EXPLAIN_POSITION = ccp(120,-40);
EXPLAIN_TAG = 4;

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("SG_LottoUI");
	end
end 

local function getHeadLayout(index)
	-- body
	local str = "head_layout_" .. index;
	local layout = tolua.cast(m_uiLayer:getWidgetByName(str),"Layout");
	return layout;
end 

local function getChatLayout(index)
	-- body
	local layout = getHeadLayout(index);
	local littoItem = layout:getChildByTag(LITTO_TAG);
	local chatlayer = tolua.cast(littoItem:getChildByName("chat_layout"),"Layout");
	return chatlayer;
end 

local function getHeadImg(index)
	-- body
	local layout = getHeadLayout(index);
	local littoItem = layout:getChildByTag(LITTO_TAG);
	local img = tolua.cast(littoItem:getChildByName("head_img"),"ImageView");
	return img;
end

local function headTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		local tag = sender:getTag();
		table.insert( m_selectedIndex,tag);
		local img = getHeadImg(tag);
		img:setEnabled(false);
	end
end

local function addBtnTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		m_count = m_count + 1;
		m_countLabel:setText(m_count);
	end
end 

local function apprear_dismissChatLayer(i,isAppera)
	-- body
	local layout = getHeadLayout(i);
	local littoItem = layout:getChildByTag(LITTO_TAG);
	local chatlayer = tolua.cast(littoItem:getChildByName("chat_layout"),"Layout");
    chatlayer:setVisible(isAppera);
end 

local function getRandomIndex()
	-- body
	local function getRIndex(index)
		-- body
		for i=1,#m_selectedIndex do
			if m_selectedIndex[i] == index then
				index = math.random(12);
				index = getRIndex(index);
				break;
			end
		end
		return index;
	end 

	local randomIndex = math.random(12);
	local rIndex = nil;
	if table.getn(m_selectedIndex) ~= 0 then
		rIndex = getRIndex(randomIndex);
	else
		rIndex = randomIndex;
	end
	CCLuaLog("rIndex:"..rIndex);
	return rIndex;
end 

local function updateLabelTime(dt)
	-- body
	m_time = m_time + dt;

	if m_time >= 5 then
		local headIndex = getRandomIndex();
		CCLuaLog(headIndex);
		apprear_dismissChatLayer(headIndex,true);
		m_isHeadApear = true;
		m_headIndex = headIndex;
		m_time = 0;
	end

	if m_time >= 3 then
		if m_isHeadApear == true then
			apprear_dismissChatLayer(m_headIndex,false);
			m_isHeadApear = false;
		end
	end
end

local function getExplainLayer(index)
	-- body
	local containLayer = tolua.cast(m_awardListView:getItem(index-1),"ListView");
	local explain = containLayer:getChildByTag(EXPLAIN_TAG);
	return explain;
end 

local function dismissExplain(index)
	-- body
	local explainLayer = getExplainLayer(index);
	explainLayer:setVisible(false);
	m_awardIndex = nil;
	m_isPreExpain = false;
end

local function presentExplain(index)
	-- body
	local explainLayer = getExplainLayer(index);
	explainLayer:setVisible(true);
	m_awardIndex = index;
	m_isPreExpain = true;
end

local function awardTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		local index = sender:getTag();

		if index == m_awardIndex and m_isPreExpain == true then
			dismissExplain(index);
		else 
			if m_awardIndex ~= nil then
				dismissExplain(m_awardIndex);
			end
			presentExplain(index);
		end
    end
end

local function initListView()
	-- body
	local function initPeopleListView(nameStr,goodsStr)
		-- body
		local str = nameStr .. "获得了" .. goodsStr;
		local contentLabel = Label:create();
		local containLayer = Layout:create();
		containLayer:setSize(ITEMSIZE_AWARD)
		containLayer:addChild(contentLabel);
		contentLabel:setText(str);
		contentLabel:setColor(BLACKCOLOR);
		contentLabel:setFontSize(FONTZISE);
		contentLabel:setPosition(LABEL_POSITION);
		m_peopleListView:pushBackCustomItem(containLayer);
	end

	local function initAwardListView(imgTag,i)
		-- body
		local img = ImageView:create();
		img:loadTexture(PATH_CCS_RES.."gold.png");
		img:setPosition(IMG_POSITON);

		local explain = tolua.cast(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SG_awardItemUI_1.json"),"Layout");
		explain:setPosition(EXPLAIN_POSITION);
		explain:setVisible(false);
		explain:setTag(EXPLAIN_TAG);

		local containLayer = Layout:create();
		containLayer:setSize(ITEMSIZE_PEOPLE)
		containLayer:setTouchEnabled(true);
		containLayer:addChild(img);
		containLayer:addChild(explain);
		containLayer:setTag(i);
		containLayer:addTouchEventListener(awardTouchEvent);

		m_awardListView:pushBackCustomItem(containLayer);
	end 

	for i=1,10 do
	 	local nameStr = "Cao";
	 	local goodsStr = "香喷喷的热翔"
	 	initPeopleListView(nameStr,goodsStr);
	end

	for i=1,7 do
		initAwardListView(2,i);
	end

end

local function gameLayoutTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_awardIndex ~= nil then
			dismissExplain(m_awardIndex);
		end
	end
end

local function initVariables()
	-- body
	m_countLabel = nil;
	m_awardListView = nil;
	m_peopleListView = nil;
	
end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	m_time = 0;
	m_count = 3;
	m_headIndex = nil;
	m_selectedIndex = {};

	m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, 1, false);

end

function create()
	-- body
	m_rootLayer = CCLayer:create();
    
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SG_LottoUI_1.json");
	local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    -- m_rootLayer:retain();
    m_uiLayer = uiLayer;

    local countLabel = tolua.cast(uiLayer:getWidgetByName("count_label"),"Label");
    m_countLabel = countLabel;

    local addCountBtn = uiLayer:getWidgetByName("add_btn");
    addCountBtn:addTouchEventListener(addBtnTouchEvent);

    local exitBtn = uiLayer:getWidgetByName("exit_btn");
    exitBtn:addTouchEventListener(exitTouchEvent);

    local awardListView = tolua.cast(uiLayer:getWidgetByName("award_listView"),"ListView");
    m_awardListView = awardListView;


    local peopleListView = tolua.cast(uiLayer:getWidgetByName("people_listView"),"ListView");
    m_peopleListView = peopleListView;

    local gameLayout = uiLayer:getWidgetByName("game_layout");
    gameLayout:addTouchEventListener(gameLayoutTouchEvent);

    for i=1,12 do
    	local str = "head_layout_" .. i;
    	local littoItem = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "litto_itemUI_1.json");
    	local layout = tolua.cast(uiLayer:getWidgetByName(str),"Layout");
 
    	layout:addChild(littoItem);
    	littoItem:setTag(LITTO_TAG);
    	local chatlayer = littoItem:getChildByName("chat_layout");
    	chatlayer:setVisible(false);
    	local img = littoItem:getChildByName("head_img");
    	img:setTag(i);
    	img:addTouchEventListener(headTouchEvent);
    end

    initListView();
end


function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	scheduler:unscheduleScriptEntry(m_schedulerEntry);

	for i=1,7 do
		dismissExplain(i);
	end

	for i=1,10 do
		apprear_dismissChatLayer(i,false);
	end

	m_count = 0;
	m_time = 0;
	m_headIndex = nil;
	m_isHeadApear = false;
	m_selectedIndex = {};
	m_awardIndex = nil;
end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);	
	m_rootLayer:release();
	initVariables();
	m_rootLayer  = nil;
end
