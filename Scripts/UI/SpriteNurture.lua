module("SpriteNurture", package.seeall)
require "UI/FigureSpriteCoat"
require "UI/HorTabFour"

require "DataMgr/Calculation/WeaponCalc"
require "DataMgr/Calculation/CoatCalc"

------------------------
--   精灵培育室界面
------------------------

local m_rootLayer = nil;
local m_rootLayouts = nil;

local m_weaponStrenLayout = nil;
local m_weaponUpStepLayout = nil;
local m_coatStrenLayout = nil;
local m_coatUpStepLayout = nil;
local m_coatCompositeLayout = nil;

local TAG_STRENGTHEH    = 1;
local TAG_UPSTEP        = 2;
local TAG_COMPOSITE     = 3;

local m_isOpen = false;


local m_curTag1 = nil; --  TAG_FIGURE, TAG_3_WEAP, TAG_2_COAT
local m_curTag2 = nil;
local m_curIndex = 0;

local m_data = nil;
local m_typeName = nil;
local m_curTag = nil;
local TYPE = {
    weapon = "weapon",
    coat = "coat",
    coatPiece = "coatPiece",
};

local function clearLayout()
    m_rootLayer:removeAllChildrenWithCleanup(false);
    HorTabFour.close();
end

local function clearData()
    m_curIndex = 0;
    m_data = nil;
    m_typeName = nil;
    m_curTag = nil;
end

local function changeLayout()
    if(m_curTag) then
        clearLayout();
        if(m_curTag == m_curTag_COMPOSITE) then
            m_rootLayer:addChild(m_rootLayouts[m_curTag]);
        else
            if(m_typeName == nil) then
                m_rootLayer:addChild(m_rootLayouts[m_curTag][TYPE.weapon]);
            else
                m_rootLayer:addChild(m_rootLayouts[m_curTag][m_typeName]);
            end
        end
    end
end


local function showWeaponStrengthDetails()
    if(m_data) then
        print("id = " .. m_data.id);
        local iconPath = GoodsManager.getIconPathById(m_data.id);
        local name = DataTableManager.getValue("weapon_name_Data", "id_" .. m_data.id, "name");
        for i=1,2 do
            local iconImg = tolua.cast(m_weaponStrenLayout:getWidgetByName("icon_img_" .. i), "ImageView");
            local nameLabel = tolua.cast(m_weaponStrenLayout:getWidgetByName("name_label_" .. i), "Label");
            iconImg:loadTexture(iconPath);
            nameLabel:setText(name);
        end

        local atkLabel1 = tolua.cast(m_weaponStrenLayout:getWidgetByName("atk_label_1"), "Label");
        atkLabel1:setText(m_data.atk);
        local proids = Util.strToNumber(Util.Split(m_data.proId, ";"));
        local provals = Util.strToNumber(Util.Split(m_data.proValue, ";"));
        for i=1,3 do
            local proNameLabel = tolua.cast(m_weaponStrenLayout:getWidgetByName("shuxing_label_1_" .. i), "Label");
            local proValueLabel = tolua.cast(m_weaponStrenLayout:getWidgetByName("sx_label_1_" .. i), "Label");
            proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proids[i], "name"));
            proValueLabel:setText(provals[i]);
        end

        if(WeaponCalc.canUpStren(m_data.star)) then
            local panel2 = tolua.cast(m_weaponStrenLayout:getWidgetByName("info2_panel"), "Layout");
            panel2:setEnabled(true);
            local nextData = WeaponCalc.calcWeapon(m_data, m_data.step, m_data.star + 1);

            local atkLabel2 = tolua.cast(m_weaponStrenLayout:getWidgetByName("atk_label_2"), "Label");
            atkLabel2:setText(nextData.atk);

            local addi = nextData.addition;
            for i=1,3 do
                local proNameLabel = tolua.cast(m_weaponStrenLayout:getWidgetByName("shuxing_label_2_" .. i), "Label");
                local proValueLabel = tolua.cast(m_weaponStrenLayout:getWidgetByName("sx_label_2_" .. i), "Label");
                proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proids[i], "name"));
                proValueLabel:setText(addi[i]);
            end
        else
            local panel2 = tolua.cast(m_weaponStrenLayout:getWidgetByName("info2_panel"), "Layout");
            panel2:setEnabled(false);
        end
    end
end

