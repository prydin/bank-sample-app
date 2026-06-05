import { Router } from 'express';
import { pool } from '../db.js';

export const accountsRouter = Router();

accountsRouter.get('/', async (_req, res, next) => {
    try {
        const { rows } = await pool.query(
            `SELECT id, name, type, account_number, balance_cents, currency, opened_at
             FROM accounts
             ORDER BY
                CASE type WHEN 'checking' THEN 1 WHEN 'savings' THEN 2 WHEN 'credit' THEN 3 ELSE 4 END,
                id`
        );
        res.json(rows);
    } catch (err) {
        next(err);
    }
});

accountsRouter.get('/:id', async (req, res, next) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ error: 'invalid id' });
        }
        const { rows } = await pool.query(
            `SELECT id, name, type, account_number, balance_cents, currency, opened_at
             FROM accounts
             WHERE id = $1`,
            [id]
        );
        if (rows.length === 0) {
            return res.status(404).json({ error: 'not found' });
        }
        res.json(rows[0]);
    } catch (err) {
        next(err);
    }
});
