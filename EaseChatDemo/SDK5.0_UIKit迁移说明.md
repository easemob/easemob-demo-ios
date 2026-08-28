# SDK 5.0 及 EaseChatUIKit 迁移说明

本文档基于当前分支（`5.0`）相对上一个基线提交的变更整理，说明 Demo 侧为适配 `HyphenateChat` SDK 5.0
以及 `EaseChatUIKit` 新版本所做的调整，供后续业务集成参考。

## 1. 依赖来源变化

`Podfile` 由拉取远程 pod 改为本地源码路径依赖，便于联调 UIKit 未发布的改动：

```diff
- pod 'EaseChatUIKit'
- pod 'EaseCallUIKit','4.18.2'
+ pod 'EaseChatUIKit',:path => '../../easemob-uikit-ios/'
+ pod 'EaseCallUIKit',:path => '../../easemob-callkit-iOS/'
```

集成方按需切回 trunk 版本号即可，不涉及业务代码改动。

## 2. SDK 5.0 移除自动登录，登录态需业务侧自行维护

### 2.1 变化点

`ChatOptions` 不再支持以下配置项，`AppDelegate.swift` 中已移除：

```diff
- options.isAutoLogin = true
- options.enableRequireReadAck = true
```

SDK 5.0 不再持久化登录凭证、不再提供自动登录能力。App 每次冷启动都需要业务侧显式调用登录接口。

### 2.2 Demo 侧适配方案

新增两个本地存储字段，用于业务侧自行保存登录凭证（`AppDelegate.swift` / `SceneDelegate.swift`）：

```swift
@UserDefault("EaseChatDemoUserToken", defaultValue: "") private var token
@UserDefault("EaseChatDemoUserName", defaultValue: "") private var userName
```

- `LoginViewController.swift`：登录成功后写入 `token` 与 `userName`。
- `AppDelegate.setupEaseChatUIKit()`：在 SDK `setup(option:)` 完成后，立即调用 `silentLogin(userId:)`
  使用本地保存的 `token` 静默登录（早于 Scene 创建）。
- `SceneDelegate.chooseRootViewController()`：根据 `token`/`userName` 是否为空决定展示登录页还是主页，
  不再依赖 `ChatClient.shared().isAutoLogin`。

> **待确认事项**：`onUserTokenDidExpired` 等回调中会发出 `backLoginPage` 通知强制退登，但退登逻辑
> （`loadLogin()` / `logoutUser()`）目前**未清空** `token`/`userName`。这意味着退登后再次冷启动仍会
> 走静默登录分支、而非登录页分支，如果业务侧希望退登后强制走登录页，需要在 `logoutUser()` 中一并清空
> 这两个 `UserDefault` 字段。

## 3. 用户名密码登录改为获取 token 再登录

SDK 5.0 移除了 `ChatClient.fetchToken(withUsername:password:)` 接口，调试模式下的用户名密码登录方式
需要改为业务服务器换取 token 后再调用 SDK 登录接口。

新增文件 `Utils/EasemobTokenRequest.swift`，通过 `ServerConfigViewController` 中新增的
"获取 token 的 Host" 配置项拼出请求地址（`{host}/{org}/{app}/token`），以
`grant_type=password` 方式换取 `access_token`，再交给 `ChatUIKitClient.shared.login(user:token:)`
完成登录。

配套改动：

- `CustomConstants/PublicDefines.swift` 新增 `TokenServerHostKey` 常量，用于在 `EaseChatDemoServerConfig`
  中存取该 Host 配置。
- `ServerConfigViewController.swift` 新增 `tokenServerField` 输入框，供调试模式下填写。
- `LoginViewController.swift` 密码登录分支由 `ChatClient.fetchToken` 切换为
  `EasemobTokenRequest.shared.fetchToken(userId:password:)`。

## 4. 群组相关 API 变化

`MineConversationsController.swift` 中建群逻辑适配新签名：

```diff
- option.style = .privateMemberCanInvite
+ option.allowInvites = true

- ChatClient.shared().groupManager?.createGroup(withSubject:description:invitees:message:setting:completion:)
+ ChatClient.shared().groupManager?.createGroup(withSubject:avatar:description:invitees:message:setting:completion:)
```

`ChatGroupOption.style` 被拆分为独立的 `allowInvites` 布尔开关；`createGroup` 新增 `avatar` 参数。

同一文件中，联系人首次拉取完成后的 `getContactsFromServer` 补充调用被删除，改为仅依赖数据同步流程
（见第 6 节），避免与 SDK 5.0 的数据同步机制重复拉取。

## 5. 会话免打扰状态改由 Conversation 对象读取

`MineContactDetailViewController.swift` 中"免打扰"开关状态，原先从本地维护的 `muteMap` 字典读取，
现改为直接读取会话对象的 `disturbType`：

```swift
var conversation: ChatConversation? {
    ChatClient.shared().chatManager?.getConversationWithConvId(self.profile.id)
}
...
"switchValue": ((self.conversation?.disturbType ?? .all) == .none)
```

集成方如果也维护了类似的本地免打扰状态缓存，建议一并切换为读取 `ChatConversation.disturbType`，
避免与服务端状态不一致。

## 6. 新增数据同步监听 / 未读数刷新

`MainViewController.swift` 新增对 `ChatDataSyncListener` 的实现：

