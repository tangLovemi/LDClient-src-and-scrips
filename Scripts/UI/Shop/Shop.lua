module("Shop", package.seeall)

require "UI/Shop/ShopData/NormalShopGoods"
require "UI/Shop/ShopData/MysteryShopGoods"
require "UI/Shop/ShopData/ExchangeShopGoods"

-- require "UI/Confirm"
require "UI/Shop/ShopBuy"
require "UI/Shop/ShopRefreshUI"

local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_slv = nil;
local m_titleImg = nil;

local SHOP_SLV_TAG_BASE = 123;
local COUNT_LINE = 2; --上述
local SPACE_X = 7.5; -- icon间隔
local SPACE_Y = 5;   -- icon间隔
local PANEL_W = 173;
local PANEL_H = 200;

local m_curIndex = nil;
local m_shopTypeId = nil;
local m_data = nil;
local m_curCount = 0;
local m_maxCount = 0;

--标志装备品质颜色的背景框
local colorBgImg = {
    PATH_CCS_RES .. "dhsd_ziy2.png", -- 白
    PATH_CCS_RES .. "dhsd_ziy9.png", -- 绿
    PATH_CCS_RES .. "dhsd_ziy8.png", -- 蓝
    PATH_CCS_RES .. "dhsd_ziy12.png",-- 紫
    PATH_CCS_RES .. "dhsd_ziy3.png", -- 橙
};

function getRootLayout()
    if(m_uiLayer) then
        return m_uiLayer;
    end
end


--Shop页关闭
local function closeShopOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.close("Shop");
    end
end

local function closeDetailsPanel()
    GoodsDetailsPanel.close();
end

local function getChoiceGoodsIndexByTag(tag)
    return tag - SHOP_SLV_TAG_BASE;
end

local function refreshMoney()
    --玩家拥有的货币
    if(m_shopTypeId == SHOP_MYSTERY) then
        local soulYUCount = UserInfoManager.getGoodsCount(GoodsManager.getSoulYuId());
        tolua.cast(m_uiLayer:getWidgetByName("houyu_labelNum"), "LabelAtlas"):setStringValue(soulYUCount);
    end
end

local function gotoRecharge()
    CCLuaLog("**********进入充值页面***********");
    -- Confirm.close();
end

local function closeConfirm()
    -- Confirm.close();
end



local function maxCount()
    return math.max(NormalShopGoods.getGoodsCount(), MysteryShopGoods.getGoodsCount(), ExchangeShopGoods.getGoodsCount());
end

----------显示详细信息---------

local function initDataById( id )
    --物品的基本信息（icon:图标路径  color:颜色  type：物品类型  name：名称  desc：描述）
    local data = {};
    data.id = id;
    local highType = GoodsManager.getGoodsHighName(id);
    local type = 0;
    if(highType == "coat") then
        --外套
        type = 1;
        local lv = 1; --初始级别
        data = CoatCalc.getCoatData(id, lv);
    elseif(highType == "weapon") then
        --武器
        type = 2;
        -- data = WeaponCalc.
    elseif(highType == "equip") then
        --装备
        type = 3;
        local lv = EquipmentCalc.getMinLV();
        if(GoodsManager.isGrowEquip(id)) then
            local step = EquipmentCalc.getMinStepLV();
            data = EquipmentCalc.calcGrowEquip(id, step, lv);
        else
            data = EquipmentCalc.calcNormalEquip(id, lv);
        end
        -- data.baseProid = Util.tableToStrBySeparator(data.ids, ";");
        -- data.baseProval = Util.tableToStrBySeparator( data.vals, ";");

    elseif(highType == "piece") then
        --碎片
        type = 4;
    elseif(highType == "other") then
        --其它物品
        type = 5;
    end
    local baseInfo = GoodsManager.getBaseInfo(id);
    data.icon = baseInfo.icon;
    data.color = baseInfo.color;
    data.type = baseInfo.type;
    data.name = baseInfo.name;
    data.desc = baseInfo.desc;
    data.typeid = type;
    return data;
