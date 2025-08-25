# Docker Tasks in **GitHub Codespaces** - 10 Points

- In this Codespace, a Docker daemon runs inside the workspace container . The docker CLI is preinstalled and connected. You can open the Terminal and run commands right away.

- First study [Docker Basics](https://dipaish.github.io/OS22/index.html) properly. I recommend completing all the tasks from the learning materials in the same environment to become familiar with the Docker environment before attempting the practical exercises below. ***You are also free to install Docker in your own personal device if you wish to.***

- You can check your score yourself. You can get a total of 10 points from the tasks.

- Remember to frequently commit and push the changes [12.Commit and push](#12--commit-and-push)

---

## 1. Verify Docker in the Codespace

```bash
# lets start by checking that Docker is available 
docker version
```

---

## 2. Use Docker run command to run a docker container based on hello-world image 

---

## 3. Use Docker run command to run a docker container based on alpine image 


---

## 4. Use Docker run command to run a docker container based on alpine image, the name of the container should be alpine-it-demo and get access to the container shell.
i.	docker run -it alpine /bin/sh ***(hint update this and include the name of the container as alpine-it-demo)***

ii.	Use mkdir command to make directories: /lab/dir1 /lab/dir2

iii. Use exit command to exit from the container’s shell. 


## 5. Run a static website in a container using an existing image “static-site”. 

i.	docker run --name static-site-2 -e AUTHOR="Your Name" -d -p 8888:80 dockersamples/static-site ***Check and read about the static-site image from DockerHub.***

ii.	Click **Open in browser** to view the simple website.

---

## 6. Type docker command to list images

---

## 7. Type docker command to list all running containers


---

## 8. Type docker command to list all containers (running + exited)


---

## 9. Type docker command to stop a running container

---

## 10. Type docker command to remove a container


---

## 11. Run the check.sh script and know your score
```bash
# it is always important to provide executable permission for the script to run that is what we do below and then run the script
chmod +x .github/classroom/check.sh
.github/classroom/check.sh > result.txt

# After you have run the above command, you can check your score by typing 

cat result.txt 

```

>> Note 

- If you’re not satisfied with your score, you may correct any mistakes you’ve made. You can try as many times as you like before the deadline. The score you have at the deadline will be your final score. ***I will check it from your repository.***
- After making the corrections, **re-run Task 11** again and check your score. 
- **Always remember to commit and push the changes you have made by doing the Task no. 12 before closing the GitHub Codespace. You need to do this frequently that is every time you work on the tasks, remember to commit and push**


## 12. Commit and push
```bash
git add .
git commit -m "Completed 11 docker tasks"
git push
```
