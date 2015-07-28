--
-- Author: Gao Jiefeng
-- Date: 2015-03-12 13:34:09
--
module("DailyTaskUI", package.seeall)
local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil
local m_UILayout = nil
local m_taskTemplate = nil
local m_taskList = nil
local m_tankuang = nil
local m_selectedBox = 0
local m_bottomView = nil
local m_boxButton1 = nil
local m_boxButton2 = nil
local m_boxButton3 = nil
local m_daliTaskInfo = nil
local m_boxInfo = nil
local m_HidePosition = nil
local m_ShowPosition = nil
local m_dailyTaskBaseLayout = nil
local m_achivementBaseLayout = nil
local m_showType = 1
local m_achieveMentBaseList = nil
local m_achievementBaseItem = nil
local m_dailyTaskShowbtn = nil
local m_achievementShowbtn = nil
local m_recordTime = 0 
local m_onprocess = false
local m_btnList = {}
local m_boxId = 0 
local function achieveCallBack(messageData)
	--展示获得的商品，更新列表
	local goodDesc = ""
	for k,reward in pairs(messageData) do
		if reward["bOK"] ==1 then
			goodDesc = GoodsManager.getNameById(reward["itemId"])..":"..reward["itemNum"].."个 "..goodDesc
		end
	end
	if goodDesc ~= "" then
		Util.showOperateResultPrompt("获得了"..goodDesc)
		initAchieveMentLsit(TaskManager.getAchievementList())
		ProgressRadial.close();
	end
end
local function getAchieveReward(sender,eventType)
	if m_onprocess then
		return
	end
	if eventType == TOUCH_EVENT_TYPE_END then
			if m_onprocess then
				return
			end
			ProgressRadial.open();
			m_onprocess = true
			m_achieveMentBaseList:setTouchEnabled(false)
			acheiveID = sender:getTag()-5000
			TaskManager.getAchievementReward(acheiveID,achieveCallBack)
			m_recordTime = os.time()
	end
end

function initAchieveMentLsit(achievementlist)
	if not m_isOpen then
		return
	end
	m_achieveMentBaseList:removeAllItems()
	m_achieveMentBaseList:setVisible(false)
	-- m_achieveMentBaseList:refreshView()
	if achievementlist ~= nil then
		for k,achive in pairs(achievementlist) do
			local panelLayout = m_achievementBaseItem:clone()
			local itemImg = tolua.cast(panelLayout:getChildByName("Image_39"),"ImageView")
			local iconView = tolua.cast(itemImg:getChildByName("Image_40"),"ImageView")
			local descImge = tolua.cast(itemImg:getChildByName("Image_42"),"ImageView") 
			local descLabel = tolua.cast(itemImg:getChildByName("Label_43_1"),"Label") 
			local itemImg1 = tolua.cast(itemImg:getChildByName("Image_48"),"ImageView") 
			local itemImg2 = tolua.cast(itemImg:getChildByName("Image_48"),"Image_48_0") 
			local itemNum1 = tolua.cast(itemImg:getChildByName("AtlasLabel_64"),"LabelAtlas")
			local itemNum2 = tolua.cast(itemImg:getChildByName("AtlasLabel_65"),"LabelAtlas")
			local count = tolua.cast(itemImg:getChildByName("chengjiu_wanchengcishu_labelNum"),"LabelAtlas") 
			local countTotal = tolua.cast(itemImg:getChildByName("chengjiu_zongcishu_labelNum"),"LabelAtlas") 

			local getRewardBtn =  tolua.cast(itemImg:getChildByName("Button_79"),"Button")

			local achivedata = DataTableManager.getItem("achievement","id_"..achive["id"])
			descImge:loadTexture(PATH_CCS_RES..achivedata["name"]..".png")
			descLabel:setText(achivedata["desc"])
			local rewardData = Util.Split(achivedata["reward"],"|")
			itemData1 = Util.Split(rewardData[1],";")
			itemData2 = Util.Split(rewardData[2],";")

			iconView:loadTexture(PATH_CCS_RES..achivedata["icon"]..".png")
			itemNum1:setStringValue(itemData1[2])
			itemNum2:setStringValue(itemData2[2])
			getRewardBtn:addTouchEventListener(getAchieveReward)
			getRewardBtn:setTag(5000+tonumber(achive["id"]))
			count:setStringValue(achive["current_time"])
			countTotal:setStringValue(achive["total_time"])
			if achive["current_time"] < achive["total_time"] then
				getRewardBtn:setVisible(false)
			else
				if achive["bfinish"] == 1 then
					getRewardBtn:setTouchEnabled(false)
					getRewardBtn:loadTextures(PATH_CCS_RES.."renwu_wanchengda.png",PATH_CCS_RES.."renwu_wanchengda.png","")
				else
					table.insert(m_btnList,getRewardBtn)
				end
			end
			
			m_achieveMentBaseList:pushBackCustomItem(panelLayout)
		end
	end
	m_achieveMentBaseList:setVisible(true)
	m_achieveMentBaseList:setTouchEnabled(true)
	m_onprocess = false
