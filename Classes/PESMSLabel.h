//
//  Label.h
//  chat
//
//  Created by Pedro Enrique on 8/13/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import <UIKit/UIKit.h>
#import "TiUIView.h"
#import "TiProxy.h"

@interface PESMSLabel : UIImageView<UIGestureRecognizerDelegate>
{
	UILabel *label;
	UIImageView *innerImage;
	UILongPressGestureRecognizer *hold;

    NSString* textValue;
    UIImage* imageValue;
	UIView* innerView;
    TiProxy* prox;
    
    NSString* thisColor;
    int thisPos; // 0: left, 1: center, 2:right
    
    BOOL isImage;
    BOOL isText;
    BOOL isView;
    int index_;
    UIDeviceOrientation orient;
}

@property(nonatomic, readonly) BOOL isImage;
@property(nonatomic, readonly) BOOL isText;
@property(nonatomic, readonly) BOOL isView;
@property(nonatomic, readonly) NSString* textValue;
@property(nonatomic, readonly) UIImage* imageValue;
@property(nonatomic, readonly) TiProxy* prox;
@property(nonatomic, assign) int index_;

@property(nonatomic, assign)NSString *sColor;
@property(nonatomic, assign)NSString *rColor;
@property(nonatomic, assign)NSString *selectedColor;
@property(nonatomic, assign)NSString *folder;
@property(nonatomic, assign)NSNumber *backgroundLeftCap;
@property(nonatomic, assign)NSNumber *backgroundTopCap;

-(void)addImage:(UIImage *)image;
-(void)addText:(NSString *)text;
-(void)position:(NSString *)pos:(NSString *)color:(NSString *)selCol;
-(void)addImageView:(TiUIView *)view;

@end
