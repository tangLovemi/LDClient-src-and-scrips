module("Smelter", package.seeall)

require "UI/Background"
require "UI/BackpackFigure"
---------------------------------------------------------
--                    熔炼房界面
---------------------------------------------------------

local m_isOpen = false;
local m_rootLayer = nil; --根节点
local m_layout = nil;

local m_curTag = nil; --标志当前背包是哪个标签下
local m_curIndex = nil; --标志当前选中的物品
local m_dataName = {"WeapData", "CoatData", "EquipsData"};

local icon_blank = "";

----------------处理代理回调---------------------
local function refreshDetails()
	local iconImg = tolua.cast(m_layout:getWidgetByName("icon_img"), "ImageView");
	local nameLabel = tolua.cast(m_layout:getWidgetByName("name_label"), "Label");
	iconImg:loadTexture(icon_blank);
	nameLabel:setText("");
end

local function showGoodsDetails( index )
	if(index == 0) then
		refreshDetails();
	else 
		local iconImg = tolua.cast(m_layout:getWidgetByName("icon_img"), "ImageView");
		local nameLabel = tolua.cast(m_layout:getWidgetByName("name_label"), "Label");
		local id = _G[m_dataName[m_curTag]].getBackpackDataItemByIndex(index, "id");
		local icon = GoodsData.getGoodsPath(id, m_curTag);
		local name = _G[m_dataName[m_curTag]].getBackpackDataItemByIndex(index, "name");
		iconImg:loadTexture(icon);
		nameLabel:setText(name);
	end
end

--处理BackpaList点击标签页回调
function tabPageOnClick( pageTag )
    m_curTag = pageTag;
    m_curIndex = 0;
    showGoodsDetails(0);
end

--处理BackpaList点击物品项回调
function goodsOnClick( index, tag )
	-- if(m_curTag == WEAP_TAG and SpriteEggData.getBackpackCount() > 0 and index == 1) then
 --        m_curIndex = 0;
 --    elseif(m_curTag == WEAP_TAG and SpriteEggData.getBackpackCount() > 0 and index > 1) then
	-- 	m_curIndex = index - 1;
	-- else
	-- 	m_curIndex = index;
	-- end
 --    showGoodsDetails(m_curIndex);
 	print(" 熔炼房 物品 tag = " .. tag .. "  ,index = " .. index);
end

--点击人物面板装备回调
function figureIconOnClick( index )
    print("熔炼房 人物 " .. index);
end

-------------------功能处理------------------------

--点击熔炼按钮
local function smelterBtnOnClick(sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
        if(m_curIndex ~= 0) then
       		CCLuaLog("点击熔炼按钮");
        end
    end
end

--设置背包UI界面一部分控件是否可用
local function setBackpackListUIEnable()
	BackpackList.setGotoOtherUIEnable(false);
	BackpackList.setExpandBtnEnable(false);
   	BackpackList.setTabPageAllEnable(true);
   	BackpackList.setTabPageEnabled(PROPS_TAG, false);
   	BackpackList.setTabPageEnabled(MISSION_TAG, false);
end

function create()
	m_rootLayer = CCLayer:create();
	-- m_rootLayer:retain();

	m_layout = TouchGroup:create();
	local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Smelter.json");
	m_layout:addWidget(panel);
	m_layout:setPosition(ccp(161, 66));

	local smelterBtn = tolua.cast(m_layout:getWidgetByName("smelter_btn"), "Button");
	smelterBtn:addTouchEventListener(smelterBtnOnClick);

	m_rootLayer:addChild(m_layout, 1);
end

function open()
	if (not m_isOpen) then
		create();
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);
        -- BackpackList.open("Smelter");
        BackpackFigure.open("Smelter");
        m_curTag = EQUIPS_TAG;
        m_curIndex = 0;

        -- setBackpackListUIEnable(false);
        Background.create("Smelter");
        Background.open();
	end
end

function close()
	if (m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
        -- BackpackList.close();
        BackpackFigure.close();
        Background.close();
        Background.remove();
    end
end

function remove()
	if(m_rootLayer) then
        m_rootLayer:removeAllChildrenWithCleanup(true);
    end
    m_rootLayer = nil;
    m_layout = nil;
    m_curTag = nil;
    m_curIndex = nil;
end