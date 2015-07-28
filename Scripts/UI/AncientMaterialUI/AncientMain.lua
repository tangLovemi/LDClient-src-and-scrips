--
-- Author: Your Name
-- Date: 2015-06-04 13:07:14
--
module("AncientMain", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_isOpen = false
local m_isCreate = false;

local m_areaItem = nil
local m_areaList = nil
local m_btnList = {}
local m_CurIndex =0
local m_screwView= nil
local m_itemBase= nil

local function closeOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("AncientMain")
	end

end

function itemOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local itemId = sender:getTag()
		UIManager.open("AncientMaterialItem",itemId)
	end
end
function stageBtn_onClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_CurIndex = sender:getTag()-1000
		updateMainArea()
	end
end
function updateMainArea()
	m_screwView:setTouchEnabled(false)
	m_screwView:removeAllChildren()
	m_screwView:scrollToTop(0.5,true)
	local ancientData = DataTableManager.getTableByName("AncientMaterial")
	local havedMaterail = UserInfoManager.getRoleInfo("ancientMaterial")
	local stageItems = {}
	local stageItemCount =0 
	for k,v in pairs(ancientData) do
		if v.stage == m_CurIndex then
			stageItemCount = stageItemCount+1
			stageItems[stageItemCount] = v
			
		end
	end
	local colums = 8
	local row = math.floor(stageItemCount/8)+1
	local lastRowNum = stageItemCount-8*(row-1)
	local totalNum = stageItemCount
	local allHeight = row*100+180
	m_screwView:setInnerContainerSize(CCSize(820,allHeight ));
	for j=1,row do
		if j == row then
			for i=1,lastRowNum do
				local itemPanel = m_itemBase:clone()
				local itemId = stageItems[stageItemCount].id
				itemPanel:setPosition(ccp((i-1)*95+30 ,allHeight-120*(j)+20))
				itemPanel:setTag(itemId)
				itemPanel:addTouchEventListener(itemOnClick)
				local imgIcon = tolua.cast(itemPanel:getChildByName("Image_20"), "ImageView")
				local itemInfo  = GoodsManager.getBaseInfo(itemId)
				local haveThis = false
				for k,v in pairs(havedMaterail) do
					if v.id == itemId then
						haveThis = true
					end
				end
				if haveThis then
					imgIcon:loadTexture(itemInfo.icon)
				else
					imgIcon:loadTexture(PATH_RES_IMAGE_ANCIENT_UNGET..itemId..".png")
				end
				local imgIconFrame = tolua.cast(itemPanel:getChildByName("Image_16"), "ImageView")
				imgIconFrame:loadTexture(itemInfo.frameIcon)
				m_screwView:addChild(itemPanel)
				stageItemCount = stageItemCount-1
			end
		else
			for i=1,colums do
				local itemPanel = m_itemBase:clone()
				local itemId = stageItems[stageItemCount].id
				itemPanel:setPosition(ccp((i-1)*95 +30,allHeight-120*(j)+20))
				itemPanel:setTag(itemId)
				itemPanel:addTouchEventListener(itemOnClick)
				local imgIcon = tolua.cast(itemPanel:getChildByName("Image_20"), "ImageView")
				local itemInfo  = GoodsManager.getBaseInfo(itemId)
				local haveThis = false
				for k,v in pairs(havedMaterail) do
					if v.id == itemId then
						haveThis = true
					end
				end
				if haveThis then
					imgIcon:loadTexture(itemInfo.icon)
				else
					imgIcon:loadTexture(PATH_RES_IMAGE_ANCIENT_UNGET..itemId..".png")
				end
				local imgIconFrame = tolua.cast(itemPanel:getChildByName("Image_16"), "ImageView")
				imgIconFrame:loadTexture(itemInfo.frameIcon)
				m_screwView:addChild(itemPanel)
				stageItemCount = stageItemCount-1
			end
		end
	end
	m_screwView:setTouchEnabled(true)
	updateLabelBtn()
end
function updateLabelBtn()
	m_btnList[1]:loadTextures(PATH_CCS_RES.."jieduan_1_2.png",PATH_CCS_RES.."jieduan_1_1.png","")
	m_btnList[2]:loadTextures(PATH_CCS_RES.."jieduan_2_2.png",PATH_CCS_RES.."jieduan_2_1.png","")
	m_btnList[3]:loadTextures(PATH_CCS_RES.."jieduan_3_2.png",PATH_CCS_RES.."jieduan_3_1.png","")
	m_btnList[4]:loadTextures(PATH_CCS_RES.."jieduan_4_2.png",PATH_CCS_RES.."jieduan_4_1.png","")
	m_btnList[5]:loadTextures(PATH_CCS_RES.."jieduan_5_2.png",PATH_CCS_RES.."jieduan_5_1.png","")
	m_btnList[6]:loadTextures(PATH_CCS_RES.."jieduan_6_2.png",PATH_CCS_RES.."jieduan_6_1.png","")

	m_btnList[m_CurIndex]:loadTextures(PATH_CCS_RES.."jieduan_"..m_CurIndex.."_1.png",PATH_CCS_RES.."jieduan_"..m_CurIndex.."_2.png","")
end
function create()
	if(m_isCreate == false)then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "cailiao_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local panel = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout")
	    panel:addTouchEventListener(closeOnClick);
	    m_btnList[1] = tolua.cast(m_UILayout:getWidgetByName("Button_17"), "Button")
	    m_btnList[2] = tolua.cast(m_UILayout:getWidgetByName("Button_21"), "Button")
	    m_btnList[3] = tolua.cast(m_UILayout:getWidgetByName("Button_22"), "Button")
	    m_btnList[4] = tolua.cast(m_UILayout:getWidgetByName("Button_23"), "Button")
	    m_btnList[5] = tolua.cast(m_UILayout:getWidgetByName("Button_26"), "Button")
	    m_btnList[6] = tolua.cast(m_UILayout:getWidgetByName("Button_27"), "Button")
	    m_CurIndex = 1
		for i=1,6 do
	    	m_btnList[i]:setTag(1000+i)
	    	m_btnList[i]:addTouchEventListener(stageBtn_onClick)
		end
	    m_screwView = tolua.cast(m_UILayout:getWidgetByName("ScrollView_31"), "ScrollView")
	    m_screwView:setBounceEnabled(true)
	    m_itemBase = tolua.cast(m_UILayout:getWidgetByName("Panel_qqqq"), "Layout")
	end

end

function open(messageData)
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        updateMainArea()
        --测试
        -- AncientMaterialItem.playGetAncientEffect(170026)
    end
end
function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		NotificationManager.onCloseCheck("AncientMain")
	end

end

function remove()
	if(m_isCreate)then
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false;
	end

end
function checkNotification()

end

function checkNotification_login()
    return false
end
function checkNotification_line()
    return true
end
function checkNotification_close()
    return false
end