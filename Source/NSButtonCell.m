/* 
   NSButtonCell.m

   The button cell class

   Copyright (C) 1996 Free Software Foundation, Inc.

   Author:  Scott Christley <scottc@net-community.com>
   Date: 1996
   
   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/ 

#include <Foundation/NSLock.h>
#include <Foundation/NSArray.h>
#include <AppKit/NSButtonCell.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSWindow.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSFont.h>
#include <AppKit/NSImage.h>

//
// NSButtonCell implementation
//
@implementation NSButtonCell

//
// Class methods
//
+ (void)initialize
{
  if (self == [NSButtonCell class])
    {
      // Initial version
      [self setVersion:1];
    }
}

//
// Instance methods
//
- init
{
  [self initTextCell:@"Button"];
  return self;
}

- initImageCell:(NSImage *)anImage
{
  [super initImageCell:anImage];
  [self setStringValue:@"Button"];
  [self setButtonType:NSMomentaryPushButton];
  [self setEnabled:YES];
  [self setTransparent:NO];
  [self setBordered:YES];
  return self;
}

- initTextCell:(NSString *)aString
{
  [super initTextCell:aString];
  altContents = @"Button";
  [self setButtonType:NSMomentaryPushButton];
  [self setEnabled:YES];
  [self setTransparent:NO];
  [self setBordered:YES];
  return self;
}

- (void)dealloc
{
  [altContents release];
  [altImage release];
  [keyEquivalent release];
  [keyEquivalentFont release];
  [super dealloc];
}

//
// Setting the Titles 
//
- (NSString *)alternateTitle
{
  return altContents;
}

- (void)setAlternateTitle:(NSString *)aString
{
  altContents = [aString copy];
  // update our state
  [self setState:[self state]];
}

- (void)setFont:(NSFont *)fontObject
{
  [super setFont:fontObject];
}

- (void)setTitle:(NSString *)aString
{
  [self setStringValue:aString];
  // update our state
  [self setState:[self state]];
}

- (NSString *)title
{
  return [self stringValue];
}

//
// Setting the Images 
//
- (NSImage *)alternateImage
{
  return altImage;
}

- (NSCellImagePosition)imagePosition
{
  return image_position;
}

- (void)setAlternateImage:(NSImage *)anImage
{
  altImage = [anImage retain];
}

- (void)setImagePosition:(NSCellImagePosition)aPosition
{
  image_position = aPosition;
}

//
// Setting the Repeat Interval 
//
- (void)getPeriodicDelay:(float *)delay
		interval:(float *)interval
{}

- (void)setPeriodicDelay:(float)delay
		interval:(float)interval
{}

//
// Setting the Key Equivalent 
//
- (NSString *)keyEquivalent
{
  return keyEquivalent;
}

- (NSFont *)keyEquivalentFont
{
  return keyEquivalentFont;
}

- (unsigned int)keyEquivalentModifierMask
{
  return keyEquivalentModifierMask;
}

- (void)setKeyEquivalent:(NSString *)key
{
  keyEquivalent = [key copy];
}

- (void)setKeyEquivalentModifierMask:(unsigned int)mask
{
  keyEquivalentModifierMask = mask;
}

- (void)setKeyEquivalentFont:(NSFont *)fontObj
{
  keyEquivalentFont = [fontObj retain];
}

- (void)setKeyEquivalentFont:(NSString *)fontName 
			size:(float)fontSize
{
  keyEquivalentFont = [[NSFont fontWithName:fontName size:fontSize] retain];
}

//
// Modifying Graphic Attributes 
//
- (BOOL)isTransparent
{
  return transparent;
}

- (void)setTransparent:(BOOL)flag
{
  transparent = flag;
}

- (BOOL)isOpaque
{
  return !transparent && [self isBordered];
}

//
// Modifying Graphic Attributes 
//
- (int)highlightsBy
{
  return highlightsByMask;
}

- (void)setHighlightsBy:(int)mask
{
  highlightsByMask = mask;
}

- (void)setShowsStateBy:(int)mask
{
  showAltStateMask = mask;
}

- (void)setButtonType:(NSButtonType)buttonType
{
  [super setType:buttonType];

  switch (buttonType) {
    case NSMomentaryLight:
      [self setHighlightsBy:NSChangeBackgroundCellMask];
      [self setShowsStateBy:NSNoCellMask];
      break;
    case NSMomentaryPushButton:
      [self setHighlightsBy:NSPushInCellMask | NSChangeGrayCellMask];
      [self setShowsStateBy:NSNoCellMask];
      break;
    case NSMomentaryChangeButton:
      [self setHighlightsBy:NSContentsCellMask];
      [self setShowsStateBy:NSNoCellMask];
      break;
    case NSPushOnPushOffButton:
      [self setHighlightsBy:NSPushInCellMask | NSChangeGrayCellMask];
      [self setShowsStateBy:NSChangeBackgroundCellMask];
      break;
    case NSOnOffButton:
      [self setHighlightsBy:NSChangeBackgroundCellMask];
      [self setShowsStateBy:NSChangeBackgroundCellMask];
      break;
    case NSToggleButton:
      [self setHighlightsBy:NSPushInCellMask | NSContentsCellMask];
      [self setShowsStateBy:NSContentsCellMask];
      break;
    case NSSwitchButton:
    case NSRadioButton:
      [self setHighlightsBy:NSContentsCellMask];
      [self setShowsStateBy:NSContentsCellMask];
      break;
  }

  // update our state
  [self setState:[self state]];
}

- (int)showsStateBy
{
  return showAltStateMask;
}

- (void)setIntValue:(int)anInt
{
  [self setState:(anInt != 0)];
}

- (void)setFloatValue:(float)aFloat
{
  [self setState:(aFloat != 0)];
}

- (void)setDoubleValue:(double)aDouble
{
  [self setState:(aDouble != 0)];
}

- (int)intValue			{ return [self state]; }
- (float)floatValue		{ return [self state]; }
- (double)doubleValue		{ return [self state]; }

//
// Displaying
//
- (void)drawWithFrame:(NSRect)cellFrame
	       inView:(NSView *)controlView
{
  // Save last view drawn to
  control_view = controlView;
}

//
// Simulating a Click 
//
- (void)performClick:(id)sender
{
}

//
// NSCoding protocol
//
- (void)encodeWithCoder:aCoder
{
  [super encodeWithCoder:aCoder];

  NSDebugLog(@"NSButtonCell: start encoding\n");
  [aCoder encodeObject: altContents];
  [aCoder encodeObject: altImage];
  [aCoder encodeValueOfObjCType: @encode(BOOL) at: &transparent];
  NSDebugLog(@"NSButtonCell: finish encoding\n");
}

- initWithCoder:aDecoder
{
  [super initWithCoder:aDecoder];

  NSDebugLog(@"NSButtonCell: start decoding\n");
  altContents = [aDecoder decodeObject];
  altImage = [aDecoder decodeObject];
  [aDecoder decodeValueOfObjCType: @encode(BOOL) at: &transparent];
  NSDebugLog(@"NSButtonCell: finish decoding\n");
  return self;
}

@end
