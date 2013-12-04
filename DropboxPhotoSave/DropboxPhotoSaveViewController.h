//
//  DropboxPhotoSaveViewController.h
//  DropboxPhotoSave
//
//  Created by Thomas Nelson on 11/28/2013.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//
#import <DropboxSDK/DropboxSDK.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "GPSViewController.h"
#import "PDFRenderer.h"

@interface DropboxPhotoSaveViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,CoreLocationControllerDelegate,DBRestClientDelegate>
{
     UIImagePickerController *imagePicker;
    DBRestClient *restClient;
    NSMutableArray *dropboxURLs;
    GPSViewController *CLController;
	IBOutlet UILabel *locLabel;

}
@property (retain, nonatomic) IBOutlet UIImageView *Photo;
@property (retain, nonatomic) IBOutlet UITextField *Name;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)btnPhoto:(id)sender;
- (IBAction)btnSave:(id)sender;
-(IBAction) doneEditing:(id) sender;
@property (retain, nonatomic) IBOutlet UILabel *caption;
@property (retain, nonatomic) IBOutlet UILabel *lblCover;

@property (retain, nonatomic) IBOutlet UIImageView *ImageCover;

//Create PDF
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * oldFilePath;
@property (nonatomic, strong) NSString * comment;
@property (nonatomic, strong) UIImage * image;
-(NSString*)getPDFFilePath;

@end
