import { useEffect, useMemo, useState } from 'react';
import { useApp } from '../../context/AppContext';
import { Toast } from '../../components/Toast';

export function AnnouncementsAdmin() {
  const {
    adminAnnouncements,
    adminCreateAnnouncement,
    adminUpdateAnnouncement,
    adminDeleteAnnouncement,
    refreshAdminAnnouncements,
  } = useApp();
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    void refreshAdminAnnouncements();
  }, [refreshAdminAnnouncements]);

  const editingItem = useMemo(
    () => adminAnnouncements.find((item) => item.id === editingId) ?? null,
    [adminAnnouncements, editingId]
  );

  async function handleSave() {
    const t = title.trim();
    const c = content.trim();
    if (!t || !c) {
      setToast('请填写标题和内容');
      return;
    }
    setSaving(true);
    try {
      if (editingItem) {
        await adminUpdateAnnouncement(editingItem.id, { title: t, content: c });
        setToast('公告已更新');
      } else {
        await adminCreateAnnouncement({ title: t, content: c });
        setToast('公告已发布');
      }
      setTitle('');
      setContent('');
      setEditingId(null);
    } catch (err) {
      setToast(err instanceof Error ? err.message : '保存失败');
    } finally {
      setSaving(false);
    }
  }

  return (
    <>
      <h1 className="admin-page-title">公告管理</h1>
      <p className="admin-page-desc">发布、编辑、删除公告内容（用户端首页同步展示）</p>

      <div className="admin-card" style={{ display: 'grid', gap: 10 }}>
        <input
          className="admin-input"
          placeholder="公告标题"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
        <textarea
          className="admin-input"
          placeholder="公告内容"
          rows={4}
          value={content}
          onChange={(e) => setContent(e.target.value)}
        />
        <div style={{ display: 'flex', gap: 8 }}>
          <button
            type="button"
            className="admin-btn admin-btn-primary"
            disabled={saving}
            onClick={() => void handleSave()}
          >
            {saving ? '保存中…' : editingItem ? '保存修改' : '发布公告'}
          </button>
          {editingItem ? (
            <button
              type="button"
              className="admin-btn"
              onClick={() => {
                setEditingId(null);
                setTitle('');
                setContent('');
              }}
            >
              取消编辑
            </button>
          ) : null}
        </div>
      </div>

      <div className="admin-card admin-table-wrap">
        <table className="admin-table">
          <thead>
            <tr>
              <th>标题</th>
              <th>内容</th>
              <th>发布时间</th>
              <th>更新时间</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            {adminAnnouncements.map((item) => (
              <tr key={item.id}>
                <td>{item.title}</td>
                <td>{item.content}</td>
                <td>{item.publishedAt}</td>
                <td>{item.updatedAt}</td>
                <td style={{ display: 'flex', gap: 8 }}>
                  <button
                    type="button"
                    className="admin-btn"
                    onClick={() => {
                      setEditingId(item.id);
                      setTitle(item.title);
                      setContent(item.content);
                    }}
                  >
                    编辑
                  </button>
                  <button
                    type="button"
                    className="admin-btn"
                    onClick={() => {
                      if (!window.confirm('确定删除这条公告？')) return;
                      if (editingId === item.id) {
                        setEditingId(null);
                        setTitle('');
                        setContent('');
                      }
                      void adminDeleteAnnouncement(item.id)
                        .then(() => setToast('已删除'))
                        .catch((err) =>
                          setToast(err instanceof Error ? err.message : '删除失败')
                        );
                    }}
                  >
                    删除
                  </button>
                </td>
              </tr>
            ))}
            {adminAnnouncements.length === 0 ? (
              <tr>
                <td colSpan={5} style={{ textAlign: 'center' }}>
                  暂无公告
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>

      {toast && <Toast message={toast} onDone={() => setToast(null)} />}
    </>
  );
}
