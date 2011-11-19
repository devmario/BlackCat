#import "TomasData.h"

@implementation TomasData

- (id)init {
    self = [super init];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstalled"]) {
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)  objectAtIndex:0], @"default.plist"]];
    } else {
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"plist"]];
        [self write];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isInstalled"];
    }
    return self;
}

- (void)dealloc {
    [dict release];
    [super dealloc];
}

- (int)getCurrentStage {
    NSNumber* key = [dict objectForKey:@"currentStage"];
    return [key intValue];
}

- (void)setCurrentStage:(int)_stage {
    [dict setObject:[NSNumber numberWithInt:_stage] forKey:@"currentStage"];
    [self write];
}

- (NSString*)getCurrentStageFile {
    NSArray* arr = [dict objectForKey:@"stageFile"];
    NSString* fileName = [arr objectAtIndex:[self getCurrentStage]];
    return [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
}

- (NSArray*)getStageFiles {
    return [dict objectForKey:@"stageFile"];
}

- (void)write {
    [dict writeToFile:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)  objectAtIndex:0], @"default.plist"] atomically:YES];
}

@end
