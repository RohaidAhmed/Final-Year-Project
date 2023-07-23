import os
import cv2
from PIL import Image
from keras.metrics import mse
from tensorflow import keras
import numpy as np
from flask import Flask, request, jsonify
import werkzeug
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
firstImage = None
seccondImage = None
confidence = None


def predicter(path, cnn_model):
    animals_list = [
        'non-retinal',
        'retinal',
    ]
    Image_Shape = (224, 224)
    path = path
    animal = Image.open(path).resize(Image_Shape)
    image = cv2.imread(str(path))
    if image is None:
        print("Wrong image")
        return "Golden_Jackal"
    else:
        image_resized = cv2.resize(image, (224, 224))
        image = np.expand_dims(image_resized, axis=0)
        pred = cnn_model.predict(image)
        global confidence
        confidence = np.max(pred)
        output_class = animals_list[np.argmax(pred)]
        return output_class


def secondPredicter(path, cnn_model):
    animals_list = [
        'No DR',
        'DR',
    ]
    Image_Shape = (224, 224)
    path = path
    animal = Image.open(path).resize(Image_Shape)
    image = cv2.imread(str(path))
    if image is None:
        print("Wrong image")
        return "Golden_Jackal"
    else:
        image_resized = cv2.resize(image, (224, 224))
        image = np.expand_dims(image_resized, axis=0)
        pred = cnn_model.predict(image)
        print(pred)
        global confidence
        confidence = np.max(pred)
        output_class = animals_list[np.argmax(pred)]
        return output_class


@app.route('/', methods=["GET"])
def hello_world():
    return "Hello World!"


@app.route('/upload', methods=["POST"])
def upload():  # put application's code here
    cnn_model = keras.models.load_model(
        'network1best_model (4).h5')
    if (request.method == "POST"):
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)

        imagefile.save("./uploadedimages/" + filename)
        path_of_image = "./uploadedimages/" + filename
        animal_name = predicter(path_of_image, cnn_model)
        # print(confidence)
        return jsonify({
            "confidence": str(confidence),
            "message": animal_name
        })


@app.route('/uploadS', methods=["POST"])
def uploadS():  # put application's code here
    cnn_model = keras.models.load_model(
        'network2best_model_mobilenet.h5')
    if (request.method == "POST"):
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        imagefile.save("./uploadedimages/" + filename)
        path_of_image = "./uploadedimages/" + filename
        animal_name = secondPredicter(path_of_image, cnn_model)
        return jsonify({
            "confidence": str(confidence),
            "message": animal_name
        })


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=os.getenv("PORT", default=5000), debug=True)
