//
//  HomeViewController.m
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "ChatViewController.h"

@interface HomeViewController () < UIActionSheetDelegate >
{
    IBOutlet UIImageView *heartImg;
    IBOutlet UIImageView *whitecircleImg;
    NSMutableArray *matchesArray;
    NSMutableArray *tempAry;
    NSMutableArray *heartedAry;
    
    NSInteger curIndex;
    __weak IBOutlet UIButton *heartBtn;
}
@end

@implementation HomeViewController

- (void)awakeFromNib{
    [self.navigationController.tabBarItem setImage:[[UIImage imageNamed:@"people"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *OKBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStylePlain target:self action:@selector(clickReport)];
    self.navigationItem.rightBarButtonItem = OKBarItem;
    
    
    self.user1imgView.layer.borderWidth = 1.f;
    self.user1imgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.user2imgView.layer.borderWidth = 1.f;
    self.user2imgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    matchesArray = [[NSMutableArray alloc] init];
    tempAry = [[NSMutableArray alloc]init];
    
    
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
//    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    swipeGesture.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:swipeGesture];
    
    UISwipeGestureRecognizer *swipeGesture1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeTop:)];
    swipeGesture1.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGesture1.numberOfTouchesRequired = 1;
    [self.user1imgView addGestureRecognizer:swipeGesture1];
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeBottom:)];
    swipeGesture2.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGesture2.numberOfTouchesRequired = 1;
    [self.user2imgView addGestureRecognizer:swipeGesture2];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickReport{
    NSString * manStr = [NSString stringWithFormat:@"Report %@", matchesArray[curIndex][@"male"][@"name"]];
    NSString * womanStr = [NSString stringWithFormat:@"Report %@", matchesArray[curIndex][@"female"][@"name"]];
    UIActionSheet *modeMenu = [[UIActionSheet alloc]
                               initWithTitle: nil
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                               otherButtonTitles:manStr,
                               womanStr,nil];
    [modeMenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Report man
        [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                                          selector: @selector(send_report) userInfo: nil repeats: NO];
    } else if(buttonIndex ==1){
        // Report woman
        [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                                          selector: @selector(send_report) userInfo: nil repeats: NO];
    }else{
        //
    }
    
    [actionSheet isHidden];
}

-(void)send_report{
    [ProgressHUD showSuccess:@"Report sent!" Interaction:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    heartedAry = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"heartedArray"] mutableCopy];
    
    if (!heartedAry) {
        heartedAry = [[NSMutableArray alloc]init];
    }
    NSLog(@"hearted = %@", heartedAry);
    
    [self loadMatchInfo];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setObject:heartedAry forKey:@"heartedArray"];
    NSLog(@"save hearted array successed");
}
-(void)loadMatchInfo{
    [ProgressHUD show:@"Loading..." Interaction:YES];
    [matchesArray removeAllObjects];
    curIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Matches"];
    if ([[[PFUser currentUser] objectForKey:@"sex"] isEqualToString:@"Male"]) {
        [query whereKey:@"male" notEqualTo:[PFUser currentUser]];
    } else{
        [query whereKey:@"female" notEqualTo:[PFUser currentUser]];
    }
    
    [query includeKey:@"male"];
    [query includeKey:@"female"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects) {
                matchesArray = [NSMutableArray arrayWithArray:objects];
                
                matchesArray = [self removeHeartedMatches:matchesArray];
                
                [ProgressHUD dismiss];
                int totalNum = (int)[matchesArray count];
                curIndex = arc4random() % totalNum;
                NSLog(@"curIndex = %ld", (long)curIndex);
                [self loadMatchDetail:[matchesArray objectAtIndex:curIndex]];
            } else{
                [ProgressHUD showError:@"No Matches"];
            }
        } else{
            [ProgressHUD showError:@"Error" Interaction:NO];
            NSLog(@"===Match Make===%@", error);
        }
    }];
}

-(NSMutableArray *) removeHeartedMatches:(NSMutableArray *)array{
    for (int i = 0; i < [array count]; i++) {
        PFObject * object = [array objectAtIndex:i];
        NSString * objID = object.objectId;
        int index = 0;
        for (NSString *string in heartedAry) {
            if ([string isEqualToString:objID]) {
                [array removeObject:object];
                [self removeHeartedMatches:array];
                break;
            }else{
                
            }
            index ++;
        }
    }
    
    return array;

}
- (void)didSwipe:(id)sender{
    NSLog(@"did swipe");
    if (curIndex < matchesArray.count - 1 && matchesArray.count > 0) {
        curIndex ++;
        [self loadMatchDetail:matchesArray[curIndex]];
    }
}

