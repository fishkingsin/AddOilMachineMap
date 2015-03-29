//
//  DetailViewController.m
//  AddOilMachineMap
//
//  Created by James Kong on 29/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0 alpha:.05]];
    self.navigationController.delegate = self;
    // Do any additional setup after loading the view.    self.carousel.tag = 0xCC;
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.vertical = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGesture];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    
}
- (void)tapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    //    return (NSInteger)[self.items count];
    return [self.annotations count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    RMAnnotation* object = [_annotations objectAtIndex:index];
    UITextView *textField = nil;
    if(view == nil)
    {
        
        CGFloat width = self.view.bounds.size.width*0.8;
        
        view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, width, width*0.5)];
        
        [view setBackgroundColor:[UIColor clearColor]];
        
        
        
        textField = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0, width, width*0.5)];
        
        textField.backgroundColor = [UIColor clearColor];
        [textField setTextAlignment:NSTextAlignmentLeft];
        textField.font = [textField.font fontWithSize:22];
        textField.tag = 1;
        [textField setTextColor:[UIColor whiteColor]];
//        [textField setBackgroundColor:[UIColor blackColor]];
        textField.center = view.center;
        [view addSubview:textField];
        [textField setSelectable:NO];
        [textField setEditable:NO];
        [textField setScrollEnabled:NO];
    }
    else
    {
        textField = (UITextView *)[view viewWithTag:1];
    }
    [textField setText:[NSString stringWithFormat:@"%@\n%@\n%@\n%@",
                        [object valueForKey:kID],
                        [object valueForKey:kName],
                        [object valueForKey:kMessage],
                        [object valueForKey:kLocation]
                        ]];
    return view;
}
- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
//            if([_annotations count]>1)
//            {
//                return YES;
//            }
//            else
            {
                return NO;
            }
        }
            
        case iCarouselOptionFadeMax:
        case iCarouselOptionArc:
        case iCarouselOptionRadius:
        case iCarouselOptionSpacing:
        {
            return value *1.02;
        }
        case iCarouselOptionTilt:
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionAngle:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            return value;
        }
    }
}
- (NSInteger)numberOfPlaceholdersInCarousel:(__unused iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    if([_annotations count]>1)
    {
        return 0;
    }
    else
    {
        return 2;
    }

}

- (UIView *)carousel:(__unused iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    if(view == nil)
    {

        CGFloat width = self.view.bounds.size.width*0.8;

        view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, width, width)];

        [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];



        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, width, width)];

        label.backgroundColor = [UIColor clearColor];
        [label setTextAlignment:NSTextAlignmentLeft];
        label.font = [label.font fontWithSize:16];
        label.tag = 1;
        [label setTextColor:[UIColor yellowColor]];

        label.center = view.center;
        [label setText:@"Stand by you"];
        [view addSubview:label];
    }
    else
    {
        label = (UILabel *)[view viewWithTag:1];
    }



    return view;
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
    //    NSNumber *item = (self.items)[(NSUInteger)index];
//    NSLog(@"Tapped view number: %li", (long)index);
    
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel
{
//    NSLog(@"Index: %@", @(self.carousel.currentItemIndex));
    @try {
        
    }
    @catch (NSException *exception) {
        
        DDLogDebug(@"exception %@",exception );
    }
}


-(void)setAnnotations:(NSArray *)annotations
{
    _annotations = [NSArray arrayWithArray:[annotations valueForKeyPath:@"@unionOfObjects.userInfo"]];
    [self.carousel reloadData];
}
#pragma mark UINavigationControllerDelegate methods


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {

        self.transition.reversed = YES;
        return self.transition;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
@end

