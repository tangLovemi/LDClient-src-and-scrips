module("BetUI", package.seeall)

local m_rootLayer = nil;
local m_roleList  = {};
local m_uiLayer   = nil;
local m_leftTextFiled = nil;
local m_rightTextFiled = nil;
local m_battleId  = nil;
local m_buttonList = {};
local m_curRole = 0;
local m_curType = 0;
SETTING_POSITION = ccp(WINSIZE.width/2 - 760/2,WINSIZE.height/2 - 450/2);
LEFTROLE = 1;
RIGHTROLE = 2;


local function exitTouchEvent(sender,eventType)
	
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("BetUI");
	end
end

local function initVariables()
	-- body
	m_roleList  = {};
	m_uiLayer   = nil;
	m_battleId  = nil;
	m_rootLayer = nil;
	m_buttonList = {};
	m_curRole = 0;
	m_curType = 0;
end

local function onTouch(eventType, x, y)
    if eventType == "began" then
    	return true;
    elseif eventType == "ended" then
        UIManager.close("BetUI");
        initVariables();
  --       local leftRolePanel = tolua.cast(m_uiLayer:getWidgetByName("leftPanel"),"Layout");
		-- local rightRolePanel = tolua.cast(m_uiLayer:getWidgetByName("rightPanel"),"Layout");
  --       local leftmoneyTextField = tolua.cast(leftRolePanel:getChildByName("money_textfield"),"TextField");
  --       local rightMoneyTextField = tolua.cast(rightRolePanel:getChildByName("money_textfield"),"TextField");
    end
end

local function setHeadPanel(headPanel)
	-- body
end

local function betTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_curRole == 0)then
			return;
		end
		local role = nil;
		local money  = 0;
		if m_curRole == LEFTROLE then
			role = m_roleList.leftData.id;
			money = m_curType;
		else
			role = m_roleList.rightData.id;
			money = m_curType;
		end
		local count = 0;
		if(m_curType == 1)then
			count = 50000;
		elseif(m_curType == 1)then
			count = 100000;
		else
			count = 200000;
		end
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURNAMENT_BET,{role,m_battleId,count});
		
	end 
end

local function setPanelContent(layout,roleList,isLeft)
	-- body
	local headPanel = tolua.cast(layout:getChildByName("tou_img"),"Layout");
	local lvLabel   = tolua.cast(layout:getChildByName("levelText"),"Label");
	local fightLabel = tolua.cast(layout:getChildByName("fightText"),"Label");
	local namePanel = tolua.cast(headPanel:getChildByName("Panel_78"),"Layout");
	local nameLabel = tolua.cast(namePanel:getChildByName("nameText"),"Label");
	nameLabel:setText(roleList.name);
	local moneyTextField = tolua.cast(layout:getChildByName("money1_textfield"),"TextField");
	local buttonpanel = tolua.cast(layout:getChildByName("button_panel"),"Layout");
	local portraitPanel = tolua.cast(layout:getChildByName("portrait"),"Layout");
	local node =  Util.createHeadLayout(roleList.hair,roleList.color,roleList.face,2);
	portraitPanel:addChild(node);


	table.insert(m_buttonList,buttonpanel:getChildByName("Button_10"));
	table.insert(m_buttonList,buttonpanel:getChildByName("Button_11"));
	table.insert(m_buttonList,buttonpanel:getChildByName("Button_12"));
	-- betBtn:addTouchEventListener(betTouchEvent);
	fightLabel:setText(tostring(roleList.battle));
	lvLabel:setText(tostring(roleList.level));
	setHeadPanel(headPanel);
end

local function clickBet(sender,eventType)
	local tag = sender:getTag();
	local type = 0;
	if(tag > 10003)then
		m_curRole = RIGHTROLE;
		type = tag-10003;
	else
		m_curRole = LEFTROLE;
		type = tag-10000;
	end
	m_curType = type;
end

local function initRolePanel()
	-- body
	local leftRolePanel = tolua.cast(m_uiLayer:getWidgetByName("leftPanel"),"Layout");
	local rightRolePanel = tolua.cast(m_uiLayer:getWidgetByName("rightPanel"),"Layout");

	setPanelContent(leftRolePanel,m_roleList.leftData,true);
	setPanelContent(rightRolePanel,m_roleList.rightData,false);
	MutipleButtonList.create(m_buttonList,false,clickBet);
end

--设置人物列表
function setTheRoleList(leftRole,rightRole,leftSupport,rightSupport)
	-- body
	CCLuaLog("leftRole:"..leftRole);
	CCLuaLog("rightRole:"..rightRole);
	m_roleList.leftRole  = leftRole;
	m_roleList.rightRole = rightRole;
	m_roleList.leftSupport = leftSupport;
	m_roleList.rightSupport = rightSupport;
end

--何止战斗ID
function setBattleId(bettleId)
	-- body
	CCLuaLog("battleId:&&&&&&"..bettleId);
	m_battleId = bettleId;
end


function create()
	-- body
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
  	m_rootLayer:addChild(bgLayer);

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "BetUI_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    -- m_rootLayer:addChild(uiLayer);

    uiLayer:setPosition(SETTING_POSITION);

    m_uiLayer = uiLayer;
	m_rootLayer:addChild(UIManager.bounceOut(m_uiLayer));
end

function reflushUI(data)
	setBattleId(data.id);
	m_roleList = {};
	m_roleList.leftData = {}; 
	m_roleList.rightData = {};
	m_roleList.leftData.id = data.attackerID;
	m_roleList.leftData.name = data.attackerName;
	m_roleList.leftData.level = data.leftLevel;
	m_roleList.leftData.battle = data.leftBattleValue;
	m_roleList.leftData.hair = data.hair1;
	m_roleList.leftData.color = data.color1;
	m_roleList.leftData.cloth = data.cloth1;
	m_roleList.leftData.face = data.face1;

	m_roleList.rightData.id = data.defenserID;
	m_roleList.rightData.name = data.defenserName;
	m_roleList.rightData.level = data.rightLevel;
	m_roleList.rightData.battle = data.rightBattleValue;

	m_roleList.rightData.hair = data.hair2;
	m_roleList.rightData.color = data.color2;
	m_roleList.rightData.cloth = data.cloth2;
	m_roleList.rightData.face = data.face2;

	local confirm = tolua.cast(m_uiLayer:getWidgetByName("queding_btn"),"Layout");
	confirm:addTouchEventListener(betTouchEvent);
	initRolePanel();
end

function open()
	-- body
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	-- initRolePanel();
end

function close()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
	m_rootLayer = nil;
	initVariables();
end

function remove()

end