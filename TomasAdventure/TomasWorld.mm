#import "TomasWorld.h"
#import <OpenGLES/ES1/gl.h>
#import "GLES-Render.h"
#import "OpenGLViewController.h"
#import "JoyPadUILayer.h"

@implementation TomasWorld

- (id)initWithTomasData:(TomasData*)_tomasData withLevelData:(LevelData*)_levelData {
    self = [super init];
    if (self) {
        b2Vec2 gravity = b2Vec2(0, 30.0);
        world = new b2World(gravity);
        world->SetAllowSleeping(false);
        
        b2Draw* debugDraw = new GLESDebugDraw();
        uint32 flags = 0;
        flags += 1	* b2Draw::e_shapeBit;
        debugDraw->SetFlags(flags);
        world->SetDebugDraw(debugDraw);
        
        tomasData = _tomasData;
        levelData = _levelData;
        [levelData create:world];
        [levelData saveFirst];
        [levelData save];
        
        tomas = [[Tomas alloc] initWithWorld:world tomasData:tomasData pos:levelData->start];
        [tomas saveFirst];
        [tomas save];
        
        uiLayer = [[JoyPadUILayer alloc] initWithTomas:self];
        
        
        VBCamera2DSetZoom(camera, 40);
        VBVector2D pos = VBCamera2DGetPosition(camera);
        pos.x = levelData->start.x - VBEngineGetDefaultResourceScreenSize().x * 0.5f;
        pos.y = levelData->start.y - VBEngineGetDefaultResourceScreenSize().y * 0.5f;
        VBCamera2DSetPosition(camera, pos);
    }
    
    return self;
}

- (void)dealloc {
    [uiLayer release];
    [tomas release];
    [levelData clear];
    delete world;
    [super dealloc];
}

- (void)touchBeginCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    [uiLayer touchBeginCenterOfTomas:_touch_pointer x:_x y:_y];
}

- (void)touchMoveCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    [uiLayer touchMoveCenterOfTomas:_touch_pointer x:_x y:_y];
}

- (void)touchEndCenterOfTomas:(void*)_touch_pointer x:(float)_x y:(float)_y {
    [uiLayer touchEndCenterOfTomas:_touch_pointer x:_x y:_y];
}

- (void)accelerometerX:(float)_x y:(float)_y z:(float)_z {
    [uiLayer accelerometerX:_x y:_y z:_z];
}

- (void)quickLoad {
    [levelData load];
    [tomas load];
    
    VBCamera2DSetZoom(camera, 40);
    VBVector2D pos = VBCamera2DGetPosition(camera);
    pos.x = tomas->body->GetTransform().p.x - VBEngineGetDefaultResourceScreenSize().x * 0.5f;
    pos.y = tomas->body->GetTransform().p.y - VBEngineGetDefaultResourceScreenSize().y * 0.5f;
    VBCamera2DSetPosition(camera, pos);
}

- (void)quickSave {
    [levelData save];
    [tomas save];
}

