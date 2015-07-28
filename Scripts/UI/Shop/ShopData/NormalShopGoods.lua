module("NormalShopGoods", package.seeall)

------------------普通商店数据-------------------
-- 游戏开始：服务器推送商店数据（物品id号）
-- 客户端接收：物品id号
-- 客户端发送：购买的物品、物品数量、消耗金钱
-------------------------------------------------

local m_maxGoodsCount = 0; 
local m_count = 0; 
local m_data = {};

function getData()
	return m_data;
end

function addGoods(data)
	table.insert(m_data, data);
	m_count = m_count + 1;
end

function getMaxGoodsCount()
	return m_maxGoodsCount;
end

function getGoodsCount()
	return m_count or 0;
end

function getGoodsByIndex(index)
	return m_data[index];
end

function getGoodsItemByIndex(index, name)
	return m_data[index][name];
end

--接收服务器端传送的普通商店数据
local function onReceiveNormalShopGoodsFromServer( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_NORMALSHOPGOODS)then
		m_data = {};
		m_count = 0;
		local curShopName = NORMAL_SHOP_DATA_NAME;
		for i = 1,#messageData do
			local data = messageData[i];
			local d = DataTableManager.getItem(curShopName, "id_" .. data.index);
			if(d ~= nil) then
				data.goodsId = d.goodid;
				data.name = "普通物品";
				data.payType = d.basePayType;
				data.count = d.unitCount;
				local unitPrice = d.price;
				data.price = unitPrice*d.unitCount;
				data.limitCount = d.maxUnit;
				data.limitDesc1 = d.limitDesc1;
				data.limitDesc2 = d.limitDesc2;
				data.isLimit = d.isLimit;
				addGoods(data);
			else
				print("普通商店商品id配置有误，无此id商品  index = " .. messageData[i].index);
			end
		end
    	ProgressRadial.close();--关闭进度条
	end
end


--切换据点或者主城时调用
function sendRequest( areaId )
    ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_NORMALSHOPREQUEST, {areaId});
end

function registerMessageCB()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_NORMALSHOPGOODS, onReceiveNormalShopGoodsFromServer);
end

function unregisterMessageCB()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_NORMALSHOPGOODS, onReceiveNormalShopGoodsFromServer);
end


--工作进度
--更新商品显示UI
--点击购买服务器连接
--定时刷新神秘商店