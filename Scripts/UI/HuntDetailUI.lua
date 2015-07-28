
-- module("HuntDetailUI", package.seeall)
-- local m_rootLayer =nil
-- local m_isCreate = false;

-- local m_UILayout = nil
-- local m_taskAcceptBtn = nil
-- local m_closeBtn = nil
-- local m_currentTaskID = nil --当前展示任务编号
-- local m_Current_Task_Status = nil --当前展示任务编号状态
-- local m_ItemLayout = nil
-- local m_scrollView = nil
-- local m_ItemNum = 0
-- local m_innerPanel = nil

-- local function closeBtnOnClick(sender,eventType)
-- 	if eventType == TOUCH_EVENT_TYPE_END then
-- 		UIManager.close("HuntDetailUI")
-- 	end
-- end

-- local function itemOnClick( sender,eventType )
-- 	if eventType == TOUCH_EVENT_TYPE_END then
-- 		print("...................."..sender:getTag())
-- 		local params ={}
-- 		params.clicked_Task = sender:getTag()
-- 		if(m_currentTaskID-params.clicked_Task>0) then
-- 			params.clicked_Task_Status = 5
-- 			--任务完成
-- 		elseif (m_currentTaskID-params.clicked_Task==0) then
-- 			params.clicked_Task_Status = m_Current_Task_Status
-- 		elseif (m_currentTaskID-params.clicked_Task<0) then	
-- 			params.clicked_Task_Status = 1
-- 		end
-- 		params.current_Task = m_currentTaskID
-- 		params.current_Task_Status = m_Current_Task_Status
-- 		UIManager.close("HuntDetailUI")
-- 		UIManager.open("HuntInfoUI",params)
-- 	end
-- end
-- local function goBackBtnOnClick(sender,eventType )
-- 	if eventType == TOUCH_EVENT_TYPE_END then
-- 		UIManager.close("HuntDetailUI")
-- 		UIManager.open("HuntUI")
-- 	end
-- end
-- function initScrollViewItems()

-- 	for i=1,m_ItemNum do
-- 		local taskId =700001 + i*100
-- 		local itemBtn = tolua.cast(m_UILayout:getWidgetByName(tostring(taskId)), "Button");
--     	if(m_currentTaskID-taskId>0) then
-- 			local imageName = DataTableManager.getValue("Hunt", taskId.."_index", "img")
-- 			imageString = PATH_RES_IMAGE_HUNTER..imageName..".png"
-- 		elseif m_currentTaskID-taskId==0 then
-- 			if 	m_Current_Task_Status==1 then
-- 				imageString = PATH_RES_IMAGE_HUNTER.."not_open.png"
-- 			else
-- 				local imageName = DataTableManager.getValue("Hunt", taskId.."_index", "img")
-- 				imageString = PATH_RES_IMAGE_HUNTER..imageName..".png"
-- 			end
-- 		else
-- 			imageString = PATH_RES_IMAGE_HUNTER.."not_open.png"
-- 		end
-- 		itemBtn:loadTextures(imageString,"","")
-- 		itemBtn:setTag(taskId)
-- 		-- local nameText = tolua.cast(tempPanel:getChildByName("name_text"), "Label")
-- 		-- nameText:setText(DataTableManager.getValue("Hunt", taskId.."_index", "huntName"))
-- 	end

-- end
-- function create()
-- 	if (not m_isCreate) then
-- 		m_isCreate= true
-- 		m_rootLayer = CCLayer:create();
-- 		m_rootLayer:retain()
		
-- 		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "shangjin2_1.json");
-- 	    m_UILayout = TouchGroup:create();
-- 	    m_UILayout:addWidget(UISource);
-- 	    m_rootLayer:addChild(m_UILayout);
-- 	    local layoutButtom = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout");
-- 	    layoutButtom:addTouchEventListener(closeBtnOnClick);  

-- 	    -- m_closeBtn = tolua.cast(m_UILayout:getWidgetByName("close_btn"), "Button");
-- 	    -- m_closeBtn:addTouchEventListener(closeBtnOnClick);  
-- 	   	-- m_goBackBtn = tolua.cast(m_UILayout:getWidgetByName("goback_btn"), "Button");
-- 	    -- m_goBackBtn:addTouchEventListener(goBackBtnOnClick);  
-- 	    -- m_goBackBtn:setTitleText("返回当前任务")
-- 		m_scrollView = tolua.cast(m_UILayout:getWidgetByName("ScrollView_29"), "ScrollView");

-- 		local huntInfo = DataTableManager.getTableByName("Hunt")
-- 		for k,v in pairs(huntInfo) do
-- 			if(v~=nil) then
-- 				m_ItemNum = m_ItemNum+1
-- 			end
-- 		end
-- 		for i=1,m_ItemNum do
-- 			local taskId =700001 + i*100
-- 			local itemBtn = tolua.cast(m_UILayout:getWidgetByName(tostring(taskId)), "Button");
-- 			itemBtn:addTouchEventListener(itemOnClick)
-- 		end
-- 	end
-- end


-- function open(params)
-- 	create();
-- 	local uiLayer = getGameLayer(SCENE_UI_LAYER);
-- 	uiLayer:addChild(m_rootLayer);
-- 	m_currentTaskID = params.current_Task
-- 	m_Current_Task_Status = params.current_Task_Status
-- 	initScrollViewItems()



-- end
-- function close()
-- 	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
-- 	uiLayer:removeChild(m_rootLayer,false);
-- end

-- function remove()
-- 	if (m_isCreate) then 
-- 		m_isCreate = false
-- 		-- body
-- 		m_rootLayer:removeAllChildrenWithCleanup(true);	
-- 		m_rootLayer:release();
-- 		m_rootLayer= nil
-- 	end
-- end