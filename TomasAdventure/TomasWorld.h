#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "TomasData.h"
#import "LevelData.h"
#import "Scene.h"
#import "Tomas.h"

@class UILayer;

@interface TomasWorld : Scene {
@public
    //Box2D포인터
    b2World* world;
    
    //캐릭터 데이터
    TomasData* tomasData;
    //레벨 데이터
    LevelData* levelData;
    
    //캐릭터
    Tomas* tomas;
    
    //세이브 영역안에 들어왔을때 한번만 세이브 발생하기 위한 마지막 세이브 바디 포인터
    b2Body* lastSaveBody;
    
    UILayer* uiLayer;
}

- (id)initWithTomasData:(TomasData*)_tomasData;

//User Interface
- (void)touchBeginCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y;
- (void)touchMoveCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y;
- (void)touchEndCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y;
- (void)accelerometerX:(float)_x y:(float)_y z:(float)_z;

- (void)quickLoad;
- (void)quickSave;

@end
