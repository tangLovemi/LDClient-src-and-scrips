module("ShopTimeRefresh", package.seeall)


--执行神秘商店时间刷新

local m_second = 0;
local m_minute = 0;
local m_hour = 0;
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_countDown_schedule = nil; -- 倒计时定时器
local m_delegate = nil;


--格式化时间
local function timeFormat()
    m_hour = m_hour .. "";
    m_minute = m_minute .. "";
    m_second = m_second .. "";
    if(string.len(m_hour) == 1) then
        m_hour = "0" .. m_hour;
    end
    if(string.len(m_minute) == 1) then
        m_minute = "0" .. m_minute;
    end
    if(string.len(m_second) == 1) then
        m_second = "0" .. m_second;
    end
end

--初始化时间
local function initTime()
    m_hour = 2;
    m_minute = 0;
    m_second = 0;
    timeFormat();
end

function getRefreshTime()
    timeFormat();
    return m_hour .. ":" .. m_minute .. ":" .. m_second;
end

--刷新MysteryShop的时间
local function refreshTimeLabel()
	ShopRefreshUI.refreshTimeLabel(getRefreshTime());
end

--判断时间刷新界面是否是神秘商店
local function isMysteryShopOpen()
    return ( ShopRefreshUI.isOpen() and (ShopRefreshUI.getShopId() == SHOP_MYSTERY) );
end

local function isShopRefreshUIOpen()
    return ShopRefreshUI.isOpen();
end

--更改神秘商店物品数据，刷新物品显示
local function refreshGoods()
	MysteryShopGoods.refreshData();
end


--停止计时器
function stopUpdate()
    if (m_countDown_schedule ~= nil) then  
        m_scheduler:unscheduleScriptEntry(m_countDown_schedule)  
        m_countDown_schedule = nil;
        m_hour = 0;
        m_minute = 0;
        m_second = 0;
    end 
end

--倒计时更新时间
local function coutDownUpdate()
    m_second = m_second - 1;
    if (m_second == -1) then
         if (m_minute ~= -1 or m_hour ~= -1) then  
            m_minute = m_minute-1  
            m_second = 59  
            if (m_minute == -1) then  
                if (m_hour ~= -1) then  
                    m_hour = m_hour-1  
                    m_minute = 59  
                    if (m_hour == -1) then
                    	--时间到，请求刷新
                        _G[m_delegate].sendRefreshRequest(MYSTERY_NO_MONEY_REFRESH);
                        stopUpdate();
                    end  
                end  
            end  
        end 
    end

    if(isShopRefreshUIOpen()) then
        refreshTimeLabel();
    end
end

--开启计时器
function startUpdate()
    if(not m_countDown_schedule) then
        m_countDown_schedule = m_scheduler:scheduleScriptFunc(coutDownUpdate, 1, false);
    end
end

--从服务器获得需要的数据
function receiveTimeFromServer( messageData )
    --确定到点刷新的位置
    if(messageData.id == SHOP_MYS_TIME) then
        m_delegate = "MysteryShopGoods";
    elseif(messageData.id == SHOP_EXC_TIME) then
        m_delegate = "ExchangeShopGoods";
    end
    m_hour = messageData.hor;
    m_minute = messageData.min;
    m_second = messageData.sec;
    refreshTimeLabel();
    --更新时间
    startUpdate();
end