#include "SJFrameLoader.h"

static SJFrameLoader* s_instance = NULL;

SJFrameLoader::SJFrameLoader()
{
	m_scriptHandler = 0;
}

SJFrameLoader::~SJFrameLoader()
{

}

SJFrameLoader* SJFrameLoader::sharedInstance()
{
	if (!s_instance)
	{
		s_instance = new SJFrameLoader();
	}
	return s_instance;
}

void SJFrameLoader::addSpriteFramesWithFileAsync(const char *fileName, int scriptHandler)
{
	m_scriptHandler = scriptHandler;
	m_fileNames.push(fileName);
	string plistName = fileName;
	CCTextureCache::sharedTextureCache()->addImageAsync(plistName.append(".png").c_str(), this, callfuncO_selector(SJFrameLoader::addImageAsyncCallback));
}

void SJFrameLoader::addFramesWithFileListAsync(CCArray* fileNames, int scriptHandler)
{
	m_scriptHandler = scriptHandler;
	int count = fileNames->count();
	for (int i = 0; i< count; i++)
	{
		const char* fileName = ((CCString*)fileNames->objectAtIndex(i))->getCString();
		m_fileNames.push(fileName);
	}
	if (count > 0)
	{
		loadImageAsync();
	}
}

void SJFrameLoader::loadImageAsync()
{
	const char* fileName = m_fileNames.front().c_str();
	string pngName = fileName;
	CCTextureCache::sharedTextureCache()->addImageAsync(pngName.append(".png").c_str(), this, callfuncO_selector(SJFrameLoader::addImageAsyncCallback));
}

void SJFrameLoader::addImageAsyncCallback(CCTexture2D* texture)
{
	string fileName = m_fileNames.front();
	CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile(fileName.append(".plist").c_str(), texture);
	m_fileNames.pop();

	if (!m_fileNames.empty())
	{
		loadImageAsync();
		return;
	}

	if (m_scriptHandler > 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_scriptHandler, "complete", NULL, "");
	}
}