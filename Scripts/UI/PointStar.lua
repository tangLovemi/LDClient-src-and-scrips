module("PointStar", package.seeall)

-------------------------------------
--           点星界面              --
--交互过程：
--打开界面：C->S 发送：数据请求，
--			S->C 得到 星系、所在星星; 人物等级; 金币; 属性列表; 发送完成标志
--          收到消息，初始化界面
--进行点星：C->S 发送：数据更改：星系、星星；金币；变化的某个属性；
--          服务器更改数据
--			服务器发送新数据：S->C 
--			S->C 更改完成标志
--			客户端刷新显示
-------------------------------------
local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate = false;
local m_isOpen = false;
local m_pointBtn = nil;

local m_starLayer = nil;

local m_pointStarLine = 0; -- 当前星系
local m_pointStar = 0; -- 当前星 （共12个星系，每个星系16颗星）
--人物二级属性名称
local m_proName = {
	"atk", "def", "hp",    
	"speed", "bash", "crit", "counterAtk", "parry", "dodge", 
};

local m_firstName = {
	"strength",		--力量
	"agility",		--敏捷
	"endurance",	--耐力
};


local POINT_BASE_LEVEL = 0; --可以进行点星的最低级别

local m_starArr; --存放每个星星
local STAR_BASE_TAG = 234;
local w = 1136;
local h = 640;
local starW = 80;
local center = ccp(w/2, h/2);
local space = (w/2 - 5*(starW/2))/2;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_move_schedule = nil;
--抛物线顶点
local m_pX = 400;
local m_pY = 180;

--与y轴交点
local m_c = 250;
local m_a = (m_c - m_pY)/(m_pX*m_pX);
local m_b = 2*(m_pY - m_c)/m_pX;
-- y = a*(x*x) + b*x + c
-- print("**************************  y = " .. m_a .. "*(x*x) + " .. m_b .. "*x + " .. m_c);
local m_starPos = ccp(50, 150);--原先整个节点位置
local dw = 168;
local dh = 140;
local m_starPosX = {400, 500, 600, 700, 800}; -- {400, 500, 630, 800};
local m_firstX = nil;
local m_speed = 5;
local m_starCount = 7;
-- local m_k = -1/250;
local m_k = -1/500;
local m_maxScale = 1.1;
-- local m_maxScale = 1;

local LINE_COUNT	= 0;
local STAR_COUNT	= 0;
local m_datas = nil;

--服务器接收数据完成标志
local FLAG_OPEN_FINISH 		= 1; 
local FLAG_POINT_FINISH  	= 2;

local RESULT_SUCESS 			= 255;
local RESULT_MONEY_NOT_ENOUGH 	= 1;  --金币不够
local RESULT_ALL_POINT 		 	= 2;  --全部点完
local RESULT_LEVEL_NOT_ENOUGH 	= 3;  --级别不够

function getMinLevelToPointStar()
	return POINT_BASE_LEVEL;
end

--从配置表读取数据
local function initFigureData()
	POINT_BASE_LEVEL = DataTableManager.getValue("pointStarLevel", "id_1", "level");
	--初始化最大星系数量，和最大星星数量
	LINE_COUNT = DataTableManager.getValue("pointStarCount", "id_1", "line");
	STAR_COUNT = DataTableManager.getValue("pointStarCount", "id_1", "star");

	--初始化属性
	m_datas = {};
	for i=1,LINE_COUNT do
		local data = {};
		local d = DataTableManager.getItem("pointStarPro", "id_" .. i);
		data.proid = Util.strToNumber(Util.Split(d.proid, ";"));
		data.proValue = Util.strToNumber(Util.Split(d.proValue, ";"));
		data.proUse = Util.strToNumber(Util.Split(d.proUse, ";"));
		table.insert(m_datas, data);
	end
end

local function onTouch(eventType,x,y)
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		UIManager.close("PointStar");
	end
end

local function createStar(pos)
	local tg = TouchGroup:create();
	local starPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "PointStarItem.json");
	tg:addWidget(starPanel);
	local newPos = ccp(pos.x + dw, pos.y + dh);
	tg:setPosition(pos);

	local img = tolua.cast(tg:getWidgetByName("star_img"), "ImageView");
	local x = pos.x;
	local s = m_k*math.abs(x + starW - m_pX) + m_maxScale;
	img:setScale(s);

	m_starArr:addObject(tg);
	m_starLayer:addChild(tg);
