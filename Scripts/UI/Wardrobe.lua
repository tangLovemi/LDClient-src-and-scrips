module("Wardrobe", package.seeall)

--------------衣柜界面-----------------

local m_rootLayer = nil;
local m_rootLayout = nil;
local m_isCreate = false;
local m_isOpen = false;

local m_infoPanel = nil;
local m_beforeIndex = 0;

local COAT_COUNT = 19;

local SLV_TAG_BASE = 123;
local SPACE_BORDER = 0;
local SPACE = 0; --左右间隔
-- local PANEL_W = 292;--图片大小
-- local PANEL_H = 539;--图片大小
local PANEL_W = 429;--图片大小
local PANEL_H = 583;--图片大小

local SIZE_W = 1136; --可显示区域宽
local SIZE_H = 640;  --可显示区域高
local POS_X = 0;
local POS_Y = 60; --滑动框高度
local CENTER_SCALE = 0.9; --1/4位置的缩放系数

local SCALE_COE = 0;--缩放系数

local ITEM_Y = 0;

local def_offX = 0;
local NEW_OFFX = math.abs(def_offX + SIZE_W/2 - PANEL_W/2);

local m_scrollView = nil;
local m_isMoved = false;
local m_curIndex;

local m_lastOffX = 0;
local isLeft = true;
local SCALE_TIME = 0.3;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_countDown_schedule = nil; -- 倒计时定时器

local star_x = 0;

local m_statusKey = nil;
local STATUS = {
	HAVE_WEAR_SELF		= 0,
	HAVE_WEAR_OTHER		= 1,
	HAVE_NO_WEAR_ALL	= 2,
	NO_HAVE_PIECE_0		= 3,
	NO_HAVE_PIECE_1		= 4,
};
local STATUS_KEY = {
	HAVE_WEAR_SELF		= "HAVE_WEAR_SELF", 
	HAVE_WEAR_OTHER		= "HAVE_WEAR_OTHER",  --替换
	HAVE_NO_WEAR_ALL	= "HAVE_NO_WEAR_ALL", --装备
	NO_HAVE_PIECE_0		= "NO_HAVE_PIECE_0",  
	NO_HAVE_PIECE_1		= "NO_HAVE_PIECE_1",  --合成
};
local m_infoLayout = nil;


local SLV_W_1 = 1136;
local SLV_W_0 = 680;

local STATUS_NORMAL = 1;
local STATUS_INFO   = 2;
local m_status = STATUS_NORMAL;

local SPACE_NORMAL = -(PANEL_W*5 - SIZE_W)/4;
local SPACE_INFO = -(PANEL_W*5 - SLV_W_0)/4 + 30;
SPACE = SPACE_NORMAL;

local btnPos = {
	ccp(568, 37), -- STATUS_NORMAL
	ccp(324, 37), -- STATUS_INFO
};

local m_funcBtn_wear = nil;
local m_funcBtn_replace = nil;
local m_funcBtn_composite = nil;

local function checkCanUpStep( typeid )
	local data = getCoatDataByTypeid(typeid);
    local canStren = CoatCalc.canStren(data);
    local canUpstep = CoatCalc.canUpStep(data);
    if(canStren or canUpstep) then
    	if(isMaterailEnough(data)) then
    		return true;
    	end
    end
    return false;
end

------------------------------------------------------------

local function checkCanCompositeNotification()
	for i=1,COAT_COUNT do
		local typeid = DataTableManager.getValue("coat_pos", "id_" .. i, "type");
		local isHave, id = isCoatHave(typeid);
		if(not isHave) then
			--未解锁此外套
			local needCount, totalCount = getPieceCount(typeid);
			if(totalCount >= needCount) then
				--碎片足够
				return true;
			end
		end
	end
	return false;
end

local function checkCanUpstepNotification()
	for i=1,COAT_COUNT do
		local typeid = DataTableManager.getValue("coat_pos", "id_" .. i, "type");
		local isHave, id = isCoatHave(typeid);
		if(isHave) then
			--已解锁此外套
			if(checkCanUpStep(typeid)) then
				return true;
			end
		end
	end
	return false;
end

--上线检测提示
function checkNotification_login()
    if(checkCanCompositeNotification()) then
    	return true;
    end
    if(checkCanUpstepNotification()) then
    	return true;
    end
    return false;
end

function checkNotification_line()
    return checkNotification_login();
end

function checkNotification_close()
    return checkNotification_login();
end
------------------------------------------------------------

local function setSlvSizeAndPos( status )
	resetSlv(status);
end

--判断玩家是否获得此位置的外套
function isCoatHave( typeid )
	local coatDatas = UserInfoManager.getBackPackInfo("coat"); --已获得所有外套
	if(coatDatas[typeid] ~= nil) then
		return true, coatDatas[typeid].id;
	end
	return false;
end

function getCoatDataByTypeid( typeid )
	local coatDatas = UserInfoManager.getBackPackInfo("coat"); --已获得所有外套
	return coatDatas[typeid];
end

function getPieceCount( typeid )
	local pieceData = DataTableManager.getItemByKey("coatPieceData", "type", typeid);
	local pieceId = 0;
	local needCount = 0;
	local totalCount = 0;
	if(pieceData ~= nil) then
		pieceId = pieceData.id;
		needCount = pieceData.count;
	end
	
	if(pieceId > 0) then
		local pieces = UserInfoManager.getBackPackInfo("coatchip");
		for i,v in ipairs(pieces) do
			if(v.id == pieceId) then
				totalCount = v.count;
				break;
			end
		end
	end
	return needCount, totalCount;
