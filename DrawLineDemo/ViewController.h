//
//  ViewController.h
//  DrawLineDemo
//
//  Created by Norman Rzepka on 29.04.14.
//  Copyright (c) 2014 scalable minds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "CvVideoCameraMod.h"

#import <opencv2/highgui/cap_ios.h>
#import <numeric>

using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate> {
  
  CvVideoCameraMod* videoCamera;
  
}

@property (nonatomic, retain) CvVideoCameraMod* videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UISlider* thresholdSlider;
@property (nonatomic, strong) IBOutlet UISlider* contrastSlider;

@end

