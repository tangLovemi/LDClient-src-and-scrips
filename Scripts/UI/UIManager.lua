module("UIManager", package.seeall)

require "UI/MainMenu"
require "UI/Login"
require "UI/Register"
require "UI/Hotel"
require "UI/Notice"
require "UI/Chat"
require "UI/FaceMakerNew"
require "UI/Escort"
require "UI/Treasure"
require "UI/Hire"
require "UI/RobMan"
require "UI/Rob"
require "UI/Arena/JJCUI"
require "UI/Mail"
require "UI/Shop/Shop"
require "UI/PointStar"
require "UI/Transform"
require "UI/Smelter"
require "UI/Bank"
require "UI/SoulChemical"
require "UI/BeatDownUI"
require "UI/LastLiveUI"
require "UI/BD_MyGameUI"
require "UI/MyBetUI"
require "UI/ExploreUI"
require "UI/AnimalHorde"
require "UI/SG_LottoUI"
require "UI/FingerGuessGame"
require "UI/MainCityUI"
require "UI/StartGameUI"
require "UI/newLoginUI"
require "UI/newRegisterUI"
require "UI/Wardrobe"
require "UI/BackpackNew"
require "UI/GoodsList"
require "UI/Figure"
-- require "UI/FigureProperty"
require "UI/FigureWeapon"
require "UI/BackpackFigurePage"
require "UI/HorTabFive"
require "UI/RadioTabFour"
require "UI/SettingUI"
require "UI/SignUI"
require "UI/PackageItemUI"
--好友系统
require "UI/Friends/FriendsMain"
require "UI/Friends/FriendRecommandUI"

require "UI/SpriteNurture"
require "UI/BetUI"
require "UI/Train/TrainUI"
require "UI/Bless"
require "UI/ZhanBao"
require "UI/Battle_simulator"
require "UI/GoodsDetailsPanel"
require "UI/ActivityLevel"
require "UI/ActivityType"
require "UI/FunBtnCount3"
require "UI/CommonUI"
require "UI/SkillsUINew"

--任务系统UI
require "UI/Hunt/HuntUI"
require "UI/Hunt/HuntDetailUI"
-- require "UI/Hunt/HuntInfoUI"
require "UI/DialogView"
require "UI/MajorTaskReward"
require "UI/TaskInfoUI"
require "UI/DailyTaskUI"

require "UI/DyLoadingBar"

--第一次外套
require "UI/FirstCoatUI"

--新手引导
require "UI/Guide/GuiderLayer"
--点金
require "UI/PurchaseGold"


require "UI/Weapon/WeaponDevour"
require "UI/Weapon/WeaponUI"
require "UI/Weapon/WeaponUpstep"

--远古材料
require "UI/AncientMaterialUI/AncientMain"
require "UI/AncientMaterialUI/AncientMaterialItem"
-- 许愿系统

require "UI/WishUI/WishMain"
require "UI/WishUI/WishItemEffect"
require "UI/Guide/NpcWordsUI"

require "UI/GoodsDetails"
require "UI/WorldMapUI"
require "UI/RewardDisplay/RewardDisplay"
require "UI/BackpackFullTishi"

local m_layerNames = {
-- "Hotel",
-- "Notice",
-- "Chat",
-- "FaceMakerNew",

-- "Escort",
-- "Treasure",
-- "Hire",
-- "RobMan",
-- "Rob",
"JJCUI",
"Battle_simulator",
"Mail",

"Shop",
"PointStar",
-- "Smelter",
"BeatDownUI",
"LastLiveUI",

"BD_MyGameUI",
"MyBetUI",

-- "ExploreUI",
-- "AnimalHorde",
-- "SG_LottoUI",
-- "FingerGuessGame",
"MainCityUI",
"StartGameUI",
"newLoginUI",
"newRegisterUI",

"Wardrobe",
"GoodsDetailsPanel",
"GoodsList", 
"BackpackNew",  --此创建要放在吞噬界面所在的界面创建完成之后
"Figure", 
-- "FigureProperty",
"FigureWeapon",
 "BackpackFigurePage", 
 "HorTabFive",
--  "RadioTabFour",
--  "MainMenu",
 "Bank",
 "FunBtnCount3",
-- "SpriteNurture",
"Transform",
"SoulChemical",

 -- "WorldMap",
-- "SettingUI",
-- "SignUI",
-- "PackageItemUI",
"FriendsMain",
-- "BetUI",
"TrainUI",
-- "Bless",
-- "ZhanBao",
-- "ActivityLevel",
-- "ActivityType",
"CommonUI",
"HuntUI",
"HuntDetailUI",
"HuntInfoUI",
"DialogView",
"MajorTaskReward",
-- "AlertView",
"TaskInfoUI",
"DailyTaskUI",
"FirstCoatUI",
"GuiderLayer",
"PurchaseGold",
"AncientMain",
"AncientMaterialItem",
"NpcWordsUI",
"RewardDisplay",
};

