module("SaoDangManager", package.seeall)

local m_data = nil;
local m_callBack = nil;
function registerMessage()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_SAODANG_REWARD, Response);
end

function Response(messageType, messageData)
	m_data = convertMessage(messageData);
	UIManager.open("SweepReward");
	SweepDetail.setTimes();

    local newMaterialData = UserInfoManager.isNewMaterial()
    if newMaterialData.isNew then
        AncientMaterialItem.playGetAncientEffect(newMaterialData["id"])
    end	
end

function getData()
	return m_data;
end

function setCallBack(fun)
	m_callBack = fun;
end

function convertMessage(messageData)
	local dataList = {};
	for i,v in pairs(messageData)do
		local data = {};
		data.money = 0;
		data.exp = 0;
		data.list = {};
		for j=1, #v.list do
			if(Util.getRemainder(j,2) == 1)then
				if(v.list[j] == 1)then
					data.money = v.list[j+1];
				elseif(v.list[j] == 2)then
					data.exp = v.list[j+1];
				else
					local temp = {v.list[j],v.list[j+1]};
					table.insert(data.list,temp);
				end
			end
		end
		table.insert(dataList,data);
	end
	return dataList;
end