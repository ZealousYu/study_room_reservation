import { useState } from 'react';
import { formatDeliveryStatus, useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';

export function Orders() {
  const { foodOrders, payFoodOrder, cancelFoodOrder } = useApp();
  const [toast, setToast] = useState<string | null>(null);

  function pay(orderId: string) {
    payFoodOrder(orderId);
    setToast('支付成功');
  }

  return (
    <>
      <h1 className="page-title">轻食订单</h1>
      <p className="page-sub">订单号、商品、金额、配送进度</p>

      {foodOrders.length === 0 ? (
        <p className="empty-hint card">暂无订单</p>
      ) : (
        foodOrders.map((o) => (
          <div key={o.id} className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <strong>{o.id}</strong>
              <span
                className={`badge ${
                  o.status === '待支付'
                    ? 'badge-warn'
                    : o.status === '已取消'
                      ? 'badge-muted'
                      : 'badge-ok'
                }`}
              >
                {o.status}
              </span>
            </div>
            <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', marginTop: 4 }}>
              {o.createdAt} · {o.delivery}
            </div>
            <div style={{ fontSize: '0.85rem', marginTop: 6, color: 'var(--primary)' }}>
              配送/履约：{formatDeliveryStatus(o)}
            </div>
            <ul style={{ margin: '0.5rem 0 0', paddingLeft: '1.1rem', fontSize: '0.9rem' }}>
              {o.items.map((l) => (
                <li key={l.product.id}>
                  {l.product.name} × {l.qty}
                </li>
              ))}
            </ul>
            <div style={{ marginTop: '0.5rem', fontWeight: 600 }}>¥{o.total}</div>
            {o.status === '待支付' && (
              <div style={{ display: 'flex', gap: 8, marginTop: '0.65rem' }}>
                <button
                  type="button"
                  className="btn btn-primary"
                  style={{ flex: 1, fontSize: '0.88rem' }}
                  onClick={() => pay(o.id)}
                >
                  立即支付
                </button>
                <button
                  type="button"
                  className="btn btn-ghost"
                  style={{ fontSize: '0.88rem' }}
                  onClick={() => {
                    cancelFoodOrder(o.id);
                    setToast('订单已取消');
                  }}
                >
                  取消
                </button>
              </div>
            )}
          </div>
        ))
      )}
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
