module("WeaponDevour", package.seeall)

require "DataMgr/Calculation/OtherCalc"

--武器吞噬界面
local m_status = nil;
local m_selects = {
    equip     = {},
    weapon    = {},
    piece     = {},
    other     = {}
}; --存放"吞噬"模式下选中的索引

--存放可吞噬物品数据(列表)
local m_devourData = {
	-- {tag =  , index =  , data = {}}, --tag：标志装备、武器、碎片、杂物；index：该物品在m_selects数据中的索引；data：该物品数据
	-- {}
	-- ...
}; 

local m_tags = {TAG_EQUIP, TAG_WEAP, TAG_PIECE, TAG_OTHER};
local m_tags2 = {
	equip = "equip",
	weapon = "weapon",
	equipPiece = "piece", 
	coatchip = "piece", 
	other = "other",
};


local m_sureBtn = nil; --吞噬按钮
local m_selectAllBtn = nil; --全选按钮
local m_slv = nil;
local m_item = nil;


local m_rootLayout = nil;
local m_count = 0; --显示的数量
local m_totalCount = 0; --ScrollView 中子项数量
local COUNT_ONE_LINE = 5;
local SLV_TAG_BASE = 323;
local SPACE_X = 10; -- icon间隔
local SPACE_Y = 6; -- icon间隔
local PANEL_W = 70;
local SELECT_ICON_SIZE = 0;

local m_select_normal = PATH_CCS_RES .. "gy_weixuanze.png";
local m_select_select = PATH_CCS_RES .. "gy_xuanze.png";

local m_isSelectAll = false;

local m_devourProduce = {};--吞噬产出 needExp, exp, money, hunyu， upstepStone, soulStone



-----------------------吞噬返回-------------------------

local m_weaponExpBefore = 0;
local m_weaponExpEnd = 0;
local m_weaponStarBefore = 0;
local m_weaponStarEnd = 0;
local m_weaponStar = 0;
local m_expDiff = 0;
local LOADING_TIME = 3;
local m_step = 1;
local m_expData = nil;
local m_isLoading = false;
function isLoading()
   return m_isLoading;
end

function weaponExpUpOk()
    m_weaponExpBefore = 0;
    m_weaponExpEnd = 0;
    m_weaponStarBefore = 0;
    m_weaponStarEnd = 0;
    m_weaponStar = 0;
    m_expDiff = 0;

    DyLoadingBar.remove();

    calcDevourProduce();
    WeaponUI.refreshDisplay();
    WeaponUI.setButtonsTouchEnabled(true);
    WeaponDevour.setButtonsTouchEnabled(true);
    m_isLoading = false;
end

-----------------------吞噬返回-------------------------

local function loading( per )
    local total = m_expData[m_weaponStar - 1];
    local now = math.floor((total*per)/100);
    WeaponUI.refreshWeapon_Exp(now, total);
end

function continueUpWeaponLoadingBar()
    if(m_weaponStar <= m_weaponStarEnd) then
        WeaponUI.refreshWeapon_Star(m_weaponStar);
    end

    if(m_weaponStar <= m_weaponStarEnd and m_expDiff > 0) then
        AudioEngine.playEffect(PATH_RES_AUDIO.."tunshi.mp3");
        local exp = 0;
        local totalExp = m_expData[m_weaponStar];
        if(m_weaponStar == m_weaponStarEnd) then
            exp = m_expDiff;
        elseif(m_weaponStar == m_weaponStarBefore) then
            exp = m_expData[m_weaponStar] - m_weaponExpBefore;
        else
            --自动升级
            exp = m_expData[m_weaponStar];
        end

        m_expDiff = m_expDiff - exp;
        m_weaponStar = m_weaponStar + 1;

        local loadingBar = WeaponUI.getLoadingBar();
        local perNow = loadingBar:getPercent();
        --考虑误差
        if(perNow >= 99.5) then
            loadingBar:setPercent(0);
            perNow = 0;
        end
        if(exp > 0) then
            -- print("**************** toPer = " .. math.min(100,(exp/totalExp)*100 + perNow) .. " %");
            DyLoadingBar.run(math.min(100,(exp/totalExp)*100 + perNow), LOADING_TIME, continueUpWeaponLoadingBar, loading);
        end
    else
        weaponExpUpOk();
    end