end

local function showDetails()
    if(m_curIndex == nil) then
        m_curIndex = 0;
    end

    if(m_curIndex ~= 0) then
        local itemPanel = tolua.cast(m_slv:getChildByTag(SHOP_SLV_TAG_BASE + m_curIndex), "Layout");
        local selectImg = tolua.cast(itemPanel:getChildByName("selectBg_img"), "ImageView");
        selectImg:setEnabled(true);
        
        local id = m_data[m_curIndex]["goodsId"];
        print("id = " .. id);
        --加关闭按钮
        local data = initDataById(id); --物品信息
        local equipPanel = m_uiLayer:getWidgetByName("equipInfo_panel");
        local otherPanel = m_uiLayer:getWidgetByName("otherInfo_panel");
        local type = data.typeid;
        --1外套 2武器 3装备 4碎片 5杂物
        if(type == 4 or type == 5 or type == 2) then
            --不是装备
            equipPanel:setEnabled(false);
            otherPanel:setEnabled(true);
            tolua.cast(m_uiLayer:getWidgetByName("otherIcon_img"), "ImageView"):loadTexture(data.icon);
            tolua.cast(m_uiLayer:getWidgetByName("otherColor_img"), "ImageView"):loadTexture(GoodsManager.getColorBgImg(data.color));
            tolua.cast(m_uiLayer:getWidgetByName("otherName_label"), "Label"):setText(data.name);
            tolua.cast(m_uiLayer:getWidgetByName("otherDesc_label"), "Label"):setText(data.desc);
        elseif(type == 3) then
            --是装备
            equipPanel:setEnabled(true);
            otherPanel:setEnabled(false);
            tolua.cast(m_uiLayer:getWidgetByName("equipIcon_img"), "ImageView"):loadTexture(data.icon);
            tolua.cast(m_uiLayer:getWidgetByName("equipColor_img"), "ImageView"):loadTexture(GoodsManager.getColorBgImg(data.color));
            tolua.cast(m_uiLayer:getWidgetByName("equipName_label"), "Label"):setText(data.name);
            tolua.cast(m_uiLayer:getWidgetByName("equipDesc_label"), "Label"):setText(data.desc);
            tolua.cast(m_uiLayer:getWidgetByName("equipLevel_label"), "LabelAtlas"):setStringValue(data.level);

            local proids = data.ids;
            local proVals = data.vals;
            for i,v in ipairs(proids) do
                tolua.cast(m_uiLayer:getWidgetByName("pro_label_" .. i), "Label"):setText(GoodsManager.getProNameByProid(v));
                tolua.cast(m_uiLayer:getWidgetByName("proValue_label_" .. i), "LabelAtlas"):setStringValue(proVals[i]);
            end
        end

        --购买面板
        ShopBuy.open(m_data[m_curIndex], m_shopTypeId);

        --描述面板
        tolua.cast(m_uiLayer:getWidgetByName("desc1_label"), "Label"):setText(m_data[m_curIndex]["limitDesc1"]);
        tolua.cast(m_uiLayer:getWidgetByName("desc2_label"), "Label"):setText(m_data[m_curIndex]["limitDesc2"]);
    end
end

-- 点击物品列表项
local function slvTouchEvent( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_BEGIN) then
    elseif(eventType == TOUCH_EVENT_TYPE_END) then
        local index = getChoiceGoodsIndexByTag(sender:getTag());
        if(m_curIndex ~= index) then
            if(m_curIndex ~= 0) then
                local itemPanel = tolua.cast(m_slv:getChildByTag(SHOP_SLV_TAG_BASE + m_curIndex), "Layout");
                local before = tolua.cast(itemPanel:getChildByName("selectBg_img"), "ImageView");
                before:setEnabled(false);
            end
            m_curIndex = index;
            showDetails();
        end
    elseif(eventType == TOUCH_EVENT_TYPE_CANCEL) then
    end
end

