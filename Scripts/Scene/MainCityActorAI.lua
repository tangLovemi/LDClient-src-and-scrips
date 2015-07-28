module("MainCityActorAI", package.seeall)

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = -1;

local m_actors = nil;
local m_aiInfo = nil;

function init()
    m_actors = {};
    m_aiInfo = {};
end

function free()
    m_actors = nil;
    m_aiInfo = nil;
end

function addActor(actor, dt, range, rt)
    table.insert(m_actors, actor);
    table.insert(m_aiInfo, {dt = dt, range = range * 10, count = (dt + rt), pos = 0});
end

function delActor(index)
    table.remove(m_actors, index);
    table.remove(m_aiInfo, index);
end

local function setActorStand(actor)
    tolua.cast(actor, "SJActor"):setAction("stand", 1);
end

local function setActorBehavior(actor, behavior, angle, speed)
    if (angle ~= 0) then
        actor:rotateInterval(angle, speed);
        actor:setFlipX(angle < 0);
    end
    actor:setAction(behavior, 1);
    local actList = CCArray:create();
    actList:addObject(CCDelayTime:create(math.abs(angle / (speed * FPS))));
    actList:addObject(CCCallFuncN:create(setActorStand));
    actor:runAction(CCSequence:create(actList));
end

local function update(dt)
    math.randomseed(tostring(os.time()):reverse():sub(1, 10));
    for i, actor in ipairs(m_actors) do
        local info = m_aiInfo[i];
        info.count = info.count - 1;
        if (info.count <= 0) then
            info.count = info.dt;
            local angle = math.random(-info.range, info.range) / 10 - info.pos;
            setActorBehavior(actor, "run", angle, 0.2);
            info.pos = angle;
        end
    end
end

function runAI()
    m_schedulerEntry = m_scheduler:scheduleScriptFunc(update, 1, false);
end

function stopAI()
    if (m_schedulerEntry >= 0) then
        m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
        m_schedulerEntry = -1;
    end
end

-- function actorsRelateMove(angle)
--     for i, actor in ipairs(m_actors) do
--         local info = m_aiInfo[i];
--         info.count = info.count - 1;
--         info.pos = angle;
--         if(angle > 0)then

--         else
--             actor:
--         end
--     end

--         if(m_curPoint.x > SCREEN_WIDTH_HALF)then--右半屏
--         if(m_player:getRotation() > -2)then
--             m_player:setRotation(m_player:getRotation() - 0.1);
--         end

--         m_rootLayer:rotateScene(-NEAR_LAYER_MOVE_SP);
--         local dfd = m_rootLayer:getCurAngle();
--         local kkkjk = m_rootLayer:getSceneLength();
--         if(m_rootLayer:getCurAngle() ~= m_rootLayer:getSceneLength())then
--             m_midLayer:rotateScene(-tonumber(midspeed));
--             m_farLayer:rotateScene(-tonumber(farspeed));
--         end
--     else
--         if(m_player:getRotation() < 2)then
--             m_player:setRotation(m_player:getRotation() + 0.1);
--         end
--         m_rootLayer:rotateScene(NEAR_LAYER_MOVE_SP);
--         if(m_rootLayer:getCurAngle() ~= -m_rootLayer:getSceneLength())then
--             m_midLayer:rotateScene(tonumber(midspeed));
--             m_farLayer:rotateScene(tonumber(farspeed));
--         end
--     end
-- end
