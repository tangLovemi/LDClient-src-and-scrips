module("FaceMakerNew", package.seeall)

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate = false;
local m_isOpen = false;


local SLV_TAG_BASE = 323;
local m_count = 0; --显示的数量
local m_totalCount = 0; --ScrollView 中子项数量
local COUNT_ONE_LINE = 4;
local SPACE = 3; -- icon间隔
local PANEL_W = 0;
local ICON_W = 97;

local PATH_PANEL_BG_ICON = PATH_CCS_RES .. "xj_kuang_1.png";
local PATH_PANEL_SELECT_BG = PATH_CCS_RES .. "xj_kuang_2.png";

local TAG_FACE  = 1;
local TAG_HAIR  = 2;
local TAG_COLOR = 3;

local COUNT_NAMES = 0;

local COUNT = {
	17, --face
	15, --hair
	10, --color
};

local name = {
	"face", --face
	"hair", --hair
	"color", --color
}

local m_index;
local m_curTag = TAG_FACE;

local m_slv = nil;
local m_playerAnim = nil;

local m_pageNormalPath = {
	PATH_CCS_RES .. "xjbtn_lianxing_2.png", --face
	PATH_CCS_RES .. "xjbtn_faxing_2.png", --hair
	PATH_CCS_RES .. "xjbtn_fase_2.png", --color
}

local m_pageSelectPath = {
	PATH_CCS_RES .. "xjbtn_lianxing_1.png", --face
	PATH_CCS_RES .. "xjbtn_faxing_1.png", --hair
	PATH_CCS_RES .. "xjbtn_fase_1.png", --color
}


---数据---
--三者的数据
local m_data = {
	0, -- face
	0, -- hair
	0, -- color
};

local m_status = 0;
----------

function getFaceCount()
	return COUNT[TAG_FACE];
end

function getHairCount()
	return COUNT[TAG_HAIR];
end

function getColorCount()
	return COUNT[TAG_COLOR];
end

local function setData( tag, data )
	m_data[tag] = data;
end

local function getData( tag )
	return m_data[tag];	
end

local function closeOnClick( sender, eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		UIManager.close("FaceMakerNew");
	end
end

--根据物品数量得到行数
local function getLinesCount(count)
 	local lines = math.floor(count/COUNT_ONE_LINE);
    if(count%COUNT_ONE_LINE > 0) then
    	lines = lines + 1;
    end
    return lines;
end

--得到某行的数量（line:行数 count:物品总个数）
local function getCountAtLine( line, count )
	local countALine;
	local last = count - (line - 1)*COUNT_ONE_LINE;
	if( last >= COUNT_ONE_LINE ) then
		countALine = COUNT_ONE_LINE;
	else
		countALine = last;
	end
	return countALine;
end

local function resetSlvItemsPosition(count)
    row = getLinesCount(count);
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    for i = 1,row do
    	local countAtLine = getCountAtLine(i, count);
        for j = 1,countAtLine do
            local panel = tolua.cast(m_slv:getChildByTag(SLV_TAG_BASE + (j + (i-1)*COUNT_ONE_LINE)), "Layout");
            panel:setPosition(
                    ccp(SPACE + (PANEL_W + SPACE)*(j - 1), 
                        slvInnerH - ((SPACE + PANEL_W) + (SPACE + PANEL_W)*(i - 1))
                        )
                    );
        end
    end
end

local function setSlvInnerSize(count)
    local row = math.ceil(count/COUNT_ONE_LINE);
    local innerHeight = PANEL_W*row + (row + 1)*SPACE;
    m_slv:setInnerContainerSize(CCSize((m_slv:getSize()).width, innerHeight));
    resetSlvItemsPosition(count);
end

local function calCurCount()
	m_count = COUNT[m_curTag];
end

local function getCount( tag )
	return COUNT[tag];
end

local function setPanelVisible()
    for i = 1,m_totalCount do
        local panel = m_rootLayout:getWidgetByTag(i + SLV_TAG_BASE);
        if(i <= m_count) then
            panel:setEnabled(true);
        else
            panel:setEnabled(false);
        end
    end
end

--------------------------------网络交互 begin--------------------------------
local function getFaceInfo()
	-- m_faceMaker = {
	-- 	hair      = 0,
	-- 	face      = 0,
	-- 	eyebrows  = 0,
	-- 	mouth     = 0,
	-- 	eye       = 0,
	-- 	name      = "",
	-- 	hairColor = {
	-- 		r = 0,
	-- 		g = 0,
	-- 		b = 0,
	-- 	}

	-- 	eyeColor  = {
	-- 		r = 0,
	-- 		g = 0,
	-- 		b = 0,
	-- 	}
	-- };
	local hairId = m_data[TAG_HAIR];
	local faceId = m_data[TAG_FACE];
	local eyebrowsId = 0;
	local mouthId = 0;
	local eyeId   = 0;
	local name = tolua.cast(m_rootLayout:getWidgetByName("inputName_textfield"), "TextField"):getStringValue();
	local hairColor = {
		r = m_data[TAG_COLOR],
		g = m_data[TAG_COLOR],
		b = m_data[TAG_COLOR],
	};
	local eyeColor = {
		r = 0,
		g = 0,
		b = 0,
	};

	local faceInfo = 
	{hairId,faceId,eyebrowsId,mouthId,eyeId,name,
	hairColor.r,hairColor.g,hairColor.b,  eyeColor.r,eyeColor.g,eyeColor.b};

	return faceInfo;
end

--创建角色返回
local function recieveDataForCreateRole(messageType,messageData)
	if messageData.sure ~= 1 then
		ProgressRadial.close();
	end
end

local function sendCreateRole()
	local name = tolua.cast(m_rootLayout:getWidgetByName("inputName_textfield"), "TextField"):getStringValue();
	if(name ~= "") then
		ProgressRadial.open();
		local faceInfo = getFaceInfo();
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CREATEROLE, faceInfo);
	else
		Util.showOperateResultPrompt("名字不能为空");
	end
