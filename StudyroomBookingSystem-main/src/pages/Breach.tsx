import { useApp } from '../context/AppContext';

export function Breach() {
  const { breachRecords, breachCount } = useApp();

  return (
    <>
      <h1 className="page-title">违约记录</h1>
      <p className="page-sub">累计 {breachCount} 次（演示数据）</p>

      {breachRecords.length === 0 ? (
        <p className="empty-hint card">暂无违约记录，继续保持～</p>
      ) : (
        breachRecords.map((b) => (
          <div key={b.id} className="card">
            <div style={{ fontWeight: 600 }}>{b.reason}</div>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: 4 }}>
              {b.at}
            </div>
          </div>
        ))
      )}
    </>
  );
}
