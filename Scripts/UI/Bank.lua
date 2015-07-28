module ("Bank", package.seeall)

require "UI/CloseButton"
require "UI/GoodsDetailsPanel"

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_defPos = ccp(165, 21);

local m_slv = nil;
local SLV_TAG_BASE = 323;
local m_count = 0; --显示的数量
local m_totalCount = 0; --ScrollView 中子项最大数量
local COUNT_ONE_LINE = 5;
local SPACE = 5; -- icon间隔
local PANEL_W = 0;
local PATH_PANEL_BG_ICON = "";
local m_index;
local m_curTag;
local m_tabPos = ccp(970, 270);

local m_infoPanel_pos_1 = ccp(150, 70);
local m_infoPanel_pos_2 = ccp(586, 70);


function setPosition( pos )
	m_rootLayer:setPosition(pos);
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

function resetSlvItemsPosition(count)
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

local function changePanelBgColor( sender, eventType )
    local panel = tolua.cast(sender, "Layout");
	if(eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL)then
	    panel:setBackGroundColor(ccc3(74, 112, 139));
	elseif(eventType == TOUCH_EVENT_TYPE_BEGIN) then
	    panel:setBackGroundColor(ccc3(92, 172, 238));
	end
end

local function getBackpackTag()
    if(m_curTag == TAG_BANK_ALL) then
        return TAG_ALL;
    elseif(m_curTag == TAG_BANK_EQUIP) then
        return TAG_EQUIP;
    elseif(m_curTag == TAG_BANK_WEAPON) then
        return TAG_WEAP;
    elseif(m_curTag == TAG_BANK_PIECE) then
        return TAG_PIECE;
    elseif(m_curTag == TAG_BANK_OTHER) then
        return TAG_OTHER;
    end
end

-------------------------------功能处理----------------------------------

local function closeGoodsInfo()
    CloseButton.close();
    GoodsDetailsPanel.close();
    ProgressRadial.close();
end


-- 背包-->仓库 返回 1725
local function onReceive_Bp2Bank_Response(messageType, messageData)
    local result = messageData.result;
    if(result == 1) then
        ProgressRadial.close();
        GoodsList.refreshDisplay();
        Bank.initDisplay();
        closeGoodsInfo();
    end
end

-- 仓库-->背包 返回 1727
local function onReceive_Bank2Bp_Response(messageType, messageData)
    local result = messageData.result;
    if(result == 1) then
        ProgressRadial.close();
        GoodsList.refreshDisplay();
        Bank.initDisplay();
        closeGoodsInfo();
    end
end

local function registerOperateMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MOVEBPTOBANKRESPONSE, onReceive_Bp2Bank_Response);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MOVEBANKTOBPRESPONSE, onReceive_Bank2Bp_Response);
end

local function unRegisterOperateMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_MOVEBPTOBANKRESPONSE, onReceive_Bp2Bank_Response);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_MOVEBANKTOBPRESPONSE, onReceive_Bank2Bp_Response);
end

--  背包-->仓库
local function moveBp2Bank(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("****  背包-->仓库");
        -- 708
        -- byte    物品类型(1装备 2材料 3其它 )  
        -- short   物品索引
        local index = GoodsList.getCurIndex();
        local datas, indexC = UserInfoManager.getGoodsInfo(getBackpackTag(), index);
        if(indexC == nil) then
            indexC = index;
        end
        local dataItem = datas[indexC];
        local typeid = GoodsManager.getGoodsHighTypeId(dataItem.id);
        --确定要移动的物品的数量（材料和其它物品默认为全部移动）
        local count = 1;
        if(GoodsManager.isEquipOrWeapon(dataItem.id) == false) then
            count = dataItem.count;
        end
        local msg = {typeid, indexC, count};
        ProgressRadial.open();
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MOVEBPTOBANK, msg);
    end
end

