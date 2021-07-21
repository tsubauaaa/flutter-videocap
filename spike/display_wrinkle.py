import json

import cv2
import mediapipe as mp
import numpy as np
from google.protobuf.json_format import MessageToJson


def filter(img, points, scale=0.5, masked=False, cropped=True):
    if masked:
        mask = np.zeros_like(img)
        for point in points:
            mask = cv2.ellipse(mask, (point, (50, 20), 0), (255, 255, 255), thickness=-1)
        img = cv2.bitwise_and(img, mask)
    if cropped:
        bounding_box = cv2.boundingRect(points)
        x, y, w, h = bounding_box
        cropped_part = img[y:y + h, x:x + w]
        cropped_part = cv2.resize(cropped_part, (0, 0), None, scale, scale)
        return cropped_part
    else:
        return mask


mp_drawing = mp.solutions.drawing_utils
mp_face_mesh = mp.solutions.face_mesh

drawing_spec = mp_drawing.DrawingSpec(thickness=1, circle_radius=1)
with mp_face_mesh.FaceMesh(
        static_image_mode=True,
        max_num_faces=1,
        min_detection_confidence=0.5) as face_mesh:
    image = cv2.imread("./out.png")
    height, width = image.shape[:2]
    results = face_mesh.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))

    if not results.multi_face_landmarks:
        print("results are empty.")
        exit()
    elif len(results.multi_face_landmarks) > 1:
        print("There are multiple faces.")
        exit()

    face_landmarks = json.loads((MessageToJson(results.multi_face_landmarks[0])))['landmark']

    face_points = [[int(face_landmark["x"] * width), int(face_landmark["y"] * height)] for face_landmark in face_landmarks]

    left_eye_center_point = face_points[226]
    right_eye_center_point = face_points[446]
    left_mouse_center_point = face_points[57]
    right_mouse_center_point = face_points[287]
    drawing_points = [left_eye_center_point, right_eye_center_point, left_mouse_center_point, right_mouse_center_point]
    
    img_lips = filter(image, drawing_points, 3, masked=True, cropped=False)

    img_color_lips = np.zeros_like(img_lips)
    color = (0, 0, 255)
    img_color_lips[:] = color
    img_color_lips = cv2.bitwise_and(img_lips, img_color_lips)
    # img_color_lips = cv2.GaussianBlur(img_color_lips, (7,7), 10)

    final_image = cv2.addWeighted(image, 1, img_color_lips, 0.4, 0)


    cv2.imwrite("mask.png", img_lips)
    cv2.imwrite("final.png" , final_image)
    cv2.imwrite("org_resized.png", image)
