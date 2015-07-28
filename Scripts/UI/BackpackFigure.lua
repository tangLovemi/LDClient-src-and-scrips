module ("BackpackFigure", package.seeall)

--背包、人物界面 (铁匠铺、灵魂炼化复用)

local m_curTag1 = TAG_EQUIP;
local m_curTag2 = TAG_EQUIP;
local m_horTabPos = ccp(510, 575);
local m_delegate = nil;
local m_isCreate = false;
local m_isOpen   = false;

--1人物 2背包
local pagePos = {
    ccp(980, 455),
    ccp(980, 455),
}

--1人物 2背包
local entityPos = {
    ccp(583, 27),
    ccp(585, 27),
}

local function changeUIByPageId( tag )
    m_curTag1 = tag;

    local status = {false, false};
	if(m_curTag1 == TAG_EQUIP) then
        m_curTag2 = TAG_EQUIP;
		Figure.close();
        GoodsList.open(m_curTag2);
        GoodsList.onBackpackTabPageChanged(m_curTag2);
        status[2] = true;
        BackpackFigurePage.setPosition(pagePos[2]);
	elseif(m_curTag1 == TAG_FIGURE) then
		GoodsList.close();
		Figure.open();
        status[1] = true;
        BackpackFigurePage.setPosition(pagePos[1]);
	end
    BackpackFigurePage.setDislpayName(status);
end

function tabPage1Callback( sender )
    local tag = sender:getTag();
     if(tag ~= m_curTag1) then
        changeUIByPageId(tag);

        if(m_delegate) then
            _G[m_delegate].onFigureBackpackPageChanged(m_curTag1);
        end
    end
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;

        GoodsList.create();
        Figure.create();
        BackpackFigurePage.create();
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;

        GoodsList.remove();
        Figure.remove();
        BackpackFigurePage.remove();
    end
end

function open(delegate)
    if(delegate) then
        m_delegate = delegate;
    end
	m_curTag1 = TAG_FIGURE;
    m_curTag2 = TAG_EQUIP;
    GoodsList.setDelegate(delegate);
    GoodsList.setName("");
    GoodsList.setPosition(entityPos[2]);

    Figure.open();
	Figure.setPosition(entityPos[1]);
    Figure.setDelegate(delegate);
    Figure.setAllEquipIconsEnabled(true);
    Figure.createAnimation();

    BackpackFigurePage.open({true, false});
    BackpackFigurePage.setPosition(pagePos[1]);
    BackpackFigurePage.setTabTag(TAG_FIGURE, TAG_EQUIP);
    BackpackFigurePage.setCallBack(tabPage1Callback, tabPage1Callback);
end

function close()
	GoodsList.close();
    Figure.close();
    Figure.removeAnimation();
    BackpackFigurePage.close();
end

