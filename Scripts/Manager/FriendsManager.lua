--
-- Author: Gao Jiefeng
-- Date: 2015-03-27 13:06:29
--
module("FriendsManager", package.seeall)
local m_resultCN = {
	"请求好友不存在",   --1
	"请求发送成功",		--2
	"自己已满",			--3
	"对方已满",			--4
	"两者都满",			--5
	"添加成功",			--6
	"对方已是好友",		--7
	"邮件发送成功",		--8
	"礼物发送成功",		--9
	"请求已经发过",     --10
	"不能为自己",		--11
	"推荐成功",			--12
	"在线玩家太少",		--13
	"珍藏成功",			--14
	"删除好友成功",		--15
	"切磋完成",			--16
	"接受成功",			--17
	"邮件删除成功",		--18
	"不能加自己为好友", --19
	"取消珍藏", 		--20
	"拒绝成功",			--21
	"礼物为空",			--22
};

local m_friendsList = {}
local m_appllyList  	= {}
local m_friendOperateHandler = nil
local m_giftDatas = {}
local m_recommandList = {}
local m_recommandCallBack = nil
local m_freindDetailData = {}
local m_friendDetailCallback = nil
--静态数据
function getFriendList()
	return m_friendsList 
end
function getApplyList()
	return m_appllyList
end

function getGiftsData()
	return m_giftDatas
end
function getRecommandListData(callback)	
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_REQUESTRECOMMEND, {});	
	m_recommandCallBack = callback
end
--网络回调 
local function onRecieveFriendList(messageType,messageData)--好友列表
	m_friendsList = messageData
end
local function onRecieveFriendOperate(messageType, messageData) --好友操作
	local operateId = messageData.operateId
	local resultId  = messageData.resultId
	refresh(operateId,resultId)
	Util.showOperateResultPrompt(m_resultCN[resultId])
end
local function onRecieveApplyList(messageType, messageData) --好友申请列表
	m_appllyList = messageData
	NotificationManager.onLineCheck("FriendsManager")
end
local function onRecieveGiftList(messageType, messageData)--接收礼物列表
	m_giftDatas = messageData
	NotificationManager.onLineCheck("FriendsManager")
end

function onRecieveRecommandList(messageType, messageData)--接收好友推荐
	m_recommandList = messageData
	m_recommandCallBack(m_recommandList)
	m_recommandCallBack= nil
