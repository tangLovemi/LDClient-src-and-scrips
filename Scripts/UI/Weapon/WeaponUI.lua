module("WeaponUI", package.seeall)

-- 武器信息界面

local m_isCreate = false;
local m_isOpen = false;

local m_rootLayer = nil;
local m_rootLayout = nil;

local STATUS_NORMAL = 1; --初始状态
local STATUS_UPSTEP = 2; --升阶状态
local STATUS_DEVOUR = 3; --吞噬状态
local m_status = 0;  --标志当前状态
local m_index = 0;

local m_datas = nil; --所有武器数据 { {index = , data = {} }, {}, ... } --index为武器在UserInfoManager数据中位置, data为数据
local m_weaponIconItem = nil;
local m_weaponList = nil;

local m_btn1 = nil;
local m_btn2 = nil;
local m_btn3 = nil;

local m_wearedArmature = nil;

local m_pos_1 = ccp(114, 143);
local m_pos_2 = ccp(577, 143);
local m_pos_3 = ccp(1136, 143);

local m_infoPanel = nil;
local m_upstepPanel = nil;
local m_devourPanel = nil;
local m_isMove = false;

local MOVE_TIME_1 = 0.5;

------------------------------------------------------------

local m_haveNewWeapon = false;
function setHaveNewWeapon( have )
	m_haveNewWeapon = have;
end

local function checkHaveNew()
	local weapons = UserInfoManager.getBackPackInfo("weapon");
	local haveNew = false;
	for i,v in ipairs(weapons) do
		if(v.isNew) then
			v.isNew = false;
			haveNew = true;
		end
	end
	return haveNew;
end

local function checkUpstep()
	local weapons = UserInfoManager.getBackPackInfo("weapon");
	for i,v in ipairs(weapons) do
		if(WeaponUpstep.checkCanUpstep(v) == 1) then
			return true;
		end
	end
	local wearedWeapon = UserInfoManager.getRoleInfo("weapon");
	if(wearedWeapon.id > 0) then
		if(WeaponUpstep.checkCanUpstep(wearedWeapon) == 1) then
			return true;
		end
	end
	return false;
end

--上线检测提示
function checkNotification_login()
    if(checkHaveNew()) then
    	return true;
    end
    if(checkUpstep()) then
    	return true;
    end
    return false;
end

function checkNotification_line()
	if(m_haveNewWeapon) then
		m_haveNewWeapon = false;
		return true;
	end
	if(checkUpstep()) then
		return true;
	end
    return false;
end

function checkNotification_close()
    return checkNotification_login();
end

------------------------------------------------------------

function getCurIndex()
	return m_index;
end

function getCurData()
	return m_datas[m_index].data;
end

function getCurAllData()
	return m_datas[m_index];
end

function getLoadingBar()
	return tolua.cast(m_rootLayout:getWidgetByName("exp_ProgressBar"), "LoadingBar");
end

---------------------------------------武器详细信息begin----------------------------------------------------
--吞噬产出
function refreshDevourProduce()
	-- 吞噬产出 needExp, exp, money, hunyu， upstepStone, soulStone
	local produce = WeaponDevour.getDevourProduce();
	tolua.cast(m_rootLayout:getWidgetByName("jw_nextexp_labelNum"), "LabelAtlas"):setStringValue(produce.needExp);
	tolua.cast(m_rootLayout:getWidgetByName("jw_tunnextexp_labelNum"), "LabelAtlas"):setStringValue(produce.exp);

	tolua.cast(m_rootLayout:getWidgetByName("jw_jinbi_huode_labelNum"), "LabelAtlas"):setStringValue(produce.money);
	tolua.cast(m_rootLayout:getWidgetByName("jw_jinjie_huode_labelNum"), "LabelAtlas"):setStringValue(produce.upstepStone);
	tolua.cast(m_rootLayout:getWidgetByName("jw_hunyu_huode_labelNum"), "LabelAtlas"):setStringValue(produce.hunyu);
end

