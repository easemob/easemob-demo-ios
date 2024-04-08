# 产品介绍

环信IM产品展示了怎么使用环信SDK创建一个完整的聊天APP。展示的功能包括：用户登录注册，添加好友，单聊，群聊，发送文字，表情，语音，图片，iCloud文件，地理位置等消息，以及实时音视频通话等。

其中音视频通话使用声网SDK实现。

# 产品体验

![](./demo.png)

#  前置环境需求

- Xcode 14.0及以上版本
- 最低支持系统：iOS 13.0
- 请确保您的项目已设置有效的开发者签名

可以使用 CocoaPods 安装 EaseChatUIKit 作为 Xcode 项目的依赖项。

在podfile中添加如下依赖

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'YourTarget' do
  use_frameworks!

  pod 'EaseChatUIKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

然后cd到终端下podfile所在文件夹目录执行

```
    pod install
```

>⚠️Xcode15编译报错 ```Sandbox: rsync.samba(47334) deny(1) file-write-create...```

> 解决方法: Build Setting里搜索 ```ENABLE_USER_SCRIPT_SANDBOXING```把```User Script Sandboxing```改为```NO```

# 跑通Demo

 1. [注册环信应用](https://doc.easemob.com/product/enable_and_configure_IM.html)

 2. 将Appkey填入`PublicFiles.swift`文件中的`AppKey`中

 3. 需要将服务端源码部署后填入`PublicFiles.swift`文件中的`ServerHost`中，手机号验证码暂时可以跳过，可以使用手机号后六位当验证码，服务端中的Appkey 要跟客户端的Appkey保持一致。Appserver主要提供了手机号验证码登录接口以及上传用户头像的接口，此接口主要的职能是根据用户的信息注册并生成EaseChatUIKit登录所需的token或者使用已注册的用户信息生成EaseChatUIKit登录所需的token，上传头像是一个普通的通用功能在此不过多赘述。

 4. 点击运行至目标设备上（注意：不支持arm模拟器，需要选择Rosetta模拟器或者真机）

# EaseChatUIKit在Demo中的使用

## 1. 初始化

[详情参见](./EaseChatDemo/EaseChatDemo/AppDelegate.swift) 中 `didFinishLaunchingWithOptions`方法中步骤。

## 2. 登录

[详情参见](./EaseChatDemo/EaseChatDemo/LoginViewController.swift)中`loginRequest`方法后续步骤

## 3. Provider使用及其最佳示例用法

如果您的App中已经有完备的用户体系以及可供展示的用户信息（例如头像昵称等。）可以实现EaseChatProfileProvider协议来提供给UIKit要展示的数据。

3.1 [Provider初始化详情参见](./EaseChatDemo/EaseChatDemo/Main/MainViewController.swift)中`viewDidLoad`方法中

3.2 实现Provider协议对`MainViewController`类的扩展参见下述示例代码

```Swift
extension MainViewController: EaseProfileProvider,EaseGroupProfileProvider {

}
```


## 4.集成EaseChatUIKit中的类进行二次开发

4.1 如何继承EaseChatUIKit中的可自定义的类

[参见IntegratedFromEaseChatUIKit文件夹](./EaseChatDemo/EaseChatDemo/IntegratedFromEaseChatUIKit)中

4.2 如何将继承EaseChatUIKit中子类注册进EaseChatUIKit中替换父类

[详情参见](./EaseChatDemo/EaseChatDemo/AppDelegate.swift) 中 `didFinishLaunchingWithOptions`方法

# Demo设计
浏览器中打开如下链接
https://www.figma.com/file/8hUyvioi2insTUc5KXbetl/Chat-UIkit-for-Mobiles


# 已知问题

1. callkit 群聊呼叫用户会产生一条单聊消息，即便对方不是您的好友，后续会改进，也可以用户自己使用群聊中的定向消息自己做信令。
2. 会话列表、联系人列表是单独的模块，如果想要监听好友事件需要初始化ContactViewModel后调用registerListener方法监听。
3. UserProvider以及GroupProvider需要用户自己实现，用于获取用户的展示信息以及群组的简要展示信息，如果不实现默认用id以及默认头像。
4. 换设备或者多设备登录，漫游的会话列表，环信SDK中没有本地存储的群头像名称等显示信息，需要用户使用Provider提供给UIKit才能正常显示。
5. 由于Provider的机制是停止滚动或者第一页不满10条数据时触发，所以更新会话列表以及联系人列表UI显示的昵称头像需要滑动后Provider提供给UIKit数据后，UIKit会刷新UI。

6. 不支持arm模拟器，因为音频录制库使用libffmpeg的wav转amr的库。


# Q&A


如有问题请联系环信技术支持或者发邮件到issue@easemob.com
