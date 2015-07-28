require "Scripts/Const/ConstDefine"
require "Scripts/Const/PathDefine"
require "Scripts/Const/ImgPathDefine"
require "Scripts/GameManager"
require "Scripts/Cocos2d/json"
require "System/Language"
require "Scripts/Update/UpdateScene"

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 200)
    collectgarbage("setstepmul", 6000)

    GameManager.initGame();
end

xpcall(main, __G__TRACKBACK__)