end


local function closeTanChuang()
	if m_tankuang:isVisible() then
		m_selectedBox = 0
		m_tankuang:setVisible(false)
		m_tankuang:setPosition(ccp(-1000,-1000))
	end
end

local function onBoxRewardSucess()
	-- m_boxId
		RewardDisplay.setTypeAndId(m_boxId,3)
		UIManager.open("RewardDisplay")
	--更新任务信息
	m_daliTaskInfo = TaskManager:getDailyTaskInfo()
	m_boxInfo = TaskManager:getBoxInfo()
	initBottomPanel()
end
local function getBoxReward(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if(GoodsManager.isBackpackFull_2()) then
			--背包满提示
			BackpackFullTishi.show();
			return
		end		
		local boxId = sender:getTag()-1000
		m_boxId = boxId
		TaskManager.getDailyTaskReward(2,boxId, onBoxRewardSucess)
	end
end
local function onBoxClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_BEGIN then		
		local boxId = sender:getTag()-1000
		if m_selectedBox~= boxId then 
			m_selectedBox = boxId
			m_tankuang:setVisible(true)
			local selectedBox= tolua.cast(sender,"CCNode")
			m_tankuang:setPosition(ccp(selectedBox:getPositionX()+50,selectedBox:getPositionY()+50))
			local needActivityNum = tolua.cast(m_tankuang:getChildByName("meiri_tankuanghuoyuedu_labelNum"),"LabelAtlas")
			local rewardinfo1 = Util.Split(DataTableManager.getValue("EveryDayTaskRewardData",boxId.."_index","item1"),";")
			local rewardinfo2 = Util.Split(DataTableManager.getValue("EveryDayTaskRewardData",boxId.."_index","item2"),";")
			local rewardinfo3 = Util.Split(DataTableManager.getValue("EveryDayTaskRewardData",boxId.."_index","item3"),";")
			local item_Img1 = tolua.cast(m_tankuang:getChildByName("meiri_tankuangwupin1_img"),"ImageView")--Icon图标
			local item_Img2 = tolua.cast(m_tankuang:getChildByName("meiri_tankuangwupin2_img"),"ImageView")--Icon图标
			local item_Img3 = tolua.cast(m_tankuang:getChildByName("meiri_tankuangwupin3_img"),"ImageView")--Icon图标
			local item_Num1 = tolua.cast(tolua.cast(item_Img1,"CCNode"):getChildByName("meiri_tankuangwupin1_labelNum"),"LabelAtlas")--Item数量
			local item_Num2 = tolua.cast(tolua.cast(item_Img2,"CCNode"):getChildByName("meiri_tankuangwupin2_labelNum"),"LabelAtlas")--Item数量
			local item_Num3 = tolua.cast(tolua.cast(item_Img3,"CCNode"):getChildByName("meiri_tankuangwupin3_labelNum"),"LabelAtlas")--Item数量

			item_Img1:loadTexture(GoodsManager.getIconPathById(tonumber(rewardinfo1[1])))
			item_Img2:loadTexture(GoodsManager.getIconPathById(tonumber(rewardinfo2[1])))
			item_Img3:loadTexture(GoodsManager.getIconPathById(tonumber(rewardinfo3[1])))
			item_Num1:setStringValue(rewardinfo1[2])
			item_Num2:setStringValue(rewardinfo2[2])
			item_Num3:setStringValue(rewardinfo3[2])

			needActivityNum:setStringValue(DataTableManager.getValue("EveryDayTaskRewardData",boxId.."_index","needActivityNum"))
		end
	elseif eventType == TOUCH_EVENT_TYPE_END then 
		closeTanChuang()
		m_selectedBox = 0
	end
end


local function onCloseClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("DailyTaskUI")

	end
end

local function onGetRewardSucess(dailyTaskID)
	Util.showOperateResultPrompt("领奖成功")
	m_onprocess = false
	ProgressRadial.close();
	local itemOnClick = m_taskList:getChildByTag(2000+dailyTaskID)
	m_taskList:removeItem(m_taskList:getIndex(itemOnClick))
	m_taskList:refreshView()
end
local function onGotoBtnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		-- Util.showOperateResultPrompt("您点击了一个前往按钮".."    按钮的ID是"..(sender:getTag()-10000))
		
		-- MainCityLogic.switchLayer(2,0,true);
		local itemId = sender:getTag()-10000
		local gotoType = tonumber(DataTableManager.getValue("EveryDayTaskData",itemId.."_index","tiaozhuan"))
		if gotoType == 1 then
			local OpenUIName = DataTableManager.getValue("EveryDayTaskData",itemId.."_index","uiming")
			UIManager.close("DailyTaskUI")
			UIManager.open(OpenUIName)
		elseif gotoType == 2 then
			UIManager.close("DailyTaskUI")
			local areaId = WorldManager.getCUrOpenMap()
			MainCityLogic.removeMainCity()
			WorldManager.setTaskMapId(areaId)
			WorldManager.setNeedOpenSelectLevel(true);
			WorldMap.create();
		end
	end
end

local function onGetDailyTaskRewardClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_onprocess then
			return
		end
		ProgressRadial.open();
		m_onprocess = true
		-- Util.showOperateResultPrompt("您点击了一个领奖按钮".."    按钮的ID是"..(sender:getTag()-10000))
		local dailyTaskID = sender:getTag()-10000
		TaskManager.getDailyTaskReward(1,dailyTaskID, onGetRewardSucess)
	end
end
local function initDailyTaskList()
	if not m_isOpen then
		return
	end
	m_taskList:setVisible(false)
	m_daliTaskInfo = TaskManager:getDailyTaskInfo()
	m_boxInfo = TaskManager:getBoxInfo()
	for k,v in pairs(m_daliTaskInfo) do
		if v["state"] ~= 2 then
			local taskPanelLayout = m_taskTemplate:clone()
			local taskPanel=  tolua.cast(taskPanelLayout:getChildByName("Image_31"),"ImageView")
			taskPanelLayout:setTag(2000+k)
			local itemIcon =  tolua.cast(taskPanel:getChildByName("Image_17"),"ImageView")--Icon图标
			-- local tempNode = tolua.cast(itemIcon,"CCNode")
			-- local itemNum =  tolua.cast(tempNode:getChildByName("meiri_renwujianglichenghao_labelNum"),"LabelAtlas")--Icon数量
			local taskContentImg = tolua.cast(taskPanel:getChildByName("meiri_renwuming_img"),"ImageView")--任务说明图标
			local taskContentLabel = tolua.cast(taskPanel:getChildByName("meiri_wancheng_label"),"Label") --任务说明标签
			local taskTotalTimes1 = tolua.cast(taskPanel:getChildByName("meiri_cishu_labelNum"),"LabelAtlas") --任务总次数
			local taskCurrentTimes = tolua.cast(taskPanel:getChildByName("meiri_wanchengcishu_labelNum"),"LabelAtlas") --任务当前次数
			local taskTotalTimes2 = tolua.cast(taskPanel:getChildByName("meiri_zongcishu_labelNum"),"LabelAtlas") --任务总次数
			local taskMoney = tolua.cast(taskPanel:getChildByName("meiri_jinbishuliang_labelNum"),"LabelAtlas") --奖励金币标签
			local taskExp = tolua.cast(taskPanel:getChildByName("meiri_jingyanshuliang_labelNum"),"LabelAtlas") --奖励经验标签
			local taskActivity = tolua.cast(taskPanel:getChildByName("meiri_huoyuedushuzi_labelNum"),"LabelAtlas") --奖励活跃度标签
			local gotoBtn = tolua.cast(taskPanel:getChildByName("meiri_qianwang_btn"),"Button")
			-- gotoBtn:loadTextures(PATH_CCS_RES.."meiri_qianwang.png",PATH_CCS_RES.."meiri_qianwanganxia.png","")
			gotoBtn:setTag(10000+k)
			gotoBtn:addTouchEventListener(onGotoBtnClick)

			local itemiconPath = DataTableManager.getValue("EveryDayTaskData",k.."_index","icon")
			itemIcon:loadTexture(PATH_CCS_RES..itemiconPath)
			-- itemNum:setStringValue(itemInfo[2])
			--设置item奖励数据
			taskContentImg:loadTexture(PATH_CCS_RES..DataTableManager.getValue("EveryDayTaskData",k.."_index","taskimg"))
			taskContentLabel:setText(DataTableManager.getValue("EveryDayTaskData",k.."_index","name"))
			taskTotalTimes1:setStringValue(DataTableManager.getValue("EveryDayTaskData",k.."_index","times"))
			if v["num"]>10 then
				v["num"] =10
			end
			taskCurrentTimes:setStringValue(v["num"])--服务器传来
			taskTotalTimes2:setStringValue(DataTableManager.getValue("EveryDayTaskData",k.."_index","times"))
			taskMoney:setStringValue(DataTableManager.getValue("EveryDayTaskData",k.."_index","money"))
			taskExp:setStringValue(DataTableManager.getValue("EveryDayTaskData",k.."_index","exp"))
			taskActivity:setStringValue(DataTableManager.getValue("EveryDayTaskData",k.."_index","activityNum"))

			

			--如果任务完成领取按钮从新设置图片
			if v["state"] == 1 then
				gotoBtn:loadTextures(PATH_CCS_RES.."gybtn_lingqu_1.png",PATH_CCS_RES.."gybtn_lingqu_2.png","")
				gotoBtn:addTouchEventListener(onGetDailyTaskRewardClick)
				m_taskList:insertCustomItem(taskPanelLayout,0)
			else
				m_taskList:pushBackCustomItem(taskPanelLayout)
			end
			
		end
	end
	m_taskList:setVisible(true)
		--初始化底部宝箱界面
	initBottomPanel()
end

function initBottomPanel()
	local activityNow = m_boxInfo[1]["num"]
	if activityNow >100 then 
		activityNow= 100
	end
	local activatyTotal = DataTableManager.getValue("EveryDayTaskRewardData","3".."_index","needActivityNum")


	local needActivityLabel1 = tolua.cast(m_bottomView:getChildByName("meiri_huoyue1_labelNum"),"LabelAtlas")
	local needActivityLabel2 = tolua.cast(m_bottomView:getChildByName("meiri_huoyue2_labelNum"),"LabelAtlas")
	local needActivityLabel3 = tolua.cast(m_bottomView:getChildByName("meiri_huoyue3_labelNum"),"LabelAtlas")
	local pocessBar = tolua.cast(m_bottomView:getChildByName("meirijindutiao_loadingBar"),"LoadingBar")
	local jinduImg = tolua.cast(tolua.cast(pocessBar,"CCNode"):getChildByName("meiri_jindu_img"),"ImageView")
	local activityNowLebel = tolua.cast(m_bottomView:getChildByName("meiri_huoyue4_labelNum"),"LabelAtlas")
	local activatyTotalLebel = tolua.cast(m_bottomView:getChildByName("meiri_huoyue5_labelNum"),"LabelAtlas")
	local needActivaty1 = DataTableManager.getValue("EveryDayTaskRewardData","1".."_index","needActivityNum")
	local needActivaty2 = DataTableManager.getValue("EveryDayTaskRewardData","2".."_index","needActivityNum")
	local needActivaty3 = DataTableManager.getValue("EveryDayTaskRewardData","3".."_index","needActivityNum")
	needActivityLabel1:setStringValue(needActivaty1)
	needActivityLabel2:setStringValue(needActivaty2)
	needActivityLabel3:setStringValue(needActivaty3)
	activityNowLebel:setStringValue(activityNow)
	activatyTotalLebel:setStringValue(activatyTotal)

	jinduImg:setScaleX(activityNow/activatyTotal)
	local boxButtons = {[1]=m_boxButton1,[2]= m_boxButton2,[3] = m_boxButton3}
	for k,v in pairs(m_boxInfo) do
		if v["state"] ==2 then
			boxButtons[k]:loadTextures(PATH_CCS_RES.."meiri_xiangzi_4.png",PATH_CCS_RES.."meiri_xiangzi_4.png","")
			boxButtons[k]:setTouchEnabled(false)
		else
			if v["state"] ==1 then
				--此处播放完成特效
				boxButtons[k]:loadTextures(PATH_CCS_RES.."meiri_xiangzi_3.png",PATH_CCS_RES.."meiri_xiangzi_3.png","")
				boxButtons[k]:addTouchEventListener(getBoxReward)
			end
		end
	end
end

local function dailytaskBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_showType == 2 then

		m_dailyTaskBaseLayout:setPosition(ccp(m_ShowPosition.x,m_ShowPosition.y+1))
			m_achivementBaseLayout:setPosition(ccp(m_HidePosition.x,m_HidePosition.y))
			m_dailyTaskShowbtn:loadTextures(PATH_CCS_RES.."chengjiu_bq_meirirenwu_1.png","","")
			m_achievementShowbtn:loadTextures(PATH_CCS_RES.."chengjiu_bq_chengjiu_2.png","","")

			m_showType = 1
		end
	end
end

local function achivementBtnOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_showType == 1 then
			m_dailyTaskBaseLayout:setPosition(m_HidePosition)
			m_achivementBaseLayout:setPosition(ccp(m_ShowPosition.x,m_ShowPosition.y-56))
			m_dailyTaskShowbtn:loadTextures(PATH_CCS_RES.."chengjiu_bq_meirirenwu_2.png","","")
			m_achievementShowbtn:loadTextures(PATH_CCS_RES.."chengjiu_bq_chengjiu_1.png","","")

			m_showType = 2
		end
	end
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "meirirenwu_ui_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local baseLayout = tolua.cast(m_UILayout:getWidgetByName("Panel_14"),"Layout")
	    baseLayout:addTouchEventListener(onCloseClick)
		m_taskList = tolua.cast(m_UILayout:getWidgetByName("meiri_renwuliebiao_list"),"ListView")
		m_taskList:setItemsMargin(10)
	    m_taskTemplate = tolua.cast(m_UILayout:getWidgetByName("meiri_renwulan_panel"),"Layout")
	    m_boxButton1 =  tolua.cast(m_UILayout:getWidgetByName("baoxiang_1_btn"),"Button")
	    m_boxButton1:setTag(1001)
	    m_boxButton1:addTouchEventListener(onBoxClick)
	    m_boxButton2 =  tolua.cast(m_UILayout:getWidgetByName("baoxiang_2_btn"),"Button")
	    m_boxButton2:setTag(1002)
	    m_boxButton2:addTouchEventListener(onBoxClick)
	    m_boxButton3 =  tolua.cast(m_UILayout:getWidgetByName("baoxiang_3_btn"),"Button")
	    m_boxButton3:setTag(1003)
	    m_boxButton3:addTouchEventListener(onBoxClick)
	    m_tankuang = tolua.cast(m_UILayout:getWidgetByName("meiri_tankuang_panel"),"Layout")
	    m_tankuang:setVisible(false)
	    m_bottomView = tolua.cast(m_UILayout:getWidgetByName("meiri_xialan_panel"),"Layout")



		m_dailyTaskBaseLayout = tolua.cast(m_UILayout:getWidgetByName("Image_25"),"ImageView")
		m_achivementBaseLayout = tolua.cast(m_UILayout:getWidgetByName("Image_32"),"ImageView")

		m_HidePosition = CCPoint(m_achivementBaseLayout:getPositionX(),m_achivementBaseLayout:getPositionY())
		m_ShowPosition = CCPoint(m_dailyTaskBaseLayout:getPositionX(),m_dailyTaskBaseLayout:getPositionY())
		m_dailyTaskShowbtn = tolua.cast(m_UILayout:getWidgetByName("Button_27"),"Button")
		m_dailyTaskShowbtn:addTouchEventListener(dailytaskBtnOnClick)

		m_achievementShowbtn = tolua.cast(m_UILayout:getWidgetByName("Button_26"),"Button")
		m_achievementShowbtn:addTouchEventListener(achivementBtnOnClick)
		m_achieveMentBaseList = tolua.cast(m_UILayout:getWidgetByName("chengjiu_renwuliebiao_list"),"ListView")
		m_achieveMentBaseList:setItemsMargin(10)
		m_achievementBaseItem = tolua.cast(m_UILayout:getWidgetByName("chengjiu_renwulan_panel"),"Layout")
		m_achievementShowbtn:loadTextures(PATH_CCS_RES.."chengjiu_bq_chengjiu_2.png","","")
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)
		-- initDailyTaskList()
		m_showType = 1
		TaskManager.getTasksInfo(initDailyTaskList) --获取任务信息
		initAchieveMentLsit(TaskManager.getAchievementList())--初始化成就列表
	end
end
function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		NotificationManager.onCloseCheck("TaskManager")
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
	end
end
