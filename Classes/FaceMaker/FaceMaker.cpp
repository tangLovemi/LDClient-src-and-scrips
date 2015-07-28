#include "FaceMaker.h"
#include "SJConfig.h"


FaceMaker::FaceMaker()
{
    
}

FaceMaker::~ FaceMaker()
{
    CC_SAFE_RELEASE(appImages);
    CC_SAFE_RELEASE(colorImages);
}

CCScene* FaceMaker::scene()
{
    auto scene = CCScene::create();
    auto layer = FaceMaker::create();
    scene->addChild(layer);
    return scene;
}

bool FaceMaker::init()
{
    if(!CCLayer::init())
	{
        return false;
	}
    
    auto lableTTF = CCLabelTTF::create("FACE MAKER", "Helvetica", 30);
    lableTTF->setAnchorPoint(ccp(0.5, 1));
    lableTTF->setPosition(ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 30));
    this->addChild(lableTTF);
    
    appImages = CCArray::create();
    CC_SAFE_RETAIN(appImages);
    
    for (int i=0; i<6; i++)
	{
        CCString * str = CCString::createWithFormat("fx%d",i);
        appImages->addObject(str);
    }
    
    colorImages = CCArray::create();
    CC_SAFE_RETAIN(colorImages);
    
    for (int i=0; i<5; i++)
	{
        CCString * str = CCString::createWithFormat("Cfx%d",i);
        colorImages->addObject(str);
    }
    
    btnTag1 = 0;
    btnTag2 = 0;
    colorTag = 0;
    
    this->initInterface(); //******初始化界面相关********
    
    return true;
}

void FaceMaker::initInterface()
{
    this->addBackButton();
    this->createXingXiangButton();
    this->createXingXiangList();
    this->yuLanBig();
    this->addEditBox();
    
    this->randomButton();
    this->createRoleButton();
    this->addScrollView();
}


void FaceMaker::addBackButton()
{
    auto bgTitle = CCLabelTTF::create("Back", "Arial", 20);
    bgTitle->setColor(ccBLACK);
    
    auto bg = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    bg->setColor(ccRED);
    
    auto size = this->getXSize(bg, 0.6, 0.4);
    
    auto backButton = CCControlButton::create(bgTitle, bg);
    backButton->setPreferredSize(size);
    
    backButton->setPosition(ccp(70, SCREEN_HEIGHT - 50));
    this->addChild(backButton,1);
    backButton->addTargetWithActionForControlEvents(this, cccontrol_selector(FaceMaker::goBackButton), CCControlEventTouchDown);
}

void FaceMaker::goBackButton(CCObject *senderz, CCControlEvent controlEvent)
{
    
}

void FaceMaker::createXingXiangButton()
{
    for (int i=0; i < 6; i++)
	{
        const char * ch;
        switch (i)
		{
            case FAIR:
                ch = CCString::createWithFormat("FAIR")->getCString();
                break;
            case FACE:
                ch = CCString::createWithFormat("FACE")->getCString();
                break;
            case EYEBROW:
                ch = CCString::createWithFormat("EYEBROW")->getCString();
                break;
            case EYE:
                ch = CCString::createWithFormat("EYE")->getCString();
                break;
            case MOUTH:
                ch = CCString::createWithFormat("MOUTH")->getCString();
                break;
            case GOATEE:
                ch = CCString::createWithFormat("GOATEE")->getCString();
                break;
            default:
                break;
        }
        
        auto bgTitle = CCLabelTTF::create(ch, "Arial", 20);
        bgTitle->setColor(ccBLACK);
        
        auto bg = CCScale9Sprite::create("Res/Image/dialog_frame.png");
        auto size = this->getXSize(bg, 0.5, 0.5);

        auto xingXiangButton = CCControlButton::create(bgTitle, bg);
        xingXiangButton->setPreferredSize(size);
        xingXiangButton->setSelected(true);
        xingXiangButton->setPosition(ccp(50, SCREEN_HEIGHT - 80 * i - 130));
        xingXiangButton->setTag(i);
        this->addChild(xingXiangButton);
        xingXiangButton->addTargetWithActionForControlEvents(this, cccontrol_selector(FaceMaker::pressXingXiangBtn) , CCControlEventTouchDown);
    }
}

