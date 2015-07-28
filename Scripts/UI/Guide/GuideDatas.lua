--
-- Author: Gao Jiefeng
-- Date: 2015-04-18 18:11:58
--

module("GuideDatas", package.seeall)
local  firstCall = true

function guidestep1_1CallBack()
	UIManager.close("GuiderLayer")
	MainCityLogic.setNpcId(320001)
	TaskManager.setLocalStepRecord(1)
	NpcInfoManager.getMajorTaskInfo(320001,MainCityLogic.onMajorTaskHandler)
	TaskManager.sendNewGuide({1,0,0,0},nil)
end

function guidestep2_1CallBack()
	UIManager.close("GuiderLayer")
	MainCityLogic.setNpcId(320002)
	NpcInfoManager.getMajorTaskInfo(320002,MainCityLogic.onMajorTaskHandler)
	TaskManager.setLocalStepRecord(1)
	TaskManager.sendNewGuide({2,0,0,0},nil)
end

function guidestep3_1CallBack()

	if Upgrade.getOpenState() then
		UIManager.close("Upgrade")
		return
	end

	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(2)
	MainCityLogic.setNpcId(320002)
	NpcInfoManager.getMajorTaskInfo(320002,MainCityLogic.onMajorTaskHandler)

end

function guidestep3_2CallBack()
	if Upgrade.getOpenState() then
		UIManager.close("Upgrade")
		return
	end
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(3)
	
	local function openGuide ()
		UIManager.open("GuiderLayer")
	end
	MainCityLogic.switchLayer(2, 0, true,openGuide)
	
end
function guidestep3_3CallBack()
	if Upgrade.getOpenState() then
		UIManager.close("Upgrade")
		return
	end	
	TaskManager.sendNewGuide({3,0,0,0},nil)
	UIManager.close("GuiderLayer")
	MainCityLogic.setNpcId(320003)
	TaskManager.setLocalStepRecord(1)
	NpcInfoManager.getMajorTaskInfo(320003,MainCityLogic.onMajorTaskHandler)
	
end

function guidestep4_1CallBack()
	if Upgrade.getOpenState() then
		UIManager.close("Upgrade")
		return
	end

	UIManager.close("GuiderLayer")
	MainCityLogic.setNpcId(320003)
	TaskManager.setLocalStepRecord(2)
	NpcInfoManager.getMajorTaskInfo(320003,MainCityLogic.onMajorTaskHandler)
	
end
function guidestep4_2CallBack()

	if Upgrade.getOpenState() then
		UIManager.close("Upgrade")
		return
	end
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(3)
	UIManager.open("SkillsUINew")
	
	UIManager.open("GuiderLayer")

end
function guidestep4_3CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(4)
	local tempNode = CCNode:create()
	tempNode:setTag(8)
	SkillsUINew.closeInfoPanel()
	-- SkillsUINew.iconOnClick(tempNode,TOUCH_EVENT_TYPE_END)
	UIManager.open("GuiderLayer")	
end
function guidestep4_4CallBack()

	local skill_sprite = CCSprite:create(PATH_RES_IMAGE_SKILLS_NORMAL.."skill_21002.png")
	skill_sprite:setPosition(ccp(323,400))
	GuiderLayer.getRootLayer():addChild(skill_sprite)
    local actList = CCArray:create()
    local moveto = CCMoveTo:create(1, CCPoint(408, 88))
    local callback = CCCallFunc:create(function() 	
			UIManager.close("GuiderLayer")
			TaskManager.setLocalStepRecord(5)    	
    		SkillsUINew.changeChooseSkill(1, 21002); --pos下面的位置
			SkillsUINew.closeInfoPanel()
			SkillsUINew.refreshChoolsePublicSkills()
			UIManager.open("GuiderLayer") 
			end)

    actList:addObject(moveto)
    actList:addObject(callback)
    skill_sprite:runAction(CCSequence:create(actList))
end

function guidestep4_5CallBack()
	TaskManager.sendNewGuide({4,0,0,0},nil)
	TaskManager.setNewStep(5)
	TaskManager.setLocalStepRecord(1)
	UIManager.close("GuiderLayer")
	UIManager.close("SkillsUINew")	
	UIManager.open("GuiderLayer")
