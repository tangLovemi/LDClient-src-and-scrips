module("TestControl", package.seeall)



 -- local m_status = STATUS_TEST;  --测试状态
local m_status = STATUS_TRUE;	  --正式流程状态






function isTest()
	if(m_status == STATUS_TEST) then
		return true;
	end
	return false;
end
