/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */


import java.util.ArrayList;
import java.util.Locale;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle3D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftBall3D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftBody3D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftGrid3D;
import com.thomasdiewald.pixelflow.java.utils.DwCoordinateTransform;
import com.thomasdiewald.pixelflow.java.utils.DwStrokeStyle;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import peasy.CameraState;
import peasy.PeasyCam;
import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PShape;
import processing.opengl.PGraphics2D;
import processing.opengl.PGraphics3D;


//
// 3D Softbody Sandbox, to debug/test/profile everything.
//
// Lots of different objects are created of particle-arrays and spring-constraints.
// Everything can collide with everything and also be destroyed (RMB).
// 
// + Collision Detection
//
// Controls:
// LMB: drag particles
// MMB: drag + fix particles to a location
// RMB: disable springs, to deform objects
//
// ALT + LMB: Camera ROTATE
// ALT + MMB: Camera PAN
// ALT + RMB: Camera ZOOM
//

class GradientBackgroundCloth {
  
  int viewport_w = 1280;
  int viewport_h = 720;
  int viewport_x = 230;
  int viewport_y = 0;
  
  int gui_w = 200;
  int gui_x = viewport_w - gui_w;
  int gui_y = 0;
  
  // main library context
  DwPixelFlow context;
  
  DwPhysics.Param param_physics = new DwPhysics.Param();
  
  // // physics simulation object
  DwPhysics<DwParticle3D> physics = new DwPhysics<DwParticle3D>(param_physics);
  
  // cloth objects
  DwSoftGrid3D cloth = new DwSoftGrid3D();
  
  // list, that will store the softbody objects (cloths, cubes, balls, ...)
  ArrayList<DwSoftBody3D> softbodies = new ArrayList<DwSoftBody3D>();
  
  // particle parameters
  DwParticle.Param param_cloth_particle = new DwParticle.Param();
  
  // spring parameters
  DwSpringConstraint.Param param_cloth_spring = new DwSpringConstraint.Param();
  
  // camera
  PeasyCam peasycam;
  CameraState cam_state_0;
  
  // cloth texture
  PGraphics2D gSurface;
  
  // global states
  int BACKGROUND_COLOR = 0;
  
  // 0 ... default: particles, spring
  // 1 ... tension
  int DISPLAY_MODE = 1;
  
  // entities to display
  
  boolean DISPLAY_MESH           = true;
  
  boolean UPDATE_PHYSICS         = true;
  
  // first thing to do, inside draw()
  boolean NEED_REBUILD = false;
  
  void settings() {
    size(viewport_w, viewport_h, P3D); 
    smooth(8);
  }
  
  void setup(PApplet app) {
  
    surface.setLocation(viewport_x, viewport_y);
  
    // main library context
    context = new DwPixelFlow(app);
    context.print();
    context.printGL();
  
    ////////////////////////////////////////////////////////////////////////////
    // PARAMETER settings
    // ... to control behavior of particles, springs, etc...
    ////////////////////////////////////////////////////////////////////////////
  
    // physics world parameters
    int cs = 1500;
    
    param_physics.GRAVITY = new float[]{ 0, 0, -0.1f};
    param_physics.bounds  = new float[]{ -cs, -cs, 0, +cs, +cs, +cs };
    param_physics.iterations_collisions = 2;
    param_physics.iterations_springs    = 8;
  
    // particle parameters (for simulation)
    param_cloth_particle.DAMP_BOUNDS    = 0.19999f;
    param_cloth_particle.DAMP_COLLISION = 0.19999f;
    param_cloth_particle.DAMP_VELOCITY  = 0.19991f;
  
    // spring parameters (for simulation)
    param_cloth_spring.damp_dec = 0.999999f;
    param_cloth_spring.damp_inc = 0.059999f;
  
    // soft-body parameters (for building)
    cloth.CREATE_STRUCT_SPRINGS = true;
    cloth.CREATE_SHEAR_SPRINGS  = true;
    cloth.CREATE_BEND_SPRINGS   = true;
    cloth.bend_spring_mode      = 0;
    cloth.bend_spring_dist      = 2;
  
    // create textures
    createClothTexture();
  
    // softbodies
    createBodies();
  
    // modelview/projection
    createCam();
  
    // gui
    //createGUI();
  
    frameRate(600);
  }
  
  
  public void createClothTexture() {
  
    int tex_w = 1024;
    int tex_h = 1024;
    int ystep = 40;
    int xstep = 10;
  
    color[] colors  = {  
      #0061ff, 
      #ffff00, 
      #ff0000, 
      #009104, 
      #ff0f97, 
      #0073a8, 
      #00FF9F, 
      #00FDFF, 
    };
      
    ystep = height / 10;
    // now create the real texture
    gSurface = (PGraphics2D) createGraphics(tex_w, tex_h, P2D);
    
    color newColor = colors[int(random(0, 6))];
    color prevColor = colors[int(random(0, 6))];
    gSurface.beginDraw();
    for (int i = 0; i <height; i+=ystep) {
      for (int j = 0; j<width; j+=xstep) {
        color tweenColor = lerpColor(newColor, prevColor, float(j)/float(width));
        gSurface.fill(tweenColor);
        gSurface.noStroke();
        gSurface.rect(j, i, xstep, ystep);
        //int xPostion = lerp(0,width,20.0);
      }
      /* 
       newColor = colors[int(random(0, 6))];
       prevColor = colors[int(random(0, 6))];
       */
      newColor = prevColor;
      prevColor = colors[int(random(0, 6))];
  
  
      /*
      fill(newColor);
       rect(0, 20, 20, 20);
       fill(prevColor);
       rect(480, 20, 20, 20); */
    }
    
    gSurface.filter(BLUR,10);
  
    gSurface.endDraw();
  
  }
  
  
  public void createBodies(PApplet app) {
    // first thing to do!
    physics.reset();
  
    int nodex_x, nodes_y, nodes_z, nodes_r;
    int nodes_start_x, nodes_start_y, nodes_start_z;
    float r, g, b, s;
  
    boolean particles_volume = false;
  
    // add to global list
    softbodies.clear();
    softbodies.add(cloth);
  
    // set some common things, like collision behavior
    for (DwSoftBody3D body : softbodies) {
      body.self_collisions = true;
      body.collision_radius_scale = 1f;
    }
  
    ///////////////////// CLOTH ////////////////////////////////////////////////
    nodex_x = 100;
    nodes_y = 100;
    nodes_z = 1;
    nodes_r = 10;
    nodes_start_x = 0;
    nodes_start_y = 0;
    nodes_start_z = nodex_x; //nodes_y * nodes_r*2-200;
    r = 255;
    g = 255;
    b = 200;
    s = 1f;
    cloth.texture_XYp = gSurface;
    // cloth.setMaterialColor(color(r, g, b));
    // cloth.setParticleColor(color(r*s, g*s, b*s));
    cloth.setParam(param_cloth_particle);
    cloth.setParam(param_cloth_spring);
    cloth.create(physics, nodex_x, nodes_y, nodes_z, nodes_r, nodes_start_x, nodes_start_y, nodes_start_z);
    cloth.createShapeParticles(app, particles_volume);
    cloth.getNode(              0, 0, 0).enable(false, false, false);
    cloth.getNode(cloth.nodes_x-1, 0, 0).enable(false, false, false);
  }
  
  
  //////////////////////////////////////////////////////////////////////////////
  // draw()
  //////////////////////////////////////////////////////////////////////////////
  
