<template>
  <div v-if="!store.state.user" >
    <h2>Login</h2>
    <form @submit.prevent="handleLogin">
      <input type="email" v-model="email" placeholder="Email" required />
      <input v-if="loginMethod === 'password'" type="password" v-model="password" placeholder="Password" required />
      <select v-model="loginMethod">
        <option value="magic-link">Magic Link</option>
        <option value="password">Password</option>
      </select>
      <button type="submit">Login</button>
    </form>
  </div>
  <div v-else>
    <button @click="signOut">Logout</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { supabase } from "./db-client"
import { store } from "./store"

const email = ref("")
const password = ref("")
const loginMethod = ref("magic-link")

async function handleLogin() {
  try {
    if (loginMethod.value === "password") {
      const { error } = await supabase.auth.signInWithPassword(
        { email: email.value, password: password.value }
      )
      if (error) throw error
      // if (!session) {
      //   throw new Error("Session returned null")
      // }
      // store.state.user = session.user
      alert("Logged in successfully!")
    } else if (loginMethod.value === "magic-link") {
      const { error } = await supabase.auth.signInWithOtp(
        {
          email: email.value,
          options: {
            shouldCreateUser: false
          }
        }
      )
      if (error) throw error
      alert("Check your email for magic link!")
    }
  } catch (error) {
    if (error instanceof Error) {
      alert(error.message)
    } else {
      alert("An unexpected error occurred")
    }
  }
}

async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) {
    alert(error.message)
  }
}
</script>
