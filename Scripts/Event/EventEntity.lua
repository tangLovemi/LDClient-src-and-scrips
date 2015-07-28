module("EventEntity", package.seeall)

local function setJudgeActionData(actions)
	local stack = {};
	local lastAction = nil;

	for i, action in ipairs(actions) do
		if (action.type == EVENT_ACTION_IFBETWEEN) then
			action.data["jump"] = i;
			table.insert(stack, action);
		elseif (action.type == EVENT_ACTION_IF) then
			action.data["jump"] = i;
			table.insert(stack, action);
		elseif (action.type == EVENT_ACTION_ELSE) then
			lastAction = stack[#stack];
			lastAction.data.jump = i - lastAction.data.jump;
			action.data["jump"] = i;
			stack[#stack] = action;
		elseif (action.type == EVENT_ACTION_END) then
			lastAction = stack[#stack];
			lastAction.data.jump = i - lastAction.data.jump;
			table.remove(stack);
		end
	end
end

local function convertTriggerType(triggerType)
	if (triggerType == "tap_actor") then
		return EVENT_TRIGGER_TAP_ACTOR;
	elseif (triggerType == "enter_range") then
		return EVENT_TRIGGER_ENTER_RANGE;
	elseif (triggerType == "move_vertical") then
		return EVENT_TRIGGER_MOVE_VERT;
	elseif (triggerType == "initial") then
		return EVENT_TRIGGER_INITIAL;
	elseif (triggerType == "scene_start") then
		return EVENT_TRIGGER_START;
	elseif (triggerType == "grade_up") then
		return EVENT_TRIGGER_UPGRADE;
	elseif (triggerType == "mission_receive") then
		return EVENT_TRIGGER_RECV_MISSION;
	elseif (triggerType == "mission_finish") then
		return EVENT_TRIGGER_FNIS_MITTION;
	else
		return EVENT_TRIGGER_NONE;
	end
end

local function convertConditionType(conditionType)
	if (conditionType == "equal") then
		return EVENT_CONDITION_EQUAL;
	elseif(conditionType == "stringEqual") then
		return EVENT_CONDITION_STRING_EQUAL;
	else
		return EVENT_CONDITION_NONE;
	end
end

local function convertActionType(actionType)
	if (actionType == "move_actor") then
		return EVENT_ACTION_MOVE_ACTOR;
	elseif (actionType == "close_event") then
		return EVENT_ACTION_CLOSE_EVENT;
	elseif (actionType == "open_event") then
		return EVENT_ACTION_OPEN_EVENT;
	elseif (actionType == "switch_layer") then
		return EVENT_ACTION_SWITCH_LAYER;
	elseif (actionType == "open_ui") then
		return EVENT_ACTION_OPEN_UI;
	elseif (actionType == "new_ui") then
		return EVENT_ACTION_NEW_UI;
	elseif (actionType == "set_variable") then
		return EVENT_ACTION_SET_VARIABLE;
	elseif (actionType == "if") then
		return EVENT_ACTION_IF;
	elseif (actionType == "else") then
		return EVENT_ACTION_ELSE;
	elseif (actionType == "end") then
		return EVENT_ACTION_END;
	elseif(actionType == "wait") then
		return EVENT_ACTION_WAIT;
	elseif(actionType == "guide") then
		return EVENT_ACTION_GUIDE;
	elseif(actionType == "setMission") then
		return EVENT_ACTION_SET_MISSION;
	elseif(actionType == "showMission") then
		return EVENT_ACTION_SHOW_MISSION;
	elseif(actionType == "upgrade") then
		return EVENT_ACTION_UP_GRADE;
	elseif (actionType == "ifBetween") then
		return EVENT_ACTION_IFBETWEEN;
	elseif (actionType == "enterBattle") then
		return EVENT_ACTION_ENTER_BATTLE;
	elseif (actionType == "sendNpcID") then
		return EVENT_ACTION_SEND_NPCID;
	elseif (actionType == "enterWorldMap") then
		return EVENT_ACTION_ENTER_WORLD_MAP;
	elseif (actionType == "enterShop") then
		return EVENT_ACTION_ENTER_SHOP;
	else
		return EVENT_ACTION_NONE;
	end
end

local function convertTrigger(event, trigger)
	local entity = {};
	entity["type"] = convertTriggerType(trigger.type);
	entity["data"] = trigger.data;
	entity["event"] = event;
	return entity;
end

local function convertCondition(condition)
	local entity = {};
	entity["type"] = convertConditionType(condition.type);
	entity["data"] = condition.data;
	entity["func"] = EventManager.getConditionFunc(entity.type);
	return entity;
end

local function convertAction(action)
	local entity = {};
	entity["type"] = convertActionType(action.type);
	entity["data"] = action.data;
	entity["func"] = EventManager.getActionFunc(entity.type);
	return entity;
end

function createEvent(data)
	local entity = {trigger = {}, condition = {}, action = {}, isRun = true, progress = 0, wait = 0}; -- wait = -1事件阻塞  wait = 0事件继续

	local triggers = data["trigger"];
	local conditions = data["condition"];
	local actions = data["action"];

	for i, trigger in ipairs(triggers) do
		table.insert(entity.trigger, convertTrigger(entity, trigger));
	end

	for i, condition in ipairs(conditions) do
		table.insert(entity.condition, convertCondition(condition));
	end

	for i, action in ipairs(actions) do
		table.insert(entity.action, convertAction(action));
	end

	setJudgeActionData(entity.action);

	return entity;
end