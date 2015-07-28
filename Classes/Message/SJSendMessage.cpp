#include "SJSendMessage.h"
#include "network\BaseSendMessage.h"

SJSendMessage::SJSendMessage(uint16 messageCode):BaseSendMessage(messageCode)
{
	m_messageCode = messageCode;
}

SJSendMessage::SJSendMessage(short type, lua_State* luaStack)
{
	m_messageCode = type;
	m_state = luaStack;
	doEncode(m_messageCode);
}
void SJSendMessage::encodeBody()
{
	char name[128];
	sprintf(name,"%d",m_messageCode);
	string tableName = "send_";
	tableName.append(name);
	int top1 = lua_gettop(m_state);
	
	lua_getglobal(m_state, tableName.c_str());
	//lua_gettable(m_state, -1);
	int len = lua_objlen(m_state, -1);
	vector<string>typeVec;
	for (int i = 1; i <= len; i++) 
	{
		lua_pushinteger(m_state, i);
		lua_gettable(m_state, -2);
		string value = lua_tostring(m_state,-1);
		typeVec.push_back(value);
		lua_pop(m_state, 1);
	}
	//lua_pushnil(m_state);
	//vector<string>typeVec;
	//while(lua_next(m_state,-2))
	//{
	//	string value = lua_tostring(m_state,-1);
	//	typeVec.push_back(value);
	//	lua_pop(m_state,1);
	//}
	lua_pop(m_state,1);
	int top = lua_gettop(m_state);
	lua_pushnil(m_state);
	bool istable = lua_istable(m_state,-2);
	for(int i = 0; i<typeVec.size(); i++)
	{
		if(typeVec[i] == "int")
		{
			MESSAGE_WRITE_INT(top);
		}else if(typeVec[i] == "string")
		{
			MESSAGE_WRITE_STRING(top);
		}else if(typeVec[i] == "byte")
		{
			MESSAGE_WRITE_BYTE(top);
		}else if(typeVec[i] == "short")
		{
			MESSAGE_WRITE_SHORT(top);
		}
	}
	lua_settop(m_state, 0);
}

