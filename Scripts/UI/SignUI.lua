module("SignUI", package.seeall)

local m_rootLayer = nil;
local m_uiLayer   = nil;
local m_isCreate  = false;
local m_isOpen	  = false;
local m_item 	  = nil;
local m_data	  = nil;
local m_haveSign  = true;--是否签到
local m_armature  = nil;
local m_infoPanel = nil;
local m_vipTishiPanel = nil;
local m_isVipShow = false;

local SIGN_COUNT  		= 28;
local TAG_BASE    		= 953;
local SIGN_TOTAL_COUNT	= 4;--累积签到奖励物品最大数量

local m_lastSignData = nil; --上次签到物品
local m_lastSignTotalData = nil; --上次累积签到奖励物品

function canSignToday()
	local datas = UserInfoManager.getRoleInfo("sign");
	local signdatas = datas.signDatas;
	for i,v in ipairs(signdatas) do
		if(v.status == 1) then
			return true;
		end
	end

	if(datas.signTotalInfo.canReceive == 0) then
		return true;
	end
	return false;
end

--登录检测
function checkNotification_login()
	return canSignToday();
end

--线上检测
function checkNotification_line()
	return checkNotification_login();
end

--关闭检测
function checkNotification_close()
	return checkNotification_login();
end




function isOpen()
	return m_isOpen;
end

local function exitTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("SignUI");
	end
end

local function closeVipPanel( sender,eventType )
	if(eventType ~= nil) then
		if(eventType == TOUCH_EVENT_TYPE_END) then
			m_vipTishiPanel:removeFromParentAndCleanup(false);
		end
	else
		m_vipTishiPanel:removeFromParentAndCleanup(false);
	end
end

local function closeInfoPanel( sender,eventType )
	if(eventType ~= nil) then
		if(eventType == TOUCH_EVENT_TYPE_END) then
			m_infoPanel:removeFromParentAndCleanup(false);
		end
	else
		m_infoPanel:removeFromParentAndCleanup(false);
	end
end

local function showInfo( id )
	local titleImg = m_infoPanel:getChildByName("xianshi_tou_img");
	local nameLabel = tolua.cast(titleImg:getChildByName("wupenzi_label"), "Label");
	local iconImg = tolua.cast(m_infoPanel:getChildByName("icon_img"), "ImageView");
	local colorImg = tolua.cast(m_infoPanel:getChildByName("bgIcon_img"), "ImageView");
	local descLabel = tolua.cast(m_infoPanel:getChildByName("desc_label"), "Label");
	local baseInfo = GoodsManager.getBaseInfo(id);
	nameLabel:setText(baseInfo.name);
	iconImg:loadTexture(baseInfo.icon);
	colorImg:loadTexture(baseInfo.frameIcon);
	descLabel:setText(baseInfo.desc);
	m_uiLayer:addWidget(m_infoPanel);
end

--点击累积签到奖励物品
local function signTotalGoodsOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local index = sender:getTag();
		showInfo(m_data.signTotalGoods[index].id);
	end
end

local function itemOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local index = sender:getTag() - TAG_BASE;
		local data = m_data.signDatas[index];

		local function sign(sender,eventType)
			local canSign = false;
			if(eventType ~= nil) then
				if(eventType == TOUCH_EVENT_TYPE_END) then
					if(m_isVipShow) then
						closeVipPanel();
						m_isVipShow = false;
					end
					canSign = true;
				end
			else
				canSign = true;
			end
			if(canSign) then
				if(GoodsManager.isBackpackFull_2()) then
					--背包满提示
					BackpackFullTishi.show();
				else
					--继续
					m_lastSignData = Util.deepcopy(data);
					ProgressRadial.open();
					NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_SIGNOK, {});
				end
			end
		end
		--进入充值页面
		local function gotoRecharge(sender,eventType)
			if(eventType == TOUCH_EVENT_TYPE_END) then
				closeVipPanel();
			end
		end

		if(data.status == 1) then
			if(data.viplevel > 0) then
				if(UserInfoManager.getRoleInfo("vipLv") < data.viplevel) then
					m_vipTishiPanel:getChildByName("lingqv_btn"):addTouchEventListener(sign);
					m_vipTishiPanel:getChildByName("couzhi_btn"):addTouchEventListener(gotoRecharge);
					m_uiLayer:addWidget(m_vipTishiPanel);
					m_isVipShow = true;
				else
					sign();
				end
			else
				sign();
			end
		else
			--显示信息
			showInfo(data.id);
		end
	end
