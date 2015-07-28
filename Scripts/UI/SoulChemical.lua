module("SoulChemical", package.seeall)

require "UI/BackpackFigure"
---------------------------------------------------------
--                    灵魂炼化界面 (在关闭时进行数据存储)
---------------------------------------------------------
local RESET_BTN_TAG_BASE = 1002;
local LAYOUT_TAG_BASE = 2002;

local m_isCreate = false;
local m_isOpen   	= false;
local m_rootLayer   = nil;
local m_tabLayout   = nil;
local m_chemicalLayout = nil; --炼化面板
local m_transLayout = nil; --转换面板
local m_resetLayout = nil;--重置面板
local m_layout = nil;
local m_figureTypeName = "";

local m_curTag1 = nil;
local m_curTag2 = nil;
local m_curTag = nil;
local m_lastTag = nil;
local CHEMI_TAG = LAYOUT_TAG_BASE + 1;
local TRANS_TAG = LAYOUT_TAG_BASE + 2;
local RESET_TAG = LAYOUT_TAG_BASE + 3;

local m_normalTexture = IMAGE_PATH.normal_page_bg;
local m_clickTexture = IMAGE_PATH.select_page_bg;
local m_disalbedTexture    = IMAGE_PATH.disable_page_bg;

local normalTexture = {
    PATH_CCS_RES .. "gy_lianhuabiaodi.png",
    PATH_CCS_RES .. "gy_zhuanhuabiaodi.png",
    PATH_CCS_RES .. "gy_chognzhibiaodi.png",
};
local clickTexture = {
    PATH_CCS_RES .. "gy_lianhuabiao.png",
    PATH_CCS_RES .. "gy_zhuanhuabiao.png",
    PATH_CCS_RES .. "gy_chongzhibiao.png",
};


local m_tabImgName = {"chemical_img", "transform_img", "reset_img"};
local m_curIndex = nil;
local m_data = nil;
local icon_blank = PATH_CCS_RES .. "c_zhuangbeikuang.png";


--灵魂属性公式
local m_soulActivateFormula = {
    {2,3,4,5},--头盔对应的四级灵魂激活需要物品
    {3,4,5,1},--铠甲
    {4,5,1,2},--裤子
    {5,1,2,3},--鞋子
    {1,2,3,4} --手套
};


local equipTypeid = {
    helmet = 1,
    armour = 2,
    trousers = 3,
    shoe = 4,
    glove = 5
};

--灵魂属性百分比
local m_soulPropertyPercent = {2, 4, 6, 8};

local m_iconPath = {
    PATH_RES_IMG_EQUIPS .. "helmet.png",
    PATH_RES_IMG_EQUIPS .. "armour.png",
    PATH_RES_IMG_EQUIPS .. "trousers.png",
    PATH_RES_IMG_EQUIPS .. "shoes.png",
    PATH_RES_IMG_EQUIPS .. "gloves.png",
};

local TAG_RESET_BOUND_BASE = 245;

local function getWuxingProImg( wuxingId )
    return GoodsManager.getWuxingProImg(wuxingId);
end


--按部位分 得到装备类型id（头盔、铠甲）
local function getEquipTypeId( equipid )
    local typeName = GoodsManager.getGoodsTypeById(equipid);
    return equipTypeid[typeName];
end

local function canSoulChemical(equipid)
    local typeName = GoodsManager.getGoodsTypeById(equipid);
    return (typeName == "helmet" or 
            typeName == "armour" or 
            typeName == "trousers" or 
            typeName == "shoe" or 
            typeName == "glove"  );
end

local function getIconPath( lv )
    return m_iconPath[lv];
end

--根据五行id得到五行名称
local function getWuxingName( id )
    return GoodsManager.getWuxingName(id);
end

--通过公式得到某一装备某一灵魂等级的激活装备id
local function getSoulActivateEquipsNeed( equipTypeId, grade )
    return m_soulActivateFormula[equipTypeId][grade];
