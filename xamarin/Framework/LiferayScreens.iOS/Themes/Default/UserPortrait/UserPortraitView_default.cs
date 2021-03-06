﻿using CoreGraphics;
using Foundation;
using ObjCRuntime;
using System;
using UIKit;

namespace LiferayScreens
{
    // @interface UserPortraitView_default : BaseScreenletView <UserPortraitViewModel, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
    [BaseType(typeof(BaseScreenletView))]
    interface UserPortraitView_default : IUserPortraitViewModel, IUIActionSheetDelegate, IUINavigationControllerDelegate, IUIImagePickerControllerDelegate
    {
        // @property (nonatomic, strong, class) UIImage * _Nullable defaultPlaceholder;
        [Static]
        [NullAllowed, Export("defaultPlaceholder", ArgumentSemantic.Strong)]
        UIImage DefaultPlaceholder { get; set; }

        // @property (nonatomic, weak) UIActivityIndicatorView * _Nullable activityIndicator __attribute__((iboutlet));
        [NullAllowed, Export("activityIndicator", ArgumentSemantic.Weak)]
        UIActivityIndicatorView ActivityIndicator { get; set; }

        // @property (nonatomic, weak) UIImageView * _Nullable portraitImage __attribute__((iboutlet));
        [NullAllowed, Export("portraitImage", ArgumentSemantic.Weak)]
        UIImageView PortraitImage { get; set; }

        // @property (nonatomic, strong) UIImage * _Nullable image;
        [NullAllowed, Export("image", ArgumentSemantic.Strong)]
        UIImage Image { get; set; }

        // @property (nonatomic) CGFloat borderWidth;
        [Export("borderWidth")]
        nfloat BorderWidth { get; set; }

        // @property (nonatomic, strong) UIColor * _Nullable borderColor;
        [NullAllowed, Export("borderColor", ArgumentSemantic.Strong)]
        UIColor BorderColor { get; set; }

        // -(void)loadPlaceholderFor:(User * _Nonnull)user;
        [Export("loadPlaceholderFor:")]
        void LoadPlaceholderFor(User user);

        // -(void)loadDefaultPlaceholder;
        [Export("loadDefaultPlaceholder")]
        void LoadDefaultPlaceholder();

        // -(instancetype _Nonnull)initWithFrame:(CGRect)frame __attribute__((objc_designated_initializer));
        [Export("initWithFrame:")]
        [DesignatedInitializer]
        IntPtr Constructor(CGRect frame);
    }
}
