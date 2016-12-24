#import "Notification.h"
#import "NotificationObject.h"

static SBLockScreenNotificationListView *notifWidget;
static UITableView *notificationsTableView;
static int sectionNumber;
static bool firstNotify;
%hook SBLockScreenNotificationListController
-(void)_updateModelAndViewForAdditionOfItem:(SBAwayBulletinListItem *)item
{
    NSMutableArray *bulletins = [notifWidget.notifications mutableCopy];
    BOOL finished = false;
    for(int i =0; i<[bulletins count]; i++)
    {
        NotificationObject *temp = bulletins[i];
        if([temp.name isEqualToString:item.activeBulletin.sectionID])
        {
            [temp addBulletin:item.activeBulletin];
            [bulletins removeObjectAtIndex:i];
            [bulletins insertObject:temp atIndex:0];
            finished = true;
            break;
        }
    }
    
    if(!finished){
        NotificationObject *notification = [[NotificationObject alloc] initWithName:item.activeBulletin.sectionID bulletin:item.activeBulletin];
        [bulletins insertObject:notification atIndex:0];
    }
    //[bulletins addObject:]
    notifWidget.notifications = [bulletins copy];
    sectionNumber = 1;
    [UIView transitionWithView:notificationsTableView
                  duration:0.35f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^(void){[notificationsTableView reloadData];}
                completion:nil];
}

-(void)_updateModelAndViewForRemovalOfItem:(SBAwayBulletinListItem *)item
{
    NSMutableArray *bulletins = [notifWidget.notifications mutableCopy];

    for(int i =0; i<[bulletins count]; i++)
    {
        NotificationObject *temp = bulletins[i];
        if([item isKindOfClass:%c(SBAwayBulletinListItem)] && [temp.name isEqualToString:item.activeBulletin.sectionID])
        {
            for(int j=0; j<[temp.bulletins count]; j++)
            {
                BBBulletin *test = temp.bulletins[j];
                if([test.bulletinID isEqualToString:item.activeBulletin.bulletinID])
                {
                    [(NotificationObject *)bulletins[i] removeBulletin:j];
                    if([temp.bulletins count] == 0)
                    {
                        [bulletins removeObjectAtIndex:i];
                        if([bulletins count] == 0)
                        {
                            firstNotify = false;
                        }
                    }
                    break;
                }
                else
                {

                }
            }
            break;
        }
    }
    notifWidget.notifications = [bulletins copy];
    sectionNumber = 1;
    [UIView transitionWithView:notificationsTableView
                  duration:0.35f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^(void){[notificationsTableView reloadData];}
                completion:nil];
}

-(void)_updateModelAndViewForModificationOfItem:(SBAwayBulletinListItem *)item
{
    NSMutableArray *bulletins = [notifWidget.notifications mutableCopy];

    for(int i =0; i<[bulletins count]; i++)
    {
        NotificationObject *temp = bulletins[i];
        if([temp.name isEqualToString:item.activeBulletin.sectionID])
        {
            for(int j=0; j<[temp.bulletins count]; j++)
            {
                BBBulletin *test = temp.bulletins[j];
                if([test.bulletinID isEqualToString:item.activeBulletin.bulletinID])
                {
                    HBLogDebug(@"End of removal")
                    [temp updateID:j bulletin:item.activeBulletin];
                    [bulletins removeObjectAtIndex:i];
                    [bulletins insertObject:temp atIndex:0];
                    break;
                    
                }
            }
            break;
        }
    }
    HBLogDebug(@"Copy over");
    notifWidget.notifications = [bulletins copy];
    [UIView transitionWithView:notificationsTableView
                  duration:0.35f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^(void){[notificationsTableView reloadData];}
                completion:nil];}

%end

%hook SBLockScreenNotificationListView

%property (nonatomic, retain) NSArray *notifications;


- (id)initWithFrame:(struct CGRect)frame{
    self = %orig;
    self.notifications = [NSMutableArray array];
    notifWidget = self;
    notificationsTableView = MSHookIvar<UITableView*>(self, "_tableView");
    return self;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if((sectionNumber-1) == section)
    {
        NotificationObject *temp = self.notifications[section];
        return [temp.bulletins count];
    }
    else
        return 0;

}