end


local function upWeaponLoadingBar()
    local weaponData = WeaponUI.getCurData();
    if(weaponData.id > 0) then
        m_weaponExpEnd = weaponData.exp;--最后剩余的经验

        --得到武器共增长的经验值
        m_weaponStarEnd = weaponData.star;
        if(m_weaponStarEnd > m_weaponStarBefore) then
            m_expDiff =  m_expData[m_weaponStarBefore] - m_weaponExpBefore;
            for i = m_weaponStarBefore + 1,m_weaponStarEnd - 1 do
                m_expDiff = m_expDiff + m_expData[i];
            end
            m_expDiff = m_expDiff + m_weaponExpEnd;
        else
            m_expDiff = m_weaponExpEnd - m_weaponExpBefore;
        end

        local go = false;
        if(WeaponCalc.canUpStren(m_weaponStarBefore)) then
            go = true;
        else
            if(m_expDiff > 0) then
                if(m_weaponExpBefore < m_expData[m_weaponStarBefore]) then
                    go = true;
                end
            end
        end

        if(go) then
            local loadingBar = WeaponUI.getLoadingBar();
            m_isLoading = true;
            DyLoadingBar.create(loadingBar);
            continueUpWeaponLoadingBar();
        else
            weaponExpUpOk();
        end
    end
end



local WEAPON_DEVOUR_OK = 1;
local WEAPON_DEVOUR_FAIL = 2;

--吞噬返回
local function onReceiveRemoveResponse( messageType, messageData )
print("************************** hulala");
    local result = messageData.result;
    ProgressRadial.close();
    if(result == WEAPON_DEVOUR_OK) then
        WeaponUI.setButtonsTouchEnabled(false);
        WeaponDevour.setButtonsTouchEnabled(false);
        WeaponUI.stopWeaponStarsAction();--停止星星闪烁
        -- WeaponUI.refreshCurData();
        WeaponUI.devourEndRefresh();
        refreshAll();    
        upWeaponLoadingBar();
    elseif(result == WEAPON_DEVOUR_FAIL) then
        Util.showOperateResultPrompt("没有装备武器");
        weaponExpUpOk();
    end
end





local function haveSelect()
    for k,v in pairs(m_selects) do
        for i,v2 in ipairs(v) do
            if(v2 == 1) then
                return true;
            end
        end
    end
    return false;
end

local function getSelectsStr()
    local str = "";
    str = str .. Util.tableToStrBySeparator(m_selects.equip, ";") .. ":";
    str = str .. Util.tableToStrBySeparator(m_selects.weapon, ";") .. ":";
    str = str .. Util.tableToStrBySeparator(m_selects.piece, ";") .. ":";
    str = str .. Util.tableToStrBySeparator(m_selects.other, ";");
    return str;
end

--开始吞噬
local function sendRemoveMessage()
    --吞噬之前武器的经验
    local data = WeaponUI.getCurAllData();
    local weaponData = data.data;
    m_weaponExpBefore = 0;
    if(weaponData.id > 0) then
        m_weaponExpBefore = weaponData.exp;
        m_weaponStarBefore = weaponData.star;
        m_weaponStar = m_weaponStarBefore;
        m_step = weaponData.step;
        local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. m_step, "exp");
        m_expData = Util.strToNumber(Util.Split(expDataStr, ";"));
    end

    ProgressRadial.open();
    local type = 0;     --标志是为背包武器吞噬(0)，还是为已装备武器吞噬(1)
    if(data.index == 0) then
        type = 1;
    end
    local msg = {type, getSelectsStr(), data.index};
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_WEAPONDEVOUR, msg);
end

