#import "JoyPadUILayer.h"

//좌측하단 이동UI넓이
#define JOYPAD_MOVE_UI_WIDTH 320.0f
//좌측하단 이동UI높이
#define JOYPAD_MOVE_UI_HEIGHT 160.0f

//우측하단 액션UI넓이
#define JOYPAD_ACTION_UI_WIDTH 340.0f
//좌측하단 액션UI넓이
#define JOYPAD_ACTION_UI_HEIGHT 165.0f

//메뉴버튼 넓이
#define JOYPAD_MENU_UI_WIDTH 118.0f
//메뉴버튼 높이
#define JOYPAD_MENU_UI_HEIGHT 102.0f

#define ITEM_UI_X 58.0f
#define ITEM_UI_Y 58.0f
#define ITEM_UI_WIDTH 120.0f
#define ITEM_UI_HEIGHT 120.0f

@implementation JoyPadUILayer

- (id)initWithTomas:(TomasWorld *)_tomasWorld {
    self = [super initWithTomas:_tomasWorld withStyle:UILayerStyleJoyPad];
    
    VBString* path = VBStringInitWithCStringFormat(VBStringAlloc(), "%s/%s", VBStringGetCString(VBEngineGetResourcePath()), "ui.obj");
    uiObjectFile = VBObjectFile2DInitAndLoad(VBObjectFile2DAlloc(), path);
    VBStringFree(&path);
    
    path = VBStringInitWithCStringFormat(VBStringAlloc(), "%s/%s", VBStringGetCString(VBEngineGetResourcePath()), "ui.png");
    uiTexture = VBTextureInitAndLoadWithImagePath(VBTextureAlloc(), path);
    VBStringFree(&path);
    
    VBString* libName = VBStringInitWithCString(VBStringAlloc(), "DefaultUI");
    defaultUIModel = VBModel2DInitWithLibraryNameAndTexture(VBModel2DAlloc(), uiObjectFile, libName, uiTexture, VBTrue);
    VBStringFree(&libName);
    
    VBModel2DAddChildModel(VBDisplay2DGetTopModel(uiLayer), defaultUIModel);
    
    [self setEquiptment:EquiptmentEmpty];
    [_tomasWorld->tomas setUI:self];
    
    return self;
}

- (void)dealloc {
    if(uiTouchPtrMove) {
        [tomasWorld->tomas stopMove];
        [tomasWorld->tomas dash:NO];
    }
    if(uiTouchPtrActionB) {
        [tomasWorld->tomas slide:NO];
        [tomasWorld->tomas seet:NO];
    }
    
    VBModel2DFree(&defaultUIModel);
    VBTextureFree(&uiTexture);
    VBObjectFile2DFree(&uiObjectFile);
    
    [super dealloc];
}

- (void)setEquiptment:(Equiptment)_equiptment {
    if(itemUIModel)
        VBModel2DFree(&itemUIModel);
    
    char lib_name_char[0xFF] = {'\0',};
    sprintf(lib_name_char, "%i", _equiptment);
    VBString* libName = VBStringInitWithCString(VBStringAlloc(), lib_name_char);
    itemUIModel = VBModel2DInitWithLibraryNameAndTexture(VBModel2DAlloc(), uiObjectFile, libName, uiTexture, VBTrue);
    VBStringFree(&libName);
    VBModel2DSetPosition(itemUIModel, VBVector2DCreate(ITEM_UI_X, ITEM_UI_Y));
    VBModel2DAddChildModel(VBDisplay2DGetTopModel(uiLayer), itemUIModel);
}

