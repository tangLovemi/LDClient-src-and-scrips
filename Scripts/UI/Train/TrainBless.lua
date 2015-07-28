module("TrainBless", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;

local m_descLabel = nil;
local m_curIndex = 0;

local function getBlessCount( type )
	if(type == 1) then
		return UserInfoManager.getGoodsCount(GoodsManager.getTrainBless1Id());
	elseif(type == 2) then
		return UserInfoManager.getGoodsCount(GoodsManager.getTrainBless2Id());
	elseif(type == 3) then
		return UserInfoManager.getGoodsCount(GoodsManager.getTrainBless3Id());
	end
end

local function closeOnTouch(sender,eventType)
	if(eventType == TOUCH_EVENT_TYPE_END) then
		TrainBless.close();
	end
end

local function buyResponse(messageType, messageData )
	ProgressRadial.close();
	local result = messageData.result;
	if(result == 1) then
		Util.showOperateResultPrompt("购买成功");
		refreshCount();
	elseif(result == 0) then
		Util.showOperateResultPrompt("钻石不足");
	end
end

--使用按钮点击
local function useOnClick(sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_curIndex > 0) then
			local perData = TrainUI.getPersonalData();
			if(perData.isBless == 0) then
				local haveCount = getBlessCount(m_curIndex);
				if(haveCount > 0) then
					--使用祝福卡
					ProgressRadial.open();
					NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_START_BLESS, {m_curIndex});
					TrainMgr.open();
        			AudioEngine.playEffect(PATH_RES_AUDIO.."beizhufu.mp3");
				else
					local function buy()
						if(GoodsManager.isBackpackFull_2()) then
							--背包满提示
							BackpackFullTishi.show();
						else
							--继续
							ProgressRadial.open();
							UIManager.close("ErrorDialog");
							TrainBless.open(m_curIndex);
							NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_BUY_BLESS, {m_curIndex});
						end
					end
					TrainBless.close();
					--无此祝福卡，显示购买提示
					local price = DataTableManager.getValue("TrainBlessData", "id_" .. m_curIndex, "price");
					UIManager.open("ErrorDialog");
					local str = "数量为0，是否花费" .. price .. "钻石购买祝福卡"
					local funs = {};
					table.insert(funs,function () UIManager.close("ErrorDialog"); TrainBless.open(m_curIndex);end);
					table.insert(funs,buy);
					ErrorDialog.setPanelStyle(str,funs);
				end
			else
				Util.showOperateResultPrompt("祝福时间内，无法再次使用祝福卡");
			end
		else
			Util.showOperateResultPrompt("请选择祝福卡");
		end
	end
end

local function cardOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		
		if(m_curIndex ~= 0) then
			m_uiLayer:getWidgetByName("select_img_" .. m_curIndex):setEnabled(false);
		end
		m_curIndex = sender:getTag();
		m_uiLayer:getWidgetByName("select_img_" .. m_curIndex):setEnabled(true);
	end
end

local function attachCard()
	for i = 1,3 do
		local cardImg = m_uiLayer:getWidgetByName("card_img_" .. i);
		cardImg:setTag(i);
		cardImg:addTouchEventListener(cardOnClick);
		m_uiLayer:getWidgetByName("select_img_" .. i):setEnabled(false);
	end
end

function refreshCount()
	for i=1,3 do
		local countLabel = tolua.cast(m_uiLayer:getWidgetByName("count_atlas_" .. i), "LabelAtlas");
		countLabel:setStringValue(getBlessCount(i));
	end
end

local function openInit()
	for i=1,3 do
		local countLabel = tolua.cast(m_uiLayer:getWidgetByName("count_atlas_" .. i), "LabelAtlas");
		m_uiLayer:getWidgetByName("select_img_" .. i):setEnabled(false);
	end
	if(m_curIndex > 0) then
		m_uiLayer:getWidgetByName("select_img_" .. m_curIndex):setEnabled(true);
	end
	refreshCount();
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();

		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TG_blessingUI.json");
		m_uiLayer = TouchGroup:create();
		m_uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(m_uiLayer, 1);

		m_rootLayer:retain();

		m_uiLayer:getWidgetByName("bg_panel"):addTouchEventListener(closeOnTouch);
		m_uiLayer:getWidgetByName("use_btn"):addTouchEventListener(useOnClick);
		
		attachCard();

		NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_BUY_BLESSRESPONSE, buyResponse);
	end
end


function open(index)
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);
		m_curIndex = 0;
		if(index) then
			m_curIndex = index;
		end
		openInit();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		ProgressRadial.close();
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		-- body	
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		m_uiLayer 	= nil;
		NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_TRAIN_BUY_BLESSRESPONSE, buyResponse);
	end
end
