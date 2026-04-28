import { useMemo, useState } from 'react';
import { useApp } from '../../context/AppContext';

export function ReservationsAdmin() {
  const { reservations, adminMarkReservation } = useApp();
  const [q, setQ] = useState('');

  const list = useMemo(() => {
    if (!q.trim()) return reservations;
    const t = q.trim().toLowerCase();
    return reservations.filter(
      (r) =>
        r.id.toLowerCase().includes(t) ||
        r.seatCode.toLowerCase().includes(t) ||
        r.date.includes(t)
    );
  }, [reservations, q]);

  return (
    <>
      <h1 className="admin-page-title">预约管理</h1>
      <p className="admin-page-desc">按预约编号/座位/日期筛选（演示）</p>

      <div className="admin-card" style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
        <input
          className="admin-input"
          style={{ flex: 1, maxWidth: 320 }}
          placeholder="搜索预约编号、座位号、日期"
          value={q}
          onChange={(e) => setQ(e.target.value)}
        />
      </div>

      <div className="admin-card admin-table-wrap">
        <table className="admin-table">
          <thead>
            <tr>
              <th>预约编号</th>
              <th>座位</th>
              <th>日期</th>
              <th>时段</th>
              <th>状态</th>
              <th>打卡</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            {list.map((r) => (
              <tr key={r.id}>
                <td>{r.id}</td>
                <td>{r.seatCode}</td>
                <td>{r.date}</td>
                <td style={{ fontSize: '0.82rem', maxWidth: 200 }}>{r.slots.join('，')}</td>
                <td>{r.status}</td>
                <td>{r.checkInAt ?? '—'}</td>
                <td>
                  {r.status === '进行中' && (
                    <span style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                      <button
                        type="button"
                        className="admin-btn"
                        onClick={() => adminMarkReservation(r.id, '到场')}
                      >
                        标记已到场
                      </button>
                      <button
                        type="button"
                        className="admin-btn"
                        onClick={() => adminMarkReservation(r.id, '违约')}
                      >
                        标记违约
                      </button>
                    </span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
