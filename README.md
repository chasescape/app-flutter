# Flutter App Portfolio

一组由我独立开发并已完成审核上线的 Flutter App 项目合集。

这个仓库主要用于展示我在移动端产品设计、Flutter UI 实现、功能落地和多题材产品孵化上的实际项目经验。当前 README 重点展示我想突出呈现的项目，包括旅行记录类与生活方式类 App。

## Overview

- 技术栈：`Flutter`、`Dart`
- 常用架构/方案：`GetX`、`Provider`、路由管理、本地存储、内购、AI 能力接入
- 项目状态：包含多个已过审项目与持续迭代中的实验项目
- 仓库形态：多模块 Flutter App 集合，按 `module/*` 组织

## Featured Projects

下面先展示当前主推的项目。

### 1. Enkou

一款旅行记录与行程灵感整理方向的 Flutter App，围绕日期、地点、路线、指南、日记和个人旅程归档展开。

**亮点**

- 首页具备完整的旅行内容卡片流与标签切换体验
- 包含 `Calendar`、`Guides`、`Day Journal`、`History`、`Profile` 等完整结构
- 支持旅行内容归档、日记记录、图片附加、指南信息整理等场景
- 使用 `GetX` 与多页面模块化组织，适合展示完整 App 信息架构能力

**核心页面建议展示**

- 首页总览
- 行程日历页
- 旅行指南页
- 日记记录页
- 个人中心页

**代码位置**

- [module/enkou/app.dart](/Users/chaseescape/work/app-flutter/module/enkou/app.dart)

### 2. ScentTrack

一款偏生活方式方向的香水收藏与穿香记录 App，包含收藏管理、记录沉淀、数据洞察和付费能力。

**亮点**

- 香水收藏与记录流程完整
- 包含首页、记录、详情、分析、设置等主要页面
- 数据洞察与日常记录结合，产品路径清晰
- 已具备较完整的产品化界面与交互呈现

**代码位置**

- [module/pekko/app.dart](/Users/chaseescape/work/app-flutter/module/pekko/app.dart)


## Demo

这一段非常重要，建议你把“视频在前、图片在后”。

### App Preview Video

建议在这里放一个演示视频封面图，点击跳转到视频：

[![Watch the demo](./docs/demo-cover.png)](https://your-demo-video-link)

如果你的视频是本地文件，建议上传到：

- GitHub Releases
- GitHub Issues / PR 附件
- Bilibili
- YouTube
- 飞书云文档 / 腾讯文档 / 网盘公开链接

### Screenshots

建议把截图按“用户路径”排，不要按“随机页面”排。

推荐顺序：

1. 首页
2. 核心功能页
3. 生成/分析过程页
4. 结果页
5. 历史记录页
6. 个人中心 / 设置页

示例排版：

<p align="center">
  <img src="./docs/screenshots/home.png" width="22%" />
  <img src="./docs/screenshots/create.png" width="22%" />
  <img src="./docs/screenshots/result.png" width="22%" />
  <img src="./docs/screenshots/profile.png" width="22%" />
</p>

如果你有第二组图，可以继续按模块补一排：

<p align="center">
  <img src="./docs/screenshots/history.png" width="22%" />
  <img src="./docs/screenshots/detail.png" width="22%" />
  <img src="./docs/screenshots/store.png" width="22%" />
  <img src="./docs/screenshots/settings.png" width="22%" />
</p>

## Project Structure

```text
app-flutter/
├── README.md
└── module/
    ├── pekko/
    ├── lenbo/
    ├── tanie/
    ├── midora/
    ├── lona/
    ├── halee/
    └── ...
```

## Module List

仓库当前包含多个 Flutter 项目模块，以下是其中一部分可直接作为作品展示的项目：

| Module | Product Name | Direction |
| --- | --- | --- |
| `enkou` | Enkou | 旅行记录 / 行程归档 |
| `pekko` | ScentTrack | 香水记录 / 生活方式 |
| `lenbo` | PlantCare | 植物识别 / 工具类 |
| `tanie` | Photo Reflection | 情绪内容 / 轻陪伴 |
| `midora` | Midora | 场景卡片 / 内容生成 |
| `lona` | ComposePilot | 构图建议 / 图像创作 |
| `halee` | Composition Advisor | 图像分析 / 创作辅助 |
| `laro` | LashVision Pro | 美妆试妆 / 工具类 |
| `havki` | QuoteVibe | 金句内容 / 情绪表达 |
| `temra` | NailVibe | 美甲灵感 / 图像内容 |
| `welgo` | LabelDecode | 标签识别 / 工具类 |
| `crushi` | StoicMind | 内容卡片 / 心理成长 |
| `veyla` | RiseCoach | 成长陪伴 / 效率提升 |

## What This Repository Shows

这个仓库主要体现了我在以下方向的能力：

- Flutter 多项目快速搭建与视觉落地
- 从产品想法到完整页面流的独立实现
- 不同题材 App 的 UI 风格切换能力
- AI 能力接入后的结果页与交互设计
- 记录、历史、会员、设置、反馈等完整产品链路设计
- 旅行记录、生活方式、内容表达等不同产品方向的独立实现能力


## Notes

- 当前仓库为多模块项目集合，并非单一 Flutter App 工程
- 部分模块为已完成产品，部分模块为迭代中的实验版本
