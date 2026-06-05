import { useQuery } from '@tanstack/react-query';
import { api, formatMoney } from '../api';
import { AccountCard } from '../components/AccountCard';

function greeting(): string {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
}

export function AccountsPage() {
    const { data: accounts, isLoading, error } = useQuery({
        queryKey: ['accounts'],
        queryFn: api.listAccounts,
    });

    if (isLoading) {
        return <div className="py-20 text-center text-slate-500">Loading accounts…</div>;
    }
    if (error || !accounts) {
        return <div className="py-20 text-center text-rose-600">Failed to load accounts.</div>;
    }

    const deposits = accounts.filter((a) => a.type !== 'credit');
    const credit = accounts.filter((a) => a.type === 'credit');

    const depositsTotal = deposits.reduce((sum, a) => sum + a.balance_cents, 0);
    const creditTotal = credit.reduce((sum, a) => sum + a.balance_cents, 0);
    const currency = accounts[0]?.currency ?? 'USD';

    return (
        <div className="space-y-10">
            <section className="rounded-2xl bg-gradient-to-br from-brand-700 to-brand-900 p-8 text-white shadow-card">
                <p className="text-sm font-medium text-brand-100">{greeting()}, Alex</p>
                <h1 className="mt-1 text-3xl font-semibold tracking-tight">Your accounts</h1>
                <div className="mt-6 grid gap-6 sm:grid-cols-2">
                    <div>
                        <div className="text-xs uppercase tracking-wide text-brand-200">Total deposits</div>
                        <div className="mt-1 text-3xl font-semibold">{formatMoney(depositsTotal, currency)}</div>
                    </div>
                    <div>
                        <div className="text-xs uppercase tracking-wide text-brand-200">Total credit balance</div>
                        <div className="mt-1 text-3xl font-semibold">{formatMoney(creditTotal, currency)}</div>
                    </div>
                </div>
            </section>

            {deposits.length > 0 && (
                <section>
                    <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-slate-500">
                        Deposits
                    </h2>
                    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                        {deposits.map((a) => (
                            <AccountCard key={a.id} account={a} />
                        ))}
                    </div>
                </section>
            )}

            {credit.length > 0 && (
                <section>
                    <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-slate-500">
                        Credit cards
                    </h2>
                    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                        {credit.map((a) => (
                            <AccountCard key={a.id} account={a} />
                        ))}
                    </div>
                </section>
            )}
        </div>
    );
}