local function clearGoodsInfo()
    --商品
    m_slv:setEnabled(false);
    --倒计时面板
    m_uiLayer:getWidgetByName("refresh_panel"):setEnabled(false);
end

--显示商店物品
local function showAllGoodsInfo()
    for i = 1,m_curCount do
        local id = m_data[i]["goodsId"];
        local iconPath = GoodsManager.getIconPathById(id);
        local moneyIconPath = GoodsManager.getUseGoodsIconPath(m_data[i]["payType"]);
        local name = GoodsManager.getNameById(m_data[i]["goodsId"]);
        local count = m_data[i]["count"];
        local price = m_data[i]["price"];

        local itemPanel = tolua.cast(m_slv:getChildByTag(SHOP_SLV_TAG_BASE + i), "Layout");
        itemPanel:setEnabled(true);
        local iconImg = tolua.cast(itemPanel:getChildByName("goodsIcon_img"), "ImageView");
        local countLabel = tolua.cast(itemPanel:getChildByName("count_label"), "LabelAtlas");
        local moneyIcon = tolua.cast(itemPanel:getChildByName("money_img"), "ImageView");
        local priceLabel = tolua.cast(itemPanel:getChildByName("price_label"), "LabelAtlas");
        local nameLabel = tolua.cast(itemPanel:getChildByName("name_label"), "Label");
        local selectImg = tolua.cast(itemPanel:getChildByName("selectBg_img"), "ImageView");
        local color_img = tolua.cast(itemPanel:getChildByName("color_img"), "ImageView");
        if(iconPath) then
            iconImg:loadTexture(iconPath);
        end
        moneyIcon:loadTexture(moneyIconPath);
        nameLabel:setText(name);
        countLabel:setStringValue(count);
        priceLabel:setStringValue(price);
        selectImg:setEnabled(false);

        local color = GoodsManager.getColorBgImg(GoodsManager.getColorById(id));
        color_img:loadTexture(color);

        --售罄图片
        local haveSale_img = tolua.cast(itemPanel:getChildByName("haveSale_img"), "ImageView");
        haveSale_img:setEnabled(false);
        if(m_data[i]["canBuy"] ~= 1) then
            haveSale_img:setEnabled(true);
        end
        -- haveSale_img:setEnabled(m_data[i]["canBuy"] ~= 1);
        --限购图片
        local limit_img = tolua.cast(itemPanel:getChildByName("limit_img"), "ImageView");
        -- local limitLabel_img = tolua.cast(itemPanel:getChildByName("limitLabel_img"), "ImageView");
        limit_img:setEnabled(false);
        -- limitLabel_img:setEnabled(false);
        if(m_data[i]["isLimit"] == 1) then
            limit_img:setEnabled(true);
            -- limitLabel_img:setEnabled(true);
        end

        -- print("canbuy:" .. m_data[i]["canBuy"]);
        -- print("isLimit:" .. m_data[i]["isLimit"]);
        -- print("***");
        -- haveSale_img:setEnabled(m_data[i]["isLimit"] == 1);
    end
end

-------------------------------------------------------------------

--根据物品数量得到行数
local function getLinesCount(count)
    local rows = math.floor(count/COUNT_LINE);
    if(count%COUNT_LINE > 0) then
        rows = rows + 1;
    end
    return rows;
end
--得到某行的数量（line:行数 count:物品总个数）
local function getCountAtLine( line, count )
    local countAtRow;
    local last = count - (line - 1)*COUNT_LINE;
    if( last >= COUNT_LINE ) then
        countAtRow = COUNT_LINE;
    else
        countAtRow = last;
    end
    return countAtRow;
end

