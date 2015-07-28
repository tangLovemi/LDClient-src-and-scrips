#ifndef __ARMATURE_LOADER__
#define __ARMATURE_LOADER__

#include "cocos2d.h"
#include "cocos-ext.h"
#include <queue>
#include <string>

USING_NS_CC;
USING_NS_CC_EXT;
using namespace std;

class SJArmatureLoader : public CCObject
{
public:
	SJArmatureLoader();
	~SJArmatureLoader();

	static SJArmatureLoader* sharedInstance();

	void addArmatureWithFileAsync(const char *fileName, int scriptHandler);
	void addArmatureWithFileListAsync(CCArray* fileNames, int scriptHandler);
	
	void loadArmatureAsync(float dt);
	void removeArmatureFileInfo(CCArray* fileNames);

private:
	queue<string> m_fileNames;
	int m_scriptHandler;
};

#endif