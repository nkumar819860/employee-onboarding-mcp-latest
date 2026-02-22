import nlp from 'compromise';
import { removeStopwords } from 'stopword';
import Sentiment from 'sentiment';

class NLPService {
  constructor() {
    this.sentiment = new Sentiment();
    
    // Define intent patterns and keywords
    this.intentPatterns = {
      CREATE_EMPLOYEE: {
        keywords: ['create', 'add', 'new', 'register', 'onboard', 'hire', 'employee', 'person', 'staff'],
        patterns: [
          /create\s+(new\s+)?employee/i,
          /add\s+(new\s+)?employee/i,
          /register\s+(new\s+)?employee/i,
          /onboard\s+/i,
          /hire\s+/i
        ]
      },
      ALLOCATE_ASSET: {
        keywords: ['allocate', 'assign', 'give', 'provide', 'laptop', 'computer', 'phone', 'asset', 'equipment'],
        patterns: [
          /allocate\s+\w+\s+to/i,
          /assign\s+\w+\s+to/i,
          /give\s+\w+\s+to/i,
          /provide\s+\w+\s+(to|for)/i
        ]
      },
      GET_ASSETS: {
        keywords: ['show', 'list', 'get', 'available', 'assets', 'equipment', 'inventory'],
        patterns: [
          /show\s+(all\s+)?available\s+assets/i,
          /list\s+(all\s+)?assets/i,
          /get\s+(all\s+)?assets/i,
          /what\s+assets\s+are\s+available/i
        ]
      },
      GET_EMPLOYEE_STATUS: {
        keywords: ['status', 'progress', 'check', 'employee', 'onboarding'],
        patterns: [
          /employee\s+\w+\s+status/i,
          /check\s+status/i,
          /onboarding\s+status/i,
          /progress\s+of/i
        ]
      },
      SEND_NOTIFICATION: {
        keywords: ['send', 'notify', 'notification', 'email', 'message', 'alert'],
        patterns: [
          /send\s+notification/i,
          /notify\s+/i,
          /send\s+email/i,
          /send\s+message/i
        ]
      },
      GET_EMPLOYEES: {
        keywords: ['employees', 'staff', 'people', 'workers', 'list'],
        patterns: [
          /show\s+(all\s+)?employees/i,
          /list\s+(all\s+)?employees/i,
          /get\s+(all\s+)?employees/i
        ]
      }
    };

    // Define entity patterns
    this.entityPatterns = {
      PERSON: {
        patterns: [/\b[A-Z][a-z]+\s+[A-Z][a-z]+\b/g]
      },
      EMPLOYEE_ID: {
        patterns: [/EMP\d{3,}/gi, /employee\s+\d+/gi, /\b\d{3,}\b/g]
      },
      ASSET: {
        patterns: [/laptop/gi, /computer/gi, /phone/gi, /mobile/gi, /tablet/gi, /monitor/gi, /keyboard/gi, /mouse/gi]
      },
      EMAIL: {
        patterns: [/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g]
      },
      NOTIFICATION_TYPE: {
        patterns: [/welcome/gi, /reminder/gi, /alert/gi, /update/gi]
      }
    };
  }

  async processText(text) {
    try {
      const doc = nlp(text);
      
      // Extract basic linguistic features
      const tokens = this.tokenize(text);
      const cleanedTokens = this.removeStopwords(tokens);
      const sentiment = this.analyzeSentiment(text);
      
      // Extract entities
      const entities = this.extractEntities(text, doc);
      
      // Determine intent
      const intent = this.classifyIntent(text, cleanedTokens);
      
      // Extract key phrases
      const keyPhrases = this.extractKeyPhrases(doc);
      
      return {
        originalText: text,
        tokens,
        cleanedTokens,
        entities,
        intent,
        confidence: this.calculateConfidence(intent, entities, text),
        sentiment: {
          score: sentiment.score,
          comparative: sentiment.comparative,
          tokens: sentiment.tokens,
          words: sentiment.words,
          positive: sentiment.positive,
          negative: sentiment.negative
        },
        keyPhrases,
        processingTime: Date.now()
      };
    } catch (error) {
      console.error('NLP Processing error:', error);
      return {
        originalText: text,
        tokens: [],
        cleanedTokens: [],
        entities: [],
        intent: 'UNKNOWN',
        confidence: 0,
        sentiment: { score: 0, comparative: 0 },
        keyPhrases: [],
        error: error.message
      };
    }
  }

  tokenize(text) {
    return text.toLowerCase()
      .replace(/[^\w\s@.-]/g, ' ')
      .split(/\s+/)
      .filter(token => token.length > 0);
  }

  removeStopwords(tokens) {
    return removeStopwords(tokens);
  }

  analyzeSentiment(text) {
    return this.sentiment.analyze(text);
  }

