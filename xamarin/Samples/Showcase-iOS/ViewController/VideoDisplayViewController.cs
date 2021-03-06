﻿using Foundation;
using LiferayScreens;
using System;
using UIKit;

namespace ShowcaseiOS.ViewController
{
    public partial class VideoDisplayViewController : UIViewController, IFileDisplayScreenletDelegate
    {
        public VideoDisplayViewController(IntPtr handle) : base(handle) { }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();

            this.videoDisplayScreenlet.ClassPK = LiferayServerContext.LongPropertyForKey("videoClassPK");
            this.videoDisplayScreenlet.ClassName = LiferayServerContext.StringPropertyForKey("fileClassName");

            this.videoDisplayScreenlet.Delegate = this;
        }

        /* IFileDisplayScreenletDelegate */

        [Export("screenlet:onFileAssetError:")]
        public virtual void OnFileAssetError(FileDisplayScreenlet screenlet, NSError error)
        {
            Console.WriteLine($"Video display failed: {error.DebugDescription}");
        }

        [Export("screenlet:onFileAssetResponse:")]
        public virtual void OnFileAssetResponse(FileDisplayScreenlet screenlet, NSUrl url)
        {
            Console.WriteLine($"Video display success: {url.DebugDescription}");
        }
    }
}