end

--根据装备灵魂等级得到这一级别灵魂属性的百分比
local function getSoulPropertyPercent( soulGrade )
    return m_soulPropertyPercent[soulGrade];
end

local function transSoulData( data )
    local wuxingProsStr = data.wuxingPros;
    local soulProsStr = data.soulPros;
    local soulValsStr = data.soulVals;

    local wuxingPros = Util.strToNumber(Util.Split(wuxingProsStr, ";"));
    local soulPros = Util.strToNumber(Util.Split(soulProsStr, ";"));
    local soulVals = Util.strToNumber(Util.Split(soulValsStr, ";"));

    return wuxingPros, soulPros, soulVals;
end


-----------------信息显示处理-----------------

--1炼化  2转化  3重置  功能按钮设置是否可点击
local function setFuncBtnEnable( index, enable )
    if(index == 1) then
        --炼化
        local btn = tolua.cast(m_chemicalLayout:getWidgetByName("funcBtn"), "Button");
        btn:setTouchEnabled(enable);
        if(enable) then
            btn:loadTextureNormal(IMAGE_PATH.BUTTON_CHEMICAL_1);
        else
            btn:loadTextureNormal(IMAGE_PATH.BUTTON_CHEMICAL_0);
        end
    elseif(index == 2) then
        --转化
        local btn = tolua.cast(m_transLayout:getWidgetByName("funcBtn"), "Button");
        btn:setTouchEnabled(enable);
        if(enable) then
            btn:loadTextureNormal(IMAGE_PATH.BUTTON_TRANS_1);
        else
            btn:loadTextureNormal(IMAGE_PATH.BUTTON_TRANS_0);
        end
    elseif(index == 3) then
        --重置
        local btn = tolua.cast(m_resetLayout:getWidgetByName("funcBtn"), "Button");
        btn:setTouchEnabled(enable);
        if(enable) then
            btn:loadTextureNormal(IMAGE_PATH.BUTTON_RESET_1);
        else
            btn:loadTextureNormal(IMAGE_PATH.BUTTON_RESET_0);
        end
    end
end

--炼化界面
local function showChemicalInfo()
    if(m_data ~= nil) then
        local soulGrade = nil;
        local curEquipTypeId = nil;
        soulGrade = m_data.soulLV; -- 0, 1, 2, 3, 4
        curEquipTypeId = getEquipTypeId(m_data.id);
        local wuxingPros, soulPros, soulVals = transSoulData(m_data);

        m_chemicalLayout:getWidgetByName("info_panel"):setEnabled(true);

        local img = tolua.cast(m_chemicalLayout:getWidgetByName("icon_img"), "ImageView");
        img:setEnabled(true);
        img:loadTexture(GoodsManager.getIconPathById(m_data.id));

        local bgIcon = tolua.cast(m_chemicalLayout:getWidgetByName("bgIcon_img"), "ImageView");
        bgIcon:setEnabled(true);
        bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(m_data.id)));

        local bgImg = tolua.cast(m_chemicalLayout:getWidgetByName("bg_img"), "ImageView");
        bgImg:setEnabled(false);

        for i = 1,4 do
            local panel = tolua.cast(m_chemicalLayout:getWidgetByName("soul" .. i .. "_panel"), "Layout");
            if(soulGrade > 0 and i <= soulGrade) then
                panel:setEnabled(true);
                local img = tolua.cast(m_chemicalLayout:getWidgetByName("soulIcon_img_" .. i), "ImageView");
                local wuxingNeedLabel = tolua.cast(m_chemicalLayout:getWidgetByName("condition_label_" .. i), "Label");
                local soulProLabel = tolua.cast(m_chemicalLayout:getWidgetByName("soul_label_" .. i), "Label");
                -- local soulProPerLabel = tolua.cast(m_chemicalLayout:getWidgetByName("percent_label_" .. i), "Label");

                local equipNeedId = getSoulActivateEquipsNeed(curEquipTypeId, i);
                img:loadTexture(getIconPath(equipNeedId));
                wuxingNeedLabel:setText(getWuxingName(wuxingPros[i]));
                soulProLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. soulPros[i], "name"));
                -- local percent = DataTableManager.getValue("soulCharactorAdd", "id_" .. m_data.soulCharacter, "per");
                -- soulProPerLabel:setText("+" .. percent .. "%");
            else
                panel:setEnabled(false);
            end
        end

        --消耗
        local priceLabel = tolua.cast(m_chemicalLayout:getWidgetByName("price_label"), "Label");
        if(soulGrade < 4) then
            local price = EquipmentCalc.calcSoulChemialUse(soulGrade + 1);
            local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold");
            priceLabel:setText(price);
            setFuncBtnEnable(1, isMoneyEnough);
        else
            priceLabel:setText(0);
            setFuncBtnEnable(1, false);
        end
    end
