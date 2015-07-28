module("TrainFight", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;

local m_nowExpLabel = nil;
local m_kingExpLabel = nil;
local m_jjcRankingLabel = nil;

local m_index = 0;

local function onTouch(eventType,x,y)
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		TrainFight.close();
	end
end

local function fightOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_index ~= 0) then
			local curAccount = TrainUI.getSeatsData(m_index).id;
			if(curAccount) then
				NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_FIGHT, {m_index, curAccount, TrainUI.getCurPageIndex()});
				TrainMgr.open();
				TrainFight.close();
			end
		end
	end
end

local function openInit(index)
	m_jjcRankingLabel:setText("");

	local data = {};
	if(index) then
		m_index = index;
		data = TrainUI.getSeatsData(m_index);
		local perdata = TrainUI.getPersonalData();
		--经验、竞技场排名
		m_nowExpLabel:setText(0);
		if(perdata.statusId == 2) then
			m_nowExpLabel:setText(perdata.nowPerExp);
		elseif(perdata.statusId == 3) then
			m_nowExpLabel:setText(perdata.nowKingExp);
		end
		m_kingExpLabel:setText(perdata.nowKingExp);

		if(m_index ~= 0) then
			-- m_nameLabel:setText(data.name);
			m_jjcRankingLabel:setText(data.jjcRanking);
		end

		--其它信息
		local seatPanel1 = tolua.cast(m_uiLayer:getWidgetByName("seat1_panel"), "Layout");
		local seatPanel2 = tolua.cast(m_uiLayer:getWidgetByName("seat2_panel"), "Layout");
		local seatPanel3 = tolua.cast(m_uiLayer:getWidgetByName("seat3_panel"), "Layout");
		seatPanel1:setEnabled(false);
		seatPanel2:setEnabled(false);
		seatPanel3:setEnabled(false);
		local groupid = perdata.jjcGroupid;
		local nameLabel = nil;
		local levelLabel = nil;
		local headPanel = nil;
		if(groupid == 0) then
			seatPanel1:setEnabled(true);
			nameLabel = tolua.cast(seatPanel1:getChildByName("name_label"), "Label");
			levelLabel = tolua.cast(seatPanel1:getChildByName("level_label"), "Label");
			headPanel = tolua.cast(seatPanel1:getChildByName("head_panel"), "Label");
		elseif(groupid == 1) then
			seatPanel2:setEnabled(true);
			nameLabel = tolua.cast(seatPanel2:getChildByName("name_label"), "Label");
			levelLabel = tolua.cast(seatPanel2:getChildByName("level_label"), "Label");
			headPanel = tolua.cast(seatPanel2:getChildByName("head_panel"), "Label");
		else
			seatPanel3:setEnabled(true);
			nameLabel = tolua.cast(seatPanel3:getChildByName("name_label"), "Label");
			levelLabel = tolua.cast(seatPanel3:getChildByName("level_label"), "Label");
			headPanel = tolua.cast(seatPanel3:getChildByName("head_panel"), "Label");
			local bgImg = tolua.cast(seatPanel3:getChildByName("bg_img"), "ImageView");
			bgImg:loadTexture(TrainUI.getGroupSeatBg(groupid + 1));
		end

		nameLabel:setText(data.name);
		levelLabel:setText(data.level);
		local face = Util.createHeadNode(data.hair, data.haircolor, data.face, data.coat);
		local headScaleX, headScaleY = TrainUI.getHeadScale();
		local headPos = TrainUI.getHeadPos();
		face:setScaleX(headScaleX);
		face:setScaleY(headScaleY);
		face:setPosition(headPos);
		headPanel:addNode(face);
	else
		print("座位index为空");
		close();
	end
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		bgLayer:registerScriptTouchHandler(onTouch);
		m_rootLayer:addChild(bgLayer, 0);

		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TrainFight.json");
		m_uiLayer = TouchGroup:create();
		m_uiLayer:retain();
		m_uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(m_uiLayer, 1);

		m_rootLayer:retain();
		
		m_nowExpLabel = tolua.cast(m_uiLayer:getWidgetByName("nowExp_label"), "Label");
		m_kingExpLabel = tolua.cast(m_uiLayer:getWidgetByName("kingExp_label"), "Label");
		m_jjcRankingLabel = tolua.cast(m_uiLayer:getWidgetByName("jjcRanking_label"), "Label");

		tolua.cast(m_uiLayer:getWidgetByName("fight_btn"), "Button"):addTouchEventListener(fightOnClick);
	end
end


function open(index)
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
		m_index = 0;
		openInit(index);
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		-- body	
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		m_uiLayer:release();
		m_uiLayer = nil;
	end
end
