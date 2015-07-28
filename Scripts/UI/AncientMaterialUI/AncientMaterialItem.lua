--
-- Author: Your Name
-- Date: 2015-06-04 13:10:03
--
module("AncientMaterialItem", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_isOpen = false
local m_isCreate = false;
local m_callBackFun = nil
function setCallBack(callBack)
	m_callBackFun = callBack
end
local function closeOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("AncientMaterialItem")
	end
end

function gotoHuntOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("AncientMaterialItem")
		UIManager.close("AncientMain")	
		if m_callBackFun~= nil then
			m_callBackFun() 
			m_callBackFun= nil
		end			
	end
end
function gotoMainTaskArea(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local instance = sender:getTag()
		UIManager.close("AncientMaterialItem")
		UIManager.close("AncientMain")
		MainCityLogic.removeMainCity()
		WorldManager.setTaskMapId(instance)
		local function openSelect()
			SelectLevel.openAppointLevel(instance);
		end
		WorldMap.create(openSelect);
		if m_callBackFun~= nil then
			m_callBackFun() 
			m_callBackFun= nil
		end		
	end
end
function create()
	if(m_isCreate == false)then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "cailiao_1_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local panel = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout")
	    panel:addTouchEventListener(closeOnClick);
	end

end

function open(item_id)
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, TEN_ZORDER);
        -- init(item_id)
        local nameLabel = tolua.cast(m_UILayout:getWidgetByName("Label_7"), "Label")
        nameLabel:setText(DataTableManager.getValue("AncientMaterial","id_"..item_id,"name"))
        local finishImg = tolua.cast(m_UILayout:getWidgetByName("Image_9"), "ImageView")
        local iconImg = tolua.cast(m_UILayout:getWidgetByName("Image_5"), "ImageView")
        local havedMaterail = UserInfoManager.getRoleInfo("ancientMaterial")
        local isHave = false
        for k,v in pairs(havedMaterail) do
        	if v.id == item_id then
        		isHave = true
        		break
        	end
        end
        if (isHave) then --判断是否已获得该材料

        	iconImg:loadTexture((GoodsManager.getBaseInfo(item_id)).icon)
        else
        	iconImg:loadTexture(PATH_RES_IMAGE_ANCIENT_UNGET..item_id..".png")
        end

        iconFrame = tolua.cast(m_UILayout:getWidgetByName("Image_6"), "ImageView")
        local stage_id = DataTableManager.getValue("AncientMaterial","id_"..item_id,"stage")
        local colorFrameImg = ""
        if stage_id == 1 or stage_id ==2 then 
        	colorFrameImg = GoodsManager.getColorBgImg(1)
        else
        	colorFrameImg = GoodsManager.getColorBgImg(stage_id-1)
        end
        iconFrame:loadTexture(colorFrameImg)

        local huntUnOpenLable = tolua.cast(m_UILayout:getWidgetByName("Label_14"), "Label")
        

        local itemBase = tolua.cast(m_UILayout:getWidgetByName("Panel_12"), "Layout")

        local taskBase = tolua.cast(m_UILayout:getWidgetByName("Panel_16"), "Layout")
        local itemList = tolua.cast(m_UILayout:getWidgetByName("ListView_22"), "ListView")
        local taskList = tolua.cast(m_UILayout:getWidgetByName("ListView_10"), "ListView")
        local dropType  = DataTableManager.getValue("AncientMaterial","id_"..item_id,"dropType")

        --初始化物品列表
        local itemGoodString = DataTableManager.getValue("AncientMaterial","id_"..item_id,"item_ids")
        local itemArray = Util.Split(itemGoodString,";")
        for k,v in pairs(itemArray) do
        	if v~= "" then
        		local itemInfo = GoodsManager.getBaseInfo(tonumber(v))
        		local tempItem = itemBase:clone()
        		local tempIcon = tolua.cast(tempItem:getChildByName("Image_11"), "ImageView")
        		tempIcon:loadTexture(itemInfo.icon)
        		local tempIconFrsme = tolua.cast(tempIcon:getChildByName("Image_13"), "ImageView")
        		local frameImgIcon = GoodsManager.getColorBgImg(itemInfo.color)
        		tempIconFrsme:loadTexture(frameImgIcon)
        		local tempLabel = tolua.cast(tempItem:getChildByName("Label_21"), "Label")
        		tempLabel:setText(itemInfo.name)
        		itemList:pushBackCustomItem(tempItem)
        	end
        end



        --初始化任务列表
        if dropType== 1 then --主线任务获得
        	huntUnOpenLable:setVisible(false)
        	finishImg:setVisible(false)
	        local areaString = DataTableManager.getValue("AncientMaterial","id_"..item_id,"area")
	        local areaIds = Util.Split(areaString,'%$')
		    for i=1,#areaIds-1 do
				local mainStrings = Util.Split(areaIds[i],";")
				local areaId = mainStrings[1]
				local instance = mainStrings[2]
				local desc = mainStrings[3]
				local task_item = taskBase:clone()
				task_item:setTag(instance)
				local descLabel = tolua.cast(task_item:getChildByName("Label_19"), "Label")
				descLabel:setText(desc)
				local descImg = tolua.cast(task_item:getChildByName("Image_17"), "ImageView")
				local bOpen = WorldManager.isUnLockLevel(tonumber(instance))
				if bOpen then --关卡开启
					descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_zhandou_1.png")
					-- task_item:setTag(instance)
					task_item:addTouchEventListener(gotoMainTaskArea)
					
				else
					descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_zhandou_2.png")
				end
				
				taskList:pushBackCustomItem(task_item)
		    end

        elseif dropType==2 then --赏金任务获得
        	huntUnOpenLable:setVisible(false)
        	finishImg:setVisible(false)

			local desc = DataTableManager.getValue("AncientMaterial","id_"..item_id,"hunt_desc")
			local hunt_taskid = DataTableManager.getValue("AncientMaterial","id_"..item_id,"hunt_taskid")
			local task_item = taskBase:clone()
			task_item:setTag(hunt_taskid)
			local descLabel = tolua.cast(task_item:getChildByName("Label_19"), "Label")
			descLabel:setText(desc)
			local descImg = tolua.cast(task_item:getChildByName("Image_17"), "ImageView")
			local huntBossIdNow,status = NpcInfoManager.getHuntBossId()
			local bSameBoss = false
			local bFinish = true
			--赏金任务是当前任务
			if huntBossIdNow ==nil then 
				Util.showOperateResultPrompt("报错了。。。。从新点击吧！！！！！！！！！！！！！！！")
				return
			end
			if tonumber(hunt_taskid) == tonumber(huntBossIdNow) then --赏金任务开启未完成
				if status == 1 then
					descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_xuanshang_2.png")
					huntUnOpenLable:setVisible(true)
				elseif status == 4 then
					descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_xuanshang_2.png")
					finishImg:setVisible(true)
				else
					descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_xuanshang_1.png")
					task_item:addTouchEventListener(gotoHuntOnClick)
				end
			elseif tonumber(hunt_taskid) > tonumber(huntBossIdNow) then --赏金任务未开启
				descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_xuanshang_2.png")
				huntUnOpenLable:setVisible(true)
				local openLevel = tonumber(DataTableManager.getValue("Hunt",hunt_taskid.."_index","level"))
				local newStr = string.gsub('该赏金任务30级解锁，完成前一个赏金任务即可接取.','30',openLevel)
				huntUnOpenLable:setText(newStr)
			elseif tonumber(hunt_taskid) < tonumber(huntBossIdNow) then --赏金任务已完成
				descImg:loadTexture(PATH_CCS_RES.."cailiao_tb_xuanshang_2.png")
				finishImg:setVisible(true)
			end
			
			taskList:pushBackCustomItem(task_item)
        end
        if isHave then
        	finishImg:setVisible(true)
        	taskList:removeAllItems()
        	return
        end
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
	if(m_isCreate)then
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false;
	end

