module("GameManager", package.seeall)

require "NetWork/SJRecvMessage"
require "NetWork/SJSendMessage"
require "bit"
require "AudioEngine"
require "System/LayerManager"
require "System/TouchDispatcher"
require "System/Loading"
require "System/WordManager"
require "Scene/MainCityLogic"
require "Scene/MainCityActorAI"
require "Scene/MainCityPlayers"
require "Scene/WorldMap"
require "UI/ProgressRadial"
require "Event/EventManager"

require "NetWork/NetWorkConnect"
require "NetWork/NetMessageManager"
require "UI/UIManager"
require "Player/PlayerActor"
require "Battle/SkillData"
require "Battle/BattleManager"
require "Manager/MessageManager"
require "System/TimeRefresh"
require "DataMgr/DataTableManager"
require "TestControl"
require "Update/UpdateScene"
require "Scene/SelectLevel"
require "Manager/WorldManager"
require "Manager/ActivityManager"
require "Manager/NpcInfoManager"
require "Manager/TaskManager"
require "Manager/MailManager"
require "Manager/FriendsManager"
require "Manager/NotificationManager"


require "DataBase/DataBaseManager"
require "UI/BattleResult"
require "UI/OtherPlayer"

require "Manager/TournamentManager"
--广播系统
require "Broadcast/BroadcastLayer"
require "Broadcast/ScrollLabel"	
require "Manager/BroadcastManager"	
require "Util/MutipleButtonList"	
require "Util/SingleChoicePanel"	
require "Manager/ChatManager"

require "System/RewardsManager"
require "Util/ClipTouchLayer"

require "Manager/NetMessageResultManager"
require "UI/ErrorDialog"
require "UI/Upgrade"
require "Manager/LoginManager"
require "UI/ServerListUI"
require "UI/Login"
require "UI/SelectActorDialog"
require "UI/JJCResult"
require "UI/FailResult"
require "UI/TrainResult"
require "UI/BiWuResult"
require "Util/List"
require "UI/SweepDetail"
require "Manager/SaoDangManager"
require "UI/WishUI/WishManager"
require "UI/SweepReward"
require "UI/ShopListPanel"
require "UI/SwitchLayer"
require "UI/UnLockLevel"

local gameScene = nil;
local m_callBackFunc = nil
local m_wishGoldCountDown = 0
local m_wishDiamondCountDown = 0
DataBaseManager.init();


--从服务器接收数据完毕
-- local function loadDataFromServerEnd()
-- 	print("*****************  从服务器接收数据完毕*************************** ");

-- 	local function loadUI()
-- 		UIManager.create(enterMainCity);
-- 	end
-- 	-- enterMainCity();
-- 	function loadFace()
-- 		local loadFace = {resType = LOADING_TYPE_MODULE, resData = {loader = PlayerActor.initFace}};
-- 		Loading.create({loadFace}, loadUI);
-- 	end

-- 	loadFace();
-- end
function loadSceneEnd()
	Loading.remove();
	MainCityUI.open();
	NotificationManager.onLoginCheckAll();
	if m_callBackFunc~= nil then
		m_callBackFunc()
		m_callBackFunc = nil
	end
end

function enterMainCity()
	Loading.remove();
	MainCityLogic.create();
	MainCityLogic.EnterCity(1, loadSceneEnd);
end


function enterMainCityOther(index,callBack)
	PlayerActor.initFace();
	PlayerActor.initPlayerActor();
	Loading.remove();
	MainCityLogic.create();
	MainCityUI.create();
	MainCityLogic.EnterCity(index, loadSceneEnd);
	m_callBackFunc = callBack
end
-- --等待服务器加载数据
-- function loadDataFromServer()
-- 	if(TestControl.isTest() == true) then

-- 	else
-- 		UserInfoManager.create(loadDataFromServerEnd);
-- 		--发送请求
-- 		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_REQUESTALLDATA, {});
-- 	end
-- end


--流程：登录--> 进入游戏--> 接收服务器数据--> 加载UI界面--> 进入主城场景--> 显示主城UI
	 -- 注册--> 登录--> 捏脸-->|

function initGame()

	SaoDangManager.registerMessage();
	MainCityPlayers.registerMessageFunction();
	Login.registerMessage();
	NetMessageResultManager.registerMessage();
	ChatManager.registerMessage();
	BroadcastManager.registerMessage();
	ActivityManager.registMessage();
	DataBaseManager.init();
	TournamentManager.registerMessage();
	WorldManager.registMessage();
	BattleManager.registerMessage();
	-- BattleManager
	CCLuaLog("enter lua and init game");
	gameScene = CCScene:create();
	CCDirector:sharedDirector():runWithScene(gameScene);
	CCLuaLog("run with scene");
	createGameLayers(gameScene);
	CCLuaLog("create game scene");
	NetMessageManager.registerReceiveFunc();
	CCLuaLog("regis all receive fun");
	-- NetWorkConnect.create(gameScene);

	TouchDispatcher.create();
	CCLuaLog("touchdispatcher create");
	BattleManager.init(); ---

	WordManager.loadWords("word.json");
	CCLuaLog("loadwords");
	EventManager.init();
	CCLuaLog("EventManager init");
	DataTableManager.loadData(); ---
	-- CCLuaLog("DataTableManager.loadData");
	TimeRefresh.registerTimeRefresh();
	CCLuaLog("TimeRefresh.registerTimeRefresh");
	

	-- UpdateScene.checkUpdate();
	-- checkUpdate();
	
	Loading.init();
	-- WorldManager.registMessage();
 --    BattleManager.registerMessage();
 	RewardsManager.create();
	UIManager.initUI();
	BroadcastLayer.open();
	-- SelectLevel.create(1);
	if(TestControl.isTest() == true) then
		UIManager.create();
	end
	CCLuaLog("game init end")
	-- BattleManager.setDebugMode(true);
	local m_scheduler = CCDirector:sharedDirector():getScheduler();
	m_scheduler:scheduleScriptFunc(clockOnSecound, 1, false);
end

tempGuiderControl = 1
function getGameScene()
	return gameScene
end

function updateCountDown(GoldCountDown,DiamondCountDown)
	if m_wishGoldCountDown~=0 then 
		m_wishGoldCountDown = GoldCountDown+1
	else
		m_wishGoldCountDown = GoldCountDown
	end
	if m_wishDiamondCountDown~=0 then 
		m_wishDiamondCountDown = DiamondCountDown+1
	else
		m_wishDiamondCountDown = DiamondCountDown
	end
end
function clockOnSecound()
	
	
	if m_wishGoldCountDown~= 0 then
		if m_wishGoldCountDown==1 then
			WishManager.getWishBaseData(nil)
		end
		m_wishGoldCountDown = m_wishGoldCountDown-1
	end
	if m_wishDiamondCountDown~=0 then
		if m_wishDiamondCountDown==1 then
			WishManager.getWishBaseData(nil)
		end		
		m_wishDiamondCountDown = m_wishDiamondCountDown-1
	end

end