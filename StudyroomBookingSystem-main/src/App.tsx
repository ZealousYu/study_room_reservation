import { Navigate, Route, Routes } from 'react-router-dom';
import { AdminLayout } from './admin/AdminLayout';
import { AdminLogin } from './admin/AdminLogin';
import { RequireAdmin } from './admin/RequireAdmin';
import { Dashboard } from './admin/pages/Dashboard';
import { SeatsAdmin } from './admin/pages/SeatsAdmin';
import { ReservationsAdmin } from './admin/pages/ReservationsAdmin';
import { ProductsAdmin } from './admin/pages/ProductsAdmin';
import { OrdersAdmin } from './admin/pages/OrdersAdmin';
import { BreachAdmin } from './admin/pages/BreachAdmin';
import { AppLayout } from './components/AppLayout';
import { RequireAuth } from './components/RequireAuth';
import { Breach } from './pages/Breach';
import { Booking } from './pages/Booking';
import { Cart } from './pages/Cart';
import { Food } from './pages/Food';
import { ForgotPassword } from './pages/ForgotPassword';
import { Home } from './pages/Home';
import { Login } from './pages/Login';
import { Orders } from './pages/Orders';
import { Profile } from './pages/Profile';
import { Register } from './pages/Register';
import { Reservations } from './pages/Reservations';

export function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />

      <Route path="/admin/login" element={<AdminLogin />} />
      <Route
        path="/admin"
        element={
          <RequireAdmin>
            <AdminLayout />
          </RequireAdmin>
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="seats" element={<SeatsAdmin />} />
        <Route path="reservations" element={<ReservationsAdmin />} />
        <Route path="products" element={<ProductsAdmin />} />
        <Route path="orders" element={<OrdersAdmin />} />
        <Route path="breach" element={<BreachAdmin />} />
      </Route>

      <Route
        element={
          <RequireAuth>
            <AppLayout />
          </RequireAuth>
        }
      >
        <Route path="/" element={<Home />} />
        <Route path="/booking" element={<Booking />} />
        <Route path="/food" element={<Food />} />
        <Route path="/cart" element={<Cart />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/orders" element={<Orders />} />
        <Route path="/reservations" element={<Reservations />} />
        <Route path="/breach" element={<Breach />} />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
