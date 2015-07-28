#ifndef __FRAME_LOADER__
#define __FRAME_LOADER__

#include "cocos2d.h"
#include <queue>
#include <string>

USING_NS_CC;
using namespace std;

class SJFrameLoader : public CCObject
{
public:
	SJFrameLoader();
	~SJFrameLoader();

	static SJFrameLoader* sharedInstance();

	void addSpriteFramesWithFileAsync(const char *fileName, int scriptHandler);
	void addFramesWithFileListAsync(CCArray* fileNames, int scriptHandler);
	
	void loadImageAsync();
	void addImageAsyncCallback(CCTexture2D* texture);

private:
	queue<string> m_fileNames;
	int m_scriptHandler;
};

#endif