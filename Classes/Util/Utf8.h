#include "network\Common.h"
#include<iostream>
using namespace std;

std::string ToUTF8(const wchar_t* buffer, int len)  
{ 
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		int size = ::WideCharToMultiByte(CP_UTF8, 0, buffer, len, NULL, 0, NULL,  
				NULL);  
		if (size == 0)  
			return "";  
  
		std::string newbuffer;  
		newbuffer.resize(size);  
		::WideCharToMultiByte(CP_UTF8, 0, buffer, len,  
				const_cast<char*>(newbuffer.c_str()), size, NULL, NULL);  
  
		return newbuffer;  
#else
	return "";
#endif
};

std::string ToUTF8(const std::wstring& str)  
{  
		return ToUTF8(str.c_str(), (int) str.size());  
};