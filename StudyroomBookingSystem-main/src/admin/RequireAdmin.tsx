import type { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';

export function RequireAdmin({ children }: { children: ReactNode }) {
  const { adminUser } = useApp();
  if (!adminUser) {
    return <Navigate to="/admin/login" replace />;
  }
  return <>{children}</>;
}
