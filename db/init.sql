-- Schema for Northwind Bank sample app
CREATE TABLE IF NOT EXISTS accounts (
    id              SERIAL PRIMARY KEY,
    name            TEXT        NOT NULL,
    type            TEXT        NOT NULL CHECK (type IN ('checking', 'savings', 'credit')),
    account_number  TEXT        NOT NULL UNIQUE,
    balance_cents   BIGINT      NOT NULL DEFAULT 0,
    currency        CHAR(3)     NOT NULL DEFAULT 'USD',
    opened_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transactions (
    id           SERIAL PRIMARY KEY,
    account_id   INTEGER     NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    posted_at    TIMESTAMPTZ NOT NULL,
    description  TEXT        NOT NULL,
    merchant     TEXT,
    category     TEXT,
    amount_cents BIGINT      NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_transactions_account_posted
    ON transactions (account_id, posted_at DESC);
