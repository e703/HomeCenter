import React from 'react';

function SystemList({ systems }) {
  return (
    <div className="system-list">
      {systems.map((system) => (
        <div key={system.id} className="system-item">
          <a href={system.url} target="_blank" rel="noopener noreferrer">
            {system.name}
          </a>
        </div>
      ))}
    </div>
  );
}

export default SystemList;
