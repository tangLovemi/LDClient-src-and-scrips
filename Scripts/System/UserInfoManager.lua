module("UserInfoManager", package.seeall)

require "NetWork/NetMessageManager"
require "Util"
local m_isGetNewAncientMaterial = false
local m_ancientMeterialId = 0 
HAIR_TAG = 1;
EYE_TAG  = 2;

ONLINE_STATE   = 1;
UNONLINE_STATE = 2;

NAME_FRIEND_TAG = 1;

local m_isDataLoadingEndFlag = false;
local m_cbFunc = nil;

local m_roleInfoNetMessages = {
	NETWORK_MESSAGE_RECEIVE_ROLE_NAME,
	NETWORK_MESSAGE_RECEIVE_ROLE_LEVEL,
	NETWORK_MESSAGE_RECEIVE_ROLE_GOLD,
	NETWORK_MESSAGE_RECEIVE_ROLE_EXP,
	NETWORK_MESSAGE_RECEIVE_ROLE_PHYSIC,
	NETWORK_MESSAGE_RECEIVE_ROLE_DIAMOND,
	NETWORK_MESSAGE_RECEIVE_ROLE_FIGHT,
	NETWORK_MESSAGE_RECEIVE_ROLE_VIPLV,
	NETWORK_MESSAGE_RECEIVE_ROLE_JJC_GROUP,
	NETWORK_MESSAGE_RECEIVE_ROLE_PVP,
	NETWORK_MESSAGE_RECEIVE_ANCIENT_MATERIAL_LIST,
	NETWORK_MESSAGE_RECEIVE_ANCIENT_MATERIAL_GET_ONE,
}

local m_rolePropertyNetMessages = {
	NETWORK_MESSAGE_RECEIVE_ROLE_FIRST_PROPERTY,  --一级属性
	NETWORK_MESSAGE_RECEIVE_ROLE_SECOND_PROPERTY, --二级属性
	NETWORK_MESSAGE_RECEIVE_ROLE_COMBAT_RATE_PROPERTY, -- 战斗率
};

local m_roleJJCNetMessages = {  --竞技场
	NETWORK_MESSAGE_RECEIVE_JJC_SELF_INFO  
};

local m_rolePointStarMessages = {
	NETWORK_MESSAGE_RECEIVE_POINTSTARDATA,
};

local m_roleSkillsMessages = {
	NETWORK_MESSAGE_RECEIVE_ROLE_SKILL_CLAS,
	NETWORK_MESSAGE_RECEIVE_ROLE_SKILL_CHOOSE,
};

--签到数据
local m_signMessages = {
	NETWORK_MESSAGE_RECEIVE_SIGNDATA, -- 28天数据
	NETWORK_MESSAGE_RECEIVE_SIGNTOTALINFO, --累积签到信息
	NETWORK_MESSAGE_RECEIVE_SIGNTOTALGOODS,--累积签到物品
};

local m_roleWeaponAndEquipNetMessage = {
	NETWORK_MESSAGE_RECEIVE_ROLE_WEAPON,
	NETWORK_MESSAGE_RECEIVE_ROLE_COAT,
	NETWORK_MESSAGE_RECEIVE_ROLE_HELMET,
	NETWORK_MESSAGE_RECEIVE_ROLE_ARMOUR,
	NETWORK_MESSAGE_RECEIVE_ROLE_NECKLACE,
	NETWORK_MESSAGE_RECEIVE_ROLE_RING,
	NETWORK_MESSAGE_RECEIVE_ROLE_SHOE,
	NETWORK_MESSAGE_RECEIVE_ROLE_TROUSERS,
	NETWORK_MESSAGE_RECEIVE_ROLE_GLOVE,
}

local m_faceInfoNetMessage = {
	NETWORK_MESSAGE_RECEIVE_FACEINFO,
	NETWORK_MESSAGE_RECEIVE_FACEINFO_COLOR,
}

local m_backpackNetMessage = {
	NETWORK_MESSAGE_RECEIVE_BACKPACK_WEAPON,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_WEAPON_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_EQUIP,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_EQUIP_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_MATERIAL,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_MATERIAL_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_OTHER,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_OTHER_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_COAT,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_COAT_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_COATCHIP,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_COATCHIP_DELETE,

	NETWORK_MESSAGE_RECEIVE_BACKPACK_EQUIP_REFRESH,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_WEAPON_REFRESH,
	NETWORK_MESSAGE_RECEIVE_BACKPACK_COAT_REFRESH,
	
}

local m_backNetMessage = {
	NETWORK_MESSAGE_RECEIVE_BACK_EQUIP,
	NETWORK_MESSAGE_RECEIVE_BACK_EQUIP_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACK_MATERIAL,
	NETWORK_MESSAGE_RECEIVE_BACK_MATERIAL_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACK_OTHER,
	NETWORK_MESSAGE_RECEIVE_BACK_OTHER_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACK_WEAPON,
	NETWORK_MESSAGE_RECEIVE_BACK_WEAPON_DELETE,
	NETWORK_MESSAGE_RECEIVE_BACK_COATCHIP,
	NETWORK_MESSAGE_RECEIVE_BACK_COATCHIP_DELETE,

}

