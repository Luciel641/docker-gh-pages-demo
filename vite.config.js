import { defineConfig } from 'vite'

// defineConfig 接收一个函数，可以读取 process.env。
// GitHub Pages 的「项目页」地址是 https://<用户名>.github.io/<仓库名>/
// 所以打包时 base 必须写成 '/<仓库名>/'，否则 JS/CSS 会 404。
// 这个值由 Dockerfile 的 ARG BASE_PATH 传入环境变量。
export default defineConfig(() => ({
  base: process.env.BASE_PATH || '/',
  build: {
    outDir: 'dist',      // 构建产物目录
    sourcemap: false,    // 入门 demo 不需要 sourcemap
  },
}))