module("MiniMap", package.seeall)

local REAL_RANGE = 0.9

local m_textureCache = CCTextureCache:sharedTextureCache();

local m_rootNode    = nil;
local m_mapBG       = nil;
local m_mapSize     = nil;
local m_textureName = nil;
local m_mapPoint    = nil;

function setMapImage(index)
    local name = PATH_RES_IMG_MAP .. "map_" .. index .. ".png";
    local texture = m_textureCache:addImage(name);
    local size = m_mapBG:setTextureAutoResize(texture);
    m_textureCache:removeTextureForKey(m_textureName);
    m_textureName = name;
    m_mapSize.width, m_mapSize.height = size.width, size.height;
end

function setPosition(posX, posY)
    m_mapPoint:setPositionX((posX * REAL_RANGE - 0.5) * m_mapSize.width);
    if (posY) then
        m_mapPoint:setPositionY(-m_mapSize.height / 2);
    end
end

function movePoint(distance, time)
    distance = distance * (m_mapSize.width * REAL_RANGE);
    local action = CCMoveBy:create(time, CCPoint(distance, 0));
    m_mapPoint:runAction(action);
end

local function init()
    m_mapSize = {width = 0, height = 0};
    m_mapBG:setPosition(CCPoint(m_mapSize.width, m_mapSize.height));
    m_mapBG:setAnchorPoint(CCPoint(1, 1));
    m_mapPoint:setPositionY(-m_mapSize.height / 2);
end

function create()
    m_rootNode = CCNode:create();
    m_mapBG = CCSprite:create();
    m_mapPoint = CCSprite:create(PATH_RES_IMG_MAP .. "point.png");
    m_rootNode:addChild(m_mapBG, 0);
    m_rootNode:addChild(m_mapPoint, 1);
    init();
    return m_rootNode;
end

function remove()
    m_mapBG:removeFromParentAndCleanup(true);
    m_mapPoint:removeFromParentAndCleanup(true);
    m_textureCache:removeTextureForKey(m_textureName);
    m_textureCache:removeTextureForKey(PATH_RES_IMG_MAP .. "point.png");
    m_textureName = nil;
    m_mapBG = nil;
    m_mapPoint = nil;
end

function isPointInRect(x, y)
    return (x > (SCREEN_WIDTH - m_mapSize.width) and y > (SCREEN_HEIGHT - m_mapSize.height));
end