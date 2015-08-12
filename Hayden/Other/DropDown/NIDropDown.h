//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NIDropDown;
@protocol NIDropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender selectedIndex:(NSInteger)selectedIndex;
@end

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSString *animationDirection;
    UIImageView *imgView;
}

@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIView *viewSender;
@property(nonatomic, retain) NSArray *list;
@property (nonatomic, retain) id <NIDropDownDelegate> delegate;
@property (nonatomic, retain) NSString *animationDirection;
@property (nonatomic) BOOL isShown;
@property (nonatomic) CGFloat height;

-(void)hideDropDown:(UIView *)view;
- (void)hideDropDown;
- (id)showDropDown:(UIView *)view height:(CGFloat *)height arr:(NSArray *)arr imgarr:(NSArray *)imgArr direction:(NSString *)direction;
- (void)showDropDown;

@end
