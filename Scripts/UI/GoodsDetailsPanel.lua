 module("GoodsDetailsPanel", package.seeall)

 require "UI/EquipPanel/Soul"
 require "UI/EquipPanel/Suit"
 require "UI/EquipPanel/Addition"

--------------------------------------
--物品详细信息对比面板，创建多个面板
--------------------------------------

local m_rootlayer = nil;
-- local m_rootLayout = {};
local icon_blank = "";
local m_isOpen = false;
local m_isCreate = false;
local m_muchOrLess = TAG_MUCH;

local m_weaponPanel = nil;
local m_equipPanel  = nil;
local m_descPanel    = nil;
local m_coatPiecePanel = nil;
local m_coatPieceSrcItemPanel = nil;
local m_position = nil;

local m_closeCB = nil;

local m_isCoatPiece = 0;

local function closeOnClick( eventType,x,y )
    -- body
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        if(m_closeCB) then
            m_isCoatPiece = 0;
            m_closeCB();
        end
    end
end

-- //      short   id          武器ID    
-- //      byte    character   性格  
-- //      byte    step        品阶  
-- //      byte    star        强化等级
-- //      short   atk         攻击力 
-- //      string  proId       额外属性id号 
-- //      string  proLV       额外属性星级  
-- //      string  proValue    额外属性值   
-- //      byte    skill       技能
-- //      byte    class       大类
local function showWeaponDetail( data, panel )
    local iconImg = tolua.cast(panel:getWidgetByName("icon_img"), "ImageView");
    local bgIconImg = tolua.cast(panel:getWidgetByName("bgIcon_img"), "ImageView");
    local name_label = tolua.cast(panel:getWidgetByName("name_label"), "Label");
    local categoryLabel = tolua.cast(panel:getWidgetByName("category_label"), "Label");
    local charactorLabel = tolua.cast(panel:getWidgetByName("gjz_label"), "Label");
    local atkLabel = tolua.cast(panel:getWidgetByName("zjz_label"), "Label");

    -- 物品的基本信息（icon:图标路径  color:颜色  type：物品类型  name：名称  desc：描述）
    local baseInfo = GoodsManager.getBaseInfo(data.id);
    iconImg:loadTexture(baseInfo.icon);
    name_label:setText(baseInfo.name);
    categoryLabel:setText(baseInfo.type);

    --图标
    bgIconImg:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(data.id)));
    --性格
    charactorLabel:setText(
        DataTableManager.getValue("weapon_character_Data", "id_" .. data.character, "name")
        );
    --攻击力
    atkLabel:setText(data.atk);
    --品阶
    local STREN_MAX = WeaponCalc.getMaxStrenlv(); --最大强化等级
    local star = data.star;
    local starEnablePath1 = PATH_CCS_RES .. "jingling_star_1.png";
    local starDisablePath1 = PATH_CCS_RES .. "jingling_star_2.png";
    for i=1,STREN_MAX do
        local starImg = tolua.cast(panel:getWidgetByName("xing_1_" .. i), "ImageView");
        if(i <= star) then
            starImg:loadTexture(starEnablePath1);
        else
            starImg:loadTexture(starDisablePath1);
        end
    end
    --额外属性
    local PRO_COUNT_MAX = 3;--额外属性数量
    local PRO_LV_MAX = 5; --额外属性最高级别
    local proIds = Util.strToNumber(Util.Split(data.proId, ";"));
    local proLVs = Util.strToNumber(Util.Split(data.proLV, ";"));
    local proValues = Util.strToNumber(Util.Split(data.proValue, ";"));
    local starEnablePath2 = PATH_CCS_RES .. "jingling_star_1.png";
    local starDisablePath2 = PATH_CCS_RES .. "jingling_star_2.png";
    for i=1,PRO_COUNT_MAX do
        local proNameLabel = tolua.cast(panel:getWidgetByName("shuxing" .. i .. "_label"), "Label");
        local proValueLabel = tolua.cast(panel:getWidgetByName("sx" .. i .. "_label"), "Label");
        proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proIds[i], "name"));
        proValueLabel:setText(proValues[i]);
        local prolv = proLVs[i];

        for j=1,PRO_LV_MAX do
            local starImg = tolua.cast(panel:getWidgetByName("shuxing" .. i .. "_xing_" .. j .. "_img"), "ImageView");
            if(j <= prolv) then
                starImg:loadTexture(starEnablePath2);
            else
                starImg:loadTexture(starDisablePath2);
            end
        end
    end

    --精灵技能 未写
end

