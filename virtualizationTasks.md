# Virtualization Basics Tasks (Hyper-V or VirtualBox or any hypervisor of your choice) - 5 Points 

In this task, you will create a virtual machine and install Ubuntu 24.04 LTS using the official Desktop ISO image.

> You can download thee **latest Ubuntu Desktop LTS (24.04)** ISO.   from the official page: https://ubuntu.com/download/desktop 
---

## 1) Install a Virtualization Tool

### Option A: Hyper-V (Windows 10/11 Pro/Enterprise/Education)
1. Open **Windows Features** .
2. Enable **Hyper-V** → **Hyper-V Management Tools** and **Hyper-V Platform**.
3. Reboot, then launch **Hyper-V Manager** from Start.

### Option B: VirtualBox (cross-platform)
- **Download Virtual Box:** from the [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads).
- Follow the installation steps and install **Virtual Box**.

---

## 2) Get the OS Image (Ubuntu Desktop 24.04 LTS)

1. Download **Ubuntu 24.04.x LTS Desktop ISO**.  
   - Primary page: ubuntu.com/download/desktop.  
2. Verify the file finishes downloading (≈ 5–6 GB).  

---

## 3) Create the Virtual Machine

### A) Hyper-V Manager (recommended settings)
1. Hyper-V Manager →  **Connect to Server → Local Computer** → New → Virtual Machine**
2. **Name:** `Firstname_Lastname_Ubuntu`  
3. **Generation:** **Generation 2** (UEFI). 
4. **Assign Memory (RAM):** **2048 MB** (2 GB).  
5. **Configure Networking:** **Default Switch** (NAT) for Internet.  
6. **Virtual Hard Disk:** **20 GB**, **dynamically expanding** (VHDX).  
7. **Installation Options:** **Install an OS from a bootable image file** → select the Ubuntu 24.04 ISO.  
8. **Finish → Start → Connect**, then follow the Ubuntu installer.

---

### B) VirtualBox (recommended settings)
1. **New** → **Name:** `Firstname_Lastname_Ubuntu`  
2. **Type:** Linux → **Version:** Ubuntu (64-bit)  
3. **Memory:** **2048 MB** 
4. **Disk:** **VDI**, **Dynamically allocated**, **20 GB**  
5. **ISO:** “**Use an ISO image**” → pick the Ubuntu 24.04 ISO  
6. **Start** and complete the Ubuntu installer.

> Tip (VirtualBox): After install, enable full-screen & shared clipboard by installing **Guest Additions** 

---

## 4) Deliverable: Submit the screenshot in canvas

1. **After installation:** Start your virtual machine, log in to Ubuntu, and take a screenshot of the entire VM window. ***You will upload this screenshot in canvas.***

>> Optional practice: After you’ve installed and logged in, you can re-do the earlier Linux command-line tasks inside this virtual machine.

>> Open a Terminal (Activities → Terminal or press Ctrl+Alt+T) and run the same commands here to practice outside Codespaces.

---