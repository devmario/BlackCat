#import <Foundation/Foundation.h>

@interface TomasData : NSObject {
    NSMutableDictionary* dict;
}

- (id)init;

- (int)getCurrentStage;

- (void)setCurrentStage:(int)_stage;

- (NSString*)getCurrentStageFile;

- (NSArray*)getStageFiles;

- (void)write;

@end