CCLayer * FaceMaker::getContinerLayer1()
{
    return continerLayer1;
}

CCLayer * FaceMaker::getContinerLayer2()
{
    return continerLayer2;
}


void FaceMaker::pressXingXiangBtn(CCObject *senderz, CCControlEvent controlEvent)
{
    auto btn = (CCControlButton *)senderz;
    int tag = btn->getTag();
    btnTag1 = tag;
    CCArray * preImgs = CCArray::create();
    CCArray * colImgs = CCArray::create();
    
    CCDictionary * xingXiangDic = CCDictionary::createWithContentsOfFile("Res/Data/xingXiang.plist");
    CCDictionary * colDic = CCDictionary::createWithContentsOfFile("Res/Data/colorImgs.plist");
    
    Sex currentSex = yuLanLayer->getRoleSex();
    
    if (currentSex == MALE)
	{
        xingXiangDic = (CCDictionary *)xingXiangDic->objectForKey("male");
        colDic = (CCDictionary *)colDic->objectForKey("male");
    }
    
    if (currentSex == FEMALE)
	{
        xingXiangDic = (CCDictionary *)xingXiangDic->objectForKey("female");
        colDic = (CCDictionary *)colDic->objectForKey("female");
    }
    
    CCArray * imgs;
    CCArray * colorImgs;
    
    const char * ch;
    switch (tag)
	{
        case FAIR:
            ch = CCString::createWithFormat("FAIR")->getCString();
            for (int i=0; i<10; i++)
			{
                CCString * str1 = CCString::createWithFormat("fx%d",i);
                preImgs->addObject(str1);
                
            }
            for (int i=0; i<6; i++)
			{
                CCString * str2 = CCString::createWithFormat("Cfx%d",i);
                colImgs->addObject(str2);
            }
            
            imgs = (CCArray *)xingXiangDic->objectForKey("fx");
            colorImgs = (CCArray *)colDic->objectForKey("fx");
            
            break;
        case FACE:
            ch = CCString::createWithFormat("FACE")->getCString();
            for (int i=0; i<10; i++)
			{
                CCString * str1 = CCString::createWithFormat("lx%d",i);
                preImgs->addObject(str1);
            }
            
            for (int i=0; i<6; i++)
			{
                CCString * str2 = CCString::createWithFormat("Clx%d",i);
                colImgs->addObject(str2);
            }
            
            imgs = (CCArray *)xingXiangDic->objectForKey("lx");
            colorImgs = (CCArray *)colDic->objectForKey("lx");
            
            break;
        case EYEBROW:
            ch = CCString::createWithFormat("EYEBROW")->getCString();
            
            for (int i=0; i<10; i++)
			{
                CCString * str1 = CCString::createWithFormat("mm%d",i);
                preImgs->addObject(str1);
            }
            
            for (int i=0; i<6; i++)
			{
                CCString * str2 = CCString::createWithFormat("Cmm%d",i);
                colImgs->addObject(str2);
            }
            
            imgs = (CCArray *)xingXiangDic->objectForKey("mm");
            colorImgs = (CCArray *)colDic->objectForKey("mm");
            
            break;
        case EYE:
            ch = CCString::createWithFormat("EYE")->getCString();
            
            for (int i=0; i<10; i++)
			{
                CCString * str1 = CCString::createWithFormat("yj%d",i);
                preImgs->addObject(str1);
            }
            
            for (int i=0; i<6; i++)
			{
                CCString * str2 = CCString::createWithFormat("Cyj%d",i);
                colImgs->addObject(str2);
            }
            
            imgs = (CCArray *)xingXiangDic->objectForKey("yj");
            colorImgs = (CCArray *)colDic->objectForKey("yj");
            
            break;
        case MOUTH:
            ch = CCString::createWithFormat("MOUTH")->getCString();
            
            for (int i=0; i<10; i++)
			{
                CCString * str1 = CCString::createWithFormat("z%d",i);
                preImgs->addObject(str1);
            }
            for (int i=0; i<6; i++)
			{
                CCString * str2 = CCString::createWithFormat("Cz%d",i);
                colImgs->addObject(str2);
            }
            
            imgs = (CCArray *)xingXiangDic->objectForKey("z");
            colorImgs = (CCArray *)colDic->objectForKey("z");
            
            break;
        case GOATEE:
            ch = CCString::createWithFormat("GOATEE")->getCString();
            
            for (int i=0; i<10; i++)
			{
                CCString * str1 = CCString::createWithFormat("hz%d",i);
                preImgs->addObject(str1);
                
            }
            for (int i=0; i<6; i++)
			{
                CCString * str2 = CCString::createWithFormat("Chz%d",i);
                colImgs->addObject(str2);
            }
            
            imgs = (CCArray *)xingXiangDic->objectForKey("hz");
            colorImgs = (CCArray *)colDic->objectForKey("hz");
            
            break;
        default:
            break;
    }
    
    this->replaceImages(preImgs, colImgs);
    
    CCLOG("%s",ch);
    
    this->replaceLeftScrollView(imgs);
    this->replaceRightScrollView(colorImgs);
}

