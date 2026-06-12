import { useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';

export function Toast({
  message,
  onDone,
  duration = 2600,
}: {
  message: string;
  onDone: () => void;
  duration?: number;
}) {
  const onDoneRef = useRef(onDone);
  onDoneRef.current = onDone;

  useEffect(() => {
    const timer = window.setTimeout(() => onDoneRef.current(), duration);
    return () => window.clearTimeout(timer);
  }, [message, duration]);

  return createPortal(
    <div className="toast" role="status" aria-live="polite">
      {message}
    </div>,
    document.body
  );
}