- (void)didSwipeTop:(id)sender{
    NSLog(@"did swipe Top");
    int swipeCount = [[[PFUser currentUser] objectForKey:@"swipes"]intValue];
    if (swipeCount <= 0) {
        [ProgressHUD showError:@"You need more swipes"];
        return;
    }
    
    if ([matchesArray count] == 0) {
        return;
    }
    
    NSString *currentname = matchesArray[curIndex][@"female"][@"name"];
    
    PFUser *male = matchesArray[curIndex][@"male"];
    [self saveSwipeCredit:male];
    
    [matchesArray removeObjectAtIndex:curIndex];
    
    if ([matchesArray count] > 0) {
        for (int i = 0;;i++) {
            if (i == [matchesArray count] - 1) {
                curIndex = 0;
                break;
            }
            if ([matchesArray[i][@"female"][@"name"] isEqualToString:currentname]) {
                curIndex = i;
                break;
            }
        }
        [self loadMatchDetail:matchesArray[curIndex]];
    }
    
}

- (void)didSwipeBottom:(id)sender{
    NSLog(@"did swipe bottom");
    
    int swipeCount = [[[PFUser currentUser] objectForKey:@"swipes"]intValue];
    if (swipeCount <= 0) {
        [ProgressHUD showError:@"You need more swipes"];
        return;
    }
    
    if ([matchesArray count] == 0) {
        return;
    }
    
    NSString *currentname = matchesArray[curIndex][@"male"][@"name"];
    
    PFUser *female = matchesArray[curIndex][@"female"];
    [self saveSwipeCredit:female];
    
    [matchesArray removeObjectAtIndex:curIndex];
    
    if ([matchesArray count] > 0) {
        for (int i = 0;;i++) {
            if (i == [matchesArray count] - 1) {
                curIndex = 0;
                break;
            }
            if ([matchesArray[i][@"male"][@"name"] isEqualToString:currentname]) {
                curIndex = i;
                break;
            }
        }
        [self loadMatchDetail:matchesArray[curIndex]];
    }
    
}

- (void) saveSwipeCredit: (PFUser *)user{
    //current user
    PFUser *me = [PFUser currentUser];
    int meswipeCount = [[me objectForKey:@"swipes"]intValue];
    int meswipedCount = [[me objectForKey:@"swiped"]intValue];
    meswipeCount += 1;
    meswipedCount += 1;
    me[@"swipes"] = [NSNumber numberWithInteger:meswipeCount];
    me[@"swiped"] = [NSNumber numberWithInteger:meswipedCount];
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"success save currentUser swipe credit");
    }];

    //swiped user
    NSString *swipedObjectID = user.objectId;
    
    [PFCloud callFunctionInBackground:@"editUser" withParameters:@{@"userId": swipedObjectID} block:^(id object, NSError *error) {
        if (!error) {
            NSLog(@"other user saved");
        }
    }];
//    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
//    [query whereKey:@"objectId" equalTo:swipedObjectID];
//    PFObject *swipedUser = [[query findObjects] firstObject];
//    NSLog(@"swipeUser = %@", swipedUser);
//    swipedUser[@"beSwiped"] = [NSNumber numberWithInteger:swipedCount];
//    swipedUser[@"swipes"] = [NSNumber numberWithInteger:swipeCount];
//    [swipedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"success save User swiped number");
//    }];

}

