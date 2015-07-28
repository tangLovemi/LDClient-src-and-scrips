module("BattleUI", package.seeall)

require (PATH_SCRIPT_BATTLE .. "BattleActor")


local UI_DATA_BLOOD		= 1;
local UI_DATA_PORTRAIT 	= 2;
local UI_DATA_PROGRESS 	= 3;
local UI_DATA_BLOOD 	= 1;

local m_bloodNodePlayer = nil;
local m_bloodNodeEnemy 	= nil;

local m_portraitPlayer 	= nil;
local m_portraitEnemy 	= nil;

local m_progressPlayer 	= nil;
local m_progressEnemy 	= nil;

local m_rollerPlayer 	= nil;
local m_rollerEnemy 	= nil;

local m_speedPlayer 	= 0;
local m_speedEnemy 		= 0;
local m_tickerPlayer = 0;
local m_tickerEnemy = 0;

local m_UIData = {};
local m_layer = nil;
--
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;
local m_callBack = nil;
local m_state = UI_STATE_NONE;
local m_bloodWidth = 0;
local m_progressWidth = 0;
local m_moveDisPlayer = 0;
local m_moveDisEnemy = 0;
local m_midPosX = 0;
local m_ticker = 0;
local m_roundFrames = 100;
local m_roundMove = 0;
local m_playerData = nil;
local m_enemyData = nil;
local m_portraitOffsetX = 0;
local m_round = 1;
local m_label = nil;
local m_leftBuffNode = nil;
local m_rightBuffNode = nil;
local m_leftBuffList = nil;
local m_rightBuffList = nil;
local m_playerDefaultPosx = 0;
local m_enemyDefaultPosx = 0;
-- SCREEN_WIDTH		= 1136
-- SCREEN_HEIGHT		= 640

-- SCREEN_WIDTH_HALF	= SCREEN_WIDTH / 2
-- SCREEN_HEIGHT_HALF	= SCREEN_HEIGHT / 2
--
function create()
	local layer = CCLayer:create();

	if(layer) then
		m_layer = layer;
		init();
	end
	return layer;
end

