module("JJCUI", package.seeall)

require "UI/CoolingTime"
require "UI/Arena/JJCReport"
require "UI/Arena/JJCPersonal"
require "UI/Arena/JJCGroup"

local m_rootLayer = nil;
local m_uiLayer   = nil;
local m_timeLabel = nil; --刷新时间
local m_isCreate = false;
local m_isOpen = false;

local OPP_COUNT = 3;
local m_oppPanel = {};
local m_oppDatas = nil;

local m_groupName = {
	"巅峰组",	--0 
	"钻石组",	--1 
	"黄金组",	--2 
	"白银组",	--3 
	"青铜组",	--4 
	"黑铁组",	--5 
	"大地组"	--6 
};

local GROUP_COUNT = 7;


local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_countDown_schedule = nil; -- 倒计时定时器
local m_hour = 0;
local m_min = 0;
local m_sec = 0;

local m_fightIndex = 0;
local REQUEST_TYPE_OPEN      = 1; --打开
local REQUEST_TYPE_FIGHT     = 2; --挑战
local REQUEST_TYPE_REFRESH   = 3; --刷新对手
local REQUEST_TYPE_HEAD      = 4; --头三名

function getGroupCount()
    return GROUP_COUNT;
end

function getGroupName( groupId )
    return m_groupName[groupId + 1];
end

function setTimePanelVisiable( visiable )
    tolua.cast(m_uiLayer:getWidgetByName("time_panel"), "Layout"):setEnabled(visiable);
end

--退出
local function exitTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("JJCUI");
	end
end
--刷新
local function flushTouchEvent(sender,eventType) 
	if eventType == TOUCH_EVENT_TYPE_END then
        local function sureFlush()
            UIManager.close("ErrorDialog");
            ProgressRadial.open();--打开进度条等待
            sendRefreshOppRequest(1);
        end
        local price = DataTableManager.getValue("arenaConstant", "id_" .. 1, "refreshPrice");
        UIManager.open("ErrorDialog");
        local str = "是否使用" .. price .. "钻石刷新一次对手";
        local funs = {};
        table.insert(funs,function () UIManager.close("ErrorDialog"); end);
        table.insert(funs,sureFlush);
        ErrorDialog.setPanelStyle(str,funs);
	end
end 
--描述
local function descTouchEvent(sender,eventType) 
	if eventType == TOUCH_EVENT_TYPE_END then
		
	end
end

local function fight()
    if(m_fightIndex ~= 0) then
        local index = m_fightIndex;
        m_fightIndex = 0;
        local jjcData = UserInfoManager.getRoleInfo("jjcData");
        if(jjcData.lastCount > 0) then
            -- 1100消息type= 2   subType=4
            -- enemyID=玩家id
            UIManager.close("JJCUI");
            local accountid = m_oppDatas[index].accountId;
            print("****竞技场挑战对手 accountId = " .. accountid);
            MainCityLogic.enterBattle(2, 4, accountid);
        else
            Util.showOperateResultPrompt("挑战次数不足");
        end
    end
end

--挑战
local function chanllengeTouchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local tag = sender:getTag();
		print("挑战 tag = " .. tag);
        if(tag <= #m_oppDatas) then
            m_fightIndex = tag;
            sendOpenRequest(REQUEST_TYPE_FIGHT);
        end
	end
end

local function refreshTimeLabel()
	m_timeLabel:setText(TimeRefresh.timeFormat(m_hour, m_minute, m_second));
end

local function stopUpdate()
	if (m_countDown_schedule ~= nil) then  
        m_scheduler:unscheduleScriptEntry(m_countDown_schedule)  
        m_countDown_schedule = nil;
        m_hour = 0;
        m_minute = 0;
        m_second = 0;
    end 
end

local function updateTime(dt)
    m_second = m_second - 1;
    if (m_second == -1) then
         if (m_minute ~= -1 or m_hour ~= -1) then  
            m_minute = m_minute-1  
            m_second = 59  
            if (m_minute == -1) then  
                if (m_hour ~= -1) then  
                    m_hour = m_hour-1  
                    m_minute = 59  
                    if (m_hour == -1) then
                    	--时间到，请求刷新
                        sendRefreshOppRequest(0);
                        stopUpdate();
                    end  
                end  
            end  
        end 
    end
    refreshTimeLabel();
end

--开启计时器
local function startUpdate()
    if(not m_countDown_schedule) then
        m_countDown_schedule = m_scheduler:scheduleScriptFunc(updateTime, 1, false);
    end
end

local function initButton(uiLayer)
	--退出
    local exitBtn = uiLayer:getWidgetByName("exit_btn");
    exitBtn:addTouchEventListener(exitTouchEvent);
    --刷新对手
    local flushBtn = uiLayer:getWidgetByName("flush_btn");
    flushBtn:addTouchEventListener(flushTouchEvent);
    --说明
    -- local descBtn = uiLayer:getWidgetByName("desc_btn");
    -- descBtn:addTouchEventListener(descTouchEvent);
end 

local function initOppPanel(uiLayer)
    m_oppPanel = {};
    for i=1,OPP_COUNT do
    	local oppPanel = tolua.cast(uiLayer:getWidgetByName("role_" .. i),"Layout");
    	local oppInfoPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "JJC_RoleItemUI.json");
        oppInfoPanel:setName("oppPanel-" .. i);
    	local chanllengeBtn = tolua.cast(oppInfoPanel:getChildByName("ch_btn"), "Button");
    	chanllengeBtn:setTag(i);
    	chanllengeBtn:addTouchEventListener(chanllengeTouchEvent);
    	oppPanel:addChild(oppInfoPanel);
    	m_oppPanel[i] = oppPanel;
    end
