module("BackpackFigurePage", package.seeall)

-------------------------------------
-- 3个标签页按钮
-------------------------------------
local m_rootLayout = nil;
local m_tab1CB = nil;
local m_tab2CB = nil;
local m_tab3CB = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_defPos = ccp(552, 471); --默认位置

--标签底图

local nameNormal = {
	PATH_CCS_RES .. "biaoqian_renwu_2.png",
	PATH_CCS_RES .. "biaoqian_beibao_2.png",
};
local nameSelect = {
	PATH_CCS_RES .. "biaoqian_renwu_1.png",
	PATH_CCS_RES .. "biaoqian_beibao_1.png",
};

local COUNT = 2;

-------------设置标签tag----------
function setTabTag( tag1, tag2 )
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	if(tag1) then tab1:setTag(tag1); end
	if(tag2) then tab2:setTag(tag2); end
end

-------------设置位置--------------
function setPosition( pos )
    m_rootLayout:setPosition(pos);
end

-------------设置标签显示内容----------
function setTab1Name( status )
	local nameImg = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	if(status) then
		nameImg:loadTexture(nameSelect[1]);
	else
		nameImg:loadTexture(nameNormal[1]);
	end
end

function setTab2Name( status )
	local nameImg = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	if(status) then
		nameImg:loadTexture(nameSelect[2]);
	else
		nameImg:loadTexture(nameNormal[2]);
	end
end

function setDislpayName( status )
	if(status[1] ~= nil)then setTab1Name( status[1] ); end
	if(status[2] ~= nil)then setTab2Name( status[2] ); end
end


-------------事件回调--------------
local function tab1Callback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_tab1CB) then
       		m_tab1CB(sender);
		end
    end
end

local function tab2Callback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        if(m_tab2CB) then
        	m_tab2CB(sender);
        end
    end
end

-------------设置回调函数--------------
function setTab1CallBack( cb )
	m_tab1CB = cb;
end

function setTab2CallBack( cb )
	m_tab2CB = cb;
end


function setCallBack( tab1CB, tab2CB )
	m_tab1CB = tab1CB;
	m_tab2CB = tab2CB;
end

-------------为标签绑定监听--------------
local function boundListener()
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	tab1:addTouchEventListener(tab1Callback);
	tab2:addTouchEventListener(tab2Callback);
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayout = TouchGroup:create();
		m_rootLayout:retain();
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "BackpackFigurePage_1.json");
		m_rootLayout:addWidget(panel);
		m_rootLayout:setPosition(m_defPos);
		boundListener();
	end
end

function open( status )
	if (not m_isOpen) then
		create();
		m_isOpen = true;
		setDislpayName( status );
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayout, FOUR_ZORDER);
	end
end

function close()
	if (m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayout, false);
    end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
	    if(m_rootLayout) then
	        m_rootLayout:removeAllChildrenWithCleanup(true);
            m_rootLayout:release();
	    end
	    m_rootLayout = nil;
		m_tab1CB = nil;
	 	m_tab2CB = nil;
	 	m_tab3CB = nil;
	end
end