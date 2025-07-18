import pandas as pd
import joblib
from ovarian_cyst_predictor import preprocess_and_clean, train_and_evaluate
import os

def train_and_save_model():
    """Train the model and save it for the API"""
    try:
        print("Loading data...")
        original_patient_data = pd.read_csv('patient_data.csv')
        
        print("Preprocessing data...")
        processed_data, target_label_encoder = preprocess_and_clean(original_patient_data)
        
        print("Training model...")
        model, feature_columns, scaler = train_and_evaluate(processed_data, target_label_encoder)
        
        print("Saving model and preprocessing objects...")
        joblib.dump(model, 'trained_model.pkl')
        joblib.dump(feature_columns, 'feature_columns.pkl')
        joblib.dump(target_label_encoder, 'target_encoder.pkl')
        joblib.dump(scaler, 'scaler.pkl')
        
        print("Model training completed successfully!")
        print("Files saved:")
        print("- trained_model.pkl")
        print("- feature_columns.pkl")
        print("- target_encoder.pkl")
        print("- scaler.pkl")
        
    except Exception as e:
        print(f"Error training model: {e}")

if __name__ == "__main__":
    train_and_save_model() 