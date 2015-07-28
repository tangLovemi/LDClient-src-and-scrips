module("OtherCalc", package.seeall)



--计算某件碎片或杂物被吞噬产出的物品
--产出包括：武器经验、金币、灵魂石、升阶石、魂玉 exp, money, soulStone, upstepStone, soulYu
function getDevourProduce(otherData)
	local otherid = otherData.id;
	local count = otherData.count;
	local item = DataTableManager.getItem("DevoursOthers", "id_" .. otherid);
	if(item ~= nil) then
		local duce = {};
		duce.exp = item.weaponExp*count;
		duce.money = item.money*count;
		duce.soulStone = item.soulStone*count;
		duce.upstepStone = item.upstepStone*count;
		duce.soulYu = item.soulYu*count;
		return duce;
	end
	return nil;
end