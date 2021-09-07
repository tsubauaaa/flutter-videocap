import json
import re

import cv2
import firebase_admin
import mediapipe as mp
import numpy as np
import pandas as pd
from firebase_admin import firestore
from google.protobuf.json_format import MessageToJson

firebase_admin.initialize_app()

db = firestore.client()


def analyze_action_unit(event, context):
    print("Event ID: {}".format(context.event_id))
    print("Event type: {}".format(context.event_type))
    print("Bucket: {}".format(event["bucket"]))
    print("File: {}".format(event["name"]))
    print("Metageneration: {}".format(event["metageneration"]))
    print("Created: {}".format(event["timeCreated"]))
    print("Updated: {}".format(event["updated"]))

    if "csvs/" not in event["name"]:
        return

    gs_url = f"gs://{event['bucket']}/{event['name']}"

    df = pd.read_csv(gs_url)

    target_columns = [x for x in df.columns if re.match(r"^AU.+_r$", x)]
    print(target_columns)
