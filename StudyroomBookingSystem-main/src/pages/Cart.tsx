import { useMemo, useState, useRef } from 'react';
import { Link } from 'react-router-dom';
import { formatDeliveryStatus, useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';

export function Cart() {
  const {
    cart,
    setCartQty,
    removeFromCart,
    placeFoodOrder,
    payFoodOrder,
    cancelFoodOrder,
    foodOrders,
    reservations,
  } = useApp();
  const [delivery, setDelivery] = useState<'配送至座位' | '吧台自取'>('配送至座位');
  const [toast, setToast] = useState<string | null>(null);
  const processingRef = useRef<string | null>(null);

  const total = cart.reduce((s, l) => s + l.product.price * l.qty, 0);
  const unpaidOrders = useMemo(() => foodOrders.filter((o) => o.status === '待支付'), [foodOrders]);

  const ongoingReservation = reservations.find((r) => r.status === '进行中' && !r.checkInAt);
  const revId = ongoingReservation ? parseInt(ongoingReservation.id) : undefined;

  async function checkout() {
    if (cart.length === 0) {
      setToast('购物车是空的');
      return;
    }
    if (processingRef.current) return;
    processingRef.current = 'checkout';
  
    let revIdToUse: number | undefined = undefined;
    if (delivery === '配送至座位') {
      const ongoing = reservations.find((r) => r.status === '进行中' && !r.checkInAt);
      if (ongoing) {
        const parsed = parseInt(ongoing.id);
        if (!isNaN(parsed) && parsed > 0) {
          revIdToUse = parsed;
        } else {
          setToast('当前预约信息无效，请重新预约');
         processingRef.current = null;
          return;
        }
      } else {
        setToast('配送至座位需要有效预约，请先预约并支付');
        processingRef.current = null;
        return;
      }
    }
  
    const result = await placeFoodOrder(delivery, revIdToUse);
    processingRef.current = null;
    if (result) {
      setToast('订单已生成，请在下方「待支付订单」中完成支付');
    } else {
      setToast('下单失败，请稍后重试');
    }
  }

  async function pay(orderId: string) {
    if (processingRef.current) return;
    processingRef.current = orderId;
    await payFoodOrder(orderId);
    processingRef.current = null;
    setToast('支付成功');
  }

  async function handleCancel(orderId: string) {
    if (processingRef.current) return;
    processingRef.current = orderId;
    await cancelFoodOrder(orderId);
    processingRef.current = null;
    setToast('订单已取消');
  }

  return (
    <>
      <h1 className="page-title">购物车</h1>
      <p className="page-sub">确认商品与配送方式后下单</p>

      {unpaidOrders.length > 0 && (
        <section className="card" style={{ marginBottom: '0.85rem', borderColor: 'rgba(196, 127, 42, 0.35)' }}>
          <div style={{ fontWeight: 700, marginBottom: '0.65rem' }}>待支付订单</div>
          <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)', margin: '0 0 0.75rem' }}>
            下单后购物车会清空，请在此完成支付。
          </p>
          {unpaidOrders.map((o, i) => (
            <div
              key={o.orderNo}
              style={{
                padding: '0.65rem 0',
                borderTop: i === 0 ? 'none' : '1px solid var(--border)',
                display: 'flex',
                flexDirection: 'column',
                gap: 8,
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                <span style={{ fontSize: '0.88rem' }}>{o.orderNo}</span>
                <span className="badge badge-warn">{o.status}</span>
              </div>
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>{o.delivery}</div>
              <div style={{ fontWeight: 600 }}>¥{o.total}</div>
              <div style={{ display: 'flex', gap: 8 }}>
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
                  onClick={() => handleCancel(o.id)}
                >
                  取消订单
                </button>
              </div>
            </div>
          ))}
        </section>
      )}

      {cart.length === 0 ? (
        <div className="card empty-hint">
          购物车暂无商品
          <div style={{ marginTop: '0.75rem' }}>
            <Link to="/food" className="btn btn-primary" style={{ textDecoration: 'none' }}>
              去逛逛
            </Link>
          </div>
        </div>
      ) : (
        <>
          {cart.map((line) => (
            <div
              key={line.product.id}
              className="card"
              style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}
            >
              <div>
                <div style={{ fontWeight: 600 }}>{line.product.name}</div>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  ¥{line.product.price} ×{' '}
                  <input
                    type="number"
                    min={1}
                    max={99}
                    value={line.qty}
                    onChange={(e) => setCartQty(line.product.id, Number(e.target.value) || 1)}
                    style={{ width: 48, padding: '0.2rem 0.35rem' }}
                  />
                </div>
              </div>
              <button
                type="button"
                className="btn btn-ghost"
                style={{ fontSize: '0.82rem' }}
                onClick={() => removeFromCart(line.product.id)}
              >
                删除
              </button>
            </div>
          ))}

          <div className="card">
            <div style={{ fontWeight: 600, marginBottom: '0.5rem' }}>配送方式</div>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
              <input
                type="radio"
                name="dlv"
                checked={delivery === '配送至座位'}
                onChange={() => setDelivery('配送至座位')}
              />
              配送至座位（需先打卡，店员再制作）
            </label>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <input
                type="radio"
                name="dlv"
                checked={delivery === '吧台自取'}
                onChange={() => setDelivery('吧台自取')}
              />
              吧台自取（支付后即可制作）
            </label>
          </div>

          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>合计</span>
              <strong style={{ color: 'var(--primary)', fontSize: '1.1rem' }}>¥{total}</strong>
            </div>
          </div>

          <button
            type="button"
            className="btn btn-primary btn-block"
            onClick={checkout}
          >
            生成订单（待支付）
          </button>
        </>
      )}

      {foodOrders.length > 0 && (
        <section style={{ marginTop: '1.25rem' }}>
          <h2 style={{ fontSize: '1rem', margin: '0 0 0.5rem' }}>最近订单</h2>
          {foodOrders.slice(0, 5).map((o) => (
            <div key={o.orderNo} className="card" style={{ fontSize: '0.88rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>{o.orderNo}</span>
                <span className={`badge ${o.status === '待支付' ? 'badge-warn' : 'badge-ok'}`}>
                  {o.status}
                </span>
              </div>
              <div style={{ color: 'var(--text-muted)', marginTop: 4 }}>{o.delivery}</div>
              <div style={{ marginTop: 4, color: 'var(--primary)' }}>{formatDeliveryStatus(o)}</div>
              <div style={{ marginTop: 4 }}>¥{o.total}</div>
            </div>
          ))}
        </section>
      )}

      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}