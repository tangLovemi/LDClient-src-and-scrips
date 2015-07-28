--
-- Author: Your Name
-- Date: 2015-06-04 17:04:56
--
--
module("WishItemEffect", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_isOpen = false
local m_isCreate = false;
local m_armature = nil 
local m_messageData = nil
local m_selectTyp = nil
local m_chouka1btn = nil
local m_rebuyOnClick = 0
local m_actionManager = CCDirector:sharedDirector():getActionManager()
local m_playingEffect = false 
local m_EffectSprit = nil
local m_CurIndex = 1
local m_osTime = 0
local m_timeDiff = 2
local m_closePanel = nil;

function chukaAgain(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if (os.time()-m_osTime)>m_timeDiff then
			WishManager.setBaseInfoCallback(WishMain.initBaseInfo)
			local function openItemDetailUI(messageData)
				UIManager.close("WishItemEffect")
				messageData["rebuy"] = 1
				UIManager.open("WishItemEffect",messageData)
			end
			WishManager.chouchaWork(m_selectTyp,#m_messageData,openItemDetailUI)
			m_osTime = os.time()
		else
			Util.showOperateResultPrompt("请两秒之后再次祈愿")
		end

	end
end
function createCoatLayout(itemData )
	local coatId= itemData.id
    local function closeDetail()

        Background.close();
        Background.remove();  
        m_actionManager:resumeTarget(m_EffectSprit)
    end
    local coatBaseLayer = Background.create(closeDetail,1)
    Background.open()  
    --Add the background
    local pBackground = CCScale9Sprite:create(PATH_CCS_RES.."ckgx_beijing.png")
    pBackground:setContentSize(CCSizeMake(1136, 640))
    pBackground:setPosition(ccp(568,320))
    coatBaseLayer:addChild(pBackground)     

    local showDaguangEffect = function ()
	    local daguanEffect = createDaguangOnBackGround()
	    coatBaseLayer:addChild(daguanEffect,2)
    end

    local showCoat = function ()
	    local coatImg = createCoatAndEffect(itemData)
	    coatImg:setPosition(ccp(363,30))
	    coatBaseLayer:addChild(coatImg,2)

	    local m_animationLodingPath = PATH_RES_EFFECT .."cjgx_shangdaguang.ExportJson"
	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationLodingPath);
	    local tempAnimate2 = CCArmature:create("cjgx_shangdaguang");
	    tempAnimate2:getAnimation():playWithIndex(0);
	    tempAnimate2:setPosition(ccp(578,320));
	    CCArmatureDataManager:purge();

		coatBaseLayer:addChild(tempAnimate2,3)

    end
    local callBack1 = CCCallFunc:create(showDaguangEffect)
    local callBack2 = CCCallFunc:create(showCoat)

	local action_delay = CCDelayTime:create(0.5)
    local arrayOfActions2 = CCArray:create()
    arrayOfActions2:addObject(callBack1)
    arrayOfActions2:addObject(action_delay)
    arrayOfActions2:addObject(callBack2)

    local sequence = CCSequence:create(arrayOfActions2)
    -- local action = CCRepeatForever:create(sequence)
	coatBaseLayer:runAction(sequence)

end
function createDaguangOnBackGround()
	local m_animationLodingPath = PATH_RES_EFFECT .."cjgx_daguang.ExportJson"

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationLodingPath);
    local tempAnimate = CCArmature:create("cjgx_daguang");
    tempAnimate:setScale(1)
    tempAnimate:getAnimation():playWithIndex(2);
    tempAnimate:setPosition(ccp(578,320));
    CCArmatureDataManager:purge();

    return tempAnimate
end
function createCoatAndEffect(itemData)
	local coatId = itemData.id
	local wordrobeBase = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Wardrobe_item.json");
    local tempLayout = TouchGroup:create();
    tempLayout:addWidget(wordrobeBase);
    local img = tolua.cast(tempLayout:getWidgetByName("coatIcon"), "ImageView");
    local countPanel = tolua.cast(tempLayout:getWidgetByName("count_panel"), "Layout");
	local colorBgImg = tolua.cast(tempLayout:getWidgetByName("colorbg_img"), "ImageView");
    countPanel:setVisible(false)
    local typeid = DataTableManager.getItemByKey("coat_grow", "id", coatId).type;
    img:loadTexture(PATH_RES_IMAGE_WARDROBE_NORMAL .. "wardrobe_" .. typeid .. ".png");
    --状态图
	local status_img = tolua.cast(img:getChildByName("status_img"), "ImageView");
	status_img:setVisible(false)
	local starName = {"force", "agility", "endurance"};
	local STAR_COUNT = 10;
	for i,v in ipairs(starName) do
		local starLV = DataTableManager.getValue("coat_grow", "id_" .. coatId, v .. "_star");
		local starPanel = tolua.cast(img:getChildByName(v .. "Star_panel"), "Layout");
		for j=1,STAR_COUNT do 
			local starImg = tolua.cast(starPanel:getChildByName(v .. "Star_" .. j), "ImageView");
			if(j <= starLV) then
				starImg:setEnabled(true);
				-- starImg:loadTexture(starEnablePath);
			else
				starImg:setEnabled(false);
			end
		end
	end

	local color = GoodsManager.getColorById(coatId);
	if(color == COLOR_WHITE) then
		colorBgImg:setEnabled(false);
	else
		colorBgImg:setEnabled(true);
		colorBgImg:loadTexture(Wardrobe.getColorBgImg(color));
	end

	if itemData.ishave == 1 then
		local descLabel = Label:create()
	    descLabel:setText(TEXT.haveThisCoatBefore..itemData.pieces);
	    descLabel:setFontSize(24);
	    descLabel:setTextHorizontalAlignment(kCCTextAlignmentLeft);
	    descLabel:setPosition(ccp(0,-290));
	    img:addChild(descLabel)
	end
	return tempLayout
end
function initItems()
	if m_messageData==nil then
		return
	end
	if #m_messageData==10 then
		local index = 1
		local function cfCallBack( ... )
			if index>10 then
				return
			end
			local i,j
			if index<=5 then
				i = 1
				j= index
			else
				i=2
				j = index -5
			end
			if m_messageData[index].iscoat ==1 then
				m_actionManager:pauseTarget(m_EffectSprit)
				createCoatLayout(m_messageData[index])
			end
			playItemEffect(m_messageData[index].id,CCPoint(578,400),CCPoint(350+80*j,350-100*i))
			if index == 10 then
				m_playingEffect = false
			end
			index = index+1
			m_CurIndex = index
		end
	    local callBack = CCCallFunc:create(cfCallBack)
		local action_delay = CCDelayTime:create(0.5)
	    local arrayOfActions2 = CCArray:create()
	    arrayOfActions2:addObject(callBack)
	    arrayOfActions2:addObject(action_delay)
	    local sequence = CCSequence:create(arrayOfActions2)
	    local action = CCRepeatForever:create(sequence)
	    m_EffectSprit:runAction(action)
		
	elseif #m_messageData==1 then
		local function cfCallBack()
			if m_messageData[1].iscoat ==1 then
				m_actionManager:pauseTarget(m_EffectSprit)
				createCoatLayout(m_messageData[1])
			end
		end
		local function cfCallBack2()
			playItemEffect(m_messageData[1].id,CCPoint(578,400),CCPoint(578,200))
		end		
	    local callBack = CCCallFunc:create(cfCallBack)
		local action_delay = CCDelayTime:create(0.01)
		local callBack2 = CCCallFunc:create(cfCallBack2)
	    local arrayOfActions2 = CCArray:create()
	    arrayOfActions2:addObject(callBack)
	    arrayOfActions2:addObject(action_delay)
	    arrayOfActions2:addObject(callBack2)
	    local sequence = CCSequence:create(arrayOfActions2)
	    m_EffectSprit:runAction(sequence)
	end

end
function playItemColorEffect(itemSprite,colorId)
	if colorId== 3 then 
		local effectPath = PATH_RES_EFFECT .."ckgx_bg_lan.ExportJson"
	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(effectPath);
	    effectArmature = CCArmature:create("ckgx_bg_lan");
	elseif colorId== 4 then 
		local effectPath = PATH_RES_EFFECT .."ckgx_bg_zi.ExportJson"
	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(effectPath);
	    effectArmature = CCArmature:create("ckgx_bg_zi");		
	elseif colorId== 5 then 
		local effectPath = PATH_RES_EFFECT .."ckgx_bg_huang.ExportJson"
	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(effectPath);
	    effectArmature = CCArmature:create("ckgx_bg_huang");		
	else
		return
	end

    effectArmature:setScale(1)

    effectArmature:getAnimation():playWithIndex(0);
    effectArmature:setPosition(ccp(32,32));
    effectArmature:retain();
    CCArmatureDataManager:purge();

    itemSprite:addChild(effectArmature,-1);
end

local m_clickBtn = nil;


local function goodsOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_BEGIN then
        GoodsDetails.onTouchBegin(sender, sender:getTag(), 1, true);
    elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
        GoodsDetails.onTouchEnd();
    end
end

function playItemEffect(itemId,startPos,endPos)
	
	local iconImage = (GoodsManager.getBaseInfo(itemId)).icon
	local colorId = (GoodsManager.getBaseInfo(itemId)).color
	local frameImg = GoodsManager.getColorBgImg(colorId)
	local baseSprite = CCSprite:create(iconImage)
	local frameSprite = CCSprite:create(frameImg)
	
	frameSprite:setPosition(ccp(32,32))
	baseSprite:setPosition(startPos)
	baseSprite:setAnchorPoint(ccp(0.5,0.5))
	baseSprite:addChild(frameSprite)
	m_EffectSprit:addChild(baseSprite)
	local maskSprite = CCSprite:create(PATH_CCS_RES.."gaitubiao.png")
	maskSprite:setPosition(startPos)
	maskSprite:setAnchorPoint(ccp(0.5,0.5))
	m_EffectSprit:addChild(maskSprite)
--main Sprite Actions
	local timeIntevel = 0.15 
	local ccDesPoint = endPos
	baseSprite:setScale(0.01)

    local arrayOfActions = CCArray:create()
    local moveToB = CCMoveTo:create(timeIntevel, ccDesPoint)
    arrayOfActions:addObject(moveToB)
    local cfCallBack = function ()
    	print("this is a callback")
    	if #m_messageData ==1 then 
    		m_playingEffect = false
    	end
		local clickItem = m_clickBtn:clone();
		clickItem:setTag(itemId);
		clickItem:addTouchEventListener(goodsOnClick);
		clickItem:setPosition(endPos);
		m_closePanel:addChild(clickItem);
    end

    local callBack = CCCallFunc:create(cfCallBack)
    local ratate = CCRotateTo:create(timeIntevel,360)
    arrayOfActions:addObject(ratate)

    local scale = CCScaleTo:create(timeIntevel,1)
    arrayOfActions:addObject(scale)

    local spawn = CCSpawn:create(arrayOfActions)
    local arrayOfActions2 = CCArray:create()
    arrayOfActions2:addObject(spawn)
    arrayOfActions2:addObject(callBack)

    local sequence = CCSequence:create(arrayOfActions2)
    baseSprite:runAction(sequence)

-- mask Sprite Actions
    local array_actions_mask1 = CCArray:create()
    local moveToB = CCMoveTo:create(timeIntevel, ccDesPoint)
    array_actions_mask1:addObject(moveToB)
    local colorEffect = function ()
	    --新手引导
	    ProgressRadial.close();
	    if TaskManager.getNewState() then
	        UIManager.open("GuiderLayer")
	    end
	    

    	print("this is a callback")
    	playItemColorEffect(baseSprite,colorId)
    end
    local callBack = CCCallFunc:create(colorEffect)
    -- array_actions_mask1:addObject(callBack)
    local ratate = CCRotateTo:create(timeIntevel,180)
    array_actions_mask1:addObject(ratate)
    local fadeOut_mask = CCFadeOut:create(timeIntevel)
    array_actions_mask1:addObject(fadeOut_mask)
    local scale = CCScaleTo:create(timeIntevel,1)
    array_actions_mask1:addObject(scale)

    local spawn = CCSpawn:create(array_actions_mask1)
    local arrayOfActions2_mask = CCArray:create()
    arrayOfActions2_mask:addObject(spawn)
    arrayOfActions2_mask:addObject(callBack)

    local sequence = CCSequence:create(arrayOfActions2_mask)
    maskSprite:runAction(sequence)
end
function playEffect()

	local m_animationLodingPath = PATH_RES_OTHER .."xuyuantianshi.ExportJson"

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationLodingPath);
    m_armature = CCArmature:create("xuyuantianshi");
    m_armature:setScale(1)
    if m_messageData["rebuy"] ==1 then
    	m_armature:getAnimation():playWithIndex(4);
    else
    	m_armature:getAnimation():playWithIndex(0);
    end
    m_armature:setPosition(ccp(578,320));
    m_armature:retain();
    CCArmatureDataManager:purge();

    m_EffectSprit:addChild(m_armature);
