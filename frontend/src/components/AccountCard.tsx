import { Link } from 'react-router-dom';
import { Wallet, PiggyBank, CreditCard } from 'lucide-react';
import { Account, formatMoney, maskAccountNumber } from '../api';

function AccountIcon({ type }: { type: Account['type'] }) {
    const cls = 'h-6 w-6';
    switch (type) {
        case 'checking':
            return <Wallet className={cls} />;
        case 'savings':
            return <PiggyBank className={cls} />;
        case 'credit':
            return <CreditCard className={cls} />;
    }
}

export function AccountCard({ account }: { account: Account }) {
    const negative = account.balance_cents < 0;
    return (
        <Link
            to={`/accounts/${account.id}`}
            className="group block rounded-2xl bg-white p-5 shadow-card transition hover:-translate-y-0.5 hover:shadow-lg"
        >
            <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                    <span className="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-700">
                        <AccountIcon type={account.type} />
                    </span>
                    <div>
                        <div className="text-sm font-semibold text-slate-900">{account.name}</div>
                        <div className="text-xs uppercase tracking-wide text-slate-500">
                            {maskAccountNumber(account.account_number)}
                        </div>
                    </div>
                </div>
                <span className="text-xs font-medium uppercase tracking-wide text-slate-400 group-hover:text-brand-600">
                    View →
                </span>
            </div>
            <div className="mt-6 flex items-baseline justify-between">
                <span className="text-xs uppercase tracking-wide text-slate-500">
                    {account.type === 'credit' ? 'Current balance' : 'Available balance'}
                </span>
                <span
                    className={`text-2xl font-semibold ${negative ? 'text-rose-600' : 'text-slate-900'}`}
                >
                    {formatMoney(account.balance_cents, account.currency)}
                </span>
            </div>
        </Link>
    );
}
