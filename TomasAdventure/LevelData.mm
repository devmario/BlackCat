#import "LevelData.h"

@implementation LevelData

- (id)initWithContentsOfFile:(NSString*)_url_str world:(b2World*)_world {
    self = [super init];
    if(self) {
        world = _world;
        bodies = [[NSMutableArray alloc] init];
        FILE* file = fopen([_url_str UTF8String], "rb");
        fread(&start, sizeof(VBVector2D), 1, file);
        start.x /= 20.0;
        start.y /= 20.0;
        int objlen;
        fread(&objlen, sizeof(int), 1, file);
        for(int i = 0; i < objlen; i++) {
            int type, pointslen;
            fread(&type, sizeof(int), 1, file);
            fread(&pointslen, sizeof(int), 1, file);
            b2Vec2* vec = (b2Vec2*)malloc(sizeof(b2Vec2) * pointslen);
            for(int j = 0; j < pointslen; j++) {
                fread(&vec[j], sizeof(b2Vec2), 1, file);
                vec[j].x /= 20.0;
                vec[j].y /= 20.0;
            }
            b2BodyDef bodyDef;
            bodyDef.type = b2_staticBody;
            bodyDef.position.Set(0.0f, 0.0f);
            bodyDef.angle = 0.0f;
            
            b2FixtureDef fixtureDef;
            b2Shape* shape;
            if(type == BodyGround) {
                b2ChainShape* chainShape = new b2ChainShape;
                chainShape->CreateLoop(vec, pointslen);
                fixtureDef.shape = chainShape;
                shape = chainShape;
            } else {
                b2PolygonShape* polygonShape = new b2PolygonShape;
                polygonShape->Set(vec, pointslen);
                fixtureDef.shape = polygonShape;
                shape = polygonShape;
            }
            
            fixtureDef.density = 1;
            fixtureDef.restitution = 0;
            switch (type) {
                case BodySave:
                    fixtureDef.isSensor = true;
                    break;
                case BodyItemRope:
                    fixtureDef.isSensor = true;
                    break;
                case BodyItemBow:
                    fixtureDef.isSensor = true;
                    break;
                case BodyItemBalloon:
                    fixtureDef.isSensor = true;
                    break;
                case BodyEnd:
                    fixtureDef.isSensor = true;
                    break;
                case BodyDie:
                    fixtureDef.isSensor = true;
                    break;
                default:
                    fixtureDef.isSensor = false;
                    break;
            }
            if(type > 3000)
                fixtureDef.isSensor = true;
            fixtureDef.friction = 1.0;
            
            GameObject* body = [[GameObject alloc] initWithWorld:world bodyDef:bodyDef fixtureDef:fixtureDef];
            body->type = type;
            [bodies addObject:body];
            
            free(vec);
            delete shape;
        }
        fclose(file);
        
        saveDataFirst = [[NSMutableDictionary alloc] init];
        saveData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    for(int i = 0; i < [bodies count]; i++) {
        GameObject* body = [bodies objectAtIndex:i];
        [body release];
    }
    [bodies release];
    
    [saveData release];
    [saveDataFirst release];
    
    [super dealloc];
}

- (void)_save:(NSMutableDictionary*)dict {
    for(int i = 0; i < [bodies count]; i++) {
        GameObject* body = [bodies objectAtIndex:i];
        [dict setObject:[NSNumber numberWithBool:body->body->IsAwake()] 
                 forKey:[NSString stringWithFormat:@"awake%i", i]];
    }
}

- (void)_load:(NSMutableDictionary*)dict {
    for(int i = 0; i < [bodies count]; i++) {
        GameObject* body = [bodies objectAtIndex:i];
        body->body->SetAwake([[dict objectForKey:[NSString stringWithFormat:@"awake%i", i]] boolValue]);
    }
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
