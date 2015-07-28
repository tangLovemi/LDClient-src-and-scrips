module("SettingUI", package.seeall)

local m_rootLayer = nil;


WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 640/2,WINSIZE.height/2 - 400/2);


local CHECK_SELECT = {
	Music  = 1,
	Effect = 2,
	CloseAnimals = 3,
	ShowPeople   = 4,
}

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("SettingUI");
	end
end

local function helpTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end

local function musicCheckTouchEvent(sender,eventType)
	-- body
	if eventType == CHECKBOX_STATE_EVENT_SELECTED then
		

	else


	end
end 

local function effectCheckTouchEvent(sender,eventType)
	-- body
	if eventType == CHECKBOX_STATE_EVENT_SELECTED then


	else


	end
end 

local function closeAnimalsCheckTouchEvent(sender,eventType)
	-- body
	if eventType == CHECKBOX_STATE_EVENT_SELECTED then


	else


	end
end 

local function showPeopleCheckTouchEvent(sender,eventType)
	-- body
	if eventType == CHECKBOX_STATE_EVENT_SELECTED then


	else


	end
end 

local function onTouch(eventType, x, y)
    if eventType == "began" then
    	return true;
    elseif eventType == "ended" then
        UIManager.close("SettingUI");
    end
end


local function initVariables()
	-- body
end

function create()
	-- body
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
  	m_rootLayer:addChild(bgLayer);

	local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SettingUI_1.json");
	uiLayer = TouchGroup:create();
	uiLayer:addWidget(hotelLayer);
	m_rootLayer:addChild(uiLayer);

	hotelLayer:setPosition(SETTING_POSITION);
	-- m_rootLayer:retain();

	local exitBtn = uiLayer:getWidgetByName("exit_btn");
	exitBtn:addTouchEventListener(exitTouchEvent);

	local helpBtn = uiLayer:getWidgetByName("help_btn");
	helpBtn:addTouchEventListener(helpTouchEvent);


	local musicChechBox  = tolua.cast(uiLayer:getWidgetByName("music_chechBox"),"CheckBox");
	local effectChechBox = tolua.cast(uiLayer:getWidgetByName("effect_chechBox"),"CheckBox");
	local closeAnimalsChechBox = tolua.cast(uiLayer:getWidgetByName("closeAnimals_chechBox"),"CheckBox");
	local showPeopleCheckBox   = tolua.cast(uiLayer:getWidgetByName("showPeople_checkBox"),"CheckBox");

	musicChechBox:setSelectedState(true);
	effectChechBox:setSelectedState(true);
	closeAnimalsChechBox:setSelectedState(true);
	showPeopleCheckBox:setSelectedState(true);

	musicChechBox:addEventListenerCheckBox(musicCheckTouchEvent);
	effectChechBox:addEventListenerCheckBox(effectCheckTouchEvent);
	closeAnimalsChechBox:addEventListenerCheckBox(closeAnimalsCheckTouchEvent);
	showPeopleCheckBox:addEventListenerCheckBox(showPeopleCheckTouchEvent);

end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);

end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	initVariables();
end