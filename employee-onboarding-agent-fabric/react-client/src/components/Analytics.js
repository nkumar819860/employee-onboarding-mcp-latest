import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Alert,
} from '@mui/material';
import { Analytics as AnalyticsIcon } from '@mui/icons-material';

const Analytics = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <AnalyticsIcon color="primary" />
        Analytics & Reporting
      </Typography>
      
      <Card>
        <CardContent>
          <Alert severity="info">
            This module provides analytics and reporting capabilities. Use the NLP Chat to query analytics data.
          </Alert>
          <Typography variant="body1" sx={{ mt: 2 }}>
            Features include:
          </Typography>
          <ul>
            <li>Employee onboarding metrics</li>
            <li>Asset allocation statistics</li>
            <li>System performance monitoring</li>
            <li>Trend analysis and insights</li>
          </ul>
        </CardContent>
      </Card>
    </Box>
  );
};

export default Analytics;
