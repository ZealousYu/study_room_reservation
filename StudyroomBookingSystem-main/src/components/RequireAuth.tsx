import type { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useApp } from '../context/AppContext';

export function RequireAuth({ children }: { children: ReactNode }) {
  const { user } = useApp();
  const loc = useLocation();
  if (!user) {
    return <Navigate to="/login" state={{ from: loc }} replace />;
  }
  return <>{children}</>;
}