-- short   index   位置  
-- int id  装备ID    
-- string  name    名称  
-- byte    color   颜色  
-- byte    level   装备等级   
-- byte    strenLV 强化等级    
-- byte    upstepLV    阶级  
-- byte    soulLV  灵魂等级    
-- byte    wuxingPro   五行属性    
-- byte    soulPro 灵魂属性    
-- byte    suitType    套装属性    
-- string  baseProid   基础属性id  
-- string  baseProval  基础属性值   
-- string  additionProval  额外属性值，重置获得的 
-- byte    soulCharacter   灵魂品质    
-- string  wuxingPros  五行品质    
-- string  soulPros    灵魂属性    
-- string  soulVals    灵魂属性值
local function showEquipDetail( data, panel )
    local iconImg = tolua.cast(panel:getWidgetByName("icon_img"), "ImageView");
    local bgIconImg = tolua.cast(panel:getWidgetByName("bgIcon_img"), "ImageView");
    local nameLabel = tolua.cast(panel:getWidgetByName("name_label"), "Label");
    local categoryLabel = tolua.cast(panel:getWidgetByName("category_label"), "Label");
    local levelLabel = tolua.cast(panel:getWidgetByName("LV_label"), "Label");

    -- 物品的基本信息（icon:图标路径  color:颜色  type：物品类型  name：名称  desc：描述  level：装备等级）
    local baseInfo = GoodsManager.getBaseInfo(data.id);
    iconImg:loadTexture(baseInfo.icon);
    bgIconImg:loadTexture(GoodsManager.getColorBgImg(baseInfo.color));
    nameLabel:setText(baseInfo.name);
    categoryLabel:setText(baseInfo.type);
    levelLabel:setText(data.level);

    --强化等级
    if(data.strenLV > 0) then
        panel:getWidgetByName("strenLv_img"):setEnabled(true);
        local strenLv_AtlasLabel = tolua.cast(panel:getWidgetByName("strenLv_AtlasLabel"), "LabelAtlas");
        strenLv_AtlasLabel:setStringValue(data.strenLV);
    else
        panel:getWidgetByName("strenLv_img"):setEnabled(false);
    end

    --品质
    local charactorName_label = tolua.cast(panel:getWidgetByName("charactorName_label"), "Label");
    local charactorName = {
        "普通",   --1
        "优秀",   --2
        "稀有",   --3
        "完美",   --4
        "套装"    --5
    };
    charactorName_label:setText(charactorName[baseInfo.color]);

    --基础属性
    local MAX_BASE_PRO_COUNT    = 2;
    local baseProIds = Util.strToNumber(Util.Split(data.baseProid, ";"));
    local baseProVals = Util.strToNumber(Util.Split(data.baseProval, ";"));
    for i = 1,MAX_BASE_PRO_COUNT do
        local nameLabel = tolua.cast(panel:getWidgetByName("attribute" .. i .. "_label"), "Label");
        local valLabel = tolua.cast(panel:getWidgetByName("attribute" .. i .. "shuzi_label"), "Label");
        nameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. baseProIds[i], "name") .. "：");
        valLabel:setText(baseProVals[i]);
    end

    --附加属性
    local addiProPanel = panel:getWidgetByName("addPro_label");
    local count = EquipmentCalc.getAddtionProCount(data.id);--额外属性条数
    addiProPanel:setEnabled(count > 0);
    if(count > 0) then
        local MAX_ADD_PRO_COUNT = 5;--额外属性最大条数
        local function transAddtionData()
            local idvals = Util.Split(data.additionProval, "|");
            local id = Util.strToNumber(Util.Split(idvals[1], ";"));
            local val = Util.strToNumber(Util.Split(idvals[2], ";"));
            return id, val;
        end
        local ids, vals = transAddtionData();

        for i=1,MAX_ADD_PRO_COUNT do
            local proNameLabel = tolua.cast(panel:getWidgetByName("addPro" .. i .. "_label"), "Label");
            if(i <= count)then
                proNameLabel:setEnabled(true);
                local proValueLabel = tolua.cast(panel:getWidgetByName("addProValue" .. i .. "_label"), "Label");
                if(ids[i] and ids[i] > 0) then
                    proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[i], "name") .. "：");
                    proValueLabel:setColor(EquipmentCalc.getAddtionProColor(data.id, ids[i], vals[i], data.upstepLV));
                    proValueLabel:setText(vals[i]);
                end
            else
                proNameLabel:setEnabled(false);
            end
        end
    end
    --灵魂连接
    local soulProPanel = panel:getWidgetByName("soulPro_label");
    local wuxing_img = tolua.cast(panel:getWidgetByName("wuxing_img"), "ImageView");
    soulProPanel:setEnabled(data.soulLV > 0);
    wuxing_img:setEnabled(data.soulLV > 0);
    if(data.soulLV > 0) then
        local soulProValue_label = tolua.cast(panel:getWidgetByName("soulProValue_label"), "Label");
        local soulCharactor_label = tolua.cast(panel:getWidgetByName("soulCharactor_label"), "Label");
        wuxing_img:setEnabled(true);
        wuxing_img:loadTexture(GoodsManager.getWuxingProImg(data.wuxingPro));
        soulProValue_label:setText(DataTableManager.getValue("PropertyNameData", "id_" .. data.soulPro, "name"));
        local add = tonumber(DataTableManager.getValue("soulCharactorAdd", "id_" .. data.soulCharacterE2 , "per"));
        soulCharactor_label:setText(add*100);
    end
    --套装属性
    print("*********  套装类型：" .. data.suitType);
    local suitPanel = panel:getWidgetByName("suitPro_panel");
    suitPanel:setEnabled(data.suitType > 0);
    if(data.suitType > 0) then
        local count = UserInfoManager.getSameSuitTypeCount(data.suitType); --角色身上与本装备套装类型相同的装备数量
        local function transSuitData(suitType)
            local datas = {};
            local data = DataTableManager.getValue("equipSuitData", "id_" .. suitType, "pro");
            local d = Util.Split(data, "|");
            for i = 1,#d do
                local e = {};
                local es = Util.Split(d[i], ";");
                -- es[1] --同套装类型装备数量
                -- es[2] --激活属性id
                -- es[3] --激活属性值
                e.ids = Util.Split(es[2], ":");
                e.vals = Util.Split(es[3], ":");
                datas[es[1]] = e;
            end
            return datas;
        end
        local suitDatas = transSuitData(data.suitType);
        local countType = {"3", "5", "7"};
        for i=1,#countType do
            local suitData = suitDatas[countType[i]];
            local ids = suitData.ids;
            local vals = suitData.vals;
            local proN = #ids;
            for j=1,proN do
                local proNameLabel = tolua.cast(panel:getWidgetByName("suit" .. countType[i] .. "Name_" .. j .. "_label"), "Label");
                local proSpaceLabel = tolua.cast(panel:getWidgetByName("suit" .. countType[i] .. "Space_" .. j .. "_label"), "Label");
                local proValueLabel = tolua.cast(panel:getWidgetByName("suit" .. countType[i] .. "Value_" .. j .. "_label"), "Label");
                if(count >= tonumber(countType[i])) then
                    proNameLabel:setColor(ccc3(255, 255, 255));
                    proSpaceLabel:setColor(ccc3(255, 255, 255));
                    proValueLabel:setColor(ccc3(255, 255, 255));
                else
                    proNameLabel:setColor(ccc3(128, 128, 128));
                    proSpaceLabel:setColor(ccc3(128, 128, 128));
                    proValueLabel:setColor(ccc3(128, 128, 128));
                end
                proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[j], "name"));
                proValueLabel:setText(vals[j]);
            end
        end
    end