--初始化界面
function init()

	m_speedPlayer = m_playerData.cycle;
	m_speedEnemy = m_enemyData.cycle;
	m_bloodNodePlayer = ClipNode:create(PATH_RES_BATTLE .. "blood_tile.png");
	m_bloodNodeEnemy = ClipNode:create(PATH_RES_BATTLE .. "blood_tile.png");
	m_bloodNodeEnemy:setFlipX(true);
	m_bloodNodePlayer:setClipX(-m_bloodNodePlayer:getImgSize().width);
	m_bloodWidth = m_bloodNodePlayer:getImgSize().width;
	local spriteVS = CCSprite:create(PATH_RES_BATTLE .. "vs.png");
	spriteVS:setPosition(ccp(SCREEN_WIDTH_HALF,SCREEN_HEIGHT - spriteVS:getContentSize().height/2));
	m_layer:addChild(spriteVS,3);
	local portraitFrame = CCSprite:create(PATH_RES_BATTLE .. "progress_frame.png");
	portraitFrame:setPosition(ccp(SCREEN_WIDTH_HALF,spriteVS:getPositionY() - spriteVS:getContentSize().height/2));
	m_layer:addChild(portraitFrame,3);
	portraitFrame:setVisible(false);
	local shadow = CCSprite:create(PATH_RES_BATTLE .. "progress_shadow.png");
	shadow:setPosition(portraitFrame:getPosition());
	m_layer:addChild(shadow);
	shadow:setVisible(false);
	
	m_label = LabelAtlas:create();--
	m_label:setProperty("1",PATH_RES_BATTLE .. "zhandou_shuzi.png",34,38,"0");
	m_label:setPosition(ccp(spriteVS:getPositionX(),spriteVS:getPositionY()));
	-- m_label:setPosition(ccp(500,300));
	m_layer:addChild(m_label,3);
	tolua.cast(m_bloodNodePlayer,"CCNode"):setPosition(ccp(SCREEN_WIDTH_HALF - portraitFrame:getContentSize().width/2 - m_bloodNodePlayer:getImgSize().width-30,spriteVS:getPositionY() - m_bloodNodePlayer:getImgSize().height/2-3));
	tolua.cast(m_bloodNodeEnemy,"CCNode"):setPosition(ccp(portraitFrame:getPositionX() + portraitFrame:getContentSize().width/2+30,spriteVS:getPositionY() - m_bloodNodePlayer:getImgSize().height/2-3));
	m_layer:addChild(tolua.cast(m_bloodNodePlayer,"CCNode"),1);
	m_layer:addChild(tolua.cast(m_bloodNodeEnemy,"CCNode"),1);

	-- m_progressPlayer = CCSprite:create(PATH_RES_BATTLE .. "progress_tile.png");
	-- m_progressEnemy = CCSprite:create(PATH_RES_BATTLE .. "progress_tile.png");
	-- m_progressEnemy:setFlipX(true);
	-- m_progressPlayer:setPosition(ccp(portraitFrame:getPositionX() - m_progressPlayer:getContentSize().width/2 - portraitFrame:getContentSize().width/2,portraitFrame:getPositionY()));
	-- m_progressEnemy:setPosition(ccp(portraitFrame:getPositionX() + m_progressPlayer:getContentSize().width/2 + portraitFrame:getContentSize().width/2, portraitFrame:getPositionY()));
	-- m_layer:addChild(m_progressPlayer);
	-- m_layer:addChild(m_progressEnemy);
	-- 	local point = m_progressPlayer:getAnchorPoint();
	-- m_rollerPlayer = CCSprite:create(PATH_RES_BATTLE .. "progress_button.png");
	-- m_rollerEnemy = CCSprite:create(PATH_RES_BATTLE .. "progress_button.png");
	-- m_rollerEnemy:setFlipX(true);
	-- m_rollerPlayer:setPosition(ccp(m_portraitOffsetX,m_progressPlayer:getContentSize().height/2));
	-- m_rollerEnemy:setPosition(ccp(m_progressEnemy:getContentSize().width-m_portraitOffsetX,m_progressEnemy:getContentSize().height/2));
	-- m_progressPlayer:addChild(m_rollerPlayer,4);
	-- m_progressEnemy:addChild(m_rollerEnemy,4);


	-- m_portraitPlayer = CCSprite:create(PATH_RES_BATTLE .. "portrait1.png");
	-- m_portraitEnemy = CCSprite:create(PATH_RES_BATTLE .. "portrait2.png");
	-- m_playerDefaultPosx = m_progressPlayer:getPositionX() - m_progressPlayer:getContentSize().width/2+m_portraitOffsetX;
	-- m_enemyDefaultPosx = m_progressEnemy:getContentSize().width/2 + m_progressEnemy:getPositionX()-m_portraitOffsetX;
	-- m_portraitEnemy:setFlipX(true);
	-- m_portraitPlayer:setPosition(ccp(m_playerDefaultPosx, m_progressPlayer:getPositionY()));
	-- m_portraitEnemy:setPosition(ccp(m_enemyDefaultPosx, m_progressEnemy:getPositionY()));
	-- m_layer:addChild(m_portraitPlayer,5);
	-- m_layer:addChild(m_portraitEnemy,5);

	local bloodBGPlayer = CCSprite:create(PATH_RES_BATTLE .. "blood_bg.png");
	local bloodBGEnemy = CCSprite:create(PATH_RES_BATTLE .. "blood_bg.png");
	bloodBGEnemy:setFlipX(true);
	bloodBGPlayer:setPosition(ccp(SCREEN_WIDTH_HALF - portraitFrame:getContentSize().width/2 - bloodBGPlayer:getContentSize().width/2-30,spriteVS:getPositionY()+10));
	bloodBGEnemy:setPosition(ccp(portraitFrame:getPositionX() + portraitFrame:getContentSize().width/2 + bloodBGEnemy:getContentSize().width/2+30,spriteVS:getPositionY()+10));
	m_layer:addChild(bloodBGPlayer);
	m_layer:addChild(bloodBGEnemy);


	-- m_progressWidth = m_progressPlayer:getContentSize().width + portraitFrame:getContentSize().width/2-m_portraitOffsetX;
	-- m_moveDisPlayer = m_progressWidth/m_speedPlayer;
	-- m_moveDisEnemy = m_progressWidth/m_speedEnemy;
	--
	m_UIData[1] = {m_bloodNodePlayer, m_portraitPlayer, m_progressPlayer};
	m_UIData[2] = {m_bloodNodeEnemy, m_portraitEnemy, m_progressEnemy};

	m_schedulerEntry = m_scheduler:scheduleScriptFunc(update, 0, false);

	
	-- m_roundMove = m_progressPlayer:getContentSize().width/m_roundFrames;

	m_playerData.hp = m_playerData.hp;
	m_enemyData.hp = m_enemyData.hp;
	local playBloodOffset = (m_playerData.hpMax - m_playerData.hp)/m_playerData.hpMax*m_bloodWidth;
	local enemyBloodOffset = (m_enemyData.hpMax - m_enemyData.hp)/m_enemyData.hpMax*m_bloodWidth;
	m_bloodNodePlayer:setClipX(m_bloodNodePlayer:getClipX() + playBloodOffset);
	m_bloodNodeEnemy:setClipX(m_bloodNodeEnemy:getClipX() - enemyBloodOffset);
	m_leftBuffNode = CCNode:create();
	m_rightBuffNode = CCNode:create();
	m_leftBuffNode:setAnchorPoint(CCPoint(0,1));
	m_rightBuffNode:setAnchorPoint(CCPoint(1,1));
	m_leftBuffNode:setPosition(CCPoint(100,515));
	m_rightBuffNode:setPosition(CCPoint(SCREEN_WIDTH-100,515));
	m_layer:addChild(m_leftBuffNode);
	m_layer:addChild(m_rightBuffNode);
	m_leftBuffList = List.new();
	m_rightBuffList = List.new();

	return true;
