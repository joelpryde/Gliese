//
//  GLTextView.h
//  gliese
//
//  Created by Joel Pryde on 3/19/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIResponder(UIResponderInsertTextAdditions)
- (void) insertText: (NSString*) text;
@end

@interface GLBarButtonItem : UIBarButtonItem
{
    NSString* _insertText;
}
@property (assign) NSString* insertText;
-(id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action text:(NSString*)text;
-(id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
-(id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
@end

@class GLTextView;

@interface GLChildView : UIView 
{
    GLTextView* _parentView;
}
-(id)initWithFrame:(CGRect)frame parentView:(GLTextView*)parentView;
@end

@interface GLTextView : UITextView
{    
    UILabel* _errorLabel;
    int _lineErrorNumber;
}

@property (readonly) int lineErrorNumber;
-(void)setError:(NSString*)error;
-(NSRange)rangeForLine:(bool)next;

@end