import { User } from "@supabase/supabase-js"
import { reactive } from "vue"

interface UserState {
  user: User | null
}

const state: UserState = reactive({
  user: null,
})

export const store = {
  state: state
}
