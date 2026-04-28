import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import './admin.css';

const nav = [
  { to: '/admin', label: '概览', end: true },
  { to: '/admin/seats', label: '座位管理' },
  { to: '/admin/reservations', label: '预约管理' },
  { to: '/admin/products', label: '商品管理' },
  { to: '/admin/orders', label: '订单管理' },
  { to: '/admin/breach', label: '违约管理' },
];

export function AdminLayout() {
  const { adminUser, adminLogout } = useApp();
  const navigate = useNavigate();

  return (
    <div className="admin-root">
      <aside className="admin-sider">
        <div className="admin-brand">
          <strong>BookSpace</strong>
          <span>自习室后台</span>
        </div>
        <nav className="admin-nav">
          {nav.map(({ to, label, end }) => (
            <NavLink key={to} to={to} end={end} className={({ isActive }) => (isActive ? 'active' : undefined)}>
              {label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <div className="admin-main">
        <header className="admin-header">
          <span style={{ fontSize: '0.9rem', color: '#666' }}>
            当前账号：{adminUser?.displayName ?? '—'}
          </span>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <a href="/" className="admin-btn" style={{ textDecoration: 'none', color: 'inherit' }}>
              用户端首页
            </a>
            <button
              type="button"
              className="admin-btn"
              onClick={() => {
                adminLogout();
                navigate('/admin/login');
              }}
            >
              退出
            </button>
          </div>
        </header>
        <div className="admin-content">
          <Outlet />
        </div>
      </div>
    </div>
  );
}
