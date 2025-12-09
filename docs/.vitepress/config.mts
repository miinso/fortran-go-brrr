import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "rules_fortran",
  description: "Fortran rules for Bazel",

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
          { text: 'Concepts', link: '/guide/concepts' }
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
