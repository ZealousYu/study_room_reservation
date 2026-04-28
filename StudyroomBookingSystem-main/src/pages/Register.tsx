import { useEffect, useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';

export function Register() {
  const { register, user } = useApp();
  const navigate = useNavigate();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    if (user) navigate('/', { replace: true });
  }, [user, navigate]);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (password !== password2) {
      setToast('两次密码不一致');
      return;
    }
    const r = register(phone, password);
    setToast(r.message);
    if (r.ok) {
      setTimeout(() => navigate('/', { replace: true }), 400);
    }
  }

  return (
    <div className="app-shell" style={{ padding: '1.25rem 1.1rem 2rem' }}>
      <div style={{ maxWidth: 400, margin: '0 auto' }}>
        <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-muted)' }}>
          新用户
        </p>
        <h1 className="page-title" style={{ marginTop: '0.25rem' }}>
          创建账号
        </h1>
        <p className="page-sub">密码需 8–16 位字母与数字组合</p>

        <form onSubmit={handleSubmit} className="card">
          <div className="field">
            <label htmlFor="reg-phone">手机号</label>
            <input
              id="reg-phone"
              className="input"
              type="tel"
              inputMode="numeric"
              placeholder="11 位手机号"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="reg-pw">密码</label>
            <input
              id="reg-pw"
              className="input"
              type="password"
              placeholder="字母+数字"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="reg-pw2">确认密码</label>
            <input
              id="reg-pw2"
              className="input"
              type="password"
              value={password2}
              onChange={(e) => setPassword2(e.target.value)}
            />
          </div>
          <button type="submit" className="btn btn-primary btn-block">
            注册并登录
          </button>
          <p style={{ marginTop: '1rem', textAlign: 'center', fontSize: '0.88rem' }}>
            已有账号？{' '}
            <Link to="/login" className="link-inline">
              去登录
            </Link>
          </p>
        </form>
      </div>
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </div>
  );
}
