import { useApp } from '../context/AppContext';

export function Announcements() {
  const { announcements } = useApp();

  return (
    <>
      <h1 className="page-title">公告中心</h1>
      <p className="page-sub">查看管理员发布的全部公告</p>

      {announcements.length === 0 ? (
        <section className="card">
          <div className="empty-hint">暂无公告</div>
        </section>
      ) : (
        <section className="card">
          <div className="home-notice-list">
            {announcements.map((item) => (
              <article key={item.id} className="home-notice-item">
                <div className="home-notice-title">{item.title}</div>
                <p className="home-notice-content">{item.content}</p>
                <div className="home-notice-time">
                  发布时间：{item.publishedAt} · 更新时间：{item.updatedAt}
                </div>
              </article>
            ))}
          </div>
        </section>
      )}
    </>
  );
}
