module("HorTabFive", package.seeall)

-------------------------------------
-- 5个标签页按钮
-------------------------------------
local m_rootLayout = nil;
local m_tabCB = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_defPos = ccp(960, 270); --默认位置

local COUNT = 4;

--标签底图
local m_normalTexture = IMAGE_PATH.backPack_page_bg_normal;
local m_clickTexture = IMAGE_PATH.backPack_page_bg_select;
local m_disalbedTexture    = IMAGE_PATH.disable_page_bg;

local nameNormal = {
	PATH_CCS_RES .. "beibao_quanbu_2.png",
	PATH_CCS_RES .. "beibao_zhuangbei_2.png",
	PATH_CCS_RES .. "beibao_suipian_2.png",
	PATH_CCS_RES .. "beibao_zawu_2.png",
};
local nameSelect = {
	PATH_CCS_RES .. "beibao_quanbu_1.png",
	PATH_CCS_RES .. "beibao_zhuangbei_1.png",
	PATH_CCS_RES .. "beibao_suipian_1.png",
	PATH_CCS_RES .. "beibao_zawu_1.png",
};


function changTouchTexture( touchEnables )
	for i = 1,COUNT do
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


function setTabEnabled( enable1, enable2, enable3, enable4, enable5 )
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


function setTouchEnabeld( enable1, enable2, enable3, enable4, enable5 )
	setTouchEnabeld1(enable1);
	setTouchEnabeld2(enable2);
	setTouchEnabeld3(enable3);
	setTouchEnabeld4(enable4);

	changTouchTexture({enable1, enable2, enable3, enable4});
end


-------------设置标签tag----------
function setTabTag( tag1, tag2, tag3, tag4, tag5 )
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
function setTab1Name( status )
	local tab = tolua.cast(m_rootLayout:getWidgetByName("tab1_img"), "ImageView");
	if(status) then
		tab:loadTexture(nameSelect[1]);
	else
		tab:loadTexture(nameNormal[1]);
	end
end
function setTab2Name( status )
	local tab = tolua.cast(m_rootLayout:getWidgetByName("tab2_img"), "ImageView");
	if(status) then
		tab:loadTexture(nameSelect[2]);
	else
		tab:loadTexture(nameNormal[2]);
	end
end

function setTab3Name( status )
	local tab = tolua.cast(m_rootLayout:getWidgetByName("tab3_img"), "ImageView");
	if(status) then
		tab:loadTexture(nameSelect[3]);
	else
		tab:loadTexture(nameNormal[3]);
	end
end

function setTab4Name( status )
	local tab = tolua.cast(m_rootLayout:getWidgetByName("tab4_img"), "ImageView");
	if(status) then
		tab:loadTexture(nameSelect[4]);
	else
		tab:loadTexture(nameNormal[4]);
	end
end

function setDislpayName( status )
	if(status[1] ~= nil)then setTab1Name( status[1] ); end
	if(status[2] ~= nil)then setTab2Name( status[2] ); end
	if(status[3] ~= nil)then setTab3Name( status[3] ); end
	if(status[4] ~= nil)then setTab4Name( status[4] ); end
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
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "HorTab_5.json");
		m_rootLayout:addWidget(panel);
		m_rootLayout:setPosition(m_defPos);
		boundListener();
	end
end

function open()
	if (not m_isOpen) then
		create();
		m_isOpen = true;
		-- setDislpayName( name1, name2, name3 );
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