import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

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

export type ReservationStatus = '待支付' | '进行中' | '已完成' | '已取消' | '违约';

export type Reservation = {
  id: string;
  seatCode: string;
  date: string;
  slots: string[];
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
  createdAt: string;
  items: CartLine[];
  total: number;
  delivery: '配送至座位' | '吧台自取';
  status: OrderStatus;
  deliveryStatus: DeliveryStatus;
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
  return r.status === '待支付' || r.status === '进行中';
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

// 将后端数字分类映射为前端枚举
function mapCategory(categoryNum: number): ProductCategory {
  switch (categoryNum) {
    case 1: return '咖啡';
    case 2: return '茶饮';
    case 3: return '甜品';
    case 4: return '小吃';
    default: return '小吃';
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

type AppContextValue = {
  user: User | null;
  adminUser: AdminUser | null;
  seats: Seat[];
  products: Product[];
  cart: CartLine[];
  reservations: Reservation[];
  foodOrders: FoodOrder[];
  announcements: Announcement[];
  breachRecords: BreachRecord[];
  breachCount: number;
  login: (phone: string, password: string) => { ok: boolean; message: string };
  register: (phone: string, password: string) => { ok: boolean; message: string };
  logout: () => void;
  adminLogin: (account: string, password: string) => { ok: boolean; message: string };
  adminLogout: () => void;
  addToCart: (product: Product, qty?: number) => { ok: boolean; message: string };
  setCartQty: (productId: string, qty: number) => void;
  removeFromCart: (productId: string) => void;
  clearCart: () => void;
  placeFoodOrder: (delivery: FoodOrder['delivery']) => FoodOrder | null;
  payFoodOrder: (orderId: string) => void;
  cancelFoodOrder: (orderId: string) => void;
  createReservation: (r: Omit<Reservation, 'id' | 'verifyCode' | 'status'>) => Reservation;
  payReservation: (id: string) => void;
  cancelReservation: (id: string) => { ok: boolean; message: string };
  checkIn: (reservationId: string) => void;
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
  cancelWaitlist: (id: string) => void;
  setSeatEnabled: (seatId: string, enabled: boolean) => void;
  setProductStock: (productId: string, stock: number) => void;
  setProductOnShelf: (productId: string, onShelf: boolean) => void;
  adminSetOrderStatus: (orderId: string, status: OrderStatus) => void;
  adminSetDeliveryStatus: (orderId: string, deliveryStatus: DeliveryStatus) => void;
  adminMarkReservation: (id: string, mark: '到场' | '违约') => void;
  adminClearBreachLimit: (phone: string) => void;
  adminCreateAnnouncement: (input: { title: string; content: string }) => void;
  adminUpdateAnnouncement: (id: string, input: { title: string; content: string }) => void;
  adminDeleteAnnouncement: (id: string) => void;
};

const AppContext = createContext<AppContextValue | null>(null);

const STORAGE_KEY = 'bookspace_user_v1';
const ADMIN_KEY = 'bookspace_admin_v1';

export function AppProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) return JSON.parse(raw) as User;
    } catch {
      /* ignore */
    }
    return null;
  });

  const [adminUser, setAdminUser] = useState<AdminUser | null>(() => {
    try {
      const raw = localStorage.getItem(ADMIN_KEY);
      if (raw) return JSON.parse(raw) as AdminUser;
    } catch {
      /* ignore */
    }
    return null;
  });

  const [seats, setSeats] = useState<Seat[]>(() => SEED_SEATS.map((s) => ({ ...s, enabled: true })));
  const [products, setProducts] = useState<Product[]>([]); // 不再使用硬编码数据
  const [cart, setCart] = useState<CartLine[]>([]);
  const [reservations, setReservations] = useState<Reservation[]>([]);
  const [foodOrders, setFoodOrders] = useState<FoodOrder[]>([]);
  const [waitlist, setWaitlist] = useState<WaitlistEntry[]>([]);
  const [announcements, setAnnouncements] = useState<Announcement[]>([
    {
      id: 'an1',
      title: '五一假期营业时间调整',
      content: '5 月 1 日至 5 月 3 日营业时间调整为 09:00-20:00，请提前预约。',
      publishedAt: '2026-04-28 10:00',
      updatedAt: '2026-04-28 10:00',
    },
    {
      id: 'an2',
      title: '静音区新增隔音耳塞领取点',
      content: '静音区前台可免费领取一次性耳塞，先到先得。',
      publishedAt: '2026-04-26 15:30',
      updatedAt: '2026-04-26 15:30',
    },
  ]);
  const [breachRecords, setBreachRecords] = useState<BreachRecord[]>([]);
  const breachCount = breachRecords.length;

  const fetchBreachRecords = useCallback(async (token: string) => {
    try {
      const res = await fetch('http://localhost:8080/api/breach', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        const records: BreachRecord[] = data.map((item: any) => ({
          id: crypto.randomUUID(),   // 生成唯一 id（注意兼容性，也可用 Date.now()）
          at: item.at,
          reason: item.reason,
          phone: undefined,
        }));
        setBreachRecords(records);
      } else {
        console.error('获取违约记录失败');
      }
    } catch (err) {
      console.error('网络错误', err);
    }
  }, []);

  // 从后端获取商品数据
  useEffect(() => {
    fetch('http://localhost:8080/api/products')
      .then((res) => res.json())
      .then((data) => {
        const mappedProducts: Product[] = data.map((item: any) => ({
          id: item.prodId.toString(),
          name: item.name,
          category: mapCategory(item.category),
          price: item.price,
          desc: item.description || '',
          rating: 4.5, // 后端未提供评分，使用默认值
          stock: item.stock,
          onShelf: item.state === 1,
          picture: item.picture,
        }));
        setProducts(mappedProducts);
      })
      .catch((err) => console.error('获取商品列表失败', err));
  }, []);

  //监听用户登录，用于个人中心  
  useEffect(() => {
    if (user) {
      const token = localStorage.getItem('bookspace_token'); // 请根据实际存储的 key 调整
      if (token) {
        fetchBreachRecords(token);
      }
    }
  }, [user, fetchBreachRecords]);

  const persistUser = useCallback((u: User | null) => {
    if (u) localStorage.setItem(STORAGE_KEY, JSON.stringify(u));
    else localStorage.removeItem(STORAGE_KEY);
    setUser(u);
  }, []);

  const persistAdmin = useCallback((a: AdminUser | null) => {
    if (a) localStorage.setItem(ADMIN_KEY, JSON.stringify(a));
    else localStorage.removeItem(ADMIN_KEY);
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
        const res = await fetch('http://localhost:8080/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ phone, password }),
        });
        const data = await res.json();

        if (res.ok) {
          // 保存 token
          localStorage.setItem('token', data.token);
          // 保存用户信息（使用后端返回的真实姓名，若没有则用手机号后四位）
          const userName = data.user.realName || `同学${phone.slice(-4)}`;
          persistUser({ phone: data.user.phone, name: userName });
          // 获取违约记录（个人中心需要 ）
          await fetchBreachRecords(data.token);
          return { ok: true, message: '登录成功' };
        } else {
          // 后端返回错误信息
          return { ok: false, message: data.error || '登录失败，请检查账号或密码' };
        }
      } catch (err) {
        console.error('登录网络错误', err);
        return { ok: false, message: '网络错误，请稍后重试' };
      }
    },
    [persistUser, fetchBreachRecords]
  );

  const register = useCallback(
    async (phone: string, password: string) => {
      if (!/^1[3-9]\d{9}$/.test(phone)) {
        return { ok: false, message: '请输入有效的 11 位手机号' };
      }
      if (password.length < 6) {
        return { ok: false, message: '密码至少 6 位' };
      }

      try {
        const res = await fetch('http://localhost:8080/api/auth/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            phone,
            password,
            realName: `同学${phone.slice(-4)}`,
          }),
        });

        const data = await res.json();

        if (res.ok) {
          localStorage.setItem('token', data.token);
          persistUser({
            phone: data.user.phone,
            name: data.user.realName,
          });
          return { ok: true, message: '注册成功' };
        } else {
          return { ok: false, message: data.error || '注册失败' };
        }
      } catch {
        return { ok: false, message: '网络错误' };
      }
    },
    [persistUser]
  );

  const logout = useCallback(() => {
    persistUser(null);
    setCart([]);
  }, [persistUser]);

  const adminLogin = useCallback(
    (account: string, password: string) => {
      const a = account.trim();
      if (!a || !password) {
        return { ok: false, message: '请输入账号和密码' };
      }
      if (a === 'admin' && password.length > 0) {
        const next = { account: 'admin', displayName: '管理员' };
        persistAdmin(next);
        return { ok: true, message: '登录成功' };
      }
      persistAdmin({ account: a, displayName: a });
      return { ok: true, message: '登录成功（演示）' };
    },
    [persistAdmin]
  );

  const adminLogout = useCallback(() => {
    persistAdmin(null);
  }, [persistAdmin]);

  const addToCart = useCallback(
    (product: Product, qty = 1) => {
      if (!product.onShelf) {
        return { ok: false, message: '商品已下架' };
      }
      const nextQty = (cart.find((l) => l.product.id === product.id)?.qty ?? 0) + qty;
      if (nextQty > product.stock) {
        return { ok: false, message: '库存不足' };
      }
      setCart((prev) => {
        const i = prev.findIndex((l) => l.product.id === product.id);
        if (i >= 0) {
          const next = [...prev];
          next[i] = { ...next[i], qty: next[i].qty + qty };
          return next;
        }
        return [...prev, { product, qty }];
      });
      return { ok: true, message: '已加入购物车' };
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
    (delivery: FoodOrder['delivery']) => {
      if (cart.length === 0) return null;
      const total = cart.reduce((s, l) => s + l.product.price * l.qty, 0);
      const order: FoodOrder = {
        id: `FO${Date.now()}`,
        createdAt: new Date().toLocaleString('zh-CN'),
        items: cart.map((l) => ({ ...l })),
        total,
        delivery,
        status: '待支付',
        deliveryStatus: 'none',
      };
      setFoodOrders((o) => [order, ...o]);
      clearCart();
      return order;
    },
    [cart, clearCart]
  );

  const payFoodOrder = useCallback((orderId: string) => {
    setFoodOrders((orders) =>
      orders.map((o) => {
        if (o.id !== orderId) return o;
        if (o.delivery === '配送至座位') {
          return {
            ...o,
            status: '已支付',
            deliveryStatus: 'await_checkin' as DeliveryStatus,
          };
        }
        return {
          ...o,
          status: '制作中',
          deliveryStatus: 'pickup_ready' as DeliveryStatus,
        };
      })
    );
  }, []);

  const cancelFoodOrder = useCallback((orderId: string) => {
    setFoodOrders((orders) =>
      orders.map((o) =>
        o.id === orderId
          ? { ...o, status: '已取消' as OrderStatus, deliveryStatus: 'none' as DeliveryStatus }
          : o
      )
    );
  }, []);

  const createReservation = useCallback(
    (r: Omit<Reservation, 'id' | 'verifyCode' | 'status'>) => {
      const res: Reservation = {
        ...r,
        id: `RV${Date.now()}`,
        status: '待支付',
        verifyCode: Math.random().toString(36).slice(2, 10).toUpperCase(),
      };
      setReservations((list) => [res, ...list]);
      return res;
    },
    []
  );

  const payReservation = useCallback((id: string) => {
    setReservations((list) => list.map((x) => (x.id === id ? { ...x, status: '进行中' } : x)));
  }, []);

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
    (seatCode: string, date: string) =>
      BOOKING_HOURS.every((h) => isHourTakenForSeat(seatCode, date, h)),
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

  const cancelReservation = useCallback(
    (id: string) => {
      const r = reservations.find((x) => x.id === id);
      if (!r) return { ok: false, message: '未找到预约' };
      if (r.checkInAt) return { ok: false, message: '已打卡不可取消预约' };
      if (r.status !== '待支付' && r.status !== '进行中') {
        return { ok: false, message: '当前状态不可取消' };
      }
      setReservations((list) => list.map((x) => (x.id === id ? { ...x, status: '已取消' } : x)));
      return { ok: true, message: '已取消预约' };
    },
    [reservations]
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

  const cancelWaitlist = useCallback((id: string) => {
    setWaitlist((w) => w.map((x) => (x.id === id ? { ...x, status: '已取消' } : x)));
  }, []);

  const bumpDeliveryAfterCheckIn = useCallback(() => {
    setFoodOrders((orders) =>
      orders.map((o) => {
        if (
          o.delivery === '配送至座位' &&
          o.status === '已支付' &&
          o.deliveryStatus === 'await_checkin'
        ) {
          return {
            ...o,
            status: '制作中' as OrderStatus,
            deliveryStatus: 'making' as DeliveryStatus,
          };
        }
        return o;
      })
    );
  }, []);

  const checkIn = useCallback(
    (reservationId: string) => {
      const at = new Date().toLocaleString('zh-CN');
      setReservations((list) => list.map((x) => (x.id === reservationId ? { ...x, checkInAt: at } : x)));
      bumpDeliveryAfterCheckIn();
    },
    [bumpDeliveryAfterCheckIn]
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

  const setSeatEnabled = useCallback((seatId: string, enabled: boolean) => {
    setSeats((list) => list.map((s) => (s.id === seatId ? { ...s, enabled } : s)));
  }, []);

  const setProductStock = useCallback((productId: string, stock: number) => {
    setProducts((list) => list.map((p) => (p.id === productId ? { ...p, stock: Math.max(0, stock) } : p)));
  }, []);

  const setProductOnShelf = useCallback((productId: string, onShelf: boolean) => {
    setProducts((list) => list.map((p) => (p.id === productId ? { ...p, onShelf } : p)));
  }, []);

  const adminSetOrderStatus = useCallback((orderId: string, status: OrderStatus) => {
    setFoodOrders((orders) =>
      orders.map((o) =>
        o.id === orderId
          ? {
            ...o,
            status,
            deliveryStatus: status === '已取消' ? ('none' as DeliveryStatus) : o.deliveryStatus,
          }
          : o
      )
    );
  }, []);

  const adminSetDeliveryStatus = useCallback((orderId: string, deliveryStatus: DeliveryStatus) => {
    setFoodOrders((orders) => orders.map((o) => (o.id === orderId ? { ...o, deliveryStatus } : o)));
  }, []);

  const adminMarkReservation = useCallback((id: string, mark: '到场' | '违约') => {
    setReservations((list) =>
      list.map((r) => {
        if (r.id !== id) return r;
        if (mark === '到场') {
          return { ...r, status: '已完成' as ReservationStatus };
        }
        return { ...r, status: '违约' as ReservationStatus };
      })
    );
  }, []);

  const adminClearBreachLimit = useCallback((phone: string) => {
    setBreachRecords((list) => list.filter((b) => b.phone !== phone));
  }, []);

  const adminCreateAnnouncement = useCallback((input: { title: string; content: string }) => {
    const now = new Date().toLocaleString('zh-CN');
    const item: Announcement = {
      id: `AN${Date.now()}`,
      title: input.title.trim(),
      content: input.content.trim(),
      publishedAt: now,
      updatedAt: now,
    };
    setAnnouncements((list) => [item, ...list]);
  }, []);

  const adminUpdateAnnouncement = useCallback(
    (id: string, input: { title: string; content: string }) => {
      const now = new Date().toLocaleString('zh-CN');
      setAnnouncements((list) =>
        list.map((item) =>
          item.id === id
            ? {
              ...item,
              title: input.title.trim(),
              content: input.content.trim(),
              updatedAt: now,
            }
            : item
        )
      );
    },
    []
  );

  const adminDeleteAnnouncement = useCallback((id: string) => {
    setAnnouncements((list) => list.filter((item) => item.id !== id));
  }, []);

  const value = useMemo<AppContextValue>(
    () => ({
      user,
      adminUser,
      seats,
      products,
      cart,
      reservations,
      foodOrders,
      announcements,
      breachRecords,
      breachCount,
      login,
      register,
      logout,
      adminLogin,
      adminLogout,
      addToCart,
      setCartQty,
      removeFromCart,
      clearCart,
      placeFoodOrder,
      payFoodOrder,
      cancelFoodOrder,
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
      announcements,
      breachRecords,
      breachCount,
      login,
      register,
      logout,
      adminLogin,
      adminLogout,
      addToCart,
      setCartQty,
      removeFromCart,
      clearCart,
      placeFoodOrder,
      payFoodOrder,
      cancelFoodOrder,
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