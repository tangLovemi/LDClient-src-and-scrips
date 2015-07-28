#include "FMRole.h"

FMRole * FMRole::createRole(int sex)
{
    FMRole * role = new FMRole();
    if (role && role->init(sex))
	{
        role->autorelease();
        return role;
    }
    CC_SAFE_DELETE(role);
    return NULL;
}

bool FMRole::init(int sex)
{
    if (!CCNode::init())
	{
        return false;
    }
    
    auto bg = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    bg->setScale(2.3, 4);
    this->addChild(bg);
    bg->setPosition(ccp(-10, -90));
    
    fx1 = CCSprite::create("Res/FaceModue/backFair.png");
    fx1->setPosition(ccp(-10,33));
    this->addChild(fx1);
    
    CCSprite * st = CCSprite::create("Res/FaceModue/body.png");
    st->setPosition(ccp(0, -203));
    this->addChild(st);
    
    lx = CCSprite::create("Res/FaceModue/face.png");
    lx->setPositionX(-5);
    this->addChild(lx);
    
    mm = CCSprite::create("Res/FaceModue/eyebrow.png");
    mm->setPosition(ccp(25, 0));
    this->addChild(mm);
    
    eye = CCSprite::create("Res/FaceModue/eye.png");
    eye->setPosition(ccp(20, -20));
    this->addChild(eye);
    
    fx2 = CCSprite::create("Res/FaceModue/frontFair.png");
    fx2->setPosition(ccp(10, 54));
    this->addChild(fx2);
    
    mouth = CCSprite::create("Res/FaceModue/mouth.png");
    mouth->setPosition(ccp(20, -55));
    this->addChild(mouth);
    
    hz = CCSprite::create("Res/FaceModue/goatee.png");
    hz->setPosition(ccp(27, -75));
    this->addChild(hz);
    
    mouthTag = 0;
    hairTag = 0;
    faceTag = 0;
    eyebrowTag = 0;
    huZiTag = 0;
    eyeTag = 0;

    return true;
}

void FMRole::setXingXiangTag(int btnTag,int imgsTag,int colorTag)
{
    switch (btnTag)
	{
        case 0:
            hairTag = imgsTag * 10 + colorTag;
            break;
        case 1:
            faceTag = imgsTag * 10 + colorTag;
            break;
        case 2:
            eyebrowTag  = imgsTag * 10 + colorTag;
            break;
        case 3:
            eyeTag  = imgsTag * 10 + colorTag;
            break;
        case 4:
            mouthTag  = imgsTag * 10 + colorTag;
            break;
        case 5:
            huZiTag  = imgsTag * 10 + colorTag;
            break;
        default:
            break;
    }
   
    CCLOG("CurrentRole Tag : hairTag(%d),faceTag(%d),eyebrowTag(%d),eyeTag(%d),mouthTag(%d),huZiTag(%d)",hairTag,faceTag,eyebrowTag,eyeTag,mouthTag,huZiTag);
}

int FMRole::getMouthTag()
{
    return mouthTag;
}

int FMRole::getHairTag()
{
    return hairTag;
}

int FMRole::getFaceTag()
{
    return faceTag;
}

int FMRole::getEyebrowTag()
{
    return eyebrowTag;
}

int FMRole::getHuZiTag()
{
    return huZiTag;
}

int FMRole::getEyeTag()
{
    return eyeTag;
}


CCSprite * FMRole::getRoleMouth()
{
    return mouth;
}

CCSprite * FMRole::getRoleBackHair()
{
    return fx1;
}

CCSprite * FMRole::getRoleFrontHair()
{
    return fx2;
}

CCSprite * FMRole::getRoleFace()
{
    return lx;
}

CCSprite * FMRole::getRoleEyebrow()
{
    return mm;
}

CCSprite * FMRole::getRoleHuzi()
{
    return hz;
}

CCSprite * FMRole::getRoleEye()
{
    return eye;
}