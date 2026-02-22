import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Alert,
} from '@mui/material';
import { Assignment as AssignmentIcon } from '@mui/icons-material';

const AssetAllocation = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <AssignmentIcon color="primary" />
        Asset Allocation
      </Typography>
      
      <Card>
        <CardContent>
          <Alert severity="info">
            This module manages asset allocation for employees. Use the NLP Chat to interact with asset features.
          </Alert>
          <Typography variant="body1" sx={{ mt: 2 }}>
            Features include:
          </Typography>
          <ul>
            <li>View available assets inventory</li>
            <li>Allocate assets to employees</li>
            <li>Track asset assignments</li>
            <li>Manage asset returns and maintenance</li>
          </ul>
        </CardContent>
      </Card>
    </Box>
  );
};

export default AssetAllocation;
