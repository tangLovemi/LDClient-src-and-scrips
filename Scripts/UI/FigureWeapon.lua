module("FigureWeapon", package.seeall)

----------------------------------------------
--武器界面
----------------------------------------------
local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isOpen = false;
local m_isCreate = false;
local m_defPos = POS_LEFT; --默认位置

local m_animaPanel = nil;
local m_iconImg = nil;
local m_weaponAnim = nil;
local m_data = nil;
local m_isSelf = true;

local Text = {
    "",
    "达到最高品阶",
    "请强化到最高等级再来",
    "经验不足",
    "材料不足",
};

function getRootLayout()
	return m_rootLayout;
end

function isOpen()
	return m_isOpen;
end

function setPosition( pos )
    m_rootLayer:setPosition(pos);
end

function getCurWeaponLoadingBar()
    local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("weaponExp_loadingBar"), "LoadingBar");
    return expLoadingBar;
end

local function weaponIconOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local data = UserInfoManager.getRoleAllInfo()["weapon"];
	    CloseButton.open(closeGoodsInfo);
	    GoodsDetailsPanel.open();
	    local figureFunParam = Figure.getFigureFuncParam();
	    GoodsDetailsPanel.showPanel(data, BackpackNew.getInfoPanel2Pos(), figureFunParam);
	end
end

local function onReceiveOperateResponse( messageType, messageData )
    local operateId = messageData.operateId;
    local resultId = messageData.resultId;

    ProgressRadial.close();
    Util.showOperateResultPrompt(Text[messageData.resultId]);
    refreshDisplay();
end

local function upStepOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_WEAPONUPSTEP, {});
	end
end

----------------------------------武器动画------------------------------------
function createWeaponAnim()
    local weaponId = UserInfoManager.getRoleInfo("weapon").id;
    weaponId = 150002;
    if(weaponId > 0) then
        print("********************** weaponId = " .. weaponId);
        local name = "Weapon_" .. weaponId;
        local path = PATH_RES_WEAPONS .. name .. ".ExportJson";
        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(path);
        m_weaponAnim = SJActor:createActor(name, -120, 1);
        m_weaponAnim:retain();
        m_weaponAnim:setAction("stand", -1);
        -- CCArmatureDataManager:purge();

	    m_animaPanel:addNode(m_weaponAnim);
	    m_weaponAnim:setPosition(ccp(0, -2632 + 100));
    end
end

function removeWeaponAnim()
    if(m_weaponAnim) then
        m_weaponAnim:removeFromParentAndCleanup(true);
        m_weaponAnim:cleanup();
        m_weaponAnim:release();
        m_weaponAnim = nil;
    end
end

----------------------------------武器动画------------------------------------
local function refreshWeaponStar(starlv)
    local STREN_MAX = WeaponCalc.getMaxStrenlv(); --最大强化等级
    local starEnablePath1 = PATH_CCS_RES .. "jingling_star_1.png";
    local starDisablePath1 = PATH_CCS_RES .. "gy_xingxingdi.png";
    for i=1,STREN_MAX do
        local starImg = tolua.cast(m_rootLayout:getWidgetByName("xing_1_" .. i), "ImageView");
        if(i <= starlv) then
            starImg:loadTexture(starEnablePath1);
        else
            starImg:loadTexture(starDisablePath1);
        end
    end
end

local function refreshBaseInfo()
    local data = m_data["weapon"];
    local nameLable = tolua.cast(m_rootLayout:getWidgetByName("name_label"), "Label");
    local lvLabel = tolua.cast(m_rootLayout:getWidgetByName("grade_label"), "Label");

    local iconImg = tolua.cast(m_rootLayout:getWidgetByName("weaponIcon_img"), "ImageView");
    local bgImg = tolua.cast(m_rootLayout:getWidgetByName("weaponBg_img"), "ImageView");
    local bgIconImg = tolua.cast(m_rootLayout:getWidgetByName("weaponBgIcon_img"), "ImageView");
    
    -- local expCurLabel = tolua.cast(m_rootLayout:getWidgetByName("exp_label"), "Label");
    -- local expTotalLabel = tolua.cast(m_rootLayout:getWidgetByName("totalExp_label"), "Label");
    local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("weaponExp_loadingBar"), "LoadingBar");

    local starEnablePath = PATH_CCS_RES .. "starEnable.png";
    local starDisablePath = PATH_CCS_RES .. "starDisabel.png";
    
    local id = data.id;
    if(id > 0) then
        nameLable:setText(DataTableManager.getValue("weapon_name_Data", "id_" .. id, "name"));

        bgImg:setEnabled(false);
        iconImg:setEnabled(true);
        bgIconImg:setEnabled(true);
        iconImg:loadTexture(GoodsManager.getIconPathById(id));
        bgIconImg:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(id)));
        --经验
        local steplv = data.step;
        local starlv = data.star;
        local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. steplv, "exp");
        local expData = Util.strToNumber(Util.Split(expDataStr, ";"));
        local expTotal = expData[1];
        if(WeaponCalc.canUpStren(starlv)) then
            expTotal = expData[starlv + 1];
            expLoadingBar:setPercent(math.min( 100, (data.exp/expTotal)*100));
        else
            expLoadingBar:setPercent(100);
        end
        -- expTotalLabel:setText(expTotal);
        -- expCurLabel:setText(data.exp);
        lvLabel:setText(starlv);
        --星级
        refreshWeaponStar(starlv);
    else
        bgImg:setEnabled(true);
        iconImg:setEnabled(false);
        bgIconImg:setEnabled(false);
        -- expCurLabel:setText(0);
        -- expTotalLabel:setText(0);
        expLoadingBar:setPercent(0.0);
    end

    --升阶需要
    local upstep_panel = m_rootLayout:getWidgetByName("upstep_panel");
    upstep_panel:setEnabled(m_isSelf);