local function setPanelVisible()
    for i = 1,m_maxCount do
        local panel = tolua.cast(m_slv:getChildByTag(i + SHOP_SLV_TAG_BASE), "Layout");
        if(i <= m_curCount) then
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
            local panel = tolua.cast(m_slv:getChildByTag(SHOP_SLV_TAG_BASE + (j + (i-1)*COUNT_LINE)), "Layout");
             panel:setPosition(
                ccp(SPACE_X + (PANEL_W + SPACE_X)*(i - 1), 
                    slvInnerH - ((SPACE_Y + PANEL_H) + (SPACE_Y + PANEL_H)*(j - 1)
                        )
                    )
                );
        end
    end
end

local function setSlvInnerSize(count)
    local row = math.ceil(count/COUNT_LINE);
    local innerWight = PANEL_W*row + (row + 1)*SPACE_X; 
    m_slv:setInnerContainerSize(CCSize(innerWight,(m_slv:getSize()).height));
    resetSlvItemsPosition(count);
end

local function createSlvItem( row, col )
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    local panel = nil;
    if(m_shopTypeId == SHOP_MYSTERY or m_shopTypeId == SHOP_EXCHANGE) then
        panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ShopGoodsItem_shenmi.json");
    else
        panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ShopGoodsItem.json");
    end
    
    panel = tolua.cast(panel, "Layout");
    panel:setBackGroundColor(ccc3(94, 94, 94));
     panel:setPosition(
        ccp(SPACE_X + (PANEL_W + SPACE_X)*(row - 1), 
            slvInnerH - ((SPACE_Y + PANEL_H) + (SPACE_Y + PANEL_H)*(col - 1)
                )
            )
        );
    local tag = SHOP_SLV_TAG_BASE + col + (row-1)*COUNT_LINE;
    panel:addTouchEventListener(slvTouchEvent);
    panel:setTouchEnabled(true);
    panel:setPosition(ccp(0, 0));
    panel:setTag(tag);
    m_slv:addChild(panel, 1, tag);
end

local function refreshSlv(count)
    if(count > m_maxCount) then
        for i = m_maxCount + 1,count do
            local row = math.ceil(i/COUNT_LINE);
            local col = i%COUNT_LINE;
            if(col == 0) then col = COUNT_LINE; end
            createSlvItem(row, col);
        end
        m_maxCount = count;
    end
    m_curCount = count;
    setSlvInnerSize(m_curCount);
    setPanelVisible();
end

local function isNormalShop( shopId )
    if(shopId >= SHOP_NORMAL_BEGIN and shopId <= SHOP_NORMAL_BEGIN + SHOP_NOR_COUNT) then
        return true;
    end
    return false;
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


local function removeOtherUI()
    if(m_shopTypeId == SHOP_MYSTERY or m_shopTypeId == SHOP_EXCHANGE) then
        ShopRefreshUI.close();
    end
end

local function createInit()
    local closeBtn = m_uiLayer:getWidgetByName("close_btn");
    closeBtn:addTouchEventListener(closeShopOnClick);
    m_titleImg = tolua.cast(m_uiLayer:getWidgetByName("title_img"), "ImageView");
    m_slv = tolua.cast(m_uiLayer:getWidgetByName("goods_slv"), "ScrollView");
    local slvWidth = (m_slv:getSize()).width;
    m_maxCount = maxCount();
end



--消息返回加载数据
function responseEnd()
    if(m_isOpen) then
        local count = 0;
        m_data = {};
        ProgressRadial.close();--关闭进度条
        m_slv:setEnabled(true);
        --商品信息面板
        m_uiLayer:getWidgetByName("info_panel"):setEnabled(true);
        local buyCountpanel = m_uiLayer:getWidgetByName("addCount_panel");
        if(isNormalShop(m_shopTypeId)) then
            m_data = NormalShopGoods.getData();
            count = NormalShopGoods.getGoodsCount();
            buyCountpanel:setEnabled(true);
        elseif(m_shopTypeId == SHOP_MYSTERY) then
            m_data = MysteryShopGoods.getData();
            count = MysteryShopGoods.getGoodsCount();
            buyCountpanel:setEnabled(false);
        elseif(m_shopTypeId == SHOP_EXCHANGE) then
            m_data = ExchangeShopGoods.getData();
            count = ExchangeShopGoods.getGoodsCount();
            buyCountpanel:setEnabled(false);
        end
        refreshSlv(count);
        showAllGoodsInfo();
        showDetails();
        refreshMoney();
    end
