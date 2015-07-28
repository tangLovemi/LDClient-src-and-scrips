module("TrainUI", package.seeall)

require "UI/Train/TrainMgr"
require "UI/Train/TrainReport"
require "UI/Train/TrainBuffDesc"
require "UI/Train/TrainBless"
require "UI/Train/TrainHelp"
require "UI/Train/TrainRobSeatSuccess"
require "UI/Train/TrainFight"
require "UI/Train/TrainBuyFightCountDesc"

require "UI/CoolingTime"

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;

local m_lastRobCountLabel = nil; --剩余抢夺次数
local m_trainTimeNameLabel = nil;
local m_trainTimeLabel = nil; -- 剩余训练时间
local m_blesstimeNameLabel = nil;
local m_blesstimeLabel = nil; -- 剩余祝福时间
local m_expLabel = nil; -- 每分钟获得经验
local m_posLabel = nil; -- 我的位置

local m_stopTrainBtnDescImg = nil; -- 停止训练图片
local m_perTrainBtnDescImg = nil; --开始个人训练图片

local m_kingSeatPanel_1 = nil;  --组别0的面板
local m_kingSeatPanel_2 = nil;  --组别1的面板
local m_kingSeatPanel_3_6 = nil;--组别2以上的面板
local m_kingSeatPage2 = nil;
local m_page = nil;
local m_kingSeat1Panels = {};
local m_kingSeat2Panels = {};
local m_groupSeatCount = {};
local m_seatItem = nil;

local m_perData = {};
local m_seatDatas = {};
local m_expContainer = nil;
local m_totalCount = 0;
local m_curPageIndex = 0; --当前页索引
local m_pageCount = 0; --当前内存page数量
local COUNT_ONE_PAGE = 9; -- 一页数量
local m_totalPage = 0;

local STATUS_NO_TRAIN 	= 1; --无训练
local STATUS_PER_TRAIN 	= 2; --个人训练
local STATUS_KING_TRAIN = 3; --王者训练

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_countDown_schedule = nil;


local text = {
	stopPerTrain = "您正在个人训练，是否终止",
	stopKingTrain = "您正在王者训练，是否终止",
};

local m_headScale_x = 1;
local m_headScale_y = 1;
local m_headPos = nil;

function getHeadScale()
	return m_headScale_x, m_headScale_y;
end

function getHeadPos()
	return m_headPos;
end

function getCurPageIndex()
	return m_curPageIndex;
end

local function onTouch(eventType,x,y)
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		UIManager.close("TrainUI");
	end
end

local function closeOnTouch( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		UIManager.close("TrainUI");
	end
end

function getPersonalData()
	return m_perData;
end

--得到某座位的玩家信息
function getSeatsData(seatid)
	return m_seatDatas[seatid%COUNT_ONE_PAGE];
end


------------------------------------------------------------------------0---


--buff点击
local function buffBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END  then
		TrainBuffDesc.open();
	end
end

--查看战报
local function reportBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END  then
		TrainReport.open();
	end
end

--祝福
local function blessPanelOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END  then
		TrainBless.open();
	end
end

local function stopTrainYes()
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_START_PERTRAIN, {0, m_perData.statusId, m_curPageIndex});
	TrainMgr.open();
	UIManager.close("ErrorDialog");
end

--开始或终止个人训练
local function perTrainBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END  then
		if(m_perData.statusId == STATUS_NO_TRAIN) then
			NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_START_PERTRAIN, {1, m_perData.statusId});
			TrainMgr.open();
		else
			local txt = "";
			if(m_perData.statusId == STATUS_PER_TRAIN) then
				txt = text.stopPerTrain;
			elseif(m_perData.statusId == STATUS_KING_TRAIN) then
				txt = text.stopKingTrain;
			end

			UIManager.open("ErrorDialog");
			local funs = {};
			table.insert(funs,function () UIManager.close("ErrorDialog"); end);
			table.insert(funs,stopTrainYes);
			ErrorDialog.setPanelStyle(txt,funs);
		end
	end
end

--购买抢夺数量
local function buyPanelOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END  then
		TrainBuyFightCountDesc.open();
	end
end

--帮助
local function helpBtnOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END  then
		TrainHelp.open();
	end
end