end

function showRewardItemWithNoAnimation()
	m_EffectSprit:removeChild(m_armature,true);
	local m_animationLodingPath = PATH_RES_OTHER .."xuyuantianshi.ExportJson"

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationLodingPath);
    m_armature = CCArmature:create("xuyuantianshi");
	m_armature:getAnimation():playWithIndex(3);
    m_armature:setPosition(ccp(578,320));
    m_armature:retain();
    CCArmatureDataManager:purge();
    m_EffectSprit:addChild(m_armature);


	if #m_messageData==10 then
		local index = m_CurIndex 
		local function cfCallBack( ... )
			if index>10 then
				return
			end
			local i,j
			if index<=5 then
				i = 1
				j= index
			else
				i=2
				j = index -5
			end
			playItemEffect(m_messageData[index].id,CCPoint(578,400),CCPoint(350+80*j,350-100*i))
			if index == 10 then
				m_playingEffect = false
			end
			index = index+1
		end
	    local callBack = CCCallFunc:create(cfCallBack)
		local action_delay = CCDelayTime:create(0.00001)
	    local arrayOfActions2 = CCArray:create()
	    arrayOfActions2:addObject(callBack)
	    arrayOfActions2:addObject(action_delay)
	    local sequence = CCSequence:create(arrayOfActions2)
	    local action = CCRepeatForever:create(sequence)
	    m_EffectSprit:runAction(action)
		
	elseif #m_messageData==1 then
		local function cfCallBack()
			if m_messageData[1].iscoat ==1 then
				m_actionManager:pauseTarget(m_EffectSprit)
				createCoatLayout(m_messageData[1])
			end
		end
		local function cfCallBack2()
			playItemEffect(m_messageData[1].id,CCPoint(578,400),CCPoint(578,200))
		end		
	    local callBack = CCCallFunc:create(cfCallBack)
		local action_delay = CCDelayTime:create(0.01)
		local callBack2 = CCCallFunc:create(cfCallBack2)
	    local arrayOfActions2 = CCArray:create()
	    arrayOfActions2:addObject(callBack)
	    arrayOfActions2:addObject(action_delay)
	    arrayOfActions2:addObject(callBack2)
	    local sequence = CCSequence:create(arrayOfActions2)
	    m_EffectSprit:runAction(sequence)
	end


