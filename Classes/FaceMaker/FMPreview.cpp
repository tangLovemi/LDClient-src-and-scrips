#include "FMPreview.h"
#include "FaceMaker.h"


FMPreview * FMPreview::createPreviewLayer(CCSize size)
{
    FMPreview * previewLayer = new FMPreview();
    if (previewLayer && previewLayer->init(size))
	{
        previewLayer->autorelease();
        return previewLayer;
    }
    CC_SAFE_DELETE(previewLayer);
    return NULL;
}

bool FMPreview::init(CCSize size)
{
    if (!CCLayer::init())
	{
       return false;
    }
    
    this->createSexRole();
    this->addBigScrollView(size);
    
    prePos = CCPointZero;
    return true;
}

void FMPreview::createSexRole()
{
    roleSex = MALE;
    maleRole = FMRole::createRole(1);
    maleRole->setScale(0.6);
    
    femaleRole = FMRole::createRole(2);
    femaleRole->setScale(0.3);
    
    currentRole = maleRole;
}

void FMPreview::addBigScrollView(CCSize size)
{
    scrollView = CCScrollView::create();
    scrollView->setViewSize(CCSizeMake(size.width * 1.1, size.height*0.85));
    
    scrollView->setContentOffset(CCPointZero);
    
    CCLayer * continerLayer = CCLayer::create();
    continerLayer->setContentSize(CCSizeMake(size.width*1.55, size.height));
    continerLayer->setAnchorPoint(ccp(0.5, 0));
    continerLayer->setPosition(ccp(0, 0));
    
    scrollView->setContainer(continerLayer);
    scrollView->setContentSize(CCSizeMake(size.width*1.55, size.height));
    scrollView->setDirection(kCCScrollViewDirectionHorizontal);
    scrollView->setPosition(ccp(0, 0));
    scrollView->setAnchorPoint(ccp(0, 0));
    this->addChild(scrollView);
    
    scrollView->setBounceable(false);
    maleRole->setPosition(ccp(size.width*0.7 - 115, size.height/2));
    continerLayer->addChild(maleRole);
    
    femaleRole->setPosition(ccp(size.width*0.7 + 155 , size.height/2));
    continerLayer->addChild(femaleRole);
   
    scrollView->setDelegate(this);
}

FMRole * FMPreview::getMaleRole()
{
    return maleRole;
}

FMRole * FMPreview::getfemaleRole()
{
    return femaleRole;
}

void FMPreview::scrollViewDidScroll(CCScrollView* view)
{
    CCPoint pos = view->getContentOffset();
    
    if (pos.x < -190)
	{
        roleSex = FEMALE;
        currentRole = femaleRole;
        maleRole->runAction(CCEaseSineOut::create(CCScaleTo::create(0.3, 0.3)));
        auto callBack = CCCallFunc::create(this, callfunc_selector(FMPreview::changeImages));
        auto seq = CCSequence::create(CCEaseSineOut::create(CCScaleTo::create(0.3, 0.6)), callBack, NULL);
        femaleRole->runAction(seq);
    }
    
    if (pos.x > -30)
	{
        roleSex = MALE;
        currentRole = maleRole;
        femaleRole->runAction(CCEaseSineOut::create(CCScaleTo::create(0.3, 0.3)));
        auto callBack = CCCallFunc::create(this, callfunc_selector(FMPreview::changeImages));
        auto seq = CCSequence::create(CCEaseSineOut::create(CCScaleTo::create(0.3, 0.6)), callBack, NULL);
        maleRole->runAction(seq);
    }
    
    prePos = pos;
}

void FMPreview::changeImages()
{
    FaceMaker * parent =(FaceMaker *)this->getParent();
    int tag = parent->getBtnTag();
    
    CCDictionary * imgDic = CCDictionary::createWithContentsOfFile("Res/Data/xingXiang.plist");
    CCDictionary * colorDic = CCDictionary::createWithContentsOfFile("Res/Data/colorImgs.plist");
    
    if (roleSex == MALE)
	{
        imgDic = (CCDictionary *) imgDic->objectForKey("male");
        colorDic = (CCDictionary *)colorDic->objectForKey("male");
    }
    
    if (roleSex == FEMALE)
	{
         imgDic = (CCDictionary *) imgDic->objectForKey("female");
        colorDic = (CCDictionary *)colorDic->objectForKey("female");
    }
    
    CCArray * imgs;
    CCArray * colors;
    
    switch (tag)
	{
        case 0:
            imgs = (CCArray *)imgDic->objectForKey("fx");
            colors = (CCArray *)colorDic->objectForKey("fx");
            break;
        case 1:
            imgs = (CCArray *)imgDic->objectForKey("lx");
            colors = (CCArray *)colorDic->objectForKey("lx");
            break;
        case 2:
            imgs = (CCArray *)imgDic->objectForKey("mm");
            colors = (CCArray *)colorDic->objectForKey("mm");
            break;
        case 3:
            imgs = (CCArray *)imgDic->objectForKey("yj");
            colors = (CCArray *)colorDic->objectForKey("yj");
            break;
        case 4:
            imgs = (CCArray *)imgDic->objectForKey("z");
            colors = (CCArray *)colorDic->objectForKey("z");
            break;
        case 5:
            imgs = (CCArray *)imgDic->objectForKey("hz");
            colors = (CCArray *)colorDic->objectForKey("hz");
            break;
        default:
            break;
    }
    
    parent->replaceLeftScrollView(imgs);
    parent->replaceRightScrollView(colors);
}

void FMPreview::scrollViewDidZoom(CCScrollView* view)
{
    
}

Sex FMPreview::getRoleSex()
{
    return roleSex;
}

FMRole * FMPreview::getCurrentRole()
{
    return currentRole;
}