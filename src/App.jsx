import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import SystemList from './components/SystemList';
import AddSystemForm from './components/AddSystemForm';
import Loader from './components/Loader';
import './styles.css';

function App() {
  const [systems, setSystems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // 获取系统列表
  useEffect(() => {
    const fetchSystems = async () => {
      try {
        const response = await fetch('/api/systems');
        if (!response.ok) throw new Error('获取数据失败');
        const data = await response.json();
        setSystems(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSystems();
  }, []);

  // 添加新系统
  const handleAddSystem = async (newSystem) => {
    try {
      const response = await fetch('/api/systems', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newSystem),
      });
      if (!response.ok) throw new Error('添加系统失败');
      const data = await response.json();
      setSystems([...systems, data]);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="app">
      <Header />
      {loading ? (
        <Loader />
      ) : error ? (
        <div className="error">{error}</div>
      ) : (
        <>
          <SystemList systems={systems} />
          <AddSystemForm onAddSystem={handleAddSystem} />
        </>
      )}
    </div>
  );
}

export default App;
