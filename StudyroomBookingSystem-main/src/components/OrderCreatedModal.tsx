import { Link } from 'react-router-dom';

export type CreatedOrderInfo = {
  orderId: string;
  orderNo: string;
  total: number;
  delivery: string;
  paymentMethod: string;
  items: { name: string; qty: number; price: number }[];
};

export function OrderCreatedModal({
  order,
  onClose,
}: {
  order: CreatedOrderInfo;
  onClose: () => void;
}) {
  return (
    <div className="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="order-created-title">
      <div className="modal-card">
        <h2 id="order-created-title" className="modal-title">
          订单已创建
        </h2>
        <p className="modal-sub">订单号：{order.orderNo}</p>
        <p className="modal-sub">配送：{order.delivery}</p>
        <p className="modal-sub">支付：{order.paymentMethod}</p>
        <ul className="modal-items">
          {order.items.map((item, idx) => (
            <li key={idx}>
              {item.name} × {item.qty}
              <span>¥{(item.price * item.qty).toFixed(2)}</span>
            </li>
          ))}
        </ul>
        <div className="modal-total">
          <span>实付金额</span>
          <strong>¥{order.total}</strong>
        </div>
        <div className="modal-actions">
          <Link
            to="/orders"
            className="btn btn-primary btn-block"
            style={{ textDecoration: 'none' }}
            onClick={onClose}
          >
            查看订单
          </Link>
          <button type="button" className="btn btn-ghost btn-block" onClick={onClose}>
            关闭
          </button>
        </div>
      </div>
    </div>
  );
}
