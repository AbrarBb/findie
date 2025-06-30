import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const now = new Date().toISOString()

    // Find expired posts
    const { data: expiredPosts, error: fetchError } = await supabaseClient
      .from('posts')
      .select('id, title, user_id, users(email, name)')
      .lt('expires_at', now)

    if (fetchError) {
      throw fetchError
    }

    console.log(`Found ${expiredPosts?.length || 0} expired posts`)

    if (expiredPosts && expiredPosts.length > 0) {
      // Delete expired posts
      const { error: deleteError } = await supabaseClient
        .from('posts')
        .delete()
        .lt('expires_at', now)

      if (deleteError) {
        throw deleteError
      }

      // Optionally, send notifications to users about expired posts
      // This would require implementing email/push notification service

      console.log(`Deleted ${expiredPosts.length} expired posts`)
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        deletedCount: expiredPosts?.length || 0,
        message: `Successfully processed ${expiredPosts?.length || 0} expired posts`
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in auto-expire-posts:', error)
    
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})