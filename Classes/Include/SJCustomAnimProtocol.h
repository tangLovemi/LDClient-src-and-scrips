#ifndef __CUSTOM_ANIMATION__
#define __CUSTOM_ANIMATION__
//lua传的资源key
#define CUSTOM_KEY_HAIR_FRONT	"hair_front"
#define CUSTOM_KEY_HAIR_BACK	"hair_back"
#define CUSTOM_KEY_FACE			"face"
#define CUSTOM_KEY_EYEBROWS		"eyebrows"
#define CUSTOM_KEY_EYES			"eyes"
#define CUSTOM_KEY_MOUTH		"mouth"
#define CUSTOM_KEY_GOATEE		"goatee"
#define CUSTOM_KEY_HAIR_OTHER	"hair_other1"
//骨骼节点名称
#define CUSTOM_MODULE_HAIR_FRONT	"hair_front_%d"
#define CUSTOM_MODULE_HAIR_BACK		"hair_back_%d"
#define CUSTOM_MODULE_HAIR_BEISHI   "beishi_hair"
#define CUSTOM_MODULE_FACE			"face_%d"
#define CUSTOM_MODULE_EYEBROWS		"eyebrows_%d"
#define CUSTOM_MODULE_EYES			"eyes_%d"
#define CUSTOM_MODULE_MOUTH			"mouth_%d"
#define CUSTOM_MODULE_GOATEE		"goatee_%d"
#define CUSTOM_MODULE_HAIR_OTHER	"hair_other1_%d"

class SJCustomAnimProtocol
{
public:
	virtual void setActorFace(CCDictionary* faceInfo) = 0;
	virtual void changeAPart(const char* partName, const char* imgName, int count) = 0;
	virtual void setPartsColor(CCDictionary* colorInfo) = 0;
	virtual void setAPartColor(const char* partName, ccColor3B color, int count) = 0;

protected:
	string m_hairFront;
	string m_hairBack;
	string m_face;
	string m_eyebrows;
	string m_eyes;
	string m_mouth;
	string m_goatee;
	string m_braid;

	string* m_hairOther;
};

#endif