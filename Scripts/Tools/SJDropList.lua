module("SJDropList",package.seeall)


FONTZISE = 20
LABEL_POSITION = ccp(100,20); 
ITEMSIZE = CCSizeMake(200, 40);
BLACKCOLOR = ccc3(0,0,0);

SJDropListClass = {
};



SJDropListClass.addLabel = function(self,text)

	local dropList = self.DropList;
	local contentLabel = Label:create();
	local containLayer = Layout:create();
	containLayer:setSize(ITEMSIZE)
	containLayer:addChild(contentLabel);
	containLayer:setTouchEnabled(true);

	contentLabel:setText(text);
	contentLabel:setColor(BLACKCOLOR);
	contentLabel:setFontSize(FONTZISE);
	contentLabel:setPosition(LABEL_POSITION);
	dropList:pushBackCustomItem(containLayer);
	table.insert(self.Labels,text);
end

SJDropListClass.create = function(self,title,topImage)
	-- body

	local m_DropLayer = {
		DropLayer = nil,
		DropList = nil,
		Labels   = {};
		selectedIndex = 0;
		topLabel = nil;
		title = nil;
		m_lastText = nil;
	};

	local m_isSelected = false;

	local function getDropLayer()
	-- body
		local dropLayer = m_DropLayer.DropLayer;
		return dropLayer;
	end 

	local function getTopPanel()
		-- body
		local dropLayer = getDropLayer();
		local topPanel = dropLayer:getChildByName("topPanel");
		return topPanel;
	end 

	local function getTopImg()
		-- body
		local topPanel = getTopPanel();
		local dropImg = tolua.cast(topPanel:getChildByName("drop_imageView"),"ImageView");
		return dropImg;
	end

	local function getTopLabel()
		-- body
		local topPanel = getTopPanel();
		local dropLabel = tolua.cast(topPanel:getChildByName("top_label"),"Label");
		return dropLabel;
	end

	local function getDropList()
		-- body
		local dropLayer = getDropLayer();
		local dropList = tolua.cast(dropLayer:getChildByName("droplist_listView"),"ListView");
		return dropList;
	end

	local function listViewTouchEvent(sender,eventType)
		-- body
		local index = sender:getCurSelectedIndex() + 1;
		if eventType == LISTVIEW_ONSELECTEDITEM_START then
			
		elseif eventType == LISTVIEW_ONSELECTEDITEM_END then				
			local topLabel = getTopLabel();
			local str = m_DropLayer.Labels[index];
       		topLabel:setText(str);

       		local dropList = m_DropLayer.DropList;
       		dropList:setEnabled(false);
       		m_DropLayer.selectedIndex = index;
       		m_isSelected = false;
    	end
	end

	local function topPanelTouchEvent(sender,eventType)
		-- body
		if eventType == TOUCH_EVENT_TYPE_END then
			local dropList = getDropList();
			if m_isSelected == false then
				m_DropLayer.m_lastText = m_DropLayer.Labels[m_DropLayer.selectedIndex];
				dropList:setEnabled(true);
				m_isSelected = true;
			else 
				dropList:setEnabled(false);
				m_isSelected = false;
			end
		end
	end

	local function listScrollTouchEvent(sender,eventType)
		-- body
		local topLabel = getTopLabel();
		if eventType == SCROLLVIEW_EVENT_SCROLLING then		
			if  m_DropLayer.m_lastText == nil then
				m_DropLayer.m_lastText = m_DropLayer.title;
			end
			topLabel:setText(m_DropLayer.m_lastText);
			m_DropLayer.m_lastText = topLabel:getStringValue();
			local dropList = m_DropLayer.DropList;
       		dropList:setEnabled(true);

       		CCLuaLog(dropList:getDirection());
		end
	end

	local function initDropLayer(title,topImage)
		-- body
		local dropImg = getTopImg();
		dropImg:loadTexture(topImage);

		local topPanel = getTopPanel();
		topPanel:addTouchEventListener(topPanelTouchEvent);

		local dropList = getDropList();
		dropList:addEventListenerListView(listViewTouchEvent);
		dropList:addEventListenerScrollView(listScrollTouchEvent);
	
		

		dropList:setEnabled(false);
		m_isSelected = false;

		local topLabel = getTopLabel();
		topLabel:setText(title);
		m_DropLayer.topLabel = topLabel;
	end

	local dropLayout = tolua.cast(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "SJDropList_1.json"),"Layout");
	m_DropLayer.DropLayer = dropLayout;
	m_DropLayer.DropList  = getDropList();
	m_DropLayer.title = title;

	setmetatable(m_DropLayer,self);
	self.__index = self;
	initDropLayer(title,topImage);
	return m_DropLayer;
end


SJDropListClass.clean = function(self)
	local dropList = self.DropList;
	dropList:removeAllItems();

	local topLabel = self.topLabel;
	local titleText = self.title;

	topLabel:setText(titleText);
	self.selectedIndex = 0;
end