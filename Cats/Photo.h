//
//  Photo.h
//  Cats
//
//  Created by Jun Oh on 2019-01-24.
//  Copyright © 2019 Jun Oh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSObject

@property (nonatomic) NSURL* photoURL;
@property (nonatomic) NSString* title;

- (instancetype) initWithPhotoURL:(NSURL *)photoURL
                         andTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
