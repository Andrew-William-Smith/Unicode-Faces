//
//  UFAppDelegate.h
//  Unicode Faces
//
//  Created by Andrew Smith on 6/26/14.
//  Copyright (c) 2014 Andrew Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UFAppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *item;
    NSMutableArray *faces;
    bool escapeMode;
    
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *escapeModeMenuItem;
    IBOutlet NSWindow *addWindow;
    IBOutlet NSTextField *addField;
    IBOutlet NSWindow *deleteWindow;
    IBOutlet NSPopUpButton *deletePopUp;
    IBOutlet NSWindow *editWindow;
    IBOutlet NSPopUpButton *editPopUp;
    IBOutlet NSTextField *editField;
}

@property (assign) IBOutlet NSWindow *window;

- (NSString *)faceFile;
- (void)insertText:(id)sender;
- (void)addNewFace:(NSString *)newFace;
- (void) addAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)retCode contextInfo:(void *)ctx;
- (void) updateFile;
- (void) editAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)retCode contextInfo:(void *)ctx;

@end