--申请座位返回
function applySeatEnd( resultid, index )
	if(resultid == 1) then
		--占座成功
		TrainRobSeatSuccess.open();
	elseif(resultid == 2) then
		--此座位有人
		TrainFight.open(index);
	end
end

local RESULT_NEED_REFRSH = 17;
function startStopTrainResponse( resultid )
	if(resultid == RESULT_NEED_REFRSH) then

	end
end

local RESULT_APPLY_SEAT_OK  = 13;
local RESULT_ROB_COUNT_NO	= 14;
local RESULT_APPLY_SEAT_HAVE_ROB = 12;
--抢夺请求返回
function robSeat( index, resultId )
	if(resultId == RESULT_APPLY_SEAT_OK) then
	    UIManager.close("TrainUI");
	    MainCityLogic.enterBattle(2, 5, index);
    elseif(resultId == RESULT_ROB_COUNT_NO) then
    	TrainFight.close();
    	TrainBuyFightCountDesc.open();
    elseif(resultId == RESULT_APPLY_SEAT_HAVE_ROB)then
    	--正被挑战
	end
end

local function refreshExpPerMin()
	if(m_perData.statusId == STATUS_NO_TRAIN) then
		m_expLabel:setText("0");
	elseif(m_perData.statusId == STATUS_PER_TRAIN) then
		m_expLabel:setText(m_perData.nowPerExp);
	elseif(m_perData.statusId == STATUS_KING_TRAIN) then
		m_expLabel:setText(m_perData.nowKingExp);
	end
end

local m_groupBgImg = {
	PATH_CCS_RES .. "xunlianchang_tu_7.png",
	PATH_CCS_RES .. "xunlianchang_tu_6.png",
	PATH_CCS_RES .. "xunlianchang_tu_5.png",
	PATH_CCS_RES .. "xunlianchang_tu_4.png",
	PATH_CCS_RES .. "xunlianchang_tu_3.png",
	PATH_CCS_RES .. "xunlianchang_tu_2.png",
	PATH_CCS_RES .. "xunlianchang_tu_1.png",
};

local function refreshMyPos()
	local status_img = tolua.cast(m_uiLayer:getWidgetByName("status_img"), "ImageView");
	if(m_perData.statusId == STATUS_PER_TRAIN or m_perData.statusId == STATUS_NO_TRAIN) then
		status_img:loadTexture(IMAGE_PATH.TRAIN_NO);
	else
		status_img:loadTexture(m_groupBgImg[m_perData.jjcGroupid + 1]);
	end
end





local function refreshPagePos()
	tolua.cast(m_uiLayer:getWidgetByName("page_label"), "Label"):setText(m_curPageIndex .. "/" .. m_totalPage);
end



----------------------------------------------------------------------------


-- 点击房间列表项
local function seatTouchEvent( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
        local index = sender:getTag();
        local selfName = UserInfoManager.getRoleInfo("name");
        local curSeatData = m_seatDatas[index];

        if(curSeatData ~= nil and curSeatData.name == selfName) then
        	return;
        else
        	local msg = {};
        	local seatid = COUNT_ONE_PAGE*(m_curPageIndex - 1) + index;
        	msg[1] = seatid;
        	-- short	座位index	
        	-- byte	本地座位状态	
        	-- string	该位置玩家uuid
	        if(curSeatData == nil) then
	        	--空座位
	        	msg[2] = 0;
	        	msg[3] = "null";
	        else
	        	--此座有人
	        	msg[2] = 1;
	        	msg[3] = curSeatData.id;
	        end
	        msg[4] = m_curPageIndex;
			ProgressRadial.open();
	        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_CLICK_KINGSEAT, msg);
        end
    end
end





--各分组座位的底图
local m_seatBg = {
	PATH_CCS_RES .. "xunlianchang_zu_1.png",
	PATH_CCS_RES .. "xunlianchang_zu_2.png",
	PATH_CCS_RES .. "xunlianchang_zu_3.png",
	PATH_CCS_RES .. "xunlianchang_zu_4.png",
	PATH_CCS_RES .. "xunlianchang_zu_5.png"
};

