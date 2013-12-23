//
//  CHViewController.m
//  NSAttributedString-HTML
//
//  Created by HangChen on 12/23/13.
//  Copyright (c) 2013 HangChen. All rights reserved.
//

#import "CHViewController.h"
#import "NSAttributedString+HTML.h"



@interface CHViewController ()

@end

@implementation CHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:textView];
    NSString* html=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	NSLog(@"%@",html);
    textView.layer.borderWidth = 2;
    textView.attributedText = [NSAttributedString attributedStringWithHTML:html];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
