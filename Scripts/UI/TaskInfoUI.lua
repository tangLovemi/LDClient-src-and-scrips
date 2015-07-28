-- 
module("TaskInfoUI", package.seeall)
require("extern")
local m_rootLayer = nil
local m_isCreate = false;
local m_isOpen = false;


local m_UILayout = nil
local m_TaskLayout = nil
local m_areaList = nil
local m_taskDesc = nil
local m_areaBg = nil
local m_rewardImg1 = nil
local m_rewardImg2 = nil
local m_rewardImg3 = nil
local m_rewardImg4 = nil
local m_rewardImg5 = nil
local m_rewardText1 = nil
local m_rewardText2 = nil
local m_rewardText3 = nil
local m_rewardText4 = nil
local m_rewardText5 = nil
local m_rewardNum1 = nil
local m_rewardNum2 = nil
local m_rewardNum3 = nil
local m_rewardNum4 = nil
local m_rewardNum5 = nil
local m_destination = nil
local m_closeBtn = nil
local m_gotoBtn = nil
local m_buttonArea = nil
local m_buttonTask = nil
local m_areaInfo = nil
local m_areaCount = 0
local m_taskOnServer = 0
local m_majorTaskOnGo = 0
local m_majorLayout = nil
local m_huntLayout = nil
local m_subTaskOnList = {}
local m_area_IDOnShow = 0
local m_exp_reward = 0
local m_money_reward =0
local m_taskInfoData = nil
local m_level_detect = nil
local function majorTaskOnClicked(sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		-- print("click on a task............."..sender:getTag())
		m_majorTaskOnGo  = DataTableManager.getValue("MajorTaskDialog",sender:getTag().."_index","subto")	
		updateTaskRightInfo(m_majorTaskOnGo,nil)

	end
end
local function huntTaskOnClicked(sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		-- print("click on a task............."..sender:getTag())
		updateTaskRightInfo(nil,sender:getTag())
	end
end

local function onAreaBtnClicked(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then

		for k,v in pairs(m_subTaskOnList) do
			local tempItem = m_areaList:getChildByTag(v);
			local tempIndex = m_areaList:getIndex(tempItem);
			m_areaList:removeItem(tempIndex);
		end
		local areaId = sender:getTag()-10000
		m_areaBg:loadTexture(PATH_CCS_RES..DataTableManager.getValue("MajorTaskInfo",areaId.."_index","areaIcon"))

		if areaId ~= m_area_IDOnShow then
			m_area_IDOnShow = areaId
			local majorTasks = DataTableManager.getValue("MajorTaskInfo",areaId.."_index","MajorTaskID")
			local majorImage = m_majorLayout:clone()
			majorImage:setTag(59999)
			table.insert(m_subTaskOnList,59999)
			m_areaList:insertCustomItem(majorImage,areaId)
			table.insert(m_subTaskOnList,m_majorLayout:getTag())
			local majorTaskIds = split(majorTasks,";")
			local majorAreaCount = 0
			if majorTasks~= "" then		
				local areaCount = #majorTaskIds
				for i=1,areaCount do
					if m_taskOnServer< majorTaskIds[i] then
						break
					end
					majorAreaCount = majorAreaCount+1
					local itembtn = m_buttonTask:clone()
					itembtn:setTag(majorTaskIds[i].."")
					table.insert(m_subTaskOnList,majorTaskIds[i])
					itembtn:setAnchorPoint(ccp(0,0))
					local taskBtnNameLabel = tolua.cast(itembtn:getChildByName("taskBtnName_text"),"Label")
					taskBtnNameLabel:setText(DataTableManager.getValue("MajorTaskDialog",(majorTaskIds[i]).."_index","TaskName"))
					itembtn:addTouchEventListener(majorTaskOnClicked)
					-- print(majorTaskIds[i].."....................."..m_taskOnServer-1)
					if majorTaskIds[i]< m_taskOnServer then
						itembtn:getChildByName("Image_24"):setVisible(true)
					elseif majorTaskIds[i] == m_taskOnServer then
						itembtn:getChildByName("Image_2"):setVisible(true)
					end
					m_areaList:insertCustomItem(itembtn,areaId+i)
				end
				if majorAreaCount ==0 then
					local tempItem = m_areaList:getChildByTag(59999);
					local tempIndex = m_areaList:getIndex(tempItem);
					m_areaList:removeItem(tempIndex);
				end
			end
			local huntImage = m_huntLayout:clone()
			huntImage:setTag(58888)
			m_areaList:insertCustomItem(huntImage,areaId+majorAreaCount+1)
			table.insert(m_subTaskOnList,58888)

			local huntTasks = DataTableManager.getValue("MajorTaskInfo",areaId.."_index","huntTaskIds")
			if huntTasks ~= "" then 
				local huntTaskIds = split(huntTasks,";")
				local huntcont = 0 
				for i=1,#huntTaskIds do
					local curHuntBossId = NpcInfoManager.getHuntBossId()
					if huntTaskIds[i]> curHuntBossId then
						break
					end
					huntcont = huntcont +1
					local itembtn = m_buttonTask:clone()
					itembtn:setTag(huntTaskIds[i].."")
					table.insert(m_subTaskOnList,huntTaskIds[i])
					itembtn:setAnchorPoint(ccp(0,0))
					local taskBtnNameLabel = tolua.cast(itembtn:getChildByName("taskBtnName_text"),"Label")
					taskBtnNameLabel:setText(DataTableManager.getValue("RewardDialog",(huntTaskIds[i]).."_index","MissionName"))
					itembtn:addTouchEventListener(huntTaskOnClicked)
					local huntData = NpcInfoManager.getHuntDataNoHandle()
					if huntTaskIds[i]< curHuntBossId then
						itembtn:getChildByName("Image_24"):setVisible(true)
					elseif huntTaskIds[i] == curHuntBossId then
						if huntData["status"] ~=1 then
							itembtn:getChildByName("Image_2"):setVisible(true)
						end
					end

					m_areaList:insertCustomItem(itembtn,areaId+majorAreaCount+1+i)
				end
				if huntcont ==0 then
					local tempItem = m_areaList:getChildByTag(58888);
					local tempIndex = m_areaList:getIndex(tempItem);
					m_areaList:removeItem(tempIndex);
				end
			end
		else
			m_area_IDOnShow =0
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

--[[更新右边面板信息]]--
function updateTaskRightInfo(taskMajorNow,hunterId)
	if(taskMajorNow~=nil ) then
		-- taskMajorNow = taskMajorNow-1
		m_areaBg:loadTexture(PATH_CCS_RES..DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","img")..".png")

		local rewardinfo1 = split(DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","reward1"),";")

		m_exp_reward:setStringValue(DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","exp_reward"))
		m_money_reward:setStringValue(DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","money_reward"))

		if(tonumber(rewardinfo1[1])~= 0) then
			local iteminfo = 
			m_rewardImg1:loadTexture(GoodsManager.getIconPathById(rewardinfo1[1]))
			-- m_rewardText1:setText(GoodsManager.getNameById(rewardinfo1[1]))
			m_rewardNum1:setText(rewardinfo1[2])
			m_rewardImg1:setVisible(true)
			m_rewardImg1:setTouchEnabled(true);
			m_rewardImg1:setTag(rewardinfo1[1]);
			m_rewardImg1:addTouchEventListener(goodsOnClick);
		else
			m_rewardImg1:setVisible(false)
		end

		local rewardinfo2 = split(DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","reward2"),";")
		if(tonumber(rewardinfo2[1])~= 0) then
			m_rewardImg2:loadTexture(GoodsManager.getIconPathById(rewardinfo2[1]))
			-- m_rewardText2:setText(GoodsManager.getNameById(rewardinfo2[1]))
			m_rewardNum2:setText(rewardinfo2[2])
			m_rewardImg2:setVisible(true)
			m_rewardImg2:setTouchEnabled(true);
			m_rewardImg2:setTag(rewardinfo2[1]);
			m_rewardImg2:addTouchEventListener(goodsOnClick);
		else
			m_rewardImg2:setVisible(false)
		end

		local rewardinfo3 = split(DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","reward3"),";")
		if(tonumber(rewardinfo3[1])~= 0) then
			m_rewardImg3:loadTexture(GoodsManager.getIconPathById(rewardinfo3[1]))
			-- m_rewardText3:setText(GoodsManager.getNameById(rewardinfo3[1]))
			m_rewardNum3:setText(rewardinfo3[2])
			m_rewardImg3:setVisible(true)
			m_rewardImg3:setTouchEnabled(true);
			m_rewardImg3:setTag(rewardinfo3[1]);
			m_rewardImg3:addTouchEventListener(goodsOnClick);
		else
			m_rewardImg3:setVisible(false)
		end
		local taskProcessDesc = DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","majortaskdesc")
		local subTasks =  split(DataTableManager.getValue("MajorTaskDialog",taskMajorNow.."_index","tasks"),";")
		for k,v in pairs(subTasks) do
			if (v<= m_taskOnServer) then
				taskProcessDesc = taskProcessDesc.."\n"..DataTableManager.getValue("MajorTaskDialog",v.."_index","taskdesc")
			end
		end
		local taskOnServer = NpcInfoManager.getMajorTaskData()
		if taskOnServer["task_id"] + 1 == taskMajorNow then
			local taskMonsterNum  = DataTableManager.getValue("MajorTaskDialog",m_taskOnServer.."_index","monster")
			if taskMonsterNum == 0 then
				m_taskDesc:setText(taskProcessDesc)
			else
				m_taskDesc:setText(taskProcessDesc.."("..taskOnServer["num"].."/"..taskMonsterNum..")")
			end
		else
			m_taskDesc:setText(taskProcessDesc)
		end
	else
		m_exp_reward:setStringValue(DataTableManager.getValue("Hunt",hunterId.."_index","exp"))
		m_money_reward:setStringValue(DataTableManager.getValue("Hunt",hunterId.."_index","money"))
		local rewardinfo1 = split(DataTableManager.getValue("Hunt",hunterId.."_index","reward1"),";")	
		if(tonumber(rewardinfo1[2])~=0)then
			-- print(GoodsManager.getIconPathById(rewardinfo1[2]).."............................."..rewardinfo1[1])

			m_rewardImg1:loadTexture(GoodsManager.getIconPathById(rewardinfo1[1]))
			-- m_rewardText1:setText(GoodsManager.getNameById(rewardinfo1[1]))
			m_rewardNum1:setText(rewardinfo1[2])
			m_rewardImg1:setVisible(true)
			m_rewardImg1:setTouchEnabled(true);
			m_rewardImg1:setTag(rewardinfo1[1]);
			m_rewardImg1:addTouchEventListener(goodsOnClick);
		else
			m_rewardImg1:setVisible(false)			
		end

		local rewardinfo2 = split(DataTableManager.getValue("Hunt",hunterId.."_index","reward2"),";")
		if(tonumber(rewardinfo2[2])~=0) then	
			m_rewardImg2:loadTexture(GoodsManager.getIconPathById(rewardinfo2[1]))
			-- m_rewardText2:setText(GoodsManager.getNameById(rewardinfo2[1]))
			m_rewardNum2:setText(rewardinfo2[2])
			m_rewardImg2:setVisible(true)
			m_rewardImg2:setTouchEnabled(true);
			m_rewardImg2:setTag(rewardinfo2[1]);
			m_rewardImg2:addTouchEventListener(goodsOnClick);
		else
			m_rewardImg2:setVisible(false)
		end

		local rewardinfo3 = split(DataTableManager.getValue("Hunt",hunterId.."_index","reward3"),";")
		if(tonumber(rewardinfo3[2])~= 0) then
			m_rewardImg3:loadTexture(GoodsManager.getIconPathById(rewardinfo3[1]))
			-- m_rewardText3:setText(GoodsManager.getNameById(rewardinfo3[1]))
			m_rewardNum3:setText(rewardinfo3[2])
			m_rewardImg3:setVisible(true)
			m_rewardImg3:setTouchEnabled(true);
			m_rewardImg3:setTag(rewardinfo3[1]);
			m_rewardImg3:addTouchEventListener(goodsOnClick);
		else
			m_rewardImg3:setVisible(false)
		end
		-- print("hunterId...."..hunterId)
		-- print(DataTableManager.getValue("Hunt", hunterId.."_index", "info"))
		m_taskDesc:setText(DataTableManager.getValue("Hunt", hunterId.."_index", "Info"))
	end
end
function initTaskArea(messageData)
	if(messageData~=nil) then
		m_taskOnServer = messageData["task_id"]
		m_taskInfoData = messageData
	end
	m_majorTaskOnGo  = DataTableManager.getValue("MajorTaskDialog",m_taskOnServer.."_index","subto")	
	for i=1,m_areaCount do
		if m_taskOnServer< NpcInfoManager.getAreaFirstMajorTaskId(i) then
			break
		end
		local itembtn = m_buttonArea:clone()
		itembtn:setTag(10000+i)
		itembtn:setTouchEnabled(true)
		itembtn:setAnchorPoint(ccp(0,0))
		local taskBtnNameLabel = tolua.cast(itembtn:getChildByName("Image_9_0"),"ImageView")
		taskBtnNameLabel:loadTexture(PATH_CCS_RES..(DataTableManager.getValue("MajorTaskInfo",i.."_index","areaName")))
		itembtn:addTouchEventListener(onAreaBtnClicked)
		m_areaList:pushBackCustomItem(itembtn)
		local statusImg = itembtn:getChildByName("Image_31")
		statusImg:setVisible(false)
	end
	updateTaskRightInfo(m_majorTaskOnGo,nil)
	--打开区域界面
	openAreaOnInit()


	local roleLevel = UserInfoManager.getRoleInfo("level")
	local needLevel = DataTableManager.getValue("MajorTaskDialog",m_taskOnServer.."_index","level")	
	if roleLevel< needLevel then
		local levelLabel = tolua.cast(m_UILayout:getWidgetByName("level_labelNum"),"LabelAtlas")
		levelLabel:setStringValue(needLevel)
		m_level_detect:setVisible(true)
		m_gotoBtn:loadTextures(PATH_CCS_RES.."cjbtn_qianwang_2.png",PATH_CCS_RES.."cjbtn_qianwang_2.png","")
		m_gotoBtn:setTouchEnabled(false)
	end
end

function openAreaOnInit()
	local function onvirtualClick()
		local maxTaskInArea = DataTableManager.getTableByName("MajorTaskInfo")
		local curAreaId = 0
		local count = 0
		for k,v in pairs(maxTaskInArea) do
			count= count+1
		end
		for i=1,count do
			local tempMax = Util.Split(maxTaskInArea[i.."_index"].maxtasks,";")
			if tonumber(tempMax[1])> m_majorTaskOnGo then
				curAreaId = i
				break
			end
		end
		local nodeTemp = CCNode:create()
		nodeTemp:setTag(10000+curAreaId)
				-- print(m_majorTaskOnGo.."ime here .................."..curAreaId)
		onAreaBtnClicked(nodeTemp,TOUCH_EVENT_TYPE_END)
		-- print(m_majorTaskOnGo.."ime here .................."..curAreaId)
	end
	performWithDelay(m_rootLayer,onvirtualClick,0.1)
end
local function onCloseClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("TaskInfoUI")
	end
end
function onGoToClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if MainCityLogic.isOpen() then 
			if m_taskOnServer == m_majorTaskOnGo - 1  then 
				local areaId =  nil
				if m_taskInfoData["status"] == 2 then 
					areaId =  DataTableManager.getValue("MajorTaskDialog",(m_taskOnServer).."_index","areaName")
				elseif m_taskInfoData["status"] == 3 then 
					areaId =  DataTableManager.getValue("MajorTaskDialog",(m_taskOnServer).."_index","area")
				elseif m_taskInfoData["status"] == 4 then 
					areaId =  DataTableManager.getValue("MajorTaskDialog",(m_taskOnServer+1).."_index","area")				
				end
				if type(areaId) == "number" then
					UIManager.close("TaskInfoUI") 
					MainCityLogic.removeMainCity()
					WorldManager.setTaskMapId(areaId)
					WorldManager.setNeedOpenSelectLevel(true);
					WorldMap.create();
					-- SelectLevel.openAppointLevel(areaId);
				elseif type(areaId) == "string" then
					local currentScenceId = MainCityLogic.getSceneID()
					if areaId ~= "scene_"..currentScenceId then
						local temp = string.gsub(areaId,"scene_","")
						local sceneId = tonumber(temp)
						UIManager.close("TaskInfoUI")
						MainCityLogic.switchLayer(sceneId,0,true,nil)
					else
						Util.showOperateResultPrompt(TEXT.mainTaskTip1)
					end
				end
			end
		else
			if m_taskOnServer == m_majorTaskOnGo - 1  then 
				local areaId =  nil
				if m_taskInfoData["status"] == 2 then 
					areaId =  DataTableManager.getValue("MajorTaskDialog",(m_taskOnServer).."_index","areaName")
				elseif m_taskInfoData["status"] == 3 then 
					areaId =  DataTableManager.getValue("MajorTaskDialog",(m_taskOnServer).."_index","area")
				elseif m_taskInfoData["status"] == 4 then 
					areaId =  DataTableManager.getValue("MajorTaskDialog",(m_taskOnServer+1).."_index","area")				
				end
				if type(areaId) == "number" then
					UIManager.close("TaskInfoUI") 
					SelectLevel.create(areaId)
				elseif type(areaId) == "string" then
					local currentScenceId = MainCityLogic.getSceneID()
					UIManager.close("TaskInfoUI")
	                WorldMap.remove();
					local temp = string.gsub(areaId,"scene_","")
					local sceneId = tonumber(temp)
            		GameManager.enterMainCityOther(sceneId);
				end
			end

		end
	end
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "missionui_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local mainLayer = tolua.cast(m_UILayout:getWidgetByName("Panel_14"),"Layout")
	    m_TaskLayout = tolua.cast(m_UILayout:getWidgetByName("task_panel"),"Layout")
	    m_buttonArea =  tolua.cast(m_UILayout:getWidgetByName("button1_panel"),"Layout")
	    m_buttonTask = tolua.cast(m_UILayout:getWidgetByName("buttonzhu1_panel"),"Layout")
	    m_buttonTask:getChildByName("Image_24"):setVisible(false)
	    m_buttonTask:getChildByName("Image_2"):setVisible(false)
	    m_majorLayout = tolua.cast(m_UILayout:getWidgetByName("Image_6"),"Layout")
	    m_huntLayout = tolua.cast(m_UILayout:getWidgetByName("Image_32"),"Layout")
	    m_areaList = tolua.cast(m_UILayout:getWidgetByName("area_list"),"ListView")
	    m_areaList:setItemsMargin(5)
	    m_taskDesc = tolua.cast(m_UILayout:getWidgetByName("task_desc"),"Label")
	    m_areaBg   = tolua.cast(m_UILayout:getWidgetByName("area_bg"),"ImageView")
	    m_rewardImg1   = tolua.cast(m_UILayout:getWidgetByName("reward_img1"),"ImageView")
	    m_rewardImg2   = tolua.cast(m_UILayout:getWidgetByName("reward_img2"),"ImageView")
	    m_rewardImg3   = tolua.cast(m_UILayout:getWidgetByName("reward_img3"),"ImageView")
	    m_rewardImg4   = tolua.cast(m_UILayout:getWidgetByName("reward_img4"),"ImageView")
	    -- m_rewardImg5   = tolua.cast(m_UILayout:getWidgetByName("reward_img5"),"ImageView")
	    -- m_rewardText1   = tolua.cast(m_UILayout:getWidgetByName("num1"),"Label")
	    -- m_rewardText2   = tolua.cast(m_UILayout:getWidgetByName("num2"),"Label")
	    -- m_rewardText3   = tolua.cast(m_UILayout:getWidgetByName("num3"),"Label")
	    -- m_rewardText4   = tolua.cast(m_UILayout:getWidgetByName("num4"),"Label")
	    -- m_rewardText5   = tolua.cast(m_UILayout:getWidgetByName("num5"),"Label")
	    m_rewardNum1   = tolua.cast(m_UILayout:getWidgetByName("num1"),"Label")
	    m_rewardNum2   = tolua.cast(m_UILayout:getWidgetByName("num2"),"Label")
	    m_rewardNum3   = tolua.cast(m_UILayout:getWidgetByName("num3"),"Label")
	    m_rewardNum4   = tolua.cast(m_UILayout:getWidgetByName("num4"),"Label")
	    -- m_rewardNum5   = tolua.cast(m_UILayout:getWidgetByName("num5"),"Label")
	    m_destination   = tolua.cast(m_UILayout:getWidgetByName("destination_text"),"Label")
	    m_exp_reward = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_40_0"),"LabelAtlas")
		m_money_reward = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_40"),"LabelAtlas")
		m_level_detect = tolua.cast(m_UILayout:getWidgetByName("level_panel"),"Layout")
		m_rewardImg4:setVisible(false)
	    -- m_closeBtn = tolua.cast(m_UILayout:getWidgetByName("close_btn"),"Button")
	    mainLayer:addTouchEventListener(onCloseClick)

	    m_gotoBtn = tolua.cast(m_UILayout:getWidgetByName("goto_btn"),"Button")
	    m_gotoBtn:addTouchEventListener(onGoToClick)

	    m_areaInfo = DataTableManager.getTableByName("MajorTaskInfo")
	    for k,v in pairs(m_areaInfo) do
	    	m_areaCount = m_areaCount +1
	    end
	end    
end

function open()
	if(not m_isOpen) then
		create();
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)
		NpcInfoManager.getMajorTaskInfo(1,initTaskArea)--npcID传1用来查看主线任务
		m_level_detect:setVisible(false)
	end
end
function close()
    if (m_isOpen) then
        m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		m_areaCount = 0
	end
end

function remove()
	if(m_isCreate) then
        m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil

		m_UILayout = nil
		m_TaskLayout = nil
		m_areaList = nil
		m_taskDesc = nil
		m_areaBg = nil
		m_rewardImg1 = nil
		m_rewardImg2 = nil
		m_rewardImg3 = nil
		m_rewardImg4 = nil
		m_rewardImg5 = nil
		m_rewardText1 = nil
		m_rewardText2 = nil
		m_rewardText3 = nil
		m_rewardText4 = nil
		m_rewardText5 = nil
		m_rewardNum1 = nil
		m_rewardNum2 = nil
		m_rewardNum3 = nil
		m_rewardNum4 = nil
		m_rewardNum5 = nil
		m_destination = nil
		m_closeBtn = nil
		m_gotoBtn = nil
		m_buttonArea = nil
		m_buttonTask = nil
		m_areaInfo = nil
		m_areaCount = 0
		m_taskOnServer = 0
		m_majorTaskOnGo = 0
		m_majorLayout = nil
		m_huntLayout = nil
		m_subTaskOnList = {}
		m_area_IDOnShow = 0
		m_exp_reward = 0
		m_money_reward =0
		m_taskInfoData = nil
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