--确定按钮
function sureOnClick( sender,eventType )
     if(eventType == TOUCH_EVENT_TYPE_END) then
        --点击"确定",开始吞噬
        if(haveSelect()) then
            sendRemoveMessage();
        else
            Util.showOperateResultPrompt("没有选择");
        end
     end
end

function getDevourProduce()
    return m_devourProduce;
end

--------------------------------------------吞噬以前----------------------------------------------
--计算当前吞噬产出
--调用时机：切换武器时；点选吞噬物品；全选操作
function calcDevourProduce()
    m_devourProduce = {};
	local needExp = 0;  --距离下一级别所需经验
    local exp = 0;  --本次吞噬可产出经验
    local money = 0;       --产出金币
    local hunyu = 0;       --产出魂玉
    local upstepStone = 0; --产出升阶石 
    local soulStone = 0; --灵魂石
    --距离下一级别所需经验
	local weaponData = WeaponUI.getCurData();
	local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. weaponData.step, "exp");
    local expData = Util.strToNumber(Util.Split(expDataStr, ";"));
    --其它额外物品
    for i=1,#m_devourData do
        local tag = m_devourData[i].tag;
        if(m_selects[tag][m_devourData[i].index] == 1) then
            --以选中
            if(tag == "equip") then
                -- exp, money, soulYu, upstepStone
                local duce = EquipmentCalc.getDevourProduce(m_devourData[i].data, weaponData);
                exp = exp + duce.exp;
                money = money + duce.money;
                hunyu = hunyu + duce.soulYu;
                upstepStone = upstepStone + duce.upstepStone;
            elseif(tag == "weapon") then
                exp = exp + WeaponCalc.getDevourProduce(m_devourData[i].data);
            else
                -- exp, money, soulStone, upstepStone, soulYu
                local duce = OtherCalc.getDevourProduce(m_devourData[i].data);
                if(duce ~= nil) then
                    exp = exp + duce.exp;
                    money = money + duce.money;
                    hunyu = hunyu + duce.soulYu;
                    upstepStone = upstepStone + duce.upstepStone;
                    soulStone = soulStone + duce.soulStone;
                else
                    print("********* 杂物吞噬表，没有没有配置此物品产出  id = " .. m_devourData[i].data.id);
                end
            end
        end
    end
    m_devourProduce.exp = exp;
    m_devourProduce.money = money;
    m_devourProduce.hunyu = hunyu;
    m_devourProduce.upstepStone = upstepStone;
    m_devourProduce.soulStone = soulStone;

    local afterStarlv, lastExp = calcAfterDevourStarlv();
    local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. weaponData.step, "exp");
    local expDatas = Util.strToNumber(Util.Split(expDataStr, ";"));
    -- local expTotal = expDatas[afterStarlv];
    -- WeaponUI.refreshWeapon_Exp(lastExp, expTotal);
    if(weaponData.exp >= expDatas[weaponData.star]) then
        m_devourProduce.needExp = 0;
    else
        m_devourProduce.needExp = expDatas[weaponData.star] - weaponData.exp;
    end

    --刷新界面
    WeaponUI.refreshDevourProduce();
    WeaponUI.refreshWeapon_Property();
    WeaponUI.refreshWeapon_Star(afterStarlv);
end

--计算吞噬之后武器的等级
function calcAfterDevourStarlv()
    if(m_devourProduce == nil) then
        calcDevourProduce();
    end
    local data = WeaponUI.getCurData();
    local exp = m_devourProduce.exp;--总共会产出的经验数量
    local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. data.step, "exp");
    local expDatas = Util.strToNumber(Util.Split(expDataStr, ";"));

    if(WeaponCalc.canUpStren(data.star)) then
        if(exp > (expDatas[data.star] - data.exp)) then
            --可以升级
            local curLv = data.star + 1;
            local lastExp = exp - (expDatas[data.star] - data.exp);
            if(curLv >= WeaponCalc.getMaxStrenlv()) then
                return WeaponCalc.getMaxStrenlv(), lastExp;
            else
                local curNeed = expDatas[curLv];
                while(lastExp > curNeed) do
                    curLv = curLv + 1;
                    if(curLv >= WeaponCalc.getMaxStrenlv()) then
                        return WeaponCalc.getMaxStrenlv(), lastExp;
                    end
                    lastExp = lastExp - curNeed;
                    curNeed = expDatas[curLv];
                end
                return curLv, lastExp;
            end
        else
            return data.star, exp;
        end
    else
        --达到最大等级
        return data.star, exp;
    end