end

local function getCurPieceIndex()
	local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
	local pieceData = DataTableManager.getItemByKey("coatPieceData", "type", typeid);
	local pieceId = pieceData.id;
	if(pieceId > 0) then
		local pieces = UserInfoManager.getBackPackInfo("coatchip");
		for i,v in ipairs(pieces) do
			if(v.id == pieceId) then
				return i;
			end
		end
	end
	return 0;		
end

local function setCurStatus()
	local wearedCoatType = UserInfoManager.getRoleInfo("coat").type;--装备上的外套在所有外套的索引
	local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
	local isHave = isCoatHave(typeid);
	if(isHave) then
		if(wearedCoatType > 0) then
			if(wearedCoatType == typeid) then
				m_statusKey = STATUS_KEY.HAVE_WEAR_SELF;
			else
				m_statusKey = STATUS_KEY.HAVE_WEAR_OTHER;
			end
		else
			m_statusKey = STATUS_KEY.HAVE_NO_WEAR_ALL;
		end
	else
		--碎片是否足够
		local needCount, totalCount = getPieceCount(typeid);
		if(totalCount >= needCount) then
			m_statusKey = STATUS_KEY.NO_HAVE_PIECE_1;
		else
			m_statusKey = STATUS_KEY.NO_HAVE_PIECE_0;
		end
	end		
end


local function setScaleAndZorder(isEnd)
	local offX = m_scrollView:getContentOffset().x;
	if(isEnd) then
		offX = def_offX - (m_curIndex - 1)*(SPACE + PANEL_W);
	end
	local container = m_scrollView:getContainer();

	local curPanel = tolua.cast(container:getChildByTag(m_curIndex + SLV_TAG_BASE), "Layout");
	local curImg = tolua.cast(curPanel:getChildByName("coatIcon"), "ImageView");
	local curX = curImg:getPositionX();

	for i=1,COAT_COUNT do
		local panel = tolua.cast(container:getChildByTag(i + SLV_TAG_BASE), "Layout");
		local img = tolua.cast(panel:getChildByName("coatIcon"), "ImageView");
		local index = 0;
		local posX = SIZE_W/2 - PANEL_W/2 + (PANEL_W + SPACE)*(i - 1);
		local d = math.abs(posX - (star_x + math.abs(offX)));
		local scale = 1 - d*SCALE_COE;
		if(scale < 0.4) then
			scale = 0.4;
		end
		img:setScale(scale);
		panel:setZOrder(COAT_COUNT - math.abs(i - m_curIndex));
		local animPanel = tolua.cast(panel:getChildByName("animPanel"), "Layout");
		if(animPanel) then
			animPanel:getNodeByTag(1):setScale(scale);
		end
	end
end

local function setBtnPos(status)
	m_funcBtn_wear:setPosition(btnPos[status]);
	m_funcBtn_replace:setPosition(btnPos[status]);
	m_funcBtn_composite:setPosition(btnPos[status]);
end

local function setBtnEnabled( enable )
	m_funcBtn_wear:setEnabled(enable);
	m_funcBtn_replace:setEnabled(enable);
	m_funcBtn_composite:setEnabled(enable);
end

local function setBtnTouchEnabled( enable )
	m_funcBtn_wear:setTouchEnabled(enable);
	m_funcBtn_replace:setTouchEnabled(enable);
	m_funcBtn_composite:setTouchEnabled(enable);
end

local function setBtnDisplay()
	setBtnPos(m_status);
	if(m_statusKey == STATUS_KEY.HAVE_WEAR_SELF) then
		setBtnEnabled( false );
	else
		if(m_status == STATUS_NORMAL) then
			if(m_statusKey == STATUS_KEY.NO_HAVE_PIECE_0) then
				setBtnEnabled(true);
				-- setBtnTouchEnabled(false);
			else
				setBtnEnabled(true);
				-- setBtnTouchEnabled(true);
			end
		elseif(m_status == STATUS_INFO) then
			local isWearOrReplace = m_statusKey == STATUS_KEY.HAVE_WEAR_OTHER or 
			m_statusKey == STATUS_KEY.HAVE_NO_WEAR_ALL;
			setBtnEnabled(isWearOrReplace);
			-- setBtnTouchEnabled(isWearOrReplace);
		end
	end

	if(m_statusKey == STATUS_KEY.HAVE_WEAR_OTHER) then
		 --替换
		m_funcBtn_replace:setEnabled(true);
		m_funcBtn_wear:setEnabled(false);
		m_funcBtn_composite:setEnabled(false);
	elseif(m_statusKey == STATUS_KEY.HAVE_NO_WEAR_ALL) then
		--装备
		m_funcBtn_wear:setEnabled(true);
		m_funcBtn_replace:setEnabled(false);
		m_funcBtn_composite:setEnabled(false);
	elseif(m_statusKey == STATUS_KEY.NO_HAVE_PIECE_1) then
		--合成
		m_funcBtn_composite:setEnabled(true);
		m_funcBtn_wear:setEnabled(false);
		m_funcBtn_replace:setEnabled(false);
	end
