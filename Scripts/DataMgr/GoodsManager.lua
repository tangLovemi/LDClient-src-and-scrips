module("GoodsManager", package.seeall)

local HIGH_CLASS_NAME = {
	equip = "equip",
	coat = "coat",
	weapon = "weapon",
	piece = "piece",
	other = "other",
	ancient = "ancient_nornal",
	self	= "self",
};

local HIGH_CLASS_TYPE = {
	equip_normal = "equip_normal",
	equip_grow = "equip_grow",
	equipPiece = "piece_equip",
	coatPiece = "piece_coat",
	other = "other",
	coat = "coat",
	weapon = "weapon",
};


local HIGH_TYPE_ID = {
	equip_normal = 1,
	equip_grow   = 1,
	equipPiece   = 6,
	coatPiece    = 5,
	other        = 4,
	coat 		 = 2,
	weapon 		 = 3,
}


--物品大类类型
function getGoodsHighType( goodsId )
	local t_highIds = DataTableManager.getTableByName("IdHighAreaData");
	for k,v in pairs(t_highIds) do
		if(goodsId >= v["minId"] and goodsId <= v["maxId"]) then
			return v["type"], v["hasPart"];
		end
	end
	return "";
end

--物品大类名称
function getGoodsHighName( goodsId )
	local t_highIds = DataTableManager.getTableByName("IdHighAreaData");
	for k,v in pairs(t_highIds) do
		if(goodsId >= v["minId"] and goodsId <= v["maxId"]) then
			return v["name"];
		end
	end
	return "";
end


function getGoodsHighTypeId( goodsId )
	local highTypeName = getGoodsHighType(goodsId);
	return HIGH_TYPE_ID[highTypeName];
end


--根据id号判断装备类型
--此类型名称和图标对应文件目录对应
local function getGoodsNameById( goodsId )
	local highType, hasPart = getGoodsHighType( goodsId );
	if(hasPart == 0) then
		return highType;
	else
		local t_ids = DataTableManager.getItemsByKey("IdAreaData", "highType", highType);
		for k,v in pairs(t_ids) do
			if(goodsId >= v["minId"] and goodsId <= v["maxId"]) then
				return v["name"];
			end
		end
	end
	return "";
end

function getGoodsTypeById( goodsId )
	local highType, hasPart = getGoodsHighType( goodsId );
	if(hasPart == 0) then
		return highType;
	else
		local t_ids = DataTableManager.getItemsByKey("IdAreaData", "highType", highType);
		for k,v in pairs(t_ids) do
			if(goodsId >= v["minId"] and goodsId <= v["maxId"]) then
				return v["type"];
			end
		end
	end
	return "";
end



------------------------------物品的基本信息-------------------------------------

--根据id得到icon路径
function getIconPathById(id)
	local name = getGoodsNameById(id);
	local iconId = id;
	local item = DataTableManager.getItem("GoodsName", "id_" .. id);
	if(item) then
		if(item.icon > 0) then
			iconId = item.icon;
		end
	end
	if("" ~= name and iconId > 0) then
		return PATH_RES_IMAGE .. name .. "/" .. iconId .. ".png";
	end
	return "";
end

--物品中文名称
function getNameById( id )
	local name = "";
	local item = DataTableManager.getItem("GoodsName", "id_" .. id);
	if(item) then
		name = item.name;
		if(name ~= nil) then
			return name;
		end
	end
	return id .. "的名称";
end

--物品描述
function getDescById( id )
	local desc = "";
	local item = DataTableManager.getItem("GoodsName", "id_" .. id);
	if(item) then
		desc = item.desc;
		if(desc ~= nil) then
			return desc;
		end
	end
	return id .. "的描述";
end

--物品类型
function getTypeById( id )
	local typeName = "";
	local item = DataTableManager.getItem("GoodsName", "id_" .. id);
	if(item) then
		typeName = item.type;
		if(typeName ~= nil) then
			return typeName;
		end
	end
	return id .. "的类型";