end
local function onRecieveFriendDetail(messageType, messageData)--接收好友详细信息
	m_freindDetailData = messageData
	local tempDetail = json.decode(m_freindDetailData["friend_detail"])
	if tempDetail.isOk ==1 then
		local equips = {}

		for i=1,7 do
			if tempDetail.equips[tostring(i)] == nil then 
				equips[i] = {["id"]=0}
			else
				equips[i] = {
						["id"] 				= tempDetail["equips"][tostring(i)].id,
						["name"] 			= tempDetail["equips"][tostring(i)].name,
						["color"] 			= tempDetail["equips"][tostring(i)].color,
						["level"] 			= tempDetail["equips"][tostring(i)].level,
						["strenLV"] 		= tempDetail["equips"][tostring(i)].strenLV,
						["upstepLV"] 		= tempDetail["equips"][tostring(i)].upstepLV,
						["soulLV"] 			= tempDetail["equips"][tostring(i)].soulLV,
						["suitType"] 		= tempDetail["equips"][tostring(i)].suitType,
						["soulCharacter"] 	= tempDetail["equips"][tostring(i)].soulChac,
						["wuxingPros"] 		= tempDetail["equips"][tostring(i)].wuxingProsStr,
						["additionProval"] 	= tempDetail["equips"][tostring(i)].additionProVal,
						["baseProval"] 		= tempDetail["equips"][tostring(i)].baseProValue,
						["baseProid"] 		= tempDetail["equips"][tostring(i)].baseProId,
						["soulPro"]			= tempDetail["equips"][tostring(i)].soulPro,
						["wuxingPro"] 		= tempDetail["equips"][tostring(i)].wuxingPro,
						["soulPros"] 		= tempDetail["equips"][tostring(i)].soulProsStr,
						["soulVals"] 		= tempDetail["equips"][tostring(i)].soulValsStr,
						}
			end
		end
		local m_roleInfo = {
			name     = tempDetail["player"].name,
			level    = tempDetail["player"].level,
			vipLv    = 0,
			gold     = 0,
			exp      = 0,
			physic   = 0,
			diamond  = 0,
			fight    = tempDetail["player"].battleValue,
			groupid  = 6,
			preExp   = 0,
			preLevel = 0,
			faceid   = tempDetail["player"].faceId,
			hairid   = tempDetail["player"].hairId,
			hairColor= tempDetail["player"].hairColor,
			coat     = tempDetail["player"].coatId,--{type = 0},
			weapon   = {
						["id"]			=tonumber(tempDetail["weapon"].id),	
						["character"]	=tonumber(tempDetail["weapon"].charactorl),
						["step"]		=tonumber(tempDetail["weapon"].step),
						["star"]		=tonumber(tempDetail["weapon"].star),
						["atk"]			=tonumber(tempDetail["weapon"].atk),
						["proId"]		=tostring(tempDetail["weapon"].proid),
						["proLV"]		=tostring(tempDetail["weapon"].proLV),	
						["proValue"] 	=tostring(tempDetail["weapon"].proVal),
						["skill"]		=tonumber(tempDetail["weapon"].skill),
						["class"]		=tonumber(tempDetail["weapon"].cls),
						["atkPer"]		=tonumber(tempDetail["weapon"].atkPer),		
						["exp"]			=tonumber(tempDetail["weapon"].exp),
						},


			fashionCoat = {id = 0},

			helmet   = equips[1],
			armour   = equips[2],
			ring     = equips[3],
			necklace = equips[4],
			shoe     = equips[5],
			glove    = equips[6],
			trousers = equips[7],
			
			uid =  tempDetail["player"].uuid,
			firstPro = {
					["strength"]	=tonumber(tempDetail["player"].strength),
					["agility"]		=tonumber(tempDetail["player"].agility),
					["endurance"]	=tonumber(tempDetail["player"].endurance),

			},--{}, --一级属性
			secondPro= {
						["atk"]			=tonumber(tempDetail["player"].attack),
						["def"]			=tonumber(tempDetail["player"].defense),
						["hp"] 			=tonumber(tempDetail["player"].hp),
						["speed"]		=math.floor(tonumber(tempDetail["player"].speed)),
						["bash"]		=tonumber(tempDetail["player"].bash),
						["crit"]		=tonumber(tempDetail["player"].crit),
						["counterAtk"]	=tonumber(tempDetail["player"].counterAttack ),
						["parry"]		=tonumber(tempDetail["player"].parry),
						["dodge"]		=tonumber(tempDetail["player"].dodge)
					},--{}, --二级属性
			combatRate = {
						["bashRate"]	=tostring(tempDetail["player"].bashRate),
						["critRate"]	=tostring(tempDetail["player"].critRate),
						["parryRate"]	=tostring(tempDetail["player"].parryRate),
						["dodgeRate"]	=tostring(tempDetail["player"].dodgeRate),
						["noHurtRate"]	=tostring(tempDetail["player"].noHurtRate),
						["counterRate"]	=tostring(tempDetail["player"].counterRate),
					},

		}

		m_friendDetailCallback(m_roleInfo)
		m_roleInfo = nil
		m_friendDetailCallback= nil
	else
		if tempDetail.errorInfo == "1" then 
			Util.showOperateResultPrompt("玩家不在线，无法查看详细信息")	
		elseif tempDetail.errorInfo == "2" then
			Util.showOperateResultPrompt("好友不存在")	
		end


	end



end


--网络申请
function applyAddFriendBySearch(name,addType,callback) --添加好友
	m_friendOperateHandler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_REQUESTFRIEND, {name,addType});	 
end

function giftFriend(userID,callback)--好友送礼
	m_friendOperateHandler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_SENDGOODS, {userID});		
end

function deleteFriend(userID,callback)--删除好友
	m_friendOperateHandler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_DELETEFRIEND, {userID});		
end
function acceptFriend(userID,callback)--接受好友
	m_friendOperateHandler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_ADDFRIEND, {userID});		
end
function rejectFriend(userID,callback) --拒绝好友请求
	m_friendOperateHandler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_REFUSEFRIEND, {userID});		
end

function acceptGift(giftId,callback) --接受礼物
	m_friendOperateHandler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_RECEIVEGIFT, {giftId});	
end

function oneKeyGetAllGift(callback) --一键收取礼物
	m_friendOperateHandler = callback
	local giftIds = ""
	for k,v in pairs(m_giftDatas) do	
		giftIds = giftIds..v.giftId..","		
	end
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_RECEIVEGIFT, {giftIds});	
end

