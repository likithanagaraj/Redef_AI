@app.get("/token")
def get_token():
    key = os.getenv("LIVEKIT_API_KEY")
    secret = os.getenv("LIVEKIT_API_SECRET")

    print("KEY:", key)
    print("SECRET:", secret)

    if not key or not secret:
        return {"error": "Missing credentials"}

    token = (
        api.AccessToken(key, secret)
        .with_identity("user-1")
        .with_grants(api.VideoGrants(room_join=True, room="test-room"))
        .to_jwt()
    )

    return {"token": token, "room": "test-room"}