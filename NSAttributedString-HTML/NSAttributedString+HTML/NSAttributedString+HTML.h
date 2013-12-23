//
//  CHViewController.h
//  NSAttributedString+HTML
//
//  Created by HangChen on 12/23/13.
//  Copyright (c) 2013 HangChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (CHHTML)
+(NSAttributedString*)attributedStringWithHTML:(NSString*)html;
@end

@interface CHHTMLParser : NSObject
-(NSAttributedString*)parse:(NSString*)html;
@end