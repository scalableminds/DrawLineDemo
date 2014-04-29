//
//  ViewController.mm
//  DrawLineDemo
//
//  Created by Norman Rzepka on 29.04.14.
//  Copyright (c) 2014 scalable minds. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController

@synthesize videoCamera;

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  
  self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
  self.videoCamera.delegate = self;
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
  self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
  self.videoCamera.defaultFPS = 30;
  
//  double newWidth = _imageView.frame.size.height * (480.0/640.0);
//  _imageView.frame = CGRectMake(_imageView.frame.origin.x - (newWidth - _imageView.frame.size.width) / 2, _imageView.frame.origin.y,
//                                newWidth, _imageView.frame.size.height);
  
  [videoCamera createVideoPreviewLayer];
  [self.imageView.layer addSublayer:self.videoCamera.customPreviewLayer];
  
}

- (NSUInteger)supportedInterfaceOrientations
{
  // Only portrait orientation
  return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#ifdef __cplusplus
- (void)processImage:(Mat&)image
{
  // Convert to grayscale
  cvtColor(image, image, CV_BGR2GRAY);
  
  int kernelSize = 33; //int(self.contrastSlider.value) * 2 + 1;
  int c = 6; //self.thresholdSlider.value;
  
  // Thresholding
  adaptiveThreshold(image, image, 255, ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, kernelSize, c);
  
  
  printf("%d %d\n", kernelSize, c);
  
  
}
#endif

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [videoCamera start];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [videoCamera stop];
}

- (void)dealloc
{
  videoCamera.delegate = nil;
}

@end
