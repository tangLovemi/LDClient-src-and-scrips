module("Figure", package.seeall)

require "UI/CloseButton"
require "UI/GoodsDetailsPanel"

--人物UI

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_defPos = ccp(153, 21); --默认位置

local m_data = nil;
local TAG_ICON_BASE = 121;
local m_infoPanel_pos_1 = ccp(150, 70);
local m_infoPanel_pos_2 = ccp(586, 70);
local m_delegate = nil;
local m_index = nil;

local m_animaPanel = nil; --动画板
local m_playerAnim = nil;

local m_isSelf = true;

local STATUS_FIGURE     = 1;
local STATUS_PROPERTY   = 2;
local m_status = STATUS_FIGURE;

local m_tishikuang = nil;
local m_curTishi = nil;

--此处编号与人物身上物品位置对应
-- local m_typeName = {
--     "helmet", "armour", "necklace", "ring", "shoe", "trousers", "glove", "coat", "weapon", "fashionCoat"
-- --    头盔      铠甲      项链       戒指    鞋子      裤子       手套    外套     武器         時裝
--         -- 1        2         3          4       5         6          7       8        9            10
-- };
local m_typeName = {
    "helmet",   --头盔 1
    "armour",   --铠甲 2
    "necklace", --项链 3
    "ring",     --戒指 4
    "shoe",     --鞋子 5
    "trousers", --裤子 6
    "glove",    --手套 7
    -- "weapon" 
--
};
    -- 服务端顺序
    -- HELMET((byte)1),  //头盔1
    -- ARMOUR((byte)2),  //铠甲2
    -- RING((byte)3),    //戒指3
    -- NECKLACE((byte)4),//项链4
    -- SHOES((byte)5),   //鞋子5
    -- GLOVES((byte)6),  //手套6
    -- TROUSERS((byte)7),//裤子7
    -- COAT((byte)8),    //外套8
    -- WEAPON((byte)9),  //武器9
function getCurPart(partid)
    local index = m_index;
    if(partid) then
        index = partid;
    end

    if(index == 3) then 
        index = 4; 
        return index;
    end

    if(index == 4) then 
        index = 3; 
        return index;
    end

    if(index == 6) then 
        index = 7; 
        return index;
    end

    if(index == 7) then 
        index = 6; 
        return index;
    end
    return index;
end

function isOpen()
    return m_isOpen;
end

local function setPropertyEnabeld( enable )
    m_rootLayout:getWidgetByName("xiaodi2_img"):setEnabled(enable);
    m_rootLayout:getWidgetByName("xiaodi1_img"):setEnabled(not enable);
end

function getCurWeaponLoadingBar()
    local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("weaponExp_loadingBar"), "LoadingBar");
    return expLoadingBar;
end

----------功能处理---------
local function show(sender,eventType)
    -- local data = UserInfoManager.getRoleInfo(m_typeName[m_index]);
    if eventType == TOUCH_EVENT_TYPE_END then
        print(" 人物   展示");
    end
end

function getFigureFuncParam()
    local param = {};
    -- name, cbs, labels
    param.name = FunBtnCount3.getDelName().Figure; --人物
    local cbs = {};
    local labels = {};
    labels[1] = nil;
    labels[2] = IMAGE_PATH.zhanshi;
    labels[3] = nil;
    cbs[1] = nil;
    cbs[2] = show;
    cbs[3] = nil;
    param.cbs = cbs;
    param.labels = labels;
    return param;
end

function setAllEquipIconsEnabled(enable)
    for i = 1,#m_typeName do
        local icon = tolua.cast(m_rootLayout:getWidgetByName(m_typeName[i] .. "Bg_img"), "ImageView");
        icon:setEnabled(enable);
    end
    refreshEquips();
end

--只显示外套
function setOnlyCoatEnable( enable )
    setAllEquipIconsEnabled(not enable);
    local icon = tolua.cast(m_rootLayout:getWidgetByName("coatBg_img"), "ImageView");
    icon:setEnabled(enable);
    refreshEquips();
end

