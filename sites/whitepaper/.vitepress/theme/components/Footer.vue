<template>
  <footer class="df-footer">
    <div class="footer-inner">
      <div class="left">
        <Logo site="whitepaper" variant="symbol" />
        <span class="epoch">Epoch: ΣΩΩ.5.0++</span>
      </div>
      <div class="right">
        <a href="https://digital-fabrica.com">Main</a>
        <a href="https://civic.digital-fabrica.com">Civic</a>
        <a href="https://qic.digital-fabrica.com">QIC</a>
        <a href="https://whitepaper.digital-fabrica.com">Whitepaper</a>
        <a href="https://fabrics.digital-fabrica.com">Fabrics</a>
        <a href="https://media.digital-fabrica.com">Media</a>
      </div>
    </div>
  </footer>
</template>

<script setup>
import Logo from './Logo.vue'
</script>

<style scoped>
.df-footer {
  background-color: #111;
  padding: 1.5rem 2rem;
  color: #ccc;
  font-size: 0.85rem;
  border-top: 1px solid #222;
}
.footer-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
}
.footer-inner a {
  margin-left: 1rem;
  color: #888;
  text-decoration: none;
  font-weight: 500;
}
.footer-inner a:hover {
  color: #fff;
}
.epoch {
  margin-left: 1rem;
  color: #aaa;
}
</style> 