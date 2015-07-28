module("Transform", package.seeall)

require "UI/Background"
require "UI/BackpackFigure"
require "DataMgr/Calculation/EquipmentCalc"
---------------------------------------------------------
--                    铁匠铺界面
---------------------------------------------------------
local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil; --根节点
local m_pageLayout = nil; --标签页
local m_strengthLayout = nil; --强化UI
local m_resetLayout = nil; --属性重置UI
local m_upStepLayout = nil; --升阶UI

local m_curTag = nil; --标志当前背包是哪个标签下
local m_curIndex = nil; --标志当前选中的物品
local m_dataName = {"WeapData", "CoatData", "EquipsData"};

local m_curLayoutTag = nil; -- 当前是铁匠铺的哪个标签页下
local m_lastLayoutTag = nil; --上一个标签
local STRENGTH_TAG = 350;
local RESET_TAG = 351;
local UPSTEP_TAG = 352;


local icon_blank = PATH_CCS_RES .. "c_zhuangbeikuang.png";
--标签底图
local m_normalTexture = IMAGE_PATH.normal_page_bg;
local m_clickTexture = IMAGE_PATH.select_page_bg;
local m_disalbedTexture  = IMAGE_PATH.disable_page_bg;

local normalTexture = {
	PATH_CCS_RES .. "tiejiangpu_bq_qianghua_2.png",
	PATH_CCS_RES .. "tiejiangpu_bq_chongzhi_2.png",
	PATH_CCS_RES .. "tiejiangpu_bq_shengjie_2.png",
};
local clickTexture = {
	PATH_CCS_RES .. "tiejiangpu_bq_qianghua_1.png",
	PATH_CCS_RES .. "tiejiangpu_bq_chongzhi_1.png",
	PATH_CCS_RES .. "tiejiangpu_bq_shengjie_1.png",
};



local m_data = nil;
local m_isGrowEquip = false;
local m_figureTypeName = nil;

local MAX_BASE_PRO_COUNT    = 2; --装备基础属性条数
local MAX_ADDTION_PRO_COUNT = 5; --装备额外属性最大数量

local function closeBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.close("Transform");
    end
end


local function setPageButtonEnabled( enables )
	local strength = tolua.cast(m_pageLayout:getWidgetByName("strengthPage_panel"), "Layout");
	local reset = tolua.cast(m_pageLayout:getWidgetByName("resetPage_panel"), "Layout");
	local upStep = tolua.cast(m_pageLayout:getWidgetByName("upStepsPage_panel"), "Layout");
	local panels = {strength, reset, upStep};

	for i,v in ipairs(enables) do
		panels[i]:setTouchEnabled(v);
	end
end

local function changePageButtonBg()
	local strengthPage = tolua.cast(m_pageLayout:getWidgetByName("strengthPage_img"), "ImageView");
	local resetPage = tolua.cast(m_pageLayout:getWidgetByName("resetPage_img"), "ImageView");
	local upStepPage = tolua.cast(m_pageLayout:getWidgetByName("upStepsPage_img"), "ImageView");

	if(m_lastLayoutTag == STRENGTH_TAG) then
		strengthPage:loadTexture(normalTexture[1]);
	elseif(m_lastLayoutTag == RESET_TAG) then
		resetPage:loadTexture(normalTexture[2]);
	elseif(m_lastLayoutTag == UPSTEP_TAG) then
		upStepPage:loadTexture(normalTexture[3]);
	end

	if(m_curLayoutTag == STRENGTH_TAG) then
		strengthPage:loadTexture(clickTexture[1]);
	elseif(m_curLayoutTag == RESET_TAG) then
		resetPage:loadTexture(clickTexture[2]);
	elseif(m_curLayoutTag == UPSTEP_TAG) then
		upStepPage:loadTexture(clickTexture[3]);
	end
end

local function initPageButtonBg()
	local strengthPage = tolua.cast(m_pageLayout:getWidgetByName("strengthPage_img"), "ImageView");
	local resetPage = tolua.cast(m_pageLayout:getWidgetByName("resetPage_img"), "ImageView");
	local upStepPage = tolua.cast(m_pageLayout:getWidgetByName("upStepsPage_img"), "ImageView");
	strengthPage:loadTexture(clickTexture[1]);
	resetPage:loadTexture(normalTexture[2]);
	upStepPage:loadTexture(normalTexture[3]);
end

----------处理代理回调------------
local YES	  		= 0;
local MONEY_0 		= 1;
local TOKEN_0 		= 2;
local MATERIAL_0 	= 3;
local TEXT_MAX_STEP	= 4;

local TEXT_MONEY_0 		= "金币不足";
local TEXT_TOKEN_0 		= "钻石不足";
local TEXT_MATERIAL_0 	= "材料不足";
local TEXT_MAX_STEP		= "最大品阶";

local function setFuncBtnEnabled( index, enable )
	-- if(index == 1) then
	-- 	local strenBtn = tolua.cast(m_strengthLayout:getWidgetByName("strength_panel"), "Button");
	-- 	strenBtn:setTouchEnabled(enable);
	-- elseif(index == 2) then
	-- 	local resetBtn = tolua.cast(m_resetLayout:getWidgetByName("reset_panel"), "Button");
	-- 	resetBtn:setTouchEnabled(enable);
	-- elseif(index == 3) then
	-- 	local upstepBtn = tolua.cast(m_upStepLayout:getWidgetByName("upSteps_panel"), "Button");
	-- 	upstepBtn:setTouchEnabled(enable);
	-- end
end


