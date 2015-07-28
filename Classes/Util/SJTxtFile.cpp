#include "SJTxtFile.h"

unsigned char* SJTxtFile::openFile(const char* fileName, unsigned long * pSize)
{
	unsigned char * pBuffer = NULL;

	CCAssert(fileName != NULL && pSize != NULL, "Open file -- Invalid parameters.");
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	unsigned long size = 0;
	pBuffer = CCFileUtils::sharedFileUtils()->getFileData(fileName,"rb",&size);
#else
	*pSize = 0;
	int count = 0;

	std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(fileName);

	FILE *fp = fopen(fullPath.c_str(), "r");

	if(fp)
	{
		fseek(fp,0,SEEK_END);

		*pSize = ftell(fp);
		fseek(fp,0,SEEK_SET);
		pBuffer = new unsigned char[*pSize];
		char c;
		while ((c = fgetc(fp)) != EOF)
		{
			pBuffer[count] = c;
			count++;
		}
		pBuffer[count] = 0;
		fclose(fp);
	}


#endif
	if (!pBuffer)
	{
		std::string msg = "Get data from file(";
		msg.append(fileName).append(") failed!");
		CCLOG("%s", msg.c_str());
	}
    return pBuffer;
}

unsigned char* SJTxtFile::openFile(const char* fileName)
{
	unsigned long size = 0;
    return openFile(fileName, &size);
}

void SJTxtFile::saveFile(const char* fileName, const char* content)
{
	CCAssert(fileName != NULL && content != NULL, "Save File -- Invalid parameters.");

	std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(fileName);
	FILE* fp = fopen(fullPath.c_str(), "w");
    if (fp)
	{
        fputs(content, fp);
        fclose(fp);
    }
}