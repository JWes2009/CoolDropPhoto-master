//
//  DropboxPhotoSaveViewController.m
//  DropboxPhotoSave
//
//  Created by Thomas Nelson on 11/28/2013.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//
#import "MBProgressHUD.h"
#import "DropboxPhotoSaveViewController.h"
#import "PDFRenderer.h"


@interface DropboxPhotoSaveViewController ()

@end

@implementation DropboxPhotoSaveViewController
@synthesize Photo;
@synthesize Name;
@synthesize scrollview;
@synthesize caption;
@synthesize lblCover;
@synthesize ImageCover;
@synthesize filePath;
NSString *files;
NSString *gps;


- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self checkinternet] == NO)
    {
          UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
                               message:@"You must connect to a Wifi or cellular data network to access CoolDropPhoto."
                               delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
                                [message show];
        
    }
   else
    {
        [self didPressLink];
    dropboxURLs = [[NSMutableArray alloc] init];

    CLController = [[GPSViewController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];

	// Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view.
    
    lblCover.hidden=0;
    ImageCover.hidden=0;
    imagePicker = [[UIImagePickerController alloc] init];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    }
}
- (BOOL) checkinternet
{
    //check internet connection
    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
    {
       // NSLog(@"Device is connected to the internet");
        return YES;
    }
    else
    {
        //NSLog(@"Device is not connected to the internet");
        return NO;
    }
    
}
-(void)dismissKeyboard {
    [Name resignFirstResponder];
}
-(IBAction) doneEditing:(id) sender {
    [sender resignFirstResponder];
}
- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPhoto:(id)sender {
    if([self checkinternet] == NO)
    {
        
        // Not connected to the internet
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
                                                          message:@"You must connect to a Wifi or cellular data network to access CoolDropPhoto."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    else
    {
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    NSArray *mediaTypes =
    [NSArray arrayWithObjects:kUTTypeImage, nil];
    imagePicker.mediaTypes = mediaTypes;
    
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePicker.allowsEditing = YES;
    
    
    //—--show the Image Picker—--
    [self presentModalViewController:imagePicker animated:YES];
    }
}
- (void)dealloc {
    [CLController release];
     [Photo release];
    [Name release];
    [scrollview release];
    [caption release];
    [lblCover release];
    [ImageCover release];
    [super dealloc];
}


- (IBAction)btnSave:(id)sender {
    if([self checkinternet] == NO)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
                                message:@"You must connect to a Wifi or cellular data network to access CoolDropPhoto."
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
        [message show];
     
    }
    else 
    {
            NSString *Caption = [Name.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([Caption isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Required"
                                                        message: @"Photo caption required"
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else
    {
    [self didPressLink];
    [self dismissKeyboard];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
      CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
   NSString *strDate = [NSString stringWithFormat:@"%02d%02d%02d%02d%02d%2.0f", currentDate.month,currentDate.day,(int)currentDate.year,currentDate.hour, currentDate.minute, currentDate.second];
    NSString *oldfilename = @"MyPicture.png";
    
    NSString *filename = [NSString stringWithFormat:@"%@ %@.%@",
                        Caption,strDate,@"png"];
         NSLog(@"filename # is: %@", filename);

    NSString *localPath = [documentsDir stringByAppendingPathComponent:oldfilename];
    NSString *destDir = @"/SecurePhotoDrop";
       NSLog(@"localPath is: %@", localPath);
    
    [[self restClient] uploadFile:filename toPath:destDir
                         fromPath:localPath];
      NSLog(@"Upload png Done");
     filePath = [self getPDFFilePath];
    filename = [NSString stringWithFormat:@"%@ %@.%@",
                           Caption,strDate,@"pdf"];
    [PDFRenderer createPDF:filePath field:Name.text Photo:Photo.image gps:gps];
         NSLog(@"PDF Done");
    [[self restClient] uploadFile:filename toPath:destDir
                         fromPath:filePath];
       NSLog(@"Upload pdf Done");
       [[self restClient] loadMetadata:@"/SecurePhotoDrop"];
    }
    }
}


-(NSString*)getPDFFilePath
{
    NSString* fileName = @"New.pdf";
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFilePath = [path stringByAppendingPathComponent:fileName];
    
    return pdfFilePath;
}

- (NSString *) filePath: (NSString *) fileName {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
   
    return [documentsDir stringByAppendingPathComponent:fileName];
   
}

- (void) saveImage{
    //—-get the date from the ImageView—-
    NSData *imageData =
    [NSData dataWithData:UIImagePNGRepresentation(Photo.image)];
    
    //—-write the date to file—-
    [imageData writeToFile:[self filePath:@"MyPicture.png"] atomically:YES];
   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string {
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    if  ([resultingString rangeOfCharacterFromSet:whitespaceSet].location == NSNotFound)      {
        return YES;
    }  else  {
        return NO;
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    NSURL *mediaUrl;
    mediaUrl = (NSURL *)[info valueForKey:
                         UIImagePickerControllerMediaURL];
    
    if (mediaUrl == nil) {
        image = (UIImage *) [info valueForKey:
                             UIImagePickerControllerEditedImage];
        if (image == nil) {
            //-—-original image selected—--
            image = (UIImage *)
            [info valueForKey:UIImagePickerControllerOriginalImage];
            
            //—--display the image—--
            Photo.image = image;
        }
        else { //—--edited image picked—-
            //—--get the cropping rectangle applied to the image—--
           
            
            //—--display the image—--
            Photo.image = image;
        }
        
        //—-save the image captured—-
        [self saveImage];
    }
    
    //—--hide the Image Picker—--
    [picker dismissModalViewControllerAnimated:0];
    lblCover.hidden=1;
    ImageCover.hidden=1;

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //-—-user did not select image; hide the Image Picker—--
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        [dropboxURLs removeAllObjects];
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"\t%@", file.filename);
            [dropboxURLs addObject:file.filename];
        }
    }
    
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    //  [activity stopAnimating];
  [MBProgressHUD hideHUDForView:self.view animated:YES];
   
     Photo.image = NULL;
    Name.text = @"";
    lblCover.hidden=0;
    ImageCover.hidden=0;
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}



- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
}
//gps coordinates
- (void)locationUpdate:(CLLocation *)location {
	
    //Get nearby address
    NSString * latitude = [[[NSString alloc] initWithFormat:@"%f", location.coordinate.latitude]autorelease];
    NSString * longitude = [[[NSString alloc] initWithFormat:@"%f", location.coordinate.longitude]autorelease];
    
    NSLog(@"latitude:%@",latitude);
    NSLog(@"longitude:%@",longitude);
    
    locLabel.text = [NSString stringWithFormat:@"%@,%@",
                     latitude, longitude];
    gps=locLabel.text;
    NSLog(@"location: %@", locLabel.text);
}

- (void)locationError:(NSError *)error {
	locLabel.text = [error description];
    
        NSLog(@"location Error: %@", locLabel.text);
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y);
    [scrollview setContentOffset:scrollPoint animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [scrollview setContentOffset:CGPointZero animated:YES];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y);
    [scrollview setContentOffset:scrollPoint animated:YES];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [scrollview setContentOffset:CGPointZero animated:YES];
}


@end
