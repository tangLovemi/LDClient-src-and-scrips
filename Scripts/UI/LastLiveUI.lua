module("LastLiveUI", package.seeall)
require "UI/BetUI"

local m_rootLayer = nil;
local m_uiLayer   = nil;
local m_tag = {1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1};
local m_betMoney  = nil;
local m_curBet = nil;

local m_roleLists = {};
local m_betlist    = {1,1,1,1};
local m_battleLists = {};

local m_item = nil;

WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 1136/2,WINSIZE.height/2 - 640/2);

function removeCurrentSources()
	MainCityLogic.removeMainCity();
end

local function playTouchevent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		id = tolua.cast(sender,"Layout"):getName();
		BattleManager.enterBattleRecord(BATTLE_MAIN_TYPE_PVP,BATTLE_SUBTYPE_TOURNAMENT,id,removeMainCity);
	end
end

function getCurBet()
	return m_curBet;
end

local function betTouchevent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		local tag = sender:getTag();
		if(TournamentManager.getMatchData()[tag].isBet == 1)then
			Util.showOperateResultPrompt("已押注");
		else
			UIManager.open("BetUI");
			m_curBet = tag;
			BetUI.reflushUI(TournamentManager.getMatchData()[tag]);
		end

	end
end 

local function exitTouchEvent(sender,eventType)
	
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("LastLiveUI");
	end
end
--我的押注按钮触发事件
local function myBetTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("MyBetUI");
	end
end 

--比赛规则按钮触发事件
--local function GameRulesTouchEvent(sender,eventType)
	-- body
--	if eventType == TOUCH_EVENT_TYPE_END then
--		UIManager.open("GameRules");
--	end
--end

--我的比赛按钮触发事件
local function mybsTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.open("BD_MyGameUI");
	end
end

local function initVariables()
	-- body
	m_betMoney     = nil;
	-- m_item:release();
	-- m_item = nil;
	m_roleLists  = {};
	m_betlist    = {};
 	m_battleLists = {};
end


local function initRoleItem()
	-- body
	for i=1,16 do
		local item = m_item:clone();
		item:setTag(1);
       	local str  = "role_" .. i .. "_panel";
       	local rolePanel = tolua.cast(m_uiLayer:getWidgetByName(str),"Layout");
       	rolePanel:addChild(item);
	end
end

function reflushUI()
	local rolelist = {};
	local linepanel = tolua.cast(m_uiLayer:getWidgetByName("line_panel_0"),"Layout");
	local array = linepanel:getChildren();
	local count = array:count();


	local linepanel1 = tolua.cast(m_uiLayer:getWidgetByName("line_panel"),"Layout");
	local array1 = linepanel1:getChildren();
	local count1 = array1:count();
	for i,v in pairs(TournamentManager.getMatchData())do
		if(v.winner ~= 0)then
			for m=1,count1 do
				local obj = array1:objectAtIndex(m - 1);
				local name = tolua.cast(obj,"Layout"):getName();
				local split = Util.Split(name, "-");
				local winner = v.winner;
				if(tonumber(split[2]) == v.id)then
					if(tonumber(split[3]) == v.winner)then
						obj:setVisible(true);
					end
				end
			end
		end

		if(v.id <= 8)then
			local data = {};
			data.name = v.attackerName;
			data.level = v.leftLevel;
			data.id = v.attackerID;
			data.hair = v.hair1;
			data.color = v.color1;
			data.face = v.face1;
			local data1 = {};
			data1.name = v.defenserName;
			data1.level = v.rightLevel;
			data1.id = v.defenserID;
			data1.hair = v.hair2;
			data1.color = v.color2;
			data1.face = v.face2;
			data.visiable = false;
			data1.visiable = false;
			if(v.winner == 1)then
				data1.visiable = true;
			elseif(v.winner ==2 )then
				data.visiable = true;
			end
			table.insert(rolelist,data);
			table.insert(rolelist,data1);
		end
		local playBtnName = "playbtn" .. v.id;
		local betBtnName = "betbtn" .. v.id;
		local btn = nil;
		if(v.winner == 0)then
			btn = tolua.cast(m_uiLayer:getWidgetByName(betBtnName),"Button");
			btn:setTouchEnabled(true);
			btn:addTouchEventListener(betTouchevent);
		else
			btn = tolua.cast(m_uiLayer:getWidgetByName(playBtnName),"Button");
			btn:setName(v.videoID);
			btn:setTouchEnabled(true);
			btn:addTouchEventListener(playTouchevent);
		end
		btn:setTouchEnabled(true);
		btn:setVisible(true);
		btn:setTag(v.id);
	end
	for i,v in pairs(rolelist) do
		local str  = "role_" .. i .. "_panel";--初始比赛人物
       	local rolePanel = tolua.cast(m_uiLayer:getWidgetByName(str),"Layout");
       	setRole(rolePanel,v.level,v.name,v.visiable,v.hair,v.color,v.face);
	end
	local roleData = TournamentManager.getState();
	if(roleData.name ~= "")then
		local roleData = TournamentManager.getState();
		local portraitPanel = tolua.cast(m_uiLayer:getWidgetByName("portrait"),"Layout");
		local portrait = Util.createHeadLayout(roleData.hair,roleData.color,roleData.face,2);
		portraitPanel:addChild(portrait);
		local nameLabel = tolua.cast(m_uiLayer:getWidgetByName("Label_3"),"Label");
		nameLabel:setText(roleData.name);
	end
