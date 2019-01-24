//
//  Photo.m
//  Cats
//
//  Created by Jun Oh on 2019-01-24.
//  Copyright © 2019 Jun Oh. All rights reserved.
//

#import "Photo.h"

@implementation Photo


- (instancetype)initWithPhotoURL:(NSURL *)photoURL
                        andTitle:(nonnull NSString *)title {
    self = [super init];
    if(self) {
        _photoURL = photoURL;
        _title = title;
    }
    return self;
}

@end
