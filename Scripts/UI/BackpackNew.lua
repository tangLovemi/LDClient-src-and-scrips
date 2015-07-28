module("BackpackNew", package.seeall)

require "UI/HorTabFive"
require "UI/Figure"
require "UI/GoodsList"
require "UI/CloseButton"
require "UI/GoodsDetailsPanel"
require "DataMgr/GoodsManager"

--人物UI
local m_isCreate = false;
local m_isOpen = false;

local m_curTag1 = TAG_ALL;
local m_panelY = 130;
local m_infoPanel_pos_1 = ccp(63, m_panelY);
local m_infoPanel_pos_2 = ccp(593, m_panelY);
local m_equipSingle0 = ccp(421, m_panelY);
local m_equipSingle1 = ccp(328, m_panelY);

local m_otherGoodsPos = ccp(300, m_panelY);

local m_curIndex = 0;

local m_isRemoveMode = false;

local m_curUITag = 0;--标志当前是 人物、人物属性、武器界面

-----------------------------------------------------------------
local function isEquipPieceEnough( pieceData )
    local have = pieceData.count;
    local itemData = DataTableManager.getItem("equipPieceData", "id_" .. pieceData.id);
    if(itemData) then
        local needN = itemData.count;
        if(have >= needN) then
            return true;
        end
    end
    return false;
end
--检测装备碎片有是否可以合成的
function checkEquipPieceNote()
    local pieces = UserInfoManager.getBackPackInfo("equipPiece");
    for i,v in ipairs(pieces) do
        local enough = isEquipPieceEnough(v);
        if(enough) then
            return true;
        end
    end
    return false;
end

--上线检测提示
function checkNotification_login()
    if(checkEquipPieceNote()) then
        return true;
    end
    return false;
end

function checkNotification_line()
    return checkNotification_login();
end

function checkNotification_close()
    return checkNotification_login();
end

------------------------------------------------------------------

function setCurUITag( tag )
    if(tag) then
        m_curUITag = tag;
    end
end

function refreshFigureDisplay()
    if(m_curUITag == BACKPACK_FIGURE) then
        return Figure.refreshDisplay();
    elseif(m_curUITag == BACKPACK_FIGURE_PROPERTY) then
    elseif(m_curUITag == BACKPACK_FIGURE_WEAPON) then
        -- return FigureWeapon.refreshDisplay();
    end
end

function onlyRefreshWeaponStar(starlv)
    if(m_curUITag == BACKPACK_FIGURE) then
        return Figure.onlyRefreshWeaponStar(starlv);
    elseif(m_curUITag == BACKPACK_FIGURE_PROPERTY) then
    elseif(m_curUITag == BACKPACK_FIGURE_WEAPON) then
        -- return FigureWeapon.onlyRefreshWeaponStar(starlv);
    end
end

function getCurWeaponLoadingBar()
    if(m_curUITag == BACKPACK_FIGURE) then
        return Figure.getCurWeaponLoadingBar();
    elseif(m_curUITag == BACKPACK_FIGURE_PROPERTY) then
    elseif(m_curUITag == BACKPACK_FIGURE_WEAPON) then
        -- return FigureWeapon.getCurWeaponLoadingBar();
    end
end

function getInfoPanel2Pos()
    return m_infoPanel_pos_2;
end

local function changeRemoveBtnState()
    if(m_curTag1 == TAG_ALL) then
    else
    end
end


--更改一级标签显示，tag:标签id
local function changeHorTabUI(tag)
    m_curTag1 = tag;
    local status = {false, false, false, false, false};
    if(m_curTag1 == TAG_ALL) then
        status[1] = true;
    elseif(m_curTag1 == TAG_EQUIP)then
        status[2] = true;
    -- elseif(m_curTag1 == TAG_WEAP)then
    --     status[3] = true;
    elseif(m_curTag1 == TAG_PIECE)then
        status[3] = true;
    elseif(m_curTag1 == TAG_OTHER)then
        status[4] = true;
    end
    HorTabFive.setDislpayName(status);
end