--转到人物属性界面
local function switchToFigureProperty(sender,eventType)
    if(eventType == TOUCH_EVENT_TYPE_END) then
        if(m_status == STATUS_FIGURE) then
            m_status = STATUS_PROPERTY;
            setPropertyEnabeld(true);
        elseif(m_status == STATUS_PROPERTY) then
            m_status = STATUS_FIGURE;
            setPropertyEnabeld(false);
        end
    end
end

--点击了角色动画
local function animationOnClick( sender,eventType )
     if(eventType == TOUCH_EVENT_TYPE_END) then
        local index = Util.random(2);
        local actionArr = CCArray:create();
        actionArr:addObject(CCString:create("wait_" .. index));
        actionArr:addObject(CCString:create("stand"));
        m_playerAnim:getArmature():getAnimation():playWithArray(actionArr, -1, false);
     end
end

----------------------------------------------------------------------------------------------------

-- function calcNoHurtRate2(value)
--     local lv = m_data["level"];
--     return math.ceil((12*(lv + 12)*value)/(1 - value));
-- end
-- function calcBashRate2(value)
--     local lv = m_data["level"];
--     return math.ceil((12*(lv + 12)*value)/(1 - value));
-- end
-- function calcCritRate2(value)
--     local lv = m_data["level"];
--     return math.ceil((12*(lv + 12)*value)/(1 - value));
-- end
-- function calcDodgeRate2(value)
--     local lv = m_data["level"];
--     return math.ceil((12*(lv + 12)*value)/(0.7 - value));
-- end
-- function calcParryRate2(value)
--     local lv = m_data["level"];
--     return math.ceil((12*(lv + 12)*value)/(1 - value));
-- end
-- function calcCounterRate2(value)
--     local lv = m_data["level"];
--     return math.ceil((12*(lv + 12)*value)/(1 - value));
-- end

function calcNoHurtRate2(value)
    local lv = m_data["level"];
    return math.ceil((180*(lv + 0)*value)/(2.6 - value));
end
function calcBashRate2(value)
    local lv = m_data["level"];
    return math.ceil((180*(lv + 0)*value)/(2.6 - value));
end
function calcCritRate2(value)
    local lv = m_data["level"];
    return math.ceil((180*(lv + 0)*value)/(2.6 - value));
end
function calcDodgeRate2(value)
    local lv = m_data["level"];
    return math.ceil((180*(lv + 0)*value)/(1.82 - value));
end
function calcParryRate2(value)
    local lv = m_data["level"];
    return math.ceil((180*(lv + 0)*value)/(2.6 - value));
end
function calcCounterRate2(value)
    local lv = m_data["level"];
    return math.ceil((180*(lv + 0)*value)/(2.6 - value));
end

-- v = p*rate*(lv + lv_p)/v_p - rate
-- v:值
-- p:180
-- rate:率
-- lv_p:0
-- v_p:2.6

-- 其他率=(值 乘以 2.6)/(值+(等级+0)*180)   
-- 闪避率=(闪避值 乘以 1.82)/(值+(等级+0)*180)      属性公式要改成这个
-- 速度公式要改成100-(速度/57)


local function calcSpeedRate2(value)
    return 70*(100 - value);
end

local function getBashRate()
    return m_data["combatRate"].bashRate;
end
local function getCritRate()
    return m_data["combatRate"].critRate;
end
local function getParryRate()
    return m_data["combatRate"].parryRate;
end
local function getDodgeRate()
    return m_data["combatRate"].dodgeRate;
end
local function getNoHurtRate()
    return m_data["combatRate"].noHurtRate;
end
local function getCounterRate()
    return m_data["combatRate"].counterRate;
end
local function getSpeedRate()
    local speed = m_data["secondPro"].speed;
    -- 100 － 向上取整（速度 ÷ 70） 且 最小为10  
    local chushoujiange = math.max(10, 100 - math.ceil(speed/70));
    return chushoujiange;
end


local function getDef()
    return m_data["secondPro"].def;
end
local function getBash()
    return m_data["secondPro"].bash;
end
local function getCrit()
    return m_data["secondPro"].crit;