local m_friendsNetMessage = { --好友
	NETWORK_MESSAGE_RECEIVE_FRIEND_FRIENDLIST,
	NETWORK_MESSAGE_RECEIVE_FRIEND_REQUESTLIST,
	NETWORK_MESSAGE_RECEIVE_FRIEND_RECOMMENDLIST,
	NETWORK_MESSAGE_RECEIVE_FRIEND_GIFTLIST,
	NETWORK_MESSAGE_RECEIVE_FRIEND_MAILLIST,
}

local m_roleInfo = {
	name     = "xxx",
	level    = 0,
	vipLv    = 0,
	gold     = 0,
	pvp   	 = 0,
	exp      = 0,
	physic   = 0,
	diamond  = 0,
	fight    = 0,
	groupid  = 6,
	preExp   = 0,
	preLevel = 0,
	coat     = {type = 0},
	weapon   = {id = 0},
	fashionCoat = {id = 0},
	helmet   = {id = 0},
	armour   = {id = 0},
	necklace = {id = 0},
	ring     = {id = 0},
	shoe     = {id = 0},
	trousers = {id = 0},
	glove    = {id = 0},
	uid = "";
	firstPro = {}, --一级属性
	secondPro= {}, --二级属性
	combatRate = {}, -- 战斗率

	jjcData  = {
		--groupId,  组别id
		--score,    积分
		--ranking,  排名
		--winCount, 连胜次数
		--lastCount 剩余次数
	},
	friends  = {
		--friends   好友列表
		--requests  请求添加列表
		--gifts     礼物列表
		--mails     邮件列表
		--recommend 推荐好友列表
	},
	pointStar = {
		-- line
		-- star
	},
	skills = {
		skillsClass = {},
		chooseSkills = "",
	},
-- 格式:"22001;0;0;22002;0",0代表此位置没有技能

	ancientMaterial = {
		-- id
		-- id
	},
	sign = {
		signDatas = {
			-- id, 	-- 物品id
			-- count,	--物品数量
			-- status,	--签到状态
			-- viplevel,	--vip等级限制
		},
		signTotalInfo = {
			-- totalSignDay 总已签到天数	
			-- rewardType	累积类型	
			-- canReceive	是否可以领取
		},
		signTotalGoods = {
			-- id,
			-- count,
		},
	},
}

local m_faceInfo = {	
	face      = 0,
	eyebrows  = 0,
	mouth     = 0,
	eye       = 0,
	hair  	  = 0,
	eye_color = {
		r = 0,
		g = 0,
		b = 0,
	},
	hair_color = {
		r = 0,
		g = 0,
		b = 0,
	},
}

local m_backpack = {
	equip    = {},
	equipPiece = {},
	other    = {},
	coat     = {},
	coatchip = {},
	weapon   = {},
}

local m_back = {
	equip    = {},
	equipPiece = {},
	other    = {},
	coatchip = {},
	weapon   = {},
}

--人物基本信息
function setRoleInfo(key,value)
	-- body
	m_roleInfo[key] = value;
end

function setRolePartInfo(part,key,value)
	-- body
	local partInfo = m_roleInfo[part];
	partInfo[key] = value;
end

function getRoleInfo(key)
	-- body
	local info = m_roleInfo[key]	
	local infoType = type(info);
	
	if (infoType == "table") then
	   local equip;
	   equip = Util.deepcopy(info);
	   return equip;
	end

	return info;
end

function getRoleAllInfo()
	return m_roleInfo;
end

function receiveDataForRoleInfo(messageType, messageData)
	-- print("receiveDataForRoleInfo");
	setRoleInfo("preLevel",getRoleInfo("level"));

	
	-- body

	if #messageData == 0 then
		for k,v in pairs(messageData) do
			setRoleInfo(k,v);
		end
	end
	if (messageType == NETWORK_MESSAGE_RECEIVE_ANCIENT_MATERIAL_LIST) then --远古材料
		setRoleInfo("ancientMaterial",messageData);
	end
	if (messageType == NETWORK_MESSAGE_RECEIVE_ANCIENT_MATERIAL_GET_ONE) then --远古材料
		addNewAncientMeterial(messageData["id"])
		NotificationManager.onLineCheck("AncientMain")
		
		NotificationManager.onLineCheck("WeaponUI");
		NotificationManager.onLineCheck("Wardrobe");
		if MainCityLogic.isOpen() then
			AncientMaterialItem.playGetAncientEffect(messageData["id"])
		else
			m_isGetNewAncientMaterial = true
			m_ancientMeterialId = messageData["id"]
		end
	end
	
	if(messageType == NETWORK_MESSAGE_RECEIVE_ROLE_LEVEL)then--更新等级 
		if(MainCityLogic.isOpen())then
			MainCityUI.refreshDisplay();
			UIManager.open("Upgrade");
			setRoleInfo("preLevel",getRoleInfo("level"));
			local newGuideinfo =TaskManager.getNewGuideInfo()
			if(newGuideinfo["step"] ~= nil) then
				if  newGuideinfo["step"] > 11 then
					if newGuideinfo["bSuccess"]==0 then
					    GuideDatas.continueNewGUide(newGuideinfo)--新手引导未全部完成
					end	
				end
			end
		end
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_ROLE_NAME then --名称
		MainCityUI.refreshDisplay();
	end
	if messageType == NETWORK_MESSAGE_RECEIVE_ROLE_GOLD  then --更新了金币
		MainCityUI.refreshDisplay();
	end
	if messageType == NETWORK_MESSAGE_RECEIVE_ROLE_DIAMOND  then --更新了钻石
		MainCityUI.refreshDisplay();
	end	
	if messageType == NETWORK_MESSAGE_RECEIVE_ROLE_EXP then --更新了经验
		MainCityUI.refreshDisplay();
	end		
	if messageType == NETWORK_MESSAGE_RECEIVE_ROLE_PHYSIC then -- 更新了体力值
		MainCityUI.refreshDisplay();
	end
