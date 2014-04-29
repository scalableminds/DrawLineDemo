//
//  CvVideoCameraMod.h
//  DrawLineDemo
//
//  Created by Norman Rzepka on 29.04.14.
//  Copyright (c) 2014 scalable minds. All rights reserved.
//

#import <opencv2/highgui/cap_ios.h>

@interface CvVideoCameraMod : CvVideoCamera

- (void)updateOrientation;
- (void)layoutPreviewLayer;

@property (nonatomic, retain) CALayer *customPreviewLayer;

@end
