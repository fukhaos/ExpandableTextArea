//
//  TextArea.m
//  chat
//
//  Created by Pedro Enrique on 8/12/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import "PESMSTextArea.h"
#import "TiSmsviewView.h"
#import "TiHost.h"

@implementation PESMSTextArea
@synthesize delegate;
@synthesize text;
@synthesize hasCam;
@synthesize firstTime;
@synthesize folder;
@synthesize maxLines;
@synthesize minLines;

@synthesize backgroundLeftCap;
@synthesize backgroundTopCap;

-(void)dealloc
{
	RELEASE_TO_NIL(textView);
	RELEASE_TO_NIL(entryImageView);
	RELEASE_TO_NIL(imageView);
	
	[super dealloc];
}

-(UIImage *)resourcesImage:(NSString *)url
{
    NSString* imgName = [[[TiHost resourcePath] stringByAppendingPathComponent:self.folder] stringByAppendingPathComponent:url];
	return [UIImage imageWithContentsOfFile:imgName];
}


- (HPGrowingTextView *)textView {
	if(textView==nil)
	{
		textView = [[HPGrowingTextView alloc] init];
		textView.minNumberOfLines = self.minLines ? self.minLines : 1;
		textView.maxNumberOfLines = self.maxLines ? self.maxLines : 4;
		textView.returnKeyType = UIReturnKeyDefault;
		textView.font = [UIFont systemFontOfSize:15.0f];
		textView.delegate = self;
		[textView sizeToFit];
	}
	return textView;
}

-(UIButton *)doneBtn
{
	if(!doneBtn)
	{
		doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		
		[doneBtn setTitle:@"Send" forState:UIControlStateNormal];
		
		[doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
		doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
		doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
		
		[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[doneBtn addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
	}
	
	return doneBtn;
}

-(UIButton *)camButton
{
	if(!camButton)
	{
		camButton = [UIButton buttonWithType:UIButtonTypeCustom];
		camButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
				
		[camButton addTarget:self action:@selector(camButtonPressed) forControlEvents:UIControlEventTouchUpInside];
				
		camButton.backgroundColor = [UIColor clearColor];
		[self addSubview:camButton];
	}
	return camButton;

}

-(UIImageView *)entryImageView
{
	if(!entryImageView)
	{
		entryImageView = [[UIImageView alloc] init];
		entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	return entryImageView;
}

-(void)buttonTitle:(NSString *)title
{
	[[self doneBtn] setTitle:title forState:UIControlStateNormal];
}

-(UIImageView *)imageView
{
	if(!imageView)
	{
		imageView = [[UIImageView alloc] init];
		imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	return imageView;
}

-(void)resize:(float)bottom
{
	imageView		= [self imageView];
	textView		= [self textView];
	entryImageView	= [self entryImageView];
	doneBtn			= [self doneBtn];
	camButton		= [self camButton];

	if(self.firstTime == NO){
		self.firstTime = YES;
		// view hierachy
		[self addSubview: imageView];
		[self addSubview: textView];
		[self addSubview: entryImageView];
		[self addSubview: doneBtn];
		[self addSubview: camButton];
	
		[imageView		setImage:			[[self resourcesImage:@"MessageEntryBackground.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22]];
		[entryImageView setImage:			[[self resourcesImage:@"MessageEntryInputField.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22]];
		[doneBtn		setBackgroundImage:	[[self resourcesImage:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0]	forState:UIControlStateNormal];
		[doneBtn		setBackgroundImage:	[[self resourcesImage:@"MessageEntrySendButton.png"]	stretchableImageWithLeftCapWidth:13	topCapHeight:0]	forState:UIControlStateSelected];
		[camButton		setBackgroundImage:	 [self resourcesImage:@"cameraButtonN.png"]																forState:UIControlStateNormal];
		[camButton		setBackgroundImage:	 [self resourcesImage:@"cameraButtonP.png"]																forState:UIControlStateSelected];

	}

	CGFloat w = CGRectGetWidth(self.superview.frame);
	CGFloat h = (float)CGRectGetHeight(self.superview.frame) - bottom;
	CGFloat height = 40;
		
	[self				setFrame: CGRectMake(0, h - height, w, height)];
	[imageView			setFrame: CGRectMake(0, 0, w, height)];
	[textView			setFrame: CGRectMake(6, 3, w - 80, height)];
	[entryImageView		setFrame: CGRectMake(5, 0, w-72, height)];
	[doneBtn			setFrame: CGRectMake(w - 69, 8, 63, 27)];

	if(self.hasCam) {
		[textView		setFrame: CGRectMake(41, 3, w - 116, height)];
		[entryImageView	setFrame: CGRectMake(40, 0, w-107, height)];
		[camButton		setFrame: CGRectMake(5, 7, 30, 30)];
	}
	[[self doneBtn].titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [textView layoutSubviews];
}

-(void)setCamera:(BOOL)val
{
	self.hasCam = val;
}

-(void)disableDoneButon:(BOOL)arg
{
	if(arg == NO || !arg)
		[[self doneBtn] setEnabled:YES];
	if(arg == YES)
		[[self doneBtn] setEnabled:NO];
}

-(void)disableCamButon:(BOOL)arg
{
	if(arg == NO || !arg)
		[[self camButton] setEnabled:YES];
	if(arg == YES)
		[[self camButton] setEnabled:NO];
	
}

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

-(void)doneButtonPressed
{
	if ([delegate respondsToSelector:@selector(textViewSendButtonPressed:)]) {
		[delegate textViewSendButtonPressed:[self textView].text];
	}	
	
}

-(void)camButtonPressed
{
	if ([delegate respondsToSelector:@selector(textViewCamButtonPressed:)]) {
		[delegate textViewCamButtonPressed:[self textView].text];
	}	

}

-(void)becomeTextView
{
	if ([delegate respondsToSelector:@selector(textViewFocus)]) {
		[delegate textViewFocus];
	}	
	[[self textView] becomeFirstResponder];
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
	[self becomeTextView];
}

-(void)resignTextView
{
	if ([delegate respondsToSelector:@selector(textViewBlur)]) {
		[delegate textViewBlur];
	}	
	[[self textView ] resignFirstResponder];
}

-(void)emptyTextView
{
	[[self textView] setText:@""];
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
	self.text = [self textView].text;
	if([delegate respondsToSelector:@selector(textViewTextChange:)])
	{
		[delegate textViewTextChange:self.text];
	}
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
	float diff = (self.frame.size.height - height);
	
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
	if ([delegate respondsToSelector:@selector(heightOfTextViewDidChange:)]) {
		[delegate heightOfTextViewDidChange:diff];
	}	
}


@end