end


local function setTransBtnEnabled(selectCount)
    local soulGrade = m_data.soulLV;
    if(soulGrade > 0) then
        --金币
        local price = EquipmentCalc.calcSoulTranMoneyUse();
        local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold")
        --元宝
        local count = 0;
        if(selectCount == nil) then
            for i=1,4 do
                local lock_checkBox = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. i), "CheckBox");
                local isBund = lock_checkBox:getSelectedState();
                if(isBund) then
                    count = count + 1;
                end
            end
        else
            count = selectCount;
        end
        local tokenPrice = EquipmentCalc.calcSoulTransTokenUse(count);
        local isTokenEnough = tokenPrice <= UserInfoManager.getRoleInfo("diamond");

        local isEnable = (isMoneyEnough and isTokenEnough);
        setFuncBtnEnable(2, isEnable);
    else
        setFuncBtnEnable(2, false);
    end
end

--转换绑定
local function transBoundOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        local d = {0, 0, 0, 0};
        local count = 0;
        for i=1,4 do
            local lock_checkBox = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. i), "CheckBox");
            local isBund = lock_checkBox:getSelectedState();
            if(isBund) then
                count = count + 1;
                d[i] = 1;
            end
        end

        local index = sender:getTag() - TAG_RESET_BOUND_BASE;
        local isChoooseBundCB = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. index), "CheckBox");
        if(isChoooseBundCB:getSelectedState()) then
            d[index] = 0;
            count = count - 1;
        else
            d[index] = 1;
            count = count + 1;
        end

        local haveLock = (count > 0);
        -- local tokenPanel = tolua.cast(m_transLayout:getWidgetByName("token_panel"), "Layout");
        -- tokenPanel:setEnabled(haveLock);
        if(haveLock) then
            local tokenLabel = tolua.cast(m_transLayout:getWidgetByName("token_label"), "Label");
            local tokenPrice = EquipmentCalc.calcSoulTransTokenUse(count);
            tokenLabel:setText(tokenPrice);
        end

        setTransBtnEnabled(count);
    end
end