function oneKeyGiveGifts(callback)	--一键送礼
	m_friendOperateHandler = callback
	local allFriendIds = ""
	for k,v in pairs(m_friendsList) do	
		allFriendIds = allFriendIds..v.id..","		
	end
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_FRIEND_SENDGOODS, {allFriendIds});		
end
function getFriendDetail(userId,calback)--请求用户详细信息
	m_friendDetailCallback= calback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_GET_FRIEND_DETAIL, {userId});
end	



function refresh( operateId ,resultId)
	--操作id
	local OPE_APPLY 		= 1; --申请好友
	local OPE_ADD   		= 2; --添加好友
	local OPE_RECOMMEND  	= 3; --推荐好友
	local OPE_MARK			= 4; --标记好友
	local OPE_DEL_FRI		= 5; --删除好友
	local OPE_SEND_GIFT		= 6; --发送礼物
	local OPE_FIGHT			= 7; --切磋好友
	local OPE_RECEIVE_GIFT  = 8; --接收礼物
	local OPE_SEND_MAIL		= 9; --发送邮件
	local OPE_DELTE_MAIL	= 10;--删除邮件
	local OPE_REFUSE_FRIEND	= 11;--拒绝添加

	if(operateId == OPE_APPLY) then
		if resultId == 2 then
			m_friendOperateHandler(2)
			m_friendOperateHandler = nil
			-- Util.showOperateResultPrompt("申请好友成功")
		else
			-- Util.showOperateResultPrompt("申请好友未成功")
		end		
	--申请好友
	elseif(operateId == OPE_ADD) then
		if resultId == 6 then
			if m_friendOperateHandler~= nil then 
				m_friendOperateHandler(2)
				m_friendOperateHandler = nil
			end
			-- Util.showOperateResultPrompt("添加好友成功")
		else
			-- Util.showOperateResultPrompt("添加好友未成功")
		end
	--添加好友
	elseif(operateId == OPE_REFUSE_FRIEND) then
		if resultId == 21 then
			m_friendOperateHandler(2)
			m_friendOperateHandler = nil
			-- Util.showOperateResultPrompt("拒绝好友成功")
		else
			-- Util.showOperateResultPrompt("拒绝好友未成功")
		end		
	--拒绝添加
	elseif(operateId == OPE_RECOMMEND) then
	--推荐好友
	elseif(operateId == OPE_MARK) then
	--标记好友
	elseif(operateId == OPE_SEND_GIFT) then
		if resultId == 9 then
			m_friendOperateHandler(1)
			m_friendOperateHandler = nil
			-- Util.showOperateResultPrompt("给好友送礼成功")
		else
			-- Util.showOperateResultPrompt("给好友送礼未成功")
		end			
	--发送礼物
	elseif(operateId == OPE_RECEIVE_GIFT) then
		if resultId == 17 then
			m_friendOperateHandler(3)
			m_friendOperateHandler = nil
			-- Util.showOperateResultPrompt("接受成功")
		else
			-- Util.showOperateResultPrompt("接受未成功")
		end			
	--接收礼物
	elseif(operateId == OPE_DEL_FRI) then
		if resultId == 15 then
			m_friendOperateHandler(1)
			m_friendOperateHandler = nil
			-- Util.showOperateResultPrompt("删除好友成功")
		else
			-- Util.showOperateResultPrompt("删除好友未成功")
		end		
	--删除好友
	elseif(operateId == OPE_DELTE_MAIL) then
	--删除邮件
	elseif(operateId == OPE_SEND_MAIL) then
	--发送邮件
	end
end
function checkNotification()
	if #m_giftDatas~= 0 then 
		return true
	end
	if #m_appllyList~= 0 then
		return true
	end
	return false
end
function checkNotification_login()
    return checkNotification()
end
function checkNotification_line()
    return checkNotification()
end
function checkNotification_close()
    return checkNotification()
end
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FRIEND_FRIENDLIST, onRecieveFriendList);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FRIEND_OPERATIONRESPONS, onRecieveFriendOperate);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FRIEND_REQUESTLIST, onRecieveApplyList);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FRIEND_GIFTLIST, onRecieveGiftList);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FRIEND_RECOMMENDLIST, onRecieveRecommandList);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_FRIEND_DETAIL, onRecieveFriendDetail);


-- m_recommandList = {}

