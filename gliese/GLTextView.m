//
//  GLTextView.m
//  gliese
//
//  Created by Joel Pryde on 3/19/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import "GLTextView.h"
#import "ShaderManager.h"

#define LIFE_OFFSET 10

@implementation UIResponder(UIResponderInsertTextAdditions)

- (void)insertText:(NSString*)text
{
	// Get a refererence to the system pasteboard because that's
	// the only one @selector(paste:) will use.
	UIPasteboard* generalPasteboard = [UIPasteboard generalPasteboard];
	
	// Save a copy of the system pasteboard's items
	// so we can restore them later.
	NSArray* items = [generalPasteboard.items copy];
	
	// Set the contents of the system pasteboard
	// to the text we wish to insert.
	generalPasteboard.string = text;
	
	// Tell this responder to paste the contents of the
	// system pasteboard at the current cursor location.
	[self paste: self];
	
	// Restore the system pasteboard to its original items.
	generalPasteboard.items = items;
	
	// Free the items array we copied earlier.
	[items release];
}
@end

@implementation GLBarButtonItem
@synthesize insertText = _insertText;

-(id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action text:(NSString*)text
{
    _insertText = text;
    self.width = 59.0;
    [super initWithTitle:title style:style target:target action:action];
    return self;
}

-(id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    self.width = 59.0;
    [super initWithTitle:title style:style target:target action:action];
    return self;
}

-(id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    self.width = 59.0;
    [super initWithImage:image style:style target:target action:action];
    return self;
}
@end

@implementation GLChildView

-(id)initWithFrame:(CGRect)frame parentView:(GLTextView*)parentView
{
    [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _parentView = parentView;
    self.opaque = false;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = false;
    return  self;
}

- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
    
    //Get the current drawing context   
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    
    //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
    NSUInteger numberOfLines = (_parentView.contentSize.height + _parentView.bounds.size.height) / _parentView.font.leading;
    
    //Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
    CGFloat baselineOffset = 6.0f;
    
    //iterate over numberOfLines and draw each line
    for (int x = 0; x < numberOfLines; x++) 
    {
        //Set the line color and width
        if (x == _parentView.lineErrorNumber)
        {
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f].CGColor);
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor);
        }
        
        CGContextSetLineWidth(context, 1.0f);
        //Start a new Path
        CGContextBeginPath(context);
        
        //0.5f offset lines up line with pixel boundary
        CGContextMoveToPoint(context, _parentView.bounds.origin.x, _parentView.font.leading*x + 0.5f + baselineOffset);
        CGContextAddLineToPoint(context, _parentView.bounds.size.width, _parentView.font.leading*x + 0.5f + baselineOffset);
        
        //Close our Path and Stroke (draw) it
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
}

@end

@implementation GLTextView

@synthesize lineErrorNumber = _lineErrorNumber;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) 
    {   
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        [self setTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
        [self setEditable:YES];
        [self setFont:[UIFont systemFontOfSize:20]];
                
        // create accessory view
        NSMutableArray* buttonArray = [[NSMutableArray alloc] init];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@"(" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@"("] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@")" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@")"] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@";" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@";"] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@"*" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@"*"] autorelease]];
        
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@"/" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@"/"] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@"+"] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStyleBordered target:self action:@selector(insertCallback:) text:@"-"] autorelease]];
        
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_up_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(moveUp)] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_down_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(moveDown)] autorelease]];
                
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(moveLeft)] autorelease]];
        [buttonArray addObject:[[[GLBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_right_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(moveRight)] autorelease]];

        
        UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 768, 44)] autorelease];
        toolbar.items = buttonArray;
        self.inputAccessoryView = toolbar;
        
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200.0, self.font.leading)];
        [_errorLabel setBackgroundColor:[UIColor redColor]];
        [_errorLabel setTextColor:[UIColor whiteColor]];
        _errorLabel.hidden = true;
        [self addSubview:_errorLabel];
        
        _lineErrorNumber = -1;
        
    }
    return self;
}

-(void)insertCallback:(UIBarButtonItem*)barButton
{
    GLBarButtonItem* glButton = (GLBarButtonItem*)barButton;
    NSLog(@"%@", glButton.insertText);
    [self insertText:glButton.insertText];
}

