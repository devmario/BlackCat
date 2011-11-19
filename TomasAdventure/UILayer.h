#import <Foundation/Foundation.h>
#import "TomasWorld.h"

enum {
    //좌는 이동 우는 액션버튼 UI
    UILayerStyleJoyPad = 0x00,
    //터치위주의 UI
    UILayerStyleTouch = 0x01,
    //좌우로 나뉘어진(beyondYNTH) UI
    UILayerStyleDoublePad = 0x02,
    
};
typedef unsigned char UILayerStyle;

@interface UILayer : NSObject {
    @public
    TomasWorld* tomasWorld; 
    UILayerStyle style;
    UILayerStyle newStyle;
    
    //UI관련 디스플레이
    VBDisplay2D* uiLayer;
    //UI관련 카메라
    VBCamera2D* uiCamera;
}

- (id)initWithTomas:(TomasWorld*)_tomasWorld withStyle:(UILayerStyle)_style;

- (UILayerStyle)getUILayerStyle;
- (void)setUILayerStyle:(UILayerStyle)_style;

- (void)setEquiptment:(Equiptment)_equiptment;

- (void)touchBeginCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y;
- (void)touchMoveCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y;
- (void)touchEndCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y;
- (void)accelerometerX:(float)_x y:(float)_y z:(float)_z;

- (UILayer*)update:(CFTimeInterval)_interval;
- (void)draw;

@end
