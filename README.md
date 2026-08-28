# Docker Tasks in **GitHub Codespaces** - 15 Points

This assignment is a hands-on introduction to Docker. You don't need any prior Docker experience. Every task below explains **what** you are doing and **why**, so that by the end you'll understand the core concepts behind containers, images, and how Docker actually works.

- In this Codespace, a Docker daemon runs inside the workspace container. The docker CLI is preinstalled and connected. You can open the Terminal and run commands right away, with no setup needed.
- First study [Docker Basics](https://dipaish.github.io/OS22/index.html) properly. I recommend completing all the tasks from the learning materials in the same environment to become familiar with the Docker environment before attempting the practical exercises below. ***You are also free to install Docker in your own personal device if you wish to.***
- You can check your score yourself. You can get a total of **15 points** from the tasks below.
- Remember to frequently commit and push the changes [Task 17. Commit and push](#17-commit-and-push)

---

##  Docker Concepts You Need First

Before you start, it helps to know these four terms. You will meet all of them in the tasks below:

| Term | What it means |
|---|---|
| **Image** | A read-only "template" or blueprint (e.g. `alpine`, `hello-world`). It contains everything needed to run an application: code, runtime, libraries. You **build or download** an image, but you don't run "an image" directly. Instead, you run a *container* from it. |
| **Container** | A running (or stopped) **instance** of an image. Think of it like a class (image) versus an object (container). You can create many containers from the same image, and each one is isolated from the others and from your host machine. |
| **Dockerfile** | A text file with step-by-step instructions (`FROM`, `RUN`, `CMD`, ...) that tells Docker how to **build your own custom image**. |
| **Volume / Bind mount** | Containers are normally *ephemeral*, meaning that when you delete a container, its filesystem changes are gone. A volume/bind mount is a folder shared between your host and the container so data can **persist** even after the container is removed. |

---

## 1. Verify Docker in the Codespace

**Concept: the Docker client/daemon architecture.** The `docker` command you type is the *client*; it talks to a background service called the *daemon* (or "engine") which actually creates and runs containers. This task just confirms both are alive and can talk to each other.

```bash
# Check the client + server (daemon) versions
docker version

# Check daemon-level info (containers, images, storage driver, etc.)
docker info
```

**✅ Task 1 (1 point):** Both commands above should run without errors.

---

## 2. Run your first container: `hello-world`

**Concept: images vs. containers, and `docker pull`.** When you run a container from an image you don't have locally yet, Docker automatically **pulls** (downloads) it from Docker Hub first, then creates a container from it.

```bash
docker run hello-world
```

Read the message it prints. It explains the exact steps Docker just performed: pull the image, create a container, run it, stream the output back to you, and then exit.

**✅ Task 2 (1 point):** The `hello-world` container has been run.

---

## 3. Run a container based on the `alpine` image

**Concept: minimal base images.** `alpine` is a tiny (~5MB) Linux distribution, commonly used as a lightweight base for other images. Unlike `hello-world` (which just prints a message and exits), `alpine` gives you an actual mini Linux environment you can interact with.

```bash
docker run alpine echo "hello from alpine"
```

**✅ Task 3 (1 point):** A container based on `alpine` has been run.

---

## 4. Run a **named, interactive** alpine container: `alpine-it-demo`

**Concept: interactive mode (`-it`) and naming containers.** By default, `docker run` gives your container a random name and exits as soon as its command finishes. The `-it` flags (interactive + pseudo-TTY) keep an open shell session inside the container so you can type commands into it, just like SSH-ing into a machine. Naming a container with `--name` makes it easier to refer to later (`docker start alpine-it-demo`, `docker exec alpine-it-demo ...`) instead of using random IDs.

```bash
docker run -it --name alpine-it-demo alpine /bin/sh
```

You are now *inside* the container's shell. Notice that this is a completely separate filesystem from your Codespace. Running `ls /` will look nothing like your repo.

**✅ Task 4 (1 point):** A container named `alpine-it-demo` exists.

---

## 5. Create directories inside the container

**Concept: container filesystem isolation.** Every container gets its own private filesystem, layered on top of its image. Changes you make, like creating folders, only exist inside that container. They don't affect your host, and they don't affect other containers, even ones created from the same image.

While still inside the `alpine-it-demo` shell:

```sh
mkdir -p /lab/dir1 /lab/dir2
ls /lab
exit
```

`exit` leaves the shell and **stops** the container. It isn't removed, so its filesystem, including your two folders, is preserved until you run `docker rm` on it.

**✅ Task 5 (1 point):** `/lab/dir1` and `/lab/dir2` both exist inside `alpine-it-demo`.

---

## 6. List all containers (running + stopped) and save the output

**Concept: container lifecycle states.** A container can be `created`, `running`, `paused`, `exited`, or `removed`. Plain `docker ps` only shows **running** containers. You need the `-a` flag, short for "all", to also see stopped ones, like `alpine-it-demo` right now.

```bash
mkdir -p outputs
docker ps -a | tee outputs/ps-a.txt
```

`tee` prints the output to your terminal **and** saves it to a file, so the checker (and you, later) can see proof of what you ran.

**✅ Task 6 (1 point):** `outputs/ps-a.txt` exists and lists `alpine-it-demo`.

---

## 7. Run a static website container: `static-site-2`

**Concept: detached mode (`-d`), port publishing (`-p`), and environment variables (`-e`).** Long-running services, like a web server, shouldn't tie up your terminal. The `-d` flag runs the container in the background, known as "detached" mode. Containers have their own private network by default, so `-p HOST:CONTAINER` **publishes** a container port to a port on your machine so you can actually reach it. The `-e` flag passes an environment variable into the container, a common way to configure apps without changing their code.

```bash
docker run --name static-site-2 -e AUTHOR="Your Name" -d -p 8888:80 dockersamples/static-site
```

***Check and read about the `static-site` image on Docker Hub to see what it does.***

**✅ Task 7 (1 point):** `static-site-2` is running with host port `8888` mapped to container port `80`.

---

## 8. View the website in your browser

**Concept: why port publishing matters.** Without `-p 8888:80`, the container's port 80 would only be reachable from *inside* Docker's internal network, so it would stay invisible to you. Publishing it is what lets your browser, outside the container, reach the app running inside the container.

- Click **Open in Browser** on the port 8888 notification, or run:

```bash
curl http://127.0.0.1:8888
```

**✅ Task 8 (1 point):** The website responds on port 8888.

---

## 9. Inspect the container's configuration

**Concept: using `docker inspect` to view metadata about a container.** Every container has a large JSON document describing its config: environment variables, network settings, mounted volumes, IP address, and more. This is the go-to command when you need to debug "why isn't this container behaving the way I expect?".

```bash
docker inspect static-site-2 | tee outputs/inspect-static-site-2.txt
```

Search the output for `"AUTHOR="`. You will find the environment variable you passed in Task 7, which proves it made it into the container's config.

**✅ Task 9 (1 point):** `outputs/inspect-static-site-2.txt` exists and contains your `AUTHOR` environment variable.

---

## 10. View and save the container's logs

**Concept: using `docker logs` to read stdout/stderr of a container.** Containers don't have a screen; whatever a process inside prints to standard output/error is captured by Docker and can be replayed at any time with `docker logs`, even for containers running in the background. This is the first place to look when something is misbehaving.

```bash
docker logs static-site-2 | tee outputs/static-site-2-logs.txt
```

**✅ Task 10 (1 point):** `outputs/static-site-2-logs.txt` exists and is not empty.

---

## 11. List all downloaded images and save the output

**Concept: the local image cache.** Every image you've pulled or built is cached locally so it doesn't need to be re-downloaded every time. `docker images` shows this cache, including image size, which helps you understand why some images, like `alpine`, are preferred for being small.

```bash
docker images | tee outputs/images.txt
```

**✅ Task 11 (1 point):** `outputs/images.txt` exists and lists `alpine`, `hello-world`, and `dockersamples/static-site`.

---

## 12. Write a `Dockerfile` and build your own image

**Concept: using a `Dockerfile` and `docker build` to create custom images.** So far you've only used images built by other people. A `Dockerfile` lets you define your **own** image: what base image to start from (`FROM`), and what it should do when run (`CMD`). This is the foundation of using Docker for your own applications.

Create a file named `Dockerfile` in the root of this repository:

```dockerfile
FROM alpine:latest
LABEL maintainer="Your Name"
CMD ["echo", "Hello, Docker! This is my first custom image."]
```

Then build it (the `.` means "use the Dockerfile in the current folder", `-t` gives your image a name/tag):

```bash
docker build -t my-first-image .
```

**✅ Task 12 (1 point):** A `Dockerfile` exists in the repo, and an image named `my-first-image` has been built.

---

## 13. Run a container from your own image

**Concept: your custom image behaves just like any other image.** Once built, `my-first-image` can be run exactly like `alpine` or `hello-world`. Docker doesn't distinguish between images you built and images you downloaded.

```bash
docker run --name my-first-container my-first-image | tee outputs/my-first-container-output.txt
```

**✅ Task 13 (1 point):** `outputs/my-first-container-output.txt` exists and contains the output of your custom image.

---

## 14. Persist data with a bind mount

**Concept: using volumes and bind mounts to make data outlive a container.** Normally, when a container is removed, everything it wrote is gone. A **bind mount** maps a folder on your host into the container, so any file written there actually lives on your host filesystem and survives container removal. This is essential for databases, logs, and any data you want to keep.

```bash
mkdir -p data
docker run --rm -v "$(pwd)/data:/data" alpine sh -c "echo 'This data survives even after the container is removed!' > /data/note.txt"
cat data/note.txt
```

Notice that the `--rm` flag automatically removes the container right after it exits, yet `data/note.txt` is still there on your host. That's the whole point of a bind mount.

**✅ Task 14 (1 point):** `data/note.txt` exists and is not empty.

---

## 15. Stop and remove a container

**Concept: cleaning up with `docker stop` and `docker rm`.** `docker stop` gracefully shuts down a running container. It still exists afterwards, in the `exited` state. `docker rm` permanently deletes a stopped container. Removing a container never removes the underlying image, so you can always create a fresh container from it again.

Try it on any container you no longer need, for example:

```bash
docker run -d --name cleanup-demo alpine sleep 300
docker stop cleanup-demo
docker rm cleanup-demo
```

**✅ Task 15 (1 point):** You have successfully stopped and removed a container.

---

## Optional Extra (Not Graded): Explore a New Docker Image

This task is purely for your own additional learning. It carries **no points** and is **not checked** by `check.sh` or graded in any way.

**Concept: exploring the Docker Hub ecosystem.** So far you've only used a handful of images picked for you. Docker Hub hosts hundreds of thousands of images for almost every purpose. Being able to find, understand, and safely try out a new image is a core Docker skill.

**What to do (optional):**

1. Go to [Docker Hub](https://hub.docker.com/) and find a lightweight, official/well-maintained image you haven't used yet in this assignment. Pick something from a category that interests you, for example:
   - AI / Machine Learning (e.g. a small model-serving or notebook image)
   - Security (e.g. a vulnerability scanner or network diagnostic tool)
   - Databases (e.g. `redis`, `postgres`, `mongo`)
   - Or any other category you find interesting.
2. Write a short paragraph describing what the image/application does, why it's useful, and why you consider it lightweight (for example, its image size from `docker images`).
3. Pull and run the image with `docker run`, and confirm it actually starts and works as expected.
4. Take a screenshot showing it running, just to have a record for yourself.

---

## 16. Run the check.sh script and know your score
```bash
chmod +x .github/classroom/check.sh
.github/classroom/check.sh > result.txt

# After you have run the above command, you can check your score by typing 

cat result.txt 

```

>> Note 

- If you’re not satisfied with your score, you may correct any mistakes you’ve made. You can try as many times as you like.
- After making the corrections, **re-run Task 16** again and check your score. 
- **Always remember to commit and push the changes you have made by doing Task 17 before closing the GitHub Codespace. You need to do this frequently. Every time you work on the tasks, remember to commit and push.**


## 17. Commit and push
```bash
git add .
git commit -m "Completed 15 docker tasks"
git push
```
