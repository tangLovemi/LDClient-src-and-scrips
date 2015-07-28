module("WeaponUpstep", package.seeall)

-- 武器升阶界面

local m_rootLayout = nil;
local m_data = nil;
local m_status = 1;
local m_upstepUse = nil;

local function onReceiveOperateResponse( messageType, messageData )
    local operateId = messageData.operateId;
    local resultId = messageData.resultId;

    ProgressRadial.close();
    if(resultId == 1) then
    	Util.showOperateResultPrompt("升阶成功");
    end
    WeaponUI.upstepEndRefresh();
    refreshInfos();
end

local function upstepOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_status == 1) then
    		local data = WeaponUI.getCurAllData();
    		local type = 0;     --标志是为背包武器吞噬(0)，还是为已装备武器吞噬(1)
		    if(data.index == 0) then
		        type = 1;
		    end
		    local msg = {type, data.index};
		    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_WEAPONUPSTEP, msg);
		else
			if(m_status == 2) then
				Util.showOperateResultPrompt("最高品阶");
			elseif(m_status == 3) then
				-- Util.showOperateResultPrompt("需要将武器升到" .. WeaponCalc.getMaxStrenlv() .. "级");
				Util.showOperateResultPrompt("需要通过吞噬将武器升到满星");
			elseif(m_status == 4) then
				Util.showOperateResultPrompt("经验未满");
			elseif(m_status == 5) then
				Util.showOperateResultPrompt("材料不足");
			end
		end
	end
end

--是否满阶
--是否达最大等级
--是否经验满
--材料是否足够
function checkCanUpstep(data)
	if(WeaponCalc.canUpStep(data.step)) then
		if(data.star == WeaponCalc.getMaxStrenlv()) then
		    local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. data.step, "exp");
		    local expDatas = Util.strToNumber(Util.Split(expDataStr, ";"));
		    if(data.exp < expDatas[data.star]) then
		    	--达到最大强化等级，但经验未满
				return 4;
		    end
		else
			--未达到最大强化等级
			return 3;
		end
	else
		--满级
		return 2;
	end

	local upstepUse = WeaponCalc.getUpstepUse(data);
	if(upstepUse ~= nil) then
		for i,v in ipairs(upstepUse) do
			local needN = v.count;
			local haveN = UserInfoManager.getGoodsCount(v.id);
			if(needN > haveN) then
				--材料不足
				return 5;
			end
		end
	end

	return 1;
end

--升阶材料
local function refreshUseMaterial()
	m_rootLayout:getWidgetByName("shengcai_2_panel"):setEnabled(false);
	m_rootLayout:getWidgetByName("shengcai_3_panel"):setEnabled(false);
	m_rootLayout:getWidgetByName("shengcai_4_panel"):setEnabled(false);
	m_rootLayout:getWidgetByName("shengcai_5_panel"):setEnabled(false);

	if(WeaponCalc.canUpStep(m_data.step)) then
		m_upstepUse = WeaponCalc.getUpstepUse(m_data);
		local count = #m_upstepUse;
		if(count == 2) then
			m_rootLayout:getWidgetByName("shengcai_2_panel"):setEnabled(true);
		elseif(count == 3) then
			m_rootLayout:getWidgetByName("shengcai_3_panel"):setEnabled(true);
		elseif(count == 4) then
			m_rootLayout:getWidgetByName("shengcai_4_panel"):setEnabled(true);
		elseif(count == 5) then
			m_rootLayout:getWidgetByName("shengcai_5_panel"):setEnabled(true);
		end
		
		for i,v in ipairs(m_upstepUse) do
			local iconImg = tolua.cast(m_rootLayout:getWidgetByName("jw_" .. count .. "_cailiao" .. i .. "_img"), "ImageView");
			local colorImg = tolua.cast(m_rootLayout:getWidgetByName("jw_" .. count .. "_kuang" .. i .. "_img"), "ImageView");
			local haveLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_" .. count .. "_zhi_label" .. i .. "_1"), "Label");
			local needLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_" .. count .. "_zhi_label" .. i .. "_2"), "Label");
			local spaceLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_" .. count .. "_xie" .. i .. "_label"), "Label");
			iconImg:loadTexture(GoodsManager.getIconPathById(v.id));
			colorImg:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(v.id)));
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
end

--升阶按钮
local function refreshBtn()
	local btn = tolua.cast(m_rootLayout:getWidgetByName("jw_shengjie_que_btn"), "Button");
	m_status = checkCanUpstep(m_data);
	-- if(can == 1) then
	-- 	btn:loadTextureNormal(PATH_CCS_RES .. "gybtn_queding_1.png");
	-- 	btn:loadTexturePressed(PATH_CCS_RES .. "gybtn_queding_2.png");
	-- 	btn:setTouchEnabled(true);
	-- else
	-- 	btn:loadTextureNormal(PATH_CCS_RES .. "gybtn_queding_3.png");
	-- 	btn:loadTexturePressed(PATH_CCS_RES .. "gybtn_queding_3.png");
	-- 	btn:setTouchEnabled(false);
	-- end
end

