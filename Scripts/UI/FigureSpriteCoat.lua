module ("FigureSpriteCoat", package.seeall)

--人物/精灵武器/衣柜  (精灵培育室)

local m_curTag1;
local m_curTag2;
local m_lastTag;

local m_horTabPos = ccp(550, 471);
local m_delegate = nil;


local function changeUIByPageId( tag )
    BackpackFigurePage.changeTexture(m_curTag1, false);
    m_lastTag = m_curTag1;
    m_curTag1 = tag;
    BackpackFigurePage.changeTexture(m_curTag1, true);
	if(m_curTag1 == TAG_3_WEAP) then --精灵武器
        m_curTag2 = TAG_31_SPRITE;
        if(m_lastTag == TAG_FIGURE) then
            Figure.close();
            GoodsList.open(m_curTag2);
        end
		RadioTabFour.setTabEnabled(true, false, false);
        RadioTabFour.setDislpayName("精灵");
        RadioTabFour.setTabTag(TAG_31_SPRITE);
        RadioTabFour.changeTexture(m_curTag2, true);
    elseif(m_curTag1 == TAG_2_COAT) then --衣柜
        m_curTag2 = TAG_21_COAT;
        if(m_lastTag == TAG_FIGURE) then
            Figure.close();
            GoodsList.open(m_curTag2);
        end
        RadioTabFour.setTabEnabled(true, true, false);
        RadioTabFour.setDislpayName("外套", "碎片");
        RadioTabFour.setTabTag(TAG_21_COAT, TAG_22_PIECE);
        RadioTabFour.changeTexture(m_curTag2, true);
	elseif(m_curTag1 == TAG_FIGURE) then --人物
		GoodsList.close();
		Figure.open();
		RadioTabFour.setAllEnabled(false);
	end
end

local function tabPage1Callback( sender )
    local tag = sender:getTag();
     if(tag ~= m_curTag1) then
        changeUIByPageId(tag);
        GoodsList.onBackpackTabPageChanged(m_curTag2);

        _G[m_delegate].onRightTab1Click(m_curTag1);
    end
end

local function tabPage2Callback( sender )
    local tag = sender:getTag();
    if(tag ~= m_curTag2) then
        RadioTabFour.changeTexture(m_curTag2, false);
        m_curTag2 = tag;
        RadioTabFour.changeTexture(m_curTag2, true);
        GoodsList.onBackpackTabPageChanged(m_curTag2);

        _G[m_delegate].onRightTab2Click(m_curTag2);
    end
end

function open(delegate)
	m_curTag1 = TAG_FIGURE;
    m_curTag2 = TAG_31_SPRITE;
    m_lastTag = m_curTag1;

    if(delegate) then
        m_delegate = delegate;
    end

    GoodsList.setDelegate(delegate);
    GoodsList.setName("");

    Figure.open();
	Figure.setPosition(POS_RIGHT);
    Figure.setDelegate(delegate);
    Figure.setAllEquipIconsEnabled(true);

    BackpackFigurePage.open("人物", "精灵武器", "衣柜");
    BackpackFigurePage.setPosition(m_horTabPos);
    BackpackFigurePage.setTabEnabled(true, true, true);
    BackpackFigurePage.setTabTag(TAG_FIGURE, TAG_3_WEAP, TAG_2_COAT);
    BackpackFigurePage.setCallBack(tabPage1Callback, tabPage1Callback, tabPage1Callback);
    BackpackFigurePage.changeAllTexture(m_normalTexture);
    BackpackFigurePage.changeTexture(TAG_FIGURE, true);

    RadioTabFour.open("精灵");
    RadioTabFour.setTabTag(TAG_31_SPRITE);
    RadioTabFour.setCallBack(tabPage2Callback, tabPage2Callback, tabPage2Callback, tabPage2Callback);
    RadioTabFour.changeAllTexture(m_normalTexture);
    RadioTabFour.changeTexture(m_curTag2, false);
    RadioTabFour.setAllEnabled(false);
end

function close()
	GoodsList.close();
    Figure.close();
    BackpackFigurePage.close();
    RadioTabFour.close();
end

