import React from 'react';
import ReactDOM from 'react-dom/client';
import './style/index.css';
import "./style/index.small.css";
import App from './App';

//using react-redux for storing user account
import { Provider } from 'react-redux';
import store from './state/store';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>
);

