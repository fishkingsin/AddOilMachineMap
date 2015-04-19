//
//  MapViewController.m
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "MapViewController.h"
#import "DetailViewController.h"
#import "TransitionFromMapToDetails.h"
#if DEBUG
#import "FLEXManager.h"
#endif

static const CLLocationCoordinate2D OriginalLocation = {22.2796095,114.1661851};
@interface MapViewController ()
@property(weak,nonatomic) DataCenter *dc;
@property (strong,nonatomic)NSDictionary*result;
@property (strong,nonatomic)RMMapView *mapView;
@property (nonatomic, strong) NSArray *amAnnotations;
@end

@implementation MapViewController
- (NSArray*)annotationFromDictionary:(NSDictionary *)dic {
   
    
    NSArray* allAnnoationDics = [dic valueForKey:@"messages"];
    return [self annotationFromArray:allAnnoationDics];
}
-(NSArray*)annotationFromArray:(NSArray*)arr
{
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue setMaxConcurrentOperationCount: 8];
    __block NSMutableArray *anno = [[NSMutableArray alloc] init];
    for (NSDictionary *annoationDic in arr) {
//        [queue addOperationWithBlock:^{
//            NSString* ID = [annoationDic valueForKey:kID];
            CGFloat lat = [[annoationDic valueForKey:kLatituede] floatValue];
            CGFloat lng = [[annoationDic valueForKey:kLongitude] floatValue];
//            NSString *location = [annoationDic valueForKey:kLongitude];
//            NSString *message = [annoationDic valueForKey:kMessage];
            NSString *name =[annoationDic valueForKey:kName] ;
        
            CLLocationCoordinate2D coord;
            coord.latitude = lat;
            coord.longitude = lng;

            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView
                                                                  coordinate:coord
                                                                    andTitle:name];
            [annotation setUserInfo:annoationDic];
            @synchronized(annotation) {
                [anno addObject:annotation];
            }
//        }];
    }
    
//    [queue waitUntilAllOperationsAreFinished];
    return anno;

}
- (void)populateWorldWithAllPhotoAnnotations {

    
    // loading/processing photos might take a while -- do it asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *annotations =[self annotationFromDictionary:self.result];
        NSAssert(annotations != nil, @"No messgae found");
        
        _amAnnotations = annotations;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotations:_amAnnotations];
        });
    });
}


- (void)populateWorldWithAllPhotoAnnotationsWithArray:(NSArray*)arr {
    
    
    // loading/processing photos might take a while -- do it asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *annotations = [self annotationFromArray:arr];
        NSAssert(annotations != nil, @"No messgae found");
        
        _amAnnotations = annotations;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotations:_amAnnotations];
        });
    });
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoiZmlza2luZ3NpbiIsImEiOiJJOTIyM3BnIn0.gdobaG3Pzh-BomT1-8jPmw"];
    
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"fiskingsin.lj4gno8f"];
    
    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds
                                            andTilesource:tileSource];
    self.mapView.delegate = self;
    // set zoom
    self.mapView.zoom = 1;
    self.mapView.clusteringEnabled = YES;
    self.mapView.tag = TARGET_MAP_TAG;
    
    // set coordinates
    // center the map to the coordinates
    self.mapView.centerCoordinate = OriginalLocation;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mapView];
//    MKCoordinateRegion newRegion;
//    newRegion.center = OriginalLocation;
//    newRegion.span.latitudeDelta = 10.0;
//    newRegion.span.longitudeDelta = 10.0;

//    self.mapView.region = newRegion;

//    _allAnnotationsMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDBDataAccess * fmdb = [FMDBDataAccess sharedInstance];
        NSArray*messages = fmdb.message;
        if ([messages count]>0) {
//            [fmdb deleteTable:kMessageTable];
            [self populateWorldWithAllPhotoAnnotationsWithArray:messages];
        }
        else{
            self.dc = [DataCenter sharedInstance];
            self.dc.delegate = self;
            [self.dc  apiRequest:kGMpaURL :nil];
        }
    });
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSixFingerQuadrupleTap:)];
    [tapGesture setNumberOfTouchesRequired:5];
    [self.view addGestureRecognizer:tapGesture];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