end 

local function initLabel(uiLayer)
    local timeLabel = tolua.cast(uiLayer:getWidgetByName("time_label"),"Label");
    m_timeLabel = timeLabel;
end

--玩家竞技场基本信息接收完毕
function baseDataReceiveEnd()
    local jjcData = UserInfoManager.getRoleInfo("jjcData");
    JJCPersonal.refreshInfo(jjcData);
end

--从面板中移除所有动画
local function removeAllAnimation()
    for i=1,3 do
       local oppP = m_oppPanel[i]:getChildByName("oppPanel-" .. i);
        local animPanel = tolua.cast(oppP:getChildByName("anim_panel"), "Layout");
        animPanel:removeAllNodes();
    end
end

--竞技场七个组的标志图
local m_jjcFlagImg = {
    PATH_CCS_RES .. "jjc_zubie_7.png",
    PATH_CCS_RES .. "jjc_zubie_6.png",
    PATH_CCS_RES .. "jjc_zubie_5.png",
    PATH_CCS_RES .. "jjc_zubie_4.png",
    PATH_CCS_RES .. "jjc_zubie_3.png",
    PATH_CCS_RES .. "jjc_zubie_2.png",
    PATH_CCS_RES .. "jjc_zubie_1.png", 
};

local m_jjcGroupNameImg = {
    PATH_CCS_RES .. "jjc_wz_dianfengzu.png",
    PATH_CCS_RES .. "jjc_wz_zuanshizu.png",
    PATH_CCS_RES .. "jjc_wz_huangjinzu.png",
    PATH_CCS_RES .. "jjc_wz_baiyinzu.png",
    PATH_CCS_RES ..  "jjc_wz_tingtongzu.png",
    PATH_CCS_RES ..  "jjc_wz_heitiezu.png",
    PATH_CCS_RES ..  "jjc_wz_dadizu.png",
};


function getJJCGroupFlagImg( group )
    return m_jjcFlagImg[group];
end

function getJJCGroupNameImg( group )
    return m_jjcGroupNameImg[group];
end

