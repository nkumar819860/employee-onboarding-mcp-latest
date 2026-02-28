import React, { useState } from 'react';
import {
  FormControl,
  Select,
  MenuItem,
  Chip,
  Box,
  Snackbar,
  Alert,
  Typography,
  Tooltip
} from '@mui/material';
import {
  CloudQueue as CloudIcon,
  Computer as LocalIcon,
  Build as StagingIcon
} from '@mui/icons-material';
import { useEnvironment } from '../contexts/EnvironmentContext';

const EnvironmentSelector = () => {
  const { currentEnvironment, environmentConfig, environments, switchEnvironment } = useEnvironment();
  const [notification, setNotification] = useState({ open: false, message: '', severity: 'info' });

  const getEnvironmentIcon = (env) => {
    switch (env) {
      case 'development':
        return <LocalIcon fontSize="small" />;
      case 'staging':
        return <StagingIcon fontSize="small" />;
      case 'production':
        return <CloudIcon fontSize="small" />;
      default:
        return <CloudIcon fontSize="small" />;
    }
  };

  const handleEnvironmentChange = (event) => {
    const newEnvironment = event.target.value;
    if (newEnvironment !== currentEnvironment) {
      console.log(`Switching environment from ${currentEnvironment} to ${newEnvironment}`);
      
      switchEnvironment(newEnvironment);
      
      setNotification({
        open: true,
        message: `Environment switched to ${environments[newEnvironment].name}. Content refreshed with new URLs.`,
        severity: 'success'
      });
    }
  };

  const handleCloseNotification = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setNotification({ ...notification, open: false });
  };

  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
      <Typography variant="body2" sx={{ color: 'inherit', minWidth: 'fit-content' }}>
        Environment:
      </Typography>
      
      <Tooltip title={`Current: ${environmentConfig.name} (${environmentConfig.baseURL})`}>
        <FormControl size="small" sx={{ minWidth: 140 }}>
          <Select
            value={currentEnvironment}
            onChange={handleEnvironmentChange}
            displayEmpty
            variant="outlined"
            sx={{
              color: 'white',
              '& .MuiOutlinedInput-notchedOutline': {
                borderColor: 'rgba(255, 255, 255, 0.3)',
              },
              '&:hover .MuiOutlinedInput-notchedOutline': {
                borderColor: 'rgba(255, 255, 255, 0.5)',
              },
              '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                borderColor: 'white',
              },
              '& .MuiSvgIcon-root': {
                color: 'white',
              },
            }}
            renderValue={(selected) => (
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                {getEnvironmentIcon(selected)}
                <Typography variant="body2" sx={{ color: 'inherit' }}>
                  {environments[selected]?.name || selected}
                </Typography>
              </Box>
            )}
          >
            {Object.entries(environments).map(([key, env]) => (
              <MenuItem key={key} value={key}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, width: '100%' }}>
                  {getEnvironmentIcon(key)}
                  <Typography variant="body2">
                    {env.name}
                  </Typography>
                  <Chip
                    size="small"
                    label={key.toUpperCase()}
                    sx={{
                      backgroundColor: env.color,
                      color: 'white',
                      height: 20,
                      fontSize: '0.75rem',
                      marginLeft: 'auto'
                    }}
                  />
                </Box>
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Tooltip>

      {/* Current environment indicator */}
      <Chip
        icon={getEnvironmentIcon(currentEnvironment)}
        label={environmentConfig.name}
        size="small"
        sx={{
          backgroundColor: environmentConfig.color,
          color: 'white',
          '& .MuiChip-icon': {
            color: 'white'
          }
        }}
      />

      {/* Notification for environment changes */}
      <Snackbar
        open={notification.open}
        autoHideDuration={4000}
        onClose={handleCloseNotification}
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
      >
        <Alert 
          onClose={handleCloseNotification} 
          severity={notification.severity}
          variant="filled"
          sx={{ width: '100%' }}
        >
          {notification.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default EnvironmentSelector;
