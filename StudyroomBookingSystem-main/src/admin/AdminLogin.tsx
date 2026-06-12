import { useEffect, useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';
import './admin.css';

export function AdminLogin() {
  const { adminUser, adminLogin } = useApp();
  const navigate = useNavigate();
  const [account, setAccount] = useState('gft141');
  const [password, setPassword] = useState('');
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    if (adminUser) navigate('/admin', { replace: true });
  }, [adminUser, navigate]);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const r = await adminLogin(account, password);
    setToast(r.message);
    if (r.ok) {
      setTimeout(() => navigate('/admin', { replace: true }), 300);
    }
  }

  return (
    <div className="admin-login">
      <div className="admin-login-card">
        <h1>管理员登录</h1>
        <p>使用后台管理员账号登录（示例：gft141 / 141414）</p>
        <form onSubmit={handleSubmit}>
          <div className="admin-field">
            <label htmlFor="adm-acc">账号</label>
            <input
              id="adm-acc"
              autoComplete="username"
              value={account}
              onChange={(e) => setAccount(e.target.value)}
            />
          </div>
          <div className="admin-field">
            <label htmlFor="adm-pw">密码</label>
            <input
              id="adm-pw"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button type="submit" className="admin-btn admin-btn-primary" style={{ width: '100%', padding: '0.65rem' }}>
            登录
          </button>
        </form>
        <p style={{ marginTop: '1rem', fontSize: '0.85rem', textAlign: 'center' }}>
          <a href="/login" style={{ color: '#2d6a4f' }}>
            返回用户端登录
          </a>
        </p>
      </div>
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </div>
  );
}