end
local function getCounter()
    return m_data["secondPro"].counterAtk;
end
local function getParry()
    return m_data["secondPro"].parry;
end
local function getDodge()
    return m_data["secondPro"].dodge;
end
local function getSpeed()
    return m_data["secondPro"].speed;
end

----------------------------------------------------------------------------------------------------

local m_rateName = {"免伤率", "重击率", "暴击率", "闪避率", "格挡率", "反击率", "出手间隔"};
local m_rateValueName = {"防御力", "重击值", "暴击值", "闪避值", "格挡值", "反击值", "速度值"};
local m_curValueFunc = {getDef, getBash, getCrit, getDodge, getParry, getCounter, getSpeed};
local m_curRateFunc =  {getNoHurtRate, getBashRate, getCritRate, getDodgeRate, getParryRate, getCounterRate, getSpeedRate};
local m_reCalcValueFunc = {calcNoHurtRate2, calcBashRate2, calcCritRate2, calcDodgeRate2, calcParryRate2, calcCounterRate2, calcSpeedRate2};

local function closeTishiKuangOnClick( sender,eventType )
    if(eventType == TOUCH_EVENT_TYPE_BEGIN) then
        if(m_curTishi) then
            m_curTishi:removeFromParentAndCleanup(true);
            m_curTishi = nil;
        end
    end
end

--属性详细信息
local function showPropertyDetails( sender,eventType )
    if(eventType == TOUCH_EVENT_TYPE_BEGIN) then
        if(m_curTishi) then
            m_curTishi:removeFromParentAndCleanup(true);
            m_curTishi = nil;
        end
        m_curTishi = m_tishikuang:clone();
        local tishiSize = m_curTishi:getContentSize();
        -- m_curTishi:addTouchEventListener(closeTishiKuangOnClick);
        local p = tolua.cast(sender, "Layout");
        local psize = p:getContentSize();
        if(m_delegate and m_delegate == "Transform") then
            m_curTishi:setPosition(ccp(-tishiSize.width, -(tishiSize.height - psize.height)/2));
        else
            m_curTishi:setPosition(ccp(psize.width, -(tishiSize.height)));
        end
        p:addChild(m_curTishi);
        -- noHurtRate   免伤率 
        -- bashRate     重击率 
        -- critRate     暴击率 
        -- dodgeRate    闪避率 
        -- parryRate    格挡率 
        -- counterRate  反击率 
        -- 出手间隔
        local r = m_curTishi:getChildByName("Image_1");
        local bianliang_label = tolua.cast(r:getChildByName("bianliang_label"), "Label");
        local bianliangzhi_label = tolua.cast(r:getChildByName("bianliangzhi_label"), "Label");
        local bianliang1_label = tolua.cast(r:getChildByName("bianliang1_label"), "Label");
        local bianliang2_label = tolua.cast(r:getChildByName("bianliang2_label"), "Label");
        local bianliang3_label = tolua.cast(r:getChildByName("bianliang3_label"), "Label");
        local bianliangzhi_3 = tolua.cast(r:getChildByName("bianliangzhi_3"), "Label");
        local bianliang4_label = tolua.cast(r:getChildByName("bianliang4_label"), "Label");
        local bianliangzhi_4 = tolua.cast(r:getChildByName("bianliangzhi_4"), "Label");

        local tag = sender:getTag();
        bianliang_label:setText(m_rateValueName[tag]);
        bianliang3_label:setText(m_rateValueName[tag]);
        bianliang1_label:setText(m_rateName[tag]);
        bianliang4_label:setText(m_rateName[tag]);

        local value1 = m_curValueFunc[tag]();
        local rate1  = m_curRateFunc[tag]();
        local value2 = 0;
        if(tag == 7) then
            rate2 = math.max(10, rate1 - 1);
            value2 = m_reCalcValueFunc[tag](rate2);
        else
            rate1 = rate1*100;
            rate2 = math.min(100, rate1 + 1);
            value2 = m_reCalcValueFunc[tag](rate2/100);
        end
        bianliangzhi_label:setText(value1);
        bianliang2_label:setText(rate1);
        bianliangzhi_3:setText(value2);
        bianliangzhi_4:setText(rate2);
    elseif(eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL) then
        if(m_curTishi) then
            m_curTishi:removeFromParentAndCleanup(true);
            m_curTishi = nil;
        end
    end
