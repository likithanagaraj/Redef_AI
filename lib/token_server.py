import os
from fastapi import FastAPI, HTTPException
from livekit import api

app = FastAPI()

LIVEKIT_API_KEY = os.getenv("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.getenv("LIVEKIT_API_SECRET")

@app.get("/token")
def get_token():
    if not (LIVEKIT_API_KEY and LIVEKIT_API_SECRET):
        raise HTTPException(status_code=500, detail="Missing LiveKit credentials")

    token = api.AccessToken(
        LIVEKIT_API_KEY,
        LIVEKIT_API_SECRET,
    ).with_identity("flutter-user").with_grants(
        api.VideoGrants(room_join=True, room="test-room")
    ).to_jwt()

    return {"token": token}