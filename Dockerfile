# syntax=docker/dockerfile:1
# ↑ 声明 Dockerfile 语法版本，让 BuildKit 使用最新稳定语法（可选但推荐）

# ================================================================
# 阶段 1：builder —— 只负责「把源码编译成静态文件」
# 这个阶段的所有东西（node_modules、源码）都不会进入最终镜像
# ================================================================
FROM node:20-alpine AS builder

# ARG：构建期参数，只在 docker build 时存在，镜像里查不到。
# 用法：docker build --build-arg BASE_PATH=/my-repo/ .
ARG BASE_PATH=/
ARG GIT_SHA=dev
ARG BUILD_TIME=local

# ENV：环境变量，在后续 RUN 指令中可被读取（npm run build 会读到）。
ENV BASE_PATH=${BASE_PATH} \
    VITE_GIT_SHA=${GIT_SHA} \
    VITE_BUILD_TIME=${BUILD_TIME}

WORKDIR /app

# 【关键缓存技巧】先只拷贝依赖清单，再装依赖。
# 只要 package.json 没变，这一层就命中缓存，改源码时不会重装 npm 包。
COPY package.json package-lock.json* ./

# 有 lock 文件时最佳实践是 npm ci（更快、可复现）。
# 这里用 install 是为了兼容没有 lock 文件的首次构建。
RUN npm install

# 再拷贝其余源码
COPY . .

# 执行构建，产物在 /app/dist
RUN npm run build

# ================================================================
# 阶段 2：runtime —— 最终镜像，只有 nginx + 静态文件
# ================================================================
FROM nginx:1.27-alpine AS runtime

# --from=builder 表示从 builder 阶段拷贝文件。
# 最终镜像大小约 50MB（而不是几百 MB 的 node 镜像）。
COPY --from=builder /app/dist /usr/share/nginx/html

# 声明容器监听 80 端口（文档性质，不实际映射端口）
EXPOSE 80

# 容器启动时的默认命令：前台运行 nginx
CMD ["nginx", "-g", "daemon off;"]