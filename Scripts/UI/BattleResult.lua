module("BattleResult", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local ID_MONEY = 1001;
local ID_EXP = 1002;
local m_data = nil;
local m_money = 0;
local m_exp = 0;
local TIME_MONEY = 60;
local m_moneyLabel = nil;
local m_expLabel = nil;
local m_moneyTicker = 0;
local m_expTicker = 0;
local m_moneyIncrease = 0;
local m_expIncrease = 0;
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerMoney = nil;
local m_schedulerExp = nil;
local m_starTable = nil;
local m_victoryPanel = nil;

local function removeSources()
	close();
	BattleScene.releaseBattleLayer();
end

local function repeatBattle()--再战一次
	BattleManager.enterBattleRepeat(removeSources);
end

local function next(sender,eventType)--下一关
	if eventType == TOUCH_EVENT_TYPE_END then 
		if(m_data[2] == BATTLE_SUBTYPE_REWARD)then--如果是赏金
			return;
		end
		local id = DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_data[3], "next");
		if(id == 0)then
			Util.showOperateResultPrompt("返回世界地图");
			return;
		end
		removeSources();
		local function openSelect()
			SelectLevel.openAppointLevel(id,true);
		end
		WorldMap.create(openSelect);
		
		-- BattleManager.enterBattle(1, m_data[2], id,removeSources);
	end
end

local function playVideo()--回放,本地回放
	close();
	BattleScene.releaseBattleLayer();
	BattleManager.enterBattleForRecord(m_data[1], m_data[2], m_data[3]);
end

local function beginReward(text,node)
	node:unregisterAnimEvent(1);
	m_moneyLabel = tolua.cast(m_uiLayer:getWidgetByName("AtlasLabel_40"),"LabelAtlas");
	m_expLabel = tolua.cast(m_uiLayer:getWidgetByName("AtlasLabel_49"),"LabelAtlas");
	-- moneyLabel:setText(tostring(rewardCommon.money));
	local rewardItem = BattleManager.getPrizeItem();
	local rewardCommon = BattleManager.getPrizeCommon();
	m_money = rewardCommon.money;
	m_exp = rewardCommon.exp;
	m_moneyIncrease = math.ceil(rewardCommon.money/TIME_MONEY);
	m_expIncrease = math.ceil(rewardCommon.exp/TIME_MONEY);
	if(m_money < 60)then
		m_moneyIncrease = 1;
	end
	if(m_exp < 60)then
		m_expIncrease = 1;
	end
	m_schedulerMoney = m_scheduler:scheduleScriptFunc(updateMoney, 0, false);
	m_schedulerExp = m_scheduler:scheduleScriptFunc(updateExp, 0, false);
	AudioEngine.playEffect(PATH_RES_AUDIO.."laohuji.mp3");
end

function setAudioEffect()
	AudioEngine.playEffect(PATH_RES_AUDIO .. "xingxing.mp3", false);
end

function setAudioEffect1()
	AudioEngine.playEffect(PATH_RES_AUDIO .. "xingxing1.mp3", false);
end

local function beginStar(text,node)
	node:unregisterAnimEvent(1);
	local pos = tolua.cast(m_uiLayer:getWidgetByName("Panel_47"),"Layout"):getPosition();
	local xingxing = SJArmature:create("xiaoxingxing");
	xingxing:registerFrameEvent("AudioEvent_jiesuanstar",setAudioEffect);
	xingxing:registerFrameEvent("AudioEvent_jiesuanstar1",setAudioEffect1);
	local kk = m_uiLayer:getWidgetByName("Panel_47"):getPositionY();
	xingxing:setPositionX(tolua.cast(m_uiLayer:getWidgetByName("Panel_47"),"Layout"):getPositionX()-200);
	xingxing:setPositionY(tolua.cast(m_uiLayer:getWidgetByName("Panel_47"),"Layout"):getPositionY()-350);
	local rewardCommon = BattleManager.getPrizeCommon();
	local stars = 1;
	if(WorldManager.isNeedStar())then
		if(rewardCommon == nil)then
			stars = 0;
		else
			stars = rewardCommon.star;
		end
	else
		stars = 3;
	end
	local name = "stand" .. stars;
	xingxing:setAnchorPoint(CCPoint(0,0));
	xingxing:getAnimation():play(name, 0, 0, 0, 0);
	m_rootLayer:addChild(xingxing,1);
	xingxing:registerAnimEvent(1, beginReward);