local function checkCanReset(selectCount)
	--金币
	local price = EquipmentCalc.calcResetMoneyUse(m_data.id, m_data.upstepLV);
	local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold")
	--元宝
	local count = 0;
	if(selectCount == nil) then
		for i=1,5 do
			local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
			local isBund = isBundCB:getSelectedState();
			if(isBund) then
				count = count + 1;
			end
		end
	else
		count = selectCount;
	end
	local tokenPrice = EquipmentCalc.calcResetTokenyUse(count);
	local isTokenEnough = tokenPrice <= UserInfoManager.getRoleInfo("diamond");

	-- local can = (isMoneyEnough and isTokenEnough);
	if(not isMoneyEnough) then
		return MONEY_0;
	end
	if(not isTokenEnough) then
		return TOKEN_0;
	end

	return YES;
end

local function checkCanStren()
	local price = EquipmentCalc.calcStrenUse( m_data.id, m_data.strenLV, m_data.upstepLV );
	local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold");
	if(not isMoneyEnough) then
		return MONEY_0;
	end
	return YES;
end

local function checkCanUpstep()
	--金币
	local price = EquipmentCalc.calcUpstepMoneyUse(m_data.upstepLV);
	local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold");

	--元宝
	local isTokenEnough = true;
	local upstepBound = tolua.cast(m_upStepLayout:getWidgetByName("bd_checkbox"), "CheckBox");
	local isBund = upstepBound:getSelectedState();
	if(isBund) then
		local tokenPrice = EquipmentCalc.calcUpstepTokenUse(m_data.upstepLV);
		isTokenEnough = tokenPrice <= UserInfoManager.getRoleInfo("diamond");
	end

	--最大品阶
	local isMaxStep = EquipmentCalc.isMaxUpstepLv(m_data.upstepLV);

	--材料是否足够
	local materialEnough = true;
	if(m_upstepUse ~= nil) then
		for i,v in ipairs(m_upstepUse) do
			local needN = v.count;
			local haveN = UserInfoManager.getGoodsCount(v.id);
			if(needN > haveN) then
				--材料不足
				materialEnough = false;
			end
		end
	end

	if(not isMoneyEnough) then
		return MONEY_0;
	elseif(not isTokenEnough) then
		return TOKEN_0;
	elseif(not materialEnough) then
		return MATERIAL_0;
	elseif(isMaxStep) then
		return MAX_STEP;
	end
	return YES;
end


local function showStrengthDetails()
	local infoPanel = tolua.cast(m_strengthLayout:getWidgetByName("info_panel"), "Layout");
	infoPanel:setEnabled(true);

	local iconImg = tolua.cast(m_strengthLayout:getWidgetByName("icon_img"), "ImageView");
	iconImg:setEnabled(true);
	iconImg:loadTexture(GoodsManager.getIconPathById(m_data.id));
	
    local bgIcon = tolua.cast(m_strengthLayout:getWidgetByName("bgIcon_img"), "ImageView");
	bgIcon:setEnabled(true);
    bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(m_data.id)));

    local bgImg = tolua.cast(m_strengthLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(false);

	local levelNowLabel = tolua.cast(m_strengthLayout:getWidgetByName("level1_label"), "Label");
	levelNowLabel:setText(m_data.strenLV);

	--基础属性
    local baseProIds = Util.strToNumber(Util.Split(m_data.baseProid, ";"));
    local baseProVals = Util.strToNumber(Util.Split(m_data.baseProval, ";"));

    for i = 1,MAX_BASE_PRO_COUNT do
		local nameLabel = tolua.cast(m_strengthLayout:getWidgetByName("shuxing" .. i .. "_label"), "Label");
		local valueLabel = tolua.cast(m_strengthLayout:getWidgetByName("shuxingzi" .. i .. "_label"), "Label");
		local addLabel = tolua.cast(m_strengthLayout:getWidgetByName("add" .. i .. "_label"), "Label");
		if(baseProIds[i] > 0) then
	        nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. baseProIds[i], "name") .. ":");
	        valueLabel:setText(baseProVals[i]);
	        addLabel:setText("");
		end
    end

    --下一强化等级
    local nextData = nil;
 	if(EquipmentCalc.canUpStren(m_data.strenLV)) then
 		if(m_isGrowEquip) then
 			nextData = EquipmentCalc.calcGrowEquip( m_data.id, m_data.upstepLV,  m_data.strenLV + 1);
 		else
 			nextData = EquipmentCalc.calcNormalEquip(m_data.id, m_data.strenLV + 1);
 		end
 	end

	local levelNextLabel = tolua.cast(m_strengthLayout:getWidgetByName("level2_label"), "Label");
    if(nextData) then
		levelNextLabel:setText(m_data.strenLV + 1);

		local ids = nextData.ids;
    	local vals = nextData.vals;
    	for i = 1,MAX_BASE_PRO_COUNT do
			local addLabel = tolua.cast(m_strengthLayout:getWidgetByName("add" .. i .. "_label"), "Label");
	        addLabel:setText(vals[i]);
	    end
		--强化按钮
		--消耗面板
		local priceLabel = tolua.cast(m_strengthLayout:getWidgetByName("price_label"), "Label");
		local price = EquipmentCalc.calcStrenUse( m_data.id, m_data.strenLV, m_data.upstepLV );
		local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold")
		-- setFuncBtnEnabled(1, isMoneyEnough);

		priceLabel:setText(price);
	else
		levelNextLabel:setText("");
		for i = 1,MAX_BASE_PRO_COUNT do
			local addLabel = tolua.cast(m_strengthLayout:getWidgetByName("add" .. i .. "_label"), "Label");
	        addLabel:setText("");
	    end
		--强化按钮
		-- setFuncBtnEnabled(1, false);
		--消耗面板
		local priceLabel = tolua.cast(m_strengthLayout:getWidgetByName("price_label"), "Label");
		priceLabel:setText(0);
    end
end

local function setResetFunc(selectCount)
	--金币
	local price = EquipmentCalc.calcResetMoneyUse(m_data.id, m_data.upstepLV);
	local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold")
	--元宝
	local count = 0;
	if(selectCount == nil) then
		for i=1,5 do
			local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
			local isBund = isBundCB:getSelectedState();
			if(isBund) then
				count = count + 1;
			end
		end
	else
		count = selectCount;
	end
	local tokenPrice = EquipmentCalc.calcResetTokenyUse(count);
	local isTokenEnough = tokenPrice <= UserInfoManager.getRoleInfo("diamond");

	local isEnable = (isMoneyEnough and isTokenEnough);
	-- setFuncBtnEnabled(2, isEnable);
