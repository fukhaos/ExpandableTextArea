//
//  Label.m
//  chat
//
//  Created by Pedro Enrique on 8/13/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import "PESMSLabel.h"
#import "TiHost.h"

@implementation PESMSLabel

@synthesize index_;
@synthesize isText;
@synthesize isImage;
@synthesize isView;
@synthesize textValue;
@synthesize imageValue;
@synthesize prox;

@synthesize rColor;
@synthesize sColor;
@synthesize selectedColor;
@synthesize folder;
@synthesize backgroundLeftCap;
@synthesize backgroundTopCap;

-(void)dealloc
{
	if(isText) {
        RELEASE_TO_NIL(label);
        RELEASE_TO_NIL(textValue);
    }
		
	if(isImage) {
        RELEASE_TO_NIL(innerImage);
        RELEASE_TO_NIL(imageValue);
    }
		
	if(isView) {
        RELEASE_TO_NIL(innerView);
        RELEASE_TO_NIL(prox);
    }
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
	[super dealloc];
}

-(id)init
{
	if(self = [super init])
	{
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
	}
	return self;
}


- (void)doLongTouch
{
	[self becomeFirstResponder];
	UIMenuController *menu = [UIMenuController sharedMenuController];
	[menu setTargetRect:CGRectMake(0,0,self.frame.size.width,self.frame.size.height) inView:self];
	[menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder;
{
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
{
	BOOL r = NO;
	if (action == @selector(copy:)) {
		r = YES;
	} else {
		r = [super canPerformAction:action withSender:sender];
	}
	return r;
}

- (void)copy:(id)sender
{
	UIPasteboard *paste = [UIPasteboard generalPasteboard];
	paste.persistent = YES;
	[paste setString:textValue];	
}

- (void)orientationChanged:(NSNotification *)note
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if (orientation == UIDeviceOrientationLandscapeLeft ||
		orientation == UIDeviceOrientationLandscapeRight ||
		orientation == UIDeviceOrientationPortrait ||
		orientation == UIDeviceOrientationPortraitUpsideDown)
	{
		if(orientation != orient && thisPos == 2)
		{
			CGRect a = self.frame;
			a.origin.x = (self.superview.frame.size.width-self.frame.size.width)-5;
			[self setFrame:a];
			[self setNeedsDisplay];
			orient = orientation;
		}
		if(orientation != orient && thisPos == 1)
		{
			CGRect a = self.frame;
			a.size.width = self.superview.frame.size.width;///2-a.size.width/2;
			a.origin.x = 0;
			CGRect b = self.label.frame;
			b.size.width = a.size.width;
			b.origin.x = 0;
			[self.label setFrame:b];
			[self setFrame:a];
			[self setNeedsDisplay];
			orient = orientation;
		}
	}

}

-(UIImageView *)innerImage:(UIImage *)image
{
	if(!innerImage)
	{
		innerImage = [[UIImageView alloc] initWithImage:image];
		isImage = YES;
	}
	return innerImage;
}

-(UILabel *)label
{
	if(!label)
	{
		hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongTouch)];
		[self addGestureRecognizer:hold];
        [hold release];
		label = [[UILabel alloc] init];
        label.font= [UIFont systemFontOfSize:14.0f];
		label.numberOfLines = 0;
		label.backgroundColor = [UIColor clearColor];
		isText = YES;
	}
	return label;
}

-(void)setUpTextImageSize
{
	CGRect x = [self label].frame;
	if(x.size.width > 270)//self.superview.frame.size.width-100)
	{
		x.size.width = 270;//self.superview.frame.size.width-100;
		[[self label] setFrame:x];
		[[self label] sizeToFit];
		
	}
	CGRect a = [self label].frame;
	a.size.width += 14;
	a.size.height += 10;
	a.origin.y = 0;
	a.origin.x = 0;
	self.frame = a;
	
	CGRect b = [self label].frame;
	b.origin.x = 7;	
    b.origin.y = 5;
	[[self label] setFrame:b];
}

-(void)setUpInnerImageImageSize
{
	CGRect a = [self innerImage:nil].frame;
	a.size.width +=25;
	a.size.height +=20;
	a.origin.y = 10;
	a.origin.x = 10;
	self.frame = a;
	
	CGRect b = [self innerImage:nil].frame;
	b.origin.y = 8;	
	b.origin.x = 15;
	
	[[self innerImage:nil] setFrame:b];
}

-(void)setUpInnerImageViewSize
{
	CGRect a = innerView.frame;
	a.size.width +=25;
	a.size.height +=20;
	a.origin.y = 10;
	a.origin.x = 10;
	self.frame = a;
	
	CGRect b = innerView.frame;
	b.origin.y = 8;	
	b.origin.x = 10;
	
	[innerView setFrame:b];
}

-(BOOL)isUserInteractionEnabled
{
	return YES;	
}