end

local function receiveDataForRoleEquip(messageType,messageData)
	-- print("receiveDataForRoleEquip");
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_ROLE_WEAPON then
		setRoleInfo("weapon",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_COAT then
		setRoleInfo("coat",messageData);
		MainCityUI.refreshDisplay();
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_HELMET then
		setRoleInfo("helmet",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_ARMOUR then
		setRoleInfo("armour",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_NECKLACE then
		setRoleInfo("necklace",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_RING then
		setRoleInfo("ring",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_SHOE then
		setRoleInfo("shoe",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_TROUSERS then
		setRoleInfo("trousers",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_ROLE_GLOVE then
		setRoleInfo("glove",messageData);
	end
end

local function receiveDataForRoleProperty( messageType, messageData )
	-- print("receiveDataForRoleProperty");
	if(messageType == NETWORK_MESSAGE_RECEIVE_ROLE_SECOND_PROPERTY) then
		m_roleInfo.secondPro = {};
		m_roleInfo.secondPro = messageData;
		-- attack; 			//攻击
		-- defense;			//防御
		-- hp;				//血量
		-- speed;			//速度
		-- bash;			//重击
		-- crit;			//暴击
		-- counterAttack;	//反击
		-- parry;			//格挡
		-- dodge;			//闪避
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_ROLE_FIRST_PROPERTY) then
		m_roleInfo.firstPro = {};
		m_roleInfo.firstPro = messageData;
		-- strength;		//力量
		-- agility;			//敏捷
		-- endurance;		//耐力
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_ROLE_COMBAT_RATE_PROPERTY) then
		m_roleInfo.combatRate = {};
		m_roleInfo.combatRate = messageData;
		-- bashRate	    重击率	
		-- critRate		暴击率	
		-- parryRate	格挡率	
		-- dodgeRate	闪避率	
		-- noHurtRate	免伤率	
		-- counterRate	反击率															

	end
end

local function receiveDataForRoleJJC( messageType, messageData )
	-- print("receiveDataForRoleJJC");
	if(messageType == NETWORK_MESSAGE_RECEIVE_JJC_SELF_INFO) then
		m_roleInfo.jjcData = {};
		m_roleInfo.jjcData.groupId = messageData.groupId;
		m_roleInfo.jjcData.score = messageData.score;
		m_roleInfo.jjcData.ranking = messageData.ranking;
		m_roleInfo.jjcData.winCount = messageData.winCount;
		m_roleInfo.jjcData.lastCount = messageData.lastCount;
		m_roleInfo.jjcData.lastgroupid = messageData.lastgroupid;
	end
	JJCUI.baseDataReceiveEnd();
end

local function receiveDataForPointStar(messageType, messageData)
	-- print("receiveDataForPointStar");
	if(messageType == NETWORK_MESSAGE_RECEIVE_POINTSTARDATA) then
		m_roleInfo.pointStar = {};
		m_roleInfo.pointStar = messageData;
	end
end

function receiveDataForRoleSkills( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_ROLE_SKILL_CLAS) then
		local skillsClassT = Util.strToNumber(Util.Split(messageData.skillsStr, ";"));
		m_roleInfo.skills.skillsClass = {};
		for i=1,#skillsClassT do
			local d = {skill = skillsClassT[i], isNew = false};
			table.insert(m_roleInfo.skills.skillsClass, d);
		end

		if(LoginMgr.isloginEnd()) then
			local level = m_roleInfo["level"];
			local skillstr = DataTableManager.getValue("expData", "id_" .. level, "skillopen");
			if(skillstr ~= "") then
				SkillsUINew.setHaveNewSkill(true);
				NotificationManager.onLineCheck("SkillsUINew");
				local skillsNew = Util.strToNumber(Util.Split(skillstr, ";"));
				for i,v1 in ipairs(skillsNew) do
					for j,v2 in ipairs(m_roleInfo.skills.skillsClass) do
						if(v1 == v2.skill) then
							v2.isNew = true;
						end
					end
				end
			end
		end
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_ROLE_SKILL_CHOOSE) then
		m_roleInfo.skills.chooseSkills = {};
		local chooseSkillsT = Util.strToNumber(Util.Split(messageData.skillsStr, ";"));
		m_roleInfo.skills.chooseSkills = chooseSkillsT;
	end
end

local function receiveDataForSign( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_SIGNDATA) then
		--28天数据
		m_roleInfo.sign.signDatas = messageData;
		if(SignUI.isOpen()) then
			SignUI.refreshInfo();
		end
	end

	--累积签到信息
	if(messageType == NETWORK_MESSAGE_RECEIVE_SIGNTOTALINFO) then
		m_roleInfo.sign.signTotalInfo = messageData;
	end

	--累积签到物品
	if(messageType == NETWORK_MESSAGE_RECEIVE_SIGNTOTALGOODS) then
		m_roleInfo.sign.signTotalGoods = messageData;
	end
end

local function receiveDataForFriends(messageType, messageData)
	-- print("receiveDataForFriends");
	--friends   好友列表
	--requests  请求添加列表
	--gifts     礼物列表
	--mails     邮件列表
	--recommend 推荐好友列表

	if(messageType == NETWORK_MESSAGE_RECEIVE_FRIEND_FRIENDLIST) then
		m_roleInfo.friends.friends = {};
		m_roleInfo.friends.friends = messageData;
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_FRIEND_REQUESTLIST) then
		m_roleInfo.friends.requests = {};
		m_roleInfo.friends.requests = messageData;
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_FRIEND_GIFTLIST) then
		m_roleInfo.friends.gifts = {};
		m_roleInfo.friends.gifts = messageData;
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_FRIEND_MAILLIST) then
		m_roleInfo.friends.mails = {};
		m_roleInfo.friends.mails = messageData;
	elseif(messageType == NETWORK_MESSAGE_RECEIVE_FRIEND_RECOMMENDLIST) then
		m_roleInfo.friends.recommend = {};
		m_roleInfo.friends.recommend = messageData;
	end
end

local function registerNetMessageForRoleInfo()
	-- body
	for i=1,#m_roleInfoNetMessages do
		local msg = m_roleInfoNetMessages[i];
		NetMessageManager.registerMessage(msg, receiveDataForRoleInfo);
	end

	for i=1,#m_roleWeaponAndEquipNetMessage do
		local msg = m_roleWeaponAndEquipNetMessage[i];
		NetMessageManager.registerMessage(msg, receiveDataForRoleEquip);
	end

	for i = 1,#m_rolePropertyNetMessages do
		local msg = m_rolePropertyNetMessages[i];
		NetMessageManager.registerMessage(msg, receiveDataForRoleProperty);
	end
	--竞技场
	for i=1,#m_roleJJCNetMessages do
		local msg = m_roleJJCNetMessages[i];
		NetMessageManager.registerMessage(msg, receiveDataForRoleJJC);
	end
	--好友
	for i=1,#m_friendsNetMessage do
		local msg = m_friendsNetMessage[i];
		NetMessageManager.registerMessage(msg, receiveDataForFriends);
	end
	--点星数据
	for i=1,#m_rolePointStarMessages do
		local msg = m_rolePointStarMessages[i];
		NetMessageManager.registerMessage(msg, receiveDataForPointStar);
	end
	--技能数据
	for i=1,#m_roleSkillsMessages do
		local msg = m_roleSkillsMessages[i];
		NetMessageManager.registerMessage(msg, receiveDataForRoleSkills);
	end
	--签到数据
	for i=1,#m_signMessages do
		local msg = m_signMessages[i];
		NetMessageManager.registerMessage(msg, receiveDataForSign);
	end
end

local function unregisterNetMessageForRoleInfo()
	-- body
	for i=1,#m_roleInfoNetMessages do
		local msg = m_roleInfoNetMessages[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForRoleInfo);
	end

	for i=1,#m_roleWeaponAndEquipNetMessage do
		local msg = m_roleWeaponAndEquipNetMessage[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForRoleEquip);
	end

	for i = 1,#m_rolePropertyNetMessages do
		local msg = m_rolePropertyNetMessages[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForRoleProperty);
	end

	for i=1,#m_roleJJCNetMessages do
		local msg = m_roleJJCNetMessages[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForRoleJJC);
	end

	for i=1,#m_friendsNetMessage do
		local msg = m_friendsNetMessage[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForFriends);
	end

	for i=1,#m_rolePointStarMessages do
		local msg = m_rolePointStarMessages[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForPointStar);
	end

	for i=1,#m_roleSkillsMessages do
		local msg = m_roleSkillsMessages[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForRoleSkills);
	end

	for i=1,#m_signMessages do
		local msg = m_signMessages[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForSign);
	end
end


-- 人物脸部信息

local function setFaceInfo(key,value)
	m_faceInfo[key] = value;
end

local function setFaceInfoColor(tag,r,g,b)
	-- body
	local key = nil;

	if tag == HAIR_TAG then
		key = "hair_color" ;
	end

	if tag == EYE_TAG then
		key = "eye_color";
	end

	local table = m_faceInfo[key];
	table["r"] = r;
	table["b"] = b;
	table["g"] = b;
end

function getAllFaceInfo()
	return m_faceInfo;
end

function getFaceInfo(key)
	-- body
	return m_faceInfo[key];
end 

function getFaceInfoColor(key)
	-- body
	local str = key .. "_color"
	local colorTable = m_faceInfo[str];
	local colors = {};
	colors.r = colorTable.r;
	colors.b = colorTable.b;
	colors.g = colorTable.g;
	return colors;
end

local function receiveDataForFaceInfo(messageType, messageData)
	if messageType == NETWORK_MESSAGE_RECEIVE_FACEINFO then
		setFaceInfo("hair",messageData.hair);
		setFaceInfo("face",messageData.face);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_FACEINFO_COLOR then
		setFaceInfoColor(messageData.tag, messageData.r, messageData.g, messageData.b);
	end
	MainCityUI.refreshDisplay();
end

local function registerNetMessageForFace()
	-- body
	for i=1,#m_faceInfoNetMessage do
		local msg = m_faceInfoNetMessage[i];
		NetMessageManager.registerMessage(msg, receiveDataForFaceInfo);
	end
end

local function unregisterNetMessageForFace()
	-- body
	for i=1,#m_faceInfoNetMessage do
		local msg = m_faceInfoNetMessage[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForFaceInfo);
	end
end

-- 背包信息
local function setBackpackInfo(key,value)
	-- body
	local infos = m_backpack[key];
	table.insert(infos,value);
end

local function setBackpackInfo2( key, value )
	local infos = m_backpack[key];
	for i,v in ipairs(infos) do
		if(v.id == value.id) then
			v.count = value.count;
			return;
		end
	end

	table.insert(infos,value);
end

local function deleteBackpackInfo(key,index)
	-- body
	local infos = m_backpack[key];
	table.remove(infos,index);
end

local function deleteBackpackInfo2( key, value )
	local infos = m_backpack[key];
	if(infos) then
		local info = infos[value.pos];
		if(info.count >= value.count) then
			info.count = info.count - value.count;
		else
			info.count = 0;
		end

		if(info.count == 0) then
			table.remove(infos, value.pos);
		end
	end
end

local function refreshBackpackInfo(key, data )
	m_backpack[key][data.index] = data;
end

local function refreshBackpackCoatInfo( data )
	local coatType = GoodsManager.getCoatTypeByCoatid(data.id);
	m_backpack["coat"][coatType] = data;
end

local function resetCoat()
	local before = {};
	for k,v in pairs(m_backpack["coat"]) do
		table.insert(before,v);
	end
	m_backpack["coat"] = {};

	for i,v in ipairs(before) do
		local id = v.id;
		local coatTypeid = GoodsManager.getCoatTypeByCoatid(id);
		m_backpack["coat"][coatTypeid] = v;
	end
end

function getBackPackInfo(key)
	-- body
	return m_backpack[key]
end

function getAllBackpackInfo()
	return m_backpack;
end

function getCoatByType( type )
	local coats = m_backpack["coat"];
	for i,v in ipairs(coats) do
		if(v.type == type) then
			return v;
		end
	end
	return nil;
end

function receiveDataForBackpack(messageType,messageData)
	-- print("*************************  messageType = " .. messageType);
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_WEAPON then
		--武器
		for i=1,#messageData do
			if(LoginMgr.isloginEnd()) then
				messageData[i].isNew = true;
			end
			setBackpackInfo("weapon", messageData[i]);
		end
		if(LoginMgr.isloginEnd()) then
			WeaponUI.setHaveNewWeapon(true);
		end
		NotificationManager.onLineCheck("WeaponUI");
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_WEAPON_DELETE then
		--刪除武器
		deleteBackpackInfo("weapon",messageData.pos);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_WEAPON_REFRESH then
		refreshBackpackInfo("weapon", messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_COAT then
		-- 外套
			-- Util.print_lua_table(messageData);
		for i=1,#messageData do
			setBackpackInfo("coat", messageData[i]);
		end
		resetCoat();
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_COAT_DELETE then
		--删除外套
		deleteBackpackInfo("coat",messageData.pos);
		resetCoat();
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_COAT_REFRESH then
		refreshBackpackCoatInfo(messageData);


	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_EQUIP then
		--装备
		for i=1,#messageData do
			setBackpackInfo("equip", messageData[i]);
		end
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_EQUIP_DELETE then
		--删除装备
		deleteBackpackInfo("equip",messageData.pos);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_EQUIP_REFRESH then
		refreshBackpackInfo("equip", messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_MATERIAL then
		-- 装备碎片
		for i=1,#messageData do
			setBackpackInfo2("equipPiece", messageData[i]);
		end
		NotificationManager.onLineCheck("BackpackNew");
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_MATERIAL_DELETE then
		--删除装备碎片
		deleteBackpackInfo2("equipPiece",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_OTHER then
		-- 其它
		for i=1,#messageData do
			setBackpackInfo2("other", messageData[i]);
		end
		NotificationManager.onLineCheck("BackpackNew");
		NotificationManager.onLineCheck("Wardrobe");
	elseif  messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_OTHER_DELETE then
		--删除其它
		deleteBackpackInfo2("other",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_COATCHIP then
		-- 外套碎片
		for i=1,#messageData do
			setBackpackInfo2("coatchip", messageData[i]);
		end
		NotificationManager.onLineCheck("Wardrobe");
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACKPACK_COATCHIP_DELETE then
		--删除外套碎片
		deleteBackpackInfo2("coatchip",messageData);
	end
end 

local function registerNetMessageForBackpack()
	-- body
	for i=1,#m_backpackNetMessage do
		local msg = m_backpackNetMessage[i];
		NetMessageManager.registerMessage(msg, receiveDataForBackpack);
	end
end

local function unregisterNetMessageForBackpack()
	-- body
	for i=1,#m_backpackNetMessage do
		local msg = m_backpackNetMessage[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForBackpack);
	end
end

-- 仓库信息

local function setBackInfo(key,value)
	-- body
	local infos = m_back[key];
	table.insert(infos, value);
end

local function setBackInfo2( key, value )
	local infos = m_back[key];
	for i,v in ipairs(infos) do
		if(v.id == value.id) then
			v.count = value.count;
			return;
		end
	end

	table.insert(infos,value);
end

local function deleteBackInfo(key,index)
	-- body
	local infos = m_back[key];
	if(infos) then
		table.remove(infos,index)
	end
end

local function deleteBackInfo2( key, value )
	local infos = m_back[key];
	if(infos) then
		local info = infos[value.pos];
		if(info) then
			if(info.count >= value.count) then
				info.count = info.count - value.count;
			else
				info.count = 0;
			end

			if(info.count == 0) then
				table.remove(infos, value.pos);
			end
		end
	end
end

function getBackInfo(key)
	-- body
	return m_back[key];
end

function getAllBackInfo()
	return m_back;
end
local function receiveDataForBack(messageType,messageData)
	-- body
	if messageType == 	NETWORK_MESSAGE_RECEIVE_BACK_EQUIP then
		--装备
		for i=1,#messageData do
			local infos = messageData[i];
			setBackInfo("equip",infos);
		end
	elseif messageType == 	NETWORK_MESSAGE_RECEIVE_BACK_EQUIP_DELETE then
		--装备删除
		deleteBackInfo("equip",messageData.pos);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACK_MATERIAL then
		--装备碎片
		for i=1,#messageData do
			local infos = messageData[i];
			setBackInfo2("equipPiece",infos);
		end
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACK_MATERIAL_DELETE then
		-- 装备碎片删除
		deleteBackInfo2("equipPiece",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACK_OTHER then
		--其它
		for i=1,#messageData do
			local infos = messageData[i];
			setBackInfo2("other",infos);
		end
	elseif  messageType == NETWORK_MESSAGE_RECEIVE_BACK_OTHER_DELETE then
		--其它删除
		deleteBackInfo2("other",messageData);
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACK_COATCHIP then
		--外套碎片
		for i=1,#messageData do
			local infos = messageData[i];
			setBackInfo2("coatchip",infos);
		end
	elseif  messageType == NETWORK_MESSAGE_RECEIVE_BACK_COATCHIP_DELETE then
		--外套碎片删除
		deleteBackInfo2("coatchip",messageData);
	elseif messageType == 	NETWORK_MESSAGE_RECEIVE_BACK_WEAPON then
		--武器
		for i=1,#messageData do
			local infos = messageData[i];
			setBackInfo("weapon",infos);
		end
	elseif messageType == NETWORK_MESSAGE_RECEIVE_BACK_WEAPON_DELETE then
		--武器删除
		deleteBackInfo("weapon",messageData.pos);
	end

end 

local function registerNetMessageForBack()
	-- body
	for i=1,#m_backNetMessage do
		local msg = m_backNetMessage[i];
		NetMessageManager.registerMessage(msg, receiveDataForBack);
	end
end

local function unregisterNetMessageForBack()
	-- body
	for i=1,#m_backNetMessage do
		local msg = m_backNetMessage[i];
		NetMessageManager.unregisterMessage(msg, receiveDataForBack);
	end
end

local function addEnemyToEnemys(value)
	-- body
	local oLEnemys = m_enemys["OLEnemys"];
	local unoLEnemys = m_enemys["unOLEnemys"];

	if state == ONLINE_STATE then
		table.insert(oLEnemys,value);
	else
		table.insert(unoLEnemys,value);
	end
	
end

local function deleteEnemyFromEnemys(name)
	-- body
	local oLEnemys = m_enemys["OLEnemys"];
	local unoLEnemys = m_enemys["unOLEnemys"];

	for i=1,#oLEnemys do
		local enemy = oLEnemys[i];
		if enemy[NAME_FRIEND_TAG] == name then
			table.remove(oLEnemys,i);
			break;
		end
	end

	for i=1,#unoLEnemys do
		local enemy = unoLEnemys[i];
		if enemy[NAME_FRIEND_TAG] == name then
			table.remove(unoLEnemys,i);
			break;
		end
	end

end

-- online,unonline
function getEnemys(key)
	-- body
	local enemys = m_enemys[key];
	return enemys;
end

local function receiveDataForEnemys(messageType,messageData)


end

local function registerNetMessageForEnemys()
	-- body
	
end

local function unregisterNetMessageForEnemys()
	-- body
	
end

local function registerShopResponse()
    NormalShopGoods.registerMessageCB();
    MysteryShopGoods.registerMessageCB();
    ExchangeShopGoods.registerMessageCB();
end

local function unregisterShopResponse()
    NormalShopGoods.unregisterMessageCB();
    MysteryShopGoods.unregisterMessageCB();
    ExchangeShopGoods.unregisterMessageCB();
end

local function registerNetMessage()
	-- body
	registerNetMessageForRoleInfo();
	registerNetMessageForFace();
	registerNetMessageForBackpack();
	registerNetMessageForBack();
	registerShopResponse();
end

local function unregisterNetMessage()
	-- body
	unregisterNetMessageForRoleInfo();
	unregisterNetMessageForFace();
	unregisterNetMessageForBackpack();
	unregisterNetMessageForBack();
	unregisterShopResponse();
end

local function onLoadingEnd()
	if(m_cbFunc) then
		m_cbFunc();
	end
end

local function receiveAllDataEnd( messageType, messageData )
	if(messageType == NETWORK_MESSAGE_RECEIVE_LOADING_END) then
		m_isDataLoadingEndFlag = true;
		-- onLoadingEnd();
	end
end

local function isLoadingEnd()
	return m_isDataLoadingEndFlag;
end


--上线请求所有数据
function create(cb)
	m_cbFunc = cb;
	registerNetMessage();
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_LOADING_END, receiveAllDataEnd);
	m_isDataLoadingEndFlag = false;
	local loadData = {resType = LOADING_DATA_FROM_SERVER, resData = {isEnd = isLoadingEnd}};
	Loading.create({loadData}, onLoadingEnd);
end

function remove()
	unregisterNetMessage();
end 

--判断点击的是否是"全部"里的物品哪个
local function allWhich_backpack(index)
    -- equip + weapon + equipPiece + coatchip + other
    local g1 = m_backpack["equip"];
    -- local g2 = m_backpack["weapon"];
    local g2 = m_backpack["equipPiece"];
    local g3 = m_backpack["coatchip"];
    local g4 = m_backpack["other"];

    if(index <= #g1) then
        return g1, index;
    end

    if(index > #g1 and 
    	index <= (#g1 + #g2)) then
        return g2, index - #g1;
    end

    if(index > (#g1 + #g2) and 
    	index <= (#g1 + #g2 + #g3)) then
        return g3, index - (#g1 + #g2);
    end

    if(index > (#g1 + #g2 + #g3) and 
    	index <= (#g1 + #g2 + #g3 + #g4)) then
        return g4, index - (#g1 + #g2 + #g3);
    end

	-- if(index > (#g1 + #g2 + #g3 + #g4) and 
 --    	index <= (#g1 + #g2 + #g3 + #g4 + #g5)) then
 --        return g5, index - (#g1 + #g2 + #g3 + #g4);
 --    end
end

local function allPiece_backpack( index )
    local g1 = m_backpack["equipPiece"];
    local g2 = m_backpack["coatchip"];

    if(index <= #g1) then
        return g1, index;
    end

    if(index > #g1 and 
    	index <= (#g1 + #g2)) then
        return g2, index - #g1;
    end
end

local function allWhich_bank(index)
    -- equip + weapon + equipPiece + coatchip + other
    local g1 = m_back["equip"];
    local g2 = m_back["weapon"];
    local g3 = m_back["equipPiece"];
    local g4 = m_back["coatchip"];
    local g5 = m_back["other"];

    if(index <= #g1) then
        return g1, index;
    end

    if(index > #g1 and 
    	index <= (#g1 + #g2)) then
        return g2, index - #g1;
    end

    if(index > (#g1 + #g2) and 
    	index <= (#g1 + #g2 + #g3)) then
        return g3, index - (#g1 + #g2);
    end

    if(index > (#g1 + #g2 + #g3) and 
    	index <= (#g1 + #g2 + #g3 + #g4)) then
        return g4, index - (#g1 + #g2 + #g3);
    end

	if(index > (#g1 + #g2 + #g3 + #g4) and 
    	index <= (#g1 + #g2 + #g3 + #g4 + #g5)) then
        return g5, index - (#g1 + #g2 + #g3 + #g4);
    end
end

local function allPiece_bank( index )
    local g1 = m_back["equipPiece"];
    local g2 = m_back["coatchip"];

    if(index <= #g1) then
        return g1, index;
    end

    if(index > #g1 and 
    	index <= (#g1 + #g2)) then
        return g2, index - #g1;
    end
end

--根据tag值得到对应的数据
function getGoodsInfo( tag, index )
	--背包下
    if(tag == TAG_ALL) then
    	return allWhich_backpack(index);
    end

    if(tag == TAG_EQUIP) then
    	return getBackPackInfo("equip");
    end

    if(tag == TAG_WEAP) then
		return getBackPackInfo("weapon");
	end

	if(tag == TAG_PIECE) then
		return allPiece_backpack(index);
	end

	if(tag == TAG_OTHER) then
		return getBackPackInfo("other");
	end

	if(tag == TAG_EQUIP_PIECE) then
		return getBackPackInfo("equipPiece");
	end

	if(tag == TAG_COAT_PIECE) then
		return getBackPackInfo("coatchip");
	end


	--仓库
	if(tag == TAG_BANK_ALL) then
		return allWhich_bank(index);
	end

	if(tag == TAG_BANK_EQUIP) then
		return getBackInfo("equip");
	end

	if(tag == TAG_BANK_WEAPON) then
		return getBackInfo("weapon");
	end

	if(tag == TAG_BANK_PIECE) then
		return allPiece_bank(index);
	end

	if(tag == TAG_BANK_OTHER) then
		return getBackInfo("other");
	end

	if(tag == TAG_BANK_PIECE_EQUIP) then
		return getBackInfo("equipPiece");
	end

	if(tag == TAG_BANK_PIECE_COAT) then
		return getBackInfo("coatchip");
	end

	return nil;
end

--背包或仓库中某物品的id
function getDataId( tag, index )
    local datas, indexC = getGoodsInfo(tag, index);
    if(indexC) then
    	index = indexC;
    end
    if(datas) then
        if(datas[index]) then
            return datas[index].id;
        end
    end
    return 0;
end

function getOtherGoodsCount(id)
	local others = getBackPackInfo("other");
	for i,v in ipairs(others) do
		if(v.id == id) then
			return v.count;
		end
	end
	return 0;
end

function getCoatPieceCount(id)
	local piece = getBackPackInfo("coatchip");
	for i,v in ipairs(piece) do
		if(v.id == id) then
			return v.count;
		end
	end
	return 0;
end

function getEquipPieceCount(id)
	local piece = getBackPackInfo("equipPiece");
	for i,v in ipairs(piece) do
		if(v.id == id) then
			return v.count;
		end
	end
	return 0;
end

function getAncientCount( id )
	local ancients = UserInfoManager.getRoleInfo("ancientMaterial");
	for i,v in ipairs(ancients) do
		if(id == v.id) then
			return 1;
		end
	end
	return 0;
end

--是否有此类型的外套
function isCoatHave( id )
	local typeid = DataTableManager.getValue("coat_grow_Data", "id_" .. id, type);
	return Wardrobe.isCoatHave(typeid);
end

--得到碎片或者杂物的数量
function getGoodsCount( id )
	if(GoodsManager.isPiece(id)) then
		if(GoodsManager.isCoatPiece(id)) then
			return UserInfoManager.getCoatPieceCount(id);
		else
			return UserInfoManager.getEquipPieceCount(id);
		end
	elseif(GoodsManager.isAncient(id)) then
		return UserInfoManager.getAncientCount(id);
	elseif(GoodsManager.isCoat(id)) then
		if(isCoatHave(id)) then
			return 1;
		end
	elseif(GoodsManager.isOther(id)) then
		return UserInfoManager.getOtherGoodsCount(id);
	end
	return 0;
end

--得到角色身上某套装类型的装备数量
function getSameSuitTypeCount( suitType )
	local n = 0;
	local name = {"helmet", "armour", "necklace", "ring", "shoe", "trousers", "glove"};
	for i,v in ipairs(name) do
		local data = getRoleInfo(v);
		if(data.suitType == suitType) then
			n = n + 1;
		end
	end
	return n;
end

--所有物品总数量（装备、碎片、杂物）
function getTotalCount()
	return #m_backpack.equip + #m_backpack.equipPiece + #m_backpack.coatchip + #m_backpack.other;
end
function addNewAncientMeterial(id)
	table.insert(m_roleInfo["ancientMaterial"],{["id"] = id})
end
function isNewMaterial()
	local material = {}
	material.isNew = false
	material.id = tonumber(m_ancientMeterialId)
	if m_isGetNewAncientMaterial then
		material.isNew = true
	end
	m_isGetNewAncientMaterial = false
	return material
	-- UserInfoManager.isNewMaterial()isNew  id
end