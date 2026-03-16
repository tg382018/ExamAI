import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
    const tokens = await prisma.deviceToken.findMany();
    console.log('Registered Tokens:', tokens);
    const users = await prisma.user.findMany({ select: { id: true, email: true } });
    console.log('Users:', users);
}
main();
