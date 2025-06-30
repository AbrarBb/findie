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
    const { name, dob, extractedText, userId } = await req.json()

    if (!name || !dob || !extractedText || !userId) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Simple verification logic
    // In a real implementation, you would use more sophisticated matching
    const nameMatch = extractedText.toLowerCase().includes(name.toLowerCase())
    const dobMatch = extractedText.includes(dob) || extractedText.includes(dob.replace(/-/g, '/'))

    const isVerified = nameMatch && dobMatch

    // Update verification status
    const { error: updateError } = await supabaseClient
      .from('verifications')
      .update({
        status: isVerified ? 'approved' : 'rejected',
        extracted_name: name,
        extracted_dob: dob
      })
      .eq('user_id', userId)
      .eq('status', 'pending')

    if (updateError) {
      throw updateError
    }

    // Update user verification status if approved
    if (isVerified) {
      const { error: userUpdateError } = await supabaseClient
        .from('users')
        .update({ is_verified: true })
        .eq('id', userId)

      if (userUpdateError) {
        throw userUpdateError
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        isVerified,
        message: isVerified 
          ? 'Identity verified successfully!' 
          : 'Identity verification failed. Please check your information.'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})