end

function setRole(role,level,name,isVisible,hair,color,face)
	local panel = role:getChildByName("Panel_20");
	local panel1 = panel:getChildByName("all_panel");
	local levelPanel = panel1:getChildByName("lv_panel");
	local namePanel = panel1:getChildByName("sjbw2_panel");
	local namePanel1 = namePanel:getChildByName("sjbw23_panel");
	local levelLabel = levelPanel:getChildByName("level_label");
	local nameLabel = namePanel1:getChildByName("sjbw1_label");
	local clipLayer = panel:getChildByName("Panel_2");
	local portraitPanel = panel1:getChildByName("Panel_5");
	local roleData = TournamentManager.getState();
	-- if(roleData.name ~= "")then
		local node =  Util.createHeadLayout(hair,color,face);
		portraitPanel:addChild(node);
	-- end
	tolua.cast(nameLabel,"Label"):setText(tostring(name));
	tolua.cast(levelLabel,"Label");
	levelLabel:setText(level);
	if(isVisible)then
		clipLayer:setVisible(true);
	end
end

local function onTouch(eventType, x, y)
    if eventType == "began" then
    	return true;
    elseif eventType == "ended" then
        UIManager.close("LastLiveUI");
    end
end

function create()
	-- body
	
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURNAMENT_LIVE, {});
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
  	m_rootLayer:addChild(bgLayer);

	local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "LastLiveUI_1.json");
	uiLayer = TouchGroup:create();
	uiLayer:addWidget(hotelLayer);
	m_rootLayer:addChild(uiLayer);

	hotelLayer:setPosition(SETTING_POSITION);


    -- local exitBtn = uiLayer:getWidgetByName("exit_btn");
    -- exitBtn:addTouchEventListener(exitTouchEvent);

    --我的投注
    local myBetBtn = uiLayer:getWidgetByName("myBet_panel");
    myBetBtn:addTouchEventListener(myBetTouchEvent);
    m_uiLayer = uiLayer;
    --比赛规则
    --local GameRulesBtn = uiLayer:getWidgetByName("last_panel");
   -- GameRulesBtn:addTouchEventListener("GameRulesTouchEvent");

    --我的比赛
   local mybsBtn = uiLayer:getWidgetByName("mybs_panel");
   mybsBtn:addTouchEventListener(mybsTouchEvent);

    

   	local item_2 = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI.."RoleItemUI_1.json");
	m_item = tolua.cast(item_2,"Widget");
    initRoleItem();

end

function open()
	-- body
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
	m_rootLayer = nil;
	m_uiLayer 	= nil;
	initVariables();
end

function remove()

end