end

function openInit()
    m_curIndex = 1;
    clearGoodsInfo();
    refreshMoney();
    ShopBuy.open();
    --商品信息面板
    m_uiLayer:getWidgetByName("info_panel"):setEnabled(false);
    if(isNormalShop(m_shopTypeId)) then
        m_titleImg:loadTexture(IMAGE_PATH.SHOP_NORMAL);
        NormalShopGoods.sendRequest(m_shopTypeId);
    elseif(m_shopTypeId == SHOP_MYSTERY) then
        m_titleImg:loadTexture(IMAGE_PATH.SHOP_MYSTERY);
        ShopRefreshUI.open(SHOP_MYSTERY);
        MysteryShopGoods.sendRequest();
    elseif(m_shopTypeId == SHOP_EXCHANGE) then
        m_titleImg:loadTexture(IMAGE_PATH.SHOP_EXCHANGE);
        -- ShopRefreshUI.open(SHOP_EXCHANGE);
        ExchangeShopGoods.sendRequest();
    end
end

function getCurShopId()
    return m_shopTypeId;
end

function getCurData()
    return m_data;
end

local function registerResponse()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SHOPRESPONSE, responseEnd);
end
local function unregisterResponse()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SHOPRESPONSE, responseEnd);
end


local function initData()
    if(m_shopTypeId == SHOP_MYSTERY) then
        COUNT_LINE = 3;
        SPACE_X = 6; -- icon间隔
        SPACE_Y = 2;   -- icon间隔
        PANEL_W = 120;
        PANEL_H = 132;
    elseif(m_shopTypeId == SHOP_EXCHANGE) then
        COUNT_LINE = 3;
        SPACE_X = 8; -- icon间隔
        SPACE_Y = 2;   -- icon间隔
        PANEL_W = 120;
        PANEL_H = 132;
    else
        COUNT_LINE = 2;
        SPACE_X = 7.5; -- icon间隔
        SPACE_Y = 5;   -- icon间隔
        PANEL_W = 173;
        PANEL_H = 200;
    end
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        m_uiLayer = TouchGroup:create();
        m_rootLayer:addChild(m_uiLayer);
    end
end

function open(shopType)
    if (not m_isOpen) then
        m_isOpen = true;
        if(shopType ~= nil) then
            m_shopTypeId = shopType.typeid;
            local layout = nil;
            if(m_shopTypeId == SHOP_MYSTERY) then
                uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Shop_shenmi.json");
            elseif(m_shopTypeId == SHOP_EXCHANGE) then
                uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Shop_exchange.json");
            else
                uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Shop.json");
            end
            m_uiLayer:addWidget(uiLayout);
            initData();
            ShopRefreshUI.create();
            --购买数量面板
            ShopBuy.create();
            createInit();
            --动态创建所有格子,并绑定监听
            createSlv(m_maxCount);
            registerResponse();
            local uiLayer = getGameLayer(SCENE_UI_LAYER);
            uiLayer:addChild(m_rootLayer);
            openInit();
        end
    end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        removeOtherUI();

        GoodsDetailsPanel.close();
        if(m_shopTypeId == SHOP_MYSTERY or m_shopTypeId == SHOP_EXCHANGE) then
            ShopTimeRefresh.stopUpdate();
        end
        ProgressRadial.close();--关闭进度条
    end
end

function remove() 
    if(m_isCreate) then
        m_isCreate = false;
        if(m_rootLayer) then
            m_rootLayer:removeAllChildrenWithCleanup(true);
            m_rootLayer:release();
            m_rootLayer = nil;
        end
        unregisterResponse();
        m_uiLayer = nil;
        m_curIndex = nil;
        ShopRefreshUI.remove();
        ShopBuy.remove();
    end
end

