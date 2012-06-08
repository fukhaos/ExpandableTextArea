//
//  ScrollView.m
//  chat
//
//  Created by Pedro Enrique on 8/12/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import "PESMSScrollView.h"
#import "TiUtils.h"

@implementation PESMSScrollView
@synthesize delegate;
@synthesize labelsPosition;
@synthesize sColor;
@synthesize rColor;
@synthesize animated;
@synthesize selectedColor;
@synthesize folder;
@synthesize numberOfMessage;
@synthesize backgroundLeftCap;
@synthesize backgroundTopCap;
@synthesize allMessages;

-(void)dealloc
{
	RELEASE_TO_NIL(allMessages);
	RELEASE_TO_NIL(tempDict);

	[super dealloc];
}

- (id)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        
		self.labelsPosition = self.frame;
		self.animated = YES;
		
        tempDict = [[NSMutableDictionary alloc] init];
		allMessages = [[NSMutableArray alloc] init];

		self.numberOfMessage = 0;
	}
    return self;
}

-(PESMSTextLabel *)textLabel:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(reloadContentSize) withObject:nil waitUntilDone:YES];
	
	PESMSTextLabel* textLabel = [[PESMSTextLabel alloc] initWithFrame:self.frame];
	[textLabel addText:text];
	
	[textLabel resize:self.frame];
	
	CGRect frame = textLabel.frame;
	frame.origin.y += labelsPosition.origin.y;	
	[textLabel setFrame:frame];
	
	CGRect a = self.labelsPosition;
	a.origin.y = frame.origin.y+frame.size.height;
	self.labelsPosition = a;
    
	textLabel.index_ = self.numberOfMessage;
	[tempDict setObject:[NSString stringWithFormat:@"%i",self.numberOfMessage] forKey:@"index"];
	
	self.numberOfMessage++;
	
	[allMessages addObject:[NSDictionary dictionaryWithDictionary:tempDict]];
	
	[self addSubview:textLabel];
    [textLabel release];

	return textLabel;
}

-(PESMSLabel *)label:(NSString *)text:(UIImage *)image:(TiUIView *)view:(NSString *)pos
{
	[self performSelectorOnMainThread:@selector(reloadContentSize) withObject:nil waitUntilDone:YES];

	PESMSLabel* label = [[PESMSLabel alloc] init];
	label.folder = self.folder;
    
    if (self.backgroundLeftCap != nil) {
        label.backgroundLeftCap = self.backgroundLeftCap;
    }
    if (self.backgroundTopCap != nil) {
        label.backgroundTopCap = self.backgroundTopCap;
    }
	
	[tempDict removeAllObjects];
	
	if(text)
	{
		[label addText:text];
		[tempDict setObject:text forKey:pos];
	}

	if(image)
	{
		[label addImage:image];
		TiBlob *blob = [[[TiBlob alloc] initWithImage:image] autorelease];
		[tempDict setObject:blob forKey:pos];
	}

	if(view)
	{
		[label addImageView:view];
		[tempDict setObject:view.proxy forKey:pos];
	}
	CGRect frame = label.frame;
	frame.origin.y += labelsPosition.origin.y == 0 ? 10 : labelsPosition.origin.y;	
	[label setFrame:frame];
	
	CGRect a = self.labelsPosition;
	a.origin.y = frame.origin.y + frame.size.height + 10; // + 10, margin bottom
	self.labelsPosition = a;
    
	label.index_ = self.numberOfMessage;

	[tempDict setObject:[NSString stringWithFormat:@"%i",numberOfMessage] forKey:@"index"];
	
	self.numberOfMessage++;
	
	[allMessages addObject:[NSDictionary dictionaryWithDictionary:tempDict]];

	[self addSubview:label];
    [label release];
    
	return label;
}

-(void)reloadContentSize
{
    if(CGRectIsEmpty(self.labelsPosition))
        self.labelsPosition = self.frame;
    
	CGFloat bottomOfContent = self.labelsPosition.origin.y;//+self.labelsPosition.size.height;
	
	CGSize contentSize1 = CGSizeMake(self.frame.size.width , bottomOfContent);
	
	
	[self setContentSize:contentSize1];
	
	CGRect contentSize2 = CGRectMake(0,0,self.frame.size.width, bottomOfContent);
	
	[self scrollRectToVisible: contentSize2 animated: self.animated];	
}

-(void)sendColor:(NSString *)col
{
    self.sColor = col;
}
-(void)recieveColor:(NSString *)col
{
    self.rColor = col;
}

-(void)selectedColor:(NSString *)col
{
	self.selectedColor = col;
}

-(void)backgroundColor:(UIColor *)col
{
	self.backgroundColor = col;
}

-(void)recieveImage:(UIImage *)image
{
	if(!self.rColor)
		self.rColor = @"White";
	[[self label:nil:image:nil:@"recieve"] position:@"Left":self.rColor:self.selectedColor];
}

-(void)sendImage:(UIImage *)image
{
	[[self label:nil:image:nil:@"send"] position:@"Right":self.sColor:self.selectedColor];
}

-(void)recieveImageView:(TiUIView *)view
{
	[[self label:nil:nil:view:@"recieve"] position:@"Left":self.rColor:self.selectedColor];
}

-(void)sendImageView:(TiUIView *)view
{
	[[self label:nil:nil:view:@"send"] position:@"Right":self.sColor:self.selectedColor];
}

-(void)recieveMessage:(NSString *)text;
{
	[[self label:text:nil:nil:@"recieve"] position:@"Left":self.rColor:self.selectedColor];
}

-(void)sendMessage:(NSString *)text;
{
 	[[self label:text:nil:nil:@"send"] position:@"Right":self.sColor:self.selectedColor];
}

-(void)addLabel:(NSString *)text;
{	
	[self textLabel:text];
}

-(void)animate:(BOOL)arg
{
	self.animated = arg;
}

-(void)empty
{
	ENSURE_UI_THREAD_0_ARGS
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.labelsPosition = self.frame;
	[allMessages removeAllObjects];
	self.numberOfMessage = 0;
	[self reloadContentSize];
	[self setNeedsDisplay];
}

@end
