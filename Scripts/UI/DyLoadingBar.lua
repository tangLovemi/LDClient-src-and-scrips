module("DyLoadingBar", package.seeall)

--动态进度条封装
--将指定进度条在某一段时间内增长到某比例，完成后调回调方法

local m_isCreate = false;
local m_loadingBar = nil;
local DEF_TIME = 1;
local m_time = DEF_TIME; --时间段单位s， 默认为1s
local m_perEnd = 0;
local m_callbackFun = nil;
local m_loadingcb = nil;

local m_curPer = 0;
local m_speed = 0; --单位 per/ss 每毫秒增长的百分比

local STATUS_RUN 	= 1;
local STATUS_PAUSE  = 2;
local STATUS_STOP   = 3;
local m_status = STATUS_STOP;

local function pause()
    m_status = STATUS_PAUSE;
    m_time = 0;
    m_perEnd = 0;
    m_curPer = 0;
    m_speed = 0;
    if(m_callbackFun) then
		m_callbackFun();
	end
end

local function update()
	if(m_status == STATUS_RUN) then
		m_curPer = math.min( 100, m_curPer + m_speed);
		if(m_loadingcb) then
			m_loadingcb(m_curPer);
		end
		-- print("********** m_curPer = " .. m_curPer);
		if(m_curPer >= m_perEnd) then
	    	m_loadingBar:setPercent(m_perEnd);
			pause();
		else
	    	m_loadingBar:setPercent(m_curPer);
		end
	end
end

function run( per, time, cb, loadingcb )
    m_callbackFun = nil;
	m_time = DEF_TIME; 
	if(time) then
		m_time = time;
	end
	if(loadingcb) then
		m_loadingcb = loadingcb;
	end
	m_perEnd = per;
	m_callbackFun = cb;
	perBegin = m_loadingBar:getPercent();
	m_curPer = perBegin;
	if(m_perEnd > perBegin) then
		m_status = STATUS_RUN;
		m_speed = (m_perEnd - perBegin)/m_time/10;
	else
		pause();
	end
end

function create(loadingBar )
	m_status = STATUS_STOP;
	m_loadingBar = loadingBar;
    local layer = getGameLayer(SCENE_LOGIN_LAYER);
    layer:scheduleUpdateWithPriorityLua(update, 0.1);
end

function remove()
    local layer = getGameLayer(SCENE_LOGIN_LAYER);
    layer:unscheduleUpdate();
	m_loadingBar = nil;
	m_time = 0;
	m_perEnd = 0;
	m_callbackFun = nil;

    m_status = STATUS_STOP;
	m_curPer = 0;
	m_speed = 0;
end