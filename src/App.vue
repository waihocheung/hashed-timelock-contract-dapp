<template>
  <!-- <img alt="Vue logo" src="./assets/logo.png"> -->
  <HashedTimeLockContractWorkflow />
</template>

<script>
import HashedTimeLockContractWorkflow from './components/HashedTimeLockContractWorkflow.vue'

export default {
  name: 'App',
  components: {
    HashedTimeLockContractWorkflow
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