end

local function showDescDetail( data, panel )
    local iconImg = tolua.cast(panel:getWidgetByName("icon_img"), "ImageView");
    local bgIconImg = tolua.cast(panel:getWidgetByName("bgIcon_img"), "ImageView");
    local name_label = tolua.cast(panel:getWidgetByName("name_label"), "Label");
    name_label:setText("");
    local categoryLabel = tolua.cast(panel:getWidgetByName("category_label"), "Label");
    categoryLabel:setText("");
    local descLabel = tolua.cast(panel:getWidgetByName("word_label"), "Label");
    descLabel:setText("");

    -- 物品的基本信息（icon:图标路径  color:颜色  type：物品类型  name：名称  desc：描述）
    local baseInfo = GoodsManager.getBaseInfo(data.id);
    iconImg:loadTexture(baseInfo.icon);
    name_label:setText(baseInfo.name);
    categoryLabel:setText(baseInfo.type);
    descLabel:setText(baseInfo.desc);
    bgIconImg:loadTexture(baseInfo.frameIcon);
end



local function gotoBattlePoint( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        local tag = sender:getTag();
        if(tag > 0) then
            local isInCity = MainCityLogic.isOpen();
            GoodsDetailsPanel.close();
            ProgressRadial.close();
            if(m_isCoatPiece == 1) then
                UIManager.close("BackpackNew");
            elseif(m_isCoatPiece == 2) then
                UIManager.close("Wardrobe");
            end
            if(isInCity) then
                if(tag == 100000) then
                    --神秘商店
                    UIManager.open("Shop", {typeid = SHOP_MYSTERY});
                elseif(tag == 200000) then
                    --许愿
                    UIManager.open("WishMain");
                else
                    --关卡开启
                    print("关卡号 = " .. tag);
                    local function openSelect()
                        SelectLevel.openAppointLevel(tag);
                    end
                    MainCityLogic.removeMainCity();
                    WorldMap.create(openSelect);
                end
            else
                 if(tag == 100000) then
                    --神秘商店
                    local function openMysteryShop()
                        UIManager.open("Shop", {typeid = SHOP_MYSTERY});
                    end
                    WorldMap.remove();
                    GameManager.enterMainCityOther(1, openMysteryShop);
                elseif(tag == 200000) then
                    --许愿
                     local function openWishUI()
                        UIManager.open("WishMain");
                    end
                    WorldMap.remove();
                    GameManager.enterMainCityOther(1, openWishUI);
                else
                    --关卡开启
                    SelectLevel.openAppointLevel(tag);
                end
            end
            
        else
            --关卡未开启
            Util.showOperateResultPrompt("关卡未开启");
        end
    end
end

local function showCoatPieceDetail( data, panel )
    --基本信息
    local iconImg = tolua.cast(panel:getWidgetByName("icon_img"), "ImageView");
    local bgIconImg = tolua.cast(panel:getWidgetByName("bgIcon_img"), "ImageView");
    local nameLabel = tolua.cast(panel:getWidgetByName("name_label"), "Label");
    local descLabel = tolua.cast(panel:getWidgetByName("desc_label"), "Label");
    local countLabel = tolua.cast(panel:getWidgetByName("count_label"), "Label");
    local baseInfo = GoodsManager.getBaseInfo(data.id);
    iconImg:loadTexture(baseInfo.icon);
    bgIconImg:loadTexture(baseInfo.frameIcon);
    nameLabel:setText(baseInfo.name);
    descLabel:setText(baseInfo.desc);
    countLabel:setText(UserInfoManager.getGoodsCount(data.id));

    --获得途径
    local list = tolua.cast(panel:getWidgetByName("list_listView"), "ListView");
    local areaStr = DataTableManager.getValue("coatPieceData", "id_" .. data.id, "get_area"); --"1;2"
    local pointStr = DataTableManager.getValue("coatPieceData", "id_" .. data.id, "get_point"); --"2;3|5;8"
    local pointStr2 = DataTableManager.getValue("coatPieceData", "id_" .. data.id, "get_point2");--区域小号
    local areas = Util.strToNumber(Util.Split(areaStr, ";"));
    local points = Util.Split(pointStr, "|");
    local points2 = Util.Split(pointStr, "|");
    for i=1,#areas do
        local areaid = areas[i];
        local pointStritem = Util.strToNumber(Util.Split(points[i], ";"));
        local pointStritem2 = Util.strToNumber(Util.Split(points2[i], ";"));
        for j=1,#pointStritem do
            local pointid = pointStritem[j];
            local item = m_coatPieceSrcItemPanel:clone();
            local desc = tolua.cast(item:getChildByName("desc_label"), "Label");
            local flagImg = tolua.cast(item:getChildByName("flag_img"), "ImageView");
            local pointid2 = pointStritem2[j];
            local pointName = DataBaseManager.getValue("WorldMapArea", "id_" .. areaid, "name");
            desc:setText("前往" .. pointName .. "-" .. pointid2);
            local isOpen = WorldManager.isUnLock(pointid);
            -- isOpen = true;
            if(isOpen) then
                item:setTag(pointid);
                flagImg:loadTexture(PATH_CCS_RES .. "cailiao_tb_zhandou_1.png");
            else
                item:setTag(-pointid);
                flagImg:loadTexture(PATH_CCS_RES .. "cailiao_tb_zhandou_2.png");
            end
            item:addTouchEventListener(gotoBattlePoint);
            list:pushBackCustomItem(item);
        end
    end
    --神秘商店
    local itemShop = m_coatPieceSrcItemPanel:clone();
    local desc = tolua.cast(itemShop:getChildByName("desc_label"), "Label");
    local flagImg = tolua.cast(itemShop:getChildByName("flag_img"), "ImageView");
    itemShop:setTag(100000);
    itemShop:addTouchEventListener(gotoBattlePoint);
    flagImg:loadTexture(PATH_CCS_RES .. "cailiao_tb_zhandou_1.png");
    desc:setText("神秘商店");
    list:pushBackCustomItem(itemShop);
    --许愿
    local itemWish = m_coatPieceSrcItemPanel:clone();
    local desc = tolua.cast(itemWish:getChildByName("desc_label"), "Label");
    local flagImg = tolua.cast(itemWish:getChildByName("flag_img"), "ImageView");
    itemWish:setTag(200000);
    itemWish:addTouchEventListener(gotoBattlePoint);
    flagImg:loadTexture(PATH_CCS_RES .. "cailiao_tb_zhandou_1.png");
    desc:setText("许愿");
    list:pushBackCustomItem(itemWish);

end

--加载面板，根据物品编号，面板位置
function showPanel(data, pos, funParam, isCoatPiece)
    m_isCoatPiece = 0;
    if(pos) then
        m_position = pos;
    end
    local highType = GoodsManager.getGoodsHighName(data.id);
    local layout = TouchGroup:create();
    if(highType == "weapon") then
        --武器
        local panel = m_weaponPanel:clone();
        layout:addWidget(panel);
        showWeaponDetail(data, layout);
    elseif(highType == "equip") then
        --装备
        local panel = m_equipPanel:clone();
        layout:addWidget(panel);
        showEquipDetail(data, layout);
    elseif(highType == "piece") then
        --碎片
        if(isCoatPiece ~= nil) then
            m_isCoatPiece = isCoatPiece;
            -- local panel = m_coatPiecePanel:clone();
            local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "waitaosuipiankuang_1.json");
            layout:addWidget(panel);
            showCoatPieceDetail(data, layout);
        else
            local panel = m_descPanel:clone();
            layout:addWidget(panel);
            showDescDetail(data, layout);
        end
    elseif(highType == "other") then
        --其它物品
        if(GoodsManager.isSpriteEgg(id)) then --是否是精灵蛋
        else
            local panel = m_descPanel:clone();
            layout:addWidget(panel);
            showDescDetail(data, layout);
        end
    elseif(highType == "coat") then
        local panel = m_descPanel:clone();
        layout:addWidget(panel);
        showDescDetail(data, layout);
    end

    if(funParam) then
        local funcBtn = layout:getWidgetByName("func_btn");
        funcBtn:setEnabled(true);
        funcBtn:addTouchEventListener(funParam);
    else
        --没有功能按钮
        local funcBtn = layout:getWidgetByName("func_btn");
        if(funcBtn) then
            funcBtn:setEnabled(false);
        end
    end
    layout:setPosition(m_position);
    m_rootlayer:addChild(layout, 1);



    -- if(funParam) then
    --     FunBtnCount3.open(funParam.name, funParam.cbs, funParam.labels, pos);
    -- end