//User Interface
- (void)touchBeginCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    [super touchBeginCenterOfTomas:_touch_pointer x:_x y:_y];
    BOOL inUI = NO;
    //터치벡터를 UI카메라 매트릭스에 해당하는 좌표로 변환
    VBVector2D touch_vector = VBMatrix2DMultiplyVBVector2D(VBMatrix2DInverse(VBCamera2DGetMatrix(uiCamera)), VBVector2DCreate(_x, _y));
    if(uiTouchPtrMenu == NULL) {
        //메뉴버튼AABB
        VBAABB aabbUIMenu = {VBEngineGetDefaultResourceScreenSize().x - JOYPAD_MENU_UI_WIDTH, 0.0f, VBEngineGetDefaultResourceScreenSize().x, JOYPAD_MENU_UI_HEIGHT};
        if(VBAABBHitTestWithVector2D(aabbUIMenu, touch_vector)) {
            inUI = YES;
            uiTouchPtrMenu = _touch_pointer;
        }
    }
    if(uiTouchPtrMove == NULL) {
        //이동버튼AABB
        VBAABB aabbUIMove = {0.0f, VBEngineGetDefaultResourceScreenSize().y - JOYPAD_MOVE_UI_HEIGHT, JOYPAD_MOVE_UI_WIDTH, VBEngineGetDefaultResourceScreenSize().y};
        if(VBAABBHitTestWithVector2D(aabbUIMove, touch_vector)) {
            if(moveTabTime > 0.0f) {
                moveTabCount++;
            } else {
                moveTabCount = 1;
            }
            moveTabTime = 0.25;
            tomasWorld->tomas->body->SetAwake(true);
            [tomasWorld->tomas move:(touch_vector.x <= JOYPAD_MOVE_UI_WIDTH * 0.5f)];
            [tomasWorld->tomas dash:(moveTabCount > 1)];
            inUI = YES;
            uiTouchPtrMove = _touch_pointer;
        }
    }
    if(uiTouchPtrActionA == NULL) {
        //Action A버튼 AABB
        VBAABB aabbUIActionA = {VBEngineGetDefaultResourceScreenSize().x - JOYPAD_ACTION_UI_WIDTH, VBEngineGetDefaultResourceScreenSize().y - JOYPAD_MOVE_UI_HEIGHT, VBEngineGetDefaultResourceScreenSize().x - JOYPAD_ACTION_UI_WIDTH * 0.5f, VBEngineGetDefaultResourceScreenSize().y};
        if(VBAABBHitTestWithVector2D(aabbUIActionA, touch_vector)) {
            tomasWorld->tomas->body->SetAwake(true);
            [tomasWorld->tomas jump];
            inUI = YES;
            uiTouchPtrActionA = _touch_pointer;
        }
    }
    if(uiTouchPtrActionB == NULL) {
        //Action B버튼 AABB
        VBAABB aabbUIActionB = {VBEngineGetDefaultResourceScreenSize().x - JOYPAD_ACTION_UI_WIDTH * 0.5f, VBEngineGetDefaultResourceScreenSize().y - JOYPAD_MOVE_UI_HEIGHT, VBEngineGetDefaultResourceScreenSize().x, VBEngineGetDefaultResourceScreenSize().y};
        if(VBAABBHitTestWithVector2D(aabbUIActionB, touch_vector)) {
            tomasWorld->tomas->body->SetAwake(true);
            [tomasWorld->tomas slide:YES];
            [tomasWorld->tomas seet:YES];
            inUI = YES;
            uiTouchPtrActionB = _touch_pointer;
        }
    }
    if(uiTouchPtrItem == NULL) {
        VBAABB aabbUIItem = {0.0f, 0.0f, ITEM_UI_WIDTH, ITEM_UI_HEIGHT};
        if(VBAABBHitTestWithVector2D(aabbUIItem, touch_vector)) {
            inUI = YES;
            uiTouchPtrItem = _touch_pointer;
        }
    }
    if(inUI == NO) {
        if(action1Ptr == NULL) {
            if([tomasWorld->tomas getEquiptment] == EquiptmentRope) {
                if(tomasWorld->tomas->ropeActionType == RopeHangOff) {
                    VBVector2D ropePos = VBVector2DCreate(touch_vector.x - 480.0f, touch_vector.y - 320.0f);
                    [tomasWorld->tomas ropeThrow:ropePos];
                } else {
                    [tomasWorld->tomas ropeThrow:VBVector2DZero()];
                }
            } else if([tomasWorld->tomas getEquiptment] == EquiptmentBow) {
                [tomasWorld->tomas bowBegin:touch_vector];
            } else if([tomasWorld->tomas getEquiptment] == EquiptmentBalloon) {
                if(tomasWorld->tomas->balloon == NULL)
                    [tomasWorld->tomas ballon];
            }
            action1Ptr = _touch_pointer;
        }
    }
}