--转换界面
local function showTransformInfo()
    local panel = nil;
    local soulGrade = m_data.soulLV;
    local curEquipTypeId = getEquipTypeId(m_data.id);
    local wuxingPros, soulPros, soulVals = transSoulData(m_data);

    m_transLayout:getWidgetByName("info_panel"):setEnabled(true);

    local img = tolua.cast(m_transLayout:getWidgetByName("icon_img"), "ImageView");
    img:setEnabled(true);
    img:loadTexture(GoodsManager.getIconPathById(m_data.id));

    local bgIcon = tolua.cast(m_transLayout:getWidgetByName("bgIcon_img"), "ImageView");
    bgIcon:setEnabled(true);
    bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(m_data.id)));

    local bgImg = tolua.cast(m_transLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(false);

    local wuxingPro = m_data.wuxingPro;
    local shuxing_img = tolua.cast(m_transLayout:getWidgetByName("shuxing_img"), "ImageView");
    if(wuxingPro > 0) then
        shuxing_img:setEnabled(true);
        shuxing_img:loadTexture(getWuxingProImg(wuxingPro));
    else
        shuxing_img:setEnabled(false);
    end

    for i = 1,4 do
        local panel = tolua.cast(m_transLayout:getWidgetByName("soul" .. i .. "_panel"), "Layout");
        if(soulGrade > 0 and i <= soulGrade) then
            panel:setEnabled(true);
            -- local img = tolua.cast(m_transLayout:getWidgetByName("soulIcon_img_" .. i), "ImageView");
            -- local imgWuxingLabel = tolua.cast(m_transLayout:getWidgetByName("wuxingPro_label_" .. i), "Label");
            local wuxingNeedLabel = tolua.cast(m_transLayout:getWidgetByName("condition_label_" .. i), "Label");
            -- local soulProLabel = tolua.cast(m_transLayout:getWidgetByName("soulProperty_label_" .. i), "Label");
            -- local soulProPerLabel = tolua.cast(m_transLayout:getWidgetByName("percent_label_" .. i), "Label");

            -- local equipNeedId = getSoulActivateEquipsNeed(curEquipTypeId, i);
            -- img:loadTexture(getIconPath(equipNeedId));
            -- imgWuxingLabel:setText(getWuxingName(wuxingPros[i]))
            wuxingNeedLabel:setText(getWuxingName(wuxingPros[i]));
            -- soulProLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. soulPros[i], "name") .. "+");
            -- soulProPerLabel:setText(soulVals[i]);
        else
            panel:setEnabled(false);
        end
        -- local lock_checkBox = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. i), "CheckBox");
        -- lock_checkBox:setSelectedState(false);
    end

    local transBtn = tolua.cast(m_transLayout:getWidgetByName("funcBtn"), "Button");
    transBtn:setTouchEnabled(true);

    --消耗
    if(soulGrade > 0) then
        local priceLabel = tolua.cast(m_transLayout:getWidgetByName("price_label"), "Label");
        local price = EquipmentCalc.calcSoulTranMoneyUse();
        priceLabel:setText(price);
    end

    setTransBtnEnabled();

    -- m_transLayout:getWidgetByName("token_panel"):setEnabled(false);
end

--重置界面
local function showResetInfo()
    if(m_data ~= nil) then
        m_resetLayout:getWidgetByName("info_panel"):setEnabled(true);

        local img = tolua.cast(m_resetLayout:getWidgetByName("icon_img"), "ImageView");
        img:setEnabled(true);
        img:loadTexture(GoodsManager.getIconPathById(m_data.id));

        local bgIcon = tolua.cast(m_resetLayout:getWidgetByName("bgIcon_img"), "ImageView");
        bgIcon:setEnabled(true);
        bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(m_data.id)));

        local bgImg = tolua.cast(m_resetLayout:getWidgetByName("bg_img"), "ImageView");
        bgImg:setEnabled(false);

        local charctorLabel = tolua.cast(m_resetLayout:getWidgetByName("soulCharctor_label"), "Label");
        local soulProLabel = tolua.cast(m_resetLayout:getWidgetByName("soul_label"), "Label"); 
        local priceLabel = tolua.cast(m_resetLayout:getWidgetByName("price_label"), "Label");
        local soulGrade = m_data.soulLV;
        charctorLabel:setText("");
        soulProLabel:setText("");
        if(soulGrade > 0) then
            if(m_data.soulCharacter > 0) then
                charctorLabel:setText(GoodsManager.getColorName(m_data.soulCharacter));
            end
            if(m_data.soulPro > 0) then
                soulProLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. m_data.soulPro, "name"));
            end
            --消费
            local price = EquipmentCalc.calcSoulResetUse();
            priceLabel:setText(price);
        else
            priceLabel:setText(0);
        end

        local price = EquipmentCalc.calcSoulResetUse();
        local isMoneyEnough = price <= UserInfoManager.getRoleInfo("gold");
        setFuncBtnEnable(3, (isMoneyEnough and soulGrade > 0));
    end
