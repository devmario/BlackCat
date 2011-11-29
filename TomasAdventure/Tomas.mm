#import "Tomas.h"
#import "UILayer.h"

//캐릭터와의 충돌체크를 할때의 확장영역
#define CHARACTER_HITTEST_MARGIN 1.0f

#define RopeMaxLength 150.0/20.0

class TomasContactFilter : public b2ContactFilter {
public:
    void* tomasAddress;
    void* tomasLegAddress;
    
    bool ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB) {
        Tomas* tomas = (Tomas*)tomasAddress;
        
        int findTomasBodyCollideCount = 0;
        if(tomas->body == fixtureA->GetBody())
            findTomasBodyCollideCount++;
        if(tomas->body == fixtureB->GetBody())
            findTomasBodyCollideCount++;
        
        int findArrowCollideCount = 0;
        for(int i = 0; i < [tomas->arrowArray count]; i++) {
            Arrow* _arrow = [tomas->arrowArray objectAtIndex:i];
            if(_arrow->body == fixtureA->GetBody())
                findArrowCollideCount++;
            if(_arrow->body == fixtureB->GetBody())
                findArrowCollideCount++;
        }
        if(findArrowCollideCount > 1)
            return false;
        
        int findRopeCollideCount = 0;
        for(int i = 0; i < [tomas->ropeArray count]; i++) {
            GameObject* _rope = [tomas->ropeArray objectAtIndex:i];
            if(_rope->body == fixtureA->GetBody())
                findRopeCollideCount++;
            if(_rope->body == fixtureB->GetBody())
                findRopeCollideCount++;
        }
        //로프끼리 충돌
        if(findRopeCollideCount > 1)
            return false;
        //로프와 캐릭터 충돌
        if(findRopeCollideCount > 0 && findTomasBodyCollideCount > 0)
            return false;
        
        return true;
    }
};

class TomasContactListener : public b2ContactListener {
public:
    
    void* tomasAddress;
    void* tomasLegAddress;
    
    bool CheckJumpTomas(b2Contact* contact, b2Body* body, b2Body* body2) {
        Tomas* tomas = (Tomas*)tomasAddress;
        if(body->GetUserData() == tomasLegAddress) {
            if(tomas->balloonActionType == BalloonOff) {
                if(body2->GetFixtureList()->IsSensor() == false) {
                    b2WorldManifold worldManifold;
                    worldManifold.Initialize(contact->GetManifold(), 
                                             contact->GetFixtureA()->GetBody()->GetTransform(), 
                                             contact->GetFixtureA()->GetShape()->m_radius,
                                             contact->GetFixtureB()->GetBody()->GetTransform(), 
                                             contact->GetFixtureB()->GetShape()->m_radius);
                    
                    b2Vec2 point;
                    for (int32 i = 0; i < contact->GetManifold()->pointCount; ++i) {
                        point = body->GetWorldCenter() - worldManifold.points[i];
                        //                        printf("BeginContact tomas hit vector (%f, %f)\n", point.x, point.y);
                    }
                    GameObject* obj = (GameObject*)body2->GetUserData();
                    if(obj->type != BodyArrowHit) {
                        if(point.y < 0.0 && point.x == 0.0f) {
                            body->GetFixtureList()->SetFriction(1.0);
                            tomas->isJump = NO;
                            if(tomas->isDash)
                                tomas->isDash = NO;
                        } else {
                            body->GetFixtureList()->SetFriction(0.0);
                        }
                    } else {
                        if(point.y < 0.0) {
                            body->GetFixtureList()->SetFriction(1.0);
                            tomas->isJump = NO;
                        } else {
                            body->GetFixtureList()->SetFriction(0.0);
                        }
                    }
                }
            }
            return true;
        }
        return false;
    }
    
    bool CheckBalloonTomas(b2Body* body1, b2Body* body2) {
        Tomas* tomas = (Tomas*)tomasAddress;
        if(body1->GetUserData() == tomas->balloon) {
            if(tomas->body != body2) {
                //[tomas ballon];
                return true;
            }
        }
        return false;
    }
    
    bool CheckArrow(b2Body* body1, b2Body* body2, b2Contact* contact, const b2ContactImpulse* impulse) {
        GameObject* _arrowObj = (GameObject*)body1->GetUserData();
        Tomas* tomas = (Tomas*)tomasAddress;
        if(_arrowObj->type == BodyArrow && (body2 != tomas->body)) {
            Arrow* _arrow = (Arrow*)_arrowObj;
            for(int i = 0; i < [tomas->arrowArray count]; i++) {
                if(_arrow == [tomas->arrowArray objectAtIndex:i]) {
                    printf("%f\n", impulse->normalImpulses[0]);
                    if(impulse->normalImpulses[0] > 0.025 && contact->GetManifold()->points[0].localPoint.x < 0.0) {
                        _arrow->isHit = YES;
                        _arrow->type = BodyArrowHit;
                        _arrow->hitPos = body1->GetPosition();
                        _arrow->hitAngle = body1->GetAngle();
                    }
                    return true;
                }
            }
        }
        return false;
    }
    
    void BeginContact(b2Contact* contact) {
        //printf("begin contact\n");
        //        if(CheckBalloonTomas(contact->GetFixtureA()->GetBody(), contact->GetFixtureB()->GetBody()) == false) {
        //            CheckBalloonTomas(contact->GetFixtureB()->GetBody(), contact->GetFixtureA()->GetBody());
        //        }
        //        if(CheckJumpTomas(contact, contact->GetFixtureA()->GetBody(), contact->GetFixtureB()->GetBody()) == false) {
        //            CheckJumpTomas(contact, contact->GetFixtureB()->GetBody(), contact->GetFixtureA()->GetBody());
        //        }
    }
    
