import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { useNavigate } from 'react-router-dom';
import { apiUrl } from '../config/api';

export function mapReservationStatus(status: number): ReservationStatus {
  switch (status) {
    case 0: return '待支付';
    case 1: return '预约成功';
    case 2: return '进行中';
    case 3: return '已取消';
    case 4: return '违约';
    case 5: return '已完成';
    default: return '待支付';
  }
}

function mapReservationStatusText(status: string): ReservationStatus {
  const allowed: ReservationStatus[] = ['待支付', '预约成功', '进行中', '已取消', '违约', '已完成'];
  return allowed.includes(status as ReservationStatus) ? (status as ReservationStatus) : '待支付';
}

export function mapOrderStatus(status: number): OrderStatus {
  switch (status) {
    case 1: return '待支付';
    case 2: return '已支付';
    case 3: return '制作中';
    case 4: return '已完成';
    case 5: return '已取消';
    default: return '待支付';
  }
}

export function orderStatusToCode(status: OrderStatus): number {
  switch (status) {
    case '待支付': return 1;
    case '已支付': return 2;
    case '制作中': return 3;
    case '已完成': return 4;
    case '已取消': return 5;
    default: return 1;
  }
}

export type Zone = '靠窗区' | '静音区' | '吧台区';

export type Seat = {
  id: string;
  code: string;
  zone: Zone;
  hasOutlet: boolean;
  hasLamp: boolean;
  hasDivider: boolean;
  nearWindow: boolean;
  enabled: boolean;
};

export type ReservationStatus = '待支付' | '预约成功' | '进行中' | '已取消' | '违约'| '已完成' ;

export type Reservation = {
  id: string;
  seatCode: string;
  date: string;
  slots: string[];
  startTime?: string;
  endTime?: string;
  status: ReservationStatus;
  fee: number;
  checkInAt?: string;
  verifyCode: string;
};

export type ProductCategory = '咖啡' | '茶饮' | '甜品' | '小吃';

export type Product = {
  id: string;
  name: string;
  category: ProductCategory;
  price: number;
  desc: string;
  rating: number;
  stock: number;
  onShelf: boolean;
  picture?: string;
};

export type CartLine = { product: Product; qty: number };

export type OrderStatus = '待支付' | '已支付' | '制作中' | '已完成' | '已取消';

export type DeliveryStatus =
  | 'none'
  | 'await_checkin'
  | 'making'
  | 'await_delivery'
  | 'shipping'
  | 'delivered'
  | 'pickup_ready'
  | 'completed';

export type FoodOrder = {
  id: string;
  orderNo: string;
  createdAt: string;
  items: { product: { id: string; name: string; price: number }; qty: number }[];
  total: number;
  delivery: '配送至座位' | '吧台自取';
  status: OrderStatus;
  deliveryStatus: DeliveryStatus;
};

export type AdminFoodOrder = FoodOrder & {
  userPhone: string;
  userName: string;
};

export type AdminReservation = Reservation & {
  userPhone: string;
  userName: string;
};

export type BreachRecord = {
  id: string;
  at: string;
  reason: string;
  phone?: string;
};

export type WaitlistStatus = '排队中' | '已通知' | '已取消';

export type WaitlistEntry = {
  id: string;
  seatCode: string;
  date: string;
  slots: string[];
  status: WaitlistStatus;
  createdAt: string;
};

export type Announcement = {
  id: string;
  title: string;
  content: string;
  publishedAt: string;
  updatedAt: string;
};

type User = {
  phone: string;
  name: string;
};

export type AdminUser = {
  account: string;
  displayName: string;
};

function reservationBlocksSlot(r: Reservation): boolean {
  return r.status === '待支付' || r.status === '预约成功' || r.status === '进行中';
}

export function hourSlotLabel(hour: number): string {
  return `${hour}:00-${hour + 1}:00`;
}

export const BOOKING_HOURS = Array.from({ length: 14 }, (_, i) => i + 9);

const SEED_SEATS: Omit<Seat, 'enabled'>[] = [
  { id: 's1', code: 'A-01', zone: '靠窗区', hasOutlet: true, hasLamp: true, hasDivider: true, nearWindow: true },
  { id: 's2', code: 'A-02', zone: '靠窗区', hasOutlet: true, hasLamp: false, hasDivider: true, nearWindow: true },
  { id: 's3', code: 'B-01', zone: '静音区', hasOutlet: true, hasLamp: true, hasDivider: false, nearWindow: false },
  { id: 's4', code: 'B-02', zone: '静音区', hasOutlet: false, hasLamp: true, hasDivider: true, nearWindow: false },
  { id: 's5', code: 'C-01', zone: '吧台区', hasOutlet: true, hasLamp: false, hasDivider: false, nearWindow: false },
  { id: 's6', code: 'C-02', zone: '吧台区', hasOutlet: true, hasLamp: true, hasDivider: false, nearWindow: false },
];

function mapCategory(categoryNum: number): ProductCategory {
  switch (categoryNum) {
    case 1: return '咖啡';
    case 2: return '茶饮';
    case 3: return '甜品';
    case 4: return '小吃';
    default: return '小吃';
  }
}

