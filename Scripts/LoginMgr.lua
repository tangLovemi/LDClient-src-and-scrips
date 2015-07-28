module("LoginMgr", package.seeall)


local m_isFirst = false;
local m_isLoginEnd = false;

function setIsFirst( isFirst )
	m_isFirst = isFirst;
end

function isFirst()
	return m_isFirst;
end

local m_beforeEndCB = nil;


-------角色动画
local isloadPlayerActorEndFlag = false;
function isLoadPlayerActorEnd()
	return isloadPlayerActorEndFlag;
end
local function loadPlayerActorEnd()
	isloadPlayerActorEndFlag = true;
	print("********** 加载角色动画完成");
end
local function loadPlayerActor()
	isloadPlayerActorEndFlag = false;
	PlayerActor.initPlayerActor(loadPlayerActorEnd);
end

-------捏脸资源
local isLoadFaceEndFlag = false;
function isLoadFaceEnd()
	return isLoadFaceEndFlag;
end
local function loadFaceEnd()
	isLoadFaceEndFlag = true;
	print("********** 加载脸部信息完成");
end
local function loadFace()
	isLoadFaceEndFlag = false;
	PlayerActor.initFace(loadFaceEnd);
end

-------服务器加载数据
local isLoadDataFromServerEndFlag = false;
function isLoadDataFromServerEnd()
	return isLoadDataFromServerEndFlag;
end
local function loadDataFromServerEnd()
	isLoadDataFromServerEndFlag = true;
	print("********** 服务器加载数据完成");
end
local function loadDataFromServer()
	if(TestControl.isTest() == true) then

	else
		isLoadDataFromServerEndFlag = false;
		UserInfoManager.create(loadDataFromServerEnd);
		--发送请求
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_REQUESTALLDATA, {});
	end
end

-------加载UI资源
local isLoadUIEndFlag = false;
function isLoadUIEnd()
	return isLoadUIEndFlag;
end
local function loadUIEnd()
	isLoadUIEndFlag = true;
	print("********** 加载UI完成");
end
local function loadUI()
	isLoadUIEndFlag = false;
	UIManager.create(loadUIEnd);
end


-------进入主城
local isLoadSceneEndFlag = false;
local function isLoadSceneEnd()
	return isLoadSceneEndFlag;
end
local function loadSceneEnd()
	isLoadSceneEndFlag = true;
	MainCityUI.create();
	MainCityUI.open();

	print("********** 主城加载完成");
	--角色登录完成，主城加载完毕

	

	local newGuideinfo =TaskManager.getNewGuideInfo()
	if  newGuideinfo["step"] == 0 then
		if newGuideinfo["bSuccess"]==0 then--第一次登录
		    UIManager.open("FirstCoatUI")
		end	
	end
	GuideDatas.continueNewGUide(newGuideinfo)--新手引导未全部完成


	NotificationManager.onLoginCheckAll();

	--检查是否签到，没签到自动弹出签到界面
	if(TaskManager.getNewState() == false) then
		if(SignUI.canSignToday()) then
			UIManager.open("SignUI");
		end
	end
end
local function enterMainCity()
	isLoadSceneEndFlag = false;
	MainCityLogic.create();
	MainCityLogic.EnterCity(1, loadSceneEnd, 0);
    if(PlayerActor.isChange()) then
    	MainCityLogic.reloadPlayer();
    end
end


-------------------------------------------------------------

local m_funcList = nil;
local m_status = nil;
local m_curStep = 0;
local m_stepMax = 0;
local m_callbackFun = nil;
local m_endFuc = nil;
local LOADING_STATE_STOP 	= 0;
local LOADING_STATE_UPDATE 	= 1;
local LOADING_STATE_WAIT 	= 2;

local i = 0;
local j = 0;
local function loadFunc( resData )
	-- i = i + 1;
	-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   i = " .. i);


    local func = resData.func;
    func();
    m_conditionFun = resData.isEnd;
    m_status = LOADING_STATE_WAIT;
