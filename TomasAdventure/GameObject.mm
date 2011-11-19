#import "GameObject.h"

@implementation GameObject

- (id)initWithWorld:(b2World*)_world 
            bodyDef:(b2BodyDef)_body_def 
         fixtureDef:(b2FixtureDef)_fixture_Def {
    self = [super init];
    if(self) {
        world = _world;
        body = _world->CreateBody(&_body_def);
        body->CreateFixture(&_fixture_Def);
        body->SetUserData(self);
    }
    return self;
}

- (void)dealloc {
    world->DestroyBody(body);
    [super dealloc];
}

- (void)update:(CFTimeInterval)_delta {
    _elapse += _delta;
}

@end
