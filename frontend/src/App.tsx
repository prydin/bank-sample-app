import { Routes, Route } from 'react-router-dom';
import { Header } from './components/Header';
import { AccountsPage } from './pages/AccountsPage';
import { AccountDetailPage } from './pages/AccountDetailPage';

export default function App() {
    return (
        <div className="min-h-full">
            <Header />
            <main className="mx-auto max-w-6xl px-6 py-10">
                <Routes>
                    <Route path="/" element={<AccountsPage />} />
                    <Route path="/accounts/:id" element={<AccountDetailPage />} />
                </Routes>
            </main>
        </div>
    );
}
