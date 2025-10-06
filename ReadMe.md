# Azure HPC Cluster Deployment (Numerica HPC)

This repository automates the end-to-end setup of a **Windows-based HPC cluster** on Azure using **ARM templates** and **PowerShell scripts**.  
It provisions a head node, compute nodes, shared folders, and installs Office and other required components automatically.
**The aim is to run Excel-based Monte Carlo or seriatim models (e.g. those used by actuaries) on this cluster.**

---

## Overview

The deployment uses Azure VM extensions and PowerShell scripts stored in Azure Blob Storage to configure each node.  
The **wrapper.ps1** script orchestrates the execution of other setup scripts in sequence, ensuring a clean, repeatable build.

### Current components

| Component | Purpose |
|------------|----------|
| **Head Node (hpcuk1)** | Central controller for job scheduling, cluster configuration, and shared file access. |
| **Compute Nodes (hpcuk1000, etc.)** | Run HPC Pack services and execute workloads. |
| **Azure Blob Storage** | Hosts all deployment scripts (downloaded at runtime by the Custom Script Extension). |
| **Custom Script Extension** | Downloads and executes PowerShell setup scripts during VM provisioning. |

---

## ⚙️ PowerShell Scripts

### 1. `disable-ieesc.ps1`
Disables **Internet Explorer Enhanced Security Configuration (IE ESC)** to allow scripted downloads and admin access.

### 2. `install-office.ps1`
Automates installation of **Microsoft Office 365** on each node (typically for Excel-based HPC workloads or VBA-driven automation).

### 3. `create-share.ps1`
Creates a shared directory: **C:\HPCShared**

and shares it as `\\<headnode>\HPCShared` with appropriate NTFS and share permissions for the cluster.

### 4. `wrapper.ps1`
Acts as the **master script**.  
- Unblocks all downloaded `.ps1` files (to bypass Windows’ Mark-of-the-Web restriction).  
- Executes the other setup scripts in order:  
  1. `disable-ieesc.ps1`  
  2. `install-office.ps1`  
  3. `create-share.ps1`  
- Logs progress to the Azure Custom Script Extension output directory.

---

## 📈 Progress so far

- ✅ Head node and compute node templates created and deployed successfully.  
- ✅ Custom Script Extension downloads scripts and runs the wrapper sequence cleanly.  
- ✅ HPC Pack installation completes and the cluster nodes register correctly.  
- ✅ Entra ID login extension installed and verified.  
- ✅ Both AVD and head node are Entra-joined.  
- ✅ Office installation confirmed working.

---

## Challenges Remaining

| Area | Issue | Status |
|------|--------|--------|
| **Entra ID login** | Head node still not accepting Entra credentials over RDP from AVD (unsupported in Server 2022) | ⏳ Workaround: local admin or Azure Bastion |
| **File sharing** | `\\hpcuk1\HPCShared` inaccessible from AVD due to Entra-only authentication | ⏳ Fix: use local account or AAD DS |
| **HPC user access** | Users can’t yet submit jobs using Entra accounts | ⏳ Fix: domain join via Azure AD DS or AD DS |
| **Automation cleanup** | Add log collection and post-run cleanup of downloaded scripts | 🔧 Planned |

---

## Next Steps

1. Evaluate **Azure AD Domain Services (AAD DS)** for cluster domain management.  
2. Add **job submission scripts** for testing HPC Pack workloads.  
3. Automate **log upload** and validation checks.  
4. Upgrade **AADLoginForWindows** to v2.2.0.0 cluster-wide.

---

## Folder Structure

/scripts
├─ disable-ieesc.ps1
├─ install-office.ps1
├─ create-share.ps1
└─ wrapper.ps1
hpc-cluster-template.json
hpc-cluster-parameters.json           <---not included here
readme.md
.gitignore


---

## 🧩 Author & Contact
*Nasrat Kamal*  

---