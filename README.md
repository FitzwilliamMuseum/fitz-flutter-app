# fitz_museum_app

An experimental app written using flutter for the Fitzwilliam Museum,
which serves up ios and android versions.

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

    <video autoplay loop muted markdown="1">
        <source src="https://fitz-cms-images.s3.eu-west-2.amazonaws.com/screen.mp4" type="video/mp4" markdown="1" >
    </video>
