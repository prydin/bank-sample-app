import { Transaction, formatMoney } from '../api';

function formatDate(iso: string): string {
    return new Date(iso).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
    });
}

const categoryColors: Record<string, string> = {
    Income:        'bg-emerald-50 text-emerald-700',
    Groceries:     'bg-amber-50 text-amber-700',
    Dining:        'bg-orange-50 text-orange-700',
    Utilities:     'bg-sky-50 text-sky-700',
    Transfer:      'bg-slate-100 text-slate-700',
    Transport:     'bg-indigo-50 text-indigo-700',
    Housing:       'bg-violet-50 text-violet-700',
    Health:        'bg-rose-50 text-rose-700',
    Entertainment: 'bg-pink-50 text-pink-700',
    Shopping:      'bg-fuchsia-50 text-fuchsia-700',
    Travel:        'bg-cyan-50 text-cyan-700',
    Payment:       'bg-emerald-50 text-emerald-700',
    Interest:      'bg-emerald-50 text-emerald-700',
};

export function TransactionRow({ tx, currency }: { tx: Transaction; currency: string }) {
    const isCredit = tx.amount_cents >= 0;
    const categoryClass = (tx.category && categoryColors[tx.category]) ?? 'bg-slate-100 text-slate-700';
    return (
        <tr className="border-b border-slate-100 last:border-0 hover:bg-slate-50">
            <td className="whitespace-nowrap py-4 pl-6 pr-4 text-sm text-slate-500">
                {formatDate(tx.posted_at)}
            </td>
            <td className="py-4 pr-4">
                <div className="text-sm font-medium text-slate-900">{tx.description}</div>
                {tx.merchant && <div className="text-xs text-slate-500">{tx.merchant}</div>}
            </td>
            <td className="py-4 pr-4">
                {tx.category && (
                    <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-medium ${categoryClass}`}>
                        {tx.category}
                    </span>
                )}
            </td>
            <td
                className={`whitespace-nowrap py-4 pl-4 pr-6 text-right text-sm font-semibold ${
                    isCredit ? 'text-emerald-600' : 'text-rose-600'
                }`}
            >
                {isCredit ? '+' : ''}
                {formatMoney(tx.amount_cents, currency)}
            </td>
        </tr>
    );
}
