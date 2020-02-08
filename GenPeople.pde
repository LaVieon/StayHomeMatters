void genPeople() {
  people = new ArrayList<Agent>();
  // 定义初始的高斯分布
  pixel_list=new int [width*height];
  for (int i = 0; i < totalPopulation; ++i) {
    int x=abs(int(density*randomGaussian()+height/2));
    int y=abs(int(density*randomGaussian()+height/2));
    if (x < height && y<height-2*borderWidth && x*y < width*height) {
      pixel_list[y*width+x]=1;
    }
  }

  for (int x=borderWidth; x<int(width-2*borderWidth); x++) {
    for (int y=borderWidth; y<int(height-2*borderWidth); y++) {
      int xb=x+borderWidth;
      int yb=y+borderWidth;
      if (pixel_list[int(yb)*width+int(xb)]==1) {
        people.add(new Agent(xb, yb));
        strokeWeight(1.5*strokeWeightMul);
        point(xb, yb);
        strokeWeight(strokeWeightMul);
        cutA+=1;
        // println("人群总量="+cutA);
      }
    }
  }
}

void initPatents() {
  for (Agent a : people) {
    if (random(100)<=int(100*patients/totalPopulation)) {
      a.state= int(random(INFECTED));
      // println("state=",a.state); //<>//
    }
    //     else {
    //         println("state=",0);
    //     }
  }
}


//   void flowPeople() {
//     for (Agent f : people) {
//       if (random(100)<=int(100-flowRate)) {
//         f.isFLow=false;
//         // println("isFLow=", false);
//       } else {
//         f.isFLow=true;
//         // println("isFLow=", true);
//       }
//     }
//   }