%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    HBLogDebug(@"called");
    HBLogDebug(@"Notifications: %@", self.notifications)
    return [self.notifications count];
}

%new
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
    NSString *appName = ((NotificationObject *)self.notifications[section]).name;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, notificationsTableView.frame.size.width, 35)];

    UILabel *lblSection = [UILabel new];
    [lblSection setFrame:CGRectMake(0, 0, 300, 30)];
    [lblSection setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [lblSection setBackgroundColor:[UIColor clearColor]];
    lblSection.alpha = 0.5;
    [lblSection setText:appName];

    UILabel *notificationNumber = [UILabel new];
    [notificationNumber setFrame:CGRectMake(notificationsTableView.frame.size.width-40, 0, 40, 30)];
    [notificationNumber setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [notificationNumber setBackgroundColor:[UIColor clearColor]];
    notificationNumber.alpha = 0.5;
    NotificationObject *temp = self.notifications[section];
    [notificationNumber setText:[NSString stringWithFormat:@"%d", (int)[temp.bulletins count]]];

    UIButton *btnCollapse = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCollapse setFrame:CGRectMake(0, 0, notificationsTableView.frame.size.width, 35)];
    [btnCollapse setBackgroundColor:[UIColor clearColor]];
    [btnCollapse addTarget:self action:@selector(showSection:) forControlEvents:UIControlEventTouchUpInside];
    btnCollapse.tag = section+1;

    [headerView addSubview:notificationNumber];
    [headerView addSubview:lblSection];
    [headerView addSubview:btnCollapse];

    return headerView;
}

- (double)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
        return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NotificationObject *temp = self.notifications[indexPath.section];
    BBBulletin *test = temp.bulletins[indexPath.row];
    cell.textLabel.text = test.message;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NotificationObject *temp = self.notifications[indexPath.section];
    BBBulletin *test = temp.bulletins[indexPath.row];
    BBAction *action = test.defaultAction;
    if(action == nil || !action)
        return;
    void (^action2)() = ^() {
        [test actionBlockForAction:action withOrigin:4 context:nil](nil);
    };
    SBLockScreenManager *manager = (SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance];
    if (manager.isUILocked) {
        SBLockScreenViewControllerBase *controller = [manager lockScreenViewController];
        id context;
        if ([controller respondsToSelector:@selector(setCustomUnlockActionContext:)]) {
            context = [[%c(SBUnlockActionContext) alloc] initWithLockLabel:nil shortLockLabel:nil unlockAction:action2 identifier:nil];
            [controller setCustomUnlockActionContext:context];
        } else {
            context = [[%c(SBLockScreenActionContext) alloc] initWithLockLabel:nil shortLockLabel:nil action:action2 identifier:nil];
            [controller setCustomLockScreenActionContext:context];
        }
        [context setDeactivateAwayController:YES];  
        [controller setPasscodeLockVisible:YES animated:YES completion:nil];
        //[context release];
    }
    
    //
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

%new
-(void)showSection:(id)sender{
    UIButton *btnSection = (UIButton *)sender;
    if (sectionNumber == -1)
    {
        sectionNumber = btnSection.tag;
        [notificationsTableView reloadSections:[NSIndexSet indexSetWithIndex:btnSection.tag-1] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(sectionNumber != btnSection.tag){
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:sectionNumber-1];
        [indexSet addIndex:btnSection.tag-1];
        sectionNumber = btnSection.tag;
        [notificationsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        sectionNumber = -1;
        [notificationsTableView reloadSections:[NSIndexSet indexSetWithIndex:btnSection.tag-1] withRowAnimation:UITableViewRowAnimationFade];
    }
    /*
    [UIView transitionWithView:notificationTable
                  duration:0.35f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^(void){[notificationsTableView reloadData];}
                completion:nil];
                */
}

%end

%hook UITableViewCell
%new
- (void)setContentAlpha:(double)arg1{

    //Do not do!
}
%end
