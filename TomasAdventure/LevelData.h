#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "Box2D.h"
#import "VBEngine.h"

enum {
    BodyType_Ground         =       0,
    BodyType_Damage         =       1,
    BodyType_Save           =       2,
    BodyType_GravityField   =       3,
    BodyType_Item           =    1000,
};
typedef int BodyType;

enum {
    ItemTypeRope            =       0,
    ItemTypeBow             =       1,
    ItemTypeBalloon         =       2,
};
typedef int ItemType;

enum {
    DamageType_Thorn        =       0,
    DamageType_Lava         =       1,
};
typedef int DamageType;

enum {
    GravityFieldType_Water  =       0,
};
typedef int GravityFieldType;

typedef struct {
    b2BodyDef def;
    float friction;
    float restitution;
    float density;
    int shapeLen;
    b2Vec2* shape;
} ShapeBodyData;

typedef struct {
    ShapeBodyData* shapeData;
} GroundBodyData;

typedef struct {
    float damage;
    ShapeBodyData* shapeData;
} DamageBodyData;

typedef struct {
    ShapeBodyData* shapeData;
} SaveBodyData;

typedef struct {
    ItemType itemType;
    ShapeBodyData* shapeData;
} ItemBodyData;

typedef struct {
    GravityFieldType gravityFieldType;
    b2Vec2 gravity;
    ShapeBodyData* shapeData;
} GravityFieldBodyData;

typedef struct {
    BodyType bodyType;
    void* data;
} BodyData;

@interface LevelData : NSObject {
@public
    b2World* world;
    NSMutableArray* bodies;
    VBVector2D start;
    VBAABB end;
    NSMutableDictionary* saveDataFirst;
    NSMutableDictionary* saveData;
}

- (id)initWithContentsOfFile:(NSString*)_url_str world:(b2World*)_world;

- (void)saveFirst;
- (void)save;
- (void)loadFirst;
- (void)load;

@end