end



local function getKeyByTag( tag )
    if(tag == TAG_EQUIP) then return "equip" end
    if(tag == TAG_WEAP) then return "weapon" end
    if(tag == TAG_PIECE) then return "piece" end
    if(tag == TAG_OTHER) then return "other" end
end

local function setSelectAllBtn()
	if(m_isSelectAll) then
		m_selectAllBtn:loadTextureNormal(PATH_CCS_RES .. "gybtn_quxiaoquanxuan_1.png");
		m_selectAllBtn:loadTexturePressed(PATH_CCS_RES .. "gybtn_quxiaoquanxuan_2.png");
	else
		m_selectAllBtn:loadTextureNormal(PATH_CCS_RES .. "gybtn_quanxuan_1.png");
		m_selectAllBtn:loadTexturePressed(PATH_CCS_RES .. "gybtn_quanxuan_2.png");
	end
end

local function setSelectData( tag, index, isSelect )
	if(isSelect) then
		m_selects[tag][index] = 1;
	else
		m_selects[tag][index] = 0;
	end
	-- print("*******************************");
	-- Util.print_lua_table(m_selects);
end

local function setIconSelect( index, isSelect )
	local item = tolua.cast(m_slv:getChildByTag(index + SLV_TAG_BASE), "Layout");
	local selectImg = tolua.cast(item:getChildByName("select_img"), "ImageView");
	if(isSelect) then
		selectImg:loadTexture(m_select_select);
	else
		selectImg:loadTexture(m_select_normal);
	end
end

--全选筛选（一些物品不会自动选择）
local function filter( data )
    local id = data.id;
    if(GoodsManager.getColorById(id) >= COLOR_PURPLE) then
        return false;
    end
    if(GoodsManager.isWeapon(id)) then
        return false;
    end

    if(GoodsManager.isEquip(id)) then
        -- 装备进行过强化 升阶 重置 灵魂连接
        if(data.strenLV > EquipmentCalc.getMinLV()) then
            return false;
        end
        if(GoodsManager.isGrowEquip(id)) then
            if(data.upstepLV > EquipmentCalc.getMinStepLV(id)) then
                return false;
            end
        end
        if(data.soulLV > 0) then
            return false;
        end
    end
    return true;
end

local function setAllSelect( isSelect )
	for i=1,m_count do
       	local data = m_devourData[i];
        if((isSelect and filter(data.data)) or (not isSelect)) then
            local indexC = data.index;
            local tag = data.tag;
            setSelectData(tag, indexC, isSelect);
            setIconSelect( i, isSelect );
        end
	end
end

--单个图标被点击
function slvTouchEvent( sender,eventType )
    if(eventType == TOUCH_EVENT_TYPE_END) then
        local index = sender:getTag() - SLV_TAG_BASE;
        local data = m_devourData[index];
        local tag = data.tag;
    	local indexC = data.index;
    	if(m_selects[tag][indexC] == 1)then
    		--取消选中
    		setSelectData(tag, indexC, false);
    		setIconSelect( index, false );
    	else
    		--选中
    		setSelectData(tag, indexC, true);
    		setIconSelect( index, true );
    	end
        calcDevourProduce();
    end
end

--全选按钮
local function selectAllOnClick( sender,eventType )
	 if(eventType == TOUCH_EVENT_TYPE_END) then
 		setAllSelect(not m_isSelectAll);
	 	m_isSelectAll = (not m_isSelectAll);
	 	setSelectAllBtn();
        calcDevourProduce();
	 end