--左侧人物界面的更改
function changeFigureUI()
    --如果不是吞噬状态下才进行任务界面切换
    if(m_isRemoveMode == false) then
        if(m_curTag1 == TAG_WEAP) then
            if(Figure.isOpen()) then
                -- UIManager.close("Figure");
                Figure.close();
            else
            end
            -- UIManager.open("FigureWeapon");
            -- FigureWeapon.open();
            m_curUITag = BACKPACK_FIGURE_WEAPON;
        else
            if(FigureWeapon.isOpen()) then
                -- UIManager.close("FigureWeapon");
                -- UIManager.open("Figure");
                -- FigureWeapon.close();
                Figure.open();
                m_curUITag = BACKPACK_FIGURE;
            end
        end
    end
end

--定位到某一标签下
function changeUIByPageId(tabId)
    if(tabId ~= m_curTag1) then
        changeHorTabUI(tabId);
        changeFigureUI();
        GoodsList.onBackpackTabPageChanged(m_curTag1);
        changeRemoveBtnState();
        if(m_isRemoveMode) then
        end
    end
end

--定位到吞噬模式
function gotoRemoveMode()
    m_isRemoveMode = true;
    -- HorTabFive.setTouchEnabeld(false, false, false, false, false);
end

--从吞噬模式恢复
function recoveryFromRemoveMode()
    m_isRemoveMode = false;
end

--点击了背包、衣柜、精灵武器标签
function tabPage1Callback(sender)
    local tag = sender:getTag();
    if(tag ~= m_curTag1) then
        changeUIByPageId(tag);
    end
end


--从衣柜界面打开初始化
function openFromWardrobe()
    m_curTag1 = TAG_2_COAT;
    open();
end

--进入衣柜界面
function gotoWardrobe()
    BackpackNew.close();
    Wardrobe.open();
end

-------------------------------功能处理----------------------------------
--关闭信息面板
local function closeGoodsInfo()
    GoodsDetailsPanel.close();
    ProgressRadial.close();
end

-- 装备返回 1721
local function onReceiveWearResponse(messageType, messageData)
    local result = messageData.result;
    ProgressRadial.close();
    if(result == 1) then 
        GoodsList.refreshDisplay();
        Figure.refreshDisplay();
        closeGoodsInfo();
    else
        if(result == 2) then
            Util.showOperateResultPrompt("等级不足");
        end
    end
end

-- 替换返回 1723
local function onReceiveReplaceResponse(messageType, messageData)
    local result = messageData.result;
    ProgressRadial.close();
    GoodsList.refreshDisplay();
    Figure.refreshDisplay();
    closeGoodsInfo();
end

--合成返回
local function onReceiveCompositeResponse(messageType, messageData)
    local COMPOSITE_EQUIP = 1;
    local COMPOSITE_COAT  = 2;
    
    --装备合成
    local COMPOSITE_EQUIP_RESULT_NOT_ENOUGH = 1;
    local COMPOSITE_EQUIP_RESULT_SUCCESS    = 2;
    
    --外套合成
    local COMPOSITE_COAT_RESULT_NOT_ENOUGH  = 1; --碎片不足
    local COMPOSITE_COAT_RESULT_SUCCESS     = 2; --合成成功
    local COMPOSITE_COAT_RESULT_HAVE        = 3; --已经拥有

    local type = messageData.type;
    local result = messageData.result;

    ProgressRadial.close();
    GoodsList.refreshDisplay();


    if(type == COMPOSITE_EQUIP) then
        --装备合成
        closeGoodsInfo();
        if(result == COMPOSITE_EQUIP_RESULT_SUCCESS) then
            Util.showOperateResultPrompt("合成成功");
        elseif(result == COMPOSITE_EQUIP_RESULT_NOT_ENOUGH) then
            Util.showOperateResultPrompt("碎片不足");
        else
            local datas, indexC = UserInfoManager.getGoodsInfo(GoodsList.getCurTag(), m_curIndex);
            print("装备合成，配置表有误 碎片id = " .. datas[indexC].id);
        end
    elseif(type == COMPOSITE_COAT) then
        --外套合成
        if(result == COMPOSITE_COAT_RESULT_SUCCESS) then
            Util.showOperateResultPrompt("合成成功");
            closeGoodsInfo();
        elseif(result == COMPOSITE_COAT_RESULT_HAVE) then
            Util.showOperateResultPrompt("已经拥有此外套");
        elseif(result == COMPOSITE_COAT_RESULT_NOT_ENOUGH) then
            Util.showOperateResultPrompt("碎片不足");
        else
            local datas, indexC = UserInfoManager.getGoodsInfo(GoodsList.getCurTag(), m_curIndex);
            print("外套合成，配置表有误 碎片id = " .. datas[indexC].id);
        end
    end
