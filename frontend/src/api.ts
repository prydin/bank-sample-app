export interface Account {
    id: number;
    name: string;
    type: 'checking' | 'savings' | 'credit';
    account_number: string;
    balance_cents: number;
    currency: string;
    opened_at: string;
}

export interface Transaction {
    id: number;
    account_id: number;
    posted_at: string;
    description: string;
    merchant: string | null;
    category: string | null;
    amount_cents: number;
}

async function getJson<T>(url: string): Promise<T> {
    const res = await fetch(url);
    if (!res.ok) {
        throw new Error(`Request failed: ${res.status}`);
    }
    return res.json() as Promise<T>;
}

export const api = {
    listAccounts: () => getJson<Account[]>('/api/accounts'),
    getAccount: (id: number) => getJson<Account>(`/api/accounts/${id}`),
    listTransactions: (id: number) => getJson<Transaction[]>(`/api/accounts/${id}/transactions`),
};

export function formatMoney(cents: number, currency = 'USD'): string {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency,
    }).format(cents / 100);
}

export function maskAccountNumber(num: string): string {
    return `••••${num.slice(-4)}`;
}
