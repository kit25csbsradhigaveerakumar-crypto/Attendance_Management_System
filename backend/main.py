"""
FastAPI Application Entrypoint
Attendance Management System
"""

import os
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

from backend.routes import auth, students, subjects, attendance, reports

app = FastAPI(
    title="Attendance Management System API",
    description="Oracle Database + FastAPI powered Academic Attendance Management System",
    version="1.0.0"
)

# Enable CORS for local testing, web clients, and direct file access
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=".*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Routers under /api
app.include_router(auth.router, prefix="/api")
app.include_router(students.router, prefix="/api")
app.include_router(subjects.router, prefix="/api")
app.include_router(attendance.router, prefix="/api")
app.include_router(reports.router, prefix="/api")

# Mount frontend directory for static serving
FRONTEND_DIR = Path(__file__).resolve().parent.parent / "frontend"

if FRONTEND_DIR.exists():
    app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

    @app.get("/")
    def serve_index():
        return FileResponse(FRONTEND_DIR / "index.html")

    # Convenience routes for html files
    @app.get("/{page}.html")
    def serve_page(page: str):
        page_file = FRONTEND_DIR / f"{page}.html"
        if page_file.exists():
            return FileResponse(page_file)
        return FileResponse(FRONTEND_DIR / "index.html")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8000, reload=True)