end

local function moveEnd()
	setScaleAndZorder(true);
	setCurStatus();
	setBtnDisplay();
	if(m_status == STATUS_INFO) then
		refreshDetails();
	end
end

local function setCurIndex()
	local offX = m_scrollView:getContentOffset().x;
	local diffX = math.abs(offX - def_offX);
	local index = -1;
	index = math.ceil(diffX/(SPACE + PANEL_W));

	if(m_curIndex ~= index) then
		m_curIndex = index;
		if(m_curIndex == 0) then
			m_curIndex = 1;
		end
	end
	if(isLeft) then
		if(m_curIndex < COAT_COUNT) then
			m_curIndex = m_curIndex + 1;
		end
	end
end

local function scrollViewDidScroll(desc, scrollView)
	setCurIndex();
	setScaleAndZorder(false);
    if(not m_scrollView:isDragging() and not m_scrollView:isTouchMoved()) then
    	if(m_isMoved == true) then
    		m_isMoved = false;
			m_scrollView:setContentOffsetWithNoDelegate(ccp(def_offX - (m_curIndex - 1)*(SPACE + PANEL_W), 0), true);
  			moveEnd();
  		end
  	else
  		local newOffX = m_scrollView:getContentOffset().x;
		isLeft = (newOffX < m_lastOffX);
  		m_lastOffX = newOffX;
  		if(m_isMoved == false) then
  			m_isMoved = true;
  		end
   	end
	-- print("******* m_curIndex = " .. m_curIndex);
end

-----------------------------详细信息-----------------------------------

local function closeInfoPanelOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		m_infoLayout:removeFromParentAndCleanup(false);
		-- local func_btn = tolua.cast(m_rootLayout:getWidgetByName("func_btn"), "Button");
		-- func_btn:setEnabled(true);
		-- setBtnDisplay();
		-- m_rootLayer:addChild(m_scrollView, 10);


	end
end

local function restoreNormal()
	m_status = STATUS_NORMAL;
	m_infoLayout:removeFromParentAndCleanup(false);
	setSlvSizeAndPos(STATUS_NORMAL);
	setBtnDisplay();
end

local m_upstepUse = nil;
--升阶材料点击
local function upstepGoodsOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_upstepUse ~= nil) then
	        local goodid = m_upstepUse[sender:getTag()].id;
	        if(GoodsManager.isAncient(goodid)) then
	        	UIManager.open("AncientMaterialItem",goodid);
	        else
	        	GoodsDetailsPanel.open(function() GoodsDetailsPanel.close(); end);
	        	if(GoodsManager.isCoatPiece(goodid)) then
	        		GoodsDetailsPanel.showPanel({id = goodid}, UPSTEP_GOODS_OTHER_POS, nil, 2);
	        	else
	        		GoodsDetailsPanel.showPanel({id = goodid}, UPSTEP_GOODS_OTHER_POS);
	        	end
	        end
		end
    end
end

--升阶材料是否足够
function isMaterailEnough( data )
	local upstepUse = CoatCalc.getUpstepUse(data);
	if(upstepUse ~= nil) then
		for i,v in ipairs(upstepUse) do
			local needN = v.count;
			local haveN = UserInfoManager.getGoodsCount(v.id);
			if(haveN < needN) then
				--材料不足
				return false;
			end
		end
		return true;
	end
	return false;
end

--升阶按钮
local function infoFuncOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
		local data = getCoatDataByTypeid(typeid);
	    local canStren = CoatCalc.canStren(data);
	    local canUpstep = CoatCalc.canUpStep(data);

		if(isMaterailEnough(data)) then
		    if(canStren) then
				ProgressRadial.open();
		    	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_COATSTRENGTHEN, {typeid});
	    	elseif(canUpstep) then
				ProgressRadial.open();
	    		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_COATUPSTEP, {typeid});
	    	else
	    		Util.showOperateResultPrompt("满级");
	    	end
		else
			Util.showOperateResultPrompt("材料不足");
		end
	end
end