  void draw() {
    if (NEED_REBUILD) {
      createBodies();
      NEED_REBUILD = false;
    }
  
    // add additional forces, e.g. Wind, ...
    int particles_count = physics.getParticlesCount();
    DwParticle[] particles = physics.getParticles();
    for (int n = 0; n < 5; n++) { 
      float[] wind = new float[3];
      for (int i = 0; i < particles_count; i++) {
        wind[1] = noise(i) * -0.5f;
        particles[i].addForce(wind);
      }
    }
  
    // update physics simulation
    if (UPDATE_PHYSICS) {
      // physics.update(1);
    }
  
    // update softbody surface normals
    for (DwSoftBody3D body : softbodies) {
      body.computeNormals();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // RENDER this madness
    ////////////////////////////////////////////////////////////////////////////
  
    background(255);
  
    // disable peasycam-interaction while we edit the model
    peasycam.setActive(false);
  
    // XY-grid, gizmo, scene-bounds
    strokeWeight(2);
    
    // lights, materials
    //lights();
    pointLight(220, 180, 140, -1000, -1000, -100);
    //ambientLight(96, 96, 96);
    directionalLight(210, 210, 210, -1, -1.5f, -2);
    lightFalloff(1.0f, 0.001f, 0.0f);
    lightSpecular(255, 0, 0);
    specular(255, 0, 0);
    shininess(20);
  
    // 3) mesh, solid
    if (DISPLAY_MESH) {
      for (DwSoftBody3D body : softbodies) {
        body.createShapeMesh(this.g);
      }
      for (DwSoftBody3D body : softbodies) {
        body.displayMesh(this.g);
      }
    }
  
  }
  
  
  
  // update all springs rest-lengths, based on current particle position
  // the effect is, that the body keeps the current shape
  public void applySpringMemoryEffect() {
    ArrayList<DwSpringConstraint> springs = physics.getSprings();
    for (DwSpringConstraint spring : springs) {
      spring.updateRestlength();
    }
  }
  
  public void createCam() {
    // camera - modelview
    double   distance = 2518.898;
    double[] look_at  = { 58.444, -48.939, 167.661};
    double[] rotation = { -0.744, 0.768, -0.587};
    peasycam = new PeasyCam(this, look_at[0], look_at[1], look_at[2], distance);
    peasycam.setMaximumDistance(10000);
    peasycam.setMinimumDistance(0.1f);
    peasycam.setRotations(rotation[0], rotation[1], rotation[2]);
    cam_state_0 = peasycam.getState();
  
    // camera - projection
    float fovy    = PI/3.0f;
    float aspect  = width/(float)(height);
    float cameraZ = (height*0.5f) / tan(fovy*0.5f);
    float zNear   = cameraZ/100.0f;
    float zFar    = cameraZ*20.0f;
    perspective(fovy, aspect, zNear, zFar);
  }

}