- (void)loadMatchDetail:(PFObject*)matchObj{
    NSLog(@"%@ vs %@", matchObj[@"male"][@"name"], matchObj[@"female"][@"name"]);
    NSLog(@"all find matches %lu", (unsigned long)[matchesArray count]);
    PFFile *maleselfie = matchObj[@"male"][@"selfie"];
    PFFile *femaleselfie = matchObj[@"female"][@"selfie"];
    [maleselfie getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data) {
            self.user1imgView.image = [UIImage imageWithData:data];
        }
    }];
    [femaleselfie getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data) {
            self.user2imgView.image = [UIImage imageWithData:data];
        }
    }];
}
#pragma mark - UIButton Action
- (IBAction)btnHeartClick:(id)sender{
//    if (matchesArray.count == 0) {
//        [ProgressHUD showError:@"No matches found"];
//        return;
//    }
//    
//    PFObject *matchObj = matchesArray[curIndex];
//    matchObj[@"heart"] = [NSNumber numberWithInteger:[matchObj[@"heart"] integerValue] + 1];
//    [matchObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            NSLog(@"Heart status updated successfully");
//        }
//    }];
//    
//    NSString *currentmale = matchObj[@"male"][@"name"];
//    NSString *currentfemale = matchObj[@"female"][@"name"];
//    NSLog(@"%@ and %@", currentmale, currentfemale);
//    
//    for (NSInteger i = 0 ; i < [matchesArray count]; i++) {
//        
//        NSLog(@"count = %lu",(unsigned long)[matchesArray count]);
//        PFObject *object = matchesArray[i];
//        if (([object[@"male"][@"name"] isEqual: currentmale]) || ([object[@"female"][@"name"] isEqual: currentfemale])) {
//            NSLog(@"delete matches ");
//        }else{
//            [tempAry addObject:object];
//        }
//    }
//    
//    [matchesArray removeAllObjects];
//    [matchesArray addObjectsFromArray:tempAry];
//    [tempAry removeAllObjects];
//    
//    curIndex = 0;
//    
//    if ([matchesArray count] > 0) {
//        [self loadMatchDetail:matchesArray[curIndex]];
//    }
//    
//    CGFloat scaledLenght = 200.0f;
//    CGRect rect = CGRectMake((self.view.bounds.size.width - scaledLenght) / 2, (self.view.bounds.size.height - scaledLenght - 64) / 2, scaledLenght, scaledLenght);
//    [UIView beginAnimations:nil context:Nil];
//    [UIView setAnimationDuration:0.3];
//    heartImg.frame = rect;
//    heartImg.alpha = 0.8f;
//    [UIView commitAnimations];
    
}
- (IBAction)tapHeartImg:(id)sender {
    //first animation
    CGFloat scaledLenght = 250.0f;
    CGRect rect = CGRectMake((self.view.bounds.size.width - scaledLenght) / 2, (self.view.bounds.size.height - scaledLenght) / 2, scaledLenght, scaledLenght);
    heartImg.frame = rect;
    heartImg.alpha = 0.5f;
    whitecircleImg.alpha = 0.0f;
    
    //second animation
    CGFloat originLenght = 50.0f;
    CGRect rect2 = CGRectMake((self.view.bounds.size.width - originLenght) / 2, (self.view.bounds.size.height - originLenght) / 2, originLenght, originLenght);
    [UIView beginAnimations:nil context:Nil];
    [UIView setAnimationDuration:1.0];
    heartImg.frame = rect2;
    heartImg.alpha = 1.0f;
    whitecircleImg.alpha = 1.0f;
    [UIView commitAnimations];
    
    ///
    if (matchesArray.count == 0) {
        [ProgressHUD showError:@"No matches found"];
        return;
    }
    
    PFObject *matchObj = matchesArray[curIndex];
    matchObj[@"heart"] = [NSNumber numberWithInteger:[matchObj[@"heart"] integerValue] + 1];
    [matchObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Heart status updated successfully");
            [heartedAry addObject:matchObj.objectId];
        }
    }];
    
    NSString *currentmale = matchObj[@"male"][@"name"];
    NSString *currentfemale = matchObj[@"female"][@"name"];
    NSLog(@"%@ and %@", currentmale, currentfemale);
    
    for (NSInteger i = 0 ; i < [matchesArray count]; i++) {
        
        NSLog(@"count = %lu",(unsigned long)[matchesArray count]);
        PFObject *object = matchesArray[i];
        if (([object[@"male"][@"name"] isEqual: currentmale]) || ([object[@"female"][@"name"] isEqual: currentfemale])) {
            NSLog(@"delete matches ");
        }else{
            [tempAry addObject:object];
        }
    }
    
    [matchesArray removeAllObjects];
    [matchesArray addObjectsFromArray:tempAry];
    [tempAry removeAllObjects];
    
    curIndex = 0;
    
    if ([matchesArray count] > 0) {
        [self loadMatchDetail:matchesArray[curIndex]];
    }
    
}

@end
