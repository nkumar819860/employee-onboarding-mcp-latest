#!/usr/bin/env python3
"""
Employee Onboarding System - NLP Testing Script
This script tests the complete employee onboarding system using natural language processing
and the Groq LLM integration through the agent network.
"""

import requests
import json
import time
import os
from datetime import datetime, timedelta
from groq import Groq
import argparse
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class EmployeeOnboardingNLPTester:
    def __init__(self):
        self.groq_client = None
        # Use direct CloudHub URLs instead of gateway for now
        self.broker_url = "https://employee-onboarding-agent-broker.sandbox.anypoint.mulesoft.com"
        self.employee_url = "https://employee-onboarding-mcp-server.sandbox.anypoint.mulesoft.com"
        self.assets_url = "https://asset-allocation-mcp-server.sandbox.anypoint.mulesoft.com"
        self.notifications_url = "https://notification-mcp-server.sandbox.anypoint.mulesoft.com"
        
        # Initialize Groq client
        groq_api_key = os.getenv('GROQ_API_KEY')
        if groq_api_key:
            self.groq_client = Groq(api_key=groq_api_key)
        else:
            logger.warning("GROQ_API_KEY not set. NLP features will be limited.")
    
    def parse_natural_language_request(self, nl_request):
        """Parse natural language onboarding request using Groq LLM"""
        if not self.groq_client:
            logger.error("Groq client not initialized. Cannot parse natural language.")
            return None
        
        system_prompt = """
        You are an expert at parsing natural language employee onboarding requests.
        Extract employee information and convert it to a structured JSON format.
        
        Expected JSON structure:
        {
            "firstName": "string",
            "lastName": "string", 
            "email": "string",
            "department": "string",
            "position": "string",
            "startDate": "YYYY-MM-DD",
            "manager": "string (optional)",
            "managerEmail": "string (optional)",
            "companyName": "string (optional)",
            "assets": [
                {
                    "category": "string (laptop, monitor, phone, etc.)",
                    "specifications": "string (optional)"
                }
            ]
        }
        
        If information is missing, make reasonable assumptions based on the role/department.
        Always return valid JSON only, no additional text.
        """
        
        try:
            chat_completion = self.groq_client.chat.completions.create(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": nl_request}
                ],
                model="llama3-8b-8192",
                temperature=0.1,
                max_tokens=1000
            )
            
            response_text = chat_completion.choices[0].message.content.strip()
            
            # Try to extract JSON from the response
            if response_text.startswith('```json'):
                response_text = response_text.replace('```json', '').replace('```', '').strip()
            elif response_text.startswith('```'):
                response_text = response_text.replace('```', '').strip()
            
            return json.loads(response_text)
            
        except Exception as e:
            logger.error(f"Failed to parse natural language request: {e}")
            return None
    
    def health_check_all_services(self):
        """Check health of all services"""
        logger.info("🏥 Performing health checks on all services...")
        
        services = [
            ("Employee Onboarding MCP", f"{self.employee_url}/health"),
            ("Asset Allocation MCP", f"{self.assets_url}/health"), 
            ("Notification MCP", f"{self.notifications_url}/health"),
            ("Agent Broker", f"{self.broker_url}/health")
        ]
        
        all_healthy = True
        for service_name, health_url in services:
            try:
                response = requests.get(health_url, timeout=10)
                if response.status_code == 200:
                    logger.info(f"✅ {service_name} is healthy")
                else:
                    logger.error(f"❌ {service_name} health check failed: {response.status_code}")
                    all_healthy = False
            except Exception as e:
                logger.error(f"❌ {service_name} health check failed: {e}")
                all_healthy = False
        
        return all_healthy
    
    def orchestrate_onboarding(self, employee_data):
        """Orchestrate complete employee onboarding through agent broker"""
        logger.info(f"🚀 Starting employee onboarding orchestration for {employee_data.get('email')}")
        
        url = f"{self.broker_url}/mcp/tools/orchestrate-employee-onboarding"
        
        try:
            response = requests.post(
                url,
                json=employee_data,
                headers={'Content-Type': 'application/json'},
                timeout=120  # Longer timeout for complete orchestration
            )
            
            if response.status_code == 200:
                result = response.json()
                logger.info("✅ Employee onboarding orchestration completed successfully!")
                return result
            else:
                logger.error(f"❌ Onboarding orchestration failed: {response.status_code}")
                logger.error(f"Response: {response.text}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Onboarding orchestration error: {e}")
            return None
    
    def get_onboarding_status(self, employee_id):
        """Get onboarding status for an employee"""
        logger.info(f"📊 Getting onboarding status for employee {employee_id}")
        
        url = f"{self.broker_url}/mcp/tools/get-onboarding-status"
        
        try:
            response = requests.post(
                url,
                json={"employeeId": employee_id},
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                logger.info("✅ Status retrieved successfully!")
                return result
            else:
                logger.error(f"❌ Status retrieval failed: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Status retrieval error: {e}")
            return None
    
    def test_individual_services(self, employee_data):
        """Test individual MCP services"""
        logger.info("🧪 Testing individual MCP services...")
        
        results = {}
        
        # Test Employee Service
        logger.info("Testing Employee MCP Service...")
        try:
            response = requests.post(
                f"{self.employee_url}/mcp/tools/create-employee",
                json=employee_data,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            results['employee_service'] = response.status_code == 200
            if results['employee_service']:
                logger.info("✅ Employee service test passed")
            else:
                logger.error(f"❌ Employee service test failed: {response.status_code}")
        except Exception as e:
            logger.error(f"❌ Employee service test error: {e}")
            results['employee_service'] = False
        
        # Test Asset Service
        logger.info("Testing Asset Allocation MCP Service...")
        try:
            asset_request = {
                "employeeId": "TEST001",
                "firstName": employee_data.get("firstName"),
                "lastName": employee_data.get("lastName"),
                "email": employee_data.get("email"),
                "department": employee_data.get("department"),
                "position": employee_data.get("position"),
                "assets": employee_data.get("assets", [])
            }
            response = requests.post(
                f"{self.assets_url}/mcp/tools/allocate-assets",
                json=asset_request,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            results['asset_service'] = response.status_code == 200
            if results['asset_service']:
                logger.info("✅ Asset service test passed")
            else:
                logger.error(f"❌ Asset service test failed: {response.status_code}")
        except Exception as e:
            logger.error(f"❌ Asset service test error: {e}")
            results['asset_service'] = False
        
        # Test Notification Service
        logger.info("Testing Notification MCP Service...")
        try:
            response = requests.post(
                f"{self.notifications_url}/mcp/tools/test-email-config",
                json={"testEmail": employee_data.get("email")},
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            results['notification_service'] = response.status_code == 200
            if results['notification_service']:
                logger.info("✅ Notification service test passed")
            else:
                logger.error(f"❌ Notification service test failed: {response.status_code}")
        except Exception as e:
            logger.error(f"❌ Notification service test error: {e}")
            results['notification_service'] = False
        
        return results
    
    def run_comprehensive_test(self, nl_request):
        """Run comprehensive end-to-end test with NLP"""
        logger.info("🎯 Starting comprehensive NLP-based onboarding test...")
        
        # Step 1: Parse natural language request
        logger.info("🧠 Parsing natural language request...")
        employee_data = self.parse_natural_language_request(nl_request)
        
        if not employee_data:
            logger.error("❌ Failed to parse natural language request")
            return False
        
        logger.info(f"✅ Parsed employee data: {json.dumps(employee_data, indent=2)}")
        
        # Step 2: Health checks
        if not self.health_check_all_services():
            logger.error("❌ Health checks failed. Cannot proceed with testing.")
            return False
        
        # Step 3: Test individual services
        service_results = self.test_individual_services(employee_data)
        logger.info(f"📊 Individual service test results: {service_results}")
        
        # Step 4: Test complete orchestration
        orchestration_result = self.orchestrate_onboarding(employee_data)
        
        if orchestration_result:
            logger.info("🎉 Complete orchestration test passed!")
            
            # Extract employee ID if available
            employee_id = orchestration_result.get('employeeId')
            if employee_id:
                # Step 5: Test status monitoring
                time.sleep(2)  # Wait a moment
                status_result = self.get_onboarding_status(employee_id)
                if status_result:
                    logger.info("✅ Status monitoring test passed!")
                else:
                    logger.warning("⚠️ Status monitoring test failed")
            
            return True
        else:
            logger.error("❌ Complete orchestration test failed")
            return False

def main():
    parser = argparse.ArgumentParser(description='Test Employee Onboarding System with NLP')
    parser.add_argument('--request', '-r', type=str, 
                       help='Natural language onboarding request')
    parser.add_argument('--health-only', action='store_true',
                       help='Only perform health checks')
    
    args = parser.parse_args()
    
    tester = EmployeeOnboardingNLPTester()
    
    if args.health_only:
        success = tester.health_check_all_services()
        if success:
            print("🎉 All services are healthy!")
        else:
            print("❌ Some services are not healthy")
        return 0 if success else 1
    
    # Default test cases if no request provided
    if not args.request:
        test_cases = [
            "I need to onboard Sarah Johnson as a Senior Software Engineer in the Engineering department. Her email is sarah.johnson@techcorp.com and she starts on March 1st, 2024. She'll need a MacBook Pro, 27-inch monitor, and wireless keyboard and mouse. Her manager is Mike Chen at mike.chen@techcorp.com.",
            
            "Please set up onboarding for Alex Rodriguez, new Marketing Manager starting February 15th. Email: alex.rodriguez@company.com. Department: Marketing. He needs a laptop and phone for his role.",
            
            "Onboard new employee: Emma Davis, Data Scientist, Analytics team, emma.davis@datatech.com, starts next Monday. Requires high-spec laptop with GPU, dual monitors, mechanical keyboard."
        ]
        
        logger.info("🚀 Running default NLP test cases...")
        all_passed = True
        
        for i, test_request in enumerate(test_cases, 1):
            logger.info(f"\n📝 Test Case {i}: {test_request[:100]}...")
            success = tester.run_comprehensive_test(test_request)
            if not success:
                all_passed = False
            
            time.sleep(5)  # Wait between tests
        
        if all_passed:
            logger.info("\n🎉 All NLP test cases passed successfully!")
            return 0
        else:
            logger.error("\n❌ Some NLP test cases failed")
            return 1
    else:
        # Run single test case
        success = tester.run_comprehensive_test(args.request)
        return 0 if success else 1

if __name__ == "__main__":
    exit(main())