--中间部分的信息，普通状态和升阶状态下是武器描述，吞噬状态时是吞噬产出
local function refreshWeaponOtherInfo()
	local data = m_datas[m_index].data;
	local skilldescPanel = m_rootLayout:getWidgetByName("jianjie_panel");
	local devourPanel = m_rootLayout:getWidgetByName("tun_panel");
	if(m_status == STATUS_DEVOUR) then
		skilldescPanel:setEnabled(false);
		devourPanel:setEnabled(true);
	else
		skilldescPanel:setEnabled(true);
		devourPanel:setEnabled(false);
		local skilldescLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_jinengjieshao_label"), "Label");
		local skillIcon = tolua.cast(m_rootLayout:getWidgetByName("skillpic_img"), "ImageView");
		local skillName = tolua.cast(m_rootLayout:getWidgetByName("nameskill_label"), "Label");
		local skillType = tolua.cast(m_rootLayout:getWidgetByName("zhuijia_label"), "Label");
		local skillRate = tolua.cast(m_rootLayout:getWidgetByName("rate_labelNum"), "LabelAtlas");
		local skillid = DataTableManager.getValue("weapon_name_Data", "id_" .. data.id, "skill");
		local skillInfo = DataTableManager.getItem("SkillInfoData", "id_" .. skillid);
		if(skillInfo ~= nil) then
			skilldescLabel:setText(skillInfo.desc);
			skillIcon:loadTexture(Util.getSkillIconPath(skillid, true));
			skillName:setText(skillInfo.name);
			skillRate:setStringValue(skillInfo.per);
			skillType:setText(DataTableManager.getValue("SkillTypeNameData", "id_" .. skillInfo.type, "name"));
		else
			skilldescLabel:setText("技能描述 skillid = " .. data.skill);
		end
	end
end

local function createStarAction()
	--星星閃
	local time = 0.5;
	local actionArr = CCArray:create();
	actionArr:addObject(CCFadeOut:create(time));
	actionArr:addObject(CCFadeIn:create(time));

	-- actionArr:addObject(CCBlink:create(time, 5));
	-- actionArr:addObject(CCDelayTime:create(0.5));

	-- actionArr:addObject(CCMoveBy:create(1, ccp(100, 0)));
	-- actionArr:addObject(CCMoveBy:create(1, ccp(-100, 0)));
	-- return CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(time), CCFadeIn:create(time)));
	return CCRepeatForever:create(CCSequence:create(actionArr));
	-- return CCFadeIn:create(5)
end

--每个品阶的星图
local m_starImgPath = {
	PATH_CCS_RES .. "jingling_x_1.png",-- 1阶
	PATH_CCS_RES .. "jingling_x_2.png",-- 2阶
	PATH_CCS_RES .. "jingling_x_3.png",-- 3阶
	PATH_CCS_RES .. "jingling_x_4.png",-- 4阶
	PATH_CCS_RES .. "jingling_x_5.png",-- 5阶
	PATH_CCS_RES .. "jingling_x_6.png",-- 6阶
	PATH_CCS_RES .. "xingxing9.png",   -- 7阶
};

--星级
function refreshWeapon_Star(starlv)
	local data = m_datas[m_index].data;
    local steplv = data.step;
    local STREN_MAX = WeaponCalc.getMaxStrenlv(); --最大强化等级
    for i=1,STREN_MAX do
        local starImg = tolua.cast(m_rootLayout:getWidgetByName("xingxingdi" .. i .. "_img"), "ImageView");
    	starImg:stopAllActions();
    	starImg:setOpacity(255);
        if(i <= starlv) then
        	if(i <= data.star) then
        		-- starImg:setOpacity(255);
        	else
        		-- starImg:setOpacity(0);
        		starImg:runAction(createStarAction());
        	end
            starImg:loadTexture(m_starImgPath[steplv]);
        else
        	local starDisablePath = "";
        	if(steplv <= 5) then
    			starDisablePath = PATH_CCS_RES .. "jingling_xingxingdi_1.png";
    		elseif(steplv == 6) then
    			starDisablePath = PATH_CCS_RES .. "jingling_xingxingdi_2.png";
    		elseif(steplv == 7) then
    			starDisablePath = PATH_CCS_RES .. "jingling_xingxingdi_3.png";
    		end
            starImg:loadTexture(starDisablePath);
        end
    end
end

function stopWeaponStarsAction()
    local STREN_MAX = WeaponCalc.getMaxStrenlv(); --最大强化等级
	for i=1,STREN_MAX do
        local starImg = tolua.cast(m_rootLayout:getWidgetByName("xingxingdi" .. i .. "_img"), "ImageView");
    	starImg:stopAllActions();
    	starImg:setOpacity(255);
    end
end