end

local function getCenterIndex()
	if(m_pointStar ~= 0) then
		local index = nil;
		if(m_pointStar == 1) then
			index = 0;
		elseif(m_pointStar == 2) then
			index = 1;
		elseif(m_pointStar == 3) then
			index = 2;
		else
			index = (m_starCount - 1)/2;
		end
		return index;
	end
	return nil;
end

local function setStarScale( index )
	local starPanel = tolua.cast(m_starArr:objectAtIndex(index - 1), "TouchGroup");
	local img = tolua.cast(starPanel:getWidgetByName("star_img"), "ImageView");
	local x = starPanel:getPositionX();
	local s = m_k*math.abs(x + starW - m_pX) + m_maxScale;
	img:setScale(s);
end

local function setAllStarScale()
	local count = m_starArr:count();
	for i = 1,count do
		setStarScale(i);
	end
end

local function restoreCenter()
	-- local index = getCenterIndex();
	-- local starPanel = tolua.cast(m_starArr:objectAtIndex(index), "TouchGroup");
	-- local starImg = tolua.cast(starPanel:getWidgetByName("star_img"), "ImageView");
	-- starImg:setTouchEnabled(false);

	m_pointBtn:setTouchEnabled(false);
end

local function removeStar()
	if(m_pointStar >= (m_starCount - 1)/2 + 2) then
		local starPanel = tolua.cast(m_starArr:objectAtIndex(0), "TouchGroup");
		local img = tolua.cast(starPanel:getWidgetByName("star_img"), "ImageView");
		local function actionEnd()
			starPanel:removeFromParentAndCleanup(true);
			m_starArr:removeObjectAtIndex(0, true);
			setCenter();
		end
		local arr = CCArray:create();
		arr:addObject(CCScaleTo:create(0.3, 0.01));
		arr:addObject(CCCallFunc:create(function() actionEnd() end));
		img:runAction(CCSequence:create(arr));
	end
end

--刷新显示(星系、星星、点击消耗)
local function refresh()
	local starLineLabel = tolua.cast(m_rootLayout:getWidgetByName("starLine_label"), "Label");
	local starLabel = tolua.cast(m_rootLayout:getWidgetByName("star_label"), "Label");
	local moneyUseLabel = tolua.cast(m_rootLayout:getWidgetByName("moneyUse _label"), "Label");
	-- local moneyLabel = tolua.cast(m_rootLayout:getWidgetByName("money_label"), "Label");

	if(m_pointStar == 0) then
		if(m_pointStarLine == 0) then
			starLineLabel:setText(LINE_COUNT);
			starLabel:setText(STAR_COUNT);
		else
			starLineLabel:setText(m_pointStarLine);
			starLabel:setText(STAR_COUNT);
			local money = m_datas[m_pointStarLine]["proUse"][STAR_COUNT];
			moneyUseLabel:setText(money);
		end	else
		starLineLabel:setText(m_pointStarLine);
		starLabel:setText(m_pointStar);
		local money = m_datas[m_pointStarLine]["proUse"][m_pointStar]
		moneyUseLabel:setText(money);
	end
	-- moneyLabel:setText(UserInfoManager.getRoleInfo("gold"));
end

local m_starImgPath = {
	PATH_CCS_RES .. "zhanxing_liliang",			-- 1	力量
	PATH_CCS_RES .. "zhanxing_minjie",			-- 2	敏捷
	PATH_CCS_RES .. "zhanxing_naili",			-- 3	耐力
	PATH_CCS_RES .. "zhanxing_gongji.png",		-- 4	攻击
	PATH_CCS_RES .. "zhanxing_fangyu.png",		-- 5	防御
	PATH_CCS_RES .. "zhanxing_shengming.png",	-- 6	生命
	PATH_CCS_RES .. "zhanxing_sudu.png",		-- 7	速度
	PATH_CCS_RES .. "zhanxing_zhongji.png",		-- 8	重击
	PATH_CCS_RES .. "zhanxing_baoji.png",		-- 9	暴击
	PATH_CCS_RES .. "zhanxing_fanji.png",		-- 10	反击
	PATH_CCS_RES .. "zhanxing_gedang.png",		-- 11	格挡
	PATH_CCS_RES .. "zhanxing_shanbi.png",		-- 12	闪避
};