    void EndContact(b2Contact* contact) {
        //printf("end contact\n");
    }
    
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
        GameObject* objA = (GameObject*)contact->GetFixtureA()->GetBody()->GetUserData();
        GameObject* objB = (GameObject*)contact->GetFixtureB()->GetBody()->GetUserData();
        b2WorldManifold manifold;
        contact->GetWorldManifold(&manifold);
        if(contact->GetManifold()->pointCount) {
            if((objA->type == BodyGround || objA->type == BodyArrowHit) && objB->type == BodyTomasBody) {
                Tomas* tomas = (Tomas*)objB;
                tomas->contactNormal[tomas->contactLen] = manifold.normal;
                tomas->contactLen++;
                float _normalAngle = VBVector2DAngle(VBVector2DCreate(manifold.normal.x, manifold.normal.y));
                if(tomas->isMoveLeft) {
                    if(_normalAngle > -M_PI_4 && _normalAngle < M_PI_2) {
                        tomas->body->SetLinearVelocity(b2Vec2(0.0, tomas->body->GetLinearVelocity().y));
                        tomas->isDash = NO;
                    }
                } else if(tomas->isMoveRight) {
                    if(_normalAngle < -M_PI + M_PI_4 || _normalAngle >= M_PI_2) {
                        tomas->body->SetLinearVelocity(b2Vec2(0.0, tomas->body->GetLinearVelocity().y));
                        tomas->isDash = NO;
                    }
                }
                
                if(tomas->isJump == NO && (tomas->isMoveRight || tomas->isMoveLeft)) {
                    if(_normalAngle >= -M_PI + M_PI_4 && _normalAngle <= -M_PI_4) {
                        float dirAngle = _normalAngle;
                        if(tomas->isMoveLeft)
                            dirAngle -= M_PI_2;
                        if(tomas->isMoveRight)
                            dirAngle += M_PI_2;
                        VBVector2D dir = VBVector2DPolar((tomas->isDash ? 10 : (tomas->isSeet ? 2.5 : 5)), dirAngle);
                        tomas->body->SetLinearVelocity(b2Vec2(dir.x, dir.y));
                    }
                }
            }
        }
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
        
        if(CheckArrow(contact->GetFixtureA()->GetBody(), contact->GetFixtureB()->GetBody(), contact, impulse) == false) {
            CheckArrow(contact->GetFixtureB()->GetBody(), contact->GetFixtureA()->GetBody(), contact, impulse);
        }
        if(CheckArrow(contact->GetFixtureA()->GetBody(), contact->GetFixtureB()->GetBody(), contact, impulse) == false) {
            CheckArrow(contact->GetFixtureB()->GetBody(), contact->GetFixtureA()->GetBody(), contact, impulse);
        }
        //        GameObject* objA = (GameObject*)contact->GetFixtureA()->GetBody()->GetUserData();
        //        GameObject* objB = (GameObject*)contact->GetFixtureB()->GetBody()->GetUserData();
        //        if((objA->type == BodyGround || objA->type == BodyArrowHit) && objB->type == BodyTomasBody) {
        //            Tomas* tomas = (Tomas*)objB;
        //            for(int i = 0; i < impulse->count; i++) {
        //                VBVector2D dir = VBVector2DPolar(impulse->normalImpulses[i], impulse->tangentImpulses[i] + M_PI_2);
        //                tomas->body->SetLinearVelocity(b2Vec2(
        //                                                      tomas->body->GetLinearVelocity().x + dir.x,
        //                                                      tomas->body->GetLinearVelocity().y + dir.y
        //                                               ));
        //            }
        //        }
    }
    
};

@implementation Arrow

@end


@implementation Tomas



- (void)initAnother {
    isMoveLeft = NO;
    isMoveRight = NO;
    isJump = NO;
    isWannaJump = NO;
    
    isHaveRope = NO;
    ropeActionType = RopeHangOff;
    
    isHaveBalloon = NO;
    balloonActionType = BalloonOff;
    
    isHaveBow = NO;
    bowActionType = BowOff;
    bowDir = VBVector2DZero();
    bowCount = 0.0f;
    bowCoolTime = 0.3f;
}

- (void)freeAnother {
    {//활 변수들 해제
        while([arrowArray count]) {
            Arrow* _arrow = [arrowArray objectAtIndex:0];
            [_arrow release];
            [arrowArray removeObjectAtIndex:0];
        }
    }
    
    {//로프 변수들 해제
        while([ropeArray count]) {
            GameObject* rope = [ropeArray lastObject];
            while(rope->body->GetJointList()) {
                b2Joint* ropejoint = (b2RevoluteJoint*)VBArrayVectorRemoveBack(ropeJointArray);
                if(ropejoint)
                    world->DestroyJoint(ropejoint);
            }
            [rope release];
            [ropeArray removeLastObject];
        }
    }
    
    if(balloonJoint) {
        world->DestroyJoint(balloonJoint);
        balloonJoint = NULL;
    }
    if(balloon) {
        [balloon release];
        balloon = nil;
    }
}

