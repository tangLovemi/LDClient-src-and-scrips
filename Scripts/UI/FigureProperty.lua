module("FigureProperty", package.seeall)

--任务属性

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_data = nil;
local m_isSelf = true;

function setPosition( pos )
    m_rootLayer:setPosition(pos);
end

function getCurWeaponLoadingBar()
    local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("weaponExp_loadingBar"), "LoadingBar");
    return expLoadingBar;
end

--设置武器面板上的蒙板是否显示
function setWeaponMaskEnabled(enable)
    m_rootLayout:getWidgetByName("weaponMask_panel"):setEnabled(enable);
end

local function switchToFigure(sender,eventType)
	if(eventType == TOUCH_EVENT_TYPE_END) then
        -- UIManager.close("FigureProperty");
        -- UIManager.open("Figure");
        if(m_isSelf) then
            FigureProperty.close();
            Figure.open();
            BackpackNew.setCurUITag(BACKPACK_FIGURE);
        else
            local data = m_data;
            FigureProperty.close();
            Figure.open(data);
        end
	end
end

local function switchToFigureWeapon( sender,eventType )
    if(eventType == TOUCH_EVENT_TYPE_END) then
        -- UIManager.close("FigureProperty");
        -- UIManager.open("FigureWeapon");
        if(m_isSelf) then
            FigureProperty.close();
            FigureWeapon.open();
            BackpackNew.setCurUITag(BACKPACK_FIGURE_WEAPON);
        else
            local data = m_data;
            FigureProperty.close();
            FigureWeapon.open(data);
        end
    end
end



--基本信息
local function refreshBaseInfo()
    local data = m_data;
    -- local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("name_label"), "Label");
    -- local lvLabel = tolua.cast(m_rootLayout:getWidgetByName("grade_label"), "Label");
    -- local vipLvLabel = tolua.cast(m_rootLayout:getWidgetByName("VIP_label"), "Label");
    -- local expLabel = tolua.cast(m_rootLayout:getWidgetByName("exp_label"), "Label");
    -- local totalExpLabel = tolua.cast(m_rootLayout:getWidgetByName("totalExp_label"), "Label");
    -- local guildLabel = tolua.cast(m_rootLayout:getWidgetByName("guild_label"), "Label");
    -- local jjcGroupLabel = tolua.cast(m_rootLayout:getWidgetByName("jjc_label"), "Label");

    -- nameLabel:setText(data["name"]);
    -- lvLabel:setText(data["level"]);
    -- vipLvLabel:setText(data["vipLv"]);
    -- expLabel:setText(data["exp"]);
    -- totalExpLabel:setText("**");
    -- guildLabel:setText("**公会");
    -- jjcGroupLabel:setText(JJCUI.getGroupName(data["groupid"]));

    local moneyPanel = m_rootLayout:getWidgetByName("money_panel");
    moneyPanel:setEnabled(m_isSelf);
    if(m_isSelf) then
        local moneyLabel = tolua.cast(m_rootLayout:getWidgetByName("jin_label"), "Label");
        local tokenLabel = tolua.cast(m_rootLayout:getWidgetByName("zuanshi_label"), "Label");
        local yu_label = tolua.cast(m_rootLayout:getWidgetByName("yu_label"), "Label");
        local pvp_label = tolua.cast(m_rootLayout:getWidgetByName("pvp_label"), "Label");
        local jinjie_label = tolua.cast(m_rootLayout:getWidgetByName("jinjie_label"), "Label");
        moneyLabel:setText(m_data["gold"]);
        tokenLabel:setText(m_data["diamond"]);
        pvp_label:setText(m_data["pvp"]);
        yu_label:setText(0);
        jinjie_label:setText(0);
    end
end

--一级属性
local function refreshFirstProeperty()
    local data = m_data["firstPro"];
        -- strength;        //力量
        -- agility;         //敏捷
        -- endurance;       //耐力
    local strengthLabel = tolua.cast(m_rootLayout:getWidgetByName("strength_label"), "Label");
    local agilityLabel = tolua.cast(m_rootLayout:getWidgetByName("agility_label"), "Label");
    local enduranceLabel = tolua.cast(m_rootLayout:getWidgetByName("endurance_label"), "Label");
    strengthLabel:setText(data["strength"]);
    agilityLabel:setText(data["agility"]);
    enduranceLabel:setText(data["endurance"]);
end

--二级属性
local function refreshSecondProperty()
    local data = m_data["secondPro"];
        -- atk;             //攻击
        -- def;             //防御
        -- hp;              //血量
        -- speed;           //速度
        -- bash;            //重击
        -- crit;            //暴击
        -- counterAtk;      //反击
        -- parry;           //格挡
        -- dodge;           //闪避
    local atkLabel = tolua.cast(m_rootLayout:getWidgetByName("atk_label"), "Label");
    local defLabel = tolua.cast(m_rootLayout:getWidgetByName("def_label"), "Label");
    local hpLabel = tolua.cast(m_rootLayout:getWidgetByName("hp_label"), "Label");
    local speedLabel = tolua.cast(m_rootLayout:getWidgetByName("speed_label"), "Label");
    local bashLabel = tolua.cast(m_rootLayout:getWidgetByName("bash_label"), "Label");
    local critLabel = tolua.cast(m_rootLayout:getWidgetByName("crit_label"), "Label");
    local counterLabel = tolua.cast(m_rootLayout:getWidgetByName("counter_label"), "Label");
    local parryLabel = tolua.cast(m_rootLayout:getWidgetByName("parry_label"), "Label");
    local dodgeLabel = tolua.cast(m_rootLayout:getWidgetByName("dodge_label"), "Label");

    atkLabel:setText(data.atk);
    defLabel:setText(data.def);
    hpLabel:setText(data.hp);
    speedLabel:setText(data.speed);
    bashLabel:setText(data.bash);
    critLabel:setText(data.crit);
    counterLabel:setText(data.counterAtk);
    parryLabel:setText(data.parry);
    dodgeLabel:setText(data.dodge);
