.  
├── .github/  
│   └── workflows/  
│       └── deploy.yml        # CI/CD 流程  
├── src/  
│   ├── main.js               # 前端逻辑  
│   └── style.css             # 样式  
├── index.html                # Vite 入口  
├── package.json  
├── vite.config.js  
├── Dockerfile                # 多阶段构建  
├── .dockerignore             # 告诉 docker 哪些文件不进构建上下文  
├── .gitignore  
└── README.md  

## 使用方法
### 1.创建仓库并推送
```bash
git init
git add .
git commit -m "init: docker + github actions demo"
git branch -M main
git remote add origin https://github.com/<你的用户名>/<仓库名>.git
git push -u origin main
```
### 2.关键一步：启用 Pages
进入仓库 → `Settings` → 左侧 `Pages` → Build and deployment → `Source` 选择 GitHub Actions。
（不选这一步，`deploy-pages` 会直接报错）

### 3.等 Actions 跑完
进入 Actions 标签页，看到绿色的 ✔ 后，访问：  
https://<你的用户名>.github.io/<仓库名>/

### 4.本地开发 & 本地 Docker 验证
```bash
npm install
npm run dev                      # http://localhost:5173

# 用 Docker 跑（本地 base 用默认的 '/'）
docker build -t demo-site .
docker run --rm -p 8080:80 demo-site
# 打开 http://localhost:8080
```

## 覆盖的知识点
**Docker**
- `FROM / WORKDIR / COPY / RUN / ENV / ARG / EXPOSE / CMD` 常用指令
- **多阶段构建**：node 构建 + nginx 运行，最终镜像体积更小
- **层缓存优化**：先 COPY `package.json` 再装依赖
- `ARG`（构建期）vs `ENV`（运行期）的区别
- `.dockerignore` 的作用
- `docker build / run / create / cp / rm` 的配合使用

**GitHub Actions**
- workflow 文件位置与结构：`on / permissions / concurrency / jobs / steps`
- 触发器：`push + paths` 过滤、`workflow_dispatch` 手动触发
- 权限模型：`GITHUB_TOKEN` 与 `pages: write`、`id-token: write`
- 并发控制：`concurrency` 防止部署互相踩踏
- 官方 Action 的用法：`checkout`、`setup-buildx`、`build-push-action`、`upload-pages-artifact`、`deploy-pages`
- Docker 层缓存：`cache-from/to: type=gha`
- `$GITHUB_OUTPUT` 在 step 之间传值
- `needs` 定义 job 依赖、`environment` 关联部署环境

**工程实践**
- Vite 的 `base` 配置（GitHub Pages 项目页的坑）
- `VITE_` 前缀环境变量的暴露规则
- 冒烟测试思路：构建通过 ≠ 能跑起来
- 静态托管平台与容器的关系（Pages 不能跑容器，所以要从镜像里提取产物）