from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import cv2
import numpy as np
import os

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def detect_plantable_areas(image):
    # Convert to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blurred, 50, 150)
    
    # Find contours of plantable areas
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def filter_sky_and_walls(image):
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lower_sky = np.array([90, 50, 50])  # Adjust based on actual sky color
    upper_sky = np.array([130, 255, 255])
    mask = cv2.inRange(hsv, lower_sky, upper_sky)
    return cv2.bitwise_and(image, image, mask=~mask)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400
    
    file = request.files['file']
    filename = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filename)
    return jsonify({'message': 'File uploaded successfully', 'filename': file.filename})

@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.json
    filename = data.get('filename')

    if not filename:
        return jsonify({'error': 'Filename not provided'}), 400

    filepath = os.path.join(UPLOAD_FOLDER, filename)
    
    if not os.path.exists(filepath):
        return jsonify({'error': 'File not found'}), 404

    image = cv2.imread(filepath)
    if image is None:
        return jsonify({'error': 'Invalid image file'}), 400

    # Remove sky and walls
    filtered_image = filter_sky_and_walls(image)
    
    # Detect plantable areas
    contours = detect_plantable_areas(filtered_image)
    
    output_image = image.copy()
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        if w * h > 500:  # Ignore very small regions
            cv2.rectangle(output_image, (x, y), (x + w, y + h), (0, 255, 0), 2)
            cv2.putText(output_image, "Plant", (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)


    output_filename = f"output_{filename}"
    output_path = os.path.join(OUTPUT_FOLDER, output_filename)
    cv2.imwrite(output_path, output_image)
    return jsonify({'message': 'Analysis complete', 'output_filename': output_filename})

@app.route('/get_output/<filename>')
def get_output(filename):
    output_path = os.path.join(OUTPUT_FOLDER, filename)
    if not os.path.exists(output_path):
        return jsonify({'error': 'Output file not found'}), 404
    return send_file(output_path, mimetype='image/png')

if __name__ == '__main__':
    app.run(debug=True)
