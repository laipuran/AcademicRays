# Academic Rays

一个智能学习辅助应用，打通"预习-记录-巩固"全链路，实现知识自动化归档与深度辅导。

## 文档

- [产品需求文档 (PRD)](docs/prd.md)
- [RFC #1: Local-First 架构](docs/rfc-1-architecture.md)
- [Git 工作流指南](docs/git-workflow-guide.md)

## 分支管理

### 主要分支

- `main` - 主分支，包含稳定的生产代码
- `feat` - 功能开发分支，用于新功能的开发

### 如何切换到 feat 分支

**方法 1：直接切换（推荐）**

```bash
git checkout feat
```

或使用更现代的命令：

```bash
git switch feat
```

这个命令会自动保留你工作树中未提交的更改，不会清空你的工作。

**方法 2：如果遇到冲突**

如果直接切换失败，使用 stash 临时保存工作：

```bash
git stash
git checkout feat
git stash pop
```

更多详细信息，请参阅 [Git 工作流指南](docs/git-workflow-guide.md)。

## 技术栈

- **客户端**: Flutter
- **后端**: ASP.NET Core
- **AI**: Gemini API
- **数据库**: 向量数据库 + Drift (SQLite)

## 核心功能

1. **课前预习** - 智能资料归档和预习摘要
2. **课中记录** - 自动化笔记生成和知识联想
3. **课后巩固** - 智能批改和动态任务流
4. **AI 助手** - 全局 Academic Ray 辅导系统

## License

待定
