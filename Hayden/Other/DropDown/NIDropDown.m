//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface NIDropDown ()

@property(nonatomic, retain) NSArray *imageList;

@end

@implementation NIDropDown
@synthesize table;
@synthesize viewSender;
@synthesize list;
@synthesize imageList;
@synthesize delegate;
@synthesize animationDirection;

- (id)showDropDown:(UIView *)view height:(CGFloat *)height arr:(NSArray *)arr imgarr:(NSArray *)imgArr direction:(NSString *)direction{
    viewSender = view;
    animationDirection = direction;
    self.table = (UITableView *)[super init];
    self.isShown = YES;
    self.height = *(height);
    if (self) {
        // Initialization code
        CGRect btn = view.frame;
        self.list = [NSArray arrayWithArray:arr];
        self.imageList = [NSArray arrayWithArray:imgArr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        table.backgroundColor = [UIColor whiteColor];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
            [table setSeparatorInset:UIEdgeInsetsZero];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y-*height, btn.size.width, *height);
        } else if([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, *height);
        }
        table.frame = CGRectMake(0, 0, btn.size.width, *height);
        [UIView commitAnimations];
        [viewSender.superview addSubview:self];
        [self addSubview:table];
    }
    return self;
}
- (void)showDropDown{
    self.isShown = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
//    if ([direction isEqualToString:@"up"]) {
//        self.frame = CGRectMake(btn.origin.x, btn.origin.y-*height, btn.size.width, *height);
//    } else if([direction isEqualToString:@"down"]) {
        self.frame = CGRectMake(viewSender.frame.origin.x, viewSender.frame.origin.y+viewSender.frame.size.height, viewSender.frame.size.width, self.height);
//    }
    table.frame = CGRectMake(0, 0, viewSender.frame.size.width, self.height);
    [UIView commitAnimations];

}
- (void)hideDropDown{
    CGRect btn = viewSender.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    }
    table.frame = CGRectMake(0, 0, btn.size.width, 0);
    [UIView commitAnimations];
    self.isShown = NO;
}
-(void)hideDropDown:(UIView *)view {
    CGRect btn = view.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    }
    table.frame = CGRectMake(0, 0, btn.size.width, 0);
    [UIView commitAnimations];
    self.isShown = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x + 30.f, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    if ([self.imageList count] == [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        cell.imageView.image = [imageList objectAtIndex:indexPath.row];
    } else if ([self.imageList count] > [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    } else if ([self.imageList count] < [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    }
    cell.textLabel.textColor = [UIColor grayColor];
    cell.separatorInset = UIEdgeInsetsZero;
    
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = v;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:viewSender];
    
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    if ([viewSender isKindOfClass:[UIButton class]]) {
        [(UIButton*)viewSender setTitle:c.textLabel.text forState:UIControlStateNormal];
    } else if ([viewSender isKindOfClass:[UITextField class]]){
        [((UITextField*)viewSender) setText:c.textLabel.text];
    }
    
    for (UIView *subview in viewSender.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    imgView.image = c.imageView.image;
    imgView = [[UIImageView alloc] initWithImage:c.imageView.image];
    imgView.frame = CGRectMake(5, 5, 25, 25);
    [viewSender addSubview:imgView];
    [self.delegate niDropDownDelegateMethod:self selectedIndex:indexPath.row];
}


-(void)dealloc {
//    [super dealloc];
//    [table release];
//    [self release];
}

@end