- (void)dataCenter:(DataCenter*)dataCenter apiString:(NSString*) apiStr dataDidReady:(NSDictionary*)result request:(AFHTTPRequestOperation*)request
{
//    DDLogDebug(@"%s %@",__PRETTY_FUNCTION__,result);
    self.result = [NSDictionary dictionaryWithDictionary:result];
    [self populateWorldWithAllPhotoAnnotations];
    NSArray* allAnnoationDics = [result valueForKey:@"messages"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        FMDBDataAccess * fmdb = [FMDBDataAccess sharedInstance];
        [fmdb setMessage:allAnnoationDics];
    });
}
- (void)dataCenter:(DataCenter*)dataCenter apiString:(NSString*) apiStr dataDidStatusFail:(NSString*) errorMessage request:(AFHTTPRequestOperation*)request
{
    DDLogDebug(@"%s %@",__PRETTY_FUNCTION__,errorMessage);
}
- (void)dataCenter:(DataCenter*)dataCenter apiString:(NSString*) apiStr dataDidFail:(NSError*)error request:(AFHTTPRequestOperation*)request
{
    DDLogDebug(@"%s %@",__PRETTY_FUNCTION__,error);
}
#pragma mark - MKMapViewDelegate
- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMapLayer *layer = nil;
    
    if (annotation.isClusterAnnotation)
    {
        layer = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker"]];
        

        layer.opacity = 0.75;
        
        // set the size of the circle
        layer.bounds = CGRectMake(0, 0, 50, 50);
        
        // change the size of the circle depending on the cluster's size
        if ([annotation.clusteredAnnotations count] < 100) {

            layer.bounds = CGRectMake(0,0, 50, 50);
        } else if ([annotation.clusteredAnnotations count] < 500) {

            layer.bounds = CGRectMake(0,0, 100, 100);
        } else if ([annotation.clusteredAnnotations count] > 500) {

            layer.bounds = CGRectMake(0,0, 200, 200);
        }
        
        [(RMMarker *)layer setTextForegroundColor:[UIColor yellowColor]];
        
        [(RMMarker *)layer changeLabelUsingText:[NSString stringWithFormat:@"%lu",
                                                 (unsigned long)[annotation.clusteredAnnotations count]]
         position:CGPointMake(layer.bounds.size.width*0.5,layer.bounds.size.height*0.5)];
    }
    else{
        layer = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker"]];
        layer.opacity = 0.75;
        
        // set the size of the circle
        layer.bounds = CGRectMake(0, 0, 30, 30);
        [(RMMarker *)layer setTextForegroundColor:[UIColor yellowColor]];
        [(RMMarker *)layer changeLabelUsingText:[NSString stringWithFormat:@"%@",annotation.title]
                                       position:CGPointMake(layer.bounds.size.width*0.5,layer.bounds.size.height*0.5)];

    }
    
    
    return layer;
}


- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [self onTap:annotation];
    
}
- (void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [self onTap:annotation];
}
-(void)onTap:(RMAnnotation *)annotation
{
    
    DetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    if([annotation.clusteredAnnotations count]>0)
    {
        [vc setAnnotations:annotation.clusteredAnnotations];
    }
    else{
        [vc setAnnotations:@[annotation]];
    }
    [self.navigationController pushViewController:vc animated:YES];
}
//- (void)updateVisibleAnnotations {
//
//    // This value to controls the number of off screen annotations are displayed.
//    // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
//    // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
//    static float marginFactor = 2.0;
//    
//    // Adjust this roughly based on the dimensions of your annotations views.
//    // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
//    // Numbers too small result in overlapping annotations views and too many annotations on screen.
//    static float bucketSize = 60.0;
//    
//    // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
//    MKMapRect visibleMapRect = [self.mapView visibleMapRect];
//    MKMapRect adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height);
//    
//    // determine how wide each bucket will be, as a MKMapRect square
//    CLLocationCoordinate2D leftCoordinate = [self.mapView convertPoint:CGPointZero toCoordinateFromView:self.view];
//    CLLocationCoordinate2D rightCoordinate = [self.mapView convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:self.view];
//    double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
//    MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
//    
//    // condense annotations, with a padding of two squares, around the visibleMapRect
//    double startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize;
//    double startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize;
//    double endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize;
//    double endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize;
//    
//    // for each square in our grid, pick one annotation to show
//    gridMapRect.origin.y = startY;
//    while (MKMapRectGetMinY(gridMapRect) <= endY) {
//        gridMapRect.origin.x = startX;
//        
//        while (MKMapRectGetMinX(gridMapRect) <= endX) {
//            NSSet *allAnnotationsInBucket = [self.allAnnotationsMapView annotationsInMapRect:gridMapRect];
//            NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:gridMapRect];
//            
//            // we only care about PhotoAnnotations
//            NSMutableSet *filteredAnnotationsInBucket = [[allAnnotationsInBucket objectsPassingTest:^BOOL(id obj, BOOL *stop) {
//                return ([obj isKindOfClass:[AMAnnotation class]]);
//            }] mutableCopy];
//            
//            if (filteredAnnotationsInBucket.count > 0) {
//                AMAnnotation *annotationForGrid = (AMAnnotation *)[self annotationInGrid:gridMapRect usingAnnotations:filteredAnnotationsInBucket];
//                
//                [filteredAnnotationsInBucket removeObject:annotationForGrid];
//                
//                // give the annotationForGrid a reference to all the annotations it will represent
//                annotationForGrid.containedAnnotations = [filteredAnnotationsInBucket allObjects];
//                
//                [self.mapView addAnnotation:annotationForGrid];
//                
//                for (AMAnnotation *annotation in filteredAnnotationsInBucket) {
//                    // give all the other annotations a reference to the one which is representing them
//                    annotation.clusterAnnotation = annotationForGrid;
//                    annotation.containedAnnotations = nil;
//                    
//                    // remove annotations which we've decided to cluster
//                    if ([visibleAnnotationsInBucket containsObject:annotation]) {
//                        CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
//                        [UIView animateWithDuration:0.3 animations:^{
//                            annotation.coordinate = annotation.clusterAnnotation.coordinate;
//                        } completion:^(BOOL finished) {
//                            annotation.coordinate = actualCoordinate;
//                            [self.mapView removeAnnotation:annotation];
//                        }];
//                    }
//                }
//            }
//            
//            gridMapRect.origin.x += gridSize;
//        }
//        
//        gridMapRect.origin.y += gridSize;
//    }
// 
//}


