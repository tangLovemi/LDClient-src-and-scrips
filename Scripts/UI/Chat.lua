module("Chat", package.seeall)

local m_rootLayer = nil;
local m_sendTextField = nil;
local m_chatList  = nil;
local m_itemCount = 0;
local m_listHight  = 0;
local m_selectedChannel = 0;
local m_listPanel = nil;
local m_curType = 0;
local m_item = nil;
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
ITEMCOUNT = 5;
ITEMPOSY  = 60;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(0,0);
local m_isOpen = false
local function moveListPos()
	-- body
	local child = m_chatList:getItem(0);
	if(child ~= nil)then
		child = child:getParent();
		local posy = child:getPositionY();
		local height = child:getContentSize().height;
		if(height <= m_listHight)then
			return;
		end
		if height > m_listHight - ITEMPOSY then
			-- child:setPositionY(height + ITEMPOSY);	
			child:setPositionY(0 + ITEMPOSY);	
			local het = child:getPositionY();
			CCLuaLog("dddddd");
		end
		-- m_chatList:jumpToBottom();
	end

end

local function isScroll()
	local child = m_chatList:getItem(0);
	if(child ~= nil)then
		child = child:getParent();
		local height = child:getContentSize().height;
		local posy = child:getPositionY();
		if height > m_listHight - ITEMPOSY then
			if(child:getPositionY() < 0)then
				return false;
			end	
		end
	end

	return true;
end

-- local function addItemToListView(name,lv,sex,content)
-- 	-- body

-- 	local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ChatContentUI_1.json");
-- 	m_chatList:pushBackCustomItem(item);

-- 	item = item:getChildByName("Panel_22");
-- 	local icon = tolua.cast(item:getChildByName("icon_img"),"ImageView");
-- 	local levelLabel = tolua.cast(item:getChildByName("level_label"),"Label");
-- 	local nameLabel = tolua.cast(item:getChildByName("nameLabel"),"Label");

-- 	local childItem = item:getChildByName("Panel_26");
-- 	local contentLabel = tolua.cast(childItem:getChildByName("content_label"),"Label");

-- 	local lvStr = "vip" .. lv;

-- 	contentLabel:setText(content);
-- 	levelLabel:setText(lvStr);
-- 	nameLabel:setText(name..":");

-- 	moveListPos();
-- end

local function exitTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("Chat");
		print("here i m out ")
	end

end 

local function convertTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then 
		local tag = tolua.cast(sender,"CCNode"):getTag();
		if(tag == 10002)then--world
			m_curType = CHAT_TYPE_WORLD;
			m_selectedChannel = 1;
		elseif(tag == 10003)then--team
			m_curType = CHAT_TYPE_TEAM;
			m_selectedChannel = 1;
		elseif(tag == 10001)then
			m_selectedChannel = 1;
			m_curType = CHAT_TYPE_ALL;
		else
			m_curType = CHAT_TYPE_SYSTEM;
			m_selectedChannel = 1;
		end
		initList();
	end
end 

local function sendChatContentToServer()
	-- body
	-- id content
	local content = m_sendTextField:getStringValue();
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CHAT, {tostring(m_selectedChannel),content});
end

local function sureTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		local chatContent = m_sendTextField:getStringValue();

		-- m_itemCount = m_itemCount + 1;	
		sendChatContentToServer();
		m_sendTextField:setText("");
	end
end

local function initVariables()
	-- body
	
    m_sendTextField = nil;
    -- m_item:release();
    m_chatList:removeAllItems();
    m_itemCount     = 0;
    m_selectedChannel = WORLDCHANNEL;
	m_listHight  = 0;
	m_listPanel = nil;
	
	m_item = nil;
	m_curType = 0;
	-- m_rootLayer     = nil;
end
local function listViewTouchEvent(sender,eventType)

end

local function listScrollTouchEvent(sender,eventType)
	if eventType == SCROLLVIEW_EVENT_SCROLLING then	
		CCLuaLog("ddd");
	end
	
end

