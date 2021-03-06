# Fitzwilliam Museum - experimental application

[![DOI](https://zenodo.org/badge/449196657.svg)](https://zenodo.org/badge/latestdoi/449196657)

An experimental app written using flutter for the Fitzwilliam Museum,
which serves up ios and android versions.

![flutter](https://user-images.githubusercontent.com/286552/164112706-cad0e6fb-0d8d-4435-84e1-0eb6d6a66ed3.jpg)


Data is retrieved from:
 * our Directus 8 content management system
 * AWS S3 buckets
 * Our Collections endpoint

Types of content you can consume:

* 360 images of galleries
* 3D models (GLB format)
* YouTube videos
* Podcasts and audioguide files
* IIIF images via Universal viewer

A working android APK file can be found via [google drive](https://drive.google.com/file/d/1QTsEpHXNQmPSqJ0DCDqdGtyJJQr7oRiz/view?usp=sharing)


## To do

* Refactor code for all pages to use riverpod
* Refactor model viewer plus to show loading overlay
* Optimise GLB files for 3d models

## Preview


https://fitz-cms-images.s3.eu-west-2.amazonaws.com/screen.mp4
