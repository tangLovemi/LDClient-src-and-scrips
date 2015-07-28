module("GoodsDetails", package.seeall)

local m_panel = nil;
local m_equipPanel = nil;
local m_descPanel = nil;
local m_equipsize = nil;
local m_descsize = nil;


local function showEquipDetails( goodid )
	local baseInfo = GoodsManager.getBaseInfo(goodid);
	local levelLabel = tolua.cast(m_panel:getWidgetByName("level_label"), "Label");
	local nameLabel = tolua.cast(m_panel:getWidgetByName("name_label"), "Label");
	local typeNameLabel = tolua.cast(m_panel:getWidgetByName("leibie_label"), "Label");
	-- local pro2CountLabel = tolua.cast(m_panel:getWidgetByName("tiaoshu_label"), "Label");--额外属性条数
	local iconImg = tolua.cast(m_panel:getWidgetByName("icon_img"), "ImageView");
	local bgIconImg = tolua.cast(m_panel:getWidgetByName("bgIcon_img"), "ImageView");
	local descLabel = tolua.cast(m_panel:getWidgetByName("desc_label"), "Label");
	levelLabel:setText(baseInfo.level);
	nameLabel:setText(baseInfo.name);
	-- pro2CountLabel:setText(EquipmentCalc.getAddtionProCount(baseInfo.color));
	iconImg:loadTexture(baseInfo.icon);
	bgIconImg:loadTexture(baseInfo.frameIcon);
	descLabel:setText(baseInfo.desc);

	local data = nil;
	if(GoodsManager.isGrowEquip(goodid)) then
		typeNameLabel:setText("成长");
		data = EquipmentCalc.calcGrowEquip(goodid, EquipmentCalc.getMinStepLV(goodid), EquipmentCalc.getMinLV());
	else
		typeNameLabel:setText("普通");
		data = EquipmentCalc.calcNormalEquip(goodid, EquipmentCalc.getMinLV());
	end

	if(data ~= nil) then
		local ids = data.ids;
		local vals = data.vals;
		for i=1,2 do
			local proNameLabel = tolua.cast(m_panel:getWidgetByName("shuxing" .. i .. "_label"), "Label");
			local proValueLabel = tolua.cast(m_panel:getWidgetByName("zhi" .. i .. "_label"), "Label");
			proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. ids[i], "name"));
			proValueLabel:setText(vals[i]);
		end
	end
end

local function showGoodsDetails( goodid )
	local baseInfo = GoodsManager.getBaseInfo(goodid);
	local nameLabel = tolua.cast(m_panel:getWidgetByName("name_label"), "Label");
	local typeNameLabel = tolua.cast(m_panel:getWidgetByName("leibie_label"), "Label");
	local descLabel = tolua.cast(m_panel:getWidgetByName("miaoshu_label"), "Label");
	nameLabel:setText(baseInfo.name);
	typeNameLabel:setText(baseInfo.type);
	descLabel:setText(baseInfo.desc);
end

function onTouchBegin( node, goodid, type, isWish )
	if(m_equipPanel == nil) then
		m_equipPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "xiangxikuang_2_1.json");
		m_equipPanel:retain();
		-- m_equipsize = CCSize(m_equipPanel:getContentSize().width, m_equipPanel:getContentSize().height);
		m_equipsize = m_equipPanel:getContentSize();
	end
	if(m_descPanel == nil) then
		m_descPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "xiangxikuang_1_1.json");
		m_descPanel:retain();
		-- m_descsize = CCSize(m_descPanel:getContentSize().width, m_descPanel:getContentSize().height);
		m_descsize = m_descPanel:getContentSize();
	end

	if(m_panel) then
		onTouchEnd();
	end

 	local highType = GoodsManager.getGoodsHighName(goodid);
-- equip
-- piece
-- coat
-- weapon
-- piece
-- other
-- self
-- ancient_nornal
 	if(highType ~= "self") then
	 	m_panel = TouchGroup:create();
	 	if(highType == "equip") then
	 		local panel = m_equipPanel:clone();
			m_panel:addWidget(panel);
			showEquipDetails(goodid);
	 	else
	 		local panel = m_descPanel:clone();
			m_panel:addWidget(panel);
			showGoodsDetails(goodid);
	 	end
		local point = node:getParent():convertToWorldSpaceAR(ccp(node:getPositionX(), node:getPositionY()));
		local size = node:getContentSize();
		if(type ~= nil and type == 1) then
			if(isWish) then
				m_panel:setPosition(ccp(point.x - m_descsize.width/2, point.y + size.width/2 + 40));
			else
				m_panel:setPosition(ccp(point.x - m_descsize.width/2, point.y + size.width/2));
			end
		else
			m_panel:setPosition(ccp(point.x - (m_descsize.width - size.width)/2, point.y + size.width));
		end
		getGameLayer(SCENE_UI_LAYER):addChild(m_panel, 50);
 	end
end


function onTouchEnd()
	if(m_panel) then
		m_panel:removeFromParentAndCleanup(true);
		m_panel = nil;
	end
end