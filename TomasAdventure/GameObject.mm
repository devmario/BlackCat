#import "GameObject.h"

@implementation GameObject

- (id)initWithBodyDef:(b2BodyDef)_body_def 
           fixtureDef:(b2FixtureDef)_fixture_Def
                shape:(b2Shape*)_shape{
    self = [super init];
    if(self) {
        bodyDef = _body_def;
        fixtureDef = _fixture_Def;
        shape = _shape;
    }
    return self;
}

- (void)create:(b2World*)_world {
    world = _world;
    body = _world->CreateBody(&bodyDef);
    body->CreateFixture(&fixtureDef);
    body->SetUserData(self);
}

- (void)dealloc {
    delete shape;
    world->DestroyBody(body);
    [super dealloc];
}

- (void)update:(CFTimeInterval)_delta {
    _elapse += _delta;
}

@end