- (id)initWithWorld:(b2World*)_world 
          tomasData:(TomasData*)_tomasData 
                pos:(VBVector2D)_pos  {
    b2BodyDef _bodyDef;
    _bodyDef.type = b2_dynamicBody;
    _bodyDef.position.Set(_pos.x, _pos.y);
    _bodyDef.angle = 0.0;
    _bodyDef.fixedRotation = true;
    _bodyDef.bullet = true;
    
    b2Vec2 vec[4];
    vec[0] = b2Vec2(-5/20.0, -8/20.0);
    vec[1] = b2Vec2(5/20.0, -8/20.0);
    vec[2] = b2Vec2(5/20.0, 8/20.0);
    vec[3] = b2Vec2(-5/20.0, 8/20.0);
    
    b2PolygonShape* polygonShape = new b2PolygonShape;
    polygonShape->Set(vec, 4);
    
    b2FixtureDef _fixtureDef;
    _fixtureDef.shape = polygonShape;
    _fixtureDef.density = 1.0;
    _fixtureDef.restitution = 0;
    _fixtureDef.isSensor = false;
    _fixtureDef.friction = 1.0;
    
    self = [super initWithBodyDef:_bodyDef fixtureDef:_fixtureDef shape:polygonShape];
    self->type = BodyTomasBody;
    [self create:_world];
    
    TomasContactListener* contactListner = new TomasContactListener;
    contactListner->tomasAddress = self;
    world->SetContactListener(contactListner);
    TomasContactFilter* contactFilter = new TomasContactFilter;
    contactFilter->tomasAddress = self;
    world->SetContactFilter(contactFilter);
    
    _tomasData = tomasData;
    
    ropeArray = [[NSMutableArray alloc] init];
    ropeJointArray = VBArrayVectorInit(VBArrayVectorAlloc());
    arrowArray = [[NSMutableArray alloc] init];
    
    saveData = [[NSMutableDictionary alloc] init];
    saveDataFirst = [[NSMutableDictionary alloc] init];
    
    [self initAnother];
    
    return self;
}

- (void)dealloc {
    [self freeAnother];
    
    [ropeArray release];
    [arrowArray release];
    VBArrayVectorFree(&ropeJointArray);
    
    [saveDataFirst release];
    [saveData release];
    [super dealloc];
}

- (void)updateTomasAABB {
    tomasAABB = VBAABBLoadIndentity();
    b2Fixture* fixture = body->GetFixtureList();
    while (fixture) {
        tomasAABB = VBAABBMerge(tomasAABB, VBAABBCreate(fixture->GetAABB(0).lowerBound.x, fixture->GetAABB(0).lowerBound.y,
                                                        fixture->GetAABB(0).upperBound.x, fixture->GetAABB(0).upperBound.y));
        fixture = fixture->GetNext();
    }
}

- (void)updateContact {
    contactLen = 0;
    b2ContactEdge* edge = body->GetContactList();
    //_body와 충돌되어있는 리스트 불러오기
    while(edge) {
        b2Fixture* fixture = edge->contact->GetFixtureA();
        GameObject* obj = (GameObject*)fixture->GetBody()->GetUserData();
        
        b2WorldManifold manifold;
        edge->contact->GetWorldManifold(&manifold);
        if(edge->contact->GetManifold()->pointCount) {
            if(obj->type == BodyGround || obj->type == BodyArrowHit) {
                contactNormal[contactLen] = manifold.normal;
                contactLen++;
            }
        }
        edge = edge->next;
    }
}

- (void)updateMove {
    if((([self getEquiptment] == EquiptmentRope && ropeActionType == RopeHangOn) || is_fall) || ([self getEquiptment] == EquiptmentBalloon && balloon)) {
        isDash = NO;
        return;
    }
    isMove = isMoveLeft || isMoveRight;
    BOOL isContactLeft = NO;
    BOOL isContactRight = NO;
    BOOL isContactBottom = NO;
    if(isMoveLeft || isMoveRight) {
        b2Vec2 bottom;
        for(int i = 0; i < contactLen; i++) {
            float _normalAngle = VBVector2DAngle(VBVector2DCreate(contactNormal[i].x, contactNormal[i].y));
            if(_normalAngle > -M_PI_4 && _normalAngle < M_PI_4) {
                //충돌될때 달리고 있었다면 달리기 정지
                isContactLeft = YES;
            }
            if(_normalAngle < -M_PI + M_PI_4 || _normalAngle > M_PI - M_PI_4) {
                //충돌될때 달리고 있었다면 달리기 정지
                isContactRight = YES;
            }
            if(_normalAngle >= -M_PI + M_PI_4 && _normalAngle <= -M_PI_4) {
                isContactBottom = YES;
                bottom = contactNormal[i];
            }
        }
        if(isMoveLeft) {
            if(isContactLeft) {
            } else {
                //충돌하지 않는다면 이동
                body->SetLinearVelocity(b2Vec2(-(isDash ? 10 : (isSeet ? 2.5 : 5)), body->GetLinearVelocity().y));
            }
        } else if(isMoveRight) {
            if(isContactRight) {
            } else {
                //충돌하지 않는다면 이동
                body->SetLinearVelocity(b2Vec2((isDash ? 10 : (isSeet ? 2.5 : 5)), body->GetLinearVelocity().y));
            }
        }
    } else {
        //양쪽모두 컨트롤 안할시 정지
        body->SetLinearVelocity(b2Vec2(0.0f, isJump?body->GetLinearVelocity().y:0));
    }
}