local m_proNameImg = {
	"",-- 1	力量
	"",-- 2	敏捷
	"",-- 3	耐力
	PATH_CCS_RES .. "jingling_wz_gongjili.png",		-- 4	攻击
	PATH_CCS_RES .. "jingling_wz_fangyuli.png",		-- 5	防御
	PATH_CCS_RES .. "jingling_wz_shengmingzhi.png",	-- 6	生命
	PATH_CCS_RES .. "jingling_wz_suduzhi.png",		-- 7	速度
	PATH_CCS_RES .. "jingling_wz_zhongjizhi.png",	-- 8	重击
	PATH_CCS_RES .. "jingling_wz_baojizhi.png",		-- 9	暴击
	PATH_CCS_RES .. "jingling_wz_fanjizhi.png",		-- 10	反击
	PATH_CCS_RES .. "jingling_wz_gedangzhi.png",	-- 11	格挡
	PATH_CCS_RES .. "jingling_wz_shanbizhi.png",	-- 12	闪避
};
--属性名称图片
function getProNameImgPath(proid)
	return m_proNameImg[proid];
end

local m_charctorNameImg = {
	PATH_CCS_RES .. "jingling_xg_danxiao.png",	-- 1	胆小
	PATH_CCS_RES .. "jingling_xg_yonggan.png",	-- 2	勇敢
	PATH_CCS_RES .. "jingling_xg_jiaohua.png",	-- 3	狡猾
	PATH_CCS_RES .. "jingling_xg_jiaoao.png",	-- 4	骄傲
	PATH_CCS_RES .. "jingling_xg_yongmeng.png",	-- 5	勇猛
	PATH_CCS_RES .. "jingling_xg_canren.png",	-- 6	残忍
	PATH_CCS_RES .. "jingling_xg_shanliang.png",-- 7	善良
	PATH_CCS_RES .. "jingling_xg_leiting.png",	-- 8	雷霆
	PATH_CCS_RES .. "jingling_xg_canbao.png",	-- 9	残暴
	PATH_CCS_RES .. "jingling_xg_baozao.png",	-- 10粗鲁
};
--武器性格名称图片
function getCharactorNameImgPath(characterid)
	return m_charctorNameImg[characterid];
end

--属性
function refreshWeapon_Property()
	local data = m_datas[m_index].data;
	local upstepData = nil;
	--吞噬状态下显示吞噬后增加的属性值(也就是计算吞噬之后武器的等级)
	if(m_status == STATUS_DEVOUR) then
		local afterDevourStarlv = WeaponDevour.calcAfterDevourStarlv();
		upstepData = WeaponCalc.calcWeapon( data, data.step, afterDevourStarlv );
	end
	--攻击力
	local atkLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_jichushanghai_labelNum"), "LabelAtlas");
	atkLabel:setStringValue(data.atk);
	if(upstepData ~= nil) then
    	m_rootLayout:getWidgetByName("upstepAdd_0_panel"):setEnabled(true);
    	tolua.cast(m_rootLayout:getWidgetByName("jw_shuxing_shanghaizengjia0_img"), "LabelAtlas"):setStringValue(upstepData.atk - data.atk);
	else
    	m_rootLayout:getWidgetByName("upstepAdd_0_panel"):setEnabled(false);
	end
	--性格
	local charactorImg = tolua.cast(m_rootLayout:getWidgetByName("jw_xingge1_img"), "ImageView");
	charactorImg:loadTexture(getCharactorNameImgPath(data.character));
	--额外属性
    local PRO_COUNT_MAX = 3;--额外属性数量
    local proIds = Util.strToNumber(Util.Split(data.proId, ";"));
    local proLVs = Util.strToNumber(Util.Split(data.proLV, ";"));
    local proValues = Util.strToNumber(Util.Split(data.proValue, ";"));
    for i=1,PRO_COUNT_MAX do
	    local proNameLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_shuxing" .. i .. "_img"), "ImageView");
	    local proValueLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_shuxing_shanghai" .. i .. "_img"), "LabelAtlas");
	    proNameLabel:loadTexture(getProNameImgPath(proIds[i]));
	    local numberImg,numberImg_W,numberImg_H = GoodsManager.getNumberImg_18(proLVs[i]);
	    proValueLabel:setProperty(proValues[i], numberImg, numberImg_W, numberImg_H, 0);
	    if(upstepData ~= nil) then
	    	m_rootLayout:getWidgetByName("upstepAdd_" .. i .. "_panel"):setEnabled(true);
	    	--升阶增加
    		tolua.cast(m_rootLayout:getWidgetByName("jw_shuxing_shanghaizengjia" .. i .. "_img"), "LabelAtlas"):setStringValue(upstepData.addition[i] - proValues[i]);
	    else
	    	m_rootLayout:getWidgetByName("upstepAdd_" .. i .. "_panel"):setEnabled(false);
	    end
	end
end