--设置某颗星星的属性
local function setStarPro( starIndex, proIndex )
	local starPanel = tolua.cast(m_starArr:objectAtIndex(starIndex - 1), "TouchGroup");
	local proValueLabel = tolua.cast(starPanel:getWidgetByName("proValue_label"), "Label");
	local proNameLabel = tolua.cast(starPanel:getWidgetByName("proName_label"), "Label");
	local img = tolua.cast(starPanel:getWidgetByName("star_img"), "ImageView");
	-- proIndex 由表获得当前星系下此索引星星的属性值
	local proValue = m_datas[m_pointStarLine]["proValue"][proIndex];
	local proid = m_datas[m_pointStarLine]["proid"][proIndex];
	local proName = DataTableManager.getValue("PropertyNameData", "id_" .. proid, "name");
	proValueLabel:setText(proValue);
	proNameLabel:setText(proName);

	-- local imgName = "star_" .. DataTableManager.getValue("PropertyNameData", "id_" .. proid, "engName") .. ".png";
	-- local imgPath = PATH_CCS_RES .. imgName;
	img:loadTexture(m_starImgPath[proid]);
end

local function addStar(index)
	if( m_pointStar - 1 < STAR_COUNT - (m_starCount - 1)/2 ) then
		local x = m_starPosX[index];
		local y = getY(x);
		createStar(ccp(x - starW, y));
		if(index <= (m_starCount + 1)/2) then
			setStarPro(index, index);
		else
			setStarPro(m_starArr:count(), m_pointStar + (m_starCount + 1)/2 - 1);
		end
	end
end

--初始化新星系
local function newStarLine()
	for i = 1,(m_starCount + 1)/2 do
		addStar(i);
	end
	setCenter();
	refresh();
end

--移除所有星星
local function removeAllStarsAndNewStarLine(isNew)
	-- 先播放动画，再移除
	local count = m_starArr:count();
	local starPanel = tolua.cast(m_starArr:objectAtIndex(2), "TouchGroup");
	local img = tolua.cast(starPanel:getWidgetByName("star_img"), "ImageView");
	local arr = CCArray:create();

	local function actionEnd()
		--删除星星
		for i = 1,count do
			local starPanel = tolua.cast(m_starArr:objectAtIndex(i - 1), "TouchGroup");
			starPanel:removeFromParentAndCleanup(true);
		end
		m_starArr:removeAllObjects();
		--加载新星系
		if(isNew) then
			newStarLine();
		end
	end

	local function scaleActionEnd()
		actionEnd();
	end
	--播放动画
	scaleActionEnd();
	-- arr:addObject(CCScaleTo:create(0.3, 1));
	-- arr:addObject(CCCallFunc:create(function() scaleActionEnd() end));
	-- img:runAction(CCSequence:create(arr));
end

local function removeAllStars()
	local count = m_starArr:count();
	for i = 1,count do
		local starPanel = tolua.cast(m_starArr:objectAtIndex(i - 1), "TouchGroup");
		starPanel:removeFromParentAndCleanup(true);
	end
	m_starArr:removeAllObjects();
end

local function canStopMove()
	local starPanel0 = tolua.cast(m_starArr:objectAtIndex(0), "TouchGroup");
	local posX = starPanel0:getPositionX();
	return m_firstX - posX >= 100;
end

local function startUpdate()
	local starPanel = tolua.cast(m_starArr:objectAtIndex(0), "TouchGroup");
	m_firstX = starPanel:getPositionX();
	m_move_schedule = m_scheduler:scheduleScriptFunc(moveUpdate, 0.01, false);
end

--停止计时器
function stopUpdate()
    if (m_move_schedule ~= nil) then  
        m_scheduler:unscheduleScriptEntry(m_move_schedule)  
        m_move_schedule = nil;
    end 
end

