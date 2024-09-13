# Piper TTS Server

This Node.js application is a Text-to-Speech (TTS) server using Piper, which converts text input into spoken audio.

## Requirements
#### Mac and Window (Ubuntu)
- Node.js
- Npm

## Installation

1. Clone the repository.
    ```bash
   git clone https://github.com/flukexp/PiperTTS-API-Wrapper.git
2. Navigate to the project directory.
    ```bash
    cd PiperTTS-API-Wrapper
3. Install dependencies, Piper TTS, Piper sample voices and Start piper server:
   ```bash
   ./piper_installer.sh
   
## Endpoints
#### Base URL

```
http://localhost:5001/
```

#### 1. **GET `/`**

**Description:**  
Returns basic information about the server.

#### 2. **POST `/tts`**

**Request Body:**
The request body should be a JSON object with the following properties:
- `text` (string, required): The text to be converted into speech.
- `voice` (string, optional): The voice model to be used for speech synthesis. If not provided, the default voice model will be used.

**Response:**
`audio/wav`

#### 3. **GET `/tts?text=<text>&voice=<voice>`**

**Request Body:**
The request body should be a JSON object with the following properties:
- `text` (string, required): The text to be converted into speech.
- `voice` (string, optional): The voice model to be used for speech synthesis. If not provided, the default voice model will be used.

**Response:**
`audio/wav`


#### 4. **GET `/voices`**

**Description:**
The response will be a JSON array containing the names of available voice models.

