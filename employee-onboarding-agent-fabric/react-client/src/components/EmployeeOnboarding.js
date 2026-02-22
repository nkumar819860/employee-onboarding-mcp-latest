import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Alert,
} from '@mui/material';
import { PersonAdd as PersonAddIcon } from '@mui/icons-material';

const EmployeeOnboarding = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <PersonAddIcon color="primary" />
        Employee Onboarding
      </Typography>
      
      <Card>
        <CardContent>
          <Alert severity="info">
            This module manages employee onboarding processes. Use the NLP Chat to interact with onboarding features.
          </Alert>
          <Typography variant="body1" sx={{ mt: 2 }}>
            Features include:
          </Typography>
          <ul>
            <li>Create new employee records</li>
            <li>Track onboarding progress</li>
            <li>Manage employee status</li>
            <li>Integration with asset allocation</li>
          </ul>
        </CardContent>
      </Card>
    </Box>
  );
};

export default EmployeeOnboarding;