function deriveDeliveryStatus(order: { status: OrderStatus; delivery: '配送至座位' | '吧台自取' }): DeliveryStatus {
  if (order.status === '待支付') return 'none';
  if (order.status === '已取消') return 'none';
  if (order.delivery === '吧台自取') {
    if (order.status === '已完成') return 'completed';
    if (order.status === '制作中') return 'pickup_ready';
    return 'pickup_ready';
  } else {
    if (order.status === '已支付') return 'await_checkin';
    if (order.status === '制作中') return 'making';
    if (order.status === '已完成') return 'completed';
    return 'await_checkin';
  }
}

export function maskPhone(phone: string): string {
  if (phone.length !== 11) return phone;
  return `${phone.slice(0, 3)}****${phone.slice(7)}`;
}

export function formatDeliveryStatus(
  o: Pick<FoodOrder, 'delivery' | 'status' | 'deliveryStatus'>
): string {
  if (o.status === '待支付' || o.status === '已取消') return '—';
  if (o.delivery === '吧台自取') {
    if (o.deliveryStatus === 'pickup_ready') return '请至吧台自取';
    if (o.deliveryStatus === 'completed' || o.status === '已完成') return '已完成';
    if (o.status === '制作中') return '制作中';
    return '处理中';
  }
  switch (o.deliveryStatus) {
    case 'await_checkin':
      return '待到店打卡（打卡后制作）';
    case 'making':
      return '制作中';
    case 'await_delivery':
      return '待配送';
    case 'shipping':
      return '配送中';
    case 'delivered':
      return '已送达座位';
    case 'completed':
      return '已完成';
    default:
      return '处理中';
  }
}

const STORAGE_KEY = 'bookspace_user_v1';
const ADMIN_KEY = 'bookspace_admin_v1';
const TOKEN_KEY = 'bookspace_token';
const ADMIN_TOKEN_KEY = 'bookspace_admin_token';

let onUnauthorized: (() => void) | null = null;
let onAdminUnauthorized: (() => void) | null = null;

function clearStoredSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(STORAGE_KEY);
}

function clearStoredAdminSession() {
  localStorage.removeItem(ADMIN_TOKEN_KEY);
  localStorage.removeItem(ADMIN_KEY);
}

function readStoredAdmin(): AdminUser | null {
  const token = localStorage.getItem(ADMIN_TOKEN_KEY);
  const raw = localStorage.getItem(ADMIN_KEY);
  if (!token || !raw || isTokenExpired(token)) {
    clearStoredAdminSession();
    return null;
  }
  try {
    return JSON.parse(raw) as AdminUser;
  } catch {
    clearStoredAdminSession();
    return null;
  }
}

function isTokenExpired(token: string): boolean {
  try {
    const payload = JSON.parse(
      atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/'))
    ) as { exp?: number };
    if (typeof payload.exp !== 'number') return true;
    return payload.exp * 1000 <= Date.now();
  } catch {
    return true;
  }
}

function readStoredUser(): User | null {
  const token = localStorage.getItem(TOKEN_KEY);
  const raw = localStorage.getItem(STORAGE_KEY);
  if (!token || !raw || isTokenExpired(token)) {
    clearStoredSession();
    return null;
  }
  try {
    return JSON.parse(raw) as User;
  } catch {
    clearStoredSession();
    return null;
  }
}

function formatAuthError(message: string): string {
  if (message === '未授权') return '账号或密码错误，请检查后重试';
  if (message === '数据已存在') return '该手机号已注册，请直接登录';
  return message;
}

// API 请求辅助函数
async function apiRequest<T>(
  url: string,
  options?: RequestInit
): Promise<T> {
  const token = localStorage.getItem(TOKEN_KEY);
  const res = await fetch(apiUrl(url), {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options?.headers,
    },
  });
  if (!res.ok) {
    const error = await res.json().catch(() => ({ error: '请求失败' }));
    if (res.status === 401 && token) {
      clearStoredSession();
      onUnauthorized?.();
    }
    throw new Error(error.error || '请求失败');
  }
  const text = await res.text();
  if (!text) return undefined as T;
  return JSON.parse(text) as T;
}

async function adminApiRequest<T>(url: string, options?: RequestInit): Promise<T> {
  const token = localStorage.getItem(ADMIN_TOKEN_KEY);
  if (!token || isTokenExpired(token)) {
    clearStoredAdminSession();
    onAdminUnauthorized?.();
    throw new Error('管理员登录已过期，请重新登录');
  }
  const res = await fetch(apiUrl(url), {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...options?.headers,
    },
  });
  if (!res.ok) {
    const error = await res.json().catch(() => ({ error: '请求失败' }));
    if (res.status === 401 || res.status === 403) {
      clearStoredAdminSession();
      onAdminUnauthorized?.();
    }
    throw new Error(error.error || '请求失败');
  }
  const text = await res.text();
  if (!text) return undefined as T;
  return JSON.parse(text) as T;
}