local m_openedLayerNames = {};
local m_callFuc = nil;

local m_currentIndex = 0;
local m_count = 0;

local m_loadindEndCB = nil;

local m_isOpen = false;

function isOpen()
	return m_isOpen;
end

function setOpen( isOpen )
	m_isOpen = isOpen;
end


local function closeCurLayer()
	-- body
	local curLayerName = m_openedLayerNames[m_currentIndex];
	_G[curLayerName].close();
end 

local function openCurLayer()
	-- body
	local curLayerName = m_openedLayerNames[m_currentIndex];
	_G[curLayerName].open();

	for i=1,#m_openedLayerNames do
		local name = m_openedLayerNames[i];
		CCLuaLog(i .. ":    " .. name);
	end
end 

local function recordTheLayer(layerName)
	-- body
	table.insert(m_openedLayerNames,layerName);
	m_currentIndex = #m_openedLayerNames;
end

local function judageTheLayer(curLayerName)
	-- body

	local max = #m_openedLayerNames;
	local lastLayerName = m_openedLayerNames[max];
	
	if lastLayerName ~= curLayerName  then
		recordTheLayer(curLayerName);
	else 
		m_currentIndex = m_currentIndex + 1;
	end
	
end 

local function createFuc(i)
	-- body
	-- 加载一个UI回调一次函数！
end

function initUI()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);

	--测试用
	if(TestControl.isTest() == true) then
		MainMenu.create();
		MainMenu.open();
		-- ActivityLevel.create();
		-- ActivityLevel.open(1);
		-- SelectLevel.create(1);
	-- 	WorldMap.create();
	else
		--真正流程
		-- MainCityUI.create();
		-- FaceMakerNew.create();
		-- newLoginUI.create();
		-- newRegisterUI.create();
		-- local login = StartGameUI.create();
		-- StartGameUI.open();
		ClientConnect:shareInstance():RequestServerList();
	end
end

function create(endCB)
	-- body
	local layerNames = m_layerNames;
	m_loadindEndCB = endCB;

	-- for i=1,#layerNames do
	-- 	local name = layerNames[i];
	-- 	_G[name].create();
	-- 	createFuc(i);
	-- end

	if(m_loadindEndCB) then
		m_loadindEndCB();
	end
end

function remove(layName)
	-- body
	-- 清空layer中加载的数据
	_G[layName].remove();
end

function open(layerName, params)
	-- body

	if m_currentIndex ~= 0 then
		judageTheLayer(layerName);
	else
		recordTheLayer(layerName);
	end
	m_count = m_count + 1;

	--需在MainCityLogic加判断，是否进入场景， 否则登录时会出问题
	if(MainCityLogic.getRootLayer() ~= nil and layerName ~= "MainCityUI") then
		MainCityLogic.unregisterTouchFunction();
	end
	
	_G[layerName].create();
	if(params ~= nil) then
		_G[layerName].open(params);
	else

		_G[layerName].open();
	end
	m_isOpen = true;
end

function close(layerName)
	-- body
	_G[layerName].close();
	_G[layerName].remove();
	m_count = m_count - 1;

	if m_count == 0 then
		if m_callFuc ~= nil then
			m_callFuc();
		end
	end

	if(MainCityLogic.getRootLayer() ~= nil) then
		MainCityLogic.registerTouchFunction();
	end
	m_isOpen = false;

	-- MainCityUI.refreshDisplay();
end

function backLastLayer()
	-- body
	closeCurLayer();
	m_currentIndex = m_currentIndex - 1;

	if m_currentIndex > 0 then
		openCurLayer();
	end
end

function advanceNextLayer()
	-- body
	closeCurLayer();
	m_currentIndex = m_currentIndex + 1;

	local max = #m_openedLayerNames;

	if m_currentIndex <= max then
		openCurLayer();
	end
end

function setCloseCBFuc(callbackFunc)
	m_callFuc = callbackFunc;
end

function bounceOut(uilayer)
	local layer = CCLayer:create();
	layer:addChild(uilayer);
	layer:setScale(0.01);
    local actList = CCArray:create();
    local scale1 = CCScaleTo:create(0.2,1.05);
    local scale2 = CCScaleTo:create(0.1,1.0);
    actList:addObject(scale1);
    actList:addObject(scale2);
    layer:runAction(CCSequence:create(actList));
    return layer;
end

function bounceIn()

end
