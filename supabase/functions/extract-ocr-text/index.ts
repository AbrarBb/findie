import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { imageUrl } = await req.json()

    if (!imageUrl) {
      return new Response(
        JSON.stringify({ error: 'Image URL is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // For demo purposes, we'll simulate OCR extraction
    // In a real implementation, you would integrate with:
    // - Google Cloud Vision API
    // - AWS Textract
    // - Azure Computer Vision
    // - Tesseract.js

    const mockOcrResults = [
      "iPhone 13 Pro Max",
      "Apple Inc.",
      "Model: A2484",
      "Serial: F2LLMQJ0Q6L3",
      "Blue Titanium",
      "128GB Storage",
      "Property of John Doe",
      "Contact: +1-555-0123"
    ]

    // Simulate processing delay
    await new Promise(resolve => setTimeout(resolve, 2000))

    // Return mock extracted text
    const extractedText = mockOcrResults.join(' ')

    return new Response(
      JSON.stringify({ 
        success: true,
        extractedText,
        confidence: 0.95,
        detectedLanguage: 'en'
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