- (void)updateJump {
    BOOL isContact = NO;
    for(int i = 0; i < contactLen; i++) {
        float _normalAngle = VBVector2DAngle(VBVector2DCreate(contactNormal[i].x, contactNormal[i].y));
        //바닥이나 화살과의 충돌여부
        if(_normalAngle >= -M_PI + M_PI_4 && _normalAngle <= -M_PI_4) {
            isContact = YES;
        }
    }
    isJump = !isContact;
    if(isJump == NO && is_fall)
        is_fall = NO;
    if(([self getEquiptment] == EquiptmentRope && ropeActionType == RopeHangOn) || ([self getEquiptment] == EquiptmentBalloon && balloon)) {
        isWannaJump = NO;
        return;
    }
    //점프컨트롤시 바닥과 충돌이 되어있다면
    if(isWannaJump) {
        if(isContact) {
            //충돌시 점프
            body->SetTransform(b2Vec2(body->GetTransform().p.x,body->GetTransform().p.y-0.1), 0);
            body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, -12.0));
            isJump = YES;
        }
        //점프컨트롤 끄기
        isWannaJump = NO;
    }
}

- (void)updateSlide:(CFTimeInterval)_delta {
    if(([self getEquiptment] == EquiptmentRope && ropeActionType == RopeHangOn) || ([self getEquiptment] == EquiptmentBalloon && balloon)) {
        if(isSlide) {
            isSlide = NO;
            isChangeShape = YES;
        }
        isWannaSlide = NO;
        return;
    }
    BOOL isSlidePrev = isSlide;
    if(isJump == NO && isDash == YES) {
        if(isWannaSlide) {
            isSlide = YES;
            slideTime = 0.5f;
        }
    } else {
        //점프하면 슬라이딩 정지
        isSlide = NO;
    }
    
    if(isSlide) {
        if(isDash) {
            slideTime -= (float)_delta;
            if(slideTime <= 0.0) {
                isSlide = NO;
                isDash = NO;
            }
        }
    }
    
    if(isSlidePrev != isSlide)
        isChangeShape = YES;
    
    isWannaSlide = NO;
}

- (void)updateSeet {
    if(([self getEquiptment] == EquiptmentRope && ropeActionType == RopeHangOn) || ([self getEquiptment] == EquiptmentBalloon && balloon)) {
        if(isSeet) {
            isSeet = NO;
            isChangeShape = YES;
        }
        isWannaSeet = NO;
        return;
    }
    BOOL isSeetPrev = isSeet;
    if(isWannaSeet) {
        if(isJump) {
            isSeet = NO;
        } else {
            if(isDash) {
                isSeet = NO;
            } else {
                isSeet = YES;
            }
        }
    } else {
        isSeet = NO;
    }
    if(isSeetPrev != isSeet)
        isChangeShape = YES;
}

- (void)updateFriction {
    //마찰계수 설정
    float friction = isJump ? 0.0f : 1.0;
    body->GetFixtureList()->SetFriction(friction);
}

- (void)updateShape {
    if(isChangeShape) {
        b2PolygonShape* bodyShape = (b2PolygonShape*)body->GetFixtureList()->GetShape();
        b2Vec2 vec[4];
        if(isSlide || isSeet) {
            vec[0] = b2Vec2(-8/20.0, -2/20.0);
            vec[1] = b2Vec2(8/20.0, -2/20.0);
            vec[2] = b2Vec2(8/20.0, 8/20.0);
            vec[3] = b2Vec2(-8/20.0, 8/20.0);
        } else {
            vec[0] = b2Vec2(-5/20.0, -8/20.0);
            vec[1] = b2Vec2(5/20.0, -8/20.0);
            vec[2] = b2Vec2(5/20.0, 8/20.0);
            vec[3] = b2Vec2(-5/20.0, 8/20.0);
        }
        bodyShape->Set(vec, 4);
    }
}

- (void)updateBow:(CFTimeInterval)_delta {
    if(bowActionType == BowShot) {
        bowCount += (float)_delta;
        if(bowCount > bowCoolTime) {
            bowActionType = BowOff;
        }
    }
    for(int i = 0; i < [arrowArray count]; i++) {
        Arrow* _arrow = [arrowArray objectAtIndex:i];
        _arrow->life -= (float)_delta;
        if(_arrow->life < 0.0f) {
            [_arrow release];
            [arrowArray removeObjectAtIndex:i];
            i--;
        } else {
            if(_arrow->isHit) {
                _arrow->body->SetTransform(_arrow->hitPos, _arrow->hitAngle);
                _arrow->body->GetFixtureList()->SetFriction(5.0);
                _arrow->body->GetFixtureList()->SetRestitution(0.0);
                _arrow->body->SetType(b2_staticBody);
                _arrow->life = 10.0;
                _arrow->isHit = NO;
            }
        }
    }
}

- (void)updateRope {
    if(isJump == NO) {
        [self ropeOff];
    } if(ropeActionType == RopeHangOff) {
        if(ropeJoint) {
            world->DestroyJoint(ropeJoint);
            ropeJoint = NULL;
        }
        if([ropeArray count]) {
            GameObject* rope = [ropeArray lastObject];
            while(rope->body->GetJointList()) {
                b2Joint* _ropejoint = (b2RevoluteJoint*)VBArrayVectorRemoveBack(ropeJointArray);
                if(_ropejoint)
                    world->DestroyJoint(_ropejoint);
            }
            [rope release];
            [ropeArray removeLastObject];
        }
    }
}

- (void)updateBalloon {
    if(balloonActionType == BalloonOff) {
        balloonTargetX = balloonX = 0.0f;
        if(balloonJoint) {
            world->DestroyJoint(balloonJoint);
            balloonJoint = NULL;
        }
        if(balloon) {
            [balloon release];
            balloon = nil;
        }
    } else {
        balloonX += (balloonTargetX - balloonX) * 0.25;
        if(balloon) {
            balloon->body->SetLinearVelocity(b2Vec2(balloonX, -2.5));
        }
    }
}

