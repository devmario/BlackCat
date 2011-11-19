#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "TomasData.h"
#import "VBEngine.h"

//움직임
enum {
    EquiptmentEmpty     =   0x00,
    EquiptmentRope      =   0x01,
    EquiptmentBow       =   0x02,
    EquiptmentBalloon   =   0x03,
    EquiptmentMax       =   0x04
};
typedef int Equiptment;

//로프
enum {
    RopeHangOff =   0x00,
    RopeHangOn  =   0x01,
};
typedef unsigned char RopeActionType;

//열기구
enum {
    BalloonOff  =   0x00,
    BalloonOn   =   0x01,
};
typedef unsigned char BalloonActionType;

//활
enum {
    BowOff      =   0x00,
    BowReady    =   0x01,
    BowShot     =   0x02,
};
typedef unsigned char BowActionType;

//총
enum {
    GunOff      =   0x00,
    GunShot     =   0x01
};
typedef unsigned char GunActionType;

//낙하산
enum {
    ParachuteOff    =   0x00,
    ParachuteOn     =   0x01
};
typedef unsigned char ParachuteActionType;

//화살
@interface Arrow : GameObject {
@public
    BOOL isHit;
    b2Vec2 hitPos;
    float hitAngle;
    float life;
}
@end

//주인공 캐릭터
@interface Tomas : GameObject {
@public
    int contactLen;
    b2Vec2 contactNormal[12];
    
    TomasData* tomasData;
    
    NSMutableDictionary* saveDataFirst;
    NSMutableDictionary* saveData;
    
    BOOL isMoveLeft;
    BOOL isMoveRight;
    BOOL isMoveChange;
    BOOL isMove;
    
    BOOL isDash;
    
    BOOL isJump;
    BOOL isWannaJump;
    
    BOOL isSlide;
    BOOL isWannaSlide;
    float slideTime;
    
    BOOL isSeet;
    BOOL isWannaSeet;
    
    BOOL isChangeShape;
    
    Equiptment equiptment;
    id ui_id;
    
    BOOL is_fall;
    
    BOOL isHaveRope;
    RopeActionType ropeActionType;
    NSMutableArray* ropeArray;
    VBArrayVector* ropeJointArray;
    b2RopeJoint* ropeJoint;
    
    BOOL isHaveBalloon;
    BalloonActionType balloonActionType;
    GameObject* balloon;
    b2RevoluteJoint* balloonJoint;
    float balloonX;
    float balloonTargetX;
    
    BOOL isHaveBow;
    BowActionType bowActionType;
    GameObject* arrowGuide;
    NSMutableArray* arrowArray;
    VBVector2D bowBeginVec;
    VBVector2D bowDir;
    float bowCount;
    float bowCoolTime;
    
    VBAABB tomasAABB;
}

- (id)initWithWorld:(b2World*)_world 
          tomasData:(TomasData*)_tomasData 
                pos:(VBVector2D)_pos;

//이동
- (void)move:(BOOL)_isLeft;
- (void)stopMove;
- (void)dash:(BOOL)_isDash;
- (void)jump;
- (void)slide:(BOOL)_isSlide;
- (void)seet:(BOOL)_isSeet;

- (void)setUI:(id)_ui_id;
- (void)setNextEquiptment;
- (BOOL)setEquiptment:(Equiptment)_equiptment;
- (Equiptment)getEquiptment;

//줄
- (void)ropeThrow:(VBVector2D)value;
- (void)ropeOff;

//열기구
- (void)ballon;

//활
- (void)bowOff;
- (BOOL)bowAvailable:(VBVector2D)_vec;
- (void)bowBegin:(VBVector2D)_vec;
- (void)bowMove:(VBVector2D)_vec;
- (void)bowEnd:(VBVector2D)_vec;

//세이브, 로드
- (void)saveFirst;
- (void)save;
- (void)loadFirst;
- (void)load;

- (void)updateTomasAABB;
- (void)updateMove;
- (void)updateJump;

@end