end

--精灵蛋操作返回
local function onReceiveSpriteEggOperateResponse(messageType, messageData)
    -- body
end

--装备
function wear(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        -- print(" 背包   装备");
        --704
        -- byte    要装备的物品类型(1装备 2外套 3武器)   
        -- short   物品的索引index
        local datas, indexC = UserInfoManager.getGoodsInfo(GoodsList.getCurTag(), m_curIndex);
        if(indexC == nil) then
            indexC = m_curIndex;
        end
        local dataItem = datas[indexC];

        -- local level = GoodsManager.getLevelById(dataItem.id);
        local level = dataItem.level;
        if(UserInfoManager.getRoleInfo("level") >= level) then
            local typeid = GoodsManager.getGoodsHighTypeId(dataItem.id);
            local msg = {typeid, indexC};
            ProgressRadial.open();
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MOVEBPTOFIGURE, msg);
        else
            Util.showOperateResultPrompt("等级不足");
        end
    end
end

--替换
local function replace(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        -- print(" 背包   替换");
        --706
        -- byte    要装备的物品类型(1装备 2外套 3武器)   
        -- short   背包中索引   
        -- byte    人物部位
        local datas, indexC = UserInfoManager.getGoodsInfo(GoodsList.getCurTag(), m_curIndex);
        if(indexC == nil) then
            indexC = m_curIndex;
        end
        local dataItem = datas[indexC];
        local level = GoodsManager.getLevelById(dataItem.id);
        if(UserInfoManager.getRoleInfo("level") >= level) then
            local equipName, partid = GoodsManager.isFigureHaveEquip(dataItem.id);
            local typeid = GoodsManager.getGoodsHighTypeId(dataItem.id);
            local figurePart = Figure.getCurPart(partid);
            local msg = {typeid, indexC, figurePart};
            ProgressRadial.open();
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_REPLACEFIGUREEQUIP, msg);
        else
            Util.showOperateResultPrompt("等级不足");
        end
    end
end

--使用
local function use(sender,eventType)
    -- local data = UserInfoManager.getGoodsInfo(m_curTag, m_curIndex);
    if eventType == TOUCH_EVENT_TYPE_END then
        -- print(" 背包   使用");
    end
end

--展示
local function show(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        -- print(" 背包   展示");
    end
end

--碎片合成
local function composite( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        -- print(" 背包   合成");
        local datas, indexC = UserInfoManager.getGoodsInfo(GoodsList.getCurTag(), m_curIndex);
        if(indexC == nil) then
            indexC = m_curIndex;
        end
        local dataItem = datas[indexC];
        if(GoodsManager.isPiece(dataItem.id)) then
            if(GoodsManager.isCoatPiece(dataItem.id)) then
                local itemData = DataTableManager.getItem("coatPieceData", "id_" .. dataItem.id);
                if(itemData) then
                    local needN = itemData.count;
                    if(dataItem.count >= needN) then
                        ProgressRadial.open();
                        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_COATCOMPOSITE, {indexC});
                    else
                        Util.showOperateResultPrompt("碎片数量不足");
                    end
                else
                    print("外套碎片表没有配 id = " .. dataItem.id);
                end
            else

                local itemData = DataTableManager.getItem("equipPieceData", "id_" .. dataItem.id);
                if(itemData) then
                    local needN = itemData.count;
                    if(dataItem.count >= needN) then
                        ProgressRadial.open();
                        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EQUIPCOMPOSITE, {indexC});
                    else
                        Util.showOperateResultPrompt("碎片数量不足");
                    end
                else
                    print("装备碎片表没有配 id = " .. dataItem.id);
                end
            end
        end
    end
end

