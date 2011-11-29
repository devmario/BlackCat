#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "Box2D.h"
#import "VBEngine.h"

@interface LevelData : NSObject {
@public
    b2World* world;
    
    VBVector2D start;
    VBAABB end;
    
    NSMutableArray* bodies;
    NSMutableArray* saveBody;
    
    NSMutableDictionary* saveDataFirst;
    NSMutableDictionary* saveData;
}

- (id)initWithContentsOfFile:(NSString*)_url_str;

- (void)create:(b2World*)_world;
- (void)clear;

- (void)saveFirst;
- (void)save;
- (void)loadFirst;
- (void)load;

@end
