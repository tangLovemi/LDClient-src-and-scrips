module("MysteryShopGoods", package.seeall)
-----------------神秘商店数据-------------------
-- 游戏开始：服务器推送神秘商店中商品
-- 游戏进行中：1. 服务器倒计时结束，主动推送刷新物品数据
--             2. 用户消耗刷新令刷新物品，向服务器发送刷新请求，服务器传来更新物品数据
-- 服务器->客户端：刷新物品
-- 客户端->服务器；刷新请求
------------------------------------------------

local m_maxGoodsCount = 0; --商店中物品最大数量
local m_count = 0; 
local m_data = {};

function getData()
	return m_data;
end

function getMaxGoodsCount()
	return m_maxGoodsCount;
end

function getGoodsCount()
	return m_count;
end

function getGoodsByIndex(index)
	return m_data[index];
end

function getGoodsItemByIndex(index, name)
	return m_data[index][name];
end

function addData( data )
	table.insert(m_data, data);
	m_count = m_count + 1;
end

--接收服务器端传送的普通商店数据
local function onReceiveMysteryShopGoodsFromServer( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_MYSTERYSHOPGOODS)then
		m_data = {};
		m_count = 0;
		local curShopName = MYSTERY_SHOP_DATA_NAME;
		local datas = _G[curShopName];
		for i = 1,#messageData do
			local data = messageData[i];
			-- int	goodsId	物品id号	
			-- int	index	在商店表中位置	
			-- byte	canBuy	是否售罄
			local d = DataTableManager.getItem(curShopName, "id_" .. data.index);
			if(d ~= nil) then
				data.goodsId = d.goodid;
				data.name    = "神秘物品";
				data.payType = d.basePayType;
				data.count   = d.unitCount;
				local unitPrice = d.price;
				data.price   = unitPrice * d.unitCount;
				data.limitCount = d.maxUnit;
				data.limitDesc1 = d.limitDesc1;
				data.limitDesc2 = d.limitDesc2;
				data.isLimit = d.isLimit;
				addData(data);
			else
				print("***************** 神秘商店商品id配置有误，无此id商品  index = " .. data.index);
			end
		end
		--刷新UI
    	ProgressRadial.close();--关闭进度条
	end
end

function sendRequest(endCB)
    ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MYSTERYSHOPREQUEST, {});
end

function sendRefreshRequest( refreshType )
    ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MYSTERYSHOPREFRESH, {refreshType});
end

function registerMessageCB()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MYSTERYSHOPGOODS, onReceiveMysteryShopGoodsFromServer);
end

function unregisterMessageCB()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_MYSTERYSHOPGOODS, onReceiveMysteryShopGoodsFromServer);
end

--玩家登录-->物品：查询数据库-->空：随机得到物品，存库，发送到客户端
							 -->非空：得到神秘商店物品
		  -->时间：请求服务器，得到距离刷新的时间，客户端倒计时

--游戏进行中-->时间到：请求服务器，随机物品，存库，发送到客户端，恢复时间
            -->消耗刷新：请求服务器，随机物品，存库，发送到客户端，恢复时间，减少消耗品


-- create table shop(
-- 	userId varchar(32) not null,
-- 	mysGoodsText text,
-- 	excGoodsText text,
-- 	mysGoodsCount tinyint(4),
-- 	excGoodsCount tinyint(4),
-- 	primary key(userId)
-- );