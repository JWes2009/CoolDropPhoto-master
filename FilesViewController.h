//
//  FilesViewController.h
//  DropPhoto
//
//  Created by Thomas Nelson on 11/28/2013.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//

#import "MTPopupWindow.h"
#import <DropboxSDK/DropboxSDK.h>
#import <UIKit/UIKit.h>

@interface FilesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource,MTPopupWindowDelegate,DBRestClientDelegate>
{
    DBRestClient *restClient;
    NSMutableArray *dropboxURLs;
}
@property (retain, nonatomic) IBOutlet UITableView *tblView;
@end
