# RFC #2: Academic Rays 课中 (In-Class) 模块实现
* **状态**：Draft
* **作者**：DuckRan
* **日期**：2026-02-15
* **目标**：基于 Local-First 架构，实现课中笔记的自动化识别、处理与存储流程。

---

## 1. 核心设计理念

基于 [RFC #1: Academic Rays Local-First 架构](rfc-1-architecture.md)，将课中笔记的处理流程抽象为 **Pipeline (流水线)** 模式。
管道模式允许我们将复杂的处理逻辑（如图片上传 -> OCR -> AI 格式化 -> 存储）分解为一系列解耦的原子步骤 (`PipelineStep`)。

## 2. 阶段详细设计与实现状态

### 2.1 阶段 1：基础设施与数据层 (Infrastructure & Data)
**目标**：建立本地持久化基础。
- **技术栈**：`drift` (SQLite), `path_provider`
- **任务完成情况**：
  - [x] **Task 1.1**: 引入 `drift`, `sqlite3`, `path_provider` 等依赖。
  - [x] **Task 1.2**: 定义 `Subjects` (科目) 和 `Captures` (原始素材) 表。
  - [x] **Task 1.3**: 定义 `Notes` (笔记) 表，建立科目关联。
  - [x] **Task 1.4**: 实现 `NoteRepository` 提供 CRUD 接口。

### 2.2 阶段 2：服务抽象与 API 集成 (Services & API)
**目标**：抽象核心能力（识别与生成）。
- **任务完成情况**：
  - [x] **Task 2.1**: 定义 `IOcrService` 接口（已实现本地/Mathpix 占位）。
  - [x] **Task 2.2**: 定义 `ILlmService` 接口（已集成 `google_generative_ai`）。
  - [x] **Task 2.3**: 基于 `flutter_secure_storage` 的密钥管理服务 `SettingsService`。

### 2.3 阶段 3：流水线编排 (Pipeline Orchestration)
**目标**：实现自动化处理逻辑。
- **任务完成情况**：
  - [x] **Task 3.1**: 定义 `PipelineStep<I, O>` 抽象架构。
  - [x] **Task 3.2**: 实现 `OcrStep`, `StructureStep`, `StorageStep`。
  - [x] **Task 3.3**: 实现 `NotePipelineManager` 负责全流程编排。

### 2.4 阶段 4：状态管理与 UI 集成 (State & UI)
**目标**：将功能暴露给用户。
- **任务完成情况**：
  - [x] **Task 4.1**: 使用 Riverpod ( `StreamProvider` ) 监听数据库变化。
  - [ ] **Task 4.2**: **(进行中)** 实现拍照上传预览与自动分类的 UI 界面。

---

## 3. 数据库模型 (Current Schema)

- **Subjects**: 存储学科信息（如：数学、物理）。
- **Captures**: 记录拍照原始记录（路径、时间、地理位置、处理状态）。
- **Notes**: 存储经 AI 处理后的结构化 Markdown 笔记。

---

## 4. 后续计划

1.  **完善 UI 交互**：开发 `lib/views` 下的相关页面，替换 `main.dart` 中的计数器 demo。
2.  **错误处理增强**：在 Pipeline 中加入重试机制。
3.  **多端同步对齐**：根据 RFC #1 的同步策略，设计 `Operation Log` 的记录逻辑。
