module("GoodsList", package.seeall)


--加载物品列表

local m_rootLayer = nil;
local m_verLayout = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_slv = nil;
local m_pos = ccp(557, 21);

local SLV_TAG_BASE = 323;
local m_count = 0; --显示的数量
local m_totalCount = 0; --ScrollView 中子项数量
local COUNT_ONE_LINE = 5;
local SPACE = 15.33333; -- icon间隔
local PANEL_W = 0;
local COLOR_W = 0;
local SELECT_ICON_SIZE = 0;

local PATH_PANEL_BG_ICON = "";

local m_delegate = nil;

local m_index;
local m_curTag = TAG_11_ALL;

function getRootLayout()
    return m_verLayout;
end

function getCurIndex()
    if(m_index > 0) then
        return m_index;
    end
end

function getCurCount()
    return m_count;
end

function getCurTag()
    return m_curTag;
end

function getItemByIndex(index)
   return tolua.cast(m_slv:getChildByTag(index + SLV_TAG_BASE), "Layout");
end


function setPosition(pos)
    m_rootLayer:setPosition(pos);
end

-------------------------吞噬---------------------



-------------------------吞噬---------------------

function setName( name )
    -- local nameLabel = tolua.cast(m_verLayout:getWidgetByName("name_label"), "Label");
    -- nameLabel:setText(name);
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

local function getInnerCount( count )
    local n = math.floor(count/COUNT_ONE_LINE);
    if(count%COUNT_ONE_LINE > 0) then
        n = n + 1;
    end
    return n*COUNT_ONE_LINE;
end

local function showIconFromIndex(tag, beginIndex)
    local count = #UserInfoManager.getGoodsInfo(tag);
    if(count > 0) then
        local data = UserInfoManager.getGoodsInfo(tag);
        for i = beginIndex,beginIndex + count - 1 do
            local panel = tolua.cast(m_verLayout:getWidgetByTag(i + SLV_TAG_BASE), "Layout");
            local icon = tolua.cast(panel:getChildByName("goodIcon"), "ImageView");
            local bgIcon = tolua.cast(panel:getChildByName("bgIcon"), "ImageView");
            local dataItem = nil;
            if(beginIndex == 1) then
                dataItem = data[i];
            else
                dataItem = data[i - beginIndex + 1];
            end

            if(dataItem ~= nil) then
                local id = dataItem.id;
                -- print("** id  = " .. id);
                local path = GoodsManager.getIconPathById(id);
                if(path ~= nil and "" ~= path) then
                    icon:loadTexture(path);
                end

                local bgPath = GoodsManager.getColorBgImg(GoodsManager.getColorById(id));
                bgIcon:loadTexture(bgPath);
                
                local countLabel = tolua.cast(panel:getChildByName("goodCount"), "Label");
                local n = dataItem.count;
                if(n and n > 0) then
                    countLabel:setText(n);
                else
                    countLabel:setText("");
                end
            end
        end
    end
end

