@interface NotificationObject : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *bulletins;

-(NotificationObject *) initWithName:(NSString *)arg1 bulletin:(id)arg2;
-(void)addBulletin:(id)arg1;
-(void)removeBulletin:(int)location;
-(void)updateID:(int)j bulletin:(id)arg2;
@end