- (Scene*)updateAndGetNextScene:(CFTimeInterval)_deltaTime {
    UILayer* newLayer = [uiLayer update:_deltaTime];
    if(newLayer) {
        [uiLayer release];
        uiLayer = newLayer;
    }
    
    VBVector2D pre_pos = VBVector2DCreate(tomas->body->GetPosition().x, tomas->body->GetPosition().y);
    
    world->Step(_deltaTime, 8, 1);
    
    
    VBVector2D force = VBVector2DSubtract(VBVector2DCreate(tomas->body->GetPosition().x, tomas->body->GetPosition().y), pre_pos);
    float zoom = VBCamera2DGetZoom(camera);
    zoom += (20.0 * (2 + VBVector2DLength(force) * 0.4 * 20.0) - zoom) * 0.05;
    VBCamera2DSetZoom(camera, zoom);
    VBVector2D pos = VBCamera2DGetPosition(camera);
    pos.x += (tomas->body->GetTransform().p.x/* + force.x * 30*/ - VBEngineGetDefaultResourceScreenSize().x * 0.5f - pos.x) * 0.2;//0.05;
    pos.y += (tomas->body->GetTransform().p.y/* + force.y * 30*/ - VBEngineGetDefaultResourceScreenSize().y * 0.5f - pos.y) * 0.2;//0.05;
    VBCamera2DSetPosition(camera, pos);
    
    [tomas update:_deltaTime];
    
    b2Fixture* fixture;
    fixture = tomas->body->GetFixtureList();
    VBAABB tomasAABB = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                    fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
    
    VBAABB aabb;
    for(int i = 0; i < [levelData->bodies count]; i++) {
        GameObject* obj = [levelData->bodies objectAtIndex:i];
        [obj update:_deltaTime];
        if(obj->type > 3000) {
            if(obj->body->IsActive()) {
                fixture = obj->body->GetFixtureList();
                aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                    fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                if (VBAABBHitTest(aabb, tomasAABB)) {
                    obj->body->SetActive(false);
                    //이벤트 발생
                    if (obj->type == 3001) {
                        NSLog(@"스토리및 이동방법 설명");
                    } else if(obj->type == 3002) {
                        NSLog(@"점프조작 설명");
                    } else if(obj->type == 3003) {
                        NSLog(@"세이브포인트 설명");
                    } else if(obj->type == 3004) {
                        NSLog(@"용암 설명");
                    } else if(obj->type == 3005) {
                        NSLog(@"연속로프 사용 설명");
                    } else if(obj->type == 3006) {
                        NSLog(@"활밟기 설명");
                    } else if(obj->type == 3007) {
                        NSLog(@"스토리및 이동방법 설명");
                    }
                }
            }
        }
        switch (obj->type) {
            case BodySave:
                fixture = obj->body->GetFixtureList();
                aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                    fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                if(VBAABBIsIn(aabb, tomasAABB)) {
                    if(lastSaveBody != obj->body) {
                        NSLog(@"자동 세이브");
                        //세이브
                        [self quickSave];
                        lastSaveBody = obj->body;
                    }
                } else if(obj->body == lastSaveBody) {
                    lastSaveBody = NULL;
                }
                break;
            case BodyDie:
                fixture = obj->body->GetFixtureList();
                aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                    fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                if (VBAABBHitTest(aabb, tomasAABB)) {
                    NSLog(@"죽음");
                    [self quickLoad];
                    //죽기(세이브포인트로)
                }
                break;
            case BodyEnd:
                fixture = obj->body->GetFixtureList();
                aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                    fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                if (VBAABBIsIn(aabb, tomasAABB)) {
                    NSLog(@"게임 클리어");
                    lastSaveBody = NULL;
                    [levelData loadFirst];
                    [tomas loadFirst];
                    [self quickSave];
                    //게임오버(처음부터)
                }
                break; 
            case BodyItemRope:
                if(obj->body->IsActive()) {
                    fixture = obj->body->GetFixtureList();
                    aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                        fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                    if (VBAABBHitTest(aabb, tomasAABB)) {
                        NSLog(@"로프 획득");
                        tomas->isHaveRope = YES;
                        obj->body->SetActive(false);
                        //로프획득
                    }
                }
            case BodyItemBow:
                if(obj->body->IsActive()) {
                    fixture = obj->body->GetFixtureList();
                    aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                        fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                    if (VBAABBHitTest(aabb, tomasAABB)) {
                        NSLog(@"활 획득");
                        tomas->isHaveBow = YES;
                        obj->body->SetActive(false);
                        //활 획득
                    }
                }
            case BodyItemBalloon:
                if(obj->body->IsActive()) {
                    fixture = obj->body->GetFixtureList();
                    aabb = VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                        fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y);
                    if (VBAABBHitTest(aabb, tomasAABB)) {
                        NSLog(@"열기구 획득");
                        tomas->isHaveBalloon = YES;
                        obj->body->SetActive(false);
                        //열기구 획득
                    }
                }
            default:
                break;
        }
    }
    
    return [super updateAndGetNextScene:_deltaTime];
}

- (void)draw {
    VBMatrix2D cameraMat = VBCamera2DGetMatrix(camera);
    float mat[16];
    mat[0] = cameraMat.m11;  mat[1] = cameraMat.m21;  mat[2] = 0;  mat[3] = cameraMat.m31;
    mat[4] = cameraMat.m12;  mat[5] = cameraMat.m22;  mat[6] = 0;  mat[7] = cameraMat.m32;
    mat[8] = 0;  mat[9] = 0;  mat[10] = 1;  mat[11] = cameraMat.m33;
    mat[12] = cameraMat.m13;  mat[13] = cameraMat.m23;  mat[14] = 0;  mat[15] = 1;
    
    glPushMatrix();
    glMultMatrixf(mat);
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    world->DrawDebugData();
    GLESDebugDraw* drawes = (GLESDebugDraw*)world->m_debugDraw;
    for(int i = 0; i < tomas->contactLen; i++) {
        drawes->DrawSegment(tomas->body->GetTransform().p, b2Vec2(-tomas->contactNormal[i].x + tomas->body->GetTransform().p.x, -tomas->contactNormal[i].y + tomas->body->GetTransform().p.y), b2Color(1.0, 0.0, 1.0, 1.0));
        drawes->DrawPoint(b2Vec2(-tomas->contactNormal[i].x + tomas->body->GetTransform().p.x, -tomas->contactNormal[i].y + tomas->body->GetTransform().p.y), 5, b2Color(1.0, 0.0, 1.0, 1.0));
        drawes->DrawPoint(tomas->body->GetTransform().p, 5, b2Color(1.0, 0.0, 1.0, 1.0));
    }
    tomas->contactLen = 0;
    
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glPopMatrix();
    
    [super draw];
    
    [uiLayer draw];
}

@end