-(void)moveLeft
{
    [self setSelectedRange:NSMakeRange(self.selectedRange.location-1, 0)];
}

-(void)moveRight
{
    [self setSelectedRange:NSMakeRange(self.selectedRange.location+1, 0)];
}

-(void)moveDown
{
    [self setSelectedRange:[self rangeForLine:true]];
}

-(void)moveUp
{
    [self setSelectedRange:[self rangeForLine:false]];
}

-(NSRange)rangeForLine:(bool)next
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    [self.text enumerateSubstringsInRange:NSMakeRange(0, self.text.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         NSValue *value = [NSValue valueWithRange:substringRange];
         [tmpArray addObject:value];
     }
     ];
 
    
    for (int i=0; i < [tmpArray count]; i++)
    {
        NSValue* line = [tmpArray objectAtIndex:i];
        NSRange range = [line rangeValue];
        NSRange currentRange = self.selectedRange;
        
        if (currentRange.location == range.location || (currentRange.location > range.location && currentRange.location <= (range.location + range.length)))
        {
            NSRange nextLineRange;
            if (next)
            {
                // next line
                if (i+1 >= [tmpArray count]) return self.selectedRange;
                nextLineRange = [[tmpArray objectAtIndex:i+1] rangeValue];
            }
            else
            {
                // previous line
                if (i-1 < 0) return self.selectedRange;
                nextLineRange = [[tmpArray objectAtIndex:i-1] rangeValue];
            }
            int currentLength = (int)(currentRange.location - range.location);
            int nextLineCursor = (int)(MIN(nextLineRange.location + nextLineRange.length, nextLineRange.location + currentLength));
            return NSMakeRange(nextLineCursor, 0);
        }
    }
    
    return self.selectedRange;
}

/*
-(NSRange)rangeForLine:(int)targetLine
{
    NSRange range;
    NSString* exampleString = @"Hello there\nHow is it going?\nAre you looking for a new line?\nA new line in what?\nThat remains to be seen";
    NSArray* separateLines = [exampleString componentsSeparatedByString:@"\n"];
    
    if (targetLine < [separateLines count])
    {
        int count = 0;
        for (int i=0; i<targetLine; i++)
        {
            count = count + [[separateLines objectAtIndex:i] length] + 1; // add 1 to compensate \n separator
        }
        
        range = NSMakeRange(count, 0);
    }
    else
    {
        range = NSMakeRange([exampleString length], 0); // set to the very end if targetLine is > number of lines
    }
}*/

-(int)lineToActualLine:(int)line
{
    NSArray* separateLines = [self.text componentsSeparatedByString:@"\n"];
    if (line < [separateLines count])
    {
        int count = 0;
        for (int i=0; i<line; i++)
        {
            CGSize stringSize = [[separateLines objectAtIndex:i] sizeWithFont:self.font constrainedToSize:self.frame.size lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
            if (stringSize.height == 0)
                count += 1;
            else 
            {
                float leading = self.font.leading;
                count += (stringSize.height / leading);
            }
        }
        
        return count-LIFE_OFFSET;
    }
    return line-LIFE_OFFSET;
}

-(void)setError:(NSString*)error
{
    if (error != nil)
    {
        NSLog(@"%@", error);
        
        // parse out line number
        NSRange range = [error rangeOfString:@"ERROR:"];
        if (range.location == NSNotFound) return;
        NSString *subError = [[error substringFromIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (subError != nil)
        {
            NSArray *partsArray = [subError componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
            NSLog(@"%@", partsArray);
            if (partsArray.count > 2)
            {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                NSNumber* number = [f numberFromString:[partsArray objectAtIndex:2]];
                if (number != nil)
                {
                    _lineErrorNumber = [self lineToActualLine:[number intValue]];
                    
                    // get the amount of text to that line
                    _errorLabel.frame = CGRectMake(0, self.font.leading*_lineErrorNumber + 0.5f + 6.0, [subError sizeWithFont:self.font].width, _errorLabel.frame.size.height);
                    _errorLabel.text = subError;
                    _errorLabel.hidden = false;
                }
                [f release];
            }
        }
    }
    else
    {
        _lineErrorNumber = -1;
        _errorLabel.hidden = true;
    }
}

@end
