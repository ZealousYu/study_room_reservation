import { useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';
import { useState } from 'react';

export function Reservations() {
  const { reservations, cancelReservation, waitlist, cancelWaitlist } = useApp();
  const [toast, setToast] = useState<string | null>(null);

  function cancel(id: string) {
    const r = cancelReservation(id);
    setToast(r.message);
  }

  return (
    <>
      <h1 className="page-title">我的预约</h1>
      <p className="page-sub">座位、时段与状态</p>

      {reservations.length === 0 ? (
        <p className="empty-hint card">暂无预约记录</p>
      ) : (
        reservations.map((r) => (
          <div key={r.id} className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
              <div>
                <strong>{r.seatCode}</strong>
                <span style={{ marginLeft: 8, fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                  {r.date}
                </span>
              </div>
              <span
                className={`badge ${
                  r.status === '待支付'
                    ? 'badge-warn'
                    : r.status === '已取消'
                      ? 'badge-muted'
                      : 'badge-ok'
                }`}
              >
                {r.status}
              </span>
            </div>
            <div style={{ fontSize: '0.88rem', marginTop: 6 }}>
              {r.slots.join('，')}
            </div>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: 4 }}>
              ¥{r.fee}
              {r.checkInAt && ` · 已打卡 ${r.checkInAt}`}
            </div>
            {r.verifyCode && (
              <div style={{ marginTop: '0.5rem', fontSize: '0.85rem' }}>
                核销码：<code>{r.verifyCode}</code>
              </div>
            )}
            {(r.status === '待支付' || r.status === '进行中') && !r.checkInAt && (
              <button
                type="button"
                className="btn btn-ghost"
                style={{ marginTop: '0.65rem', fontSize: '0.85rem' }}
                onClick={() => cancel(r.id)}
              >
                取消预约
              </button>
            )}
            {(r.status === '待支付' || r.status === '进行中') && r.checkInAt && (
              <p style={{ marginTop: '0.65rem', fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                已打卡，不可取消预约
              </p>
            )}
          </div>
        ))
      )}

      <h2 style={{ fontSize: '1.05rem', margin: '1.5rem 0 0.5rem' }}>候补队列</h2>
      <p className="page-sub" style={{ marginTop: 0 }}>
        约满时提交的期望时段，可在有空档时通知您（演示）
      </p>

      {waitlist.filter((w) => w.status !== '已取消').length === 0 ? (
        <p className="empty-hint card">暂无候补记录</p>
      ) : (
        waitlist
          .filter((w) => w.status !== '已取消')
          .map((w) => (
            <div key={w.id} className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <strong>{w.seatCode}</strong>
                <span className="badge badge-ok">{w.status}</span>
              </div>
              <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: 4 }}>
                {w.date} · {w.slots.join('，')}
              </div>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: 4 }}>
                {w.createdAt}
              </div>
              {w.status === '排队中' && (
                <button
                  type="button"
                  className="btn btn-ghost"
                  style={{ marginTop: '0.55rem', fontSize: '0.85rem' }}
                  onClick={() => {
                    cancelWaitlist(w.id);
                    setToast('已取消候补');
                  }}
                >
                  取消候补
                </button>
              )}
            </div>
          ))
      )}

      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