local function showCoatStrengthDetails()
    
    --icon 和 名称
    for i=1,2 do
        local iconImg = tolua.cast(m_coatStrenLayout:getWidgetByName("icon_img_" .. i), "ImageView");
        local nameLabel = tolua.cast(m_coatStrenLayout:getWidgetByName("name_label_" .. i), "Label");
        local lvLabel = tolua.cast(m_coatStrenLayout:getWidgetByName("level_label_" .. i), "Label");

        iconImg:loadTexture(GoodsManager.getIconPathById(m_data.id));
        nameLabel:setText(m_data.name);
        if(m_data.lv == 1) then
            lvLabel:setText("");
        else
            lvLabel:setText("+" .. m_data.lv);
        end
    end

    --属性转换
    local labelName = {"stren", "agility", "endurance"};
    local dataName = {"strenPro", "agilityPro", "endurPro"};
    local pro = {};
    pro.strenPro = Util.strToNumber(Util.Split(m_data.strenPro, ";"));
    pro.agilityPro = Util.strToNumber(Util.Split(m_data.agilityPro, ";"));
    pro.endurPro = Util.strToNumber(Util.Split(m_data.endurPro, ";"));

    --当前属性
    for i=1,#labelName do
        local n = 1;
        local data = pro[dataName[i]];
        for j=1,#data do
            if(data[j] > 0) then
                local valLabel = tolua.cast(m_coatStrenLayout:getWidgetByName(labelName[i] .. "_label_1_" .. n), "Label");
                valLabel:setText(data[j]);
                n = n + 1;
            end
        end
    end

    --下一强化等级
    local infoPanel2 = tolua.cast(m_coatStrenLayout:getWidgetByName("info_panel_2"), "Layout");
    if(CoatCalc.canStren(m_data)) then
        infoPanel2:setEnabled(true);

        local nextData = CoatCalc.calcCoat_nextStrenlv(m_data);
        local pro = {};
        pro.strenPro = nextData.strenPro;
        pro.agilityPro = nextData.agilityPro;
        pro.endurPro = nextData.endurPro;

        for i=1,#labelName do
            local n = 1;
            local data = pro[dataName[i]];
            for j=1,#data do
                if(data[j] > 0) then
                    local valLabel = tolua.cast(m_coatStrenLayout:getWidgetByName(labelName[i] .. "_label_2_" .. n), "Label");
                    valLabel:setText(data[j]);
                    n = n + 1;
                end
            end
        end
    else
        infoPanel2:setEnabled(false);
    end

    --消耗
end

local function showStrengthDetails()
    if(m_typeName == TYPE.weapon) then
        showWeaponStrengthDetails();
    elseif(m_typeName == TYPE.coat) then
        showCoatStrengthDetails();
    end
end

local function showWeaponUpStepDetails()
    if(m_data) then
        local iconPath = GoodsManager.getIconPathById(m_data.id);
        local name = DataTableManager.getValue("weapon_name_Data", "id_" .. m_data.id, "name");
        for i=1,2 do
            local iconImg = tolua.cast(m_weaponUpStepLayout:getWidgetByName("icon_img_" .. i), "ImageView");
            local nameLabel = tolua.cast(m_weaponUpStepLayout:getWidgetByName("name_label_" .. i), "Label");
            iconImg:loadTexture(iconPath);
            nameLabel:setText(name);
        end

        local atkLabel1 = tolua.cast(m_weaponUpStepLayout:getWidgetByName("atk_label_1"), "Label");
        atkLabel1:setText(m_data.atk);
        local proids = Util.strToNumber(Util.Split(m_data.proId, ";"));
        local provals = Util.strToNumber(Util.Split(m_data.proValue, ";"));
        for i=1,3 do
            local proNameLabel = tolua.cast(m_weaponUpStepLayout:getWidgetByName("shuxing_label_1_" .. i), "Label");
            local proValueLabel = tolua.cast(m_weaponUpStepLayout:getWidgetByName("sx_label_1_" .. i), "Label");
            proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proids[i], "name"));
            proValueLabel:setText(provals[i]);
        end

        if(WeaponCalc.canUpStep(m_data.step)) then
            local panel2 = tolua.cast(m_weaponUpStepLayout:getWidgetByName("info2_panel"), "Layout");
            panel2:setEnabled(true);
            local nextData = WeaponCalc.calcWeapon(m_data, m_data.step + 1, 0);

            local atkLabel2 = tolua.cast(m_weaponUpStepLayout:getWidgetByName("atk_label_2"), "Label");
            atkLabel2:setText(nextData.atk);

            local addi = nextData.addition;
            for i=1,3 do
                local proNameLabel = tolua.cast(m_weaponUpStepLayout:getWidgetByName("shuxing_label_2_" .. i), "Label");
                local proValueLabel = tolua.cast(m_weaponUpStepLayout:getWidgetByName("sx_label_2_" .. i), "Label");
                proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proids[i], "name"));
                proValueLabel:setText(addi[i]);
            end
        else
            local panel2 = tolua.cast(m_weaponUpStepLayout:getWidgetByName("info2_panel"), "Layout");
            panel2:setEnabled(false);
        end
    end
