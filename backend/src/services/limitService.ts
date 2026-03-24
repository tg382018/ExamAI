import prisma from '../config/prisma';

export const SUBSCRIPTION_LIMITS = {
  FREE: {
    maxExamsPerDay: 3,
    maxAutoPilotConfigs: 0,
  },
  PRO: {
    maxExamsPerDay: 25,
    maxAutoPilotConfigs: 20,
  }
};

export class LimitService {
  static async getUserLimits(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { subscriptionTier: true, email: true }
    });
    
    // Developer bypass
    if (user?.email === 'tgulck@gmail.com') {
      return SUBSCRIPTION_LIMITS.PRO;
    }

    const tier = (user?.subscriptionTier || 'FREE') as keyof typeof SUBSCRIPTION_LIMITS;
    return SUBSCRIPTION_LIMITS[tier];
  }

  static async checkExamLimit(userId: string): Promise<{ allowed: boolean; remaining: number }> {
    const limits = await this.getUserLimits(userId);
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tonight = new Date();
    tonight.setHours(23, 59, 59, 999);

    const count = await prisma.exam.count({
      where: {
        userId,
        createdAt: {
          gte: today,
          lte: tonight,
        }
      }
    });

    const allowed = count < limits.maxExamsPerDay;
    const remaining = Math.max(0, limits.maxExamsPerDay - count);

    return { allowed, remaining };
  }

  static async checkAutoPilotLimit(userId: string): Promise<{ allowed: boolean; count: number }> {
    const limits = await this.getUserLimits(userId);
    
    // We count active configs
    const count = await prisma.autoPilotConfig.count({
      where: {
        userId,
        isActive: true
      }
    });

    const allowed = count < limits.maxAutoPilotConfigs;
    return { allowed, count };
  }
}