--经验
function refreshWeapon_Exp(now, total)
	local expLoadingBar = tolua.cast(m_rootLayout:getWidgetByName("exp_ProgressBar"), "LoadingBar");
	local nowLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_exp_label"), "Label");
	local totalLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_expmax_label"), "Label");

	-- local data = m_datas[m_index].data;
	-- local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. data.step, "exp");
 --    local expDatas = Util.strToNumber(Util.Split(expDataStr, ";"));
	-- nowLabel:setText(data.exp);
	-- totalLabel:setText(expDatas[data.star]);
	nowLabel:setText(now);
	totalLabel:setText(total);

	expLoadingBar:setPercent((now/total)*100.0);
	-- expLoadingBar:setPercent(math.min(100.0, (now/total)*100.0));
end

--基本信息
local function refreshWeaponInfo()
	if(m_datas[m_index] ~= nil) then
		local data = m_datas[m_index].data;
		local id = data.id;
	    local steplv = data.step;
	    local starlv = data.star;
		--图标
		local iconImg = tolua.cast(m_rootLayout:getWidgetByName("jw_jwicon1_img"), "ImageView");
		-- local kuangImg = tolua.cast(m_rootLayout:getWidgetByName("jw_jwicomkuang1_img"), "ImageView");
		-- kuangImg:setEnabled(true);
		iconImg:loadTexture(GoodsManager.getIconPathById(id));
		--星级
		refreshWeapon_Star(starlv);
		--属性
		refreshWeapon_Property();
		--经验
		local expDataStr = DataTableManager.getValue("weapon_grow_exp_Data", "id_" .. steplv, "exp");
	    local expData = Util.strToNumber(Util.Split(expDataStr, ";"));
	    local expTotal = expData[starlv];
	    local exp = data.exp;
		refreshWeapon_Exp(exp, expTotal);
		--其它信息
		refreshWeaponOtherInfo();
	end
end

---------------------------------------武器详细信息end----------------------------------------------------

--设置已装备（调用时机：打开界面、装备武器消息返回）
function setWearedIcon()
	for i=1,#m_datas do
		local item = m_weaponList:getChildByTag(i);
		local wearedImg = tolua.cast(item:getChildByName("wearFlag_img"), "ImageView");
		wearedImg:setEnabled(false);
		if(m_datas[i].index == 0) then
			wearedImg:setEnabled(true);
			return i;
		end
	end
end

--设置选中（调用时机：打开界面、点击武器图标）
local function setSelectIcon(enabled)
	local item = m_weaponList:getChildByTag(m_index);
	local selectImg = tolua.cast(item:getChildByName("select_img"), "ImageView");
	selectImg:setEnabled(enabled);
end

--刷新大背景图
local function refreshBgImg()
	if(m_datas[m_index] ~= nil) then
		local weaponid = m_datas[m_index].data.id;
		local bgImg = tolua.cast(m_rootLayout:getWidgetByName("jw_beijing1_img"), "ImageView");
		local imgName = DataTableManager.getValue("weapon_name_Data", "id_" .. weaponid, "bg");
		local path = PATH_CCS_RES .. imgName .. ".png";
		bgImg:loadTexture(path);
	end
end

