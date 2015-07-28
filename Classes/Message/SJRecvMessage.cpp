#include "SJRecvMessage.h"
#include "lua.h"

SJRecvMessage::SJRecvMessage(char* buffer):BaseRecvMessage(buffer)
{
	m_buffer = buffer;
	m_pos = 5;
}


void SJRecvMessage::pushData(lua_State* luaState,MapObj&obj,int length)
{
	if(obj.value == "int")
	{
		MESSAGE_READ_INT(obj.key.c_str());
	}else if(obj.value == "string")
	{
		MESSAGE_READ_STRING(obj.key.c_str());
	}else if(obj.value == "short")
	{
		MESSAGE_READ_SHORT(obj.key.c_str());
	}else if(obj.value == "byte")
	{
		MESSAGE_READ_BYTE(obj.key.c_str());
	}else if(obj.value == "byteList")
	{
		MESSAGE_READ_BYTE_LIST(obj.key.c_str());
	}else if(obj.value == "stringList")
	{
		MESSAGE_READ_STRING_LIST(obj.key.c_str());
	}else if(obj.value == "intList")
	{
		MESSAGE_READ_INT_LIST(obj.key.c_str());
	}
}
void SJRecvMessage::doDecode(short type, lua_State* luaState)
{
	//CCLOG("decode message code = %d",type);
	if(type == 2209)
	{
		int lll = 111;
	}
	int length = 0;
	m_type = type;
	char name[128];
	sprintf(name,"%d",type);
	string tableName = "rev_";
	tableName.append(name);
	//从lua 获取该协议所有数据的类型和名称

	//根据table读取服务器返回列数据
	lua_getglobal(luaState, tableName.c_str());
	lua_pushstring(luaState, "isList");
	lua_gettable(luaState, -2);
	string str = "";
	if(lua_isnil(luaState,-1)){
		CCLOG("no this key in lua file");
		return;
	}
	str = lua_tostring(luaState,-1);
	bool isList = false;
	if(str == "True")
		isList = true;
	lua_pop(luaState,1);
	lua_pushstring(luaState, "key");
	lua_gettable(luaState, -2);
	bool istable = lua_istable(luaState,-1);
	//lua_pop(luaState,1);
	
	vector<MapObj> nameVec;

	///
	//lua_getglobal(L, t);
	int len = lua_objlen(luaState, -1);
	for (int i = 1; i <= len; i++) 
	{
		lua_pushinteger(luaState, i);
		lua_gettable(luaState, -2);
		lua_pushnil(luaState);
		while(lua_next(luaState,-2))
		{
			string value = lua_tostring(luaState,-1);
			string key = lua_tostring(luaState,-2);
			MapObj &obj = MapObj(key,value);
			nameVec.push_back(obj);
			lua_pop(luaState,1);
		}

		lua_pop(luaState, 1);
	}
	


	///
	//while(lua_next(luaState,-2))
	//{
	//	string value = lua_tostring(luaState,-1);
	//	string key = lua_tostring(luaState,-2);
	//	MapObj &obj = MapObj(key,value);
	//	nameVec.push_back(obj);
	//	lua_pop(luaState,1);
	//}
	lua_pop(luaState,2);
	lua_newtable(luaState);
	if(isList)//如果是list
	{
		int count = readShort();
		CCLOG("message is list count=%d",count);
		for (int i = 1; i <= count; i++)
		{
			lua_pushnumber(luaState, i);
			lua_newtable(luaState);
			for(int i = 0;i<nameVec.size(); i++)
			{
				pushData(luaState,nameVec[i],length);
			}
			lua_settable(luaState, -3);
		}
	}else
	{
		for(int i = 0;i<nameVec.size(); i++)
		{
			pushData(luaState,nameVec[i],length);
		}	
	}
	CCLOG("message convert end");

}