--外套详细信息
function refreshDetails()
	local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
	local data = getCoatDataByTypeid(typeid);

	local iconColorImg = tolua.cast(m_infoLayout:getWidgetByName("iconKuang_img"), "ImageView");
	local iconImg = tolua.cast(m_infoLayout:getWidgetByName("icon_img"), "ImageView");
    local name_label = tolua.cast(m_infoLayout:getWidgetByName("name_label"), "Label");
    local lvLabel = tolua.cast(m_infoLayout:getWidgetByName("lv_AtlasLabel"), "LabelAtlas");
    local lvFlagImg = tolua.cast(m_infoLayout:getWidgetByName("lvFlagImg"), "ImageView");
    local desc_label = tolua.cast(m_infoLayout:getWidgetByName("story_label"), "Label");
	local infofunc_btn = tolua.cast(m_infoLayout:getWidgetByName("func_btn"), "Button");

    iconImg:loadTexture(GoodsManager.getCoatIconByCoatType(typeid));
    iconColorImg:loadTexture(GoodsManager.getColorBgImg(COLOR_WHITE));
    --名称
    local name = DataTableManager.getValue("coat_name", "id_" .. typeid, "name");
    name_label:setText(name);
    lvLabel:setEnabled(false);
    lvFlagImg:setEnabled(false);

    local desc = DataTableManager.getValue("coat_name", "id_" .. typeid, "desc");
    desc_label:setText(desc);

	infofunc_btn:setEnabled(true);
    local labelName = {"stren", "agility", "endurance"};
    for i,v in ipairs(labelName) do
        for j=1,4 do
            local valLabel1 = tolua.cast(m_infoLayout:getWidgetByName(v .. "_label_" .. j .. "_1"), "Label");
            valLabel1:setText("");
            local valLabel2 = tolua.cast(m_infoLayout:getWidgetByName(v .. "_label_" .. j .. "_2"), "Label");
            valLabel2:setText("");
        end
		tolua.cast(m_infoLayout:getWidgetByName("proImg_" .. i .. "_" .. 4), "ImageView"):setEnabled(true);
    end

    --材料初始化
    for i=1,4 do
    	m_infoLayout:getWidgetByName("cailiao_" .. i .. "_panel"):setEnabled(true);
    	local iconImg = tolua.cast(m_infoLayout:getWidgetByName("cailiao_" .. i .. "_img"), "ImageView");    	
    	local colorImg = tolua.cast(m_infoLayout:getWidgetByName("cailiaoColor_" .. i .. "_img"), "ImageView");
    	iconImg:loadTexture(PATH_CCS_RES .. "gy_wenhaobai.png");
    	colorImg:loadTexture(GoodsManager.getColorBgImg(COLOR_WHITE));
    	tolua.cast(m_infoLayout:getWidgetByName("have_label_" .. i), "Label"):setText("");
    	tolua.cast(m_infoLayout:getWidgetByName("need_label_" .. i), "Label"):setText("");
    	tolua.cast(m_infoLayout:getWidgetByName("xiexian_" .. i .. "_label"), "Label"):setText("");
    end


	if(data ~= nil) then
	    iconColorImg:loadTexture(GoodsManager.getColorBgImg(data.color));

    	name_label:setColor(COLOR_VALUE[data.color]);
	    --级别
	    if(data.lv > 1) then
    		lvLabel:setEnabled(true);
	    	lvFlagImg:setEnabled(true);
	    	lvFlagImg:loadTexture(GoodsManager.getPlusImgByColor(data.color));
	    	local numberImg, numberImg_W, numberImg_H = GoodsManager.getNumberImg_18(data.color);
	    	lvLabel:setProperty(data.lv - 1, numberImg, numberImg_W, numberImg_H, 0);
	    end
	    --属性对比
	    --当前属性
	    local dataName = {"strenPro", "agilityPro", "endurPro"};
	    local curData = CoatCalc.calcCoat(data.id, data.lv);
	    for i,v in ipairs(dataName) do
	    	local d = curData[v];
	    	for j=1,#d do
        		local proNameLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "Value_label_" .. j), "Label");
        		proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. d[j].proid, "name"));
        		local valLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "_label_" .. j .. "_1"), "Label");
                valLabel:setText(d[j].proval);
	    	end

	    	local addtionId = curData.addition[v].proid;
			tolua.cast(m_infoLayout:getWidgetByName("proImg_" .. i .. "_" .. 4), "ImageView"):setEnabled(addtionId > 0);
    		if(addtionId > 0) then
	    		local addtionValue = curData.addition[v].proval;
	    		local ddtionProNameLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "Value_label_" .. 4), "Label");
	    		ddtionProNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. addtionId, "name"));
	    		local addtionValueLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "_label_" .. 4 .. "_1"), "Label");
	            addtionValueLabel:setText(addtionValue);
    		end
	    end


	    --下一强化等级
	    for i,v in ipairs(labelName) do
	    	for j=1,4 do
	            local valLabel = tolua.cast(m_infoLayout:getWidgetByName(v .. "_label_" .. j .. "_2"), "Label");
	            valLabel:setText("");
	        end
	    end
	    local canStren = CoatCalc.canStren(data);
	    local canUpstep = CoatCalc.canUpStep(data);

        local nextData = nil;
	    if(canStren) then
	        nextData = CoatCalc.calcCoat_nextStrenlv(data);
	    elseif(canUpstep) then
	    	nextData = CoatCalc.calcCoat_nextSteplv(data);
	    end

	    if(nextData ~= nil) then
		    for i,v in ipairs(dataName) do
		    	local d = nextData[v];
		    	for j=1,#d do
	                local valLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "_label_" .. j .. "_2"), "Label");
	                valLabel:setText(d[j].proval);
		    	end
		    	local addtionId = curData.addition[v].proid;
		    	if(addtionId > 0) then
			    	local addtionValue = nextData.addition[v].proval;
		    		local addtionValueLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "_label_" .. 4 .. "_2"), "Label");
		            addtionValueLabel:setText(addtionValue);
		    	end
		    end
	    end

	    --升阶材料
	    --功能按钮
	    if(canStren == false and canUpstep == false) then
	    	m_infoLayout:getWidgetByName("cailiao_panel"):setEnabled(false);
	    	infofunc_btn:setEnabled(false);
	    else
	    	m_infoLayout:getWidgetByName("cailiao_panel"):setEnabled(true);
	    	m_upstepUse = CoatCalc.getUpstepUse(data);
			local MAX = 4; --最大消耗物品数量
			for i=1,MAX do
				if(i <= #m_upstepUse) then
					tolua.cast(m_infoLayout:getWidgetByName("cailiao_" .. i .. "_panel"), "Layout"):setEnabled(true);
					local id = m_upstepUse[i].id;
					local needCount = m_upstepUse[i].count;
					local haveN = UserInfoManager.getGoodsCount(id);           
					local needLabel = tolua.cast(m_infoLayout:getWidgetByName("need_label_" .. i), "Label");
					local haveLabel = tolua.cast(m_infoLayout:getWidgetByName("have_label_" .. i), "Label");
					local spaceLabel = tolua.cast(m_infoLayout:getWidgetByName("xiexian_" .. i .. "_label"), "Label");
					needLabel:setText(needCount);
					haveLabel:setText(haveN);
					spaceLabel:setText("/");
					if(haveN >= needCount) then
						haveLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
						needLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
						spaceLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
					else
						haveLabel:setColor(COLOR_VALUE[COLOR_RED]);
						needLabel:setColor(COLOR_VALUE[COLOR_RED]);
						spaceLabel:setColor(COLOR_VALUE[COLOR_RED]);
					end
					
					--消耗物品图标
					local iconImg = tolua.cast(m_infoLayout:getWidgetByName("cailiao_" .. i .. "_img"), "ImageView");
					local colorImg = tolua.cast(m_infoLayout:getWidgetByName("cailiaoColor_" .. i .. "_img"), "ImageView");
					iconImg:loadTexture(GoodsManager.getIconPathById(id));
					colorImg:loadTexture( GoodsManager.getColorBgImg(GoodsManager.getColorById(id)) );
				else
					tolua.cast(m_infoLayout:getWidgetByName("cailiao_" .. i .. "_panel"), "Layout"):setEnabled(false);
				end
			end
	    	infofunc_btn:setEnabled(true);
		end
	else
		infofunc_btn:setEnabled(false);
		name_label:setColor(COLOR_VALUE[COLOR_WHITE]);
		--额外转化属性
		local keys = {"force", "agility", "endurance"};
    	for i,v in ipairs(keys) do
    		local dataItem = DataTableManager.getItemByKey("coat_grow_Data", "type", typeid);
    		if(dataItem ~= nil)then
    			local proid = dataItem[v .. "_addition_id"];
				tolua.cast(m_infoLayout:getWidgetByName("proImg_" .. i .. "_" .. 4), "ImageView"):setEnabled(proid > 0);
				if(proid > 0) then
					local proNameLabel = tolua.cast(m_infoLayout:getWidgetByName(labelName[i] .. "Value_label_4"), "Label");
					proNameLabel:setText(DataTableManager.getValue("PropertyNameData", "id_" .. proid, "name"));
				end
    		end
    	end
	end
end



--外套详细信息
local function showDetailsInfo()
	refreshDetails();
	setSlvSizeAndPos(STATUS_INFO);
	setBtnPos(STATUS_INFO);
	m_infoLayout:setPosition(ccp(SCREEN_WIDTH, 0));
	m_rootLayer:addChild(m_infoLayout);
	local time = 0.3;
	local action = CCMoveTo:create(time, ccp(0, 0));
	m_infoLayout:runAction(action);	

	m_status = STATUS_INFO;
end


local function closeOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_status == STATUS_NORMAL) then
			UIManager.close("Wardrobe");
		else
			restoreNormal();
		end
	end