end

local function refreshIcon()
	for i=1,m_count do
		local data = m_devourData[i].data;
		local item = tolua.cast(m_slv:getChildByTag(i + SLV_TAG_BASE), "Layout");
		local iconImg = tolua.cast(item:getChildByName("icon_img"), "ImageView");
		local colorImg = tolua.cast(item:getChildByName("color_img"), "ImageView");
		local selectImg = tolua.cast(item:getChildByName("select_img"), "ImageView");
		iconImg:loadTexture(GoodsManager.getIconPathById(data.id));
		colorImg:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(data.id)));
		selectImg:loadTexture(m_select_normal);
	end
end


----------------------------------------------------------------------------------------------------
--根据物品数量得到行数
local function getLinesCount(count)
 	local lines = math.floor(count/COUNT_ONE_LINE);
    if(count%COUNT_ONE_LINE > 0) then
    	lines = lines + 1;
    end
    return lines;
end
--得到某行的数量（line:行数 count:物品总个数）
local function getCountAtLine( line, count )
	local countALine;
	local last = count - (line - 1)*COUNT_ONE_LINE;
	if( last >= COUNT_ONE_LINE ) then
		countALine = COUNT_ONE_LINE;
	else
		countALine = last;
	end
	return countALine;
end

local function resetSlvItemsPosition(count)
    row = getLinesCount(count);
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    for i = 1,row do
    	local countAtLine = getCountAtLine(i, count);
        for j = 1,countAtLine do
            local panel = tolua.cast(m_slv:getChildByTag(SLV_TAG_BASE + (j + (i-1)*COUNT_ONE_LINE)), "Layout");
            panel:setPosition(
                    ccp(SPACE_X + (PANEL_W + SPACE_X)*(j - 1), 
                        slvInnerH - ((SPACE_Y + PANEL_W) + (SPACE_Y + PANEL_W)*(i - 1))
                        )
                    );
        end
    end
end

local function setPanelVisible()
    for i = 1,m_totalCount do
        local panel = m_slv:getChildByTag(i + SLV_TAG_BASE);
        if(i <= m_count) then
            panel:setEnabled(true);
        else
            panel:setEnabled(false);
        end
    end
end

function setSlvInnerSize(count)
    local row = math.ceil(count/COUNT_ONE_LINE);
    local innerHeight = PANEL_W*row + (row + 1)*SPACE_Y;
    m_slv:setInnerContainerSize(CCSize((m_slv:getSize()).width, innerHeight));
    resetSlvItemsPosition(count);
end

local function createSlvItem( row, col )
    local slvInnerH = (m_slv:getInnerContainerSize()).height;
    local panel = m_item:clone();
    local pos =  ccp(SPACE_X + (PANEL_W + SPACE_X)*(col - 1), 
            slvInnerH - ((SPACE_Y + PANEL_W) + (SPACE_Y + PANEL_W)*(row - 1))
            );
    panel:setPosition(pos);

    local tag = SLV_TAG_BASE + (col + (row-1)*COUNT_ONE_LINE);
    panel:addTouchEventListener(slvTouchEvent);
    panel:setTag(tag);
    m_slv:addChild(panel, 1);
end

local function refreshSlv()
    m_count = #m_devourData;
    if(m_count > m_totalCount) then
        for i = m_totalCount + 1,m_count do
            local row = math.ceil(i/COUNT_ONE_LINE);
            local col = i%COUNT_ONE_LINE;
            if(col == 0) then col = COUNT_ONE_LINE; end
            createSlvItem(row, col);
        end
        m_totalCount = m_count;
    end
    setSlvInnerSize(m_count);
    setPanelVisible();
    refreshIcon();
end
----------------------------------------------------------------------------------------------------





