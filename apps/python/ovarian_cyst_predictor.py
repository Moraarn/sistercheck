import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import accuracy_score, classification_report
import numpy as np
import os
import warnings

warnings.filterwarnings('ignore', category=UserWarning, module='sklearn')
pd.options.mode.chained_assignment = None # Suppress the SettingWithCopyWarning

# --- Configuration ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PATIENT_DATA_PATH = os.path.join(SCRIPT_DIR, 'patient_data.csv')
INVENTORY_PATH = os.path.join(SCRIPT_DIR, 'inventory.csv')
CHARGES_PATH = os.path.join(SCRIPT_DIR, 'hospital_charges.csv')

def preprocess_and_clean(df):
    """
    Cleans data, merges rare classes, and uses a mix of intelligent and one-hot encoding.
    """
    df_clean = df.copy()
    df_clean.columns = df_clean.columns.str.strip()

    # --- Step 1: Clean Target Variable ---
    df_clean['Recommended'] = df_clean['Recommended'].str.strip().replace({'Bic Referral': 'Referral', 'Nauss Surgery': 'Surgery'})

    # --- Step 2: Intelligent Symptom Parsing ---
    # Treat symptoms as individual binary features. This is smarter than one-hot encoding every combo.
    df_clean['Reported Sym'] = df_clean['Reported Sym'].str.strip().str.replace('"', '').fillna('Unknown')
    symptom_dummies = df_clean['Reported Sym'].str.get_dummies(sep=', ').add_prefix('Symptom_')
    df_clean = pd.concat([df_clean, symptom_dummies], axis=1)
    df_clean = df_clean.drop('Reported Sym', axis=1)

    # --- Step 3: One-Hot Encoding for Remaining Categorical Features ---
    categorical_cols = ['Menopause Stage', 'Ultrasound Fe']
    for col in categorical_cols:
        df_clean[col] = df_clean[col].str.strip().str.replace('"', '').fillna('Unknown')
    
    df_processed = pd.get_dummies(df_clean, columns=categorical_cols, dtype=float)

    # --- Step 4: Label Encode the Target Variable ---
    target_encoder = LabelEncoder()
    df_processed['Recommended'] = target_encoder.fit_transform(df_processed['Recommended'])

    # Drop original identifier columns
    df_processed = df_processed.drop(columns=['Patient ID', 'Date of Exam', 'Region'], errors='ignore')

    return df_processed, target_encoder

