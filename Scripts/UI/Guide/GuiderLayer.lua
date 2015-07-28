-- --
-- -- Author: Gao Jiefeng
-- -- Date: 2015-04-14 10:27:27
-- --
module("GuiderLayer", package.seeall)

require("extern")
local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_UILayout = nil
local m_posInfo = {}
local m_ShieldColor = ccc4f(0,0,0,(180/255))
local m_localStepRecord = 1
local m_isRegister = false
local m_ActionIndex= 0
local m_PointRect = CCRect(0,200,1136,300)
local m_callback = nil
local m_pointBeginX = 0 
local m_pointBeginY = 0 
local m_armature = nil
local m_PositionEffect = nil
local m_dialogImg = nil 
local m_dailogLabel = nil
local function initDataTable()
    local posInfo = DataTableManager.getTableByName("NewGuider")
    for k,v in pairs(posInfo) do
        m_posInfo[v.steps] = v
        m_posInfo[v.steps]["callback"] = GuideDatas["guide"..v.steps.."CallBack"]
    end
end

local function createAnime(animActorName,x,y,w,h,actionIndex)
    local path = PATH_RES_OTHER .. animActorName .. ".ExportJson";
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(path);
    local armature = CCArmature:create(animActorName)

    armature:getAnimation():playWithIndex(actionIndex)
    armature:setPosition(ccp(x+w/2,y+h/2))
    m_PositionEffect = CCPoint(x+w/2,y+h/2)
    if TaskManager.getNewGuideInfo()["step"] ==4 then
        if TaskManager.getLocalStepRecord() ==4 then
            armature:getAnimation():playWithIndex(0)
            armature:setPosition(ccp(323,400))
            local actList = CCArray:create()
            local moveto = CCMoveTo:create(1, CCPoint(408, 86))
            local callback = CCCallFunc:create(function()   
                            armature:setPosition(ccp(323,400))
                    end)
            actList:addObject(moveto)
            actList:addObject(callback)
            armature:runAction(CCRepeatForever:create(CCSequence:create(actList) ) )
        end
    end
    
    m_rootLayer:addChild(armature)
end

function palyEffect()
    if m_armature~= nil then
        -- m_armature:removeFromParentAndCleanup(true)
        m_rootLayer:removeChild(m_armature,false)
        m_armature = nil
    end
    m_armature = nil
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_OTHER.."tishiyinying.ExportJson");
    m_armature = CCArmature:create("tishiyinying");
    m_armature:setPosition(m_PositionEffect);
    CCArmatureDataManager:purge();
    m_armature:getAnimation():playWithIndex(0);
    m_rootLayer:addChild(m_armature,100);
    
    local removeEffectNode = function ()
        if m_armature~= nil then
            -- m_armature:removeFromParentAndCleanup(true)
            m_rootLayer:removeChild(m_armature,false)
            m_armature = nil
        end
    end
    performWithDelay(m_rootLayer,removeEffectNode, 0.6)
end
function createPolygon(posX,posY,width,height)

end

function GuideTouchBegin(x,y)
    if m_PointRect:containsPoint(ccp(x,y)) then
        m_pointBeginX = x 
        m_pointBeginY = y
    else
        palyEffect()
    end
end
function GuideTouchMoved(x,y)
    if m_PointRect:containsPoint(ccp(x,y)) then
    end
end
function GuideTouchEnded(x,y)
    if m_PointRect:containsPoint(ccp(x,y)) then
        if m_ActionIndex == 0 then
                if m_callback~= nil then
                    m_callback()
                end            
        elseif (m_ActionIndex == 1 or m_ActionIndex == 2) then --zuohua,youhua
            if math.abs(m_pointBeginX -x)>100 then
                m_callback()
            end
        elseif (m_ActionIndex == 3 or m_ActionIndex == 4) then --shanghua,xiahua
            if math.abs(m_pointBeginY -y)>100 then
                m_callback()
            end
        end
    end


