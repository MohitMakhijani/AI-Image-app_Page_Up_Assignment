from flask import Flask, request, jsonify , send_file
from deepface import DeepFace
import numpy as np
import cv2
import tempfile
import os
import mediapipe as mp
from io import BytesIO
from PIL import Image
import base64

app = Flask(__name__)

# ---------- Existing embedding route ----------
@app.route("/get_embedding", methods=["POST"])
def get_embedding():
    try:
        if 'image' not in request.files:
            return jsonify({"error": "No image file uploaded"}), 400

        file = request.files['image']
        file_bytes = file.read()
        nparr = np.frombuffer(file_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        # Save image temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp:
            temp_path = tmp.name
            cv2.imwrite(temp_path, img)

        results = DeepFace.represent(
            img_path=temp_path,
            model_name="Facenet",
            detector_backend="retinaface",
            enforce_detection=True
        )

        os.remove(temp_path)

        if results:
            return jsonify({"embedding": results[0]["embedding"]}), 200
        else:
            return jsonify({"error": "No face detected"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/bokeh_effect", methods=["POST"])
def bokeh_effect():
    try:
        if 'image' not in request.files:
            return jsonify({"error": "No image file uploaded"}), 400

        file = request.files['image']
        file_bytes = file.read()
        nparr = np.frombuffer(file_bytes, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        mp_selfie_segmentation = mp.solutions.selfie_segmentation
        with mp_selfie_segmentation.SelfieSegmentation(model_selection=1) as selfie_seg:
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = selfie_seg.process(image_rgb)
            mask = results.segmentation_mask
            condition = mask > 0.5
            blurred = cv2.GaussianBlur(image, (101, 101), 0)
            bokeh_result = np.where(condition[..., None], image, blurred)

        # Convert image to JPEG and send it directly
        _, buffer = cv2.imencode('.jpg', bokeh_result)
        img_io = BytesIO(buffer.tobytes())
        img_io.seek(0)

        return send_file(img_io, mimetype='image/jpeg', download_name='bokeh_result.jpg')

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
