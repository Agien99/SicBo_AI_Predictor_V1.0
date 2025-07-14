# ai_creator/model_definitions.py

import os
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Input
from tensorflow.keras.optimizers import Adam

def train_sum_predictor(csv_path="sicbo_training_data.csv", export_dir="models"):
    print("Training: sum_predictor.tflite")

    # Load data
    df = pd.read_csv(csv_path)
    X = df[["dice1", "dice2", "dice3"]].values
    y = df["total"].values - 3  # Shift target from [3–18] to [0–15]

    # Normalize
    scaler = StandardScaler()
    X = scaler.fit_transform(X)

    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Build model
    model = Sequential([
        Input(shape=(3,)),
        Dense(64, activation='relu'),
        Dense(32, activation='relu'),
        Dense(16, activation='softmax')  # Output for totals 3–18
    ])

    model.compile(optimizer=Adam(0.001), loss='sparse_categorical_crossentropy', metrics=['accuracy'])

    # Train
    model.fit(X_train, y_train, epochs=10, batch_size=64, validation_split=0.1, verbose=1)

    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()

    # Export
    os.makedirs(export_dir, exist_ok=True)
    model_path = os.path.join(export_dir, "sum_predictor.tflite")
    with open(model_path, "wb") as f:
        f.write(tflite_model)

    print(f"✅ Exported: {model_path}")