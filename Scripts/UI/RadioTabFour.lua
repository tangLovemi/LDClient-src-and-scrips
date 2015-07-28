module("RadioTabFour", package.seeall)

-------------------------------------
-- 4个单选标签
-------------------------------------
local m_rootLayout = nil;
local m_tab1CB = nil;
local m_tab2CB = nil;
local m_tab3CB = nil;
local m_tab4CB = nil;
local m_isOpen = false;
local m_defPos = ccp(584, 107); --默认位置

--标签底图
local m_normalTexture = PATH_CCS_RES .. "renwu_5.png";
local m_clickTexture = PATH_CCS_RES .. "renwu_2.png";

local IMG_BG_TAG_BASE = 230;

function changeTexture( tag, isOn )
	local img = tolua.cast(m_rootLayout:getWidgetByTag(tag + IMG_BG_TAG_BASE), "ImageView");
	if(isOn) then
		img:loadTexture(m_clickTexture);
	else
		img:loadTexture(m_normalTexture);
	end
end

function changeAllTexture( isOn )
	for i = 1,4 do
		local img = tolua.cast(m_rootLayout:getWidgetByName("radio" .. i .. "_img"), "ImageView");
		if(isOn) then
			img:loadTexture(m_clickTexture);
		else
			img:loadTexture(m_normalTexture);
		end
	end
end

-------------设置标签是否可用----------
function setTab1Enabled( enable )
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("qian1_panel"), "Layout");
	tab1:setEnabled(enable);
end

function setTab2Enabled( enable )
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("qian2_panel"), "Layout");
	tab2:setEnabled(enable);
end

function setTab3Enabled( enable )
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("qian3_panel"), "Layout");
	tab3:setEnabled(enable);
end
	
function setTab4Enabled( enable )
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("qian4_panel"), "Layout");
	tab4:setEnabled(enable);
end

function setTabEnabled( enable1, enable2, enable3, enable4 )
	if(enable1 ~= nil) then setTab1Enabled(enable1); end
	if(enable2 ~= nil) then setTab2Enabled(enable2); end
	if(enable3 ~= nil) then setTab3Enabled(enable3); end
	if(enable4 ~= nil) then setTab4Enabled(enable4); end
end

function setAllEnabled( enable )
	setTabEnabled( enable, enable, enable, enable )
end

-------------设置标签tag----------
function setTabTag( tag1, tag2, tag3, tag4 )
	local img1 = tolua.cast(m_rootLayout:getWidgetByName("radio1_img"), "ImageView");
	local img2 = tolua.cast(m_rootLayout:getWidgetByName("radio2_img"), "ImageView");
	local img3 = tolua.cast(m_rootLayout:getWidgetByName("radio3_img"), "ImageView");
	local img4 = tolua.cast(m_rootLayout:getWidgetByName("radio4_img"), "ImageView");
	if(tag1) then img1:setTag(tag1 + IMG_BG_TAG_BASE); end
	if(tag2) then img2:setTag(tag2 + IMG_BG_TAG_BASE); end
	if(tag3) then img3:setTag(tag3 + IMG_BG_TAG_BASE); end
	if(tag4) then img4:setTag(tag4 + IMG_BG_TAG_BASE); end

	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("qian1_panel"), "Layout");
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("qian2_panel"), "Layout");
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("qian3_panel"), "Layout");
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("qian4_panel"), "Layout");
	if(tag1) then tab1:setTag(tag1); end
	if(tag2) then tab2:setTag(tag2); end
	if(tag3) then tab3:setTag(tag3); end
	if(tag4) then tab4:setTag(tag4); end
end

-------------设置位置--------------
function setPosition( pos )
    m_rootLayout:setPosition(pos);
end

-------------设置标签显示内容----------
function setTab1Name( name )
	local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name1_label"), "Label");
	nameLabel:setText(name);
end

function setTab2Name( name )
	local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name2_label"), "Label");
	nameLabel:setText(name);
end

function setTab3Name( name )
	local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name3_label"), "Label");
	nameLabel:setText(name);
end

function setTab4Name( name )
	local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name4_label"), "Label");
	nameLabel:setText(name);
end

function setDislpayName( name1, name2, name3, name4 )
	if(name1)then setTab1Name( name1 ) end;
	if(name2)then setTab2Name( name2 ) end;
	if(name3)then setTab3Name( name3 ) end;
	if(name4)then setTab4Name( name4 ) end;
end


-------------事件回调--------------
local function tab1Callback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_tab1CB) then
        	if(m_tab1CB) then
        		m_tab1CB(sender);
        	end
		end
    end
end

local function tab2Callback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_tab2CB) then
        	if(m_tab2CB) then
        		m_tab2CB(sender);
        	end
   		end
    end
end

local function tab3Callback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_tab3CB) then
        	if(m_tab3CB) then
        		m_tab3CB(sender);
        	end
   		end
    end
end

local function tab4Callback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_tab4CB) then
        	if(m_tab4CB) then
        		m_tab4CB(sender);
        	end
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

function setTab3CallBack( cb )
	m_tab3CB = cb;
end

function setTab4CallBack( cb )
	m_tab4CB = cb;
end

function setCallBack( tab1CB, tab2CB, tab3CB, tab4CB )
	if(tab1CB) then m_tab1CB = tab1CB; end
	if(tab2CB) then m_tab2CB = tab2CB; end
	if(tab3CB) then m_tab3CB = tab3CB; end
	if(tab4CB) then m_tab4CB = tab4CB; end
end


-------------为标签绑定监听--------------
local function boundListener()
	-- local tab1 = tolua.cast(m_rootLayout:getWidgetByName("radio1_img"), "ImageView");
	-- local tab2 = tolua.cast(m_rootLayout:getWidgetByName("radio2_img"), "ImageView");
	-- local tab3 = tolua.cast(m_rootLayout:getWidgetByName("radio3_img"), "ImageView");
	-- local tab4 = tolua.cast(m_rootLayout:getWidgetByName("radio4_img"), "ImageView");
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("qian1_panel"), "Layout");
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("qian2_panel"), "Layout");
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("qian3_panel"), "Layout");
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("qian4_panel"), "Layout");
	tab1:addTouchEventListener(tab1Callback);
	tab2:addTouchEventListener(tab2Callback);
	tab3:addTouchEventListener(tab3Callback);
	tab4:addTouchEventListener(tab4Callback);
end

function create()
	m_rootLayout = TouchGroup:create();
	-- m_rootLayout:retain();
	local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "RadioTab_4.json");
	m_rootLayout:addWidget(panel);
	m_rootLayout:setPosition(m_defPos);
	boundListener();
end

function open( name1, name2, name3, name4 )
	if (not m_isOpen) then
		create();
		m_isOpen = true;
		setDislpayName( name1, name2, name3, name4 );
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
    if(m_rootLayout) then
        m_rootLayout:removeAllChildrenWithCleanup(true);
    end
    m_rootLayout = nil;
	m_tab1CB = nil;
 	m_tab2CB = nil;
 	m_tab3CB = nil;
end