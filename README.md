# icorn

icorn is a [uvicorn](https://uvicorn.dev) container implementation as an ASGI
web server implementation for Python, designed to handle network communication
for asynchronous applications. It allows frameworks like FastAPI to
efficiently manage incoming requests and responses using the ASGI
specification.

## Initial Setup

```
uv init
uv add uvicorn fastapi
```

## Run Application

```
uv run uvicorn main:app --reload
```