--刷新对手信息
local function receiveOppEnd()
    ProgressRadial.close(); --关闭进度条
    local flushBtn = tolua.cast(m_uiLayer:getWidgetByName("flush_btn"), "Button");
    flushBtn:setTouchEnabled(true);

    print("***********  对手   size = " .. #m_oppDatas);
	for i=1,#m_oppDatas do
        print("accountId = " .. m_oppDatas[i].accountId);
        print("groupId   = " .. m_oppDatas[i].groupId);
        print("ranking   = " .. m_oppDatas[i].ranking);
        print("score     = " .. m_oppDatas[i].score);
        print("name      = " .. m_oppDatas[i].name);
        print("skills    = " .. m_oppDatas[i].skillsStr);
        print("coat      = " .. m_oppDatas[i].coat);
        print("face      = " .. m_oppDatas[i].face);
        print("hair      = " .. m_oppDatas[i].hair);
        print("hairColor = " .. m_oppDatas[i].hairColor);
        print("  ");
        --accountId,
        --groupId,
        --ranking,
        --score
        --isAttack
        --result 战斗结果(2未攻打  0失败  1成功)
        --name
        --skillsStr
        --coat
        --face
        --hair
        --hairColor
        m_oppPanel[i]:setEnabled(true);
        local oppP = m_oppPanel[i]:getChildByName("oppPanel-" .. i);
		local group_img = tolua.cast(oppP:getChildByName("group_image"), "ImageView");
		local score_label = tolua.cast(oppP:getChildByName("score_label"), "Label");
        local attackBtn = tolua.cast(oppP:getChildByName("ch_btn"), "Button");
        local nameLabel = tolua.cast(oppP:getChildByName("name_label"), "Label");
        group_img:loadTexture(m_jjcFlagImg[m_oppDatas[i].groupId + 1]);

        score_label:setText(m_oppDatas[i].ranking);
        local rankingImg = tolua.cast(oppP:getChildByName("ranking_img"), "ImageView"); --第几名
        rankingImg:setEnabled(false);

        local haveDefence = false;
        if(m_oppDatas[i].isAttack == 1) then
            haveDefence = true;
        end
        attackBtn:setTouchEnabled(not haveDefence);
        if(not haveDefence) then
            attackBtn:loadTextureNormal(PATH_CCS_RES .. "gybtn_tiaozhan_1.png");
            attackBtn:loadTexturePressed(PATH_CCS_RES .. "gybtn_tiaozhan_2.png");
        else
            attackBtn:loadTextureNormal(PATH_CCS_RES .. "gybtn_tiaozhan_3.png");
            attackBtn:loadTexturePressed(PATH_CCS_RES .. "gybtn_tiaozhan_3.png");
        end
        nameLabel:setText(m_oppDatas[i].name);

        --技能
        if(m_oppDatas[i].skillsStr) then
            local skills = Util.strToNumber(Util.Split(m_oppDatas[i].skillsStr, ";"));
            for i=1,5 do
                tolua.cast(oppP:getChildByName("jn" .. i .. "_imageView_0"), "ImageView"):setEnabled(false);
            end
            for i=1,#skills do
                if(skills[i] > 0) then
                    local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. skills[i] .. ".png";
                    local icon = tolua.cast(oppP:getChildByName("jn" .. i .. "_imageView_0"), "ImageView");
                    icon:setEnabled(true);
                    icon:loadTexture(iconPath);
                end
            end
        end
        --动画
        local animPanel = tolua.cast(oppP:getChildByName("anim_panel"), "Layout");
        animPanel:removeAllNodes();
        local animActor = OtherPlayer.createAnimation(m_oppDatas[i].coat, m_oppDatas[i].face, m_oppDatas[i].hair, m_oppDatas[i].hairColor);
        animPanel:addNode(animActor);
        animActor:setPosition(ccp(18, -2632 + 10));
    end
end

local m_ranking1_3FlagImg = {
    PATH_CCS_RES .. "jjc_paiming_1.png",
    PATH_CCS_RES .. "jjc_paiming_2.png",
    PATH_CCS_RES .. "jjc_paiming_3.png",
};

--刷新显示前三名
local function refreshHeadPlayers( messageType, messageData )
    ProgressRadial.close();
    local headDatas = messageData;
    -- if(#headDatas > 0) then
    --     setNoPeopleIN(false);
    -- else 
    --     setNoPeopleIN(true);
    -- end
    setNoPeopleIN(#headDatas == 0);

    OtherPlayer.removeAnimation();
    for i=1,#headDatas do
        print("accountId = " .. headDatas[i].accountId);
        print("groupId   = " .. headDatas[i].groupId);
        print("ranking   = " .. headDatas[i].ranking);
        print("score     = " .. headDatas[i].score);
        print("name      = " .. headDatas[i].name);
        print("skills    = " .. headDatas[i].skillsStr);
        print("  ");
        --accountId,
        --groupId,
        --ranking,
        --score
        --name
        --skillsStr
        tolua.cast(m_oppPanel[i], "Layout"):setEnabled(true);
        local oppP = tolua.cast(m_oppPanel[i], "Layout"):getChildByName("oppPanel-" .. i);
        local group_img = tolua.cast(oppP:getChildByName("group_image"), "ImageView");
        local score_label = tolua.cast(oppP:getChildByName("score_label"), "Label");
        local attackBtn = tolua.cast(oppP:getChildByName("ch_btn"), "Button");
        local nameLabel = tolua.cast(oppP:getChildByName("name_label"), "Label");
        local rankingImg = tolua.cast(oppP:getChildByName("ranking_img"), "ImageView"); --第几名
        group_img:loadTexture(m_jjcFlagImg[headDatas[i].groupId + 1]);
        score_label:setText(headDatas[i].ranking);
        attackBtn:setEnabled(false);
        nameLabel:setText(headDatas[i].name);
        rankingImg:setEnabled(true);
        rankingImg:loadTexture(m_ranking1_3FlagImg[i]);

        --技能
        if(headDatas[i].skillsStr) then
            local skills = Util.strToNumber(Util.Split(headDatas[i].skillsStr, ";"));
            for i=1,5 do
                tolua.cast(oppP:getChildByName("jn" .. i .. "_imageView_0"), "ImageView"):setEnabled(false);
            end
            for i=1,#skills do
                if(skills[i] > 0) then
                    local iconPath = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. skills[i] .. ".png";
                    local icon = tolua.cast(oppP:getChildByName("jn" .. i .. "_imageView_0"), "ImageView");
                    icon:setEnabled(true);
                    icon:loadTexture(iconPath);
                end
            end
        end
        --动画
        local animPanel = tolua.cast(oppP:getChildByName("anim_panel"), "Layout");
        animPanel:removeAllNodes();
        local animActor = OtherPlayer.createAnimation(headDatas[i].coat, headDatas[i].face, headDatas[i].hair, headDatas[i].hairColor);
        animPanel:addNode(animActor);
        animActor:setPosition(ccp(18, -2632 + 10));
    end
end

function requestHeadPlayers( groupid )
    for i=1,3 do
        tolua.cast(m_oppPanel[i], "Layout"):setEnabled(false);
    end
    ProgressRadial.open();--打开进度条等待
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_JJCHEADPLAYER, {groupid});
end

local function onReceiveOppDataFromServer(messageType, messageData)
	m_oppDatas = nil;
	m_oppDatas = messageData;
	receiveOppEnd();
end

function refreshOpps()
    for i=1,3 do
        tolua.cast(m_oppPanel[i], "Layout"):setEnabled(false);
    end
    receiveOppEnd();
end

function setNoPeopleIN( isHave )
    m_uiLayer:getWidgetByName("isHave_img"):setEnabled(isHave);
end


--注册接收
local function registerMessageCB()
	--对手信息
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_JJC_OOP, onReceiveOppDataFromServer);
	--战报
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_JJC_REPORT, JJCReport.onReceiveReportDataFromServer);
    --各组最低积分
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_JJC_GROUP_SCORE, JJCGroup.onReceiveGroupScores);
    --某组前三名
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_JJC_HEAD_PLAYERS, refreshHeadPlayers);
end