--按钮
local function refreshBtnDisplay()
	if(m_isMove) then
		m_btn1:setTouchEnabled(false);
		m_btn2:setTouchEnabled(false);
		m_btn3:setTouchEnabled(false);
	else
		m_btn1:setTouchEnabled(true);
		m_btn2:setTouchEnabled(true);
		m_btn3:setTouchEnabled(true);
	end

	if(m_datas[m_index]) then
		if(m_datas[m_index].index == 0) then
			m_btn3:setTouchEnabled(false);
			m_btn3:loadTextureNormal(PATH_CCS_RES .. "gybtn_zhuangbei_3.png");
			m_btn3:loadTexturePressed(PATH_CCS_RES .. "gybtn_zhuangbei_3.png");
		else
			m_btn3:loadTextureNormal(PATH_CCS_RES .. "gybtn_zhuangbei_1.png");
			m_btn3:loadTexturePressed(PATH_CCS_RES .. "gybtn_zhuangbei_2.png");
		end
	end

	-- if(m_status == STATUS_NORMAL) then
	-- 	m_btn1:setTouchEnabled(true);
	-- 	m_btn2:setTouchEnabled(true);
	-- 	m_btn3:setTouchEnabled(true);
	-- 	m_btn1:loadTextureNormal(PATH_CCS_RES .. "btn_sheng.png");
	-- 	m_btn1:loadTexturePressed(PATH_CCS_RES .. "btn_shengan.png");
	-- 	m_btn2:loadTextureNormal(PATH_CCS_RES .. "btn_tun.png");
	-- 	m_btn2:loadTexturePressed(PATH_CCS_RES .. "btn_tunan.png");
	-- 	m_btn3:loadTextureNormal(PATH_CCS_RES .. "btn_zhuang.png");
	-- 	m_btn3:loadTexturePressed(PATH_CCS_RES .. "btn_zhuangan.png");
	-- elseif(m_status == STATUS_UPSTEP) then
	-- 	m_btn1:setTouchEnabled(false);
	-- 	m_btn2:setTouchEnabled(true);
	-- 	m_btn3:setTouchEnabled(true);
	-- 	m_btn1:loadTextureNormal(PATH_CCS_RES .. "btn_shengbu.png");
	-- 	m_btn1:loadTexturePressed(PATH_CCS_RES .. "btn_shengbu.png");
	-- 	m_btn2:loadTextureNormal(PATH_CCS_RES .. "btn_tun.png");
	-- 	m_btn2:loadTexturePressed(PATH_CCS_RES .. "btn_tunan.png");
	-- 	m_btn3:loadTextureNormal(PATH_CCS_RES .. "btn_zhuang.png");
	-- 	m_btn3:loadTexturePressed(PATH_CCS_RES .. "btn_zhuangan.png");
	-- elseif(m_status == STATUS_DEVOUR) then
	-- 	m_btn1:setTouchEnabled(true);
	-- 	m_btn2:setTouchEnabled(false);
	-- 	m_btn3:setTouchEnabled(true);
	-- 	m_btn1:loadTextureNormal(PATH_CCS_RES .. "btn_sheng.png");
	-- 	m_btn1:loadTexturePressed(PATH_CCS_RES .. "btn_shengan.png");
	-- 	m_btn2:loadTextureNormal(PATH_CCS_RES .. "btn_tunbu.png");
	-- 	m_btn2:loadTexturePressed(PATH_CCS_RES .. "btn_tunbu.png");
	-- 	m_btn3:loadTextureNormal(PATH_CCS_RES .. "btn_zhuang.png");
	-- 	m_btn3:loadTexturePressed(PATH_CCS_RES .. "btn_zhuangan.png");
	-- end
end

function refreshDisplay()
	refreshBgImg();
	refreshWeaponInfo();
	refreshBtnDisplay();
end

----------------------------------------信息刷新----------------------------------------------
--点击武器图标的刷新
local function iconOnClickRefresh()
	if(m_status == STATUS_UPSTEP) then
		WeaponUpstep.refreshInfos();
	elseif(m_status == STATUS_DEVOUR) then
		WeaponDevour.refreshDisplay();
	end
	refreshDisplay();
end

local function goInfoRefresh()
	refreshWeaponInfo();
end

local function goUpstepRefresh()
	refreshWeaponInfo();
	WeaponUpstep.refreshInfos();
end

local function goDevourRefresh()
	WeaponDevour.refreshDisplay();
	refreshWeaponInfo();
end


----------------------------------------------------------------------------------------------


------------------------------------------------界面转换begin-----------------------------------------------------


local function movePanel( node, desPos, time, endcb )
	local moveAction = CCMoveTo:create(time, desPos);
	if(endcb) then
		local callfunc = CCCallFunc:create(endcb);
	    local sequence = CCSequence:createWithTwoActions(moveAction, callfunc);
		node:runAction(sequence);
	else
		node:runAction(moveAction);
	end
end

local function setMoveEnd( isMove )
	m_isMove = isMove;
	refreshBtnDisplay();
end

local function moveEnd2()
	setMoveEnd(false);
end

--点击了主页面的返回按钮
function returnBtnOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		m_isMove = true;
		refreshBtnDisplay();
		if(m_status == STATUS_NORMAL) then
			--关闭界面
			UIManager.close("WeaponUI");
		elseif(m_status == STATUS_UPSTEP) then
			--从升阶-->普通
			movePanel(m_infoPanel, m_pos_2, MOVE_TIME_1);
			movePanel(m_upstepPanel, m_pos_3, MOVE_TIME_1, moveEnd2);
			m_status = STATUS_NORMAL;
			goInfoRefresh();
		elseif(m_status == STATUS_DEVOUR) then
			--从吞噬-->普通
			movePanel(m_infoPanel, m_pos_2, MOVE_TIME_1);
			movePanel(m_devourPanel, m_pos_3, MOVE_TIME_1, moveEnd2);
			m_status = STATUS_NORMAL;
			goInfoRefresh();
		end
	end
