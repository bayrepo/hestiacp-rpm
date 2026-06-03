---
layout: page
title: Установка панели
---

<script setup>
  import PageHeader from './.vitepress/theme/components/PageHeader.vue';
  import InstallOptions from './.vitepress/theme/components/InstallOptions.vue';
  import InstallPage from './.vitepress/theme/components/InstallPage.vue';
  import { options } from './_data/options';
</script>

<InstallPage>
  <PageHeader>
    <template #title>Генератор конфигурации для быстрой установки панели управления сервером Hestia</template>
  </PageHeader>
  <PageHeader>
    <template #aside><a class="header-button" href="./docs/introduction/getting-started#требования">Посмотреть требования к установке</a></template>  
  </PageHeader>
  <InstallOptions :options="options"></InstallOptions>
</InstallPage>

<style>
.header-button {
  display: inline-block;
  border: 1px solid transparent;
  font-weight: 600;
  transition: color 0.25s, border-color 0.25s, background-color 0.25s;
  border-radius: 20px;
  padding: 0 20px;
  line-height: 38px;
  font-size: 14px;
  border-color: var(--vp-button-alt-border);
  color: var(--vp-button-alt-text);
  background-color: var(--vp-button-alt-bg);

  &:hover {
    border-color: var(--vp-button-alt-hover-border);
    color: var(--vp-button-alt-hover-text);
    background-color: var(--vp-button-alt-hover-bg);
  }
}
</style>

<style>
  .header-button {  
    color: white;
    background-color: var(--vp-c-brand);
  }  
  .header-button:hover {
    color: white;
    background-color: #d8036a;
  }  
</style>
