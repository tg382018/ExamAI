import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export interface DraftPlan {
    questionCount: number;
    durationMin: number;
    difficulty: string;
    title: string;
    outline: string[];
}

/**
 * Fast call: Generate a plan from user prompt (used in POST /exam/draft)
 */
export async function generateDraftPlan(prompt: string): Promise<DraftPlan> {
    const completion = await openai.chat.completions.create({
        model: 'gpt-4o',
        temperature: 0.5,
        messages: [
            {
                role: 'system',
                content: `Sen yardımcı bir sınav planlayıcısısın. Kullanıcının talebine göre kısa bir sınav planı oluşturuyorsun. 
Yalnızca JSON döndür, başka metin ekleme. Format:
{
  "title": "sınav başlığı",
  "questionCount": 10,
  "durationMin": 30,
  "difficulty": "mixed",
  "outline": ["konu1", "konu2", "konu3"]
}`,
            },
            {
                role: 'user',
                content: prompt,
            },
        ],
        response_format: { type: 'json_object' },
    });
    const raw = completion.choices[0].message.content || '{}';
    return JSON.parse(raw) as DraftPlan;
}

export interface GeneratedQuestion {
    orderIndex: number;
    text: string;
    options: string[];
    correctOption: number;
    explanation: string;
    difficulty: string;
    topicTag: string;
}

/**
 * Full exam generation - called from worker.
 * Multi-step: outline → questions → explanations → summary
 */
export async function generateFullExam(
    prompt: string,
    plan: DraftPlan
): Promise<{ questions: GeneratedQuestion[]; summary: string }> {
    // Step 1: Generate questions with answer key + explanations (combined for efficiency)
    const questionsCompletion = await openai.chat.completions.create({
        model: 'gpt-4o',
        temperature: 0.7,
        messages: [
            {
                role: 'system',
                content: `Sen kapsamlı bir sınav üreticisisin. Türkçe sınav soruları üretiyorsun.
Aşağıdaki planı takip ederek tam sınav bilgisini JSON olarak döndür.
Her soru için 5 şık (A, B, C, D, E) üret. correctOption 0-tabanlı index (0=A, 1=B, ...).
Açıklama (explanation) Türkçe ve ayrıntılı olmalı.
Format (kesinlikle JSON döndür):
{
  "questions": [
    {
      "orderIndex": 0,
      "text": "soru metni",
      "options": ["A) ...", "B) ...", "C) ...", "D) ...", "E) ..."],
      "correctOption": 2,
      "explanation": "ayrıntılı çözüm açıklaması",
      "difficulty": "easy|medium|hard",
      "topicTag": "konu"
    }
  ]
}`,
            },
            {
                role: 'user',
                content: `Prompt: ${prompt}
Başlık: ${plan.title}
Soru sayısı: ${plan.questionCount}
Konular: ${plan.outline.join(', ')}
Zorluk: ${plan.difficulty}`,
            },
        ],
        response_format: { type: 'json_object' },
    });

    const questionsRaw = JSON.parse(questionsCompletion.choices[0].message.content || '{"questions":[]}');

    // Step 2: Generate AI summary
    const summaryCompletion = await openai.chat.completions.create({
        model: 'gpt-4o',
        temperature: 0.6,
        messages: [
            {
                role: 'system',
                content: `Sen bir eğitim asistanısın. Bir sınav için Türkçe, öğrenciye yönelik, kısa ve net bir çalışma özeti yaz. 
3-5 paragraf, konuları ve önemli noktaları vurgula. Markdown formatında yaz.`,
            },
            {
                role: 'user',
                content: `Sınav: ${plan.title}
Konular: ${plan.outline.join(', ')}
Bu sınav için öğrenciye yönelik bir çalışma özeti yaz.`,
            },
        ],
    });

    return {
        questions: questionsRaw.questions as GeneratedQuestion[],
        summary: summaryCompletion.choices[0].message.content || '',
    };
}
