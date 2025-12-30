Repo used on my youtube video about using Ruby with Ollama AI.

The Docker compose is inpired on my contribuition on helo_lhama project, a complete chat bot with UI app:

https://github.com/fabiosammy/hello_llama


# Installing

<img src="https://upload.wikimedia.org/wikipedia/sco/thumb/2/21/Nvidia_logo.svg/351px-Nvidia_logo.svg.png?20150924223142" width="50" heigth="50"> If you use NVIDIA, prepare your environment:

1. Configure the repository

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
```

2. Install the NVIDIA Container Toolkit packages

```bash
sudo apt-get install -y nvidia-container-toolkit
```

3. Configure Docker to use Nvidia driver

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```
4. If you encounter the

`no nvidia devices detected by library /usr/lib/x86_64-linux-gnu/libcuda.so`

you can solve by editing `/etc/nvidia-container-runtime/config.toml` as:

```bash
sudo nano  /etc/nvidia-container-runtime/config.toml
```

change `no-cgroups = false`

save the file and restart docker:

```bash
sudo systemctl restart docker
```

more about it: https://github.com/ollama/ollama/issues/6840

Now you can run the project


First, Spin up the ollama service:

```
docker compose up -f docker-compose-nvidia.yaml
```

Now, in a new terminal, connect to the ollama container, and then download the models that you need, we recommend the combination below:

```
docker compose -f docker-compose-nvidia.yaml exec ollama bash
ollama pull llama3.1:8b
```

You can check more models here: [https://ollama.com/library](https://ollama.com/library)

# Working with MCP Integration

This is a work in progress feature.

create the db

```bash
ruby db.rb
```

To make everything work, you need to start the MCP server by running:

```bash
ruby mcp_server.rb
```

Then, you can run the demo:

```bash
ruby mcp_demo.rb
```

Demo

https://github.com/user-attachments/assets/f3af7e5e-c1fd-4bf3-88d2-78a9d607cd4a


