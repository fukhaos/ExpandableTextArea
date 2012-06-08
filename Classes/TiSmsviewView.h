//
//  PecTfTextField.h
//  textfield
//
//  Created by Pedro Enrique on 7/3/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import "TiUIView.h"
#import "PESMSTextArea.h"
#import "PESMSScrollView.h"


@interface TiSmsviewView : TiUIView<PESMSTextAreaDelegate> {
	PESMSTextArea *textArea;
	PESMSScrollView *scrollView;
	UITapGestureRecognizer* clickGestureRecognizer;
    NSString *folder;
    NSString *buttonTitle;
    UIReturnKeyType returnType;
    UIFont* font;
    UIColor* textColor;
    NSString* sendColor;
    NSString* recieveColor;
    NSString* selectedColor;
    NSNumber* backgroundTopCap;
    NSNumber* backgroundLeftCap;
    
    UITextAlignment textAlignment;
	BOOL deallocOnce;
    BOOL firstTime;
    BOOL hasCam;
    BOOL autocorrect;
    BOOL beditable;
    BOOL shouldAnimate;
    BOOL sendDisabled;
    BOOL camDisabled;
    BOOL hasTabbar;
    int maxLines, minLines;
    float bottomOfWin;
}

-(void)sendImageView:(TiUIView *)view;
-(void)recieveImageView:(TiUIView *)view;
-(void)sendImage:(UIImage *)image;
-(void)recieveImage:(UIImage *)image;
-(void)sendMessage:(NSString *)msg;
-(void)recieveMessage:(NSString *)msg;
-(void)addLabel:(NSString *)msg;
-(void)_blur;
-(void)_focus;
-(void)empty;
-(NSArray *)getMessages;

@end
