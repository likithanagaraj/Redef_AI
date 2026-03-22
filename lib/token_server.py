import os
from fastapi import FastAPI, HTTPException
from livekit import api

app = FastAPI()

LIVEKIT_API_KEY = os.getenv("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.getenv("LIVEKIT_API_SECRET")
LIVEKIT_URL = "https://redefai-0ymcdbve.livekit.cloud"

@app.get("/token")
def get_token():
    if not (LIVEKIT_API_KEY and LIVEKIT_API_SECRET):
        raise HTTPException(status_code=500, detail="Missing LiveKit credentials")

    room_name = "redef-demo"

    # Generate token
    token = api.AccessToken(
        LIVEKIT_API_KEY,
        LIVEKIT_API_SECRET,
    ).with_identity("flutter-user").with_grants(
        api.VideoGrants(room_join=True, room=room_name)
    ).to_jwt()

    # 👉 CREATE DISPATCH (THIS IS THE FIX)
    lk = api.LiveKitAPI(
        LIVEKIT_API_KEY,
        LIVEKIT_API_SECRET,
        url=LIVEKIT_URL,
    )

    lk.agent.dispatch_create(
        api.CreateAgentDispatchRequest(
            agent_name="Redef-demo",
            room=room_name,
        )
    )

    return {"token": token, "room": room_name}  