end

--确定更改返回
local function receiveFaceMakerChangeResponse( messageType,messageData )
	ProgressRadial.close();

	PlayerActor.changeFace();
	UIManager.close("FaceMakerNew");
end

local function sendChangeRole()
	ProgressRadial.open();
	local data = {m_data[TAG_HAIR], m_data[TAG_FACE], m_data[TAG_COLOR]};
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FACEMAKER_CHANGE, data);
end

--确定按钮点击
local function sureOnClick( sender, eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		-- sendChangeRole();
		if(m_status) then
			if(m_status == FACEMAKER_STATUS_CREATE) then
				--创建角色
				sendCreateRole();
			elseif(m_status == FACEMAKER_STATUS_CHANGE) then
				--更改角色
				sendChangeRole();
			end
		end
	end
end

--------------------------------网络交互 end--------------------------------


--------------------------------逻辑处理 begin--------------------------------

local function refreshIcon()
    local count = getCount(m_curTag);
    if(count > 0) then
        for i = 1,count do
            local panel = tolua.cast(m_rootLayout:getWidgetByTag(i + SLV_TAG_BASE), "Layout");
            local icon = tolua.cast(panel:getChildByName("icon"), "ImageView");
			local path = "";
           	if(m_curTag == TAG_COLOR) then
           		path = Util.getColorImgPath(i);
       		elseif(m_curTag == TAG_FACE) then
       			path = Util.getFaceImgPath(i);
   			elseif(m_curTag == TAG_HAIR) then
       			path = Util.getHairImgPath(i, 4);
       		end
           	icon:loadTexture(path);
        end
    end
end

local function changePageBg()
	for i=1,3 do
		tolua.cast(m_rootLayout:getWidgetByName(name[i] .. "Page_img"), "ImageView"):loadTexture(m_pageNormalPath[i]);
	end
	tolua.cast(m_rootLayout:getWidgetByName(name[m_curTag] .. "Page_img"), "ImageView"):loadTexture(m_pageSelectPath[m_curTag]);
end

--标志当前页下已选择的项
local function showSelectOne()
	local count = getCount(m_curTag);
    if(count > 0) then
        for i = 1,count do
            local panel = tolua.cast(m_rootLayout:getWidgetByTag(i + SLV_TAG_BASE), "Layout");
           	--bg
            local bgImg = tolua.cast(panel:getChildByName("bg"), "ImageView");
            bgImg:loadTexture(PATH_PANEL_BG_ICON);
        end
    end

	if(getData(m_curTag) > 0) then
		local panel = tolua.cast(m_rootLayout:getWidgetByTag(getData(m_curTag) + SLV_TAG_BASE), "Layout");
        local bgImg = tolua.cast(panel:getChildByName("bg"), "ImageView");
        bgImg:loadTexture(PATH_PANEL_SELECT_BG);
	end
end

local function changePage()
	-- m_curTag
	--根据二级标签id(m_curTag)先得到应该显示的数量，然后跟m_totalCount比较，
	--判断是否需要为ScrollView新增子项，改变innerSize
    calCurCount();
    if(m_count > m_totalCount) then
        for i = m_totalCount + 1,m_count do
            local row = math.ceil(i/COUNT_ONE_LINE);
            local col = i%COUNT_ONE_LINE;
            if(col == 0) then col = COUNT_ONE_LINE; end
            createSlvItem(row, col);
        end
        m_totalCount = m_count;
    end
    setSlvInnerSize(m_count);
    setPanelVisible();
    refreshIcon();
    changePageBg();
    showSelectOne();
end


--点击三个选择标签
local function pagePanelOnClick( sender, eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local tag = sender:getTag();
		if(tag ~= m_curTag) then
			m_curTag = tag;
			changePage();
		end
	end
end

local function changeFace()
    --更改角色动画脸部
    local faceInfo = {face = m_data[TAG_FACE], hair = m_data[TAG_HAIR], hairColor = m_data[TAG_COLOR]};
    PlayerActor.changeFace(faceInfo);
end

--点击某一项
local function choiceOneItem()
	-- m_curTag, m_index

	print("****** m_index = " .. m_index);
    setData(m_curTag, m_index);
    showSelectOne();
    changeFace();
end

--设置名称
local function setName(name)
	tolua.cast(m_rootLayout:getWidgetByName("inputName_textfield"), "TextField"):setText(name);
	tolua.cast(m_rootLayout:getWidgetByName("name_label"), "Label"):setText(name);
end

--随机姓名
local function randomName()
    local names = DataTableManager.getTableByName("NamesRandom");
    local t = Util.random3(2, COUNT_NAMES);
    local random1 = t[1];
    local random2 = t[2];
    return names["id_" .. random1].name .. "·" .. names["id_" .. random2].xing;
end

--------------------------------逻辑处理 end--------------------------------

local function randomNameOnClick( sender, eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		setName(randomName());
	end
end


local function onTouchBegan(sender)
    
end

local function onTouchEnded(sender)
    local panel = tolua.cast(sender, "Layout");
    local index = panel:getTag() - SLV_TAG_BASE;
    m_index = index;
    choiceOneItem();
end

local function onTouchCancel( sender )
   
end

local function slvTouchEvent( sender,eventType )
    if(eventType == TOUCH_EVENT_TYPE_BEGIN) then
        onTouchBegan(sender);
    elseif(eventType == TOUCH_EVENT_TYPE_END) then
        onTouchEnded(sender);
    elseif(eventType == TOUCH_EVENT_TYPE_CANCEL) then
        onTouchCancel(sender);
    end
end

function createSlvItem( row, col )
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    local panel = Layout:create();
    panel:setSize(CCSize(PANEL_W, PANEL_W));
    local pos =  ccp(SPACE + (PANEL_W + SPACE)*(col - 1), 
            slvInnerH - ((SPACE + PANEL_W) + (SPACE + PANEL_W)*(row - 1))
            );
    panel:setPosition(pos);

    local bgImg = ImageView:create();
    bgImg:ignoreContentAdaptWithSize(false);
    bgImg:setName("bg");
    bgImg:setSize(CCSize(PANEL_W - 3, PANEL_W - 3));
    bgImg:loadTexture(PATH_PANEL_BG_ICON);
    bgImg:setPosition(ccp(PANEL_W/2, PANEL_W/2));
    panel:addChild(bgImg);

    local icon = ImageView:create();
    icon:ignoreContentAdaptWithSize(false);
    icon:setName("icon");
    icon:setSize(CCSize(ICON_W, ICON_W));
    icon:setPosition(ccp(PANEL_W/2, PANEL_W/2));
    panel:addChild(icon);
    
    local tag = SLV_TAG_BASE + (col + (row-1)*COUNT_ONE_LINE);
    panel:addTouchEventListener(slvTouchEvent);
    panel:setTouchEnabled(true);
    panel:setTag(tag);
    m_slv:addChild(panel, 1);
end

local function createSlv(count)
    local lines = getLinesCount(count);
    for i = 1,lines do
    	local countAtLine = getCountAtLine(i, count);
        for j = 1,countAtLine do
            createSlvItem(i, j);
        end
    end
    setSlvInnerSize(count);
end


local function createinit()
    --得到各个物品的最大数量去创建，切换时更改innerSize即可
    m_totalCount = COUNT[TAG_FACE];
    m_slv = tolua.cast(m_rootLayout:getWidgetByName("slv"), "ScrollView");
    local slvWidth = (m_slv:getSize()).width;
    PANEL_W = (slvWidth - (COUNT_ONE_LINE + 1)*SPACE)/COUNT_ONE_LINE;
end


local function registerMessage()
	--创建角色返回
	if(m_status) then
		if(m_status == FACEMAKER_STATUS_CREATE) then
			--创建角色
    		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_CREATEROLE, recieveDataForCreateRole);
		elseif(m_status == FACEMAKER_STATUS_CHANGE) then
			--更改角色
    		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FACEMAKER_CHANGE_RESPONSE, receiveFaceMakerChangeResponse);
		end
	end
end

local function unRegisterMessage()
	if(m_status) then
		if(m_status == FACEMAKER_STATUS_CREATE) then
			--创建角色
			NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_CREATEROLE, recieveDataForCreateRole);
		elseif(m_status == FACEMAKER_STATUS_CHANGE) then
			--更改角色
    		NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_FACEMAKER_CHANGE_RESPONSE, receiveFaceMakerChangeResponse);
		end
	end
