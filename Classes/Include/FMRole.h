#ifndef __BuyTest__Role__
#define __BuyTest__Role__

#include <iostream>
#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;

class FMRole : public CCNode
{
public:
    
    static FMRole * createRole(int sex);
    virtual bool init(int sex);
    
    CCSprite * getRoleMouth();
    CCSprite * getRoleBackHair();
    CCSprite * getRoleFrontHair();
    CCSprite * getRoleFace();
    CCSprite * getRoleEyebrow();
    CCSprite * getRoleHuzi();
    CCSprite * getRoleEye();
    
    void setXingXiangTag(int btnTag,int imgsTag,int colorTag);
    
    int getMouthTag();
    int getHairTag();
    int getFaceTag();
    int getEyebrowTag();
    int getHuZiTag();
    int getEyeTag();

private:
    int sex;
    CCSprite * fx1;
    CCSprite * fx2;
    CCSprite * lx;
    CCSprite * mm;
    CCSprite * eye;
    CCSprite * mouth;
    CCSprite * hz;
    
    int mouthTag;
    int hairTag;
    int faceTag;
    int eyebrowTag;
    int huZiTag;
    int eyeTag;
};
#endif