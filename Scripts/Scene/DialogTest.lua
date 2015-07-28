-- --
-- -- Author: gaojiefeng
-- -- Date: 2014-12-09 10:13:02
-- --
-- module("DialogTest", package.seeall)


-- local m_rootLayer = nil;
-- local DialogText = nil;
-- local missionInfo = nil;
-- local m_panel = nil  
-- local m_dialogID = 10003;
-- local m_sceneEditorData = nil; --
-- local npcID = nil; --点击的npcID

-- function onRecieveMission(messageType, messageData)
-- 	m_dialogID = messageData.task_id
-- 	DialogText:setText(tostring(missionInfo["id_"..m_dialogID].DialogContent))
-- 	DialogText:setVisible(true);
-- 	m_panel:addTouchEventListener(touchEvent);
-- end
-- --消息接收管理NETWORK_MESSAGE_SEND_CLICK_NPC

-- function setDialogID( dialogid )
-- 	m_dialogID = dialogid
-- end

-- function touchEvent(sender,eventType)
-- 	if eventType == TOUCH_EVENT_TYPE_END then	
-- 		print(".......m_dialogID....................."..m_dialogID)
-- 		if 	m_dialogID ~= 0 then
-- 			if tostring(missionInfo[tostring("id_"..(m_dialogID+1))].DialogContent)== "0" then
-- 				close()
-- 				m_dialogID = 0
-- 			elseif DialogText:getStringValue() == tostring(missionInfo[tostring("id_"..m_dialogID)].DialogContent) then
-- 				DialogText:setText(tostring(missionInfo[tostring("id_"..(m_dialogID+1))].DialogContent))
-- 				m_dialogID = m_dialogID+1
-- 			end
-- 		end
-- 	end

-- end
-- --点击任务按钮
-- function missionOnClick( sender,eventType)
-- 	if eventType == TOUCH_EVENT_TYPE_END then
-- 		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CLICK_NPC, {1000})
-- 	end
-- end
-- --点击打开UI按钮
-- function openUIOnClick( sender,eventType)
-- 	if eventType == TOUCH_EVENT_TYPE_END then
-- 		openUI()
-- 	end
-- end


-- function create(data)
-- 	m_sceneEditorData = data

-- 	--data 为场景编辑器传过来数据，包含以下信息
-- 	--1，任务信息，从而设置对话信息
-- 	--2，UI信息，如果选择打开UI,这边进行操作
-- 	--3 UI暂停信息
-- 	npcID = m_sceneEditorData[1]
-- 	m_dialogID =10003;--暂定设置
-- --	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAJORTASK_INFO, onRecieveMission);
-- 	m_rootLayer = CCLayer:create();
-- 	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Dialog_1.json");
--     local uiLayer = TouchGroup:create();
--     uiLayer:addWidget(uiLayout);
--     m_rootLayer:addChild(uiLayer);
--     --添加点击监听
--     m_panel = tolua.cast(uiLayer:getWidgetByName("Panel_20"), "Layout")
--     --对话框
--     DialogText = tolua.cast(uiLayout:getChildByName("dialogContent"), "Label");
--     DialogText:setVisible(false)
    
--     -- tipToChoose//尚未使用的固定文本标签
--     local missionBtn = tolua.cast(uiLayer:getWidgetByName("mission_btn"), "Button");
--     missionBtn:addTouchEventListener(missionOnClick);

--     local openUIBtn = tolua.cast(uiLayer:getWidgetByName("open_UI_btn"), "Button");
--     openUIBtn:addTouchEventListener(openUIOnClick);	

--     local closeBtn = tolua.cast(uiLayer:getWidgetByName("closeBtn"), "Button");
--     closeBtn:addTouchEventListener(close);
    
-- 	missionInfo = DataTableManager.getTableByName("MissionDialog")
-- 	if m_dialogID ~= 0 then
-- 		DialogText:setText(tostring(missionInfo[m_dialogID.."_index"].DialogContent))
-- 	end

-- -- -- 创建动画
-- -- 	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_PLAYER .. "NewProject.ExportJson");

-- -- 	m_Actor = SJArmature:create("NewProject")
-- -- 	m_panel:addChlid(m_Actor)
-- -- 	local onTouchRootLayer = function( ... )
-- -- 	print("onTouchRootLayeronTouchRootLayeronTouchRootLayeronTouchRootLayeronTouchRootLayeronTouchRootLayer")
-- -- 		return(true)
-- -- 	end

-- -- 	m_rootLayer:registerWithTouchDispatcher(onTouchRootLayer)



	
-- end

-- function open()
-- 	local uiLayer = getGameLayer(SCENE_UI_LAYER);
-- 	uiLayer:addChild(m_rootLayer);
-- end
-- function close()
-- 	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
-- 	uiLayer:removeChild(m_rootLayer,false);
-- end

-- function remove()
-- 	-- body
-- 	m_rootLayer:removeAllChildrenWithCleanup(true);	
-- 	m_rootLayer:release();
-- 	initVariables();
-- end
-- function initVariables()
-- 	-- body
-- 	m_rootLayer = nil;
-- end

-- --打开UI
-- function openUI()
--     local uiName = m_sceneEditorData[2];
--     local pauseGame = m_sceneEditorData[3];
-- 	m_scene = _G["MainCityLogic"];
--     if (m_scene.openUI) then
--         m_scene.openUI(uiName, pauseGame);
--     end
-- end