end

----------------------------------角色动画------------------------------------
local function createAnimation()
    m_playerAnim = PlayerActor.getFigureActor();

    local animaPanel = tolua.cast(m_rootLayout:getWidgetByName("animPos_panel"), "Layout");
    animaPanel:addNode(m_playerAnim);
    m_playerAnim:setPosition(ccp(18, -2632 + 10));
end

local function removeAnimation()
    m_playerAnim:removeFromParentAndCleanup(false);
    m_playerAnim = nil;
end


local function initDisplay()
    --初始化数据
    m_curTag = TAG_FACE;
    COUNT_NAMES = DataTableManager.getCount("NamesRandom");
    --创建或更改
    if(m_status) then
		if(m_status == FACEMAKER_STATUS_CREATE) then
			--创建角色
			m_rootLayout:getWidgetByName("create_panel"):setEnabled(true);
			m_rootLayout:getWidgetByName("name_panel"):setEnabled(false);

		    m_data[TAG_FACE] = Util.random(COUNT[TAG_FACE]);
		    m_data[TAG_HAIR] = Util.random(COUNT[TAG_HAIR]);
		    m_data[TAG_COLOR] = Util.random(COUNT[TAG_COLOR]);
		    changeFace();

		    --随机名称
		    setName(randomName());
		elseif(m_status == FACEMAKER_STATUS_CHANGE) then
			--更改角色
			m_rootLayout:getWidgetByName("name_panel"):setEnabled(true);
			m_rootLayout:getWidgetByName("create_panel"):setEnabled(false);
			setName(UserInfoManager.getRoleInfo("name"));
			
			local faceInfo = UserInfoManager.getAllFaceInfo();
		    m_data[TAG_FACE] = faceInfo.face;
		    m_data[TAG_HAIR] = faceInfo.hair;
		    m_data[TAG_COLOR] = faceInfo.hair_color.r;
		end
	else
		print("************ 捏脸：打开漏填参数(创建；更改)");
	end

    changePage();
	--加载角色动画
	createAnimation();
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

		m_rootLayout = TouchGroup:create();
		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "FaceMakerUI_1.json");
		m_rootLayout:addWidget(uiLayout);
		m_rootLayer:addChild(m_rootLayout, 1);
		BattleManager.setDebugMode(true);
   	 	-- m_rootLayout:getWidgetByName("close_btn"):addTouchEventListener(closeOnClick);

   	 	createinit();
   	 	createSlv(m_totalCount); --先按最大数量去创建
   	 	--标签页
   	 	local facePanel = m_rootLayout:getWidgetByName("face_panel");
   	 	local hairPanel = m_rootLayout:getWidgetByName("hair_panel");
   	 	local colorPanel = m_rootLayout:getWidgetByName("hairColor_panel");
   	 	facePanel:setTag(TAG_FACE);
   	 	hairPanel:setTag(TAG_HAIR);
   	 	colorPanel:setTag(TAG_COLOR);
   	 	facePanel:addTouchEventListener(pagePanelOnClick);
   	 	hairPanel:addTouchEventListener(pagePanelOnClick);
   	 	colorPanel:addTouchEventListener(pagePanelOnClick);

   	 	--确定按钮
   	 	m_rootLayout:getWidgetByName("sure_btn"):addTouchEventListener(sureOnClick);

   	 	m_rootLayout:getWidgetByName("random_btn"):addTouchEventListener(randomNameOnClick);
	end
end

function open(status)
	if(not m_isOpen) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);

        m_status = nil;
        if(status) then
        	m_status = status;
        end

        initDisplay();
        registerMessage();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

        unRegisterMessage();
        removeAnimation();
        if(m_status and m_status == FACEMAKER_STATUS_CHANGE) then
			PlayerActor.changeFace();
        end

		ProgressRadial.close();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    end
		m_rootLayer = nil;
		m_rootLayout = nil;
	end
end