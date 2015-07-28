module("BeatDownUI", package.seeall)


local m_rootLayer = nil;
local m_applyBtn = nil;
local m_myGameBtn = nil;
local m_liveBtn = nil;
local m_betBtn = nil;
local m_uiLayer = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 1136/2,WINSIZE.height/2 - 640/2);


local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("BeatDownUI");
	end
end

local function rewardTouchEvent(sender,eventType)
	-- body

	if eventType == TOUCH_EVENT_TYPE_END then
	end
end

local function applyTouchEvent(sender,eventType)
	-- body

	if eventType == TOUCH_EVENT_TYPE_END then
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURNAMENT_APPLY, {});
	end

end

local function myGameTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if(TournamentManager.getState().isBattle == 1)then
			UIManager.open("BD_MyGameUI");
		else
			Util.showOperateResultPrompt("没有您的比赛");
		end
		
	end
end

local function liveTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if(TournamentManager.getState().isVideo == 0)then--**
			Util.showOperateResultPrompt("没有比赛可以可以观看");
			return;
		end
		UIManager.open("LastLiveUI");
	end
end

local function betTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("MyBetUI");
	end
end

local function initVariables()
	-- body
end

local function onTouch(eventType, x, y)
    if eventType == "began" then
    	return true;
    elseif eventType == "ended" then
        UIManager.close("BeatDownUI");
    end
end
local function closeSelf(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("BeatDownUI");
	end
end
function create()
	-- body
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
  	m_rootLayer:addChild(bgLayer);

	local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "BeatDownUI_1.json");
	m_uiLayer = TouchGroup:create();
	m_uiLayer:addWidget(hotelLayer);
	-- m_rootLayer:addChild(m_uiLayer);
	local closeBtn = tolua.cast(m_uiLayer:getWidgetByName("Image_8"),"Layout");
	closeBtn:addTouchEventListener(closeSelf);
	m_uiLayer:setPosition(SETTING_POSITION);
	-- m_rootLayer:retain();

  	-- local exitBtn = guiLayer:getWidgetByName("exit_btn");
  	-- exitBtn:addTouchEventListener(exitTouchEvent);

  	-- local rewardBtn = guiLayer:getWidgetByName("reward_btn");
  	-- rewardBtn:addTouchEventListener(rewardTouchEvent);

  	m_applyBtn = m_uiLayer:getWidgetByName("bgd_btn1");
  	m_applyBtn:addTouchEventListener(applyTouchEvent);

  	m_myGameBtn = m_uiLayer:getWidgetByName("bgd_btn2");
  	m_myGameBtn:addTouchEventListener(myGameTouchEvent);

  	m_liveBtn = m_uiLayer:getWidgetByName("bgd_btn3");
  	m_liveBtn:addTouchEventListener(liveTouchEvent);

  	m_betBtn = m_uiLayer:getWidgetByName("bgd_btn4");
  	m_betBtn:addTouchEventListener(betTouchEvent);
  	m_rootLayer:addChild(UIManager.bounceOut(m_uiLayer));

end

function reflushUI()
	local data = TournamentManager.getState();
	if(data.isJoin ~= 1)then
		m_applyBtn:setTouchEnabled(false);
	end

	if(data.isBet ~= 1)then
		m_betBtn:setTouchEnabled(false);
	end

	if(data.isBattle ~= 1)then
		m_myGameBtn:setTouchEnabled(false);
	end
	local nameLabel = tolua.cast(m_uiLayer:getWidgetByName("Label_6"),"Label");
	if(data.name == "")then
		nameLabel:setText("???");
	else
		nameLabel:setText(data.name);
	end
	-- haieNum,hairColorNum,faceNum,coatNum
	if(data.name ~= "")then
		local portrait = Util.createHeadLayout(data.hair,data.color,data.face,2);

		local portraitPanel = tolua.cast(m_uiLayer:getWidgetByName("portrait"),"Layout");
		-- portrait:setPosition(ccp((portraitPanel:getContentSize().width-portrait:getContentSize().width)/2,(portraitPanel:getContentSize().height-portrait:getContentSize().height)/2));
		portraitPanel:addChild(portrait);
	end

	-- if(data.isVideo == 1)then
	-- 	m_liveBtn:setTouchEnabled(false);
	-- end
end

function open()
	-- body
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURNAMENT_STATE, {});
end

function close()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
	m_rootLayer = nil;
	initVariables();
end

function remove()

end