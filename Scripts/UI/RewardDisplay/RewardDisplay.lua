--
-- Author: gaojiefeng
-- Date: 2015-07-26 17:36:23
--

module("RewardDisplay", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_isOpen = false
local m_isCreate = false;
local m_taskId = 0
local m_taskType = 0
local m_animationPath = PATH_RES_OTHER.."qitahuode.ExportJson"
local m_panel = nil
local function goodsOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_BEGIN then
        GoodsDetails.onTouchBegin(sender, sender:getTag(), 1);
    elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
        GoodsDetails.onTouchEnd();
    end
end
local function closeOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
        if Upgrade.getOpenState() then
            UIManager.close("Upgrade")
            return
        end
		UIManager.close("RewardDisplay")
	end

end
function create()
	if(m_isCreate == false)then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
	    m_isCreate = true;
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SheildLayer_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout,1);
	    m_panel = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout")
	    m_panel:addTouchEventListener(closeOnClick);
	end

end
function initHuntItemDatas()
	local rewardinfo1 = split(DataTableManager.getValue("Hunt",m_taskId.."_index","reward1"),";")
	local rewardinfo2 = split(DataTableManager.getValue("Hunt",m_taskId.."_index","reward2"),";")
	local rewardinfo3 = split(DataTableManager.getValue("Hunt",m_taskId.."_index","reward3"),";")
	local rewardinfo4 = split(DataTableManager.getValue("Hunt",m_taskId.."_index","reward4"),";")
	local money 	  = DataTableManager.getValue("Hunt",m_taskId.."_index","money")
	local exp   	  = DataTableManager.getValue("Hunt",m_taskId.."_index","exp")
	createItems(rewardinfo1,rewardinfo2,rewardinfo3,rewardinfo4)
	showMoneyAndExp(money,exp)
end
function initMajorItemDatas()
	local rewardinfo1 = split(DataTableManager.getValue("MajorTaskDialog",m_taskId.."_index","reward1"),";")
	local rewardinfo2 = split(DataTableManager.getValue("MajorTaskDialog",m_taskId.."_index","reward2"),";")
	local rewardinfo3 = split(DataTableManager.getValue("MajorTaskDialog",m_taskId.."_index","reward3"),";")
	local rewardinfo4 = split(DataTableManager.getValue("MajorTaskDialog",m_taskId.."_index","reward4"),";")
	createItems(rewardinfo1,rewardinfo2,rewardinfo3,rewardinfo4)
	local money = DataTableManager.getValue("MajorTaskDialog",m_taskId.."_index","money_reward")
	local exp   = DataTableManager.getValue("MajorTaskDialog",m_taskId.."_index","exp_reward")
	showMoneyAndExp(money,exp)
end
function showMoneyAndExp(moneyNum,expNum)
		local Height = 200
		local moneyImg = ImageView:create()
		moneyImg:loadTexture(PATH_CCS_RES.."gy_hb_jinbi.png")
		moneyImg:setPosition(ccp(400,Height))
		m_panel:addChild(moneyImg,1)
		local moneyLabel = Label:create()
		moneyLabel:setAnchorPoint(ccp(0,0.5))
        moneyLabel:setText("x"..moneyNum);
        moneyLabel:setPosition(ccp(45, 0));
        moneyLabel:setFontSize(18);
        moneyLabel:setColor(ccc3(255, 251, 240));
        moneyImg:addChild(moneyLabel)

		local expImg = ImageView:create()
		expImg:loadTexture(PATH_CCS_RES.."gy_hb_exp.png")
		expImg:setPosition(ccp(700,Height))
		m_panel:addChild(expImg,1)
		local expLabel = Label:create()
		expLabel:setAnchorPoint(ccp(0,0.5))
        expLabel:setText("x"..expNum);
        expLabel:setPosition(ccp(45, 0));
        expLabel:setFontSize(18);
        expLabel:setColor(ccc3(255, 251, 240));
        expImg:addChild(expLabel)
