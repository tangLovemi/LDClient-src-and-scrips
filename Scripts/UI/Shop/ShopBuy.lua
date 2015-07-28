module("ShopBuy", package.seeall)

-------------------------------------
-- 商城购买按钮
-------------------------------------
local m_rootLayout = nil;
local m_callback = nil;

local m_addtionPanel = nil;

local m_buyBtn = nil;
local m_countLabel = nil;
local m_moneyIconImg = nil;
local m_priceLabel = nil;
local m_excPayType = nil;
local m_excPrice = nil;

local m_isCreate = false;
local m_isOpen = false;
local m_shopTypeId = nil;
local m_goodsData = nil;
local m_data = nil;
local m_count = 0;
local SUCCESS = 255;
local response = {
	"金币不足",			--1
	"元宝不足",			--2
	"声望不够",			--3
	"pvp点不够",		--4
	"魂玉不足",			--5	魂玉
	"级别不够",			--6
	"全服售完",			--7
	"售完",				--8
	"兑换所需不足",		--9
	"",					--10
	"钱币不足",         --11 灵魂石不足
	"vip等级不足",		--12
	"全服数量不足",		--13	
};

	-- public static final byte SUCCESS 				= -1;// 购买成功
	-- public static final byte MONEY_NOT_ENOUGH 		= 1;// 金币不足
	-- public static final byte TOKEN_NOT_ENOUGH 		= 2;// 元宝不足
	-- public static final byte REPUTATION_NOT_ENOUGH 	= 3;// 声望不够
	-- public static final byte PVP_NOT_ENOUGH 			= 4;// pvp点不够
	-- public static final byte SOULYU_NOT_ENOUGH 		= 5;// 魂玉不足
	-- public static final byte LEVEL_NOT_ENOUGH 		= 6;// 级别不够
	-- public static final byte TOTAL_COUNT_LIMIT 		= 7;// 全服数量限制
	-- public static final byte PER_COUNT_LIMIT 		= 8;// 个人数量限制
	-- public static final byte EXC_NOT_ENOUGH		 	= 9;// 兑换所需不足
	-- public static final byte TIME_NOT_OK 			= 10;// 兑换所需不足
	-- public static final byte SOULSTONE_NOT_ENOUGH 	= 11;// 灵魂石不足
	-- public static final byte VIP_NOT_ENOUGH 			= 12;// vip等级不足
	-- public static final byte TOTAL_COUNT_NOT_ENOUGH = 13;// 全服购买数量不足

local m_unitPrice = 0; --单价
local m_addUnitPrice = 0; --额外兑换物品单价
local m_perLimitCount = 0; --个人购买上限(一次购买的最大单元数)

local function setAddtionPanelEnabled( enable )
	-- m_addtionPanel:setEnabled(enable);
end

--购买返回
local function receiveBuyResponse( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_SHOPBUYRESPONSE) then
		ProgressRadial.close();
		local resultId = messageData.resultId;
		print("resultId = " .. resultId);

		if(resultId == SUCCESS) then
			Util.showOperateResultPrompt("购买成功");
			print("购买成功");
		else
			Util.showOperateResultPrompt(response[resultId]);
			print(response[resultId]);
		end
		Shop.responseEnd();
	end
end


--购买逻辑
local function buy()
	if(m_data) then
		if(GoodsManager.isBackpackFull_2()) then
			--背包满提示
			BackpackFullTishi.show();
		else
			--继续
			print("m_shopTypeId = " .. m_shopTypeId);
			print("goodId = " .. m_data.goodsId);
			ProgressRadial.open();
			NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_SHOPBUY, {m_shopTypeId, m_count, m_data.index});--商店id，物品id，购买数量
		end
	end
end

--显示商品数据信息
local function refreshPrice()
	if(m_data) then
		m_countLabel:setStringValue(m_count);
		m_priceLabel:setStringValue(m_unitPrice*m_count);

		if(m_shopTypeId == SHOP_EXCHANGE) then
			-- m_excPrice:setText(m_addUnitPrice*m_count);
		end
	else
		m_countLabel:setStringValue(0);
		m_priceLabel:setStringValue(0);
		-- m_excPrice:setText(0);
	end
end

