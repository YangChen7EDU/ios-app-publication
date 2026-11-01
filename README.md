# ios-app-publication

研究 iOS App 上架 App Store 的规则、流程和审核要求，并以 **7EDU 发布 7edu.vip（Seven by 7EDU）iOS App** 为主线案例。

> 写于 2026-11-01。Apple 的规则每年都会变（通常在 WWDC 后的 6 月和新系统发布后的 9–11 月），提交前请以文末「官方资料」里的原文为准。

---

## 0. 一页总览

| 阶段 | 做什么 | 一次性 / 每次 |
|---|---|---|
| 账号 | 公司名义的 Apple Developer Program（Organization） | 一次性 |
| 合规设计 | Sign in with Apple、账号删除、AI 数据告知、未成年人隐私 | 一次性（改动时复查） |
| App Store Connect 建档 | Bundle ID、App 名称、隐私政策、隐私标签、年龄分级、协议与税务 | 一次性 |
| 构建上传 | 改版本号 → Archive → 上传 | **每次** |
| 测试 | TestFlight 内测 / 外测 | **每次** |
| 提交审核 | 填 What's New、截图（UI 变了才换）、审核备注 | **每次** |
| 发布 | 手动 / 自动 / 分阶段发布 | **每次** |

---

## 1. 7edu.vip 的背景，以及它对上架的影响

7edu.vip 是 Next.js 15 + Supabase 的 Web 应用，部署在 Vercel。产品角色是 Seven（"Seven by 7EDU"），面向 **家长（主要是 9–10 年级学生的家长）** 和 **学生本人**，免费，核心能力是 AI 对话和生成大学规划。

这几个事实直接决定了上架时会被重点审查的点：

| 7edu.vip 的事实 | 对应的 App Store 规则 | 需要做什么 |
|---|---|---|
| 现在只有网站 | **4.2 最低功能**：纯网页套壳会被拒 | App 必须有网页给不了的价值，见第 3 节 |
| 支持 Google 登录（Supabase OAuth） | **4.8 登录服务**：用了第三方登录，就必须同时提供一个保护隐私的登录选项，实际做法就是 Sign in with Apple | 在 Supabase 开 Apple provider，App 里加 Sign in with Apple 按钮 |
| 用户可以注册账号 | **5.1.1(v)**：能在 App 内注册，就必须能在 App 内删除账号 | 设置页加"删除账号"，真删数据，而不是只停用 |
| 对话和规划会把学生资料发给 OpenAI / Anthropic / Google 模型 | **5.1.2(i)**（2025-11 修订）：把个人数据发给第三方 AI 前，必须明确告知并取得用户同意 | 第一次使用 Seven 前弹一个同意页，写清楚发什么、发给谁；隐私政策里也写上 |
| 用户包括未成年学生 | **5.1.4 儿童**、COPPA；年龄分级问卷 | 不要选 Kids 分类（选了限制更多）；分类选 Education；年龄分级如实填（有 AI 聊天，预计会是 13+ 左右）；13 岁以下不开放学生注册，或走家长同意流程 |
| 有用户生成内容和对话 | **1.2 用户生成内容** | 提供举报和屏蔽机制，以及 AI 输出的内容过滤说明 |
| 将来可能收费（真人咨询） | **3.1.1 应用内购买** / **3.1.3(d) 一对一真人服务** | 首版建议完全不在 App 里卖东西，最省事；以后要收费再单独研究 |
| 网站禁用"AI""app"等词（PRODUCT.md） | App Store 元数据 | App 名称和副标题沿用品牌用语，比如 "Seven by 7EDU"；名称在全商店必须唯一，最多 30 字符，要先占 |

---

## 2. 初次发布：完整清单

### 2.1 账号（最先做，可能要等 1–2 周）

- [ ] **用公司名义注册 Organization 账号**：7edu.vip 要以 7EDU 的名义上架，商店里的"开发者 / 销售方"才会显示公司名。
  - 你现有的开发者账号如果是**个人（Individual）**账号，App 页面会显示你的个人姓名。不建议用它上架公司产品。可以拿它做练习 App。
  - Organization 账号需要：公司法律实体、**D-U-N-S 编号**（免费申请，几个工作日到两周）、公司域名邮箱、有签约权的人。年费 99 美元。
  - 个人账号以后可以把 App 转让给公司账号（App Transfer），但有限制，不如一开始就用对。
- [ ] 在 App Store Connect 里邀请团队成员，分配角色（Admin / App Manager / Developer / Marketing）。
- [ ] 签署 **Paid Apps 协议**、填写税务和银行信息。即使完全免费也建议签，因为以后加内购必须要。
- [ ] 如果要在欧盟上架：填写 **DSA Trader 信息**（公司地址、电话、邮箱会公开显示）。不在欧盟上架可以先跳过。
- [ ] 如果要在中国大陆商店上架：需要 **ICP 备案号**，而且生成式 AI 功能在大陆还要单独取得资质。**建议首版不勾选中国大陆**。