```swift
extension MainViewController: ChatDataSyncListener {
    var interestedSyncType: EaseChatUIKit.DataSyncType { [.conversations, .contacts] }
    func onChatDatabaseOpened() { self.chats.loadingView.stopAnimating() }
    func onChatDataSyncStart(type: EaseChatUIKit.DataSyncType) { }
    func onChatDataSyncFinished(error: EaseChatUIKit.ChatError?, type: EaseChatUIKit.DataSyncType) {
        if error == nil {
            switch type {
            case .conversations:
                self.onConversationsUnreadCountUpdate(unreadCount: UInt(ChatClient.shared().chatManager?.getUnreadMessageCount() ?? 0))
            default:
                break
            }
        }
    }
}
```

登录后数据库尚未打开完成前，会话列表页会展示 `loadingView`（`viewDidLoad` 中提前调用
`self.chats.loadingView.startAnimating()`），待 `onChatDatabaseOpened` 回调后关闭，用于遮盖登录到
数据同步完成之间的空窗期。

`onChatDataSyncFinished` 中针对 `.conversations` 类型的同步结果补充了未读数刷新逻辑：会话数据
同步成功后主动调用 `onConversationsUnreadCountUpdate`，用当前 `getUnreadMessageCount()` 的结果
刷新 Tab 角标。这是为了解决登录初期——数据同步尚未完成时——角标可能因本地会话数据不全而显示不准确
的问题，与第 6 节前面提到的 `ConversationEmergencyListener` 已读回执刷新是同一诉求的两处触发点
（一个在数据同步完成时，一个在收到已读回执时），二者共同保证未读角标在各类时机下都能及时刷新。

`ConversationEmergencyListener` 回调中新增已读类型判断，登录后/收到已读回执时主动刷新未读数：

```swift
if type == .read {
    self.onConversationsUnreadCountUpdate(unreadCount: UInt(ChatClient.shared().chatManager?.getUnreadMessageCount() ?? 0))
}
```

## 7. 用户资料局部更新方式调整

`PersonalInfoViewController.swift` 中更新昵称/头像时，不再通过
`currentUser?.toJsonObject()` + `setValuesForKeys` 整体转存后再改字段，而是直接基于
`ChatUIKitContext.shared?.currentUser` 构造新的 `EaseChatProfile` 并设置目标字段，语义更清晰，
避免 KVC 方式对新增字段的隐式依赖。

## 8. 已知问题：状态栏高度求值时机（尚未修复）

### 现象

静默登录 / 应用重启后，`ConversationListController` 等页面的自定义导航栏会顶到状态栏内，
在 iOS 18、iOS 26 上均可复现，与系统版本无关。

### 根因

`EaseChatUIKit` 的 `StatusBarHeight` / `NavigationHeight`（`Contants.swift`）是**全局 `let`**，
只在第一次被访问时求值一次并永久缓存：

```swift
public let StatusBarHeight: CGFloat = UIApplication.shared.chat.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
public let NavigationHeight: CGFloat = StatusBarHeight + 44
```

而 `UIApplication.chat.keyWindow`（`UIAppliactionExtension.swift`）要求窗口所在 scene
`activationState == .foregroundActive` 且窗口 `isKeyWindow`。SDK 5.0 去掉自动登录后，
Demo 在 `SceneDelegate.scene(_:willConnectTo:)` 期间就同步构建了 `MainViewController`
（见 `chooseRootViewController()`），而此时 scene 必然还处于 `.foregroundInactive`，
`keyWindow` 恒为 `nil`，`StatusBarHeight` 首次求值即被永久缓存为 `0`，
`NavigationHeight` 随之变为 `44`，导致所有依赖它布局的导航栏/搜索框顶到状态栏。

`BottomBarHeight` 同样是全局 `let` 且使用了已废弃的 `UIApplication.shared.windows.first`，
存在相同的首次求值时机不可靠问题，只是取值恰好为 0 时不易察觉（无 Home Indicator 机型上
本身合法值也是 0，无法用非零判断兜底）。

### 排查过程中确认的关键点

- 仅将 `makeKeyAndVisible()` 提前到 `rootViewController` 赋值之前，**不能修复**该问题：
  `keyWindow` 的判定条件里 `activationState == .foregroundActive` 这一半在
  `willConnectTo` 阶段永远无法满足，与窗口是否为 key 无关。
- 由于 `token`/`userName` 在退登时未被清空（见第 2.2 节），实际测试中"从登录页进入"很难在
  已登录过的设备上复现，多数情况下都会走静默登录分支，从而命中此问题。

### 建议修复方向

将 `Contants.swift` 中的 `StatusBarHeight` / `NavigationHeight` / `BottomBarHeight`
由存储属性改为计算属性，取值不依赖 `keyWindow` 的 `activationState`/`isKeyWindow` 双重限制，
而是直接从 `connectedScenes` 中取 `UIWindowScene`（`BottomBarHeight` 需要注意 iOS 15 以下的
兼容写法，以及无 Home Indicator 机型下 0 是合法值、不能用于判断是否取值成功）。
该改动影响面在 `easemob-uikit-ios` 仓库内部，建议随下一次 UIKit 发版一并修复。

## 9. 影响范围小结

| 类别 | 是否需要业务侧适配 |
|---|---|
| 移除自动登录，需自行保存 token 并显式登录 | 是，参考第 2 节 |
| 用户名密码登录改为服务器换 token | 仅调试模式生效，正式环境走短信验证码登录不受影响 |
| `createGroup` 签名变化 / `option.style` 拆分 | 是，参考第 4 节 |
| 会话免打扰状态读取方式 | 建议同步调整，参考第 5 节 |
| 数据同步监听 / 未读数刷新 | 可选，用于优化登录后的加载体验 |
| 状态栏高度求值时机问题 | 暂未修复，等待 UIKit 侧发版，业务侧可临时通过尽早触发一次
`UIApplication.shared.chat.keyWindow` 的方式规避（需保证调用时 scene 已 active） |
