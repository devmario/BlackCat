#import <Foundation/Foundation.h>
#import "VBEngine.h"

@interface Scene : NSObject {
@public
    VBDisplay2D* display;
    VBCamera2D* camera;
}

- (Scene*)updateAndGetNextScene:(CFTimeInterval)_deltaTime;
- (void)draw;

@end
