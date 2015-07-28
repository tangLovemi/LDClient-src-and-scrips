module("SelectLevelUI", package.seeall)

local m_rootLayer = nil;

local m_energyUpLimit = 0;
local m_schedulerMessage = nil;
local m_rotateLightArray = nil;
local backBtn = nil
local function back(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		close();--跳转到世界地图界面 
	end
end
function setBackBtn()
	backBtn:setTouchEnabled(false)
end
local function convertMode(sender,eventType)
	if (eventType == TOUCH_EVENT_TYPE_END) then
		local object = tolua.cast(sender,"Button");
		selectMode(object:getTag());
	end
	
end
function selectMode(mode)
	if(mode == 1)then--普通模式
		m_commonStateNormal:setVisible(false);
    	m_commonStateHeiLight:setVisible(true);
    	if(not m_eliteStateDisable:isVisible())then
    		m_eliteStateDisable:setVisible(false);
    		m_eliteStateNormal:setVisible(true);
    		m_eliteStateHeiLight:setVisible(false);
    	end
		MessageManager.addMessage({GLOBAL_MESSAGE_COMMON});
	elseif(mode == 2)then--精英模式 
		m_commonStateNormal:setVisible(true);
    	m_commonStateHeiLight:setVisible(false);
    	m_eliteStateDisable:setVisible(false);
    	m_eliteStateNormal:setVisible(false);
    	m_eliteStateHeiLight:setVisible(true);
		MessageManager.addMessage({GLOBAL_MESSAGE_ELITE});
	end
end

local function equireReward(sender,eventType)
	local obj = tolua.cast(sender,"CCNode");
	if eventType == TOUCH_EVENT_TYPE_END then
		tolua.cast(m_rotateLightArray[obj:getTag()],"CCNode"):removeFromParentAndCleanup(true);
		m_rotateLightArray[obj:getTag()] = nil;
		tolua.cast(sender,"Button"):setBright(false);
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MAP_REWARD, {WorldManager.getCurBattleMap(), obj:getTag()});
	end
end

local function isOpenEliteMode()--是否开启精英模式 
	local mapid = WorldManager.getCurBattleMap();
	for i,v in pairs(WorldManager.getInfo())do
		if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. v.id, "mode") == 2
			and DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. v.id, "belong") == mapid and v.lock >= 0)then
			return true;
		end
	end
	return false;
end

function create()
	m_rotateLightArray = {nil,nil,nil};
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "selectlevel.json");
    local uiLayer = TouchGroup:create();
    m_rootLayer:setTouchPriority(0);
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    -- m_rootLayer:retain();

    backBtn = uiLayer:getWidgetByName("back_button");
    backBtn = tolua.cast(backBtn,"Button");
    backBtn:addTouchEventListener(back);

    local commonBtn = uiLayer:getWidgetByName("Image_60_0");--普通模式
    commonBtn:setTag(1);
    commonBtn:addTouchEventListener(convertMode);

    m_commonStateNormal = uiLayer:getWidgetByName("Image_94");
    m_commonStateHeiLight = uiLayer:getWidgetByName("Image_93");
    m_eliteStateDisable = uiLayer:getWidgetByName("Image_89");
    m_eliteStateNormal = uiLayer:getWidgetByName("Image_88");
    m_eliteStateHeiLight = uiLayer:getWidgetByName("Image_87");

    m_commonStateNormal:setVisible(false);
    m_commonStateHeiLight:setVisible(true);
    m_eliteStateDisable:setVisible(true);
    m_eliteStateNormal:setVisible(false);
    m_eliteStateHeiLight:setVisible(false);
    local specilBtn = uiLayer:getWidgetByName("Image_60");--精英模式 
    if(isOpenEliteMode())then--如果精英模未开启 
		specilBtn:setTag(2);
    	specilBtn:addTouchEventListener(convertMode);
    	m_eliteStateDisable:setVisible(false);
    	m_eliteStateNormal:setVisible(true);
    	m_eliteStateHeiLight:setVisible(false);
    end

    local img = tolua.cast(uiLayer:getWidgetByName("Image_86"),"ImageView");
    img:loadTexture(PATH_CCS_RES .. "guanka_" .. SelectLevel.getMapID() .. ".png");

    tolua.cast(uiLayer:getWidgetByName("Panel_6"),"Layout"):addTouchEventListener(back);
    tolua.cast(uiLayer:getWidgetByName("Panel_8"),"Layout"):addTouchEventListener(back);
    tolua.cast(uiLayer:getWidgetByName("Panel_9"),"Layout"):addTouchEventListener(back);
    tolua.cast(uiLayer:getWidgetByName("Panel_10"),"Layout"):addTouchEventListener(back);
end


function open()
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
				--新手引导
			--新手引导
    if TaskManager.getNewState() then
    	UIManager.close("GuiderLayer")
    	-- TaskManager.setLocalStepRecord(2)
        UIManager.open("GuiderLayer")
    end
end



function close()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
	m_rootLayer = nil;
	SelectLevel.remove();
	-- for i,v in pairs(m_rotateLightArray)do
	-- 	if(v ~= nil)then
	-- 		tolua.cast(v,"CCNode"):removeFromParentAndCleanup(true);
	-- 	end
	-- end
	-- WorldMap.create();

				--新手引导
    -- if TaskManager.getNewState() then
    --      UIManager.open("GuiderLayer")
    -- end
end

function removeFromParent()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end