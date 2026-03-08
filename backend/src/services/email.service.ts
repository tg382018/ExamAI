import nodemailer from 'nodemailer';

class EmailService {
    private transporter;

    constructor() {
        this.transporter = nodemailer.createTransport({
            host: process.env.SMTP_HOST,
            port: parseInt(process.env.SMTP_PORT || '587'),
            secure: process.env.SMTP_SECURE === 'true',
            auth: {
                user: process.env.SMTP_USER,
                pass: process.env.SMTP_PASS,
            },
            tls: {
                rejectUnauthorized: false
            }
        });
    }

    async sendVerificationCode(email: string, code: string) {
        const mailOptions = {
            from: process.env.SMTP_FROM,
            to: email,
            subject: 'ExamAI E-posta Doğrulama Kodu',
            html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
          <h2 style="color: #4F46E5; text-align: center;">ExamAI'ye Hoş Geldiniz!</h2>
          <p>Hesabınızı doğrulamak için lütfen aşağıdaki 6 haneli kodu kullanın:</p>
          <div style="background-color: #F3F4F6; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #1F2937;">${code}</span>
          </div>
          <p>Eğer bu hesabı siz oluşturmadıysanız, lütfen bu e-postayı dikkate almayın.</p>
          <hr style="margin: 20px 0; border: none; border-top: 1px solid #eee;" />
          <p style="font-size: 12px; color: #6B7280; text-align: center;">ExamAI Ekibi</p>
        </div>
      `,
        };

        try {
            await this.transporter.sendMail(mailOptions);
            console.log(`Verification email sent to ${email}`);
        } catch (error) {
            console.error('Error sending verification email:', error);
            // We don't throw here to avoid breaking the registration flow if email fails in dev
            // but in production, you might want to handle this differently.
        }
    }
}

export const emailService = new EmailService();