function getY( x )
	return (x*x)*(m_a) + x*(m_b) + m_c; -- y = a*(x*x) + b*x + c
end

function moveUpdate()
	if(canStopMove()) then
		stopUpdate();
		removeStar();
		if(m_pointStar < (m_starCount - 1)/2 + 2) then
			setCenter();
		end
		refresh();
	else
		local count = m_starArr:count();
		for i = 1,count do
			local starPanel = tolua.cast(m_starArr:objectAtIndex(i - 1), "TouchGroup");
			local x = starPanel:getPositionX() + starW - m_speed;
			local y = getY(x);
			starPanel:setPosition(x - starW, y);
		end
		setAllStarScale();
	end
end


local function refreshAllHeroPros()
	local firstPro = UserInfoManager.getRoleInfo("firstPro");
	for i=1,#m_firstName do
		local proLabel = tolua.cast(m_rootLayout:getWidgetByName(m_firstName[i] .. "_label"), "Label");
		proLabel:setText(firstPro[m_firstName[i]]);
	end

	local secPro = UserInfoManager.getRoleInfo("secondPro");
	for i = 1,#m_proName do
		local proLabel = tolua.cast(m_rootLayout:getWidgetByName(m_proName[i] .. "_label"), "Label");
		proLabel:setText(secPro[m_proName[i]]);
	end
end

local function centerStarTouchEvent( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		restoreCenter();
		pointExe();
	end
end


--设置中间星星的点击监听
function setCenter()
	-- local index = getCenterIndex();
	-- if(index ~= nil) then
	-- 	local starPanel = tolua.cast(m_starArr:objectAtIndex(index), "TouchGroup");
	-- 	local starImg = tolua.cast(starPanel:getWidgetByName("star_img"), "ImageView");
	-- 	starImg:addTouchEventListener(centerStarTouchEvent);
	-- end
	m_pointBtn:setTouchEnabled(true);
end


local function getInitStarCount()
	if(m_pointStar ~= 0) then
		if(m_pointStar == 1 or m_pointStar == STAR_COUNT) then
			return 4;
		elseif(m_pointStar == 2 or m_pointStar == STAR_COUNT - 1) then
			return 5;
		elseif(m_pointStar == 3 or m_pointStar == STAR_COUNT - 2) then
			return 6;
		else
			return 7;
		end
	end
	return nil;
end

local function initStars()
	local count = getInitStarCount();
	if(count ~= nil) then
		local startX = nil;
		if(m_pointStar >= (m_starCount + 1)/2) then
			startX = (400 - ((m_starCount - 1)/2)*100);
		else
			startX = 400 - (count - (m_starCount + 1)/2)*100;
		end
		
		for i = 1,count do
			local x = startX + 100*(i - 1);
			local y = getY(x);
			createStar(ccp(x - starW, y));
			local proIndex = nil;
			if(m_pointStar >= (m_starCount + 1)/2) then
				proIndex = m_pointStar + i - (m_starCount + 1)/2;
			else
				proIndex = m_pointStar + i - (count - 3);
			end
			setStarPro( i, proIndex );
		end
	end
	setCenter();
end

local function canPoint()
	if(m_pointStarLine > 0) then
		local heroLevel = UserInfoManager.getRoleInfo("level");
		return (heroLevel >= DataTableManager.getValue("pointStarLevel", "id_" .. m_pointStarLine, "level"));
	end
	return false;
end

--设置级别不足
local function setLevelNotEnoughEnabled( enable )
	m_rootLayout:getWidgetByName("levelLimit_img"):setEnabled(enable);
	m_rootLayout:getWidgetByName("line_img"):setEnabled(not enable);
	if(enable) then
		local level = DataTableManager.getValue("pointStarLevel", "id_" .. m_pointStarLine, "level");
		local levelAl = tolua.cast(m_rootLayout:getWidgetByName("level_AtlasLabel"), "LabelAtlas");
		levelAl:setStringValue(level);
	end
end

local function init()
	local heroLevel = UserInfoManager.getRoleInfo("level");
	local data = UserInfoManager.getRoleInfo("pointStar");
	m_pointStarLine = data.starLine;
	m_pointStar = data.star;

	setLevelNotEnoughEnabled(false);
	m_pointBtn:setEnabled(true);
	tolua.cast(m_rootLayout:getWidgetByName("desPanel"), "Layout"):setEnabled(true);

	if(heroLevel >= POINT_BASE_LEVEL) then
		if(canPoint()) then
			refresh();
			--显示星星
			m_starArr = CCArray:createWithCapacity(m_starCount + 1);
			m_starArr:retain();
			initStars();
		else
			m_pointBtn:setEnabled(false);
			tolua.cast(m_rootLayout:getWidgetByName("desPanel"), "Layout"):setEnabled(false);
			if(m_pointStar == 1) then
				-- Util.showOperateResultPrompt(TEXT.levelNotEnoughToPointStar);
				setLevelNotEnoughEnabled(true);
			else
				Util.showOperateResultPrompt(TEXT.allStarPoint);
			end
		end
	else
		--未到点星最低级别
		m_pointBtn:setEnabled(false);
		tolua.cast(m_rootLayout:getWidgetByName("desPanel"), "Layout"):setEnabled(false);
		-- Util.showOperateResultPrompt("需达到" .. POINT_BASE_LEVEL .. "级才可开启");
		setLevelNotEnoughEnabled(true);
	end

	--显示hero属性
	refreshAllHeroPros();
end

local function onReceivePointStarDataFinishFlag( messageType, messageData )
	ProgressRadial.close();
	local data = UserInfoManager.getRoleInfo("pointStar");
	m_pointStarLine = data.starLine;
	m_pointStar = data.star;

	if(messageData.id == FLAG_OPEN_FINISH) then
		-- init();
	elseif(messageData.id == FLAG_POINT_FINISH) then
		refreshAllHeroPros();
		if(messageData.resultId == RESULT_SUCESS) then
			if(m_pointStar ~= 1) then
				addStar((m_starCount - 1)/2 + 2);
				startUpdate(); -- 启动定时器
			else
				--点击完本星系所有星星
				removeAllStarsAndNewStarLine(true);
			end
		elseif(messageData.resultId == RESULT_LEVEL_NOT_ENOUGH) then
			removeAllStarsAndNewStarLine(false);
			-- Util.showOperateResultPrompt(TEXT.levelNotEnoughToPointStar);
			setLevelNotEnoughEnabled(true);
		elseif(messageData.resultId == RESULT_MONEY_NOT_ENOUGH) then
			Util.showOperateResultPrompt(TEXT.noMoney);
		elseif(messageData.resultId == RESULT_ALL_POINT) then
			removeAllStars();
			Util.showOperateResultPrompt(TEXT.allStarPoint);
		end
	end
end

local function unRegisterPointStarMessage()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_POINTSTARFINISH, onReceivePointStarDataFinishFlag);
end

