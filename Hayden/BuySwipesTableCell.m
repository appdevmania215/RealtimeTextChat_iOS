//
//  BuySwipesTableCell.m
//  Hayden
//
//  Created by Matti on 16/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "BuySwipesTableCell.h"

@implementation BuySwipesTableCell

- (void)awakeFromNib {
    // Initialization code
    self.buybtn.layer.cornerRadius = 15.f;
    self.buybtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
