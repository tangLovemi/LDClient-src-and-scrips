#ifndef __LuanDou__GameScene__
#define __LuanDou__GameScene__

#include <iostream>
#include "cocos2d.h"

USING_NS_CC;

class TestScene : public CCLayer
{
public:
    CREATE_FUNC(TestScene);
    virtual bool init();
    static CCScene * scene();
};

#endif