#import "ZXIBinarizerHelper.h"

ZXing::Binarizer BinarizerFromZXIBinarizer(ZXIBinarizer binarizer) {
    switch (binarizer) {
        case ZXIBinarizer::LOCAL_AVERAGE:
            return ZXing::Binarizer::LocalAverage;
        case ZXIBinarizer::GLOBAL_HISTOGRAM:
            return ZXing::Binarizer::GlobalHistogram;
        case ZXIBinarizer::FIXED_THRESHOLD:
            return ZXing::Binarizer::FixedThreshold;
        case ZXIBinarizer::BOOL_CAST:
            return ZXing::Binarizer::BoolCast;
    }
    NSLog(@"ZXIWrapper: Received invalid ZXIBinarizer, returning format: LocalAverage");
    return ZXing::Binarizer::LocalAverage;
}

ZXIBinarizer ZXIBinarizerFromBinarizer(ZXing::Binarizer binarizer) {
    switch (binarizer) {
        case ZXing::Binarizer::LocalAverage:
            return ZXIBinarizer::LOCAL_AVERAGE;
        case ZXing::Binarizer::GlobalHistogram:
            return ZXIBinarizer::GLOBAL_HISTOGRAM;
        case ZXing::Binarizer::FixedThreshold:
            return ZXIBinarizer::FIXED_THRESHOLD;
        case ZXing::Binarizer::BoolCast:
            return ZXIBinarizer::BOOL_CAST;
    }
    NSLog(@"ZXIWrapper: Received invalid Binarizer, returning format: LOCAL_AVERAGE");
    return ZXIBinarizer::LOCAL_AVERAGE;
}
