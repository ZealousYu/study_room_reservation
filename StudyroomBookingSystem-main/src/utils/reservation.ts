import type { Reservation } from '../context/AppContext';

export const CHECKIN_WINDOW_MINUTES = 15;

export type CheckinWindowState = 'before' | 'open' | 'after' | 'unknown';

export function parseReservationStart(r: Reservation): Date | null {
  if (r.startTime) {
    const normalized = r.startTime.includes('T') ? r.startTime : r.startTime.replace(' ', 'T');
    const d = new Date(normalized);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  if (r.date && r.slots[0]) {
    const startPart = r.slots[0].split('-')[0]?.trim();
    if (!startPart) return null;
    const d = new Date(`${r.date}T${startPart}:00`);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  return null;
}

export function getCheckinWindowState(r: Reservation): CheckinWindowState {
  const start = parseReservationStart(r);
  if (!start) return 'unknown';
  const now = Date.now();
  const windowMs = CHECKIN_WINDOW_MINUTES * 60 * 1000;
  const startMs = start.getTime();
  if (now < startMs - windowMs) return 'before';
  if (now > startMs + windowMs) return 'after';
  return 'open';
}

export function formatReservationTime(r: Reservation): string {
  if (r.startTime && r.endTime) {
    const start = r.startTime.slice(11, 16);
    const end = r.endTime.slice(11, 16);
    return `${r.date} ${start}–${end}`;
  }
  if (r.date && r.slots.length) {
    return `${r.date} ${r.slots.join('，')}`;
  }
  return r.date;
}

export function checkinWindowHint(state: CheckinWindowState): string {
  switch (state) {
    case 'before':
      return `请在预约开始前 ${CHECKIN_WINDOW_MINUTES} 分钟内打卡`;
    case 'open':
      return `打卡窗口已开放（前后各 ${CHECKIN_WINDOW_MINUTES} 分钟）`;
    case 'after':
      return `已过打卡时间，未打卡将记为违约`;
    default:
      return '';
  }
}