local function initSeatItemInfo( page )
	for i=1,COUNT_ONE_PAGE do
		local panel = page:getChildByName("seat_panel_" .. i);
		panel:setTag(i);
		panel:addTouchEventListener(seatTouchEvent);
		tolua.cast(panel:getChildByName("name_label"), "Label"):setText("");
		tolua.cast(panel:getChildByName("level_label"), "Label"):setText("");
		tolua.cast(panel:getChildByName("time_label"), "Label"):setText("--:--:--");
		panel:getChildByName("head_panel"):removeAllNodes();
		panel:getChildByName("head_panel"):setEnabled(false);
		if(m_perData.jjcGroupid > 1) then
			local bgImg = tolua.cast(panel:getChildByName("bg_img"), "ImageView");
			bgImg:loadTexture(m_seatBg[m_perData.jjcGroupid + 1]);
		end
	end
end

local function addPage( pageIndex, index )
	local item = tolua.cast(m_seatItem:clone(), "Layout");
	initSeatItemInfo(item);
	item:setTag(pageIndex);
	m_page:insertPage(item, index - 1);
	m_pageCount = m_pageCount + 1;
end

local function removePage( pageIndex, index )
	m_page:removePageAtIndex(index - 1);
	m_pageCount = m_pageCount - 1;
end

--滑动
local m_curIndex = 0;
function PageViewEventListener( sender,eventType )
	local index = m_page:getCurPageIndex() + 1;
	if(m_curIndex ~= index) then
		if(index > m_curIndex) then
			--左滑
			m_curPageIndex = m_curPageIndex + 1;
			if(m_curPageIndex == 2) then
				addPage(m_curPageIndex + 1, 3);
			else
				if(m_curPageIndex < m_totalPage) then
					addPage(m_curPageIndex + 1, 3);
				end
				removePage(m_curPageIndex - 2, 1);
			end
			m_curIndex = 2;
			m_page:setCurPageIndex(1);
			m_page:resetPosition();
		else
			--右滑
			m_curPageIndex = m_curPageIndex - 1;
			if(m_curPageIndex == 1) then
				removePage(m_curPageIndex + 2, 3);
				m_curIndex = 1;
				m_page:setCurPageIndex(0);
			else
				addPage(m_curPageIndex - 1, 1);
				if(m_curPageIndex < m_totalPage - 1) then
					removePage(m_curPageIndex + 2, 3);
				end
				m_curIndex = 2;
				m_page:setCurPageIndex(1);
			end
			m_page:resetPosition();
		end
		requestCurPageInfos();
		refreshPagePos();
	end
end


function getGroupSeatBg(group)
	return m_seatBg[group];
end

local function attachSeatItemInfo( page )
	for i=1,COUNT_ONE_PAGE do
		local data = m_seatDatas[i];
		if(data ~= nil) then
			local panel = page:getChildByName("seat_panel_" .. i);
			--名称
			local nameLable = tolua.cast(panel:getChildByName("name_label"), "Label");
			local selfName = UserInfoManager.getRoleInfo("name");
			if(data.name == selfName) then
				nameLable:setText("self");
			else
				nameLable:setText(data.name);
			end
			--级别
			tolua.cast(panel:getChildByName("level_label"), "Label"):setText(data.level);
			--脸部信息
			local face = Util.createHeadNode(data.hair, data.haircolor, data.face, data.coat);
			local headPanel = tolua.cast(panel:getChildByName("head_panel"), "Layout");
			headPanel:setEnabled(true);
			headPanel:removeAllNodes();
			face:setScaleX(m_headScale_x);
			face:setScaleY(m_headScale_y);
			face:setPosition(m_headPos);
			headPanel:addNode(face);
		end
	end
end


local function initSeatPanel()
	m_totalPage = 1;
	m_totalCount = m_groupSeatCount[m_perData.jjcGroupid + 1];
	m_kingSeatPanel_1:setEnabled(false);
	m_kingSeatPanel_2:setEnabled(false);
	m_kingSeatPanel_3_6:setEnabled(false);
	if(m_perData.jjcGroupid == 0) then
		m_kingSeatPanel_1:setEnabled(true);
		COUNT_ONE_PAGE = m_groupSeatCount[1];
		initSeatItemInfo(m_kingSeatPanel_1);
	elseif(m_perData.jjcGroupid == 1) then
		m_kingSeatPanel_2:setEnabled(true);
		COUNT_ONE_PAGE = m_groupSeatCount[2];
		initSeatItemInfo(m_kingSeatPage2);
	else
		COUNT_ONE_PAGE = 9;
		m_totalPage = m_totalCount/COUNT_ONE_PAGE;
		if(m_totalCount%COUNT_ONE_PAGE ~= 0) then
			m_totalPage = math.floor(m_totalCount/COUNT_ONE_PAGE) + 1;
		end
		m_kingSeatPanel_3_6:setEnabled(true);
		addPage(1, 1);
		addPage(2, 2);
	end
	refreshPagePos();
