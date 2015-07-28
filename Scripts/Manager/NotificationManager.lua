--
-- Author: gaojiefeng
-- Date: 2015-06-25 14:40:28
--

module("NotificationManager", package.seeall)

local m_allModules = {
	"MailManager",
	"FriendsManager",
	"PurchaseGold",
	"NpcInfoManager",
	"TaskManager",
	"WishManager",
	"AncientMain",













	------------------------
	"WeaponUI",			--精灵
	"BackpackNew",		--背包
	"Wardrobe",			--衣柜
	"SkillsUINew",		--技能
	"SignUI",			--签到




};

local m_flags = {
	FriendsManager 		= "h_5_img",
	MailManager         = "s_2_img",
	PurchaseGold        = "h_4_img",
	NpcInfoManager      = "h_6_img",
	TaskManager         = "h_7_img",
	WishManager         = "h_9_img",
	AncientMain	        = "s_6_img",












	------------------------
	BackpackNew			= "h_1_img",
	WeaponUI			= "h_8_img",
	Wardrobe			= "h_2_img",
	SkillsUINew			= "h_3_img",
	SignUI				= "s_3_img",





};

-- h_1_img	背包
-- h_2_img	衣柜
-- h_3_img	技能
-- h_4_img	点金
-- h_5_img	好友
-- h_6_img	任务
-- h_7_img	活跃
-- h_8_img	精灵
-- h_9_img	许愿
-- s_2_img	邮箱
-- s_3_img	签到
-- s_5_img	礼包
-- s_6_img	材料


local function canOperate()
	if(MainCityUI.isExists()) then
		local notificationList1 = MainCityUI.getNotificationImages();
		if(notificationList1) then
			return notificationList1;
		end
	end

	if(WorldMapUI.isOpen()) then
		local list = WorldMapUI.getNotificationImages();
		return list;
	end
	return false;
end

local function setModuleFlagVisiable( module, visiable )
	local list = canOperate();
	if(list) then
		if(list[m_flags[module]]) then
			list[m_flags[module]]:setVisible(visiable);
		end
	end
end


--登录检测
function onLoginCheckAll()
	if(canOperate()) then
		for i,v in ipairs(m_allModules) do
			if(_G[v].checkNotification_login ~= nil) then
				local can = _G[v].checkNotification_login();
				setModuleFlagVisiable(v, can);
			end
		end
	end
end


--线上检测
function onLineCheck( module )
	if(canOperate()) then
		if(_G[module].checkNotification_line ~= nil) then
			local can = _G[module].checkNotification_line();
			setModuleFlagVisiable(module, can);
		end
	end
end


--关闭检测
function onCloseCheck( module )
	if(canOperate()) then
		if(_G[module].checkNotification_close ~= nil) then
			local can = _G[module].checkNotification_close();
			setModuleFlagVisiable(module, can);
		end
	end
end