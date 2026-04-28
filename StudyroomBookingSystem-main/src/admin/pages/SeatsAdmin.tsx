import { useApp } from '../../context/AppContext';

export function SeatsAdmin() {
  const { seats, setSeatEnabled } = useApp();

  return (
    <>
      <h1 className="admin-page-title">座位管理</h1>
      <p className="admin-page-desc">座位编号、区域、配置与启用状态</p>

      <div className="admin-card admin-table-wrap">
        <table className="admin-table">
          <thead>
            <tr>
              <th>编号</th>
              <th>区域</th>
              <th>配置</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            {seats.map((s) => (
              <tr key={s.id}>
                <td>{s.code}</td>
                <td>{s.zone}</td>
                <td style={{ fontSize: '0.82rem', color: '#666' }}>
                  {[
                    s.hasOutlet && '插座',
                    s.hasLamp && '台灯',
                    s.hasDivider && '挡板',
                    s.nearWindow && '靠窗',
                  ]
                    .filter(Boolean)
                    .join(' · ') || '—'}
                </td>
                <td>{s.enabled ? '启用' : '禁用'}</td>
                <td>
                  <button
                    type="button"
                    className="admin-btn"
                    onClick={() => setSeatEnabled(s.id, !s.enabled)}
                  >
                    {s.enabled ? '禁用' : '启用'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
