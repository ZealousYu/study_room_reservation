/**
 * API 基址：开发默认 localhost:8080；生产在 Netlify 环境变量里配置 VITE_API_URL
 */
const raw = import.meta.env.VITE_API_URL?.trim() || 'http://localhost:8080';

export const API_BASE = raw.replace(/\/$/, '');

export function apiUrl(path: string): string {
  return `${API_BASE}${path.startsWith('/') ? path : `/${path}`}`;
}

/** 商品图片等静态资源（后端 /images 路由） */
export function assetUrl(path: string): string {
  if (!path) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  const p = path.startsWith('/') ? path : `/${path}`;
  return `${API_BASE}${p}`;
}
