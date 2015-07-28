module("HorTabFour", package.seeall)

-------------------------------------
-- 4个标签页按钮
-------------------------------------
local m_rootLayout = nil;
local m_tabCB = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_defPos = ccp(552, 515); --默认位置


--标签底图
local m_normalTexture = IMAGE_PATH.normal_page_bg;
local m_clickTexture = IMAGE_PATH.select_page_bg;
local m_disalbedTexture    = IMAGE_PATH.disable_page_bg;

function changeTexture( tag, isOn )
	local img = tolua.cast(m_rootLayout:getWidgetByTag(tag), "ImageView");
	if(isOn) then
		img:loadTexture(m_clickTexture);
	else
		img:loadTexture(m_normalTexture);
	end
end

function changeAllTexture( isOn )
	for i = 1,4 do
		local img = tolua.cast(m_rootLayout:getWidgetByName("tab" .. i .. "_img"), "ImageView");
		if(isOn) then
			img:loadTexture(m_clickTexture);
		else
			img:loadTexture(m_normalTexture);
		end
	end
end

function changTouchTexture( touchEnables )
	for i = 1,4 do
		local img = tolua.cast(m_rootLayout:getWidgetByName("tab" .. i .. "_img"), "ImageView");
		if(touchEnables[i]) then
			img:loadTexture(m_normalTexture);
		else
			img:loadTexture(m_disalbedTexture);
		end
	end
end

-------------设置标签是否可用----------
function setTab1Enabled( enable )
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	tab1:setEnabled(enable);
end

function setTab2Enabled( enable )
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	tab2:setEnabled(enable);
end

function setTab3Enabled( enable )
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("tab3_img"), "ImageView");
	tab3:setEnabled(enable);
end

function setTab4Enabled( enable )
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("tab4_img"), "ImageView");
	tab4:setEnabled(enable);
end

function setTabEnabled( enable1, enable2, enable3, enable4 )
	setTab1Enabled(enable1);
	setTab2Enabled(enable2);
	setTab3Enabled(enable3);
	setTab4Enabled(enable4);
end




--设置不可点击状态
local function setTouchEnabeld1( enable )
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	tab1:setTouchEnabled(enable);
end

local function setTouchEnabeld2( enable )
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	tab2:setTouchEnabled(enable);
end

local function setTouchEnabeld3( enable )
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("tab3_img"), "ImageView");
	tab3:setTouchEnabled(enable);
end

local function setTouchEnabeld4( enable )
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("tab4_img"), "ImageView");
	tab4:setTouchEnabled(enable);
end

function setTouchEnabeld( enable1, enable2, enable3, enable4 )
	setTouchEnabeld1(enable1);
	setTouchEnabeld2(enable2);
	setTouchEnabeld3(enable3);
	setTouchEnabeld4(enable4);

	changTouchTexture({enable1, enable2, enable3, enable4});
end


-------------设置标签tag----------
function setTabTag( tag1, tag2, tag3, tag4 )
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("tab3_img"), "ImageView");
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("tab4_img"), "ImageView");
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
	if(name1)then setTab1Name( name1 ); end
	if(name2)then setTab2Name( name2 ); end
	if(name3)then setTab3Name( name3 ); end
	if(name4)then setTab3Name( name4 ); end
end

-------------事件回调--------------
local function tabCallback( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_tabCB) then
       		m_tabCB(sender);
		end
    end
end

-------------设置回调函数--------------
function setCallBack( tabCB )
	m_tabCB = tabCB;
end

-------------为标签绑定监听--------------
local function boundListener()
	local tab1 = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	local tab2 = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	local tab3 = tolua.cast(m_rootLayout:getWidgetByName("tab3_img"), "ImageView");
	local tab4 = tolua.cast(m_rootLayout:getWidgetByName("tab4_img"), "ImageView");
	tab1:addTouchEventListener(tabCallback);
	tab2:addTouchEventListener(tabCallback);
	tab3:addTouchEventListener(tabCallback);
	tab4:addTouchEventListener(tabCallback);
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayout = TouchGroup:create();
		m_rootLayout:retain();
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "HorTab_4.json");
		m_rootLayout:addWidget(panel);
		m_rootLayout:setPosition(m_defPos);
		boundListener();
	end
end

function open( name1, name2, name3 )
	if (not m_isOpen) then
		create();
		m_isOpen = true;
		setDislpayName( name1, name2, name3 );
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
		m_tabCB = nil;
	end
end