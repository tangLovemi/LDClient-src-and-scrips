-- module("UpdateScene", package.seeall)


UPDATE_STATE_NONE = 0				-- 不需要更新;
UPDATE_STATE_END = 1		-- 资源更新结束;
UPDATE_STATE_DOWNLOAD = 2		--下载资源
UPDATE_STATE_WRITE = 3		-- 写入版本号
UPDATE_STATE_FAILED = 4				--更新失败
UPDATE_STATE_ERROR = 5	--更新版本失败

local m_updateLayer = nil;
function create()
	CCLuaLog("enter update method");
	m_updateLayer = UpdateLayer:create();
	return m_updateLayer;
end

function checkUpdate()
	local state = AutoUpdate:getInstance():CheckUpdate();
	-- CCLuaLog("the update state:" .. state);
	if(state == UPDATE_STATE_NONE)then--不需要更新
		enterGame();
	elseif(state == UPDATE_STATE_DOWNLOAD)then--打开更新界面
		local layer = create();
		local scene = GameManager.getGameScene();
		scene:addChild(layer,1,1000);
	end
end

function UpdateAuto(state)
	-- CCLuaLog("enter update method" .. state);
	if(state == UPDATE_STATE_FAILED)then

	elseif(state == UPDATE_STATE_ERROR)then
		
	elseif(state == UPDATE_STATE_END)then
		local scene = GameManager.getGameScene();
		scene:removeChildByTag(1000,true);
		enterGame();
	end
end

function enterGame()

	UIManager.initUI();

	if(TestControl.isTest() == true) then
		UIManager.create();
	end
end