module("ShopReload", package.seeall)


--重新load数据
function reloadShopData()
	local datas = DataTableManager.getTableByName("shop");
	for k,v in pairs(datas) do
		local areaid = v.areaid;
		local id = v.goodid;
		if(areaid == SHOP_MYSTERY) then
			_G["mysteryShop"][k] = v;
		elseif(areaid == SHOP_EXCHANGE) then
			_G["exchangeShop"][k] = v;
		elseif(areaid >= SHOP_NORMAL_BEGIN and areaid <= SHOP_NORMAL_BEGIN + SHOP_NOR_COUNT) then
			_G["generalShop"][k] = v;
		end
	end
end