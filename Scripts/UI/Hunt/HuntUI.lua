--
-- Author: gaojiefeng
-- Date: 2015-01-29 13:52:14
--
module("HuntUI", package.seeall)
------------------------赏金猎人选择界面----------------------
local m_rootLayer= nil
local m_isCreate = false 
local m_isOpen = false;
local m_UILayout= nil
local m_Current_Task = nil
local m_Current_Task_Status = nil
local m_Current_Task_Num = nil
local m_checkInfoBtn = nil
local m_doHuntBtn = nil
local m_ShowPosition = nil
local m_HidePosition = CCPoint(10000,10000)
local m_finishBtn = nil
local m_unopenBtn= nil
local m_rewardBtn= nil
local m_acceptBtn= nil
local m_ongoingBtn= nil
local m_showAllBtn= nil
local m_showHuntBossInfo = nil
local m_fightBtn = nil
local m_fightData = nil
local m_huntDescLabel = nil
local m_getReward = false
local function onCloseClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("HuntUI")
	end
end
local function onAcceptClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		NpcInfoManager.sendHuntTaskStatusChange(recieveDataOnHunter)
	end
end
local function onRewardClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then

		if(GoodsManager.isBackpackFull_2()) then
			--背包满提示
			BackpackFullTishi.show();
			return
		end

		m_getReward = true
		NpcInfoManager.sendHuntTaskStatusChange(recieveDataOnHunter)
	end
end
local function onUnopenClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		--UIManager.close("HuntUI")
	end
end
local function onFinishClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- UIManager.close("HuntUI")
	end
end
local function onOnGoingClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- UIManager.close("HuntUI")
	end
end

local function onShowAllClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("HuntUI")
		UIManager.open("HuntDetailUI")
	end
end

local function onFightClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.close("HuntUI")
        UIManager.open("DialogView",m_fightData)
	end
end


local function recieveDataOnTaskStatusChange(messageType,messageData)
	NpcInfoManager.getHuntTaskInfo(710001,recieveDataOnHunter)
end
function recieveDataOnHunter(messageData)
	m_rootLayer:setVisible(true)
	if m_getReward then 
		m_getReward = false
		RewardDisplay.setTypeAndId(m_Current_Task,2)
		UIManager.open("RewardDisplay")
	end

	-- --1,不可接取，2，可以接但未接，3，接任务未完成，4，接任务已完成未领奖励，5接任务已完成领取奖励
	if m_showHuntBossInfo~= nil then
		m_Current_Task = tonumber(m_showHuntBossInfo["task_id"])
		if m_Current_Task == tonumber(messageData["task_id"]) then 
			m_Current_Task_Status = messageData["status"]
		elseif m_Current_Task < tonumber(messageData["task_id"]) then
			m_Current_Task_Status = 5
		elseif m_Current_Task > tonumber(messageData["task_id"]) then
			m_Current_Task_Status = 1
		end
		-- m_Current_Task_Status = m_showHuntBossInfo["status"]
		-- m_Current_Task_Num = m_showHuntBossInfo["num"]
	else
		m_Current_Task = tonumber(messageData["task_id"])
		m_Current_Task_Status = messageData["status"]
		m_Current_Task_Num = messageData["num"]
	end
	if m_Current_Task==0 then 
		m_Current_Task= 700101
		m_Current_Task_Status = 1
	end
	initView()
	if m_Current_Task_Status == 3 then
		local isCity = DataTableManager.getValue("Hunt", messageData["task_id"].."_index", "isCity") 
		if isCity == 0 then
			local bossId = DataTableManager.getValue("RewardDialog", messageData["task_id"].."_index", "bossid")
	        messageData["npcID"] = bossId
	        m_fightData = messageData
	        m_fightBtn:setPosition(m_ShowPosition)
	        m_ongoingBtn:setPosition(m_HidePosition)
    	end
    end
end


local function goodsOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_BEGIN then
		GoodsDetails.onTouchBegin(sender, sender:getTag(), 1);
	elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
		GoodsDetails.onTouchEnd();
	end
end

