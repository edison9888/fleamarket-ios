//
//  TBSDKLoginErrorDefine.h
//  TBSDKLoginSDK
//
//  Created by 亿刀 on 13-3-29.
//  Copyright (c) 2013年 亿刀. All rights reserved.
//

/*******本地错误******/
#ifndef TBSDKLoginSDK_TBSDKLoginErrorDefine_h
#define TBSDKLoginSDK_TBSDKLoginErrorDefine_h

#define kLoginUnKnowError                                       @"kLoginUnKnowError"
#define kLoginUnKnowErrorMSG                                    @"未知错误"

#define kLoginUsernameOrPasswordIsNULL                          @"kLoginUsernameOrPasswordIsNULL"
#define kLoginUsernameOrPasswordIsNULLMSG                       @"用户名或密码不能为空"

#define kLoginPubKeyOrAppTokenIsNULL                            @"kLoginPubKeyOrAppTokenIsNULL"
#define kLoginPubKeyOrAppTokenIsNULLMSG                         @"pubkey或appToken不能为空"

#define kLoginAutoLoginTokenIsNULL                              @"kLoginAutoLoginTokenIsNULL"
#define kLoginAutoLoginTokenIsNULLMSG                           @"自动登录令牌不能为空"
/*******************/


/*******服务器返回错误******/
#define ERROR_NEED_CHECK_CODE                                   @"ERROR_NEED_CHECK_CODE"        //"ERROR_NEED_CHECK_CODE::为了您的账号安全，请输入验证码。"
#define ERROR_CHECK_CODE_ERROR                                  @"1003"                         //"1003::验证码错误，请重新输入。"
/*******************/




#endif
