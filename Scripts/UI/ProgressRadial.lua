module("ProgressRadial", package.seeall)

local m_layer = nil;
local m_pt = nil;
local m_isOpen = false;
local m_isCreate = false;

function open()
	if(not m_isOpen) then
		m_isOpen = true;

		if(not m_isCreate) then
			m_layer = CCLayer:create();
			local progressPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ClosePanelBtn.json");
			local layout = TouchGroup:create();
        	layout:addWidget(progressPanel);
			m_pt = CCSprite:create(PATH_RES_IMAGE .. "ProgressRadial.png");
			m_pt:setPosition(ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2));
			progressPanel:addNode(m_pt);
			m_layer:addChild(layout);
			m_layer:retain();
			m_isCreate = true;
		end
		
		m_pt:runAction(CCRepeatForever:create(CCRotateBy:create(1, 360)));
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_layer, 10);

		if(MainCityLogic.getRootLayer() ~= nil and layerName ~= "MainCityUI") then
			MainCityLogic.unregisterTouchFunction();
		end
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		m_pt:stopAllActions();
		m_layer:removeFromParentAndCleanup(false);
		if(MainCityLogic.getRootLayer() ~= nil) then
			MainCityLogic.registerTouchFunction();
		end
	end
end