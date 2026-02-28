import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  Box,
  Chip,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  PersonAdd as PersonAddIcon,
  Assignment as AssignmentIcon,
  Chat as ChatIcon,
  Analytics as AnalyticsIcon,
  Cloud as CloudIcon,
} from '@mui/icons-material';
import { useNavigate, useLocation } from 'react-router-dom';

const Navbar = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const navigationItems = [
    { path: '/', label: 'Dashboard', icon: <DashboardIcon /> },
    { path: '/onboarding', label: 'Onboarding', icon: <PersonAddIcon /> },
    { path: '/assets', label: 'Assets', icon: <AssignmentIcon /> },
    { path: '/chat', label: 'NLP Chat', icon: <ChatIcon /> },
    { path: '/analytics', label: 'Analytics', icon: <AnalyticsIcon /> },
  ];

  return (
    <AppBar position="static">
      <Toolbar>
        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
          Employee Onboarding Agent Fabric
        </Typography>
        
        {/* CloudHub Environment Indicator */}
        <Chip 
          icon={<CloudIcon />}
          label="CloudHub Production"
          size="small"
          variant="outlined"
          sx={{ 
            color: 'white', 
            borderColor: 'rgba(255,255,255,0.3)',
            mr: 2 
          }}
        />
        
        <Box sx={{ display: 'flex', gap: 1 }}>
          {navigationItems.map((item) => (
            <Button
              key={item.path}
              color="inherit"
              startIcon={item.icon}
              onClick={() => navigate(item.path)}
              variant={location.pathname === item.path ? 'outlined' : 'text'}
              sx={{
                color: location.pathname === item.path ? 'primary.main' : 'inherit',
                backgroundColor: location.pathname === item.path ? 'rgba(255,255,255,0.1)' : 'transparent',
              }}
            >
              {item.label}
            </Button>
          ))}
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar;
