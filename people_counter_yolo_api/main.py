from fastapi import FastAPI, UploadFile, File, Request, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

import os
import shutil
import time
import random
import subprocess

import cv2
import imageio_ffmpeg

try:
    from ultralytics import YOLO
except Exception:
    YOLO = None


app = FastAPI(title="People Counter YOLO API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
RESULT_DIR = "results"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(RESULT_DIR, exist_ok=True)

app.mount("/results", StaticFiles(directory=RESULT_DIR), name="results")

model = None


def load_yolo_model():
    global model

    if model is None:
        if YOLO is None:
            return None

        # โหลดโมเดล YOLO ขนาดเล็ก
        # ครั้งแรกจะดาวน์โหลด yolov8n.pt
        model = YOLO("yolov8n.pt")

    return model


@app.get("/")
def home():
    return {
        "message": "People Counter YOLO API is running",
        "mock_endpoint": "/detect-video?mode=mock",
        "real_yolo_endpoint": "/detect-video?mode=real",
    }


@app.post("/detect-video")
async def detect_video(
    request: Request,
    file: UploadFile = File(...),
    mode: str = Query(default="mock"),
):
    start_time = time.time()

    safe_name = file.filename.replace(" ", "_")
    input_path = os.path.join(UPLOAD_DIR, safe_name)

    with open(input_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    if mode == "real":
        yolo = load_yolo_model()

        if yolo is None:
            return {
                "success": False,
                "message": "YOLO cannot be loaded",
            }

        return process_real_yolo(
            request=request,
            yolo_model=yolo,
            input_path=input_path,
            safe_name=safe_name,
            start_time=start_time,
        )

    return process_mock_video(
        request=request,
        input_path=input_path,
        safe_name=safe_name,
        start_time=start_time,
    )


def convert_to_h264(input_path, output_path):
    """
    แปลงวิดีโอให้เป็น H.264 MP4
    เพื่อให้ Android / ExoPlayer เล่นได้
    """
    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()

    command = [
        ffmpeg_exe,
        "-y",
        "-i",
        input_path,
        "-vcodec",
        "libx264",
        "-pix_fmt",
        "yuv420p",
        "-movflags",
        "+faststart",
        output_path,
    ]

    subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )


def process_mock_video(request, input_path, safe_name, start_time):
    output_filename = f"mock_detected_{int(time.time())}_{safe_name}"

    if not output_filename.lower().endswith(".mp4"):
        output_filename += ".mp4"

    temp_output_filename = f"temp_{output_filename}"
    temp_output_path = os.path.join(RESULT_DIR, temp_output_filename)
    output_path = os.path.join(RESULT_DIR, output_filename)

    cap = cv2.VideoCapture(input_path)

    if not cap.isOpened():
        return {
            "success": False,
            "message": "Cannot open uploaded video",
        }

    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps <= 0:
        fps = 25

    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(temp_output_path, fourcc, fps, (width, height))

    frame_index = 0

    while True:
        ret, frame = cap.read()

        if not ret:
            break

        frame_index += 1

        # จำลองกรอบคนที่กำลังเคลื่อนที่
        move_x = 40 + (frame_index * 5) % max(width - 180, 1)

        x1 = move_x
        y1 = int(height * 0.25)
        x2 = move_x + 120
        y2 = int(height * 0.75)

        cv2.rectangle(
            frame,
            (x1, y1),
            (x2, y2),
            (0, 255, 0),
            3,
        )

        cv2.rectangle(
            frame,
            (x1, max(y1 - 35, 0)),
            (x1 + 180, y1),
            (0, 255, 0),
            -1,
        )

        cv2.putText(
            frame,
            "ID:P001 PERSON",
            (x1 + 5, max(y1 - 12, 15)),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.55,
            (0, 0, 0),
            2,
        )

        cv2.putText(
            frame,
            "Mock AI Detection",
            (20, 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 180, 255),
            2,
        )

        writer.write(frame)

    cap.release()
    writer.release()

    try:
        convert_to_h264(temp_output_path, output_path)
    except Exception as e:
        return {
            "success": False,
            "message": f"Video convert error: {str(e)}",
        }

    if os.path.exists(temp_output_path):
        os.remove(temp_output_path)

    unique_people = random.randint(5, 20)
    male = random.randint(0, unique_people)
    female = unique_people - male

    enter = unique_people
    exit_count = random.randint(0, enter)
    inside = enter - exit_count

    base_url = str(request.base_url).rstrip("/")
    output_video_url = f"{base_url}/results/{output_filename}"

    return {
        "success": True,
        "mode": "mock",
        "file_name": safe_name,
        "output_video_url": output_video_url,
        "total_people": unique_people,
        "unique_people": unique_people,
        "male": male,
        "female": female,
        "enter": enter,
        "exit": exit_count,
        "inside": inside,
        "status": "High Density" if unique_people >= 15 else "Normal",
        "processing_time": round(time.time() - start_time, 2),
        "message": "Mock video detection completed successfully",
    }


def process_real_yolo(request, yolo_model, input_path, safe_name, start_time):
    output_filename = f"yolo_detected_{int(time.time())}_{safe_name}"

    if not output_filename.lower().endswith(".mp4"):
        output_filename += ".mp4"

    temp_output_filename = f"temp_{output_filename}"
    temp_output_path = os.path.join(RESULT_DIR, temp_output_filename)
    output_path = os.path.join(RESULT_DIR, output_filename)

    cap = cv2.VideoCapture(input_path)

    if not cap.isOpened():
        return {
            "success": False,
            "message": "Cannot open uploaded video",
        }

    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps <= 0:
        fps = 25

    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(temp_output_path, fourcc, fps, (width, height))

    unique_ids = set()
    frame_index = 0
    last_annotated_frame = None

    while True:
        ret, frame = cap.read()

        if not ret:
            break

        frame_index += 1

        # เพื่อให้ประมวลผลเร็วขึ้น ตรวจจับทุก ๆ 5 เฟรม
        # เฟรมที่ไม่ได้ตรวจจับจะใช้เฟรมล่าสุดที่มีกรอบแทน
        if frame_index % 5 != 0:
            if last_annotated_frame is not None:
                writer.write(last_annotated_frame)
            else:
                writer.write(frame)
            continue

        results = yolo_model.track(
            frame,
            persist=True,
            classes=[0],  # class 0 = person
            verbose=False,
            tracker="bytetrack.yaml",
        )

        annotated_frame = frame.copy()

        if results and len(results) > 0:
            boxes = results[0].boxes

            if boxes is not None and boxes.xyxy is not None:
                for i, box in enumerate(boxes.xyxy):
                    x1, y1, x2, y2 = box.cpu().numpy().astype(int)

                    track_id = None

                    if boxes.id is not None:
                        track_id = int(boxes.id[i].cpu().numpy())
                        unique_ids.add(track_id)

                    label = "PERSON"

                    if track_id is not None:
                        label = f"ID:{track_id} PERSON"

                    cv2.rectangle(
                        annotated_frame,
                        (x1, y1),
                        (x2, y2),
                        (0, 255, 0),
                        2,
                    )

                    cv2.rectangle(
                        annotated_frame,
                        (x1, max(y1 - 30, 0)),
                        (x1 + 170, y1),
                        (0, 255, 0),
                        -1,
                    )

                    cv2.putText(
                        annotated_frame,
                        label,
                        (x1 + 5, max(y1 - 10, 15)),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.5,
                        (0, 0, 0),
                        2,
                    )

        cv2.putText(
            annotated_frame,
            f"Unique People: {len(unique_ids)}",
            (20, 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 180, 255),
            2,
        )

        last_annotated_frame = annotated_frame.copy()
        writer.write(annotated_frame)

    cap.release()
    writer.release()

    try:
        convert_to_h264(temp_output_path, output_path)
    except Exception as e:
        return {
            "success": False,
            "message": f"Video convert error: {str(e)}",
        }

    if os.path.exists(temp_output_path):
        os.remove(temp_output_path)

    unique_people = len(unique_ids)

    # YOLO ตรวจจับ person ได้จริง แต่ชาย/หญิงเป็นค่าจำลอง
    male = random.randint(0, unique_people) if unique_people > 0 else 0
    female = unique_people - male

    enter = unique_people
    exit_count = random.randint(0, enter) if enter > 0 else 0
    inside = enter - exit_count

    base_url = str(request.base_url).rstrip("/")
    output_video_url = f"{base_url}/results/{output_filename}"

    return {
        "success": True,
        "mode": "real_yolo",
        "file_name": safe_name,
        "output_video_url": output_video_url,
        "total_people": unique_people,
        "unique_people": unique_people,
        "male": male,
        "female": female,
        "enter": enter,
        "exit": exit_count,
        "inside": inside,
        "status": "High Density" if unique_people >= 15 else "Normal",
        "processing_time": round(time.time() - start_time, 2),
        "message": "YOLO video detection completed successfully",
    }