end



local TAG_RESET_BOUND_BASE = 245;
local function resetBoundOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		local count = 0;
		local d = {0, 0, 0, 0, 0};
		for i=1,5 do
			local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
			local isBund = isBundCB:getSelectedState();
			if(isBund) then
				count = count + 1;
				d[i] = 1;
			end
		end

		local index = sender:getTag() - TAG_RESET_BOUND_BASE;
		local isChoooseBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. index .. "_checkbox"), "CheckBox");
		if(isChoooseBundCB:getSelectedState()) then
			d[index] = 0;
			count = count - 1;
		else
			d[index] = 1;
			count = count + 1;
		end

		local haveLock = (count > 0);
		local tokenPanel = tolua.cast(m_resetLayout:getWidgetByName("token_panel"), "Layout");
		tokenPanel:setEnabled(haveLock);
		if(haveLock) then
			local tokenLabel = tolua.cast(m_resetLayout:getWidgetByName("zuanshi_label"), "Label");
			local tokenPrice = EquipmentCalc.calcResetTokenyUse(count);
			tokenLabel:setText(tokenPrice);
		end

		if(count < 4) then
			for i,v in ipairs(d) do
				if(v == 0) then
					local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
					-- isBundCB:setEnabled(true);
					isBundCB:setTouchEnabled(true);
				end
			end
		elseif(count == 4) then
			for i,v in ipairs(d) do
				if(v == 0) then
					local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
					-- isBundCB:setEnabled(false);
					isBundCB:setTouchEnabled(false);
				end
			end
		end

		-- setResetFunc(count);
	end
end

local function showResetDetails()
	local iconImg = tolua.cast(m_resetLayout:getWidgetByName("icon_img"), "ImageView");
	iconImg:setEnabled(true);
	iconImg:loadTexture(GoodsManager.getIconPathById(m_data.id));

    local bgIcon = tolua.cast(m_resetLayout:getWidgetByName("bgIcon_img"), "ImageView");
	bgIcon:setEnabled(true);
    bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(m_data.id)));

    local bgImg = tolua.cast(m_resetLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(false);

	local infoPanel = tolua.cast(m_resetLayout:getWidgetByName("info_panel"), "Layout");
	infoPanel:setEnabled(true);

	local function transData()
		local idvals = Util.Split(m_data.additionProval, "|");
		local id = Util.strToNumber(Util.Split(idvals[1], ";"));
		local val = Util.strToNumber(Util.Split(idvals[2], ";"));
		return id, val;
	end

	local ids, vals = transData();
	local count = #ids;
	--附加属性
	for i=1,MAX_ADDTION_PRO_COUNT do
		local panel = tolua.cast(m_resetLayout:getWidgetByName("shux" .. i .. "_panel"), "Label");
		panel:setEnabled(i <= count);
		if(i <= count) then
			local nameLabel = tolua.cast(m_resetLayout:getWidgetByName("shux" .. i .. "_label"), "Label");
			local valueLabel = tolua.cast(m_resetLayout:getWidgetByName("pro" .. i .. "_label"), "Label");
			-- local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
			nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[i], "name") .. ":");
			valueLabel:setColor(EquipmentCalc.getAddtionProColor(m_data.id, ids[i], vals[i], m_data.upstepLV));
			valueLabel:setText(vals[i]);
			-- isBundCB:setSelectedState(false);
		end
	end

	--重置按钮
	--白装无额外属性
	local priceLabel = tolua.cast(m_resetLayout:getWidgetByName("price_label"), "Label");
	if(m_data.color and m_data.color == COLOR_WHITE) then
		--消耗面板
		priceLabel:setText(0);
	else
		--消耗面板
		local price = EquipmentCalc.calcResetMoneyUse(m_data.id, m_data.upstepLV);
		priceLabel:setText(price);
	end

	-- local tokenPanel = tolua.cast(m_resetLayout:getWidgetByName("token_panel"), "Layout");
	-- tokenPanel:setEnabled(false);


	-- setResetFunc();
end


local function setUpstepFunc()
	-- local isMaxStrenLv = EquipmentCalc.isMaxStrenLv(m_data.strenLV);
	--金币
	local price = EquipmentCalc.calcUpstepMoneyUse(m_data.upstepLV);
	local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold");

	--元宝
	local tokenPrice = EquipmentCalc.calcUpstepTokenUse(m_data.upstepLV);
	local isTokenEnough = tokenPrice <= UserInfoManager.getRoleInfo("diamond");

	--最大品阶
	local isMaxStep = EquipmentCalc.isMaxUpstepLv(m_data.upstepLV);

	--材料是否足够
	local materialEnough = true;
	if(m_upstepUse ~= nil) then
		for i,v in ipairs(m_upstepUse) do
			local needN = v.count;
			local haveN = UserInfoManager.getGoodsCount(v.id);
			if(needN > haveN) then
				--材料不足
				materialEnough = false;
			end
		end
	end
	local isEnable = (isMoneyEnough and isTokenEnough and (not isMaxStep) and materialEnough);
	-- local isEnable = (isMoneyEnough and isTokenEnough and (not isMaxStep));
	-- setFuncBtnEnabled(3, isEnable);
end

--升阶绑定复选框
local function upstepBoundOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		local upstepBound = tolua.cast(m_upStepLayout:getWidgetByName("bd_checkbox"), "CheckBox");
		local isBund = upstepBound:getSelectedState();
		-- local tokenPanel = tolua.cast(m_upStepLayout:getWidgetByName("token_panel"), "Layout");
		-- tokenPanel:setEnabled(not isBund);

		local diamondLabel = tolua.cast(m_upStepLayout:getWidgetByName("zuanshi_label"), "Label");
		if(not isBund) then
			local tokenPrice = EquipmentCalc.calcUpstepTokenUse(m_data.upstepLV);
			diamondLabel:setText(tokenPrice);
		else
			diamondLabel:setText(0);
		end

		--计算升阶二级消耗
		setUpstepFunc();
	end
