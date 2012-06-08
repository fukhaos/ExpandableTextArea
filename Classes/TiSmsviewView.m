//
//  PecTfTextField.m
//  textfield
//
//  Created by Pedro Enrique on 7/3/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import "TiSmsviewView.h"
#import "TiBase.h"
#import "TiUtils.h"
#import "TiHost.h"

@implementation TiSmsviewView

-(void)dealloc
{
    RELEASE_TO_NIL(textColor);
    RELEASE_TO_NIL(sendColor);
    RELEASE_TO_NIL(recieveColor);
    RELEASE_TO_NIL(selectedColor);
    RELEASE_TO_NIL(backgroundTopCap);
    RELEASE_TO_NIL(backgroundLeftCap);
    RELEASE_TO_NIL(folder);
    RELEASE_TO_NIL(buttonTitle);
    RELEASE_TO_NIL(font);
    RELEASE_TO_NIL(scrollView);
    RELEASE_TO_NIL(textArea);

	[[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
	
	[super dealloc];
}

-(id)init
{
    if(self = [super init])
	{
		firstTime = YES;
		autocorrect = YES;
		beditable = YES;
		hasCam = NO;
		shouldAnimate = YES;
		sendDisabled = NO;
		camDisabled = NO;
		hasTabbar = NO;
		bottomOfWin = 0.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];	

	}
	return self;
}

#pragma mark UI Elements

-(PESMSTextArea *)textArea 
{
	if(!textArea){
		textArea = [[PESMSTextArea alloc] initWithFrame:self.frame];
        [textArea becomeTextView];
		textArea.delegate = self;
	}
	return textArea;
}

-(PESMSScrollView *)scrollView
{
	if(!scrollView)
	{
		CGFloat h = CGRectGetHeight(self.frame);
		CGRect a = self.frame;
		a.size.height = h - 40;
		a.origin.y = 0;
		scrollView = [[PESMSScrollView alloc] initWithFrame:a];
		clickGestureRecognizer = [[UITapGestureRecognizer alloc]
														  initWithTarget:self 
                                  action:@selector(handleClick:)];
		clickGestureRecognizer.numberOfTapsRequired = 1; 
		[scrollView addGestureRecognizer:clickGestureRecognizer];
        [clickGestureRecognizer release];
	}
	return scrollView;
}

#pragma mark Keyboard stuff

-(void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary* userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardFrameBegin = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL portrait = orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown;
    
    CGRect textareaFrame = [self textArea].frame, scrollViewFrame = [self scrollView].frame;

    // APPEARS FROM BOTTOM TO TOP
    if (portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) { 
        textareaFrame.origin.y = self.frame.size.height - textareaFrame.size.height - keyboardFrameEnd.size.height;
        scrollViewFrame.size.height = textareaFrame.origin.y;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:duration];
        
        [self textArea].frame = textareaFrame;
        [self scrollView].frame = scrollViewFrame;
        
        [UIView commitAnimations];
        [[self scrollView] reloadContentSize];
    }
    else if (!portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) { 
        textareaFrame.origin.x = 0.0f;
        textareaFrame.origin.y = self.frame.size.height - keyboardFrameEnd.size.width - textareaFrame.size.height;

        scrollViewFrame.origin.x = 0.0f;
        scrollViewFrame.size.height = textareaFrame.origin.y;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:duration];
        
        [self textArea].frame = textareaFrame;
        [self scrollView].frame = scrollViewFrame;
        
        [UIView commitAnimations];
        [[self scrollView] reloadContentSize];
    }
    // APPEARS FROM RIGHT TO RIGHT (NAVIGATION CONTROLLER, OPENING WINDOW)
    else if (portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) { 
        textareaFrame.origin.x = keyboardFrameEnd.origin.x;
        textareaFrame.origin.y = self.frame.size.height - keyboardFrameEnd.size.height - textareaFrame.size.height;        
        scrollViewFrame.size.height = textareaFrame.origin.y;
        
        [self textArea].frame = textareaFrame;
        [self scrollView].frame = scrollViewFrame;
    }
    else if (!portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) { 
        textareaFrame.origin.x = 0.0f;
        textareaFrame.origin.y = self.frame.size.height - keyboardFrameEnd.size.width - textareaFrame.size.height;        

        scrollViewFrame.origin.x = 0.0f;
        scrollViewFrame.size.height = textareaFrame.origin.y;
        
        [self textArea].frame = textareaFrame;
        [self scrollView].frame = scrollViewFrame;
    }
    bottomOfWin = portrait ? keyboardFrameEnd.size.height : keyboardFrameEnd.size.width;
}

