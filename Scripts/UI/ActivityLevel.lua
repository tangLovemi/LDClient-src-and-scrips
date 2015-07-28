
module("ActivityLevel", package.seeall)
local m_layout  = nil;
local m_rootLayer = nil;
local m_iconHeight = 0;
local fontHeight = 30;
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_curType = 0;
local m_isOpen = false;
local scrollView = nil;
local m_btnArray = nil;
local m_curSelectedID = 0;
local m_curSelectBtn = nil;
local m_rewardList = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 780/2,WINSIZE.height/2 - 460/2);
local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("ActivityLevel");
    end
end

local function closeSelf(obj,event)
    if(event == TOUCH_EVENT_TYPE_END) then
        UIManager.close("ActivityLevel");
    end 
end

function create()
	m_rootLayer = CCLayer:create();
	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
    bgLayer:registerScriptTouchHandler(onTouch);
    m_rootLayer:addChild(bgLayer);
    m_layout = TouchGroup:create();
    m_layout:setPosition(SETTING_POSITION);
    m_layout:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "huodongfuben_2.json"));
    local backBtn = tolua.cast(m_layout:getWidgetByName("Button_11"),"Button");
    backBtn:addTouchEventListener(closeSelf);
    -- m_rootLayer:addChild(m_layout);--ACTIVITY_LEVEL_DATA_NAME
    m_rootLayer:addChild(UIManager.bounceOut(m_layout));

end

function removeCurrentSources()
    UIManager.close("ActivityType");
    UIManager.close("ActivityLevel");
    MainCityLogic.removeMainCity();
end

local function enterActivity()
    BattleManager.enterBattle(BATTLE_MAIN_TYPE_PVE,BATTLE_SUBTYPE_ACTIVITY,m_curSelectedID,removeCurrentSources);
end


local function openHelp(obj,event)
	if(event == TOUCH_EVENT_TYPE_END) then

	end
end


local function goodsOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_BEGIN then
        GoodsDetails.onTouchBegin(sender, sender:getTag(), 1);
    elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
        GoodsDetails.onTouchEnd();
    end
end


local function selectDiffcault(obj,event)
    if(event == TOUCH_EVENT_TYPE_END) then
        if(m_curSelectBtn ~= nil)then
            if(m_curSelectBtn == obj)then
                return;
            end
        end
        local selectedImg = ImageView:create();
        selectedImg:loadTexture(PATH_CCS_RES .. "huodong_gaoguang.png");
        selectedImg:setTag(1);
        obj:addChild(selectedImg);
        if(m_curSelectBtn ~= nil)then
            m_curSelectBtn:removeChildByTag(1,true);
        end
        m_curSelectBtn = obj;
        tolua.cast(m_rewardList,"ListView"):removeAllItems();
        local kkk = tolua.cast(obj,"Button");
        local kkjkj = tolua.cast(obj,"Layout"):getName();
       local rewardStr = DataBaseManager.getValue(DATA_BASE_ACTIVITY_LEVEL, DATABASE_HEAD .. tolua.cast(obj,"Layout"):getName(), "reward");
       local rewardCountStr = DataBaseManager.getValue(DATA_BASE_ACTIVITY_LEVEL, DATABASE_HEAD .. tolua.cast(obj,"Layout"):getName(), "rewardcount");
       local rewardList = Util.strToNumber(Util.Split(rewardStr,"&"));
       for i=1,#rewardList do
            local res = GoodsManager.getIconPathById(tonumber(rewardList[i]));
            if(res ~= "")then
                local image = ImageView:create();
                image:setTouchEnabled(true);
                image:loadTexture(res,0);
                local frame = ImageView:create();
                frame:loadTexture(GoodsManager.getColorBgImg(GoodsManager.getColorById(rewardList[i])),0);
                image:addChild(frame);
                m_rewardList:pushBackCustomItem(image);
                image:setTag(rewardList[i]);
                image:addTouchEventListener(goodsOnClick);
            end
       end
    end
end

local function copyItem(item)
    local obj = {};
    for key,value in pairs(item)do
        obj[key] = value;
    end
    return obj;
end

function compare(item1,item2)
    return item1.level > item2.level;
