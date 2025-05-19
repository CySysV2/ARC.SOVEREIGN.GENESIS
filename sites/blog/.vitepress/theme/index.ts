import DefaultTheme from 'vitepress/theme'
import Logo from './components/Logo.vue'
import Footer from './components/Footer.vue'
import './custom.css'

export default {
  ...DefaultTheme,
  Layout() {
    return {
      template: `
        <header class="navbar">
          <Logo site="blog" variant="full" />
          <nav>
            <a href="/">Home</a>
            <a href="/civic">Civic</a>
            <a href="/whitepaper">Whitepaper</a>
          </nav>
        </header>
        <DefaultTheme.Layout />
        <Footer />
      `
    }
  }
} 