end

local function showCoatUpStepDetails()
    --icon 和 名称
    local iconImg = tolua.cast(m_coatUpStepLayout:getWidgetByName("icon_img_1"), "ImageView");
    local nameLabel = tolua.cast(m_coatUpStepLayout:getWidgetByName("name_label_1"), "Label");
    local lvLabel = tolua.cast(m_coatUpStepLayout:getWidgetByName("level_label_1"), "Label");

    iconImg:loadTexture(GoodsManager.getIconPathById(m_data.id));
    nameLabel:setText(m_data.name);
    if(m_data.lv == 1) then
        lvLabel:setText("");
    else
        lvLabel:setText("+" .. m_data.lv);
    end

    --属性转换
    local labelName = {"stren", "agility", "endurance"};
    local dataName = {"strenPro", "agilityPro", "endurPro"};
    local pro = {};
    pro.strenPro = Util.strToNumber(Util.Split(m_data.strenPro, ";"));
    pro.agilityPro = Util.strToNumber(Util.Split(m_data.agilityPro, ";"));
    pro.endurPro = Util.strToNumber(Util.Split(m_data.endurPro, ";"));

    --当前属性
    for i=1,#labelName do
        local n = 1;
        local data = pro[dataName[i]];
        for j=1,#data do
            if(data[j] > 0) then
                local valLabel = tolua.cast(m_coatUpStepLayout:getWidgetByName(labelName[i] .. "_label_1_" .. n), "Label");
                valLabel:setText(data[j]);
                n = n + 1;
            end
        end
    end

    --下一品阶
    local infoPanel2 = tolua.cast(m_coatUpStepLayout:getWidgetByName("info_panel_2"), "Layout");
    if(CoatCalc.canUpStep(m_data)) then
        infoPanel2:setEnabled(true);

        local nextData = CoatCalc.calcCoat_nextSteplv(m_data);

        local iconImg = tolua.cast(m_coatUpStepLayout:getWidgetByName("icon_img_2"), "ImageView");
        local nameLabel = tolua.cast(m_coatUpStepLayout:getWidgetByName("name_label_2"), "Label");
        local lvLabel = tolua.cast(m_coatUpStepLayout:getWidgetByName("level_label_2"), "Label");

        iconImg:loadTexture(GoodsManager.getIconPathById(nextData.id));
        nameLabel:setText(nextData.name);
        if(nextData.lv == 1) then
            lvLabel:setText("");
        else
            lvLabel:setText("+" .. nextData.lv);
        end

        local pro = {};
        pro.strenPro = nextData.strenPro;
        pro.agilityPro = nextData.agilityPro;
        pro.endurPro = nextData.endurPro;

        for i=1,#labelName do
            local n = 1;
            local data = pro[dataName[i]];
            for j=1,#data do
                if(data[j] > 0) then
                    local valLabel = tolua.cast(m_coatUpStepLayout:getWidgetByName(labelName[i] .. "_label_2_" .. n), "Label");
                    valLabel:setText(data[j]);
                    n = n + 1;
                end
            end
        end
    else
        infoPanel2:setEnabled(false);
    end

    --消耗

end

local function showUpStepDetails()
    if(m_typeName == TYPE.weapon) then
        showWeaponUpStepDetails();
    elseif(m_typeName == TYPE.coat) then
        showCoatUpStepDetails();
    end
end

local function showCompositeDetails()
    -- body
end

local function showGoodsDetails()
    showStrengthDetails();
    showUpStepDetails();
    showCompositeDetails();
end

--------------------------------功能处理------------------------------------

