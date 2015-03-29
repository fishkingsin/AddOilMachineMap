//
//  DetailViewController.h
//  AddOilMachineMap
//
//  Created by James Kong on 29/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionFromMapToDetails.h"
@interface DetailViewController : UIViewController<UINavigationControllerDelegate, iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, strong) TransitionFromMapToDetails *transition;

@property (strong,nonatomic)NSArray*annotations;
-(void)setAnnotations:(NSArray *)annotations;
@end