local function unregisterMessageCB()
    --对手信息
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_JJC_OOP, onReceiveOppDataFromServer);
    --战报
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_JJC_REPORT, JJCReport.onReceiveReportDataFromServer);
    --各组最低积分
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_JJC_GROUP_SCORE, JJCGroup.onReceiveGroupScores);
    --某组前三名
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_JJC_HEAD_PLAYERS, refreshHeadPlayers);
end

function sendOpenRequest(type)
    -- ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_JJCREQUEST, {type});
end

function sendRefreshOppRequest(type)
	ProgressRadial.open();--打开进度条等待
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_JJCREFRESH, {type});
end

function receiveTimeFromServer(messageData)
    -- print("****************  receive time end");
    -- print("hor = " .. messageData.hor);
    -- print("min = " .. messageData.min);
    -- print("sec = " .. messageData.sec);
    m_hour = messageData.hor;
    m_minute = messageData.min;
    m_second = messageData.sec;
    refreshTimeLabel();

	startUpdate();
end

local function openInit()
    for i = 1,#m_oppPanel do
        tolua.cast(m_oppPanel[i], "Layout"):setEnabled(false);
    end
    local flushBtn = tolua.cast(m_uiLayer:getWidgetByName("flush_btn"), "Button");
    flushBtn:setTouchEnabled(false);

    m_hour = 0;
    m_minute = 0;
    m_second = 0;
    refreshTimeLabel();

    m_fightIndex = 0;
end

local m_upPanel = nil;
local m_upAnim  = nil;

