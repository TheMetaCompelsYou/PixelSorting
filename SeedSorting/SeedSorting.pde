
/*
SEED SORTING (ie: sort with edge detection or random seeds)
 Jeff Thompson | 2013 | www.jeffreythompson.org
 
 Using either a set of random seed pixels, or seed pixels defined through edge-
 detection, expand those locations step-by-step, gathering the neighboring pixel's
 color values, sorting them, and putting them back in place.
 
 The crystal-like growth results in tesselated spirals of color without altering
 or deleting any of the pixels in the source image.
 
 Much of the optimization for this code is thanks to generous help from the Processing
 forum, especially code by asimes.
 
 ** Note that we use an ArrayList to store the seed pixels, rather than a standard
 array - this allows us more flexibility to add items, and for more efficient checking
 to see if the pixel has already been stored
 
 */

// file to process
String filename = "highRes/09.jpg";

boolean edgeSeed = true;                                // use edge-detection or random seed?
boolean limitSeeds = true;                              // remove redundant seeds from edge-detection
int distThresh = 100;                                   // remove seeds that are too close
float thresh = 50;                                      // edge-detection threshold (lower = less edges)
int numRandSeeds = 30;                                  // if using random seeds, how many to start?
boolean getDiagonal = true;                             // get diagonal neighbors? true makes boxes, false diamonds
int steps = 2500;                                       // # of steps to expand/sort
boolean saveIt = true;                                  // save the result?
boolean verbose = false;                                // tell us everything about what's happening?

ArrayList<Integer> seeds = new ArrayList<Integer>();    // seed pixels to find neighbors for**
boolean[] traversed;                                    // keep track of pixels we have traversed
int step = 0;                                           // count steps through the image
PImage img;                                             // variable to load in image
boolean finishIt = false;                               // hit spacebar to stop the process manually!

void setup() {

  println("Loading image...");
  img = loadImage(filename);
  img.loadPixels();
  size(img.width, img.height);
  image(img, 0, 0);
  println("  dimensions: " + width + " x " + height + "\n");
  loadPixels();

  // intialize array of already-traversed
  traversed = new boolean[width*height];
}

void draw() {

  println("STEP: " + step + "/" + steps);

  // if we're on the first step, find the edges
  if (step == 0) {
    println("  finding edges...");
    if (edgeSeed) {
      findEdges(img);
    }
    else {
      for (int i=0; i<numRandSeeds; i++) {
        int seed = int(random(0, width*height));
        seeds.add(seed);
        traversed[seed] = true;
      }
    }
  }

  // otherwise, get neighbors, sort, and put back in place
  else {
    if (verbose) {
      println("  gathering neighboring pixels...");
    }
    updateSeeds();

    // retrieve
    if (verbose) {
      println("  getting color values from neighboring pixels...");
    }
    color[] px = new color[seeds.size()];
    for (int i = seeds.size()-1; i >= 0; i--) {
      px[i] = pixels[seeds.get(i)];
    }

    // sort the results
    if (verbose) {
      println("  sorting the results...");
    }
    px = sort(px);

    // set the resulting pixels back into place
    if (verbose) {
      println("  setting sorted pixels into place...\n");
    }
    for (int i = seeds.size()-1; i >= 0; i--) {
      pixels[seeds.get(i)] = px[i];
    }
  }

  // so long as we're not at our limit (and not manually stopped) continue!
  if (step < steps && !finishIt) {
    step++;
    updatePixels();    // update to display the results
  }
  else {
    // save results
    if (saveIt) {
      saveImage();
    }

    // all done!
    println("DONE!");
    noLoop(); 
  }
}

void keyPressed() {
  if (key == 32) {
    if (!finishIt) {
      finishIt = true;
    }
    else {
      finishIt = false;
      loop();
    }
  }
}
