import { createClient } from "@supabase/supabase-js"

if (!import.meta.env.VITE_SUPABASE_URL || !import.meta.env.VITE_SUPABASE_KEY) {
    throw new Error('Missing Supabase environment variables')
}

const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_KEY,
    {
        auth: {
            autoRefreshToken: true,
            persistSession: true
        }
    }
)

export { supabase }