end

local function init(data)
	m_data = data;
	local rewardItem = BattleManager.getPrizeItem();
	local rewardCommon = BattleManager.getPrizeCommon();
	-- local reward  = {{id=1,count=1000},{id=2,count=1000},{id=3,count=1000}};
	local winner = BattleManager.getWinner();
	m_victoryPanel = tolua.cast(m_uiLayer:getWidgetByName("victory_panel"),"Layout");
	local failPanel = tolua.cast(m_uiLayer:getWidgetByName("fail_panel"),"Layout");
	local closeButton = tolua.cast(m_uiLayer:getWidgetByName("Button_close"),"Button");
	closeButton:addTouchEventListener(goToSurface);
	if(winner ==1 )then--victory
		m_victoryPanel:setVisible(true);
		failPanel:setVisible(false);
		AudioEngine.playEffect(PATH_RES_AUDIO .. "shengli.mp3", false);
		local button1 = tolua.cast(m_uiLayer:getWidgetByName("Button_1"),"Button");
		local button2 = tolua.cast(m_uiLayer:getWidgetByName("Button_2"),"Button");
		local button3 = tolua.cast(m_uiLayer:getWidgetByName("Button_3"),"Button");
		button1:addTouchEventListener(repeatBattle);
		button2:addTouchEventListener(playVideo);
		button3:addTouchEventListener(next);
		if(m_data[2] == BATTLE_SUBTYPE_ACTIVITY)then
			button1:setVisible(false);
			button1:setTouchEnabled(false);
			button3:setVisible(false);
			button3:setTouchEnabled(false);
		end
		local pos = tolua.cast(m_uiLayer:getWidgetByName("zhandoushengli_panel"),"Layout"):getPosition();
		local shengli = SJArmature:create("zhandoushengli");
		shengli:setPositionX(tolua.cast(m_uiLayer:getWidgetByName("zhandoushengli_panel"),"Layout"):getPositionX());
		shengli:setPositionY(tolua.cast(m_uiLayer:getWidgetByName("zhandoushengli_panel"),"Layout"):getPositionY());
		shengli:getAnimation():play("stand", 0, 0, 0, 0);
		-- m_victoryPanel:addChild(tolua.cast(shengli,"Widget"));
		shengli:setAnchorPoint(CCPoint(0,0));
		getGameLayer(SCENE_UI_LAYER):addChild(shengli,10);
		--精英模式
		if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_data[3], "mode") == 2)then
			shengli:registerAnimEvent(1, beginReward);
		else
			shengli:registerAnimEvent(1, beginStar);
		end
		
		
		local list = tolua.cast(m_uiLayer:getWidgetByName("good_list"),"ListView");
		if(rewardItem)then
			for i,v in pairs(rewardItem)do
				local res = GoodsManager.getIconPathById(v.itemid);
				if(res ~= "")then
					local image = ImageView:create();
					image:loadTexture(res,0);
					local frame = ImageView:create();
					frame:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(v.itemid)),0);
					image:addChild(frame);
					list:pushBackCustomItem(image);
				end
			end
		end

		if(data[1] == 1)then--pve
			if(data[2] == 1)then--普通关卡,下一关 
				button3:setVisible(true);
				button3:addTouchEventListener(next);
			end
		end

	else--fail
		AudioEngine.playEffect(PATH_RES_AUDIO .. "shibai.mp3", false);
		m_victoryPanel:setVisible(false);
		failPanel:setVisible(true);
		local list = tolua.cast(m_uiLayer:getWidgetByName("ListView_fail"),"ListView");
		-- list:addTouchEventListener(revertEvent);
		local equipButton = tolua.cast(m_uiLayer:getWidgetByName("Button_equip"),"Button");
		local clothButton = tolua.cast(m_uiLayer:getWidgetByName("Button_cloth"),"Button");
		local weaponButton = tolua.cast(m_uiLayer:getWidgetByName("Button_weapon"),"Button");
		local skillButton = tolua.cast(m_uiLayer:getWidgetByName("Button_skill"),"Button");
		equipButton:addTouchEventListener(revertEvent);
		clothButton:addTouchEventListener(revertEvent);
		weaponButton:addTouchEventListener(revertEvent);
		skillButton:addTouchEventListener(revertEvent);
		local button4 = tolua.cast(m_uiLayer:getWidgetByName("Button_15"),"Button");
		local button5 = tolua.cast(m_uiLayer:getWidgetByName("Button_16"),"Button");
		button4:addTouchEventListener(repeatBattle);
		button5:addTouchEventListener(playVideo);
	end
