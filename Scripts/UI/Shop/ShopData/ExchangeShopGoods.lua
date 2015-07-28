module("ExchangeShopGoods", package.seeall)

-----------------兑换商店数据-------------------
------------------------------------------------

local m_maxGoodsCount = 0; --商店中物品最大数量
local m_count = 0; 
local m_data = {};

function getData()
	return m_data;
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
	-- m_data["id_" .. data.id] = data;
	m_count = m_count + 1;
end

--接收服务器端传送的普通商店数据
local function onReceiveMysteryShopGoodsFromServer( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_EXCHANGESHOPGOODS)then
		m_data = {};
		m_count = 0;
		local curShopName = EXCHANGE_SHOP_DATA_NAME;
		for i = 1,#messageData do
			local data = messageData[i];
			local d = DataTableManager.getItem(curShopName, "id_" .. data.index);
			if(d ~= nil) then
				data.goodsId = d.goodid;
				data.name      = "兑换物品";
				data.payType   = d.basePayType;
				data.count     = d.unitCount;
				local unitPrice = d.price;
				data.price     = unitPrice * d.unitCount;
				data.excPayType = d.excPayType;
				data.excPrice  = d.excCount;
				data.limitCount = d.maxUnit;
				data.limitDesc1 = d.limitDesc1;
				data.limitDesc2 = d.limitDesc2;
				data.isLimit = d.isLimit;
				addData(data);
			else
				print("***************** 兑换商店商品id配置有误，无此id商品  index = " .. data.index);
			end
		end
		--刷新UI
    	ProgressRadial.close();--关闭进度条
	end
end

function sendRequest(endCB)
    ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EXCHANGESHOPREQUEST, {SHOP_EXCHANGE});
end

function sendRefreshRequest( refreshType )
    ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EXCHANGESHOPREFRESH, {refreshType});
end

function registerMessageCB()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_EXCHANGESHOPGOODS, onReceiveMysteryShopGoodsFromServer);
end

function unregisterMessageCB()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_EXCHANGESHOPGOODS, onReceiveMysteryShopGoodsFromServer);
end

