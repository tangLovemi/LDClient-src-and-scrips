#ifndef __EXAM_SENDMESSAGE__
#define __EXAM_SENDMESSAGE__

#include "network/BaseSendMessage.h"
#include "CCLuaEngine.h"
#include "SJConfig.h"

#define MESSAGE_WRITE_INT(top)		lua_next(m_state, top);					\
									writeInt(lua_tonumber(m_state, -1));	\
									lua_pop(m_state, 1);

#define MESSAGE_WRITE_SHORT(top)	lua_next(m_state, top);					\
									writeShort(lua_tonumber(m_state, -1));	\
									lua_pop(m_state, 1);

#define MESSAGE_WRITE_BYTE(top)		lua_next(m_state, top);					\
									writeByte(lua_tonumber(m_state, -1));	\
									lua_pop(m_state, 1);

#define MESSAGE_WRITE_STRING(top)	lua_next(m_state, top);					\
									writeString(lua_tostring(m_state, -1));	\
									lua_pop(m_state, 1);

class SJSendMessage : public BaseSendMessage
{
private:
	uint8* m_buffer;
	short m_pos;
	short m_bodySize;
	short m_messageCode;
public:
	SJSendMessage();
	SJSendMessage(uint16 messageCode);
	SJSendMessage(short type, lua_State* luaStack);

	void setMsgCode(short code)
	{
		m_messageCode = code;
	};

//	virtual void doEncode();
private:
	lua_State* m_state;
	uint16 m_id;
	uint8 m_bag;
	char m_num;
	string m_str;
	int m_serial;
	
	virtual void encodeBody();
};
#endif