end

--某个装备被点击
local function goodsIconOnClick(sender,eventType)
    if(eventType == TOUCH_EVENT_TYPE_END) then
        local index = tolua.cast(sender, "ImageView"):getTag() - TAG_ICON_BASE;
        local id = m_data[m_typeName[index]].id;
        if(id > 0) then
            m_index = index;
            if(m_isSelf) then
                _G[m_delegate].figureIconOnClick(m_typeName[m_index]);
            else
                FriendsMain.showEquipDetails(m_data[m_typeName[m_index]]);
            end
        end
    end
end

function setDelegate(delegate)
    m_delegate = delegate;
end


function setPosition( pos )
    m_rootLayer:setPosition(pos);
end

function refreshEquips()
    for i = 1,#m_typeName do
        local bgImg = tolua.cast(m_rootLayout:getWidgetByName(m_typeName[i] .. "Bg_img"), "ImageView");
        local icon = tolua.cast(m_rootLayout:getWidgetByName(m_typeName[i] .. "_img"), "ImageView");
        local bgIcon = tolua.cast(m_rootLayout:getWidgetByName(m_typeName[i] .. "BgIcon_img"), "ImageView");
        local id = 0;
        if(m_typeName[i] == "coat") then
            local coat = UserInfoManager.getCoatByType(m_data["coat"].type);
            if(nil ~= coat) then
                id = coat.id;
            end
        else
            id = m_data[m_typeName[i]].id;
        end

        if(id > 0) then
            local path = GoodsManager.getIconPathById(id);
            bgImg:setEnabled(false);
            icon:setEnabled(true);
            bgIcon:setEnabled(true);
            icon:loadTexture(path);
            bgIcon:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(id)));
        else 
            bgImg:setEnabled(true);
            icon:setEnabled(false);
            bgIcon:setEnabled(false);
        end
    end
end