end

--颜色
function getColorById( id )
	local color = COLOR_WHITE;
	local item = DataTableManager.getItem("GoodsName", "id_" .. id);
	if(item) then
		if(item.color ~= nil) then
			if(item.color ~= "") then
				color = item.color;
			end
		end
	end
	return color;
end
--装备等级
function getLevelById( id )
	local level = 1;
	local item = DataTableManager.getItem("GoodsName", "id_" .. id);
	if(item) then
		if(item.level ~= nil) then
			if(item.level ~= "") then
				level = item.level;
			end
		end
	end
	return level;
end

--物品的基本信息（icon:图标路径  color:颜色  type：物品类型  name：名称  desc：描述  level：装备等级）
function getBaseInfo( id )
	local info = {};
	info.id = id;
	info.icon = getIconPathById(id);
	info.color = getColorById(id);
	info.frameIcon = getColorBgImg(info.color);
	info.type = getTypeById(id);
	info.name = getNameById(id);
	info.desc = getDescById(id);
	info.level = getLevelById(id);
	return info;
end




--商店某些消耗icon
function getUseGoodsIconPath( id )
	if(id == getSoulYuId()) then
		return PATH_RES_IMG_SHOP .. "gy_hb_hunyu.png";
	end

	if(id == getMoneyId()) then
		return PATH_RES_IMG_SHOP .. "180000.png";
	end
	
	if(id == getTokenId()) then
		return PATH_RES_IMG_SHOP .. "180003.png";
	end

	if(id == getPvpId()) then
		return PATH_RES_IMG_SHOP .. "180004.png";
	end
end
-------------------------------------------------------------------



--判断是成长性装备还是普通装备
function isGrowEquip( equipid )
	local highType = getGoodsHighType(equipid);
	if(HIGH_CLASS_TYPE.equip_normal == highType) then
		return false;
	elseif(HIGH_CLASS_TYPE.equip_grow == highType) then
		return true;
	end
	return -1;
end

--是武器或是装备
function isEquipOrWeapon(id)
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.coat or typeName == HIGH_CLASS_NAME.weapon or typeName == HIGH_CLASS_NAME.equip) then
		return true;
	end
	return false;
end

--是否是装备
function isEquip(id)
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.equip) then
		return true;
	end
	return false;
end

--是武器或是外套
function isWeaponOrCoat( id )
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.weapon or typeName == HIGH_CLASS_NAME.coat) then
		return true, typeName;
	end
	return false;
end

function isCoat( id )
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.coat) then
		return true, typeName;
	end
	return false;
end

function isWeapon( id )
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.weapon) then
		return true, typeName;
	end
	return false;
end

--是否是碎片
function isPiece( id )
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.piece) then
		return true;
	end
	return false;
end

function isAncient( id )
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.ancient) then
		return true;
	end
	return false;
end

function isSelf( id )
	local typeName = getGoodsHighName(id);
	if(typeName == HIGH_CLASS_NAME.self) then
		return true;
	end
	return false;
end

--是否是外套碎片
function isCoatPiece( id )
	local highType = getGoodsHighType(id);
	if(highType == HIGH_CLASS_TYPE.coatPiece) then
		return true;
	end
	return false;
end

function isOther( id )
	local highType = getGoodsHighType(id);
	if(highType == HIGH_CLASS_TYPE.other) then
		return true;
	end
	return false;
end

--是否是精灵蛋
function isSpriteEgg( id )
	return false;
end

local typeNameEN = {
    "helmet", "armour", "necklace", "ring", "shoe", "trousers", "glove", "coat", "weapon", "fashionCoat"
--    头盔      铠甲      项链       戒指    鞋子      裤子       手套    外套     武器         時裝
};

function getWeaponPartid()
	return 9;
end