end
function playGetAncientEffect(itemId)
	local itemLayer = CCLayer:create()
	local itemInfo = GoodsManager.getBaseInfo(tonumber(itemId))
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_OTHER .."gongxihuode.ExportJson");
    local armature = CCArmature:create("gongxihuode");
    armature:getAnimation():playWithIndex(0);
    armature:setPosition(ccp(568,250));
    itemLayer:addChild(armature);
    local addItemIcon = function ()
	    local itemIcon = CCSprite:create(itemInfo.icon)
	    itemIcon:setPosition(ccp(568,250+30));
	    itemLayer:addChild(itemIcon)
	    local frameImgIcon = GoodsManager.getColorBgImg(itemInfo.color)
	    local itemFrame = CCSprite:create(frameImgIcon)
	    itemFrame:setPosition(ccp(568,250+30));
	    itemLayer:addChild(itemFrame)
	    local labelName = Label:create();
	    labelName:setText(itemInfo.name);
	    labelName:setPosition(ccp(568,250-20));
	    labelName:setFontSize(25);
	    labelName:setColor(ccc3(255, 0, 0));
	    itemLayer:addChild(labelName)
	    
	    armature:getAnimation():playWithIndex(1);
    end
    schedule(itemLayer, addItemIcon, 1.5)
    getGameLayer(SCENE_GUIDE_LAYER):addChild(itemLayer)
    local removeItemLayer = function ()
    	getGameLayer(SCENE_GUIDE_LAYER):removeChild(itemLayer, true)
    end
    schedule(itemLayer, removeItemLayer, 3.5)
end