## HudsonAlpha Image Streamer Artifact Bundles  
  
The CentOS 7.4 Artifact Bundle includes OS Build Plan and Plan Scripts for these use cases:
* Docker-CE bare metal
* OpenStack Queens all-in-one  
* OpenStack Queens compute node
* Kubernetes master node  
* Kubernetes worker node  

The Fedora 27 Artifact Bundle includes OS Build Plan and Plan Scripts for these use cases:
* Docker-CE bare metal

After applying these Artifact Bundles onto Image Streamer, you must create a CentOS 7.4 and/or Fedora 27 Golden Image (see docs) and Deployment Plan for each use case.  A Deployment Plan is a combination of an OS Build Plan from the Artifact Bundle and a Golden Image. Deployment Plans are referenced in OneView Profile Templates.  