local function onReceiveOperateResponse( messageType, messageData )
    local operateId = messageData.operateId;
    local resultId = messageData.resultId;

    ProgressRadial.close();

    GoodsList.refreshDisplay();
    Figure.refreshDisplay();

    if(m_curTag1 == TAG_FIGURE) then
        m_data = UserInfoManager.getRoleAllInfo()[m_figureTypeName];
    else
        m_data = UserInfoManager.getGoodsInfo(m_curTag2, m_curIndex)[m_curIndex];
    end
    showGoodsDetails();
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

local function getWeaponOrCoatId()
    if(m_typeName) then
        if(m_typeName == TYPE.weapon) then
            return 1;
        elseif(m_typeName == TYPE.coat) then
            return 2;
        end
    else
        return 0;
    end
end

local function sendStrenOrUpStepMsg( strenOrUpstep )
    -- byte    标志是强化还是升阶（1强化  2升阶） 
    -- byte    标志是武器还是外套  (1 武器 2 外套)
    -- byte    标志人物装备还是背包中的物品  
    -- short   物品的索引index
    local coatWeapon = getWeaponOrCoatId();
    if(coatWeapon ~= 0) then
        ProgressRadial.open();
        local msg = {strenOrUpstep, coatWeapon, getFigureOrBp(), getFigureOrBpIndex()};
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_SPRITESTRENORUPSTEP, msg);
    else
        print("精灵培育室  既不是武器也不是外套");
    end
end

local function strenOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        print("***** 强化");
        if(m_data) then
            sendStrenOrUpStepMsg(1);
        end
    end
end

local function upstepOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        print("***** 升阶");
        if(m_data) then
            sendStrenOrUpStepMsg(2);
        end
    end
end

local function compositeOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        print("***** 合成");
        if(m_data) then
            ProgressRadial.open();
            local msg = {getFigureOrBpIndex()};
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_SPRITESTRENORUPSTEP, msg);
        end
    end
end

--根据点击的物品，显示对应的标签
local function showLayout( typeName, tag )
    HorTabFour.close();
    HorTabFour.changeAllTexture(false);
    if(typeName == TYPE.coat) then
        m_curTag = tag;
        HorTabFour.setTouchEnabeld(true, true, false, false);
    elseif(typeName == TYPE.weapon) then
        m_curTag = TAG_UPSTEP;
        HorTabFour.setTouchEnabeld(false, true, false, false);
    elseif(typeName == TYPE.coatPiece) then
        m_curTag = TAG_COMPOSITE;
        HorTabFour.setTouchEnabeld(false, false, true, false);
    end

    changeLayout();

    HorTabFour.open("强化", "升阶", "合成");
    HorTabFour.changeTexture(m_curTag, true);
end

--GoodsList 点击物品回调
function goodsOnClick( index, tag )
    print("****** 精灵培育室 物品 tag = " .. tag .. "  ,index = " .. index);
    local isSame = true;
    if(m_curTag1 == TAG_FIGURE) then
        m_curTag2 = tag;
        m_curIndex = index;
        isSame = false;
    elseif(m_curTag2 ~= tag) then
        m_curTag2 = tag;
        m_curIndex = index;
        isSame = false;
    else
        if(m_curIndex ~= index) then
            m_curIndex = index;
            isSame = false;
        end
    end

    if(not isSame) then
        local data = UserInfoManager.getGoodsInfo(m_curTag2, m_curIndex)[m_curIndex];
        local is, typeName = GoodsManager.isWeaponOrCoat(data.id);
        --是武器、外套或者外套碎片
        if(is) then
            m_typeName = typeName;
            m_data = data;

            showLayout(m_typeName, TAG_STRENGTHEH);

            showGoodsDetails();
        else
            clearLayout();
            clearData();
        end
    else
        m_data = nil;
    end
end

--人物icon点击
function figureIconOnClick( typeName )
    print("****** 精灵培育室 人物 typeName = " .. typeName);
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
        local is, typeName = GoodsManager.isWeaponOrCoat(data.id);
        if(is) then
            m_typeName = typeName;
            m_data = data;

            showLayout(m_typeName, TAG_STRENGTHEH);

            showGoodsDetails();
        else
            clearLayout();
            clearData();
        end
    else
        m_data = nil;
    end
end


function onRightTab2Click( tag )
    m_curTag2 = tag;
    clearLayout();
    clearData();
end

function onRightTab1Click( tag )
    m_curTag1 = tag;
    clearLayout();
    clearData();
end

--标签页转换
local function onTabClick( sender )
    local tag = sender:getTag();
    if(m_curTag ~= tag) then
         m_curTag = tag;
        showLayout(m_typeName, m_curTag);
    end