--  仓库-->背包
local function moveBank2Bp(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("****  仓库-->背包");
        -- 710
        local datas, indexC = UserInfoManager.getGoodsInfo(m_curTag, m_index);
        if(indexC == nil) then
            indexC = m_index;
        end
        local dataItem = datas[indexC];
        local typeid = GoodsManager.getGoodsHighTypeId(dataItem.id);
        --确定要移动的物品的数量（材料和其它物品默认为全部移动）
        local count = 1;
        if(GoodsManager.isEquipOrWeapon(dataItem.id) == false) then
            count = dataItem.count;
        end
        local msg = {typeid, indexC, count};
        ProgressRadial.open();
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MOVEBANKTOBP, msg);
    end
end



--背包物品面板功能按钮参数
local function getCurBpFuncParam()
    local param = {};
    -- name, cbs, labels
    param.name = FunBtnCount3.getDelName().BP; --背包
    local cbs = {};
    local labels = {};
    labels[1] = nil;
    labels[2] = IMAGE_PATH.fangru;
    labels[3] = nil;
    cbs[1] = nil;
    cbs[2] = moveBp2Bank;
    cbs[3] = nil;
    param.cbs = cbs;
    param.labels = labels;
    return param;
end

--仓库物品面板功能按钮参数
local function getCurBankFuncParam()
    local param = {};
    -- name, cbs, labels
    param.name = FunBtnCount3.getDelName().Bank; --仓库
    local cbs = {};
    local labels = {};
    labels[1] = nil;
    labels[2] = IMAGE_PATH.quchu;
    labels[3] = nil;
    cbs[1] = nil;
    cbs[2] = moveBank2Bp;
    cbs[3] = nil;
    param.cbs = cbs;
    param.labels = labels;
    return param;
end


--协议函数 背包列表点击回调
function goodsOnClick(index)
    print(" 背包 m_curTag " .. m_curTag .. "  ,index = " .. index);
    local datas, indexC = UserInfoManager.getGoodsInfo(getBackpackTag(), index);
    CloseButton.open(closeGoodsInfo);
    GoodsDetailsPanel.open();
    local bpFunParam = getCurBpFuncParam();
    if(indexC == nil) then
        indexC = index;
    end
    GoodsDetailsPanel.showPanel(datas[indexC], m_infoPanel_pos_1, bpFunParam);
end

local function slvTouchEvent( sender,eventType )
    if(eventType == TOUCH_EVENT_TYPE_BEGIN) then
    	-- changePanelBgColor( sender, TOUCH_EVENT_TYPE_BEGIN );
    elseif(eventType == TOUCH_EVENT_TYPE_END) then
    	-- changePanelBgColor( sender, TOUCH_EVENT_TYPE_END );
    	local panel = tolua.cast(sender, "Layout");
	    local index = panel:getTag() - SLV_TAG_BASE;
	    if(m_index ~= index) then
            m_index = index;
        end
        --打开物品详细信息面板
        CloseButton.open(closeGoodsInfo);
        local datas, indexC = UserInfoManager.getGoodsInfo(m_curTag, m_index);
        GoodsDetailsPanel.open();
        local bankFunParam = getCurBankFuncParam();
        if(indexC == nil) then
            indexC = m_index;
        end
        GoodsDetailsPanel.showPanel(datas[indexC], m_infoPanel_pos_2, bankFunParam);
    elseif(eventType == TOUCH_EVENT_TYPE_CANCEL) then
    	-- changePanelBgColor( sender, TOUCH_EVENT_TYPE_CANCEL );
    end
end

local function createSlvItem( row, col )
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    local panel = Layout:create();
    -- panel:setBackGroundColorType(LAYOUT_COLOR_SOLID);
    -- panel:setBackGroundColor(ccc3(74, 112, 139));
    panel:setSize(CCSize(PANEL_W, PANEL_W));
    panel:setPosition(
        ccp(SPACE + (PANEL_W + SPACE)*(col - 1), 
            slvInnerH - ((SPACE + PANEL_W) + (SPACE + PANEL_W)*(row - 1))
            )
        );
    local icon = ImageView:create();
    icon:ignoreContentAdaptWithSize(false);
    icon:setName("goodIcon");
    icon:setSize(CCSize(PANEL_W - 7, PANEL_W - 7));
    icon:loadTexture(PATH_PANEL_BG_ICON);
    icon:setPosition(ccp(PANEL_W/2, PANEL_W/2));
    panel:addChild(icon);

    local name = Label:create();
    name:setName("goodName");
    name:setFontSize(20);
    name:setPosition(ccp(PANEL_W/2, 24));
    panel:addChild(name);

    local count = Label:create();
    count:setName("goodCount");
    count:setFontSize(20);
    count:setPosition(ccp(PANEL_W - 24, 24));
    count:setColor(ccc3(220, 20, 60));
    panel:addChild(count);

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