end
------------------------------------------------------------------------

local function scrollViewTouchEnd(type, x, y)
	if(m_status == STATUS_NORMAL) then
		if(not m_isMoved) then
			if(x > SCREEN_WIDTH_HALF - PANEL_W/2 + 20 and x < SCREEN_WIDTH_HALF + PANEL_W/2 - 20
				and y > SCREEN_HEIGHT_HALF - PANEL_H/2 + 100 and y < SCREEN_HEIGHT_HALF + PANEL_H/2 - 100) then
				-- print("************************m_curIndex = " .. m_curIndex);
				local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
				local isHave = isCoatHave(typeid);
				if(isHave) then
					showDetailsInfo();
				end
			end
		end
	end
end


local function createSlv()
	m_scrollView = CCScrollView:create()
	m_scrollView:retain();
    if nil ~= m_scrollView then
        m_scrollView:setViewSize(CCSizeMake(SIZE_W, PANEL_H))
        m_scrollView:setPosition(ccp(POS_X, POS_Y))
        m_scrollView:setDirection(kCCScrollViewDirectionHorizontal)
        m_scrollView:setBounceable(false)
        local sizeW = (SIZE_W/2 - PANEL_W/2)*2 + COAT_COUNT*PANEL_W + (COAT_COUNT - 1)*SPACE;
		m_scrollView:setContentSize(CCSize(sizeW, PANEL_H));

        m_scrollView:registerScriptHandler(scrollViewDidScroll,CCScrollView.kScrollViewScroll)

        m_scrollView:registerScripTouchEndHandler(scrollViewTouchEnd);
    end
    m_rootLayer:addChild(m_scrollView, 10);
end