void FaceMaker::replaceLeftScrollView(CCArray * imgs)
{
    continerLayer1->removeAllChildren();
    this->addXingXiangImage(continerLayer1, imgs);
}

void FaceMaker::replaceRightScrollView(CCArray * coImgs)
{
    continerLayer2->removeAllChildren();
    this->addColorImages(continerLayer2, coImgs);
}


void FaceMaker::replaceImages(CCArray * imgs,CCArray * coImgs)
{
    appImages->removeAllObjects();
    colorImages->removeAllObjects();
    
    for (int i=0; i<imgs->count(); i++) {
        CCString * str = (CCString *)imgs->objectAtIndex(i);
        appImages->addObject(str);
    }
    
    for (int i=0; i<coImgs->count(); i++) {
        CCString * str = (CCString *)coImgs->objectAtIndex(i);
        colorImages->addObject(str);
    }
}

void FaceMaker::createXingXiangList()
{
    list11 = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    auto width1 = list11->getContentSize().width;
    auto height1 = list11->getContentSize().height;
    
    width1 = width1 * 0.5;
    height1 = height1 * 3;
    
    auto size = this->getXSize(list11, 0.5, 3);
    list11->setPreferredSize(size);
    
    list11->setPosition(ccp(50 + width1, SCREEN_HEIGHT / 2 -10));
    this->addChild(list11);
    
    auto list12 = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    list12->setPreferredSize(CCSizeMake(width1, height1));
    list12->setPosition(ccp(50 + width1 * 2, SCREEN_HEIGHT / 2 -10));
    this->addChild(list12);
}

void FaceMaker::yuLanBig()
{
    yuLanLayer = FMPreview::createPreviewLayer(CCSizeMake(600, 500));
    this->addChild(yuLanLayer);
    
    yuLanLayer->setPosition(ccp(300, 100));
}

