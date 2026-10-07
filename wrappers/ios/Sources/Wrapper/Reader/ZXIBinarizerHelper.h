#import <Foundation/Foundation.h>
#import "ZXing/BarcodeFormat.h"
#import "ZXing/DecodeHints.h"
#import "ZXIBinarizer.h"

NS_ASSUME_NONNULL_BEGIN

ZXing::Binarizer BinarizerFromZXIBinarizer(ZXIBinarizer binarizer);
ZXIBinarizer ZXIBinarizerFromBinarizer(ZXing::Binarizer binarizer);
NS_ASSUME_NONNULL_END
