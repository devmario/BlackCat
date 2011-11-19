#import <Foundation/Foundation.h>
#ifndef WORLDB2
#import "Box2D.h"
#endif

enum {
    BodyGround              =   0,
    BodyWall                =   1,
    BodyCeiling             =   2,
    BodySave                =   3,
    BodyDie                 =   4,
    BodyRock                =   5,
    BodyLadders             =   6,
    BodyItemRope            =   100,
    BodyItemBow             =   101,
    BodyItemBalloon         =   102,
    BodyEnd                 =   999,
    BodyTomasBody           =   1000,
    BodyTomasLeg            =   1001,
    BodyRope                =   2001,
    BodyArrow               =   2002,
    BodyArrowHit            =   2003,
    BodyArrowGuideOn        =   2004,
    BodyArrowGuideOff       =   2005,
    BodyBalloon             =   2006,
    BodyParachute           =   2007,
};
typedef int BodyType;

@interface GameObject : NSObject {
@public
    BodyType type;
    b2Body* body;
    b2World* world;
    CFTimeInterval _elapse;
}

- (id)initWithWorld:(b2World*)_world 
            bodyDef:(b2BodyDef)_body_def 
         fixtureDef:(b2FixtureDef)_fixture_Def;

- (void)update:(CFTimeInterval)_delta;

@end
