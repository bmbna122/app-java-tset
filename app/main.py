from fastapi import FastAPI
app = FastAPI()
@app.get("/")
def home():
    return {"message": "CI/CD"} 
    # return {"message": "BLue"}
@app.get("/health")
def health():
    return {"status": "healthy"}

raise Exception("Test exception")
