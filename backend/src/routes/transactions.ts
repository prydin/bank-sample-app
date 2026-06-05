import { Router } from 'express';
import { pool } from '../db.js';

export const transactionsRouter = Router();

transactionsRouter.get('/accounts/:id/transactions', async (req, res, next) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ error: 'invalid id' });
        }
        const { rows } = await pool.query(
            `SELECT id, account_id, posted_at, description, merchant, category, amount_cents
             FROM transactions
             WHERE account_id = $1
             ORDER BY posted_at DESC
             LIMIT 50`,
            [id]
        );
        res.json(rows);
    } catch (err) {
        next(err);
    }
});
