import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "rules_fortran",
  description: "Fortran rules for Bazel using LLVM Flang. Build Fortran libraries, binaries, and WebAssembly targets.",
  base: '/rules_fortran/',

  head: [
    ['meta', { name: 'keywords', content: 'fortran, bazel, rules, llvm, flang, wasm, webassembly' }],
    ['meta', { name: 'author', content: 'Minseo Park' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'rules_fortran' }],
    ['meta', { property: 'og:description', content: 'Fortran rules for Bazel' }],
    ['meta', { property: 'og:url', content: 'https://miinso.github.io/rules_fortran/' }],
    ['meta', { name: 'twitter:card', content: 'summary' }],
    ['meta', { name: 'twitter:title', content: 'rules_fortran' }],
    ['meta', { name: 'twitter:description', content: 'Fortran rules for Bazel' }],
  ],

  sitemap: {
    hostname: 'https://miinso.github.io/rules_fortran/'
  },

  lastUpdated: true,

  rewrites: {
    'reference/api.md': 'index.md'
  },

  markdown: {
    languages: ['fortran-free-form', 'python', 'c', 'bash'],
    languageAlias: {
      'fortran': 'fortran-free-form',
      'starlark': 'python'
    }
  },

  themeConfig: {
    nav: [
      { text: 'docs', link: '/' }
    ],

    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Installation', link: '/guide/installation' },
          { text: 'Quick Start', link: '/guide/quick-start' },
          { text: 'Concepts', link: '/guide/concepts' },
          { text: 'Contributing', link: '/guide/contributing' }
        ]
      },
      {
        text: 'Examples',
        items: [
          { text: '1. Basic', link: '/examples/basic' },
          { text: '2. Interop', link: '/examples/interop' },
          { text: '3. WebAssembly', link: '/examples/wasm' }
        ]
      },
      {
        text: 'Reference',
        items: [
          { text: 'API', link: '/' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/miinso/rules_fortran' }
    ]
  }
})
