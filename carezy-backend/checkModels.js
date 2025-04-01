const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI("AIzaSyDUbBAvO4SVIumAaFL2M5gyJ0QVSfvgKrI"); // Replace with your actual API key

async function testModel() {
    try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.0-pro" }); // Trying a common model
        console.log("✅ Model is accessible:", model);
    } catch (error) {
        console.error("❌ Error accessing model:", error);
    }
}

testModel();