end

--战斗伤害率
local function refreshCombatRate()
    local data = m_data["combatRate"];
        -- bashRate     重击率 
        -- critRate     暴击率 
        -- parryRate    格挡率 
        -- dodgeRate    闪避率 
        -- noHurtRate   免伤率 
        -- counterRate  反击率 
    local bashRateLabel = tolua.cast(m_rootLayout:getWidgetByName("bashRate_label"), "Label");
    local critRateLabel = tolua.cast(m_rootLayout:getWidgetByName("critRate_label"), "Label");
    local parryRateLabel = tolua.cast(m_rootLayout:getWidgetByName("parryRate_label"), "Label");
    local dodgeRateLabel = tolua.cast(m_rootLayout:getWidgetByName("dodgeRate_label"), "Label");
    local noHurtRateLabel = tolua.cast(m_rootLayout:getWidgetByName("noHurtRate_label"), "Label");
    local counterRateLabel = tolua.cast(m_rootLayout:getWidgetByName("counterRate_label"), "Label");
    bashRateLabel:setText(data.bashRate*100 .. "%");
    critRateLabel:setText(data.critRate*100 .. "%");
    parryRateLabel:setText(data.parryRate*100 .. "%");
    dodgeRateLabel:setText(data.dodgeRate*100 .. "%");
    noHurtRateLabel:setText(data.noHurtRate*100 .. "%");
    counterRateLabel:setText(data.counterRate*100 .. "%");
end

--武器
local function refreshWeaponStar(starlv)
    local STREN_MAX = WeaponCalc.getMaxStrenlv(); --最大强化等级
    local starEnablePath1 = PATH_CCS_RES .. "jingling_star_1.png";
    local starDisablePath1 = PATH_CCS_RES .. "jingling_star_2.png";
    for i=1,STREN_MAX do
        local starImg = tolua.cast(m_rootLayout:getWidgetByName("xing_1_" .. i), "ImageView");
        if(i <= starlv) then
            starImg:loadTexture(starEnablePath1);
        else
            starImg:loadTexture(starDisablePath1);
        end
    end
end

local function refreshWeaponInfo()
    local iconImg = tolua.cast(m_rootLayout:getWidgetByName("weaponIcon_img"), "ImageView");
    local bgImg = tolua.cast(m_rootLayout:getWidgetByName("weaponBg_img"), "ImageView");
    local bgIconImg = tolua.cast(m_rootLayout:getWidgetByName("weaponBgIcon_img"), "ImageView");
    local nameLabel = tolua.cast(m_rootLayout:getWidgetByName("weaponName_label"), "Label");
    -- local charLable = tolua.cast(m_rootLayout:getWidgetByName("weaponCharacter_Label"), "Label");
    local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("weaponExp_loadingBar"), "LoadingBar");

    local data = m_data["weapon"];
    local id = data.id;
    if(id > 0) then
        bgImg:setEnabled(false);
        iconImg:setEnabled(true);
        bgIconImg:setEnabled(true);
        iconImg:loadTexture(GoodsManager.getIconPathById(id));
        bgIconImg:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(id)));
        nameLabel:setText(DataTableManager.getValue("weapon_name_Data", "id_" .. id, "name"));
        -- charLable:setText(DataTableManager.getValue("weapon_character_Data", "id_" .. data.character, "name"));
        
        --星级
        local steplv = data.step;
        local starlv = data.star;
       refreshWeaponStar(starlv);
        --经验条
        local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. steplv, "exp");
        local expData = Util.strToNumber(Util.Split(expDataStr, ";"));
        local expTotal = expData[1];
        if(WeaponCalc.canUpStren(starlv)) then
            expTotal = expData[starlv + 1];
            expLoadingBar:setPercent(math.min( 100, (data.exp/expTotal)*100));
        else
            expLoadingBar:setPercent(100);
        end
    else
        bgImg:setEnabled(true);
        iconImg:setEnabled(false);
        bgIconImg:setEnabled(false);
        nameLabel:setText("");
        -- charLable:setText("");
        expLoadingBar:setPercent(0.0);
    end
end

local function initData()
    if(m_data == nil) then
        m_data = UserInfoManager.getRoleAllInfo();
    end
end

--更新控件显示
function refreshDisplay()
    initData();
    if(m_data) then
        refreshBaseInfo();
        refreshFirstProeperty();
        refreshSecondProperty();
        refreshCombatRate();
        refreshWeaponInfo();
    end
end

function onlyRefreshWeaponStar(starlv)
    refreshWeaponStar(starlv);
end


local function boundTouchListener()
    -- m_rootLayout:getWidgetByName("switch_btn"):addTouchEventListener(switchToFigure);
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        m_rootLayout = TouchGroup:create();
        m_rootLayer:addChild(m_rootLayout);
        m_rootLayout:retain();

        -- local rootPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "FigureProperty.json");
        -- m_rootLayout:addWidget(rootPanel);

        

        boundTouchListener();
    end
end

function open(data)
	if(not m_isOpen) then
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);
        if(m_data == nil) then
            if(data) then
                m_data = data;
                m_isSelf = false;
                -- setWeaponMaskEnabled(false);
            else
                m_data = UserInfoManager.getRoleAllInfo();
            end
        end
        refreshDisplay();
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
    end
end