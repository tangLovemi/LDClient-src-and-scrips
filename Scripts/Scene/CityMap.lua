module("CityMap", package.seeall)

local REAL_RANGE = 0.9

local m_textureCache = CCTextureCache:sharedTextureCache();

local m_rootNode    = nil;
local m_mapBG       = nil;
local m_mapSize     = nil;
local m_textureName = nil;
local m_mapPoint    = nil;

function setPositionX(posX)
    m_mapPoint:setPositionX(posX * m_mapSize.width * REAL_RANGE);
end

function setPositionY(posY)
    m_mapPoint:setPositionX((posY - 0.5) * REAL_RANGE * m_mapSize.height);
end

local function init()
    m_textureName = PATH_RES_IMG_MAP .. "map_all.png";
    m_mapBG = CCSprite:create(m_textureName);
    m_mapPoint = CCSprite:create(PATH_RES_IMG_MAP .. "point_big.png");
    local size = m_mapBG:getContentSize();
    m_mapSize = {width = size.width, height = size.height};
end

function open()
    m_rootNode:setVisible(true);
end

function close()
    m_rootNode:setVisible(false);
end

function create()
    init();
    m_rootNode = CCNode:create();
    m_rootNode:addChild(m_mapBG, 0);
    m_rootNode:addChild(m_mapPoint, 1);
    return m_rootNode;
end

function remove()
    m_mapBG:removeFromParentAndCleanup(true);
    m_mapPoint:removeFromParentAndCleanup(true);
    m_textureCache:removeTextureForKey(m_textureName);
    m_textureCache:removeTextureForKey(PATH_RES_IMG_MAP .. "point_big.png");
    m_textureName = nil;
    m_mapBG = nil;
    m_mapPoint = nil;
end