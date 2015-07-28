module("Bless", package.seeall)

local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器

WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 532/2,WINSIZE.height/2 - 339/2);
local m_rootLayer = nil;
local m_uiLayer = nil;

local m_commonPanel = nil;
local m_surePanel = nil;
local m_isBLessingCount = 0;
local m_countLabel = nil;
--local m_sure_messageLabel = nil;

-- local m_blessCardCount = {
-- 	day   = 1,
-- 	week  = 2,
-- 	month = 3,
-- }
m_dayCardCount = 1;
m_weekCardCount = 0;
m_monthCardCount = 3;

local m_blessTime = 0;

BLESS_DAY   = 1;
BLESS_WEEK  = 2;
BLESS_MONTH = 3;

BLESSCOUNT_MAX  = 1;

DIAMOND_DAY     = 30;
DIAMOND_WEEK    = 30*7 - 30;
DIAMOND_MONTH   = 180*5 - 30;

BLESSTIME_DAY  = 24 * 3600;
BLESSTIME_WEEK = 7 * BLESSTIME_DAY;
BLESSTIME_MONTH = 30 * BLESSTIME_DAY;

local function onTouch(eventType,x,y)
	-- body
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then	
		UIManager.close("Bless");
	end
end

local function setBlessToRole_double(tag)
	-- body
	if m_blessingTag == tag then
		m_isBLessingCount = m_isBLessingCount + 1;
	end
end
local function setCardCount( tag )
	if tag == 1 then
		local panel = m_uiLayer:getWidgetByName("card1_panel");
		local count = panel:getChildByName("count");
		count:setText(m_dayCardCount);
	end
	if tag == 2 then
		local panel = m_uiLayer:getWidgetByName("card2_panel");
		local count = panel:getChildByName("count");
		count:setText(m_weekCardCount);
	end
	if tag == 3 then
		local panel = m_uiLayer:getWidgetByName("card3_panel");
		local count = panel:getChildByName("count");
		count:setText(m_monthCardCount);
	end
end
local function setBlessToRole_one(tag)
	-- body
	m_surePanel:setEnabled(true);
	if tag == BLESS_DAY then
		m_blessTime = BLESSTIME_DAY;
		local messageStr = "消耗了\"祝福卡(\"天\")\",进行一次祝福！";
		m_sure_messageLabel:setText(messageStr);
		m_dayCardCount = m_dayCardCount - 1;

		setCardCount(tag);
	elseif tag == BLESS_WEEK then
		m_blessTime = BLESSTIME_WEEK;
		local messageStr = "消耗了\"祝福卡（\"周\"）\",进行一次祝福！";
		m_sure_messageLabel:setText(messageStr);
		m_weekCardCount = m_weekCardCount - 1;

		setCardCount(tag);
	elseif tag == BLESS_MONTH then
		m_blessTime = BLESSTIME_MONTH;
		local messageStr = "消耗了\"祝福卡（\"月\"）\",进行一次祝福！";
		m_sure_messageLabel:setText(messageStr);
		m_monthCardCount = m_monthCardCount - 1;

		setCardCount(tag);
	end 

	m_isBLessingCount = 1;
	m_blessingTag = tag;
end
function changeTime()

	if m_blessTime >0 then
		m_blessTime = m_blessTime -1;
		local time = m_blessTime;
		return time;
	else
		return 0;
	end
end
local function setMessageLabel_Bless(tag)
	-- body
	m_surePanel:setEnabled(true);
	local str = nil;
	if m_blessingTag == tag then
		if tag == BLESS_DAY then
			str = "天";
		elseif tag == BLESS_WEEK then
			str = "周";
		elseif tag == BLESS_MONTH then
			str = "月";
		end
		local messageStr = "消耗\"祝福卡（"..str.."）\",进行第二次祝福！（只提升祝福效果，不增加持续时间）";
		m_sure_messageLabel:setText(messageStr);
	else 
		local messageStr = "祝福类型不同，无法祝福！";
		m_sure_messageLabel:setText(messageStr);
	end
	--m_isBLessingCount = m_isBLessingCount + 1;
end
local function setMessageLabel_MAX()
	-- body
	m_surePanel:setEnabled(true);
	local messageStr = "已经达到上限，无法再祝福";
	m_sure_messageLabel:setText(messageStr);

end