local function showAll()
    local bpData = UserInfoManager.getAllBackpackInfo();
    local g1 = bpData.equip;
    -- local g2 = bpData.weapon;
    local g2 = bpData.equipPiece;
    local g3 = bpData.coatchip;
    local g4 = bpData.other;
    showIconFromIndex(TAG_EQUIP, 1);
    showIconFromIndex(TAG_EQUIP_PIECE, #g1 + 1);
    showIconFromIndex(TAG_COAT_PIECE, #g1 + #g2 + 1);
    showIconFromIndex(TAG_OTHER, #g1 + #g2 + #g3 + 1);
    -- showIconFromIndex(TAG_OTHER, #g1 + #g2 + #g3 + #g4 + 1);
end

local function showPieces()
    local bpData = UserInfoManager.getAllBackpackInfo();
    local g1 = bpData.equipPiece;
    local g2 = bpData.coatchip;
    showIconFromIndex(TAG_EQUIP_PIECE, 1);
    showIconFromIndex(TAG_COAT_PIECE, #g1 + 1);
end

local function refreshIcon()
    if(m_curTag == TAG_ALL) then
        --显示所有包括：装备、武器、碎片、其它
        showAll();
    elseif(m_curTag == TAG_PIECE) then
        --显示装备碎片、外套碎片
        showPieces();
    else
        showIconFromIndex(m_curTag, 1);
    end
end

local function setPanelVisible()
    for i = 1,m_totalCount do
        local panel = m_verLayout:getWidgetByTag(i + SLV_TAG_BASE);
        if(i <= m_count) then
            panel:setEnabled(true);
        else
            panel:setEnabled(false);
        end
    end
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

function setSlvInnerSize(count)
    local row = math.ceil(count/COUNT_ONE_LINE);
    local innerHeight = PANEL_W*row + (row + 1)*SPACE;
    m_slv:setInnerContainerSize(CCSize((m_slv:getSize()).width, innerHeight));
    resetSlvItemsPosition(count);
end


local isMoved = false;

--记录点击的位置
local function onTouchBegan(sender)
    local panel = tolua.cast(sender, "Layout");
    -- panel:setBackGroundColor(ccc3(92, 172, 238));
end

--显示装备属性
local function onTouchEnded(sender)
    local panel = tolua.cast(sender, "Layout");
    -- panel:setBackGroundColor(ccc3(74, 112, 139));

    local index = panel:getTag() - SLV_TAG_BASE;
    if(m_index ~= index) then
        m_index = index;
    end
    if(m_delegate) then
        _G[m_delegate].goodsOnClick(index, m_curTag);
    end
end

--判断是否可以放入,不能放入则放回原处
local function onTouchCancel( sender )
    local panel = tolua.cast(sender, "Layout");
    -- panel:setBackGroundColor(ccc3(74, 112, 139));
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

local function createSlvItem( row, col )
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    local panel = Layout:create();
    -- panel:setBackGroundColorType(LAYOUT_COLOR_SOLID);
    -- panel:setBackGroundColor(ccc3(74, 112, 139));
    panel:setSize(CCSize(PANEL_W, PANEL_W));
    local pos =  ccp(SPACE + (PANEL_W + SPACE)*(col - 1), 
            slvInnerH - ((SPACE + PANEL_W) + (SPACE + PANEL_W)*(row - 1))
            );
    panel:setPosition(pos);

    local icon = ImageView:create();
    icon:ignoreContentAdaptWithSize(false);
    icon:setName("goodIcon");
    icon:setSize(CCSize(PANEL_W, PANEL_W));
    icon:loadTexture(PATH_PANEL_BG_ICON);
    icon:setPosition(ccp(PANEL_W/2, PANEL_W/2));
    panel:addChild(icon, 0);

    local bgIcon = ImageView:create();
    bgIcon:ignoreContentAdaptWithSize(false);
    bgIcon:setName("bgIcon");
    bgIcon:setSize(CCSize(COLOR_W, COLOR_W));
    bgIcon:loadTexture(PATH_UNSELECT_ICON);
    bgIcon:setPosition(ccp(PANEL_W/2, PANEL_W/2));
    panel:addChild(bgIcon, 1);

    local selectIcon = ImageView:create();
    selectIcon:ignoreContentAdaptWithSize(false);
    selectIcon:setName("selectIcon");
    selectIcon:setSize(CCSize(SELECT_ICON_SIZE, SELECT_ICON_SIZE));
    selectIcon:loadTexture(PATH_UNSELECT_ICON);
    selectIcon:setPosition(ccp(SELECT_ICON_SIZE/2, PANEL_W - SELECT_ICON_SIZE/2));
    panel:addChild(selectIcon, 2);

    local name = Label:create();
    name:setName("goodName");
    name:setFontSize(20);
    name:setPosition(ccp(PANEL_W/2, 24));
    panel:addChild(name, 2);

    local count = Label:create();
    count:setAnchorPoint(ccp(0.5, 0.5));
    count:setName("goodCount");
    count:setFontSize(26);
    count:setPosition(ccp((PANEL_W/2)*1, 15));
    count:setColor(COLOR_VALUE[COLOR_WHITE]);
    panel:addChild(count, 2);

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

local function calCurCount()
    if(m_curTag == TAG_ALL) then
        local bpData = UserInfoManager.getAllBackpackInfo();
        m_count = #bpData.equip + #bpData.equipPiece + #bpData.coatchip + #bpData.other;
    elseif(m_curTag == TAG_PIECE) then
        local bpData = UserInfoManager.getAllBackpackInfo();
        m_count = #bpData.equipPiece + #bpData.coatchip;
    else
        m_count = #UserInfoManager.getGoodsInfo(m_curTag);
    end
    -- print("当前数量：" .. m_count);
end

local function refreshSlv()
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
end


--数量提示
local function refreshCountLabel()
    local curCountLabel = tolua.cast(m_verLayout:getWidgetByName("curCount_label"), "Label");
    local totalCountLabel = tolua.cast(m_verLayout:getWidgetByName("totalCount_label"), "Label");
    curCountLabel:setText(UserInfoManager.getTotalCount());
    totalCountLabel:setText(GOODS_COUNT_TOTAL_1);
end

local function initDisplay()
    --初始化数据
    refreshSlv();
    refreshCountLabel();
end

function refreshDisplay()
    refreshSlv();
    refreshCountLabel();
end

--背包中标签切换,tag为标签标识
function onBackpackTabPageChanged(tag)
    if(m_curTag ~= tag) then
        m_curTag = tag;
        refreshDisplay();
    end
end

function onBankTabPageChanged(tag)
    if(m_curTag ~= tag) then
        m_curTag = tag;
        refreshSlv();
    end
end

function setDelegate( delegate )
    m_delegate = delegate;
end

--得到数量最大值
local function getBackpackMaxCount()
    local bpData = UserInfoManager.getAllBackpackInfo();
    local max = #bpData.equip + #bpData.weapon + #bpData.equipPiece + #bpData.coatchip + #bpData.other;
    return max;
end

local function createinit()
    --得到各个物品的最大数量去创建，切换时更改innerSize即可
    m_totalCount = getBackpackMaxCount();
    m_slv = tolua.cast(m_verLayout:getWidgetByName("goods_slv"), "ScrollView");
    local slvWidth = (m_slv:getSize()).width;
    PANEL_W = (slvWidth - (COUNT_ONE_LINE + 1)*SPACE)/COUNT_ONE_LINE;
    COLOR_W = PANEL_W + 20;
    SELECT_ICON_SIZE = PANEL_W/4;

    print("***************  PANEL_W = " .. PANEL_W);
    print("***************  COLOR_W = " .. COLOR_W);
end

function create()
    if(not m_isCreate)then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        m_rootLayer:setPosition(POS_RIGHT);

        m_verLayout = TouchGroup:create();
        m_rootLayer:addChild(m_verLayout);

        local verPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "GoodsList.json");
        m_verLayout:addWidget(verPanel);

        createinit();
        createSlv(m_totalCount); --先按最大数量去创建
    end
end

function open(tag)
	if(not m_isOpen) then
        create();
		m_isOpen = true;
        m_curTag = tag;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);
        initDisplay();
        m_index = -1;
	end
end
 
function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

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
        m_verLayout = nil;
    end
end