end

local m_upstepUse = nil;
--升阶材料点击
local function upstepGoodsOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_upstepUse ~= nil) then
	        local goodid = m_upstepUse[sender:getTag()].id;
	        if(GoodsManager.isAncient(goodid)) then
	        	UIManager.open("AncientMaterialItem",goodid);
	        else
	        	GoodsDetailsPanel.open(function() GoodsDetailsPanel.close(); end);
	        	GoodsDetailsPanel.showPanel({id = goodid}, UPSTEP_GOODS_OTHER_POS);
	        end
		end
    end
end

local function showUpStepDetails()
	local iconImg = tolua.cast(m_upStepLayout:getWidgetByName("icon_img"), "ImageView");
	iconImg:setEnabled(true);
	iconImg:loadTexture(GoodsManager.getIconPathById(m_data.id));

    local bgIcon = tolua.cast(m_upStepLayout:getWidgetByName("bgIcon_img"), "ImageView");
	bgIcon:setEnabled(true);
    bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(m_data.id)));

    local bgImg = tolua.cast(m_upStepLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(false);

	local infoPanel = tolua.cast(m_upStepLayout:getWidgetByName("info_panel"), "Layout");
	infoPanel:setEnabled(true);


	--基础属性
	local baseProIds = Util.strToNumber(Util.Split(m_data.baseProid, ";"));
    local baseProVals = Util.strToNumber(Util.Split(m_data.baseProval, ";"));
	for i=1,MAX_BASE_PRO_COUNT do
		local nameLabel = tolua.cast(m_upStepLayout:getWidgetByName("whux" .. i .. "_label"), "Label");
		local valueLabel = tolua.cast(m_upStepLayout:getWidgetByName("whuxzi" .. i .. "_label"), "Label");
        nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. baseProIds[i], "name") .. ":");
        valueLabel:setText(baseProVals[i]);
	end

	--装备等级
	local lvLabel = tolua.cast(m_upStepLayout:getWidgetByName("level_label"), "Label");
	lvLabel:setText(m_data.level);

	--下一品阶
 	local nextData = nil;
	if(m_isGrowEquip) then
    	if(EquipmentCalc.canUpStep(m_data.upstepLV)) then
    		nextData = EquipmentCalc.calcGrowEquip( m_data.id, m_data.upstepLV + 1, m_data.strenLV );
    	end
    end

	local levelNextLabel = tolua.cast(m_upStepLayout:getWidgetByName("level2_label"), "Label");
	local priceLabel = tolua.cast(m_upStepLayout:getWidgetByName("price_label"), "Label");
	if(nextData) then
		if(m_isGrowEquip) then
			levelNextLabel:setText(nextData.level);
		end
		local ids = nextData.ids;
		local vals = nextData.vals;
    	for i = 1,MAX_BASE_PRO_COUNT do
			-- local nameLabel = tolua.cast(m_upStepLayout:getWidgetByName("addzi" .. i .. "_label"), "Label");
			-- nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[i], "name") .. ":");
			local addLabel = tolua.cast(m_upStepLayout:getWidgetByName("add" .. i .. "_label"), "Label");
	        addLabel:setText(vals[i]);
	    end
		--普通升阶和绑定升阶按钮
		--消耗面板 计算
		local price = EquipmentCalc.calcUpstepMoneyUse(m_data.upstepLV);
		priceLabel:setText(price);
		--按钮
	else
		levelNextLabel:setText("");
		for i = 1,MAX_BASE_PRO_COUNT do
			-- local nameLabel = tolua.cast(m_upStepLayout:getWidgetByName("addzi" .. i .. "_label"), "Label");
			-- nameLabel:setText("");
			local addLabel = tolua.cast(m_upStepLayout:getWidgetByName("add" .. i .. "_label"), "Label");
	        addLabel:setText("");
	    end
		--普通升阶和绑定升阶按钮
		--消耗面板
		priceLabel:setText(0);
    end

	-- local tokenPanel = tolua.cast(m_upStepLayout:getWidgetByName("token_panel"), "Layout");
	-- tokenPanel:setEnabled(false);
	local diamondLabel = tolua.cast(m_upStepLayout:getWidgetByName("zuanshi_label"), "Label");
	local upstepBound = tolua.cast(m_upStepLayout:getWidgetByName("bd_checkbox"), "CheckBox");
	local isBund = upstepBound:getSelectedState();
	if(isBund) then
		local tokenPrice = EquipmentCalc.calcUpstepTokenUse(m_data.upstepLV);
		diamondLabel:setText(tokenPrice);
	else
		diamondLabel:setText(0);
	end

	m_upStepLayout:getWidgetByName("bd_checkbox"):setTouchEnabled(true);
	-- local boundPanel = tolua.cast(m_upStepLayout:getWidgetByName("bound_panel"), "Layout");
	-- boundPanel:setEnabled(true);

	--升阶消耗
	m_upstepUse = EquipmentCalc.getUpstepUse(m_data);
	m_upStepLayout:getWidgetByName("cailiao_2_Panel"):setEnabled(false);
	m_upStepLayout:getWidgetByName("cailiao_3_Panel"):setEnabled(false);
	m_upStepLayout:getWidgetByName("cailiao_4_Panel"):setEnabled(false);
	if(m_upstepUse ~= nil) then
		local count = #m_upstepUse;
		if(count == 2) then
			m_upStepLayout:getWidgetByName("cailiao_2_Panel"):setEnabled(true);
		elseif(count == 3) then
			m_upStepLayout:getWidgetByName("cailiao_3_Panel"):setEnabled(true);
		elseif(count == 4) then
			m_upStepLayout:getWidgetByName("cailiao_4_Panel"):setEnabled(true);
		end
		
		for i,v in ipairs(m_upstepUse) do
			local iconImg = tolua.cast(m_upStepLayout:getWidgetByName("zb_" .. count .. "_cailiao" .. i .. "_img"), "ImageView");
			local bgiconImg = tolua.cast(m_upStepLayout:getWidgetByName("zb_" .. count .. "_kuang" .. i .. "_img"), "ImageView");
			local haveLabel = tolua.cast(m_upStepLayout:getWidgetByName("zb_" .. count .. "_zhi_label" .. i .. "_1"), "Label");
			local needLabel = tolua.cast(m_upStepLayout:getWidgetByName("zb_" .. count .. "_zhi_label" .. i .. "_2"), "Label");
			local spaceLabel = tolua.cast(m_upStepLayout:getWidgetByName("zb_" .. count .. "_xie_label" .. i .. "_1"), "Label");
			iconImg:loadTexture(GoodsManager.getIconPathById(v.id));
			bgiconImg:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(v.id)));
			local haveN = UserInfoManager.getGoodsCount(v.id);
			local needN = v.count;
			haveLabel:setText(haveN);
			needLabel:setText(needN);
			if(haveN >= needN) then
				haveLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
				needLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
				spaceLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
			else
				haveLabel:setColor(COLOR_VALUE[COLOR_RED]);
				needLabel:setColor(COLOR_VALUE[COLOR_RED]);
				spaceLabel:setColor(COLOR_VALUE[COLOR_RED]);
			end
		end
	end

	--箭头
	-- local function setJianTouEnabeld( enable )
	-- 	for i=1,3 do
	-- 		local jiantouImg = tolua.cast(m_upStepLayout:getWidgetByName("jiantou_img_" .. i), "ImageView");
	-- 		jiantouImg:setEnabled(enable);
	-- 	end
	-- end
	-- setJianTouEnabeld(true);
	local function setInfoPanelEnabled(enable)
		m_upStepLayout:getWidgetByName("info_panel"):setEnabled(enable);
		m_upStepLayout:getWidgetByName("shengjieyiman_Panel"):setEnabled(not enable);
	end
	setInfoPanelEnabled(true);
	--最高品阶提示
    if(m_data.upstepLV >= EquipmentCalc.getMaxUpstepLV()) then
		-- setJianTouEnabeld(false);
		setInfoPanelEnabled(false);
    	if(m_curLayoutTag == UPSTEP_TAG) then
    		-- Util.showOperateResultPrompt("该物品升阶暂未开启！");
    	end
    end

    --设置功能按钮
	setUpstepFunc();
