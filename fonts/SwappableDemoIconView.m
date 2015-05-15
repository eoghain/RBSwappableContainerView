//
//  SwappableDemoIconView.m
//

#import "SwappableDemoIconView.h"
#import <CoreText/CoreText.h>

@implementation SwappableDemoIconView

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];

	CGFloat fontSize = MIN(rect.size.width, rect.size.height) / 2;

	CFStringRef string; CTFontRef font; CGContextRef context;
	// Initialize the string, font, and context
	string = (__bridge CFStringRef)self.icon;
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithNameAndSize((CFStringRef)@"SwappableDemo", fontSize);
	font = CTFontCreateWithFontDescriptor(fontDescriptor, fontSize, NULL);
	context = UIGraphicsGetCurrentContext();

	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
	CFTypeRef values[] = { font, self.fontColor.CGColor };

	CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
		(const void**)&values, sizeof(keys) / sizeof(keys[0]),
		&kCFTypeDictionaryKeyCallBacks,
		&kCFTypeDictionaryValueCallBacks);

	CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
	CFRelease(string);
	CFRelease(attributes);

	CTLineRef line = CTLineCreateWithAttributedString(attrString);

	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	CFRange range;
	CGSize constraint = rect.size;
	CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 1), nil, constraint, &range);

	// Set text position and draw the line into the graphics context
	CGContextSetTextPosition(context, (rect.size.width - coreTextSize.width) / 2, (rect.size.height - coreTextSize.height) / 2);
	CTLineDraw(line, context);
	CFRelease(line);
}

@end