#include "network\Common.h"
#include<iostream>
#include "cocos2d.h"
using namespace cocos2d;
using namespace std;

static long long GetCurSystemTime()
{
	struct cc_timeval now; 
	CCTime::gettimeofdayCocos2d(&now, NULL); 
	long long kkkk = ((long long)((long long)now.tv_sec * (long long)1000) + (long long)((long long)now.tv_usec / (long long)1000));
	return ((long long)((long long)now.tv_sec * (long long)1000) + (long long)((long long)now.tv_usec / (long long)1000)); 
}

static void stopAnimation()
{
	CCDirector::sharedDirector()->pause();
}

static void continueAnimation()
{
	CCDirector::sharedDirector()->resume();
}

static bool isPaused()
{
	return CCDirector::sharedDirector()->isPaused();
}

static CCSprite* createEdgeLabel(const char* value,float strokeValue,ccColor3B color)
{
	CCLabelTTF *label = CCLabelTTF::create(value,"Arial",30);
     
    /* 通过label的大小来设置最终生成的纹理图片的大小，strokeValue为描边字体的偏移量，影响粗细 */
    CCSize textureSize = label->getContentSize();
    textureSize.width += 2 * strokeValue;
    textureSize.height += 2 * strokeValue;
     
    /* 监测OpenGl的错误状态 */
    glGetError();
     
    /* 创建一张纹理画布 */
    CCRenderTexture *rt = CCRenderTexture::create(textureSize.width, textureSize.height);
    if(!rt)
    {
        CCLog("create render texture failed !!!!");
        //addChild(label);
        return 0;
    }
     
    /* 设置描边的颜色 */
    label->setColor(color);
     
    /* 
     *拿到源文字的混色机制，存储以备恢复，并设置新的目标混色机制
     *混色机制设为：源颜色透明度（影响亮度）和目标颜色（影响颜色）
     */
    ccBlendFunc originalBlend = label->getBlendFunc();
    ccBlendFunc func = { GL_SRC_ALPHA, GL_ONE};
    label->setBlendFunc(func);
     
    /* 这是自定义的一些调整，倾斜了一点 */
    label->setAnchorPoint(ccp(0.5, 0.5));
    //label->setRotationX(15);
     
    /* 张开画布，开始绘画 */
    rt->begin();
    for(int i = 0; i < 360; i += 5)//每变化5度绘制一张
    {
        float r = CC_DEGREES_TO_RADIANS(i); //度数格式的转换
        label->setPosition(ccp(textureSize.width * 0.5f + sin(r) * strokeValue,textureSize.height * 0.5f + cos(r) * strokeValue));
 
        /* CCRenderTexture的用法，在begin和end之间visit的纹理，都会画在CCRenderTexture里面 */
        label->visit();//画了一次该label
    }
 
    /* 恢复原始的label并绘制在最上层 */
    label->setColor(ccWHITE);
    label->setBlendFunc(originalBlend);
    label->setPosition(ccp(textureSize.width * 0.5f, textureSize.height * 0.5f));
    label->visit();
 
    /* 在画布上绘制结束，此时会生成一张纹理 */
    rt->end();
     
    /* 取出生成的纹理，添加抗锯齿打磨，并返回 */
    CCTexture2D *texture = rt->getSprite()->getTexture();
    texture->setAntiAliasTexParameters();// setAliasTexParameters();
	CCSprite*sprite = CCSprite::createWithTexture(texture);
	sprite->setFlipX(false);
	sprite->setFlipY(true);
	return sprite;
}

	