// ************EditBox************
void FaceMaker::addEditBox()
{
    //**********输入角色名**************
    auto inputBox = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    
    auto size = getXSize(inputBox, 1.4, 0.4);
    
    inputBox->setPreferredSize(size);
    inputBox->setPosition(ccp(SCREEN_WIDTH / 2 + 30, 50));
    this->addChild(inputBox,-1);
    
    auto editBox = CCEditBox::create(CCSizeMake(150, 35.0), CCScale9Sprite::create());
    editBox->setPosition(inputBox->getPosition());
    editBox->setPlaceHolder("create your name");
    editBox->setInputMode(kEditBoxInputModeAny);
    editBox->setDelegate(this);
    editBox->setFontColor(ccBLACK);
    editBox->setTag(100);
    this->addChild(editBox,1);
    
    //*************昵称****************
    auto inputBox2 = CCSprite::create("Res/Image/dialog_frame.png");
    inputBox2->setScaleX(0.5);
    inputBox2->setScaleY(0.3);
    inputBox2->setPosition(ccp(SCREEN_WIDTH / 2 - 160, 50));
    this->addChild(inputBox2);
    
    auto editBox2 = CCEditBox::create(CCSizeMake(80, 35.0), CCScale9Sprite::create());
    editBox2->setPosition(inputBox2->getPosition());
    editBox2->setPlaceHolder("FrName");
    editBox2->setInputMode(kEditBoxInputModeAny);
    editBox2->setDelegate(this);
    editBox2->setFontColor(ccBLACK);
    editBox2->setTag(101);
    this->addChild(editBox2,1);
}

void FaceMaker::randomButton()
{
    auto randomTitle = CCLabelTTF::create("Random", "Arial", 20);
    randomTitle->setColor(ccBLACK);
    
    auto bg = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    auto size = this->getXSize(bg, 0.6, 0.4);
    
    auto randonButton = CCControlButton::create(randomTitle, bg);
    randonButton->setPosition(ccp(SCREEN_WIDTH / 2 + 230, 50));
    randonButton->setPreferredSize(size);
    randonButton->setTag(2);
    this->addChild(randonButton);
    randonButton->addTargetWithActionForControlEvents(this,cccontrol_selector(FaceMaker::selectRandomButton) , CCControlEventTouchDown);
}

void FaceMaker::selectRandomButton(CCObject *senderz, CCControlEvent controlEvent)
{
    auto nameEditBox = this->getNameEditBox();
    auto nickEditBox = this->getNickNameEditBox();
    
    //**********从plist文件中随机取姓，取名*********
    //**********这里姓有10个，名有10个**************
    int i = rand() % 10;
    int j = rand() % 10;
    
    nickEditBox->setText(CCString::createWithFormat("^_^!")->getCString());
    
    CCDictionary * plistDic = CCDictionary::createWithContentsOfFile("Res/Data/name.plist");
    
    CCArray * sexs = (CCArray *)plistDic->objectForKey("Sex");
    CCArray * names = (CCArray *)plistDic->objectForKey("Name");
    
    CCString * strSex = (CCString *)sexs->objectAtIndex(i);
    CCString * strNames = (CCString *)names->objectAtIndex(j);
    
    CCLOG("%s%s",strSex->getCString(),strNames->getCString());
    
    nameEditBox->setText(CCString::createWithFormat("%s%s",strSex->getCString(),strNames->getCString())->getCString());
}

void FaceMaker::createRoleButton()
{
    auto roleTile = CCLabelTTF::create("Create Role", "Arial", 20);
    roleTile->setColor(ccBLACK);
    
    auto bgPic = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    bgPic->setColor(ccBLUE);
    
    auto size = this->getXSize(bgPic, 0.8, 0.6);
    
    auto roleButton = CCControlButton::create(roleTile, bgPic);
    roleButton->setPosition(ccp(SCREEN_WIDTH / 2 + 380,70));
    roleButton->setPreferredSize(size);
    roleButton->addTargetWithActionForControlEvents(this, cccontrol_selector(FaceMaker::pressCreateRoleButton),CCControlEventTouchDown);
    this->addChild(roleButton);
}

