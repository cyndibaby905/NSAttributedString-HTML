//
//  CHViewController.m
//  NSAttributedString+HTML
//
//  Created by HangChen on 12/23/13.
//  Copyright (c) 2013 HangChen. All rights reserved.
//

#import "NSAttributedString+HTML.h"
#import <objc/runtime.h>
#import <libxml/HTMLparser.h>
#import <CoreText/CoreText.h>
#define kFontStaits @"kFontStaits"

@implementation NSAttributedString (CHHTML)
+(NSAttributedString*)attributedStringWithHTML:(NSString*)html
{
    CHHTMLParser* parser=[[CHHTMLParser alloc] init];
	return [parser parse:html];
}
@end

@implementation CHHTMLParser
{
	htmlSAXHandler m_handler;
	NSMutableAttributedString* m_attributedString;
	NSMutableArray* m_style;
	CTParagraphStyleSetting m_paragraph[kCTParagraphStyleSpecifierCount];
}

-(id)init
{
	if ((self=[super init])!=nil)
	{
		xmlSAX2InitHtmlDefaultSAXHandler(&m_handler);
		
		struct callbacks
		{
			static void startElement(CHHTMLParser* parser, const xmlChar* name,const xmlChar** atts)
			{
				[parser->m_style addObject:[NSMutableDictionary dictionaryWithDictionary:parser->m_style.lastObject]];
				[parser->m_style.lastObject removeObjectsForKeys:@[@"width",@"height"]];
				
				if (xmlStrcasecmp(name,BAD_CAST"u")==0)
				{
					[parser->m_style.lastObject setValue:@(kCTUnderlineStyleSingle) forKey:(id)kCTUnderlineStyleAttributeName];
				}
				else if (xmlStrcasecmp(name,BAD_CAST"s")==0)
				{
					[parser->m_style.lastObject setValue:@(3.0f) forKey:(id)kCTStrokeWidthAttributeName];
				}
				else if (xmlStrcasecmp(name,BAD_CAST"a")==0)
				{
					[parser->m_style.lastObject setValue:(id)[UIColor blueColor].CGColor forKey:(id)kCTForegroundColorAttributeName];
					[parser->m_style.lastObject setValue:@(kCTUnderlineStyleSingle) forKey:(id)kCTUnderlineStyleAttributeName];
				}
				
				if (atts)
				{
					for (const xmlChar* key;(key=*atts++);)
					{
						const xmlChar* value=*atts++;
						if (xmlStrcasecmp(key,BAD_CAST"color")==0)
						{
							uint8_t r,g,b;
							CGFloat a=1.0f;
							if (sscanf((const char*)value, "#%2hhx%2hhx%2hhx",&r,&g,&b)==3 || sscanf((const char*)value, "rgb(%hhu,%hhu,%hhu)",&r,&g,&b)==3 || sscanf((const char*)value, "rgba(%hhu,%hhu,%hhu,%f)",&r,&g,&b,&a)==4)
							{
								UIColor* color=[UIColor colorWithRed:((CGFloat)r)/255.0f green:((CGFloat)g)/255.0f blue:((CGFloat)b)/255.0f alpha:a];
								if (xmlStrcasecmp(name,BAD_CAST"s")==0)
								{
									[parser->m_style.lastObject setValue:(id)color.CGColor forKey:(id)kCTStrokeColorAttributeName];
								}
								else
								{
									[parser->m_style.lastObject setValue:(id)color.CGColor forKey:(id)kCTForegroundColorAttributeName];
								}
							}
						}
						else if (xmlStrcasecmp(key,BAD_CAST"size")==0)
						{
							[parser->m_style.lastObject setValue:@(strtod((const char*)value, NULL)) forKey:@"size"];
						}
						else if (xmlStrcasecmp(key,BAD_CAST"style")==0 && xmlStrcasecmp(name,BAD_CAST"u")==0)
						{
							if (xmlStrcasecmp(value,BAD_CAST"none")==0)
							{
								[parser->m_style.lastObject setValue:@(kCTUnderlineStyleNone) forKey:(id)kCTUnderlineStyleAttributeName];
							}
							else if (xmlStrcasecmp(value,BAD_CAST"thick")==0)
							{
								[parser->m_style.lastObject setValue:@(kCTUnderlineStyleThick) forKey:(id)kCTUnderlineStyleAttributeName];
							}
							else if (xmlStrcasecmp(value,BAD_CAST"double")==0)
							{
								[parser->m_style.lastObject setValue:@(kCTUnderlineStyleDouble) forKey:(id)kCTUnderlineStyleAttributeName];
							}
						}
						else if (xmlStrcasecmp(key,BAD_CAST"width")==0 && xmlStrcasecmp(name,BAD_CAST"s")==0)
						{
							[parser->m_style.lastObject setValue:@(strtod((const char*)value, NULL)) forKey:(id)kCTStrokeWidthAttributeName];
						}
						else if (xmlStrcasecmp(key,BAD_CAST"src")==0 && xmlStrcasecmp(name,BAD_CAST"a")==0)
						{
							[parser->m_style.lastObject setValue:[NSURL URLWithString:[NSString stringWithUTF8String:(const char*)value]] forKey:@"src"];
						}
						else if (xmlStrcasecmp(key,BAD_CAST"href")==0)
						{
							if (xmlStrcasecmp(name,BAD_CAST"a")!=0)
								continue;
							NSString* href=[NSString stringWithUTF8String:(const char*)value];
							NSURL* url=[NSURL URLWithString:href];
							if (url.scheme==nil)
							{
								if (href.length && [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] characterIsMember:[href characterAtIndex:0]])
									url=[NSURL URLWithString:[@"tel://" stringByAppendingString:href]];
								else
									url=[NSURL URLWithString:[@"http://" stringByAppendingString:href]];
							}
							[parser->m_style.lastObject setValue:url forKey:@"href"];
						}
						else if (xmlStrcasecmp(key,BAD_CAST"width")==0 || xmlStrcasecmp(key,BAD_CAST"width")==0 || xmlStrcasecmp(key,BAD_CAST"descent")==0)
						{
							[parser->m_style.lastObject setValue:@(strtof((const char*)value, NULL)) forKey:[NSString stringWithUTF8String:(const char*)key]];
						}
						else
						{
							[parser->m_style.lastObject setValue:[NSString stringWithUTF8String:(const char*)value] forKey:[NSString stringWithUTF8String:(const char*)key]];
						}
					}
				}
				
				if (xmlStrcasecmp(name,BAD_CAST"b")==0)
				{
					[parser->m_style.lastObject setValue:@([parser->m_style.lastObject[kFontStaits] unsignedIntegerValue]|kCTFontBoldTrait) forKey:kFontStaits];
				}
				else if (xmlStrcasecmp(name,BAD_CAST"i")==0)
				{
					[parser->m_style.lastObject setValue:@([parser->m_style.lastObject[kFontStaits] unsignedIntegerValue]|kCTFontItalicTrait) forKey:kFontStaits];
				}
				
				size_t paragraph=0;
				for (NSString* key in [parser->m_style.lastObject allKeys])
				{
					NSString* value=[parser->m_style.lastObject valueForKey:key];
                    
                    if ([key isEqualToString:@"font"])
					{
						CTFontSymbolicTraits traits=[parser->m_style.lastObject[kFontStaits] unsignedIntegerValue];
						CGFloat size=[parser->m_style.lastObject[@"size"] floatValue];
						NSString* name=[value stringByAppendingFormat:@"%c%c%g",(traits & kCTFontTraitBold) ? 'B' : '-',(traits & kCTFontTraitItalic) ? 'I' : '-',size];
						static NSCache* cache=nil;
						static dispatch_once_t onceToken;
						dispatch_once(&onceToken, ^{
							cache=[[NSCache alloc] init];
						});
						id font=[cache objectForKey:name];
						if (font==nil && (font=CFBridgingRelease(CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)(CFBridgingRelease(CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)(@{(id)kCTFontFamilyNameAttribute:value,(id)kCTFontTraitsAttribute:@{(id)kCTFontSymbolicTrait:@(traits)}})))),size,NULL)))==nil)
						{
							continue;
						}
						[parser->m_style.lastObject setValue:font forKey:(id)kCTFontAttributeName];
					}
				}
				
				if (paragraph)
				{
					[parser->m_style.lastObject setValue:CFBridgingRelease(CTParagraphStyleCreate(parser->m_paragraph,paragraph)) forKey:(id)kCTParagraphStyleAttributeName];
				}
				
				if (xmlStrcasecmp(name,BAD_CAST"br")==0)
				{
					[parser->m_attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r\n" attributes:parser->m_style.lastObject]];
				}
				
				
			}
			static void endElement(CHHTMLParser* parser, const xmlChar* name)
			{
				[parser->m_style removeLastObject];
			}
			static void characters(CHHTMLParser* parser, const xmlChar *chars, int len)
			{
				[parser->m_attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString alloc] initWithBytes:chars length:len encoding:NSUTF8StringEncoding] attributes:parser->m_style.lastObject]];
			}
			static void endDocument(CHHTMLParser* parser)
			{
				
			}
			static void error(CHHTMLParser* parser, const char* msg, ...)
			{
				va_list va;
				va_start(va, msg);
				vfprintf(stderr, msg, va);
				va_end(va);
			}
		};
		m_handler.startDocument=NULL;
		m_handler.endDocument=(endDocumentSAXFunc)callbacks::endDocument;
		m_handler.startElement=(startElementSAXFunc)callbacks::startElement;
		m_handler.endElement=(endElementSAXFunc)callbacks::endElement;
		m_handler.characters=(charactersSAXFunc)callbacks::characters;
		m_handler.comment=NULL;
		m_handler.cdataBlock=NULL;
		m_handler.error=(errorSAXFunc)callbacks::error;
		
		m_style=[NSMutableArray arrayWithCapacity:4];
	}
	return self;
}
-(NSAttributedString*)parse:(NSString*)html
{
	NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
	if (data)
	{
		htmlParserCtxtPtr context=htmlCreatePushParserCtxt(&m_handler, (__bridge void *)(self), (const char*)data.bytes, data.length, NULL, XML_CHAR_ENCODING_UTF8);
		if (context)
		{
			htmlCtxtUseOptions(context, HTML_PARSE_RECOVER|HTML_PARSE_NOERROR|HTML_PARSE_NOWARNING|HTML_PARSE_NONET|HTML_PARSE_COMPACT|HTML_PARSE_NOBLANKS);
			m_attributedString=[[NSMutableAttributedString alloc] init];
			[m_style setArray:@[@{@"font":@"Helvetica",@"size":@([UIFont systemFontSize])}]];
			if (htmlParseDocument(context)==0)
			{
				htmlFreeParserCtxt(context);
				return m_attributedString;
			}
			htmlFreeParserCtxt(context);
		}
	}
	return nil;
}
@end