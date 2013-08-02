#ifndef __TB_ITF_H__
#define __TB_ITF_H__

#if defined(__cplusplus)||defined(c_plusplus) 
#define TBEXTERN_C extern "C"
#else
#define TBEXTERN_C extern 
#endif

#define TB_STR_SIZE 976

typedef signed int TBInt;
typedef signed char TBChar;
typedef unsigned char TBUChar;



// The format of TBarImage MUST be BGRA(8888)
typedef struct {
    TBInt width;
    TBInt height;
    TBInt bytesPerRow;
    TBUChar* data;
} TBarImage;

typedef struct {
    TBInt x;
    TBInt y;
    TBInt width;
    TBInt height;
} TBarRect;

typedef struct {
    TBInt type;             //0:unknown 1:barcode 2:qrcode
    TBInt subType;          //depend on 'type'. 
    TBarRect rect;          //hot area
    TBInt x[4], y[4];
    TBChar str[TB_STR_SIZE];//null-terminated string for decoding info
} TBarRet;


// image: image info provided by camera
// ret: decoded data return form decoder. ret may be NULL.
// return: 1: success
TBEXTERN_C TBInt TBDecode(const TBarImage* image, TBarRet* ret, TBInt inCount, TBInt* outCount);

TBEXTERN_C TBInt TBDecodeBigImage(const TBarImage* image, TBarRet* ret, TBInt inCount, TBInt* outCount);
//TBEXTERN_C TBarRet TBDecodeBigImage(const TBarImage* image);

#endif // __TB_ITF_H__
