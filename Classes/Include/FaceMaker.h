#ifndef __nianLianDemo__NianLian__
#define __nianLianDemo__NianLian__

#include <iostream>
#include "cocos2d.h"
#include "cocos-ext.h"
#include "FMPreview.h"

USING_NS_CC;
USING_NS_CC_EXT;

#define BTNSIZE CCSizeMake(82.99, 64.80)

enum FaceMakerSwitch{
    FAIR,
    FACE,
    EYEBROW,
    EYE,
    MOUTH,
    GOATEE
};

class FaceMaker : public CCLayer, public CCEditBoxDelegate, public CCScrollViewDelegate
{
public:
    static CCScene* scene();
    virtual bool init();
    ~FaceMaker();
    FaceMaker();
    CREATE_FUNC(FaceMaker);
    
    void initInterface();
    void createXingXiangList();
    
    void yuLanBig();
    void addEditBox();
    
    //*********左侧形象按钮（6个）*****
    void createXingXiangButton();
    void pressXingXiangBtn(CCObject *senderz, CCControlEvent controlEvent);
    
    //*********返回按钮*********
    void addBackButton();
    void goBackButton(CCObject *senderz, CCControlEvent controlEvent);
    
    //*********随机按钮*********
    void randomButton();
    void selectRandomButton(CCObject *senderz, CCControlEvent controlEvent);
    
    //*******创建角色按钮********
    void createRoleButton();
    void pressCreateRoleButton(CCObject *senderz, CCControlEvent controlEvent);
    
    //*******ScrollView********
    void addScrollView();
    virtual void scrollViewDidScroll(CCScrollView* view);
    virtual void scrollViewDidZoom(CCScrollView* view);

    //********姓名和昵称EditBox******
    CCEditBox * getNameEditBox();
    CCEditBox * getNickNameEditBox();

    void editBoxEditingDidBegin(CCEditBox* editBox);
    void editBoxEditingDidEnd(CCEditBox* editBox);
    void editBoxTextChanged(CCEditBox* editBox, const std::string& text);
    void editBoxReturn(CCEditBox* editBox);
    
    //********获得各个X应该有的size
    CCSize getXSize(CCScale9Sprite * s9sprite,float wideScale,float heightScale);
    
    //********向continerlayer中添加图片******
    void addXingXiangImage(CCLayer * continerLayer,CCArray * picNames);
    void addColorImages(CCLayer * continerLayer,CCArray * colorImages);
    void pressXingBtn(CCObject *senderz, CCControlEvent controlEvent);
    void pressColorBtn(CCObject *senderz, CCControlEvent controlEvent);
    
    void replaceImages(CCArray * imgs,CCArray * coImgs);
    void replaceLeftScrollView(CCArray * imgs);
    void replaceRightScrollView(CCArray * coImgs);

    CCLayer * getContinerLayer1();
    CCLayer * getContinerLayer2();
    int getBtnTag();
    
    void setCurrentRoleXingXiangTxture(int btnTag,int imgTag,int colorTag);
    
private:
    CCScrollView * showScrollView1;
    CCScrollView * showScrollView2;
    CCLayer * continerLayer1;
    CCLayer * continerLayer2;
    CCScale9Sprite * list11;
    
    CCArray * appImages;
    CCArray * colorImages;
    
    int btnTag1;
    int btnTag2;
    int colorTag;
    
    FMPreview * yuLanLayer;
    
    CCSize list1Size;
    CCSize list2Size;
};

#endif