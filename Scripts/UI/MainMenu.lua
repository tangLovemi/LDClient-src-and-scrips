module("MainMenu", package.seeall)

require "NetWork/NetMessageManager"
require "System/UserInfoManager"
require "DataMgr/DataTableManager"
require "Scene/ABGameLogic"
require "UI/BackpackNew"
require "UI/Wardrobe"
require "UI/MainCityUI"
require "Scene/BattleActivity"
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_editBox = nil;
local m_sendtext  = nil;
local m_gmSucLabel = nil;
local m_leftList = nil;
local m_rightList = nil;
local m_startGameBtn = nil;
local m_tempLayer = nil;

local function mailTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        --gotoMailUI
        UIManager.open("Mail");
    end
end

local function bankTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        --gotoBankUI
        UIManager.open("Bank");
    end
end

local function noticeTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        --gotoNoticeUI   
        UIManager.open("Notice");
    end
end 

local function normalShopTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        --gotoShopUI
        -- UIManager.open("NormalShop");
        Shop.open(SHOP_NORMAL_BEGIN); --此处普通商店id号要写对应据点普通商店的id号
    end
end

local function mysterShopTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        --gotoShopUI
        Shop.open(SHOP_MYSTERY);
    end
end

local function hotelTouchEvent(sender,eventType)
    EditBoxControl( "hide" )
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("Hotel");
    end
end 

local function escortTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
       
        UIManager.open("Escort");
    end
end 

local function robTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
       
       UIManager.open("RobMan");
    end

end 

local function backpackTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("BackpackNew");
        Guide.clearGuide();
    end
end 

local function transformTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("Transform");
        Guide.clearGuide();
    end
end

local function smelterTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("Smelter");
        Guide.clearGuide();
    end
end 

local function soulChemicalTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("SoulChemical");
        Guide.clearGuide();
    end
end 


local function loginTouchEvent(sender,eventType)
    -- body

    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("Login");
    end
end 

local function chatTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("Chat");
    end
end

local function faceMakerTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("FaceMaker");
    end
end

local function beatDownTouchEvent(sender,eventType)
    
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("BeatDownUI");
    end

end

local function JJCTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("JJCUI");
    end
end

local function PointStarTouchEvent( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("PointStar");
    end
end

local function tranningTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.open("TrainUI");
        EditBoxControl( "hide" )
       -- UIManager.open("TranningGroundUI");
    end
end 

local function exploreTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
         UIManager.open("ExploreUI");
    end
end 

local function animalHordeTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("AnimalHorde");
    end
end 

--猜拳
local function fingerGuessTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        -- local data = {-1, -1}; --发送请求，游戏状态-1，局数-1，表示状态未知
        -- NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FINGERGUESSREQUEST, data);
        -- ProgressRadial.open();
        FingerGuessGame.sendRequest();
        FingerGuessGame.test_sendStatus();
    end
end 

