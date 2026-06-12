import { useState, useRef } from 'react';
import { Link } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { OrderCreatedModal, type CreatedOrderInfo } from '../components/OrderCreatedModal';
import { Toast } from '../components/Toast';

type PaymentMethod = '支付宝' | '微信';

export function Cart() {
  const { cart, setCartQty, removeFromCart, placeFoodOrder, payFoodOrder, reservations } = useApp();
  const [delivery, setDelivery] = useState<'配送至座位' | '吧台自取'>('吧台自取');
  const [toast, setToast] = useState<string | null>(null);
  const [createdOrder, setCreatedOrder] = useState<CreatedOrderInfo | null>(null);
  const [payingMethod, setPayingMethod] = useState<PaymentMethod | null>(null);
  const processingRef = useRef<string | null>(null);

  const total = cart.reduce((s, l) => s + l.product.price * l.qty, 0);

  async function checkout(method: PaymentMethod) {
    if (cart.length === 0) {
      setToast('购物车是空的');
      return;
    }
    if (processingRef.current) return;
    processingRef.current = method;
    setPayingMethod(method);

    let revIdToUse: number | undefined;
    if (delivery === '配送至座位') {
      const ongoing = reservations.find((r) => r.status === '进行中' && !r.checkInAt);
      if (ongoing) {
        const parsed = parseInt(ongoing.id);
        if (!isNaN(parsed) && parsed > 0) {
          revIdToUse = parsed;
        } else {
          setToast('当前预约信息无效，请重新预约');
          processingRef.current = null;
          setPayingMethod(null);
          return;
        }
      } else {
        setToast('配送至座位需要有效预约，请先预约并支付');
        processingRef.current = null;
        setPayingMethod(null);
        return;
      }
    }

    const result = await placeFoodOrder(delivery, revIdToUse);
    if (!result) {
      setToast('下单失败，请确认已登录且后端服务正常');
      processingRef.current = null;
      setPayingMethod(null);
      return;
    }

    try {
      await payFoodOrder(result.orderId);
      setCreatedOrder({ ...result, paymentMethod: method });
    } catch {
      setToast('支付失败，请前往「我的 → 轻食订单」完成支付');
    } finally {
      processingRef.current = null;
      setPayingMethod(null);
    }
  }

  return (
    <>
      <h1 className="page-title">购物车</h1>
      <p className="page-sub">确认商品、配送方式与支付方式</p>

      {cart.length === 0 ? (
        <div className="card empty-hint">
          购物车暂无商品
          <div style={{ marginTop: '0.75rem' }}>
            <Link to="/food" className="btn btn-primary" style={{ textDecoration: 'none' }}>
              去点单
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
                checked={delivery === '吧台自取'}
                onChange={() => setDelivery('吧台自取')}
              />
              吧台自取（支付后即可制作）
            </label>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <input
                type="radio"
                name="dlv"
                checked={delivery === '配送至座位'}
                onChange={() => setDelivery('配送至座位')}
              />
              配送至座位（需先有进行中的预约）
            </label>
          </div>

          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.75rem' }}>
              <span>合计</span>
              <strong style={{ color: 'var(--primary)', fontSize: '1.1rem' }}>¥{total}</strong>
            </div>
            <div style={{ fontWeight: 600, marginBottom: '0.5rem' }}>支付方式</div>
            <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)', margin: '0 0 0.65rem' }}>
              以下为演示支付，点击后将创建订单并完成付款。
            </p>
            <button
              type="button"
              className="btn btn-primary btn-block"
              style={{ marginBottom: 8 }}
              disabled={payingMethod !== null}
              onClick={() => checkout('支付宝')}
            >
              {payingMethod === '支付宝' ? '支付中...' : '支付宝支付'}
            </button>
            <button
              type="button"
              className="btn btn-ghost btn-block"
              disabled={payingMethod !== null}
              onClick={() => checkout('微信')}
            >
              {payingMethod === '微信' ? '支付中...' : '微信支付'}
            </button>
          </div>
        </>
      )}

      {createdOrder && (
        <OrderCreatedModal order={createdOrder} onClose={() => setCreatedOrder(null)} />
      )}

      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