end

local function getCurPageItem()
	if(m_perData.jjcGroupid == 0) then
		return m_kingSeatPanel_1;
	elseif(m_perData.jjcGroupid == 1) then
		return m_kingSeatPage2;
	else
		local pages = m_page:getPages();
		if(m_curPageIndex == 1) then
			return pages:objectAtIndex(0);
		else
			return pages:objectAtIndex(1);
		end
	end
end


----------------------------------------------------------------------
--关闭计时器
local function stopUpdate()
	if (m_countDown_schedule ~= nil) then  
        m_scheduler:unscheduleScriptEntry(m_countDown_schedule)  
        m_countDown_schedule = nil;
    end 
end

local function refreshTimeLabel()
	if(m_perData.lastTrainTime > 0) then
		m_trainTimeLabel:setText(CoolingTime.timeChangeString(m_perData.lastTrainTime));
	else
		m_trainTimeLabel:setText("");
	end

	if(m_perData.lastBlessTime > 0) then
		m_blesstimeLabel:setText(CoolingTime.timeChangeString(m_perData.lastBlessTime));
	else
		m_blesstimeLabel:setText("");
	end

	local timeOk = {};

	for i=1,COUNT_ONE_PAGE do
		local data = m_seatDatas[i];
		if(data ~= nil) then
			local timeLabel =  nil;
			if(m_perData.jjcGroupid == 0) then
				timeLabel =  tolua.cast(m_kingSeat1Panels[i]:getChildByName("time_label"), "Label");
			elseif(m_perData.jjcGroupid == 1) then
				timeLabel =  tolua.cast(m_kingSeat2Panels[i]:getChildByName("time_label"), "Label");
			else
				local panel = getCurPageItem():getChildByName("seat_panel_" .. i);
				timeLabel =  tolua.cast(panel:getChildByName("time_label"), "Label");
			end

			if(data.lastTrainTime > 0) then
				timeLabel:setText(CoolingTime.timeChangeString(data.lastTrainTime));
			else
				local levelLabel = nil;
				local nameLabel = nil;
				local headPanel = nil;
				if(m_perData.jjcGroupid == 0) then
					levelLabel =  tolua.cast(m_kingSeat1Panels[i]:getChildByName("level_label"), "Label");
					nameLabel =  tolua.cast(m_kingSeat1Panels[i]:getChildByName("name_label"), "Label");
					headPanel =  tolua.cast(m_kingSeat1Panels[i]:getChildByName("head_panel"), "Label");
				elseif(m_perData.jjcGroupid == 1) then
					levelLabel =  tolua.cast(m_kingSeat2Panels[i]:getChildByName("level_label"), "Label");
					nameLabel =  tolua.cast(m_kingSeat2Panels[i]:getChildByName("name_label"), "Label");
					headPanel =  tolua.cast(m_kingSeat2Panels[i]:getChildByName("head_panel"), "Label");
				else
					local panel = getCurPageItem():getChildByName("seat_panel_" .. i);
					levelLabel =  tolua.cast(panel:getChildByName("level_label"), "Label");
					nameLabel =  tolua.cast(panel:getChildByName("name_label"), "Label");
					headPanel =  tolua.cast(panel:getChildByName("head_panel"), "Label");
				end
				levelLabel:setText("");
				nameLabel:setText("");
				headPanel:setEnabled(false);

				if(m_perData.jjcGroupid > 1) then
					timeLabel:setText("--:--:--");
				else
					timeLabel:setText("");
				end

				table.insert(timeOk, seatid);
			end
		end
	end

	--移除到时的项
	for i,v in ipairs(timeOk) do
		m_seatDatas[v] = nil;
	end
end

local function updateTime(dt)
    if(m_perData.lastTrainTime > 0) then
    	m_perData.lastTrainTime = m_perData.lastTrainTime - 1;
    	if(m_perData.lastTrainTime <= 0) then
    		--时间到达发送消息
    		ProgressRadial.open();
    		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_TIME_UP, {m_perData.statusId, m_curPageIndex});
    	end
	end

	if(m_perData.lastBlessTime > 0) then
		m_perData.lastBlessTime = m_perData.lastBlessTime - 1;
	end

	for k,v in pairs(m_seatDatas) do
		v.lastTrainTime = v.lastTrainTime - 1;
	end
    
    refreshTimeLabel();
