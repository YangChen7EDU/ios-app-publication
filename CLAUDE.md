# CLAUDE.md

## 项目是什么

研究 iOS App 上架 App Store 的规则和流程。主线案例是 7EDU 发布 7edu.vip（Seven by 7EDU）的 iOS App，同时会用几个练习 App 跑通流程。

- 主文档：`README.md`，内容包括初次发布清单、每次发版流程、易拒审点、练习路线、审核记录表
- 7edu.vip 的源码在 `/Users/chen/Codes/v0-ai-powered-counselor-system`（Next.js 15 + Supabase，部署在 Vercel）。需要产品背景时，读那边的 `PRODUCT.md`、`ARCHITECTURE.md`、`CLAUDE.md`；不要在那个仓库里做改动

## 写文档的规则

- 正文用中文；条款编号、API 名、配置键名、App Store Connect 里的菜单名保持英文原文
- 每条规则写明出处：App Review Guidelines 的条款编号（如 4.8、5.1.2(i)），或 Apple 官方文档链接
- Apple 的规则会变。写入或修改涉及日期、尺寸、版本要求的内容前，先查 Apple 官方页面核实；只查到第三方来源的，要在文中标注"未经官方核实"
- 更新 README 时，同步更新文件顶部的"写于"日期
- 被拒审的经验记到 README 的「审核记录」表，写清条款编号和处理办法

## Git 规则

- 提交信息用 Conventional Commits 格式，例如 `docs: ...`、`feat: ...`
- 标题下面空一行，写正文：说明改了什么、为什么改
- **提交信息里不要加 `Co-Authored-By` 行**，PR 描述里也不要加 AI 署名
- remote 必须用公司账号的 SSH 别名 `git@github.com-work:YangChen7EDU/ios-app-publication.git`。用 `github.com` 会以个人账号 tjcchen 推送，会被拒绝