local function registerPointStarMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_POINTSTARFINISH, onReceivePointStarDataFinishFlag);
end

local function sendRequest()
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_POINTSTARREQUEST, {});
	ProgressRadial.open();
end

function pointExe()
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EXEPOINTSTAR, {m_pointStarLine, m_pointStar}); --星系 和 星星
	ProgressRadial.open();
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		bgLayer:registerScriptTouchHandler(onTouch);
		m_rootLayer:addChild(bgLayer);

		m_rootLayer:retain();
		m_rootLayout = TouchGroup:create();
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "PointStar.json");
		m_rootLayout:addWidget(panel);
		m_rootLayer:addChild(m_rootLayout);

		m_starLayer = CCLayer:create();
		m_starLayer:retain();
		m_starLayer:setPosition(m_starPos);
		m_rootLayer:addChild(m_starLayer);

		m_pointBtn = m_rootLayout:getWidgetByName("point_btn");
		m_pointBtn:addTouchEventListener(centerStarTouchEvent);

		registerPointStarMessage();
		initFigureData();
	end
end

function open()
	if (not m_isOpen) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer, THREE_ZORDER);
		-- sendRequest();

		init();
	end
end

function close()
	if (m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
		ProgressRadial.close();
    end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
	    if(m_rootLayer) then
	        unRegisterPointStarMessage();
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    end
	    m_rootLayer = nil;
	    m_starLayer:release();
	    m_starLayer = nil;
	end
end