import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'IP | Ivan Pasev',
  description: 'Operator 11411 — Public Research, Proofs, and IP Registry',
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Research', link: '/research/' },
      { text: 'Proofs', link: '/proofs/' },
      { text: 'Legal', link: '/legal/' },
      { text: 'Identity', link: '/identity/did.json' },
    ],
    sidebar: {
      '/research/': [
        { text: 'Research Archive', link: '/research/' }
      ],
      '/proofs/': [
        { text: 'Formal Proofs', link: '/proofs/' }
      ],
      '/legal/': [
        { text: 'Legal IP Registry', link: '/legal/' }
      ],
    },
  },
}); 