from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, HttpUrl
import boto3
import os
import hashlib
from datetime import datetime

app = FastAPI(title="URL Shortener")

# DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name=os.getenv('AWS_REGION', 'eu-north-1'))
table_name = os.getenv('DYNAMODB_TABLE', 'urls-dev')
table = dynamodb.Table(table_name)

class URLRequest(BaseModel):
    url: HttpUrl

class URLResponse(BaseModel):
    short_code: str
    original_url: str
    short_url: str

def generate_short_code(url: str) -> str:
    """Generate 6-character hash from URL"""
    return hashlib.md5(url.encode()).hexdigest()[:6]

@app.get("/", response_class=HTMLResponse)
def home():
    """Home page with UI"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>URL Shortener - AWS ECS Fargate Project</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 600px;
            width: 100%;
        }
        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }
        .logo-icon {
            font-size: 3em;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .logo-text {
            font-size: 1.8em;
            font-weight: bold;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            letter-spacing: -1px;
        }
        h1 {
            color: #667eea;
            text-align: center;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 0.9em;
        }
        .badge {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.8em;
            margin: 5px;
        }
        .input-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
        }
        input[type="url"] {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        input[type="url"]:focus {
            outline: none;
            border-color: #667eea;
        }
        button {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
        }
        button:active {
            transform: translateY(0);
        }
        .result {
            display: none;
            margin-top: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        .result.show {
            display: block;
            animation: slideIn 0.3s ease;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .short-url {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }
        .short-url input {
            flex: 1;
            padding: 10px;
            border: 2px solid #667eea;
            border-radius: 8px;
            font-size: 16px;
            background: white;
        }
        .copy-btn {
            padding: 10px 20px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            width: auto;
        }
        .copy-btn:hover {
            background: #5568d3;
        }
        .error {
            color: #e74c3c;
            margin-top: 10px;
            display: none;
        }
        .error.show {
            display: block;
        }
        .stats {
            display: flex;
            justify-content: space-around;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e0e0e0;
        }
        .stat {
            text-align: center;
        }
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #666;
            font-size: 0.9em;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #e0e0e0;
            color: #999;
            font-size: 0.85em;
        }
        .footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <div class="logo-icon">⚡</div>
            <div class="logo-text">awsapp.cloudycode</div>
        </div>
        <h1>🔗 URL Shortener v4.0</h1>
        <p class="subtitle">
            <span class="badge">AWS ECS Fargate</span>
            <span class="badge">Terraform</span>
            <span class="badge">Blue/Green Deployment</span>
            <span class="badge">CodeDeploy</span>
        </p>

        <div class="input-group">
            <label for="url">Enter your long URL:</label>
            <input type="url" id="url" placeholder="https://example.com/very/long/url" required>
        </div>

        <button onclick="shortenURL()">✨ Shorten URL</button>

        <div class="error" id="error"></div>

        <div class="result" id="result">
            <h3>✅ Your shortened URL:</h3>
            <div class="short-url">
                <input type="text" id="shortUrl" readonly>
                <button class="copy-btn" onclick="copyURL()">📋 Copy</button>
            </div>
        </div>

        <div class="stats">
            <div class="stat">
                <div class="stat-value" id="urlCount">0</div>
                <div class="stat-label">URLs Created</div>
            </div>
            <div class="stat">
                <div class="stat-value">⚡</div>
                <div class="stat-label">Fast & Secure</div>
            </div>
        </div>

        <div class="footer">
            <strong>ECS Fargate Terraform Deployment</strong><br>
            Made  by <a href="https://github.com/engabelal" target="_blank">Ahmed Belal</a> | Powered by AWS ECS Fargate & Terraform
        </div>
    </div>

    <script>
        let urlCount = 0;

        async function shortenURL() {
            const urlInput = document.getElementById('url');
            const url = urlInput.value.trim();
            const errorDiv = document.getElementById('error');
            const resultDiv = document.getElementById('result');

            errorDiv.classList.remove('show');
            resultDiv.classList.remove('show');

            if (!url) {
                errorDiv.textContent = 'Please enter a URL';
                errorDiv.classList.add('show');
                return;
            }

            try {
                const response = await fetch('/api/shorten', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ url: url })
                });

                if (!response.ok) throw new Error('Failed to shorten URL');

                const data = await response.json();
                document.getElementById('shortUrl').value = data.short_url;
                resultDiv.classList.add('show');
                urlCount++;
                document.getElementById('urlCount').textContent = urlCount;
            } catch (error) {
                errorDiv.textContent = 'Error: ' + error.message;
                errorDiv.classList.add('show');
            }
        }

        function copyURL() {
            const shortUrl = document.getElementById('shortUrl');
            shortUrl.select();
            document.execCommand('copy');

            const btn = event.target;
            const originalText = btn.textContent;
            btn.textContent = '✅ Copied!';
            setTimeout(() => {
                btn.textContent = originalText;
            }, 2000);
        }

        document.getElementById('url').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') shortenURL();
        });
    </script>
</body>
</html>
    """

@app.get("/health")
def health_check():
    """Health check endpoint for ALB"""
    return {"status": "healthy", "service": "url-shortener"}

@app.post("/api/shorten", response_model=URLResponse)
def shorten_url(request: URLRequest):
    """Create shortened URL"""
    original_url = str(request.url)
    short_code = generate_short_code(original_url)

    # Save to DynamoDB
    try:
        table.put_item(Item={
            'short_code': short_code,
            'original_url': original_url,
            'created_at': datetime.utcnow().isoformat()
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

    base_url = os.getenv('BASE_URL', 'http://localhost:8000')
    return URLResponse(
        short_code=short_code,
        original_url=original_url,
        short_url=f"{base_url}/{short_code}"
    )

@app.get("/{short_code}")
def redirect_url(short_code: str):
    """Redirect to original URL"""
    try:
        response = table.get_item(Key={'short_code': short_code})
        if 'Item' not in response:
            raise HTTPException(status_code=404, detail="URL not found")

        return RedirectResponse(url=response['Item']['original_url'])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

# Blue/Green Deployment Test - CodeDeploy v4.0
