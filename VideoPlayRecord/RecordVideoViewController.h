//
//  RecordVideoViewController.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "SRWebSocket.h"


using namespace cv;

@interface RecordVideoViewController : UIViewController<CvVideoCameraDelegate,SRWebSocketDelegate,NSURLConnectionDelegate> {
    SRWebSocket *_webSocket;
     NSMutableArray *_messages;
     CvVideoCamera *videoCamera;
    NSMutableData *_responseData;

}
@property (nonatomic, retain, readonly) NSString *message;
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UIButton *startVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopVideoButton;
@property (weak, nonatomic) IBOutlet UITextField *emal;
- (IBAction)stopVideo:(UIButton *)sender;
- (IBAction)recordVideo:(id)sender;
- (IBAction)invite:(id)sender;

@end