end

--升阶
local function btn1OnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		m_isMove = true;
		refreshBtnDisplay();
		local function moveToUpstepEnd()
			moveEnd2();
			goUpstepRefresh();
		end
		if(m_status == STATUS_NORMAL) then
			--普通状态进入升阶界面
			movePanel(m_infoPanel, m_pos_1, MOVE_TIME_1);
			movePanel(m_upstepPanel, m_pos_2, MOVE_TIME_1, moveToUpstepEnd);
			m_status = STATUS_UPSTEP;
		elseif(m_status == STATUS_DEVOUR) then
			--从吞噬状态返回再进入升阶状态
			local function moveEnd()
				movePanel(m_upstepPanel, m_pos_2, MOVE_TIME_1, moveToUpstepEnd);
			end
			movePanel(m_devourPanel, m_pos_3, MOVE_TIME_1, moveEnd);
			m_status = STATUS_UPSTEP;
		elseif(m_status == STATUS_UPSTEP) then
			--升阶-->普通
			movePanel(m_infoPanel, m_pos_2, MOVE_TIME_1);
			movePanel(m_upstepPanel, m_pos_3, MOVE_TIME_1, moveEnd2);
			m_status = STATUS_NORMAL;
		end
	end
end

--吞噬
function btn2OnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		m_isMove = true;
		refreshBtnDisplay();
		local function moveToDevourEnd()
			moveEnd2();
			goDevourRefresh();
		end
		if(m_status == STATUS_NORMAL) then
			--普通状态进入吞噬界面
			movePanel(m_infoPanel, m_pos_1, MOVE_TIME_1);
			movePanel(m_devourPanel, m_pos_2, MOVE_TIME_1, moveToDevourEnd);
			m_status = STATUS_DEVOUR;
		elseif(m_status == STATUS_UPSTEP) then
			--从升阶状态返回再进入吞噬状态
			local function moveEnd()
				movePanel(m_devourPanel, m_pos_2, MOVE_TIME_1, moveToDevourEnd);
			end
			movePanel(m_upstepPanel, m_pos_3, MOVE_TIME_1, moveEnd);
			m_status = STATUS_DEVOUR;
		elseif(m_status == STATUS_DEVOUR) then
			--从吞噬-->普通
			movePanel(m_infoPanel, m_pos_2, MOVE_TIME_1);
			movePanel(m_devourPanel, m_pos_3, MOVE_TIME_1, moveEnd2);
			m_status = STATUS_NORMAL;
			goInfoRefresh();
		end
	end
end

function upstepEndRefresh()
    refreshCurData();
    refreshDisplay();
end




local m_lastData = nil;

local function resetCurIndex()
	if(m_lastData) then
		for i=1,#m_datas do
			local data = m_datas[i].data;
			if(data.id == m_lastData.id and data.atkPer == m_lastData.atkPer and data.character == m_lastData.character) then
				if(data.proId == m_lastData.proId and data.proLV == m_lastData.proLV) then
					m_index = i;
					return;
				end
			end
		end
	else
		m_index = 1;
	end
end

function devourEndRefresh()
	local data = getCurData();
	m_lastData = {};
	m_lastData.id = data.id;
	m_lastData.atkPer = data.atkPer;
	m_lastData.character = data.character;
	m_lastData.proId = data.proId;
	m_lastData.proLV = data.proLV;

	refreshDatas();
	refreshWeaponList(true);
	resetCurIndex();
	-- refreshDisplay();

	setSelectIcon(true);
	setWearedIcon();
end

local function wearEndRefresh()
    ProgressRadial.close();
	refreshDatas();
	refreshWeaponList(true);
	m_index = setWearedIcon();
	setSelectIcon(true);
	refreshBtnDisplay();

	if(m_status == STATUS_DEVOUR) then
		WeaponDevour.refreshDisplay();
	end
end

-- 装备武器返回 1721
local function onReceiveWearResponse(messageType, messageData)
    local result = messageData.result;
    if(result == 1) then
    	wearEndRefresh(); 
    else
        if(result == 2) then
            Util.showOperateResultPrompt("等级不足");
        end
    end
end

-- 替换返回 1723
local function onReceiveReplaceResponse(messageType, messageData)
    local result = messageData.result;
	wearEndRefresh();
end

