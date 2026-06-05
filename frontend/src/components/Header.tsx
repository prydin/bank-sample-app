import { Link } from 'react-router-dom';
import { Landmark, Bell, UserCircle2 } from 'lucide-react';

export function Header() {
    return (
        <header className="bg-brand-800 text-white">
            <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
                <Link to="/" className="flex items-center gap-2">
                    <Landmark className="h-7 w-7" />
                    <span className="text-xl font-semibold tracking-tight">Northwind Bank</span>
                </Link>
                <nav className="hidden gap-6 text-sm font-medium text-brand-100 md:flex">
                    <Link to="/" className="hover:text-white">Accounts</Link>
                    <a className="cursor-not-allowed opacity-60" title="Demo only">Transfers</a>
                    <a className="cursor-not-allowed opacity-60" title="Demo only">Payments</a>
                    <a className="cursor-not-allowed opacity-60" title="Demo only">Cards</a>
                </nav>
                <div className="flex items-center gap-4">
                    <Bell className="h-5 w-5 text-brand-100" />
                    <div className="flex items-center gap-2">
                        <UserCircle2 className="h-7 w-7 text-brand-100" />
                        <span className="hidden text-sm font-medium md:block">Alex Morgan</span>
                    </div>
                </div>
            </div>
        </header>
    );
}
