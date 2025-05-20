import DefaultTheme from 'vitepress/theme'
import Logo from './components/Logo.vue'
import Footer from './components/Footer.vue'
import { h } from 'vue'
import './custom.css'

export default {
  ...DefaultTheme,
  Layout: () => h('div', [
    h('header', { class: 'navbar' }, [
      h(Logo, { site: 'ip', variant: 'full' }),
      h('nav', [
        h('a', { href: '/' }, 'Home'),
        h('a', { href: '/civic' }, 'Civic'),
        h('a', { href: '/whitepaper' }, 'Whitepaper')
      ])
    ]),
    h(DefaultTheme.Layout),
    h(Footer)
  ])
} 