end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "NewerGuideUI_1.json");
        m_UILayout = TouchGroup:create();
        m_UILayout:addWidget(UISource);
        m_rootLayer:addChild(m_UILayout);
        local panel = tolua.cast(m_UILayout:getWidgetByName("Panel_3"),"Button")
        local function swalloTouch(event,eventType)
            if Upgrade.getOpenState() then
                UIManager.close("Upgrade")
                return
            end
            if RewardDisplay.getOpenState() then
                UIManager.close("RewardDisplay")
                return
            end
            
            if eventType == TOUCH_EVENT_TYPE_BEGIN then
                local pos = panel:getTouchStartPos()
                GuideTouchBegin(pos.x,pos.y)
            elseif eventType == TOUCH_EVENT_TYPE_MOVE then
                local pos = panel:getTouchMovePos()
                GuideTouchMoved(pos.x,pos.y)
            elseif eventType == TOUCH_EVENT_TYPE_END then
                local pos = panel:getTouchEndPos()
                GuideTouchEnded(pos.x,pos.y)
            end
        end        
        panel:addTouchEventListener(swalloTouch)
        m_dialogImg = tolua.cast(m_UILayout:getWidgetByName("Image_3"),"ImageView")
        m_dialogImg:setVisible(false)
        m_dailogLabel = tolua.cast(m_UILayout:getWidgetByName("Label_5"),"Label")
        m_dailogLabel:setVisible(false)
    end
end

function open()
    if (not m_isOpen) then
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_GUIDE_LAYER);
        uiLayer:addChild(m_rootLayer);
        --屏蔽事件（主城和世界地图）

        initDataTable()
        local guideData = TaskManager.getNewGuideInfo()

        --调整到相应的主城位置
        if guideData["step"] == 1 then
        else
        end
        m_localStepRecord = TaskManager.getLocalStepRecord()
        local guideDataNow = m_posInfo["step"..guideData["step"].."_"..m_localStepRecord] 
        createPolygon(guideDataNow.posX,guideDataNow.posY,guideDataNow.width,guideDataNow.height)

        local dialogContent = guideDataNow["text"]
        -- if dialogContent~= nil then 
        if  dialogContent~= "" then 
            
            m_dailogLabel:setVisible(true)
            m_dailogLabel:setText(dialogContent)
            m_dialogImg:setVisible(true)
            local imgX = guideDataNow["ImgX"]
            local imgY = guideDataNow["ImgY"]
            m_dialogImg:setPosition(ccp(imgX, imgY))
            if guideDataNow["roleicon"] == 320003 then 
                m_dialogImg:loadTexture(PATH_CCS_RES.."gy_yindao1.png")
            else
                m_dialogImg:loadTexture(PATH_CCS_RES.."gy_yindao.png")
            end
            local direction  = guideDataNow["direction"]
            if direction== 0 then
                m_dialogImg:setFlipX(true)
                m_dailogLabel:setPositionX(m_dailogLabel:getPositionX()-160)
            end
        end

        m_PointRect = CCRect(guideDataNow.posX,guideDataNow.posY,guideDataNow.width,guideDataNow.height)
        m_callback = guideDataNow.callback

        m_ActionIndex = 0
        if guideDataNow.actionName  == "dianji" then 
            m_ActionIndex = 0
        elseif guideDataNow.actionName  == "zuohua" then 
            m_ActionIndex = 1
        elseif guideDataNow.actionName  == "youhua" then 
            m_ActionIndex = 2
        elseif guideDataNow.actionName  == "shanghua" then 
            m_ActionIndex = 3
        elseif guideDataNow.actionName  == "xiahua" then 
            m_ActionIndex = 4
        end
        createAnime(guideDataNow["animName"],guideDataNow["posX"],guideDataNow["posY"],guideDataNow["width"],guideDataNow["height"], m_ActionIndex)
    end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_GUIDE_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        TouchDispatcher.init()
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        if(m_rootLayer) then
            m_rootLayer:removeAllChildrenWithCleanup(true);
            m_rootLayer:release();
        end
        m_isCreate = nil;
        m_isOpen = nil;
        m_rootLayer = nil;
        m_uiLayer = nil;
    end
end
function getRootLayer()
    return m_rootLayer
end

