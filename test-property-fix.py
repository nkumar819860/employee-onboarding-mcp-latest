#!/usr/bin/env python3
"""
Simple test script to verify the property reference fix in the health check endpoint
"""
import requests
import json
import time

def test_health_endpoint_property_fix():
    """Test that the orchestrationEnabled property is returned as boolean, not string"""
    
    broker_url = "https://employee-onboarding-agent-broker.sandbox.anypoint.mulesoft.com"
    health_url = f"{broker_url}/health"
    
    print("🔧 Testing property reference fix in health check endpoint...")
    print(f"📍 Health URL: {health_url}")
    
    try:
        response = requests.get(health_url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Health endpoint is accessible")
            print(f"📋 Response: {json.dumps(data, indent=2)}")
            
            # Check if orchestrationEnabled is present and is a boolean
            orchestration_enabled = data.get('orchestrationEnabled')
            
            if orchestration_enabled is not None:
                if isinstance(orchestration_enabled, bool):
                    print(f"✅ Property fix successful! orchestrationEnabled is boolean: {orchestration_enabled}")
                    return True
                elif isinstance(orchestration_enabled, str):
                    if orchestration_enabled in ['${agent.broker.orchestration.enabled}', "'${agent.broker.orchestration.enabled}'"]:
                        print(f"❌ Property fix failed! orchestrationEnabled is still a property placeholder: {orchestration_enabled}")
                    else:
                        print(f"⚠️ Property is string but not placeholder: {orchestration_enabled}")
                    return False
                else:
                    print(f"⚠️ orchestrationEnabled has unexpected type: {type(orchestration_enabled)} = {orchestration_enabled}")
                    return False
            else:
                print("❌ orchestrationEnabled property not found in response")
                return False
                
        else:
            print(f"❌ Health endpoint returned {response.status_code}: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error testing health endpoint: {e}")
        return False

def wait_for_deployment():
    """Wait for the deployment to complete"""
    print("⏳ Waiting for CloudHub deployment to complete...")
    
    max_attempts = 20
    for attempt in range(1, max_attempts + 1):
        print(f"🔄 Attempt {attempt}/{max_attempts}")
        
        if test_health_endpoint_property_fix():
            return True
            
        if attempt < max_attempts:
            print("⏸️ Waiting 30 seconds before next attempt...")
            time.sleep(30)
    
    print("❌ Deployment verification timed out")
    return False

if __name__ == "__main__":
    success = wait_for_deployment()
    if success:
        print("\n🎉 Property reference fix verification completed successfully!")
        exit(0)
    else:
        print("\n❌ Property reference fix verification failed")
        exit(1)