--AB答
local function ABGameTouchEvent( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        ABGameLogic.registerReceiveMsg();
        ABGameLogic.sendRequest();
        ABGameLogic.test_sendRequest();
        ABGameLogic.test_sendQuestions();
    end
end

local function lottoTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("SG_LottoUI");
    end
end 

local function mainCityTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        MainCityUI.open();
    end
end 

local function startGameTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("StartGameUI");
    end
end

local function wardrobeTouchEvent( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("Wardrobe");
    end
end

local function spriteNurtureTouchEvent( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("SpriteNurture");
    end
end

local function exchangeShopBtnTouchEvent( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        Shop.open(SHOP_EXCHANGE);
    end
end


local function friendsBtnTouchEvent( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        UIManager.open("FriendsMain");
    end
end


local function gmMessage(messageType,messageData)
    -- body

    if messageData.result == 1 then
        CCLuaLog("成功");
        m_gmSucLabel:setText("成功");
    else 
        CCLuaLog("失败");
        m_gmSucLabel:setText("失败");
    end
end 

--GM消息
local function GMTouchEvent(sender,eventType)
    -- body
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        CCLuaLog(m_editBox:getText());
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_GM,{m_editBox:getText()}); 
        m_sendtext:setText("发送了："..m_editBox:getText());

        if string.sub(m_editBox:getText(),1,6)=='Combat' then
            CCLuaLog("-------------Combat");    
            BattleManager.gmEnterBattle(1,1);
        end 
    end
end

local function createEditBox(uiLayer)
    -- body
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        if strEventName == "began" then
          
        elseif strEventName == "ended" then
            
        elseif strEventName == "return" then

        elseif strEventName == "changed" then
           
        end
    end
    -- top
    local editBoxSize = CCSizeMake(200, 40);
    local EditMsg = CCEditBox:create(editBoxSize, CCScale9Sprite:create())
    EditMsg:setPosition(ccp(366, 372));
    EditMsg:setFontSize(25)
    EditMsg:setFontColor(ccc3(255,0,0))
    EditMsg:setPlaceHolder("输入GM信息");
    EditMsg:setInputMode(kEditBoxInputModeAny);
    EditMsg:registerScriptEditBoxHandler(editBoxTextEventHandle)
    uiLayer:addChild(EditMsg); 
    EditMsg:setZOrder(243);
    m_editBox = EditMsg;
    m_tempLayer = uiLayer;
end

function EditBoxControl( hadleType )
    if hadleType == "hide" then 
        if m_editBox ~= nil then 
            m_tempLayer:removeChild(m_editBox,false);
        end 
    elseif hadleType == "show" then        
        --if m_editBox == nil then 
            createEditBox(m_tempLayer)
        --end
    else
    end    
    -- body
end

local function setskillData(skills,list)
    -- body
    list:removeAllItems();
    for i=1,#skills do
        local text = skills[i];
        local contentLabel = Label:create();
        local containLayer = Layout:create();
        containLayer:setSize(CCSizeMake(200, 30))
        containLayer:addChild(contentLabel);
        contentLabel:setText(text);
        contentLabel:setColor(ccc3(255,0,0));
        contentLabel:setFontSize(20);
        contentLabel:setPosition(ccp(100,15));
        list:pushBackCustomItem(containLayer);
    end
    
end 

--收到技能
local function receiveDataForSkills(messageType,messageData)
    -- body
    local skills = messageData.skill 
    local list   = nil;
    if messageData.dir == 1 then
        list = m_leftList;
        CCLuaLog("leftList:"..#skills);    
    else
        list = m_rightList;
        CCLuaLog(#skills);
    end

    setskillData(skills,list); 
end 

local function enterBattleTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )

        close();
        BattleManager.init();
        BattleManager.enterBattle(1, 1,1);
        -- SelectLevel.create(1);
    end
end

local function battle_simulatorTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" )
        print("this is a button call ....................................")
               -- EditBoxControl( "hide" )
        UIManager.open("Battle_simulator");    end
end

local function select_levelTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        EditBoxControl( "hide" );
        close();
        -- SelectLevel.create(1);
        WorldMap.create();
    end
end


local function activity_levelTouchEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        -- local type = DataBaseManager.getValue("ActivityLevelData","101_index","imgPray");
        close();        
        EditBoxControl( "hide" );
        BattleActivity.open();
    end
end

-----------------------------------------------开始Button设置-----------------------------------------------------
function startGameBtnSet()
    local Btn = nil;
    Btn = m_startGameBtn;
    return Btn;
end

local m_isOpen = false;
local m_isCreate = false;

function create()

    if(m_isCreate == false) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        BattleManager.init();
        WorldManager.registMessage();
        BattleManager.registerMessage();
        local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MainMenu.json");
        m_uiLayer = TouchGroup:create();
        m_uiLayer:addWidget(uiLayout);
        m_rootLayer:addChild(m_uiLayer);

        createEditBox(m_uiLayer);

        local mailBtn = m_uiLayer:getWidgetByName("mail_btn");
        mailBtn:addTouchEventListener(mailTouchEvent);

        local bankBtn = m_uiLayer:getWidgetByName("bank_btn");
        bankBtn:addTouchEventListener(bankTouchEvent);

        local noticeBtn = m_uiLayer:getWidgetByName("notice_btn");
        noticeBtn:addTouchEventListener(noticeTouchEvent);

        local normalShopBtn = m_uiLayer:getWidgetByName("normalShop_btn")
        normalShopBtn:addTouchEventListener(normalShopTouchEvent)

        local mysterShopBtn = m_uiLayer:getWidgetByName("mysteryShop_btn")
        mysterShopBtn:addTouchEventListener(mysterShopTouchEvent)

        local hotelBtn = m_uiLayer:getWidgetByName("hotel_btn");
        hotelBtn:addTouchEventListener(hotelTouchEvent);

        local escortBtn = m_uiLayer:getWidgetByName("escort_btn");
        escortBtn:addTouchEventListener(escortTouchEvent);

        local robBtn = m_uiLayer:getWidgetByName("rob_btn");
        robBtn:addTouchEventListener(robTouchEvent);

        local backpackBtn = m_uiLayer:getWidgetByName("backpack_btn");
        backpackBtn:addTouchEventListener(backpackTouchEvent);

        local transformBtn = m_uiLayer:getWidgetByName("transform_btn");
        transformBtn:addTouchEventListener(transformTouchEvent);

        local smelterBtn = m_uiLayer:getWidgetByName("smelt_btn");
        smelterBtn:addTouchEventListener(smelterTouchEvent);
        --灵魂炼化
        local soulBtn = m_uiLayer:getWidgetByName("soulChemical_btn");
        soulBtn:addTouchEventListener(soulChemicalTouchEvent);

        local loginBtn = m_uiLayer:getWidgetByName("login_btn");
        loginBtn:addTouchEventListener(loginTouchEvent);

        local chatBtn = m_uiLayer:getWidgetByName("chat_btn");
        chatBtn:addTouchEventListener(chatTouchEvent);

        local faceMakerBtn = m_uiLayer:getWidgetByName("faceMaker_btn");
        faceMakerBtn:addTouchEventListener(faceMakerTouchEvent);

        local beatDownBtn = m_uiLayer:getWidgetByName("beatDown_btn");
        beatDownBtn:addTouchEventListener(beatDownTouchEvent);

        local JJCBtn = m_uiLayer:getWidgetByName("JJC_btn");
        JJCBtn:addTouchEventListener(JJCTouchEvent);


        local pointStarBtn = m_uiLayer:getWidgetByName("pointStar_btn");
        pointStarBtn:addTouchEventListener(PointStarTouchEvent);

        local tranningBtn = m_uiLayer:getWidgetByName("tranning_btn");
        tranningBtn:addTouchEventListener(tranningTouchEvent);

        local exploreBtn = m_uiLayer:getWidgetByName("explore_btn");
        exploreBtn:addTouchEventListener(exploreTouchEvent);

        local animalHordeBtn = m_uiLayer:getWidgetByName("animalHorde_btn");
        animalHordeBtn:addTouchEventListener(animalHordeTouchEvent);

        local fingerGuessGameBtn = m_uiLayer:getWidgetByName("fingerGuess_btn");
        fingerGuessGameBtn:addTouchEventListener(fingerGuessTouchEvent);
        
        local lottoBtn = m_uiLayer:getWidgetByName("lotto_btn");
        lottoBtn:addTouchEventListener(lottoTouchEvent);

        local maincityBtn = m_uiLayer:getWidgetByName("mainCity_btn");
        maincityBtn:addTouchEventListener(mainCityTouchEvent);


        local ABGameBtn = m_uiLayer:getWidgetByName("ABGame_btn");
        ABGameBtn:addTouchEventListener(ABGameTouchEvent);

        local StartGameUI = m_uiLayer:getWidgetByName("newLogin_btn");
        StartGameUI:addTouchEventListener(startGameTouchEvent);
        m_startGameBtn = StartGameUI;

        local wardrobeBtn = m_uiLayer:getWidgetByName("wardrobe_btn");
        wardrobeBtn:addTouchEventListener(wardrobeTouchEvent);

        local spriteNurtureBtn = m_uiLayer:getWidgetByName("spriteNurture_btn");
        spriteNurtureBtn:addTouchEventListener(spriteNurtureTouchEvent);

        local exchangeShopBtn = m_uiLayer:getWidgetByName("exchangeShop_btn");
        exchangeShopBtn:addTouchEventListener(exchangeShopBtnTouchEvent);

        local friendsBtn = m_uiLayer:getWidgetByName("friends_btn");
        friendsBtn:addTouchEventListener(friendsBtnTouchEvent);

        local GMBtn = m_uiLayer:getWidgetByName("GM_btn");
        GMBtn:addTouchEventListener(GMTouchEvent);

        local gmsucLabel = tolua.cast(m_uiLayer:getWidgetByName("suc_label"),"Label");
        m_gmSucLabel = gmsucLabel;

        local sendtext = tolua.cast(m_uiLayer:getWidgetByName("sendGM_label"),"Label");
        m_sendtext = sendtext;

        local enterBattleBtn = m_uiLayer:getWidgetByName("enterbattle_btn");
        enterBattleBtn:addTouchEventListener(enterBattleTouchEvent);

        local enterBattleBtn = m_uiLayer:getWidgetByName("battle_simulator");
        enterBattleBtn:addTouchEventListener(battle_simulatorTouchEvent);

        local selectlevel = m_uiLayer:getWidgetByName("selectlevel");
        selectlevel:addTouchEventListener(select_levelTouchEvent);

        local activity = m_uiLayer:getWidgetByName("activity");
        activity:addTouchEventListener(activity_levelTouchEvent);


        local leftList = tolua.cast(m_uiLayer:getWidgetByName("leftSkiils_list"),"ListView");
        local rightList = tolua.cast(m_uiLayer:getWidgetByName("rightSkiils_list"),"ListView");
        m_leftList = leftList;
        m_rightList = rightList;

        m_leftList:retain();
        m_rightList:retain();

        NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_GM, gmMessage);
        NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ROLRSKILLS, receiveDataForSkills);

        return m_rootLayer;
    end
end

function open()
    if(m_isOpen == false) then
        m_isOpen = true;

        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, ONE_ZORDER);
    end
end


function close()
    if(m_isOpen) then
        m_isOpen = false;
        local  uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer,false);
    end
end