import { useState } from 'react';
import { maskPhone, useApp } from '../../context/AppContext';

export function BreachAdmin() {
  const { breachRecords, adminClearBreachLimit } = useApp();
  const [phone, setPhone] = useState('');

  return (
    <>
      <h1 className="admin-page-title">违约管理</h1>
      <p className="admin-page-desc">违约记录与解除限制（演示：按手机号清除记录）</p>

      <div className="admin-card" style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'center' }}>
        <input
          className="admin-input"
          style={{ flex: 1, minWidth: 200, maxWidth: 280 }}
          placeholder="输入手机号解除限制"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        />
        <button
          type="button"
          className="admin-btn admin-btn-primary"
          onClick={() => {
            if (!/^1[3-9]\d{9}$/.test(phone.trim())) return;
            adminClearBreachLimit(phone.trim());
            setPhone('');
          }}
        >
          清除该用户违约记录
        </button>
      </div>

      <div className="admin-card admin-table-wrap">
        <table className="admin-table">
          <thead>
            <tr>
              <th>时间</th>
              <th>原因</th>
              <th>手机</th>
            </tr>
          </thead>
          <tbody>
            {breachRecords.map((b) => (
              <tr key={b.id}>
                <td>{b.at}</td>
                <td>{b.reason}</td>
                <td>{b.phone ? maskPhone(b.phone) : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
