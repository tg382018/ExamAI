import prisma from './src/config/prisma';

async function check() {
    const exams = await prisma.exam.findMany({
        orderBy: { createdAt: 'desc' },
        take: 10
    });
    console.log(JSON.stringify(exams, null, 2));
    process.exit(0);
}

check();
