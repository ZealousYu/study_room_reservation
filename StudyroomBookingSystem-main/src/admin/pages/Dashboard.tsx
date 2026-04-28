import { useMemo } from 'react';
import { useApp } from '../../context/AppContext';

export function Dashboard() {
  const { reservations, foodOrders, waitlist, breachRecords, products } = useApp();

  const stats = useMemo(
    () => ({
      res: reservations.length,
      orders: foodOrders.length,
      wl: waitlist.filter((w) => w.status === '排队中').length,
      breach: breachRecords.length,
      lowStock: products.filter((p) => p.stock < 10).length,
    }),
    [reservations, foodOrders, waitlist, breachRecords, products]
  );

  return (
    <>
      <h1 className="admin-page-title">运营概览</h1>
      <p className="admin-page-desc">演示数据与客户端共用，刷新后部分状态会重置</p>

      <div className="admin-stats">
        <div className="admin-stat">
          <div className="num">{stats.res}</div>
          <div className="lab">预约记录</div>
        </div>
        <div className="admin-stat">
          <div className="num">{stats.orders}</div>
          <div className="lab">点单订单</div>
        </div>
        <div className="admin-stat">
          <div className="num">{stats.wl}</div>
          <div className="lab">候补中</div>
        </div>
        <div className="admin-stat">
          <div className="num">{stats.breach}</div>
          <div className="lab">违约记录</div>
        </div>
        <div className="admin-stat">
          <div className="num">{stats.lowStock}</div>
          <div className="lab">低库存商品</div>
        </div>
      </div>

      <div className="admin-card">
        <strong>快捷说明</strong>
        <ul style={{ margin: '0.75rem 0 0', paddingLeft: '1.2rem', color: '#555', fontSize: '0.88rem', lineHeight: 1.6 }}>
          <li>座位：可启用/禁用；用户端仅展示启用座位。</li>
          <li>配送单：用户打卡后订单进入制作；请在订单中推进配送状态。</li>
          <li>商品：可改库存、上下架、与客户端点单联动。</li>
        </ul>
      </div>
    </>
  );
}