local function refreshProperty()
    ------------------------------------基本属性------------------------------------------------------------------
    --名称
    local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name_label"), "Label");
    nameLabel:setText(m_data["name"]);
    --等级
    local lvLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_dengji"), "LabelAtlas");
    local lv = m_data["level"];
    lvLabel:setStringValue(lv);
    --vip等级
    
    local vipLv = m_data["vipLv"];
    if(vipLv > 0) then
        m_rootLayout:getWidgetByName("Image_vip"):setEnabled(true);
        local vipLvLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_vip"), "LabelAtlas");
        vipLvLabel:setStringValue(vipLv);
    else
        m_rootLayout:getWidgetByName("Image_vip"):setEnabled(false);
    end
    --战斗力
    local fightingLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_zhandouli"), "LabelAtlas");
    local fighting = m_data["fight"];
    fightingLabel:setStringValue(fighting);
    --经验值
    local curExpLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_newexp"), "LabelAtlas");
    local totalExpLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_maxexp"), "LabelAtlas");
    local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("figureExp_loadingBar"), "LoadingBar");
    
    local min = 0;
    if(lv > 1) then
        min = DataTableManager.getValue("expData", "id_" .. (lv - 1), "expmax");
    else
        min = DataTableManager.getValue("expData", "id_" .. lv, "expmin");
    end
    local max = DataTableManager.getValue("expData", "id_" .. lv, "expmax");
    local exp = m_data["exp"];
    local totalExp = max - min;
    if(lv > 1) then
        local lastlvExpMax = DataTableManager.getValue("expData", "id_" .. (lv - 1), "expmax");
        exp = exp - lastlvExpMax;
    end
    exp = math.floor(exp);
    if(exp < 0) then 
        exp = 0;
    end
    
    curExpLabel:setStringValue(exp);
    totalExpLabel:setStringValue(totalExp);
    expLoadingBar:setPercent((exp/totalExp)*100);

    ------------------------------------消耗物品------------------------------------------------------------------
    m_rootLayout:getWidgetByName("Image_huobi"):setEnabled(m_isSelf);
    if(m_isSelf) then
        local moneyLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_jinbi"), "LabelAtlas");
        local tokenLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_zuanshi"), "LabelAtlas");
        local hunyu_label = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_hunyu"), "LabelAtlas");
        local pvp_label = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_PVPdian"), "LabelAtlas");
        local jinjieshi_label = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_jinjieshi"), "LabelAtlas");
        local linghunshi_label = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_linghunshi"), "LabelAtlas");
        moneyLabel:setStringValue(m_data["gold"]);
        tokenLabel:setStringValue(m_data["diamond"]);
        pvp_label:setStringValue(m_data["pvp"]);
        hunyu_label:setStringValue(UserInfoManager.getGoodsCount(GoodsManager.getSoulYuId()));
        jinjieshi_label:setStringValue(UserInfoManager.getGoodsCount(GoodsManager.getUpstepStoneId()));
    end
    ------------------------------------一级属性------------------------------------------------------------------
    local firstData = m_data["firstPro"];
    -- "strength",     --力量
    -- "agility",      --敏捷
    -- "endurance",    --耐力
    local strengthLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_liliang"), "LabelAtlas");
    local agilityLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_minjie"), "LabelAtlas");
    local enduranceLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_naili"), "LabelAtlas");
    strengthLabel:setStringValue(firstData.strength);
    agilityLabel:setStringValue(firstData.agility);
    enduranceLabel:setStringValue(firstData.endurance);
    ------------------------------------二级属性------------------------------------------------------------------
    local spData = m_data["secondPro"];
        -- atk;             //攻击
        -- def;             //防御
        -- hp;              //血量
        -- speed;           //速度
        -- bash;            //重击
        -- crit;            //暴击
        -- counterAtk;      //反击
        -- parry;           //格挡
        -- dodge;           //闪避
    local atkLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_gongjili"), "LabelAtlas");
    local hpLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_shengmingzhi"), "LabelAtlas");
    local defLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_fangyuli"), "LabelAtlas");
    local speedLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_suduzhi"), "LabelAtlas");
    local bashLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_zhongjizhi"), "LabelAtlas");
    local critLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_baojizhi"), "LabelAtlas");
    local counterLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_fanjizhi"), "LabelAtlas");
    local parryLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_gedangzhi"), "LabelAtlas");
    local dodgeLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_shanbizhi"), "LabelAtlas");
    atkLabel:setStringValue(spData.atk);
    defLabel:setStringValue(spData.def);
    hpLabel:setStringValue(spData.hp);
    speedLabel:setStringValue(spData.speed);
    bashLabel:setStringValue(spData.bash);
    critLabel:setStringValue(spData.crit);
    counterLabel:setStringValue(spData.counterAtk);
    parryLabel:setStringValue(spData.parry);
    dodgeLabel:setStringValue(spData.dodge);

    ------------------------------------战斗属性------------------------------------------------------------------
    local crData = m_data["combatRate"];
        -- bashRate     重击率 
        -- critRate     暴击率 
        -- parryRate    格挡率 
        -- dodgeRate    闪避率 
        -- noHurtRate   免伤率 
        -- counterRate  反击率 
    local bashRateLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_zhongjilv"), "LabelAtlas");
    local critRateLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_baojilv"), "LabelAtlas");
    local parryRateLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_gedanglv"), "LabelAtlas");
    local dodgeRateLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_shanbilv"), "LabelAtlas");
    local noHurtRateLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_mianshanglv"), "LabelAtlas");
    local counterRateLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_fanjilv"), "LabelAtlas");
    bashRateLabel:setStringValue(crData.bashRate*100);
    critRateLabel:setStringValue(crData.critRate*100);
    parryRateLabel:setStringValue(crData.parryRate*100);
    dodgeRateLabel:setStringValue(crData.dodgeRate*100);
    noHurtRateLabel:setStringValue(crData.noHurtRate*100);
    counterRateLabel:setStringValue(crData.counterRate*100);
    --出手间隔
    local chushoujiangeLabel = tolua.cast(m_rootLayout:getWidgetByName("AtlasLabel_chushoujiange"), "LabelAtlas");
    chushoujiangeLabel:setStringValue(getSpeedRate());
