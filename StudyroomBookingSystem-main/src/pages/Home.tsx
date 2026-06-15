import { Link } from 'react-router-dom';
import { useEffect, useMemo, useState } from 'react';
import { useApp } from '../context/AppContext';
import { Toast } from '../components/Toast';
import {
  checkinWindowHint,
  formatReservationTime,
  getCheckinWindowState,
} from '../utils/reservation';

export function Home() {
  const { user, reservations, announcements, checkIn } = useApp();
  const [toast, setToast] = useState<string | null>(null);
  const [checking, setChecking] = useState(false);
  const [, setTick] = useState(0);

  // 每分钟刷新打卡窗口状态
  useEffect(() => {
    const id = window.setInterval(() => setTick((t) => t + 1), 60_000);
    return () => window.clearInterval(id);
  }, []);

  const upcoming = useMemo(
    () =>
      reservations.filter(
        (r) => r.status === '预约成功' || r.status === '进行中'
      ),
    [reservations]
  );

  const checkinable = useMemo(
    () =>
      upcoming.find(
        (r) => r.status === '预约成功' && !r.checkInAt && getCheckinWindowState(r) === 'open'
      ) ?? null,
    [upcoming]
  );

  const nextReservation = useMemo(() => {
    if (checkinable) return checkinable;
    return (
      upcoming.find((r) => r.status === '预约成功' && !r.checkInAt) ?? upcoming[0] ?? null
    );
  }, [upcoming, checkinable]);

  const windowState = nextReservation ? getCheckinWindowState(nextReservation) : null;

  async function handleCheckIn() {
    if (!checkinable) return;
    setChecking(true);
    const result = await checkIn(parseInt(checkinable.id, 10));
    setChecking(false);
    setToast(result.message);
  }

  return (
    <>
      <header className="hero-banner">
        <h2>你好，{user?.name ?? '访客'} · 今天也要专注一点点</h2>
        <p>选座、点单、打卡，都在下面</p>

        {nextReservation && (
          <div className="checkin-bar" style={{ flexDirection: 'column', alignItems: 'stretch', gap: 8 }}>
            <div style={{ fontSize: '0.88rem' }}>
              <strong>{nextReservation.seatCode}</strong>
              <span style={{ marginLeft: 8, color: 'var(--text-muted)' }}>
                {formatReservationTime(nextReservation)}
              </span>
              <span style={{ marginLeft: 8 }} className="badge badge-ok">
                {nextReservation.status}
              </span>
            </div>
            {nextReservation.status === '预约成功' && !nextReservation.checkInAt && windowState && (
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                {checkinWindowHint(windowState)}
              </div>
            )}
            {checkinable && (
              <button
                type="button"
                className="btn btn-primary"
                style={{ padding: '0.45rem 0.9rem', fontSize: '0.88rem', alignSelf: 'flex-start' }}
                onClick={() => void handleCheckIn()}
                disabled={checking}
              >
                {checking ? '打卡中...' : '立即打卡'}
              </button>
            )}
          </div>
        )}
      </header>

      {upcoming.length > 0 && (
        <section className="card" style={{ marginBottom: '0.85rem' }}>
          <h3 style={{ margin: '0 0 0.75rem', fontSize: '1rem' }}>我的预约</h3>
          <div style={{ display: 'grid', gap: '0.55rem' }}>
            {upcoming.map((r) => (
              <div
                key={r.id}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  fontSize: '0.88rem',
                  padding: '0.5rem 0',
                  borderBottom: '1px solid var(--border)',
                }}
              >
                <div>
                  <strong>{r.seatCode}</strong>
                  <div style={{ color: 'var(--text-muted)', marginTop: 2 }}>
                    {formatReservationTime(r)}
                  </div>
                </div>
                <span className="badge badge-ok">{r.status}</span>
              </div>
            ))}
          </div>
          <Link to="/reservations" style={{ fontSize: '0.78rem', marginTop: '0.6rem', display: 'inline-block' }}>
            查看全部预约
          </Link>
        </section>
      )}

      <section className="card home-notice-card" style={{ marginBottom: '0.85rem' }}>
        <div className="home-notice-head">
          <h3 style={{ margin: 0, fontSize: '1rem' }}>最新公告</h3>
          <Link to="/announcements" style={{ fontSize: '0.78rem' }}>
            查看更多
          </Link>
        </div>
        {announcements.length === 0 ? (
          <div className="home-notice-empty">当前暂无公告</div>
        ) : (
          <div className="home-notice-list">
            {announcements.slice(0, 3).map((item) => (
              <article key={item.id} className="home-notice-item">
                <div className="home-notice-title">{item.title}</div>
                <p className="home-notice-content">{item.content}</p>
                <div className="home-notice-time">更新时间：{item.updatedAt}</div>
              </article>
            ))}
          </div>
        )}
      </section>

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
          <li>请在预约时间前后 15 分钟内打卡，超时未打卡将记为违约。</li>
          <li>配送至座位的订单需打卡后，店员才会开始制作。</li>
          <li>未支付订单 30 分钟会自动取消（演示中可手动取消）。</li>
        </ul>
      </section>

      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
