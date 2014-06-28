//
//  UFAppDelegate.m
//  Unicode Faces
//
//  Created by Andrew Smith on 6/26/14.
//  Copyright (c) 2014 Andrew Smith. All rights reserved.
//

#import "UFAppDelegate.h"

@implementation UFAppDelegate

- (NSString *)faceFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = @"~/.faces";
    filePath = [filePath stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath:filePath isDirectory:NO] == NO) {
        NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"DefaultFaces" ofType:@"txt"];
        NSData *defaultData = [NSData dataWithContentsOfFile:defaultPath];
        [fileManager createFileAtPath:filePath contents:defaultData attributes:nil];
    }
    
    return filePath;
}

- (void) updateFile {
    NSMutableData *newData = [[NSMutableData alloc] init];
    
    // Deal with escape mode
    if (escapeMode == YES) {
        [newData appendData:[@"true\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        [newData appendData:[@"false\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (NSString *face in faces) {
        [newData appendData:[[NSString stringWithFormat:@"%@\n", face] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = @"~/.faces";
    filePath = [filePath stringByExpandingTildeInPath];
    
    // If the face file exists, delete it
    if ([fileManager fileExistsAtPath:filePath isDirectory:NO] == NO) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    // Otherwise, something seriously wrong happened or the user deleted it for us
    [fileManager createFileAtPath:filePath contents:newData attributes:nil];
}

- (void)insertText:(id)sender {
    NSString *face = [sender representedObject];
    
    if (escapeMode == YES) {
        face = [face stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    }
    
    CGEventRef sendKeys = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0, true);
    // Convert the NSString to a UniChar and send it to the frontmost application
    UniChar unicodeBuffer;
    
    for (int i = 0; i < [face length]; i++) {
        [face getCharacters:&unicodeBuffer range:NSMakeRange(i, 1)];
        CGEventKeyboardSetUnicodeString(sendKeys, 1, &unicodeBuffer);
        CGEventPost(kCGHIDEventTap, sendKeys);
    }
    
    CFRelease(sendKeys);
    
    // Set the menu bar item's text to the last face used
    [item setTitle:[sender representedObject]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Set up the status bar item
    item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [item setMenu:menu];
    [item setTitle:@"ಠ_ಠ"];
    [item setHighlightMode:YES];
    
    // Read faces from the face file and add them to the menu
    NSData *fileData = [NSData dataWithContentsOfFile:[self faceFile]];
    NSString *fileContents = [[NSString alloc] initWithBytes:[fileData bytes] length:[fileData length] encoding:NSUTF8StringEncoding];
    
    if ([fileContents hasPrefix:@"true"]) {
        escapeMode = YES;
        [escapeModeMenuItem setState:NSOnState];
    }
    else {
        escapeMode = NO;
        [escapeModeMenuItem setState:NSOffState];
    }
    
    faces = [NSMutableArray arrayWithArray:[fileContents componentsSeparatedByString:@"\n"]];
    [faces removeObjectAtIndex:0];
    [faces removeObjectAtIndex:([faces count] - 1)];
    
    for (NSString *face in faces) {
        NSMenuItem *faceItem = [[NSMenuItem alloc] initWithTitle:face action:@selector(insertText:) keyEquivalent:@""];
        [faceItem setRepresentedObject:face];
        [faceItem setTarget:self];
        [menu addItem:faceItem];
    }
}

- (IBAction)toggleescapeMode:(id)sender {
    NSMenuItem *check = (NSMenuItem *)sender;
    NSInteger state = [check state];
    
    if (state == NSOffState) {
        [escapeModeMenuItem setState:NSOnState];
        escapeMode = YES;
    }
    else {
        [escapeModeMenuItem setState:NSOffState];
        escapeMode = NO;
    }
}

- (void)addNewFace:(NSString *)newFace {
    [faces addObject:newFace];
    
    // Add the face to the menu
    NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:newFace action:@selector(insertText:) keyEquivalent:@""];
    [newItem setRepresentedObject:newFace];
    [newItem setTarget:self];
    [menu addItem:newItem];
    
    // Append the face to the face file
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[self faceFile]];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[[NSString stringWithFormat:@"%@\n", newFace] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    [self hideAddWindow:nil];
}

- (void)addAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)retCode contextInfo:(void *)ctx {
    switch (retCode) {
        case NSAlertFirstButtonReturn:
            [self addNewFace:[addField stringValue]];
            break;
            
        case NSAlertSecondButtonReturn:
            break;
    }
}

- (IBAction)addFace:(id)sender {
    NSString *newFace = [addField stringValue];
    
    // Make sure that the face does not already exist
    if ([faces containsObject:newFace] == NO) {
        [self addNewFace:newFace];
    }
    else {
        // Ask the user if they would like to add it anyway
        NSAlert *existsNotification = [[NSAlert alloc] init];
        [existsNotification setMessageText:@"Face already exists"];
        [existsNotification setInformativeText:@"The face that you entered is already in the face list.  Would you like to add another instance of it anyway?"];
        [existsNotification setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kAlertNoteIcon)]];
        [existsNotification addButtonWithTitle:@"Yes"];
        [existsNotification addButtonWithTitle:@"No"];
        [existsNotification beginSheetModalForWindow:addWindow modalDelegate:self didEndSelector:@selector(addAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (IBAction)showAddWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [addWindow center];
    [addWindow makeKeyAndOrderFront:nil];
}

- (IBAction)hideAddWindow:(id)sender {
    [addField setStringValue:@""];
    [addWindow orderOut:self];
}

- (IBAction)deleteFace:(id)sender {
    NSInteger selectedIndex = [deletePopUp indexOfSelectedItem];
    [faces removeObjectAtIndex:selectedIndex];
    [self updateFile];
    [menu removeItemAtIndex:(selectedIndex + 7)];
    [self hideDeleteWindow:nil];
}

- (IBAction)showDeleteWindow:(id)sender {
    // Add the faces to the popup button
    for (NSString *face in faces) {
        NSMenuItem *faceItem = [[NSMenuItem alloc] initWithTitle:face action:nil keyEquivalent:@""];
        [[deletePopUp menu] addItem:faceItem];
    }
    
    // Show the window
    [NSApp activateIgnoringOtherApps:YES];
    [deleteWindow center];
    [deleteWindow makeKeyAndOrderFront:nil];
}

- (IBAction)hideDeleteWindow:(id)sender {
    [[deletePopUp menu] removeAllItems];
    [deleteWindow orderOut:self];
}

- (void)editAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)retCode contextInfo:(void *)ctx {
    NSInteger selectedIndex = [editPopUp indexOfSelectedItem];
    NSString *newFace = [editField stringValue];
    
    switch (retCode) {
        case NSAlertFirstButtonReturn:
            [faces removeObjectAtIndex:selectedIndex];
            [self updateFile];
            [menu removeItemAtIndex:(selectedIndex + 7)];
            [self hideEditWindow:nil];
            break;
            
        case NSAlertSecondButtonReturn:
            [faces replaceObjectAtIndex:selectedIndex withObject:newFace];
            [self updateFile];
            [[menu itemAtIndex:(selectedIndex + 7)] setTitle:newFace];
            [self hideEditWindow:nil];
            break;
            
        case NSAlertThirdButtonReturn:
            break;
    }
}

- (IBAction)editFace:(id)sender {
    NSInteger selectedIndex = [editPopUp indexOfSelectedItem];
    NSString *newFace = [editField stringValue];
    
    if ([newFace isEqual:@""]) {
        NSAlert *blankNotification = [[NSAlert alloc] init];
        [blankNotification setMessageText:@"Blank replacement"];
        [blankNotification setInformativeText:@"You are attempting to replace the face you selected with nothing.  Would you like to delete the face instead?"];
        [blankNotification setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kTrashIcon)]];
        [blankNotification addButtonWithTitle:@"Delete"];
        [blankNotification addButtonWithTitle:@"Replace with Blank"];
        [blankNotification addButtonWithTitle:@"Cancel"];
        [blankNotification beginSheetModalForWindow:editWindow modalDelegate:self didEndSelector:@selector(editAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
    else {
        [faces replaceObjectAtIndex:selectedIndex withObject:newFace];
        [self updateFile];
        [[menu itemAtIndex:(selectedIndex + 7)] setTitle:newFace];
        [[menu itemAtIndex:(selectedIndex + 7)] setRepresentedObject:newFace];
        [self hideEditWindow:nil];
    }
}

- (IBAction)showEditWindow:(id)sender {
    // Add the faces to the popup button
    for (NSString *face in faces) {
        NSMenuItem *faceItem = [[NSMenuItem alloc] initWithTitle:face action:nil keyEquivalent:@""];
        [[editPopUp menu] addItem:faceItem];
    }
    
    // Show the window
    [NSApp activateIgnoringOtherApps:YES];
    [editWindow center];
    [editWindow makeKeyAndOrderFront:nil];
}

- (IBAction)hideEditWindow:(id)sender {
    [[editPopUp menu] removeAllItems];
    [editField setStringValue:@""];
    [editWindow orderOut:self];
}

- (IBAction)editSelectionChanged:(id)sender {
    [editField setStringValue:[faces objectAtIndex:[editPopUp indexOfSelectedItem]]];
}

- (IBAction)quit:(id)sender {
    [self updateFile];
    [NSApp terminate:0];
}

@end
