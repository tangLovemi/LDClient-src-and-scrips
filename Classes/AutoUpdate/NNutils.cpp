#include "NNUtils.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
#include <io.h>
#else
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#endif

#define MAX_LEN         (cocos2d::kMaxLogLen + 1)

bool FsFolder( std::string folderPath, std::vector<std::string>& fileNames, int depth )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
	_finddata_t FileInfo;
	std::string strFind = folderPath + "\\*";
	long Handle = _findfirst(strFind.c_str(), &FileInfo );

	if ( Handle == -1L )
	{
		return false;
	}

	do 
	{
		// 判断是否有子目录;
		if ( FileInfo.attrib & _A_SUBDIR )
		{
			if ( (strcmp(FileInfo.name, ".") != 0) && (strcmp(FileInfo.name, "..") != 0) )
			{
				std::string newPath = folderPath + "\\" + FileInfo.name;
				FsFolder( newPath, fileNames);
			}
		}else{
			std::string fileName = folderPath + "\\" + FileInfo.name;
			fileNames.push_back(fileName);
		}

	} while ( _findnext(Handle, &FileInfo) ==0 );
	_findclose(Handle);
#else
	DIR* dp;
	struct dirent* entry;
	struct stat statbuf;

	if ( (dp = opendir(folderPath.c_str())) == NULL )
	{
		return false;
	}

	chdir( folderPath.c_str() );
	while( (entry = readdir(dp)) != NULL ){
		lstat(entry->d_name, &statbuf);
		if ( S_ISDIR(statbuf.st_mode) )
		{
			if ( strcmp(".", entry->d_name) == 0 || 
				strcmp("..", entry->d_name) == 0 )
			{
				continue;
			}
			FsFolder( entry->d_name, fileNames, depth + 4);
		}else{
			std::string fileName = entry->d_name;
			fileNames.push_back(fileName);
		}
	}
	chdir("..");
	closedir(dp);
#endif
	return true;
}

bool DeleteDir( std::string folderPath ){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
	std::vector<std::string> fileNameVec;
	FsFolder( folderPath, fileNameVec);

	for ( size_t j=0; j < fileNameVec.size(); ++j )
	{
		remove( fileNameVec.at(j).c_str() );
	}
#else
	DIR* dir;
	dirent* dir_info;
	char file_path[PATH_MAX];

	struct stat statBuf;
	if (lstat(folderPath.c_str(), &statBuf) == 0)
	{
		if ( S_ISREG(statBuf.st_mode) != 0 )
		{
			remove(folderPath.c_str());
			return true;
		}

		if ( S_ISDIR(statBuf.st_mode) != 0 )
		{
			if ( (dir = opendir(folderPath.c_str())) == NULL) 
			{
				return false;
			}
			while( (dir_info = readdir(dir)) != NULL ){
				if ( strcmp(".", dir_info->d_name) == 0 || 
					strcmp("..", dir_info->d_name) == 0 )
				{
					continue;
				}
				strcpy(file_path, folderPath.c_str());
				if ( file_path[strlen(folderPath.c_str()) -1] != '/' )
				{
					strcat(file_path, "/");
				}
				strcat(file_path,dir_info->d_name);
				DeleteDir(file_path);
				rmdir(file_path);
			}
		}
	}
#endif
	return true;
}