def train_and_evaluate(df, target_encoder):
    """
    Scales features, performs hyperparameter tuning, and evaluates the best model.
    """
    X = df.drop('Recommended', axis=1)
    y = df['Recommended']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)

    # --- Feature Scaling ---
    numerical_cols = ['Age', 'SI Cyst Size cm', 'Cyst Growth', 'fca 125 Level']
    scaler = StandardScaler()
    X_train_scaled = X_train.copy()
    X_test_scaled = X_test.copy()
    X_train_scaled[numerical_cols] = scaler.fit_transform(X_train[numerical_cols])
    X_test_scaled[numerical_cols] = scaler.transform(X_test[numerical_cols])

    # --- Hyperparameter Tuning using GridSearchCV ---
    param_grid = {
        'n_estimators': [100, 150, 200],
        'max_depth': [None, 10, 20],
        'min_samples_split': [2, 5, 10],
        'min_samples_leaf': [1, 2, 4]
    }
    rf = RandomForestClassifier(random_state=42, class_weight='balanced')
    grid_search = GridSearchCV(estimator=rf, param_grid=param_grid, cv=3, n_jobs=-1, scoring='accuracy')
    grid_search.fit(X_train_scaled, y_train)

    print("\n--- Hyperparameter Tuning Results ---")
    print(f"Best Parameters Found: {grid_search.best_params_}")
    
    best_model = grid_search.best_estimator_
    y_pred = best_model.predict(X_test_scaled)
    
    target_names = target_encoder.classes_
    print("\n--- Final Model Evaluation ---")
    print(f"Model Accuracy: {accuracy_score(y_test, y_pred):.2f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=target_names, zero_division='warn'))
    print("-" * 28)
    
    return best_model, X.columns, scaler

def generate_care_template(model, feature_names, patient_record, target_encoder, scaler, inventory_df, charges_df):
    """
    Generates a full care template for a single patient record.
    """
    print("\n--- Generating Care Template ---")
    
    display_record = patient_record.copy()
    display_record.index = display_record.index.str.strip()
    print("\nPatient Details:")
    print(display_record[['Age', 'Menopause Stage', 'SI Cyst Size cm', 'Cyst Growth', 'fca 125 Level', 'Ultrasound Fe', 'Reported Sym']])
    
    # --- Replicate the exact same preprocessing for the single record ---
    patient_df = pd.DataFrame([display_record])
    patient_df.columns = patient_df.columns.str.strip()
    
    # 1. Parse Symptoms and One-Hot Encode
    patient_df['Reported Sym'] = patient_df['Reported Sym'].str.strip().str.replace('"', '').fillna('Unknown')
    symptom_dummies = patient_df['Reported Sym'].str.get_dummies(sep=', ').add_prefix('Symptom_')
    patient_df = pd.concat([patient_df, symptom_dummies], axis=1).drop('Reported Sym', axis=1)
    
    categorical_cols = ['Menopause Stage', 'Ultrasound Fe']
    for col in categorical_cols:
        patient_df[col] = patient_df[col].str.strip().str.replace('"', '').fillna('Unknown')
    patient_processed = pd.get_dummies(patient_df, columns=categorical_cols, dtype=float)
    
    # 2. Align columns and Scale
    final_patient_features = patient_processed.reindex(columns=feature_names, fill_value=0)
    numerical_cols = ['Age', 'SI Cyst Size cm', 'Cyst Growth', 'fca 125 Level']
    cols_to_scale = [col for col in numerical_cols if col in final_patient_features.columns]
    if cols_to_scale:
        final_patient_features[cols_to_scale] = scaler.transform(final_patient_features[cols_to_scale])
    
    # 3. Predict
    prediction_encoded = model.predict(final_patient_features)
    recommended_plan = target_encoder.inverse_transform(prediction_encoded)[0]
    
    print(f"\nPredicted Treatment Plan: ---> {recommended_plan} <---")
    
    cost_info, inventory_info = "Not Available", "Not Available"
    service_map = {
        'Surgery': ('Ovarian Cystec', 'Speculum'),
        'Medication': ('Pain Managem', 'Paracetamol'),
        'Observation': ('Initial Consult', None),
        'Referral': ('Referral Speci', None)
    }

    if recommended_plan in service_map:
        service_name, tool_name = service_map[recommended_plan]
        
        cost_row = charges_df[charges_df['Service'].str.contains(service_name, na=False)]
        if not cost_row.empty:
            cost_info = cost_row.iloc[0][['Service', 'Base Cost (KES)', 'Out-of-Pocket (KES)']].to_dict()

        if tool_name:
            inventory_row = inventory_df[inventory_df['Item'].str.contains(tool_name, na=False)]
            if not inventory_row.empty:
                inventory_info = inventory_row.iloc[0][['Item', 'Available Stock']].to_dict()

    print("\n--- Financial & Inventory Details ---")
    print("Estimated Cost:", cost_info)
    print("Relevant Inventory:", inventory_info)
    print("--- End of Template ---\n")

if __name__ == "__main__":
    try:
        original_patient_data = pd.read_csv(PATIENT_DATA_PATH)
        inventory_data = pd.read_csv(INVENTORY_PATH)
        hospital_charges = pd.read_csv(CHARGES_PATH)
        
        processed_data, target_label_encoder = preprocess_and_clean(original_patient_data)
        
        model, feature_columns, scaler = train_and_evaluate(processed_data, target_label_encoder)

        patient_1 = original_patient_data.iloc[30]
        generate_care_template(model, feature_columns, patient_1, target_label_encoder, scaler, inventory_data, hospital_charges)

        patient_2 = original_patient_data.iloc[4]
        generate_care_template(model, feature_columns, patient_2, target_label_encoder, scaler, inventory_data, hospital_charges)

    except FileNotFoundError as e:
        print(f"Error: {e}. Make sure all CSV files are in the same directory as the script.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}") 