end



local function closeOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_playingEffect == false then
			UIManager.close("WishItemEffect")
		else
			m_playingEffect = false
			m_actionManager:removeAllActionsFromTarget(m_EffectSprit)
			-- m_EffectSprit:removeAllChildrenWithCleanup(true)
			showRewardItemWithNoAnimation()
			-- print("closeOnClick")
		end
	end
end

local function closeOnClick2(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_playingEffect == false then
			-- UIManager.close("WishItemEffect")
		else
		if (os.time()-m_osTime)>m_timeDiff then
			m_playingEffect = false
			m_actionManager:removeAllActionsFromTarget(m_EffectSprit)
			if #m_messageData ==1 then
				-- print("#m_messageData ==1 ")
				m_EffectSprit:removeAllChildrenWithCleanup(true)
			end
			showRewardItemWithNoAnimation()
			m_osTime = os.time()
		else
			Util.showOperateResultPrompt("操作过于频繁")
		end

			-- print("closeOnClick2")
		end
	end
end



function create()
	if(m_isCreate == false)then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "xuyuan2_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    m_closePanel = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout")
	    m_closePanel:addTouchEventListener(closeOnClick2);

	    m_clickBtn = tolua.cast(m_UILayout:getWidgetByName("Image_6"), "ImageView");
	    m_isCreate = true;
	    local okbtn = tolua.cast(m_UILayout:getWidgetByName("Button_1_0"), "Button")
	    okbtn:addTouchEventListener(closeOnClick);
	    m_chouka1btn = tolua.cast(m_UILayout:getWidgetByName("Button_1_1"), "Button")
	    m_chouka1btn:addTouchEventListener(chukaAgain);
	    -- local chouka10btn = tolua.cast(m_UILayout:getWidgetByName("Button_1"), "Button")
	    -- chouka10btn:addTouchEventListener(closeOnClick);

	end

