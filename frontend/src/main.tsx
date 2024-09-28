import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import Index from './components/Index.tsx';
import Board from './components/Board.tsx';
import './index.css';

const router = createBrowserRouter([
  {
    path: '/',
    element: <Index />
  },
  {
    path: '/:boardId',
    element: <Board />
  }
]);

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>
);