end

function caculateData()
	-- local playerRetainTicker = m_speedPlayer - m_tickerPlayer;
	-- local enemyRetainTicker = m_speedEnemy - m_tickerEnemy;
	-- local playerRetainLen = m_progressWidth - (m_portraitPlayer:getPositionX() - m_playerDefaultPosx);
	-- local enemyRetainLen = m_progressWidth - ( m_enemyDefaultPosx - m_portraitEnemy:getPositionX());
	-- if(playerRetainTicker ~= 0)then
	-- 	m_moveDisPlayer = playerRetainLen/playerRetainTicker;
	-- else
	-- 	m_moveDisPlayer = m_progressWidth/m_speedPlayer;
	-- end
	-- if(enemyRetainTicker ~= 0)then
	-- 	m_moveDisEnemy = enemyRetainLen/enemyRetainTicker;
	-- else
	-- 	m_moveDisEnemy = m_progressWidth/m_speedEnemy;
	-- end
	
	
end

function setCallFun(callFun)
	m_callBack = callFun;
end

function setState(state)
	m_state = state;
end

function getState()
	return m_state;
end

function setSpeed(id,speed)
	if(id == 1)then
		m_speedPlayer = speed;
	else
		m_speedEnemy = speed;
	end
end
-- local UI_STATE_CONTINUE 	= 1;
-- local UI_STATE_STOP     	= 2;--本次出手结束
-- local UI_STATE_ATTACK   	= 3;
-- local UI_STATE_INTERVAL 	= 4;--一回合结束
-- UI_STATE_EQUAL

local function scalePortrait(node)
	-- local action = CCScaleTo:create(0.2,1.5);
	-- local action1 = CCScaleTo:create(0.2,1.0);
	-- local array = CCArray:create();
	-- array:addObject(action);
	-- array:addObject(action1);
	-- local sequence = CCSequence:create(array);
	-- node:runAction(sequence);
end

local function nextTicker()
	m_ticker = m_ticker + 1;
end


