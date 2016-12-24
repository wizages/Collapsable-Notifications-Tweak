#import "NotificationObject.h"
@implementation NotificationObject

-(NotificationObject *) initWithName:(NSString *)arg1 bulletin:(id)arg2{
	[self init];
	self.name = arg1;
	self.bulletins = [NSMutableArray arrayWithObject:arg2];
	return self;
}

-(void)addBulletin:(id)arg1
{
	[self.bulletins insertObject:arg1 atIndex:0];
}

-(void)removeBulletin:(int)location
{
	[self.bulletins removeObjectAtIndex:location];
}

-(void)updateID:(int)j bulletin:(id)arg2
{
	[self.bulletins replaceObjectAtIndex:j withObject:arg2];
}

@end