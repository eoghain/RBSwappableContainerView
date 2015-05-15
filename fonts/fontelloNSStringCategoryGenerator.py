#!/usr/bin/env python
 
import sys
import json
import os

def pascalCase(str):
	str = str.replace('-', ' ')
	str = str.replace('_', ' ')
	components = str.split(' ')
	print components
	print "".join(x.title() for x in components[0:])
	return "".join(x.title() for x in components[0:])
	
def camelCase(str):
	str = str.replace('-', ' ')
	str = str.replace('_', ' ')
	components = str.split(' ')
	print components
	print components[0] + "".join(x.title() for x in components[1:])
	return components[0] + "".join(x.title() for x in components[1:])
 
def writeFile(fileName, contents):
	header = '//\n'
	header += '//  %s\n' % os.path.basename(fileName)
	header += '//\n\n'
 
	f = open(fileName, 'w')
	f.write(header)
	f.write(contents)
	f.close()
 
def createHFile(name, prefixText, glyphs):
	hFile = '#import <Foundation/Foundation.h>\n\n@interface NSString (%s)\n' % name
	srcName = ''
 
	for glyph in glyphs:
		if (srcName != glyph['src']):
			srcName = glyph['src']
			hFile += '\n// %s Strings\n' % srcName
 
		fontName = prefixText + glyph['css']
		hFile += '+ (NSString *)%s;\n' % camelCase(fontName)
 
	hFile += '\n@end'
	return hFile
 
def createMFile(name, prefixText, glyphs):
	mFile = '#import "%s"\n\n@implementation NSString (%s)\n\n' % (('NSString+%s.h' % name), name)
	srcName = ''
 
	for glyph in glyphs:
		if (srcName != glyph['src']):
			srcName = glyph['src']
			mFile += '\n#pragma mark - %s\n\n' % srcName
 
		fontName = prefixText + glyph['css']
		mFile += '+ (NSString *)%s\n' % camelCase(fontName)
		mFile += '{\n'
		mFile += '\treturn @"%s"; \n' % hex(glyph['code']).replace('0xe', '\uE')
		mFile += '}\n\n'
 
	mFile += '@end'
	return mFile
 
def createIconViewH(name):
	className = "%sIconView" % name
	hFile =  "#import <UIKit/UIKit.h>\n\n"
	hFile += "IB_DESIGNABLE\n"
	hFile += "@interface %s : UIView\n\n" % className
	hFile += "@property (strong, nonatomic) IBInspectable NSString * icon;\n"
	hFile += "@property (strong, nonatomic) IBInspectable UIColor * fontColor;\n\n"
	hFile += "@end"
	return hFile;
    
def createIconViewM(name):
	className = "%sIconView" % name
	mFile = "#import \"%s.h\"\n" % className
	mFile += "#import <CoreText/CoreText.h>\n\n"
	mFile += "@implementation %s\n\n" % className
	mFile += "- (void)drawRect:(CGRect)rect\n"
	mFile += "{\n"
	mFile += "\t[super drawRect:rect];\n\n"
	mFile += "\tCGFloat fontSize = MIN(rect.size.width, rect.size.height) / 2;\n\n"
	mFile += "\tCFStringRef string; CTFontRef font; CGContextRef context;\n"
	mFile += "\t// Initialize the string, font, and context\n"
	mFile += "\tstring = (__bridge CFStringRef)self.icon;\n"
	mFile += "\tCTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithNameAndSize((CFStringRef)@\"%s\", fontSize);\n" % name
	mFile += "\tfont = CTFontCreateWithFontDescriptor(fontDescriptor, fontSize, NULL);\n"
	mFile += "\tcontext = UIGraphicsGetCurrentContext();\n\n"
	mFile += "\tCGContextSetTextMatrix(context, CGAffineTransformIdentity);\n";
	mFile += "\tCGContextTranslateCTM(context, 0, self.bounds.size.height);\n";
	mFile += "\tCGContextScaleCTM(context, 1.0, -1.0);\n\n";
	mFile += "\tCFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };\n"
	mFile += "\tCFTypeRef values[] = { font, self.fontColor.CGColor };\n\n"
	mFile += "\tCFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,\n"
	mFile += "\t\t(const void**)&values, sizeof(keys) / sizeof(keys[0]),\n"
	mFile += "\t\t&kCFTypeDictionaryKeyCallBacks,\n";
	mFile += "\t\t&kCFTypeDictionaryValueCallBacks);\n\n"
	mFile += "\tCFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);\n"
	mFile += "\tCFRelease(string);\n"
	mFile += "\tCFRelease(attributes);\n\n"
	mFile += "\tCTLineRef line = CTLineCreateWithAttributedString(attrString);\n\n"
	mFile += "\tCTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);\n"
	mFile += "\tCFRange range;\n"
	mFile += "\tCGSize constraint = rect.size;\n"
	mFile += "\tCGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 1), nil, constraint, &range);\n\n"
	mFile += "\t// Set text position and draw the line into the graphics context\n"
	mFile += "\tCGContextSetTextPosition(context, (rect.size.width - coreTextSize.width) / 2, (rect.size.height - coreTextSize.height) / 2);\n"
	mFile += "\tCTLineDraw(line, context);\n"
	mFile += "\tCFRelease(line);\n"
	mFile += "}\n\n"
	mFile += "@end"
	return mFile;
 
def main(configFile, outputDir):
	json_data=open(configFile)
	data = json.load(json_data)
 
	name = pascalCase(data['name'])
	glyphs = sorted(data['glyphs'], key=lambda k: k['css']) # sort by name
	glyphs = sorted(glyphs, key=lambda k: k['src']) #sort by name
	prefixText = data['css_prefix_text']
 
	outputFileName = outputDir + ('NSString+%s.h' % name)
	writeFile(outputFileName, createHFile(name, prefixText, glyphs))
 
	outputFileName = outputDir + ('NSString+%s.m' % name)
	writeFile(outputFileName, createMFile(name, prefixText, glyphs))
	
	outputFileName = outputDir + ('%sIconView.h' % name)
	writeFile(outputFileName, createIconViewH(name))
 
	outputFileName = outputDir + ('%sIconView.m' % name)
	writeFile(outputFileName, createIconViewM(name))
 
def usage(fileName):
	print 'usage: %s config.json <output directory>' % fileName
 
 
if __name__ == '__main__':
	if (len(sys.argv) < 2):
		usage(sys.argv[0])
		exit(1)
 
	outputDir = ''
	if (len(sys.argv) > 2):
		outputDir = sys.argv[2] + '/'
 
	main(sys.argv[1], outputDir)