end


--刷新累计签到信息
local function refreshSignTotal()
	local info = m_data.signTotalInfo;
	local totalSignedDayLabelAtlas = tolua.cast(m_uiLayer:getWidgetByName("qiandao_labelNum"), "LabelAtlas");
	local totalSignTypeImg = tolua.cast(m_uiLayer:getWidgetByName("7tian_img"), "ImageView");
	local canReceiveBtn = tolua.cast(m_uiLayer:getWidgetByName("lingqv_btn"), "Button");
	totalSignedDayLabelAtlas:setStringValue(info.totalSignDay);
	totalSignTypeImg:loadTexture(PATH_CCS_RES .. "qiandao_" .. info.rewardType .. ".png");
	canReceiveBtn:setTouchEnabled(info.canReceive == 0);
	if(info.canReceive == 0) then
		canReceiveBtn:loadTextureNormal(PATH_CCS_RES .. "qiandao_btn_lingqu_1.png");
		canReceiveBtn:loadTexturePressed(PATH_CCS_RES .. "qiandao_btn_lingqu_2.png");
	else
		canReceiveBtn:loadTextureNormal(PATH_CCS_RES .. "qiandao_btn_lingqu_3.png");
		canReceiveBtn:loadTexturePressed(PATH_CCS_RES .. "qiandao_btn_lingqu_3.png");
	end

	local goods = m_data.signTotalGoods;
	for i=1,SIGN_TOTAL_COUNT do
		local panel = m_uiLayer:getWidgetByName("7_lji" .. i .. "_panel");
		if(goods[i] ~= nil) then
			panel:setEnabled(true);
			panel:setTag(i);
			panel:addTouchEventListener(signTotalGoodsOnClick);
			local id = goods[i].id;
			local count = goods[i].count;
			tolua.cast(panel:getChildByName("wupen_lji_img"), "ImageView"):loadTexture(GoodsManager.getIconPathById(id));
			tolua.cast(panel:getChildByName("kuang_lji_img"), "ImageView"):loadTexture(GoodsManager.getColorBgByGoodid(id));

			local moneyCountAtlas = tolua.cast(panel:getChildByName("huobi_labelNum"), "LabelAtlas");
			local chenghao = panel:getChildByName("x_img");
			local countAtlas = tolua.cast(panel:getChildByName("wupen_labelNum"), "LabelAtlas");
			moneyCountAtlas:setEnabled(false);
			chenghao:setEnabled(false);
			countAtlas:setEnabled(false);
			if(GoodsManager.isSelf(id)) then
				moneyCountAtlas:setEnabled(true);
				moneyCountAtlas:setStringValue(count);
			else
				chenghao:setEnabled(true);
				countAtlas:setEnabled(true);
				countAtlas:setStringValue(count);
			end
		else
			panel:setEnabled(false);
		end
	end
end

