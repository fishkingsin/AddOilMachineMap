//
//  TransitionFromMapToDetails.h
//  AddOilMachineMap
//
//  Created by James Kong on 29/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TARGET_MAP_TAG 0xAA
@interface TransitionFromMapToDetails : NSObject<UIViewControllerAnimatedTransitioning>


@property (weak, nonatomic) id<UIViewControllerContextTransitioning> context;

@property (nonatomic, strong) UIImageView *bluredImageView;
@property (nonatomic, strong) UIView *backgroundView;
@property (assign, nonatomic) BOOL reversed;

@end