local function showInfo()
	if(m_data) then
        local moneyIconPath = GoodsManager.getUseGoodsIconPath(m_data["payType"]);
		m_moneyIconImg:loadTexture(moneyIconPath)
		if(m_shopTypeId == SHOP_EXCHANGE) then
			-- m_excPayIconImg:loadTexture(GoodsManager.getIconPathById(m_data["excPayType"])));
		end

		--是否可以购买
		local buyBtn = tolua.cast(m_rootLayout:getWidgetByName("buyBtn"), "Button");
        if(m_data["canBuy"] == 1) then
        	buyBtn:setTouchEnabled(true);
        	if(m_shopTypeId == SHOP_MYSTERY) then
				buyBtn:loadTextureNormal(IMAGE_PATH.SHENMI_SHOP_BUY_BTN_1);
        	else
				buyBtn:loadTextureNormal(IMAGE_PATH.SHOP_BUY_BTN_1);
        	end
    	else
        	buyBtn:setTouchEnabled(false);
        	if(m_shopTypeId == SHOP_MYSTERY) then
				buyBtn:loadTextureNormal(IMAGE_PATH.SHENMI_SHOP_BUY_BTN_0);
        	else
				buyBtn:loadTextureNormal(IMAGE_PATH.SHOP_BUY_BTN_0);
        	end
    	end

	else
		m_moneyIconImg:loadTexture("a.png");
		-- m_excPayIconImg:loadTexture("a.png");
	end
	refreshPrice();
end

local function buyBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
       	buy();
    end
end

local function addCountOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		--考虑上限
		if(m_count < m_perLimitCount) then
			m_count = m_count + 1;
			refreshPrice();
		end
    end
end

local function subCountOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        if(m_count > 1) then
			m_count = m_count - 1;
			refreshPrice();
        end
    end
end

function setPosition( pos )
    m_rootLayout:setPosition(pos);
end

local function setCallBack( btnCB )
	m_callback = btnCB;
end

local function setShowName( name )
	local buyBtn = tolua.cast(m_rootLayout:getWidgetByName("buy_btn"), "Button");
	buyBtn:setTitleText(name);
end

local function boundListener()
	local buyBtn = m_rootLayout:getWidgetByName("buyBtn");
	local addBtn = m_rootLayout:getWidgetByName("addBtn");
 	local subBtn = m_rootLayout:getWidgetByName("subBtn");
 	addBtn:addTouchEventListener(addCountOnClick);
 	subBtn:addTouchEventListener(subCountOnClick);
	buyBtn:addTouchEventListener(buyBtnOnClick);
end


--根据商店类型 和 商品编号查表获得商品数据
local function initData()
	m_count = 1;
	m_unitPrice = m_data.price; --单价
	m_perLimitCount = m_data.limitCount; --个人购买上限
	if(m_shopTypeId == SHOP_EXCHANGE) then
		m_addUnitPrice = m_data.excPrice; --额外兑换物品单价
	end
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayout = Shop.getRootLayout();
		boundListener();

		m_countLabel = tolua.cast(m_rootLayout:getWidgetByName("count_label"), "LabelAtlas");
		m_moneyIconImg = tolua.cast(m_rootLayout:getWidgetByName("moneyIcon_img"), "ImageView");
		m_priceLabel = tolua.cast(m_rootLayout:getWidgetByName("price_label"), "LabelAtlas");
		-- m_addtionPanel = tolua.cast(m_rootLayout:getWidgetByName("addtion_panel"), "Layout");
		m_excPayIconImg = tolua.cast(m_rootLayout:getWidgetByName("addtionicon_img"), "ImageView");
		m_excPrice = tolua.cast(m_rootLayout:getWidgetByName("addtionCount_label"), "Label");
		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SHOPBUYRESPONSE, receiveBuyResponse);
	end
end

function open(data, shopTypeId)
	if(data) then
		m_data = data;
		initData();
        -- m_rootLayout:getWidgetByName("buy_panel"):setEnabled(true);
		if(shopTypeId) then
			m_shopTypeId = shopTypeId;
			-- setAddtionPanelEnabled(m_shopTypeId == SHOP_EXCHANGE);
		end
		showInfo();
	else
        -- m_rootLayout:getWidgetByName("buy_panel"):setEnabled(false);
	end
end

function close()
	m_data = nil;
	shopTypeId = 0;
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
	    m_rootLayout = nil;
		m_callback = nil;
		NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SHOPBUYRESPONSE, receiveBuyResponse);
	end
end