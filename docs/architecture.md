# System Architecture

The VM runs:
- **Ubuntu Server**: Base OS with NVIDIA drivers and CUDA 12.8.
- **Ollama**: Runs LLMs with GPU acceleration, accessible on port 11434.
- **Kokoro Fast API**: GPU-accelerated text-to-speech API, exposed on port 8880.
- **Wyoming OpenAI**: Optional component for Home Assistant integration, exposed on port 10200.

The NVIDIA GPU is passed through to the VM for hardware acceleration.
