module("BattleActor", package.seeall)

local faceMap = {cloth11={}};
function create(resName, posX, posY, actorType)
	CCLuaLog("animation " .. resName .. " is null");
	local actor = SJBattleActor:create(resName);
	tolua.cast(actor, "CCNode"):setPosition(CCPoint(posX, posY));

	return actor;
--	return actor;
end

function creteActorData(actorType)
	local actorData = {};
	actorData.hp = 0;
	actorData.hpMax = 0;
	actorData.type = actorType;
	actorData.targetPos = CCPoint(0, 0);
	actorData.hasAttacked = false;
	actorData.buff = {};
	actorData.dead = false;--是否死亡
	actorData.willDead = false;--是否濒死
	actorData.skillDisEnd  = false;
	actorData.isVertiGo = false;--人物是否眩晕
	actorData.stop = SKILL_MOVE_DAMAGE;--人物是否没有被打但是还要使用mov
	actorData.cycle = 0;
	local buffCount = BattleBuff.getBuffCount();
	for i = 1, buffCount do
		table.insert(actorData.buff, {});
	end

	return actorData;
end	

function setPlayerSkin(actorData)
	actorData.skin = {};
	actorData.skin["hairFront"] = UserInfoManager.getFaceInfo("hair");
	actorData.skin["hairBack"] = UserInfoManager.getFaceInfo("hair");
	actorData.skin["face"] = UserInfoManager.getFaceInfo("face");
	actorData.skin["cloth"] = UserInfoManager.getRoleInfo("coat").type;
	actorData.skin["color"] = UserInfoManager.getFaceInfo("hair_color").r;
	if(BattleManager.isDebugMode())then
		actorData.skin["cloth"] = 11;
	end
	-- actorData.skin["hairFront"] = 1
	-- actorData.skin["hairBack"] = 1
	-- actorData.skin["face"] = 1
	-- actorData.skin["cloth"] = 11
	actorData.skin["sex"] = "Male";
end

function setEnemySkin(actorData, skinData)
	actorData.skin = {};
	actorData.skin["hairFront"] = skinData.hair;
	actorData.skin["hairBack"] = skinData.hair;
	actorData.skin["face"] = skinData.face;
	actorData.skin["cloth"] = skinData.cloth;
	actorData.skin["color"] = skinData.color;
	if(skinData.cloth == 0) then
		actorData.skin["cloth"] = 12;
	end


	-- actorData.skin["hairFront"] = 1;
	-- actorData.skin["hairBack"] = 1;
	-- actorData.skin["face"] = 10;
	-- actorData.skin["cloth"] = 730022;
	-- actorData.skin["color"] = 5;
	actorData.skin["sex"] = "Male";
end

function getSkin(actorData)
	return actorData.skin;
end

function setTargetPos(actorData, x, y)
	actorData.targetPos.x = x;
	actorData.targetPos.y = y;
end

function setTargetPosX(actorData, x)
	actorData.targetPos.x = x;
end

function getTargetPosX(actorData)
	return actorData.targetPos.x;
end

function setEffectData(actorData, buff, index, object)
	actorData.buff[buff][index] = object;
end

function hasEffectData(actorData, buff, index)
	if(actorData.buff[buff][index] ~= nil)then
		return true;
	end
	return false;
end

function getEffectData(actorData, buff, index)
	return actorData.buff[buff][index];
end