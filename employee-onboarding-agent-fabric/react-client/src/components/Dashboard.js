import React, { useState, useEffect } from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  LinearProgress,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Chip,
  Alert,
} from '@mui/material';
import {
  People as PeopleIcon,
  Assignment as AssignmentIcon,
  Notifications as NotificationsIcon,
  TrendingUp as TrendingUpIcon,
  CheckCircle as CheckCircleIcon,
  Schedule as ScheduleIcon,
  Warning as WarningIcon,
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

const Dashboard = () => {
  const [analytics, setAnalytics] = useState(null);
  const [healthStatus, setHealthStatus] = useState([]);
  const [recentActivities, setRecentActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      const [analyticsData, healthData] = await Promise.all([
        apiService.getAnalytics(),
        apiService.checkHealth(),
      ]);
      
      setAnalytics(analyticsData);
      setHealthStatus(healthData);
      
      // Mock recent activities
      setRecentActivities([
        {
          id: 1,
          type: 'employee_created',
          message: 'New employee John Smith created',
          timestamp: new Date(Date.now() - 30 * 60 * 1000),
          status: 'success'
        },
        {
          id: 2,
          type: 'asset_allocated',
          message: 'Laptop allocated to EMP001',
          timestamp: new Date(Date.now() - 60 * 60 * 1000),
          status: 'success'
        },
        {
          id: 3,
          type: 'notification_sent',
          message: 'Welcome notification sent to maria.garcia@company.com',
          timestamp: new Date(Date.now() - 120 * 60 * 1000),
          status: 'info'
        },
      ]);
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const getHealthStatusColor = (status) => {
    switch (status) {
      case 'UP': return 'success';
      case 'DOWN': return 'error';
      default: return 'warning';
    }
  };

  const getActivityIcon = (type) => {
    switch (type) {
      case 'employee_created': return <PeopleIcon />;
      case 'asset_allocated': return <AssignmentIcon />;
      case 'notification_sent': return <NotificationsIcon />;
      default: return <CheckCircleIcon />;
    }
  };

  if (loading) {
    return (
      <Box sx={{ width: '100%', mt: 2 }}>
        <LinearProgress />
        <Typography variant="h6" sx={{ mt: 2, textAlign: 'center' }}>
          Loading Dashboard...
        </Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ flexGrow: 1, p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>

      {/* Key Metrics */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <PeopleIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Employees</Typography>
              </Box>
              <Typography variant="h4" color="primary">
                {analytics?.totalEmployees || 0}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Total employees
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <ScheduleIcon color="warning" sx={{ mr: 1 }} />
                <Typography variant="h6">Onboarding</Typography>
              </Box>
              <Typography variant="h4" color="warning.main">
                {analytics?.activeOnboarding || 0}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                In progress
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <AssignmentIcon color="success" sx={{ mr: 1 }} />
                <Typography variant="h6">Assets</Typography>
              </Box>
              <Typography variant="h4" color="success.main">
                {analytics?.availableAssets || 0}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Available assets
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <NotificationsIcon color="info" sx={{ mr: 1 }} />
                <Typography variant="h6">Notifications</Typography>
              </Box>
              <Typography variant="h4" color="info.main">
                {analytics?.notificationsSent || 0}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Sent this month
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Grid container spacing={3}>
        {/* System Health */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                System Health
              </Typography>
              <List>
                {healthStatus.map((service, index) => (
                  <ListItem key={index}>
                    <ListItemIcon>
                      {service.status === 'UP' ? 
                        <CheckCircleIcon color="success" /> : 
                        <WarningIcon color="error" />
                      }
                    </ListItemIcon>
                    <ListItemText
                      primary={service.service}
                      secondary={service.error || 'Running normally'}
                    />
                    <Chip
                      label={service.status}
                      color={getHealthStatusColor(service.status)}
                      size="small"
                    />
                  </ListItem>
                ))}
              </List>
            </CardContent>
          </Card>
        </Grid>

        {/* Recent Activities */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Recent Activities
              </Typography>
              <List>
                {recentActivities.map((activity) => (
                  <ListItem key={activity.id}>
                    <ListItemIcon>
                      {getActivityIcon(activity.type)}
                    </ListItemIcon>
                    <ListItemText
                      primary={activity.message}
                      secondary={activity.timestamp.toLocaleString()}
                    />
                  </ListItem>
                ))}
              </List>
            </CardContent>
          </Card>
        </Grid>

        {/* Quick Actions */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Quick Actions
              </Typography>
              <Alert severity="info" sx={{ mb: 2 }}>
                Use the NLP Chat feature to interact with the system using natural language!
              </Alert>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                <Chip
                  label="Try: 'Create new employee John Doe'"
                  variant="outlined"
                  color="primary"
                />
                <Chip
                  label="Try: 'Allocate laptop to EMP001'"
                  variant="outlined"
                  color="primary"
                />
                <Chip
                  label="Try: 'Show me all available assets'"
                  variant="outlined"
                  color="primary"
                />
                <Chip
                  label="Try: 'Send welcome notification'"
                  variant="outlined"
                  color="primary"
                />
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