void FaceMaker::pressCreateRoleButton(CCObject *senderz, CCControlEvent controlEvent)
{
    auto layerColor = CCLayerColor::create(ccc4(0, 0, 0, 125));
    this->addChild(layerColor,3);
    
    auto currentSex = yuLanLayer->getRoleSex();
    
    CCLOG("%d",currentSex);
    
    CCLOG("Enter the Game!");
}

CCEditBox * FaceMaker::getNameEditBox()
{
    auto nameEditBox = (CCEditBox *)this->getChildByTag(100);
    return nameEditBox;
}

CCEditBox * FaceMaker::getNickNameEditBox()
{
    auto nickEditBox = (CCEditBox *)this->getChildByTag(101);
    return nickEditBox;
}

//**************EditBox委托****************
void FaceMaker::editBoxEditingDidBegin(CCEditBox* editBox)
{
    
}

void FaceMaker::editBoxEditingDidEnd(CCEditBox* editBox)
{
    
}
void FaceMaker::editBoxTextChanged(CCEditBox* editBox, const std::string& text)
{
    
}
void FaceMaker::editBoxReturn(CCEditBox* editBox)
{
    
}

void FaceMaker::addScrollView()
{
    //******左scrollview******
    showScrollView1 = CCScrollView::create();
    continerLayer1 = CCLayer::create();
    
    auto size = this->getXSize(list11, 0.5, 3);
    showScrollView1->setViewSize(CCSizeMake(80, 476));
    showScrollView1->setContentOffset(CCPointZero);
    continerLayer1->setContentSize(CCSizeMake(size.width, size.height / 1.85));
    continerLayer1->setAnchorPoint(ccp(0, 1));
    continerLayer1->setPosition(ccp(0, -310));
    
    showScrollView1->setContentSize(CCSizeMake(size.width, size.height / 1.85));
    showScrollView1->setContainer(continerLayer1);
    showScrollView1->setDirection(kCCScrollViewDirectionVertical);
    showScrollView1->setPosition(ccp(105, 70));
    
    this->addChild(showScrollView1);
    
    //******右scrollview*******
    
    showScrollView2 = CCScrollView::create();
    continerLayer2 = CCLayer::create();
    
    showScrollView2->setTouchEnabled(true);
    auto size1 = this->getXSize(list11, 0.5, 3);
    showScrollView2->setViewSize(CCSizeMake(80, 476));
    
    continerLayer2->setContentSize(CCSizeMake(size1.width, size1.height / 1.85));
    continerLayer2->setAnchorPoint(ccp(0, 1));
    continerLayer2->setPosition(ccp(0, -310));
    
    showScrollView2->setContentSize(CCSizeMake(size1.width, size1.height / 1.85));
    showScrollView2->setContainer(continerLayer2);
    showScrollView2->setDirection(kCCScrollViewDirectionVertical);
    
    showScrollView2->setPosition(ccp(200, 70));
    this->addChild(showScrollView2);
    
    //*******scrollview中加入的图片******
    CCArray * leftImages = CCArray::create();
    CCArray * rightImages = CCArray::create();
    
    for (int i=0 ; i < 3; i++)
	{
        CCString * str = CCString::createWithFormat("Res/Image/dialog_frame.png");
        leftImages->addObject(str);
        rightImages->addObject(str);
    }
    
    list1Size = size;
    list2Size = size1; 
    
    this->addXingXiangImage(continerLayer1, leftImages);
    
    this->addColorImages(continerLayer2, rightImages);
}