end

local function showInfo()
    if(m_data ~= nil) then
        showChemicalInfo();
        showTransformInfo();
        showResetInfo();
    end
end



local function clearChemicalInfo()
    local img = tolua.cast(m_chemicalLayout:getWidgetByName("icon_img"), "ImageView");
    img:setEnabled(false);

    local bgIcon = tolua.cast(m_chemicalLayout:getWidgetByName("bgIcon_img"), "ImageView");
    bgIcon:setEnabled(false);

    local bgImg = tolua.cast(m_chemicalLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(true);

    m_chemicalLayout:getWidgetByName("icon_img"):setEnabled(false);

    m_chemicalLayout:getWidgetByName("info_panel"):setEnabled(false);

    local priceLabel = tolua.cast(m_chemicalLayout:getWidgetByName("price_label"), "Label");
    priceLabel:setText(0);

    setFuncBtnEnable(1, false);
end

local function clearTransformInfo()
    local img = tolua.cast(m_transLayout:getWidgetByName("icon_img"), "ImageView");
    img:setEnabled(false);

    local bgIcon = tolua.cast(m_transLayout:getWidgetByName("bgIcon_img"), "ImageView");
    bgIcon:setEnabled(false);

    local bgImg = tolua.cast(m_transLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(true);

    m_transLayout:getWidgetByName("icon_img"):setEnabled(false);

    m_transLayout:getWidgetByName("info_panel"):setEnabled(false);

    m_transLayout:getWidgetByName("shuxing_img"):setEnabled(false);

    tolua.cast(m_transLayout:getWidgetByName("price_label"), "Label"):setText(0);
    tolua.cast(m_transLayout:getWidgetByName("token_label"), "Label"):setText(0);
    
    for i = 1,4 do
        local lock_checkBox = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. i), "CheckBox");
        lock_checkBox:setSelectedState(false);
    end

    -- m_transLayout:getWidgetByName("token_panel"):setEnabled(false);

    setFuncBtnEnable(2, false);
end

local function clearResetInfo()
    local img = tolua.cast(m_resetLayout:getWidgetByName("icon_img"), "ImageView");
    img:setEnabled(false);
    
    local bgIcon = tolua.cast(m_resetLayout:getWidgetByName("bgIcon_img"), "ImageView");
    bgIcon:setEnabled(false);

    local bgImg = tolua.cast(m_resetLayout:getWidgetByName("bg_img"), "ImageView");
    bgImg:setEnabled(true);
        
    m_resetLayout:getWidgetByName("icon_img"):setEnabled(false);

    m_resetLayout:getWidgetByName("info_panel"):setEnabled(false);

    local priceLabel = tolua.cast(m_resetLayout:getWidgetByName("price_label"), "Label");
    priceLabel:setText(0);

    setFuncBtnEnable(3, false);
end

local function clearInfo()
    -- if(m_curTag == CHEMI_TAG) then
    --     clearChemicalInfo();
    -- elseif(m_curTag == TRANS_TAG) then
    --     clearTransformInfo();
    -- elseif(m_curTag == RESET_TAG) then
    --     clearResetInfo();
    -- end
    clearChemicalInfo();
    clearTransformInfo();
    clearResetInfo();
end


