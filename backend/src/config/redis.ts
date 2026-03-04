// BullMQ uses its own bundled ioredis — pass connection options (not an IORedis instance)
// to avoid version mismatch. For general use, we also export an IORedis instance.
import IORedis from 'ioredis';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

// Parsed connection options for BullMQ
function parseRedisUrl(url: string) {
    const parsed = new URL(url);
    return {
        host: parsed.hostname || 'localhost',
        port: parseInt(parsed.port || '6379', 10),
        password: parsed.password || undefined,
        db: parseInt(parsed.pathname?.slice(1) || '0', 10) || 0,
    };
}

export const redisConnectionOptions = parseRedisUrl(redisUrl);

// General IORedis client (for non-BullMQ usage if needed)
export const redis = new IORedis(redisUrl, {
    maxRetriesPerRequest: null,
});

export default redis;