end

local function showGoodsDetails()
	if(m_data) then
		m_isGrowEquip = GoodsManager.isGrowEquip(m_data.id);
	 --   	if(m_isGrowEquip) then
		-- 	setPageButtonEnabled({true, true, true});
		-- else
		-- 	setPageButtonEnabled({true, true, false});
		-- end
		changePageButtonBg();

		showStrengthDetails();
		showResetDetails();
		showUpStepDetails();
	end
end

---------------------------清空面板---------------------------
local function clearStrengthDetails()
	local iconImg = tolua.cast(m_strengthLayout:getWidgetByName("icon_img"), "ImageView");
	iconImg:setEnabled(false);

	local bgIcon = tolua.cast(m_strengthLayout:getWidgetByName("bgIcon_img"), "ImageView");
	bgIcon:setEnabled(false);

    local bgImg = tolua.cast(m_strengthLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(true);

	local infoPanel = tolua.cast(m_strengthLayout:getWidgetByName("info_panel"), "Layout");
	infoPanel:setEnabled(false);

	local priceLabel = tolua.cast(m_strengthLayout:getWidgetByName("price_label"), "Label");
	priceLabel:setText(0);

	--强化按钮
	setFuncBtnEnabled(1, false);
end

local function clearResetDetails()
	local iconImg = tolua.cast(m_resetLayout:getWidgetByName("icon_img"), "ImageView");
	iconImg:setEnabled(false);

    local bgIcon = tolua.cast(m_resetLayout:getWidgetByName("bgIcon_img"), "ImageView");
	bgIcon:setEnabled(false);

    local bgImg = tolua.cast(m_resetLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(true);

	local infoPanel = tolua.cast(m_resetLayout:getWidgetByName("info_panel"), "Layout");
	infoPanel:setEnabled(false);

	local priceLabel = tolua.cast(m_resetLayout:getWidgetByName("price_label"), "Label");
	priceLabel:setText(0);

	local tokenPanel = tolua.cast(m_resetLayout:getWidgetByName("token_panel"), "Layout");
	tokenPanel:setEnabled(false);

	for i=1,MAX_ADDTION_PRO_COUNT do
		local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
		isBundCB:setSelectedState(false);
	end

	--重置按钮
	setFuncBtnEnabled(2, false);
end

local function clearUpStepDetails()
	local iconImg = tolua.cast(m_upStepLayout:getWidgetByName("icon_img"), "ImageView");
	iconImg:setEnabled(false);

	local bgIcon = tolua.cast(m_upStepLayout:getWidgetByName("bgIcon_img"), "ImageView");
	bgIcon:setEnabled(false);

    local bgImg = tolua.cast(m_upStepLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(true);

	local infoPanel = tolua.cast(m_upStepLayout:getWidgetByName("info_panel"), "Layout");
	infoPanel:setEnabled(false);

	local priceLabel = tolua.cast(m_upStepLayout:getWidgetByName("price_label"), "Label");
	priceLabel:setText(0);
	local diamondLabel = tolua.cast(m_upStepLayout:getWidgetByName("zuanshi_label"), "Label");
	diamondLabel:setText(0);

	m_upStepLayout:getWidgetByName("shengjieyiman_Panel"):setEnabled(false);

	local upstepBound = tolua.cast(m_upStepLayout:getWidgetByName("bd_checkbox"), "CheckBox");
	upstepBound:setSelectedState(false);

	m_upStepLayout:getWidgetByName("bd_checkbox"):setTouchEnabled(false);
	m_upStepLayout:getWidgetByName("cailiao_2_Panel"):setEnabled(false);
	m_upStepLayout:getWidgetByName("cailiao_3_Panel"):setEnabled(false);
	m_upStepLayout:getWidgetByName("cailiao_4_Panel"):setEnabled(false);
	
	--普通升阶和绑定升阶按钮
	setFuncBtnEnabled(3, false);
end


local function clearGoodsDetails()
	clearStrengthDetails();
	clearResetDetails();
	clearUpStepDetails();
end

------------标签页转换-----------
local function showStrengthLayout()
	if(m_curLayoutTag == RESET_TAG) then
		m_rootLayer:removeChild(m_resetLayout, false);
		m_rootLayer:addChild(m_strengthLayout, 1);
		m_lastLayoutTag = RESET_TAG;
	elseif(m_curLayoutTag == UPSTEP_TAG) then
		m_rootLayer:removeChild(m_upStepLayout, false);
		m_rootLayer:addChild(m_strengthLayout, 1);
		m_lastLayoutTag = UPSTEP_TAG;
	end
	m_curLayoutTag = STRENGTH_TAG;
end

local function showResetLayout()
	if(m_curLayoutTag == STRENGTH_TAG) then
		m_rootLayer:removeChild(m_strengthLayout, false);
		m_rootLayer:addChild(m_resetLayout, 1);
		m_lastLayoutTag = STRENGTH_TAG;
	elseif(m_curLayoutTag == UPSTEP_TAG) then
		m_rootLayer:removeChild(m_upStepLayout, false);
		m_rootLayer:addChild(m_resetLayout, 1);
		m_lastLayoutTag = UPSTEP_TAG;
	end
	m_curLayoutTag = RESET_TAG;
end

local function showUpStepLayout()
	if(m_curLayoutTag == STRENGTH_TAG) then
		m_rootLayer:removeChild(m_strengthLayout, false);
		m_rootLayer:addChild(m_upStepLayout, 1);
		m_lastLayoutTag = STRENGTH_TAG;
	elseif(m_curLayoutTag == RESET_TAG) then
		m_rootLayer:removeChild(m_resetLayout, false);
		m_rootLayer:addChild(m_upStepLayout, 1);
		m_lastLayoutTag = RESET_TAG;
	end
	m_curLayoutTag = UPSTEP_TAG;
end

local function strengthPageOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        showStrengthLayout();
        changePageButtonBg();
    end
end

local function resetPageOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        showResetLayout();
        changePageButtonBg();
    end
end

local function upStepPageOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_isGrowEquip) then
	        showUpStepLayout();	
	        changePageButtonBg();
	    else
			if(m_data ~= nil) then
    			Util.showOperateResultPrompt("此装备不可升阶");
    		end
		end
    end
end

local OPE_TYPE_STRENGTH_EQUIP = 1;
local OPE_TYPE_UPSTEP_EQUIP	 = 2;
local OPE_TYTE_RESET_EQUIP	 = 3;

--装备强化
local OPE_RESULT_EQUIP_STREN_MAX  = 1; --强化到最高
local OPE_RESULT_EQUIP_STREN_OK   = 2; --强化成功
local OPE_RESULT_EQUIP_STREN_FAIL = 3; -- 强化失败
local OPE_RESULT_EQUIP_STREN_DOWN = 4; -- 强化降级

--升阶装备
local OPE_RESULT_EQUIP_UPSTEP_MAX = 6; --升阶到最高阶
local OPE_RESULT_EQUIP_UPSTEP_OK  = 7; --升阶成功
local OPE_RESULT_MATERIAL_NOT_ENOUGH = 8; --材料不足
local OPE_RESULT_LEVEL_NOT_ENOUGH = 9; --升阶后不能装备

--重置装备
local OPE_RESULT_EQUIP_RESET_OK  = 11; --重置成功


-----------------功能按钮处理, 处理各个功能逻辑----------------------

local function showResult(operateId, resultId)
	local text = "";
	if(resultId == OPE_RESULT_EQUIP_MONEY_NOT_ENOUGH) then
		text = TEXT.noMoney;
	elseif(resultId == OPE_RESULT_EQUIP_TOKEN_NOT_ENOUGH) then
		text = TEXT.noToken;
	else
		if(operateId == OPE_TYPE_STRENGTH_EQUIP) then
			if(resultId == OPE_RESULT_EQUIP_STREN_MAX) then
				text = "强化到最高等级";
			elseif(resultId == OPE_RESULT_EQUIP_STREN_OK) then
				text = "强化成功";
        		AudioEngine.playEffect(PATH_RES_AUDIO.."qianghuachenggong.mp3");
			elseif(resultId == OPE_RESULT_EQUIP_STREN_FAIL) then
				text = "强化失败";
        		AudioEngine.playEffect(PATH_RES_AUDIO.."qianghuashibai.mp3");
			elseif(resultId == OPE_RESULT_EQUIP_STREN_DOWN) then
				text = "强化降级";
        		AudioEngine.playEffect(PATH_RES_AUDIO.."qianghuajiangji.mp3");
			end
		elseif(operateId == OPE_TYPE_UPSTEP_EQUIP) then
			if(resultId == OPE_RESULT_EQUIP_UPSTEP_MAX) then
				text = "升阶到最高等级";
			elseif(resultId == OPE_RESULT_MATERIAL_NOT_ENOUGH)then
				text = "材料不足";
			elseif(resultId == OPE_RESULT_LEVEL_NOT_ENOUGH) then
				text = "升阶后装备等级不足";
			elseif(resultId == OPE_RESULT_EQUIP_UPSTEP_OK) then
				text = "升阶成功";
			end
		elseif(operateId == OPE_TYTE_RESET_EQUIP) then
			if(resultId == OPE_RESULT_EQUIP_RESET_OK) then
				text = "重置成功";
			end
		end
	end
	Util.showOperateResultPrompt(text);
end

local function onReceiveOperateResponse( messageType, messageData )
	local operateId = messageData.operateId;
	local resultId = messageData.resultId;

    ProgressRadial.close();
	if(m_curTag ~= TAG_FIGURE) then
    	GoodsList.refreshDisplay();
    else
    	Figure.refreshDisplay();
	end

    if(m_curTag == TAG_FIGURE) then
	    local data = UserInfoManager.getRoleAllInfo()[m_figureTypeName];
		if(GoodsManager.isEquip(data.id)) then
			m_data = data;
		end
    	-- FigureProperty.refreshDisplay();
    else
    	local data = UserInfoManager.getGoodsInfo(m_curTag, m_curIndex)[m_curIndex];
    	if(GoodsManager.isEquip(data.id)) then
    		m_data = data;
    	end
    end
    showGoodsDetails();

    showResult(operateId, resultId);
end


local function getFigureOrBp()
	if(m_curTag == TAG_FIGURE) then
		return 1;
	else
		return 2;
	end
end

local function getFigureOrBpIndex()
	if(m_curTag == TAG_FIGURE) then
		return Figure.getCurPart();
	else
		return m_curIndex;
	end
end


local function canOperate()
	if(m_data ~= nil and (m_curIndex > 0 or m_figureTypeName ~= "")) then
		return true;
	else
		Util.showOperateResultPrompt("未选择装备");
		return false;
	end
end

function strengthBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(canOperate()) then
			local can = checkCanStren();
			if(can == YES) then
				ProgressRadial.open();
				NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPSTRENGTHEN, {getFigureOrBp(), getFigureOrBpIndex()});
			else
				Util.showOperateResultPrompt(TEXT_MONEY_0);
			end
		end
    end
end

local function resetBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(canOperate()) then
			if(m_data ~= nil) then
				local can = checkCanReset();
				if(can == YES) then
					--将锁定的属性位置置为1 例如：010100010000  三个位置的属性被锁定
					local isBundT = {};
					local count = EquipmentCalc.getAddtionProCount(m_data.id);
					if(count > 0) then
						for i=1,count do
							local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
							local isBund = isBundCB:getSelectedState();
							if(isBund) then
								table.insert(isBundT, 1);
							else
								table.insert(isBundT, 0);
							end
						end
						local isBundStr = Util.tableToStrBySeparator(isBundT, ";");
						ProgressRadial.open();
						NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPRESET, {getFigureOrBp(), getFigureOrBpIndex(), isBundStr});
					end
				else
					if(can == MONEY_0) then
						Util.showOperateResultPrompt(TEXT_MONEY_0);
					elseif(can == TOKEN_0) then
						Util.showOperateResultPrompt(TEXT_TOKEN_0);
					end
				end
			end
		end
    end