end

local function bundListener()
    local funcBtn = tolua.cast(m_coatStrenLayout:getWidgetByName("funBtn_panel"), "Layout");
    funcBtn:addTouchEventListener(strenOnClick);
    funcBtn = tolua.cast(m_weaponStrenLayout:getWidgetByName("funBtn_panel"), "Layout");
    funcBtn:addTouchEventListener(strenOnClick);

    funcBtn = tolua.cast(m_coatUpStepLayout:getWidgetByName("funBtn_panel"), "Layout");
    funcBtn:addTouchEventListener(upstepOnClick);
    funcBtn = tolua.cast(m_weaponUpStepLayout:getWidgetByName("funBtn_panel"), "Layout");
    funcBtn:addTouchEventListener(upstepOnClick);

    funcBtn = tolua.cast(m_coatCompositeLayout:getWidgetByName("funBtn_panel"), "Layout");
    funcBtn:addTouchEventListener(compositeOnClick);
end

local function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SPRITERESPONSE, onReceiveOperateResponse);
end

local function unregisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SPRITERESPONSE, onReceiveOperateResponse);
end

function create()
	m_rootLayer = CCLayer:create();
	-- m_rootLayer:retain();

    local panelPos = POS_LEFT;

    local weaponStrenPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Weapon_Strengthen.json");
    local weaponUpStepPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Weapon_UpSteps.json");
    local coatStrenPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "coat_Strengthen.json");
    local coatUpStepPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "coat_UpSteps.json");
    local coatCompositePanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "coat_synthetic.json");

    m_weaponStrenLayout = TouchGroup:create();
    m_weaponStrenLayout:addWidget(weaponStrenPanel);
    m_weaponStrenLayout:setPosition(panelPos);
    -- m_weaponStrenLayout:retain();

    m_weaponUpStepLayout = TouchGroup:create();
    m_weaponUpStepLayout:addWidget(weaponUpStepPanel);
    m_weaponUpStepLayout:setPosition(panelPos);
    -- m_weaponUpStepLayout:retain();

    m_coatStrenLayout = TouchGroup:create();
    m_coatStrenLayout:addWidget(coatStrenPanel);
    m_coatStrenLayout:setPosition(panelPos);
    -- m_coatStrenLayout:retain();

    m_coatUpStepLayout = TouchGroup:create();
    m_coatUpStepLayout:addWidget(coatUpStepPanel);
    m_coatUpStepLayout:setPosition(panelPos);
    -- m_coatUpStepLayout:retain();

    m_coatCompositeLayout = TouchGroup:create();
    m_coatCompositeLayout:addWidget(coatCompositePanel);
    m_coatCompositeLayout:setPosition(panelPos);
    -- m_coatCompositeLayout:retain();

    m_rootLayouts = {
        {weapon = m_weaponStrenLayout, coat = m_coatStrenLayout},   --强化
        {weapon = m_weaponUpStepLayout, coat = m_coatUpStepLayout}, --升阶
        m_coatCompositeLayout --合成
    };

    bundListener();
end

function open()
	if (not m_isOpen) then
		m_isOpen = true;
        create();
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);


        local m_tabPos = ccp(180, 515);

        --背景
        Background.create(SpriteNurture.close);
        Background.open();
        --右侧（人物、精灵武器、衣柜）
	    FigureSpriteCoat.open("SpriteNurture");
 		--标签页
 		HorTabFour.create();
 		HorTabFour.setTabTag(TAG_STRENGTHEH, TAG_UPSTEP, TAG_COMPOSITE);
 		HorTabFour.setCallBack(onTabClick);
 		HorTabFour.setPosition(m_tabPos);
 		HorTabFour.setTabEnabled(true, true, true, false);

        m_curTag = TAG_STRENGTHEH;
        m_curIndex = 0;

        m_curTag1 = TAG_FIGURE;
        m_typeName = nil;

        clearLayout();
        registerMessage();
    end
end

function close()
	if (m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

        Background.close();
        Background.remove();

        FigureSpriteCoat.close();

       	HorTabFour.close();
        HorTabFour.remove();

        unregisterMessage();
    end
end

function remove()
    if(m_rootLayer) then
        m_rootLayer:removeAllChildrenWithCleanup(true);
    end
    m_rootLayer = nil;
    m_curIndex = nil;
	m_upStepLayout = nil; 
	m_compositeLayout = nil; 
end

