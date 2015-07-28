module("SweepReward", package.seeall)

local m_rootLayer = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 320/2,WINSIZE.height/2 - 400/2);
local m_item = nil;

local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("SweepReward");
    end
end

local function initItem(index,data)

	local item = m_item:clone();
	local panel = tolua.cast(item:getChildByName("Panel_1"),"Layout");
	local moneyLabel = tolua.cast(panel:getChildByName("AtlasLabel_10"),"LabelAtlas");
	local expLabel = tolua.cast(panel:getChildByName("AtlasLabel_8"),"LabelAtlas");
	local timeLabel = tolua.cast(panel:getChildByName("AtlasLabel_5"),"LabelAtlas");
	moneyLabel:setStringValue(tostring(data.money));
	expLabel:setStringValue(tostring(data.exp));
	timeLabel:setStringValue(tostring(index));
	-- local list = tolua.cast(panel:getChildByName("ListView_11"),"ListView");
	local imageList = {};
	local panel = nil;
	local width = item:getSize().width;
	local panelList = {};
	for i,v in pairs(data.list) do
		local res = GoodsManager.getIconPathById(v[1]);
		if(Util.getRemainder(i-1,3) == 0)then
			panel = Layout:create();
			panel:setSize(CCSize(width,75));
			table.insert(panelList,panel);
			-- list:pushBackCustomItem(panel);
		end
		if(res ~= "")then
			local image = ImageView:create();
			image:loadTexture(res,0);
			local frame = ImageView:create();
			frame:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(v[1])),0);
			-- frame:setAnchorPoint(CCPoint(0,0));
			image:addChild(frame);
			local interval = (width - 20 - (image:getContentSize().width*3))/2;
			image:setPositionX(10 + image:getContentSize().width /2 +(i-1)*(image:getContentSize().width + interval));
			image:setPositionY(image:getContentSize().height/2);
			-- image:setAnchorPoint(CCPoint(0,0));
			panel:addChild(image);
		end
	end
	local view = Layout:create();
	local posy = 0;
	if(#panelList ~= 0)then
		for i= #panelList,1,-1 do
			panelList[i]:setPositionY(posy);
			posy = posy + panelList[i]:getSize().height;
			view:addChild(panelList[i]);
		end
	end
	item:setPositionY(posy);
	posy = posy + item:getSize().height;
	view:addChild(item);
	view:setSize(CCSize(item:getSize().width,posy));
	return view;
end

function create()
	m_rootLayer = CCLayer:create();
	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
    m_rootLayer:addChild(bgLayer);
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "saodang_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    uiLayer:setPosition(SETTING_POSITION);
    local list = tolua.cast(uiLayer:getWidgetByName("ListView_12"),"ListView");
	
	local rewardData = SaoDangManager.getData();

	m_item = tolua.cast(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "saodang_1_1.json"),"Widget");
	m_item:retain();
	for i=1,#rewardData do
		list:pushBackCustomItem(initItem(i,rewardData[i]));
	end
	local imageLayout = Layout:create();

	local image1 = ImageView:create();
	image1:loadTexture(PATH_CCS_RES .. "saodang_wz_wancheng.png");
	imageLayout:setSize(CCSize(list:getSize().width,image1:getContentSize().height));
	image1:setPositionX(list:getSize().width/2);
	image1:setPositionY(image1:getContentSize().height/2);
	imageLayout:addChild(image1);

	list:pushBackCustomItem(imageLayout);
end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer,1);
	ClipTouchLayer.clear();
end

function close()
	m_item:release();
	m_item = nil;
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer, true);
	m_rootLayer = nil;
end

function remove()

end
