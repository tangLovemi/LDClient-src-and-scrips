--
-- Author: gaojiefeng
-- Date: 2014-11-19 16:18:22
--
module("Battle_simulator", package.seeall)

require "Scene/DialogTest"


local m_rootLayer = nil;
local m_itemBase = nil
local m_user1List = nil
local m_user2List = nil
local m_propName = {
	"等级",
	"外套ID",
	"技能1",
	"技能2",
	"技能3",
	"技能4",
	"技能5",
	"血量",
	"攻击力",
	"防御力",
	"速度值",
	"重击值",
	"暴击值",
	"反击值",
	"格挡值",
	"闪避值",
	"精灵武器",
	}

local m_user1TextFields = {}
local m_user2TextFields = {}

local total_win = nil;
local win_per = nil;
local fighttimes_per = nil;
local fighttimes_per_b = nil;
local battle_desc= nil;


local winTotal = 0;
local winper = 0;
local fighttimesper = 0

local function receiveBattle_simulator(messageType, messageData )
	local  aaa = 1
	myGameList:removeAllChildren();
    local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Battle_simulator_item_1.json");
	itemNew = tolua.cast(item,"Widget");
	local batlttle_desc = tolua.cast(itemNew:getChildByName("text_desc"), "Label");
	batlttle_desc:setText(messageData.battle_desc)
	print(messageData.battle_desc)

	myGameList:pushBackCustomItem(itemNew);
	
	total_win:setText(messageData.win1)
	win_per:setText(tonumber(messageData.roundData));
	fighttimes_per:setText(messageData.times1)
	fighttimes_per_b:setText(messageData.times2)

end 

NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_BATTLE_SIMULATORRESPONS, receiveBattle_simulator);

