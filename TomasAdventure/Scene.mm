#import "Scene.h"

@implementation Scene

- (id)init {
    self = [super init];
    display = VBDisplay2DInit(VBDisplay2DAlloc());
    camera = VBDisplay2DGetCamera(display);
    return self;
}

- (Scene*)updateAndGetNextScene:(CFTimeInterval)_deltaTime {
    VBDisplay2DUpdate(display, _deltaTime);
    return nil;
}  

- (void)draw {
    VBDisplay2DDraw(display);
}

- (void)dealloc {
    VBDisplay2DFree(&display);
    [super dealloc];
}

@end
