#!/usr/bin/env python3
"""
Startup script for SisterCheck Python Backend
This script will:
1. Train the model if it doesn't exist
2. Start the enhanced API server
"""

import os
import sys
import subprocess
from pathlib import Path

def check_model_files():
    """Check if the trained model files exist"""
    required_files = [
        'trained_model.pkl',
        'feature_columns.pkl', 
        'target_encoder.pkl',
        'scaler.pkl'
    ]
    
    missing_files = []
    for file in required_files:
        if not os.path.exists(file):
            missing_files.append(file)
    
    return len(missing_files) == 0, missing_files

def train_model():
    """Train the model using the training script"""
    print("🤖 Model files not found. Training new model...")
    print("=" * 50)
    
    try:
        # Run the training script
        result = subprocess.run([sys.executable, 'train_model.py'], 
                              capture_output=True, text=True, check=True)
        
        print("✅ Model training completed successfully!")
        print(result.stdout)
        return True
        
    except subprocess.CalledProcessError as e:
        print("❌ Error during model training:")
        print(e.stderr)
        return False
    except FileNotFoundError:
        print("❌ train_model.py not found!")
        return False

def start_server():
    """Start the enhanced API server"""
    print("\n🚀 Starting Enhanced API Server...")
    print("=" * 50)
    
    try:
        # Import and run the server
        from enhanced_api_server import app
        
        print("✅ Server started successfully!")
        print("🌐 API available at: http://127.0.0.1:5001")
        print("📋 Available endpoints:")
        print("  GET  / - API information")
        print("  GET  /health - Health check")
        print("  POST /predict - Enhanced prediction with ML model")
        print("  POST /care-template - Complete intelligent care template")
        print("  POST /risk-assessment - Risk assessment based on guidelines")
        print("  POST /cost-estimation - Detailed cost analysis")
        print("  POST /inventory-status - Real-time inventory check")
        print("  GET  /patients - List all patients (paginated)")
        print("  GET  /search-patients?q=<query>&type=<id|region> - Search patients")
        print("  GET  /patient/<patient_id>/care-template - Get care template for existing patient")
        
        # Start the Flask app
        app.run(host='127.0.0.1', port=5001, debug=True)
        
    except ImportError as e:
        print(f"❌ Error importing server: {e}")
        return False
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        return False

def main():
    """Main startup function"""
    print("🚀 SisterCheck Python Backend Startup")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists('patient_data.csv'):
        print("❌ patient_data.csv not found!")
        print("Please run this script from the sistercheck-python directory")
        return False
    
    # Check if model files exist
    model_exists, missing_files = check_model_files()
    
    if not model_exists:
        print(f"📋 Missing model files: {', '.join(missing_files)}")
        
        # Train the model
        if not train_model():
            print("❌ Failed to train model. Exiting.")
            return False
    else:
        print("✅ Model files found. Skipping training.")
        
        # Start the server
    return start_server()
        
if __name__ == "__main__":
    try:
        success = main()
        if not success:
            sys.exit(1)
    except KeyboardInterrupt:
        print("\n👋 Server stopped by user")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        sys.exit(1) 