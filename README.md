# 产品介绍

环信新版本UIKit Demo：打造卓越聊天体验的强大工具

全面功能，产品化体验

环信UIKit Demo为您提供全面的聊天功能，助力您轻松构建功能强大、产品化的聊天体验。从基本的文字消息到高级的群组互动，我们的Demo涵盖了所有市场通用能力，让您能够满足用户的各种聊天需求。

开箱即用，快速集成

我们的Demo经过精心设计，可轻松集成到您的现有应用程序中。清晰的代码结构和详尽的文档让您能够快速上手，无需繁琐的配置和开发工作。

应用服务器示例代码，简化集成

为了进一步简化集成过程，我们提供了完整的应用服务器示例代码，展示了如何将您的应用程序连接到环信IM后端。这将帮助您轻松实现聊天功能的部署和运行。

功能亮点:

流畅的实时消息传递
语音和视频通话
文件共享
群组聊天
线程讨论
群组成员管理
消息提醒
可定制界面
预配置的聊天功能
应用服务器示例代码

立即体验环信新版本UIKit Demo，开始构建您的梦想聊天应用程序吧！

# 产品体验

![](./demo.png)

#  前置环境需求

- Xcode 15.0及以上版本 原因是UIKit中使用了部分检测音频AVAudioApplication api适配iOS17以上系统
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

 3. 需要将[服务端源码](https://github.com/easemob/easemob-im-app-server/tree/dev-demo)部署后填入`PublicFiles.swift`文件中的`ServerHost`中，手机号验证码暂时可以跳过，可以使用手机号后六位当验证码，服务端中的Appkey 要跟客户端的Appkey保持一致。Appserver主要提供了手机号验证码登录接口以及上传用户头像的接口，此接口主要的职能是根据用户的信息注册并生成EaseChatUIKit登录所需的token或者使用已注册的用户信息生成EaseChatUIKit登录所需的token，上传头像是一个普通的通用功能在此不过多赘述。

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
4.10.0及其以上
extension MainViewController: ChatUserProfileProvider,ChatGroupProfileProvider {

}
4.10.0以下
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
https://www.figma.com/community/file/1327193019424263350/chat-uikit-for-mobile


# 已知问题

1. callkit 群聊呼叫用户会产生一条单聊消息，即便对方不是您的好友，后续会改进，也可以用户自己使用群聊中的定向消息自己做信令。
2. 会话列表、联系人列表是单独的模块，如果想要监听好友事件需要初始化ContactViewModel后调用registerListener方法监听。
3. UserProvider以及GroupProvider需要用户自己实现，用于获取用户的展示信息以及群组的简要展示信息，如果不实现默认用id以及默认头像。
4. 换设备或者多设备登录，漫游的会话列表，环信SDK中没有本地存储的群头像名称等显示信息，需要用户使用Provider提供给UIKit才能正常显示。
5. 由于Provider的机制是停止滚动或者第一页不满10条数据时触发，所以更新会话列表以及联系人列表UI显示的昵称头像需要滑动后Provider提供给UIKit数据后，UIKit会刷新UI。

6. 不支持arm模拟器，因为音频录制库使用libffmpeg的wav转amr的库。


# Q&A


如有问题请联系环信技术支持或者发邮件到issue@easemob.com


[推送角标后台更新以及推送达到率统计](https://doc.easemob.com/push/push_apns_deliver_statistics.html#_1%E3%80%81%E6%8E%A8%E9%80%81%E6%9C%8D%E5%8A%A1%E6%89%A9%E5%B1%95%E4%BB%8B%E7%BB%8D)