end


--开启计时器
local function startUpdate()
    if(not m_countDown_schedule) then
        m_countDown_schedule = m_scheduler:scheduleScriptFunc(updateTime, 1, false);
    end
end

local function refreshPersonalInfo()
	local pd = m_perData;
	--剩余训练时间 和 剩余祝福时间
	if(pd.isBless == 0 and pd.statusId ~= STATUS_NO_TRAIN) then
		-- stopUpdate();
	end
	
	if(pd.isBless ~= 1) then
		m_blesstimeLabel:setText("");
	end

	if(pd.statusId ~= STATUS_NO_TRAIN) then
		m_trainTimeLabel:setText("");
	end


	--我的位置
	refreshMyPos();

	--每分钟获得经验
	refreshExpPerMin();

	--剩余挑战次数
	m_lastRobCountLabel:setText(pd.lastFightCount);

	--训练按钮状态
	local perTrainBtn = tolua.cast(m_uiLayer:getWidgetByName("perTrain_btn"), "Button");
	if(pd.statusId == STATUS_NO_TRAIN) then
		perTrainBtn:loadTextureNormal(IMAGE_PATH.TRAIN_START_1);
		perTrainBtn:loadTexturePressed(IMAGE_PATH.TRAIN_START_0);

	else
		perTrainBtn:loadTextureNormal(IMAGE_PATH.TRAIN_STOP_1);
		perTrainBtn:loadTexturePressed(IMAGE_PATH.TRAIN_STOP_0);
	end
end

--打开请求结束
function openReceiveDataEnd()
	initSeatPanel();
	requestCurPageInfos();
	startUpdate();
	refreshPersonalInfo();
	TrainReport.refresh();
end

function refreshInfo()
	refreshPersonalInfo();
	TrainReport.refresh();
end

-------------------------------------------------------------------------
--请求当前页信息
function requestCurPageInfos()
	-- stopUpdate();
	ProgressRadial.open();
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_PAGE, {m_curPageIndex});
end


--收到本页面玩家信息
local function onReceivePageInfos( messageType, messageData )
	ProgressRadial.close();
	m_seatDatas = {};
	for i,v in ipairs(messageData) do
		local seatid = v.seatid;
		-- m_seatDatas[math.mod(seatid - 1,COUNT_ONE_PAGE) + 1] = v;
		m_seatDatas[(seatid - 1)%COUNT_ONE_PAGE + 1] = v;
	end
	-- seatid
	-- id
	-- name
	-- jjcRanking
	-- level
	-- hair
	-- haircolor
	-- face
	local page = getCurPageItem();
	initSeatItemInfo(page);
	attachSeatItemInfo(page);
	-- startUpdate();
end


function show(str)
	Util.showOperateResultPrompt(str);
end

local function refreshExpContainer()
	tolua.cast(m_uiLayer:getWidgetByName("expContainer_label"), "Label"):setText(m_expContainer);
end

--接收个人数据
local function onReceivePersonalInfo(messageType, messageData)
	m_perData = {};
	m_perData = messageData;

	-- statusId	
	-- jjcGroupid 
	-- isBless	
	-- nowPerExp
	-- nowKingExp
	-- nowBuff	
	-- upBuff	
	-- lastTrainTime	
	-- lastBlessTime	
	-- lastFightCount
end

--接收本组座位数据
local function onReceiveSeatsInfos(messageType, messageData)
	CCLuaLog(json.encode(messageData));
	m_seatDatas = {};
	for i,v in ipairs(messageData) do
		local seatid = v.seatid;
		m_seatDatas[seatid] = v;
	end
	-- seatid
	-- id
	-- name
	-- jjcRanking
	-- level
	-- hair
	-- haircolor
	-- face
end

