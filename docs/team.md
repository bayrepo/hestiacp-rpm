---
layout: page
title: Команда
---

<style>
.VPTeamPageSection {
  margin-top: 50px !important;
}
</style>
<script setup>
  import { VPTeamPage, VPTeamPageTitle, VPTeamPageSection, VPTeamMembers } from "vitepress/theme";
  import { projectManagers, teamMembers, teamRpm } from "./_data/team";
</script>
  <VPTeamPageTitle>
    <template #title>Команда</template>
    <template #lead>
    Разработка Hestia осуществляется международной командой, некоторые из участников которой представлены ниже.
    </template>
  </VPTeamPageTitle>
  <VPTeamPageSection>
    <template #title>Руководители проекта</template>
    <template #members>
      <VPTeamMembers :members="projectManagers" />
    </template>
  </VPTeamPageSection>
  <VPTeamPageSection>
    <template #title>Участники команды</template>
    <template #members>
      <VPTeamMembers :members="teamMembers" />
    </template>
  </VPTeamPageSection>
  <VPTeamPageSection>
    <template #title>Сопровождающий RPM-версии</template>
    <template #members>
      <VPTeamMembers :members="teamRpm" />
    </template>
  </VPTeamPageSection>
