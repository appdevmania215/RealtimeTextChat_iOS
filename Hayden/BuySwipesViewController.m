//
//  BuySwipesViewController.m
//  Hayden
//
//  Created by Matti on 16/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "BuySwipesViewController.h"
#import "BuySwipesTableCell.h"
#import "IMOBIAPHelper.h"
#import <Parse/Parse.h>
#import <StoreKit/StoreKit.h>

//#define kaddSwipeProductIdentifier1 @"com.hayden.swipe100"
//#define kaddSwipeProductIdentifier2 @"com.hayden.swipe500"
//#define kaddSwipeProductIdentifier3 @"com.hayden.swipe1000"

@interface BuySwipesViewController ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    SKProduct *myProduct1;
    SKProduct *myProduct2;
    SKProduct *myProduct3;
}

@end

@implementation BuySwipesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(BackPressed)];
    [self.navigationItem setLeftBarButtonItem:backBtn animated:NO];
    
    [[IMOBIAPHelper sharedInstance]requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if(products && products.count>0){
            myProduct1 = products[0];
            myProduct2 = products[1];
            myProduct3 = products[2];
            NSLog(@"id_count = %lu", (unsigned long)products.count);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)productPurchased:(NSNotification *)notification{
    NSLog(@"success");
    int swipeCount = [[[PFUser currentUser]objectForKey:@"swipes"]intValue];
    NSLog(@"origin_swipes = %d", swipeCount);
    NSString *productIdentifier = notification.object;
    if ([productIdentifier isEqual:@"com.hayden.swipe_100"]) {
        swipeCount += 100;
    } else if ([productIdentifier isEqual:@"com.hayden.swipe500"]){
        swipeCount += 500;
    }else if ([productIdentifier isEqual:@"com.hayden.swipe1000"]){
        swipeCount += 1000;
    }else{
    
    }
    
    NSLog(@"next_swipes = %d", swipeCount);
    PFUser *user = [PFUser currentUser];
    user[@"swipes"] = [NSNumber numberWithInteger:swipeCount];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"success save");
    }];
}

- (void)BackPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 172.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BuySwipesTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buyswipesTableCell"];
    if (!cell) {
        cell = [[BuySwipesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buyswipesTableCell"];
    }
    if (indexPath.row == 0) {
        cell.dollarlbl.text = @"$0.99";
        [cell.buybtn setTitle:@"100 swipes" forState:UIControlStateNormal];
    } else if (indexPath.row == 1){
        cell.dollarlbl.text = @"$3.99";
        [cell.buybtn setTitle:@"500 swipes" forState:UIControlStateNormal];
    } else if (indexPath.row == 2){
        cell.dollarlbl.text = @"$6.99";
        [cell.buybtn setTitle:@"1000 swipes" forState:UIControlStateNormal];
    }
    [cell.buybtn setTag:100 + indexPath.row];
    [cell.buybtn addTarget:self action:@selector(btnBuyClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (void)btnBuyClick:(UIButton*)sender{
    if (sender.tag == 100) {
        NSLog(@"0.99");
        [[IMOBIAPHelper sharedInstance]buyProduct:myProduct1];
    } else if (sender.tag == 101){
        NSLog(@"3.99");
        [[IMOBIAPHelper sharedInstance]buyProduct:myProduct2];
    } else if (sender.tag == 102){
        NSLog(@"6.99");
        [[IMOBIAPHelper sharedInstance]buyProduct:myProduct3];
    }
}

@end
