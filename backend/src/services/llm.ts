import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export interface DraftPlan {
    isValid: boolean;
    error?: string;
    description: string;
    questionCount: number;
    difficulty: string;
    title: string;
    outline: string[];
    needsAscii: boolean;
    allowedTypes: string[]; // ['MULTIPLE_CHOICE', 'TRUE_FALSE', 'OPEN_ENDED']
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
4. "allowedTypes" alanı: Kullanıcı talebinde "test", "çoktan seçmeli", "açık uçlu", "klasik", "doğru yanlış" gibi ifadeler geçiyorsa bunlara uygun tipleri dizi olarak dön. Belirtilmemişse varsayılan olarak ["MULTIPLE_CHOICE"] dön.
   Tipler: "MULTIPLE_CHOICE", "TRUE_FALSE", "OPEN_ENDED"
5. "needsAscii" alanı: Eğer sınav konusu geometri, fizik veya grafik gerektiren bir konuysa (çizim gerektiriyorsa) true, aksi halde false dön.
6. Yalnızca JSON döndür.

DÖNÜŞ FORMATI:
{
  "isValid": boolean,
  "error": string | null,
  "title": "Sınav Başlığı/Konu",
  "description": "Genel sınav açıklaması ve teknik detaylar",
  "questionCount": number,
  "difficulty": "Kolay|Orta|Zor",
  "outline": ["konu başlığı 1", "konu başlığı 2"],
  "allowedTypes": ["MULTIPLE_CHOICE", "..."],
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
    type: 'MULTIPLE_CHOICE' | 'TRUE_FALSE' | 'OPEN_ENDED';
    text: string;
    explanation: string;
    options: string[]; // MCQ için 5 şık, TF için ["Doğru", "Yanlış"], OPEN_ENDED için boş []
    correctOption?: number; // MCQ/TF için index
    correctAnswer?: string; // OPEN_ENDED için anahtar kelimeler/kısa cevap
    difficulty: string;
    topicTag: string;
    asciiArt?: string;
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
        temperature: 0.4,
        messages: [
            {
                role: 'system',
                content: `Sen dünyanın en titiz eğitimcisisin. Aşağıdaki plana göre ${plan.questionCount} adet soru üret.

PLANDAKİ SORU TİPLERİ: ${plan.allowedTypes.join(', ')}

KRİTİK TALİMATLAR:
1. SORU TİPLERİNE GÖRE FORMAT:
   - MULTIPLE_CHOICE: 5 şıklı klasik test. Doğru şıkkın sonuna " (DC)" ekle.
   - TRUE_FALSE: "options" alanı ["Doğru", "Yanlış"] olsun. "correctOption" 0 (Doğru) veya 1 (Yanlış) değerini alsın. "correctAnswer" alanına "Doğru" veya "Yanlış" yaz.
   - OPEN_ENDED: "options" boş [] olsun. "correctOption" null kalsın. "correctAnswer" alanına sorunun beklenen doğru cevabını veya anahtar kelimelerini yaz.
2. MATEMATİKSEL FORMAT: Standart LaTeX kullan ($ $ veya $$ $$).
3. Karışık tip istenmişse, soruları dengeli dağıt veya kullanıcının özel sayısını (eğer belirtmişse) dikkate al.

JSON FORMATI:
{
  "questions": [
    {
      "orderIndex": number,
      "type": "MULTIPLE_CHOICE | TRUE_FALSE | OPEN_ENDED",
      "text": "...",
      "explanation": "...",
      "options": ["A) ...", "B) ... (DC)", ...],
      "correctOption": number | null,
      "correctAnswer": "...", 
      "difficulty": "...",
      "topicTag": "..."
    }
  ]
}

ÖNEMLİ: "correctAnswer" alanı, açık uçlu sorular için tüm kabul edilebilir varyasyonları veya detaylı bir değerlendirme anahtarını içermelidir (Örn: "Nokta veya 'da eki veya kesme işareti ile ayrılmış herhangi bir doğru ek").
`,
            },
            {
                role: 'user',
                content: `Prompt: ${prompt}\nPlan: ${JSON.stringify(plan)}`,
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
                content: `Sınav: ${plan.title}\nKonular: ${plan.outline.join(', ')}\nBu sınav için öğrenciye yönelik bir çalışma özeti yaz.`,
            },
        ],
    });

    return {
        questions: questionsRaw.questions as GeneratedQuestion[],
        summary: summaryCompletion.choices[0].message.content || '',
    };
}

export interface GradingResult {
    [questionId: string]: {
        score: number; // 0-100
        feedback: string;
    };
}

/**
 * Grade open-ended answers using AI.
 */
export async function gradeOpenEndedQuestions(
    gradingData: {
        questionId: string;
        questionText: string;
        studentAnswer: string;
        correctAnswerCriteria: string;
    }[]
): Promise<GradingResult> {
    if (gradingData.length === 0) return {};

    const completion = await openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4o',
        temperature: 0.3,
        messages: [
            {
                role: 'system',
                content: `Sen bir öğretmensin. Öğrencilerin açık uçlu sorulara verdiği cevapları, sorunun kendisi ve beklenen doğru cevap kriterleri ile karşılaştırarak puanlayacaksın.
                
KRALLAR:
1. Her soru için 0 ile 100 arasında bir tam sayı puan ver.
2. Anlam olarak doğruysa tam puan ver, eksikse kısmi puan ver, tamamen yanlışsa 0 ver.
3. Kısa ve yapıcı bir Türkçe geri bildirim yaz.
4. Yalnızca JSON döndür.

DÖNÜŞ FORMATI:
{
  "SORU_ID_1": { "score": 85, "feedback": "..." },
  "SORU_ID_2": { "score": 40, "feedback": "..." }
}
Cevap olarak YALNIZCA bu yapıda JSON dön. Anahtarlar (keys) mutlaka size verilen "questionId" değerleri olmalıdır.

EK TALİMATLAR:
1. Kesme işaretlerindeki farklılıkları ( ‘ , ’ , ' ) veya tırnak işaretlerini hata olarak görme, bunları aynı kabul et.
2. Öğrenci eğer bir noktalama işaretini hem simge olarak (.) hem de yazı olarak (Nokta) belirtmişse bunu doğru kabul et.
3. Büyük/küçük harf duyarlılığını (soru özelinde kritik değilse) göz ardı et.`,
            },
            {
                role: 'user',
                content: JSON.stringify(gradingData),
            },
        ],
        response_format: { type: 'json_object' },
    });

    const raw = JSON.parse(completion.choices[0].message.content || '{}');
    return raw as GradingResult;
}
