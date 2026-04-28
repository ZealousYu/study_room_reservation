import { Link } from 'react-router-dom';
import { maskPhone, useApp } from '../context/AppContext';

export function Profile() {
  const { user, logout, breachCount } = useApp();

  return (
    <>
      <h1 className="page-title">个人中心</h1>
      <p className="page-sub">账号信息与常用入口</p>

      {breachCount >= 3 && (
        <div
          className="card"
          style={{
            borderColor: 'rgba(196, 127, 42, 0.35)',
            background: 'rgba(196, 127, 42, 0.08)',
            marginBottom: '0.85rem',
          }}
        >
          您已累计违约 3 次，将被限制预约 7 天（演示文案）。
        </div>
      )}

      <div className="card" style={{ marginBottom: '0.85rem' }}>
        <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>昵称</div>
        <div style={{ fontWeight: 700, fontSize: '1.05rem' }}>{user?.name}</div>
        <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', marginTop: '0.65rem' }}>
          手机（脱敏）
        </div>
        <div>{user ? maskPhone(user.phone) : '—'}</div>
      </div>

      <nav className="card" style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
        <Link
          to="/reservations"
          style={{
            padding: '0.75rem 0',
            borderBottom: '1px solid var(--border)',
            textDecoration: 'none',
            color: 'var(--text)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          我的预约
          <span aria-hidden>›</span>
        </Link>
        <Link
          to="/orders"
          style={{
            padding: '0.75rem 0',
            borderBottom: '1px solid var(--border)',
            textDecoration: 'none',
            color: 'var(--text)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          轻食订单
          <span aria-hidden>›</span>
        </Link>
        <Link
          to="/breach"
          style={{
            padding: '0.75rem 0',
            textDecoration: 'none',
            color: 'var(--text)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          违约记录
          <span aria-hidden>›</span>
        </Link>
      </nav>

      <button
        type="button"
        className="btn btn-ghost btn-block"
        style={{ marginTop: '1rem' }}
        onClick={() => logout()}
      >
        退出登录
      </button>
    </>
  );
}