local function exitTouchEvent(sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		myGameList:removeAllChildren();
		UIManager.close("Battle_simulator");
	end
end 

local function startTouchEvent(sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then	

		local  user1_level 	= tonumber(m_user1TextFields[1]:getStringValue())	
		local  user1_coatID = tonumber(m_user1TextFields[2]:getStringValue())			
		local  user1_skill1 = tonumber(m_user1TextFields[3]:getStringValue())			
		local  user1_skill2 = tonumber(m_user1TextFields[4]:getStringValue())			
		local  user1_skill3 = tonumber(m_user1TextFields[5]:getStringValue())			
		local  user1_skill4 = tonumber(m_user1TextFields[6]:getStringValue())			
		local  user1_skill5	= tonumber(m_user1TextFields[7]:getStringValue())		
		local  user1_hp		= tonumber(m_user1TextFields[8]:getStringValue())	
		local  user1_attack	= tonumber(m_user1TextFields[9]:getStringValue())		
		local  user1_defense= tonumber(m_user1TextFields[10]:getStringValue())			
		local  user1_speed	= tonumber(m_user1TextFields[11]:getStringValue())		
		local  user1_bash	= tonumber(m_user1TextFields[12]:getStringValue())		
		local  user1_crit	= tonumber(m_user1TextFields[13]:getStringValue())		
		local  user1_counterAttack	= tonumber(m_user1TextFields[14]:getStringValue())		
		local  user1_parry	= tonumber(m_user1TextFields[15]:getStringValue())		
		local  user1_dodge	= tonumber(m_user1TextFields[16]:getStringValue())		
		local  user1_spriteequip = tonumber(m_user1TextFields[17]:getStringValue())			


		local  user2_level 	= tonumber(m_user2TextFields[1]:getStringValue())	
		local  user2_coatID = tonumber(m_user2TextFields[2]:getStringValue())			
		local  user2_skill1 = tonumber(m_user2TextFields[3]:getStringValue())			
		local  user2_skill2 = tonumber(m_user2TextFields[4]:getStringValue())			
		local  user2_skill3 = tonumber(m_user2TextFields[5]:getStringValue())			
		local  user2_skill4 = tonumber(m_user2TextFields[6]:getStringValue())			
		local  user2_skill5	= tonumber(m_user2TextFields[7]:getStringValue())		
		local  user2_hp		= tonumber(m_user2TextFields[8]:getStringValue())	
		local  user2_attack	= tonumber(m_user2TextFields[9]:getStringValue())		
		local  user2_defense= tonumber(m_user2TextFields[10]:getStringValue())			
		local  user2_speed	= tonumber(m_user2TextFields[11]:getStringValue())		
		local  user2_bash	= tonumber(m_user2TextFields[12]:getStringValue())		
		local  user2_crit	= tonumber(m_user2TextFields[13]:getStringValue())		
		local  user2_counterAttack	= tonumber(m_user2TextFields[14]:getStringValue())		
		local  user2_parry	= tonumber(m_user2TextFields[15]:getStringValue())		
		local  user2_dodge	= tonumber(m_user2TextFields[16]:getStringValue())		
		local  user2_spriteequip = tonumber(m_user2TextFields[17]:getStringValue())		

		battleTime= tonumber(battle_time:getStringValue())

	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_BATTLE_SIMULATOR, {user1_level,
		user1_coatID,
		user1_skill1,
		user1_skill2,
		user1_skill3,
		user1_skill4 ,		
		user1_skill5,	
		user1_hp,
		user1_attack,	
		user1_defense,			
		user1_speed,		
		user1_bash,		
		user1_crit,		
		user1_counterAttack,		
		user1_parry,		
		user1_dodge,		
		user1_spriteequip,

		user2_level,
		user2_coatID,
		user2_skill1,
		user2_skill2,
		user2_skill3,
		user2_skill4 ,		
		user2_skill5,	
		user2_hp,
		user2_attack,	
		user2_defense,			
		user2_speed,		
		user2_bash,		
		user2_crit,		
		user2_counterAttack,		
		user2_parry,		
		user2_dodge,		
		user2_spriteequip,	
		battleTime
		});
	CCLuaLog("发送成功！")		
	end
end 



function create()
	-- body
	m_rootLayer = CCLayer:create();

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "battle_simulator_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);

    local loginBtn = uiLayer:getWidgetByName("statBtn");
    loginBtn:addTouchEventListener(startTouchEvent);


    local loginBtn = uiLayer:getWidgetByName("closeBtn");
    loginBtn:addTouchEventListener(exitTouchEvent);


    m_user1List = tolua.cast(uiLayout:getChildByName("use1_lst"),"ListView");
    m_user2List = tolua.cast(uiLayout:getChildByName("use2_lst"),"ListView");



    m_itemBase = tolua.cast(uiLayout:getChildByName("item_panel"),"Layout");


   for i=1,#m_propName do
	   	local tempItem = m_itemBase:clone()
	   	local nameLabel = tolua.cast(tempItem:getChildByName("name"),"Label")
	   	m_user1TextFields[i]= tolua.cast(tempItem:getChildByName("TextField_11"),"TextField")
	   	nameLabel:setText(m_propName[i])
	   	m_user1TextFields[i]:setText("1")
	   	m_user1List:pushBackCustomItem(tempItem)
   end


   for i=1,#m_propName do
	   	local tempItem = m_itemBase:clone()
	   	local nameLabel = tolua.cast(tempItem:getChildByName("name"),"Label")
	   	m_user2TextFields[i]= tolua.cast(tempItem:getChildByName("TextField_11"),"TextField")
	   	m_user2TextFields[i]:setText("1")
	   	nameLabel:setText(m_propName[i])
	   	m_user2List:pushBackCustomItem(tempItem)
   end

	battle_desc = tolua.cast(uiLayout:getChildByName("battle_desc"),"Label");
	total_win = tolua.cast(uiLayout:getChildByName("total_win"),"TextField");
	win_per = tolua.cast(uiLayout:getChildByName("win_per"),"TextField");
	fighttimes_per = tolua.cast(uiLayout:getChildByName("fighttimes_per"),"TextField");
	fighttimes_per_b = tolua.cast(uiLayout:getChildByName("fighttimes_per_b"),"TextField");

	battle_time = tolua.cast(uiLayout:getChildByName("battle_time"),"TextField");    


    myGameList = tolua.cast(uiLayout:getChildByName("battle_ListView"),"ListView"); 
    local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Battle_simulator_item_1.json");

end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	-- --测试对话框
	-- DialogTest.create()
	-- DialogTest.open()
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);

end

function remove()
	-- body
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_LOGIN, receiveDataFromServer);
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	initVariables();
end
