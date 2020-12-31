# EaseIM
--------
## 简介
环信IM产品展示了怎么使用环信SDK创建一个完整的类微信的聊天APP。展示的功能包括：注册新用户，用户登录，添加好友，单聊，群聊，发送文字，表情，语音，图片，iCloud文件，地理位置等消息，以及实时音视频通话等。

## 环信IM APP运行

### 集成之前
-
    集成环信IM的APP应该有独立的AppKey，APP用户数据才可以实时统计，并可进行后续的数据加工和分析。
    这里是环信Console登录/注册引导地址：
    
> 环信Console引导地址：[环信文档](http://docs-im.easemob.com/im/quickstart/guide/experience#注册并创建应用)

-
    登录到环信Console，即可创建自己的IM应用。

### APP运行

1.安装cocoapods

```
sudo gem install cocoapods
```
2.安装成功后, 运行Podfile

```
cd ./EaseIM

pod install

```
3.点击.xcworkspace运行即可

## 目录介绍

  - class : EaseIMHelper  [监听事件回调并且控制页面跳转]
  - Helper [自定义库:消息提醒，本地设置项，UI弹窗等]
  - Account [账户验证：登录、注册、服务配置]
  - Home [登录后主页]
  - Communicate [实时音视频]
  - Chat [聊天基础组件（单聊/群聊/聊天室）]
  - Chatroom [聊天室服务]
  - Contact [好友列表]
  - Conversation [会话列表]
  - Group [群组服务]
  - Settings [设置]
  
## 添加SDK及基础服务头文件

- 环信IM使用配置 PCH 文件的方式引用sdk以及基础服务头文件，不需要在每个文件中添加头文件。

- 如果只需要使用环信IM项目的部分组件，建议创建一个 PCH 文件，引入sdk头文件，并在Build Settings 中设置 Prefix Header 为该 PCH 文件

## 集成功能模块条件

在成功登录到环信服务器的前提下：

集成联系人模块，群聊模块，聊天室模块时若需要使用聊天功能则必须导入 Chat 模块，创建聊天控制器，即可跳转会话聊天（联系人-单聊 / 群组列表-群聊 / 聊天室列表-聊天室）页面。

## 集成聊天模块：

- 使用聊天控制工厂生产指定类型的聊天控制器

```
//生产传入对应会话类型参数的会话聊天控制器
+ (EMChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType;
```

# 集成其他模块

- 以下介绍的模块需要初始化全局监听单例类：EaseIMHelper，监听事件回调并且控制页面跳转

## 会话列表模块：

- 向工程导入 Conversation 模块，其中包括 会话列表 和 系统通知（加好友/加群 通知），使用示例：

```
EMConversationsViewController *conversationController = [[EMConversationsViewController alloc] init];
```
**可通过导航跳转

## 好友列表模块：

- 向工程导入 Contact 模块，其中包括 好友列表 和 添加/删除好友，使用示例：

```
EMContactsViewController *contactsController = [[EMContactsViewController alloc] init];
```
**可通过导航跳转

## 群聊模块：

- 向工程导入 Group 模块，其中包括 加入的群聊列表，群组详情信息，创建群组等，使用示例：

```
EMGroupsViewController *controller = [[EMGroupsViewController alloc] init];
```
* 可通过导航跳转

## 聊天室模块：

- 向工程导入 Chatroom 模块，其中包括 聊天室列表，聊天室详情信息等，使用示例：

```
EMChatroomsViewController *controller = [[EMChatroomsViewController alloc] init];
```
* 可通过导航跳转


> 环信sdk集成文档：[环信文档](http://docs-im.easemob.com/im/ios/sdk/prepare)

> 环信sdk API文档：[环信文档](http://sdkdocs.easemob.com/apidoc/ios/chat3.0/annotated.html)
