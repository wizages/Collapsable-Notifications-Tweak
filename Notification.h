#import <BulletinBoard/BBBulletin.h>

@interface SBLockScreenNotificationCell : UITableViewCell
- (void)setContentAlpha:(double)arg1;
@end

@interface SBLockScreenNotificationListView : UIView <UITableViewDataSource, UITableViewDelegate>
{
	UITableView *_tableView;
	NSArray *_notifications;
}
@property (nonatomic, retain) NSArray *notifications;
-(SBLockScreenNotificationCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface SBAwayBulletinListItem : NSObject
@property(retain) BBBulletin *activeBulletin;
@property(retain) UIViewController* secondaryContentViewController;
@end

@interface SBLockScreenNotificationListController : NSObject
- (void)listSubviewsOfView:(UIView *)view;
@end

@interface SBUnlockActionContext : NSObject
- (id)initWithLockLabel:(NSString *)lockLabel shortLockLabel:(NSString *)label unlockAction:(void (^)())action identifier:(NSString *)id;
- (void)setDeactivateAwayController:(BOOL)deactivate;
@end

@interface SBLockScreenActionContext : NSObject
- (id)initWithLockLabel:(NSString *)lockLabel shortLockLabel:(NSString *)label action:(void (^)())action identifier:(NSString *)id;
- (void)setDeactivateAwayController:(BOOL)deactivate;
@end

@interface SBAlert : UIViewController
@end

@interface SBLockScreenViewControllerBase : SBAlert
-(void)disableLockScreenBundleWithName:(id)name deactivationContext:(id)context;
-(void)enableLockScreenBundleWithName:(id)name activationContext:(id)context;
- (void)setCustomUnlockActionContext:(SBUnlockActionContext *)context;
-(void)setUnlockActionContext:(id)context;
-(void)setCustomLockScreenActionContext:(id)context;
- (void)setPasscodeLockVisible:(BOOL)visibile animated:(BOOL)animated completion:(void (^)())completion;
@end

@interface SBLockScreenManager : NSObject
+ (SBLockScreenManager *)sharedInstance;
@property (nonatomic, readonly) BOOL isUILocked;
@property (nonatomic, readonly) SBLockScreenViewControllerBase *lockScreenViewController;
@end

@interface SBDeviceLockController : NSObject
+ (SBDeviceLockController *)sharedController;
- (BOOL)isPasscodeLocked;
@end