-(void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary* userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardFrameBegin = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL portrait = orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown;
    
    CGRect textareaFrame = [self textArea].frame, scrollViewFrame = [self scrollView].frame;
    
    // DISAPPEARS TOP TO BOTTOM
    if (
        (portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) ||
        (!portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y)
        ) 
    { 
        textareaFrame.origin.y = self.frame.size.height - textareaFrame.size.height;
        
        scrollViewFrame.size.height = self.frame.size.height - textareaFrame.size.height;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:duration];
        
        [self textArea].frame = textareaFrame;
        [self scrollView].frame = scrollViewFrame;
        
        [UIView commitAnimations];
    }
    // DISAPPEARS FROM LEFT TO RIGHT (NAVIGATION CONTROLLER, CLOSING WINDOW)
    else if (
             (portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) ||
             (!portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x)
             ) 
    { 
    }
	bottomOfWin = 0.0;
}

-(void)heightOfTextViewDidChange:(float)height
{
	CGRect scrollViewFrame = [self scrollView].frame;	
	scrollViewFrame.size.height +=height;
	[[self scrollView]setFrame: scrollViewFrame];
	[[self scrollView] reloadContentSize];
}

#pragma mark methods to be used in Javascript

-(void)_blur
{
	[[[self textArea] textView] performSelectorOnMainThread:@selector(resignFirstResponder) withObject:nil waitUntilDone:YES];
}
-(void)_focus
{
	[[[self textArea] textView] performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:YES];
}

-(void)sendImage:(UIImage *)image
{
	ENSURE_UI_THREAD(sendImage, image);
	[[self scrollView] sendImage:image];
	[[self scrollView] reloadContentSize];
}
-(void)recieveImage:(UIImage *)image
{
	ENSURE_UI_THREAD(recieveImage, image);
	[[self scrollView] recieveImage:image];
	[[self scrollView] reloadContentSize];
}

-(void)sendImageView:(TiUIView *)view
{
	ENSURE_UI_THREAD(sendImageView, view);
	[[self scrollView] sendImageView:view];
	[[self scrollView] reloadContentSize];
}
-(void)recieveImageView:(TiUIView *)view
{
	ENSURE_UI_THREAD(recieveImageView, view);
    
	[[self scrollView] recieveImageView:view];
	[[self scrollView] reloadContentSize];
}

-(void)sendMessage:(NSString *)msg
{
	ENSURE_UI_THREAD(sendMessage,msg);

	if([msg isEqualToString:@""])
		return;
	[[self scrollView] sendMessage:msg];
	[[self scrollView] reloadContentSize];
}

-(void)recieveMessage:(NSString *)msg
{
	ENSURE_UI_THREAD(recieveMessage, msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] recieveMessage:msg];
	[[self scrollView] reloadContentSize];
}

-(void)addLabel:(NSString *)msg
{
	ENSURE_UI_THREAD(addLabel,msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] animate:NO];	
	[[self scrollView] addLabel:msg];
	[[self scrollView] reloadContentSize];
	[[self scrollView] animate:shouldAnimate];	
}

-(void)empty
{
	[[self scrollView] empty];
}

-(NSArray *)getMessages
{
	return [self scrollView].allMessages;
}

#pragma mark Event listeners

-(void)textViewCamButtonPressed:(NSString *)text
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	[tiEvent setObject:text forKey:@"value"];
	[self.proxy fireEvent:@"camButtonClicked" withObject:tiEvent];
}

-(void)textViewSendButtonPressed:(NSString *)text
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	[tiEvent setObject:text forKey:@"value"];
	[self.proxy fireEvent:@"buttonClicked" withObject:tiEvent];
	[[self textArea] emptyTextView];
	[[self scrollView] reloadContentSize];
}
-(void)textViewTextChange:(NSString *)text
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	[tiEvent setObject:text forKey:@"value"];
	[self.proxy fireEvent:@"change" withObject:tiEvent];
}

