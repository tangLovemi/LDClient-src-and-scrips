
module("HuntDetailUI", package.seeall)
local m_rootLayer =nil
local m_isCreate = false;

local m_UILayout = nil
local m_taskAcceptBtn = nil
local m_closeBtn = nil
local m_currentTaskID = nil --当前展示任务编号
local m_Current_Task_Status = nil --当前展示任务编号状态
local m_ItemLayout = nil
local m_scrollView = nil
local m_ItemNum = 0
local m_innerPanel = nil
local m_allBtn = nil  --m_index =1
local m_finishedBtn = nil ----m_index =2
local m_unopenBtn = nil --m_index =3
local m_ListViwPanel = nil
local m_index = 1
local function closeBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("HuntDetailUI")
		UIManager.open("HuntUI")
	end
end
local function allBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_index~= 1 then
			m_index = 1
			updateListView()
		end
	end
end
local function finishedBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_index~= 2 then
			m_index = 2
			updateListView()
		end	
	end
end
local function unopenBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_index~= 3 then
			m_index = 3
			updateListView()
		end	
	end
end
function updateListView()
	m_ListViwPanel:removeAllItems()
	local huntAllData = DataTableManager.getTableByName("Hunt")
	local huntCount = 0
	for k,v in pairs(huntAllData) do
		huntCount = huntCount+1
	end
	if m_index ==1 then --全部
		for i=1,huntCount do
			local tempItem_x = initItemPanel(700001+i*100)
			m_ListViwPanel:pushBackCustomItem(tempItem_x)
		end
	elseif m_index ==2 then --已完成
		local huntfinish = {}
		for i=1,huntCount do
			if m_Current_Task>(700001+i*100) then
				local tempItem_x = initItemPanel(700001+i*100)
				m_ListViwPanel:pushBackCustomItem(tempItem_x)
			elseif m_Current_Task==(700001+i*100) then 
				if m_Current_Task_Status ==5 then
					local tempItem_x = initItemPanel(700001+i*100)
					m_ListViwPanel:pushBackCustomItem(tempItem_x)
				end
			end
		end
	elseif m_index ==3 then --未开启

		local huntfinish = {}
		for i=1,huntCount do
			if m_Current_Task<=(700001+i*100) then
				local tempItem_x = initItemPanel(700001+i*100)
				m_ListViwPanel:pushBackCustomItem(tempItem_x)
			-- elseif m_Current_Task==(700001+i*100) then 
			-- 	if m_Current_Task_Status ==1 then
			-- 		local tempItem_x = initItemPanel(700001+i*100)
			-- 		m_ListViwPanel:pushBackCustomItem(tempItem_x)
			-- 	end
			end
		end
	end
	updateBtnView()
end
function updateBtnView()
    m_allBtn:loadTextures(PATH_CCS_RES.."xuanshang_biaoqian_quanbu_2.png",PATH_CCS_RES.."xuanshang_biaoqian_quanbu_1.png","")
    m_unopenBtn:loadTextures(PATH_CCS_RES.."xuanshang_biaoqian_weiwancheng_2.png",PATH_CCS_RES.."xuanshang_biaoqian_weiwancheng_1.png","")
    m_finishedBtn:loadTextures(PATH_CCS_RES.."xuanshang_biaoqian_yiwancheng_2.png",PATH_CCS_RES.."xuanshang_biaoqian_yiwancheng_1.png","")

	if  m_index ==1 then 
	    m_allBtn:loadTextures(PATH_CCS_RES.."xuanshang_biaoqian_quanbu_1.png",PATH_CCS_RES.."xuanshang_biaoqian_quanbu_2.png","")
	elseif m_index ==2 then
		m_finishedBtn:loadTextures(PATH_CCS_RES.."xuanshang_biaoqian_yiwancheng_1.png",PATH_CCS_RES.."xuanshang_biaoqian_yiwancheng_2.png","")			
	elseif m_index ==3 then
	 	m_unopenBtn:loadTextures(PATH_CCS_RES.."xuanshang_biaoqian_weiwancheng_1.png",PATH_CCS_RES.."xuanshang_biaoqian_weiwancheng_2.png","") 
	end
end


function initHuntData(messageData)
	-- --1,不可接取，2，可以接但未接，3，接任务未完成，4，接任务已完成未领奖励，5接任务已完成领取奖励
		m_Current_Task = tonumber(messageData["task_id"])
		m_Current_Task_Status = messageData["status"]
		m_Current_Task_Num = messageData["num"]
end
function itemOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		taskid = sender:getTag()
		local params = {}
		params["task_id"] = taskid
		UIManager.close("HuntDetailUI")
		UIManager.open("HuntUI",params)
	end
end