end

local function upStepBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(canOperate()) then
			if(m_data ~= nil) then
				local can = checkCanUpstep();
				if(can == YES) then
					ProgressRadial.open();
					local upstepBound = tolua.cast(m_upStepLayout:getWidgetByName("bd_checkbox"), "CheckBox");
					local isBound = 0;
					if(upstepBound:getSelectedState()) then
						isBound = 1;
					end
					NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPUPSTEP, {getFigureOrBp(), getFigureOrBpIndex(), isBound});
				else
					if(can == MONEY_0) then
						Util.showOperateResultPrompt(TEXT_MONEY_0); 
					elseif(can == TOKEN_0) then
						Util.showOperateResultPrompt(TEXT_TOKEN_0);
					elseif(can == MATERIAL_0) then
						Util.showOperateResultPrompt(TEXT_MATERIAL_0);
					elseif(can == MAX_STEP)then
						Util.showOperateResultPrompt(TEXT_MAX_STEP);
					end
				end
			end
		end
    end
end


----------------绑定监听-------------------------

--为标签按钮添加监听
local function boundTabPageBtnListener()
	local strengthBtn = tolua.cast(m_pageLayout:getWidgetByName("strengthPage_panel"), "Layout");
	local resetBtn = tolua.cast(m_pageLayout:getWidgetByName("resetPage_panel"), "Layout");
	local upStepBtn = tolua.cast(m_pageLayout:getWidgetByName("upStepsPage_panel"), "Layout");
	strengthBtn:addTouchEventListener(strengthPageOnClick);
	resetBtn:addTouchEventListener(resetPageOnClick);
	upStepBtn:addTouchEventListener(upStepPageOnClick);