//#pragma mark - MKMapViewDelegate
//
//- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated {
//    
//    [self updateVisibleAnnotations];
//}
//
//- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
///*
//    for (MKAnnotationView *annotationView in views) {
//        if (![annotationView.annotation isKindOfClass:[PhotoAnnotation class]]) {
//            continue;
//        }
//        
//        PhotoAnnotation *annotation = (PhotoAnnotation *)annotationView.annotation;
//        
//        if (annotation.clusterAnnotation != nil) {
//            // animate the annotation from it's old container's coordinate, to its actual coordinate
//            CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
//            CLLocationCoordinate2D containerCoordinate = annotation.clusterAnnotation.coordinate;
//            
//            // since it's displayed on the map, it is no longer contained by another annotation,
//            // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
//            // to get the containerCoordinate)
//            annotation.clusterAnnotation = nil;
//            
//            annotation.coordinate = containerCoordinate;
//            
//            [UIView animateWithDuration:0.3 animations:^{
//                annotation.coordinate = actualCoordinate;
//            }];
//        }
//    }*/
//}
//
//- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
//    /*
//    static NSString *annotationIdentifier = @"Photo";
//    
//    if (aMapView != self.mapView)
//        return nil;
//    
//    if ([annotation isKindOfClass:[PhotoAnnotation class]]) {
//        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
//        if (annotationView == nil)
//            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
//        
//        annotationView.canShowCallout = YES;
//        
//        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        annotationView.rightCalloutAccessoryView = disclosureButton;
//        
//        return annotationView;
//    }
//    */
//    return nil;
//}
//
//// user tapped the call out accessory 'i' button
//- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
///*
//    PhotoAnnotation *annotation = (PhotoAnnotation *)view.annotation;
//    
//    NSMutableArray *photosToShow = [NSMutableArray arrayWithObject:annotation];
//    [photosToShow addObjectsFromArray:annotation.containedAnnotations];
//    
//    PhotosViewController *viewController = [[PhotosViewController alloc] init];
//    viewController.edgesForExtendedLayout = UIRectEdgeNone;
//    viewController.photosToShow = photosToShow;
//    
//    [self.navigationController pushViewController:viewController animated:YES];
// */
//}
//
//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
///*
//    if ([view.annotation isKindOfClass:[PhotoAnnotation class]])
//    {
//        PhotoAnnotation *annotation = (PhotoAnnotation *)view.annotation;
//        [annotation updateSubtitleIfNeeded];
//    }
// */
//}
//- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet *)annotations {
//    
//    // first, see if one of the annotations we were already showing is in this mapRect
//    NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:gridMapRect];
//    NSSet *annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
//        BOOL returnValue = ([visibleAnnotationsInBucket containsObject:obj]);
//        if (returnValue)
//        {
//            *stop = YES;
//        }
//        return returnValue;
//    }];
//    
//    if (annotationsForGridSet.count != 0) {
//        return [annotationsForGridSet anyObject];
//    }
//    
//    // otherwise, sort the annotations based on their distance from the center of the grid square,
//    // then choose the one closest to the center to show
//    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect));
//    NSArray *sortedAnnotations = [[annotations allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
//        MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
//        MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);
//        
//        CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint);
//        CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint);
//        
//        if (distance1 < distance2) {
//            return NSOrderedAscending;
//        } else if (distance1 > distance2) {
//            return NSOrderedDescending;
//        }
//        
//        return NSOrderedSame;
//    }];
//    
//    return sortedAnnotations[0];
//}
#pragma mark UINavigationControllerDelegate methods


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a DSLSecondViewController
    if (fromVC == self && [toVC isKindOfClass:[DetailViewController class]]) {
        TransitionFromMapToDetails* transistion = [[TransitionFromMapToDetails alloc] init];
        ((DetailViewController*)toVC).transition = transistion;
        return transistion;
    }
    else {
        return nil;
    }
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (IBAction)showFlex:(id)sender {

    [[FLEXManager sharedManager] showExplorer];
}

- (void)handleSixFingerQuadrupleTap:(UITapGestureRecognizer *)tapRecognizer
{
#if DEBUG
    if (tapRecognizer.state == UIGestureRecognizerStateRecognized) {
        // This could also live in a handler for a keyboard shortcut, debug menu item, etc.
        [[FLEXManager sharedManager] showExplorer];
    }
#endif
}

@end
