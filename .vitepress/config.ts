import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Digital Fabrica',
  description: 'Quantum-synced sovereign interface for research, governance, and epoch publishing.',
  ignoreDeadLinks: true,
  themeConfig: {
    nav: [
      { text: 'Home', link: '/sites/index' },
      { text: 'Theory', link: '/sites/theory' },
      { text: 'Fabrics', link: '/sites/fabrics/' },
      { text: 'Whitepaper', link: '/sites/whitepaper/' },
      { text: 'Civic', link: '/sites/civic/' },
      { text: 'Blog', link: '/sites/blog/' },
      { text: 'DAO UI', link: '/dao-ui/index.html' }
    ],
    sidebar: {
      '/sites/': [
        { text: 'Landing', link: '/sites/index' },
        { text: 'Theory', link: '/sites/theory' },
        { text: 'Fabrics', link: '/sites/fabrics/' },
        { text: 'Whitepaper', link: '/sites/whitepaper/' },
        { text: 'Civic', link: '/sites/civic/' },
        { text: 'Blog', link: '/sites/blog/' }
      ]
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/digital-fabrica' }
    ]
  }
}); 