#import "UILayer.h"
#import "JoyPadUILayer.h"

@implementation UILayer

- (id)initWithTomas:(TomasWorld*)_tomasWorld withStyle:(UILayerStyle)_style {
    self = [super init];
    tomasWorld = _tomasWorld;
    newStyle = style = _style;
    
    uiLayer = VBDisplay2DInit(VBDisplay2DAlloc());
    uiCamera = VBDisplay2DGetCamera(uiLayer);
    
    return self;
}

- (void)dealloc {
    VBDisplay2DFree(&uiLayer);
    [super dealloc];
}

- (UILayerStyle)getUILayerStyle {
    return style;
}

- (void)setUILayerStyle:(UILayerStyle)_style {
    if(newStyle != _style) {
        newStyle = _style;
    }
}

- (void)setEquiptment:(Equiptment)_equiptment {
    
}

- (void)touchBeginCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    
}

- (void)touchMoveCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    
}

- (void)touchEndCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    
}

- (void)accelerometerX:(float)_x y:(float)_y z:(float)_z {
    
}

- (UILayer*)update:(CFTimeInterval)_interval {
    VBDisplay2DUpdate(uiLayer, _interval);
    if(style != newStyle) {
        switch (newStyle) {
            case UILayerStyleJoyPad:
                UILayer* newUILayer = [[JoyPadUILayer alloc] initWithTomas:tomasWorld];
                return newUILayer;
                break;
        }
    }
    return nil;
}

- (void)draw {
    VBDisplay2DDraw(uiLayer);
}

@end
