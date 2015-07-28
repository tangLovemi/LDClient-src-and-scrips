#include "ExamRecvMessage.h"



ExamRecvMessage::ExamRecvMessage(char* buffer):BaseRecvMessage(buffer)
{
	//m_buffer = buffer;
	//m_pos = 5;
	  
}

void ExamRecvMessage::doDecode()
{
	m_type = readByte();
//	m_content = readShort();
//	m_content = readString();
	m_str = readString();
	m_senderId = readInt();
	m_messageCode = decodeHeader();
}

