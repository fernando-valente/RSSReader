//
//  FVAppDelegate.h
//  RSSReader
//
//  Created by Fernando Valente on 8/26/14.
//  Copyright (c) 2014 Fernando Valente. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface FVAppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet NSTextField *addressField;
    IBOutlet NSTableView *tableView;
    IBOutlet WebView *webView;
    
    NSURLConnection *connection;
    NSMutableData *XMLData;
    
    NSMutableArray *feedArray;
    
    NSString *currentTitle;
}

-(IBAction)loadFeed:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
