 /*@@

	Copyright (c) Beijing Second Laboratory Game Studio. All rights reserved. 
	
	Created_datetime : 	2013-7-14 15:46
	
	File Name :	NNUtils.h
	
	Author : zhuhuangqing; 
	
	Description : 
	
	Change List :
@@*/
#ifndef __NNUTILS_H__
#define __NNUTILS_H__

#include <string>
#include <vector>
#include "cocos2d.h"
bool			FsFolder( std::string folderPath, std::vector<std::string>& fileNames, int depth = 0 );
bool			DeleteDir( std::string folderPath );
#endif