- (void)touchMoveCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    [super touchMoveCenterOfTomas:_touch_pointer x:_x y:_y];
    BOOL inUI = NO;
    //터치벡터를 UI카메라 매트릭스에 해당하는 좌표로 변환
    VBVector2D touch_vector = VBMatrix2DMultiplyVBVector2D(VBMatrix2DInverse(VBCamera2DGetMatrix(uiCamera)), VBVector2DCreate(_x, _y));
    if(uiTouchPtrMove == _touch_pointer) {
        tomasWorld->tomas->body->SetAwake(true);
        [tomasWorld->tomas move:(touch_vector.x <= JOYPAD_MOVE_UI_WIDTH * 0.5f)];
        inUI = YES;
    }
    if(uiTouchPtrActionA == _touch_pointer) {
        inUI = YES;
    }
    if(uiTouchPtrActionB == _touch_pointer) {
        inUI = YES;
    }
    if(uiTouchPtrMenu == _touch_pointer) {
        inUI = YES;
    }
    if(uiTouchPtrItem == _touch_pointer) {
        inUI = YES;
    }
    if(inUI == NO) {
        if(action1Ptr == _touch_pointer) {
            if([tomasWorld->tomas getEquiptment] == EquiptmentBow) {
                [tomasWorld->tomas bowMove:touch_vector];
            }
        }
    }
    
}

- (void)touchEndCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    [super touchEndCenterOfTomas:_touch_pointer x:_x y:_y];
    BOOL inUI = NO;
    //터치벡터를 UI카메라 매트릭스에 해당하는 좌표로 변환
    VBVector2D touch_vector = VBMatrix2DMultiplyVBVector2D(VBMatrix2DInverse(VBCamera2DGetMatrix(uiCamera)), VBVector2DCreate(_x, _y));
    if(uiTouchPtrMove == _touch_pointer) {
        tomasWorld->tomas->body->SetAwake(true);
        [tomasWorld->tomas stopMove];
        [tomasWorld->tomas dash:NO];
        inUI = YES;
        uiTouchPtrMove = NULL;
    }
    if(uiTouchPtrActionA == _touch_pointer) {
        inUI = YES;
        uiTouchPtrActionA = NULL;
    }
    if(uiTouchPtrActionB == _touch_pointer) {
        tomasWorld->tomas->body->SetAwake(true);
        [tomasWorld->tomas slide:NO];
        [tomasWorld->tomas seet:NO];
        inUI = YES;
        uiTouchPtrActionB = NULL;
    }
    if(uiTouchPtrMenu == _touch_pointer) {
        [tomasWorld quickLoad];
        inUI = YES;
        uiTouchPtrMenu = NULL;
    }
    if(uiTouchPtrItem == _touch_pointer) {
        [tomasWorld->tomas setNextEquiptment];
        inUI = YES;
        uiTouchPtrItem = NULL;
    }
    if(inUI == NO) {
        if(action1Ptr == _touch_pointer) {
            if([tomasWorld->tomas getEquiptment] == EquiptmentBow) {
                [tomasWorld->tomas bowEnd:touch_vector];
            } else if([tomasWorld->tomas getEquiptment] == EquiptmentBalloon) {
                if(tomasWorld->tomas->balloon)
                    [tomasWorld->tomas ballon];
            }
            action1Ptr = NULL;
        }
    }
}

- (void)accelerometerX:(float)_x y:(float)_y z:(float)_z {
    [super accelerometerX:_x y:_y z:_z];
    if(tomasWorld->tomas->balloonActionType == BalloonOn) {
        float yx = -atan2f(_y, _x);
        VBVector2D polar = VBVector2DPolar(1.0, yx);
        tomasWorld->tomas->balloonTargetX = -polar.y * 2.5f;
    }
}

- (UILayer*)update:(CFTimeInterval)_interval {
    if(moveTabTime > 0.0f)
        moveTabTime -= (float)_interval;
    return [super update:_interval];
}

- (void)draw {
    [super draw];
}

@end