- (void)update:(CFTimeInterval)_delta {
    _elapse += _delta;
    
    [self updateTomasAABB];
    
    //[self updateContact];
    
    [self updateMove];
    [self updateJump];
    [self updateSlide:_delta];
    [self updateSeet];
    
    [self updateRope];
    [self updateBow:_delta];
    [self updateBalloon];
    
    [self updateShape];
    [self updateFriction];
}

- (void)move:(BOOL)_isLeft {
    is_fall = NO;
    if(_isLeft) {
        if(isMoveLeft == NO) {
            isMoveLeft = YES;
            if(isMoveRight)
                isMoveChange = YES;
            else
                isMoveChange = NO;
            isMoveRight = NO;
        }
    } else {
        if(isMoveRight == NO) {
            isMoveRight = YES;
            if(isMoveLeft)
                isMoveChange = YES;
            else
                isMoveChange = NO;
            isMoveLeft = NO;
        }
    }
    if(isMoveChange) {
        isDash = NO;
    }
}

- (void)stopMove {
    isMoveChange = NO;
    isMoveLeft = NO;
    isMoveRight = NO;
    isDash = NO;
}

- (void)dash:(BOOL)_isDash {
    if(_isDash) {
        if(isJump == NO && isSeet == NO && isSlide == NO)
            isDash = YES;
    } else {
        isDash = NO;
    }
}

- (void)jump {
    isWannaJump = YES;
}

- (void)slide:(BOOL)_isSlide {
    if(_isSlide) {
        if(isSlide == NO) {
            isWannaSlide = YES;
        }
    } else {
        if(isSlide && isDash)
            isDash = NO;
        isSlide = NO;
    }
}

- (void)seet:(BOOL)_isSeet {
    isWannaSeet = _isSeet;
}

- (void)setUI:(id)_ui_id {
    ui_id = _ui_id;
}

- (void)setNextEquiptment {
    int count = 0;
    Equiptment _equipt = equiptment;
    while(count < EquiptmentMax) {
        if(_equipt == EquiptmentBalloon) {
            _equipt = EquiptmentEmpty;
        } else {
            _equipt += 1;
        }
        if([self setEquiptment:_equipt]) {
            break;
        }
        count++;
    }
}

- (BOOL)setEquiptment:(Equiptment)_equiptment {
    if(equiptment != _equiptment) {
        if(equiptment == EquiptmentRope)
            [self ropeOff];
        if(equiptment == EquiptmentBow)
            [self bowOff];
        if(equiptment == EquiptmentBalloon) {
            if(balloon)
                [self ballon];
        }
        if(_equiptment == EquiptmentRope) {
            if(isHaveRope) {
                equiptment = _equiptment;
                UILayer* uiLayer = ui_id;
                if([uiLayer getUILayerStyle] == UILayerStyleJoyPad)
                    [uiLayer setEquiptment:equiptment];
                return YES;
            }
        } else if(_equiptment == EquiptmentBow) {
            if(isHaveBow) {
                equiptment = _equiptment;
                UILayer* uiLayer = ui_id;
                if([uiLayer getUILayerStyle] == UILayerStyleJoyPad)
                    [uiLayer setEquiptment:equiptment];
                return YES;
            }
        } else if(_equiptment == EquiptmentBalloon) {
            if(isHaveBalloon) {
                equiptment = _equiptment;
                UILayer* uiLayer = ui_id;
                if([uiLayer getUILayerStyle] == UILayerStyleJoyPad)
                    [uiLayer setEquiptment:equiptment];
                return YES;
            }
        } else {
            equiptment = _equiptment;
            UILayer* uiLayer = ui_id;
            if([uiLayer getUILayerStyle] == UILayerStyleJoyPad)
                [uiLayer setEquiptment:equiptment];
            return YES;
        }
    }
    return NO;
}

- (Equiptment)getEquiptment {
    return equiptment;
}

