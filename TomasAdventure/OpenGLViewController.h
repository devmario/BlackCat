#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "TomasData.h"
#import "TomasWorld.h"

@interface OpenGLViewController : UIViewController <UIAccelerometerDelegate, UIAlertViewDelegate> {
@private
    EAGLContext *context;
    
    BOOL animating;
    
    CFAbsoluteTime absoluteTime;
    
    NSTimer* timer;
    
    
    TomasData* tomasData;
    Scene* currentScene;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;

- (void)startAnimation;
- (void)stopAnimation;

@end
