import json

import cv2
import mediapipe as mp
import numpy as np
from google.protobuf.json_format import MessageToJson


def analyze_action_unit(event, context):
    print('Event ID: {}'.format(context.event_id))
    print('Event type: {}'.format(context.event_type))
    print('Bucket: {}'.format(event['bucket']))
    print('File: {}'.format(event['name']))
    print('Metageneration: {}'.format(event['metageneration']))
    print('Created: {}'.format(event['timeCreated']))
    print('Updated: {}'.format(event['updated']))

    if "csvs/" not in event["name"]:
        return