-- m_recommandList[1]={["id"]= "aaaaaaaa1",["name"]="名称1",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=2,["hair"]=2,["haircolor"]=1,["face"] = 2,["coat"] = 1}
-- m_recommandList[2]={["id"]= "aaaaaaaa2",["name"]="名称2",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=1,["hair"]=2,["haircolor"]=3,["face"] = 4,["coat"] = 5}
-- m_recommandList[3]={["id"]= "aaaaaaaa3",["name"]="名称3",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=3,["hair"]=4,["haircolor"]=5,["face"] = 6,["coat"] = 7}
-- m_recommandList[4]={["id"]= "aaaaaaaa4",["name"]="名称4",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=2,["hair"]=7,["haircolor"]=8,["face"] = 9,["coat"] = 10}
-- m_recommandList[5]={["id"]= "aaaaaaaa5",["name"]="名称5",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=2,["hair"]=11,["haircolor"]=2,["face"] = 4,["coat"] = 9}
-- m_recommandList[6]={["id"]= "aaaaaaaa6",["name"]="名称6",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=2,["hair"]=2,["haircolor"]=1,["face"] = 2,["coat"] = 1}
-- m_recommandList[7]={["id"]= "aaaaaaaa7",["name"]="名称7",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=2,["hair"]=2,["haircolor"]=1,["face"] = 2,["coat"] = 1}
-- m_recommandList[8]={["id"]= "aaaaaaaa8",["name"]="名称8",["level"]=2,["jjcGroupId"]= 1,["jjcRanking"]=2,["hair"]=2,["haircolor"]=1,["face"] = 2,["coat"] = 1}
--好友send
-- NETWORK_MESSAGE_SEND_FRIEND_REQUEST = 656取消
-- NETWORK_MESSAGE_SEND_FRIEND_MARK = 658  --标记好友{id, 是否标记}
-- NETWORK_MESSAGE_SEND_FRIEND_SENDGOODS = 660 --发送礼物 {id}
-- NETWORK_MESSAGE_SEND_FRIEND_SENDMAIL = 662--取消
-- NETWORK_MESSAGE_SEND_FRIEND_DELETEFRIEND = 664删除好友{id}
-- NETWORK_MESSAGE_SEND_FRIEND_FIGHT = 666好友切磋 --取消
-- NETWORK_MESSAGE_SEND_FRIEND_REQUESTFRIEND = 668申请好友{name,1：自己搜索，2：系统推荐}
-- NETWORK_MESSAGE_SEND_FRIEND_REQUESTRECOMMEND = 670 申请系统推荐 {}
-- NETWORK_MESSAGE_SEND_FRIEND_ADDFRIEND = 672添加好友{id}
-- NETWORK_MESSAGE_SEND_FRIEND_RECEIVEGIFT = 674--接受礼物{gift id}
-- NETWORK_MESSAGE_SEND_FRIEND_DELETEMAIL = 676取消
-- NETWORK_MESSAGE_SEND_FRIEND_REFUSEFRIEND = 678拒绝好友{id}
-- NETWORK_MESSAGE_SEND_GET_FRIEND_DETAIL      = 3100 --好友详细信息

-- --好友receive
-- NETWORK_MESSAGE_RECEIVE_FRIEND_FRIENDLIST = 2107 {id：id	name:名称,level	级别	jjcGroupId	:竞技场分组		jjcRanking	:竞技场排名	 isMark	:是否要珍藏	isSendGift	:是否已送礼	,coat	:外套	face	：脸型	hair：发型	hairColor：	发色}
-- NETWORK_MESSAGE_RECEIVE_FRIEND_REQUESTLIST = 2109 {id	id	name	名称	level	级别	jjcGroupId	竞技场分组	jjcRanking	竞技场排名}
-- NETWORK_MESSAGE_RECEIVE_FRIEND_RECOMMENDLIST = 2111 {id	id	name	名称	level	级别	jjcGroupId	竞技场分组	jjcRanking	竞技场排名}
-- NETWORK_MESSAGE_RECEIVE_FRIEND_GIFTLIST = 2113{string	senderid	发送者id	string	name	名称	byte	level	级别	byte	jjcGroupId	竞技场分组	string	time	发送时间	int	giftId	礼物id	int	itemID	赠送的道具ID	int	itemNum	赠送的道具数量}
-- NETWORK_MESSAGE_RECEIVE_FRIEND_MAILLIST = 2115
-- NETWORK_MESSAGE_RECEIVE_FRIEND_OPERATIONRESPONS = 2117{byte	operateId	操作id	byte	resultId	返回结果}
-- NETWORK_MESSAGE_RECEIVE_FRIEND_DETAIL		= 3101  好友详细信息