class Agent {
  //运动行为变量声明
  PVector location, velocity, acceleration;
  float maxforce, maxspeed;
  float seekX, seekY;
  float separationRate;
  float px, py;
  // float currentx,currenty;
  //疾病参数
  int state=0;
  boolean inHospital=false;
  boolean isFLow;
  int nearbyVirus=0;
  



  //定义粒子基本属性
  Agent(float x, float y) {
    //粒子锚定的位置
    // this.currentx=x;
    // this.currenty=y;
    seekX = x;
    seekY = y;
    //定义粒子群的出生位置
    int birthRandom=10;//粒子初始混乱程度
    location = new PVector(random(x-birthRandom, x+birthRandom), random(y-birthRandom, y+birthRandom));
    //保存粒子目前的位置，为描述运动做准备
    px=location.x;
    py=location.y;
    //运动描述参数
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    separationRate = 6;
    //判定粒子是否流动
    if (random(100)<=int(flowRate)) {
      isFLow=true;
      maxspeed = 3.3;
      maxforce = 0.3;
    } else {
      maxspeed = 0;
      maxforce = 0;
    }
    
  }

//定义粒子感染行为
  void applyVirusSpreading(ArrayList<Agent> people){
    for (Agent other : people) {
      if (state==0 && isFLow) {
        float d = dist(px,py, other.px,other.py);//粒子与其他粒子的绝对距离
        // float d = dist(currentx,currenty, other.currentx,other.currenty);//粒子与其他粒子的绝对距离
        if ((d > 0) && (d < spreadDist) && other.state!=0 && other.state<=REMOVAL) {//计算一定距离内的被感染的其他粒子
          nearbyVirus+=1;
          float thisTimeProbability=pow(spreadProbability,nearbyVirus);
          if (random(100)<=100*thisTimeProbability) {
            updateInfect();
          }
          // if (nearbyVirus>1) {
          //   println("Oh Lucky One,Surround Virus count is",nearbyVirus);
          // }
        }
      }
    }
  }

  //首次被感染
  void updateInfect(){
    state=1;
  }

  //计算病程
  void updateState(){
    // if (state==CURED || state==DEAD) {
    //   // println("Out of state,REMOVAL CODE,",state);
    //   return;
    // }
    //医院尝试收治
    if (state >= CONFIRMED && state < REMOVAL && !inHospital) {
      tryHospitalized();
    }
    //判定是否还在病程中
    if (state > NORMAL && state<=REMOVAL) {
      state+=1;
      // println("state",state);
    }else if (state > REMOVAL && state < CURED) {
      //判断是否死亡
      float deathRate;
      if (inHospital) {
        deathRate=deathRateHospital;
      }else{
        deathRate=deathRateNature;
      }

      if (random(100) <=deathRate) {
        beDead();          
        // println("deathRate=",deathRate,"bedscount=",bedsCount,"inHospital=",inHospital);
      }else{
        beCured();
      }
      if (inHospital) {
        dischargeHospitalized();
      }
    }
  }


  void tryHospitalized(){
    if (bedsCount<bedsTotal) {
      bedsCount+=1;
      inHospital=true;
      maxspeed = 0;
      maxforce = 0;
      // println("Remain beds",bedsTotal-bedsCount,"One Hospitalized");            
    }
  }
  void dischargeHospitalized(){ 
    bedsCount-=1;
    inHospital=false;
    // println("Remain beds",bedsTotal-bedsCount,"Discharged");            
  }

  void beDead(){
      state=DEAD;
      // deathCount+=1;
      isFLow=false;
      location.x=0;
      location.y=0;
      px=0;
      py=0;
      maxspeed = 0;
      maxforce = 0;
      //更新粒子位置,到dead栏,在frame方法里做
     
  }


  void beCured(){
      state=CURED;
      isFLow=false;
      maxspeed = 0;
      maxforce = 0;
      // println(state);
      //更新粒子位置
     
  }


//定义粒子运动行为
  //将作用力转化为加速度
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void applyBehaviors(ArrayList<Agent> people) {
    PVector separateForce = separate(people);
    PVector seekForce = seek(new PVector(seekX, seekY));
    separateForce.mult(2);
    seekForce.mult(2);
    applyForce(separateForce);
    applyForce(seekForce);
  }

  //对于其他粒子的排斥力
  PVector separate (ArrayList<Agent> people) {
    float desiredseparation = separationRate;
    PVector sum = new PVector();
    int count = 0;
    for (Agent other : people) {
      float d = PVector.dist(location, other.location);//粒子与其他粒子的绝对距离
      if ((d > 0) && (d < desiredseparation)) {//计算一定距离内的其他粒子
        PVector diff = PVector.sub(location, other.location);//粒子与其他粒子的距离向量
        diff.normalize();
        diff.div(d); 
        sum.add(diff);
        count++;
      }
    }
    // 计算出力场总的分离速度再加权修正，均分后给这个粒子，防止某个粒子被不动的粒子挤静止了
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }
  //对于锚定目标点的吸引力
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(maxspeed);
    desired.sub(velocity);
    desired.limit(maxforce);
    return desired;
  }

//更新运动位置
  void updateLocation() {
    velocity.add(acceleration);
    velocity.limit(maxspeed); 
    location.add(velocity);
    choiceColor(state);
    choiceStrokeWeight(isFLow);
    line(location.x, location.y, px, py);
    stroke(lines); 
    strokeWeight(1);
    px=location.x;
    py=location.y;
  }
  }
  //选择画笔颜色
  void choiceColor(int state) {
    if (state==NORMAL) { 
      stroke(sColor);
    } else if (state<=INFECTED) {
      stroke(shadowColor);
    } else if (state<=CONFIRMED) {
      stroke(iColor);
    } else if (state<=REMOVAL+1) {
      stroke(iColor);
    } else if (state==CURED) {
      stroke(rColor);
      // println(state);
    } else {
      stroke(dColor);
      // println(state);
    }
  }
  //选择画笔宽度,让运动的粒子与静止的粒子占用的像素相近
  void choiceStrokeWeight(boolean isFLow) {
    if (!isFLow) { 
      strokeWeight(2*strokeWeightMul);
    } else {
      strokeWeight(strokeWeightMul);
    }
  }
