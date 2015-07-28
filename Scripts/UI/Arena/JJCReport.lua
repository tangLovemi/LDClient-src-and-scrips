module("JJCReport", package.seeall)

local m_rootLayer = nil;
local m_list = nil;
local m_item = nil;
local m_isCreate = false;
local m_isOpen = false;
local m_datas = nil;
local m_defPos = ccp(179, 46.5);


local function bgOnClick( eventType,x,y )
	-- body
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		close();
	end
end

local function playbackOnTouch(sender,eventType)
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local tag = sender:getTag();
		print("*****战斗回放 tag = " .. tag);
		if(tag <= #m_datas) then
			print("battleId = " .. m_datas[tag].battleId);
			local cb = function() UIManager.close("JJCUI"); end
			BattleManager.enterBattleRecord(BATTLE_MAIN_TYPE_PVP, BATTLE_SUBTYPE_JJC, m_datas[tag].battleId, cb);
		end
	end
end

local function isWin( data )
	-- if((data.mode == 1 and data.result == 1) or (data.mode == 2 and data.result == 0) ) then
	-- 	return true;
	-- end
	-- return false;
	return (data.result == 1);
end

local function resultName(isWin)
	if(isWin) then
		return "胜";
	else
		return "负";
	end
end

local function resultDesc( data )
	local score = math.abs(data.score);
	if(data.mode == 1) then
		--self是攻击方
		if(data.result == 1) then
			if(score <= 0) then
				return "您挑战了" .. data.oppName .. "，并获得了胜利"; 
			else
				return "您挑战了" .. data.oppName .. "，并获得了胜利，收获了" .. score .. "积分"; 
			end
		else
			if(score <= 0) then
				return "您挑战了" .. data.oppName .. "，但失败了"; 
			else
				return "您挑战了" .. data.oppName .. "，但失败了，失去了" .. score .. "积分"; 
			end
		end
	elseif(data.mode == 2) then
		--self是防御方
		if(data.result == 1) then
			if(score <= 0) then
				return data.oppName .. "挑战了您" .. "，您防御成功了"; 
			else
				return data.oppName .. "挑战了您" .. "，您防御成功了，获得了" .. score .. "积分"; 
			end
		else
			if(score <= 0) then
				return data.oppName .. "挑战了您" .. "，您防御失败了"; 
			else
				return data.oppName .. "挑战了您" .. "，您防御失败了，失去了" .. score .. "积分"; 
			end
		end
	end
end

local function receiveDataEnd()
	m_list:removeAllItems();
	print("***********  战报   size = " .. #m_datas);

	for i=#m_datas,1,-1 do
		print("oppName = " .. m_datas[i].oppName);
		print("mode    = " .. m_datas[i].mode);
		print("result  = " .. m_datas[i].result);
		print("score   = " .. m_datas[i].score);
		print("battleId= " .. m_datas[i].battleId);
		print("  ");
		local item = m_item:clone();

		local playBackBtn = tolua.cast(item:getChildByName("playback_btn"), "Button");
		playBackBtn:setTag(i);
		playBackBtn:addTouchEventListener(playbackOnTouch);
		local isWin = isWin(m_datas[i]);
		local result_Img = tolua.cast(item:getChildByName("result_img"), "ImageView");
		if(isWin) then
			result_Img:loadTexture(PATH_CCS_RES .. "gy_bt_sheng.png");
		else
			result_Img:loadTexture(PATH_CCS_RES .. "gy_bt_fu.png");
		end
		local desc_label = tolua.cast(item:getChildByName("desc_label"), "Label");
		desc_label:setText(resultDesc(m_datas[i]));
		m_list:pushBackCustomItem(item);
	end

	-- for i=1,#m_datas do
	-- 	print("oppName = " .. m_datas[i].oppName);
	-- 	print("mode    = " .. m_datas[i].mode);
	-- 	print("result  = " .. m_datas[i].result);
	-- 	print("score   = " .. m_datas[i].score);
	-- 	print("battleId= " .. m_datas[i].battleId);
	-- 	print("  ");
	-- 	local item = m_item:clone();

	-- 	local playBackBtn = tolua.cast(item:getChildByName("playback_btn"), "Button");
	-- 	playBackBtn:setTag(i);
	-- 	playBackBtn:addTouchEventListener(playbackOnTouch);
	-- 	local isWin = isWin(m_datas[i]);
	-- 	local result_Img = tolua.cast(item:getChildByName("result_img"), "ImageView");
	-- 	if(isWin) then
	-- 		result_Img:loadTexture(PATH_CCS_RES .. "gy_bt_sheng.png");
	-- 	else
	-- 		result_Img:loadTexture(PATH_CCS_RES .. "gy_bt_fu.png");
	-- 	end
	-- 	local desc_label = tolua.cast(item:getChildByName("desc_label"), "Label");
	-- 	desc_label:setText(resultDesc(m_datas[i]));
	-- 	m_list:pushBackCustomItem(item);
	-- end
end

function onReceiveReportDataFromServer( messageType, messageData )
	m_datas = nil;
	m_datas = messageData;
	receiveDataEnd();
	--oppName,
	--mode,
	--result,
	--score,
	--battleId
end

local function setPosition(node)
	local w = node:getContentSize().width;
	local h = node:getContentSize().height;
	node:setPosition(ccp((SCREEN_WIDTH - w)/2, (SCREEN_HEIGHT - h)/2));
end



function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		-- m_rootLayer:setPosition(m_defPos);

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		m_rootLayer:addChild(bgLayer, 0);
		bgLayer:registerScriptTouchHandler(bgOnClick);

		local uiLayer = TouchGroup:create();
		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "JJCReport.json");
		uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(uiLayer, 1);
		-- setPosition(uiLayout);

		m_list = tolua.cast(uiLayer:getWidgetByName("report_list"), "ListView");
		m_list:retain();

		local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "JJCReportItem.json");
	    m_item = tolua.cast(item,"Widget");
	    m_item:retain();
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
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
		m_list:release();
		m_list = nil;
		m_item:release();
		m_item = nil;
	end
end