-(void)handleClick:(UITapGestureRecognizer*)recognizer
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];

	id view = recognizer.view;
	CGPoint loc = [recognizer locationInView:view];
	id subview = [view hitTest:loc withEvent:nil];
	NSString *where;
	if([subview isKindOfClass: [PESMSLabel class]])
	{
		PESMSLabel * a = subview;
		where = @"message";
		if(a.isText)
			[tiEvent setObject:a.textValue forKey:@"text"];
		if(a.isImage)
		{
			TiBlob *blob = [[[TiBlob alloc] initWithImage:a.imageValue] autorelease];
			[tiEvent setObject:blob forKey:@"image"];

		}
		if(a.isView)
			[tiEvent setObject:a.prox forKey:@"view"];
		[tiEvent setObject:[NSString stringWithFormat:@"%i",a.index_] forKey:@"index"];
	} 
    else {
		where = @"scrollView";
		[tiEvent setObject:@"scrollView" forKey:@"scrollView"];
	}
	[tiEvent setObject:where forKey:@"where"];
	[self.proxy fireEvent:@"click" withObject:tiEvent];
	[self.proxy fireEvent:@"messageClicked" withObject:tiEvent];
	
}


-(void)label:(NSSet *)touches withEvent:(UIEvent *)event :(UIImage *)image :(NSString *)text :(TiProxy *)view
{
	
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	
    if(text) {
		[tiEvent setObject:text forKey:@"text"];
    }

	if(image) {
		TiBlob *blob = [[[TiBlob alloc] initWithImage:image] autorelease];
		[tiEvent setObject:blob forKey:@"image"];
	}

	if(view) {
		[tiEvent setObject:view forKey:@"view"];
	}

	[self.proxy fireEvent:@"messageClicked" withObject:tiEvent];
}

-(void)changeHeightOfScrollView
{
	// Empty for now, we don't need this, it is completely useless for the JS app
}

#pragma mark Titanium's resize/init function

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:self positionRect:self.superview.bounds];

    CGRect a = self.frame;
    CGFloat h = CGRectGetHeight(self.frame);
	float meh = h - 40;
    a.size.height = meh;
	
	if (firstTime == YES) {
		firstTime = NO;
		
        [self addSubview: [self scrollView]];
		[self addSubview: [self textArea]];
        
		//if(![self.proxy valueForUndefinedKey:@"backgroundColor"])
        //self.backgroundColor = [[TiUtils colorValue:(id)@"#dae1eb"] _color];
		
		if (returnType)
            [[self textArea] textView].returnKeyType = returnType;
        
		if (font)
			[[self textArea] textView].font = font;
        
		if (textColor)
			[[self textArea] textView].textColor = textColor;
        
		if (textAlignment)
			[[self textArea] textView].textAlignment = textAlignment;
        
		if (folder) {
			[self textArea].folder = folder;
			[self scrollView].folder = folder;
		}
        
		if(buttonTitle)
			[[self textArea] buttonTitle:buttonTitle];
        
		[[self textArea] setCamera:hasCam];
		[[[self textArea] textView] setEditable:beditable];
		[[[self textArea] textView] setAutocorrectionType:autocorrect ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo];
		[[[self textArea] textView] setDataDetectorTypes:UIDataDetectorTypeAll];
		if(sendDisabled)
			[[self textArea] disableDoneButon:sendDisabled];
		if(camDisabled)	
			[[self textArea] disableCamButon:camDisabled];
			

	}

	[[self scrollView] setFrame:a];
	[[self scrollView] reloadContentSize];
	[[self textArea] resize:bottomOfWin];
}

#pragma mark Titanium's setters

-(void)setCamButton_:(id)args
{
	hasCam = [TiUtils boolValue:args];
	if(!firstTime) {
		[[self textArea] setCamera:hasCam];
		[[self textArea] resize:bottomOfWin];
	}
}	

-(void)setSendColor_:(id)col
{
    RELEASE_TO_NIL(sendColor);
    sendColor = [[TiUtils stringValue:col] retain];
    [[self scrollView] performSelectorOnMainThread:@selector(sendColor:) withObject:sendColor waitUntilDone:YES];
}