type AppContextValue = {
  user: User | null;
  adminUser: AdminUser | null;
  seats: Seat[];
  products: Product[];
  cart: CartLine[];
  reservations: Reservation[];
  foodOrders: FoodOrder[];
  adminOrders: AdminFoodOrder[];
  adminReservations: AdminReservation[];
  adminAnnouncements: Announcement[];
  announcements: Announcement[];
  breachRecords: BreachRecord[];
  breachCount: number;
  login: (phone: string, password: string) => Promise<{ ok: boolean; message: string }>;
  register: (phone: string, password: string) => Promise<{ ok: boolean; message: string }>;
  resetPassword: (phone: string, code: string, newPassword: string) => Promise<{ ok: boolean; message: string }>;
  logout: () => void;
  adminLogin: (account: string, password: string) => Promise<{ ok: boolean; message: string }>;
  adminLogout: () => void;
  refreshAdminOrders: () => Promise<void>;
  refreshAdminReservations: () => Promise<void>;
  refreshAdminAnnouncements: () => Promise<void>;
  refreshAnnouncements: () => Promise<void>;
  addToCart: (product: Product, qty?: number) => { ok: boolean; message: string };
  setCartQty: (productId: string, qty: number) => void;
  removeFromCart: (productId: string) => void;
  clearCart: () => void;
  placeFoodOrder: (
    delivery: FoodOrder['delivery'],
    revId?: number
  ) => Promise<{
    orderId: string;
    orderNo: string;
    total: number;
    delivery: FoodOrder['delivery'];
    items: { name: string; qty: number; price: number }[];
  } | null>;
  payFoodOrder: (orderId: string) => Promise<void>;
  cancelFoodOrder: (orderId: string) => Promise<void>;
  refreshFoodOrders: () => Promise<void>;
  createReservation: (
    r: Omit<Reservation, 'id' | 'verifyCode' | 'status'>
  ) => Promise<Reservation | null>;
  payReservation: (id: string) => Promise<boolean>;
  cancelReservation: (id: string) => Promise<{ ok: boolean; message: string }>;
  checkIn: (reservationId: number) => Promise<{ ok: boolean; message: string }>;
  filterSeats: (filters: {
    outlet?: boolean;
    lamp?: boolean;
    divider?: boolean;
    window?: boolean;
  }) => Seat[];
  isHourTakenForSeat: (seatCode: string, date: string, hour: number) => boolean;
  isSeatDateFullyBooked: (seatCode: string, date: string) => boolean;
  canBookSlots: (seatCode: string, date: string, slotLabels: string[]) => boolean;
  waitlist: WaitlistEntry[];
  joinWaitlist: (p: { seatCode: string; date: string; slots: string[] }) => WaitlistEntry;
  cancelWaitlist: (id: string) => Promise<void>;
  setSeatEnabled: (seatId: string, enabled: boolean) => void;
  setProductStock: (productId: string, stock: number) => void;
  setProductOnShelf: (productId: string, onShelf: boolean) => void;
  adminSetOrderStatus: (orderId: string, status: OrderStatus) => Promise<void>;
  adminSetDeliveryStatus: (orderId: string, deliveryStatus: DeliveryStatus) => void;
  adminMarkReservation: (id: string, mark: '到场' | '违约') => Promise<void>;
  adminDeleteReservation: (id: string) => Promise<void>;
  adminDeleteOrder: (id: string) => Promise<void>;
  adminClearBreachLimit: (phone: string) => void;
  adminCreateAnnouncement: (input: { title: string; content: string }) => Promise<void>;
  adminUpdateAnnouncement: (id: string, input: { title: string; content: string }) => Promise<void>;
  adminDeleteAnnouncement: (id: string) => Promise<void>;
};

const AppContext = createContext<AppContextValue | null>(null);

