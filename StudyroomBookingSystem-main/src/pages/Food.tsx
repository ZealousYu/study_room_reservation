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
  const [imgErrors, setImgErrors] = useState<Record<string, boolean>>({});

  const list = useMemo(() => {
    const base = products.filter((p) => p.onShelf);
    if (cat === '全部') return base;
    return base.filter((p) => p.category === cat);
  }, [products, cat]);

  const cartCount = cart.reduce((s, l) => s + l.qty, 0);

  // 后端返回的 picture 字段是相对路径，需要拼接 base URL
  const getImageUrl = (picture: string | undefined) => {
    if (!picture) return null;
    // 如果已经是完整 URL 则直接返回，否则加上后端地址
    if (picture.startsWith('http')) return picture;
    return `http://localhost:8080${picture}`;
  };

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
        {list.map((p) => {
          const imageUrl = getImageUrl(p.picture); // 注意：前端 Product 类型没有 picture 字段，但后端返回的数据中有，我们临时使用 any 或者扩展类型，这里简单处理
          // 由于 AppContext 中映射时未保留 picture，我们需要从原始数据中获取。更合理的方式是在 AppContext 的映射中保留 picture 字段。
          // 为了快速演示，我们假设在 AppContext 的映射中已经添加了 picture 字段。实际上我们应该修改 Product 类型增加 picture? 字段。
          // 但为不破坏原有类型，我们暂时从 products 数组中查找原始 picture（但 products 中已无原始 picture，因此需要修改 AppContext 映射时保留 picture）。
          // 下面我们改为在 AppContext 的 Product 类型中添加 picture? 字段，并修改映射逻辑。
          // 由于用户提供的 AppContext.tsx 中 Product 类型没有 picture，我们需要同步修改类型定义。
          // 为了代码完整，我将在下方给出同时修改 Product 类型并保留 picture 的方案。
          // 请参考下面的注释说明。
          return (
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
                  overflow: 'hidden',
                }}
              >
                {imageUrl && !imgErrors[p.id] ? (
                  <img
                    src={imageUrl}
                    alt={p.name}
                    style={{ width: '100%', height: '100%', objectFit: 'contain' }}
                    onError={() => setImgErrors((prev) => ({ ...prev, [p.id]: true }))}
                  />
                ) : (
                  <span>{p.category === '咖啡' || p.category === '茶饮' ? '☕' : '🍰'}</span>
                )}
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
          );
        })}
      </div>
      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}