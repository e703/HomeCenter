import React, { useState } from 'react';

function AddSystemForm({ onAddSystem }) {
  const [name, setName] = useState('');
  const [url, setUrl] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onAddSystem({ name, url });
    setName('');
    setUrl('');
  };

  return (
    <form className="add-system-form" onSubmit={handleSubmit}>
      <input
        type="text"
        placeholder="系统名称"
        value={name}
        onChange={(e) => setName(e.target.value)}
        required
      />
      <input
        type="url"
        placeholder="系统URL"
        value={url}
        onChange={(e) => setUrl(e.target.value)}
        required
      />
      <button type="submit">添加系统</button>
    </form>
  );
}

export default AddSystemForm;