function goodsOnClick(index, tag)
    if(m_curIndex ~= index) then
        m_curIndex = index;
        local data = UserInfoManager.getGoodsInfo(m_curTag2, m_curIndex)[m_curIndex];
        if(GoodsManager.isEquip(data.id)) then
            if(canSoulChemical(data.id)) then --是头盔、铠甲、裤子、鞋子、手套
                m_data = data;
                clearTransformInfo();
                showPanel();
                showInfo();
            elseif(GoodsManager.isWeapon(data.id)) then
                Util.showOperateResultPrompt("武器不可进行灵魂炼化");
            else
                local typeName = GoodsManager.getTypeById(data.id);
                Util.showOperateResultPrompt(typeName .. "不可进行灵魂炼化");
            end
        end
    else
        m_data = nil;
    end
end

--点击人物面板装备回调
function figureIconOnClick( typeName )
    if(m_figureTypeName ~= typeName) then
        m_figureTypeName = typeName;
        local data = UserInfoManager.getRoleAllInfo()[m_figureTypeName];
        if(GoodsManager.isEquip(data.id)) then
            if(canSoulChemical(data.id)) then
                m_data = data;
                clearTransformInfo();
                showPanel();
                showInfo();
            elseif(GoodsManager.isWeapon(data.id)) then
                Util.showOperateResultPrompt("武器不可进行灵魂炼化");
            else
                local typeName = GoodsManager.getTypeById(data.id);
                Util.showOperateResultPrompt(typeName .. "不可进行灵魂炼化");
            end
        end
    else
        m_data = nil;
    end
end

-----------------功能处理-----------------

local OPE_SOUL_CHEMICAL = 1;
local OPE_SOUL_RESET    = 2;
local OPE_SOUL_TRANS    = 3;

local OPE_RESULT_SOUL_CHEMICAL_OK = 1;
local OPE_RESULT_SOUL_CHEMICAL_FAIL = 2;

local OPE_RESULT_SOUL_RESET_OK = 6;
local OPE_RESULT_SOUL_RESET_FAIL = 7;

local OPE_RESULT_SOUL_TRANS_OK = 11;
local OPE_RESULT_SOUL_TRANS_FAIL = 12;
 
local function showResult(operateId, resultId) 
    local text = "";
    if(resultId == OPE_RESULT_EQUIP_MONEY_NOT_ENOUGH) then
        text = TEXT.noMoney;
    elseif(resultId == OPE_RESULT_EQUIP_TOKEN_NOT_ENOUGH) then
        text = TEXT.noToken;
    else
        if(operateId == OPE_SOUL_CHEMICAL) then
            if(resultId == OPE_RESULT_SOUL_CHEMICAL_OK) then
                text = "炼化成功";
            elseif(resultId == OPE_RESULT_SOUL_CHEMICAL_FAIL) then
                text = "炼化失败";
            end
        elseif(operateId == OPE_SOUL_RESET) then
            if(resultId == OPE_RESULT_SOUL_RESET_OK) then
                text = "重置成功";
            elseif(resultId == OPE_RESULT_SOUL_RESET_FAIL) then
                text = "重置失败";
            end
        elseif(operateId == OPE_SOUL_TRANS) then
            if(resultId == OPE_RESULT_SOUL_TRANS_OK) then
                text = "转换成功";
            elseif(resultId == OPE_RESULT_SOUL_TRANS_FAIL) then
                text = "转换失败";
            end
        end
    end
    Util.showOperateResultPrompt(text);
end


local function onReceiveOperateResponse( messageType, messageData )
    local operateId = messageData.operateId;
    local resultId = messageData.resultId;

    ProgressRadial.close();

    if(m_curTag1 == TAG_FIGURE) then
        m_data = UserInfoManager.getRoleAllInfo()[m_figureTypeName];
        -- Figure.refreshDisplay();
        -- FigureProperty.refreshDisplay();
    else
        m_data = UserInfoManager.getGoodsInfo(m_curTag2, m_curIndex)[m_curIndex];
        -- GoodsList.refreshDisplay();
    end

    showInfo();

    showResult();
end

local function getFigureOrBp()
    if(m_curTag1 == TAG_FIGURE) then
        return 1;
    else
        return 2;
    end
