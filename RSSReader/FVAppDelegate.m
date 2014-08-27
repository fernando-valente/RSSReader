//
//  FVAppDelegate.m
//  RSSReader
//
//  Created by Fernando Valente on 8/26/14.
//  Copyright (c) 2014 Fernando Valente. All rights reserved.
//

#import "FVAppDelegate.h"

@implementation FVAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification{
    currentTitle = @"RSSReader";
    
    [[self window] setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
}

-(IBAction)loadFeed:(id)sender{
    [connection cancel];
    
    NSString *URLString = [addressField stringValue];
    
    if([URLString rangeOfString:@"://"].length == 0)
        URLString = [@"http://" stringByAppendingString:URLString];
    
    NSURL *URL = [NSURL URLWithString:URLString];

    if(!URL){
        NSBeep();
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [[self window] setTitle:@"RSSReader - Loading..."];
}

#pragma mark Connection

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    XMLData = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [XMLData appendData:data];
}

-(void)connection:(NSURLConnection *)con didFailWithError:(NSError *)err{
    [[self window] setTitle:currentTitle];
    
    NSAlert *alert = [NSAlert alertWithError:err];
    [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
    connection = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)con{
    connection = nil;
    
    
    NSError *err = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:XMLData options:0 error:&err];
    
    if(err){
        NSAlert *alert = [NSAlert alertWithError:err];
        [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        [[self window] setTitle:currentTitle];
        
        return;
    }
    
    NSArray *titleArr = [document nodesForXPath:@"rss/channel/title" error:nil];
    
    if([titleArr count] > 0){
        currentTitle = [[titleArr objectAtIndex:0] stringValue];
        currentTitle = [NSString stringWithFormat:@"RSSReader - %@", currentTitle];
    }
    else{
        currentTitle = @"RSSReader";
    }
    
    [[self window] setTitle:currentTitle];
    
    feedArray = [[NSMutableArray alloc] init];
    
    NSArray *entries = [document nodesForXPath:@"rss/channel/item" error:nil];
    
    for(int i = 0; i < [entries count]; i++){
        NSXMLNode *entry = [entries objectAtIndex:i];
    
        NSString *title = [[[entry nodesForXPath:@"title" error:nil] objectAtIndex:0] stringValue];
        NSString *description = [[[entry nodesForXPath:@"description" error:nil] objectAtIndex:0] stringValue];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title",
                              description, @"description", nil];
        
        [feedArray addObject:dict];
    }
    
    [tableView reloadData];
}

#pragma mark TableView

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return [feedArray count];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    NSDictionary *dict = [feedArray objectAtIndex:rowIndex];
    
    return [dict objectForKey:@"title"];
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    NSInteger selectedRow = [tableView selectedRow];
    
    NSDictionary *dict = [feedArray objectAtIndex:selectedRow];
    NSString *description = [dict objectForKey:@"description"];
    
    [[webView mainFrame] loadHTMLString:description baseURL:[NSURL URLWithString:@""]];
}

@end
