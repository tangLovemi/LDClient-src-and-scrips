#ifndef __EXAM_RECVMESSAGE__
#define __EXAM_RECVMESSAGE__

#include "cocos2d.h"
#include "network/BaseRecvMessage.h"
#include "network/Common.h"
#include "CCLuaEngine.h"
#include "SJConfig.h"

USING_NS_CC;
struct MapObj
{
	string key;
	string value;
	MapObj(string p1,string p2 )
		:key( p1 )
		,value( p2 )
	{

	}
};
#define MESSAGE_READ_STRING(key)		lua_pushstring(luaState, key);					\
										lua_pushstring(luaState, readString().c_str());	\
										lua_settable(luaState, -3);

#define MESSAGE_READ_INT(key)			lua_pushstring(luaState, key);			\
										lua_pushinteger(luaState, readInt());	\
										lua_settable(luaState, -3);

#define MESSAGE_READ_SHORT(key)			lua_pushstring(luaState, key);			\
										lua_pushnumber(luaState, readShort());	\
										lua_settable(luaState, -3);

#define MESSAGE_READ_BYTE(key)			lua_pushstring(luaState, key);			\
										lua_pushnumber(luaState, readByte());	\
										lua_settable(luaState, -3);

#define MESSAGE_READ_LIST_HEAD(key)		lua_pushstring(luaState, key);			\
										lua_newtable(luaState);					\
										length = readByte();

#define MESSAGE_READ_STRING_LIST(key)	MESSAGE_READ_LIST_HEAD(key)					\
										for (int j = 1; j <= length; j++)			\
										{											\
											lua_pushnumber(luaState, j);			\
											lua_pushstring(luaState, readString().c_str());	\
											lua_settable(luaState, -3);				\
										}											\
										lua_settable(luaState, -3);

#define MESSAGE_READ_INT_LIST(key)		MESSAGE_READ_LIST_HEAD(key)					\
										for (int j = 1; j <= length; j++)			\
										{											\
											lua_pushnumber(luaState, j);			\
											lua_pushnumber(luaState, readInt());	\
											lua_settable(luaState, -3);				\
										}											\
										lua_settable(luaState, -3);

#define MESSAGE_READ_SHORT_LIST(key)	MESSAGE_READ_LIST_HEAD(key)					\
										for (int j = 1; j <= length; j++)			\
										{											\
											lua_pushnumber(luaState, j);			\
											lua_pushnumber(luaState, readShort());	\
											lua_settable(luaState, -3);				\
										}											\
										lua_settable(luaState, -3);

#define MESSAGE_READ_BYTE_LIST(key)		MESSAGE_READ_LIST_HEAD(key)					\
										for (int j = 1; j <= length; j++)			\
										{											\
											lua_pushnumber(luaState, j);			\
											lua_pushnumber(luaState, readByte());	\
											lua_settable(luaState, -3);				\
										}											\
										lua_settable(luaState, -3);

class SJRecvMessage : public BaseRecvMessage
{

private:
	char* m_buffer;
	short m_pos;
	lua_State* m_state;

public:
	CC_SYNTHESIZE(string, m_str, Str);
	CC_SYNTHESIZE(short, m_type, Type);
	
public:
	SJRecvMessage(char* buffer);
	void pushData(lua_State* luaState,MapObj&obj,int length);
	virtual void doDecode(short type, lua_State* luaState);
};



#endif