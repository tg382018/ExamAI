import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export interface DraftPlan {
    isValid: boolean;
    error?: string;
    description: string;
    questionCount: number;
    durationMin: number;
    difficulty: string;
    title: string;
    outline: string[];
    needsAscii: boolean;
}

/**
 * Fast call: Generate a plan from user prompt (used in POST /exam/draft)
 */
export async function generateDraftPlan(prompt: string): Promise<DraftPlan> {
    const completion = await openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4o',
        temperature: 0.5,
        messages: [
            {
                role: 'system',
                content: `Sen bir AI sınav oluşturma uygulaması için çalışan uzman bir analiz asistanısın. Kullanıcının sınav talebini incele ve aşağıdaki kurallara göre bir plan veya hata mesajı üret.

KURALLAR:
1. Talebin sınav oluşturma ile bir ilgisi yoksa veya bilgiler bir sınav oluşturmak için (ders adı veya konu eksikliği gibi) çok yetersizse, "isValid": false dön.
2. "isValid": false durumunda, "error" kısmına neden sınav oluşturulamayacağını açıklayan nazik bir Türkçe mesaj yaz.
3. Kullanıcı 15'ten fazla soru isterse, soru sayısını otomatik olarak 15 ile sınırla. Soru sayısı belirtilmemişse varsayılan olarak 10 yap.
4. "needsAscii" alanı: Eğer sınav konusu geometri, fizik veya grafik gerektiren bir konuysa (çizim gerektiriyorsa) true, aksi halde false dön.
5. Sınavı henüz oluşturma, sadece teknik detayları içeren planı döndür.
6. Yalnızca JSON döndür.

DÖNÜŞ FORMATI:
{
  "isValid": boolean,
  "error": string | null,
  "title": "Sınav Başlığı/Konu",
  "description": "Genel sınav açıklaması ve teknik detaylar",
  "questionCount": number,
  "durationMin": number,
  "difficulty": "Kolay|Orta|Zor",
  "outline": ["konu başlığı 1", "konu başlığı 2"],
  "needsAscii": boolean
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
 */
export async function generateFullExam(
    prompt: string,
    plan: DraftPlan
): Promise<{ questions: GeneratedQuestion[]; summary: string }> {
    const questionsCompletion = await openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4o',
        temperature: 0.7,
        messages: [
            {
                role: 'system',
                content: `Sen profesyonel ve titiz bir eğitimcisin. Sana verilen sınav planına göre yüksek kaliteli bir sınav üret.
Kullanıcının talebi: ${prompt}
Plan Detayları:
- Başlık: ${plan.title}
- Açıklama: ${plan.description}
- Soru Sayısı: ${plan.questionCount}
- Konu: ${plan.outline.join(', ')}
- ASCII Çizim Gerekli mi: ${plan.needsAscii ? 'Evet' : 'Hayır'}

Lütfen her soru için şu verileri JSON formatında üret:
- orderIndex: Sorunun sırası
- text: Soru metni (Eğer ASCII çizim gerekliyse soru metnine dahil et)
- options: 5 adet şık (A, B, C, D, E şeklinde)
- correctOption: Doğru şıkkın indexi (0=A, 1=B, 2=C, 3=D, 4=E)
- explanation: Detaylı çözüm anlatımı
- difficulty: Sorunun zorluğu
- topicTag: Konu başlığı

Format (JSON):
{
  "questions": [
    {
      "orderIndex": 0,
      "text": "...",
      "options": ["A) ...", "B) ...", "C) ...", "D) ...", "E) ..."],
      "correctOption": 2,
      "explanation": "...",
      "difficulty": "...",
      "topicTag": "..."
    }
  ]
}`,
            },
        ],
        response_format: { type: 'json_object' },
    });

    const questionsRaw = JSON.parse(questionsCompletion.choices[0].message.content || '{"questions":[]}');

    // Step 2: Generate AI summary
    const summaryCompletion = await openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4o',
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