function resetSlv(status)
	if(status) then
		local pos = nil;
		local size = nil;--可视区域
		if(status == STATUS_INFO) then
			SPACE = SPACE_INFO;
			pos = ccp(-(SIZE_W - SLV_W_0)/2 - 20, POS_Y);
			size = CCSizeMake(SLV_W_0 + (SIZE_W - SLV_W_0)/2 - 20, PANEL_H);
		elseif(status == STATUS_NORMAL) then
			SPACE = SPACE_NORMAL;
			pos = ccp(POS_X, POS_Y);
			size = CCSizeMake(SIZE_W, PANEL_H);
		end
		m_scrollView:setPosition(pos);
		m_scrollView:setViewSize(size);--可视区域
		--滑动区域
        local sizeW = (SIZE_W/2 - PANEL_W/2)*2 + COAT_COUNT*PANEL_W + (COAT_COUNT - 1)*SPACE;
		m_scrollView:setContentSize(CCSize(sizeW + 20, PANEL_H));
        if(status == STATUS_INFO) then
			m_scrollView:setContentSize(CCSize(sizeW - PANEL_W/2, PANEL_H));
		end

		local container = m_scrollView:getContainer();
		local offX = SIZE_W/2 - PANEL_W/2;
		for i = 1,COAT_COUNT do
			local panel = tolua.cast(container:getChildByTag(i + SLV_TAG_BASE), "Layout");
		    panel:setPosition(ccp( offX + (PANEL_W + SPACE)*(i - 1), ITEM_Y )); --ccp(0, 0)为锚点
		end

		local panel1 = tolua.cast(container:getChildByTag(1 + SLV_TAG_BASE), "Layout");
		local posX1 = panel1:getPositionX();

		local panel2 = tolua.cast(container:getChildByTag(2 + SLV_TAG_BASE), "Layout");
		local posX2 = panel2:getPositionX();

		star_x = def_offX + posX1;

		SCALE_COE = (1 - CENTER_SCALE)/(posX2 - posX1);

		m_scrollView:setContentOffsetWithNoDelegate(ccp(def_offX - (m_curIndex - 1)*(SPACE + PANEL_W), 0), true);
		setScaleAndZorder(true);
	end
end

local function createItems()
	if(m_scrollView) then
		local panelCopy = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Wardrobe_item.json");
		local offX = SIZE_W/2 - PANEL_W/2;
		for i = 1,COAT_COUNT do
			local panel = panelCopy:clone();
		    panel:setPosition(ccp( offX + (PANEL_W + SPACE)*(i - 1), ITEM_Y )); --ccp(0, 0)为锚点

		    local tag = SLV_TAG_BASE + i;
		    panel:setTag(tag);
		    m_scrollView:addChild(panel, 1);
		    -- panel:setAnchorPoint(ccp(0.5, 0.5));
		    local animPanel = tolua.cast(panel:getChildByName("animPanel"), "Layout");
			local anim = createNotiAnim();
			animPanel:addNode(anim, 1, 1);
		end

		local container = m_scrollView:getContainer();
		local panel1 = tolua.cast(container:getChildByTag(1 + SLV_TAG_BASE), "Layout");
		local posX1 = panel1:getPositionX();

		local panel2 = tolua.cast(container:getChildByTag(2 + SLV_TAG_BASE), "Layout");
		local posX2 = panel2:getPositionX();

		star_x = def_offX + posX1;

		SCALE_COE = (1 - 0.8)/(posX2 - posX1);
		print("*****");
	end
end


--合成、装备、替换 按钮
local function funcOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		if(m_statusKey == STATUS_KEY.NO_HAVE_PIECE_1 or m_statusKey == STATUS_KEY.NO_HAVE_PIECE_0) then
			--合成
			local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
			local needCount, totalCount = getPieceCount(typeid);
			if(totalCount >= needCount) then
				ProgressRadial.open();
				local index = getCurPieceIndex();
	            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_COATCOMPOSITE, {index});
	        else
	        	Util.showOperateResultPrompt("碎片不足");
	        end
		elseif(m_statusKey == STATUS_KEY.HAVE_NO_WEAR_ALL or m_statusKey == STATUS_KEY.HAVE_WEAR_OTHER) then
			--装备 --替换
			local typeid = DataTableManager.getValue("coat_pos", "id_" .. m_curIndex, "type");
            NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_COATWEARORREPLACE, {typeid});
		else
			ProgressRadial.close();
		end
	end
end

local m_colorBgImg = {
	"",
	PATH_CCS_RES .. "wtk_2.png",
	PATH_CCS_RES .. "wtk_3.png",
	PATH_CCS_RES .. "wtk_4.png",
	PATH_CCS_RES .. "wtk_5.png",
}; 

function getColorBgImg( color )
	return m_colorBgImg[color];
end