end

local function getFigureOrBpIndex()
    if(m_curTag1 == TAG_FIGURE) then
        return Figure.getCurPart();
    else
        return m_curIndex;
    end
end

--炼化
local function chemicalBtnOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        --升级灵魂等级-->若是第一次炼化：随机得到五行属性、灵魂属性
        --  根据灵魂等级：确定激活条件装备、灵魂属性百分比
        --  扣除消耗
        if(m_data) then
            ProgressRadial.open();
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPSOULCHEMICAL, {getFigureOrBp(), getFigureOrBpIndex()});
        end
    end
end

--转换
local function transformBtnOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        if(m_data) then
            local lock = {0,0,0,0};
            for i = 1,4 do
                local lock_checkBox = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. i), "CheckBox");
                local isLock = lock_checkBox:getSelectedState();
                if(isLock) then
                    lock[i] = 1;
                end
            end
            local lockStr = Util.tableToStrBySeparator(lock, ";");
            ProgressRadial.open();
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPSOULTRANS, {getFigureOrBp(), getFigureOrBpIndex(), lockStr});
        end
    end
end

--重置
local function resetBtnOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        if(m_data) then
            ProgressRadial.open();
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPSOULRESET, {getFigureOrBp(), getFigureOrBpIndex()});
        end
    end
end

local function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SOULRESPONSE, onReceiveOperateResponse);
end

local function unregisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SOULRESPONSE, onReceiveOperateResponse);
end


-----------------面板转换显示处理-----------------
local function freshTabBg()
    local img = nil;
    for i = 1,  #m_tabImgName do
    	img = tolua.cast(m_tabLayout:getWidgetByName(m_tabImgName[i]), "ImageView");
    	img:loadTexture(normalTexture[i]);
    end
end

local function changeTabBg()
    local lastTabImg = tolua.cast(m_tabLayout:getWidgetByName(m_tabImgName[m_lastTag - LAYOUT_TAG_BASE]), "ImageView");
    lastTabImg:loadTexture(normalTexture[m_lastTag - LAYOUT_TAG_BASE]);

    local curTabImg = tolua.cast(m_tabLayout:getWidgetByName(m_tabImgName[m_curTag - LAYOUT_TAG_BASE]), "ImageView");
    curTabImg:loadTexture(clickTexture[m_curTag - LAYOUT_TAG_BASE]);
end

local function changeLayout(tag)
    m_rootLayer:removeChild(m_layout[m_curTag - LAYOUT_TAG_BASE], false);
    m_rootLayer:addChild(m_layout[tag - LAYOUT_TAG_BASE], 1);
end

function showPanel()
    if(m_curTag == 0)then
        -- m_curTag = CHEMI_TAG;
        -- m_lastTag = m_curTag;
        
        -- freshTabBg();
        -- changeTabBg();
    end
end

function clearPanel()
    m_rootLayer:removeChild(m_layout[m_curTag - LAYOUT_TAG_BASE], false);
    m_rootLayer:removeChild(m_tabLayout, false);
    m_curTag = 0;
    m_lastTag = m_curTag;
end

--左侧标签
local function tabPageOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		local tag = sender:getTag();
        if(m_curTag ~= tag) then
            changeLayout(tag);
            m_lastTag = m_curTag;
            m_curTag = tag;
            changeTabBg();
        end
	end
end

--点击了右侧上面标签
function onFigureBackpackPageChanged(tag)
    m_curTag1 = tag;
    if(m_curTag1 ~= TAG_FIGURE) then
        m_curTag2 = TAG_EQUIP;
    end

    m_curIndex = 0;
    m_figureTypeName = "";
    m_data = nil;
    -- clearPanel();
    clearInfo();
end

-----------------初始化-----------------