local typeNameCN = {
	weapon = "精灵武器", 
	coat = "外套", 
	helmet_normal = "头盔", 
	armour_normal = "铠甲",
	necklace_normal = "项链",
	ring_normal = "戒指", 
	trousers_normal = "裤子",
	shoes_normal = "鞋子", 
	gloves_normal = "手套",
	helmet_grow = "头盔", 
	armour_grow = "铠甲",
	necklace_grow = "项链",
	ring_grow = "戒指", 
	trousers_grow = "裤子",
	shoes_grow = "鞋子", 
	gloves_grow = "手套",
};

--根据id得到类型名称
function getTypeNameById(id)
	local name = getGoodsTypeById(id);
	return typeNameCN.name;
end



--根据id得到物品信息是多是少
function getDetailsPanelTypeById(id)
	if(id >= ID_BEGIN_WEAP and id <= ID_END_NECKLACE) then
		return TAG_MUCH;
	else
		return TAG_LESS;
	end
end

--判断人物身上有无同类物品
--人物身上若没有此装备则对应物品id为-1
function isFigureHaveEquip( id )
	local typeName = getGoodsTypeById(id);
	for i = 1,#typeNameEN do
		if(typeNameEN[i] ~= "coat") then
			local figureData = UserInfoManager.getRoleInfo(typeNameEN[i]);
			if(figureData.id > 0) then
				local figureGoodName = getGoodsTypeById(figureData.id);
				if(typeName == figureGoodName) then
					return typeName, i;
				end
			end
		end
	end
	return nil;
end

--根据外套id得到外套类型
function getCoatTypeByCoatid( coatid )
	return DataTableManager.getItemByKey("coat_grow", "id", coatid).type;
end

function isWearedWeapon()
	local weaponid = UserInfoManager.getRoleInfo("weapon").id;
	if(weaponid > 0) then
		return true;
	else
		return false;
	end
end