--大图上的信息
local function initDisplay()
	local wearedCoatType = UserInfoManager.getRoleInfo("coat").type;--装备上的外套在所有外套的索引
	for i=1,COAT_COUNT do
		local container = m_scrollView:getContainer();
		local panel = tolua.cast(container:getChildByTag(i + SLV_TAG_BASE), "Layout");
		local img = tolua.cast(panel:getChildByName("coatIcon"), "ImageView");
		local animPanel = tolua.cast(panel:getChildByName("animPanel"), "Layout");
		local colorBgImg = tolua.cast(img:getChildByName("colorbg_img"), "ImageView");
		local typeid = DataTableManager.getValue("coat_pos", "id_" .. i, "type");
		local data = getCoatDataByTypeid(typeid);

		--加入动画
		local anim = animPanel:getNodeByTag(1);
		setAnimAction(anim, 0);

	    --此位置对应图片
		local isHave, id = isCoatHave(typeid);
	    
		--是否已装备
		local status_img = tolua.cast(img:getChildByName("status_img"), "ImageView");
		if(isHave and wearedCoatType == typeid) then
			status_img:setEnabled(true);
		else
			status_img:setEnabled(false);
		end

		--对应碎片
		local countPanel = tolua.cast(img:getChildByName("count_panel"), "Layout");
		local flagLabel = tolua.cast(countPanel:getChildByName("chenghao_label"), "Label");
		-- local needCount_label = tolua.cast(countPanel:getChildByName("needCount_label"), "Label");
		local totalCount_label = tolua.cast(countPanel:getChildByName("totalCount_label"), "Label");
		-- needCount_label:setText("");
		totalCount_label:setText("");

		countPanel:setColor(COLOR_VALUE[COLOR_WHITE]);
		flagLabel:setColor(COLOR_VALUE[COLOR_WHITE]);
		totalCount_label:setColor(COLOR_VALUE[COLOR_WHITE]);

		local needCount, totalCount = getPieceCount(typeid);
		-- needCount_label:setText(needCount);
		totalCount_label:setText(totalCount);
		
		--星级
		local starName = {"force", "agility", "endurance"};
	    -- local starEnablePath = PATH_CCS_RES .. "jingling_star_1.png";
	    -- local starDisablePath = PATH_CCS_RES .. "jingling_star_2.png";
		colorBgImg:setEnabled(true);
		local STAR_COUNT = 10;
		local canGiveNote = 0;
		if(isHave) then
			--已经解锁此外套

			--大图
			img:loadTexture(PATH_RES_IMAGE_WARDROBE_NORMAL .. "wardrobe_" .. typeid .. ".png");
			--属性星级
			for i,v in ipairs(starName) do
				local starLV = DataTableManager.getValue("coat_grow", "id_" .. id, v .. "_star");
				local starPanel = tolua.cast(img:getChildByName(v .. "Star_panel"), "Layout");
				for j=1,STAR_COUNT do 
					local starImg = tolua.cast(starPanel:getChildByName(v .. "Star_" .. j), "ImageView");
					if(j <= starLV) then
						starImg:setEnabled(true);
						-- starImg:loadTexture(starEnablePath);
					else
						starImg:setEnabled(false);
					end
				end
			end
			--升阶提示
			if(checkCanUpStep(typeid)) then
				--可以升阶
				canGiveNote = 1;
			end

			--颜色
			local color = data.color;
			anim:getBone("Layer3"):setColor(COLOR_VALUE[color]);
			if(color == COLOR_WHITE) then
				colorBgImg:setEnabled(false);
			else
				colorBgImg:loadTexture(m_colorBgImg[color]);
			end
		else
			--未解锁此外套
			anim:getBone("Layer3"):setColor(COLOR_VALUE[COLOR_WHITE]);
			--大图
			img:loadTexture(PATH_RES_IMAGE_WARDROBE_DISABLE .. "wardrobe_" .. typeid .. ".png");
			colorBgImg:setEnabled(false);
			--星星
			for i,v in ipairs(starName) do
				local starPanel = tolua.cast(img:getChildByName(v .. "Star_panel"), "Layout");
				for j=1,STAR_COUNT do
					local starImg = tolua.cast(starPanel:getChildByName(v .. "Star_" .. j), "ImageView");
					starImg:setEnabled(false);
				end
			end
			if(totalCount >= needCount) then
				--碎片足够
				flagLabel:setColor(COLOR_VALUE[COLOR_GREEN]);
				totalCount_label:setColor(COLOR_VALUE[COLOR_GREEN]);
				canGiveNote = 2;
			else
				flagLabel:setColor(COLOR_VALUE[COLOR_RED]);
				totalCount_label:setColor(COLOR_VALUE[COLOR_RED]);
			end
		end

		--给提示(合成或升阶)
		if(canGiveNote ~= 0) then
			setAnimAction(anim, 1);
		end
	end
end

local function refreshDisplay()
	initDisplay();
	setCurStatus();
	setBtnDisplay();
end

local function initCurIndex()
	m_curIndex = 1;
	local wearedCoatType = UserInfoManager.getRoleInfo("coat").type;--装备上的外套在所有外套的索引
	m_beforeIndex = wearedCoatType;
	if(wearedCoatType > 0) then
		local index = DataTableManager.getItemByKey("coat_pos", "type", wearedCoatType).id;
		if(index > 0) then
			m_curIndex = index;
		end
	end
end

local function init()
	m_lastOffX = 0;
	isLeft = true;
	m_isMoved = false;
	m_scrollView:setContentOffsetWithNoDelegate(ccp(def_offX, 0), false);
	m_status = STATUS_NORMAL;

	initCurIndex();
    initDisplay();
    setScaleAndZorder(false);
	setCurStatus();
	setBtnDisplay();
	setSlvSizeAndPos(STATUS_NORMAL);
end

--合成返回
local function onReceiveCompositeResponse( messageType, messageData )
	local typeid = messageData.type;
	local result = messageData.result;
	refreshDisplay();
	ProgressRadial.close();
end

