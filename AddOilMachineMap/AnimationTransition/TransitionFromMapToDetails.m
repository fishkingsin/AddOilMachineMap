//
//  TransitionFromMapToDetails.m
//  AddOilMachineMap
//
//  Created by James Kong on 29/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "TransitionFromMapToDetails.h"

@implementation TransitionFromMapToDetails
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    
    UIView *containerView = [transitionContext containerView];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    if(!self.reversed)
    {
        RMMapView *mapview =nil;
        [self findMapView:fromView ref:&mapview];
        if(mapview){
            UIImage *originalImage = [mapview takeSnapshotAndIncludeOverlay:YES];
            UIImageView *blurImageView = [[UIImageView alloc] initWithFrame:fromView.bounds];
            
            [blurImageView setImage:[originalImage blurredImageWithRadius:10.0f iterations:3 tintColor:[UIColor blackColor]]];
            self.bluredImageView = blurImageView;
        }
        [containerView addSubview:self.bluredImageView];
        [containerView addSubview:toView];
        self.bluredImageView.alpha = 0.0;
        
        toView.center = CGPointMake( toView.frame.size.width , toView.center.y);
        [UIView animateWithDuration:duration animations:^{
            self.bluredImageView.alpha = 1.0f;
            toView.center = fromView.center;
            
            
        } completion:^(BOOL finished) {
            if(finished)
            {
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }
            
            
        }];
        
    }
    else{
        [containerView addSubview:toView];
        toView.alpha = 0.0;
        [UIView animateWithDuration:duration animations:^{
            self.bluredImageView.alpha = 0.0f;
            toView.alpha = 1.0;
            fromView.alpha = 0.0;
            fromView.center = CGPointMake(fromView.center.x+fromView.frame.size.width,fromView.center.y);
        } completion:^(BOOL finished) {
            if(finished)
            {
                [fromView removeFromSuperview];
                [self.bluredImageView removeFromSuperview];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }
            
            
        }];
    }
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.5;
}
- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}
-(void)findMapView:(UIView*)fromView ref:(UIView**)ref
{
    NSArray * arr = [fromView subviews];
    
    for(UIView *view in arr)
    {
        if(view.tag == TARGET_MAP_TAG)
        {
            *ref = view;
        }
        else
        {
            if([view.subviews count]>0)
            {
                [self findMapView:view ref:ref];
            }
        }
    }
    
}
@end