--装备
function btn3OnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
        local wearedWeapon = UserInfoManager.getRoleInfo("weapon");
    	local typeid = GoodsManager.getGoodsHighTypeId(m_datas[m_index].data.id);
        if(wearedWeapon.id > 0) then
			--替换武器
        	local partid = GoodsManager.getWeaponPartid();
	        local msg = {typeid, m_datas[m_index].index, partid};
	        ProgressRadial.open();
	        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_REPLACEFIGUREEQUIP, msg);
        else
			--装备武器
	        local msg = {typeid, m_datas[m_index].index};
	        ProgressRadial.open();
	        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MOVEBPTOFIGURE, msg);
        end
	end
end


------------------------------------------------界面转换end-------------------------------------------------------

--消亡提示
local function removeNote()
	local data = m_datas[m_index].data;
	if(data.isNew ~= nil and data.isNew == true) then
		data.isNew = false;
		--提示红点消失
	end
end


--武器icon点击
function iconOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local index = sender:getTag();
		if(m_index ~= index) then
			removeNote();
			setSelectIcon(false);
			m_index = index;
			setSelectIcon(true);
			iconOnClickRefresh();
		end
	end
end

--武器icon列表
function refreshWeaponList(clean)
	if(clean) then
		m_weaponList:removeAllItems();
	end
	-- m_wearedArmature:removeFromParentAndCleanup(false);
	local count = #m_datas;
	for i=1,count do
		local item = nil;
		if(clean) then
			item = m_weaponIconItem:clone();
			item:addTouchEventListener(iconOnClick);
		else
			item = m_weaponList:getChildByTag(i);
		end
		item:setTag(i);
		local data = m_datas[i];
		local iconImg = tolua.cast(item:getChildByName("icon_img"), "ImageView");
		local selectImg = tolua.cast(item:getChildByName("select_img"), "ImageView");
		local wearedImg = tolua.cast(item:getChildByName("wearFlag_img"), "ImageView");
		iconImg:loadTexture(GoodsManager.getIconPathById(data.data.id));
		selectImg:setEnabled(false);
		wearedImg:setEnabled(false);
		if(clean) then
			m_weaponList:pushBackCustomItem(item);
		end


		--提示
		local function giveNote()
			-- body
		end
		local canNote = false;
		if(data.data.isNew ~= nil and data.data.isNew == true) then
			canNote = true;
			print("****** 提示 this weapon is new,      id = " .. data.data.id);
		end
		if(canNote) then
			giveNote();
		else
			if(WeaponUpstep.checkCanUpstep(data.data) == 1) then
				giveNote();
			end
		end
	end

	--数量
	local haveCountLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_list_num1_label"), "Label");
	local totalCountLabel = tolua.cast(m_rootLayout:getWidgetByName("jw_list_num2_label"), "Label");
	haveCountLabel:setText(count);
	totalCountLabel:setText(WeaponCalc.getMaxWeaponCount());
end

function refreshCurData()
	local index = m_datas[m_index].index;
	local newData = {}
	newData.index = index;
	if(index == 0) then
		newData.data = UserInfoManager.getRoleInfo("weapon");
	else
		local datasrc = UserInfoManager.getBackPackInfo("weapon");
		newData.data = datasrc[index];
	end
	m_datas[m_index] = newData;
end

--读取武器数据，重新排序存放到当前数据中
function refreshDatas()
	m_datas = {};
	--已装备的武器
	local isWeared = false;
	local wearedWeapon = UserInfoManager.getRoleInfo("weapon");
	if(wearedWeapon.id > 0) then
		isWeared = true;
		local data = {};
		data.index = 0;
		data.data = wearedWeapon;
		data.level = WeaponCalc.getMaxStrenlv()*(wearedWeapon.step - 1) + wearedWeapon.star;
		m_datas[1] = data;
	end

	local datasrc = UserInfoManager.getBackPackInfo("weapon");
	local count = #datasrc;
	for i=1,count do
		local data = {};
		data.index = i;
		data.data = datasrc[i];
		data.level = WeaponCalc.getMaxStrenlv()*(datasrc[i].step - 1) + datasrc[i].star;
		if(isWeared) then
			m_datas[i + 1] = data;
		else
			m_datas[i] = data;
		end
	end

	--按照武器品阶排序
	count = #m_datas;
	local exchange
    for i=1,count-1 do
        exchange = false
        for j=1,count-i do
            if(m_datas[j].level < m_datas[j + 1].level) then
            	m_datas[j], m_datas[j + 1] = m_datas[j + 1], m_datas[j];
            	exchange = true;
            end
        end
        if exchange == false then
            break
        end
    end
end

