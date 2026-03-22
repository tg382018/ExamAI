import prisma from '../config/prisma';
import { startOfDay, endOfDay } from 'date-fns';

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
      select: { subscriptionTier: true }
    });
    
    const tier = (user?.subscriptionTier || 'FREE') as keyof typeof SUBSCRIPTION_LIMITS;
    return SUBSCRIPTION_LIMITS[tier];
  }

  static async checkExamLimit(userId: string): Promise<{ allowed: boolean; remaining: number }> {
    const limits = await this.getUserLimits(userId);
    
    const today = startOfDay(new Date());
    const tonight = endOfDay(new Date());

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
    
    // We only count active configs for the limit
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