local function setMessageLabel_noBless(tag)
	-- body
	m_surePanel:setEnabled(true);
	local str = nil;
	local diamonCost = 0;
	if tag == BLESS_DAY then
		str = "天";
		diamonCost = DIAMOND_DAY;
	elseif tag == BLESS_WEEK then
		str = "周";
		diamonCost = DIAMOND_WEEK;
	elseif tag == BLESS_MONTH then
		str = "月";
		diamonCost = DIAMOND_MONTH;
	end

	local messageStr = "您没有\"祝福卡（"..str.."）\",是否消耗"..diamonCost .."钻石进行祝福！";
	m_sure_messageLabel:setText(messageStr);

end

local function setCardCountLabel(i,countLabel)
	-- body
	local cardCount = 0;
	if i == BLESS_DAY then
		cardCount = m_dayCardCount;
	end

	if i == BLESS_WEEK then
		cardCount = m_weekCardCount;
	end

	if i == BLESS_MONTH then
		cardCount = m_monthCardCount;
	end

	countLabel:setText(cardCount);
end
local function sureTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		-- if m_isBLessingCount == BLESSCOUNT_MAX then
		-- 	setMessageLabel_MAX();
		-- elseif m_isBLessingCount > 0 and m_isBLessingCount < BLESSCOUNT_MAX then
		-- 	setBlessToRole_double(m_cardSelectTag);
		-- elseif m_isBLessingCount == 0 then
		-- 	setBlessToRole_one(m_cardSelectTag);		
		-- end
		m_surePanel:setEnabled(false);

	end
end
local function cancleTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		m_surePanel:setEnabled(false)
	end
end 

local function getBlessCardCount(tag)
	-- body
	if tag == 1 then
		return m_dayCardCount;
	end

	if tag == 2 then
		return m_weekCardCount;
	end

	if tag == 3 then
		return m_monthCardCount;
	end
end 
local function cardPanelTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		
		local tag = sender:getTag();----1,2,3---
		local count = getBlessCardCount(tag);----1,0,3---
			
		if m_isBLessingCount == 0 then

			if count == 0 then
				setMessageLabel_noBless(tag);
			else
				setBlessToRole_one(tag);
			end

		elseif m_isBLessingCount == BLESSCOUNT_MAX then

			setMessageLabel_MAX();

		end

		-- if count == 0 then
		-- 	m_surePanel:setEnabled(true);
		-- else
		-- 	if m_blessingTag ~= tag  or m_isBLessingCount == BLESSCOUNT_MAX then
		-- 		m_surePanel:setEnabled(true);
		-- 	end
		-- end
		m_cardSelectTag = tag;
	end
end

local function initVariables()

	m_sure_messageLabel = nil;
end

local function initLabel()

	local sure_messageLabel = tolua.cast(m_surePanel:getChildByName("message_label"),"Label");
	m_sure_messageLabel  = sure_messageLabel;
	m_sure_messageLabel:setText("XXXXX");
end 
local function initBless()

	local sureBtn = m_surePanel:getChildByName("sure_panel");
	sureBtn:addTouchEventListener(sureTouchEvent);

	local cancleBtn = m_surePanel:getChildByName("cancle_panel");
	cancleBtn:addTouchEventListener(cancleTouchEvent);

	for i=1,3 do
		local panelStr = "card" .. i .. "_panel";
		local cardPanel = m_uiLayer:getWidgetByName(panelStr);
		cardPanel:addTouchEventListener(cardPanelTouchEvent);

		local countLabel = tolua.cast(cardPanel:getChildByName("count"),"Label");
		m_countLabel = countLabel;		
		setCardCountLabel(i,m_countLabel);

		cardPanel:setTag(i);
	end

	--m_commonPanel = commonPanel;
end

function create()

	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
	m_rootLayer:addChild(bgLayer);

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TG_blessingUI_1.json");
	local uiLayer = TouchGroup:create();
	uiLayer:addWidget(uiLayout);
	m_rootLayer:addChild(uiLayer);
	--确认窗口
	local surePanel = uiLayer:getWidgetByName("surePanel");
    m_surePanel = surePanel;
    surePanel:setEnabled(false);

	uiLayout:setPosition(SETTING_POSITION);
	-- m_rootLayer:retain();
	m_uiLayer = uiLayer;
end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	initBless();
	initLabel();
	m_schedulerEntry = scheduler:scheduleScriptFunc(changeTime, 1, false);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	initVariables();
end

function remove()
	-- body
	
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	m_uiLayer 	= nil;
	
end