-(void)setRecieveColor_:(id)col
{
    RELEASE_TO_NIL(recieveColor);
    recieveColor = [[TiUtils stringValue:col] retain];
    [[self scrollView] performSelectorOnMainThread:@selector(recieveColor:) withObject:recieveColor waitUntilDone:YES];	
}

-(void)setSelectedColor_:(id)col
{
    RELEASE_TO_NIL(selectedColor);
    selectedColor = [[TiUtils stringValue:col] retain];
	[[self scrollView] performSelectorOnMainThread:@selector(selectedColor:) withObject:selectedColor waitUntilDone:YES];
}

-(void)setReturnKeyType_:(id)val
{
	returnType = [TiUtils intValue:val];
	if(!firstTime)
		[[[self textArea] textView] setReturnKeyType:returnType];
}

-(void)setButtonTitle_:(id)title
{
    RELEASE_TO_NIL(buttonTitle);
	buttonTitle = [[TiUtils stringValue:title] retain];
	if(!firstTime) {
		[[self textArea] buttonTitle:buttonTitle];
		[[self scrollView] reloadContentSize];
	}
}

-(void)setFont_:(id)val
{
    RELEASE_TO_NIL(font);
	font = [[[TiUtils fontValue:val def:nil] font] retain];
	if(!firstTime) {
		[[[self textArea] textView] setFont:font];
    }
}

-(void)setTextColor_:(id)val
{
    RELEASE_TO_NIL(textColor);
	textColor = [[[TiUtils colorValue:val] _color] retain];
	if(!firstTime) {
        [[[self textArea] textView] setTextColor:textColor];
    }
}

-(void)setTextAlignment_:(id)val
{
	textAlignment = [TiUtils textAlignmentValue:val];
	if(!firstTime)
		[[[self textArea] textView] setTextAlignment:textAlignment];
}

-(void)setAutocorrect_:(id)val
{
	autocorrect = [TiUtils boolValue:val];
	if(!firstTime)
		[[[self textArea] textView ]setAutocorrectionType:[TiUtils boolValue:val] ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo];
}

-(void)setEditable_:(id)val
{
	beditable = [TiUtils boolValue:val];
	if(!firstTime)
		[[[self textArea] textView] setEditable:beditable];
}

-(void)setAnimated_:(id)args
{
	shouldAnimate = [TiUtils boolValue:args];
	[[self scrollView] animate:shouldAnimate];
}

-(void)setFolder_:(id)args
{
    RELEASE_TO_NIL(folder);
	folder =  [[TiUtils stringValue:args] retain];
	if(!firstTime)
	{
		[[self textArea] setFolder:folder];
		[[self scrollView] setFolder:folder];
	}
}

-(void)setBackgroundLeftCap_:(id)args
{
    RELEASE_TO_NIL(backgroundLeftCap);
    backgroundLeftCap = [[TiUtils numberFromObject:args] retain];
    [self textArea].backgroundLeftCap = backgroundLeftCap;
    [self scrollView].backgroundLeftCap = backgroundLeftCap;
}

-(void)setBackgroundTopCap_:(id)args
{
    RELEASE_TO_NIL(backgroundTopCap);
    backgroundTopCap = [[TiUtils numberFromObject:args] retain];
    [self textArea].backgroundTopCap = backgroundTopCap;
    [self scrollView].backgroundTopCap = backgroundTopCap;
}
 
-(void)setReturnType_:(id)arg
{
	returnType = [TiUtils boolValue:arg];
	if(!firstTime)
		[[[self textArea] textView] setReturnKeyType:returnType];
}

-(void)setMaxLines_:(id)arg
{
    maxLines = [TiUtils intValue:arg];
	[[self textArea] setMaxLines:maxLines];	
}

-(void)setMinLines_:(id)arg
{
    minLines = [TiUtils intValue:arg];
	[[self textArea] setMinLines:minLines];
}

-(void)setSendButtonDisabled_:(id)arg
{
	sendDisabled = [TiUtils boolValue:arg];
	if(!firstTime)
	{
		[[self textArea] disableDoneButon:sendDisabled];
	}
}

-(void)setHasTab_:(id)args
{
	hasTabbar = [TiUtils boolValue:args];
}

-(void)setCamButtonDisabled_:(id)arg
{
	camDisabled = [TiUtils boolValue:arg];
	if(!firstTime)
	{
		[[self textArea] disableCamButon:camDisabled];
	}
}

@end
