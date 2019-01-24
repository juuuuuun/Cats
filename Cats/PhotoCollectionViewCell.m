//
//  PhotoCollectionViewCell.m
//  Cats
//
//  Created by Jun Oh on 2019-01-24.
//  Copyright © 2019 Jun Oh. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

- (void)prepareForReuse {
    self.imageView.image = nil;
    self.titleLabel.text = @"";
}

@end
