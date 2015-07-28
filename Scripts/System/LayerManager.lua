SCENE_MAIN_LAYER    = 1
SCENE_BATTLE_LAYER  = 2
SCENE_TOUCH_LAYER     = 3
SCENE_EFFECT_LAYER  = 4
SCENE_UI_LAYER   = 5
SCENE_GUIDE_LAYER   = 6
SCENE_LOGIN_LAYER   = 7;
SCENE_BROADCAST_LAYER   = 8;--broadcast
SCENE_LOADING_LAYER = 9
SCENE_TOP_LAYER = 10

local s_scene = nil;

function createGameLayers(scene)
    s_scene = scene;
    local mainLayer = CCLayer:create();
    local battleLayer = CCLayer:create();
    local uiLayer = CCLayer:create();
    local effectLayer = CCLayer:create();
    local loading = CCLayer:create();
    local guideLayer = CCLayer:create();
    local loginLayer = CCLayer:create();
    local broadcastLayer = CCLayer:create();
    local topLayer = CCLayer:create();
    scene:addChild(mainLayer, 1, SCENE_MAIN_LAYER);
    scene:addChild(battleLayer, 2, SCENE_BATTLE_LAYER);
    scene:addChild(uiLayer, 3, SCENE_UI_LAYER);
    scene:addChild(effectLayer, 4, SCENE_EFFECT_LAYER);
    scene:addChild(loading, 9, SCENE_LOADING_LAYER);
    scene:addChild(guideLayer, 5, SCENE_GUIDE_LAYER);
    scene:addChild(loginLayer, 6, SCENE_LOGIN_LAYER)
    scene:addChild(broadcastLayer, 8, SCENE_BROADCAST_LAYER)
    scene:addChild(topLayer, 10, SCENE_TOP_LAYER)
end

function getGameLayer(tag)
    local layer = s_scene:getChildByTag(tag);
    return tolua.cast(layer, "CCLayer");
end

function addGameLayer(child, z, tag)
    s_scene:addChild(tolua.cast(child, "CCNode"), z, tag);
end