-(void)addText:(NSString *)text
{
	textValue = [text retain];
	[[self label] performSelectorOnMainThread : @selector(setText:) withObject:text waitUntilDone:YES];
	[self addSubview:[self label]];
	[[self label] sizeToFit];
	[self setUpTextImageSize];
}

-(void)addImage:(UIImage *)image
{
	imageValue = [image retain];
	[self addSubview:[self innerImage:image]];
	[[self innerImage:nil] sizeToFit];
	[self setUpInnerImageImageSize];
}

-(void)addImageView:(TiUIView *)view
{
	[view setUserInteractionEnabled:NO];
	isView = YES;
	innerView = [view retain];
	prox = [view.proxy retain];
	
	//this is just a quick workaround, just for now
	
	CGRect a = view.frame;
	a.origin.x = 0;
	a.origin.y = 0;
	[view setFrame:a];
	[self performSelectorOnMainThread:@selector(addSubview:) withObject:view waitUntilDone:YES];
	[self setUpInnerImageViewSize];
}


-(NSString*)getNormalizedPath:(NSString*)source
{
	if ([source hasPrefix:@"file:/"]) {
		NSURL* url = [NSURL URLWithString:source];
		return [url path];
	}
	return source;
}

-(NSString *)resourcesDir:(NSString *)url
{
	url = [[TiHost resourcePath] stringByAppendingPathComponent:[self getNormalizedPath:url]];
	
	return url;
}

-(NSString *)pathOfImage:(NSString *)pos:(NSString *)color
{
	NSString *imgName = [[[color stringByAppendingString:@"Balloon"] stringByAppendingString:pos] stringByAppendingString:@".png" ];
    imgName = [[[TiHost resourcePath] stringByAppendingPathComponent:self.folder] stringByAppendingPathComponent:imgName];
    
	return imgName;
}

-(void)position:(NSString *)pos:(NSString *)color:(NSString *)selCol
{
	if([pos isEqualToString:@""] || !pos)
		pos = @"Left";
	if([color isEqualToString:@""] || !color)
		color = @"White";
	if([selCol isEqualToString:@""] || !selCol)
		selCol = @"White";
	
	thisColor = color;
	selectedColor = selCol;
	
	NSString *imgName = [self pathOfImage:pos :color];
    
    int leftCap = 16, topCap = 9;
    if (self.backgroundLeftCap != nil) {
        leftCap = [self.backgroundLeftCap intValue];
    }
    if (self.backgroundTopCap != nil) {
        topCap = [self.backgroundTopCap intValue];
    }
	
	if([pos isEqualToString:@"Left"])
	{
        thisPos = 0;
		if(isText)
		{
			CGRect a = [self label].frame;
			a.origin.x += 8;
			[[self label] setFrame:a];
		}
		if(isImage)
		{
			CGRect a = [self innerImage:nil].frame;
			a.origin.x +=5;
			[[self innerImage:nil] setFrame:a];
		}
		if(isView)
		{
			CGRect a = innerView.frame;
			a.origin.x +=5;
			[innerView setFrame:a];
		}
		
		CGRect b = self.frame;
        b.origin.x = 5; // margin
        b.size.width += 10; // padding
		[self setFrame:b];		
		self.image = [[UIImage imageWithContentsOfFile:imgName] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
	}
	else if([pos isEqualToString:@"Right"])
	{
        thisPos = 2;
		self.image = [[UIImage imageWithContentsOfFile:imgName] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
		CGRect a = self.frame;
		a.size.width += 8; // padding
		a.origin.x = (self.superview.frame.size.width - a.size.width) - 5; // margin
		[self setFrame:a];
	}
	else if([pos isEqualToString:@"Center"])
	{
        thisPos = 1;
        //only used by addLabel currently
        //self.label.textColor = [UIColor grayColor];
		self.label.textAlignment = UITextAlignmentCenter;
		CGRect a = self.frame;
        a.size.width = self.superview.frame.size.width;///2-a.size.width/2;
		a.origin.x = 0;
		CGRect b = self.label.frame;
		b.size.width = a.size.width;
		b.origin.x = 0;
		a.size.height = b.size.height;
		[self.label setFrame:b];
		[self setFrame:a];
	}
	else
	{
		NSLog(@"[ERROR] need to know if it's \"Left\" or \"Center\" or \"Right\", stupid!");
	}

}

-(void)resetImage
{
	//image = [[UIImage imageWithContentsOfFile:[self pathOfImage:thisPos:thisColor]] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resetImage];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resetImage];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resetImage];		
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString* stringPos;
    switch (thisPos) {
        case 0:
            stringPos = @"Left";
            break;
        case 1:
            stringPos = @"Center";
            break;
        case 2:
            stringPos = @"Right";
            break;            
        default:
            break;
    }
	NSString *imgName = [self pathOfImage:stringPos:selectedColor];
	self.image = [[UIImage imageWithContentsOfFile:imgName] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
}

@end