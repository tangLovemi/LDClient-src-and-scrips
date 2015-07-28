module("Notice",package.seeall)

local m_anouceLabel = nil
local m_rootLayer = nil
local m_noticeContent = {};

local function changeLabelData(lableString)
	-- body
	m_anouceLabel:setText(lableString)
end 

local  function backBtnTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
	   UIManager.close("Notice");
	end
end 

--每个标题的按钮
local function title1TouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		print("title1TouchEvent!")
		local lableString = m_noticeContent.content1;
		changeLabelData(lableString)
	end
end

local function title2TouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		print("title2TouchEvent!")
		local lableString = m_noticeContent.content2;
		changeLabelData(lableString)
	end
end 

local function title3TouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		print("title3TouchEvent!")
		local lableString = m_noticeContent.content3;
		changeLabelData(lableString)
	end
end 

local function title4TouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		print("title4TouchEvent!")
		local lableString = m_noticeContent.content4;
		changeLabelData(lableString)
	end
end 

local function title5TouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		print("title5TouchEvent!")
		local lableString = m_noticeContent.content5;
		changeLabelData(lableString)
	end
end 

--网络得到的标题内容
local function receiveDataFromServer(messageType, messageData)
	-- body

	m_noticeContent = {
		content1 = messageData.content1;
		content2 = messageData.content2;
		content3 = messageData.content3;
		content4 = messageData.content4;
		content5 = messageData.content5;
	};

	changeLabelData(m_noticeContent.content1);
	
end

--发送内容协议
local function requestNoticeContent()
	-- body
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_NOTICE, {true});
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_NOTICE, receiveDataFromServer);
end

local function initVariables()
	-- body
	m_anouceLabel = nil;
    m_rootLayer = nil;
    m_noticeContent = {};
end

function  create()
	-- body
	m_rootLayer = CCLayer:create()

	local ancounceLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "AnouceUI_1.json")
	local uiLayer = TouchGroup:create()
	uiLayer:addWidget(ancounceLayer)
	m_rootLayer:addChild(uiLayer)

	-- m_rootLayer:retain();

	local  backBtn = uiLayer:getWidgetByName("backBtn")
	backBtn:addTouchEventListener(backBtnTouchEvent)

	local title1 = uiLayer:getWidgetByName("title1")
	title1:addTouchEventListener(title1TouchEvent)

	local title2 = uiLayer:getWidgetByName("title2")
	title2:addTouchEventListener(title2TouchEvent)

	local title3 = uiLayer:getWidgetByName("title3")
	title3:addTouchEventListener(title3TouchEvent)

	local title4 = uiLayer:getWidgetByName("title4")
	title4:addTouchEventListener(title4TouchEvent)

	local title5 = uiLayer:getWidgetByName("title5")
	title5:addTouchEventListener(title5TouchEvent)

	local anouceMent = uiLayer:getWidgetByName("anouceLabel")
	m_anouceLabel = tolua.cast(anouceMent,"Label")
	m_anouceLabel:setText("");

end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	requestNoticeContent();

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
	initVariables();
end
