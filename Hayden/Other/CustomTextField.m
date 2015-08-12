//
//  CustomTextField.m
//  Hayden
//
//  Created by Matti on 08/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
- (void)awakeFromNib{
    UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.leftView = paddingview;
    self.leftViewMode = UITextFieldViewModeAlways;
    
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.f;
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
}

@end