--精灵蛋鉴定
local function appraisalSpriteEgg( sender,eventType )
    -- body
end

local function registerOperateMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MOVEBPTOFIGURERESPONSE, onReceiveWearResponse);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REPLACEFIGUREEQUIPRESPONSE, onReceiveReplaceResponse);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_COMPOSITERESPONSE, onReceiveCompositeResponse);
end

local function unRegisterOperateMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_MOVEBPTOFIGURERESPONSE, onReceiveWearResponse);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_REPLACEFIGUREEQUIPRESPONSE, onReceiveReplaceResponse);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_COMPOSITERESPONSE, onReceiveCompositeResponse);
end



local function getCurBpFuncParam(id)
    local bpFunParam = {};
    local canWear = GoodsManager.isEquipOrWeapon(id); --判断是否是可装备物品
    -- name, cbs, labels
    bpFunParam.name = FunBtnCount3.getDelName().BP; --背包

    local labels = {};
    local cbs = {};

    labels[3] = IMAGE_PATH.zhanshi;
    labels[2] = nil;

    cbs[3] = show;
    cbs[2] = nil;

    if(canWear == false) then
        if(GoodsManager.isPiece(id)) then
            labels[1] = IMAGE_PATH.hecheng;
            cbs[1] = composite;
        elseif(GoodsManager.isSpriteEgg(id)) then --是否是精灵蛋
            labels[1] = IMAGE_PATH.jianding;
            cbs[1] = appraisalSpriteEgg;
        else
            labels[1] = IMAGE_PATH.shiyong;
            cbs[1] = use;
        end
    else
        local equipName = GoodsManager.isFigureHaveEquip(id);
        if(equipName == nil) then
            --人物身上没有
            labels[1] = IMAGE_PATH.zhuangbei;
            cbs[1] = wear;
        else
            labels[1] = IMAGE_PATH.tihuan;
            cbs[1] = replace;
        end
    end

    bpFunParam.labels = labels;
    bpFunParam.cbs = cbs;

    return bpFunParam;
end

local function getEquipPanelPos(type, selectData, wearedData )
    if(type == 1) then
        --点击了背包装备
        if(wearedData) then
            return m_infoPanel_pos_1, m_infoPanel_pos_2;
        else
            if(selectData.suitType > 0) then
                return m_equipSingle1;
            else
                return m_equipSingle0;
            end
        end
    elseif(type == 2) then
        --点击了已装备装备
        if(selectData.suitType > 0) then
            return m_equipSingle1;
        else
            return m_equipSingle0;
        end
    end
end


--加载物品信息对比界面
local function openGoodsInfo(data)
    print("************  data.id = " .. data.id);
    GoodsDetailsPanel.open(closeGoodsInfo);
    --判断是否有已装备上的同类装备
    local figureData = nil;
    if(data) then
        --显示点击的物品
        local bpFunParam = getCurBpFuncParam(data.id);--------------------------设置背包功能按钮面板回调
        -- GoodsDetailsPanel.showPanel(data, m_infoPanel_pos_2, bpFunParam);
        local isHave = false;
        local pos1, pos2 = nil;
        if(GoodsManager.isEquip(data.id)) then
            --人物身上有同类装备
            local equipName = GoodsManager.isFigureHaveEquip(data.id);
            if(equipName ~= nil) then
                isHave = true;
                figureData = UserInfoManager.getRoleInfo(equipName);
                local figureFunParam = Figure.getFigureFuncParam();---------------------------------------------------
                -- GoodsDetailsPanel.showPanel(figureData, m_infoPanel_pos_1, figureFunParam);
                pos1, pos2 = getEquipPanelPos(1, data, figureData);
                GoodsDetailsPanel.showPanel(figureData, pos1);
            end
            if(isHave) then
                GoodsDetailsPanel.showPanel(data, pos2, replace);
            else
                local pos = getEquipPanelPos(1, data);
                GoodsDetailsPanel.showPanel(data, pos, wear);
            end
        else
            if(GoodsManager.isPiece(data.id)) then
                if(GoodsManager.isCoatPiece(data.id)) then
                    GoodsDetailsPanel.showPanel(data, m_otherGoodsPos, composite, 1);
                else
                    GoodsDetailsPanel.showPanel(data, m_otherGoodsPos, composite);
                end
            else
                GoodsDetailsPanel.showPanel(data, m_otherGoodsPos);
            end
        end
    end
