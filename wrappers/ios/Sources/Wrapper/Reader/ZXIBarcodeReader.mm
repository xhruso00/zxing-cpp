// Copyright 2022 KURZ Digital Solutions GmbH
//
// SPDX-License-Identifier: Apache-2.0

#import "ZXIBarcodeReader.h"
#import "ZXing/ReadBarcode.h"
#import "ZXing/ImageView.h"
#import "ZXing/Result.h"
#import "ZXIFormatHelper.h"
#import "ZXIBinarizerHelper.h"
#import "ZXIPosition+Helper.h"
#import "ZXIErrors.h"

using namespace ZXing;

NSString *stringToNSString(const std::string &text) {
    return [[NSString alloc]initWithBytes:text.data() length:text.size() encoding:NSUTF8StringEncoding];
}

@interface ZXIBarcodeReader()
@property (nonatomic, strong) CIContext* ciContext;
@end

@implementation ZXIBarcodeReader

- (instancetype)init {
    return [self initWithHints: [[ZXIDecodeHints alloc] init]];
}

- (instancetype)initWithHints:(ZXIDecodeHints*)hints{
    self = [super init];
    self.ciContext = [[CIContext alloc] initWithOptions:@{kCIContextWorkingColorSpace: [NSNull new]}];
    self.hints = hints;
    return self;
}

- (nullable NSArray<ZXIResult *> *)readCIImage:(nonnull CIImage *)image
                                error:(NSError *__autoreleasing _Nullable *)error {
    CGImageRef cgImage = [self.ciContext createCGImage:image fromRect:image.extent];
    if (cgImage == NULL) {
        SetNSError(error, ZXIReaderError, "Could not create a CGImage from the CIImage");
        return nil;
    }
    auto results = [self readCGImage:cgImage error:error];
    CGImageRelease(cgImage);
    return results;
}

- (nullable NSArray<ZXIResult *> *)readCGImage:(nonnull CGImageRef)image
                                         error:(NSError *__autoreleasing _Nullable *)error {
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    NSMutableData *data = [NSMutableData dataWithLength: cols * rows];

    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
    CGContextRef contextRef = CGBitmapContextCreate(data.mutableBytes,// Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cols,              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGColorSpaceRelease(colorSpace);
    if (contextRef == NULL) {
        SetNSError(error, ZXIReaderError, "Could not create a bitmap context for the image");
        return nil;
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
    CGContextRelease(contextRef);

    ImageView imageView = ImageView(
              static_cast<const uint8_t *>(data.bytes),
              static_cast<int>(cols),
              static_cast<int>(rows),
              ImageFormat::Lum);
    return [self readImageView:imageView error:error];
}

+ (DecodeHints)DecodeHintsFromZXIOptions:(ZXIDecodeHints*)hints {
    BarcodeFormats formats;
    for(NSNumber* flag in hints.formats) {
        formats.setFlag(BarcodeFormatFromZXIFormat((ZXIFormat)flag.integerValue));
    }
    DecodeHints resultingHints = DecodeHints()
        .setTryRotate(hints.tryRotate)
        .setTryHarder(hints.tryHarder)
        .setTryInvert(hints.tryInvert)
        .setTryDownscale(hints.tryDownscale)
        .setTryCode39ExtendedMode(hints.tryCode39ExtendedMode)
        .setValidateCode39CheckSum(hints.validateCode39CheckSum)
        .setValidateITFCheckSum(hints.validateITFCheckSum)

        .setFormats(formats)
        .setMaxNumberOfSymbols(hints.maxNumberOfSymbols)
        .setBinarizer(BinarizerFromZXIBinarizer((ZXIBinarizer)hints.binarizer))
        .setIsPure(hints.isPure);
    return resultingHints;
}

- (NSArray<ZXIResult*> *)readImageView:(ImageView)imageView
                                 error:(NSError *__autoreleasing _Nullable *)error {
    try {
        Results results = ReadBarcodes(imageView, [ZXIBarcodeReader DecodeHintsFromZXIOptions:self.hints]);
        NSMutableArray* zxiResults = [NSMutableArray array];
        for (auto result: results) {
            NSData *bytes = [[NSData alloc] initWithBytes:result.bytes().data() length:result.bytes().size()];
            [zxiResults addObject:
             [[ZXIResult alloc] init:stringToNSString(result.text())
                              format:ZXIFormatFromBarcodeFormat(result.format())
                               bytes:bytes
                            position:[[ZXIPosition alloc]initWithPosition: result.position()]
             ]];
        }
        return zxiResults;
    } catch(std::exception &e) {
        SetNSError(error, ZXIReaderError, e.what());
        return nil;
    } catch (...) {
        SetNSError(error, ZXIReaderError, "An unknown error occurred");
        return nil;
    }
}

@end
