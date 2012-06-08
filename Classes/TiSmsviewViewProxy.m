//
//  PecTfTextFieldProxy.m
//  textfield
//
//  Created by Pedro Enrique on 7/3/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

// modified by jordi domenech on 6/2012
// iamyellow.net jordi@iamyellow.net @iamyellow2 github.com/iamyellow

#import "TiSmsviewView.h"
#import "TiSmsviewViewProxy.h"
#import "TiUtils.h"
#import "UIImage+Resize.h"

@implementation TiSmsviewViewProxy

-(void)_destroy
{
	// This method is called from the dealloc method and is good place to
	// release any objects and memory that have been allocated for the view proxy.
	[super _destroy];
}

-(void)dealloc
{
	// This method is called when the view proxy is being deallocated. The superclass
	// method calls the _destroy method.

	[super dealloc];
}

-(TiSmsviewView *)ourView
{
	if(!ourView) {
		ourView = (TiSmsviewView *)[self view];
	}
	return ourView;
}

-(void)blur:(id)args
{
	ENSURE_UI_THREAD(blur, args);
	
	if([self viewAttached]) {
		[[self ourView] _blur];
	}
}

-(void)focus:(id)args
{
	ENSURE_UI_THREAD(focus, args);
	if([self viewAttached]) {
		[[self ourView] _focus];
	}
}


-(UIImage *)returnImage:(id)arg
{
	if([self viewAttached])
	{
		UIImage *image = nil;
		if ([arg isKindOfClass:[UIImage class]]) {
			image = (UIImage*)arg;
		}
		else if ([arg isKindOfClass:[TiBlob class]]) {
			TiBlob *blob = (TiBlob*)arg;
			image = [blob image];
			
		}
		else {
			NSLog(@"[WARN] The image MUST be a blob.");
			NSLog(@"[WARN]");
			NSLog(@"[WARN] This is a workaround:");
			NSLog(@"[WARN]");
			NSLog(@"[WARN] var img = Ti.UI.createImageView({image:'whatever.png'}).toImage();");
			NSLog(@"[WARN] xx.sendMessage(img);");
			NSLog(@"[WARN]      or");
			NSLog(@"[WARN] xx.recieveMessage(img);");
			NSLog(@"[WARN]");
		}
		
		if(image != nil) {
			CGSize imageSize = image.size;		
			if(imageSize.width > 270.0)//[[self ourView] superview].frame.size.width-100)
			{
				float x = 270.0;//([[self ourView] superview].frame.size.width-100);
				float y = ((x/imageSize.width)*imageSize.height);
				CGSize newSize = CGSizeMake(x, y);
				image = [UIImageResize resizedImage:newSize interpolationQuality:kCGInterpolationDefault image:image  hires:YES];
			}
			
		}		
		return image;
	}
	return nil;	
}

-(void)empty:(id)args
{
	ENSURE_UI_THREAD(empty, args);
	if([self viewAttached])
	{
		[ourView empty];
	}
}

-(void)sendMessage:(id)args
{
	if([self viewAttached])
	{
		id arg = [args objectAtIndex:0];
		if([arg isKindOfClass:[NSString class]]) {
			[[self ourView] sendMessage:arg];
        }
		else if ([arg isKindOfClass:[TiViewProxy class]]) {
			TiViewProxy *a = arg;
			[[self ourView] sendImageView:a.view];
		}
		else {
			[[self ourView] sendImage:[self returnImage:arg]];
        }
	}
}

-(void)recieveMessage:(id)args
{
	ENSURE_UI_THREAD(recieveMessage,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		
		id arg = [args objectAtIndex:0];
		
		if([arg isKindOfClass:[NSString class]]) {
			[[self ourView] recieveMessage:arg];
        }
		else if ([arg isKindOfClass:[TiViewProxy class]])
		{
			TiViewProxy *a = arg;
			[[self ourView] recieveImageView:a.view];
		}
		else {
			[[self ourView] recieveImage:[self returnImage:arg]];
        }
	}
}

-(void)addLabel:(id)args
{
	ENSURE_UI_THREAD(addLabel,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		id arg = [TiUtils stringValue: [args objectAtIndex:0]];
		if([arg isKindOfClass:[NSString class]]) {
			[[self ourView] addLabel:arg];
        }
	}
}

-(void)loadMessages:(id)args
{
	ENSURE_SINGLE_ARG(args,NSArray);
	if([self viewAttached])
	{
		for(int i = 0; i < [args count]; i++)
		{
			id obj = [args objectAtIndex:i];
			ENSURE_SINGLE_ARG(obj, NSObject);

			if([obj objectForKey:@"send"]) {
				[self sendMessage: [NSArray arrayWithObject:[obj objectForKey:@"send"]]];
			}
			if([obj objectForKey:@"recieve"]) {
				[self recieveMessage: [NSArray arrayWithObject:[obj objectForKey:@"recieve"]]];
			}
		}
	}
}

-(NSArray *)getAllMessages:(id)arg
{
	if([self viewAttached]) {
		return [[self ourView] getMessages];
	}
	return nil;
}

-(id)value
{
	if([self viewAttached]) {
		return [self ourView].value;
	}
	return nil;
}
@end