end

function guidestep5_1CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(2)
	UIManager.open("WishMain")
	UIManager.open("GuiderLayer")

end
function guidestep5_2CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(3)
	WishManager.setBaseInfoCallback(WishMain.initBaseInfo)
	WishManager.chouchaWork(2,-1,WishMain.openItemDetailUI)--正确的
	-- WishManager.chouchaWork(2,1,WishMain.openItemDetailUI)
	ProgressRadial.open();
	
end
function guidestep5_3CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(4)
	UIManager.close("WishItemEffect")
	
	UIManager.open("GuiderLayer")
end
function guidestep5_4CallBack()
	UIManager.close("GuiderLayer")
	local function openGuide ()
		UIManager.open("GuiderLayer")
		ProgressRadial.close();
	end
	ProgressRadial.open();
	TaskManager.sendNewGuide({5,0,0,0},openGuide)
	TaskManager.setLocalStepRecord(1)
	UIManager.close("WishMain")
end

function guidestep6_1CallBack()
	TaskManager.setLocalStepRecord(2)
	UIManager.close("GuiderLayer")
	UIManager.open("WeaponUI")
	UIManager.open("GuiderLayer")
end

function guidestep6_2CallBack()
	TaskManager.setLocalStepRecord(3)
	UIManager.close("GuiderLayer")
	local tempNode = CCNode:create()
	tempNode:setTag(1)
	WeaponUI.iconOnClick(tempNode,TOUCH_EVENT_TYPE_END)
	UIManager.open("GuiderLayer");
	
end

function guidestep6_3CallBack()
	TaskManager.setLocalStepRecord(4)
	UIManager.close("GuiderLayer")
	local tempNode = CCNode:create()
	WeaponUI.btn3OnClick(tempNode,TOUCH_EVENT_TYPE_END)
	UIManager.open("GuiderLayer");
	
end
function guidestep6_4CallBack()
	local function openGuide ()
		UIManager.open("GuiderLayer")
		ProgressRadial.close();
	end
	ProgressRadial.open();
	TaskManager.setLocalStepRecord(1)
	TaskManager.sendNewGuide({6,0,0,0},openGuide)
	-- TaskManager.setNewStep(6)
	UIManager.close("GuiderLayer")
	UIManager.close("WeaponUI")
	
end


function guidestep7_1CallBack()
	TaskManager.setLocalStepRecord(2)
	UIManager.close("GuiderLayer")
	local function openGuide ()
		UIManager.open("GuiderLayer")
	end
	MainCityLogic.switchLayer(3, 0, true,openGuide)
	
end
function guidestep7_2CallBack()
	TaskManager.setLocalStepRecord(3)
	UIManager.close("GuiderLayer")
	MainCityLogic.enterWorldMap()
	
end
function guidestep7_3CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(4)

    WorldManager.setCurBattleMap(1);
    SelectLevel.create(1);

 --    local function openSelect()
	-- 		SelectLevel.openAppointLevel(1);
	-- 	end
	-- WorldMap.create(openSelect);
end

function guidestep7_4CallBack()
	UIManager.close("GuiderLayer")
	local function openGuide ()
		ProgressRadial.close();
		local data = {};
		local type = 1;
		local level = 1;
		data.id = 1;

		local removeMap =function()
			SelectLevel.remove();
			WorldMap.remove();
			-- UIManager.close("SweepDetail");
		end
		data.type = 1;
		data.subType = type;
		WorldManager.setCurData(data);
		BattleManager.enterBattle(1, 1, 1,removeMap);
	end
	ProgressRadial.open();
	TaskManager.setLocalStepRecord(1)
	TaskManager.sendNewGuide({7,0,0,0},openGuide)
end

function guidestep8_1CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(2)
	BattleResult.goToSurface()

end

function guidestep8_2CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(3)
	SelectLevelUI.close()
	UIManager.open("GuiderLayer") 

end

function guidestep8_3CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(4)
	
    WorldMap.remove();   
    local function openGuide()
    	UIManager.open("GuiderLayer")
    end
    GameManager.enterMainCityOther(3,openGuide);
	