local IS_TRAINING 	= 1; --正在训练
local CAN_SEAT    	= 2; --空座位可以坐下
local CAN_ROB     	= 3; --非空座位，可以抢座
local NEED_REFRESH 	= 4; --座位信息不一致，需要刷新
local function onReceiveClickKingSeatResponse( messageType, messageData )
	ProgressRadial.close();
	local result = messageData.result;
	if(result == IS_TRAINING) then
		show("您正在进行训练");
	elseif(result == CAN_SEAT or result == CAN_ROB) then
		local index = messageData.seatid;
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_ROB_SEAT, {index, m_curPageIndex});
		TrainMgr.open(index);
	elseif(result == NEED_REFRESH) then
		show("信息过期，需要刷新");
		-- openReceiveDataEnd();
		refreshInfo();
	end
end

local function onReceiveTimeUpResponse( messageType, messageData )
	ProgressRadial.close();
	-- openReceiveDataEnd();
	refreshInfo();
end

--接收经验容器数据
local function onReceiveExpContainerInfo(messageType, messageData)
	m_expContainer = messageData.expDiff;
	local trainType = messageData.type;
	-- expDiff
	-- type
	print("***$$$$$$$$$$$$$$$$$$ : " .. m_expContainer);
	if(trainType == STATUS_PER_TRAIN) then
		Util.showOperateResultPrompt("个人训练场获得经验 " .. m_expContainer);
	elseif(trainType == STATUS_KING_TRAIN) then
		Util.showOperateResultPrompt("王者训练场获得经验 " .. m_expContainer);
	else
		Util.showOperateResultPrompt("训练场获得经验 " .. m_expContainer);
	end
	-- refreshExpContainer();
end

-------------------------------------------------------------------------



local function attachOtherUI()
	m_lastRobCountLabel = tolua.cast(m_uiLayer:getWidgetByName("lastRobCount_label"),"Label");

	m_expLabel = tolua.cast(m_uiLayer:getWidgetByName("exp_label"),"Label");

	m_trainTimeLabel = tolua.cast(m_uiLayer:getWidgetByName("trainTime_label"),"Label");

	m_blesstimeLabel = tolua.cast(m_uiLayer:getWidgetByName("blesstime_label"),"Label");

	m_kingSeatPanel_1 = tolua.cast(m_uiLayer:getWidgetByName("kingSeat1_panel"), "Layout");
	m_kingSeatPanel_2 = tolua.cast(m_uiLayer:getWidgetByName("kingSeat2_panel"), "Layout");
	m_kingSeatPanel_3_6 = tolua.cast(m_uiLayer:getWidgetByName("kingSeat3_6_panel"), "Layout");

	for i = 1,GROUP_COUNT do
		m_groupSeatCount[i] = DataTableManager.getValue("TrainSeatCount", "id_" .. (i - 1), "seatcount");
	end

	for i=1,m_groupSeatCount[1] do
		m_kingSeat1Panels[i] = tolua.cast(m_kingSeatPanel_1:getChildByName("seat_panel_" .. i), "Layout");
		m_kingSeat1Panels[i]:setTag(i);
		m_kingSeat1Panels[i]:addTouchEventListener(seatTouchEvent);
	end

	local slv = m_kingSeatPanel_2:getChildByName("xlc_sv");
	m_kingSeatPage2 = slv:getChildByName("xlc_panel");
	for i=1,m_groupSeatCount[2] do
		m_kingSeat2Panels[i] = tolua.cast(m_kingSeatPage2:getChildByName("seat_panel_" .. i), "Layout");
		m_kingSeat2Panels[i]:setTag(i);
		m_kingSeat2Panels[i]:addTouchEventListener(seatTouchEvent);
	end

	m_page = tolua.cast(m_uiLayer:getWidgetByName("page_PagetView"), "PageView");
	m_page:retain();
	m_page:addEventListenerPageView(TrainUI.PageViewEventListener);

	local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TG_roleItemUI_2.json");
	m_seatItem = tolua.cast(item, "Layout");
	m_seatItem:retain();

	-- local headPanel = tolua.cast(item:getChildByName("head_panel"), "Layout");
	-- local pW = headPanel:getContentSize().width;
	-- local pH = headPanel:getContentSize().height;
	local pW = 90;
	local pH = 98;
	local headW, headH = Util.getHeadSize();
	m_headScale_x = pW/headW;
	m_headScale_y = pH/headH;
	m_headPos = ccp(pW/2, pH/2);
end