--刷新签到列表
local function refreshSignList()
	if(not m_haveSign) then
		m_haveSign = true;
		m_armature:removeFromParentAndCleanup(true);
		m_armature = nil;
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(PATH_RES_OTHER .. "guangquan.ExportJson");
		CCTextureCache:sharedTextureCache():removeTextureForKey(PATH_RES_OTHER .. "guangquan0.png");
		if(m_lastSignData) then
			--给出签到奖励提示
			local text = GoodsManager.getNameById(m_lastSignData.id) .. "×" .. m_lastSignData.count;
			Util.showOperateResultPrompt(text);
		end
	end
	local datas = m_data.signDatas;
	for i,v in ipairs(datas) do
		local id = v.id;
		local count = v.count;
		local status = v.status;
		local viplv = v.viplevel;
		local item = m_uiLayer:getWidgetByTag(TAG_BASE + i);
		tolua.cast(item:getChildByName("wupeng_img"), "ImageView"):loadTexture(GoodsManager.getIconPathById(id));
		tolua.cast(item:getChildByName("kuang_img"), "ImageView"):loadTexture(GoodsManager.getColorBgByGoodid(id));
		tolua.cast(item:getChildByName("qiandao_img"), "ImageView"):setEnabled(status == -1);
		local vipPanel = tolua.cast(item:getChildByName("vip_panel"), "Layout");
		if(viplv > 0) then
			vipPanel:setEnabled(true);
			local vipImg = tolua.cast(vipPanel:getChildByName("vip_img"), "ImageView");
			vipImg:loadTexture(PATH_CCS_RES .. "qiandao_v" .. viplv .. ".png");
		else
			vipPanel:setEnabled(false);
		end

		local moneyCountAtlas = tolua.cast(item:getChildByName("huobi_labelNum"), "LabelAtlas");
		local chenghao = item:getChildByName("x_img");
		local countAtlas = tolua.cast(item:getChildByName("wupen_labelNum"), "LabelAtlas");
		moneyCountAtlas:setEnabled(false);
		chenghao:setEnabled(false);
		countAtlas:setEnabled(false);

		if(GoodsManager.isSelf(id)) then
			moneyCountAtlas:setEnabled(true);
			moneyCountAtlas:setStringValue(count);
		else
			chenghao:setEnabled(true);
			countAtlas:setEnabled(true);
			countAtlas:setStringValue(count);
		end

		if(status == 1) then
			m_haveSign = false;
			--今日可签的动画
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_OTHER .. "guangquan.ExportJson");
			m_armature = CCArmature:create("guangquan");
			m_armature:setPosition(ccp(48, 43));
		    m_armature:getAnimation():playWithIndex(0);
		    item:addNode(m_armature);
		end
	end
end

function refreshInfo()
	ProgressRadial.close();
	m_data = UserInfoManager.getRoleInfo("sign");
	refreshSignList();
	refreshSignTotal();
end

local function openInit()
	m_haveSign = true;
	m_isVipShow = false;
	m_data = UserInfoManager.getRoleInfo("sign");
	refreshInfo();
end

local function createItems()
	for i=1,SIGN_COUNT do
		local item = m_item:clone();
		local panel = m_uiLayer:getWidgetByName(i .. "_wupen_panel");
		panel:addChild(item);
		item:setTag(i + TAG_BASE);
		item:addTouchEventListener(itemOnClick);
	end
end


--点击领取累积签到
local function signTotalOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END)then
		if(GoodsManager.isBackpackFull_2()) then
			--背包满提示
			BackpackFullTishi.show();
		else
			--继续
			m_lastSignTotalData = Util.deepcopy(m_data.signTotalGoods);
			ProgressRadial.open();
			NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_SIGNTOTAL, {});
		end
	end
end

--领取累积签到奖励返回
local function onReceiveSignTotalResponse( messageType, messageData )
	ProgressRadial.close();
	local result = messageData.result;
	m_data = UserInfoManager.getRoleInfo("sign");
	refreshSignTotal();
	if(m_lastSignTotalData ~= nil) then
		RewardsManager.onReceiveRewards(nil, m_lastSignTotalData);
	end
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "CumulativeUi_1.json");
		panel:addTouchEventListener(exitTouchEvent);
		m_uiLayer = TouchGroup:create();
		m_uiLayer:addWidget(panel);
		m_rootLayer:addChild(m_uiLayer);

		m_item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "qiandaowupenUi.json");
		m_item:retain();
		createItems();

		m_infoPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Cumulative_xiansiUi_1.json");
		m_infoPanel:addTouchEventListener(closeInfoPanel);
		m_infoPanel:retain();

		m_vipTishiPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Cumulative_tisUi_1.json");
		m_vipTishiPanel:addTouchEventListener(closeVipPanel);
		m_vipTishiPanel:retain();

		m_uiLayer:getWidgetByName("lingqv_btn"):addTouchEventListener(signTotalOnClick);
		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SIGNTOTALRESPONSE, onReceiveSignTotalResponse);
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
		openInit();

		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
        NotificationManager.onCloseCheck("SignUI");
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		m_item:release();
		m_item = nil;
		m_infoPanel:release();
		m_infoPanel = nil;
		m_vipTishiPanel:release();
		m_vipTishiPanel = nil;

		NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_SIGNTOTALRESPONSE, onReceiveSignTotalResponse);
	end
end