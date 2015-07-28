module("JJCPersonal", package.seeall)

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate  = false;
local m_isOpen = false;

local m_rankingLabel    = nil; --本组排名
local m_myScoreLabel      = nil; --积分
local m_gourpScoreLabel   = nil; --本组最低积分
local m_winCountAtals = nil; --连胜次数
local m_lastCountLabel = nil; --剩余挑战次数
local m_myGroupImg = nil; --组别图片
local m_myGroupNameImg = nil; --组别名称图片

local m_minScoreLabel = nil; --本组最低积分
-- local m_nextMinScoreLabel = nil; --下一组最低积分
local m_faLabel = nil; -- 战斗力
local m_playerAnim = nil;

function setPosition( pos )
	if(pos) then
		m_rootLayer:setPosition(pos);
	end
end

function createAnimation()
    m_playerAnim = PlayerActor.getFigureActor();

    local animaPanel = tolua.cast(m_rootLayout:getWidgetByName("anim_panel"), "Layout");
    animaPanel:addNode(m_playerAnim);
    m_playerAnim:setPosition(ccp(18, -2632 + 10));
end

function removeAnimation()
	if(m_playerAnim) then
	    m_playerAnim:removeFromParentAndCleanup(false);
	    m_playerAnim = nil;
	end
end



function refreshInfo( jjcData )
	m_rankingLabel:setText(jjcData.ranking);
    m_myScoreLabel:setText(jjcData.score);
    m_winCountAtals:setStringValue(jjcData.winCount);
    m_lastCountLabel:setText(jjcData.lastCount);
	m_myGroupImg:loadTexture(JJCUI.getJJCGroupFlagImg(jjcData.groupId + 1));
	m_myGroupNameImg:loadTexture(JJCUI.getJJCGroupNameImg(jjcData.groupId + 1));
    m_minScoreLabel:setText(JJCGroup.getMinScoreOfGroup(jjcData.groupId + 1));

    local nextScore = JJCGroup.getMinScoreOfGroup(jjcData.groupId + 1);
    local ds = nextScore - jjcData.score;
    --若当前组别是最高组  或者  积分已到升组条件但还未到降组时间，则隐藏此条信息(距离升组积分差)
    -- if(jjcData.groupId + 1 >= JJCUI.getGroupCount() or ds <= 0) then
    -- 	tolua.cast(m_rootLayout:getWidgetByName("next_panel"), "Layout"):setEnabled(false);
    -- else
    -- 	tolua.cast(m_rootLayout:getWidgetByName("next_panel"), "Layout"):setEnabled(true);
    	-- m_nextMinScoreLabel:setText(ds);
    -- end

    m_faLabel:setText(UserInfoManager.getRoleInfo("fight"));
end

--战报
local function reportTouchEvent(sender,eventType) 
	if eventType == TOUCH_EVENT_TYPE_END then
		JJCReport.open();
	end
end 

local function gotoGroup( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		JJCPersonal.close();
		JJCGroup.open();
		JJCUI.setTimePanelVisiable(false);
	end
end

local function openInit()
	
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;

		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();

		m_rootLayout = TouchGroup:create();
		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "JJC_tiaozhan_1.json");
		m_rootLayout:addWidget(uiLayout);
		m_rootLayer:addChild(m_rootLayout, 1);

		m_myScoreLabel = tolua.cast(m_rootLayout:getWidgetByName("myScore_label"),"Label");

	    m_gourpScoreLabel = tolua.cast(m_rootLayout:getWidgetByName("score_label"),"Label");

	    m_winCountAtals = tolua.cast(m_rootLayout:getWidgetByName("winningCount_Atlas"),"LabelAtlas");

	    m_lastCountLabel = tolua.cast(m_rootLayout:getWidgetByName("count_label"),"Label");

	    m_rankingLabel = tolua.cast(m_rootLayout:getWidgetByName("myRanking_label"),"Label");

	    m_myGroupImg = tolua.cast(m_rootLayout:getWidgetByName("myGroup_img"),"ImageView");
	    m_myGroupNameImg = tolua.cast(m_rootLayout:getWidgetByName("myGroupName_img"),"ImageView");

	    m_faLabel = tolua.cast(m_rootLayout:getWidgetByName("zhanli_label"),"Label");

	    m_minScoreLabel = tolua.cast(m_rootLayout:getWidgetByName("minScore_label"),"Label");
	    -- local nextMinScoreLabel = tolua.cast(m_rootLayout:getWidgetByName("nextMinScore_label"),"Label");
	    -- m_nextMinScoreLabel = nextMinScoreLabel;

    	local reportBtn = tolua.cast(m_rootLayout:getWidgetByName("report_btn"), "Button");
   	 	reportBtn:addTouchEventListener(reportTouchEvent);

   	 	local gotoGroup_btn = m_rootLayout:getWidgetByName("gotoGroup_btn");
   	 	gotoGroup_btn:addTouchEventListener(gotoGroup);
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;

		local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        JJCUI.setNoPeopleIN(false);
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
	        m_rootLayer:release();
	    end
		m_rootLayer = nil;
		m_rootLayout = nil;
	end
end