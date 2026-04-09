@app.get("/token")
async def get_token():
    key = os.getenv("LIVEKIT_API_KEY")
    secret = os.getenv("LIVEKIT_API_SECRET")

    room_name = "redef-room"
    identity = "user-" + os.urandom(4).hex()

    token = (
        api.AccessToken(key, secret)
        .with_identity(identity)
        .with_grants(
            api.VideoGrants(
                room_join=True,
                room=room_name,
                can_publish=True,
                can_subscribe=True,
            )
        )
        .to_jwt()
    )

    return {
        "token": token,
        "room": room_name,
    }