end

local function update()
	if (m_status == LOADING_STATE_UPDATE) then
        if (m_curStep > m_stepMax) then
            LoginMgr.stop();
            m_callbackFun();
            return;
        end
        local resData = m_resList[m_curStep].resData;
        loadFunc(resData);
        m_curStep = m_curStep + 1;
    else
        if (m_conditionFun() == true) then
			-- j = j + 1;
			-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   j = " .. j);
            m_conditionFun = nil;
            m_status = LOADING_STATE_UPDATE;
        end
    end
end

function start()
    m_status = LOADING_STATE_UPDATE;
    local layer = getGameLayer(SCENE_LOGIN_LAYER);
    layer:scheduleUpdateWithPriorityLua(update, 1);
end

function stop()
    m_status = LOADING_STATE_STOP;
    local layer = getGameLayer(SCENE_LOGIN_LAYER);
    layer:unscheduleUpdate();
    m_resList = nil;
end

local function free()
    local layer = getGameLayer(SCENE_LOGIN_LAYER);
    layer:removeAllChildrenWithCleanup(true);
end

function create(resList, cbFun)
	m_stepMax = #resList;
    m_resList = resList;
    m_curStep = 1;
    m_callbackFun = cbFun;
    start();
end

function remove()
	m_curStep = 1;
    m_stepMax = 1;
    m_resList = nil;
    m_callbackFun = nil;
    -- free();
end

-------------------------------------------------------------


local function loadBeforeCreateDataEnd()
	LoginMgr.remove();
	if(m_beforeEndCB) then
		m_beforeEndCB();
	end
end

--注册角色时，捏脸之前要加载的数据
function loadBeforeCreateData(endCB)
	if(endCB) then
		m_beforeEndCB = endCB;
	end

	local loadFaceF = {resData = {func = loadFace, isEnd = isLoadFaceEnd}};
	local loadPlayerActorF = {resData = {func = loadPlayerActor, isEnd = isLoadPlayerActorEnd}};

	local resList = {loadFaceF, loadPlayerActorF};
    LoginMgr.create(resList, loadBeforeCreateDataEnd);
end



local function loadLoginDataEnd()
	LoginMgr.remove();
	if(BattleManager.isDebugMode())then
		BattleManager.enterDebugBattle(enterMainCity);
	else
		enterMainCity();
	end
	
	m_isLoginEnd = true;
end

--如果是注册则加载捏脸之后的数据
--如果是登陆则加载全部数据
function loadLoginData()
	if(m_isFirst) then
		--注册后加载
		local loadServerDataF = {resData = {func = loadDataFromServer, isEnd = isLoadDataFromServerEnd}};
		local loadUIF = {resData = {func = loadUI, isEnd = isLoadUIEnd}};

		local resList = {loadServerDataF, loadUIF};
	    LoginMgr.create(resList, loadLoginDataEnd);
	else
		--正式登陆加载
		local loadServerDataF = {resData = {func = loadDataFromServer, isEnd = isLoadDataFromServerEnd}};
		local loadFaceF = {resData = {func = loadFace, isEnd = isLoadFaceEnd}};
		local loadUIF = {resData = {func = loadUI, isEnd = isLoadUIEnd}};
		local loadPlayerActorF = {resData = {func = loadPlayerActor, isEnd = isLoadPlayerActorEnd}};
		local resList = {loadServerDataF, loadFaceF, loadUIF, loadPlayerActorF};
	    LoginMgr.create(resList, loadLoginDataEnd);
	end
end



function isloginEnd()
	return m_isLoginEnd;
end



function battleEndReturn( id )
	enterMainCity();
	if(id) then
		if(id == 4) then
			UIManager.open("JJCUI");
		elseif(id == 5) then
			UIManager.open("TrainUI");
		end
	end
end
--------------------------新登录


