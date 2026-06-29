import { useEffect, useState } from 'react';
import { getServerIp } from '../api';

export function Footer() {
    const [ip, setIp] = useState<string | null>(null);

    useEffect(() => {
        getServerIp()
            .then(setIp)
            .catch(() => setIp(null));
    }, []);

    return (
        <footer className="mx-auto max-w-6xl px-6 py-6 text-center">
            <p className="text-xs text-gray-400">
                Served by {ip ?? 'unknown'}
            </p>
        </footer>
    );
}
