import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import type { ProductCategory } from '../context/AppContext';
import { useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';

const CATS: ProductCategory[] = ['咖啡', '茶饮', '甜品', '小吃'];

export function Food() {
  const { products, addToCart, cart } = useApp();
  const [cat, setCat] = useState<ProductCategory | '全部'>('全部');
  const [toast, setToast] = useState<string | null>(null);

  const list = useMemo(() => {
    const base = products.filter((p) => p.onShelf);
    if (cat === '全部') return base;
    return base.filter((p) => p.category === cat);
  }, [products, cat]);

  const cartCount = cart.reduce((s, l) => s + l.qty, 0);

  return (
    <>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
        <div>
          <h1 className="page-title" style={{ marginBottom: 0 }}>轻食点单</h1>
          <p className="page-sub" style={{ marginBottom: 0 }}>咖啡 · 茶饮 · 甜品 · 小吃</p>
        </div>
        <Link
          to="/cart"
          className="btn btn-ghost"
          style={{ whiteSpace: 'nowrap', textDecoration: 'none' }}
        >
          购物车 {cartCount > 0 ? `(${cartCount})` : ''}
        </Link>
      </div>

      <div className="chip-row" style={{ marginBottom: '0.85rem' }}>
        <button
          type="button"
          className={`chip ${cat === '全部' ? 'on' : ''}`}
          onClick={() => setCat('全部')}
        >
          全部
        </button>
        {CATS.map((c) => (
          <button
            key={c}
            type="button"
            className={`chip ${cat === c ? 'on' : ''}`}
            onClick={() => setCat(c)}
          >
            {c}
          </button>
        ))}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
        {list.map((p) => (
          <div key={p.id} className="card" style={{ display: 'flex', gap: '0.85rem' }}>
            <div
              style={{
                width: 72,
                height: 72,
                borderRadius: 12,
                background: 'linear-gradient(145deg, #e8efe8, #dde8e0)',
                flexShrink: 0,
                display: 'grid',
                placeItems: 'center',
                fontSize: '1.75rem',
              }}
              aria-hidden
            >
              {p.category === '咖啡' || p.category === '茶饮' ? '☕' : '🍰'}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontWeight: 700 }}>{p.name}</div>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: 2 }}>
                {p.desc}
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: 4 }}>
                库存 {p.stock}
              </div>
              <div style={{ marginTop: '0.45rem', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
                <span>
                  <strong style={{ color: 'var(--primary)' }}>¥{p.price}</strong>
                  <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginLeft: 6 }}>
                    ★ {p.rating}
                  </span>
                </span>
                <button
                  type="button"
                  className="btn btn-primary"
                  style={{ padding: '0.35rem 0.75rem', fontSize: '0.85rem' }}
                  onClick={() => {
                    const r = addToCart(p);
                    if (!r.ok) setToast(r.message);
                  }}
                >
                  加入购物车
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