end


------------------------------------------------------------------
--关闭信息面板
local function closeGoodsInfo()
    GoodsDetailsPanel.close();
    ProgressRadial.close();
end

function showFigureDetails( data, pos )
    if(data) then
        GoodsDetailsPanel.open(closeGoodsInfo);
        GoodsDetailsPanel.showPanel(data, pos);
    end
end
-------------------------------------------------------------------

function getZorder()
    m_rootlayer:getZOrder();
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootlayer = CCLayer:create();
        m_rootlayer:retain();

        -- m_weaponPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "weaponsPanel.json");
        -- m_weaponPanel:retain();

        m_equipPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "equipPanel.json");
        m_equipPanel:retain();

        m_descPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SimpleGoodsPanel.json");
        m_descPanel:retain();

        m_coatPiecePanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "waitaosuipiankuang_1.json");
        m_coatPiecePanel:retain();

        m_coatPieceSrcItemPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "waitaosuipiankuang_1_1.json");
        m_coatPieceSrcItemPanel:retain();
        -- Suit.create();
        -- Soul.create();
        -- Addition.create();
    end
end

function open(closeCB)
    if (not m_isOpen) then
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootlayer, FIVE_ZORDER);

        local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
        m_rootlayer:addChild(bgLayer, 0);
        bgLayer:registerScriptTouchHandler(closeOnClick);
        if(closeCB) then
            m_closeCB = closeCB;
        end
    end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootlayer, false);
        m_rootlayer:removeAllChildrenWithCleanup(true);
        FunBtnCount3.close();
        m_closeCB = nil;
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        if(m_rootlayer) then
            m_rootlayer:removeAllChildrenWithCleanup(true);
            m_rootlayer:release();
            -- m_weaponPanel:release();
            m_equipPanel:release();
            m_descPanel:release();
            m_coatPiecePanel:release();
            m_coatPieceSrcItemPanel:release();
        end
        m_rootlayer = nil;
        m_rootLayout = nil;
        -- Suit.remove();
        -- Soul.remove();
        -- Addition.remove();
    end
end