--装备、替换返回
local function onReceiveWearCoatResponse( messageType, messageData )
	local typeid = messageData.type;
	local result = messageData.result;
	ProgressRadial.close();

	refreshDisplay();
end


local OPE_RESULT_COAT_UPSTEP_OK = 1;
local OPE_RESULT_COAT_UPSTEP_MAX = 2;
local OPE_RESULT_COAT_UPSTEP_MATERIAL_NOT_ENOUGH = 3;
--强化、升阶返回
local function onReceiveStrenUpstepResponse( messageType, messageData )
	local typeid = messageData.type;
	local result = messageData.result;
	if(result == OPE_RESULT_COAT_UPSTEP_OK) then
		refreshDisplay();
		refreshDetails();
	elseif(result == OPE_RESULT_COAT_UPSTEP_MAX) then
		Util.showOperateResultPrompt("满级");
	elseif(result == OPE_RESULT_COAT_UPSTEP_MATERIAL_NOT_ENOUGH) then
		Util.showOperateResultPrompt("材料不足");
	end
	ProgressRadial.close();
end

local function registerMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_COMPOSITERESPONSE, onReceiveCompositeResponse);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_WEARCOATRESPONSE, onReceiveWearCoatResponse);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_STRENUPSTEPRESPONSE, onReceiveStrenUpstepResponse);

end

local function unRegisterMessage()
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_COMPOSITERESPONSE, onReceiveCompositeResponse);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_WEARCOATRESPONSE, onReceiveWearCoatResponse);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_STRENUPSTEPRESPONSE, onReceiveStrenUpstepResponse);
end

function setAnimAction( anim, action )
	if(action == 0) then
		anim:getAnimation():play("stand");
	else
		anim:getAnimation():play("cycle");
	end
end

function createNotiAnim()
	local anim = CCArmature:create("waitaobiankuang");
    anim:getAnimation():play("stand"); --cycle
    anim:setPosition(ccp(0, 0));
    return anim;
end

local function loadNotiAnim()
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(PATH_RES_OTHER .. "waitaobiankuang.ExportJson");
end

local function removeNotiAnim()
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(PATH_RES_OTHER .. "waitaobiankuang.ExportJson");
	CCTextureCache:sharedTextureCache():removeTextureForKey(PATH_RES_OTHER .. "waitaobiankuang0.png");
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		m_rootLayer:setPosition(ccp(0,0));

		m_rootLayout = TouchGroup:create();
		m_rootLayout:retain();
		m_rootLayer:addChild(m_rootLayout);

		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Wardrobe.json");
		m_rootLayout:addWidget(panel);

		m_infoLayout = TouchGroup:create();
		m_infoLayout:retain();
		m_infoPanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "WardrobeInfo.json");
		m_infoPanel:setPosition(ccp(0, 0));
		m_infoLayout:addWidget(m_infoPanel);
		-- local closeInfoPanel = tolua.cast(m_infoLayout:getWidgetByName("close_panel"), "Layout");
		-- closeInfoPanel:addTouchEventListener(closeInfoPanelOnClick);
		local infofunc_btn = tolua.cast(m_infoLayout:getWidgetByName("func_btn"), "Button");
		infofunc_btn:addTouchEventListener(infoFuncOnClick);


		loadNotiAnim();
		createSlv();
		createItems();

		local closeBtn = tolua.cast(m_rootLayout:getWidgetByName("back_img"), "ImageView");
		closeBtn:addTouchEventListener(closeOnClick);

		m_funcBtn_wear = tolua.cast(m_rootLayout:getWidgetByName("func_btn_1"), "Button");
		m_funcBtn_replace = tolua.cast(m_rootLayout:getWidgetByName("func_btn_2"), "Button");
		m_funcBtn_composite = tolua.cast(m_rootLayout:getWidgetByName("func_btn_3"), "Button");
		m_funcBtn_wear:addTouchEventListener(funcOnClick);
		m_funcBtn_replace:addTouchEventListener(funcOnClick);
		m_funcBtn_composite:addTouchEventListener(funcOnClick);

		--升阶材料点击
		for i=1,4 do
			m_infoLayout:getWidgetByName("cailiao_" .. i .. "_panel"):setTag(i);
			m_infoLayout:getWidgetByName("cailiao_" .. i .. "_panel"):addTouchEventListener(upstepGoodsOnClick);
		end

		GoodsDetailsPanel.create();
	end
end

function open()
	if(not m_isOpen) then
		m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, THREE_ZORDER);

		init();

		registerMessage();
        AncientMaterialItem.setCallBack(function() UIManager.close("Wardrobe"); end);
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);

        unRegisterMessage();
        ProgressRadial.close();

        local nowCoat = UserInfoManager.getRoleInfo("coat").type;
        if(m_beforeIndex ~= nowCoat and nowCoat > 0) then
        	MainCityLogic.reloadPlayer();
        end
        NotificationManager.onCloseCheck("Wardrobe");
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		if(m_rootLayer) then
	        m_rootLayer:removeAllChildrenWithCleanup(true);
		    m_rootLayer:release();
		    m_rootLayer = nil;
	    end
	    m_rootLayout:release();
	   	m_rootLayout = nil;
	   	m_infoLayout:release();
	   	m_infoLayout = nil;
	   	m_scrollView:release();
	   	m_scrollView = nil;
	   	removeNotiAnim();
	end
end