--改变列表InnerSize和ContentSize
local function checkSlv()
    --根据标签id先得到应该显示的数量，判断是否需要为ScrollView新增子项，改变innerSize
    if(m_count > m_totalCount) then
        for i = m_totalCount + 1,m_count do
            print("Bank  i = " .. i );
            local row = math.ceil(i/COUNT_ONE_LINE);
            local col = i%COUNT_ONE_LINE;
            if(col == 0) then col = COUNT_ONE_LINE; end
            createSlvItem(row, col);
        end
        m_totalCount = m_count;
    end
    setSlvInnerSize(m_count);
    setPanelVisible();
end

local function showIconFromIndex(tag, beginIndex)
    local count = #UserInfoManager.getGoodsInfo(tag);
    if(count > 0) then
        local data = UserInfoManager.getGoodsInfo(tag);
        for i = beginIndex,beginIndex + count - 1 do
            local panel = tolua.cast(m_rootLayout:getWidgetByTag(i + SLV_TAG_BASE), "Layout");
            local icon = tolua.cast(panel:getChildByName("goodIcon"), "ImageView");
            local dataItem = nil;
            if(beginIndex == 1) then
                dataItem = data[i];
            else
                dataItem = data[i - beginIndex + 1];
            end

            if(dataItem ~= nil) then
                local id = dataItem.id;
                local path = GoodsManager.getIconPathById(id);
                if(path ~= nil and "" ~= path) then
                    icon:loadTexture(path);
                end

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
    local bpData = UserInfoManager.getAllBackInfo();
    local g1 = bpData.equip;
    local g2 = bpData.weapon;
    local g3 = bpData.equipPiece;
    local g4 = bpData.coatchip;
    local g5 = bpData.other;
    showIconFromIndex(TAG_BANK_EQUIP, 1);
    showIconFromIndex(TAG_BANK_WEAPON, #g1 + 1);
    showIconFromIndex(TAG_BANK_PIECE_EQUIP, #g1 + #g2 + 1);
    showIconFromIndex(TAG_BANK_PIECE_COAT, #g1 + #g2 + #g3 + 1);
    showIconFromIndex(TAG_BANK_OTHER, #g1 + #g2 + #g3 + #g4 + 1);
end

local function showPieces()
    local bpData = UserInfoManager.getAllBackInfo();
    local g1 = bpData.equipPiece;
    local g2 = bpData.coatchip;
    showIconFromIndex(TAG_BANK_PIECE_EQUIP, 1);
    showIconFromIndex(TAG_BANK_PIECE_COAT, #g1 + 1);
end

--根据m_curTag更新显示
local function refreshSlv()
    if(m_curTag == TAG_BANK_ALL) then
        --显示所有包括：装备、武器、碎片、其它
        showAll();
    elseif(m_curTag == TAG_BANK_PIECE) then
        --显示装备碎片、外套碎片
        showPieces();
    else
        showIconFromIndex(m_curTag, 1);
    end
end

local function getBankAllCount()
    local bankData = UserInfoManager.getAllBackInfo();
    local max = #bankData.equip + #bankData.equipPiece + #bankData.other + #bankData.coatchip + #bankData.weapon;
    return max;
end

local function getBankAllPieceCount()
    local bpData = UserInfoManager.getAllBackInfo();
    local count = #bpData.equipPiece + #bpData.coatchip;
    return count;
end

local function calcCurCount()
    if(m_curTag == TAG_BANK_ALL) then
        m_count = getBankAllCount();
    elseif(m_curTag == TAG_BANK_PIECE) then
        m_count = getBankAllPieceCount();
    else
        m_count = #UserInfoManager.getGoodsInfo(m_curTag);
    end
end

function refreshDisplay()
    HorTabFive.changeTexture(m_curTag, true);
    --更新要显示的物品数量，显示新列表
    calcCurCount();
    checkSlv(); --检查slv innersize 和 contentsize
    refreshSlv(); -- 更新显示
    --更新背包列表显示
    GoodsList.onBankTabPageChanged(getBackpackTag());
end


local function tabOnClick( sender )
	local tag = sender:getTag();
	if(m_curTag ~= tag) then
		HorTabFive.changeTexture(m_curTag, false);
		m_curTag = tag;
		refreshDisplay();
	end
end

--初始打开初始化
function initDisplay()
    calcCurCount();
    checkSlv();
    refreshSlv();
end


local function init()
    --得到各个物品的最大数量去创建，切换时更改innerSize即可
    m_totalCount = getBankAllCount();
    print("**************  banktotal = " .. m_totalCount);

    m_slv = tolua.cast(m_rootLayout:getWidgetByName("goods_slv"), "ScrollView");
    local slvWidth = (m_slv:getSize()).width;
    PANEL_W = (slvWidth - (COUNT_ONE_LINE + 1)*SPACE)/COUNT_ONE_LINE;
    SELECT_ICON_SIZE = PANEL_W/4;

    local selectAllCB = tolua.cast(m_rootLayout:getWidgetByName("selectAll_cb"), "CheckBox");
    selectAllCB:setEnabled(false);
    local selectAllCBBg = tolua.cast(m_rootLayout:getWidgetByName("selectAll_cbBg_img"), "ImageView");
    selectAllCBBg:setEnabled(false);

    -- local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name_label"), "Label");
    -- nameLabel:setText("仓库");

    local m_exitRemoveBtn = tolua.cast(m_rootLayout:getWidgetByName("exitRemove_img"), "ImageView");
    m_exitRemoveBtn:setEnabled(false);
    local m_exitRemoveBtnBg = tolua.cast(m_rootLayout:getWidgetByName("exitRemoveBg_img"), "ImageView");
    m_exitRemoveBtnBg:setEnabled(false);

    local m_removeBtn = tolua.cast(m_rootLayout:getWidgetByName("remove_btn"), "Button");
    m_removeBtn:setEnabled(false);


end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        setPosition(m_defPos);

        m_rootLayout = TouchGroup:create();
        m_rootLayer:addChild(m_rootLayout);

        local rootPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "GoodsList.json");
        m_rootLayout:addWidget(rootPanel);
        init();
        createSlv(m_totalCount);

        GoodsList.create();
        HorTabFive.create();
    end
end

function open()
	if(not m_isOpen) then
        create();
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);

        m_index = 0;
        m_curTag = TAG_BANK_ALL;
        Background.create("Bank");
        Background.open();
        
        GoodsList.open(getBackpackTag());
        GoodsList.setName("背包")
        GoodsList.setDelegate("Bank");

        HorTabFive.open("全部", "装备", "武器", "碎片", "其它");
        HorTabFive.setTabEnabled(true, true, true, true, true);
        HorTabFive.setTabTag(TAG_BANK_ALL, TAG_BANK_EQUIP, TAG_BANK_WEAPON, TAG_BANK_PIECE, TAG_BANK_OTHER);
        HorTabFive.setCallBack(tabOnClick, tabOnClick, tabOnClick, tabOnClick, tabOnClick);
        HorTabFive.setPosition(m_tabPos);
        HorTabFive.changeAllTexture(false);
        HorTabFive.changeTexture(m_curTag, true);

        CloseButton.create();

        initDisplay();

        registerOperateMessage();
	end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

        Background.close();
        Background.remove();
        GoodsList.close();
        HorTabFive.close();

        unRegisterOperateMessage();
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

        GoodsList.remove();
        HorTabFive.remove();
    end
end