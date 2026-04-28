import { Outlet } from 'react-router-dom';
import { BottomNav } from './BottomNav';
import '../app.css';

export function AppLayout() {
  return (
    <div className="app-shell">
      <main className="app-main">
        <Outlet />
      </main>
      <BottomNav />
    </div>
  );
}
