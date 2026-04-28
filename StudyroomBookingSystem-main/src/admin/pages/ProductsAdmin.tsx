import { useApp } from '../../context/AppContext';

export function ProductsAdmin() {
  const { products, setProductStock, setProductOnShelf } = useApp();

  return (
    <>
      <h1 className="admin-page-title">商品管理</h1>
      <p className="admin-page-desc">库存、上下架（库存为 0 时请下架）</p>

      <div className="admin-card admin-table-wrap">
        <table className="admin-table">
          <thead>
            <tr>
              <th>名称</th>
              <th>分类</th>
              <th>单价</th>
              <th>库存</th>
              <th>上架</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            {products.map((p) => (
              <tr key={p.id}>
                <td>{p.name}</td>
                <td>{p.category}</td>
                <td>¥{p.price}</td>
                <td>
                  <input
                    type="number"
                    min={0}
                    className="admin-input"
                    style={{ width: 72 }}
                    value={p.stock}
                    onChange={(e) =>
                      setProductStock(p.id, Number(e.target.value) || 0)
                    }
                  />
                </td>
                <td>{p.onShelf ? '是' : '否'}</td>
                <td>
                  <button
                    type="button"
                    className="admin-btn"
                    onClick={() => setProductOnShelf(p.id, !p.onShelf)}
                  >
                    {p.onShelf ? '下架' : '上架'}
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
