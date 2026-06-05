import pg from 'pg';

const { Pool, types } = pg;

// Parse BIGINT (int8, OID 20) as a JS number. Cent values fit safely
// within Number.MAX_SAFE_INTEGER and we need real numbers for arithmetic
// on the client (otherwise reduce() concatenates strings).
types.setTypeParser(20, (val) => (val === null ? null : Number(val)));

export const pool = new Pool({
    connectionString: process.env.DATABASE_URL ?? 'postgres://bank:bank@localhost:5432/bankdb',
});