end

local function initData()
    if(m_data == nil) then
        m_data = UserInfoManager.getRoleAllInfo();
    end
end

--更新控件显示
function refreshDisplay()
    --从m_data中得到需要显示的数据，加载控件
    initData();
    if(m_data) then
        refreshEquips();
        refreshProperty();
    end
end

function onlyRefreshWeaponStar(starlv)

end


----------------------------------角色动画------------------------------------
function createAnimation()
    m_animaPanel:removeAllNodes();
    if(m_isSelf) then
        m_playerAnim = PlayerActor.getFigureActor();
    else
        m_playerAnim = OtherPlayer.createAnimation(m_data.coat, m_data.faceid, m_data.hairid, m_data.hairColor);
    end
    m_animaPanel:addNode(m_playerAnim);
    m_playerAnim:setPosition(ccp(40, -2632 + 40));
end

function removeAnimation()
    m_playerAnim:removeFromParentAndCleanup(false);
    m_playerAnim = nil;
    if(not m_isSelf) then
        OtherPlayer.removeAnimation();
    end
end


local function boundListener()
    m_rootLayout:getWidgetByName("switch_btn"):addTouchEventListener(switchToFigureProperty);

    m_rootLayout:getWidgetByName("animationClick_panel"):addTouchEventListener(animationOnClick);

    for i = 1,#m_typeName do
        local icon = tolua.cast(m_rootLayout:getWidgetByName(m_typeName[i] .. "_img"), "ImageView");
        icon:setTag(i + TAG_ICON_BASE);
        icon:addTouchEventListener(goodsIconOnClick);
    end

    m_rootLayout:getWidgetByName("Panel_fangyuli"):setTag(1);
    m_rootLayout:getWidgetByName("Panel_zhongjizhi"):setTag(2);
    m_rootLayout:getWidgetByName("Panel_baojizhi"):setTag(3);
    m_rootLayout:getWidgetByName("Panel_shanbizhi"):setTag(4);
    m_rootLayout:getWidgetByName("Panel_gedangzhi"):setTag(5);
    m_rootLayout:getWidgetByName("Panel_fanjizhi"):setTag(6);
    m_rootLayout:getWidgetByName("Panel_suduzhi"):setTag(7);

    -- m_rootLayout:getWidgetByName("Panel_gongjili"):addTouchEventListener(showPropertyDetails);
    -- m_rootLayout:getWidgetByName("Panel_shengmingzhi"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_fangyuli"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_zhongjizhi"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_baojizhi"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_shanbizhi"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_gedangzhi"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_fanjizhi"):addTouchEventListener(showPropertyDetails);
    m_rootLayout:getWidgetByName("Panel_suduzhi"):addTouchEventListener(showPropertyDetails);
end


function create()
    if(not m_isCreate) then
        m_isCreate = true;
        
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();

        m_rootLayout = TouchGroup:create();
        m_rootLayer:addChild(m_rootLayout);
        m_rootLayout:retain();

        local rootPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Figure.json");
        m_rootLayout:addWidget(rootPanel);

        m_animaPanel = tolua.cast(m_rootLayout:getWidgetByName("animation_panel"), "Layout");

        m_tishikuang = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "tishikuang_1.json");
        m_tishikuang:retain();

        boundListener();
    end
end

function open(data)
	if(not m_isOpen) then
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);
        m_status = STATUS_FIGURE;
        if(m_data == nil) then
            if(data) then
                m_data = data;
                m_isSelf = false;
            else
                m_isSelf = true;
                m_data = UserInfoManager.getRoleAllInfo();
            end
        end

        setPropertyEnabeld(false);
        refreshDisplay();
        createAnimation();
	end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        m_data = nil;
        m_isSelf = true;
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
        m_rootLayout = nil;
        m_tishikuang:release();
        m_tishikuang = nil;
        m_delegate = nil;
    end
end