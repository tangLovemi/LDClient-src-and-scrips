module("TrainHelp", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;


local function onTouch(eventType,x,y)
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		TrainHelp.close();
	end
end

local function openInit()
	
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		bgLayer:registerScriptTouchHandler(onTouch);
		m_rootLayer:addChild(bgLayer);

		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TrainHelp.json");
		m_uiLayer = TouchGroup:create();
		m_uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(m_uiLayer);

		m_rootLayer:retain();
	end
end


function open()
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);

		openInit();
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
	if(m_isCreate) then
		m_isCreate = false;
		-- body	
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		m_uiLayer 	= nil;
	end
end