- (void)ropeThrow:(VBVector2D)value {
    if(equiptment != EquiptmentRope || isJump == NO)
        return;
    if([ropeArray count] == 0) {
        ropeActionType = RopeHangOn;
        
        float ropeAngle = VBVector2DAngle(value);
        if(ropeAngle > 0.0f) {
            if(ropeAngle < M_PI_2)
                ropeAngle = 0.0f;
            else
                ropeAngle = -M_PI;
        }
        if(ropeAngle > -M_PI_4)
            ropeAngle = -M_PI_4;
        if(ropeAngle < -M_PI_2-M_PI_4)
            ropeAngle = -M_PI_2-M_PI_4;
        value = VBVector2DPolar(1000.0f/20.0, ropeAngle);
        
        b2Body* _body = world->GetBodyList();
        b2Body* _hitBody;
        b2Vec2 _hitVec;
        float _length = FLT_MAX;
        bool _finded = false;
        while(_body) {
            b2Fixture* _fixture = _body->GetFixtureList();
            while(_fixture) {
                bool ignore = false;
                if(_fixture->GetBody() == body)
                    ignore = true;
                if(_fixture->GetBody()->GetFixtureList()->IsSensor())
                    ignore = true;
                for(int i = 0; i < [arrowArray count]; i++) {
                    Arrow* _arrow = [arrowArray objectAtIndex:i];
                    if(_arrow->body == _fixture->GetBody()) {
                        ignore = true;
                    }
                }
                if(ignore == false) {
                    b2RayCastInput inputRay;
                    inputRay.p1 = b2Vec2(body->GetWorldCenter().x, body->GetWorldCenter().y - 8/20.0);
                    VBVector2D _value = VBVector2DCreate(value.x, value.y);
                    float valueLen = VBVector2DLength(_value);
                    inputRay.maxFraction = valueLen > RopeMaxLength ? RopeMaxLength : valueLen;
                    _value = VBVector2DNormal(_value, 1.0);
                    inputRay.p2 = inputRay.p1 + b2Vec2(_value.x, _value.y);
                    b2RayCastOutput outputRay;
                    for(int i = 0; i < _fixture->GetShape()->GetChildCount(); i++) {
                        if(_fixture->RayCast(&outputRay, inputRay, i)) {
                            b2Vec2 hitVec = inputRay.p1 + outputRay.fraction * (inputRay.p2 - inputRay.p1);
                            float length = b2Distance(hitVec, b2Vec2(body->GetWorldCenter().x, 
                                                                     body->GetWorldCenter().y - 8/20.0));
                            if(_length > length) {
                                _hitBody = _body;
                                _hitVec = hitVec;
                                _length = length;
                                _finded = true;
                            }
                        }
                    }
                }
                _fixture = _fixture->GetNext();
            }
            _body = _body->GetNext();
        }
        if(_finded == false) {
            if(VBVector2DLength(value) > RopeMaxLength) {
                float angle = VBVector2DAngle(value);
                VBVector2D polar = VBVector2DPolar(RopeMaxLength, angle);
                _hitVec = b2Vec2(body->GetWorldCenter().x, 
                                 body->GetWorldCenter().y) + b2Vec2(polar.x, polar.y);
                _length = RopeMaxLength;
            } else { 
                _hitVec = b2Vec2(body->GetWorldCenter().x, 
                                 body->GetWorldCenter().y) + b2Vec2(value.x, value.y);
                _length = VBVector2DLength(value);
            }
        }
        VBLine2D _line = VBLine2DCreate(body->GetWorldCenter().x, 
                                        body->GetWorldCenter().y - 8/20.0, 
                                        _hitVec.x, _hitVec.y);
        VBFloat _angle = VBVector2DAngleTo(VBVector2DCreate(body->GetWorldCenter().x, 
                                                            body->GetWorldCenter().y - 8/20.0), 
                                           VBVector2DCreate(_hitVec.x, _hitVec.y));
        b2Body* _link = body;
        VBVector2D _prePos = VBLine2DGetVector2D(_line, 0.0);
        VBVector2D _curPos;
        VBVector2D _nextPos;
        b2RevoluteJointDef _jointDef = b2RevoluteJointDef();
        
        int ropeCount = (int)floorf(_length / (5.0f/20.0f));
        if(ropeCount == 0)
            ropeCount = 1;
        if(ropeCount > 10)
            ropeCount = 10;
        
//        b2RopeJointDef _ropeJointDef = b2RopeJointDef();
//        
//        _ropeJointDef.localAnchorA.Set(0.0f, 0.0f);
        
        for (int i = 0; i < ropeCount; i++) {
            _curPos = VBLine2DGetVector2D(_line, (i + 0.5) / (float)ropeCount);
            _nextPos = VBLine2DGetVector2D(_line, (i + 1) / (float)ropeCount);
            b2Body* _ropeBody;
            b2BodyDef _bodyDef;
            _bodyDef.type = b2_dynamicBody;
            _bodyDef.position.Set(_curPos.x,_curPos.y);
            _bodyDef.angle = _angle;
            
            b2PolygonShape _shape;
            _shape.SetAsBox(_length / (float)ropeCount / 2.0 + 1.0/20.0, 0.1/20.0);
            
            
            
            b2Vec2 vec[4];
            vec[0] = b2Vec2(-(_length / (float)ropeCount / 2.0 + 1.0/20.0), -0.1/20.0);
            vec[1] = b2Vec2((_length / (float)ropeCount / 2.0 + 1.0/20.0), -0.1/20.0);
            vec[2] = b2Vec2((_length / (float)ropeCount / 2.0 + 1.0/20.0), 0.1/20.0);
            vec[3] = b2Vec2(-(_length / (float)ropeCount / 2.0 + 1.0/20.0), 0.1/20.0);
            
            b2PolygonShape* polygonShape = new b2PolygonShape;
            polygonShape->Set(vec, 4);
            
            b2FixtureDef _fixtureDef;
            _fixtureDef.shape = &_shape;
            _fixtureDef.density = 20.0;
            _fixtureDef.restitution = 0;
            _fixtureDef.isSensor = false;
            _fixtureDef.friction = 0;
            
            GameObject* obj = [[GameObject alloc] initWithBodyDef:_bodyDef fixtureDef:_fixtureDef shape:polygonShape];
            [obj create:world];
            obj->type = BodyRope;
            [ropeArray addObject:obj];
            
            _ropeBody = obj->body;
            
            _jointDef.Initialize(_link, _ropeBody, b2Vec2(_prePos.x, _prePos.y));
            b2RevoluteJoint* _ropeJoint = (b2RevoluteJoint*)world->CreateJoint(&_jointDef);
            VBArrayVectorAddBack(ropeJointArray, _ropeJoint);
            
            _link = _ropeBody;
            _prePos = VBLine2DGetVector2D(_line, (i + 1) / (float)ropeCount);
        }
        
        
        if(_finded) {
            _jointDef.Initialize(_link, _hitBody, _hitVec);
            b2RevoluteJoint* _ropeJoint = (b2RevoluteJoint*)world->CreateJoint(&_jointDef);
            VBArrayVectorAddBack(ropeJointArray, _ropeJoint);
            
//            _ropeJointDef.localAnchorB = _hitVec;
//            
//            float32 extraLength = 0.01/20.0;
//            _ropeJointDef.maxLength = b2Distance(_hitVec, body->GetWorldCenter()) + extraLength;
//            _ropeJointDef.bodyB = _hitBody;
//            _ropeJointDef.bodyA = body;
//            _ropeJointDef.collideConnected = true;
            //ropeJoint = (b2RopeJoint*)world->CreateJoint(&_ropeJointDef);
        } else {
            [self ropeOff];
        }
    } else {
        [self ropeOff];
        GameObject* lastRope = [ropeArray lastObject];
        b2Vec2 vec = body->GetWorldCenter() - lastRope->body->GetWorldCenter();
        body->SetLinearVelocity(b2Vec2(vec.x < 0 ? -6.0 : 6.0, -6.0));
        is_fall = YES;
    }
    if(isJump == NO)
        [self ropeOff];
}