function update(dt)
	if(getState() == UI_STATE_CONTINUE) then
		-- if((Util.getRemainder(m_tickerPlayer,m_speedPlayer) == 0 and m_tickerPlayer ~= 0) or
		--  (Util.getRemainder(m_tickerEnemy,m_speedEnemy) == 0 and m_tickerEnemy ~= 0))then
		-- -- if(m_portraitPlayer:getPositionX() == SCREEN_WIDTH_HALF or m_portraitEnemy:getPositionX() == SCREEN_WIDTH_HALF)then
		-- 	setState(UI_STATE_STOP);
		-- 	return;
		-- else
		-- 	m_ticker = m_ticker + 1;
		-- 	m_tickerEnemy = m_tickerEnemy + 1;
		-- 	m_tickerPlayer = m_tickerPlayer + 1;
		-- end
		-- if(Util.getRemainder(m_ticker,m_roundFrames) == 0 and m_ticker ~= 0)then
		-- 	m_rollerPlayer:setPositionX(m_progressEnemy:getContentSize().width);
		-- 	m_rollerEnemy:setPositionX(0);
		-- else
		-- 	m_rollerPlayer:setPositionX(m_rollerPlayer:getPositionX() + m_roundMove);
		-- 	m_rollerEnemy:setPositionX(m_rollerEnemy:getPositionX() - m_roundMove);
		-- end

		-- if(Util.getRemainder(m_tickerPlayer,m_speedPlayer) == 0 and m_tickerPlayer ~= 0)then--如果是一次出手进度条最后一帧,调整最后一帧的距离
		-- 	m_portraitPlayer:setPositionX(SCREEN_WIDTH_HALF);
		-- 	scalePortrait(m_portraitPlayer);
		-- else
		-- 	m_portraitPlayer:setPositionX(m_portraitPlayer:getPositionX() + m_moveDisPlayer);
		-- end

		-- if(Util.getRemainder(m_tickerEnemy,m_speedEnemy) == 0 and m_tickerEnemy ~= 0)then
		-- 	m_portraitEnemy:setPositionX(SCREEN_WIDTH_HALF);
		-- 	scalePortrait(m_portraitEnemy);
		-- else
		-- 	m_portraitEnemy:setPositionX(m_portraitEnemy:getPositionX() - m_moveDisEnemy);
		-- end

		-- if((Util.getRemainder(m_tickerPlayer,m_speedPlayer) == 0 and m_tickerPlayer ~= 0) or
		--  (Util.getRemainder(m_tickerEnemy,m_speedEnemy) == 0 and m_tickerEnemy ~= 0)) then
		-- 	if(Util.getRemainder(m_ticker,m_roundFrames) == 0 and m_ticker ~= 0)then
		-- 		m_rollerPlayer:setPosition(ccp(m_portraitOffsetX,m_progressPlayer:getContentSize().height/2));
		-- 		m_rollerEnemy:setPosition(ccp(m_progressEnemy:getContentSize().width-m_portraitOffsetX,m_progressEnemy:getContentSize().height/2));
		-- 		m_round = m_round+1;
		-- 		-- m_ticker = 0;
		-- 		m_label:setStringValue(tostring(m_round));
		-- 	end
		-- 	setState(UI_STATE_STOP);
		-- end
		
		-- if(Util.getRemainder(m_tickerPlayer,m_speedPlayer) ~= 0 and Util.getRemainder(m_tickerEnemy,m_speedEnemy) ~= 0)then
		-- 	if(Util.getRemainder(m_ticker,m_roundFrames) == 0 and m_ticker ~= 0)then
		-- 		m_rollerPlayer:setPosition(ccp(m_portraitOffsetX,m_progressPlayer:getContentSize().height/2));
		-- 		m_rollerEnemy:setPosition(ccp(m_progressEnemy:getContentSize().width-m_portraitOffsetX,m_progressEnemy:getContentSize().height/2));
		-- 		m_round = m_round+1;

		-- 		m_label:setStringValue(tostring(m_round));
		-- 		setState(UI_STATE_INTERVAL);
		-- 	end
		-- end
		setState(UI_STATE_STOP);
	elseif(getState() == UI_STATE_STOP)then
		caculateData();
		local actList = CCArray:create();
    	local delay = CCDelayTime:create(0.1);
    	local callback = CCCallFunc:create(convertToAttack);
    	actList:addObject(delay);
    	actList:addObject(callback);
    	m_layer:runAction(CCSequence:create(actList));--停顿一秒
    	setState(UI_STATE_NONE);
    elseif(getState() == UI_STATE_INTERVAL)then
    	--回合中间停顿
    	-- m_round = m_round+1;
		m_label:setStringValue(tostring(m_round));
    	caculateData();
    	local actList = CCArray:create();
    	local delay = CCDelayTime:create(0.1);
    	local callback = CCCallFunc:create(convertToAttack);
    	actList:addObject(delay);
    	actList:addObject(callback);
    	m_layer:runAction(CCSequence:create(actList));--停顿一秒
    	setState(UI_STATE_NONE);
    elseif(getState() == UI_STATE_NONE)then
    	-- CCLuaLog("ui state is none");
    	-- caculateData();
	end

	

end



function convertToAttack()
	BattleScene.setBattleState(BATTLE_STATE_ATTACK);
end

function nextRound()
	setState(UI_STATE_CONTINUE);
end

function updateBlood()
	updateBloodByIndex(1);
	updateBloodByIndex(2);