export function AppProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate();

  const [user, setUser] = useState<User | null>(() => readStoredUser());

  const [adminUser, setAdminUser] = useState<AdminUser | null>(() => readStoredAdmin());

  const [seats, setSeats] = useState<Seat[]>(() => SEED_SEATS.map((s) => ({ ...s, enabled: true })));
  const [products, setProducts] = useState<Product[]>([]);
  const [cart, setCart] = useState<CartLine[]>([]);
  const [reservations, setReservations] = useState<Reservation[]>([]);
  const [foodOrders, setFoodOrders] = useState<FoodOrder[]>([]);
  const [adminOrders, setAdminOrders] = useState<AdminFoodOrder[]>([]);
  const [adminReservations, setAdminReservations] = useState<AdminReservation[]>([]);
  const [adminAnnouncements, setAdminAnnouncements] = useState<Announcement[]>([]);
  const [waitlist, setWaitlist] = useState<WaitlistEntry[]>([]);
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [breachRecords, setBreachRecords] = useState<BreachRecord[]>([]);
  const breachCount = breachRecords.length;

  // ---------- 数据加载函数 ----------
  const loadOrders = useCallback(async (token?: string) => {
    const t = token || localStorage.getItem(TOKEN_KEY);
    if (!t) return;
    try {
      const data = await apiRequest<any[]>('/api/orders');
      const converted: FoodOrder[] = data.map((order) => {
        const delivery: FoodOrder['delivery'] =
          order.delivery ??
          (order.deliveryType === 1 ? '配送至座位' : '吧台自取');
        const status: OrderStatus =
          typeof order.status === 'string'
            ? order.status
            : mapOrderStatus(order.status);
        return {
          id: String(order.id ?? order.orderId),
          orderNo: order.orderNo,
          createdAt: String(order.createdAt ?? order.createTime ?? ''),
          items: (order.items ?? []).map((item: any) => ({
            product: item.product ?? {
              id: String(item.prodId),
              name: item.name,
              price: item.price,
            },
            qty: item.qty ?? item.quantity,
          })),
          total: order.total ?? order.totalAmount,
          delivery,
          status,
          deliveryStatus:
            order.deliveryStatus ??
            deriveDeliveryStatus({ status, delivery }),
        };
      });
      setFoodOrders(converted);
    } catch (err) {
      console.error('加载订单失败', err);
    }
  }, []);

  const loadAdminOrders = useCallback(async () => {
    const token = localStorage.getItem(ADMIN_TOKEN_KEY);
    if (!token) return;
    try {
      const data = await adminApiRequest<any[]>('/api/admin/orders');
      const converted: AdminFoodOrder[] = data.map((order) => {
        const delivery: FoodOrder['delivery'] =
          order.deliveryType === 1 ? '配送至座位' : '吧台自取';
        const status = mapOrderStatus(order.status);
        return {
          id: String(order.orderId),
          orderNo: order.orderNo,
          createdAt: String(order.createTime ?? ''),
          items: [],
          total: order.totalAmount,
          delivery,
          status,
          deliveryStatus: deriveDeliveryStatus({ status, delivery }),
          userPhone: order.userPhone ?? '',
          userName: order.userName ?? '',
        };
      });
      setAdminOrders(converted);
    } catch (err) {
      console.error('加载管理端订单失败', err);
    }
  }, []);

  function mapAdminReservation(row: any): AdminReservation {
    const startTime = String(row.startTime ?? '');
    const endTime = String(row.endTime ?? '');
    const date = startTime.slice(0, 10);
    const startHour = startTime.slice(11, 13).replace(/^0/, '');
    const endHour = endTime.slice(11, 13).replace(/^0/, '');
    const slots =
      startTime && endTime
        ? [`${startHour}:00-${endHour}:00`]
        : [];
    return {
      id: String(row.revId),
      seatCode: row.seatCode,
      date,
      slots,
      status: mapReservationStatus(Number(row.status)),
      fee: row.amount ?? 0,
      checkInAt: row.checkinTime ? String(row.checkinTime) : undefined,
      verifyCode: '',
      userPhone: row.userPhone ?? '',
      userName: row.userName ?? '',
    };
  }

  function mapNotice(row: any): Announcement {
    const time = String(row.createTime ?? row.publishedAt ?? row.updatedAt ?? '');
    const formatted = time.includes('T') ? time.replace('T', ' ').slice(0, 19) : time;
    return {
      id: String(row.nId ?? row.id),
      title: row.title,
      content: row.content,
      publishedAt: row.publishedAt ?? formatted,
      updatedAt: row.updatedAt ?? formatted,
    };
  }

  const loadAdminReservations = useCallback(async () => {
    const token = localStorage.getItem(ADMIN_TOKEN_KEY);
    if (!token) return;
    try {
      const data = await adminApiRequest<any[]>('/api/admin/reservations');
      setAdminReservations(data.map(mapAdminReservation));
    } catch (err) {
      console.error('加载管理端预约失败', err);
    }
  }, []);

  const loadAdminAnnouncements = useCallback(async () => {
    const token = localStorage.getItem(ADMIN_TOKEN_KEY);
    if (!token) return;
    try {
      const data = await adminApiRequest<any[]>('/api/admin/notices');
      setAdminAnnouncements(data.map(mapNotice));
    } catch (err) {
      console.error('加载管理端公告失败', err);
    }
  }, []);

  const loadAnnouncements = useCallback(async () => {
    try {
      const res = await fetch(apiUrl('/api/notices'));
      if (!res.ok) return;
      const data = await res.json();
      setAnnouncements(data.map(mapNotice));
    } catch (err) {
      console.error('加载公告失败', err);
    }
  }, []);

  const loadReservations = useCallback(async (token?: string) => {
    const t = token || localStorage.getItem(TOKEN_KEY);
    if (!t) return;
    try {
      const data = await apiRequest<any[]>('/api/reservations');
      setReservations(
        data.map((item) => ({
          ...item,
          status: typeof item.status === 'string'
            ? mapReservationStatusText(item.status)
            : mapReservationStatus(item.status),
        }))
      );
    } catch (err) {
      console.error('加载预约列表失败', err);
    }
  }, []);

  const loadWaitlist = useCallback(async (token?: string) => {
    const t = token || localStorage.getItem(TOKEN_KEY);
    if (!t) return;
    try {
      const data = await apiRequest<any[]>('/api/waitlist');
      setWaitlist(data);
    } catch (err) {
      console.error('加载候补列表失败', err);
    }
  }, []);

  const loadBreach = useCallback(async (token?: string) => {
    const t = token || localStorage.getItem(TOKEN_KEY);
    if (!t) return;
    try {
      const data = await apiRequest<any[]>('/api/breach');
      const records: BreachRecord[] = data.map((item, idx) => ({
        id: idx.toString(),
        at: item.at,
        reason: item.reason,
      }));
      setBreachRecords(records);
    } catch (err) {
      console.error('加载违约记录失败', err);
    }
  }, []);

  // 自动恢复登录状态并加载数据
  useEffect(() => {
    onUnauthorized = () => {
      setUser(null);
      setCart([]);
      setFoodOrders([]);
      setReservations([]);
      setWaitlist([]);
      setBreachRecords([]);
      navigate('/login', { replace: true });
    };
    return () => {
      onUnauthorized = null;
    };
  }, [navigate]);

  useEffect(() => {
    onAdminUnauthorized = () => {
      setAdminUser(null);
      setAdminOrders([]);
      setAdminReservations([]);
      setAdminAnnouncements([]);
      navigate('/admin/login', { replace: true });
    };
    return () => {
      onAdminUnauthorized = null;
    };
  }, [navigate]);

  useEffect(() => {
    const token = localStorage.getItem(TOKEN_KEY);
    if (!token || isTokenExpired(token)) return;
    loadOrders(token);
    loadReservations(token);
    loadWaitlist(token);
    loadBreach(token);
  }, [loadOrders, loadReservations, loadWaitlist, loadBreach]);

  useEffect(() => {
    const token = localStorage.getItem(ADMIN_TOKEN_KEY);
    if (token && adminUser) {
      void loadAdminOrders();
      void loadAdminReservations();
      void loadAdminAnnouncements();
    }
  }, [adminUser, loadAdminOrders, loadAdminReservations, loadAdminAnnouncements]);

  useEffect(() => {
    void loadAnnouncements();
  }, [loadAnnouncements]);

  // 获取商品列表
  useEffect(() => {
    fetch(apiUrl('/api/products'))
      .then((res) => res.json())
      .then((data) => {
        const mapped: Product[] = data.map((item: any) => ({
          id: item.prodId.toString(),
          name: item.name,
          category: mapCategory(item.category),
          price: item.price,
          desc: item.description || '',
          rating: 4.5,
          stock: item.stock,
          onShelf: item.state === 1,
          picture: item.picture,
        }));
        setProducts(mapped);
      })
      .catch((err) => console.error('获取商品失败', err));
  }, []);

  // ---------- 用户认证 ----------
  const persistUser = useCallback((u: User | null) => {
    if (u) localStorage.setItem(STORAGE_KEY, JSON.stringify(u));
    else localStorage.removeItem(STORAGE_KEY);
    setUser(u);
  }, []);

  const persistAdmin = useCallback((a: AdminUser | null) => {
    if (a) localStorage.setItem(ADMIN_KEY, JSON.stringify(a));
    else clearStoredAdminSession();
    setAdminUser(a);
  }, []);

  const login = useCallback(
    async (phone: string, password: string) => {
      if (!/^1[3-9]\d{9}$/.test(phone)) {
        return { ok: false, message: '请输入有效的 11 位手机号' };
      }
      if (password.length < 1) {
        return { ok: false, message: '请输入密码' };
      }
      try {
        const res = await fetch(apiUrl('/api/auth/login'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ phone, password }),
        });
        const data = await res.json();
        if (res.ok) {
          localStorage.setItem(TOKEN_KEY, data.token);
          const userName = data.user.realName || `同学${phone.slice(-4)}`;
          persistUser({ phone: data.user.phone, name: userName });
          await loadOrders(data.token);
          await loadReservations(data.token);
          await loadWaitlist(data.token);
          await loadBreach(data.token);
          return { ok: true, message: '登录成功' };
        } else {
          return { ok: false, message: formatAuthError(data.error || '登录失败，请检查账号或密码') };
        }
      } catch (err) {
        console.error('登录错误', err);
        return { ok: false, message: '网络错误，请稍后重试' };
      }
    },
    [persistUser, loadOrders, loadReservations, loadWaitlist, loadBreach]
  );

  const register = useCallback(
    async (phone: string, password: string) => {
      if (!/^1[3-9]\d{9}$/.test(phone)) {
        return { ok: false, message: '请输入有效的 11 位手机号' };
      }
      if (password.length < 8) {
        return { ok: false, message: '密码至少 8 位' };
      }

      try {
        const res = await fetch(apiUrl('/api/auth/register'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ phone, password, realName: `同学${phone.slice(-4)}` }),
        });
        const data = await res.json();
        if (res.ok) {
          localStorage.setItem(TOKEN_KEY, data.token);
          persistUser({ phone: data.user.phone, name: data.user.realName });
          await loadOrders(data.token);
          await loadReservations(data.token);
          await loadWaitlist(data.token);
          await loadBreach(data.token);
          return { ok: true, message: '注册成功' };
        } else {
          return { ok: false, message: formatAuthError(data.error || '注册失败') };
        }
      } catch (err) {
        return { ok: false, message: '网络错误' };
      }
    },
    [persistUser, loadOrders, loadReservations, loadWaitlist, loadBreach]
  );

  const resetPassword = useCallback(
    async (phone: string, code: string, newPassword: string) => {
      if (newPassword.length < 8) {
        return { ok: false, message: '密码至少 8 位' };
      }

      try {
        const res = await fetch(apiUrl('/api/reset-password'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            phone,
            code,
            new_password: newPassword,
          }),
        });

        const data = await res.json();
        return { ok: res.ok, message: data.message || '密码重置成功' };
      } catch {
        return { ok: false, message: '网络错误' };
      }
    },
    []
  );

  const logout = useCallback(() => {
    clearStoredSession();
    persistUser(null);
    setCart([]);
    setFoodOrders([]);
    setBreachRecords([]);
    setReservations([]);
    setWaitlist([]);
  }, [persistUser]);

  const adminLogin = useCallback(
    async (account: string, password: string) => {
      const a = account.trim();
      if (!a || !password) return { ok: false, message: '请输入账号和密码' };
      try {
        const res = await fetch(apiUrl('/api/admin/login'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ phone: a, password }),
        });
        const data = await res.json();
        if (res.ok) {
          localStorage.setItem(ADMIN_TOKEN_KEY, data.token);
          persistAdmin({ account: data.account, displayName: data.realName || data.account });
          await loadAdminOrders();
          await loadAdminReservations();
          await loadAdminAnnouncements();
          return { ok: true, message: '登录成功' };
        }
        return { ok: false, message: formatAuthError(data.error || '登录失败') };
      } catch {
        return { ok: false, message: '网络错误，请稍后重试' };
      }
    },
    [persistAdmin, loadAdminOrders, loadAdminReservations, loadAdminAnnouncements]
  );

  const adminLogout = useCallback(() => {
    clearStoredAdminSession();
    setAdminOrders([]);
    setAdminReservations([]);
    setAdminAnnouncements([]);
    setAdminUser(null);
  }, []);

  // ---------- 购物车 ----------
  const addToCart = useCallback(
    (product: Product, qty = 1) => {
      if (!product.onShelf) return { ok: false, message: '商品已下架' };
      const nextQty = (cart.find((l) => l.product.id === product.id)?.qty ?? 0) + qty;
      if (nextQty > product.stock) return { ok: false, message: '库存不足' };
      setCart((prev) => {
        const i = prev.findIndex((l) => l.product.id === product.id);
        if (i >= 0) {
          const next = [...prev];
          next[i] = { ...next[i], qty: next[i].qty + qty };
          return next;
        }
        return [...prev, { product, qty }];
      });
      return { ok: true, message: '已经加入购物车' };
    },
    [cart]
  );

  const setCartQty = useCallback((productId: string, qty: number) => {
    setCart((prev) => {
      const line = prev.find((l) => l.product.id === productId);
      if (!line) return prev;
      if (qty <= 0) return prev.filter((l) => l.product.id !== productId);
      const p = line.product;
      const q = Math.min(qty, p.stock);
      return prev.map((l) => (l.product.id === productId ? { ...l, qty: q } : l));
    });
  }, []);

  const removeFromCart = useCallback((productId: string) => {
    setCart((prev) => prev.filter((l) => l.product.id !== productId));
  }, []);

  const clearCart = useCallback(() => setCart([]), []);

  const placeFoodOrder = useCallback(
    async (delivery: FoodOrder['delivery'], revId?: number) => {
      if (cart.length === 0) return null;
      const cartSnapshot = cart.map((line) => ({ ...line }));
      const items = cartSnapshot.map((line) => ({
        prodId: Number(line.product.id),
        quantity: line.qty,
      }));
      const deliveryType = delivery === '配送至座位' ? 1 : 2;
      const body: Record<string, unknown> = { items, deliveryType };
      if (delivery === '配送至座位' && revId && !isNaN(revId) && revId > 0) {
        body.revId = revId;
      }
      try {
        const result = await apiRequest<{ orderId: number; totalAmount: number; orderNo: string }>(
          '/api/orders',
          { method: 'POST', body: JSON.stringify(body) }
        );
        const orderId = String(result.orderId);
        const newOrder: FoodOrder = {
          id: orderId,
          orderNo: result.orderNo,
          createdAt: new Date().toLocaleString('zh-CN', { hour12: false }),
          items: cartSnapshot.map((line) => ({
            product: {
              id: line.product.id,
              name: line.product.name,
              price: line.product.price,
            },
            qty: line.qty,
          })),
          total: result.totalAmount,
          delivery,
          status: '待支付',
          deliveryStatus: 'none',
        };
        setFoodOrders((prev) => {
          if (prev.some((o) => o.id === orderId)) return prev;
          return [newOrder, ...prev];
        });
        clearCart();
        return {
          orderId,
          orderNo: result.orderNo,
          total: result.totalAmount,
          delivery,
          items: cartSnapshot.map((line) => ({
            name: line.product.name,
            qty: line.qty,
            price: line.product.price,
          })),
        };
      } catch (err) {
        console.error('下单失败', err);
        return null;
      }
    },
    [cart, clearCart, loadOrders]
  );

  const payFoodOrder = useCallback(
    async (orderId: string) => {
      await apiRequest(`/api/orders/${orderId}/pay`, { method: 'POST' });
      setFoodOrders((prev) =>
        prev.map((o) =>
          o.id === orderId
            ? {
                ...o,
                status: '已支付',
                deliveryStatus: deriveDeliveryStatus({
                  status: '已支付',
                  delivery: o.delivery,
                }),
              }
            : o
        )
      );
      void loadOrders();
    },
    [loadOrders]
  );

  const cancelFoodOrder = useCallback(
    async (orderId: string) => {
      await apiRequest(`/api/orders/${orderId}/cancel`, { method: 'POST' });
      setFoodOrders((prev) =>
        prev.map((o) =>
          o.id === orderId
            ? { ...o, status: '已取消', deliveryStatus: 'none' as DeliveryStatus }
            : o
        )
      );
      void loadOrders();
    },
    [loadOrders]
  );

  const checkIn = useCallback(
    async (reservationId: number): Promise<{ ok: boolean; message: string }> => {
      try {
        await apiRequest('/api/checkin', {
          method: 'POST',
          body: JSON.stringify({ revId: reservationId }),
        });
        await loadOrders();
        await loadReservations();
        return { ok: true, message: '打卡成功，配送订单已开始制作' };
      } catch (err) {
        const message = err instanceof Error ? err.message : '打卡失败';
        await loadReservations();
        return { ok: false, message };
      }
    },
    [loadOrders, loadReservations]
  );

  // ---------- 预约与候补 ----------
  const createReservation = useCallback(
    async (r: Omit<Reservation, 'id' | 'verifyCode' | 'status'>) => {
      try {
        const data = await apiRequest<Reservation>('/api/reservations', {
          method: 'POST',
          body: JSON.stringify({
            seatCode: r.seatCode,
            date: r.date,
            slots: r.slots,
            fee: r.fee,
          }),
        });
        const created: Reservation = {
          ...data,
          status: mapReservationStatusText(String(data.status)),
        };
        setReservations((list) => [created, ...list]);
        return created;
      } catch (err) {
        console.error('创建预约失败', err);
        return null;
      }
    },
    []
  );

  const payReservation = useCallback(async (id: string) => {
    try {
      await apiRequest(`/api/reservations/${id}/pay`, { method: 'POST' });
      setReservations((list) =>
        list.map((x) => (x.id === id ? { ...x, status: '预约成功' as ReservationStatus } : x))
      );
      void loadReservations();
      return true;
    } catch (err) {
      console.error('支付预约失败', err);
      return false;
    }
  }, [loadReservations]);

  const cancelReservation = useCallback(
    async (id: string) => {
      try {
        await apiRequest(`/api/reservations/${id}/cancel`, { method: 'POST' });
        setReservations((prev) =>
          prev.map((r) => (r.id === id ? { ...r, status: '已取消' } : r))
        );
        await loadReservations();
        return { ok: true, message: '已取消预约' };
      } catch (err: any) {
        console.error('取消预约失败', err);
        return { ok: false, message: err.message || '取消失败' };
      }
    },
    [loadReservations]
  );

  const joinWaitlist = useCallback(
    (p: { seatCode: string; date: string; slots: string[] }) => {
      const entry: WaitlistEntry = {
        id: `WL${Date.now()}`,
        seatCode: p.seatCode,
        date: p.date,
        slots: [...p.slots],
        status: '排队中',
        createdAt: new Date().toLocaleString('zh-CN'),
      };
      setWaitlist((w) => [entry, ...w]);
      return entry;
    },
    []
  );

  const cancelWaitlist = useCallback(
    async (id: string) => {
      try {
        await apiRequest(`/api/waitlist/${id}/cancel`, { method: 'POST' });
        setWaitlist((prev) => prev.filter((w) => w.id !== id));
        //await loadWaitlist();
      } catch (err) {
        console.error('取消候补失败', err);
      }
    },
    []
  );

  // ---------- 座位筛选与时间判断（模拟）----------
  const isHourTakenForSeat = useCallback(
    (seatCode: string, date: string, hour: number) => {
      const label = hourSlotLabel(hour);
      const byBooking = reservations.some(
        (r) =>
          reservationBlocksSlot(r) &&
          r.seatCode === seatCode &&
          r.date === date &&
          r.slots.includes(label)
      );
      const mockBusy =
        (seatCode.charCodeAt(0) + hour * 3 + date.replaceAll('-', '').length) % 11 === 0;
      return byBooking || mockBusy;
    },
    [reservations]
  );

  const isSeatDateFullyBooked = useCallback(
    (seatCode: string, date: string) => BOOKING_HOURS.every((h) => isHourTakenForSeat(seatCode, date, h)),
    [isHourTakenForSeat]
  );

  const canBookSlots = useCallback(
    (seatCode: string, date: string, slotLabels: string[]) => {
      if (slotLabels.length === 0) return false;
      return slotLabels.every((label) => {
        const m = /^(\d{1,2}):00-/.exec(label);
        const hour = m ? Number(m[1]) : NaN;
        if (Number.isNaN(hour)) return false;
        return !isHourTakenForSeat(seatCode, date, hour);
      });
    },
    [isHourTakenForSeat]
  );

  const filterSeats = useCallback(
    (filters: { outlet?: boolean; lamp?: boolean; divider?: boolean; window?: boolean }) => {
      return seats.filter((s) => {
        if (!s.enabled) return false;
        if (filters.outlet && !s.hasOutlet) return false;
        if (filters.lamp && !s.hasLamp) return false;
        if (filters.divider && !s.hasDivider) return false;
        if (filters.window && !s.nearWindow) return false;
        return true;
      });
    },
    [seats]
  );

  // ---------- 管理员功能（模拟）----------
  const setSeatEnabled = useCallback((seatId: string, enabled: boolean) => {
    setSeats((list) => list.map((s) => (s.id === seatId ? { ...s, enabled } : s)));
  }, []);

  const setProductStock = useCallback((productId: string, stock: number) => {
    setProducts((list) => list.map((p) => (p.id === productId ? { ...p, stock: Math.max(0, stock) } : p)));
  }, []);

  const setProductOnShelf = useCallback((productId: string, onShelf: boolean) => {
    setProducts((list) => list.map((p) => (p.id === productId ? { ...p, onShelf } : p)));
  }, []);

  const adminSetOrderStatus = useCallback(
    async (orderId: string, status: OrderStatus) => {
      await adminApiRequest(`/api/admin/orders/${orderId}/status`, {
        method: 'POST',
        body: JSON.stringify({ status: orderStatusToCode(status) }),
      });
      setAdminOrders((orders) =>
        orders.map((o) =>
          o.id === orderId
            ? {
                ...o,
                status,
                deliveryStatus:
                  status === '已取消'
                    ? ('none' as DeliveryStatus)
                    : deriveDeliveryStatus({ status, delivery: o.delivery }),
              }
            : o
        )
      );
    },
    []
  );

  const adminSetDeliveryStatus = useCallback((orderId: string, deliveryStatus: DeliveryStatus) => {
    setAdminOrders((orders) => orders.map((o) => (o.id === orderId ? { ...o, deliveryStatus } : o)));
  }, []);

  const adminMarkReservation = useCallback(
    async (id: string, mark: '到场' | '违约') => {
      const path =
        mark === '到场'
          ? `/api/admin/reservations/${id}/checkin`
          : `/api/admin/reservations/${id}/violation`;
      await adminApiRequest(path, { method: 'POST' });
      await loadAdminReservations();
    },
    [loadAdminReservations]
  );

  const adminDeleteReservation = useCallback(
    async (id: string) => {
      await adminApiRequest(`/api/admin/reservations/${id}`, { method: 'DELETE' });
      await loadAdminReservations();
    },
    [loadAdminReservations]
  );

  const adminDeleteOrder = useCallback(
    async (id: string) => {
      await adminApiRequest(`/api/admin/orders/${id}`, { method: 'DELETE' });
      await loadAdminOrders();
    },
    [loadAdminOrders]
  );

  const adminClearBreachLimit = useCallback((phone: string) => {
    setBreachRecords((list) => list.filter((b) => b.phone !== phone));
  }, []);

  const adminCreateAnnouncement = useCallback(
    async (input: { title: string; content: string }) => {
      await adminApiRequest('/api/admin/notices', {
        method: 'POST',
        body: JSON.stringify({ title: input.title.trim(), content: input.content.trim(), state: 1 }),
      });
      await loadAdminAnnouncements();
      await loadAnnouncements();
    },
    [loadAdminAnnouncements, loadAnnouncements]
  );

  const adminUpdateAnnouncement = useCallback(
    async (id: string, input: { title: string; content: string }) => {
      await adminApiRequest(`/api/admin/notices/${id}`, {
        method: 'POST',
        body: JSON.stringify({ title: input.title.trim(), content: input.content.trim() }),
      });
      await loadAdminAnnouncements();
      await loadAnnouncements();
    },
    [loadAdminAnnouncements, loadAnnouncements]
  );

  const adminDeleteAnnouncement = useCallback(
    async (id: string) => {
      await adminApiRequest(`/api/admin/notices/${id}`, { method: 'DELETE' });
      await loadAdminAnnouncements();
      await loadAnnouncements();
    },
    [loadAdminAnnouncements, loadAnnouncements]
  );

  const value = useMemo<AppContextValue>(
    () => ({
      user,
      adminUser,
      seats,
      products,
      cart,
      reservations,
      foodOrders,
      adminOrders,
      adminReservations,
      adminAnnouncements,
      announcements,
      breachRecords,
      breachCount,
      login,
      register,
      resetPassword,
      logout,
      adminLogin,
      adminLogout,
      refreshAdminOrders: loadAdminOrders,
      refreshAdminReservations: loadAdminReservations,
      refreshAdminAnnouncements: loadAdminAnnouncements,
      refreshAnnouncements: loadAnnouncements,
      addToCart,
      setCartQty,
      removeFromCart,
      clearCart,
      placeFoodOrder,
      payFoodOrder,
      cancelFoodOrder,
      refreshFoodOrders: loadOrders,
      createReservation,
      payReservation,
      cancelReservation,
      checkIn,
      filterSeats,
      isHourTakenForSeat,
      isSeatDateFullyBooked,
      canBookSlots,
      waitlist,
      joinWaitlist,
      cancelWaitlist,
      setSeatEnabled,
      setProductStock,
      setProductOnShelf,
      adminSetOrderStatus,
      adminSetDeliveryStatus,
      adminMarkReservation,
      adminDeleteReservation,
      adminDeleteOrder,
      adminClearBreachLimit,
      adminCreateAnnouncement,
      adminUpdateAnnouncement,
      adminDeleteAnnouncement,
    }),
    [
      user,
      adminUser,
      seats,
      products,
      cart,
      reservations,
      foodOrders,
      adminOrders,
      adminReservations,
      adminAnnouncements,
      announcements,
      breachRecords,
      breachCount,
      login,
      register,
      resetPassword,
      logout,
      adminLogin,
      adminLogout,
      loadAdminOrders,
      loadAdminReservations,
      loadAdminAnnouncements,
      loadAnnouncements,
      addToCart,
      setCartQty,
      removeFromCart,
      clearCart,
      placeFoodOrder,
      payFoodOrder,
      cancelFoodOrder,
      loadOrders,
      createReservation,
      payReservation,
      cancelReservation,
      checkIn,
      filterSeats,
      isHourTakenForSeat,
      isSeatDateFullyBooked,
      canBookSlots,
      waitlist,
      joinWaitlist,
      cancelWaitlist,
      setSeatEnabled,
      setProductStock,
      setProductOnShelf,
      adminSetOrderStatus,
      adminSetDeliveryStatus,
      adminMarkReservation,
      adminDeleteReservation,
      adminDeleteOrder,
      adminClearBreachLimit,
      adminCreateAnnouncement,
      adminUpdateAnnouncement,
      adminDeleteAnnouncement,
    ]
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp outside AppProvider');
  return ctx;
}