end

function sort(list,compare)
    local len = #list;
    for i=1,len do
        local temp = list[i];
        for k=len,i,-1 do
            if(compare(temp,list[k]))then
                list[i] = list[k];
                list[k] = temp;
                temp = list[i];
            end
        end
    end
end

function open(type,message)
	m_curType = type;
	create();
    local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(m_rootLayer, TWO_ZORDER);
	local function enterBattle(obj,event)
		if(event == TOUCH_EVENT_TYPE_END) then
            if(GoodsManager.isBackpackFull_1()) then
                BackpackFullTishi.show();
            else
                CCLuaLog("button event");--进入相应的战斗副本 
                if(m_curSelectBtn ~= nil)then
                    local id = tonumber(tolua.cast(m_curSelectBtn,"Layout"):getName());
                    BattleManager.enterBattle(BATTLE_MAIN_TYPE_PVE,BATTLE_SUBTYPE_ACTIVITY,id,removeCurrentSources);
                end
                -- m_curSelectedID = tonumber(tolua.cast(obj,"Layout"):getName());--获取要进入关卡的id
                -- MainCityLogic.removeMainCity();
            end
		end
	end

    local titleName = "Image_Title" .. type;
    local title = tolua.cast(m_layout:getWidgetByName(titleName),"Layout");
    title:setVisible(true);
	local array = {};
 	scrollView = m_layout:getWidgetByName("ListView_2");
    m_rewardList = m_layout:getWidgetByName("ListView_20");
	local column = 4;
    scrollView = tolua.cast(scrollView,"ListView");
    local size = scrollView:getSize();
    local width = size.width;
    local height = size.height;
    local data = DataBaseManager.getTableByName(DATA_BASE_ACTIVITY_LEVEL);
    local count = 0;
    local iconArray = {};
    local dataArray = {};
    local length = #data;
    local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "huodongfuben_3.json")
    if(m_btnArray == nil)then
        m_btnArray = {};
    end
    local sortTable = {};
    for i,v in pairs(data) do
    	if(v.type == type)then
            table.insert(sortTable,copyItem(v));
        end
    end
    sort(sortTable,compare);
    for i = 1,#sortTable do
        local node = tolua.cast(item:clone(),"Layout");

        -- node:setName(sortTable[i].id);
        local btn = tolua.cast(node:getChildByName("Button_5"),"Button");
        local image1 = btn:getChildByName("Image_3");
        local level = tolua.cast(image1:getChildByName("AtlasLabel_4"),"LabelAtlas");
        level:setStringValue(tostring(sortTable[i].level));
        btn:setName(sortTable[i].id);
        local normalImgName = PATH_CCS_RES .. "hd_normal_" .. type .. "_" .. sortTable[i].level .. ".png";
        local disableImgName = PATH_CCS_RES .. "hd_disable_" .. type .. "_" .. sortTable[i].level .. ".png";
        btn:loadTextures(normalImgName,normalImgName,disableImgName);
        if(sortTable[i].rstrainLevel > UserInfoManager.getRoleInfo("level"))then
            local temp = tolua.cast(btn,"Button");
            temp:setTouchEnabled(false);
            temp:setBright(false);
        else
            btn:addTouchEventListener(selectDiffcault); 
        end

        scrollView:pushBackCustomItem(tolua.cast(node,"Layout"));
    end
	-- local helpBtn = m_layout:getWidgetByName("help_img");
 --    helpBtn = tolua.cast(helpBtn,"ImageView");
 --    helpBtn:addTouchEventListener(openHelp); 

    local timeLabel = m_layout:getWidgetByName("Label_7");
    timeLabel = tolua.cast(timeLabel,"Label");
    timeLabel:setText(tostring(message[type].times));


    
    local confirmBtn = m_layout:getWidgetByName("Button_11");
    confirmBtn = tolua.cast(confirmBtn,"Button");
    confirmBtn:addTouchEventListener(enterBattle); 
end


function close()
    m_curSelectedID = 0;
    m_curSelectBtn = nil;
    m_rewardList = nil;
    local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:removeChild(m_rootLayer, true);
end

function remove()

end