### 2.2 技术方案（决定 4.2 能不能过）

| 方案 | 适合 | 4.2 风险 |
|---|---|---|
| 纯 WKWebView 加载 7edu.vip | 不推荐 | **很高**，基本必拒 |
| **Capacitor** 打包，加上原生能力（推送、Sign in with Apple、分享、原生导航） | 想最大复用现有 Next.js 代码 | 中等，原生能力要做实 |
| **Expo / React Native** 重写移动端 UI，后端复用 Supabase 和 API | 想要原生体验，团队熟 React | 低 |
| SwiftUI 原生 | 体验最好，成本最高 | 低 |

无论哪种方案，都至少要给出 2–3 个网页做不到的点，例如：
- **推送通知**：Seven 有新的规划节点、会议提醒、截止日期提醒
- 原生登录（Sign in with Apple、Face ID 快速登录）
- 离线查看规划 / Timeline
- 分享到微信或信息、桌面小组件（Widget）

还要注意：
- 用远程网页承载核心功能，等于绕过审核随时改 App 功能，违反 **2.5.2 / 4.7**。修 bug 可以，改变 App 的用途不行。
- 构建工具：从 **2026-04-28** 起，上传的构建必须用 **Xcode 26 + iOS 26 SDK**。

### 2.3 工程配置（一次性）

- [ ] **Bundle ID**：例如 `vip.7edu.seven`，确定后不能改。
- [ ] Capabilities：Sign in with Apple、Push Notifications、Associated Domains（`applinks:7edu.vip`，让邮件里的链接直接打开 App）。
- [ ] **Supabase**：开启 Apple provider；在 Redirect URLs 里加上 App 的回调 scheme 或 universal link。
- [ ] **隐私清单 `PrivacyInfo.xcprivacy`**：声明收集的数据类型，以及用到的 Required Reason API（如 UserDefaults、文件时间戳）。第三方 SDK 也要带各自的隐私清单。
- [ ] Info.plist：
  - `ITSAppUsesNonExemptEncryption = NO`（只用 HTTPS 时，可以免去每次上传后的出口合规问答）
  - 每个用到的权限都要写清楚用途说明，例如 `NSCameraUsageDescription`（上传成绩单照片时）
- [ ] App 图标：1024×1024，不透明，不带圆角。
- [ ] 签名：用 Xcode 的 Automatic Signing 即可；推送需要在开发者后台生成 APNs Key（.p8）交给后端。

### 2.4 App Store Connect 建档（一次性）

- [ ] 新建 App：名称、主要语言（English (U.S.)）、Bundle ID、SKU。
- [ ] **隐私政策 URL**（必填），例如 `https://7edu.vip/privacy`。必须写到：
  - 收集哪些数据
  - 发给哪些第三方，**包括哪些 AI 服务商**
  - 数据保留多久
  - 如何删除
  - 未成年人数据怎么处理
- [ ] **支持 URL**（必填），例如 `https://7edu.vip/support`。
- [ ] **App 隐私标签（Privacy Nutrition Label）**：如实勾选收集的数据，例如联系信息、用户内容（聊天内容、学业资料）、标识符、使用数据，以及每项是否关联到身份、是否用于追踪。**这必须和隐私清单、隐私政策三者一致**，不一致是常见的拒审原因。
- [ ] **年龄分级问卷**：Apple 在 2025 年改成了 4+ / 9+ / 13+ / 16+ / 18+。要如实回答"不受限的网页访问""用户生成内容""聊天 / 消息"等问题。
- [ ] 分类：主分类 Education，次分类可以选 Productivity。
- [ ] 价格：免费；可用地区：建议先选美国（加拿大等可选）。
- [ ] 商店页面元数据：
  - 名称（30 字符）、副标题（30 字符）
  - 描述（不能写价格变动、不能提其他平台）
  - 关键词（100 字符，逗号分隔，不要和名称重复，不要写竞品名）
  - 截图
  - 宣传文本（可随时改，不用审核）
- [ ] **截图**：至少要一组 6.9 英寸 iPhone 截图（1320×2868 或 1290×2796，竖屏），最多 10 张；支持 iPad 时，还需要 13 英寸 iPad 截图（2064×2752）。截图必须是真实的 App 界面。

### 2.5 审核备注（App Review Information）

这一步决定能不能一次过：

- [ ] **提供演示账号**：至少一个家长账号，下面已经有一个学生和生成好的规划，让审核员不用自己走完引导流程就能看到核心功能。如有必要，再提供一个学生账号。账号在审核期间不要过期，也不要开二次验证。
- [ ] 在备注里用英文说明：
  - App 是做什么的
  - 哪里调用了第三方 AI、同意页在哪
  - 账号删除入口在哪（写出具体路径，例如 Settings → Account → Delete Account）
  - 推送通知用来做什么