end

local function refreshProperty()
    local data = m_data["weapon"];
    local id = data.id;
    if(id > 0) then
        --基础属性
        local atkLabel = tolua.cast(m_rootLayout:getWidgetByName("atk_label"), "Label");
        atkLabel:setText(data.atk);
        --额外属性
        local PRO_COUNT_MAX = 3;--额外属性数量
        local proIds = Util.strToNumber(Util.Split(data.proId, ";"));
        local proLVs = Util.strToNumber(Util.Split(data.proLV, ";"));
        local proValues = Util.strToNumber(Util.Split(data.proValue, ";"));
        local starEnablePath = PATH_CCS_RES .. "jingling_star_1.png";
        local starDisablePath = PATH_CCS_RES .. "jingling_star_2.png";
        --星级
        local starlv = data.star;
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

        for i=1,PRO_COUNT_MAX do
            local proNameLabel = tolua.cast(m_rootLayout:getWidgetByName("proName" .. i .. "_label"), "Label");
            local proValueLabel = tolua.cast(m_rootLayout:getWidgetByName("pro" .. i .. "_label"), "Label");
            proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proIds[i], "name"));
            proValueLabel:setText(proValues[i]);
        end
    end
end

local function initData()
    if(m_data == nil) then
        m_data = UserInfoManager.getRoleAllInfo();
    end
end

function refreshDisplay()
    initData();
    if(m_data) then
        refreshBaseInfo();
        refreshProperty();
    end
end

function onlyRefreshWeaponStar(starlv)
    refreshWeaponStar(starlv);
end

local function switchToFigure(sender,eventType)
    if(eventType == TOUCH_EVENT_TYPE_END) then
        -- UIManager.close("FigureWeapon");
        -- UIManager.open("Figure");
        if(m_isSelf) then
            FigureWeapon.close();
            Figure.open();
            BackpackNew.setCurUITag(BACKPACK_FIGURE);
        else
            local data = m_data;
            FigureWeapon.close();
            Figure.open(data);
        end
    end
end

local function switchToFigureProperty(sender,eventType)
    if(eventType == TOUCH_EVENT_TYPE_END) then
        -- UIManager.close("FigureWeapon");
        -- UIManager.open("FigureProperty");
        if(m_isSelf) then
            FigureWeapon.close();
            -- FigureProperty.open();
            BackpackNew.setCurUITag(BACKPACK_FIGURE_PROPERTY);
        else
            local data = m_data;
            FigureWeapon.close();
            -- FigureProperty.open(data);
        end
    end
end


local function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_WEAPONUPSTEPRESPONSE, onReceiveOperateResponse);
end

local function unregisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_WEAPONUPSTEPRESPONSE, onReceiveOperateResponse);
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();

        -- setPosition(m_defPos);

        m_rootLayout = TouchGroup:create();
        m_rootLayer:addChild(m_rootLayout);
        m_rootLayout:retain();

        local rootPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Spirit.json");
        m_rootLayout:addWidget(rootPanel);

        m_animaPanel = tolua.cast(m_rootLayout:getWidgetByName("animation_panel"), "Layout");
        -- local iconImg = tolua.cast(m_rootLayout:getWidgetByName("weapon_img"), "ImageView");
        -- iconImg:addTouchEventListener(weaponIconOnClick);

        local upStepBtn = tolua.cast(m_rootLayout:getWidgetByName("upstep_btn"), "Button");
        upStepBtn:addTouchEventListener(upStepOnClick); 

        --切换监听
        local tab1 = tolua.cast(m_rootLayout:getWidgetByName("switch_img_1"), "ImageView");
        tab1:addTouchEventListener(switchToFigure);

        local tab2 = tolua.cast(m_rootLayout:getWidgetByName("switch_img_2"), "ImageView");
        tab2:addTouchEventListener(switchToFigureProperty);

        registerMessage();
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
        m_rootLayout:release();
        m_rootLayout = nil;
        m_animaPanel = nil;

        unregisterMessage();
    end
end