end

function updateBloodByIndex(index)--谁掉血 
	local data = nil;
	local node = getBloodNode(index);
	if(index == 1)then
		data = m_playerData;
	else
		data = m_enemyData;
	end
	if(data.hp > data.hpMax)then
		data.hp = data.hpMax;
	end
	local isFlip = node:getFlipX();
	local rate = data.hp/data.hpMax;
	local reduce = (1 - rate)*m_bloodWidth;
	if(isFlip) then
		node:setClipX(m_bloodWidth - reduce);
	else
		node:setClipX(-m_bloodWidth + reduce);
	end
end

function getBloodNode(index)
	if(index == 1) then
		return m_bloodNodePlayer;	
	else
		return m_bloodNodeEnemy;
	end
end

function getDefenser(attacker)
	if(attacker ==1) then
		return 2;
	else
		return 1;
	end
end

function getPortrait(index)
	if(index ==1) then
		return m_portraitPlayer;
	else
		return m_portraitEnemy;
	end
end

function relive(attacker)
	local defenser = getDefenser(attacker);
	local defNode = getBloodNode(defenser);
	local isFlip = defNode:getFlipX();
	if(isFlip) then
		defNode:setClipX(m_bloodNodePlayer:getImgSize().width);
	else
		defNode:setClipX(-m_bloodNodePlayer:getImgSize().width);
	end
end

function setDefaultPortrait(attacker)
	local atkPortrait = getPortrait(attacker);
	local isFlip = atkPortrait:isFlipX();
	if(isFlip)then
		atkPortrait:setPositionX(m_progressEnemy:getContentSize().width/2 + m_progressEnemy:getPositionX() - m_portraitOffsetX);
		m_tickerEnemy = 0;
	else
		atkPortrait:setPositionX(m_progressPlayer:getPositionX() - m_progressPlayer:getContentSize().width/2 + m_portraitOffsetX);
		m_tickerPlayer = 0;
	end
end

function setDefaultRoller()
	m_rollerPlayer:setPositionX(0);
	m_rollerEnemy:setPositionX(m_progressEnemy:getContentSize().width);
end

function setData(playerData, enemyData)
	m_playerData = playerData;
	m_enemyData = enemyData;
end

function close()
	m_round = 1;
	m_ticker = 0;
	m_tickerPlayer = 0;
	m_tickerEnemy = 0;
end

function addBuffIcon(attacker,buff,imgName)
	local node = m_leftBuffNode;
	local list = m_leftBuffList;
	local image = CCSprite:create(PATH_RES_IMG_ICON .. "buff_" .. imgName);
	if(attacker == 2)then
		node = m_rightBuffNode;
		list = m_rightBuffList;
		image:setAnchorPoint(ccp(1,1));
		local len = list:Length();
    	image:setPositionX(0-(len)*(image:getContentSize().width+10));
    else
    	image:setAnchorPoint(ccp(0,1));
		local len = list:Length();
    	image:setPositionX(0+(len)*(image:getContentSize().width+10));
	end
    
    local object = {};
    object.obj = image;
    object.x = image:getPositionX();
    object.y = image:getPositionY();
    list:addObject(object);
    image:setTag(buff);
    node:addChild(image);
end

function removeBuffIcon(attacker,buff)
	local node = m_leftBuffNode;
	local list = m_leftBuffList;
	if(attacker == 2)then
		node = m_rightBuffNode;
		list = m_rightBuffList;
	end

	local temp = list;
    local tempobj = nil;
    local headObj = nil;
    while temp:hasNext() do
        local obj = temp:nextObj();
        if(obj.obj.obj:getTag() == buff)then
            tempobj = obj;
            headObj = temp;
            break;
        end
        temp = obj;
    end
    if(tempobj == nil)then
    	return;
    end
    local temp1 = tempobj;
    while temp1:hasNext() do
        local objj = temp1:nextObj();
        objj.obj.x = temp1.obj.obj:getPositionX();
        temp1 = objj;
    end
    temp1 = tempobj;
    while temp1:hasNext() do
        local obj = temp1:nextObj();
        obj.obj.obj:setPositionX(obj.obj.x);
        temp1 = obj;
    end
    list:removeObject(tempobj);
    tempobj.obj.obj:removeFromParentAndCleanup(true);
end

function updateRound()
	m_round = m_round + 1;
	m_label:setStringValue(tostring(m_round));
end