local function initPos()
	m_infoPanel:setPosition(m_pos_2);
	m_upstepPanel:setPosition(m_pos_3);
	m_devourPanel:setPosition(m_pos_3);
end

local function openInit()
	m_status = STATUS_NORMAL;
	m_index = 1;
	m_isMove = false;
	initPos();
	refreshDatas();
	refreshWeaponList(true);
	refreshDisplay();
	setSelectIcon(true);
	setWearedIcon();
end

function setButtonsTouchEnabled( enable )
	m_btn1:setTouchEnabled(enable);
	m_btn2:setTouchEnabled(enable);
	m_btn3:setTouchEnabled(enable);
	-- m_rootLayout:getWidgetByName("return_img"):setTouchEnabled(enable);
end


local function boundListener()
	m_rootLayout:getWidgetByName("return_img"):addTouchEventListener(returnBtnOnClick);
	m_btn1 = tolua.cast(m_rootLayout:getWidgetByName("jw_btn_1"), "Button");
	m_btn2 = tolua.cast(m_rootLayout:getWidgetByName("jw_btn_2"), "Button");
	m_btn3 = tolua.cast(m_rootLayout:getWidgetByName("jw_btn_3"), "Button");
	m_btn1:addTouchEventListener(btn1OnClick);
	m_btn2:addTouchEventListener(btn2OnClick);
	m_btn3:addTouchEventListener(btn3OnClick);
end

-------------------------------------------------------------------------------------------------------------
local m_wearedArmatureJsonPath = PATH_RES_OTHER .. "WearWeaponFlag.ExportJson";
local m_wearedArmatureResPath  = PATH_RES_OTHER .. "WearWeaponFlag0.png";
local function loadWearedArmature()
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_wearedArmatureJsonPath);
    m_wearedArmature = CCArmature:create("WearWeaponFlag");
    -- m_wearedArmature:setScale(0.8)
    m_wearedArmature:getAnimation():playWithIndex(0);
    m_wearedArmature:setPosition(ccp(0,0));
    m_wearedArmature:retain();
    CCArmatureDataManager:purge();
end
local function removeWearedArmature()
	m_wearedArmature:removeFromParentAndCleanup(true);
	m_wearedArmature = nil;
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(m_wearedArmatureJsonPath);
	CCTextureCache:sharedTextureCache():removeTextureForKey(m_wearedArmatureResPath);
end
-------------------------------------------------------------------------------------------------------------


local function registerMessage()
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MOVEBPTOFIGURERESPONSE, onReceiveWearResponse);--装备返回
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REPLACEFIGUREEQUIPRESPONSE, onReceiveReplaceResponse);
end

local function unregisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_MOVEBPTOFIGURERESPONSE, onReceiveWearResponse);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_REPLACEFIGUREEQUIPRESPONSE, onReceiveReplaceResponse);
end

function create()
    if(not m_isCreate) then
    	m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		
	    m_rootLayout = TouchGroup:create();
	    m_rootLayer:addChild(m_rootLayout);
	    m_rootLayout:retain();

		local rootPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "jingwu_1.json");
	    m_rootLayout:addWidget(rootPanel);

	    m_weaponIconItem = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "jw_list_1.json");
	    m_weaponIconItem:retain();

	    m_weaponList = tolua.cast(m_rootLayout:getWidgetByName("weapon_list"), "ListView");

		m_infoPanel = m_rootLayout:getWidgetByName("info_img");
		m_upstepPanel = m_rootLayout:getWidgetByName("shengjie_panel");
		m_devourPanel = m_rootLayout:getWidgetByName("tunshi_panel");
	    -- loadWearedArmature();

	    boundListener();
	    registerMessage();
    end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;

        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);

        openInit();
        refreshDisplay();

        WeaponDevour.open(m_rootLayout);
        WeaponUpstep.open(m_rootLayout);
        AncientMaterialItem.setCallBack(function() UIManager.close("WeaponUI"); end);
	end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        ProgressRadial.close();
        if(WeaponDevour.isLoading()) then
        	WeaponDevour.weaponExpUpOk();
        end
        WeaponUpstep.close();
        WeaponDevour.close();
        NotificationManager.onCloseCheck("WeaponUI");
        NotificationManager.onCloseCheck("Wardrobe");
    end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
	    if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    	m_rootLayer = nil;
	    end
	    m_rootLayout:release();
	   	m_rootLayout = nil;
	   	m_weaponIconItem:release();
	   	m_weaponIconItem = nil;
	   	-- removeWearedArmature();
	   	unregisterMessage();
	end
end