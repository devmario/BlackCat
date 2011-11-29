#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"

#import "OpenGLViewController.h"

#import "VBEngine.h"

#define TIMER_INTERVAL (1.0/60.0)

OpenGLViewController* rootViewController = nil;

@interface OpenGLViewController ()
@property (nonatomic, retain) EAGLContext *context;
@end

@implementation OpenGLViewController

@synthesize animating, context;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch* touch in touches) {
        CGPoint touch_point = [touch locationInView:self.view];
        TomasWorld* world = (TomasWorld*)currentScene;
        [world touchBeginCenterOfTomas:touch x:touch_point.x * self.view.contentScaleFactor y:touch_point.y * self.view.contentScaleFactor];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch* touch in touches) {
        CGPoint touch_point = [touch locationInView:self.view];
        TomasWorld* world = (TomasWorld*)currentScene;
        [world touchMoveCenterOfTomas:touch x:touch_point.x * self.view.contentScaleFactor y:touch_point.y * self.view.contentScaleFactor];
    }
}

- (void)touchEnd:(UITouch*)touch {
    CGPoint touch_point = [touch locationInView:self.view];
    TomasWorld* world = (TomasWorld*)currentScene;
    [world touchEndCenterOfTomas:touch x:touch_point.x * self.view.contentScaleFactor y:touch_point.y * self.view.contentScaleFactor];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
    TomasWorld* world = (TomasWorld*)currentScene;
    [world accelerometerX:acceleration.x y:acceleration.y z:acceleration.z];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch* touch in touches) {
        [self touchEnd:touch];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch* touch in touches) {
        [self touchEnd:touch];
    }
}

- (void)quickLoad {
    TomasWorld* tw = (TomasWorld*)currentScene;
    [tw quickLoad];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tomasData:(TomasData*)_td levelData:(LevelData*)_ld {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    rootViewController = self;
    
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    
    tomasData = _td;
    levelData = _ld;
    currentScene = [[TomasWorld alloc] initWithTomasData:tomasData withLevelData:levelData];
    
    
    UIBarButtonItem* bt1 = [[UIBarButtonItem alloc] initWithTitle:@"퀵로드" style:UIBarButtonItemStylePlain target:self action:@selector(quickLoad)];
    NSArray* arr = [[NSArray alloc] initWithObjects:bt1, nil];
    [self.navigationItem setRightBarButtonItems:arr];
    [bt1 release];
    
    return self;
}

- (void)dealloc {
    [currentScene release];
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
    VBEngineClearDisplay();
    
    CFAbsoluteTime currentAbsoluteTime = CFAbsoluteTimeGetCurrent();
    Scene* nextScene = [currentScene updateAndGetNextScene:currentAbsoluteTime - absoluteTime];
    if(nextScene) {
        if(currentScene)
            [currentScene release];
        currentScene = nextScene;
    }
    
    [currentScene draw];
    
    absoluteTime = currentAbsoluteTime;
    
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (void)startAnimation
{
    if (!animating) {
        timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
        
        animating = TRUE;
    }
    [UIAccelerometer sharedAccelerometer].updateInterval = TIMER_INTERVAL;
    [UIAccelerometer sharedAccelerometer].delegate = self;
}

- (void)stopAnimation
{
    if (animating) {
        [timer invalidate];
        animating = FALSE;
    }
    [UIAccelerometer sharedAccelerometer].delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    else
        return NO;
}

@end
