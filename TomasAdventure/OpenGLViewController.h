#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "TomasData.h"
#import "TomasWorld.h"

@interface OpenGLViewController : UIViewController <UIAccelerometerDelegate, UIAlertViewDelegate> {
@public
    EAGLContext *context;
    
    BOOL animating;
    
    CFAbsoluteTime absoluteTime;
    
    NSTimer* timer;
    
    TomasData* tomasData;
    LevelData* levelData;
    Scene* currentScene;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tomasData:(TomasData*)_td levelData:(LevelData*)_ld;

- (void)quickLoad;

- (void)startAnimation;
- (void)stopAnimation;

@end
