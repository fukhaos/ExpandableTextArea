//
//  ScrollView.h
//  chat
//
//  Created by Pedro Enrique on 8/12/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import <UIKit/UIKit.h>
#import "PESMSLabel.h"
#import "PESMSTextLabel.h"
#import "TiUIView.h"


@interface PESMSScrollView : UIScrollView {
	NSMutableArray* allMessages;
	NSMutableDictionary* tempDict;
}

@property(nonatomic) CGRect labelsPosition;

@property(nonatomic)BOOL animated;
@property(nonatomic)int numberOfMessage;
@property(nonatomic, assign)NSString *sColor;
@property(nonatomic, assign)NSString *rColor;
@property(nonatomic, assign)NSString *selectedColor;
@property(nonatomic, assign)NSString *folder;
@property(nonatomic, assign)NSNumber *backgroundLeftCap;
@property(nonatomic, assign)NSNumber *backgroundTopCap;

@property(nonatomic,readonly)NSArray* allMessages;

-(void)sendMessage:(NSString *)text;
-(void)recieveMessage:(NSString *)text;
-(void)addLabel:(NSString *)msg;
-(void)sendImageView:(TiUIView *)view;
-(void)recieveImageView:(TiUIView *)view;
-(void)sendImage:(UIImage *)image;
-(void)recieveImage:(UIImage *)image;
-(void)reloadContentSize;
-(void)backgroundColor:(UIColor *)col;
-(void)sendColor:(NSString *)col;
-(void)recieveColor:(NSString *)col;
-(void)animate:(BOOL)arg;
-(void)selectedColor:(NSString *)col;
-(void)empty;

@end
