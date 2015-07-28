#ifndef __BuyTest__YuLanLayer__
#define __BuyTest__YuLanLayer__

#include <iostream>
#include "cocos2d.h"
#include "cocos-ext.h"
#include "FMRole.h"

USING_NS_CC;
USING_NS_CC_EXT;

enum Sex {
    MALE,
    FEMALE
};

class FMPreview :public CCLayer ,public CCScrollViewDelegate
{
public:
    static FMPreview * createPreviewLayer(CCSize size);
    virtual bool init(CCSize size);

    FMRole * getMaleRole();
    FMRole * getfemaleRole();
    void addBigScrollView(CCSize size);
    void createSexRole();
    
    virtual void scrollViewDidScroll(CCScrollView* view);
    virtual void scrollViewDidZoom(CCScrollView* view);
    Sex getRoleSex();
    
    FMRole * getCurrentRole();
    void changeImages();
    
private:
    FMRole * maleRole;
    FMRole * femaleRole;
    CCScrollView * scrollView;
    FMRole * currentRole;
    
    CCPoint prePos;
    Sex roleSex;
};

#endif