import express from 'express';
import cors from 'cors';
import { accountsRouter } from './routes/accounts.js';
import { transactionsRouter } from './routes/transactions.js';

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN ?? 'http://localhost:5173' }));
app.use(express.json());

app.get('/api/health', (_req, res) => res.json({ ok: true }));

app.use('/api/accounts', accountsRouter);
app.use('/api', transactionsRouter);

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    console.error(err);
    res.status(500).json({ error: 'internal server error' });
});

const port = Number(process.env.PORT ?? 4000);
app.listen(port, () => {
    console.log(`Bank API listening on http://localhost:${port}`);
});
