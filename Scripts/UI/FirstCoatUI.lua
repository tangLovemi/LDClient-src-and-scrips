--
-- Author: Gao Jiefeng
-- Date: 2015-03-19 10:23:19
--
module("FirstCoatUI", package.seeall)
local m_rootLayer = nil 
local m_isCreate  = false
local m_isOpen = false
local m_UILayout = nil
local m_baseLayout = nil
local m_DialogView = nil
local m_dialogContent = nil
local m_dialogID = 1
local m_dialogFrame = nil 
local m_dialogLabel = nil
local m_head2 = nil
local m_suit1Button = nil
local m_suit2Button = nil
local m_suit3Button = nil
local m_suitOKButton = nil
local m_confirmButton = nil 
local m_cancelButton = nil
local m_confirmPanel = nil
local m_selectedCoatID = nil

local m_coatID1 = 140017
local m_coatID2 = 140014
local m_coatID3 = 140009

local m_coatImg1Big     = PATH_CCS_RES.. "xinshou_1_1.png"
local m_coatImg1  = PATH_CCS_RES.. "xinshou_1.png"
local m_coatImg2Big     = PATH_CCS_RES.. "xinshou_2_1.png"
local m_coatImg2  = PATH_CCS_RES.. "xinshou_2.png"
local m_coatImg3Big     = PATH_CCS_RES.. "xinshou_3_1.png"
local m_coatImg3  = PATH_CCS_RES.. "xinshou_3.png"

local function OkOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_confirmPanel:setPosition(ccp(335,250))
	end
end
local function changCoatSucess()
	MainCityLogic.reloadPlayer();
	UIManager.close("FirstCoatUI")
end
local function confirmOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		TaskManager.sendNewGuide({0,m_selectedCoatID,0,0},changCoatSucess)
	end
end

local function cancelOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_confirmPanel:setPosition(ccp(10000,200))
	end
end
local function dialogOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local contents =  Util.Split(string.sub(m_dialogContent[m_dialogID],2,-2),"&")
		local headPostion = contents[2]
		if contents[1]~= "0" then
			m_dialogLabel:setText(contents[1])
			m_dialogID = m_dialogID+1
			if headPostion~= "self" then
				m_head2:setVisible(true)
			else
				m_head2:setVisible(false)
			end
		else
			m_DialogView:setVisible(false)
			m_DialogView:setPosition(ccp(10000,10000))
			m_UILayout:setVisible(true)

		end
	end
end

local function coatOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_selectedCoatID= sender:getTag()
		if m_selectedCoatID == m_coatID1 then
			m_suit1Button:loadTextures(m_coatImg1Big,m_coatImg1Big,m_coatImg1Big)
			m_suit2Button:loadTextures(m_coatImg2,m_coatImg2,m_coatImg2)
			m_suit3Button:loadTextures(m_coatImg3,m_coatImg3,m_coatImg3)
			m_suit1Button:setScale(1)
			m_suit2Button:setScale(0.8)
			m_suit3Button:setScale(0.8)
		elseif m_selectedCoatID == m_coatID2 then
			m_suit1Button:loadTextures(m_coatImg1,m_coatImg1,m_coatImg1)
			m_suit2Button:loadTextures(m_coatImg2Big,m_coatImg2Big,m_coatImg2Big)
			m_suit3Button:loadTextures(m_coatImg3,m_coatImg3,m_coatImg3)
			-- m_suit2Button:setScale(1)
			m_suit1Button:setScale(0.8)
			m_suit2Button:setScale(1)
			m_suit3Button:setScale(0.8)			
		elseif m_selectedCoatID == m_coatID3 then
			m_suit1Button:loadTextures(m_coatImg1,m_coatImg1,m_coatImg1)
			m_suit2Button:loadTextures(m_coatImg2,m_coatImg2,m_coatImg2)
			m_suit3Button:loadTextures(m_coatImg3Big,m_coatImg3Big,m_coatImg3Big)
			-- m_suit3Button:setScale(1)
			m_suit1Button:setScale(0.8)
			m_suit2Button:setScale(0.8)
			m_suit3Button:setScale(1)			
		end
	end
end
function create()
	if (not m_isCreate) then
		m_isCreate = true
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "firstcoatUI_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    m_UILayout:setVisible(false)
	    m_suit1Button = tolua.cast(m_UILayout:getWidgetByName("Button_3"), "Button")
	    m_suit1Button:setTag(m_coatID1)
	    m_suit1Button:addTouchEventListener(coatOnClick)
	    m_suit2Button = tolua.cast(m_UILayout:getWidgetByName("Button_4"), "Button")
	    m_suit2Button:setTag(m_coatID2)
	    m_suit2Button:addTouchEventListener(coatOnClick)  
	    m_suit3Button = tolua.cast(m_UILayout:getWidgetByName("Button_5"), "Button")
	    m_suit3Button:setTag(m_coatID3)
	    m_suit3Button:addTouchEventListener(coatOnClick)
	    m_suit1Button:setScale(0.8)
	    m_suit2Button:setScale(0.8)
	    m_suit3Button:setScale(0.8)


	    m_confirmPanel = tolua.cast(m_UILayout:getWidgetByName("Panel_8"), "Layout")
	    m_confirmPanel:setPosition(ccp(10000,200))
	    -- m_confirmPanel:setAnchorPoint(ccp(0.5,0.5))

		m_suitOKButton = tolua.cast(m_UILayout:getWidgetByName("Button_6"), "Button")
		m_suitOKButton:addTouchEventListener(OkOnClick)
		m_confirmButton  = tolua.cast(m_UILayout:getWidgetByName("Button_10"), "Button")
		m_confirmButton:addTouchEventListener(confirmOnClick)
		m_cancelButton = tolua.cast(m_UILayout:getWidgetByName("Button_12"), "Button")
		m_cancelButton:addTouchEventListener(cancelOnClick)


	    local UISource1 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Dialog_1.json");
	    m_DialogView = TouchGroup:create();
	    m_DialogView:addWidget(UISource1);
	    m_rootLayer:addChild(m_DialogView);

	    local panel = tolua.cast(m_DialogView:getWidgetByName("Panel_20"), "Layout")
	    panel:addTouchEventListener(dialogOnClick);

	    m_dialogLabel = tolua.cast(m_DialogView:getWidgetByName("dialogContent"), "Label");
	    m_head2 = tolua.cast(m_DialogView:getWidgetByName("head2"), "ImageView");
	end
end

function open()
	if (not m_isOpen) then
		m_dialogContent = Util.Split(TEXT.firstCoat,";")
		create();
		m_isOpen = true;
		-- if CCUserDefault:sharedUserDefault():getIntegerForKey(UserInfoManager.getRoleInfo("name")) ==1 then
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)
		-- CCUserDefault:sharedUserDefault():setIntegerForKey(UserInfoManager.getRoleInfo("name"), 2);
		-- end

		local contents =  Util.Split(string.sub(m_dialogContent[m_dialogID],2,-2),"&")
		local headPostion = contents[2]
		if contents[1]~= 0 then
			m_dialogLabel:setText(contents[1])
			m_dialogID = m_dialogID+1
			if headPostion~= "self" then
				m_head2:setVisible(true)
			else
				m_head2:setVisible(false)
			end
		end
	end
end
function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
    end

end

function remove()
	if (m_isCreate) then
		m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
	end
end
