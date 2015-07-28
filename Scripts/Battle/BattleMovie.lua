module("BattleMovie", package.seeall)

local MOVIE_STATE_NORMAL = 0;
local MOVIE_STATE_RELIVE = 1;
local m_movieState = MOVIE_STATE_NORMAL;

local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;

local m_movieData = nil;
local m_movieCallBack = nil;

local m_isSwapID = false;

local m_movieStep = 0;
local m_curFrame = 0;
local m_atkFrameInfo = nil;
local m_atkFrameCount = 0;
local m_defFrameInfo = nil;
local m_defFrameCount = 0;

local m_isAtkFrameEnd = false;
local m_isDefFrameEnd = false;


local m_skinID = nil;

local m_forbidDamage = false;

local m_roundEnd = false;

local m_selfHasBuff = false;
local m_enemyHasBuff = false;

local m_hasPrePhrase = false;
local m_battleStep = 1;
local m_needRelive = false;
function getBattleStep()
	return m_battleStep;
end
function setBattleStep(step)
	local curMovie = m_movieData[m_movieStep];
	if(step == 1)then
		BattleScene.setDefenserAction(curMovie.attacker, curMovie.defAnim);
	elseif(step == 2)then
		BattleScene.setAttackerAction(curMovie.attacker, curMovie.atkAnim);
	end
	m_battleStep = step;
end
local function toUnsignedByte(value)
	if (value > 127) then
		value = value - 256;
	end
	return value;
end

local function getKOInfo(data)
	-- CCLuaLog("revert koinfo to lua = " .. data);
	local info = {};
	info[BATTLE_KO_ATTACKER] = (bit.band(data, 2) > 0);
	info[BATTLE_KO_DEFENSER] = (bit.band(data, 1) > 0);
	info[BATTLE_KO_END] = (bit.band(data, 4) > 0);--回合是否结束
	info[BATTLE_KO_HAND_END] = (bit.band(data, 8) > 0);
	info[BATTLE_KO_DEF_VERTIGO] = (bit.band(data, 16) > 0);
	info[BATTLE_KO_ATK_VERTIGO] = (bit.band(data, 32) > 0);
	info[BATTLE_KO_DEF_DEAD] = (bit.band(data, 64) > 0);
	info[BATTLE_KO_ATK_DEAD] = (bit.band(data, 128) > 0);
	return info;
end

local function getFlagSecond(data)
	local flag = {};
	local value = 1;
	for i = 1, BATTLE_FLAG_SECOND_COUNT do
		if (bit.band(data, value) > 0) then
			flag[i] = true;
		else
			flag[i] = false;
		end
		value = value * 2;
	end
	return flag;
end

local function getFlag(data)
	local flag = {};
	local value = 1;
	for i = 1, BATTLE_FLAG_COUNT do
		if (bit.band(data, value) > 0) then
			flag[i] = true;
		else
			flag[i] = false;
		end
		value = value * 2;
	end
	return flag;
end

local function getBuff(buffList)
	for i, buff in ipairs(buffList) do
		buffList[i] = toUnsignedByte(buff);
	end
	return buffList;
end

local function getSkillID(action)
	-- if (attacker == 1) then
		return action.skillNum1, action.skillNum2;
	-- else
		-- return action.skillNum2, action.skillNum1;
	-- end
end

--获取人物本次出手的技能
--[[
@para isAttacker:本次出手是否是攻击方
@para isCrit    :是否是暴击
@para isHeave   :是否是重击
--]]
local function getAnimation(isAttacker,skillID,isCrit,isHeave)
	local anim = nil;
	if (skillID > 0) then
		anim = "skill_" .. skillID;
	else
		if(isAttacker) then
			if(isCrit == true and isHeave == true)then
				anim = "doublecrit";
			elseif((isCrit == true and isHeave == false) or (isCrit == false and isHeave == true))then
				if(isCrit)then
					anim = "crit";
				else
					anim = "heavy";
				end
			else
				math.randomseed(tostring(os.time()):reverse():sub(1, 6));
				local num = math.random(3);
				anim = "normal" .. num;
			end
		else
			anim = "null";
		end
	end
	return anim;
end

function setSkinID(index,cloth)
	if(m_skinID == nil)then
		m_skinID = {0,0};
	end
	m_skinID[index] = cloth;
	-- m_skinID[2] = 10;
	-- m_skinID = {10,10};
end

function setBattlerCamp(isPlayerOnLeft)
	m_isSwapID = isPlayerOnLeft;
end

