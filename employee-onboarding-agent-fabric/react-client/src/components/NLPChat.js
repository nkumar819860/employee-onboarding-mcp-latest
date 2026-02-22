import React, { useState, useEffect, useRef } from 'react';
import {
  Box,
  Paper,
  TextField,
  Button,
  Typography,
  List,
  ListItem,
  ListItemText,
  Avatar,
  Chip,
  LinearProgress,
  Alert,
  Divider,
  IconButton,
  Tooltip,
  Card,
  CardContent,
} from '@mui/material';
import {
  Send as SendIcon,
  Mic as MicIcon,
  MicOff as MicOffIcon,
  Psychology as AIIcon,
  Person as PersonIcon,
  SmartToy as BotIcon,
} from '@mui/icons-material';
import { nlpProcessor } from '../services/nlpService';
import { apiService } from '../services/apiService';

const NLPChat = () => {
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [nlpResults, setNlpResults] = useState(null);
  const [suggestions] = useState([
    "Create new employee John Smith",
    "Allocate laptop to employee EMP001",
    "Show me all available assets",
    "Get employee onboarding status",
    "Send notification to new employees",
  ]);

  const messagesEndRef = useRef(null);
  const recognition = useRef(null);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    // Initialize speech recognition
    if ('webkitSpeechRecognition' in window) {
      recognition.current = new window.webkitSpeechRecognition();
      recognition.current.continuous = false;
      recognition.current.interimResults = false;
      recognition.current.lang = 'en-US';

      recognition.current.onstart = () => {
        setIsListening(true);
      };

      recognition.current.onend = () => {
        setIsListening(false);
      };

      recognition.current.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        setInputText(transcript);
      };

      recognition.current.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        setIsListening(false);
      };
    }
  }, []);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const toggleListening = () => {
    if (!recognition.current) {
      alert('Speech recognition not supported in this browser');
      return;
    }

    if (isListening) {
      recognition.current.stop();
    } else {
      recognition.current.start();
    }
  };

  const processNLP = async (text) => {
    const results = await nlpProcessor.processText(text);
    setNlpResults(results);
    return results;
  };

  const executeAction = async (intent, entities) => {
    try {
      switch (intent) {
        case 'CREATE_EMPLOYEE':
          const employeeName = entities.find(e => e.label === 'PERSON')?.text;
          if (employeeName) {
            const response = await apiService.createEmployee({
              name: employeeName,
              email: `${employeeName.toLowerCase().replace(' ', '.')}@company.com`
            });
            return `Employee ${employeeName} created successfully with ID: ${response.employeeId}`;
          }
          break;

        case 'ALLOCATE_ASSET':
          const assetType = entities.find(e => e.label === 'ASSET')?.text || 'laptop';
          const empId = entities.find(e => e.label === 'EMPLOYEE_ID')?.text;
          if (empId) {
            const response = await apiService.allocateAsset(empId, assetType);
            return `${assetType} allocated to employee ${empId} successfully`;
          }
          break;

        case 'GET_ASSETS':
          const assets = await apiService.getAvailableAssets();
          return `Found ${assets.length} available assets: ${assets.map(a => a.name).join(', ')}`;

        case 'GET_EMPLOYEE_STATUS':
          const employee = entities.find(e => e.label === 'EMPLOYEE_ID')?.text;
          if (employee) {
            const status = await apiService.getEmployeeStatus(employee);
            return `Employee ${employee} status: ${status.status}`;
          }
          break;

        case 'SEND_NOTIFICATION':
          const notificationType = entities.find(e => e.label === 'NOTIFICATION_TYPE')?.text || 'welcome';
          const response = await apiService.sendNotification(notificationType);
          return `Notification sent successfully to ${response.recipients} employees`;

        default:
          return "I understand your request but I'm not sure how to help with that specific action yet.";
      }
    } catch (error) {
      console.error('Action execution error:', error);
      return `Error executing action: ${error.message}`;
    }
  };

  const handleSendMessage = async () => {
    if (!inputText.trim()) return;

    const userMessage = {
      id: Date.now(),
      text: inputText,
      sender: 'user',
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInputText('');
    setIsLoading(true);

    try {
      // Process with NLP
      const nlpResults = await processNLP(inputText);
      
      let botResponse = "I'm processing your request...";
      
      if (nlpResults.intent && nlpResults.intent !== 'UNKNOWN') {
        botResponse = await executeAction(nlpResults.intent, nlpResults.entities);
      } else {
        // If no specific intent, try to provide helpful information
        botResponse = `I detected the following in your message: ${nlpResults.entities.map(e => `${e.label}: ${e.text}`).join(', ')}. Could you please be more specific about what you'd like me to do?`;
      }

      const aiMessage = {
        id: Date.now() + 1,
        text: botResponse,
        sender: 'ai',
        timestamp: new Date(),
        nlpData: nlpResults,
      };

      setMessages(prev => [...prev, aiMessage]);
    } catch (error) {
      console.error('Error processing message:', error);
      const errorMessage = {
        id: Date.now() + 1,
        text: 'Sorry, I encountered an error processing your request. Please try again.',
        sender: 'ai',
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (event) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage();
    }
  };

  const handleSuggestionClick = (suggestion) => {
    setInputText(suggestion);
  };

  return (
    <Box sx={{ height: '100vh', display: 'flex', flexDirection: 'column', p: 2 }}>
      <Typography variant="h4" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <AIIcon color="primary" />
        NLP Employee Assistant
      </Typography>

      {/* NLP Results Display */}
      {nlpResults && (
        <Card sx={{ mb: 2, bgcolor: 'primary.main', color: 'white' }}>
          <CardContent sx={{ py: 1 }}>
            <Typography variant="subtitle2">
              Intent: <Chip label={nlpResults.intent} size="small" sx={{ ml: 1, bgcolor: 'white', color: 'primary.main' }} />
              {nlpResults.entities.length > 0 && (
                <>
                  | Entities: {nlpResults.entities.map((entity, index) => (
                    <Chip 
                      key={index} 
                      label={`${entity.label}: ${entity.text}`} 
                      size="small" 
                      sx={{ ml: 1, bgcolor: 'white', color: 'primary.main' }} 
                    />
                  ))}
                </>
              )}
            </Typography>
          </CardContent>
        </Card>
      )}

      {/* Suggestions */}
      <Box sx={{ mb: 2 }}>
        <Typography variant="subtitle2" gutterBottom>Try these examples:</Typography>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
          {suggestions.map((suggestion, index) => (
            <Chip
              key={index}
              label={suggestion}
              variant="outlined"
              size="small"
              onClick={() => handleSuggestionClick(suggestion)}
              sx={{ cursor: 'pointer' }}
            />
          ))}
        </Box>
      </Box>

      {/* Messages */}
      <Paper sx={{ flexGrow: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        <Box sx={{ flexGrow: 1, overflow: 'auto', p: 2 }}>
          <List>
            {messages.map((message) => (
              <ListItem
                key={message.id}
                sx={{
                  flexDirection: 'column',
                  alignItems: message.sender === 'user' ? 'flex-end' : 'flex-start',
                  mb: 2,
                }}
              >
                <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 1, maxWidth: '70%' }}>
                  <Avatar sx={{ bgcolor: message.sender === 'user' ? 'primary.main' : 'secondary.main' }}>
                    {message.sender === 'user' ? <PersonIcon /> : <BotIcon />}
                  </Avatar>
                  <Paper
                    elevation={1}
                    sx={{
                      p: 2,
                      bgcolor: message.sender === 'user' ? 'primary.light' : 'grey.100',
                      color: message.sender === 'user' ? 'white' : 'text.primary',
                    }}
                  >
                    <Typography variant="body1">{message.text}</Typography>
                    <Typography variant="caption" sx={{ opacity: 0.7, display: 'block', mt: 1 }}>
                      {message.timestamp.toLocaleTimeString()}
                    </Typography>
                  </Paper>
                </Box>
              </ListItem>
            ))}
            {isLoading && (
              <ListItem>
                <Box sx={{ width: '100%' }}>
                  <LinearProgress />
                  <Typography variant="body2" sx={{ mt: 1 }}>Processing your request...</Typography>
                </Box>
              </ListItem>
            )}
          </List>
          <div ref={messagesEndRef} />
        </Box>

        <Divider />

        {/* Input */}
        <Box sx={{ p: 2, display: 'flex', gap: 1 }}>
          <TextField
            fullWidth
            multiline
            maxRows={4}
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Ask me about employee onboarding, asset allocation, or anything else..."
            disabled={isLoading}
          />
          <Tooltip title="Voice Input">
            <IconButton
              color={isListening ? "secondary" : "primary"}
              onClick={toggleListening}
              disabled={isLoading}
            >
              {isListening ? <MicOffIcon /> : <MicIcon />}
            </IconButton>
          </Tooltip>
          <Button
            variant="contained"
            onClick={handleSendMessage}
            disabled={!inputText.trim() || isLoading}
            endIcon={<SendIcon />}
          >
            Send
          </Button>
        </Box>
      </Paper>
    </Box>
  );
};

export default NLPChat;
