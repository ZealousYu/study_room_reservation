import type { DeliveryStatus, OrderStatus } from '../../context/AppContext';
import { formatDeliveryStatus, useApp } from '../../context/AppContext';

const ORDER_STATUSES: OrderStatus[] = [
  '待支付',
  '已支付',
  '制作中',
  '已完成',
  '已取消',
];

const DELIVERY_OPTIONS: { value: DeliveryStatus; label: string }[] = [
  { value: 'none', label: '—' },
  { value: 'await_checkin', label: '待打卡' },
  { value: 'making', label: '制作中' },
  { value: 'await_delivery', label: '待配送' },
  { value: 'shipping', label: '配送中' },
  { value: 'delivered', label: '已送达' },
  { value: 'pickup_ready', label: '吧台自取' },
  { value: 'completed', label: '已完成' },
];

export function OrdersAdmin() {
  const { foodOrders, adminSetOrderStatus, adminSetDeliveryStatus } = useApp();

  return (
    <>
      <h1 className="admin-page-title">订单管理</h1>
      <p className="admin-page-desc">点单状态与配送进度（演示）</p>

      <div className="admin-card admin-table-wrap">
        <table className="admin-table">
          <thead>
            <tr>
              <th>订单号</th>
              <th>金额</th>
              <th>配送方式</th>
              <th>订单状态</th>
              <th>配送/履约</th>
              <th>调整</th>
            </tr>
          </thead>
          <tbody>
            {foodOrders.map((o) => (
              <tr key={o.id}>
                <td>{o.id}</td>
                <td>¥{o.total}</td>
                <td>{o.delivery}</td>
                <td>{o.status}</td>
                <td style={{ fontSize: '0.82rem' }}>{formatDeliveryStatus(o)}</td>
                <td>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 6, minWidth: 140 }}>
                    <select
                      className="admin-input"
                      value={o.status}
                      onChange={(e) =>
                        adminSetOrderStatus(o.id, e.target.value as OrderStatus)
                      }
                    >
                      {ORDER_STATUSES.map((s) => (
                        <option key={s} value={s}>
                          {s}
                        </option>
                      ))}
                    </select>
                    <select
                      className="admin-input"
                      value={o.deliveryStatus}
                      onChange={(e) =>
                        adminSetDeliveryStatus(
                          o.id,
                          e.target.value as DeliveryStatus
                        )
                      }
                    >
                      {DELIVERY_OPTIONS.map((d) => (
                        <option key={d.value} value={d.value}>
                          {d.label}
                        </option>
                      ))}
                    </select>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