end
function guidestep8_4CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(5)  
	local function openGuide ()
		UIManager.open("GuiderLayer")
	end
	MainCityLogic.switchLayer(2, 0, true,openGuide)
	

end
function guidestep8_5CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(1)
	MainCityLogic.setNpcId(320003)
	NpcInfoManager.getMajorTaskInfo(320003,MainCityLogic.onMajorTaskHandler)
	local function openGuide8_5 ()
		
		ProgressRadial.close();
		UIManager.close("GuiderLayer")
	end	
	ProgressRadial.open();
	TaskManager.sendNewGuide({8,0,0,0},openGuide8_5)
end

function guidestep9_1CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(2)
	UIManager.open("WeaponUI")
	UIManager.open("GuiderLayer")
end
function guidestep9_2CallBack()
	UIManager.close("GuiderLayer")
	local tempNode = CCNode:create()
	WeaponUI.btn2OnClick(tempNode,TOUCH_EVENT_TYPE_END)
	tempNode = nil
	TaskManager.setLocalStepRecord(3)
	UIManager.open("GuiderLayer")
end
function guidestep9_3CallBack()
	UIManager.close("GuiderLayer")
	local tag  = 1+323;
	local tempNode = CCNode:create()
	tempNode:setTag(tag)
	WeaponDevour.slvTouchEvent(tempNode,TOUCH_EVENT_TYPE_END)
	tempNode = nil
	TaskManager.setLocalStepRecord(4)
	UIManager.open("GuiderLayer")
end

function guidestep9_4CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(5)
	local tempNode = CCNode:create()
	WeaponDevour.sureOnClick(tempNode,TOUCH_EVENT_TYPE_END)
	UIManager.open("GuiderLayer")
end
function guidestep9_5CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(6)
	local tempNode = CCNode:create()
	WeaponUI.returnBtnOnClick(tempNode,TOUCH_EVENT_TYPE_END)
	UIManager.open("GuiderLayer")
end
function guidestep9_6CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(1)
	local function openGuide ()
		UIManager.open("GuiderLayer")
		ProgressRadial.close();
	end	
	UIManager.close("WeaponUI")
	ProgressRadial.open();
	TaskManager.sendNewGuide({9,0,0,0},openGuide)
end
function guidestep10_1CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(2)
	UIManager.open("SwitchLayer");
	UIManager.open("GuiderLayer")
end
function guidestep10_2CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(3)
	local function openGuide ()
		UIManager.open("GuiderLayer")
	end
	UIManager.close("SwitchLayer");
	MainCityLogic.switchLayer(3, 0, true,openGuide)
end
function guidestep10_3CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(4)
	MainCityLogic.teachDrag(20)
	
end
function guidestep10_4CallBack()
	UIManager.close("GuiderLayer")
	UIManager.open("Transform")
	TaskManager.setLocalStepRecord(5)
	UIManager.open("GuiderLayer")
end
function guidestep10_5CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(6)
	local tempNode = CCNode:create()
	tempNode:setTag(127)
	BackpackFigure.tabPage1Callback(tempNode)   --tag127
	tempNode = nil
	UIManager.open("GuiderLayer")
end
function guidestep10_6CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(7)
	Transform.goodsOnClick(1, 127)
	UIManager.open("GuiderLayer")
end
function guidestep10_7CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(8)
	local tempNode = CCNode:create()
	Transform.strengthBtnOnClick(tempNode,TOUCH_EVENT_TYPE_END)
	tempNode = nil
	UIManager.open("GuiderLayer")
end
function guidestep10_8CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(1)
	local function openGuide ()
		UIManager.open("GuiderLayer")
		ProgressRadial.close();
	end	
	UIManager.close("Transform")
	ProgressRadial.open();
	TaskManager.sendNewGuide({10,0,0,0},openGuide)
end
function guidestep11_1CallBack()
	UIManager.close("GuiderLayer")
	TaskManager.setLocalStepRecord(2)
	UIManager.open("TaskInfoUI")
	UIManager.open("GuiderLayer")
end
function guidestep11_2CallBack()
	UIManager.close("GuiderLayer")
	
	local tempNode = CCNode:create()
	TaskInfoUI.onGoToClick(tempNode,TOUCH_EVENT_TYPE_END)
	tempNode = nil
	TaskManager.setLocalStepRecord(3)
	UIManager.open("GuiderLayer")	
	