local function onReceiveOpenResponse( messageType, messageData )
    ProgressRadial.close(); --关闭进度条
    local type = messageData.type;
    local result = messageData.result;
    if(result == 0) then
        Util.showOperateResultPrompt("23:00-24:00为竞技场结算冷却时间");
        if(type == REQUEST_TYPE_OPEN)then
            UIManager.close("JJCUI");
        end
    else
        if(type == REQUEST_TYPE_OPEN) then
            local uiLayer = getGameLayer(SCENE_UI_LAYER);
            uiLayer:addChild(m_rootLayer);
            JJCPersonal.open();
            JJCPersonal.createAnimation();

            --分组变化提示
            local jjcData = UserInfoManager.getRoleInfo("jjcData");
            local lastGroupid = jjcData.lastgroupid;
            local curGroupid = jjcData.groupId;
            -- lastGroupid = 6;
            -- curGroupid  = 5;
            if(lastGroupid ~= nil and lastGroupid ~= 10 and lastGroupid ~= curGroupid) then
               --关闭升降组提示
                local function closeUpPanel(sender,eventType) 
                    if eventType == TOUCH_EVENT_TYPE_END then
                        m_upAnim:removeFromParentAndCleanup(true);
                        m_upPanel:removeFromParentAndCleanup(true);
                        CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(PATH_RES_OTHER .. "jingjichangsz.ExportJson");
                        CCTextureCache:sharedTextureCache():removeTextureForKey(PATH_RES_OTHER .. "jingjichangsz0.png");
                    end
                end
                CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_OTHER .. "jingjichangsz.ExportJson");
                m_upAnim = CCArmature:create("jingjichangsz");
                m_upAnim:setPosition(ccp(568, 300));
                uiLayer:addChild(m_upAnim, 5);
                m_upPanel = TouchGroup:create();
                local upPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "shengzuUi_1.json");
                upPanel:addTouchEventListener(closeUpPanel);
                m_upPanel:addWidget(upPanel);
                uiLayer:addChild(m_upPanel, 10);

                local lastG = getGroupName(lastGroupid);
                local curG = getGroupName(curGroupid);
                local uprrPanel = tolua.cast(upPanel:getChildByName("rootPanel"), "Layout");
                local img1 = tolua.cast(uprrPanel:getChildByName("pride1_img"), "ImageView");
                local img2 = tolua.cast(uprrPanel:getChildByName("pride2_img"), "ImageView");
                local name1 = tolua.cast(uprrPanel:getChildByName("pridename1_label"), "Label");
                local name2 = tolua.cast(uprrPanel:getChildByName("pridename2_label"), "Label");
                local desc = tolua.cast(uprrPanel:getChildByName("desc_label"), "Label");
                img1:loadTexture(getJJCGroupFlagImg(lastGroupid));
                img2:loadTexture(getJJCGroupFlagImg(curGroupid));
                name1:setText(getGroupName(lastGroupid));
                name2:setText(getGroupName(curGroupid));
                if(curGroupid < lastGroupid) then
                    --升组了
                    m_upAnim:getAnimation():play("stand");
                    AudioEngine.playEffect(PATH_RES_AUDIO.."jingjichangshengjie.mp3");
                    desc:setText("升组了");
                else
                    --降组
                    m_upAnim:getAnimation():play("fall");
                    desc:setText("降组了");
                end
            end
        elseif(type == REQUEST_TYPE_FIGHT) then
            --挑战
            fight();
        end
    end
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "JJCUI.json");
        m_uiLayer = TouchGroup:create();
        m_uiLayer:addWidget(uiLayout);
        m_rootLayer:addChild(m_uiLayer);
        m_rootLayer:retain();   

        initLabel(m_uiLayer);
        initOppPanel(m_uiLayer);
        initButton(m_uiLayer);

        local tiaozhan_panel = m_uiLayer:getWidgetByName("tiaozhan_panel");
        local pos = ccp(tiaozhan_panel:getPositionX(), tiaozhan_panel:getPositionY());
        JJCReport.create();
        JJCPersonal.create();
        JJCPersonal.setPosition(pos);
        JJCGroup.create();
        JJCGroup.setPosition(pos);

        registerMessageCB();
    end
end

function open()
    if(not m_isOpen) then
        m_isOpen = true;
        openInit();
        NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_JJC_OPEN_RESPONSE, onReceiveOpenResponse);
        ProgressRadial.open(); --关闭进度条
        sendOpenRequest(REQUEST_TYPE_OPEN);
    end
end

function close()
    if(m_isOpen) then
        m_isOpen = false;
        local  uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer,false);

        JJCReport.close();
        JJCPersonal.close();
        JJCGroup.close();

        stopUpdate();
        JJCPersonal.removeAnimation();
        ProgressRadial.close();
        removeAllAnimation();
        OtherPlayer.removeAnimation();
        NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_JJC_OPEN_RESPONSE, onReceiveOpenResponse);
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        m_rootLayer:removeAllChildrenWithCleanup(true);
        m_rootLayer:release();
        m_rootLayer = nil;
        m_uiLayer   = nil;
        m_oppPanel = nil;
        m_timeLabel = nil;
        unregisterMessageCB();

        JJCReport.remove();
        JJCPersonal.remove();
        JJCGroup.remove();
    end
end