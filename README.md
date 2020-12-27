# topdf
A minimal program to convert just images to PDF

To build this program, you need a D environnement. Then, just type

```bash
dub -b release
```

The aim of topdf is to be productive quickly. I created this little programme in 30 minutes to make my life easier when I have a lot of homework to be sent online from images took from my phone. To use it, simply drag all the images you want to convert (in **PNG** or **JPG** format only) onto the application icon (on Linux, you might write the path of the images to the terminal). The application will create a unique resulting folder in which each image will have been converted to PDF.

You can test with the few test images that have been provided. Scaling in case the image exceeds the dimensions of a PDF page are correctly managed, the original quality is preserved, no image will be enlarged.
