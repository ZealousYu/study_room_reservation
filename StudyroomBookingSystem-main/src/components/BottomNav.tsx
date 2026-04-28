import { NavLink } from 'react-router-dom';

const items = [
  { to: '/', label: '首页', icon: '🌿' },
  { to: '/booking', label: '预约', icon: '🪑' },
  { to: '/food', label: '轻食', icon: '☕' },
  { to: '/profile', label: '我的', icon: '👤' },
];

export function BottomNav() {
  return (
    <nav className="nav-bottom" aria-label="主导航">
      {items.map(({ to, label, icon }) => (
        <NavLink
          key={to}
          to={to}
          end={to === '/'}
          className={({ isActive }) => (isActive ? 'active' : undefined)}
        >
          <span className="nav-ico" aria-hidden>
            {icon}
          </span>
          {label}
        </NavLink>
      ))}
    </nav>
  );
}
