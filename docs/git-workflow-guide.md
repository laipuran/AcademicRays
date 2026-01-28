# Git 工作流指南

## 如何在不清空工作树的情况下切换分支

### 方法一：直接切换（推荐）

当工作树中有未提交的更改时，如果这些更改与目标分支没有冲突，Git 会自动保留这些更改：

```bash
# 切换到已存在的 feat 分支
git checkout feat

# 或者使用更现代的 switch 命令
git switch feat
```

### 方法二：使用 stash（有冲突时）

如果直接切换失败（因为有冲突的文件），可以使用 stash 临时保存工作：

```bash
# 1. 暂存当前工作树的更改
git stash save "临时保存的工作"

# 2. 切换到目标分支
git checkout feat

# 3. 恢复之前保存的更改
git stash pop
```

### 方法三：带着更改切换

如果你想确保更改被带到新分支：

```bash
# 使用 -m 参数强制合并更改
git checkout -m feat
```

### 创建并切换到新分支（保留更改）

如果 feat 分支还不存在，可以创建它：

```bash
# 基于当前分支创建 feat 分支并切换
git checkout -b feat

# 或使用 switch 命令
git switch -c feat
```

## 常见问题

### Q: 切换分支时会丢失未提交的更改吗？

A: 通常不会。Git 会尝试保留你的更改。但如果：
- 目标分支中有与你更改冲突的文件
- Git 无法自动合并

那么 Git 会阻止切换并提示你先处理这些更改。

### Q: 如何查看当前分支？

```bash
git branch        # 查看本地分支
git branch -a     # 查看所有分支（包括远程）
```

### Q: 如何查看工作树状态？

```bash
git status        # 查看未提交的更改
```

## 最佳实践

1. **经常提交**：养成经常提交的习惯，避免工作树中积累太多未提交的更改
2. **使用功能分支**：为每个新功能创建独立的分支
3. **切换前检查**：使用 `git status` 检查工作树状态
4. **善用 stash**：临时切换分支时使用 stash 保存工作进度

## 示例场景

### 场景 1：在 main 分支有未提交更改，需要切换到 feat 分支

```bash
# 检查当前状态
git status

# 直接切换（Git 会保留你的更改）
git checkout feat

# 确认切换成功且更改保留
git status
```

### 场景 2：有冲突无法直接切换

```bash
# 尝试切换
git checkout feat
# 错误：Your local changes to the following files would be overwritten...

# 使用 stash 解决
git stash
git checkout feat
git stash pop

# 如果有冲突，手动解决后继续
```

### 场景 3：创建新的功能分支

```bash
# 基于当前 main 分支创建 new-feature 分支
git checkout -b new-feature

# 开发新功能...
# 提交更改
git add .
git commit -m "实现新功能"

# 推送到远程
git push -u origin new-feature
```

## 参考资源

- [Git 官方文档 - git-checkout](https://git-scm.com/docs/git-checkout)
- [Git 官方文档 - git-switch](https://git-scm.com/docs/git-switch)
- [Git 官方文档 - git-stash](https://git-scm.com/docs/git-stash)