local function bundTabPageBtnListener()
    local img = nil;
    for i = 1,  #m_tabImgName do
    	img = tolua.cast(m_tabLayout:getWidgetByName(m_tabImgName[i]), "ImageView");
	    img:setTag(i + LAYOUT_TAG_BASE);
	    img:addTouchEventListener(tabPageOnClick);
    end
end

local function boundFuncBtnListener()
    --炼化按钮
	m_chemicalLayout:getWidgetByName("funcBtn"):addTouchEventListener(chemicalBtnOnClick);
    --重置按钮
    m_resetLayout:getWidgetByName("funcBtn"):addTouchEventListener(resetBtnOnClick);
    --转换按钮
    m_transLayout:getWidgetByName("funcBtn"):addTouchEventListener(transformBtnOnClick);


    for i=1,4 do
        local lock_checkBox = tolua.cast(m_transLayout:getWidgetByName("suod_checkBox_" .. i), "CheckBox");
        lock_checkBox:setTag(i + TAG_RESET_BOUND_BASE);
        lock_checkBox:addTouchEventListener(transBoundOnClick);
    end
end


function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();

        local m_showLayoutPos = ccp(67, 17);

        --创建三个面板
        --炼化面板
        local chemiTransPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SoulChemical.json");
        m_chemicalLayout = TouchGroup:create();
        m_chemicalLayout:addWidget(chemiTransPanel);
        m_chemicalLayout:retain();
        m_chemicalLayout:setPosition(m_showLayoutPos);
        --转换面板
        local transPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SoulTransform.json");
        m_transLayout = TouchGroup:create();
        m_transLayout:addWidget(transPanel);
        m_transLayout:retain();
        m_transLayout:setPosition(m_showLayoutPos);
        --重置面板
        local resetPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SoulReset.json");
        m_resetLayout = TouchGroup:create();
        m_resetLayout:addWidget(resetPanel);
        m_resetLayout:retain();
        m_resetLayout:setPosition(m_showLayoutPos);

        m_layout = {m_chemicalLayout, m_transLayout, m_resetLayout};

         --创建tab标签页
        local page = tolua.cast(m_chemicalLayout:getWidgetByName("biaoqian_panel"), "Layout");
        local x = page:getPositionX();
        local y = page:getPositionY();
        local pagePos = ccp(m_showLayoutPos.x + x, m_showLayoutPos.y + y);

        local tabPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SoulChemical_Page.json");
        m_tabLayout = TouchGroup:create();
        m_tabLayout:addWidget(tabPanel);
        m_tabLayout:retain();
        m_tabLayout:setPosition(pagePos);

        bundTabPageBtnListener();
        boundFuncBtnListener();
        
        BackpackFigure.create();
    end
end

function open()
    if (not m_isOpen) then
        m_isOpen = true;
        Background.create("SoulChemical");
        Background.open();
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);

        BackpackFigure.open("SoulChemical");

    	m_curTag = CHEMI_TAG;
        m_lastTag = m_curTag;
        m_curTag1 = TAG_FIGURE;
        m_curIndex = 0;
        m_figureTypeName = "";
        clearInfo();

        m_rootLayer:addChild(m_layout[1], 1);
        m_rootLayer:addChild(m_tabLayout, 2);

        registerMessage();
    end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        BackpackFigure.close();
        
        Background.close();
        Background.remove();

        clearPanel();
        ProgressRadial.close();
        unregisterMessage();
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        if(m_rootLayer) then
            m_rootLayer:removeAllChildrenWithCleanup(true);
            m_rootLayer:release();
        end
        m_rootLayer   = nil;
        m_curTag = nil;
        m_lastTag = nil;
        m_tabLayout:release();
        m_tabLayout   = nil;
        m_chemicalLayout:release();
        m_chemicalLayout = nil;
        m_transLayout:release();
        m_transLayout = nil; 
        m_resetLayout:release();
        m_resetLayout = nil;
        m_layout = nil;
        m_curIndex = nil;

        BackpackFigure.remove();
    end
end
