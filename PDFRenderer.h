//
//  PDFRenderer.h
//  PDFRenderer
//
//  Created by Thomas Nelson on 11/28/2013.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface PDFRenderer : NSObject

+ (void)drawText:(NSString*)text inFrame:(CGRect)frame fontName:(NSString *)fontName fontSize:(int) fontSize;

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to;
    
+(void)drawImage:(UIImage*)image inRect:(CGRect)rect;

+(void)createPDF:(NSString*)filePath field:(NSString*) field Photo:(UIImage*) Photo gps:(NSString*) gps;

+(void)editPDF:(NSString*)filePath templateFilePath:(NSString*) templatePath field:(NSString*) field Photo:(UIImage*) Photo;
@end