local function getAttacker(id)
	if (m_isSwapID == true) then
		if (id == 1) then
			return 2;
		else
			return 1;
		end
	else
		return id;
	end
end

local function getDefenser(attacker)
	if (attacker == 1) then
		return 2;
	else
		return 1;
	end
end

local m_debugMode = false;
--flag所填写数字式以下几种数字的相加。但是有些东西是不能同时出现的。1暴击，2重击，4反击，8,闪避，16格挡，32是否是永久技能，64连击，128取消
--ko是四位二进制，1防御方死亡战斗结束,2攻击方死亡战斗结束,4本回合是否结束，属于预留位，暂时无用。8本次出手是否结束.
--bState 1是否是buff掉血掉死的 2是否出发技能下一次额外出手 4防御方眩晕 8攻击方眩晕
--所填数字为以上几个的加法，如有则加上相应的数字无则不加
local m_testTable = {
{cycle1=5,buffharm2=0,defDamage=0,defBuff={},cycle2=2,oncebuffharm1=0,flag=32,skillNum1=21030,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=0,vmpire1=0,attacker=2,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=3989,defBuff={},cycle2=2,oncebuffharm1=0,flag=1,skillNum1=0,vmpire2=0,oncebuffharm2=0,ko=0,skillNum2=21024,buffharm1=0,vmpire1=0,attacker=1,atkBuff={97},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=14557,defBuff={},cycle2=2,oncebuffharm1=0,flag=64,skillNum1=23012,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=0,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=2989,defBuff={},cycle2=2,oncebuffharm1=0,flag=2,skillNum1=0,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=0,vmpire1=0,attacker=2,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=3896,defBuff={},cycle2=2,oncebuffharm1=0,flag=2,skillNum1=21007,vmpire2=0,oncebuffharm2=0,ko=0,skillNum2=0,buffharm1=0,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=11557,defBuff={},cycle2=2,oncebuffharm1=0,flag=64,skillNum1=23002,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=0,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=13978,defBuff={},cycle2=2,oncebuffharm1=0,flag=0,skillNum1=23007,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=0,vmpire1=0,attacker=2,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=13989,defBuff={89},cycle2=2,oncebuffharm1=0,flag=1,skillNum1=21001,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=21019,buffharm1=0,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=1968,defBuff={},cycle2=2,oncebuffharm1=0,flag=4,skillNum1=0,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=0,vmpire1=0,attacker=2,atkBuff={-89},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=0,defBuff={},cycle2=2,oncebuffharm1=0,flag=0,skillNum1=21016,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=48970,vmpire1=0,attacker=2,atkBuff={83},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=5789,defBuff={},cycle2=2,oncebuffharm1=0,flag=3,skillNum1=0,vmpire2=0,oncebuffharm2=0,ko=0,skillNum2=0,buffharm1=0,vmpire1=0,attacker=2,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=19878,defBuff={},cycle2=2,oncebuffharm1=0,flag=64,skillNum1=23011,vmpire2=0,oncebuffharm2=0,ko=72,skillNum2=0,buffharm1=0,vmpire1=0,attacker=2,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=0,defBuff={},cycle2=2,oncebuffharm1=0,flag=0,skillNum1=21032,vmpire2=0,oncebuffharm2=0,ko=8,skillNum2=0,buffharm1=6786,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=0,defBuff={},cycle2=2,oncebuffharm1=0,flag=0,skillNum1=22012,vmpire2=0,oncebuffharm2=0,ko=0,skillNum2=0,buffharm1=0,vmpire1=0,attacker=1,atkBuff={18,113},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=10989,defBuff={},cycle2=2,oncebuffharm1=0,flag=3,skillNum1=21012,vmpire2=0,oncebuffharm2=0,ko=0,skillNum2=0,buffharm1=0,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
{cycle1=5,buffharm2=0,defDamage=66557,defBuff={},cycle2=2,oncebuffharm1=0,flag=64,skillNum1=23021,vmpire2=0,oncebuffharm2=0,ko=9,skillNum2=0,buffharm1=0,vmpire1=0,attacker=1,atkBuff={},atkDamage=0,bState=0},
};
--把服务端传过来的战斗过程转换成自己用的数据
function convert(processData)
	if(m_debugMode or BattleManager.isDebugMode()) then
		processData = m_testTable;
	end
	local loadSkillAniList = {};
	local movieData = {};
	local atkSkill = nil;
	local defSkill = nil;
	CCLuaLog(json.encode(processData));
	for i, action in ipairs(processData) do
		local oneData = {};
		CCLuaLog("***************************");
		CCLuaLog("step:" .. i);
		oneData.attacker = getAttacker(action.attacker);
		if (oneData.attacker ~= 0) then
			oneData.defDamage = action.defDamage;
			oneData.atkDamage = action.atkDamage;
			-- CCLuaLog("movieStep:" .. i .."ko=" .. action.ko);
			oneData.koInfo = getKOInfo(action.ko);
			if(oneData.koInfo ==nil)then
				CCLuaLog("movieStep:" .. i .."koinfo = nil");
			end
			CCLuaLog("movieStep:" .. i .."koinfo is not nil");
			-- local koin = action.ko;
			
			oneData.flagSecond = getFlagSecond(action.bState);
			oneData.flag = getFlag(action.flag);
			oneData.atkBuff = getBuff(action.atkBuff);
			oneData.defBuff = getBuff(action.defBuff);
			local temp = {oneData.atkBuff,oneData.defBuff};
			oneData.bufList = getBufList(temp);
			atkSkill, defSkill = getSkillID(action);
			oneData.relive = false;

			oneData.atkAnim = getAnimation(true,atkSkill, oneData.flag[BATTLE_FLAG_CRITICAL], oneData.flag[BATTLE_FLAG_HEAVY]);
			oneData.defAnim = getAnimation(false,defSkill, oneData.flag[BATTLE_FLAG_CRITICAL], oneData.flag[BATTLE_FLAG_HEAVY]);
			oneData.attackerBufHurt = action.buffharm1;
			oneData.defenserBufHurt = action.buffharm2;
			-- oneData.fetchHPRate = action.vmpirerate;
			oneData.atkFetch =action.vmpire1;
			oneData.defFetch = action.vmpire2;
			oneData.cycle1 = action.cycle1;
			oneData.cycle2 = action.cycle2;
			oneData.atkOnceHurt = action.oncebuffharm1;--一次性buf调血
			oneData.defOnceHurt = action.oncebuffharm2;
			oneData.extraAttTime = action.extraAttTime;

			local atkActionName = oneData.atkAnim .. "_" .. m_skinID[oneData.attacker];
			local defActionName = nil;
			if(oneData.defAnim ~= "null")then
				defActionName = oneData.defAnim .. "_" .. m_skinID[getDefenser(oneData.attacker)];
			end
			if (atkSkill > 0) then
				oneData.flag[BATTLE_FLAG_SKILL] = true;
			end
			oneData.atkFrameInfo = SkillData.getSkillData(atkActionName);
			local atkList = SkillData.getProperties(atkActionName).anis;
			if(atkList ~= nil)then
				increaseAniList(atkList,loadSkillAniList);
			end
			if(oneData.defAnim == "null")then
				oneData.defFrameInfo = nil;
			else
				oneData.defFrameInfo = SkillData.getSkillData(defActionName);
				local defList = SkillData.getProperties(defActionName).anis;
				if(defList ~= nil)then
					if(#defList ~= 0)then
						increaseAniList(defList,loadSkillAniList);
					end
				end
			end
			if(bit.band(processData[i].flag, 4) > 0) then
				oneData.atkAnim = "counter";
				oneData.atkFrameInfo = SkillData.getSkillData(oneData.atkAnim .. "_" .. m_skinID[oneData.attacker]);
			end

			oneData.prePhraseEnd = false;
			if(bit.band(processData[i].flag, 32) > 0)then
				if(action.skillNum1 == 0)then
					oneData.atkAnim = "null";
					oneData.atkFrameInfo = nil;
				end
				if(action.skillNum2 == 0)then
					oneData.defAnim = "null";
				end
				m_hasPrePhrase = true;
				if(bit.band(processData[i + 1].flag, 32) <= 0)then 
					-- oneData.koInfo[BATTLE_KO_HAND_END] = true;
					oneData.prePhraseEnd = true;
				end
			end
			if (i < #processData) then
				-- 如果连续出手则连击
				local fl = processData[i].flag;
				local f2 = processData[i+1].flag;
				-- CCLuaLog("movieStep:" .. i .. "flag=" .. fl);
				if (bit.band(processData[i+1].flag, 64) > 0) then
					oneData.interrupt = MOVIE_INTERRUPT_TYPE_COMBO;
				end
				-- 如果反击
				if (bit.band(processData[i + 1].flag, 4) > 0) then
					oneData.interrupt = MOVIE_INTERRUPT_TYPE_COUNTER;
				end
				-- 如果中断动作
				if (oneData.flag[BATTLE_FLAG_CANCEL] == true) then
					oneData.interrupt = MOVIE_INTERRUPT_TYPE_CANCEL;
				end

				-- if(processData[i].attacker == processData[i+1].attacker and processData[i].koInfo[]) then

				-- end

			end
			table.insert(movieData, oneData);
		end
	end
		BattleScene.setLoadAniList(loadSkillAniList);
    return movieData;
end

function increaseAniList(sourceList,destiList)
		for i,v in pairs(sourceList)do
			if(checkedAni(destiList,v) ~= true)then
				table.insert(destiList,v);
			end
		end
end
function checkedAni(list,name)
	for i,v in pairs(list)do
		if(v == name)then
			return true;
		end
	end
	return false;
end

function getBufList(data)
	local list = {};
	for i,v in pairs(data) do
		for m,n in pairs(v) do
			if(n > 0)then
				table.insert(list,n);
			end
		end
	end
	return list;
end

function getAttackType(flag)
	if(flag[BATTLE_FLAG_CRITICAL] and flag[BATTLE_FLAG_HEAVY] == true)then
		return 3;
	end
	if(flag[BATTLE_FLAG_CRITICAL])then
		return 1;
	end
	if(flag[BATTLE_FLAG_HEAVY])then
		return 2;
	end
	if(flag[BATTLE_FLAG_BLOCK])then
		return 4;
	end
	if(flag[BATTLE_FLAG_COUNTER])then
		return 5;
	end
	if(flag[BATTLE_FLAG_COMBO])then
		return 6;
	end
	return 0;
end
--播放帧动画的过程
local function doFrameAction(frameInfo)
	-- CCLuaLog("m_movieStep:" .. m_movieStep);
	local curMovie = m_movieData[m_movieStep];
	local attacker = curMovie.attacker;	
	local finalAttack = frameInfo.final;
	
	if (frameInfo.damage and (m_forbidDamage == false)) then
		local defDamage = curMovie.defDamage * frameInfo.damage;
		local superAttack = (curMovie.flag[BATTLE_FLAG_CRITICAL] == true and curMovie.flag[BATTLE_FLAG_HEAVY] == true);
		local finalAttack = frameInfo.final;
		-- if (curMovie.koInfo[BATTLE_KO_DEFENSER] == true and finalAttack == true) then
		-- 	BattleScene.finalHurt(attacker, defDamage, curMovie.damage);
		-- else
		local isFinal = false;
		if (curMovie.koInfo[BATTLE_KO_DEFENSER] == true and finalAttack == true) then
			isFinal = true;
		end
			--受伤害
		if (curMovie.flag[BATTLE_FLAG_AVOID] == true) then--如果闪避停止播放所有东西
			local counter = false;
			if (m_movieStep < #m_movieData) then
				counter = m_movieData[m_movieStep + 1].flag[BATTLE_FLAG_COUNTER];
			end
			BattleScene.avoidHurt(attacker, counter);
			m_isAtkFrameEnd = true;
			m_forbidDamage = true;
			return;
		end
			
		if(curMovie.atkFetch ~= 0)then--打人自己吸血
			local hp = frameInfo.damage*curMovie.atkFetch;
			BattleScene.fetchHpAttacker(curMovie.attacker,hp);
		end

		if(curMovie.defFetch ~= 0)then
			local hp = frameInfo.damage*curMovie.defFetch;--打别人，别人吸血
			BattleScene.fetchHpAttacker(getDefenser(curMovie.attacker),hp);
		end

		if(finalAttack == true)then
			if(curMovie.atkOnceHurt ~= 0)then--一次性buf攻击方
				BattleScene.onceDamage(curMovie.attacker,curMovie.atkOnceHurt);
			end
			if(curMovie.defOnceHurt ~= 0)then
				BattleScene.onceDamage(getDefenser(curMovie.attacker),curMovie.defOnceHurt);
			end
		end

		if(curMovie.koInfo[BATTLE_KO_ATK_DEAD] == true and finalAttack == true)then--反伤把自己反成濒死
			BattleScene.attackerWillDead(attacker);
			-- BattleScene.setAttackerDead(false);
			m_needRelive = true;
			m_movieData[m_movieStep + 1].relive = true;
			--准备复活
		end


		if(curMovie.koInfo[BATTLE_KO_DEF_DEAD] == true and finalAttack == true)then--把对方打成濒死
			BattleScene.defenserWillDead(attacker);
			m_movieData[m_movieStep + 1].relive = true;
			m_needRelive = true;
			--准备复活
		end

		if(curMovie.koInfo[BATTLE_KO_ATTACKER] == true and finalAttack == true)then--反伤反死了
			local atkDamage = curMovie.atkDamage * frameInfo.damage;
			BattleScene.attackerHurt(attacker, atkDamage, curMovie.koInfo[BATTLE_KO_ATTACKER]);
			BattleScene.finalFeedBack(attacker);
		end

		local attackType = FINAL_ATTACK_TYPE_NORMAL;--FINAL_ATTACK_TYPE_NORMAL
		if(frameInfo.final == true)then
			local isSpecil = false;
			if(frameInfo.isSpecil)then
				if(frameInfo.isSpecil == 1)then
					isSpecil = true;
				end
			end
			if(isSpecil ~= true)then--如果不是特殊运动走连击击飞否则击退的逻辑
				if(curMovie.interrupt ~= MOVIE_INTERRUPT_TYPE_COMBO)then
					if(m_movieStep > 1) then 
						if(m_movieData[m_movieStep - 1].interrupt == MOVIE_INTERRUPT_TYPE_COMBO) then
							attackType = FINAL_ATTACK_TYPE_CONTINUE;
						else
							attackType = FINAL_ATTACK_TYPE_BACK;
						end
					else
						attackType = FINAL_ATTACK_TYPE_BACK;
					end
				else
					attackType = FINAL_ATTACK_TYPE_FLY;
				end
			end
		end
		if(attackType == FINAL_ATTACK_TYPE_BACK) then
			if(curMovie.flag[BATTLE_FLAG_BLOCK])then
				frameInfo.mov = {vx = 17.2, ax = -0.1, vy = 0, ay = 0, t = 50};
			else
				frameInfo.mov = {vx = 13.2, ax = -0.1, vy = 0, ay = 0, t = 80};
				frameInfo.anim = "jidao";
				attackType = FINAL_ATTACK_TYPE_FLY;
			end
		end
		local defenser = getDefenser(attacker);
		local isVertigo = false;

		isVertigo = curMovie.flagSecond[BATTLE_FLAG_SECOND_DEF_VERTIGO];

		BattleScene.defenserHurt(attacker, defDamage, frameInfo.anim, frameInfo.mov, superAttack, curMovie.interrupt,attackType,isVertigo,isFinal,getAttackType(curMovie.flag));

		if (curMovie.atkDamage ~= 0) then--反伤 
			local atkDamage = curMovie.atkDamage * frameInfo.damage;
			BattleScene.attackerHurt(attacker, atkDamage, curMovie.koInfo[BATTLE_KO_ATTACKER]);
		end
	else
		local type = 0;
		if(finalAttack and frameInfo.mov)then--如果是上BUF技能
			BattleScene.setDefenserMov(attacker,frameInfo.mov,SKILL_MOVE_BUFF);
		elseif(finalAttack ~= true and frameInfo.mov)then
			BattleScene.setDefenserMov(attacker,frameInfo.mov,SKILL_MOVE_NORMAL);
		end

		if(frameInfo.anim ~="") then
			BattleScene.setDefenserAni(attacker,frameInfo.anim);
		end
	end
	
	if (frameInfo.special) then
		local data = frameInfo.special;
		if(data.sfx)then
			AudioEngine.playEffect(PATH_RES_AUDIO .. data.sfx, false);
		end 
		if(data.hit_sfx)then
			AudioEngine.playEffect(PATH_RES_AUDIO .. data.hit_sfx, false);
		end
		if(data.effect)then
			BattleScene.playAttackerEffect(curMovie.attacker, data.effect, data.eff_follow, data.eff_move_t, data.effPos);
		end
		if(data.hit_eff)then
			if (curMovie.flag[BATTLE_FLAG_AVOID] == false) then
				BattleScene.playDefenserEffect(curMovie.attacker, data.hit_eff, data.hitPos);
			end  
		end
	end
	if (frameInfo.move) then
		local data = frameInfo.move;
		BattleScene.moveAttacker(attacker, data.moveType, data.offset, data.offsetY, data.duration);
	end
	if (frameInfo.color) then
		local data = frameInfo.color;
		if (data.target == BATTLE_TURN_COLOR_SCREEN) then
			BattleScene.turnScreenColor(data.duration, {r = data.r, g = data.g, b = data.b, a = data.a});
		elseif (data.target == BATTLE_TURN_COLOR_ACTOR) then
			BattleScene.turnDefenserColor(attacker, data.duration, {r = data.r, g = data.g, b = data.b, a = data.a});
		end
	end
	if(frameInfo.shock_t) then--震屏
		BattleScene.shockScreen(frameInfo.shock_t);
	end
	if(frameInfo.buffList) then--这里只有攻击者才能上buf
		--判断buf服务器是否发送，是否触发
		local selfTemp = BattleScene.getSelfBuffLast(frameInfo.buffList);--技能中显示的buf
		local otherTemp = BattleScene.getOtherBuffLast(frameInfo.buffList);
		local self = checkedBuf(curMovie.bufList,selfTemp);--需要释放的buf
		local other = checkedBuf(curMovie.bufList,otherTemp);--bufList
		BattleScene.updateAtkBuff(attacker, self);--给自己上buf
		BattleScene.updateDefBuff(attacker, other);--给敌人上buf
	end
	if(frameInfo.scale)then
		BattleScene.modifyScale(frameInfo.scale);
	end
end

function checkedBuf(list,buf)--检查buf是否需要释
	local temp = {};
	for i,v in pairs(buf)do 
		for m,n in pairs(list)do
			if(v == n)then
				table.insert(temp,n);
				break;
			end
		end
	end
	return temp;
end

--播放防御方的光效
local function doDefFrameAction(frameInfo)
	local curMovie = m_movieData[m_movieStep];
	if (frameInfo.special) then
		local data = frameInfo.special;
		-- AudioEngine.playEffect(data.sfx, false);
		if(data.sfx)then
			AudioEngine.playEffect(PATH_RES_AUDIO .. data.sfx, false);
		end 
		BattleScene.playDefenserEffect(curMovie.attacker, data.effect, data.effPos);
	end
	if(frameInfo.buffList) then--这里只有攻击者才能上buf
		local selfTemp = BattleScene.getSelfBuffLast(frameInfo.buffList);--技能中显示的buf
		local otherTemp = BattleScene.getOtherBuffLast(frameInfo.buffList);
		local self = checkedBuf(curMovie.bufList,selfTemp);--需要释放的buf
		local other = checkedBuf(curMovie.bufList,otherTemp);--bufList
		BattleScene.updateAtkBuff(getDefenser(curMovie.attacker), self);--给自己上buf
		BattleScene.updateDefBuff(getDefenser(curMovie.attacker), other);--给敌人上buf

		-- local self = BattleScene.getSelfBuffLast(frameInfo.buffList);
		-- local other = BattleScene.getOtherBuffLast(frameInfo.buffList);
		-- BattleScene.updateAtkBuff(getDefenser(curMovie.attacker), self);--给自己上buf
		-- BattleScene.updateDefBuff(getDefenser(curMovie.attacker), other);--给敌人上buf
	end
end
local function updateBufHurt(data)--双方buff开场掉血
	local curMovie = m_movieData[m_movieStep];
	if(curMovie.attackerBufHurt == 0 and curMovie.defenserBufHurt ==0)then
		return;
	end
	BattleScene.buffHurt(curMovie.attacker,curMovie.attackerBufHurt,isAttacker);
	BattleScene.buffHurt(getDefenser(curMovie.attacker),curMovie.defenserBufHurt);
end

function stopBattle()
	stopMovie();
	m_movieCallBack();
end
--不断播放skillData里的frame
local function updateFrame(dt)
	local curMovie = m_movieData[m_movieStep];
	if((curMovie.koInfo[BATTLE_KO_ATK_DEAD] or curMovie.koInfo[BATTLE_KO_DEF_DEAD]) and curMovie.flagSecond[BATTLE_FLAG_SECOND_BUFF_DEAD])then
		-- BattleUI.setDefaultPortrait(curMovie.attacker);
		BattleScene.setBattleState(BATTLE_STATE_PREPARE_RELIVE);
		if(curMovie.koInfo[BATTLE_KO_ATK_DEAD])then
			BattleScene.attackerWillDead(curMovie.attacker);
		else
			BattleScene.buffFalseDead(getDefenser(curMovie.attacker));
		end
		BattleScene.setAniEnd();--强制动画结束
		m_movieData[m_movieStep + 1].relive = true;
		m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
		return;
	end


	if(getBattleStep() == 1) then--防御方播放防御技能状态
		if(m_defFrameInfo == nil)then
			m_isDefFrameEnd = true;
			setBattleStep(3);
			readyToAttack(curMovie);
			return;
		end
		m_curFrame = m_curFrame + 1;
		if (m_isDefFrameEnd ~= true) then
			-- CCLuaLog("m_isDefFrame Start!");
			-- CCLuaLog("m_defFrameCount:" .. m_defFrameCount);	
			while (m_defFrameInfo[m_defFrameCount].frame <= m_curFrame) do		
				doDefFrameAction(m_defFrameInfo[m_defFrameCount]);
				m_defFrameCount = m_defFrameCount + 1;
				if (m_defFrameCount > (#m_defFrameInfo)) then
					m_isDefFrameEnd = true;
					setBattleStep(3);
					readyToAttack(curMovie);
					BattleScene.setDefaultAniActor(curMovie.attacker,false);
					break;
				end
			end
		end

	elseif(getBattleStep() == 2)then
		m_curFrame = m_curFrame + 1;
		if (m_isAtkFrameEnd ~= true) then
			while (m_atkFrameInfo[m_atkFrameCount].frame <= m_curFrame) do
				doFrameAction(m_atkFrameInfo[m_atkFrameCount]);
				m_atkFrameCount = m_atkFrameCount + 1;
				if (m_atkFrameCount > (#m_atkFrameInfo)) then
					m_isAtkFrameEnd = true;
					BattleScene.setDefaultAniActor(curMovie.attacker,true);
					break;
				end
			end
		end
	end
	
	if ((m_isDefFrameEnd == true and m_isAtkFrameEnd == true)) then
		m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
		m_selfHasBuff = false;
		m_enemyHasBuff = false;
		BattleScene.setClearBuffData(curMovie.attacker, curMovie.atkBuff, curMovie.defBuff);
		if (m_movieStep > #m_movieData) then
			return;
		end	
		local curMovie = m_movieData[m_movieStep];

		if(curMovie.prePhraseEnd)then--永久技能播放完毕
			BattleScene.setBattleState(BATTLE_STATE_BEGIN);
			return;
		end
		-- if(m_needRelive)then
		-- 	--需要复活状态
		-- 	m_needRelive = false;
		-- 	BattleUI.setDefaultPortrait(curMovie.attacker);
		-- 	BattleScene.setBattleState(BATTLE_STATE_RELIVE);
		-- 	return;

		-- end
		--如果回合结束进入下一回合阶段，否则继续出手
		if(curMovie.koInfo[BATTLE_KO_HAND_END]) then 
			-- BattleScene.setBattleState(BATTLE_STATE_WAIT);
			if(m_needRelive)then
			--需要复活状态
				m_needRelive = false;
				-- BattleUI.setDefaultPortrait(curMovie.attacker);
				BattleScene.setBattleState(BATTLE_STATE_PREPARE_RELIVE);
				return;
			end
			if(curMovie.relive)then--本次复活
				-- BattleUI.setDefaultPortrait(curMovie.attacker);
		 		BattleScene.setBattleState(BATTLE_STATE_RELIVE);
		 		return;
			end
			local ticker = m_movieStep;
			-- if(m_movieStep >= 1) then
			-- 	if(m_movieData[m_movieStep - 1] ~= nil)then
			-- 		if(m_movieData[m_movieStep - 1].interrupt ~= MOVIE_INTERRUPT_TYPE_COUNTER) then
			-- 			BattleUI.setDefaultPortrait(curMovie.attacker);
			-- 		else
			-- 			BattleUI.setDefaultPortrait(m_movieData[m_movieStep - 1].attacker);
			-- 		end
			-- 	else
			-- 		BattleUI.setDefaultPortrait(curMovie.attacker);
			-- 	end
			-- end
			if(curMovie.extraAttTime == 1)then--如果需要暂停时间轴
				BattleScene.setBattleState(BATTLE_STATE_PAUSE_ROLL);
				return;
			end
			if(curMovie.koInfo[BATTLE_KO_END]) then
				-- BattleUI.setDefaultRoller();--重置回合滚动条
				BattleUI.updateRound();
				-- if()then

				-- end
				BattleScene.setBattleState(BATTLE_STATE_WAIT);
			else
				BattleScene.setBattleState(BATTLE_STATE_WAIT);
			end
		else
			if(curMovie.interrupt == MOVIE_INTERRUPT_TYPE_COUNTER) then
				BattleScene.setBattleState(BATTLE_STATE_COUNTER);
			else
				BattleScene.setBattleState(BATTLE_STATE_ATTACK);
			end
		end
	end

end

function stopMovie()
	if( m_schedulerEntry ~= nil) then
		m_movieStep = 0;
		m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
	end
end	

--开始战斗
local function startAttack()
	local curMovie = m_movieData[m_movieStep];
	CCLuaLog("startAttack!");
	BattleScene.setPlayAttackAnim(true);
	--技能数据
	m_atkFrameInfo = curMovie.atkFrameInfo;
	--显示技能名称
	local skillID = curMovie.atkAnim .. "_" .. m_skinID[curMovie.attacker];
	setBattleStep(2);
	m_curFrame = 0;
	BattleScene.showSkillLabel(curMovie.attacker, skillID);
end


--重击，连击，暴击等等。根据flag判断
local function startAttackWithFlip()
	BattleScene.flipAttacker(m_movieData[m_movieStep].attacker);
	startAttack();
end

local function normalAttack(attacker, offsetX)
	CCLuaLog("普通攻击！");
	local distance = BattleScene.getWorldDistance();

	if (distance > offsetX) then
		BattleScene.attackerRun(attacker, offsetX, startAttack);
	else
		startAttack();
	end
end

local function getOffsetX(skillID)
	local properties = SkillData.getProperties(skillID);
	return properties.distance;
end

--准备攻击
function readyToAttack(curData)
	local attacker = curData.attacker;
	local flag = curData.flag;
	if(curData.atkAnim == "null")then--如果攻击方技能是空，表示没有战前永久技能，播放下一条数据 
		-- BattleScene.setBattleState(BATTLE_STATE_ATTACK);
		m_isAtkFrameEnd = true;
	else
		local offsetX = getOffsetX(curData.atkAnim .. "_" .. m_skinID[attacker]);
		-- BattleScene.setDefaultHeightAttacker(attacker);
		normalAttack(attacker, offsetX);
	end
end

--更新一个回合
local function updateMovie()
	m_forbidDamage = false;
	-- m_movieStep = m_movieStep + 1;
	if (m_movieStep + 1 > #m_movieData) then
		m_movieCallBack();
		return;
	end
	m_movieStep = m_movieStep + 1;
	CCLuaLog("the battledata length is " .. #m_movieData);
	CCLuaLog("the battledata step is " .. m_movieStep);
	local curMovie = m_movieData[m_movieStep];
	BattleUI.setSpeed(1,curMovie.cycle1);
	BattleUI.setSpeed(2,curMovie.cycle2);
	m_curFrame = 0;
	m_isAtkFrameEnd = false;
	m_isDefFrameEnd = false;
	m_atkFrameCount = 1;
	m_defFrameCount = 1;
	setBattleStep(1);
	BattleScene.setDefenserAction(curMovie.attacker, curMovie.defAnim);
	updateBufHurt(curMovie);

	if((curMovie.koInfo[BATTLE_KO_DEFENSER] or curMovie.koInfo[BATTLE_KO_ATTACKER]) and curMovie.flagSecond[BATTLE_FLAG_SECOND_BUFF_DEAD])then
		if(curMovie.koInfo[BATTLE_KO_DEFENSER])then
			BattleScene.buffDead(getDefenser(curMovie.attacker));
		else
			BattleScene.buffDead(curMovie.attacker);
		end
		return
	end
	m_schedulerEntry = m_scheduler:scheduleScriptFunc(updateFrame, 0, false);
	m_defFrameInfo = curMovie.defFrameInfo;
	-- readyToAttack(curData);
end


--播放战斗（开始，开始战斗，战斗结束）
function playMovie(movieType, movieData, cbFunc)
	m_movieStep = 0;
    if (movieType == BATTLE_MOVIE_BENGIN) then
    	CCLuaLog("BATTLE_MOVIE_BENGIN!")
        BattleScene.playBegin(cbFunc);
    elseif (movieType == BATTLE_MOVIE_ATTACK) then
    	CCLuaLog("BATTLE_MOVIE_ATTACK!")
    	m_movieData = movieData;
        m_movieCallBack = cbFunc;
        BattleScene.setAttackCallbackFunc(updateMovie);
        if(m_hasPrePhrase)then
        	BattleUI.setState(UI_STATE_NONE);--停止ui对流程的影响,播放永久技能
        	updateMovie();
        else
        	BattleUI.setState(UI_STATE_INTERVAL);
        end
        
        -- updateMovie();
    elseif (movieType == BATTLE_MOVIE_END) then
    	CCLuaLog("BATTLE_MOVIE_END!")
        BattleScene.playEnd(movieData, cbFunc);
    end
end

function continueNext()
	local curData = m_movieData[m_movieStep];
	BattleScene.setBattleState(BATTLE_STATE_NONE);
	readyToAttack(curData);
end
function getDefIndex()
local attacker = m_movieData[m_movieStep].attacker;
	return attacker;
end