end
function createItems(rewardinfo1,rewardinfo2,rewardinfo3,rewardinfo4)
	local baseYPos = 250 
	local baseXPos = 480+100
	local itemPos = 150
	local item1 
	local item2
	local item3
	local item4
	local count = 0
	if rewardinfo1~= nil and rewardinfo1[1] ~= 0 then
		item1 = createItem(rewardinfo1)
		count = count+1
	end
	if rewardinfo2 ~= nil and rewardinfo2[1] ~= 0 then
		item2 = createItem(rewardinfo2)
		count = count+1
	end
	if rewardinfo3 ~= nil and  rewardinfo3[1] ~= 0 then
		item3 = createItem(rewardinfo3)
		count = count+1
	end
	if rewardinfo4 ~= nil and rewardinfo4[1] ~= 0 then
		item4 = createItem(rewardinfo4)
		count = count+1
	end
	if count==1 then
		item1:setPosition(ccp(baseXPos-itemPos,baseYPos))
		m_panel:addChild(item1,1)
	elseif count == 2 then 
		item1:setPosition(ccp(baseXPos-itemPos/2,baseYPos))
		m_panel:addChild(item1,1)

		item2:setPosition(ccp(baseXPos+itemPos/2,baseYPos))
		m_panel:addChild(item2,1)		
	elseif count == 3 then 
		item1:setPosition(ccp(baseXPos-itemPos,baseYPos))
		m_panel:addChild(item1,1)

		item2:setPosition(ccp(baseXPos,baseYPos))
		m_panel:addChild(item2,1)

		item3:setPosition(ccp(baseXPos+itemPos,baseYPos))
		m_panel:addChild(item3,1)
	elseif count == 4 then 
		item1:setPosition(ccp(baseXPos-itemPos*1.5,baseYPos))
		m_panel:addChild(item1,1)

		item2:setPosition(ccp(baseXPos-itemPos/2,baseYPos))
		m_panel:addChild(item2,1)

		item3:setPosition(ccp(baseXPos+itemPos/2,baseYPos))
		m_panel:addChild(item3,1)

		item4:setPosition(ccp(baseXPos+itemPos*1.5,baseYPos))
		m_panel:addChild(item3,1)
	end
end
function createItem(rewardinfo)
	local itemId1 = rewardinfo[1]
	if(tonumber(itemId1)~= 0) then
		local rewardImg1 = ImageView:create()
		rewardImg1:loadTexture(GoodsManager.getIconPathById(itemId1))
		rewardImg1:setVisible(true)
		rewardImg1:setTouchEnabled(true);
		rewardImg1:setTag(itemId1);
		rewardImg1:addTouchEventListener(goodsOnClick)
		--边框
		local colorId = (GoodsManager.getBaseInfo(itemId1)).color
		local frameImg = GoodsManager.getColorBgImg(colorId)
		local frame1 = ImageView:create()
		frame1:loadTexture(frameImg)
		frame1:setPosition(ccp(0,0))
		rewardImg1:addChild(frame1)
		
		local nameLabel = Label:create()
        nameLabel:setText(GoodsManager.getNameById(itemId1));
        nameLabel:setPosition(ccp(0, 50));
        nameLabel:setFontSize(18);
        nameLabel:setColor(ccc3(255, 251, 240));
        rewardImg1:addChild(nameLabel)
		local XLabel = Label:create()
        XLabel:setText("X");
        XLabel:setPosition(ccp(10, -20));
        XLabel:setFontSize(20);
        XLabel:setColor(ccc3(255, 251, 240));
        rewardImg1:addChild(XLabel)
		local numLabel = Label:create()
		numLabel:setAnchorPoint(ccp(0,0.5))
        numLabel:setText(rewardinfo[2]);
        numLabel:setPosition(ccp(20, -20));
        numLabel:setFontSize(18);
        numLabel:setColor(ccc3(255, 251, 240));
        rewardImg1:addChild(numLabel)
        return rewardImg1
	end
	
end
function initBoxItemDatas()
	local rewardinfo1 = split(DataTableManager.getValue("EveryDayTaskRewardData",m_taskId.."_index","item1"),";")
	local rewardinfo2 = split(DataTableManager.getValue("EveryDayTaskRewardData",m_taskId.."_index","item2"),";")
	local rewardinfo3 = split(DataTableManager.getValue("EveryDayTaskRewardData",m_taskId.."_index","item3"),";")
	local rewardinfo4 = split(DataTableManager.getValue("EveryDayTaskRewardData",m_taskId.."_index","item4"),";")
	local money = DataTableManager.getValue("EveryDayTaskRewardData",m_taskId.."_index","money")
	local exp   = DataTableManager.getValue("EveryDayTaskRewardData",m_taskId.."_index","exp")
	createItems(rewardinfo1,rewardinfo2,rewardinfo3,rewardinfo4)
	showMoneyAndExp(money,exp)
end
function initAnimation()
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationPath);
    m_armature = CCArmature:create("qitahuode");
    m_armature:getAnimation():playWithIndex(0);
    m_armature:setPosition(ccp(578,250));
    m_rootLayer:addChild(m_armature);
    local function callback()
    	m_armature:getAnimation():playWithIndex(1);
    end
    schedule(m_rootLayer, callback, 1.5)
    if m_taskType==1 then
    	initMajorItemDatas()
	elseif m_taskType ==2 then
    	initHuntItemDatas()
	elseif m_taskType ==3 then
    	initBoxItemDatas()
    end	  
end

function open()
	
	if m_isOpen ==false then
		m_isOpen = true
		initAnimation()
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
	end
end
function setTypeAndId(taskId,taskType)
	-- taskType 1,主线; 2,赏金；3,宝箱
	m_taskId = taskId
	m_taskType = taskType
end
function getOpenState( )
	return m_isOpen
end
function close()
	if(m_isOpen)then
		m_isOpen = false
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
	end

end

function remove()
	if(m_isCreate)then
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false;
	end

end

function split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, tonumber(match))
    end
    return result
end