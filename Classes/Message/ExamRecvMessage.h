#ifndef __EXAM_RECVMESSAGE__
#define __EXAM_RECVMESSAGE__

#include "cocos2d.h"
#include "network\BaseRecvMessage.h"
#include "network\Common.h"
//#include "BaseSendMessage.h"

//USING_NS_CC;

class ExamRecvMessage : public BaseRecvMessage
{

private:
	char* m_buffer;
	short m_pos;
	uint16 m_content;
	int m_senderId;

public:
	CC_SYNTHESIZE(string, m_str, Str);  
	CC_SYNTHESIZE(uint8, m_type, Type);
	CC_SYNTHESIZE(short,m_messageCode, MessageCode);
	
public:
	ExamRecvMessage(char* buffer);

	virtual void doDecode();
};



#endif