//
//  FilesViewController.m
//  DropPhoto
//
//  Created by Thomas Nelson on 11/28/2013.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//


#import <DropboxSDK/DropboxSDK.h>
#import "FilesViewController.h"

@interface FilesViewController ()
@end

@implementation FilesViewController
@synthesize tblView=tblView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // dropboxURLs = [[NSMutableArray alloc] init];
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
    [self didPressLink];
    dropboxURLs = [NSMutableArray new];

     [[self restClient] loadMetadata:@"/SecurePhotoDrop"];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
   
}


- (DBRestClient*)restClient {
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}



- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
  
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if (!file.isDirectory)
            {
                NSLog(@"%@", file.filename);
                [dropboxURLs addObject:file.filename];
            }
        }
    }
    [self.tblView reloadData];

    
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}



- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return dropboxURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [dropboxURLs objectAtIndex:indexPath.row];
      NSLog(@"Folder '%@' contains:",cell.textLabel.text);

    return cell;
}
// Set action on Row selection.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //DeselectRowAtIndexPath method to deselect row.
    // [self.tableViewForDropBoxItems deselectRowAtIndexPath:indexPath animated:YES];
    NSString *path = [@"/SecurePhotoDrop/" stringByAppendingString:[dropboxURLs objectAtIndex:indexPath.row]];
   [[self restClient] loadSharableLinkForFile:path];
       NSLog(@"Path is: '%@':",path);
}
- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path
{
  // MTPopupWindow *popup = [[MTPopupWindow alloc] init];
 // popup.delegate = self;
  //popup.fileName = link;
  // [popup show];
    
   MTPopupWindow *popup = [[MTPopupWindow alloc] init];
    popup.usesSafari = YES;
    popup.fileName = link;
   [popup show];

   
  }

@end
