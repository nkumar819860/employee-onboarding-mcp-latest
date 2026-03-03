import React, { useState } from 'react';
import AgentFabricNLPClient from './components/AgentFabricNLPClient';
import './App.css';

function App() {
  const [darkMode, setDarkMode] = useState(false);

  return (
    <div className={`App ${darkMode ? 'dark-mode' : ''}`}>
      <header className="App-header">
        <div className="header-content">
          <h1>🤖 Agent Fabric NLP Testing Client</h1>
          <p>Standalone React client for testing NLP with Agent Fabric service hosted on Docker</p>
          <button 
            className="theme-toggle"
            onClick={() => setDarkMode(!darkMode)}
            title="Toggle theme"
          >
            {darkMode ? '☀️' : '🌙'}
          </button>
        </div>
      </header>
      
      <main className="App-main">
        <AgentFabricNLPClient />
      </main>
      
      <footer className="App-footer">
        <p>
          Built with React • Connected to Agent Fabric MCP Services
        </p>
      </footer>
    </div>
  );
}

export default App;