--颜色名称
local COLOR_NAME = {
	"白", --1
	"绿", --2
	"蓝", --3
	"紫", --4
	"橙", --5
};
function getColorName(colorid)
	if(colorid <= #COLOR_NAME) then
		return COLOR_NAME[colorid];
	end
	return "";
end

--标志物品颜色的边框
local colorBgImg = {
    PATH_CCS_RES .. "gy_bian_bai.png", -- 白
    PATH_CCS_RES .. "gy_bian_lv.png", -- 绿
    PATH_CCS_RES .. "gy_bian_lan.png", -- 蓝
    PATH_CCS_RES .. "gy_bian_zi.png",-- 紫
    PATH_CCS_RES .. "gy_bian_cheng.png", -- 橙
};
function getColorBgImg( colorid )
	if(colorid > 0) then
		return colorBgImg[colorid];
	end
	return "";
end

--通过物品id直接获得颜色路径
function getColorBgByGoodid( goodid )
	local colorid = getColorById(goodid);
	return getColorBgImg(colorid);
end


--属性的中文名称
function getProNameByProid( proid )
	return DataTableManager.getValue("PropertyNameData", "id_" .. proid, "name")
end

function getCoatIconByCoatType( type )
	local iconId = DataTableManager.getValue("coat_name", "id_" .. type, "icon");
	return PATH_RES_IMG_COAT .. iconId ..".png";
end






---------------------------------得到某些特殊道具的id号----------------------------------------
local m_otherTypeName = {
	soulStone 	= "soulStone",
	soulYu 		= "soulYu",
	upstepStone = "upstepStone",
	spriteEgg 	= "spriteEgg",
	trainBless1 = "trainBless1",
	trainBless2 = "trainBless2",
	trainBless3 = "trainBless3",

};

local function getOtheridByTypeName( typeName )
	local ids = DataTableManager.getTableByName("IdAreaData");
	for k,v in pairs(ids) do
		if(typeName == v.type) then
			return v.minId;
		end
	end
end

function getSoulStoneId()
	return getOtheridByTypeName(m_otherTypeName["soulStone"]);
end
function getSoulYuId()
	return getOtheridByTypeName(m_otherTypeName["soulYu"]);
end
function getUpstepStoneId()
	return getOtheridByTypeName(m_otherTypeName["upstepStone"]);
end

function getTrainBless1Id()
	return getOtheridByTypeName(m_otherTypeName["trainBless1"]);
end
function getTrainBless2Id()
	return getOtheridByTypeName(m_otherTypeName["trainBless2"]);
end
function getTrainBless3Id()
	return getOtheridByTypeName(m_otherTypeName["trainBless3"]);
end

---------------------------------得到某些角色自身消耗品的id号----------------------------------------
local m_selfTypeName = {
	money = "money",
	token = "token",
	pvp   = "pvp",
};
local function getSelfidByTypeName( typeName )
	local ids = DataTableManager.getTableByName("IdAreaData");
	for k,v in pairs(ids) do
		if(typeName == v.type) then
			return v.minId;
		end
	end
end

function getMoneyId()
	return getSelfidByTypeName(m_selfTypeName["money"]);
end
function getTokenId()
	return getSelfidByTypeName(m_selfTypeName["token"]);
end
function getPvpId()
	return getSelfidByTypeName(m_selfTypeName["pvp"]);
end



--18号数字
local m_numberImg_18 = {
    PATH_CCS_RES .. "gyz_18_bai_houhei.png", 	-- 白
    PATH_CCS_RES .. "gyz_18_lv_houhei.png",	    -- 绿
    PATH_CCS_RES .. "gyz_18_lan_houhei.png", 	-- 蓝
    PATH_CCS_RES .. "gyz_18_zi_houhei.png",  	-- 紫
    PATH_CCS_RES .. "gyz_18_cheng_houhei.png",  -- 橙
};
local NUMBER_18_W = 14;
local NUMBER_18_H = 18;
function getNumberImg_18(color)
	if(color > 0) then
		return m_numberImg_18[color], NUMBER_18_W, NUMBER_18_H;
	end
	return "";
end




--装备五行属性图片
local m_wuxingImg = {
	PATH_CCS_RES .. "tiejiangpu_kuang_feng.png",	--1
	PATH_CCS_RES .. "tiejiangpu_kuang_huo.png",	--2
	PATH_CCS_RES .. "tiejaingpu_kuang_lei.png",	--3
	PATH_CCS_RES .. "tiejiangpu_kuang_guang.png",	--4
	PATH_CCS_RES .. "tiejiangpu_kuang_an.png",		--5
};
function getWuxingProImg( wuxingId )
   return m_wuxingImg[wuxingId];
end


--五行属性名称
local m_wuxingName = {
    "风", --1
    "火", --2
    "雷", --3
    "光", --4
    "暗"  --5
};
--五行名称
function getWuxingName( wuxingId )
	if(wuxingId) then
		return m_wuxingName[wuxingId];
	end
	return "";
end


--加号
local m_plusImg = {
	PATH_CCS_RES .. "gyf_jia_bai_18.png", 	--白
	PATH_CCS_RES .. "gyf_jia_lv_18.png", 	--绿
	PATH_CCS_RES .. "gyf_jia_lan_18.png", 	--蓝
	PATH_CCS_RES .. "gyf_jia_zi_18.png", 	--紫 
	PATH_CCS_RES .. "gyf_jia_cheng_18.png", --橙
};
function getPlusImgByColor( colorid )
	if(colorid) then
		return m_plusImg[colorid];
	end
	return "";
end



----------背包是否已满(是返回true， 否返回false)------------

-- 许愿
-- 活动副本
-- 关卡、扫荡   
function isBackpackFull_1()
	local curCount = UserInfoManager.getTotalCount();
    return curCount >= GOODS_COUNT_TOTAL_1;
end

-- 训练场买祝福卡
-- 商店
-- 赏金任务领取
-- 主线任务奖励领取（交任务）
-- 每日任务宝箱
-- 签到
-- 邮件
-- 好友礼物
function isBackpackFull_2()
	local curCount = UserInfoManager.getTotalCount();
    return curCount >= GOODS_COUNT_TOTAL_2;
end