local function goodsOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_BEGIN then
		GoodsDetails.onTouchBegin(sender, sender:getTag(), 1);
	elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
		GoodsDetails.onTouchEnd();
	end
end

function initItemPanel(taskid)
	local tempItem = m_itemBase:clone()
	tempItem:setTag(taskid)
	tempItem:addTouchEventListener(itemOnClick)
	local baseImg_x = tolua.cast(tempItem:getChildByName("Image_10"), "ImageView");
	local hunt_IconImgStr = DataTableManager.getValue("Hunt", taskid.."_index", "img")
	local hunt_NameImgStr = DataTableManager.getValue("Hunt", taskid.."_index", "Pic_Name")
	local ability_textStr = DataTableManager.getValue("Hunt", taskid.."_index", "Info")
	local money_textStr  = tostring(DataTableManager.getValue("Hunt", taskid.."_index", "money"))
	local exp_textStr  = tostring(DataTableManager.getValue("Hunt", taskid.."_index", "exp"))

	local hunt_NameImg = tolua.cast(baseImg_x:getChildByName("Image_12"), "ImageView")
	hunt_NameImg:loadTexture(PATH_CCS_RES..hunt_NameImgStr..".png")
	local hunt_IconImg = tolua.cast(baseImg_x:getChildByName("Image_11"), "ImageView")
	local statuImg = tolua.cast(baseImg_x:getChildByName("Image_26"), "ImageView")
	
	if m_Current_Task> taskid then 
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
	elseif m_Current_Task< taskid then
		-- hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr.."_1.png")
		hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		statuImg:setVisible(false)
	elseif m_Current_Task== taskid then
		if m_Current_Task_Status ==1 then
			hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
			-- hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr.."_1.png")
			statuImg:setVisible(false)
		elseif m_Current_Task_Status ==2 then
			hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
			-- hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr.."_1.png")
			statuImg:setVisible(false)
		elseif m_Current_Task_Status ==3 then
			hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		elseif m_Current_Task_Status ==4 then
			hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		elseif m_Current_Task_Status ==5 then
			hunt_IconImg:loadTexture(PATH_CCS_RES..hunt_IconImgStr..".png")
		end
	end

	local money_text = tolua.cast(baseImg_x:getChildByName("AtlasLabel_17"),"LabelAtlas")
	money_text:setStringValue(money_textStr)
	local exp_text = tolua.cast(baseImg_x:getChildByName("AtlasLabel_15"),"LabelAtlas")
	exp_text:setStringValue(exp_textStr)

	local rewardInfo1 = split(DataTableManager.getValue("Hunt", taskid.."_index", "reward1"),";")
	local rewardInfo2 = split(DataTableManager.getValue("Hunt", taskid.."_index", "reward2"),";")
	local rewardInfo3 = split(DataTableManager.getValue("Hunt", taskid.."_index", "reward3"),";")
	local itemImg1 = tolua.cast(baseImg_x:getChildByName("Image_18"), "ImageView");
	local itemImg2 = tolua.cast(baseImg_x:getChildByName("Image_20"), "ImageView");
	local itemImg3 = tolua.cast(baseImg_x:getChildByName("Image_22"), "ImageView");
	local itemframe1 = tolua.cast(itemImg1:getChildByName("Image_19"), "ImageView");
	local itemframe2 = tolua.cast(itemImg2:getChildByName("Image_21"), "ImageView");
	local itemframe3 = tolua.cast(itemImg3:getChildByName("Image_23"), "ImageView");

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

	return tempItem
end


function create()
	if (not m_isCreate) then
		m_isCreate= true
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()
		
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "shangjin_2_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local layoutButtom = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout");
	    layoutButtom:addTouchEventListener(closeBtnOnClick);  

	    m_allBtn = tolua.cast(m_UILayout:getWidgetByName("Button_6"), "Button");
	    m_allBtn:addTouchEventListener(allBtnOnClick);
	    m_unopenBtn = tolua.cast(m_UILayout:getWidgetByName("Button_7"), "Button");
	    m_unopenBtn:addTouchEventListener(unopenBtnOnClick);
	    m_finishedBtn = tolua.cast(m_UILayout:getWidgetByName("Button_8"), "Button");
	    m_finishedBtn:addTouchEventListener(finishedBtnOnClick);
	    m_ListViwPanel = tolua.cast(m_UILayout:getWidgetByName("ListView_25"), "ListView");
	    m_itemBase = tolua.cast(m_UILayout:getWidgetByName("Panel_9"), "Layout");
	end
end


function open()
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	initHuntData(NpcInfoManager.getHuntDataNoHandle())
	updateListView()



end
function close()
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end

function remove()
	if (m_isCreate) then 
		m_isCreate = false
		-- body
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
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