function initView()
	m_finishBtn :setPosition(m_HidePosition)
	m_unopenBtn :setPosition(m_HidePosition)
	m_rewardBtn :setPosition(m_HidePosition)
	m_acceptBtn :setPosition(m_HidePosition)
	m_ongoingBtn:setPosition(m_HidePosition)
	local hunt_IconImgStr = DataTableManager.getValue("Hunt", m_Current_Task.."_index", "img")
	local hunt_NameImgStr = DataTableManager.getValue("Hunt", m_Current_Task.."_index", "Pic_Name")
	local ability_textStr = DataTableManager.getValue("Hunt", m_Current_Task.."_index", "Info")
	local money_textStr  = tostring(DataTableManager.getValue("Hunt", m_Current_Task.."_index", "money"))
	local exp_textStr  = tostring(DataTableManager.getValue("Hunt", m_Current_Task.."_index", "exp"))
	local area_textStr  = tostring(DataTableManager.getValue("Hunt", m_Current_Task.."_index", "areadesc"))
	m_huntDescLabel:setText(area_textStr)

	local hunt_NameImg = tolua.cast(m_UILayout:getWidgetByName("Image_29"), "ImageView")
	hunt_NameImg:loadTexture(PATH_CCS_RES..hunt_NameImgStr..".png")
	local hunt_IconImg = tolua.cast(m_UILayout:getWidgetByName("Image_6"), "ImageView")
	-- print(m_Current_Task_Status.."...........m_Current_Task_Status...............")
	if m_Current_Task_Status ==1 then
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr.."_1.png")
		m_unopenBtn:setPosition(m_ShowPosition)
	elseif m_Current_Task_Status ==2 then
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr.."_1.png")
		m_acceptBtn:setPosition(m_ShowPosition)
	elseif m_Current_Task_Status ==3 then
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		m_ongoingBtn:setPosition(m_ShowPosition)
	elseif m_Current_Task_Status ==4 then
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		m_rewardBtn:setPosition(m_ShowPosition)
	elseif m_Current_Task_Status ==5 then
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		-- print(m_Current_Task_Status.."...........m_Current_Task_Status...............")
		-- m_finishBtn:setLocalZOrder(100)
		m_finishBtn:setPosition(m_ShowPosition)
	end


	local ability_text = tolua.cast(m_UILayout:getWidgetByName("Label_23"),"Label")
	ability_text:setText(ability_textStr)
	local money_text = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_19"),"LabelAtlas")
	-- print(money_textStr)
	money_text:setStringValue(money_textStr)
	local exp_text = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_21"),"LabelAtlas")
	exp_text:setStringValue(exp_textStr)

	local rewardInfo1 = split(DataTableManager.getValue("Hunt", m_Current_Task.."_index", "reward1"),";")
	local rewardInfo2 = split(DataTableManager.getValue("Hunt", m_Current_Task.."_index", "reward2"),";")
	local rewardInfo3 = split(DataTableManager.getValue("Hunt", m_Current_Task.."_index", "reward3"),";")
	local itemImg1 = tolua.cast(m_UILayout:getWidgetByName("Image_17"), "ImageView");
	local itemImg2 = tolua.cast(m_UILayout:getWidgetByName("Image_11"), "ImageView");
	local itemImg3 = tolua.cast(m_UILayout:getWidgetByName("Image_13"), "ImageView");
	local itemframe1 = tolua.cast(m_UILayout:getWidgetByName("Image_10"), "ImageView");
	local itemframe2 = tolua.cast(m_UILayout:getWidgetByName("Image_12"), "ImageView");
	local itemframe3 = tolua.cast(m_UILayout:getWidgetByName("Image_14"), "ImageView");

	if (rewardInfo1[1]~=0)then
		local iteminfo =GoodsManager.getBaseInfo(rewardInfo1[1])
		itemImg1:loadTexture(iteminfo.icon); 
		itemframe1:loadTexture(iteminfo.frameIcon)
		itemImg1:setTouchEnabled(true);
		itemImg1:setTag(rewardInfo1[1]);
		itemImg1:addTouchEventListener(goodsOnClick);
	end
	if (rewardInfo2[1]~=0)then
		local iteminfo =GoodsManager.getBaseInfo(rewardInfo2[1])
		itemImg2:loadTexture(iteminfo.icon); 
		itemframe2:loadTexture(iteminfo.frameIcon)
		itemImg2:setTouchEnabled(true);
		itemImg2:setTag(rewardInfo2[1]);
		itemImg2:addTouchEventListener(goodsOnClick);
	end
	if (rewardInfo3[1]~=0)then
		local iteminfo =GoodsManager.getBaseInfo(rewardInfo3[1])
		itemImg3:loadTexture(iteminfo.icon); 
		itemframe3:loadTexture(iteminfo.frameIcon)
		itemImg3:setTouchEnabled(true);
		itemImg3:setTag(rewardInfo3[1]);
		itemImg3:addTouchEventListener(goodsOnClick);
	end