end

function updateExp(dt)
	if(m_expTicker == TIME_MONEY)then
		--升级了 
		if(UserInfoManager.getRoleInfo("preLevel") < UserInfoManager.getRoleInfo("level"))then
			UIManager.open("Upgrade");
			UserInfoManager.setRoleInfo("preLevel",UserInfoManager.getRoleInfo("level"));
		end
		m_scheduler:unscheduleScriptEntry(m_schedulerExp);
		m_expLabel:setStringValue(tostring(m_exp));
		return;
	end
	m_expLabel:setStringValue(tostring(m_expIncrease*m_expTicker));
	m_expTicker = m_expTicker + 1;
end
function updateMoney(dt)
	if(m_moneyTicker == TIME_MONEY)then
		m_scheduler:unscheduleScriptEntry(m_schedulerMoney);
		m_moneyLabel:setStringValue(tostring(m_money));
		return;
	end
	m_moneyLabel:setStringValue(tostring(m_moneyIncrease*m_moneyTicker));
	m_moneyTicker = m_moneyTicker + 1;
end

function create()
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "battleResult_1.json");
    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_uiLayer = uiLayer;
    -- m_rootLayer:addChild(uiLayer);
    m_rootLayer:addChild(UIManager.bounceOut(uiLayer));
    -- m_rootLayer:retain();
end

function open(data)
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	init(data);
			--新手引导
    if TaskManager.getNewState() then
         UIManager.open("GuiderLayer")
    end

end

function close()
	if(m_schedulerMoney ~= nil)then
		m_scheduler:unscheduleScriptEntry(m_schedulerMoney);
	end
	if(m_schedulerMoney ~= nil)then
		m_scheduler:unscheduleScriptEntry(m_schedulerExp);
	end
	m_money = 0;
	m_moneyIncrease = 0;
	m_moneyLabel = nil;
	m_moneyTicker = 0;
	m_expLabel = nil;
	m_expTicker = 0;
	m_expIncrease = 0;
	m_schedulerMoney = nil;
	m_schedulerExp = nil;
	getGameLayer(SCENE_UI_LAYER):removeChild(m_rootLayer, true);
	m_rootLayer = nil;
end

function revertEvent(object,event)
	-- if eventType == TOUCH_EVENT_TYPE_END then 
		close();
		BattleScene.releaseBattleLayer();
		GameManager.enterMainCityOther(3);
		if(object:getTag() == 1001)then--强化装备
			UIManager.open("Transform");
		elseif(object:getTag() == 1002)then--强化外套
			UIManager.open("Wardrobe");
		elseif(object:getTag() == 1003)then--强化武器
			UIManager.open("WeaponUI");
		elseif(object:getTag() == 1004)then--调整技能
			UIManager.open("SkillsUINew");
		end
	-- end
end



function goToSurface()--根据类型转到相应界面 
	close();
	BattleScene.releaseBattleLayer();
	if(m_data[1] == BATTLE_MAIN_TYPE_PVE)then--pve
		if(m_data[2] == BATTLE_SUBTYPE_LEVEL)then--选关进战斗 
			WorldManager.setCurBattleMap(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_data[3], "belong"));
			WorldManager.setNeedOpenSelectLevel(true);
			WorldMap.create();
		elseif(m_data[2] == BATTLE_SUBTYPE_ACTIVITY)then--活动副本进战斗
			GameManager.enterMainCityOther(2);
			-- UIManager.open("MainCityUI");
			UIManager.open("ActivityType");
		else
			GameManager.enterMainCityOther(3);
		end
	else--pvp BATTLE_MAIN_TYPE_PVP
		GameManager.enterMainCityOther(3);
		-- UIManager.open("MainCityUI");
		if(m_data[2] == BATTLE_SUBTYPE_JJC)then

		end
	end

			--新手引导
    if TaskManager.getNewState() then
    	UIManager.close("GuiderLayer")
    	TaskManager.setLocalStepRecord(2)
        UIManager.open("GuiderLayer")
    end
end
