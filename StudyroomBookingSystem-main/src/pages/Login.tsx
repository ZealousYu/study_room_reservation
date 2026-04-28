import { useEffect, useState, type FormEvent } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';

export function Login() {
  const { login, user } = useApp();
  const navigate = useNavigate();
  const loc = useLocation();
  const from = (loc.state as { from?: { pathname: string } })?.from?.pathname ?? '/';

  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    if (user) navigate(from, { replace: true });
  }, [user, navigate, from]);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const r = login(phone, password);
    setToast(r.message);
    if (r.ok) {
      setTimeout(() => navigate(from, { replace: true }), 400);
    }
  }

  return (
    <div className="app-shell" style={{ padding: '1.25rem 1.1rem 2rem' }}>
      <div style={{ maxWidth: 400, margin: '0 auto' }}>
        <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-muted)' }}>
          轻享自习空间
        </p>
        <h1 className="page-title" style={{ marginTop: '0.25rem' }}>
          欢迎回来
        </h1>
        <p className="page-sub">登录后可预约座位、点单轻食</p>

        <form onSubmit={handleSubmit} className="card">
          <div className="field">
            <label htmlFor="login-phone">手机号</label>
            <input
              id="login-phone"
              className="input"
              type="tel"
              inputMode="numeric"
              autoComplete="tel"
              placeholder="11 位手机号"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="login-pw">密码</label>
            <input
              id="login-pw"
              className="input"
              type="password"
              autoComplete="current-password"
              placeholder="请输入密码"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button type="submit" className="btn btn-primary btn-block">
            登录
          </button>
          <p style={{ marginTop: '1rem', textAlign: 'center', fontSize: '0.88rem' }}>
            <Link to="/forgot-password" className="link-inline">
              忘记密码
            </Link>
            {' · '}
            <Link to="/register" className="link-inline">
              注册账号
            </Link>
          </p>
        </form>
        <p style={{ marginTop: '1rem', textAlign: 'center', fontSize: '0.82rem' }}>
          <Link to="/admin/login" className="link-inline">
            管理员入口
          </Link>
        </p>
      </div>
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </div>
  );
}