- (void)ropeOff {
    ropeActionType = RopeHangOff;
}

- (void)ballon {
    if(isHaveBalloon == NO)
        return;
    if(balloon == NULL) {
        isJump = YES;
        balloonActionType = BalloonOn;
        b2BodyDef _bodyDef;
        _bodyDef.type = b2_dynamicBody;
        _bodyDef.position.Set(body->GetWorldCenter().x, body->GetWorldCenter().y - 30/20.0);
        _bodyDef.angle = 0;
        _bodyDef.fixedRotation = true;
        
        b2CircleShape* _shape = new b2CircleShape;
        _shape->m_p.Set(0, 0);
        _shape->m_radius = 20/20.0;
        
        b2FixtureDef _fixtureDef;
        _fixtureDef.shape = _shape;
        _fixtureDef.density = 1.0;
        _fixtureDef.restitution = 0;
        _fixtureDef.isSensor = false;
        _fixtureDef.friction = 0;
        
        balloon = [[GameObject alloc] initWithBodyDef:_bodyDef fixtureDef:_fixtureDef shape:_shape];
        [balloon create:world];
        balloon->type = BodyBalloon;
        
        
        b2RevoluteJointDef jointDef;
        jointDef.Initialize(body, balloon->body, balloon->body->GetWorldCenter());
        jointDef.lowerAngle = 0;
        jointDef.upperAngle = 0;
        jointDef.enableLimit = true;
        jointDef.maxMotorTorque = 0.0f;
        jointDef.motorSpeed = 0.0f;
        jointDef.enableMotor = false;
        
        balloonJoint = (b2RevoluteJoint*)world->CreateJoint(&jointDef);
    } else {
        balloonActionType = BalloonOff;
        isHaveBalloon = NO;
        [self setNextEquiptment];
    }
}

- (BOOL)bowAvailable:(VBVector2D)_vec {
    b2Body* _body = world->GetBodyList();
    b2Vec2 _hitVec;
    float _length = FLT_MAX;
    bool _finded = false;
    while(_body) {
        b2Fixture* _fixture = _body->GetFixtureList();
        while(_fixture) {
            bool ignore = false;
            if(_fixture->GetBody() == body)
                ignore = true;
            if(_fixture->GetBody()->GetFixtureList()->IsSensor())
                ignore = true;
            for(int i = 0; i < [arrowArray count]; i++) {
                Arrow* _arrow = [arrowArray objectAtIndex:i];
                if(_arrow->body == _fixture->GetBody()) {
                    ignore = true;
                }
            }
            if(ignore == false) {
                b2RayCastInput inputRay;
                inputRay.p1 = body->GetWorldCenter();
                VBVector2D _value = VBVector2DSubtract(_vec, bowBeginVec);
                _value = VBVector2DNormal(_value, 5.0);
                inputRay.maxFraction = VBVector2DLength(_value);
                inputRay.p2 = inputRay.p1 + b2Vec2(-_value.x, -_value.y);
                b2RayCastOutput outputRay;
                //이밑라인에서 에러발생 처리 필요
                int shapeLen = _fixture->GetShape()->GetChildCount();
                for(int i = 0; i < shapeLen; i++) {
                    if(_fixture->GetShape()->RayCast(&outputRay, inputRay, _body->GetTransform(), i)) {
                        b2Vec2 hitVec = inputRay.p1 + outputRay.fraction * (inputRay.p2 - inputRay.p1);
                        float length = b2Distance(hitVec, body->GetWorldCenter());
                        if(_length > length) {
                            _hitVec = hitVec;
                            _length = length;
                            _finded = true;
                        }
                    }
                    
                }
            }
            _fixture = _fixture->GetNext();
        }
        _body = _body->GetNext();
    }
    
    //활시휘 당기려면 1.5만큼의 공간이 필요
    if(_length < 1.5f)
        return NO;
    
    //적어도 1이상은 당겨야 함
    if(VBVector2DDistance(_vec, bowBeginVec) < 1.0f)
        return NO;
    
    return YES;
}

- (void)bowBegin:(VBVector2D)_vec {
    bowBeginVec = _vec;
    if(bowActionType == BowOff) {
        bowActionType = BowReady;
    }
}