end

--为功能按钮添加监听
local function boundFunctionBtnListener()
	--强化按钮
	local strengthBtn = m_strengthLayout:getWidgetByName("strength_panel");
	strengthBtn:addTouchEventListener(strengthBtnOnClick);
	--重置按钮
	local resetBtn = m_resetLayout:getWidgetByName("reset_panel");
	resetBtn:addTouchEventListener(resetBtnOnClick);
	--普通升阶和绑定升阶按钮
	local upStepBtn = m_upStepLayout:getWidgetByName("upSteps_panel");
	upStepBtn:addTouchEventListener(upStepBtnOnClick);


	--重置界面绑定按钮
	for i=1,5 do
		local isBundCB = tolua.cast(m_resetLayout:getWidgetByName("xz" .. i .. "_checkbox"), "CheckBox");
		isBundCB:setTag(i + TAG_RESET_BOUND_BASE);
		isBundCB:addTouchEventListener(resetBoundOnClick);
	end

	--升阶绑定按钮
	local upstepBound = tolua.cast(m_upStepLayout:getWidgetByName("bd_checkbox"), "CheckBox");
	upstepBound:addTouchEventListener(upstepBoundOnClick);

	--升阶材料点击
	local types = {2,3,4};
	for i=1,#types do
		for j=1,types[i] do
			local good = m_upStepLayout:getWidgetByName("zb_" .. types[i] .. "_cailiao" .. j .. "_img");
			good:setTag(j);
			good:addTouchEventListener(upstepGoodsOnClick);
		end
	end
