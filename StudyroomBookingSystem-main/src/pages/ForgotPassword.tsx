import { useState, type FormEvent, type MouseEvent } from 'react';
import { Link } from 'react-router-dom';
import { Toast } from '../components/Toast';
import { useApp } from '../context/AppContext'; 

export function ForgotPassword() {
  const {resetPassword} = useApp(); 
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState('');
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');
  const [toast, setToast] = useState<string | null>(null);
  const [countdown, setCountdown] = useState(0);

  function sendCode(e: MouseEvent<HTMLButtonElement>) {
    e.preventDefault();
    if (!/^1[3-9]\d{9}$/.test(phone)) {
      setToast('请输入有效手机号');
      return;
    }
    setToast('验证码已发送（演示：123456）');
    setCountdown(60);
    const timer = setInterval(() => {
      setCountdown((c) => {
        if (c <= 1) {
          clearInterval(timer);
          return 0;
        }
        return c - 1;
      });
    }, 1000);
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (password !== password2) {
      setToast('两次密码不一致');
      return;
    }
    if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$/.test(password)) {
      setToast('密码需为 8–16 位字母与数字组合');
      return;
    }

    const r = await resetPassword(phone, code, password);
    setToast(r.message);

    if (r.ok) {
      setTimeout(() => {
        window.location.href = '/login';
      }, 1500);
    }
  }

  return (
    <div className="app-shell" style={{ padding: '1.25rem 1.1rem 2rem' }}>
      <div style={{ maxWidth: 400, margin: '0 auto' }}>
        <h1 className="page-title">找回密码</h1>
        <p className="page-sub">通过手机验证码重置（演示环境：123456）</p>

        <form onSubmit={handleSubmit} className="card">
          <div className="field">
            <label htmlFor="fp-phone">手机号</label>
            <input
              id="fp-phone"
              className="input"
              type="tel"
              placeholder="11 位手机号"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
            />
          </div>

          <div className="field">
            <label htmlFor="fp-code">短信验证码</label>
            <div style={{ display: 'flex', gap: 8 }}>
              <input
                id="fp-code"
                className="input"
                style={{ flex: 1 }}
                placeholder="6 位验证码"
                value={code}
                onChange={(e) => setCode(e.target.value)}
              />
              <button
                type="button"
                className="btn btn-ghost"
                onClick={sendCode}
                disabled={countdown > 0}
              >
                {countdown > 0 ? `${countdown}s` : '获取验证码'}
              </button>
            </div>
          </div>

          <div className="field">
            <label htmlFor="fp-pw">新密码</label>
            <input
              id="fp-pw"
              className="input"
              type="password"
              placeholder="至少 8 位"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          <div className="field">
            <label htmlFor="fp-pw2">确认新密码</label>
            <input
              id="fp-pw2"
              className="input"
              type="password"
              placeholder="再次输入新密码"
              value={password2}
              onChange={(e) => setPassword2(e.target.value)}
            />
          </div>

          <button type="submit" className="btn btn-primary btn-block">
            确认重置
          </button>

          <p style={{ marginTop: '1rem', textAlign: 'center', fontSize: '0.88rem' }}>
            <Link to="/login" className="link-inline">
              返回登录
            </Link>
          </p>
        </form>
      </div>
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </div>
  );
}