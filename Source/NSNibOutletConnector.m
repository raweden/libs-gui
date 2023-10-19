/*
   <title>NSNibOutletConnector</title>

   <abstract>Implementation of NSNibOutletConnector</abstract>

   Copyright (C) 1999, 2015 Free Software Foundation, Inc.

   Author:  Richard Frith-Macdonald <richard@branstorm.co.uk>
   Date: 1999
   Author: Fred Kiefer <fredkiefer@gmx.de>
   Date: August 2015

   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.
*/

#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import "AppKit/NSNibOutletConnector.h"

@implementation	NSNibOutletConnector

- (void) establishConnection
{
  NS_DURING
    {
      if (_src != nil)
	{
          NSString *selName;
          SEL sel;

#ifndef __WASM_NOVARG
          selName = [NSString stringWithFormat: @"set%@%@:",
                       [[_tag substringToIndex: 1] uppercaseString],
                      [_tag substringFromIndex: 1]];
#else
          selName = NSStringWithFormat(@"set%@%@:",
                       [[_tag substringToIndex: 1] uppercaseString],
                      [_tag substringFromIndex: 1]);
#endif
          sel = NSSelectorFromString(selName);

#ifdef DEBUG_NIB_LOADING
          fprintf(stderr, "entered at %s connecting '%s'\n", __PRETTY_FUNCTION__, sel_getName(sel));
#endif

          if (sel && [_src respondsToSelector: sel])
            {
#ifdef DEBUG_NIB_LOADING
              fprintf(stderr, "trying to invoke '%s'\n", [selName cString]);
#endif

#ifndef __WASM_EMCC_OBJC
              [_src performSelector: sel withObject: _dst];
#else
              void(*fp)(id, SEL, id);
              fp = (void(*)(id, SEL, id))[_src methodForSelector: sel];
              fp(_src, sel, _dst);
#endif
            }
          else
            {
              /*
               * We cannot use the KVC mechanism here, as this would always retain _dst
               * and it could also affect _setXXX methods and _XXX ivars that aren't
               * affected by the Cocoa code.
               */
              const char *name = [_tag cString];
              Class class = object_getClass(_src);
              Ivar ivar = class_getInstanceVariable(class, name);

              if (ivar != 0)
                {
                  object_setIvar(_src, ivar, _dst);
                }
            }
	}
    }
  NS_HANDLER
    {
      NSLog(@"Error while establishing connection %@: %@", self, [localException reason]);
    }
  NS_ENDHANDLER;
}

@end