- [ ] 联系人：电话和邮箱，审核员可能会打电话。

### 2.6 第一次提交前的自检

- [ ] 在真机上从**全新安装**走一遍：注册 → Sign in with Apple → AI 同意页 → 生成规划 → 删除账号
- [ ] 断网、弱网下不白屏、不崩溃
- [ ] 不出现"Beta""Coming soon"、占位文字、空页面、死链接
- [ ] App 内没有引导用户到网站付费的链接（除非已经研究过 3.1 和美国区的外链规则）
- [ ] 所有权限弹窗都在用户真正用到时才出现，而不是一启动就全部弹出
- [ ] 先发 TestFlight 给内部测一轮

---

## 3. 每次发布新版本：标准流程

| 步骤 | 做什么 | 备注 |
|---|---|---|
| 1. 改版本号 | `Version`（CFBundleShortVersionString，如 1.2.0）对用户可见；`Build`（CFBundleVersion）**每次上传必须递增** | 同一个 Version 可以上传多个 Build |
| 2. 构建上传 | Xcode → Product → Archive → Distribute App → App Store Connect；或用 `xcodebuild` / fastlane / Xcode Cloud / EAS | 上传后 App Store Connect 处理通常需要 5–30 分钟 |
| 3. TestFlight | 内部测试员（最多 100 个团队成员）**不用审核**；外部测试员（最多 10,000 人）第一个 Build 要过 Beta 审核 | 每个 Build 的有效期是 90 天 |
| 4. 建新版本 | App Store Connect →「+ 版本」→ 填 **What's New**、选 Build | |
| 5. 复查元数据 | UI 有明显变化就更新截图；新增数据收集就**同步更新隐私标签和隐私政策**；新增内容类型就重答年龄分级问卷 | 漏改隐私标签是常见的拒审原因 |
| 6. 提交审核 | 审核备注里说明这一版的变化，尤其是新功能和新权限 | 大多数在 24–48 小时内出结果 |
| 7. 发布 | 选手动发布、审核通过后自动发布、或**分阶段发布**（7 天内按 1%→2%→5%→10%→20%→50%→100% 推给开启自动更新的用户，可暂停） | 推荐重要版本用分阶段发布 |
| 8. 发布后 | 看 Xcode Organizer 或 App Store Connect 的崩溃数据、评论；必要时尽快发修复版 | |

**紧急修复**：可以在 App Store Connect 申请**加急审核（Expedited Review）**，只用于严重 bug 或安全问题，不要常用。

**不用发版就能改的**：宣传文本、后端 API、网页内容（只要不改变 App 的性质和功能）。

**必须发版的**：原生代码、权限、新增 SDK、隐私清单。

**被拒了怎么办**：在 App Store Connect 的 Resolution Center 回复。
- 如果是误解：解释清楚，或者补充截图或视频。
- 如果确实违规：改了以后重新提交。
- 如果不同意审核结果：可以向 App Review Board 申诉。

---

## 4. 7edu.vip 最容易被拒的点（按风险排序）

1. **4.2 最低功能**：看起来像把网站装进壳里。→ 加推送、原生登录、原生导航，首屏不要直接就是网页。
2. **4.8 / Sign in with Apple**：有 Google 登录却没有 Apple 登录。
3. **5.1.1(v) 账号删除**：找不到删除入口，或者删除只是"联系客服"。
4. **5.1.2(i) 第三方 AI**：没有在 App 内明确告知并取得同意就把学生资料发给模型。
5. **2.1 信息不全**：演示账号进去没有数据、登不上、或需要短信验证码。
6. **5.1.1 隐私一致性**：隐私标签、隐私清单、隐私政策三者对不上。
7. **1.2 / 年龄分级**：AI 自由对话加上未成年用户，年龄分级选得太低。

---

## 5. 练习路线（先用个人账号试几个小 App）

1. **App A：最小原生 App**（SwiftUI，单屏）→ 跑通 Archive、上传、TestFlight、提交、发布的全流程。
2. **App B：带登录的 App** → 练 Sign in with Apple、账号删除、隐私标签。
3. **App C：Capacitor 或 Expo 套一个 Next.js 小项目，加推送** → 验证 4.2 的边界，最接近 7edu.vip 的情况。
4. 每次被拒，都把原因和解决办法记到下面的「审核记录」。

### 审核记录

| 日期 | App | 版本 | 结果 | 条款 | 原因 / 处理 |
|---|---|---|---|---|---|
| | | | | | |

---

## 6. 官方资料

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)：所有条款编号（4.2、4.8、5.1.x 等）的出处
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/)：Xcode 和 SDK 的最低版本要求
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)：隐私标签
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Offering account deletion in your app](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Enrolling as an organization / D-U-N-S](https://developer.apple.com/help/account/membership/D-U-N-S/)
- [TestFlight](https://developer.apple.com/testflight/)
- [Phased release](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases/)
