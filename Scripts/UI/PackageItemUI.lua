module("PackageItemUI", package.seeall)

local m_rootLayer = nil;
local m_uiLayer   = nil;


SETTING_POSITION = ccp(WINSIZE.width/2 - 200/2,WINSIZE.height/2 - 260/2);


local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("PackageItemUI");
	end
end


local function onTouch(eventType, x, y)
    if eventType == "began" then
    	return true;
    elseif eventType == "ended" then
        UIManager.close("PackageItemUI");
    end
end


local function setGoodsList(goodsTable)
	-- body
	local goodsList = tolua.cast(m_uiLayer:getWidgetByName("goods_listView"),"ListView");

	for i=1,#goodsTable do
		local good = goodsTable[i];
		local goodLabel = Label:create();
		goodLabel:setText(good);
		goodLabel:setColor(ccc3(0,0,0));
		goodLabel:setFontSize(10);
		-- local size = goodLabel:getContentSize();
		-- goodLabel:setPosition(ccp(size.width/2,size.height/2));

		goodsList:pushBackCustomItem(goodLabel);
	end
end 

local function cleanGoodsList()
	-- body
	local goodsList = tolua.cast(m_uiLayer:getWidgetByName("goods_listView"),"ListView");
	goodsList:removeAllItems();
end 

local function initVariables()
	-- body
	m_uiLayer = nil;
end


function setLayer(imagePath,name,state,products)
	-- body
end

function create()
	-- body
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
  	m_rootLayer:addChild(bgLayer);

	local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "PackageItemUI_1.json");
	uiLayer = TouchGroup:create();
	uiLayer:addWidget(hotelLayer);
	m_rootLayer:addChild(uiLayer);

	hotelLayer:setPosition(SETTING_POSITION);
	-- m_rootLayer:retain();

	local exitBtn = uiLayer:getWidgetByName("exit_btn");
	exitBtn:addTouchEventListener(exitTouchEvent);

	m_uiLayer = uiLayer;

end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	local goodsTable = {"xxxxxxx* 2","xxasdasdasd * 3"};
	setGoodsList(goodsTable);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	cleanGoodsList();
end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer = nil;
	initVariables();
end