end

--在升阶面板点击了一个普通装备，转到强化面板
local function checkupstepToStren()
	if(m_curLayoutTag == UPSTEP_TAG) then
		if(GoodsManager.getColorById(m_data.id) ~= COLOR_ORANGE) then
	        showStrengthLayout();
	        changePageButtonBg();
		end
	end
end

--点击背包中装备回调
function goodsOnClick( index, tag )
    -- print("******** 铁匠铺 物品 tag " .. tag .. "  ,index = " .. index);
    local isSame = true;
    if(m_curTag ~= tag) then
    	m_curTag = tag;
    	m_curIndex = index;
    	isSame = false;
    else
    	if(m_curIndex ~= index) then
    		m_curIndex = index;
    		isSame = false;
    	end
    end

    if(not isSame) then
    	local data = UserInfoManager.getGoodsInfo(m_curTag, m_curIndex)[m_curIndex];
    	if(GoodsManager.isEquip(data.id)) then
    		m_data = data;
    		clearResetDetails();
    		showGoodsDetails();
    		checkupstepToStren();
    	end
    else
    	m_data = nil;
    end
end

--点击人物面板装备回调
function figureIconOnClick( typeName )
    print("********** typeName = " .. typeName);
    local isSame = true;
    if(m_curTag ~= TAG_FIGURE) then
    	m_curTag = TAG_FIGURE;
    	m_figureTypeName = typeName;
    	isSame = false;
    else
    	if(m_figureTypeName ~= typeName) then
    		m_figureTypeName = typeName;
    		isSame = false;
    	end
    end

    if(not isSame) then
    	local data = UserInfoManager.getRoleAllInfo()[m_figureTypeName];
    	if(GoodsManager.isEquip(data.id)) then
    		m_data = data;
    		clearResetDetails();
    		showGoodsDetails();
    		checkupstepToStren();
    	end
    else
    	m_data = nil;
	end
end

local function openInit()
	clearGoodsDetails();
    m_curIndex = 0;
    m_figureTypeName = "";
    m_isGrowEquip = true;
end

--点击了右侧上面标签
function onFigureBackpackPageChanged(tag)
	-- if(m_isGrowEquip) then
	-- 	setPageButtonEnabled({true, true, true});
	-- else
	-- 	setPageButtonEnabled({true, true, false});
	-- end
	changePageButtonBg();

	openInit();
end


local function registerMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRANSFORMRESPONSE, onReceiveOperateResponse);
end

local function unRegisterMessage()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRANSFORMRESPONSE, onReceiveOperateResponse);
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

	    local pagePanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TransForm_Page.json");

		local strengthPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TransForm_Strengthen.json");
	    local resetPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Transform_Reset.json");
	    local upStepPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TransForm_UpSteps.json");
	    -- local compositePanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TransForm_Composite.json");

	    local panelPos = ccp(104, 27);

	    m_strengthLayout = TouchGroup:create();
	    m_strengthLayout:addWidget(strengthPanel);
	    m_strengthLayout:setPosition(panelPos);
	    m_strengthLayout:retain();

	    m_resetLayout = TouchGroup:create();
	    m_resetLayout:addWidget(resetPanel);
	    m_resetLayout:setPosition(panelPos);
	    m_resetLayout:retain();

	    m_upStepLayout = TouchGroup:create();
	    m_upStepLayout:addWidget(upStepPanel);
	    m_upStepLayout:setPosition(panelPos);
	    m_upStepLayout:retain();

	    local page = tolua.cast(m_strengthLayout:getWidgetByName("biaoqian_panel"), "Layout");
	    local x = page:getPositionX();
	    local y = page:getPositionY();
	    local pagePos = ccp(panelPos.x + x, panelPos.y + y);

	    m_pageLayout = TouchGroup:create();
	    m_pageLayout:addWidget(pagePanel);
	    m_pageLayout:setPosition(pagePos);
	    m_pageLayout:retain();

	    m_rootLayer:addChild(m_strengthLayout, 1);
	    m_rootLayer:addChild(m_pageLayout, 2);

	    boundTabPageBtnListener();
	    boundFunctionBtnListener();

	    BackpackFigure.create();
		GoodsDetailsPanel.create();
	end
end

function open()
	if (not m_isOpen) then
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        Background.create("Transform");
        Background.open();
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);


        clearGoodsDetails();

        if(m_curLayoutTag == nil) then
        	m_curLayoutTag = STRENGTH_TAG;
        	m_lastLayoutTag = STRENGTH_TAG;
        else
        	showStrengthLayout();
        end
        m_curTag = TAG_FIGURE;
        m_curIndex = 0;
        m_figureTypeName = "";
    	m_isGrowEquip = true;
        m_data = nil;

        -- setPageButtonEnabled({true, true, true});
        changePageButtonBg();
        initPageButtonBg();

	    BackpackFigure.open("Transform");
        registerMessage();
        AncientMaterialItem.setCallBack(function() UIManager.close("Transform"); end);
    end
end

function close()
	if (m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

        Background.close();
        Background.remove();

        BackpackFigure.close();
        unRegisterMessage();

		ProgressRadial.close();
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
	    m_curLayoutTag = nil;
	    m_lastLayoutTag = nil;
	    m_curTag = nil;
	    m_curIndex = nil;
	    m_pageLayout = nil; 
	    m_strengthLayout:release();
		m_strengthLayout = nil; 
	    m_resetLayout:release();
		m_resetLayout = nil; 
	    m_upStepLayout:release();
		m_upStepLayout = nil; 

	    BackpackFigure.remove();
	end
end