local function initItem(data)
	local temp = m_item:clone();
	-- local label = Label:create();
	-- label:setText(tostring(data.ticker));
	-- label:setPosition(ccp(200,20));
	-- label:setColor(ccc3(255,0,0));
	local panel = temp:getChildByName("Panel_22");
	local icon =  tolua.cast(panel:getChildByName("icon_img"),"Layout");
	local vip = tolua.cast(panel:getChildByName("icon_img"),"ImageView");
	local name = tolua.cast(panel:getChildByName("nameLabel"),"Label");
	local contentPanel = tolua.cast(panel:getChildByName("Panel_26"),"Layout");
	local content = tolua.cast(contentPanel:getChildByName("content_label"),"Label");
	if(data.type == 0)then--系统 
		icon:setVisible(false);
		vip:setVisible(false);
		-- name:setText("系统");
		-- local fontSize = name:getFontSize()
		-- local newSizeX = fontSize*(string.len("系统"))/3+fontSize
		-- name:setSize(CCSize(newSizeX,fontSize+7))		
		-- name:setColor(ccc3(255,0,0));
		-- content:setColor(ccc3(255,0,0));
		-- local movedX = newSizeX- 5*fontSize 
		-- content:setPositionX(content:getPositionX()+movedX+5)
		name:setText("")
		local richText = RichText:create()
		
		local element = RichElementText:create(1, ccc3(0,255,0), 255 ,"系统:", "Arial",25);
		richText:pushBackElement(element)
		local element2 = RichElementText:create(1, ccc3(0,255,255), 255 ," "..data.content, "Arial",25);
		richText:pushBackElement(element2)
		richText:setAnchorPoint(ccp(0,0.5))
		name:addChild(richText)

	else 
		-- vip:setText("lv" .. data.viplevel);

		-- local fontSize = name:getFontSize()
		-- local newSizeX = fontSize*(string.len(data.name))/3+fontSize
		-- name:setSize(CCSize(newSizeX,fontSize+7))
		-- name:setColor(ccc3(0,255,0));
		-- name:setText(data.name.."：");
		-- local movedX = newSizeX- 5*fontSize 
		-- content:setPositionX(content:getPositionX()+movedX+5)
		name:setText("")
		-- aaaa:setPosition(0,0)
		local richText = RichText:create()
		local element = RichElementText:create(1, ccc3(0,255,0), 255 ,data.name..":", "Arial",25);
		richText:pushBackElement(element)
		local element2 = RichElementText:create(1, ccc3(0,255,255), 255 ," "..data.content, "Arial",25);
		richText:pushBackElement(element2)
		richText:setAnchorPoint(ccp(0,0.5))
		name:addChild(richText)
		if data.viplevel == 0 then
			vip:setVisible(false);
			-- name:setPositionX(name:getPositionX()-70)
		else
			vip:loadTexture(PATH_CCS_RES.."vip_"..data.viplevel..".png")
		end

	end
	-- content:setText(data.content);
	content:setVisible(false)
	return temp;
end

function addNewMessage(type,data)
	if m_isOpen  then
		if(type == m_curType)then
			local needScroll = isScroll(); 
			local temp = initItem(data);
			m_chatList:pushBackCustomItem(temp);
			if(needScroll)then
				moveListPos();
			end
		end
	end
end

function removeMessage(type)
	if(type == m_curType)then
		m_chatList:removeItem(0);
	end
end


function update1(dt)
	moveListPos();
	m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
end
function initList()
	m_chatList:removeAllItems();
	for i,v in pairs(ChatManager.getData()[m_curType])do
		local temp = initItem(v);
		m_chatList:pushBackCustomItem(temp);
	end
	m_chatList:refreshView();
	m_schedulerEntry = m_scheduler:scheduleScriptFunc(update1, 0, false);
end

function create()
	-- body
	m_selectedChannel = WORLDCHANNEL;
	m_rootLayer = CCLayer:create();
	m_item = tolua.cast(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ChatContentUI_1.json"),"Layout");
	m_item:retain();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ChatUI.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    -- m_rootLayer:addChild(uiLayer);
    m_rootLayer:setPosition(SETTING_POSITION);
    local het = uiLayer:getContentSize().height;
    local allBtn = uiLayer:getWidgetByName("Button_8");
    local worldBtn = uiLayer:getWidgetByName("Button_9");
    local teamBtn = uiLayer:getWidgetByName("Button_13");
    local systemBtn = uiLayer:getWidgetByName("Button_14");
    local list = {};
    table.insert(list,allBtn);
    table.insert(list,worldBtn);
    table.insert(list,teamBtn);
    table.insert(list,systemBtn);

    local sendTextField = uiLayer:getWidgetByName("textfield");
    sendTextFiled = tolua.cast(sendTextField,"TextField");

    local sureBtn = uiLayer:getWidgetByName("send1_img");
    local exitBtn = uiLayer:getWidgetByName("Button_12");

    exitBtn:addTouchEventListener(exitTouchEvent);
    sureBtn:addTouchEventListener(sureTouchEvent);

    m_sendTextField = sendTextFiled;

    local chatList = uiLayer:getWidgetByName("chat_list");
    chatList = tolua.cast(chatList,"ListView");
    m_chatList = chatList;

    m_listHight  = 455;
    m_listPanel = SingleChoicePanel.create(list,convertTouchEvent);
    m_listPanel.selectIndex(1);
	m_chatList:addEventListenerListView(listViewTouchEvent);
	m_chatList:addEventListenerScrollView(listScrollTouchEvent);
	m_rootLayer:addChild(UIManager.bounceOut(uiLayer));
end

function open()
	m_isOpen = true 
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	-- initVariables();
	m_isOpen = false
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end

function remove()
	
end