--计算升阶之后的等级
local function calcAfterUpStepStar()
	local data = m_data;
	local exp = data.exp;--总共会剩余的经验数量
	local defStar = WeaponCalc.getMinStarlv();
    local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. (data.step + 1), "exp");
    local expDatas = Util.strToNumber(Util.Split(expDataStr, ";"));

    if(data.star >= WeaponCalc.getMaxStrenlv()) then
    	local lastExp = exp;
        local curLv = defStar;
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
        --达到最大等级
        return defStar, exp;
    end
end

function refreshInfos()
	m_data = WeaponUI.getCurData();
	--额外属性
	local upstepData = nil;
	if(WeaponCalc.canUpStep(m_data.step)) then
		local afterLv = WeaponCalc.getMinStarlv();
		if(WeaponCalc.canWeaponUpstep(m_data)) then
			afterLv = calcAfterUpStepStar();
		end
		upstepData = WeaponCalc.calcWeapon( m_data, m_data.step + 1,  afterLv);
	end

	--攻击力
    local atkValueLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_sheng_shuxing0_labelNum"), "LabelAtlas");
    local afterAtkValueLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_sheng_shuxingAfter0_labelNum"), "LabelAtlas");
    atkValueLabel:setStringValue(m_data.atk);
    if(upstepData ~= nil) then
    	afterAtkValueLabel:setEnabled(true);
	    afterAtkValueLabel:setStringValue(upstepData.atk);
	else
		afterAtkValueLabel:setEnabled(false);
   end
   --额外属性
    local PRO_COUNT_MAX = 3;--额外属性数量
    local proIds = Util.strToNumber(Util.Split(m_data.proId, ";"));
    local proLVs = Util.strToNumber(Util.Split(m_data.proLV, ";"));
    local proValues = Util.strToNumber(Util.Split(m_data.proValue, ";"));
    for i=1,PRO_COUNT_MAX do
	    local proNameLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_shengjie_shuxing" .. i .. "_img"), "ImageView");
	    local proValueLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_sheng_shuxing" .. i .. "_labelNum"), "LabelAtlas");
	    local afterValueLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_sheng_shuxingAfter" .. i .. "_labelNum"), "LabelAtlas");
	    proNameLabel:loadTexture(WeaponUI.getProNameImgPath(proIds[i]));
	    local numberImg,numberImg_W,numberImg_H = GoodsManager.getNumberImg_18(proLVs[i]);
	    proValueLabel:setProperty(proValues[i], numberImg, numberImg_W, numberImg_H, 0);
	    if(upstepData ~= nil) then
	    	--升阶增加
	    	m_rootLayout:getWidgetByName("jw_shengjie_jiantou_" .. i .. "_img"):setEnabled(true);
	    	m_rootLayout:getWidgetByName("jw_sheng_shuxingAfter" .. i .. "_labelNum"):setEnabled(true);
    		tolua.cast(m_rootLayout:getWidgetByName("jw_sheng_shuxingAfter" .. i .. "_labelNum"), "LabelAtlas"):setProperty(upstepData.addition[i], numberImg, numberImg_W, numberImg_H, 0);
	    else
	    	m_rootLayout:getWidgetByName("jw_shengjie_jiantou_" .. i .. "_img"):setEnabled(false);
	    	m_rootLayout:getWidgetByName("jw_sheng_shuxingAfter" .. i .. "_labelNum"):setEnabled(false);
	    end
	end

	--升阶材料
	refreshUseMaterial();

	--按钮
	refreshBtn();
end

--------------------------------------------------------------------------------------------------------
--升阶材料点击
local function upstepGoodsOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
        local goodid = m_upstepUse[sender:getTag()].id;
        if(GoodsManager.isAncient(goodid)) then
        	UIManager.open("AncientMaterialItem",goodid);
        else
        	GoodsDetailsPanel.open(function() GoodsDetailsPanel.close(); end);
        	GoodsDetailsPanel.showPanel({id = goodid}, UPSTEP_GOODS_OTHER_POS);
        end
    end
end


local function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_WEAPONUPSTEPRESPONSE, onReceiveOperateResponse);--升阶返回
end

local function unregisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_WEAPONUPSTEPRESPONSE, onReceiveOperateResponse);
end


local function boundListener()
	--确定按钮
	m_rootLayout:getWidgetByName("jw_shengjie_que_btn"):addTouchEventListener(upstepOnClick);
	--物品
	local types = {2,3,4,5};
	for i=1,#types do
		for j=1,types[i] do
			local good = m_rootLayout:getWidgetByName("jw_" .. types[i] .. "_cailiao" .. j .. "_img");
			good:setTag(j);
			good:addTouchEventListener(upstepGoodsOnClick);
		end
	end
end

function open(rootLayout)
	if(rootLayout) then
		m_rootLayout = rootLayout;
		m_data = nil;
		registerMessage();
		boundListener();
		m_rootLayout:getWidgetByName("shengcai_2_panel"):setEnabled(false);
		m_rootLayout:getWidgetByName("shengcai_3_panel"):setEnabled(false);
		m_rootLayout:getWidgetByName("shengcai_4_panel"):setEnabled(false);
		m_rootLayout:getWidgetByName("shengcai_5_panel"):setEnabled(false);
		GoodsDetailsPanel.create();
	end
end

function close()
	unregisterMessage();
    m_upstepUse = nil;
end