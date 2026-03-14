import { generateDraftPlan } from './src/services/llm';
import dotenv from 'dotenv';

dotenv.config();

async function main() {
    const plan = await generateDraftPlan('geometri 5 soru Lise 1');
    console.log(JSON.stringify(plan, null, 2));
}

main().catch(console.error);