end

function open(messageData)
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        m_messageData = messageData

	    m_playingEffect = true
		m_EffectSprit = CCSprite:create()
		m_EffectSprit:setPosition(0,0)
		m_rootLayer:addChild(m_EffectSprit)

	    local playCicle = function ()
	    	m_armature:getAnimation():playWithIndex(3);
	    end

	    local action_playEffect = CCCallFunc:create(playEffect)

	    
	    local action_playCicle = CCCallFunc:create(playCicle)
	    local action_initItem = CCCallFunc:create(initItems)
	    local arrayOfActions = CCArray:create()

	    arrayOfActions:addObject(action_playEffect)
	    if messageData["rebuy"] ==1 then
	    	local action_delay = CCDelayTime:create(0.6)
	    	arrayOfActions:addObject(action_delay)
	    elseif messageData["rebuy"] ==nil then
	    	local action_delay = CCDelayTime:create(3.5)
	    	arrayOfActions:addObject(action_delay)
	    end

	    
	    arrayOfActions:addObject(action_playCicle)
	    arrayOfActions:addObject(action_initItem)

	    local sequence = CCSequence:create(arrayOfActions)
	    m_EffectSprit:runAction(sequence)
	    m_selectTyp = WishManager.getSelecttype()
	    if #m_messageData ==10 then
	    	m_chouka1btn:loadTextures(PATH_CCS_RES.."xuyuanshici_1.png",PATH_CCS_RES.."xuyuanshici_1.png","")
	    end

	    m_osTime = os.time()


    -- if TaskManager.getNewState() then
    --     UIManager.open("GuiderLayer")
    -- end
	    
    end
end
function close()
	if(m_isOpen)then
		m_isOpen = false
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);


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