local function boundListener()
	m_uiLayer:getWidgetByName("close_btn"):addTouchEventListener(closeOnTouch);

	local buffBtn = tolua.cast(m_uiLayer:getWidgetByName("buff_btn"), "Button");
	buffBtn:addTouchEventListener(buffBtnOnClick);

	local perTrainBtn = m_uiLayer:getWidgetByName("perTrain_btn");
	perTrainBtn:addTouchEventListener(perTrainBtnOnClick);

	local blessPanel = m_uiLayer:getWidgetByName("bless_btn");
	blessPanel:addTouchEventListener(blessPanelOnClick);
end

local function openInit()
	m_lastRobCountLabel:setText("");
	m_trainTimeLabel:setText("");
	m_blesstimeLabel:setText("");
	m_expLabel:setText("");

	m_kingSeatPanel_1:setEnabled(false);
	m_kingSeatPanel_2:setEnabled(false);
	m_kingSeatPanel_3_6:setEnabled(false);

	m_totalCount = 0;
	m_curPageIndex = 1;
	m_curIndex = 1;
	m_pageCount = 0;
	m_page:removeAllPages();
end

local function registerReceiveData()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAINPERSONINFO, onReceivePersonalInfo);
	-- NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TAINSEATSINFOS, onReceiveSeatsInfos);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_BATTLE_REPORT, TrainReport.onReceiveReportDataFromServer);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_EXPCONTANER, onReceiveExpContainerInfo);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_CLICK_KINGSEAT_RESPONSE, onReceiveClickKingSeatResponse);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_TIME_UP_RESPONSE, onReceiveTimeUpResponse);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_PAGE_RESPONSE, onReceivePageInfos);
end

local function unregisterReceiveData()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAINPERSONINFO, onReceivePersonalInfo);
	-- NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TAINSEATSINFOS, onReceiveSeatsInfos);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_BATTLE_REPORT, TrainReport.onReceiveReportDataFromServer);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_EXPCONTANER, onReceiveExpContainerInfo);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_CLICK_KINGSEAT_RESPONSE, onReceiveClickKingSeatResponse);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_TIME_UP_RESPONSE, onReceiveTimeUpResponse);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_PAGE_RESPONSE, onReceivePageInfos);
end


local m_playerAnim = nil;
function createAnimation()
    m_playerAnim = PlayerActor.getFigureActor();
    local animaPanel = tolua.cast(m_uiLayer:getWidgetByName("anim_panel"), "Layout");
    animaPanel:addNode(m_playerAnim);
    m_playerAnim:setPosition(ccp(18, -2632 + 10));
end

function removeAnimation()
	if(m_playerAnim) then
	    m_playerAnim:removeFromParentAndCleanup(false);
	    m_playerAnim = nil;
	end
end


function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

		-- local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		-- bgLayer:registerScriptTouchHandler(onTouch);
		-- m_rootLayer:addChild(bgLayer);

		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TG_kingUI.json");
		m_uiLayer = TouchGroup:create();
		m_uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(m_uiLayer);

		attachOtherUI();
		boundListener();
		registerReceiveData();

		TrainReport.create();
		TrainBuffDesc.create();
		TrainBless.create();
		TrainHelp.create();
		TrainRobSeatSuccess.create();
		TrainFight.create();
		TrainBuyFightCountDesc.create();
		TrainMgr.create();
	end
end

function open()
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);

		openInit();

		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_REQUEST, {});
		TrainMgr.open();

		TrainReport.open();
		local repostPanel = tolua.cast(m_uiLayer:getWidgetByName("report_panel"), "Layout");
		TrainReport.setPosition(ccp(0, 0));
		repostPanel:addChild(TrainReport.getRootLayout(), 2);

		createAnimation();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);

		TrainMgr.close();
		TrainReport.close();
		m_page:removeAllChildrenWithCleanup(true);
		stopUpdate();

		removeAnimation();
		ProgressRadial.close();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		unregisterReceiveData();
		if(m_rootLayer) then
			m_rootLayer:removeAllChildrenWithCleanup(true);
			m_rootLayer:release();
			m_rootLayer = nil;
		end
		m_uiLayer 	= nil;
		m_page:release();
		m_page = nil;

		TrainReport.remove();
		TrainMgr.remove();
		TrainBuffDesc.remove();
		TrainBless.remove();
		TrainHelp.remove();
		TrainRobSeatSuccess.remove();
		TrainFight.remove();
		TrainBuyFightCountDesc.remove();
	end
end