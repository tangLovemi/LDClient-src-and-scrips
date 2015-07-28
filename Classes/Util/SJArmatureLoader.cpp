#include "SJArmatureLoader.h"

static SJArmatureLoader* s_instance = NULL;

SJArmatureLoader::SJArmatureLoader()
{
	m_scriptHandler = 0;
}

SJArmatureLoader::~SJArmatureLoader()
{

}

SJArmatureLoader* SJArmatureLoader::sharedInstance()
{
	if (!s_instance)
	{
		s_instance = new SJArmatureLoader();
	}
	return s_instance;
}

void SJArmatureLoader::addArmatureWithFileAsync(const char *fileName, int scriptHandler)
{
	m_scriptHandler = scriptHandler;
	CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfoAsync(fileName, this, schedule_selector(SJArmatureLoader::loadArmatureAsync));
}

void SJArmatureLoader::addArmatureWithFileListAsync(CCArray* fileNames, int scriptHandler)
{
	m_scriptHandler = scriptHandler;

	int count = fileNames->count();
	for (int i = 0; i< count; i++)
	{
		const char* fileName = ((CCString*)fileNames->objectAtIndex(i))->getCString();
		m_fileNames.push(fileName);
	}

	loadArmatureAsync(0);
}

void SJArmatureLoader::loadArmatureAsync(float dt)
{
	if (!m_fileNames.empty())
	{
		const char* fileName = m_fileNames.front().c_str();
		CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfoAsync(fileName, this, schedule_selector(SJArmatureLoader::loadArmatureAsync));
		m_fileNames.pop();
	}
	else
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_scriptHandler, "complete", NULL, "");
	}
}

void SJArmatureLoader::removeArmatureFileInfo(CCArray* fileNames)
{
	int count = fileNames->count();
	for (int i = 0; i< count; i++)
	{
		const char* fileName = ((CCString*)fileNames->objectAtIndex(i))->getCString();
		CCArmatureDataManager::sharedArmatureDataManager()->removeArmatureFileInfo(fileName);
	}
}