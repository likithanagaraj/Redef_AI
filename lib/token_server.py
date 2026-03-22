from fastapi import FastAPI
from livekit import api
import os
import asyncio

app = FastAPI()

LIVEKIT_URL = "https://redefai-0ymcdbve.livekit.cloud"

@app.get("/token")
async def get_token():
    key = os.getenv("LIVEKIT_API_KEY")
    secret = os.getenv("LIVEKIT_API_SECRET")

    if not key or not secret:
        return {"error": "Missing credentials"}

    room_name = "test-room"

    token = (
        api.AccessToken(key, secret)
        .with_identity("user-1")
        .with_grants(api.VideoGrants(room_join=True, room=room_name))
        .to_jwt()
    )

    # 🔥 run dispatch in background (DON'T BLOCK)
    asyncio.create_task(dispatch_agent(key, secret, room_name))

    return {"token": token, "room": room_name}


async def dispatch_agent(key, secret, room_name):
    try:
        async with api.LiveKitAPI(
            url=LIVEKIT_URL,
            api_key=key,
            api_secret=secret,
        ) as lk:
            await lk.agent_dispatch.create_dispatch(
                api.CreateAgentDispatchRequest(
                    agent_name="Redef-demo",
                    room=room_name,
                )
            )
            print("Agent dispatched")
    except Exception as e:
        print("Dispatch error:", e)