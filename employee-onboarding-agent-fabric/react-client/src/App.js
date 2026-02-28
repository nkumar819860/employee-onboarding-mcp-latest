import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Box } from '@mui/material';

// Components
import Navbar from './components/Navbar';
import Dashboard from './components/Dashboard';
import EmployeeOnboarding from './components/EmployeeOnboarding';
import AssetAllocation from './components/AssetAllocation';
import NLPChat from './components/NLPChat';
import Analytics from './components/Analytics';

// Professional Theme with Rich Colors and Poppins Font
const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#2E4C6D', // Professional Navy Blue
      light: '#5A7FA7',
      dark: '#1E3447',
      contrastText: '#FFFFFF',
    },
    secondary: {
      main: '#FC7300', // Vibrant Orange
      light: '#FD9A33',
      dark: '#E65100',
      contrastText: '#FFFFFF',
    },
    success: {
      main: '#2E7D59', // Professional Green
      light: '#4CAF50',
      dark: '#1B5E20',
    },
    warning: {
      main: '#F57C00', // Warm Orange
      light: '#FFB74D',
      dark: '#E65100',
    },
    error: {
      main: '#C62828', // Professional Red
      light: '#EF5350',
      dark: '#B71C1C',
    },
    background: {
      default: '#F8FAFC', // Light Gray-Blue
      paper: '#FFFFFF',
    },
    text: {
      primary: '#2D3748', // Dark Gray
      secondary: '#4A5568', // Medium Gray
    },
    divider: '#E2E8F0',
  },
  typography: {
    fontFamily: '"Poppins", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 700,
      fontSize: '2.5rem',
      lineHeight: 1.2,
      color: '#2D3748',
    },
    h2: {
      fontWeight: 600,
      fontSize: '2rem',
      lineHeight: 1.3,
      color: '#2D3748',
    },
    h3: {
      fontWeight: 600,
      fontSize: '1.75rem',
      lineHeight: 1.3,
      color: '#2D3748',
    },
    h4: {
      fontWeight: 600,
      fontSize: '1.5rem',
      lineHeight: 1.4,
      color: '#2D3748',
    },
    h5: {
      fontWeight: 500,
      fontSize: '1.25rem',
      lineHeight: 1.4,
      color: '#2D3748',
    },
    h6: {
      fontWeight: 500,
      fontSize: '1rem',
      lineHeight: 1.5,
      color: '#2D3748',
    },
    subtitle1: {
      fontWeight: 500,
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    subtitle2: {
      fontWeight: 500,
      fontSize: '0.875rem',
      lineHeight: 1.57,
    },
    body1: {
      fontWeight: 400,
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    body2: {
      fontWeight: 400,
      fontSize: '0.875rem',
      lineHeight: 1.43,
    },
    button: {
      fontWeight: 500,
      fontSize: '0.875rem',
      textTransform: 'none',
    },
  },
  shape: {
    borderRadius: 12,
  },
  shadows: [
    'none',
    '0px 2px 4px rgba(46, 76, 109, 0.08)',
    '0px 4px 8px rgba(46, 76, 109, 0.12)',
    '0px 8px 16px rgba(46, 76, 109, 0.16)',
    '0px 12px 24px rgba(46, 76, 109, 0.2)',
    '0px 16px 32px rgba(46, 76, 109, 0.24)',
    '0px 20px 40px rgba(46, 76, 109, 0.28)',
    '0px 24px 48px rgba(46, 76, 109, 0.32)',
    '0px 28px 56px rgba(46, 76, 109, 0.36)',
    '0px 32px 64px rgba(46, 76, 109, 0.4)',
    '0px 36px 72px rgba(46, 76, 109, 0.44)',
    '0px 40px 80px rgba(46, 76, 109, 0.48)',
    '0px 44px 88px rgba(46, 76, 109, 0.52)',
    '0px 48px 96px rgba(46, 76, 109, 0.56)',
    '0px 52px 104px rgba(46, 76, 109, 0.6)',
    '0px 56px 112px rgba(46, 76, 109, 0.64)',
    '0px 60px 120px rgba(46, 76, 109, 0.68)',
    '0px 64px 128px rgba(46, 76, 109, 0.72)',
    '0px 68px 136px rgba(46, 76, 109, 0.76)',
    '0px 72px 144px rgba(46, 76, 109, 0.8)',
    '0px 76px 152px rgba(46, 76, 109, 0.84)',
    '0px 80px 160px rgba(46, 76, 109, 0.88)',
    '0px 84px 168px rgba(46, 76, 109, 0.92)',
    '0px 88px 176px rgba(46, 76, 109, 0.96)',
    '0px 92px 184px rgba(46, 76, 109, 1)',
  ],
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: 'none',
          fontWeight: 500,
          padding: '10px 24px',
        },
        contained: {
          boxShadow: '0px 4px 12px rgba(46, 76, 109, 0.15)',
          '&:hover': {
            boxShadow: '0px 6px 16px rgba(46, 76, 109, 0.2)',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0px 4px 12px rgba(46, 76, 109, 0.1)',
          border: '1px solid rgba(226, 232, 240, 0.8)',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: '0px 2px 8px rgba(46, 76, 109, 0.15)',
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 8,
          },
        },
      },
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
          <Navbar />
          <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/onboarding" element={<EmployeeOnboarding />} />
              <Route path="/assets" element={<AssetAllocation />} />
              <Route path="/chat" element={<NLPChat />} />
              <Route path="/analytics" element={<Analytics />} />
            </Routes>
          </Box>
        </Box>
      </Router>
    </ThemeProvider>
  );
}

export default App;