void FaceMaker::addXingXiangImage(CCLayer * continerLayer,CCArray * picNames)
{
	auto size = this->getXSize(list11, 0.5, 3);
    
    if (picNames->count() <= 7)
	{
        continerLayer1->setContentSize(CCSizeMake(size.width, size.height/3.1));
        continerLayer1->setPosition(ccp(0,0));
        showScrollView1->setContentSize(CCSizeMake(size.width, size.height/3.1));
    }
    
    for (int i=0; i<picNames->count(); i++)
	{
        CCString * str = (CCString *)picNames->objectAtIndex(i);
        auto scale9Sprite = CCScale9Sprite::create(str->getCString());
        CCString * str2 = CCString::createWithFormat("tag=%d",i);

        auto btnTiTle = CCLabelTTF::create(str2->getCString(), "Arial", 20);
        btnTiTle->setColor(ccBLACK);
        auto btn = CCControlButton::create(btnTiTle, scale9Sprite);
        btn->setPreferredSize(BTNSIZE);
        
        btn->setSelected(true);
        btn->setAnchorPoint(ccp(0, 1));
        btn->setTag(i);
        btn->setPosition(ccp(0,continerLayer->getContentSize().height-i*BTNSIZE.height));
        btn->addTargetWithActionForControlEvents(this, cccontrol_selector(FaceMaker::pressXingBtn), CCControlEventTouchDown);
        continerLayer->addChild(btn);
    }
}

void FaceMaker::addColorImages(CCLayer * continerLayer, CCArray * colorImages)
{
    auto size = this->getXSize(list11, 0.5, 3);
    
    if (colorImages->count() <= 7)
	{
        continerLayer2->setContentSize(CCSizeMake(size.width, size.height/3.1));
        continerLayer2->setPosition(ccp(0,0));
        showScrollView2->setContentSize(CCSizeMake(size.width, size.height/3.1));
    }
    
    for (int i=0; i<colorImages->count(); i++)
	{
        CCString * str = (CCString *)colorImages->objectAtIndex(i);
        auto scale9Sprite = CCScale9Sprite::create(str->getCString());
        
        auto btnTiTle = CCLabelTTF::create();
        auto size = this->getXSize(scale9Sprite, 0.43, 0.4);
        auto btn = CCControlButton::create(btnTiTle, scale9Sprite);
        btn->setPreferredSize(size);
        btn->setSelected(true);
        btn->setAnchorPoint(ccp(0, 1));
        btn->setTag(i);
        btn->setColor(ccc3(rand()%256,rand()% 256,rand()%256));
        btn->setPosition(ccp(0, continerLayer->getContentSize().height-i*size.height));
        btn->addTargetWithActionForControlEvents(this, cccontrol_selector(FaceMaker::pressColorBtn),CCControlEventTouchDown);
        continerLayer->addChild(btn);
    }
}
void FaceMaker::pressXingBtn(CCObject *senderz, CCControlEvent controlEvent)
{
    auto btn = (CCControlButton *)senderz;
    btnTag2 = btn->getTag();
    
    auto currentRole = yuLanLayer->getCurrentRole();
    currentRole->setXingXiangTag(btnTag1, btnTag2, colorTag);
    
    this->setCurrentRoleXingXiangTxture(btnTag1, btnTag2, colorTag);
}


void FaceMaker::pressColorBtn(CCObject *senderz, CCControlEvent controlEvent)
{
    auto btn = (CCControlButton *)senderz;
    colorTag = btn->getTag();
    
    auto currentRole = yuLanLayer->getCurrentRole();
    currentRole->setXingXiangTag(btnTag1, btnTag2, colorTag);
    this->setCurrentRoleXingXiangTxture(btnTag1, btnTag2, colorTag);
}


void FaceMaker::setCurrentRoleXingXiangTxture(int btnTag,int imgTag,int colorTag)
{
    
}

void FaceMaker::scrollViewDidScroll(CCScrollView* view)
{
    
}

void FaceMaker::scrollViewDidZoom(CCScrollView* view)
{
    
}

CCSize FaceMaker::getXSize(CCScale9Sprite * s9sprite,float wideScale,float heightScale)
{
    auto width = s9sprite->getContentSize().width;
    auto height = s9sprite->getContentSize().height;
    
    width = width * wideScale;
    height = height * heightScale;
    
    return CCSizeMake(width, height);
}

int FaceMaker::getBtnTag()
{
    return btnTag1;
}