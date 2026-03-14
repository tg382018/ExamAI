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
    explanation: string;
    options: string[];
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
        temperature: 0.4, // Increased temperature for better topic diversity and adherence
        messages: [
            {
                role: 'system',
                content: `Sen dünyanın en titiz, en dikkatli ve matematiksel/mantıksal hata yapması imkansız olan bir eğitimcisin. Ürettiğin her soruyu defalarca kontrol eden bir algoritma gibi çalışmalısın.

KRİTİK TALİMATLAR:
1. Kesinlikle tam olarak ${plan.questionCount} adet soru üret.
2. ÖNCE ÇÖZ, SONRA ŞIKLARLI OLUŞTUR: Her soru için önce 'explanation' alanını doldur. Soruyu adım adım çöz ve kesin sonucu bul. 
3. ŞIKLARIN TUTARLILIĞI: Bulduğun kesin sonuç, 'options' dizisindeki 5 şıktan biri olmak ZORUNDADIR. Eğer bulduğun sonuç şıklarda yoksa soruyu baştan yaz.
4. DOĞRU ŞIKKI ETİKETLEME: 'options' listesi içindeki doğru seçeneğin sonuna boşluk bırakarak " (DC)" ekle. 
   Örnek: "options": ["A) 10", "B) 20 (DC)", "C) 30", "D) 40", "E) 50"]
5. MATEMATİKSEL FORMAT (ÖNEMLİ): Matematiksel formülleri, denklemleri, kesirleri ve üslü sayıları yazarken MUTLAKA standart LaTeX formatını kullan. JSON formatını bozmamak için backslash sınırlarına dikkat et. Satır içi formüller için her zaman $ ve $ kullan (örneğin: $x^2 + y^2 = z^2$ veya $\\frac{1}{2}$). Ayrı satırda büyük formüller için $$ ve $$ kullan (örneğin: $$a^2 + b^2 = c^2$$). Asla düz metin ile x^2 yazma, daima $ içine al. (Kesinlikle \\( veya \\[ kullanma!)
6. YASAKLAR:
   - Şıklarda 'options' içinde formül varsa, formülü de $ $ arasına al.
   - 'explanation' metninin içine asla " (DC)" yazma. Bu etiket sadece ve sadece 'options' dizisindeki tek bir şıkta olmalı.
   - Bulduğun sonuçtan farklı bir şıkkı asla (DC) olarak işaretleme.
   - İşlem hatası yapma. (Örn: 7+24+25 toplamını 56 olarak bulmalısın).
7. Şıklar makul ve çeldiriciler kuvvetli olmalıdır.
8. KONUYA BAĞLILIK: Sadece ve sadece '${plan.outline.join(', ')}' konuları ile ilgili soru üret. Dışına çıkma.${plan.needsAscii ? '\n9. GEOMETRİK ŞEKİL ZORUNLULUĞU (HAYATİ ÖNEMDE): Bu bir GEOMETRİ sınavıdır. Sorduğun HER SORU için mutlaka "asciiArt" alanına bir şekil çizmelisiniz. Şekil içermeyen bir soru KESİNLİKLE KABUL EDİLEMEZ. Soru metni "Yukarıdaki şekilde...", "Yandaki üçgende..." gibi ifadelerle bu şekle atıfta bulunmalıdır. \n   - Şekil çizerken JSON formatını bozmamak için \\ (backslash) ASLA KULLANMA. \n   - Sadece şu karakterleri kullan: | (düz çizgi), - (yatay), / (eğik), _ (alt çizgi), . (nokta), + (köşe), A, B, C, D (köşe isimleri).\n   - "asciiArt" alanı asla null olmamalı, mutlaka en az 3-4 satırlık anlamlı bir geometrik şekil içermelidir.' : ''}

Lütfen her soru için şu verileri JSON formatında üret:
- orderIndex: Sorunun sırası
- text: Soru metni
- explanation: Detaylı ve hatasız çözüm anlatımı (Önce burayı doldur ki mantığın otursun)
- options: 5 adet şık (Doğru olanın sonuna " (DC)" ekle)
- difficulty: Kolay|Orta|Zor
- topicTag: Konu başlığı${plan.needsAscii ? '\n- asciiArt: Soruya ait ASCII çizimi (MUTLAKA DOLDUR)' : ''}

Format (JSON):
{
  "questions": [
    {
      "orderIndex": 0,
      "text": "...",
      "explanation": "...",
      "options": ["A) ...", "B) ... (DC)", "C) ...", "D) ...", "E) ..."],
      "difficulty": "...",
      "topicTag": "..."${plan.needsAscii ? ',\n      "asciiArt": "... ASCII GEOMETRİ ŞEKLİ BURAYA ..."' : ''}
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
