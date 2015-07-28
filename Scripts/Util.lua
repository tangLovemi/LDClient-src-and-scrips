module("Util", package.seeall)


--显示操作结果提示
function showOperateResultPrompt( text ,tempNode)
    if(text and text ~= "") then
        local to = nil;
        local TIME = 1;
        to = Toast:getInstance();
        local isF = to:isFirst();
        if(isF) then
            local uiLayer = getGameLayer(SCENE_UI_LAYER);
            uiLayer:addChild(to, CONFIRM_ZORDER);
        end
        if tempNode~= nil then 
            to:showWithNode( text, TIME, SCREEN_WIDTH_HALF, SCREEN_HEIGHT_HALF,tempNode);
            return
        end 
        to:show( text, TIME, SCREEN_WIDTH_HALF, SCREEN_HEIGHT_HALF);
    end
end

--深度复制一个表
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
--字符串分割，szSeparator为分隔符( 返回的表中数据都是字符串)
function Split(szFullString, szSeparator)  
    local nFindStartIndex = 1  
    local nSplitIndex = 1  
    local nSplitArray = {}  
    while true do  
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
        if not nFindLastIndex then  
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
            break  
       end  
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
       nSplitIndex = nSplitIndex + 1  
    end
    return nSplitArray  
end

function strToNumber(strTable)
    local newTable = {};
    for i = 1,#strTable do
        newTable[i] = tonumber(strTable[i]);
    end
    return newTable;
end

