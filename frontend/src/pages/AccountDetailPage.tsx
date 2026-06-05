import { Link, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ChevronLeft } from 'lucide-react';
import { api, formatMoney, maskAccountNumber } from '../api';
import { TransactionRow } from '../components/TransactionRow';

export function AccountDetailPage() {
    const { id } = useParams<{ id: string }>();
    const accountId = Number(id);

    const accountQuery = useQuery({
        queryKey: ['account', accountId],
        queryFn: () => api.getAccount(accountId),
        enabled: Number.isInteger(accountId),
    });

    const txQuery = useQuery({
        queryKey: ['transactions', accountId],
        queryFn: () => api.listTransactions(accountId),
        enabled: Number.isInteger(accountId),
    });

    if (accountQuery.isLoading || txQuery.isLoading) {
        return <div className="py-20 text-center text-slate-500">Loading account…</div>;
    }
    if (accountQuery.error || !accountQuery.data) {
        return <div className="py-20 text-center text-rose-600">Account not found.</div>;
    }

    const account = accountQuery.data;
    const transactions = txQuery.data ?? [];
    const negative = account.balance_cents < 0;

    return (
        <div className="space-y-8">
            <Link
                to="/"
                className="inline-flex items-center gap-1 text-sm font-medium text-brand-700 hover:text-brand-900"
            >
                <ChevronLeft className="h-4 w-4" />
                Back to accounts
            </Link>

            <section className="rounded-2xl bg-white p-8 shadow-card">
                <div className="text-xs uppercase tracking-wide text-slate-500">
                    {account.type === 'credit' ? 'Credit card' : account.type === 'savings' ? 'Savings' : 'Checking'}
                </div>
                <h1 className="mt-1 text-2xl font-semibold text-slate-900">{account.name}</h1>
                <div className="mt-1 text-sm text-slate-500">{maskAccountNumber(account.account_number)}</div>
                <div className="mt-6 flex items-baseline gap-3">
                    <span
                        className={`text-4xl font-semibold tracking-tight ${
                            negative ? 'text-rose-600' : 'text-slate-900'
                        }`}
                    >
                        {formatMoney(account.balance_cents, account.currency)}
                    </span>
                    <span className="text-sm text-slate-500">
                        {account.type === 'credit' ? 'Current balance' : 'Available balance'}
                    </span>
                </div>
            </section>

            <section className="overflow-hidden rounded-2xl bg-white shadow-card">
                <div className="flex items-center justify-between border-b border-slate-100 px-6 py-4">
                    <h2 className="text-base font-semibold text-slate-900">Recent transactions</h2>
                    <span className="text-xs text-slate-500">{transactions.length} shown</span>
                </div>
                {transactions.length === 0 ? (
                    <div className="px-6 py-12 text-center text-sm text-slate-500">
                        No transactions yet.
                    </div>
                ) : (
                    <table className="w-full">
                        <thead>
                            <tr className="border-b border-slate-100 text-left text-xs font-medium uppercase tracking-wide text-slate-500">
                                <th className="py-3 pl-6 pr-4">Date</th>
                                <th className="py-3 pr-4">Description</th>
                                <th className="py-3 pr-4">Category</th>
                                <th className="py-3 pl-4 pr-6 text-right">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            {transactions.map((tx) => (
                                <TransactionRow key={tx.id} tx={tx} currency={account.currency} />
                            ))}
                        </tbody>
                    </table>
                )}
            </section>
        </div>
    );
}
