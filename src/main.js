// import.meta.env 是 Vite 注入的环境变量对象。
// 规则：只有以 VITE_ 开头的变量才会暴露给浏览器代码（防止泄露密钥）。
// BASE_URL 是 Vite 内置变量，等于 vite.config.js 里的 base。
const rows = {
  'Commit SHA': import.meta.env.VITE_GIT_SHA || 'local-dev',
  '构建时间(UTC)': import.meta.env.VITE_BUILD_TIME || new Date().toISOString(),
  'Base 路径': import.meta.env.BASE_URL,
  '运行模式': import.meta.env.MODE,
  '当前时间': new Date().toLocaleString('zh-CN'),
}

const list = document.getElementById('info')

for (const [key, value] of Object.entries(rows)) {
  const li = document.createElement('li')
  li.innerHTML = `<span>${key}</span><code>${value}</code>`
  list.appendChild(li)
}

console.log('[demo] 页面加载完成', rows)