function tableToStrBySeparator( t, szSeparator )
    local str = "";

    for i=1,#t do
        if(i ~= #t) then
            str = str .. t[i] .. szSeparator;
        else 
            str = str .. t[i];
        end
    end

    return str;
end
     
-----------------------------------------------
--以下方法为用时测试临时用，跟程序无关
local clock = nil; -- 模块用时测试
function initClock()
    clock = os.clock();
end

function printClock( id )
    CCLuaLog("***** clock " .. id .. "--> " .. (os.clock() - clock));
    clock = os.clock();
end
-----------------------------------------------


--判断表是否为空
function table_is_empty(t)
    return _G.next( t ) == nil
end


--随机 [1, n] 
function random(n)
    local param = tonumber(string.sub(os.clock() .. "", -3));
    math.randomseed(tostring(os.time() + param):reverse():sub(1, 6));
    return math.random(n);
end

--随机 [0, n] 
function random2(n)
    local param = tonumber(string.sub(os.clock() .. "", -3));
    math.randomseed(tostring(os.time() + param):reverse():sub(1, 6));
    return math.random(n + 1) - 1;
end

--随机count个[1，n]的数,可重复
function random3( count, n )
    local t = {};
    local param = tonumber(string.sub(os.clock() .. "", -3));
    for i=1,count do
        math.randomseed(tostring(os.time() + i*2 + param):reverse():sub(1, 6));
        table.insert(t, math.random(n));
    end
    return t;
end

--随机count个不同的[1, n]的数，不可重复
function randomNDiff( count, n )
    if(count > n) then
        return nil;
    end
    local param = tonumber(string.sub(os.clock() .. "", -3));
    print("**** param = " .. param);
    local p = 0;
    local t = {};
    while(#t < count) do
        p = p + 1;
        math.randomseed(tostring(os.time() + param + p*2):reverse():sub(1, 6));
        local num = math.random(n);
        local isHave = false;
        for i,v in ipairs(t) do
            if(v == num) then
                isHave = true;
                break;
            end
        end
        if(not isHave) then
            table.insert(t, num);
        end
    end
    return t;
end

function print_lua_table (lua_table, indent)
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print(formatting)
            print_lua_table(v, indent + 1)
            print(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting..szValue..",")
        end
    end
end
function getColorImgPath( colorid )
    return PATH_RES_IMAGE_HEAD_COLOR .. "color_" .. colorid .. ".png";
end

function getRemainder(a, b)
    return a - math.floor(a/b)*b;
end

function getHairImgPath(haieNum,hairColorNum)--获取发型图像路径
    return PATH_RES_IMAGE_HEAD_HAIR.."DTFX_"..(haieNum).."_"..(hairColorNum)..".png"
end
function getFaceImgPath(faceNum)--获取脸型图像路径
    return PATH_RES_IMAGE_HEAD_FACE.."DTTX_"..(faceNum)..".png"
end
function getCoatImgPath(coatNum)--获取外套拼图路径
    return PATH_RES_IMAGE_HEAD_COAT.."DTWT_"..(coatNum)..".png"
end
function getHeadImgPath ( haieNum,hairColorNum,faceNum,coatNum)--获取头像拼图路径
    local headImgPaths = {}
    headImgPaths["hairImg"] = PATH_RES_IMAGE_HEAD_HAIR.."DTFX_"..(haieNum).."_"..(hairColorNum)..".png"
    headImgPaths["faceImg"] = PATH_RES_IMAGE_HEAD_FACE.."DTTX_"..(faceNum)..".png"
    headImgPaths["coatImg"] = PATH_RES_IMAGE_HEAD_COAT.."DTWT_"..(coatNum)..".png"

    return headImgPaths
end


function createHeadNode(haieNum,hairColorNum,faceNum,coatNum)
    local baseNode = CCNode:create();
    baseNode:setAnchorPoint(CCPoint(0,0));

    local hairNode = CCSprite:create(getHairImgPath(haieNum,hairColorNum))
    local faceNode = CCSprite:create(getFaceImgPath(faceNum))
    
    if coatNum > 0 then
        local coatNode = CCSprite:create(getCoatImgPath(coatNum))       
        baseNode:addChild(coatNode)
    end   

    -- baseNode:addChild(coatNode)
    baseNode:addChild(faceNode)
    baseNode:addChild(hairNode)

    return baseNode
end

function createHeadLayout(haieNum,hairColorNum,faceNum,coatNum)
    local baseNode = Layout:create();
    baseNode:setAnchorPoint(CCPoint(0,0));

    local hairNode = ImageView:create();
    hairNode:loadTexture(getHairImgPath(haieNum,hairColorNum));
    hairNode:setAnchorPoint(CCPoint(0,0));
    local faceNode = ImageView:create()
    local facepath = getFaceImgPath(faceNum);
    faceNode:loadTexture(getFaceImgPath(faceNum));
    faceNode:setAnchorPoint(CCPoint(0,0));
    if coatNum~= nil then
        local coatNode = ImageView:create()   
        local coatpath = getCoatImgPath(coatNum);
        coatNode:loadTexture(getCoatImgPath(coatNum));    
        baseNode:addChild(coatNode)
        coatNode:setAnchorPoint(CCPoint(0,0));
    end   
    -- Layout:setContentSize(hairNode:getContentSize());
    -- baseNode:addChild(coatNode)
    baseNode:addChild(faceNode)
    baseNode:addChild(hairNode)

    return baseNode
end

local headW = 162;
local headH = 162;

function getHeadSize()
    return headW, headH;
end


function getSkillIconPath(id,isNormal)
    local path = nil;
    if(isNormal)then
        path = PATH_RES_IMAGE_SKILLS_NORMAL .. "skill_" .. id .. ".png";
    else
        path = PATH_RES_IMAGE_SKILLS_DISABLE .. "skill_" .. id .. ".png";
    end
    return path;
end

function getSkillIconByID(id,isNormal)
    local image = ImageView:create();
    image:loadTexture(getSkillIconPath(id,isNormal));
    return image;
end

--排序一个数字table
function bubble_sort(t)
    local exchange
    for i=1,(#t)-1 do
        exchange = false
        for j=1,(#t)-i do
            if t[j+1] < t[j] then
                t[j],t[j+1] = t[j+1],t[j]
                exchange = true
            end
        end
        if exchange == false then
            break
        end
    end
    return t;
end
