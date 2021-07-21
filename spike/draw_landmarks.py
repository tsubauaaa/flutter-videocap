import json

import cv2
import mediapipe as mp
from google.protobuf.json_format import MessageToJson

mp_drawing = mp.solutions.drawing_utils
mp_face_mesh = mp.solutions.face_mesh

drawing_spec = mp_drawing.DrawingSpec(thickness=1, circle_radius=1)
with mp_face_mesh.FaceMesh(
        static_image_mode=True,
        max_num_faces=1,
        min_detection_confidence=0.5) as face_mesh:
    image = cv2.imread("./out.png")
    results = face_mesh.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))

    if not results.multi_face_landmarks:
        print("results are empty.")
        exit()
    elif len(results.multi_face_landmarks) > 1:
        print("There are multiple faces.")
        exit()

    face_landmarks = json.loads((MessageToJson(results.multi_face_landmarks[0])))['landmark']

    print("face_landmarks:", face_landmarks)
    face_points = [[face_landmark["x"], face_landmark["y"]] for face_landmark in face_landmarks]
    
    print(face_points)
    print(len(face_points))