- (void)bowMove:(VBVector2D)_vec {
    if(bowActionType == BowReady) {
        VBVector2D dir = VBVector2DSubtract(_vec, bowBeginVec);
        float angle = VBVector2DAngle(dir);
        VBVector2D dirNormal = VBVector2DNormal(dir, 1.0);
        
        if(arrowGuide == nil) {
            b2BodyDef _arrowBodyDef;
            _arrowBodyDef.type = b2_dynamicBody;
            _arrowBodyDef.position.Set(body->GetWorldCenter().x - dirNormal.x, body->GetWorldCenter().y - dirNormal.y);
            _arrowBodyDef.angle = angle;
            
            
            b2Vec2 vec[4];
            vec[0] = b2Vec2(-0.5, -0.01);
            vec[1] = b2Vec2(0.5, -0.01);
            vec[2] = b2Vec2(0.5, 0.01);
            vec[3] = b2Vec2(-0.5, 0.01);
            
            b2PolygonShape* polygonShape = new b2PolygonShape;
            polygonShape->Set(vec, 4);
            
            b2FixtureDef _arrowFixture;
            _arrowFixture.shape = polygonShape;
            _arrowFixture.density = 1.0;
            _arrowFixture.restitution = 0.0;
            _arrowFixture.isSensor = true;
            _arrowFixture.friction = 1.0;
            
            arrowGuide = [[GameObject alloc] initWithBodyDef:_arrowBodyDef fixtureDef:_arrowFixture shape:polygonShape];
            [arrowGuide create:world];
            arrowGuide->body->SetActive(false);
        }
        if([self bowAvailable:_vec]) {
            arrowGuide->type = BodyArrowGuideOn;
        } else {
            arrowGuide->type = BodyArrowGuideOff;
        }
        arrowGuide->body->SetTransform(b2Vec2(body->GetWorldCenter().x - dirNormal.x, body->GetWorldCenter().y - dirNormal.y), angle);
    }
}

- (void)bowEnd:(VBVector2D)_vec {
    if(bowActionType == BowReady) {
        if(arrowGuide) {
            [arrowGuide release];
            arrowGuide = nil;
        }
        if([self bowAvailable:_vec]) {
            VBVector2D dir = VBVector2DSubtract(_vec, bowBeginVec);
            float length = VBVector2DLength(dir);
            float angle = VBVector2DAngle(dir);
            VBVector2D dirNormal = VBVector2DNormal(dir, 1.0);
            
            b2BodyDef _arrowBodyDef;
            _arrowBodyDef.type = b2_dynamicBody;
            _arrowBodyDef.position.Set(body->GetWorldCenter().x - dirNormal.x, body->GetWorldCenter().y - dirNormal.y);
            _arrowBodyDef.angle = angle;
            
            b2Vec2 vec[4];
            vec[0] = b2Vec2(-0.5, -0.01);
            vec[1] = b2Vec2(0.5, -0.01);
            vec[2] = b2Vec2(0.5, 0.01);
            vec[3] = b2Vec2(-0.5, 0.01);
            
            b2PolygonShape* polygonShape = new b2PolygonShape;
            polygonShape->Set(vec, 4);
            
            b2FixtureDef _arrowFixture;
            _arrowFixture.shape = polygonShape;
            _arrowFixture.density = 1.0;
            _arrowFixture.restitution = 0.0;
            _arrowFixture.isSensor = false;
            _arrowFixture.friction = 1.0;
            
            Arrow* arrow = [[Arrow alloc] initWithBodyDef:_arrowBodyDef fixtureDef:_arrowFixture shape:polygonShape];
            [arrow create:world];
            arrow->type = BodyArrow;
            
            dirNormal = VBVector2DNormal(dir, length / 100.0);//활시위 파워
            arrow->body->ApplyLinearImpulse(b2Vec2(-dirNormal.x, -dirNormal.y), arrow->body->GetWorldCenter());
            
            arrow->life = 3.0;
            
            [arrowArray addObject:arrow];
            
            bowCount = 0.0;
            bowActionType = BowShot;
        } else {
            bowActionType = BowOff;
        }
        
    }
}
- (void)bowOff {
    bowActionType = BowOff;
    if(arrowGuide) {
        [arrowGuide release];
        arrowGuide = nil;
    }
}

- (void)_save:(NSMutableDictionary*)dict {
    [dict setObject:[NSNumber numberWithFloat:body->GetTransform().p.x] forKey:@"x"];
    [dict setObject:[NSNumber numberWithFloat:body->GetTransform().p.y] forKey:@"y"];
    [dict setObject:[NSNumber numberWithBool:isHaveRope] forKey:@"isHaveRope"];
    [dict setObject:[NSNumber numberWithBool:isHaveBow] forKey:@"isHaveBow"];
    [dict setObject:[NSNumber numberWithBool:isHaveBalloon] forKey:@"isHaveBalloon"];
    [dict setObject:[NSNumber numberWithInt:equiptment] forKey:@"equiptment"];
}

- (void)_load:(NSMutableDictionary*)dict {
    [self freeAnother];
    [self initAnother];
    float x = [[dict objectForKey:@"x"] floatValue];
    float y = [[dict objectForKey:@"y"] floatValue];
    isHaveRope = [[dict objectForKey:@"isHaveRope"] boolValue];
    isHaveBow = [[dict objectForKey:@"isHaveBow"] boolValue];
    isHaveBalloon = [[dict objectForKey:@"isHaveBalloon"] boolValue];
    equiptment = [[dict objectForKey:@"equiptment"] intValue];
    
    UILayer* uiLayer = ui_id;
    if([uiLayer getUILayerStyle] == UILayerStyleJoyPad)
        [uiLayer setEquiptment:equiptment];
    
    body->SetTransform(b2Vec2(x, y), 0);
    body->SetLinearVelocity(b2Vec2_zero);
}

- (void)saveFirst {
    [self _save:saveDataFirst];
}

- (void)save {
    [self _save:saveData];
}

- (void)loadFirst {
    [self _load:saveDataFirst];
}

- (void)load {
    [self _load:saveData];
}

@end