end

--协议函数 物品列表点击回调
function goodsOnClick( index, tag )
    m_curIndex = index;
    if(m_isRemoveMode) then
    else
        local data, indexC = UserInfoManager.getGoodsInfo(tag, m_curIndex);
        if(indexC == nil) then
            indexC = m_curIndex;
        end
        if(data) then
            local dataItem = data[indexC];
            openGoodsInfo(dataItem);
        end
    end
end

--协议函数 人物面板装备点击回调
function figureIconOnClick( typeName )
    print("********** typeName = " .. typeName);
    --根据位置索引获得人物数据data
    local data = UserInfoManager.getRoleAllInfo()[typeName];
    GoodsDetailsPanel.open(closeGoodsInfo);
    local figureFunParam = Figure.getFigureFuncParam();
    -- GoodsDetailsPanel.showPanel(data, m_infoPanel_pos_2, figureFunParam);
    GoodsDetailsPanel.showPanel(data, getEquipPanelPos(2, data));
end

local function openRequestEnd()
     ProgressRadial.close();

     Figure.refreshDisplay();
end

local function sendOpenRequest()
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_BACKPACK_OPEN_REQUEST, {});
end


local function initData()
    m_curTag1 = TAG_ALL;
    m_curIndex = 0;
    m_isRemoveMode = false;

end


function create()
    if(not m_isCreate) then
        m_isCreate = true;
        -- loadDataTest();--加载数据模拟
        NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_BACKPACK_REQUEST_OK, openRequestEnd);

        GoodsList.create();
        Figure.create();
        HorTabFive.create();
        -- FigureWeapon.create();
        GoodsDetailsPanel.create();
        -- FunBtnCount3.create();
    end
end

local figurePos = ccp(104, 27);
local goodsListPos = ccp(584, 27);
local m_horTabPos = ccp(980, 300);
local figureWeaponPos = ccp(104, 27);

function open()
	if(not m_isOpen) then
		m_isOpen = true;

        initData();

        -- ProgressRadial.open();
        -- sendOpenRequest();


        Background.create("BackpackNew");
        Background.open();

        GoodsList.open(TAG_ALL);
        GoodsList.setName("");
        GoodsList.setDelegate("BackpackNew");
        GoodsList.setPosition(goodsListPos);

        Figure.open();
        Figure.setPosition(figurePos);
        Figure.setDelegate("BackpackNew");
        Figure.setAllEquipIconsEnabled(true);

        HorTabFive.open();
        HorTabFive.setPosition(m_horTabPos);
        HorTabFive.setTabTag(TAG_ALL, TAG_EQUIP, TAG_PIECE, TAG_OTHER);
        HorTabFive.setCallBack(tabPage1Callback, tabPage1Callback, tabPage1Callback, tabPage1Callback, tabPage1Callback);
        local status = {true, false, false, false, false};
        HorTabFive.setDislpayName(status);

        -- FigureWeapon.setPosition(figureWeaponPos);

        changeFigureUI();
        changeRemoveBtnState();
        
        registerOperateMessage();

        -- Figure.createAnimation();
        -- FigureWeapon.createWeaponAnim();

        m_curUITag = BACKPACK_FIGURE;
	end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        
        Background.close();
        Background.remove();
        GoodsList.close();
        Figure.close();
        -- FigureWeapon.close();
        HorTabFive.close();
        closeGoodsInfo();

        unRegisterOperateMessage();

        Figure.removeAnimation();
        -- FigureWeapon.removeWeaponAnim();

        --------
        -- 进度条关闭
        ProgressRadial.close();

        NotificationManager.onCloseCheck("BackpackNew");

        m_curUITag = 0;
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_BACKPACK_REQUEST_OK, openRequestEnd);

        GoodsList.remove();
        Figure.remove();
        HorTabFive.remove();
        -- FigureWeapon.remove();
        GoodsDetailsPanel.remove();
        -- FunBtnCount3.remove();
    end
end