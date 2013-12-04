//
//  PDFRenderer.m
//  PDFRenderer
//
//  Created by Thomas Nelson on 11/28/2013.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//

#import "PDFRenderer.h"

@implementation PDFRenderer

+(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frame fontName:(NSString *)fontName fontSize:(int) fontSize
{        
    CFStringRef stringRef = ( CFStringRef)textToDraw;
    
    // Prepare the text using a Core Text Framesetter.
    CTFontRef font = CTFontCreateWithName(( CFStringRef)fontName, fontSize, NULL);
    CFStringRef keys[] = { kCTFontAttributeName };
    CFTypeRef values[] = { font };
    CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                              sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, attr);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(currentText);
 
    CGRect frameRect = (CGRect){frame.origin.x, -1 * frame.origin.y, frame.size};
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
            
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    // CGContextTranslateCTM(currentContext, 0, 100);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Revert coordinate
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(frameSetter);    
}

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}

+(void)drawImage:(UIImage*)image inRect:(CGRect)rect
{
    [image drawInRect:rect];
}

+(void)createPDF:(NSString*)filePath field:(NSString*) field Photo:(UIImage*) Photo gps:(NSString*) gps
{
    NSString *Caption=field;
     NSString *maps = [field stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    NSString *http=@"https://";
     NSString *http1=@"maps.google.com/maps?q=";
    NSString *map1=@"+";
    NSString *map2=@"&z=14&ll=";
    NSString *link=[NSString stringWithFormat:@"%@%@%@%@(%@)%@%@",
     http,http1,gps,map1,maps,map2,gps];
    NSURL *url2 = [NSURL URLWithString:[link
                                        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *myString = [url2 absoluteString];
     NSString *myString2 = [url2 absoluteString];
    NSString *myString3 = [url2 absoluteString];
    CGRect  fldFrame1 =CGRectMake(150, 380, 320, 50);
      CGRect  fldFrame2 = CGRectMake(100, 420, 500,50);
     // CGRect  fldFrame3 = CGRectMake(150, 10, 320,320);

   
    [PDFRenderer drawText:Caption inFrame:CGRectMake(150, 380, 320, 50) fontName:@"TimesNewRomanPSMT" fontSize:20];
    UIGraphicsSetPDFContextURLForRect ([NSURL URLWithString:myString], fldFrame1);
    [PDFRenderer drawText:@"link to map" inFrame:CGRectMake(285, 420, 500,50) fontName:@"TimesNewRomanPSMT" fontSize:10];
     UIGraphicsSetPDFContextURLForRect ([NSURL URLWithString:myString2], fldFrame2);
    //CGPoint from = CGPointMake(0, 0);
   // CGPoint to = CGPointMake(200, 300);
    //[PDFRenderer drawLineFromPoint:from toPoint:to];
  
    UIImage* logo = Photo;
    
    CGRect frame = CGRectMake(150, 10, 320,320);
    [PDFRenderer drawImage:logo inRect:frame];
    UIGraphicsSetPDFContextURLForRect ([NSURL URLWithString:myString3],  CGRectMake(150, 500, 320,320));
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

+(void)editPDF:(NSString*)filePath templateFilePath:(NSString*) templatePath field:(NSString*) field Photo:(UIImage*) Photo
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        
    //open template file
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, ( CFStringRef)templatePath, kCFURLPOSIXPathStyle, 0);
    CGPDFDocumentRef templateDocument = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    
    //get bounds of template page
    CGPDFPageRef templatePage = CGPDFDocumentGetPage(templateDocument, 1);
    CGRect templatePageBounds = CGPDFPageGetBoxRect(templatePage, kCGPDFCropBox);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //flip context due to different origins
    CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //copy content of template page on the corresponding page in new file
    CGContextDrawPDFPage(context, templatePage);
    
    //flip context back
    CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // Edit body
    [PDFRenderer drawText:field inFrame:CGRectMake(150, 550, 300, 50) fontName:@"Times" fontSize:36];
    [PDFRenderer drawText:@"adasd" inFrame:CGRectMake(150, 550, 305, 50) fontName:@"Times" fontSize:36];
    
    CGPoint from = CGPointMake(0, 400);
    CGPoint to = CGPointMake(200, 700);
    [PDFRenderer drawLineFromPoint:from toPoint:to];
    
    UIImage* logo = Photo;
    CGRect frame = CGRectMake(20, 500, 60, 60);
    
    [PDFRenderer drawImage:logo inRect:frame];
    
    
    CGPDFDocumentRelease(templateDocument);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}
@end
