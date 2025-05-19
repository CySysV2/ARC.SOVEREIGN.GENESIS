import DefaultTheme from 'vitepress/theme'
import './custom.css'

export default {
  ...DefaultTheme,
  Layout() {
    return {
      template: `
        <div class="navbar">
          <img src="https://media.digital-fabrica.com/logos/fabrica.svg" class="logo" alt="DF Logo"/>
          <nav>
            <a href="https://digital-fabrica.com">Home</a>
            <a href="https://civic.digital-fabrica.com">Civic</a>
            <a href="https://qic.digital-fabrica.com">QIC</a>
            <a href="https://whitepaper.digital-fabrica.com">Whitepaper</a>
            <a href="https://blog.digital-fabrica.com">Blog</a>
          </nav>
        </div>
        <DefaultTheme.Layout />
      `
    }
  }
} 