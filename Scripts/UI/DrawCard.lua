module("DrawCard", package.seeall)

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate = false;
local m_isOpen = false;

function create()
	-- if(not m_isCreate) then
	-- 	m_isCreate = true;
	-- end

	local card = CCSprite:create(PATH_CCS_RES .. "DTFX_7_3.png");
	card:setPosition(ccp(500, 400));
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(card, CONFIRM_ZORDER);
    local n = 0;
	local function actionEnd()
		n = n + 1;
		local p = "";
		if(n%2 == 0) then
			p = PATH_CCS_RES .. "DTFX_7_6.png";
		else
			p = PATH_CCS_RES .. "DTFX_7_3.png"
		end

		local texture = CCTextureCache:sharedTextureCache():addImage(p);
		card:setTexture(texture);
	end

	local arr = CCArray:create();
	arr:addObject(CCOrbitCamera:create(0.1 , 1 , 0 , 0 , 90 , 0, 0)); --z方向在1秒內，以半径1，从0度增加90度
	arr:addObject(CCCallFunc:create(function() actionEnd() end));
	arr:addObject(CCOrbitCamera:create(0.2 , 1 , 0 , 90, 90 , 0, 0)); --z方向在1秒內，以半径1，从90度增加90度
	card:runAction(
		CCSequence:create(arr)
		);
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
	end
end