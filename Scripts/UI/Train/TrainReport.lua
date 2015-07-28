module("TrainReport", package.seeall)
local m_uiLayout = nil;
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
		TrainReport.close();
	end
end

local function playbackOnTouch(sender,eventType)
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local tag = sender:getTag();
		print("*****战斗回放 tag = " .. tag);
		if(tag < #m_datas) then
			print("battleId = " .. m_datas[tag].battleId);
			BattleManager.enterBattleForRecord(1, 1,m_datas[tag].battleId);
		end
	end
end

local function isWin( data )
	-- if((data.mode == 1 and data.result == 1) or (data.mode == 2 and data.result == 0) ) then
	-- 	return true;
	-- end
	return(data.result == 1);
end

local function resultName(isWin)
	if(isWin) then
		return "胜";
	else
		return "负";
	end
end

local function resultDesc( data )
	if(data.mode == 1) then
		--self是攻击方
		if(data.result == 1) then
			return "您挑战了" .. data.oppName .. "，抢夺成功了"; 
		else
			return "您挑战了" .. data.oppName .. "，抢夺失败了"; 
		end
	else
		--self是防御方
		if(data.result == 1) then
			return data.oppName .. "想要抢夺你的位置，" .. "防御成功了"; 
		else
			return data.oppName .. "抢夺了你的位置，" .. "防御失败了"; 
		end
	end
end

local function openInit()
	m_list:removeAllItems();
	for i=#m_datas,1, -1 do
		local v = m_datas[i];
		local item = m_item:clone();
		-- local playBackBtn = tolua.cast(item:getChildByName("playback_btn"), "Button");
		-- playBackBtn:setTag(i);
		-- playBackBtn:addTouchEventListener(playbackOnTouch);
		local isWin = isWin(v);
		local resultImg = tolua.cast(item:getChildByName("result_img"), "ImageView");
		if(isWin) then
			resultImg:loadTexture(IMAGE_PATH.TRAIN_RESULT_SUCCESS);	
		else
			resultImg:loadTexture(IMAGE_PATH.TRAIN_RESULT_FAIL);	
		end
		local atkPanel = tolua.cast(item:getChildByName("atk_panel"), "Layout");
		local defPanel = tolua.cast(item:getChildByName("def_panel"), "Layout");
		if(v.mode == 1) then
			--self是攻击方
			atkPanel:setEnabled(true);
			defPanel:setEnabled(false);
			tolua.cast(atkPanel:getChildByName("name_label"), "Label"):setText(v.oppName);
			local descImg1 = tolua.cast(atkPanel:getChildByName("desc1_img"), "ImageView");
			local descImg2 = tolua.cast(atkPanel:getChildByName("desc2_img"), "ImageView");
			if(isWin) then
				descImg1:loadTexture(IMAGE_PATH.TRAIN_ATK_DESC_1_1);
				descImg2:loadTexture(IMAGE_PATH.TRAIN_ATK_DESC_2_1);
			else
				descImg1:loadTexture(IMAGE_PATH.TRAIN_ATK_DESC_1_0);
				descImg2:loadTexture(IMAGE_PATH.TRAIN_ATK_DESC_2_0);
			end
		else
			--self是防御方
			atkPanel:setEnabled(false);
			defPanel:setEnabled(true);
			tolua.cast(defPanel:getChildByName("name_label"), "Label"):setText(v.oppName);
			local descImg = tolua.cast(defPanel:getChildByName("desc_img"), "ImageView");
			if(isWin) then
				descImg:loadTexture(IMAGE_PATH.TRAIN_DEF_DESC_1);
			else
				descImg:loadTexture(IMAGE_PATH.TRAIN_DEF_DESC_0);
			end
		end
		m_list:pushBackCustomItem(item);
	end
end

function refresh()
	openInit();
end

function onReceiveReportDataFromServer( messageType, messageData )
	m_datas = nil;
	m_datas = messageData;
	print("***********  战报   size = " .. #m_datas);
	-- receiveDataEnd();

	-- oppName
	-- mode
	-- result
	-- battleId
end

function setPosition(pos)
	m_uiLayout:setPosition(pos);
end

function getRootLayout()
	return m_uiLayout;
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TrainReport.json");

		m_list = tolua.cast(m_uiLayout:getChildByName("report_list"), "ListView");
		m_list:retain();

		local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TrainReportItem.json");
	    m_item = tolua.cast(item,"Widget");
	    m_item:retain();
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
        m_uiLayout:removeFromParentAndCleanup(true);
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
        m_uiLayout = nil;
		m_list = nil;
		m_item = nil;
	end
end