--刷新可吞噬物品数据
local function refreshDevourData()
	m_devourData = {};
    local curWeaponData = WeaponUI.getCurAllData();
    local bpData = UserInfoManager.getAllBackpackInfo();
    local dataKeys = {"equip", "weapon", "equipPiece", "coatchip", "other"};
    local devourOthers = DataTableManager.getTableByName("DevoursOthers");
    local piN = 0;
    local n = 1;
    for i=1,#dataKeys do
    	local datas = bpData[dataKeys[i]];
    	local tag = m_tags2[dataKeys[i]];
    	for j=1,#datas do
    		local canDevour = false;
    		if(dataKeys[i] == "equip" or dataKeys[i] == "weapon") then
    			--装备和武器都可以被吞噬
                if(dataKeys[i] == "weapon" and curWeaponData.index == j) then
                    canDevour = false;
                else
                    canDevour = true;
                end
    		else
                --碎片或者杂物，需要读表"DevoursOthers"(产出表)判断是否可以被吞噬（若表里没有此项，则表示不可被吞噬）
	    		local canDe = devourOthers["id_" .. datas[j].id];
	    		if(canDe ~= nil)then
	    			--此物品可以被吞噬
	    			canDevour = true;
    			end
    		end

    		if(tag == "piece") then
    			piN = piN + 1;
    		end

    		if(canDevour) then
    			local data = {};
    			data.tag = tag;
		    	if(tag == "piece") then
		    		data.index = piN;
		    	else
		    		data.index = j;
		    	end
    			data.data = datas[j];
    			m_devourData[n] = data;
				n = n + 1;
    		end
    	end
    end
end

local function initSelectData(tag)
	local key = getKeyByTag(tag);
    m_selects[key] = {};
    local n = 0;
    if(tag == TAG_PIECE) then
        n = #UserInfoManager.getGoodsInfo(TAG_EQUIP_PIECE) + #UserInfoManager.getGoodsInfo(TAG_COAT_PIECE);
    else
        n = #UserInfoManager.getGoodsInfo(tag);
    end
    for j=1,n do
        table.insert(m_selects[key], 0);
    end
end

local function initAllSelectData()
    m_selects = {};
    for i=1,#m_tags do
    	initSelectData(m_tags[i]);
    end
end

--1.点击了武器图标  2.每次吞噬面板打开
function refreshDisplay()
    refreshAll();
	-- m_isSelectAll = false;
 -- 	setSelectAllBtn();
 -- 	setAllSelect(false);
    calcDevourProduce();
end

--刷新显示和数据
--调用时机：打开主界面时刷新一次；吞噬操作返回
function refreshAll()
	initAllSelectData();
	refreshDevourData();
	refreshSlv();
    m_isSelectAll = false;
    setSelectAllBtn();
    setAllSelect(false);
end

local function openInit()
	m_totalCount = 0;
	m_isSelectAll = false;
end

function setButtonsTouchEnabled(enable)
    m_sureBtn:setTouchEnabled(enable);
    m_selectAllBtn:setTouchEnabled(enable);
end

local function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_WEAPONDEVOURRESPONSE, onReceiveRemoveResponse);--吞噬返回
end

local function unregisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_WEAPONDEVOURRESPONSE, onReceiveRemoveResponse);
end

function open(rootLayout)
	if(rootLayout) then
		m_rootLayout = rootLayout;
		m_slv = tolua.cast(m_rootLayout:getWidgetByName("jw_tun_slv"), "ScrollView");
		m_sureBtn = tolua.cast(m_rootLayout:getWidgetByName("jw_tun_queding_btn"), "Button");
		m_selectAllBtn = tolua.cast(m_rootLayout:getWidgetByName("jw_tun_quan_btn"), "Button");
		m_sureBtn:addTouchEventListener(sureOnClick);
		m_selectAllBtn:addTouchEventListener(selectAllOnClick);
		m_item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "jw_tunshi_1.json");
		m_item:retain();
		openInit();
		refreshAll();
        registerMessage();
	end
end

function close()
	if(m_item) then
		m_item:release();
		m_item = nil;
	end
    m_slv:removeAllChildrenWithCleanup(true);
    m_slv = nil;
    unregisterMessage();
end