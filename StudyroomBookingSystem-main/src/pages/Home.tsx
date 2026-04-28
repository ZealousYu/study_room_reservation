import { Link } from 'react-router-dom';
import { useApp } from '../context/AppContext';

export function Home() {
  const { user, reservations, checkIn } = useApp();

  const ongoing = reservations.find(
    (r) => r.status === '进行中' && !r.checkInAt
  );

  return (
    <>
      <header className="hero-banner">
        <h2>你好，{user?.name ?? '访客'} · 今天也要专注一点点</h2>
        <p>选座、点单、打卡，都在下面 — 界面为演示数据，未接后端。</p>
        {ongoing && (
          <div className="checkin-bar">
            <span style={{ fontSize: '0.88rem' }}>
              进行中：{ongoing.seatCode} · {ongoing.date}{' '}
              {ongoing.slots[0]}
              {ongoing.slots.length > 1 ? ' 起' : ''}
            </span>
            <button
              type="button"
              className="btn btn-primary"
              style={{ padding: '0.45rem 0.9rem', fontSize: '0.88rem' }}
              onClick={() => checkIn(ongoing.id)}
            >
              立即打卡
            </button>
          </div>
        )}
      </header>

      <section className="card" style={{ marginBottom: '0.85rem' }}>
        <h3 style={{ margin: '0 0 0.75rem', fontSize: '1rem' }}>快速开始</h3>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: '0.65rem',
          }}
        >
          <Link
            to="/booking"
            className="card"
            style={{
              margin: 0,
              padding: '0.9rem',
              textDecoration: 'none',
              color: 'inherit',
              display: 'block',
            }}
          >
            <span style={{ fontSize: '1.25rem' }}>🪑</span>
            <div style={{ fontWeight: 600, marginTop: '0.35rem' }}>预约座位</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
              平面图 / 筛选
            </div>
          </Link>
          <Link
            to="/food"
            className="card"
            style={{
              margin: 0,
              padding: '0.9rem',
              textDecoration: 'none',
              color: 'inherit',
              display: 'block',
            }}
          >
            <span style={{ fontSize: '1.25rem' }}>☕</span>
            <div style={{ fontWeight: 600, marginTop: '0.35rem' }}>轻食点单</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
              咖啡 / 茶饮 / 小食
            </div>
          </Link>
        </div>
      </section>

      <section className="card">
        <h3 style={{ margin: '0 0 0.5rem', fontSize: '1rem' }}>学习小贴士</h3>
        <ul
          style={{
            margin: 0,
            paddingLeft: '1.1rem',
            color: 'var(--text-muted)',
            fontSize: '0.88rem',
          }}
        >
          <li>预约开始后 1 小时内记得打卡，避免记为违约。</li>
          <li>配送至座位的订单需打卡后，店员才会开始制作。</li>
          <li>未支付订单 30 分钟会自动取消（演示中可手动取消）。</li>
        </ul>
      </section>
    </>
  );
}
