#import <Foundation/Foundation.h>
#import "UILayer.h"

@interface JoyPadUILayer : UILayer {
    //UI관련 obj파일
    VBObjectFile2D* uiObjectFile;
    //UI관련 텍스쳐
    VBTexture* uiTexture;
    
    //기본 UI 모델
    VBModel2D* defaultUIModel;
    
    VBModel2D* itemUIModel;
    
    //이동관련 UI터치 포인터
    void* uiTouchPtrMove;
    //대쉬를 위한 탭카운트 올리는 시간
    float moveTabTime;
    //대쉬를 위한 탭카운트
    int moveTabCount;
    //액션버튼A 포인터
    void* uiTouchPtrActionA;
    //액션버튼B 포인터
    void* uiTouchPtrActionB;
    //메뉴버튼 포인터
    void* uiTouchPtrMenu;
    
    void* uiTouchPtrItem;
    
    void* action1Ptr;
}

- (id)initWithTomas:(TomasWorld *)_tomasWorld;

@end