end

function guidestep11_3CallBack()
	UIManager.close("GuiderLayer")

	local finishGuide= function ()
		TaskManager.setNewStep(0)
		TaskManager.setNewState(false)
		MainCityLogic.registerTouchFunction()
	end
	
	TaskManager.sendNewGuide({11,0,0,0},finishGuide)
end
--新手引导强制未完成继续
function continueNewGUide(newGuideinfo)
	local majorTaskInfo = NpcInfoManager.getMajorTaskData()
	if  newGuideinfo["step"] == 1 then
		if newGuideinfo["bSuccess"]==0 then--新手第1步未完成
			UIManager.open("GuiderLayer")
		end	
	end

	if  newGuideinfo["step"] == 2 then
		if newGuideinfo["bSuccess"]==0 then--新手第2步未完成
			UIManager.open("GuiderLayer")
		end	
	end

	if  newGuideinfo["step"] == 3 then
		if newGuideinfo["bSuccess"]==0 then--新手第3步未完成

			if majorTaskInfo["status"] == 2 then
				UIManager.open("GuiderLayer")
			elseif majorTaskInfo["status"] == 3 then
				TaskManager.setLocalStepRecord(2)
				UIManager.open("GuiderLayer")
			end
		end	
	end

	if  newGuideinfo["step"] == 4 then
		if newGuideinfo["bSuccess"]==0 then--新手第4步未完成
			if majorTaskInfo["status"] == 2 then
				local function openGuide ()
					UIManager.open("GuiderLayer")
				end
				MainCityLogic.switchLayer(2, 0, true,openGuide)
			elseif majorTaskInfo["status"] == 3 then
				local function openGuide ()
					TaskManager.setLocalStepRecord(2)
					UIManager.open("GuiderLayer")
				end
				MainCityLogic.switchLayer(2, 0, true,openGuide)
			end
		end	
	end
	if  newGuideinfo["step"] == 5 then
		if newGuideinfo["bSuccess"]==0 then--新手第四步未完成
			TaskManager.setLocalStepRecord(1)
			UIManager.open("GuiderLayer")
		end	
	end		
	if  newGuideinfo["step"] == 6 then
		if newGuideinfo["bSuccess"]==0 then--新手第四步未完成
			if majorTaskInfo["status"] == 2 then
				Util.showOperateResultPrompt("some thing wrong please restart the client")
			elseif majorTaskInfo["status"] == 3 then
				local function openGuide ()
					-- TaskManager.setLocalStepRecord(2)
					UIManager.open("GuiderLayer")
				end
				MainCityLogic.switchLayer(2, 0, true,openGuide)
			end
		end	
	end	
	if  newGuideinfo["step"] == 7 then
		if newGuideinfo["bSuccess"]==0 then--新手第四步未完成
			if majorTaskInfo["status"] == 2 then
				Util.showOperateResultPrompt("some thing wrong please restart the client")
			elseif majorTaskInfo["status"] == 3 then
				local function openGuide ()
					-- TaskManager.setLocalStepRecord(2)
					UIManager.open("GuiderLayer")
				end
			    if MainCityLogic.getCurSceneId() == 2 then
			        return
			    end
				MainCityLogic.switchLayer(2, 0, true,openGuide)
			end
		end	
	end	
	if  newGuideinfo["step"] == 8 then
		if newGuideinfo["bSuccess"]==0 then--新手第四步未完成
			if majorTaskInfo["status"] == 2 then
				Util.showOperateResultPrompt("some thing wrong please restart the client")
			elseif majorTaskInfo["status"] == 4 then
				local function openGuide ()
					TaskManager.setLocalStepRecord(5)
					UIManager.open("GuiderLayer")
				end
			    if MainCityLogic.getCurSceneId() == 2 then
			        return
			    end
				MainCityLogic.switchLayer(2, 0, true,openGuide)
			end
		end	
	end		
	if  newGuideinfo["step"] == 9 then
		if newGuideinfo["bSuccess"]==0 then
			TaskManager.setLocalStepRecord(1)
			UIManager.open("GuiderLayer")
		end	
	end

	if  newGuideinfo["step"] == 10 then
		if newGuideinfo["bSuccess"]==0 then
			local function openGuide ()
				TaskManager.setLocalStepRecord(1)
				UIManager.open("GuiderLayer")
			end
			MainCityLogic.switchLayer(2, 0, true,openGuide)
		end	
	end
	if  newGuideinfo["step"] == 11 then
		if newGuideinfo["bSuccess"]==0 then
			TaskManager.setLocalStepRecord(1)
			UIManager.open("GuiderLayer")
		end	
	end	
	if  newGuideinfo["step"] == 12 then
		if newGuideinfo["bSuccess"]==0 then--新手第八步未完成
			if Upgrade.getOpenState() then
				UIManager.close("Upgrade")
			end
			UIManager.close("ErrorDialog")
			UIManager.open("ErrorDialog");
			local funs = {};
			table.insert(funs,function ()
							TaskManager.sendNewGuide({12,0,0,0},nil)
						 	UIManager.close("ErrorDialog");
						 	end);
			table.insert(funs,function () 
							TaskManager.sendNewGuide({12,0,0,0},nil)
							UIManager.close("ErrorDialog")
							UIManager.open("PointStar")
							end);
			ErrorDialog.setPanelStyle(TEXT.gotoPointStarGuide,funs);
		end	
	end
	if  newGuideinfo["step"] == 13 then
		if newGuideinfo["bSuccess"]==0 then--新手第六步未完成
		
			UIManager.close("ErrorDialog")
			UIManager.open("ErrorDialog");
			local funs = {};
			table.insert(funs,function ()
							if Upgrade.getOpenState() then
								UIManager.close("Upgrade")
							end	

							TaskManager.sendNewGuide({13,0,0,0},nil)
						 	UIManager.close("ErrorDialog");
						 	end);
			table.insert(funs,function () 
							if Upgrade.getOpenState() then
								UIManager.close("Upgrade")
							end					
							TaskManager.sendNewGuide({13,0,0,0},nil)
							UIManager.close("ErrorDialog")
							UIManager.open("ActivityType");
							end);
			ErrorDialog.setPanelStyle(TEXT.gotoActivtyGuide,funs);
		end	
	end
	if  newGuideinfo["step"] == 14 then
		if newGuideinfo["bSuccess"]==0 then--新手第六步未完成
		
			UIManager.close("ErrorDialog")
			UIManager.open("ErrorDialog");
			local funs = {};
			table.insert(funs,function ()
							if Upgrade.getOpenState() then
								UIManager.close("Upgrade")
							end	

							TaskManager.sendNewGuide({14,0,0,0},nil)
						 	UIManager.close("ErrorDialog");
						 	end);
			table.insert(funs,function () 
							if Upgrade.getOpenState() then
								UIManager.close("Upgrade")
							end					
							TaskManager.sendNewGuide({14,0,0,0},nil)
							UIManager.close("ErrorDialog")
							UIManager.open("HuntUI")
							end);
			ErrorDialog.setPanelStyle(TEXT.gotoBetUIGuide,funs);
		end	
	end

	if  newGuideinfo["step"] == 15 then
		if newGuideinfo["bSuccess"]==0 then--新手第六步未完成
			if Upgrade.getOpenState() then
				UIManager.close("Upgrade")
			end			
			UIManager.close("ErrorDialog")
			UIManager.open("ErrorDialog");
			local funs = {};
			table.insert(funs,function ()
							if Upgrade.getOpenState() then
								UIManager.close("Upgrade")
							end		
							TaskManager.sendNewGuide({15,0,0,0},nil)
						 	UIManager.close("ErrorDialog");
						 	end);
			table.insert(funs,function () 
							if Upgrade.getOpenState() then
								UIManager.close("Upgrade")
							end						
							TaskManager.sendNewGuide({15,0,0,0},nil)
							UIManager.close("ErrorDialog")
							UIManager.open("JJCUI")
							end);
			UIManager.close("DialogView")
			ErrorDialog.setPanelStyle(TEXT.gotoTrainUIGuide,funs);
		end	
	end	
end