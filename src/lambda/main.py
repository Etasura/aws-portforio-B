import json

def handler(event, context):
    body = json.loads(event.get("body") or "{}")

    name = body.get("name")
    email = body.get("email")
    message = body.get("message")

    print(f"お問い合わせ受信: {name=} {email=} {message=}")

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps({"message": "お問い合わせを受け付けました"})
    }
