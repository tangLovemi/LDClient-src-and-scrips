module("ShopRefreshUI", package.seeall)
--商店中倒计时刷新

local m_rootLayout = nil;
local m_isCreate = false;
local m_isOpen = false;
local m_shopId = nil;

local m_timeLabel = nil;

function isOpen()
	return m_isOpen;
end

function getShopId()
	return m_shopId;
end

function refreshTimeLabel(time)
    if(m_timeLabel) then
        m_timeLabel:setText(time);
    end
end

local function refreshGoodsOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		--判断刷新币是否足够
		local useData = DataTableManager.getItemByKey("shop_refresh_use", "shopId", m_shopId);
		local payType = useData.payType;
		local price = useData.price;
		local isEnough = false;
		if(payType == GoodsManager.getMoneyId()) then
			local money = UserInfoManager.getRoleInfo("gold");
			if(money >= price) then
				isEnough = true;
			else
				Util.showOperateResultPrompt("金币不足");
			end
		end

		if(payType == GoodsManager.getTokenId()) then
			local token = UserInfoManager.getRoleInfo("diamond");
			if(token >= price) then
				isEnough = true;
			else
				Util.showOperateResultPrompt("钻石不足");
			end
		end

		if(isEnough) then
			if(m_shopId == SHOP_MYSTERY) then
				MysteryShopGoods.sendRefreshRequest(MYSTERY_MONEY_REFRESH);
			elseif(m_shopId == SHOP_EXCHANGE) then
				ExchangeShopGoods.sendRefreshRequest(MYSTERY_MONEY_REFRESH);
			end
		end

	end
end

local function refreshToken()
	local useData = DataTableManager.getItemByKey("shop_refresh_use", "shopId", m_shopId);
	local payType = useData.payType;
	local price = useData.price;

	local payImg = tolua.cast(m_rootLayout:getWidgetByName("refreshPayType_img"), "ImageView");
	payImg:loadTexture(GoodsManager.getIconPathById(payType));

    local priceLabel = tolua.cast(m_rootLayout:getWidgetByName("refreshPrice_label"), "Label");
    priceLabel:setText(price);
end

local function initTime()
	m_timeLabel:setText(ShopTimeRefresh.getRefreshTime());
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayout = Shop.getRootLayout();

		m_timeLabel = tolua.cast(m_rootLayout:getWidgetByName("time_label"), "Label");
		local refreshBtn = m_rootLayout:getWidgetByName("refresh_btn");
		refreshBtn:addTouchEventListener(refreshGoodsOnClick);
	end
end

function open( ShopId )
	if (not m_isOpen) then
		m_isOpen = true;
		
		tolua.cast(m_rootLayout:getWidgetByName("refresh_panel"), "Layout"):setEnabled(true);

		if(ShopId ~= nil) then
			m_shopId = ShopId;
		end 
		initTime();
		refreshToken();
	end
end

function close()
	if (m_isOpen) then
		m_isOpen = false;
		tolua.cast(m_rootLayout:getWidgetByName("refresh_panel"), "Layout"):setEnabled(false);
    end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
	    m_rootLayout = nil;
		m_timeLabel = nil;
	end
end