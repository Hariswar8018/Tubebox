require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./db');
const { GoogleGenAI } = require('@google/genai');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Initialize Gemini (Automatically uses GEMINI_API_KEY from environment variables)
const ai = new GoogleGenAI();

app.post('/api/generate-campaign', async (req, res) => {
    const requestData = req.body;
    
    // Default values if not provided
    const crop = requestData.crop || "Cotton";
    const state = requestData.state || "Maharashtra";
    const district = requestData.district || "Yavatmal";
    const pestRisk = requestData.pestRisk || "High - Pink Bollworm";
    const weather = "High Humidity, Intermittent Rain";
    const language = requestData.language || "Marathi";

    const prompt = `
You are an expert AI agriculture marketing assistant for Syngenta. 
Generate a hyperlocal marketing campaign targeting farmers based on the following context:
- State: ${state}
- District: ${district}
- Crop: ${crop}
- Pest Risk: ${pestRisk}
- Language: ${language}

Return your response ONLY as a raw JSON object (without Markdown formatting or \`\`\`json blocks) with the following exact structure:
{
    "personas": {
        "farmerA": {
            "name": "Farmer A",
            "profile": "Low literacy | Feature phone",
            "channel": "Voice Call",
            "content": "(Write a short 30-word voice call script in ${language} warning about ${pestRisk} for ${crop})",
            "engagement": 76
        },
        "farmerB": {
            "name": "Farmer B",
            "profile": "Smartphone | Tech Savvy",
            "channel": "WhatsApp",
            "content": "(Write a WhatsApp message with emojis in ${language})",
            "engagement": 88
        },
        "retailer": {
            "name": "Retailer",
            "profile": "Inventory Manager",
            "channel": "SMS",
            "content": "(Write an English SMS to the retailer to stock up on Amplego/Proclaim)",
            "engagement": 92
        }
    },
    "battleArena": [
        {
            "variant": "Variant A (Fear-based)",
            "message": "(Write a short 1-sentence English fear-based marketing message)",
            "score": 68,
            "color": "warning"
        },
        {
            "variant": "Variant B (Profit-based)",
            "message": "(Write a short 1-sentence English profit-based marketing message)",
            "score": 84,
            "color": "success"
        },
        {
            "variant": "Variant C (Community-based)",
            "message": "(Write a short 1-sentence English community-based marketing message)",
            "score": 72,
            "color": "primary"
        }
    ]
}
`;

    try {
        let aiGeneratedContent;
        
        if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'your_gemini_api_key_here') {
            const response = await ai.models.generateContent({
                model: 'gemini-2.5-flash',
                contents: prompt
            });
            // Clean up the response if it has markdown formatting
            let text = response.text.replace(/```json/g, '').replace(/```/g, '').trim();
            aiGeneratedContent = JSON.parse(text);
        } else {
            // Fallback if API key is not set
            console.warn("GEMINI_API_KEY not set. Using fallback mock data.");
            aiGeneratedContent = {
                personas: {
                    farmerA: {
                        name: "Farmer A",
                        profile: "Age 58 | Feature phone | Low literacy | Marathi",
                        channel: "Voice Call",
                        content: "[Mock] नमस्कार! सिंजेंटा तर्फे हा एक महत्त्वाचा संदेश आहे. यवतमाळ जिल्ह्यात सध्याच्या हवामानामुळे कापसावर गुलाबी बोंडअळीचा धोका वाढला आहे. कृपया त्वरित Amplego ची फवारणी करा आणि आपले पीक वाचवा.",
                        engagement: 76
                    },
                    farmerB: {
                        name: "Farmer B",
                        profile: "Age 24 | Smartphone | Tech Savvy | Marathi/English",
                        channel: "WhatsApp",
                        content: "[Mock] 🚨 *High Risk Alert: Pink Bollworm* 🚨\nनमस्कार शेतकरी मित्रांनो, तुमच्या कापूस पिकामध्ये गुलाबी बोंडअळीचा प्रादुर्भाव होण्याची दाट शक्यता आहे.\n\n🛡️ *Solution:* 'Amplego' किंवा 'Proclaim' फवारणी करा.\n\n👇 *Click below to find the nearest dealer.*",
                        engagement: 88
                    },
                    retailer: {
                        name: "Retailer / Dealer",
                        profile: "Inventory Manager | Smartphone | Quick Actions",
                        channel: "SMS & App Notification",
                        content: "[Mock] Dealer Alert: High demand expected for Amplego & Proclaim in Yavatmal due to Pink Bollworm risk. Current stock: 45 units. Recommended restock: 200 units. Reply 'ORDER' to process.",
                        engagement: 92
                    }
                },
                battleArena: [
                    { variant: "Variant A (Fear-based)", message: "[Mock] Pink Bollworm risk is critical this week.", score: 68, color: "warning" },
                    { variant: "Variant B (Profit-based)", message: "[Mock] Protect your yield and increase your returns.", score: 84, color: "success" },
                    { variant: "Variant C (Community-based)", message: "[Mock] Farmers nearby are already taking action.", score: 72, color: "primary" }
                ]
            };
        }

        const mockResponse = {
            status: "success",
            campaignDetails: {
                id: "CMP-" + Math.floor(Math.random() * 10000),
                crop: crop,
                state: state,
                district: district,
                pestRisk: pestRisk,
                weather: weather,
            },
            personas: aiGeneratedContent.personas,
            battleArena: aiGeneratedContent.battleArena,
            explainabilityFlow: [
                {
                    step: "Signal Detection",
                    icon: "fa-cloud-rain",
                    title: "Weather Signal",
                    desc: "High humidity (85%) & rain in " + district
                },
                {
                    step: "Risk Prediction",
                    icon: "fa-bug",
                    title: "Pest Risk",
                    desc: "70% probability of " + pestRisk
                },
                {
                    step: "AI Strategy",
                    icon: "fa-bullseye",
                    title: "Campaign Strategy",
                    desc: "Targeting tailored per Persona"
                },
                {
                    step: "Outcome Prediction",
                    icon: "fa-chart-line",
                    title: "Expected Engagement",
                    desc: "Based on real-time optimization"
                }
            ]
        };

        if (db.hasDb()) {
            const campaignName = pestRisk.split('-')[1]?.trim() + " Alert" || "Campaign " + mockResponse.campaignDetails.id;
            const region = `${district}, ${state}`;
            const engagement = mockResponse.personas.farmerB.engagement; 
            
            db.query(
                `INSERT INTO campaigns (campaign_name, crop, region, language, engagement_prediction) 
                 VALUES ($1, $2, $3, $4, $5)`,
                [campaignName, crop, region, language, engagement]
            ).catch(err => console.error("DB Insert Error:", err));
        }

        res.json(mockResponse);

    } catch (error) {
        console.error("Gemini Generation Error:", error);
        res.status(500).json({ status: "error", message: "Failed to generate AI content" });
    }
});

app.get('/api/campaigns', async (req, res) => {
    try {
        if (!db.hasDb()) {
            return res.json([
                { id: 1, campaign_name: "Pink Bollworm Alert", crop: "Cotton", region: "Yavatmal, Maharashtra", language: "Marathi", engagement_prediction: 74, created_at: new Date().toISOString() },
                { id: 2, campaign_name: "Blast Control - Kharif", crop: "Rice", region: "Rourkela, Odisha", language: "Odia", engagement_prediction: 68, created_at: new Date(Date.now() - 86400000).toISOString() }
            ]);
        }

        const result = await db.query('SELECT * FROM campaigns ORDER BY created_at DESC LIMIT 10');
        res.json(result.rows);
    } catch (err) {
        console.error("Error fetching campaigns:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

