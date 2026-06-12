import { useMemo, useState } from 'react';
import type { Seat } from '../context/AppContext';
import {
  BOOKING_HOURS,
  hourSlotLabel,
  useApp,
} from '../context/AppContext';
import { Toast } from '../components/Toast';

function feeForSlots(slots: string[]): number {
  const n = slots.length;
  const hourly = 15;
  const raw = n * hourly;
  const cap = 80;
  return Math.min(raw, cap);
}

export function Booking() {
  const {
    filterSeats,
    createReservation,
    payReservation,
    isHourTakenForSeat,
    isSeatDateFullyBooked,
    canBookSlots,
    joinWaitlist,
  } = useApp();

  const [filters, setFilters] = useState({
    outlet: false,
    lamp: false,
    divider: false,
    window: false,
  });

  const seats = useMemo(
    () => filterSeats(filters),
    [filterSeats, filters]
  );

  const [seat, setSeat] = useState<Seat | null>(null);
  const [date, setDate] = useState(() => new Date().toISOString().slice(0, 10));
  const [selectedSlots, setSelectedSlots] = useState<string[]>([]);
  const [waitlistSlots, setWaitlistSlots] = useState<string[]>([]);

  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [toast, setToast] = useState<string | null>(null);
  const [lastResId, setLastResId] = useState<string | null>(null);
  const [verifyCode, setVerifyCode] = useState('');

  const fullyBooked = seat
    ? isSeatDateFullyBooked(seat.code, date)
    : false;

  function toggleFilter(key: keyof typeof filters) {
    setFilters((f) => ({ ...f, [key]: !f[key] }));
  }

  function toggleHour(h: number) {
    if (!seat) return;
    const label = hourSlotLabel(h);
    if (isHourTakenForSeat(seat.code, date, h)) return;
    setSelectedSlots((prev) =>
      prev.includes(label) ? prev.filter((x) => x !== label) : [...prev, label].sort()
    );
  }

  /** 候补：任意时段均可点选（含已满） */
  function toggleWaitlistHour(h: number) {
    const label = hourSlotLabel(h);
    setWaitlistSlots((prev) =>
      prev.includes(label) ? prev.filter((x) => x !== label) : [...prev, label].sort()
    );
  }

  function nextFromSeat() {
    if (!seat) {
      setToast('请先选择座位');
      return;
    }
    setSelectedSlots([]);
    setWaitlistSlots([]);
    setStep(2);
  }

  function nextFromTime() {
    if (fullyBooked) {
      setToast('当日该座位已全部约满，请使用下方候补或更换日期/座位');
      return;
    }
    if (selectedSlots.length === 0) {
      setToast('请选择至少一个可预约时段');
      return;
    }
    if (!canBookSlots(seat!.code, date, selectedSlots)) {
      setToast('所选时段不可用，请去掉已满时段或更换时间');
      return;
    }
    setStep(3);
  }

  function submitWaitlist() {
    if (!seat) return;
    if (waitlistSlots.length === 0) {
      setToast('请至少选择一个期望时段');
      return;
    }
    joinWaitlist({
      seatCode: seat.code,
      date,
      slots: waitlistSlots,
    });
    setToast('已加入候补队列，有空位将通知您');
    setWaitlistSlots([]);
  }

  async function confirmReserve() {
    if (!seat) return;
    if (!canBookSlots(seat.code, date, selectedSlots)) {
      setToast('所选时段已满或冲突，请返回修改；心仪时段若已满可加入下方候补');
      return;
    }
    const r = await createReservation({
      seatCode: seat.code,
      date,
      slots: selectedSlots,
      fee: feeForSlots(selectedSlots),
    });
    if (!r) {
      setToast('创建预约失败，请稍后重试');
      return;
    }
    setLastResId(r.id);
    setVerifyCode(r.verifyCode);
    setToast('订单已创建，请选择支付方式');
  }

  async function mockPay(method: string) {
    if (!lastResId) {
      setToast('请先确认预约');
      return;
    }
    const ok = await payReservation(lastResId);
    if (!ok) {
      setToast('支付失败，请稍后重试');
      return;
    }
    setToast(`已跳转${method}（演示）· 支付成功`);
    setStep(1);
    setSeat(null);
    setSelectedSlots([]);
    setLastResId(null);
  }

  return (
    <>
      <h1 className="page-title">座位预约</h1>
      <p className="page-sub">选座 → 时段 → 确认费用与支付</p>

      {step === 1 && (
        <>
          <div className="card">
            <div style={{ fontWeight: 600, marginBottom: '0.6rem' }}>筛选条件（多选交集）</div>
            <div className="chip-row">
              {(
                [
                  ['outlet', '有插座'],
                  ['lamp', '有台灯'],
                  ['divider', '有挡板'],
                  ['window', '靠窗'],
                ] as const
              ).map(([k, lab]) => (
                <button
                  key={k}
                  type="button"
                  className={`chip ${filters[k] ? 'on' : ''}`}
                  onClick={() => toggleFilter(k)}
                >
                  {lab}
                </button>
              ))}
            </div>
          </div>

          <div className="card">
            <div style={{ fontWeight: 600, marginBottom: '0.65rem' }}>座位列表</div>
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))',
                gap: '0.55rem',
              }}
            >
              {seats.map((s) => (
                <button
                  key={s.id}
                  type="button"
                  onClick={() => setSeat(s)}
                  className="card"
                  style={{
                    margin: 0,
                    padding: '0.65rem 0.75rem',
                    textAlign: 'left',
                    cursor: 'pointer',
                    border:
                      seat?.id === s.id
                        ? '2px solid var(--primary)'
                        : '1px solid var(--border)',
                    background: seat?.id === s.id ? 'var(--bg-accent-soft)' : '#fff',
                  }}
                >
                  <div style={{ fontWeight: 700 }}>{s.code}</div>
                  <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                    {s.zone}
                  </div>
                  <div style={{ fontSize: '0.72rem', marginTop: '0.35rem', color: 'var(--text-muted)' }}>
                    {[
                      s.hasOutlet && '插座',
                      s.hasLamp && '台灯',
                      s.hasDivider && '挡板',
                      s.nearWindow && '靠窗',
                    ]
                      .filter(Boolean)
                      .join(' · ')}
                  </div>
                </button>
              ))}
            </div>
            {seats.length === 0 && (
              <p className="empty-hint" style={{ padding: '1rem 0' }}>
                没有同时满足所有条件的座位，请减少筛选。
              </p>
            )}
          </div>

          <button type="button" className="btn btn-primary btn-block" onClick={nextFromSeat}>
            下一步：选择时段
          </button>
        </>
      )}

      {step === 2 && seat && (
        <>
          <div className="card">
            <div style={{ fontSize: '0.88rem', color: 'var(--text-muted)' }}>已选座位</div>
            <div style={{ fontWeight: 700, fontSize: '1.05rem', marginTop: '0.2rem' }}>
              {seat.code} · {seat.zone}
            </div>
          </div>
          <div className="field">
            <label htmlFor="bk-date">预约日期</label>
            <input
              id="bk-date"
              className="input"
              type="date"
              value={date}
              min={new Date().toISOString().slice(0, 10)}
              onChange={(e) => {
                setDate(e.target.value);
                setSelectedSlots([]);
                setWaitlistSlots([]);
              }}
            />
          </div>

          <div className="card">
            <div style={{ fontWeight: 600, marginBottom: '0.5rem' }}>可预约时段</div>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', margin: '0 0 0.65rem' }}>
              灰色为已满，不可点；约不到心仪时段时，请使用下方「候补」选择期望时段（含已满时段）。
            </p>
            {fullyBooked && (
              <p style={{ fontSize: '0.85rem', color: 'var(--warning)', margin: '0 0 0.65rem' }}>
                当日该座位时段已全部约满，请直接在下方的候补中选择期望时段，或更换日期/座位。
              </p>
            )}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(72px, 1fr))',
                gap: '0.45rem',
              }}
            >
              {BOOKING_HOURS.map((h) => {
                const label = hourSlotLabel(h);
                const taken = isHourTakenForSeat(seat.code, date, h);
                const on = selectedSlots.includes(label);
                return (
                  <button
                    key={h}
                    type="button"
                    disabled={taken}
                    onClick={() => toggleHour(h)}
                    style={{
                      padding: '0.45rem 0.35rem',
                      borderRadius: 8,
                      border: '1px solid var(--border)',
                      fontSize: '0.72rem',
                      background: taken
                        ? '#e8e8e8'
                        : on
                          ? 'var(--bg-accent-soft)'
                          : '#fff',
                      color: taken ? '#999' : 'var(--text)',
                      cursor: taken ? 'not-allowed' : 'pointer',
                    }}
                  >
                    {h}:00
                  </button>
                );
              })}
            </div>
          </div>

          <div className="card" style={{ background: 'rgba(45, 106, 79, 0.06)' }}>
            <div style={{ fontWeight: 700, marginBottom: '0.35rem' }}>候补 · 期望时段</div>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', margin: '0 0 0.65rem' }}>
              以下时段<strong>均可点选</strong>（含已满时段），用于排队；与上方「可预约」无关。
            </p>
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(72px, 1fr))',
                gap: '0.45rem',
              }}
            >
              {BOOKING_HOURS.map((h) => {
                const label = hourSlotLabel(h);
                const taken = isHourTakenForSeat(seat.code, date, h);
                const on = waitlistSlots.includes(label);
                return (
                  <button
                    key={`wl-${h}`}
                    type="button"
                    onClick={() => toggleWaitlistHour(h)}
                    style={{
                      padding: '0.45rem 0.35rem',
                      borderRadius: 8,
                      border: taken ? '1px dashed var(--warning)' : '1px solid var(--border)',
                      fontSize: '0.72rem',
                      background: on ? 'var(--primary-soft)' : '#fff',
                      color: 'var(--text)',
                      cursor: 'pointer',
                      position: 'relative',
                    }}
                  >
                    {h}:00
                    {taken && (
                      <span
                        style={{
                          position: 'absolute',
                          top: 2,
                          right: 2,
                          fontSize: '0.55rem',
                          color: 'var(--warning)',
                          fontWeight: 700,
                        }}
                      >
                        满
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
            <button
              type="button"
              className="btn btn-primary btn-block"
              style={{ marginTop: '0.85rem' }}
              onClick={submitWaitlist}
            >
              加入候补队列
            </button>
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
            <button type="button" className="btn btn-ghost btn-block" onClick={() => setStep(1)}>
              上一步
            </button>
            {!fullyBooked && (
              <button type="button" className="btn btn-primary btn-block" onClick={nextFromTime}>
                下一步
              </button>
            )}
          </div>
        </>
      )}

      {step === 3 && seat && (
        <>
          <div className="card">
            <h3 style={{ margin: '0 0 0.5rem', fontSize: '1rem' }}>确认信息</h3>
            <p style={{ margin: '0.25rem 0', fontSize: '0.9rem' }}>
              座位：<strong>{seat.code}</strong>（{seat.zone}）
            </p>
            <p style={{ margin: '0.25rem 0', fontSize: '0.9rem' }}>日期：{date}</p>
            <p style={{ margin: '0.25rem 0', fontSize: '0.9rem' }}>
              时段：{selectedSlots.join('，')}
            </p>
            <p style={{ margin: '0.75rem 0 0', fontSize: '1rem' }}>
              费用：<strong style={{ color: 'var(--primary)' }}>
                ¥{feeForSlots(selectedSlots)}
              </strong>
              <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                {' '}
               （¥15/小时，当日封顶 ¥80）
              </span>
            </p>
          </div>

          {!lastResId ? (
            <button
              type="button"
              className="btn btn-primary btn-block"
              style={{ marginBottom: 8 }}
              onClick={confirmReserve}
            >
              生成预约订单
            </button>
          ) : (
            <>
              <div className="card" style={{ marginBottom: 8 }}>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>核销码</div>
                <div style={{ fontSize: '1.25rem', fontWeight: 700, letterSpacing: '0.12em' }}>
                  {verifyCode}
                </div>
              </div>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', margin: '0 0 0.65rem' }}>
                支付成功后即可在「我的预约」查看；以下为演示支付。
              </p>
              <button
                type="button"
                className="btn btn-primary btn-block"
                style={{ marginBottom: 8 }}
                onClick={() => mockPay('支付宝')}
              >
                支付宝支付
              </button>
              <button
                type="button"
                className="btn btn-ghost btn-block"
                style={{ marginBottom: 8 }}
                onClick={() => mockPay('微信')}
              >
                微信支付
              </button>
            </>
          )}

          <button
            type="button"
            className="btn btn-ghost btn-block"
            onClick={() => {
              setStep(2);
              setLastResId(null);
            }}
          >
            上一步
          </button>
        </>
      )}

      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