  extractEntities(text, doc) {
    const entities = [];

    // Extract using compromise.js
    const people = doc.people().out('array');
    people.forEach(person => {
      entities.push({
        text: person,
        label: 'PERSON',
        confidence: 0.9
      });
    });

    const places = doc.places().out('array');
    places.forEach(place => {
      entities.push({
        text: place,
        label: 'PLACE',
        confidence: 0.8
      });
    });

    const organizations = doc.organizations().out('array');
    organizations.forEach(org => {
      entities.push({
        text: org,
        label: 'ORGANIZATION',
        confidence: 0.8
      });
    });

    // Extract using custom patterns
    Object.keys(this.entityPatterns).forEach(entityType => {
      const patterns = this.entityPatterns[entityType].patterns;
      patterns.forEach(pattern => {
        const matches = text.match(pattern);
        if (matches) {
          matches.forEach(match => {
            entities.push({
              text: match.trim(),
              label: entityType,
              confidence: 0.7
            });
          });
        }
      });
    });

    // Remove duplicates and sort by confidence
    const uniqueEntities = entities.filter((entity, index, self) =>
      index === self.findIndex(e => e.text.toLowerCase() === entity.text.toLowerCase() && e.label === entity.label)
    );

    return uniqueEntities.sort((a, b) => b.confidence - a.confidence);
  }

  classifyIntent(text, cleanedTokens) {
    let bestIntent = 'UNKNOWN';
    let highestScore = 0;

    Object.keys(this.intentPatterns).forEach(intent => {
      const intentData = this.intentPatterns[intent];
      let score = 0;

      // Check pattern matches
      intentData.patterns.forEach(pattern => {
        if (pattern.test(text)) {
          score += 3; // Pattern match gets high score
        }
      });

      // Check keyword matches
      intentData.keywords.forEach(keyword => {
        if (cleanedTokens.includes(keyword.toLowerCase()) || text.toLowerCase().includes(keyword.toLowerCase())) {
          score += 1;
        }
      });

      if (score > highestScore) {
        highestScore = score;
        bestIntent = intent;
      }
    });

    return highestScore > 0 ? bestIntent : 'UNKNOWN';
  }

  extractKeyPhrases(doc) {
    const keyPhrases = [];

    // Extract noun phrases
    const nounPhrases = doc.nouns().out('array');
    keyPhrases.push(...nounPhrases.map(phrase => ({ text: phrase, type: 'noun_phrase' })));

    // Extract verb phrases
    const verbs = doc.verbs().out('array');
    keyPhrases.push(...verbs.map(verb => ({ text: verb, type: 'verb' })));

    // Extract adjectives
    const adjectives = doc.adjectives().out('array');
    keyPhrases.push(...adjectives.map(adj => ({ text: adj, type: 'adjective' })));

    return keyPhrases.slice(0, 10); // Limit to top 10 key phrases
  }

  calculateConfidence(intent, entities, text) {
    let confidence = 0;

    // Base confidence on intent classification
    if (intent !== 'UNKNOWN') {
      confidence += 0.5;

      // Boost confidence if we have relevant entities
      const intentEntityMap = {
        CREATE_EMPLOYEE: ['PERSON', 'EMAIL'],
        ALLOCATE_ASSET: ['EMPLOYEE_ID', 'ASSET'],
        GET_EMPLOYEE_STATUS: ['EMPLOYEE_ID'],
        SEND_NOTIFICATION: ['NOTIFICATION_TYPE', 'EMPLOYEE_ID']
      };

      const relevantEntityTypes = intentEntityMap[intent] || [];
      const foundRelevantEntities = entities.filter(entity => 
        relevantEntityTypes.includes(entity.label)
      ).length;

      if (foundRelevantEntities > 0) {
        confidence += Math.min(foundRelevantEntities * 0.2, 0.4);
      }
    }

    // Boost confidence for clear, well-formed sentences
    if (text.length > 10 && text.length < 200) {
      confidence += 0.1;
    }

    return Math.min(confidence, 1.0);
  }

  // Utility method to get intent explanation
  getIntentExplanation(intent) {
    const explanations = {
      CREATE_EMPLOYEE: "I can help you create a new employee record",
      ALLOCATE_ASSET: "I can assign assets like laptops, phones, or equipment to employees",
      GET_ASSETS: "I can show you available assets and inventory",
      GET_EMPLOYEE_STATUS: "I can check the onboarding status of employees",
      SEND_NOTIFICATION: "I can send notifications and messages to employees",
      GET_EMPLOYEES: "I can list employees and their information",
      UNKNOWN: "I'm not sure what you're asking for. Could you be more specific?"
    };

    return explanations[intent] || explanations.UNKNOWN;
  }
}

export const nlpProcessor = new NLPService();