end

function create()
	if (not m_isCreate) then
		m_isCreate = true
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()
		
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "shangjin_1_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    local baseLayout = tolua.cast(m_UILayout:getWidgetByName("Panel_14"),"Layout")
	    baseLayout:addTouchEventListener(onCloseClick)

	    m_rootLayer:addChild(m_UILayout);
		m_finishBtn = tolua.cast(m_UILayout:getWidgetByName("Button_24"), "Button")
		m_finishBtn:addTouchEventListener(onFinishClick)

		m_finishBtn:setPosition(m_HidePosition)
		m_unopenBtn = tolua.cast(m_UILayout:getWidgetByName("Button_25"), "Button")
		m_unopenBtn:addTouchEventListener(onUnopenClick)
		m_unopenBtn:setPosition(m_HidePosition)
		m_rewardBtn = tolua.cast(m_UILayout:getWidgetByName("Button_26"), "Button")
		m_rewardBtn:addTouchEventListener(onRewardClick)
		m_rewardBtn:setPosition(m_HidePosition)
		m_acceptBtn = tolua.cast(m_UILayout:getWidgetByName("Button_27"), "Button")
		m_acceptBtn:addTouchEventListener(onAcceptClick)
		m_acceptBtn:setPosition(m_HidePosition)
		m_ongoingBtn = tolua.cast(m_UILayout:getWidgetByName("Button_28"), "Button")
		m_ongoingBtn:addTouchEventListener(onOnGoingClick)
		m_ongoingBtn:setPosition(m_HidePosition)
		m_showAllBtn = tolua.cast(m_UILayout:getWidgetByName("Button_30"), "Button")
		m_showAllBtn:addTouchEventListener(onShowAllClick)
		m_ShowPosition= CCPoint(716,197)
		m_fightBtn= tolua.cast(m_UILayout:getWidgetByName("Button_9"), "Button")
		m_fightBtn:addTouchEventListener(onFightClick)
		m_huntDescLabel = tolua.cast(m_UILayout:getWidgetByName("zhand_label"), "Label")
	end
   
end


function open(params)
	if(not m_isOpen) then
		m_isOpen = true;
		m_showHuntBossInfo = params
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
		m_rootLayer:setVisible(false)
		if m_showHuntBossInfo~= nil then
			--recieveDataOnHunter(NpcInfoManager.getHuntData())
		end
		-- NpcInfoManager.getHuntData(recieveDataOnHunter)
		NpcInfoManager.getHuntTaskInfo(710001,recieveDataOnHunter)
	end

end
function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
	end
end

function remove()
	if (m_isCreate) then
		m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false 
		m_isOpen = false;
		m_UILayout= nil
		m_Current_Task = nil
		m_Current_Task_Status = nil
		m_Current_Task_Num = nil
		m_checkInfoBtn = nil
		m_doHuntBtn = nil
		m_ShowPosition = nil
		m_HidePosition = CCPoint(10000,10000)
		m_finishBtn = nil
		m_unopenBtn= nil
		m_rewardBtn= nil
		m_acceptBtn= nil
		m_ongoingBtn= nil
		m_showAllBtn= nil
		m_showHuntBossInfo = nil
	end
end
function split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, tonumber(match))
    end
    return result
end