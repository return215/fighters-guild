<template>
  <div>
    <h1>Hello Vue 3 + TypeScript</h1>
    <p>Edit <code>components</code> to get started!</p>
    <Auth />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import Auth from "./Auth.vue";
import { supabase } from "./db-client";
import { store } from "./store";

async function initializeAuth() {
  const userResponse = await supabase.auth.getUser()
  store.state.user = userResponse.data.user
}

onMounted(async () => {
  await initializeAuth()
})

supabase.auth.onAuthStateChange((event, session) => {
  if (event === "SIGNED_OUT") {
    store.state.user = null
  } else {
    store.state.user = session?.user ?? null
  }
})

</script>

<style scoped>
/* Component styles go here */
</style> 