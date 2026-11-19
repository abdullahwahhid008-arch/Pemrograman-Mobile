from datetime import datetime
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from .database import engine

app = FastAPI(
    title="TabungKu API",
    version="0.1.0"
)


@app.get("/")
def beranda():
    return {
        "pesan": "Selamat datang di TabungKu API",
        "dokumentasi": "/docs"
    }


@app.get("/health")
def health():
    waktu = datetime.now().isoformat(timespec="seconds")

    try:
        with engine.connect() as connection:
            versi = connection.execute(
                text("SELECT VERSION()")
            ).scalar_one()

        return {
            "status": "ok",
            "waktu_server": waktu,
            "database": "connected",
            "mysql_version": versi
        }

    except SQLAlchemyError as error:
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "waktu_server": waktu,
                "database": "error",
                "mysql_version": None,
                "detail": str(error)
            }
        )